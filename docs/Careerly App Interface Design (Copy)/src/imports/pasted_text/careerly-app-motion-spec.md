请为当前 Careerly App 建立一套完整的「页面切换 + 按钮微交互 + Liquid Glass 交互」系统。

不要重新设计页面视觉结构。
保持当前已经确定的 Careerly UI、布局、颜色、字体、卡片和 Liquid Glass 导航栏。

本次重点只优化：

1. 页面之间如何切换
2. 页面进入 / 离开动画
3. 按钮 Press / Release 状态
4. Tab Bar 交互
5. Liquid Glass 动态反馈
6. 上传 / 解析 / 分析过程
7. 成功 / 错误 / 空状态反馈
8. 列表与卡片交互
9. AI 相关操作反馈

整体目标：

让 Careerly 感觉像一个真正成熟的高级消费级 App，
而不是“静态 Figma 页面拼接”。

视觉参考：
Apple iOS 26 / Liquid Glass
Apple Human Interface Guidelines
高级消费级 App
克制、流畅、自然、具有物理感。

不要加入夸张动画。
不要使用网页式的 hover 动画。
不要使用大量 bounce。
不要使用游戏化动画。
不要让动画抢过内容本身。

Motion 的核心原则：

「快、轻、连续、有因果关系。」
一、全局 Motion 原则
建立 Careerly 全局动画规则：

所有动画必须有明确目的：

- 表示页面正在进入
- 表示用户点击成功
- 表示内容发生变化
- 表示系统正在工作
- 表示任务完成
- 表示错误
- 表示元素之间存在连续关系

不要为了“好看”而添加动画。

动画应该帮助用户理解：
“我刚刚做了什么”
“现在发生了什么”
“接下来会发生什么”

Apple 的官方原则也明确强调，Motion 应该帮助表达状态、反馈和操作，而不是为了动画本身而动画。

二、页面切换 Transition
1. 一级导航

Careerly：

首页
分析
AI
我的

切换一级页面时：

不使用：
❌ 大幅左右滑动
❌ 旋转
❌ 缩放过度
❌ 页面从下方弹出
❌ 卡片式翻页

使用：

「轻微淡入 + 内容位移」

页面切换：

旧页面
↓
内容轻微淡出
↓
新页面进入
↓
主要内容从 8–12px 下方轻微上移
↓
稳定

动画时长：

180–260ms

推荐：

opacity:
0 → 1

translationY:
8px → 0

使用 ease-out / smooth easing。

整个过程必须非常轻。

三、二级页面进入

例如：

我的
 ↓
我的简历

我的
 ↓
职业资产

历史分析
 ↓
分析详情

这种属于“深入内容”。

使用：

Shared Axis / Push Transition

新页面：

从右侧轻微进入

旧页面：

向左移动少量距离

但不要做传统 Android 页面那种明显的整页横向滑动。

建议：

translationX:
16–24px

duration:
240–300ms

进入时：

opacity:
0 → 1
四、返回操作

返回必须和进入形成相反关系。

例如：

我的
 ↓
职业资产

进入：

职业资产 → 从右侧进入

返回：

职业资产 → 向右退出
我的 → 恢复

不要：

❌ 返回时重新淡入整个页面
❌ 返回直接瞬移

用户应该感觉：

“我从哪里进入，就回到哪里。”

Apple 强调可预测、可恢复的交互和一致反馈。

五、首次 onboarding 页面切换

首次用户流程：

价值介绍
↓
建立职业画像
↓
上传简历
↓
目标岗位
↓
分析
↓
分析报告
↓
职业档案

这里不要使用普通 Tab Navigation。

应该使用：

Progressive Flow

每一步都有连续关系。

例如：

价值介绍
      ↓
下一步
      ↓
当前页面内容轻微向左移动
      ↓
下一页面从右侧进入

动画：

duration: 280–320ms

保持轻微。

六、「下一步 / 继续」按钮微交互

所有主要 CTA 必须设计 4 个状态：

1. Default
2. Pressed
3. Loading
4. Success
Default

正常状态：

opacity: 100%
scale: 1
Pressed

用户按下：

scale: 0.97–0.98
opacity: 0.92

持续时间：

80–120ms

不要产生明显位移。

如果是 Liquid Glass 按钮：

允许产生非常轻微的：

glass highlight
+
light refraction
+
scale

Apple 最新 Liquid Glass 的交互控件本身会产生缩放、bounce 等直接反馈，因此 Careerly 可以借鉴这种“材质响应触摸”的感觉。

七、按钮释放

Release：

scale:
0.97 → 1

duration:
150–200ms

不要使用夸张的 bounce。

可以使用非常轻微的 spring：

1 → 1.015 → 1

只允许极轻微回弹。

八、主要 CTA 的 Loading

例如：

开始分析
上传简历
继续

点击以后：

按钮内容：

开始分析

变成：

分析中…

或者：

Uploading…

按钮保持原位置。

不要让整个页面突然出现大 Loading。

例如：

[ 开始分析 ]

变成：

[  ◌  正在分析 ]

按钮保持宽度不变。

九、上传简历交互

用户点击：

上传简历

之后：

① Press

按钮轻微缩放。

② 文件选择

系统文件选择器。

③ 返回 App

文件卡片 Materialize：

透明
↓
轻微放大
↓
卡片出现

duration：

250–350ms

然后：

Resume.pdf

✓ 已上传

✓ 图标使用非常轻的 scale animation：

0.8 → 1.05 → 1
十、简历解析过程

页面：

正在认识你的职业经历

不要使用无限旋转 Spinner 作为主要视觉。

使用：

Progressive Progress

例如：

✓ 读取简历
✓ 提取工作经历
● 整理项目经历
○ 识别技能
○ 建立职业画像

当前项目：

●

轻微呼吸动画。

完成：

● → ✓

并且下一项自动激活。

这种反馈应该让用户感觉：

AI 正在真正工作。

十一、目标岗位输入

用户点击：

粘贴岗位 JD

输入框获得焦点：

border / glass highlight
↑
轻微增强

不要突然改变整个页面颜色。

输入完成以后：

Paste JD
↓
内容出现
↓
自动识别

可以显示：

✓ 已识别岗位

AI 产品经理
示例科技

卡片从输入框附近自然展开。

十二、粘贴岗位 JD / URL 后

这是 Careerly 一个非常重要的流程。

我们已经确定：

用户粘贴岗位 JD 或岗位链接后，直接开始匹配分析。

所以：

粘贴
↓
识别岗位
↓
自动开始分析

不要再增加“确认岗位”页面。

动画：

输入框
↓
岗位卡片 materialize
↓
开始分析
↓
页面进入分析状态

让整个过程感觉像：

“我把岗位交给 Careerly，Careerly 自动开始工作。”

十三、分析过程动画

页面：

正在分析你的职业状态

建议：

解析你的职业经历
✓

理解岗位要求
✓

比较能力匹配
●

识别核心 Gap
○

生成职业报告
○

当前任务：

轻微 shimmer / breathing。

不要：

❌ 巨大的 AI 机器人
❌ 大型旋转圆环
❌ 彩色霓虹
❌ 复杂 3D 动画

保持高级、克制。

十四、分析完成 → 报告

这是整个 Careerly 最重要的 Transition。

不要直接：

Loading
↓
页面瞬间替换

而应该：

分析进度完成
↓
最后一个 ✓
↓
整体内容轻微稳定
↓
报告页面进入

报告核心数字：

86%

可以使用：

Number Reveal
0
↓
42
↓
68
↓
79
↓
86

duration：

500–700ms

但不要快速滚动得像老虎机。

应该是平滑计数。

十五、分析报告卡片

报告中的：

优势
Gap
能力
匹配度

不要全部同时出现。

使用：

Staggered Reveal

例如：

匹配度
↓
200ms
↓
优势
↓
150ms
↓
Gap
↓
150ms
↓
下一步建议

每个模块：

opacity: 0 → 1
translationY: 8px → 0

整体 duration：

约 400–600ms。

十六、报告中的能力条

例如：

产品规划     █████████ 85
用户研究     ████████  78
数据分析     ██████    60

进入页面后：

0%
↓
目标值

用 500–700ms 缓慢增长。

不要同时全部高速动画。

按照从上到下顺序依次出现。

十七、「查看完整报告」按钮

如果用户点击：

查看完整职业分析

按钮：

scale 0.97
↓
release
↓
页面 push

报告详情页面从右侧进入。

保持上下文连续。

十八、分析历史列表

历史分析卡片：

2026.09.03

AI 产品经理
86%

点击：

Card Press

卡片：

scale: 0.98

同时：

shadow / glass highlight

然后进入详情。

不要整个卡片突然变色。

十九、职业资产卡片交互

我的：

工作经历
项目经历
技能
奖项

点击：

卡片轻微：

scale 0.98

然后进入列表。

进入列表后：

标题
↓
列表内容 staggered reveal

例如：

工作经历

产品经理
2024–2026

↓

建筑设计师
2021–2024

每一项延迟：

50–80ms

不要超过 500ms 总时长。

二十、底部 Liquid Glass Navigation

底部导航是全局最高频交互。

必须设计：

Default

透明 Liquid Glass。

Pressed

点击：

scale 0.96–0.98

玻璃内部：

highlight ↑
Selected

当前 Tab：

icon tint
+
soft glass highlight
+
slight inner light

不要使用紫色实心背景。

Tab 切换

选中状态应该：

流动 / morph 到新的位置

而不是：

旧选中状态消失
+
新选中状态突然出现

尽量让选中状态像一块液态玻璃在导航项之间移动。

Apple 的 Liquid Glass 支持元素之间的 fluid morphing，并可以让玻璃元素在交互时缩放、弹性变化。

二十一、AI 按钮

AI 是 Careerly 的核心陪伴入口。

点击：

AI Glass Button
↓
scale 0.96
↓
glass highlight
↓
AI 页面进入

AI 页面打开时：

不要普通 Fade。

建议：

AI 按钮
↓
轻微放大
↓
Morph
↓
变成 AI 页面顶部的主要入口 / 对话区域

如果 Figma Make 无法真正实现 Morph：

使用：

scale + fade + shared position

模拟连续运动。

二十二、所有 Icon Button

例如：

返回
关闭
编辑
删除
更多
分享

必须统一：

Press
scale 0.90–0.95
opacity 0.85
Release
scale 1

不要给每个 Icon Button 设置不同动画。

二十三、删除操作

例如：

删除历史简历

不要立即删除。

点击：

Delete
↓
轻微反馈
↓
确认操作

如果确认：

卡片向左轻微收缩
opacity 1 → 0
height 100% → 0

duration：

220–300ms

下面的内容自然上移。

如果可以撤销：

显示：

已删除 · 撤销

Apple 也强调应该让用户能够恢复错误操作，减少操作成本。

二十四、Toast / Snackbar

不要大量使用 Toast。

只用于：

保存成功
复制成功
删除成功
简历更新成功

动画：

bottom:
+8px → 0

opacity:
0 → 1

退出：

opacity:
1 → 0

duration：

150–200ms
二十五、错误状态

错误不要：

❌ 红色巨大警告
❌ 页面震动
❌ 大幅弹窗

例如岗位 JD 无法解析：

无法识别这个岗位

请检查链接是否有效，
或者直接粘贴岗位 JD。

[ 重新尝试 ]

[ 粘贴 JD ]

按钮轻微 Press feedback 即可。

二十六、所有按钮必须建立统一状态系统

请为 Figma 建立 Button Component Variants：

Button
├── Primary
│   ├── Default
│   ├── Pressed
│   ├── Loading
│   ├── Disabled
│   └── Success
│
├── Secondary
│   ├── Default
│   ├── Pressed
│   └── Disabled
│
└── Glass
    ├── Default
    ├── Pressed
    ├── Selected
    └── Disabled

同时建立：

Icon Button
├── Default
├── Pressed
├── Selected
└── Disabled
二十七、页面 Transition 统一规范

建立以下 Transition Tokens：

Micro Interaction
80–120ms

Button Feedback
120–200ms

Small Component
180–240ms

Page Transition
240–320ms

Modal / Sheet
300–400ms

Major Result Reveal
400–700ms

不要每个页面随意设置动画时间。

二十八、最重要：不要让所有东西一起动

这是高级 UI 和“AI 生成页面”的一个非常明显区别。

不要：

页面进入
↓
标题动
↓
按钮动
↓
卡片动
↓
背景动
↓
图标动
↓
数字动
↓
导航栏动

这样会非常廉价。

应该建立：

Motion Hierarchy
一级：
页面 / 核心内容

二级：
主要 CTA

三级：
辅助信息

四级：
装饰

只有核心变化才使用明显动画。

二十九、Liquid Glass 特别要求

请遵循最新 Apple Liquid Glass 的设计逻辑：

Liquid Glass 是：

Interactive Layer

不是普通内容卡片。

它主要用于：

Bottom Tab Bar
Floating AI Button
重要 Floating Controls

不要把所有 Careerly 卡片都变成 Liquid Glass。

Apple 官方明确建议限制 Liquid Glass 到最重要的功能元素，并让内容层与控制层保持清晰层级。

三十、最终请给 Figma Make 做成一个完整 Prototype

必须至少实现以下可点击流程：

首次使用

欢迎
 ↓
建立职业画像
 ↓
上传简历
 ↓
简历解析
 ↓
目标岗位
 ↓
自动开始分析
 ↓
分析过程
 ↓
分析报告
 ↓
职业档案

以及：

首页
 ↕
分析
 ↕
AI
 ↕
我的

以及：

分析
 ↓
新建分析
 ↓
粘贴 JD / URL
 ↓
自动分析
 ↓
结果

以及：

分析
 ↓
历史分析
 ↓
分析详情

以及：

我的
 ↓
职业资产
 ↓
工作经历
 ↓
经历详情

以及：

我的
 ↓
我的简历
 ↓
简历历史
 ↓
切换当前简历

所有这些页面必须使用统一的：

Transition
Button interaction
Press state
Loading state
Success state
Liquid Glass behavior
Easing
Duration
Spacing

不要只做静态页面。

请将整个 Careerly Prototype 设计成“可连续体验”的产品，而不是页面集合。