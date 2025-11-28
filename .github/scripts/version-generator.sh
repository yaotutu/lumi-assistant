#!/bin/bash
# 版本号自动生成脚本
# 用于 GitHub Actions 自动生成语义化版本号

set -e

# 获取构建号（GitHub Actions run number）
BUILD_NUMBER=${GITHUB_RUN_NUMBER:-1}

# 获取当前日期
BUILD_DATE=$(date +"%Y%m%d")

# 获取 Git 提交信息
COMMIT_SHA=${GITHUB_SHA:-$(git rev-parse --short HEAD)}
COMMIT_SHORT_SHA=$(echo "$COMMIT_SHA" | cut -c1-7)

# 获取当前分支
CURRENT_BRANCH="${GITHUB_REF#refs/heads/}"

# 基础版本号（可以从 build.gradle 读取，或使用默认值）
BASE_VERSION="0.1.0"

# 版本号生成规则
if [[ "$GITHUB_REF" == refs/tags/* ]]; then
    # Tag 触发：使用 Tag 作为版本号
    VERSION_NAME="${GITHUB_REF#refs/tags/}"
    VERSION_NAME="${VERSION_NAME#v}"  # 移除 'v' 前缀
    VERSION_NAME="${VERSION_NAME#beta-}"  # 移除 'beta-' 前缀

elif [[ "$CURRENT_BRANCH" == "release" ]]; then
    # release 分支：生成正式版本号
    VERSION_NAME="${BASE_VERSION}"
    echo "🎯 正式版本"

elif [[ "$CURRENT_BRANCH" == "dev" ]]; then
    # dev 分支：生成测试版本号
    VERSION_NAME="${BASE_VERSION}-beta.${BUILD_NUMBER}"
    echo "🧪 测试版本"

elif [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    # main 分支：生成开发版本号
    VERSION_NAME="${BASE_VERSION}-dev.${BUILD_NUMBER}"
    echo "🔧 开发版本"

else
    # 其他分支：生成预发布版本号（带分支名）
    # 清理分支名（移除特殊字符，替换 / 为 -）
    CLEAN_BRANCH=$(echo "$CURRENT_BRANCH" | sed 's/[^a-zA-Z0-9\-]/-/g')
    VERSION_NAME="${BASE_VERSION}-${CLEAN_BRANCH}.${BUILD_NUMBER}"
    echo "📦 特性分支版本"
fi

# Version Code = 日期(8位) + 构建号后3位
# 例如: 20250125001 (2025年1月25日的第1次构建)
VERSION_CODE="${BUILD_DATE}$(printf "%03d" $((BUILD_NUMBER % 1000)))"

# 输出到 GitHub Actions 环境变量
echo "VERSION_NAME=$VERSION_NAME" >> $GITHUB_ENV
echo "VERSION_CODE=$VERSION_CODE" >> $GITHUB_ENV
echo "COMMIT_SHORT_SHA=$COMMIT_SHORT_SHA" >> $GITHUB_ENV

# 输出日志
echo "========================================"
echo "版本信息生成完成:"
echo "  BRANCH: $CURRENT_BRANCH"
echo "  VERSION_NAME: $VERSION_NAME"
echo "  VERSION_CODE: $VERSION_CODE"
echo "  COMMIT_SHA: $COMMIT_SHORT_SHA"
echo "  BUILD_NUMBER: $BUILD_NUMBER"
echo "========================================"
