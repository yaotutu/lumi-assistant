# 🤝 贡献者指南

> 欢迎为 Lumi Assistant 贡献代码！

## 🎯 贡献流程

### 1. 准备工作
- 🍴 Fork 本仓库到你的GitHub账户
- 📥 克隆你的Fork到本地开发环境
- 🔧 按照项目README配置开发环境

### 2. 开发规范
- 📋 **必须遵循** [Git提交规范](../../.github/COMMIT_CONVENTION.md)
- 🌿 **必须遵循** [分支策略](../../.github/BRANCH_STRATEGY.md)
- 🏗️ **必须遵循** 项目架构规范（见 [CLAUDE.md](../../CLAUDE.md)）

### 3. 代码质量要求
- ✅ 确保代码通过 `flutter analyze`
- 🧪 添加必要的测试用例
- 📝 添加详细的代码注释
- 🎨 遵循项目代码风格

### 4. 提交流程
1. 🔄 从main分支创建功能分支
2. 💻 完成功能开发和测试
3. 📝 按规范编写提交信息
4. 🔀 创建Pull Request到main分支

## 📋 代码规范

### Git提交规范
```bash
# 正确格式
feat(ui): 新增语音按钮动画效果

# 类型说明
feat     - 新功能
fix      - Bug修复
docs     - 文档更新
style    - 代码格式
refactor - 重构
perf     - 性能优化
test     - 测试
build    - 构建
ci       - CI配置
chore    - 杂项
```

### 分支命名规范
```bash
# 功能分支
feature/voice-animation
feature/dashboard-weather

# 修复分支
fix/websocket-connection
fix/audio-playback

# 文档分支
docs/api-update
docs/setup-guide
```

### 代码风格
- 🐍 文件名使用snake_case：`voice_service.dart`
- 🐫 类名使用PascalCase：`VoiceService`  
- 🐪 变量名使用camelCase：`isConnected`
- 📝 必须添加详细注释，解释功能和逻辑
- 🧹 保持代码简洁，避免过度复杂的写法

## 🚫 禁止事项

### 代码质量
- ❌ 不允许提交未通过analyze检查的代码
- ❌ 不允许硬编码敏感信息（API密钥等）
- ❌ 不允许提交无意义的提交信息
- ❌ 不允许绕过代码审查直接推送到main分支

### 功能开发
- ❌ 不允许添加未经讨论的大型功能
- ❌ 不允许修改核心架构而不通知维护者
- ❌ 不允许删除现有功能而不提供替代方案

## ✅ 最佳实践

### 开发流程
```bash
# 1. 同步最新代码
git checkout main
git pull upstream main

# 2. 创建功能分支
git checkout -b feature/new-awesome-feature

# 3. 开发和测试
# ... 编码 ...
flutter test
flutter analyze

# 4. 按规范提交
git add .
git commit -m "feat(scope): 简短描述新功能"

# 5. 推送并创建PR
git push origin feature/new-awesome-feature
```

### Pull Request模板
```markdown
## 🎯 功能描述
简要描述这个PR实现的功能

## 🔧 技术方案
- 使用的技术和实现方案
- 关键代码逻辑说明

## 🧪 测试情况
- [ ] 通过flutter analyze检查
- [ ] 通过相关单元测试
- [ ] 在目标设备上测试通过

## 📝 相关Issue
关联的Issue链接

## 🖼️ 截图/录屏
如果涉及UI变化，提供截图或录屏
```

## 🎖️ 贡献者认可

### 贡献类型
- 💻 **代码贡献** - 功能开发、Bug修复
- 📚 **文档贡献** - 改进文档、添加示例
- 🐛 **问题报告** - 发现并报告Bug
- 💡 **功能建议** - 提出有价值的功能建议
- 🎨 **设计贡献** - UI/UX设计改进

### 认可方式
- 🏆 在Release Notes中感谢贡献者
- 📈 GitHub贡献统计记录
- 🎯 核心贡献者可获得Collaborator权限

## 📞 获取帮助

### 遇到问题？
- 💬 在Issue中讨论技术问题
- 📧 通过Discussion获取帮助
- 📖 查阅项目文档和代码注释

### 功能讨论
- 💡 通过GitHub Discussions讨论新功能
- 🎯 在Issue中提出具体的功能需求
- 🤝 与维护者沟通重大改动

---

**感谢你的贡献！让我们一起打造更好的智能助手 🚀**