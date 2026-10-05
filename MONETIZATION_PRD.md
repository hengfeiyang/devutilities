# DevUtilities 30 天试用与 Lifetime Pro 产品需求文档（PRD）

版本：3.0

状态：已确认，进入实现与发布验证

适用平台：macOS 15+

商业模式：免费下载 + 30 天完整 Pro 试用 + Lifetime Pro 一次性买断

## 1. 产品摘要

DevUtilities 3.0 从收费下载切换为免费下载。新用户可以永久使用 18 个常用工具，并可主动开始一次 30 天完整 Pro 试用。试用结束后，7 个 Pro 工具必须购买 Lifetime Pro 才能继续使用。已有付费下载用户自动获得永久 Pro 权限，无需重复购买。

Lifetime Pro 是 StoreKit 2 非消耗型内购，不是自动续费订阅。购买后永久解锁当前 Apple Account 下的全部 Pro 工具，并支持家庭共享和恢复购买。

源码与网站由同一个 Git 仓库维护，`website/` 为普通子目录。愿意自行构建的用户可以遵循仓库许可证修改本地授权逻辑；不希望自行构建的用户可通过官方 App Store 版本及 Lifetime Pro 支持开发。此说明不改变官方 3.0 免费下载与一次性买断规则，也不提供外部 AI API 额度。仓库公开状态与网站发布仍需单独执行。

核心原则：

- 免费工具足以形成完整、长期可用的开发者工具箱。
- 需要外部付费服务、较稀缺或专业安全能力的工具归入 Pro。
- 30 天试用由用户主动开始，不在安装或首次启动时自动倒计时。
- 试用到期后不再提供每日免费额度。
- 点击未解锁的 Pro 工具时，不切换当前工具页面，直接显示统一的 Pro 窗口。
- 2026-10-24 当天及之前首次获取 App 的用户，无论付费还是免费，永久获得 Legacy Pro。

## 2. 产品目标

### 2.1 业务目标

- 降低首次下载门槛，提高安装和激活量。
- 用完整的 30 天体验证明 Pro 工具价值。
- 用清晰的一次性买断路径提高付费转化。
- 保护历史付费用户，避免重复购买和负面口碑。

### 2.2 用户目标

- 下载后立即使用常用工具。
- 在需要时自行开始 30 天完整试用。
- 清楚知道哪些工具属于 Pro、试用何时结束、购买后获得什么。
- 试用结束后仍可无障碍使用全部免费工具。

### 2.3 非目标

- 不做自动续费订阅。
- 不做按月、按年收费。
- 不做每日分钟数、每日次数或广告解锁。
- 不锁定用户已经输入或生成的数据。
- 不让免费工具显示购买拦截。

## 3. 工具权限

### 3.1 永久免费工具：18 个

1. Timestamp
2. Unit Converter
3. Number Base
4. Color
5. Text Compare
6. JSON
7. Base64
8. Hex String
9. Regex
10. UUID
11. Random String
12. URL
13. HTTP Client
14. QR Code
15. SQL
16. HTML
17. Struct Converter
18. Data Converter

### 3.2 Pro 工具：7 个

1. AI Chat
2. AI Translate
3. Parquet
4. IP Lookup
5. Currency
6. JWT
7. Crypto

归类原则：

- AI Chat、AI Translate 可能调用外部付费服务。
- Parquet、IP Lookup、Currency 属于一般工具集合中较稀缺的能力。
- JWT、Crypto 属于专业、安全相关且相对低频的能力。

### 3.3 Spotlight 与 Shortcuts

现有 App Intents 保持免费，不因用户未购买 Pro 而失败。快捷命令不触发 Pro 窗口。

## 4. StoreKit 商品

| 字段 | 内容 |
|---|---|
| 类型 | Non-Consumable |
| Product ID | `com.hengfeiyang.devutilities.pro.lifetime` |
| 展示名称 | Lifetime Pro |
| 基准价格 | USD 29.99，最终以 App Store 本地价格为准 |
| 家庭共享 | 开启 |
| 自动续费 | 无 |

用户界面统一使用：

- `Unlock Pro Forever`
- `One-time purchase`
- `Restore Purchase`

禁止使用可能暗示订阅的文案，例如 `Subscribe`、`per month`、`renews automatically`。

## 5. 试用规则

### 5.1 开始试用

- 新用户初始状态为 `trialNotStarted`。
- 只有用户点击 `Start 30-Day Trial` 后才记录开始时间。
- 试用开始时间和结束时间保存在 Keychain，并保留本地容错缓存。
- 同一设备不能通过普通重装重新获得试用。

### 5.2 试用期间

- 30 天内所有 7 个 Pro 工具完整可用。
- 不显示工具级购买拦截。
- DevUtilities Pro 页面显示剩余天数和准确结束时间。
- 用户可以在试用期间随时购买 Lifetime Pro。

### 5.3 试用结束

- 状态立即切换为 `trialExpired`。
- 18 个免费工具继续正常使用。
- 7 个 Pro 工具停止授权，不提供额外分钟数或次数。
- 试用结束不删除任何输入、历史或工具配置。
- 用户购买或恢复购买成功后立即解锁全部 Pro 工具。

## 6. 统一 Pro 窗口

### 6.1 打开方式

以下入口显示同一个 `LicenseSettingsView`：

- 侧边栏顶部 Crown 按钮。
- 侧边栏底部 Pro 状态卡片，仅未买断的用户显示；已购买及首批赠送的永久 Pro 用户隐藏此区域。
- 顶部 Crown 按钮对永久 Pro 用户仍保留，可主动查看授权状态。
- 用户点击当前无权使用的 Pro 工具。
- 应用收到 `licenseSettingsRequested` 通知。

### 6.2 导航拦截

用户点击未授权的 Pro 工具时：

1. 在侧边栏选择提交前检查权限。
2. 不修改 `selectedTool`。
3. 保留当前免费工具的页面和状态。
4. 直接以 Sheet 显示统一 Pro 窗口。
5. 关闭窗口后仍停留在原工具。

不允许先切换到 Pro 工具后再用空白页、遮罩页或占位页拦截。

如果用户正在 Pro 工具中且试用恰好到期：

1. 切换回最近使用的免费工具；找不到时回到 JSON。
2. 保留 Pro 工具已持久化的数据。
3. 显示统一 Pro 窗口。

### 6.3 未开始试用

统一窗口显示：

- `30-day Pro trial available`
- `Start 30-Day Trial`
- `Unlock Pro Forever — {localized price}`
- `Restore Purchase`
- 7 个 Pro 工具以三列网格直接平铺名称及图标，不再合并为 AI / Network / Security 等分类

### 6.4 试用进行中

统一窗口显示：

- 剩余天数
- 准确结束时间
- Lifetime Pro 一次性购买按钮
- 恢复购买

### 6.5 试用已结束

统一窗口显示：

- `Pro trial ended`
- `Your 30-day Pro trial has ended. Unlock Lifetime Pro to continue using Pro tools.`
- Lifetime Pro 一次性购买按钮
- 恢复购买
- 不显示再次开始试用按钮
- 不显示继续若干分钟、明日恢复或每日额度相关文案

## 7. 权限状态机

```text
loading
  ├─ paid transition build ───────────────> legacyPro
  ├─ verified early supporter ────────────> legacyPro
  ├─ verified Lifetime Pro purchase ──────> purchasedPro
  ├─ trial never started ─────────────────> trialNotStarted
  ├─ trial active ────────────────────────> trialActive
  └─ trial ended ─────────────────────────> trialExpired

trialNotStarted -- user starts trial -----> trialActive
trialActive -- reaches expiry ------------> trialExpired
trialNotStarted/trialActive/trialExpired
  -- purchase or restore succeeds --------> purchasedPro
```

权限优先级：

1. Legacy Pro
2. 已验证的 Lifetime Pro
3. 进行中的 30 天试用
4. 未开始试用或试用已结束

Pro 工具只有在 `legacyPro`、`purchasedPro` 或 `trialActive` 时可用。

## 8. Legacy Pro 与分阶段发布

### 8.1 Early Supporter

- 2026-10-24 当天及之前首次获取 App 的用户永久获得 Legacy Pro，包括付费及免费下载用户；页面只显示日期，不显示时区。
- 使用已验证的 `AppTransaction.originalPurchaseDate` 严格小于 2026-10-25 00:00:00（Asia/Shanghai）判断，包含 24 日全天，不包含 25 日零点；不按首次启动或首次使用计算。对应 UTC 为 2026-10-24 16:00:00。
- 成功判断后写入 Keychain 和本地容错缓存。
- App Store 暂时不可用时，已有成功缓存不得失效。

### 8.2 发布阶段

首批用户赠送包含 2026-10-24 全天，截止时间已配置为 2026-10-25 00:00（北京时间），独立于免费下载价格切换日期，不再追加宽限。免费切换到该截止点之前新增的免费用户也永久获得 Pro。当前 Release 保护开关仍保留；App Store 价格修改和网站发布尚未执行。

1. 验证历史付费用户以及截止点前免费用户的 AppTransaction 永久授权。
2. 完成 Lifetime Pro 配置、Sandbox 测试和上线时间安排。
3. 验证后开启 Release freemium，Archive、上传并执行 TestFlight 回归。
4. Lifetime Pro 和 3.0 一起提交审核；保留人工发布控制，协调 App Store 免费价格与版本上线。
5. 验证截止点前后的新用户、已有首批用户、购买、共享和恢复购买路径。

## 9. 技术实现

### 9.1 核心文件

- `Models/AccessState.swift`：权限状态和 Pro 工具映射。
- `Services/EntitlementManager.swift`：StoreKit 2、Legacy Pro、试用和本地状态。
- `Views/MonetizationViews.swift`：统一 Pro 窗口、购买和恢复购买 UI。
- `ContentView.swift`：侧边栏导航拦截和 Sheet 展示。
- `Configuration.storekit`：本地 StoreKit 测试商品。

### 9.2 本地状态

Keychain 状态包含：

- `trialStartedAt`
- `trialExpiresAt`
- `lastTrustedLocalDate`
- `legacyProVerified`
- `lifetimeProVerified`

旧版本遗留的每日额度字段读取时忽略，不再参与任何权限判断。

### 9.3 时间处理

- 使用最近可信本地时间降低简单回拨系统时间绕过试用的风险。
- 应用重新激活、系统时钟变化或自然日变化时刷新试用状态。
- 试用运行中安排到期任务，到点切换为 `trialExpired`。

### 9.4 Debug 预览

Debug 构建支持：

- `--preview-trial-not-started`
- `--preview-trial-active`
- `--preview-trial-expired`

预览参数不修改真实 Keychain、StoreKit 权益或试用日期，并且不能进入 Release 二进制。

## 10. 购买与恢复

- 使用 `Product.products(for:)` 加载本地化价格。
- 使用 StoreKit 2 `purchase()` 完成购买。
- 只接受已验证交易。
- pending 状态不提前授权。
- 取消购买保持原状态。
- 使用 `AppStore.sync()` 恢复购买。
- 收到 `Transaction.updates` 后刷新权益。
- 退款或撤销后取消 `purchasedPro`，再回落到有效试用或 `trialExpired`。

## 11. 埋点与隐私

允许记录：

- 试用入口展示、开始和结束。
- 试用结束后的统一 Pro 窗口展示。
- 购买开始、成功、失败、取消、pending。
- 恢复购买开始、成功、失败、未找到购买。

禁止记录：

- 用户输入、输出或剪贴板内容。
- 文件名、文件路径和文件内容。
- API Key、请求体、JWT、密钥或模型对话。
- 可识别个人身份的数据。

## 12. 验收标准

### 12.1 免费工具

- 18 个免费工具始终可打开。
- 免费工具不显示 Pro 窗口。
- 试用到期不影响免费工具数据和功能。

### 12.2 试用

- 试用不会自动开始。
- 点击开始后立即解锁全部 Pro 工具。
- 剩余时间跨重启保持一致。
- 到期后状态变为 `trialExpired`。
- 不能再次开始试用。

### 12.3 Pro 导航拦截

- 未开始试用或试用已结束时，点击任意 Pro 工具不会改变当前选中的工具。
- 统一 Pro 窗口立即出现。
- 不出现空白详情页、工具级提示卡或覆盖层。
- 关闭窗口后仍停留在原免费工具。
- Pro 工具中途到期时自动回到最近使用的免费工具并显示统一 Pro 窗口。

### 12.4 购买

- 显示 App Store 本地化价格。
- 购买成功后全部 Pro 工具立即可用。
- 重启后购买状态保持。
- 恢复购买可恢复全部 Pro 工具。
- 所有购买文案明确为一次性永久解锁。

### 12.5 Legacy Pro

- 历史付费用户不看到购买拦截。
- App Store 暂时不可用时，已缓存的 Legacy Pro 仍有效。
- 截止点之前首次获取的免费用户按策略获得永久 Legacy Pro；截止点及之后获取的新用户不得自动获得 Legacy Pro。

## 13. 测试矩阵

| 场景 | 预期结果 |
|---|---|
| 新用户首次启动 | 18 个免费工具可用，Pro 工具有标记 |
| 未开始试用点击 Pro | 当前工具不变，统一窗口显示试用和购买 |
| 点击开始试用 | 全部 Pro 工具立即可用 |
| 试用中重启 | 剩余时间保持 |
| 试用到期时停留在免费工具 | 免费工具继续使用 |
| 试用到期时停留在 Pro 工具 | 回到最近免费工具并显示统一窗口 |
| 试用到期后点击 Pro | 当前工具不变，统一窗口显示购买 |
| 购买成功 | 全部 Pro 工具永久解锁 |
| 购买 pending | 不提前授权，窗口显示等待状态 |
| 用户取消购买 | 保持原权限状态 |
| 恢复购买成功 | 全部 Pro 工具立即解锁 |
| 无历史购买时恢复 | 显示明确错误，不授权 |
| Legacy Pro 用户 | 全部 Pro 工具永久可用 |
| Release 构建携带预览参数 | 参数无效且二进制不包含预览字符串 |

## 14. 最终产品承诺

> DevUtilities 可以免费下载。18 个常用工具永久免费；7 个高级工具可完整试用 30 天。试用结束后，可通过一次性购买 Lifetime Pro 永久解锁，不自动续费。所有早期付费用户永久保留 Pro 权益。
