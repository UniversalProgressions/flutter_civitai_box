# 项目进展记录（Project Progress）

> 记录 CivitAI Box 的功能进展、剩余工作和关键决策。
> 最后更新：2026-08-09

---

## 项目概览

**CivitAI Box** — 基于 Flutter 的 Windows 桌面应用，用于浏览、管理和下载 CivitAI 的 AI 模型。

主要模块：

| 模块 | 目录 | 说明 |
| ------ | ------ | ------ |
| CivitAI API 客户端 | `lib/civitai_api/` | Dio 驱动的 REST 客户端 |
| 数据库 | `lib/db/` | SQLite（sqflite），CivitAI 镜像 + 用户自定义表 |
| 下载系统 | `lib/services/download/` | 下载队列 + Magazine 下载系统 |
| UI | `lib/ui/` | 本地模型库、下载、统计、设置 |
| 打包与发布 | `docs/packaging.md` + `.github/workflows/` | Fast Forge 打包 MSIX/DMG/AppImage + GitHub Releases |
| 文档 | `docs/` | 架构、数据库、下载、UI、打包设计文档 |

---

## 最近里程碑

### ✅ 2026-08-09 — Fast Forge 打包 + GitHub Releases 发布（三平台 CI 全部跑通 🎉）

用 Fast Forge 0.6.12 打通三大桌面平台的安装包打包与 GitHub Releases 发布：

| 平台 | 格式 | 配置 | 状态 |
| ------ | ------ | ------ | ------ |
| Windows | MSIX | `windows/packaging/msix/make_config.yaml` | ✅ 36.2 MB |
| macOS | DMG | `macos/packaging/dmg/make_config.yaml` | ✅ 38.4 MB |
| Linux | AppImage | `linux/packaging/appimage/make_config.yaml` | ✅ 114 MB |

- **结果**：GitHub Actions Run 4 三平台全部通过，**draft release `v1.0.0`** 已生成
  （含 3 个安装包 + 源码 + 自动 changelog），等人工确认后 Publish。

- **决策**：Linux 只保留 AppImage，不做 DEB/RPM。
- **发布工作流**：`.github/workflows/release.yml`（tag `v*` 推送或手动触发 → 矩阵构建 → `fastforge publish` 上传到 GitHub Releases）。
- **版本管理与发布策略（2026-08-09 增补）**：
  - **单一版本源**：`pubspec.yaml` 的 `version` 是唯一版本来源；新增 `prepare` job 自动从
    pubspec 读版本 → 创建 tag `v<version>`，并校验 pubspec 与 tag 一致。
  - **手动触发免输入**：workflow_dispatch 无需填版本号，改 pubspec → 提交 → 点 Run workflow 即可。
  - **draft 草稿发布**：改用 `softprops/action-gh-release` 上传（不再用 `fastforge publish`），
    创建 draft release + 自动 release notes + `overwrite: true`（重跑覆盖同名资产）。
    人工确认后手动 Publish release，避免"手滑公开"。
  - 详细流程见 `docs/packaging.md`。
- **关键发现/坑**：
  - fastforge 0.6.12 的 `MakeMsixConfig` 所有字段都是字符串类型——YAML 里布尔值要写成 `"false"`（否则 `type 'bool' is not a subtype of type 'String?'`）。
  - `install_certificate: "false"` 必须设置——否则 msix 包会弹"是否安装证书"的交互提示，CI/脚本会卡死；设为 false 后仍会用内置 `Msix Testing` 测试证书签名。
  - `languages` 要写成逗号分隔字符串（`en-US,zh-CN`），不能是 YAML 列表。
  - `add_execution_alias` 是无效键（msix 包没有对应 CLI 参数），会导致 `FormatException`，已移除。
  - `media_kit` 跨平台：`pubspec.yaml` 补了 `media_kit_libs_macos_video` + `media_kit_libs_linux`。
  - macOS bundle ID 已从 `com.example.*` 改为 `com.universalprogressions.civitaibox`。
  - **CI 三平台踩坑（已全部修复，Run 4 通过）**：
    - Linux 缺 ALSA → 装 `libasound2-dev`（volume_controller 需要）。
    - Linux 缺 mpv → 装 `libmpv-dev`（media_kit_video 需要）。
    - Windows 上 fastforge 是 `fastforge.bat`，Git Bash 裸名 `fastforge` 不解析 `.bat`
      （exit 127）→ Package 步骤 Windows 显式调用 `$PUB_CACHE/bin/fastforge.bat`。
    - fastforge 路径统一用 `$PUB_CACHE/bin`（flutter-action 设置的环境变量）。
- **待办**：正式发布前替换品牌图标（当前用 Flutter 默认图标占位）、配置真实签名证书。
- **详细文档**：`docs/packaging.md`（操作手册）、`docs/packaging-guide.md`（完整指南 + 16 个踩坑记录）。

### ✅ 2026-06-07 — Magazine 下载系统（Load → Review → Fire）— 提交 `ac77bc0`

TDD 实现的"装填 → 审阅 → 开火"下载暂存系统，已完整提交（引擎 + UI + 崩溃恢复）。

| 模块 | 状态 | 测试 |
| ------ | ------ | ------ |
| 数据模型 `MagazineItem` / `LoadResult` / `FireEvent` | ✅ | 54 |
| 数据库 CRUD `download_magazine` 表（19 列） | ✅ | 11 |
| `load()` 引擎（API 拉取 + 校验 + 持久化） | ✅ | 13 |
| `fire()` 引擎（顺序下载、3 次重试后 JAM、unjam） | ✅ | 9 |
| UI — `DownloadMagazineTab` + `MagazineItemTile` | ✅ | 11 widget |
| `DownloadPage` TabBar 集成（Fetch + Magazine） | ✅ | — |
| 崩溃恢复 `_recoverMagazineFromCrash()` | ✅ | — |

详细设计见 `docs/download/`。

---

## 代码健康状态

- **`flutter analyze`**：基本干净，仅 1 个 info 级 lint（`LoadError_` 命名，freezed 常见模式，无害）。
- **测试**：`test/download` 下 **98/98 全部通过**（2026-08-08 修复剩余工作 #1 后全绿）。

---

## 剩余工作与决策

### 1. 修复 4 个失败的 widget 测试（已完成 ✅）

- **状态**：已修复（2026-08-08）
- **原问题**：`test/download/download_magazine_tab_test.dart` 中 4 个测试失败，两个独立根因：
  1. **Load/Fire 按钮禁用测试**（2 个）：`DownloadMagazineTab()` 未传 `initialRounds`，触发 `initState` 中的真实 SQLite 读取；而 widget 测试环境未初始化 `databaseFactory = databaseFactoryFfi`，抛 `databaseFactory not initialized`。
  2. **列表渲染测试**（2 个）：断言 `find.text('Model A')`，但 tile 实际渲染的是 `'Model A — v1.0'`（模型名 + 版本名拼接），字符串不匹配。
- **修复方案**：
  1. 按钮禁用测试改为传入 `initialRounds: []`，符合设计意图（widget 测试走同步路径、不碰数据库）。
  2. 渲染测试改用 `find.textContaining('Model A')` 等，不再依赖拼接格式。
- **验证**：`flutter test test/download` → **98/98 全部通过**；`flutter analyze` 无新增问题。

### 2. Phase 6 集成测试（待办 📋）

- **状态**：待办
- **描述**：`test/download/magazine_integration_test.dart` — 端到端测试：
  - Load → Fire → 验证磁盘 JSON 文件 → 验证 DB 记录
  - Load → Fire 失败 → 重试 3 次 → JAM → Unjam（跳过）→ 继续
  - App 重启模拟：Load → Fire 中断 → 恢复 → 继续
- **备注**：此前没有相关实现记录，本条目仅用于记录该计划，后续需要实现。

### 3. Rust FFI — 已决定移除（已清理 ✅）

- **状态**：已移除（决策日期 2026-08-08）
- **决策**：**暂不集成 Rust**。原因：尚未完全理解 `flutter_rust_bridge` 的原理。
- **已执行清理**：
  - 移除 `pubspec.yaml` 中的 `flutter_rust_bridge: 2.11.1` 依赖
  - 移除 `pubspec.lock` 中的对应条目（通过 `flutter pub get` 更新）
  - 更新 `docs/download/` 下文档中关于 Rust FFI 的描述
- **未来**：若后续需要支持 Rust，需重新引入 `flutter_rust_bridge` 并创建 `rust/` 目录。

### 4. 本地 API 服务 — 预留（暂不开发 ⏸️）

- **状态**：预留，暂不开发（决策日期 2026-08-08）
- **需求**：为应用设计一个 **API**，让其他外部应用程序（例如 SD 绘图软件）能够与应用交互。
- **依赖**：`shelf`、`shelf_open_api`、`shelf_open_api_generator`（已加入 `pubspec.yaml`，目前未被任何代码使用）。
- **决策**：**保留依赖，暂不开发**。待确定 API 设计方案后再启动。

### 5. 下载功能与 UI 改进（分析中 🔍 → 2026-08-08）

- **触发原因**：实际使用发现下载功能不顺手、且存在重复下载任务（任务失败后重新提交/重下会再生成一份）。
- **分析文档**：`docs/download/analysis.md`（完整根因 + 痛点 + 改进方案）。
- **已确认的重复任务根因**：
  - 重试/重下路径**新建批次**而不是复用原任务（Magazine 自动重试每次 `enqueueBatch` 新时间戳 batchId；Fetch 重下同理）。
  - `hasActiveBatch` 方法已写好但**从未接线调用**。
  - batchId 用时间戳生成，每次必不相同，无法幂等。
- **已决策**：**去掉 Fetch 流程，只保留 Magazine 单一下载逻辑**（简化、便于维护）。删除 `DownloadFetchTab`，`DownloadPage` 简化为 Magazine + 共享队列区。
- **Magazine Load**：仅支持 Version ID（已确认，暂不加 Model ID）。
- **已实施（2026-08-08）**：
  - P0 修复重复任务：Magazine 重试复用批次（`retryBatch` / `tasksForVersion`），不再新建批次。
  - P2 去掉 Fetch：`DownloadPage` 改为 Magazine 单页，删除 `download_fetch_tab.dart`。
  - P1 队列可读性：`download_task` 加 `model_name`/`version_name` 列（DB v4 迁移），批次卡片显示模型名。
  - P1 控制按钮：批次卡片 取消/重试，队列区 暂停/恢复/清除历史。
  - P0 并发保护 + 启动去重：`_activePaths` 在途路径保护、`_deduplicateActiveBatches`。
  - P0 任务幂等：`download_task` 加 `(model_version_id, target_path)` 唯一索引（DB v5 迁移），
    插入冲突改 `ignore`，复用逻辑处理"全部已完成"场景。
  - P1 进度增强：任务行显示实时下载速度 + 当前文件高亮。
  - 删除模型 → 清该版本 `download_task` 记录；取消未完成任务 → 清理其部分文件。
  - 设计确认：媒体文件始终与模型一起下载/删除，**不做"仅模型"选项**。
  - **Magazine Load 支持 Model ID**：标签页顶部 Version/Model 切换，Model 模式下浏览版本→勾选→装填（单次 API 调用）。
  - **下载启动慢修复**：`resolveFileDownloadUrl` 改为不跟随重定向、只读 `Location` 头（原先 GET+followRedirects 会把整个文件下载进内存，每个文件被下两遍且串行 → 下载迟迟不开始）；URL 解析改并行。
  - 修复既有 `utils_test` 失败。
- **验证**：`flutter analyze` 无新增问题；**全项目 343/343 测试通过**。
- **待办**：无（下载功能 P0/P1/P2 + 性能修复全部完成）。
- **详细进度**：见 `docs/download/analysis.md`。

---

## 测试状态

| 测试文件 | 数量 | 状态 |
| ---------- | ------ | ------ |
| `magazine_item_test.dart` | 25 | ✅ |
| `load_result_test.dart` | 12 | ✅ |
| `fire_event_test.dart` | 17 | ✅ |
| `download_magazine_database_test.dart` | 11 | ✅ |
| `download_magazine_resolver_test.dart` | 22 | ✅ |
| `magazine_item_tile_test.dart` | 5 | ✅ |
| `download_magazine_tab_test.dart` | 6 | ✅（已修复，见剩余工作 #1） |
| `magazine_integration_test.dart`（Phase 6） | — | ⬜ 未开始（见剩余工作 #2） |
