# Android HAL Audio Builder

## 项目说明

本项目用于编译修改后的Android Audio HAL库，实现VoIP-GSM桥接功能。

## 修改内容

- 修改了 `audio_hw.c` 以支持 `incall_music_uplink` 参数
- 实现了VoIP音频注入到GSM通话的功能

## 编译方法

使用GitHub Actions自动编译：

1. Fork本仓库
2. 进入 Actions 标签页
3. 运行 "Build Audio HAL" workflow
4. 下载编译产物

## 设备信息

- 设备代号: mi439 (red7a)
- Android版本: LineageOS 17.1
- 处理器: Qualcomm MSM8937

## 许可

遵循LineageOS/AOSP原有许可协议
