# DevUtilities 免费试用与 Lifetime Pro 产品需求文档（PRD）

**文档版本：** 1.0  
**状态：** Review Draft  
**日期：** 2026-07-19  
**目标版本：** DevUtilities v2.16.0  
**负责人：** Hengfei Yang  
**适用平台：** Mac App Store / macOS 15.0+（代码当前部署目标）

---

## 1. 文档摘要

DevUtilities 当前采用 Mac App Store 付费下载模式，用户必须在体验产品前一次性支付 $29.99。为了降低首次体验门槛、扩大用户规模并保留买断制，本版本将商业模式调整为：

> 免费下载 + 用户主动开启 30 天完整 Pro 试用 + 16 个永久免费工具 + 9 个 Pro 工具每天共享 10 分钟免费额度 + $29.99 Lifetime Pro 一次性买断。

本方案不引入订阅。现有所有付费下载用户自动获得 Lifetime Pro，不需要再次购买。

### 1.1 核心决策

| 项目 | 决策 |
|---|---|
| App 下载价格 | 免费 |
| Pro 商品类型 | 非消耗型 App 内购买（Non-Consumable In-App Purchase） |
| Pro 商品名 | DevUtilities Pro Lifetime |
| 美国基础价格 | $29.99；界面必须读取 StoreKit 本地化价格，不得硬编码 |
| 试用方式 | 用户主动开启 30 天完整 Pro 试用 |
| 试用是否要求购买授权 | 不要求 |
| 试用结束后 | 16 个免费工具永久可用；9 个 Pro 工具每天共享 10 分钟 |
| 每日提示 | 每个 Pro 工具每天第一次打开时提示一次购买 |
| 购买后权益 | 永久使用全部当前 Pro 功能及后续同一产品内的 Pro 更新 |
| 老用户权益 | 免费模式生效前付费下载的用户自动获得 Lifetime Pro |
| 订阅 | 不提供 |

### 1.2 Apple 产品定义

Lifetime Pro 使用 Apple StoreKit 的非消耗型内购。Apple 对该类型的定义是：购买后不会消耗，也不会过期。

- [Apple：Getting started with In-App Purchase using StoreKit views](https://developer.apple.com/documentation/storekit/getting-started-with-in-app-purchases-using-storekit-views)
- [Apple：Supporting business model changes with AppTransaction](https://developer.apple.com/documentation/storekit/apptransaction)

---

## 2. 背景与问题

### 2.1 当前模式

- DevUtilities 当前为 $29.99 付费下载。
- 用户在 App Store 付款前无法亲自验证工具质量、使用频率或是否适合自己的工作流。
- 产品已包含 25 个工具，但工具数量本身难以与免费、开源或低价竞品形成有效差异。
- 当前累计用户规模不足 1000，继续增加工具不能直接解决获客和购买决策问题。

### 2.2 用户问题

1. 用户无法在购买前确认 Parquet、Data Converter、Struct Converter 等专业能力是否满足实际需求。
2. $29.99 的前置价格使一次偶然搜索难以转化为安装和日常使用。
3. 用户尚未形成使用习惯，就需要做出永久购买决定。
4. 如果简单地把全部功能永久免费，产品又缺乏明确、可持续的付费理由。

### 2.3 商业问题

1. 付费下载限制了安装漏斗顶部的用户数量。
2. 当前缺少“试用开始 → 实际使用 → 购买”的可测量转化路径。
3. 当前无法识别哪些专业工具真正驱动购买。
4. 需要在扩大传播与维持收入之间取得平衡。

---

## 3. 产品目标

### 3.1 业务目标

1. 降低安装门槛，提高新增用户数量。
2. 让用户在购买前完整体验专业功能并形成使用习惯。
3. 保持一次性买断定位，不引入订阅阻力。
4. 建立可观测的试用、激活、付费和留存漏斗。
5. 保护原付费用户权益和品牌信任。

### 3.2 用户目标

1. 免费用户可以长期使用足够完整的日常开发工具。
2. 用户可以在不提供支付信息的情况下体验全部 Pro 功能。
3. 试用到期后，紧急工作仍可通过每日 10 分钟完成，不被完全阻断。
4. 用户可以清楚理解：Pro 是一次性购买，不是持续付费服务。
5. 购买、恢复购买、换机和离线使用都应稳定可靠。

### 3.3 产品体验目标

- 首次启动不显示付费墙。
- 免费工具永远不显示购买提示。
- 试用期间不打断 Pro 工具的正常使用。
- 试用到期后，购买提醒可预测、可关闭、不删除工作内容。
- 权限系统发生故障时优先保护已付费用户，避免错误降级。

---

## 4. 非目标

本版本不包含：

1. 月度或年度订阅。
2. DevUtilities 账号系统。
3. 自建支付、许可证服务器或第三方支付渠道。
4. 团队席位、企业控制台或批量许可证。
5. 新增第 26 个工具。
6. 复杂的反盗版或强 DRM。
7. 不同 Pro 工具分别出售。
8. 按次购买额外使用时间。
9. 在免费模式上线时同时降低 Lifetime Pro 标准价格。

---

## 5. 用户类型

### 5.1 新免费用户

- 在免费模式生效后首次下载应用。
- 可以永久使用免费工具。
- 可以主动开启一次 30 天完整 Pro 试用。

### 5.2 试用用户

- 已主动开启 30 天 Pro 试用。
- 试用有效期内拥有与付费用户相同的工具访问权限。
- 不需要先发起购买。

### 5.3 试用结束的免费用户

- 免费工具永久可用。
- Pro 工具每天共享 600 秒前台使用时间。
- 每个 Pro 工具每天第一次打开时显示一次购买提示。

### 5.4 Lifetime Pro 用户

- 通过非消耗型内购买断 Pro。
- 永久使用所有 Pro 工具。
- 可通过 StoreKit 恢复购买。

### 5.5 Legacy Pro 用户

- 在 App 改为免费下载之前付费下载。
- 自动获得与 Lifetime Pro 相同的永久权益。
- 不需要创建内购交易，也不需要再次付款。
- 应看到 Early Supporter 感谢信息，而不是购买按钮。

---

## 6. 工具权限矩阵

### 6.1 永久免费工具：16 个

| # | 工具 | 免费范围 |
|---|---|---|
| 1 | Timestamp | 完整功能 |
| 2 | Unit Converter | 完整功能 |
| 3 | Number Base | 完整功能 |
| 4 | Color | 完整功能 |
| 5 | Text Compare | 完整功能 |
| 6 | JSON | 格式化、验证、转义/反转义、Diff 全部免费 |
| 7 | Base64 | 完整功能 |
| 8 | Hex String | 完整功能 |
| 9 | Regex | 完整功能 |
| 10 | UUID | 完整功能 |
| 11 | Random String | 完整功能 |
| 12 | URL | 完整功能 |
| 13 | IP Lookup | 完整功能 |
| 14 | QR Code | 完整功能 |
| 15 | SQL | 格式化及 Diff 全部免费 |
| 16 | HTML | 格式化及 Diff 全部免费 |

### 6.2 Pro 工具：9 个

| # | 工具 | Pro 能力 |
|---|---|---|
| 1 | AI Chat | 完整聊天、流式输出、推理与自定义模型能力 |
| 2 | AI Translate | 翻译、润色、总结、OpenAI/macOS TTS |
| 3 | JWT | 完整编码、解码、HMAC/RSA 签名与验证 |
| 4 | Crypto | Hash、AES、RSA 完整工具套件 |
| 5 | HTTP Client | 请求、认证、SSE、JSON 响应查看 |
| 6 | Parquet | Parquet/Arrow 文件完整查看 |
| 7 | Currency | 实时汇率、缓存、历史和趋势 |
| 8 | Struct Converter | 全格式输入和全语言输出 |
| 9 | Data Converter | JSON/YAML/TOML/CSV 任意转换 |

### 6.3 Spotlight / Shortcuts 例外

v2.15.0 已提供 11 个 App Intents。为了保持系统级入口稳定并把 Spotlight 作为获客渠道，以下已有快捷命令永久免费，即使其对应的完整应用页面属于 Pro：

- Decode JWT：仅解码快捷命令免费；完整 JWT 页面仍为 Pro。
- Hash Text：仅 Hash 快捷命令免费；完整 Crypto 页面仍为 Pro。

其他现有 Spotlight 命令对应的工具本身已属于免费工具，继续保持免费。

App Intents 不消耗每日 Pro 额度，不显示付费提示，也不得因为用户未购买 Pro 而失败。

---

## 7. 商业规则

### 7.1 StoreKit 商品

| 字段 | 值 |
|---|---|
| Product ID | `com.hengfeiyang.devutilities.pro.lifetime` |
| Product Type | Non-Consumable |
| Reference Name | DevUtilities Pro Lifetime |
| Display Name | Pro Lifetime |
| Description | Unlock all Pro tools forever with one purchase. |
| Base Price | USD $29.99 |
| Family Sharing | 建议开启，正式配置前确认 |

所有界面价格必须使用 StoreKit 返回的 `displayPrice`。不得将 `$29.99` 作为用户界面的固定字符串，以保证地区、货币和税费显示正确。

### 7.2 一次性买断表述

允许使用：

- One-time purchase
- Unlock Pro forever
- Lifetime Pro
- Pay once, use forever
- 一次买断，永久使用

不使用：

- Subscribe / Subscription
- Cancel anytime
- Auto-renew / Automatic renewal
- Monthly / Yearly plan
- 任何暗示周期扣费的描述

### 7.3 购买恢复

- License 页面必须提供 `Restore Purchases`。
- 恢复操作使用 `AppStore.sync()`，随后重新读取 `Transaction.currentEntitlements`。
- 恢复成功后立即解除限制，不要求重启。
- 没有可恢复购买时给出明确、非错误式提示。

### 7.4 退款与撤销

- Lifetime Pro 非消耗型交易被退款或撤销后，用户回到符合其身份的状态。
- 如果同时符合 Legacy Pro 条件，Legacy Pro 优先，不能因为新内购退款而错误移除老用户权益。
- 购买处于 pending 状态时不授予永久权益，但保留当前试用或每日额度。

---

## 8. 试用规则

### 8.1 试用开始

- 试用不在下载、安装或首次启动时自动开始。
- 新用户首次选择任意 Pro 工具时显示试用介绍页。
- 只有点击 `Start 30-Day Trial` 后才写入试用开始时间。
- 点击 `Not Now` 返回此前的免费工具或 JSON，不消耗试用资格。
- 每个设备仅可开始一次试用。

### 8.2 试用时长

- 时长：30 天。
- 过期时间：`trialStartedAt` 加 30 个日历日。
- 试用开始后不能暂停。
- 修改系统时间不得使已过期试用重新有效。
- 本版本试用状态为设备本地状态，不在多台 Mac 之间同步。

### 8.3 试用期间体验

- 所有 Pro 工具完整开放。
- 不显示每日首次付费提示。
- 不消耗每日 10 分钟额度。
- 前 20 天不主动显示购买弹窗。
- 剩余 10 天时允许在侧边栏底部显示安静的剩余天数。
- 剩余 3 天时最多显示一次可关闭提醒。
- 试用最后一天最多显示一次可关闭提醒。

### 8.4 试用到期

- 到期时不取消正在执行的 AI、HTTP、TTS 或文件解析操作。
- 当前操作允许完成。
- 当前输入、输出、历史和配置不得删除。
- 完成中的操作结束后进入每日 10 分钟模式。
- 首次遇到 Pro 工具时展示试用结束页。

---

## 9. 每日共享 10 分钟规则

### 9.1 基本规则

- 适用对象：试用已经结束、未购买且不属于 Legacy Pro 的用户。
- 总额度：每天 600 秒。
- 共享范围：全部 9 个 Pro 工具共享同一额度。
- 免费工具和免费 App Intents 不消耗额度。
- 每天最多重置一次。

### 9.2 计时开始条件

只有同时满足以下条件才计时：

1. 当前选中的是 Pro 工具。
2. 用户已经在当日提示中点击 `Continue`。
3. DevUtilities 是前台活动应用。
4. 主窗口处于可交互状态。
5. 用户没有打开阻断式系统授权或 StoreKit 购买面板。

### 9.3 暂停条件

以下情况立即暂停计时并保存剩余秒数：

- 切换到免费工具。
- 应用进入后台或失去活动状态。
- 主窗口关闭。
- 打开 StoreKit 购买确认面板。
- 应用正常退出。

切换到另一个 Pro 工具不重置额度；如果用户已允许使用当日额度，则继续使用同一个剩余时间池。

### 9.4 持久化

- `dailyRemainingSeconds` 初始值为 600。
- 计时过程中至少每 15 秒持久化一次。
- 在切换工具、进入后台、窗口关闭和应用退出时立即持久化。
- 异常崩溃最多产生 15 秒额度误差，可接受。
- 数据存储需要防止简单删除 `UserDefaults` 后无限重置，建议使用 Keychain 保存权威值，`UserDefaults` 仅用于 UI 缓存。

### 9.5 每日重置

- 使用用户当前日历的本地日期作为自然日。
- 当当前日期严格晚于最后一次额度日期时重置为 600 秒。
- 系统时间向后调整时不得重置。
- 时区改变最多触发一次新的自然日重置，不进行服务器时间校验。
- 不追求阻止所有人为修改时间的行为。

### 9.6 额度耗尽

- 不取消正在执行的操作。
- 当前操作完成后，禁止发起新的 Pro 操作。
- 当前结果保持可见、可选择、可复制。
- 显示统一的额度结束状态：

```text
Today's Pro access has ended
Free access returns tomorrow, or unlock Pro forever.

[Unlock Pro Forever — {localized price}]
[Continue with Free Tools]
[Restore Purchase]
```

- 如果难以在第一版对所有工具实现“结果可复制但不能继续操作”，允许显示覆盖层，但底层输入状态必须保留，购买后能够恢复。

---

## 10. 每日购买提示规则

### 10.1 触发条件

试用结束的免费用户每天第一次打开每个 Pro 工具时显示一次购买提示。

例如用户当天依次打开 Parquet、Struct Converter 和 Parquet：

1. 第一次打开 Parquet：显示提示。
2. 第一次打开 Struct Converter：显示提示。
3. 再次打开 Parquet：不再显示提示。

### 10.2 提示内容

```text
Unlock {Tool Name} Forever

Get unlimited access to all Pro tools with one purchase.

[Unlock Pro Forever — {localized price}]
[Continue — 10 Minutes Available]
[Restore Purchase]
```

如果已经消耗部分额度：

```text
[Continue — 06:14 Remaining Today]
```

### 10.3 频率限制

- 同一个 Pro 工具每个自然日最多一次。
- 只在用户主动选择 Pro 工具时触发。
- 不在应用启动时自动弹出。
- 不在工具操作、输入或输出过程中突然弹出。
- 试用用户、Lifetime Pro 用户和 Legacy Pro 用户从不显示。
- 当日额度已经耗尽时直接显示额度结束页，不重复显示首次提示。

### 10.4 提示交互

- `Unlock Pro Forever`：发起非消耗型内购。
- `Continue`：关闭提示，允许使用当天剩余额度。
- `Restore Purchase`：执行购买恢复。
- 关闭窗口或按 Escape：返回最近使用的免费工具，不开始计时。

---

## 11. 用户体验与界面需求

### 11.1 首次启动

当前应用默认选中 AI Chat。由于 AI Chat 将成为 Pro，免费模式上线时必须将新用户默认工具改为 JSON，避免第一次启动立即出现试用或付费提示。

要求：

- 新用户默认进入 JSON。
- 已有用户可以继续恢复其最近使用的工具；如果最近工具是 Pro，则根据权限显示对应状态。
- 首次启动不显示付费弹窗。

### 11.2 侧边栏

- Pro 工具标题右侧显示低调的 `PRO` 标记。
- 不使用永久锁头图标，避免让免费应用看起来大部分不可用。
- 试用期间 Pro 标记仍可保留，但不得显示锁定状态。
- Lifetime Pro 用户可选择隐藏 Pro 标记，默认隐藏。

侧边栏底部状态：

| 状态 | 显示 |
|---|---|
| Trial not started | `30-day Pro trial available` |
| Trial active | `Pro Trial · {N} days left` |
| Daily access | `Daily Pro Access · 07:32 remaining` |
| Daily exhausted | `Daily Pro Access · returns tomorrow` |
| Lifetime Pro | `Lifetime Pro` |
| Legacy Pro | `Lifetime Pro · Early Supporter` |

### 11.3 Trial Offer 页面

标题：

```text
Try every Pro tool for 30 days
```

辅助说明：

```text
Explore Parquet, data conversion, HTTP, crypto, AI tools, and more.
```

按钮：

- `Start 30-Day Trial`
- `Not Now`
- `Unlock Pro Forever — {localized price}`

页面不出现订阅、续费、取消或周期计费文案。

### 11.4 主购买页

标题：

```text
Unlock DevUtilities Pro Forever
```

核心卖点：

1. Open Parquet and Arrow files locally.
2. Convert JSON, YAML, TOML, and CSV without losing structure.
3. Generate typed structs for seven languages.
4. Use HTTP, JWT, and Crypto workflows in one native app.
5. One purchase, permanent access.

操作：

- `Unlock Pro Forever — {localized price}`
- `Restore Purchase`
- `Continue with Free Tools`

### 11.5 License 设置页

在设置或现有 Feature Settings 中增加独立的 License 区域，显示：

- 当前授权状态。
- 试用结束日期或每日剩余时间。
- Lifetime Pro 商品价格。
- 购买按钮。
- 恢复购买按钮。
- `Manage Purchases` 系统入口（如适用）。
- Legacy Pro 用户的感谢信息。

### 11.6 Legacy Pro 文案

```text
Lifetime Pro · Early Supporter

You purchased DevUtilities before it became free to download.
All Pro tools are permanently unlocked. Thank you for supporting the app early.
```

Legacy Pro 页面不显示再次购买按钮。

### 11.7 错误状态

| 场景 | 行为 |
|---|---|
| StoreKit 商品暂时无法加载 | 保留当前可用权限，显示稍后重试 |
| 购买取消 | 不显示错误警报，回到购买页 |
| 购买失败 | 显示本地化错误和重试按钮 |
| 购买 pending | 显示等待 App Store 确认，不重复发起购买 |
| 交易验证失败 | 不授予 Pro，记录匿名错误类型 |
| 恢复购买无结果 | 显示 `No previous Pro purchase was found.` |
| 离线 | 允许已缓存的 Pro/Legacy 权益；新购买提示联网 |

---

## 12. 权限状态机

### 12.1 状态定义

```swift
enum AccessState: Equatable {
    case legacyPro
    case purchasedPro
    case trialNotStarted
    case trialActive(expiresAt: Date)
    case free(dailyProSecondsRemaining: TimeInterval)
}
```

购买流程另有瞬时状态：

```swift
enum PurchaseState: Equatable {
    case idle
    case loadingProduct
    case purchasing
    case pending
    case succeeded
    case failed(message: String)
}
```

### 12.2 权限优先级

按以下顺序判断，命中后不继续降级：

1. Legacy Pro。
2. 已验证且未撤销的 Lifetime Pro 内购。
3. 有效的 30 天试用。
4. 试用未开始。
5. 试用结束后的每日额度。

### 12.3 状态转移

```text
New Download
    │
    ├── Free tools ───────────────────────────────┐
    │                                             │
    └── Open Pro tool                             │
            │                                     │
            ▼                                     │
      Trial Not Started                           │
            │                                     │
            ├── Buy ───────────────► Purchased Pro│
            │                                     │
            └── Start Trial                       │
                    │                             │
                    ▼                             │
              Trial Active                        │
                    │                             │
                    ├── Buy ───────► Purchased Pro│
                    │                             │
                    └── 30 days expire            │
                            │                     │
                            ▼                     │
                  Free + Daily 10 Minutes ◄───────┘
                            │
                            └── Buy ──────────────► Purchased Pro

Existing Paid Download ──────────────────────────► Legacy Pro
```

### 12.4 访问判断

```swift
func canAccess(_ tool: ToolType) -> Bool {
    if tool.productAccess == .free {
        return true
    }

    switch accessState {
    case .legacyPro, .purchasedPro, .trialActive:
        return true
    case .free(let remaining):
        return remaining > 0
    case .trialNotStarted:
        return false
    }
}
```

实际实现还需区分“可以展示 Pro 工具试用页”和“可以直接执行 Pro 功能”，不得因为 `false` 而隐藏购买入口。

---

## 13. 技术架构建议

### 13.1 新增文件

```text
DevUtilities/
├── Models/
│   ├── AccessState.swift
│   └── ProductAccess.swift
├── Services/
│   ├── EntitlementManager.swift
│   ├── PurchaseManager.swift
│   ├── TrialManager.swift
│   └── DailyProAllowanceManager.swift
└── Views/
    ├── TrialOfferView.swift
    ├── ProPurchaseView.swift
    ├── ProToolGateView.swift
    ├── ProStatusView.swift
    └── LicenseSettingsView.swift
```

如实现后发现 `EntitlementManager` 能清晰承担购买、试用和每日额度协调，可以减少服务数量，但必须保持职责可测试。

### 13.2 ToolType 扩展

```swift
enum ProductAccess {
    case free
    case pro
}

extension ToolType {
    var productAccess: ProductAccess {
        switch self {
        case .aiChat,
             .aiTranslate,
             .jwt,
             .cryptoTools,
             .httpRequest,
             .parquetViewer,
             .currencyConverter,
             .structConverter,
             .dataConverter:
            return .pro
        default:
            return .free
        }
    }
}
```

不得修改 `ToolType` 已有 raw value，以免破坏已保存的工具排序和用户偏好。

### 13.3 环境注入

`EntitlementManager` 作为应用级 `@StateObject` 从 `DevUtilitiesApp` 注入：

```swift
@StateObject private var entitlementManager = EntitlementManager()

ContentView()
    .environmentObject(entitlementManager)
```

所有权限状态必须来自单一数据源，工具页面不得各自读取散落的 `UserDefaults` 权限标记。

### 13.4 统一导航拦截

当前全部工具由 `ContentView` 集中路由。权限拦截应优先在此处统一处理：

```swift
if entitlementManager.shouldShowTool(selectedTool) {
    toolView(for: selectedTool)
} else {
    ProToolGateView(tool: selectedTool)
}
```

每日额度耗尽时，为保留已有输入和输出，推荐使用覆盖层而不是销毁工具 View。如果实现成本过高，至少要保证各工具原有 `UserDefaults` 状态不会被清除。

### 13.5 StoreKit 2

`PurchaseManager` 需要负责：

1. 加载 Lifetime Pro 商品。
2. 发起购买。
3. 验证交易。
4. 读取当前权益。
5. 持续监听 `Transaction.updates`。
6. 完成交易。
7. 恢复购买。
8. 处理撤销、退款和 pending。

交易必须通过 StoreKit 验证结果确认，不能仅依赖本地布尔值。

### 13.6 AppTransaction 与 Legacy Pro

使用 `AppTransaction.shared` 的已验证信息读取：

- `originalPurchaseDate`
- `originalAppVersion`

Legacy Pro 建议条件：

```text
originalPurchaseDate <= legacyCutoffDate
```

`legacyCutoffDate` 是 App 下载价格正式变为免费的实际时间，加 24–48 小时安全宽限。

如购买日期处于边界或 StoreKit 暂时不可用，应优先避免让可能付费下载的用户再次付费。可以结合原始版本作为第二判断条件，但不能只按版本判断，因为过渡版本发布后仍会短期保持付费下载。

### 13.7 Keychain 数据

建议由 Keychain 保存：

```text
trialStartedAt
trialExpiresAt
trialHasStarted
dailyAllowanceDate
dailyRemainingSeconds
lastTrustedLocalDate
```

可由 `UserDefaults` 保存的非权威 UI 状态：

```text
dailyPromptedToolIDs
lastSelectedTool
hasShownTrialEndingReminder
hasShownTrialExpiredMessage
```

每日提示集合在自然日切换时清空。

### 13.8 离线原则

- 已验证的 Lifetime Pro 应支持离线使用。
- Legacy Pro 应支持离线使用。
- 试用和每日额度均在本地运行。
- 购买、恢复购买和首次商品价格加载需要网络。
- 网络故障不能导致已付费用户突然被锁定。

---

## 14. 埋点与隐私

### 14.1 新增事件

| 事件 | 必要参数 |
|---|---|
| `trial_offer_viewed` | `tool`, `source` |
| `trial_started` | `source_tool` |
| `trial_reminder_viewed` | `days_remaining` |
| `trial_expired` | 无 |
| `daily_pro_prompt_viewed` | `tool`, `seconds_remaining` |
| `daily_pro_access_started` | `tool`, `seconds_remaining` |
| `daily_pro_allowance_exhausted` | `last_tool` |
| `paywall_viewed` | `source`, `tool?` |
| `purchase_started` | `product_id`, `source` |
| `purchase_succeeded` | `product_id`, `source` |
| `purchase_pending` | `product_id` |
| `purchase_failed` | `product_id`, `error_category` |
| `restore_started` | `source` |
| `restore_succeeded` | `entitlement_type` |
| `restore_no_purchase_found` | `source` |
| `tool_action_succeeded` | `tool`, `action` |

### 14.2 禁止收集

不得收集或发送：

- 用户输入文本。
- JSON、JWT、SQL、HTML 或请求正文。
- URL 完整内容。
- API Key、Header、Token 或密钥。
- 文件名、文件路径或文件内容。
- AI 对话内容。
- 生成或转换后的输出。

现有 Parquet 打开事件包含文件名，本版本应改为仅记录文件类型和非敏感大小区间。

### 14.3 分析开关

- 设置页必须提供可发现的匿名使用分析开关。
- 隐私政策、App Store 隐私标签和官网文案保持一致。
- 关闭分析后，购买和权限验证仍正常工作，但不发送产品分析事件。

---

## 15. 核心指标

### 15.1 北极星指标

每周完成至少 3 次成功工具操作的活跃用户数。

### 15.2 转化漏斗

```text
App Store Impression
    → Product Page View
    → Free Download
    → First Successful Action
    → Trial Started
    → 3 Successful Pro Actions
    → Trial Completed
    → Lifetime Pro Purchased
```

### 15.3 首期实验指标

上线后以免费模式前 8 周与切换前 8 周进行对比。以下为初始假设，不是永久 KPI：

| 指标 | 初始目标 |
|---|---|
| 免费下载量 | 至少为原付费下载量的 3 倍 |
| 首次启动后完成一次有效操作 | ≥ 60% |
| 活跃新用户开启试用 | ≥ 30% |
| 试用用户完成至少 3 次 Pro 操作 | ≥ 50% |
| 开启试用到购买转化 | ≥ 5% |
| 第 8 周累计净收入 | 不低于切换前同期基线，或呈明确上升趋势 |
| 退款率 | 不高于当前水平的显著区间 |
| 商店评分 | 不因付费提示下降超过 0.3 分 |

### 15.4 每日额度评估

重点观察：

- 用户平均每天消耗多少秒。
- 多少用户连续多日耗尽额度。
- 哪个 Pro 工具最常触发购买。
- 购买发生在提示页、额度耗尽页还是试用提醒页。
- 10 分钟是否足以让大多数用户长期避免购买。

在至少运行 6 周前不调整每日额度。后续可能的实验包括 5 分钟、10 分钟或每周固定次数，但一次只改变一个变量。

---

## 16. 发布与迁移计划

### 16.1 阶段 A：开发和本地测试

1. 创建 StoreKit Configuration 文件。
2. 创建 Lifetime Pro 非消耗型商品。
3. 实现权限状态机。
4. 实现 Legacy Pro 判断。
5. 实现 30 天试用。
6. 实现每日共享 600 秒。
7. 实现付费页、试用页和 License 设置页。
8. 增加埋点和隐私修正。
9. 完成单元测试、StoreKit 测试和 UI 测试。

### 16.2 阶段 B：发布付费过渡版本

目标版本 v2.16.0 首先继续保持 App Store 付费下载：

- StoreKit 和权限代码已经包含在版本中。
- 当前和过渡期间购买的用户全部获得 Legacy Pro。
- 普通用户不看到试用或购买页面。
- 验证 AppTransaction、离线、删除重装和换机恢复。
- 观察至少 7 天，确认不存在付费用户被错误锁定。

### 16.3 阶段 C：切换免费下载

1. 确认 v2.16.0 已广泛可用。
2. 记录实际价格切换时间。
3. 设置 Legacy Pro 截止时间并保留 24–48 小时宽限。
4. 将 App 下载价格改为免费。
5. 启用 Lifetime Pro 商品销售。
6. 更新 App Store 描述、截图和支持页面。
7. 确认新下载用户进入 JSON 且不会被识别为 Legacy Pro。
8. 确认旧付费用户仍拥有全部 Pro 权益。

### 16.4 阶段 D：6–8 周观察期

- 不新增工具。
- 不同时修改 Lifetime Pro 标准价格。
- 每周检查转化漏斗和异常反馈。
- 重点监控 Legacy Pro 错误、购买恢复失败、每日计时异常和差评。
- 6 周后进行第一次商业复盘，8 周后决定是否保留、收紧或放宽每日额度。

### 16.5 文档同步

正式实现并发布时，按照仓库 Documentation Update Protocol 同步更新：

1. `README.md`
2. `AGENTS.md`
3. `DESIGN.md`
4. `website/README.md`
5. `website/index.html`
6. `website/release-notes.html`
7. `website/ai-translate.html`

并新增或更新对应的 `appstore/APPSTORE_SUBMISSION_v2.16.0.md`。

---

## 17. 验收标准

### 17.1 免费工具

- [ ] 新用户首次启动默认进入 JSON。
- [ ] 16 个免费工具无需开启试用即可完整使用。
- [ ] 免费工具不显示购买提示，不消耗每日额度。
- [ ] SQL 和 HTML 完整免费。
- [ ] Currency 被正确识别为 Pro。

### 17.2 试用

- [ ] 试用不会在下载或首次启动时自动开始。
- [ ] 首次选择 Pro 工具时可以开启 30 天试用。
- [ ] 点击 Not Now 不消耗试用资格。
- [ ] 试用期间全部 Pro 工具完整可用。
- [ ] 试用期间不显示每日购买提示。
- [ ] 删除并重装不会简单地重置同一设备试用。
- [ ] 修改系统时间向后不会恢复已过期试用。
- [ ] 试用到期不删除任何工具数据。

### 17.3 每日共享额度

- [ ] 试用到期后全部 Pro 工具共享 600 秒。
- [ ] 使用 Parquet 4 分钟后，Struct Converter 显示剩余约 6 分钟。
- [ ] 切换到免费工具时计时暂停。
- [ ] 应用进入后台时计时暂停。
- [ ] 切换 Pro 工具不重置计时。
- [ ] 退出重开不重置当日额度。
- [ ] 新的自然日恢复到 600 秒。
- [ ] 系统时间向后调整不触发额度重置。
- [ ] 额度耗尽不取消正在执行的操作。
- [ ] 额度耗尽后保留用户输入和输出。

### 17.4 每日提示

- [ ] 每个 Pro 工具每天第一次打开显示一次购买提示。
- [ ] 同一工具当天第二次打开不再显示。
- [ ] 不同 Pro 工具当天第一次打开分别显示。
- [ ] 提示中的 Continue 显示准确的共享剩余时间。
- [ ] 当日额度耗尽后显示统一结束页。
- [ ] 提示不会在应用启动或操作进行中突然出现。

### 17.5 购买

- [ ] 商品价格来自 StoreKit 本地化数据。
- [ ] 购买成功后立即解锁全部 Pro 工具。
- [ ] 购买取消不会显示错误警报。
- [ ] pending 状态不会重复扣款或错误解锁。
- [ ] 恢复购买成功后立即解锁。
- [ ] 已购买用户离线启动仍可使用 Pro。
- [ ] 被撤销的非消耗型交易会正确更新权益。

### 17.6 Legacy Pro

- [ ] 免费模式生效前付费下载用户自动获得 Pro。
- [ ] 付费过渡版本期间购买的用户也获得 Pro。
- [ ] Legacy Pro 用户不看到购买按钮或每日提示。
- [ ] Legacy Pro 用户删除重装后仍可恢复权益。
- [ ] Legacy Pro 用户离线时不会因为临时验证失败被降级。
- [ ] 边界时间判断优先避免让付费用户再次购买。

### 17.7 Spotlight 与 Shortcuts

- [ ] 现有 11 个 App Intents 保持可用。
- [ ] Decode JWT 快捷命令不要求 Pro。
- [ ] Hash Text 快捷命令不要求 Pro。
- [ ] 免费快捷命令不消耗每日 Pro 额度。
- [ ] App Intents 不显示无法完成的应用内购买界面。

### 17.8 隐私和分析

- [ ] 新付费漏斗事件不包含用户内容。
- [ ] 文件打开事件不再发送文件名或路径。
- [ ] 关闭分析后不发送产品事件。
- [ ] 关闭分析不影响 StoreKit 权限和购买恢复。

---

## 18. 测试矩阵

| 场景 | 预期结果 |
|---|---|
| 新用户首次启动 | 进入 JSON，无弹窗 |
| 新用户只使用免费工具 | 永久可用，无试用计时 |
| 新用户打开 Pro 工具并选择 Not Now | 返回免费工具，试用未开始 |
| 新用户开启试用 | 当前 Pro 工具立即开放，30 天计时开始 |
| 试用期内离线 | Pro 正常使用 |
| 试用过期时 AI 请求正在进行 | 请求完成，下一次操作进入每日额度模式 |
| 当日首次打开 Parquet | 显示购买提示 |
| 当日再次打开 Parquet | 不显示提示 |
| 当日首次打开 Currency | 显示 Currency 购买提示，使用共享剩余时间 |
| Pro 使用 4 分钟后切换免费工具 | 剩余约 6 分钟且暂停 |
| Pro 使用 4 分钟后切换另一 Pro 工具 | 继续消耗同一剩余时间 |
| 每日额度耗尽 | 当前内容保留，新 Pro 操作被限制 |
| 到第二天 | 额度恢复为 600 秒，工具提示集合清空 |
| 购买成功 | 全部 Pro 立即永久开放 |
| 用户取消购买 | 保持原状态，无错误弹窗 |
| Ask to Buy / pending | 保持原状态并显示等待确认 |
| 已购用户换机 | Restore Purchases 后恢复 Pro |
| Legacy 用户更新版本 | 自动显示 Early Supporter Pro |
| 免费切换边界用户 | 宁可授予 Legacy Pro，不要求二次付费 |
| StoreKit 暂时不可用 | 已缓存权益继续有效 |
| Decode JWT Spotlight 命令 | 免费执行，不消耗额度 |
| Hash Text Spotlight 命令 | 免费执行，不消耗额度 |

---

## 19. 风险与缓解措施

### 19.1 每日 10 分钟足以完成大部分任务

**风险：** 开发工具单次操作通常很短，用户可能长期依赖每日额度而不购买。  
**缓解：** 先运行至少 6 周，观察连续使用和额度耗尽数据；必要时单独测试 5 分钟或每周次数，不同时改变价格。

### 19.2 每工具每日提示引起反感

**风险：** 高频切换多个 Pro 工具的用户一天可能看到多个提示。  
**缓解：** 每工具每天最多一次；允许 Escape；不在启动和处理中出现；提示必须轻量、快速继续。

### 19.3 Legacy Pro 误判

**风险：** 原付费用户被要求再次购买会造成严重信任损失和差评。  
**缓解：** 先发布付费过渡版本；使用 AppTransaction；设置宽限；边界优先授予权益；保留人工支持方案。

### 19.4 免费下载提高用户量但降低收入

**风险：** 免费用户增长但 Lifetime Pro 转化不足。  
**缓解：** 保持 $29.99 不变以隔离变量；比较切换前后 8 周收入；根据真实驱动购买的工具调整 Pro 组合。

### 19.5 本地试用和额度被绕过

**风险：** 用户可通过高级手段修改本地状态。  
**缓解：** Keychain、防时间回退和 AppTransaction 足以覆盖普通场景；本版本不引入账号或服务器 DRM。

### 19.6 App Store 价格切换非原子

**风险：** 过渡期用户可能付费下载，却被新版本识别为免费用户。  
**缓解：** 以实际购买日期判断 Legacy Pro；设置 24–48 小时宽限；上线期间执行真实账号验证。

---

## 20. 待配置项

以下不阻塞 PRD 评审，但必须在发布前确定：

1. App Store 实际免费生效时间和 Legacy Pro 截止时间。
2. Lifetime Pro 是否开启 Family Sharing。
3. 各地区是否完全使用 Apple 自动价格，还是对中国等市场单独定价。
4. StoreKit 商品本地化文案。
5. App Store 新截图与描述。
6. 客服处理 Legacy Pro 边界争议的标准流程。

---

## 21. 发布后决策规则

上线 6–8 周后仅做以下三种决策之一：

### 21.1 保持方案

适用条件：下载、激活、收入和评分均符合预期，每日额度没有明显替代购买。

### 21.2 收紧每日额度

适用条件：大量用户持续使用 Pro，但购买转化显著不足，且大部分用户从不耗尽 10 分钟。

可测试：

- 600 秒改为 300 秒；或
- 每周固定若干次 Pro session。

### 21.3 调整 Pro 工具组合或购买表达

适用条件：试用开启率低，或者用户无法理解 Pro 价值。

优先调整：

- 商店页和应用内价值表达。
- Pro 工具展示顺序。
- Parquet、Data Converter、Struct Converter 的工作流案例。

不要优先增加新工具，也不要同时降价和缩短额度。

---

## 22. 最终产品承诺

DevUtilities 免费模式应遵守以下长期承诺：

1. 免费工具不会在用户没有明确通知的情况下突然全部收费。
2. Lifetime Pro 是一次购买、永久使用，不变成周期付费。
3. 原付费下载用户永久保留完整 Pro 权益。
4. 试用和每日额度到期不删除用户数据。
5. 购买提示不阻断免费工具。
6. 用户内容保持本地处理原则；分析事件不包含内容。
7. 商业模式调整优先保护已经支持产品的用户。

