# GitHub Actions 配置说明

这个目录包含了Lumi Assistant项目的GitHub Actions工作流配置，用于自动构建和发布Android APK。

## 📁 文件结构

```
.github/
├── workflows/
│   ├── build-and-release.yml    # 主要的构建和发布工作流
│   └── test-build.yml           # 快速测试工作流
├── scripts/
│   ├── version-generator.sh     # 版本号生成脚本
│   └── release-generator.sh     # Release描述生成脚本
├── release-template.md          # Release描述模板
└── README.md                    # 本说明文件
```

## 🚀 工作流说明

### 1. build-and-release.yml（主工作流）

**触发条件**：
- 推送到 `main` 分支
- 对 `main` 分支的Pull Request
- 手动触发（workflow_dispatch）

**功能特性**：
- ✅ 代码质量检查（analyze + test）
- 🔨 自动构建Android APK
- 📝 自动生成版本号（带pre前缀）
- 📦 自动创建GitHub Release
- 🏷️ 自动标记为预发布版本
- 📄 详细的Release描述

**构建产物**：
- Debug APK文件
- 版本信息
- 构建日志

### 2. test-build.yml（测试工作流）

**触发条件**：
- 手动触发，支持选择测试类型

**测试选项**：
- `version-only`: 仅测试版本生成
- `build-only`: 仅测试构建流程
- `full-build`: 完整测试

## 🔧 版本号规则

### 版本格式
```
主版本.次版本.补丁版本-pre+构建号
例如: 0.1.123-pre+202401151230
```

### 版本组成
- **主版本**: 0（开发阶段固定）
- **次版本**: 1（功能版本）
- **补丁版本**: Git提交计数
- **预发布标识**: `pre`（开发阶段标识）
- **构建号**: 时间戳（YYYYMMDDHHmm）

### 示例版本号
```bash
# 主分支推送
0.1.156-pre+202401151230

# 功能分支（如果配置）
0.1.156-feature-audio.a1b2c3d
```

## 📱 发布流程

### 自动发布（main分支）
1. 推送代码到main分支
2. GitHub Actions自动触发
3. 执行代码质量检查
4. 构建Android APK
5. 生成版本号和Release描述
6. 创建GitHub Release
7. 上传APK到Release

### 手动发布
1. 在GitHub上访问Actions页面
2. 选择"Build and Release Android APK"工作流
3. 点击"Run workflow"
4. 选择分支并确认

## 🛠️ 脚本功能

### version-generator.sh
- 自动生成符合规范的版本号
- 基于Git历史计算版本
- 支持多分支版本策略
- 输出到GitHub Actions环境

### release-generator.sh
- 基于模板生成Release描述
- 自动替换版本信息
- 包含构建信息和技术细节
- 生成用户友好的安装说明

## 📋 配置要求

### GitHub仓库设置
- 确保仓库已启用Actions
- 无需额外的Secrets（使用默认GITHUB_TOKEN）

### 依赖版本
- **Flutter**: 3.24.3
- **Java**: 17
- **Android**: API 23+

### 权限要求
```yaml
permissions:
  contents: write  # 创建Release
  actions: read    # 读取Actions
```

## 🔍 故障排查

### 常见问题

1. **构建失败**
   ```bash
   # 检查Flutter版本
   flutter --version
   
   # 检查依赖
   flutter pub get
   flutter analyze
   ```

2. **版本生成失败**
   ```bash
   # 本地测试版本脚本
   ./.github/scripts/version-generator.sh
   ```

3. **Release创建失败**
   ```bash
   # 检查权限设置
   # 确保GITHUB_TOKEN有写权限
   ```

### 调试技巧

1. **本地测试脚本**：
   ```bash
   # 测试版本生成
   ./.github/scripts/version-generator.sh
   
   # 测试Release生成
   ./.github/scripts/release-generator.sh
   ```

2. **使用测试工作流**：
   - 访问Actions页面
   - 运行"Test Build"工作流
   - 选择合适的测试类型

3. **查看详细日志**：
   - Actions执行页面查看每个步骤的详细输出
   - 检查构建产物和错误信息

## 📈 优化建议

### 性能优化
- 使用Actions缓存加速构建
- 并行执行独立任务
- 优化Docker镜像和依赖安装

### 安全优化
- 定期更新Actions版本
- 使用最小权限原则
- 验证第三方Actions

### 功能扩展
- 添加iOS构建支持
- 集成自动化测试
- 添加通知机制
- 支持多环境部署

## 📚 相关文档

- [GitHub Actions文档](https://docs.github.com/en/actions)
- [Flutter CI/CD指南](https://docs.flutter.dev/deployment/cd)
- [Android构建配置](https://developer.android.com/studio/build)

## 🤝 贡献指南

如需修改构建配置：

1. Fork仓库
2. 修改工作流文件
3. 本地测试脚本
4. 提交Pull Request
5. 等待Review和合并

---

> 📝 此配置专为Lumi Assistant开发阶段设计
> 
> 🔄 支持持续集成和自动化发布
> 
> 🚀 提升开发效率和代码质量