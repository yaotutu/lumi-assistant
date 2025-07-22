# 分支构建策略说明

## 📋 分支策略概览

项目采用清晰的分支构建策略，不同分支生成不同类型的APK版本：

| 分支 | 版本类型 | 构建方式 | 命名格式 | Release类型 |
|------|----------|----------|----------|-------------|
| **main** | 正式版本 | `--release` | `lumi-assistant-0.1.X-{arch}.apk` | 正式Release |
| **dev** | 开发测试 | `--debug` | `lumi-assistant-0.1.X-pre-{arch}-dev.apk` | 预发布 |
| **其他** | 分支构建 | `--debug` | `lumi-assistant-0.1.X-{branch}-{arch}-{branch}.apk` | 预发布 |

## 🏗️ 构建架构支持

每个分支都支持4种架构的APK：

### 🎯 特定架构版本（推荐）
- **ARM32**: `{name}-arm32{suffix}.apk` - 32位ARM设备
- **ARM64**: `{name}-arm64{suffix}.apk` - 64位ARM设备（推荐）
- **x64**: `{name}-x64{suffix}.apk` - x86_64架构设备

### 📦 通用版本
- **Universal**: `{name}-universal{suffix}.apk` - 包含所有架构

## 🚀 Main分支 (正式版本)

### 特点
- 🎯 **构建类型**: Release构建 (`flutter build apk --release`)
- 📦 **版本号**: `0.1.X` (无pre后缀)
- ✅ **Release类型**: 正式Release (`prerelease: false`)
- 🏆 **Latest**: 设置为最新版本 (`make_latest: true`)

### APK命名示例
```
lumi-assistant-0.1.69-arm32.apk
lumi-assistant-0.1.69-arm64.apk
lumi-assistant-0.1.69-x64.apk
lumi-assistant-0.1.69-universal.apk
```

### Release页面显示
- **标题**: 🚀 Release 0.1.69
- **说明**: 正式版本 - 包含 X 个更改
- **版本说明**: ✅ 正式版本 - 此为正式发布版本，经过完整测试和验证

## 🧪 Dev分支 (开发测试)

### 特点
- 🔧 **构建类型**: Debug构建 (`flutter build apk --debug`)
- 📦 **版本号**: `0.1.X-pre` (包含pre后缀)
- ⚠️ **Release类型**: 预发布 (`prerelease: true`)
- 📝 **Latest**: 不设为最新版本 (`make_latest: false`)

### APK命名示例
```
lumi-assistant-0.1.69-pre-arm32-dev.apk
lumi-assistant-0.1.69-pre-arm64-dev.apk
lumi-assistant-0.1.69-pre-x64-dev.apk
lumi-assistant-0.1.69-pre-universal-dev.apk
```

### Release页面显示
- **标题**: 🧪 Development 0.1.69-pre
- **说明**: 开发测试版本 - 包含 X 个更改
- **版本说明**: ⚠️ 开发测试版本 - 此为开发测试版本，包含最新功能但可能存在未完成功能和已知问题

## 🔧 其他分支 (功能分支)

### 特点
- 🛠️ **构建类型**: Debug构建 (`flutter build apk --debug`)
- 📦 **版本号**: `0.1.X-{branch}.{hash}` (包含分支名和提交哈希)
- 🔧 **Release类型**: 预发布 (`prerelease: true`)
- 📝 **Latest**: 不设为最新版本 (`make_latest: false`)

### APK命名示例（feature/audio分支）
```
lumi-assistant-0.1.69-feature-audio.a1b2c3d-arm32-feature-audio.apk
lumi-assistant-0.1.69-feature-audio.a1b2c3d-arm64-feature-audio.apk
lumi-assistant-0.1.69-feature-audio.a1b2c3d-x64-feature-audio.apk
lumi-assistant-0.1.69-feature-audio.a1b2c3d-universal-feature-audio.apk
```

### Release页面显示
- **标题**: 🔧 Branch Build 0.1.69-feature-audio.a1b2c3d
- **说明**: 分支构建版本 - 包含 X 个更改
- **版本说明**: 🔧 分支构建版本 - 此为特定分支的构建版本，仅用于功能测试和验证

## 📱 用户下载指南

### 推荐下载策略

1. **普通用户**: 下载main分支的ARM64版本
   - 文件: `lumi-assistant-0.1.X-arm64.apk`
   - 特点: 正式版本，体积小，稳定性好

2. **测试用户**: 下载dev分支的ARM64版本  
   - 文件: `lumi-assistant-0.1.X-pre-arm64-dev.apk`
   - 特点: 最新功能，可能有bug

3. **开发者**: 根据需要下载特定分支版本
   - 文件: `lumi-assistant-0.1.X-{branch}-arm64-{branch}.apk`
   - 特点: 特定功能测试

### 架构选择指南

| 设备类型 | 推荐架构 | 备选方案 |
|----------|----------|----------|
| 现代Android设备 | ARM64 | Universal |
| 老旧32位设备 | ARM32 | Universal |
| 模拟器/x86设备 | x64 | Universal |
| 不确定设备类型 | Universal | - |

## 🔄 自动化流程

### 触发条件
- **push到main**: 创建正式Release
- **push到dev**: 创建开发预发布
- **push到其他分支**: 创建分支预发布
- **手动触发**: 支持强制发布任何分支

### 构建矩阵
```yaml
strategy:
  matrix:
    arch: [arm32, arm64, x64, universal]
```

### 并行构建
- 4种架构同时构建，提高效率
- 每种架构独立上传，便于选择下载
- 自动生成包含所有架构的Release

## 🎯 最佳实践

### 开发流程
1. **功能开发**: 在feature分支开发新功能
2. **集成测试**: 合并到dev分支进行集成测试
3. **正式发布**: 从dev合并到main发布正式版本

### 版本管理
- main分支版本号递增，无pre后缀
- dev分支包含pre后缀，表示预发布
- 功能分支包含分支名，便于识别

### 用户体验
- 清晰的版本标识，用户易于区分
- 详细的下载指南，降低选择难度
- 多架构支持，优化安装体积

---

> 📝 此策略确保了清晰的版本管理和用户友好的下载体验
> 
> 🔄 支持灵活的开发流程和自动化构建
> 
> 🚀 提供最优的APK体积和兼容性平衡