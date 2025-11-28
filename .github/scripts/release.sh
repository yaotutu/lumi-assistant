#!/bin/bash
# 快速发布脚本
# 将 main 分支合并到 release 分支并触发自动发布

set -e

echo "========================================="
echo "🚀 Lumi Assistant Release 发布工具"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否有未提交的更改
if [[ -n $(git status -s) ]]; then
    echo -e "${RED}❌ 错误: 存在未提交的更改${NC}"
    echo ""
    echo "请先提交或暂存更改："
    git status -s
    exit 1
fi

echo -e "${GREEN}✅ 工作区干净${NC}"
echo ""

# 获取当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 当前分支: $CURRENT_BRANCH"
echo ""

# 更新 main 分支
echo "📥 更新 main 分支..."
git checkout main
git pull origin main
echo -e "${GREEN}✅ main 分支已更新${NC}"
echo ""

# 显示最近的提交
echo "📝 最近的提交记录:"
git log --oneline -5
echo ""

# 询问是否继续
read -p "❓ 是否继续发布到 release 分支？ (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  发布已取消${NC}"
    exit 0
fi

# 切换到 release 分支
echo ""
echo "🔄 切换到 release 分支..."
if git show-ref --verify --quiet refs/heads/release; then
    git checkout release
    git pull origin release
    echo -e "${GREEN}✅ release 分支已更新${NC}"
else
    echo -e "${YELLOW}⚠️  release 分支不存在，正在创建...${NC}"
    git checkout -b release
    echo -e "${GREEN}✅ release 分支已创建${NC}"
fi
echo ""

# 合并 main 分支
echo "🔀 合并 main 分支到 release..."
if git merge main --no-edit; then
    echo -e "${GREEN}✅ 合并成功${NC}"
else
    echo -e "${RED}❌ 合并失败，存在冲突${NC}"
    echo ""
    echo "请手动解决冲突后运行："
    echo "  git add ."
    echo "  git commit"
    echo "  git push origin release"
    exit 1
fi
echo ""

# 显示将要推送的更改
echo "📋 即将推送的更改:"
git log origin/release..HEAD --oneline 2>/dev/null || git log --oneline -3
echo ""

# 最终确认
read -p "🚀 确认推送到 release 分支并触发发布？ (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  推送已取消${NC}"
    echo ""
    echo "你可以手动推送："
    echo "  git push origin release"
    exit 0
fi

# 推送到远程
echo ""
echo "📤 推送到远程仓库..."
git push origin release
echo ""

echo "========================================="
echo -e "${GREEN}✅ 发布成功！${NC}"
echo "========================================="
echo ""
echo "🎉 GitHub Actions 正在自动构建和发布..."
echo ""
echo "📍 查看构建进度:"
echo "   https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo ""
echo "📦 查看 Release:"
echo "   https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases"
echo ""

# 切换回原分支
if [ "$CURRENT_BRANCH" != "release" ]; then
    echo "🔙 切换回 $CURRENT_BRANCH 分支..."
    git checkout "$CURRENT_BRANCH"
fi

echo ""
echo -e "${GREEN}🎊 发布流程完成！${NC}"
