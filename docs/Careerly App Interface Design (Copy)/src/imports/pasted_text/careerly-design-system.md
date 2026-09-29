# Careerly Figma Design System V1.0

> **产品名称：** Careerly  
> **对应版本：** V1.0 MVP  
> **平台：** Flutter / Android  
> **设计工具：** Figma  
> **Design Language：** Material 3 × iOS Minimal Glassmorphism  
> **文档类型：** 视觉与组件规范  
> **状态：** 设计系统建立阶段  
> **更新时间：** 2026-08

---

## 文档定位

本文档定义 Careerly 从产品策略到 Figma 高保真设计、再到 Flutter Material 3 开发之间的**视觉与组件规范**。

### 文档链路

```
01_PRD                        → 定义产品价值
       ↓
02_Design Direction           → 定义设计语言
       ↓
03_Core Function              → 定义功能逻辑
       ↓
04_IA Page Specification      → 定义页面结构
       ↓
05_Figma Design System        → 定义视觉实现
```

### 本版本重点

- Design Token
- 色彩系统
- Typography
- Layout Grid
- Glassmorphism 规范
- Card 组件 / Match 组件 / Career Asset 组件 / Chart 组件 / Button 状态
- Flutter Material 3 映射

---

## 目录

- [一、Design System 设计目标](#一design-system-设计目标)
- [二、视觉设计原则](#二视觉设计原则)
- [三、Design Token — 色彩系统](#三design-token--色彩系统)
- [四、Glassmorphism 规范](#四glassmorphism-规范)
- [五、Typography 系统](#五typography-系统)
- [六、Spacing System](#六spacing-system)
- [七、Layout 规范](#七layout-规范)
- [八、核心组件规范](#八核心组件规范)
- [九、图表规范](#九图表规范)
- [十、Animation 规范](#十animation-规范)
- [十一、Flutter Material 3 映射](#十一flutter-material-3-映射)
- [十二、Figma 组件结构](#十二figma-组件结构)
- [十三、高保真设计验收标准](#十三高保真设计验收标准)
- [十四、最终设计定位](#十四最终设计定位)
- [附录：Careerly 完整设计开发体系](#附录careerly-完整设计开发体系)

---

## 一、Design System 设计目标

### 1.1 核心设计目标

Careerly 的视觉系统需要同时满足三种情绪表达：

| 情绪 | 用途 |
|------|------|
| **专业可信** | 职业分析、能力评估、岗位匹配 |
| **温暖陪伴** | 成长记录、能力变化、长期使用 |
| **高级克制** | 避免传统招聘平台的信息焦虑 |

### 1.2 设计关键词

| 英文 | 中文 |
|------|------|
| Clear | 清晰 |
| Professional | 专业 |
| Warm | 温暖 |
| Calm | 克制 |
| Growth | 成长 |

---

## 二、视觉设计原则

### Principle 01：数据必须有情绪温度

Careerly 不是数据分析工具，数字不是冷冰冰评分。

| ❌ 错误 | ✅ 正确 |
|---------|--------|
| 86 分 | 86% ↑ +8 — 因为新增 AI 项目经历 |

### Principle 02：所有变化必须被看见

强调 **Before → After** 的视觉对比：

```
72%  →  86%
```

变化需通过颜色、动画、趋势箭头等多维度呈现。

### Principle 03：信息层级优先

页面信息按以下优先级排列：

```
状态 → 变化 → 原因 → 详情
```

用户首先感知当前状态，其次看到变化，再了解原因，最后按需查看详情。

---

## 三、Design Token — 色彩系统

Careerly 采用**浅色玻璃拟态体系**。

### 3.1 Page Background

线性渐变背景：

| Token | 值 |
|-------|----|
| Gradient Start | `#DDE9FA` |
| Gradient End | `#FFF1F3` |

**用途：** 首页背景、资产页面背景

### 3.2 Brand Color — Primary Gradient

品牌主色蓝紫渐变：

| Token | 值 |
|-------|----|
| Primary Blue | `#4F7EF5` |
| Primary Purple | `#A77BE6` |

**用途：** 主按钮、重要数据、AI 相关状态

### 3.3 Secondary Color

| 色彩 | 值 | 用途 |
|------|----|------|
| Growth Green | `#34C759` | 成长提升、正向变化 |
| Warning Orange | `#FF9500` | Gap 提醒 |

### 3.4 Neutral

| Token | 值 |
|-------|----|
| White | `#FFFFFF` |
| Text Primary | `#111827` |
| Text Secondary | `#6B7280` |
| Divider | `#E5E7EB` |

---

## 四、Glassmorphism 规范

Glass Card 是 Careerly 的核心视觉元素，贯穿所有页面。

### 4.1 Glass Card 属性

| 属性 | 值 |
|------|----|
| Background Fill | `rgba(255, 255, 255, 0.60)` |
| Border | `rgba(255, 255, 255, 0.50)` |
| Blur | `24px` |
| Shadow | `0 8px 24px rgba(98, 118, 222, 0.08)` |

### 4.2 圆角规范

| 尺寸 | 圆角值 | 用途 |
|------|--------|------|
| Large | `24px` | 主卡片 |
| Medium | `16px` | 次级卡片 |
| Small | `12px` | 小组件/标签 |

---

## 五、Typography 系统

采用 **Android Material 3 Typography**，同时保持 Apple 式精致比例。

| 类型 | 用途 | 示例 | 字号 | 字重 |
|------|------|------|------|------|
| Display | 首页核心数字 | 86% | 40px | Bold |
| Heading | 页面标题 | — | 28px | Semibold |
| Card Title | 卡片标题 | — | 18px | Medium |
| Body | 正文内容 | — | 16px | Regular |
| Caption | 辅助说明 | — | 13px | Regular |

---

## 六、Spacing System

采用 **8px 基础单位**，所有间距为 8 的倍数：

| Token | 值 |
|-------|----|
| `space-xs` | 4px |
| `space-sm` | 8px |
| `space-md` | 12px |
| `space-base` | 16px |
| `space-lg` | 24px |
| `space-xl` | 32px |
| `space-2xl` | 40px |
| `space-3xl` | 48px |

---

## 七、Layout 规范

### 7.1 Mobile Frame

| 平台 | 尺寸 |
|------|------|
| Android | 390 × 844 |

### 7.2 页面布局参数

| 参数 | 值 |
|------|----|
| Horizontal Padding | 20px |
| Vertical Padding | 24px |
| Card 间距 | 16px |

---

## 八、核心组件规范

### 8.1 Career Asset Card

**用途：** 首页职业资产概览

**结构：** Title → Score → Trend → Reason

**示例：**

| 字段 | 值 |
|------|----|
| Title | 职业资产指数 |
| Score | 82 |
| Trend | ↑ +5 |
| Reason | 新增 AI 项目经历 |

**参数：**

| 参数 | 值 |
|------|----|
| Width | 100% |
| Radius | 24px |
| Padding | 20px |

---

### 8.2 Match Card

**用途：** 岗位匹配展示

**结构：** 岗位名称 → 匹配度 → 排名 → 变化 → 原因

**示例：**

| 字段 | 值 |
|------|----|
| 岗位名称 | AI 产品经理 |
| 匹配度 | 86% |
| 排名 | Rank #1 |
| 变化 | ↑ +8 |
| 原因 | AI 项目经验匹配 |

**视觉重点：** 匹配度数字最大、最突出。

---

### 8.3 Ranking Component

**用途：** 多岗位排序展示

**结构：**

```
01    岗位名称    86%    ↑8
```

**状态样式：**

| 排名 | 样式 |
|------|------|
| 第一名 | Primary Gradient 背景 |
| 其他 | Neutral 背景 |

---

### 8.4 Gap Card

**用途：** 展示成长空间

**设计原则：** 避免负面表达

| ❌ 不用 | ✅ 使用 |
|---------|--------|
| 缺陷 | 成长空间 |

**示例：**

```
成长空间
├── 商业化经验
└── 数据分析能力
```

---

### 8.5 Skill Trend Card

**用途：** 能力变化展示

**结构：** 能力名称 → 旧值 → 新值 → 变化值

**示例：**

| 能力 | 旧值 | 新值 | 变化 |
|------|------|------|------|
| AI 能力 | 60 | 72 | +12 |

**组件包含：** 数字、趋势箭头、时间标签

---

### 8.6 Growth Timeline

**用途：** 成长记录展示

**结构：** 时间 → 事件 → 影响

**示例：**

| 时间 | 事件 | 影响 |
|------|------|------|
| 2026.08 | 新增 AI Agent 项目 | AI 能力 +8 |

---

## 九、图表规范

### 9.1 能力趋势图

| 属性 | 值 |
|------|----|
| 类型 | Line Chart |
| 用途 | 能力变化趋势 |
| 要求 | 简洁，不展示复杂坐标 |

### 9.2 匹配变化图

| 属性 | 值 |
|------|----|
| 类型 | Progress Chart |
| 示例 | 72% → 86% |

---

## 十、Animation 规范

动画的核心目的是**表达变化**，而非装饰。

| 动画 | 场景 | 时长 |
|------|------|------|
| **Match Increase** | 匹配度数字增长（如 72% → 86%） | 600ms |
| **Asset Update** | 新增经历时卡片展开 | 300ms |
| **Page Transition** | 页面切换 | Material 3 Motion 标准 |

---

## 十一、Flutter Material 3 映射

### 11.1 ColorScheme

```dart
ColorScheme(
  primary: Color(0xFF4F7EF5),
  secondary: Color(0xFFA77BE6),
)
```

### 11.2 Card — 玻璃效果实现

```dart
Card(
  // 配合 BackdropFilter 实现玻璃效果
  child: BackdropFilter(...)
)
```

### 11.3 Typography

使用 Material 3 `TextTheme`，映射至第五章定义的字号/字重。

### 11.4 Navigation

使用 Material 3 `NavigationBar` 实现底部四 Tab 导航。

---

## 十二、Figma 组件结构

建议 Figma 文件结构如下：

```
Careerly Design System
├── Foundations
│   ├── Colors
│   ├── Typography
│   └── Spacing
├── Components
│   ├── Cards
│   ├── Buttons
│   ├── Charts
│   └── Icons
├── Patterns
│   ├── Match Result
│   ├── Career Asset
│   └── Growth Timeline
└── Pages
    ├── Home
    ├── Analysis
    ├── AI
    └── Assets
```

---

## 十三、高保真设计验收标准

页面设计必须满足以下四项验收标准：

| 序号 | 验收标准 | 时间要求 |
|------|----------|----------|
| 1 | 用户知道当前职业状态 | 3 秒内 |
| 2 | 用户知道哪个岗位最适合 | 5 秒内 |
| 3 | 用户知道为什么匹配 | 10 秒内 |
| 4 | 用户再次回来可以看到变化 | 持续 |

---

## 十四、最终设计定位

Careerly 视觉**不是**招聘平台，**不是** AI 工具。

**而是：**

> 一个属于个人的职业能力仪表盘。

### 视觉表达

| 灵感来源 | 借鉴维度 |
|----------|----------|
| Apple Health | 反馈感 |
| Notion | 资产感 |
| Day One | 成长温度 |

### 最终体验

```
用户打开 Careerly：
  看到 → "现在的我。"
  理解 → "为什么。"
  记录 → "如何变得更好。"
```

---

## 附录：Careerly 完整设计开发体系

Careerly V1.0 已形成完整的五层设计开发体系：

```
01 PRD                         产品战略
       ↓
02 Design Direction            设计方向
       ↓
03 Core Function               功能规格
       ↓
04 IA Page Spec                页面规范
       ↓
05 Design System               视觉系统
```

| 文档 | 定位 | 回答的问题 |
|------|------|-----------|
| 01 PRD | 产品战略 | 为什么做？解决什么问题？ |
| 02 Design Direction | 设计方向 | 如何表达产品价值？ |
| 03 Core Function Spec | 功能规格 | 如何实现核心功能？ |
| 04 IA & Page Spec | 页面规范 | 如何构建具体页面？ |
| 05 Figma Design System | 视觉系统 | 如何落地视觉与组件？ |

---

*本文档（05_Careerly_Figma_Design_System_V1.0.md）完成。*
