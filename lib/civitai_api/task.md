# CivitAI API Client Migration

> Migrating `bun-civitai-browser-master/src/civitai-api/v1/` (TypeScript) → `lib/civitai_api/` (Dart/Flutter)

---

## 1. Decisions (Final)

| Concern | Choice | Rationale |
|---|---|---|
| Result type | `dartz` `Either<L, R>` | FP monad with `map`, `flatMap`, `fold` — replaces neverthrow |
| Data models | Freezed + json_serializable | Immutable, generated unions, `copyWith`, pattern matching |
| Validation | `validart` | Already in pubspec, closest to ArkType |
| HTTP | `dio` with interceptors | Already in pubspec, maps cleanly to `ky` |
| Architecture | **Functional Programming** | Functions > classes, no OOP patterns, pure transformations |
| Download URL | Dio with `followRedirects` | Native support, no raw fetch needed |
| Error types | Simplified to 2 variants | `ApiError` and `NetworkError` — merged 401/400/404 into `ApiError(statusCode, message)` |

## 2. FP Architecture vs OOP (TS → Dart)

### What changes

| TS (OOP) | Dart (FP) |
|---|---|
| `class CivitaiApiClientImpl` with injected endpoints | `CivitaiApi` typedef — a record of function bundles |
| `class ModelsEndpointImpl` with constructor DI | `createModelsApi(client)` — factory function returning a record of functions |
| `class CivitaiClient` wrapping `ky` | `createHttpClient(dio)` — function returning `{get, post, put, delete}` |
| Method chaining on class instances | Pure function composition with `Either` pipelines |
| ArkType schema objects | Freezed `@freezed` data classes + validart validators |

### Core pattern: Closure-based dependency injection

```dart
// Instead of class with injected dependencies:
//   class ModelsEndpointImpl { ModelsEndpointImpl(this.client); }

// We use a factory function that captures the client in closures:
ModelsApi createModelsApi(HttpClient client) => (
  list: (opts) => client.get('models', queryParams: opts?.toQueryParams()),
  getById: (id) => client.get('models/\$id'),
  // Each function closes over `client` — no `this`, no class
);
```

This is the **module pattern** — a function returns a record of functions, each closing over shared state. Pure FP: no classes, no `this`, no inheritance.

## 3. Directory Structure

```
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
├── utils.dart                    # Pure utility functions (URL parsing, file type, etc.)
└── task.md                       # This file
```

## 4. Core Types

### Error type (simplified, Freezed sealed union)

```dart
@freezed
sealed class CivitaiError with _$CivitaiError {
  const factory CivitaiError.api(int statusCode, String message) = ApiError;
  const factory CivitaiError.network(String message, [Object? cause]) = NetworkError;
}
```

### HTTP client (function record)

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

HttpClient createHttpClient(Dio dio) => (/* ... closures ... */);
```

### Endpoint API (function record)

```dart
typedef ModelsApi = ({
  Future<Either<CivitaiError, ModelsResponse>> Function([ModelsRequestOptions?]) list,
  Future<Either<CivitaiError, ModelById>> Function(int) getById,
  Future<Either<CivitaiError, Model>> Function(int) getModel,
  Future<Either<CivitaiError, ModelsResponse>> Function(String) nextPage,
});

ModelsApi createModelsApi(HttpClient client) => (
  list: (opts) => client.get('models', queryParams: opts?.toJson()),
  getById: (id) => client.get('models/\$id'),
  getModel: (id) => client.get('models/\$id').flatMap(modelId2Model),
  nextPage: (url) => client.get(url),
);
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
  // ... configure interceptors for auth ...
  final http = createHttpClient(dio);
  return (
    models: createModelsApi(http),
    creators: createCreatorsApi(http),
    modelVersions: createModelVersionsApi(http),
    tags: createTagsApi(http),
  );
}
```

## 5. Usage Example

```dart
final api = createCivitaiApi(apiKey: 'my-key');

// Railway-oriented with dartz Either
final result = await api.models.list(
  ModelsRequestOptions(limit: 20, query: 'pony'),
);

result.fold(
  (error) => switch (error) {
    ApiError(:final message) => print('API error: \$message'),
    NetworkError(:final message) => print('Network error: \$message'),
  },
  (response) => print('Found \${response.items.length} models'),
);

// Or compose with flatMap
final model = await api.models
    .getById(123)
    .flatMap((m) => api.modelVersions.getById(m.modelVersions.first.id));
```

## 6. Files to Create (in dependency order)

| # | File | What it is |
|---|---|---|
| 1 | `errors.dart` | Freezed sealed union `CivitaiError` |
| 2 | `config.dart` | Freezed `CivitaiConfig` |
| 3 | `models/enums.dart` | Plain enums: `ModelType`, `BaseModel`, `Sort`, `Period`, `CheckpointType`, `NsfwLevel`, `AllowCommercialUse` |
| 4 | `models/shared.dart` | Freezed: `ModelFile`, `ModelImage`, `ModelVersionStats`, `ModelStats`, `PaginationMetadata` |
| 5 | `models/creator.dart` | Freezed: `Creator`, `CreatorsResponse` |
| 6 | `models/model.dart` | Freezed: `Model`, `ModelVersion`, `ModelsResponse` |
| 7 | `models/model_id.dart` | Freezed: `ModelById`, `ModelByIdVersion` |
| 8 | `models/model_version.dart` | Freezed: `ModelVersionEndpointData` |
| 9 | `models/tag.dart` | Freezed: `TagItem`, `TagsResponse` |
| 10 | `models/request_options.dart` | Freezed: `ModelsRequestOptions`, `CreatorsRequestOptions`, `TagsRequestOptions` |
| 11 | `utils.dart` | Pure functions: `modelId2Model`, `extractFilenameFromUrl`, `obj2QueryParams`, `getFileType`, etc. |
| 12 | `http_client.dart` | `createHttpClient()` — wraps Dio, returns `HttpClient` record |
| 13 | `endpoints/models.dart` | `createModelsApi()` |
| 14 | `endpoints/creators.dart` | `createCreatorsApi()` |
| 15 | `endpoints/model_versions.dart` | `createModelVersionsApi()` |
| 16 | `endpoints/tags.dart` | `createTagsApi()` |
| 17 | `civitai_api.dart` | Barrel + `createCivitaiApi()` top-level factory |

## 7. FP Best Practices for This Project

| Principle | Application |
|---|---|
| **Pure functions** | `utils.dart` functions have no side effects; `modelId2Model` is a pure `ModelById → Either<Error, Model>` |
| **Immutable data** | All Freezed models are immutable; use `copyWith` for updates |
| **Either for errors** | No exceptions in API layer; every async call returns `Either<CivitaiError, T>` |
| **flatMap chaining** | Compose dependent calls: `getById().flatMap(getVersion).flatMap(resolveUrl)` |
| **Closure DI** | Module factory functions close over `HttpClient` — no service locator or DI framework needed |
| **Records over classes** | Dart 3 records (`({...})`) for lightweight structural types without nominal overhead |
| **Pattern matching** | Dart 3 `switch` on sealed classes for exhaustive error handling |

## 8. Dependencies to Add

```yaml
# pubspec.yaml additions
dependencies:
  dartz: ^0.10.1          # Either, Option, Task, functional combinators
  freezed_annotation: ^3.0.0   # Immutable data class annotations
  json_annotation: ^4.9.0      # JSON serialization annotations

dev_dependencies:
  build_runner: ^2.4.0         # Code generation runner
  freezed: ^3.0.0              # Freezed code generator
  json_serializable: ^6.8.0    # JSON serialization generator
```