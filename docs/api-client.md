# API Client Architecture

> FP-style CivitAI REST client — migrated from `bun-civitai-browser` (TypeScript) to Dart/Flutter.

---

## Design Decisions

| Concern | Choice | Rationale |
|---------|--------|-----------|
| Result type | `dartz` `Either<L, R>` | FP monad with `map`, `flatMap`, `fold` — replaces neverthrow |
| Data models | Freezed + json_serializable | Immutable, generated unions, `copyWith`, pattern matching |
| HTTP | `dio` with interceptors | Already in pubspec, maps cleanly to `ky` |
| Architecture | **Functional Programming** | Functions > classes, no OOP patterns, pure transformations |
| Download URL | Dio with `followRedirects` | Native support, no raw fetch needed |
| Error types | 2 variants | `ApiError` and `NetworkError` — merged 401/400/404 into `ApiError(statusCode, message)` |

---

## FP Architecture

### Closure-based Dependency Injection

Instead of classes with injected dependencies, we use factory functions that capture shared state in closures:

```dart
// Module pattern — a function returns a record of functions,
// each closing over shared state. No classes, no this, no inheritance.

ModelsApi createModelsApi(HttpClient client) => (
  list: (opts) => client.get('models', queryParams: opts?.toQueryParams()),
  getById: (id) => client.get('models/$id'),
);
```

### TS (OOP) → Dart (FP) Mapping

| TS (OOP) | Dart (FP) |
|----------|-----------|
| `class CivitaiApiClientImpl` with injected endpoints | `CivitaiApi` typedef — a record of function bundles |
| `class ModelsEndpointImpl` with constructor DI | `createModelsApi(client)` — factory function returning a record of functions |
| `class CivitaiClient` wrapping `ky` | `createHttpClient(dio)` — function returning `{get, post, put, delete}` |
| Method chaining on class instances | Pure function composition with `Either` pipelines |

---

## Directory Structure

```txt
lib/civitai_api/
├── civitai_api.dart              # Barrel + createCivitaiApi() factory
├── config.dart                   # Freezed CivitaiConfig
├── errors.dart                   # Freezed sealed union: ApiError | NetworkError
├── http_client.dart              # createHttpClient(): returns get/post/put/delete
├── endpoints/
│   ├── models.dart               # createModelsApi(client) → ModelsApi record
│   ├── creators.dart             # createCreatorsApi(client) → CreatorsApi record
│   ├── model_versions.dart       # createModelVersionsApi(client) → ModelVersionsApi record
│   └── tags.dart                 # createTagsApi(client) → TagsApi record
├── models/
│   ├── model.dart                # Freezed Model, ModelVersion, ModelsResponse
│   ├── model_id.dart             # Freezed ModelById, ModelByIdVersion
│   ├── model_version.dart        # Freezed ModelVersionEndpointData
│   ├── creator.dart              # Freezed Creator, CreatorsResponse
│   ├── tag.dart                  # Freezed TagItem, TagsResponse
│   ├── shared.dart               # Freezed ModelFile, ModelImage, PaginationMetadata, etc.
│   ├── enums.dart                # Plain Dart enums: ModelType, BaseModel, Sort, Period, etc.
│   └── request_options.dart      # Freezed ModelsRequestOptions
└── utils.dart                    # Pure utility functions (URL parsing, file type, etc.)
```

---

## Core Types

### Error (Freezed sealed union)

```dart
@freezed
sealed class CivitaiError with _$CivitaiError {
  const factory CivitaiError.api(int statusCode, String message) = ApiError;
  const factory CivitaiError.network(String message, [Object? cause]) = NetworkError;
}
```

### HTTP Client (function record)

```dart
typedef HttpClient = ({
  Future<Either<CivitaiError, T>> Function<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) get,
  Future<Either<CivitaiError, T>> Function<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) post,
  // ... put, delete
});
```

### Main API (top-level record)

```dart
typedef CivitaiApi = ({
  ModelsApi models,
  CreatorsApi creators,
  ModelVersionsApi modelVersions,
  TagsApi tags,
});

CivitaiApi createCivitaiApi({String? apiKey, String? baseUrl}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl ?? 'https://civitai.com/api/v1',
    connectTimeout: const Duration(seconds: 30),
  ));
  final http = createHttpClient(dio);
  return (
    models: createModelsApi(http),
    creators: createCreatorsApi(http),
    modelVersions: createModelVersionsApi(http),
    tags: createTagsApi(http),
  );
}
```

---

## Usage Example

```dart
final api = createCivitaiApi(apiKey: 'my-key');

final result = await api.models.list(
  ModelsRequestOptions(limit: 20, query: 'pony'),
);

result.fold(
  (error) => switch (error) {
    ApiError(:final message) => print('API error: $message'),
    NetworkError(:final message) => print('Network error: $message'),
  },
  (response) => print('Found ${response.items.length} models'),
);

// Compose with flatMap
final model = await api.models
    .getById(123)
    .flatMap((m) => api.modelVersions.getById(m.modelVersions.first.id));
```

---

## FP Best Practices

| Principle | Application |
|-----------|-------------|
| **Pure functions** | `utils.dart` functions have no side effects |
| **Immutable data** | All Freezed models are immutable; use `copyWith` for updates |
| **Either for errors** | No exceptions in API layer; every async call returns `Either<CivitaiError, T>` |
| **flatMap chaining** | Compose dependent calls: `getById().flatMap(getVersion).flatMap(resolveUrl)` |
| **Closure DI** | Module factory functions close over `HttpClient` — no service locator needed |
| **Records over classes** | Dart 3 records for lightweight structural types |
| **Pattern matching** | Dart 3 `switch` on sealed classes for exhaustive error handling |

---

## Dependencies

```yaml
dependencies:
  dartz: ^0.10.1
  freezed_annotation: ^3.0.0
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^3.0.0
  json_serializable: ^6.8.0
```
