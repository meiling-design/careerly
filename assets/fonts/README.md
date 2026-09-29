# Careerly 字体资源

> ⚠️ **当前此目录为空。这是一个已知的、已上报的资源缺口。**

## 状态

| 项 | 状态 |
|---|---|
| 中文 UI 字体决策 | ✅ 已锁定：**Noto Sans SC**（Phase 0 O1） |
| Typography Token | ✅ 已建立：`lib/design_system/tokens/app_typography.dart` |
| Theme 声明 | ✅ 已声明：`CareerlyTheme` → `fontFamily: 'Noto Sans SC'` |
| **字体文件** | ❌ **缺失** |

## 为什么没有字体文件

Phase 1 明确要求：

> 如果当前没有字体文件：**不要自行从网络下载字体**。

因此 Phase 1 的处理方式是：
1. 建立完整 Typography Token
2. 在 Token 与 Theme 中**明确声明** Noto Sans SC
3. 记录缺口（本文件 + `docs/phase_1_report.md`）
4. **不使用其他中文字体偷偷替代产品决策**

## 当前运行时会怎样

`fontFamily: 'Noto Sans SC'` 已写入 Theme。由于系统中通常没有注册该字体族，
Android 会**由平台回退**到系统中文字体渲染。

这是**运行时的回退行为**，不是本项目的字体选择——
代码中没有任何一处写入了其他中文字体。

## 补齐方式

把 Noto Sans SC 的字体文件放入本目录，然后在 `pubspec.yaml` 中注册：

```yaml
flutter:
  fonts:
    - family: Noto Sans SC
      fonts:
        - asset: assets/fonts/NotoSansSC-Regular.ttf
          weight: 400
        - asset: assets/fonts/NotoSansSC-Medium.ttf
          weight: 500
        - asset: assets/fonts/NotoSansSC-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/NotoSansSC-Bold.ttf
          weight: 700
```

注册后**不需要改动任何 Dart 代码**——
`AppTypography.fontFamilyChinese` 的值已经与上面的 `family` 一致。

## 其他字体

- **英文 / 数字**：Phase 2 确认最终方案。
  当前 `AppTypography.fontFamilyNumeric` 为 `null`，数字沿用中文字体族。
- **Logo**：属于独立 Brand Asset，**不属于** UI Typography Token。
