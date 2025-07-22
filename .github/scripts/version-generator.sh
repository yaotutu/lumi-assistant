#!/bin/bash

# 版本号生成脚本
# 用于GitHub Actions自动生成带pre前缀的版本号

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否在Git仓库中
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "当前目录不是Git仓库"
        exit 1
    fi
}

# 获取Git信息
get_git_info() {
    # 获取提交计数（用作版本递增）
    COMMIT_COUNT=$(git rev-list --count HEAD)
    
    # 获取当前分支
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    # 获取最新提交的短哈希
    COMMIT_SHA=$(git rev-parse --short HEAD)
    
    # 获取最新提交信息
    COMMIT_MSG=$(git log -1 --pretty=format:'%s')
    
    log_info "Git信息："
    log_info "  分支: ${CURRENT_BRANCH}"
    log_info "  提交数: ${COMMIT_COUNT}"
    log_info "  提交哈希: ${COMMIT_SHA}"
    log_info "  提交信息: ${COMMIT_MSG}"
}

# 生成版本号
generate_version() {
    # 基础版本（主要版本.次要版本）
    local BASE_VERSION="0.1"
    
    # 补丁版本号使用提交计数
    local PATCH_VERSION=${COMMIT_COUNT}
    
    # 生成完整版本号
    if [ "${CURRENT_BRANCH}" = "main" ]; then
        # main分支：使用pre前缀表示开发版本
        VERSION="${BASE_VERSION}.${PATCH_VERSION}-pre"
        PRERELEASE=true
    else
        # 其他分支：使用分支名和提交哈希
        BRANCH_NAME=$(echo ${CURRENT_BRANCH} | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
        VERSION="${BASE_VERSION}.${PATCH_VERSION}-${BRANCH_NAME}.${COMMIT_SHA}"
        PRERELEASE=true
    fi
    
    log_success "生成版本号: ${VERSION}"
}

# 生成构建号
generate_build_number() {
    # 使用更短的构建号格式，避免超过Android限制（2100000000）
    # 格式：提交计数 * 1000 + 小时分钟（4位数字）
    local HOUR_MIN=$(date +'%H%M')
    BUILD_NUMBER=$((COMMIT_COUNT * 1000 + HOUR_MIN))
    
    # 确保不超过Android最大值
    if [ ${BUILD_NUMBER} -gt 2100000000 ]; then
        # 如果超过限制，使用更简单的格式：提交计数 + 日期后2位
        local DAY_HOUR=$(date +'%d%H')
        BUILD_NUMBER=$((COMMIT_COUNT * 100 + DAY_HOUR % 100))
    fi
    
    # 最终安全检查，确保不超过Android限制
    if [ ${BUILD_NUMBER} -gt 2100000000 ]; then
        BUILD_NUMBER=${COMMIT_COUNT}
    fi
    
    log_success "生成构建号: ${BUILD_NUMBER}"
}

# 生成完整的版本字符串（用于pubspec.yaml）
generate_full_version() {
    FULL_VERSION="${VERSION}+${BUILD_NUMBER}"
    log_success "完整版本字符串: ${FULL_VERSION}"
}

# 输出到GitHub Actions环境
output_to_github() {
    if [ -n "${GITHUB_OUTPUT}" ]; then
        echo "version=${VERSION}" >> ${GITHUB_OUTPUT}
        echo "build-number=${BUILD_NUMBER}" >> ${GITHUB_OUTPUT}
        echo "full-version=${FULL_VERSION}" >> ${GITHUB_OUTPUT}
        echo "prerelease=${PRERELEASE}" >> ${GITHUB_OUTPUT}
        echo "commit-sha=${COMMIT_SHA}" >> ${GITHUB_OUTPUT}
        echo "commit-count=${COMMIT_COUNT}" >> ${GITHUB_OUTPUT}
        echo "branch=${CURRENT_BRANCH}" >> ${GITHUB_OUTPUT}
        
        log_success "版本信息已输出到GitHub Actions环境"
    fi
}

# 显示版本摘要
show_summary() {
    echo ""
    echo "================================================"
    echo "              版本信息摘要"
    echo "================================================"
    echo "版本号:           ${VERSION}"
    echo "构建号:           ${BUILD_NUMBER}"
    echo "完整版本:         ${FULL_VERSION}"
    echo "预发布版本:       ${PRERELEASE}"
    echo "当前分支:         ${CURRENT_BRANCH}"
    echo "提交计数:         ${COMMIT_COUNT}"
    echo "提交哈希:         ${COMMIT_SHA}"
    echo "================================================"
}

# 主函数
main() {
    log_info "开始生成版本信息..."
    
    check_git_repo
    get_git_info
    generate_version
    generate_build_number
    generate_full_version
    output_to_github
    show_summary
    
    log_success "版本信息生成完成！"
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi