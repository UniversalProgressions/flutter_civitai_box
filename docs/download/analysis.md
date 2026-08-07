# 下载功能 & UI 深度分析

> 分析日期：2026-08-08
> 目的：记录下载功能与 UI 的问题根源与改进方案，作为后续改动的对照文档。
> 关联文档：`docs/download/design.md`（原设计）、`docs/download/magazine-design.md`（Magazine 设计）

---

## 一、用户反馈的实际问题

1. 下载功能"用起来并不顺手"，日常使用体验差。
2. 存在**重复的下载任务**，尤其是**任务失败后重新提交/重下时会再生成一份**。

---

## 二、重复下载任务的根源（代码级）

### 根源 1：`hasActiveBatch` 写了但从未被调用 ⚠️ 核心

- `download_database.dart` 已有现成去重方法 `hasActiveBatch(modelVersionId)`（检查某版本是否已有未完成的批次）。
- 设计文档也写明："Duplicate enqueue (same version already in queue) — Check existing batch, offer overwrite or skip"。
- **但全项目没有任何地方调用它**（仅有定义，零调用）。
- 后果：用户重复点下载、同一版本从多个入口下载时完全无拦截。

### 根源 2：失败后的"重下/重试"会创建新的批次而不是复用原任务 ⚠️ 用户确认的主要场景

两条重试路径都会**新建批次**而不是复用原任务行：

- **Magazine 自动重试**：`_productionDownloadRound` 每次执行都生成新 `batchId`
  （`'mag-$modelId-$versionId-${timestamp}'`）并 `enqueueBatch`。一轮失败重试 3 次，
  每次都在 `download_task` 表里**新增一整组任务**，旧的 failed 批次仍留在表里 →
  **同一个文件在队列里有 3 组任务**。
- **手动重下（Fetch）**：失败后用户重新 Fetch 并点 Download，`batchId`
  （`'{modelId}-{versionId}-{timestamp}'`）时间戳不同 → 全新一组任务，旧 failed 批次残留。

### 根源 3：batchId 用时间戳生成，每次必不相同

- 即使下载同一个版本的同几个文件，时间戳不同 → `batchId` 不同 → 任务主键
  `id = '$batchId-f-${f.id}'` 也不同 → 数据库 `ConflictAlgorithm.replace` 无法拦截。

### 根源 4：`_processBatch` 不感知其它批次（并发写同一文件）

- 每个 `enqueueBatch` 立即启动 `_processBatch` 并发下载。
- 若两个批次同时下载同一个 `target_path` 的文件，可能并发写入同一文件 →
  浪费带宽、甚至文件写坏。`_fileExists` 只能兜住"已完整下完"的情况。

### 根源 5：重启恢复 + 历史堆积

- 启动 `init()` 会对每个 active batch 整体重跑 `_processBatch`（有 `fileExists` 兜底，但冗余）。
- 完成后任务永不自动清理，也无 UI 清理入口 → 队列堆积大量重复的 completed 批次。

### 根源 6：Fetch 与 Magazine 两条路互不感知

- 同一版本既可在 Fetch 直接下，也可装进 Magazine 再 Fire，各自前缀不同
  （`{modelId}-{versionId}-ts` vs `mag-...`）→ 两条路可同时下载同一版本。

> **结论**：重复任务不是偶发小毛病，而是**去重机制缺失 + batchId 时间戳设计 +
> 重试路径新建批次**共同导致的确定性 bug。`hasActiveBatch` 方法已写好，只差接线。

---

## 三、UI 交互不顺手的痛点

### 痛点 1：队列里认不出"在下载什么" 🔴

- `DownloadTask` 数据模型只有 `modelId` / `modelVersionId`，**没有模型名/版本名**。
- 批次卡片标题只能显示 `"11821 / v1805971"` 一串数字，多任务同时下载时无法区分。

### 痛点 2：控制按钮严重缺失

- 队列引擎已实现 `cancelBatch`、`clearHistory`、`pause()`/`resume()`，但 **UI 一个都没接**。
- 唯一接上的是失败任务的"重试"图标。README 宣称的
  "Pause / Resume / Cancel controls per batch" 实际 UI 并不存在。

### 痛点 3：Fetch 是"单模型向导"，无法批量管理

- 一次只能输入一个 ID → 看模型 → 勾版本 → 下载 → 返回，连下多个要反复走流程。
- `_fetchByModelId` 对每个版本逐个调 API（N 版本 = N 请求），版本多时很慢。

### 痛点 4：Fetch 与 Magazine 双流程，心智负担重

- 下载页有 Fetch（直下）和 Magazine（暂存→审阅→开火）两套哲学，定位重叠、互相看不懂。
- **决策（2026-08-08）：去掉 Fetch，只保留 Magazine 单一下载流程。**

### 痛点 5：进度信息单薄

- 只有百分比进度条，无下载速度、剩余时间、当前文件高亮。
- 媒体文件固定全量下载（5~20 张图），无"只要模型文件/不要预览图"选项。

---

## 四、改进方案（分层）

### P0 — 修复重复任务（功能性 bug）【优先级最高】

1. **重试复用原任务**（针对用户确认的主场景）：
   - Magazine `fire()`：重试失败轮次时，**先清理/重置该版本已存在的 failed 任务**
     再重新入队；或在 `_productionDownloadRound` 里按 `(model_version_id, target_path)`
     查找已存在的任务，重置为 pending 复用，而不是新建。
   - 重下（若保留任何入口）同样复用原 batch。
2. **接线去重守卫**：入队前调用 `hasActiveBatch(modelVersionId)`，已有未完成任务 →
   提示"已在队列中"，不再重复入队。
3. **任务级幂等**：`download_task` 增加按 `(model_version_id, target_path)` 的
   唯一约束/去重逻辑，让同一文件在队列里只有一个任务。
4. **文件级并发保护**：`_downloadWithConcurrency` 增加"正在下载的路径集合"，
   避免两个批次写同一文件。
5. **启动恢复去重**：`init()` 时合并/取消完全重复的批次。

### P1 — 提升日常体验（UI）

1. **批次卡片显示模型名/版本名**：`DownloadTask` 增加 `modelName`/`versionName` 字段
   （入队时带上），卡片标题改为 `模型名 — 版本名`。投入产出比最高。
2. **补齐控制按钮**：批次卡片加 取消/重试；页面加 暂停/恢复、清除已完成历史。
3. **进度信息增强**：下载速度、当前文件；提供"仅模型文件/含预览图"选项。

### P2 — 架构与流程（已决策）

1. **去掉 Fetch，只保留 Magazine**：下载页只保留 Magazine 标签 + 共享队列区；
   删除 `DownloadFetchTab`；`DownloadPage` 简化为单一流程。
2. **Magazine Load 扩展**（可选）：支持按 Model ID 添加（浏览版本→勾选→入队），
    吸收 Fetch 的浏览能力，避免能力倒退。

---

## 五、实施进度（2026-08-08）

### 已实施 ✅

- **P0-1 Magazine 重试复用批次**：`DownloadQueue` 新增 `nonCompletedTasksForVersion()` +
  `retryBatch()`；`_productionDownloadRound` 入队前先查该版本是否已有未完成任务，
  有则复用原批次（失败则重置重跑，进行中则等待），**不再新建批次** → 修复"失败重试导致重复任务"。
- **P0-4 文件级并发保护**：`_downloadOne` 增加在途路径集合 `_activePaths`，两个批次不会并发写同一文件
  （等待期间重复检查文件是否已由其它批次完成）。
- **P0-5 启动恢复去重**：`init()` 时调用 `_deduplicateActiveBatches()`，同一版本分散在多个批次的
  历史任务只保留最新批次、删除其余 → 清理用户数据库中已有的重复任务。
- **P2 去掉 Fetch**：`DownloadPage` 改为 Magazine 单页 + 共享队列区，删除 `download_fetch_tab.dart`。
- **P1-1 队列可读性**：`download_task` 表新增 `model_name` / `version_name` 列（DB 版本 3→4），
  `DownloadTask` 模型 + Magazine 入队填充名字，批次卡片标题显示 `模型名 - 版本名`（无名字时回退到数字 ID）。
  注意：版本名已含 "v" 前缀，直接拼接，不再额外加 "v"。
- **P1-2 控制按钮**：批次卡片加 **取消**（活动批次）和 **重试**（失败批次）按钮；
  队列区加 **暂停/恢复**（改进 `pause`/`resume`：暂停时在途任务重置为 pending，恢复时重新处理）、
  **清除已完成历史** 按钮。
- **修复既有失败**：`utils_test.dart: extractFilenameFromUrl` 现在要求绝对 URL（scheme + host），
  `not-a-url` 返回 null。全项目 **336/336 测试通过**。
- **P0-3 任务幂等（DB 唯一约束）**：`download_task` 增加 `(model_version_id, target_path)` **唯一索引**
  （DB 版本 4→5，迁移先按最新行去重旧数据再建索引）；插入冲突策略从 `replace` 改为 `ignore`
  （重复插入被跳过而不是覆盖）。`_productionDownloadRound` 复用逻辑增强：复用查询改为 `tasksForVersion`
  （含已完成），**全部已完成且文件都在 → 直接完成不再重复**；文件缺失才 `retryBatch` 补下。
- **P1-3a 下载速度**：`DownloadTaskTile` 改为 Stateful，根据两次进度快照差值实时计算速度并显示
  （仅对已知大小的模型文件有效；媒体文件 `fileSizeKb == 0` 不显示速度）。
- **P1-3b 当前文件高亮**：正在下载的文件名加粗 + 主色高亮。
- **删除模型 → 清 download_task 记录**：`ModelVersionRepository.deleteVersion` 事务内
  `DELETE FROM download_task WHERE model_version_id = ?`（覆盖单删 + 批量删，因 `deleteMultipleVersions`
  复用 `deleteVersion`）。磁盘文件（含媒体）本来就随模型目录一并删除，此项补齐队列记录。
- **取消未完成任务 → 清部分文件**：`DownloadQueue.cancelBatch` 对未完成的任务调用
  `_cleanupTaskFiles`（删除残留的 `targetPath` 及 `targetPath.part`）；`background_downloader`
  自身在 cancel 时已清理临时文件，此为兜底。已完成的任务文件不会被删除。
- **设计确认**：媒体文件**始终与模型一起下载/删除**，不做"仅模型"选项 → 不存在"旧媒体任务清理"问题，
  P1-3c 已从计划移除。
- **适配唯一索引的测试修正**：`download_database_test.dart`、`download_queue_test.dart` 的 `makeTask`
  改为按 `id` 派生唯一 `targetPath`（这些测试原本为多个任务用相同路径，与新约束冲突）。
- **P2 Magazine Load 支持 Model ID**：Magazine 标签页顶部加 **Version ID / Model ID** 切换。
  Model 模式下输入模型 ID → "Browse" → 显示模型版本列表（名称/基础模型/首文件/缩略图，
  复用了 `ModelById` 自带版本数据，**单次 API 调用，无 N+1**）→ 勾选一个或多个 → "Load (n)"
  逐个调用 `load()` 装填进 Magazine（已存在的自动跳过）。返回按钮回到 Magazine 列表。
- **下载启动慢的根因与修复（P-性能）**：
  - **根因**：`resolveFileDownloadUrl` 原实现用 `GET + followRedirects: true`，会跟随重定向
    **把整个文件内容下载进内存**，只为拿到 `realUri`，随后丢弃 → 每个文件实际被下载两遍
    （一遍浪费在"解析 URL"、一遍真正下载），且全部**串行**。一个版本 10 张图 + 1 个大模型，
    会在"开始下载"前先把 11 个文件整个拉一遍 → 这就是"等很久才能开始"的直接原因。
  - **修复**：
    1. `resolveFileDownloadUrl` 改为 `followRedirects: false` + **只读 `Location` 头**返回目标 URL，
       绝不下载文件体；加 15s 超时；`validateStatus` 放行 3xx 以读取重定向。
    2. `_productionDownloadRound` 用 `Future.wait` **并行**解析所有模型/媒体 URL。
  - 另：`load()` 仅 2 个串行请求，非瓶颈。
- 全项目 **343/343 测试通过**（新增 resolveFileDownloadUrl 重定向解析测试 2 个）。

### 待办 ⏳

- 暂无（下载功能 P0/P1/P2 + 性能修复全部完成）。

### 备注

- Magazine Load 同时支持 **Version ID**（直接装填）和 **Model ID**（浏览版本后勾选装填）。
- `test/download` 现有 106 个测试。
