#!/bin/bash

# 自动变更日志生成脚本
# 基于Git提交记录和Conventional Commits规范自动生成Release notes

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# 默认值
VERSION=${VERSION:-"0.1.0-pre"}
BUILD_NUMBER=${BUILD_NUMBER:-$(date +'%Y%m%d%H%M')}
SINCE_TAG=${SINCE_TAG:-""}

# 如果没有设置GITHUB_REPOSITORY，尝试从git remote获取
if [ -z "${GITHUB_REPOSITORY}" ]; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ "$REMOTE_URL" == *"github.com"* ]]; then
        # 从git remote URL提取仓库名，移除.git后缀
        GITHUB_REPOSITORY=$(echo "$REMOTE_URL" | sed -E 's/.*github\.com[\/:]([^\/]+\/[^\/]+)(\.git)?$/\1/' | sed 's/\.git$//')
    else
        GITHUB_REPOSITORY="your-username/your-repo"
        log_warning "无法获取GitHub仓库名，使用默认值: ${GITHUB_REPOSITORY}"
    fi
fi

# 如果没有指定起始tag，尝试找到最近的tag
if [ -z "${SINCE_TAG}" ]; then
    SINCE_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
fi

# 分类函数
categorize_commit() {
    local commit_msg="$1"
    local commit_type=$(echo "$commit_msg" | grep -o '^[a-z]*:' | sed 's/:$//' || echo "other")
    
    case "$commit_type" in
        feat|feature)
            echo "🚀 Features"
            ;;
        fix|bug|bugfix)
            echo "🐛 Bug fixes"
            ;;
        docs|doc)
            echo "📚 Documentation"
            ;;
        style|refactor)
            echo "🌟 Enhancements"
            ;;
        perf|performance)
            echo "🌟 Enhancements"
            ;;
        test|tests)
            echo "🧪 Testing"
            ;;
        build|ci|chore)
            echo "🔧 Build & CI"
            ;;
        security|sec)
            echo "🔒 Security"
            ;;
        deps|dependencies)
            echo "📦 Dependencies"
            ;;
        remove|deprecated)
            echo "🗑️ Deprecations"
            ;;
        i18n|locale|translation)
            echo "🌐 Translations"
            ;;
        *)
            echo "🔄 Other Changes"
            ;;
    esac
}

# 格式化提交信息 - 重点突出可点击的更改链接
format_commit() {
    local commit_hash="$1"
    local commit_msg="$2"
    local short_hash=$(echo "$commit_hash" | cut -c1-7)
    
    # 提取作者信息
    local author=$(git log -1 --pretty=format:'%an' "$commit_hash" 2>/dev/null || echo "Unknown")
    local author_email=$(git log -1 --pretty=format:'%ae' "$commit_hash" 2>/dev/null || echo "")
    
    # 生成GitHub用户名
    local github_user=""
    if [[ "$author_email" == *"@users.noreply.github.com" ]]; then
        github_user=$(echo "$author_email" | sed 's/@users.noreply.github.com//' | sed 's/^[0-9]*+//')
    else
        github_user=$(echo "$author" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
    fi
    
    # 移除类型前缀，保留主要信息
    local clean_msg=$(echo "$commit_msg" | sed 's/^[a-z]*: *//' | sed 's/^[a-z]*(\([^)]*\)): *//')
    
    # 检查是否有scope（括号内容）
    local scope=""
    if echo "$commit_msg" | grep -q '^[a-z]*([^)]*):'; then
        scope=$(echo "$commit_msg" | sed -n 's/^[a-z]*\(([^)]*)\):.*$/\1: /p')
    fi
    
    # 重点：每个改动都可以直接点击查看具体更改
    # 格式：description by @user → [🔍 查看代码更改 hash]
    echo "- ${scope}${clean_msg} by [@${github_user}](https://github.com/${github_user}) → [🔍 **查看代码更改** \`${short_hash}\`](https://github.com/${GITHUB_REPOSITORY}/commit/${commit_hash})"
}

# 生成变更日志
generate_changelog() {
    local output_file="${REPO_ROOT}/release_notes.md"
    local temp_file=$(mktemp)
    
    log_info "生成自动化变更日志..."
    
    # 获取提交范围
    local commit_range=""
    if [ -n "${SINCE_TAG}" ]; then
        commit_range="${SINCE_TAG}..HEAD"
        log_info "获取从 ${SINCE_TAG} 到 HEAD 的提交"
    else
        # 如果没有之前的tag，获取最近10个提交
        commit_range="HEAD~10..HEAD"
        log_warning "未找到之前的tag，获取最近10个提交"
    fi
    
    # 获取提交列表
    local commits=$(git log --pretty=format:"%H|%s" "$commit_range" --reverse)
    
    if [ -z "$commits" ]; then
        log_warning "未找到新的提交"
        commits=$(git log --pretty=format:"%H|%s" -1)
    fi
    
    # 创建临时文件存储分类信息
    local temp_dir=$(mktemp -d)
    
    # 处理每个提交
    while IFS='|' read -r commit_hash commit_msg; do
        if [ -n "$commit_hash" ] && [ -n "$commit_msg" ]; then
            local category=$(categorize_commit "$commit_msg")
            local formatted_commit=$(format_commit "$commit_hash" "$commit_msg")
            
            # 将提交信息追加到对应分类文件
            local category_file="${temp_dir}/$(echo "$category" | tr ' ' '_')"
            echo "$formatted_commit" >> "$category_file"
        fi
    done <<< "$commits"
    
    # 确定当前分支和版本类型
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    
    if [ "${CURRENT_BRANCH}" = "main" ]; then
        VERSION_TYPE="🚀 Release"
        VERSION_DESC="正式版本"
    elif [ "${CURRENT_BRANCH}" = "dev" ]; then
        VERSION_TYPE="🧪 Development"
        VERSION_DESC="内测版本"
    else
        VERSION_TYPE="🔧 Branch Build"
        VERSION_DESC="分支构建版本"
    fi
    
    # 生成Release notes - 完全基于Git提交记录
    cat > "$output_file" << EOF
# ${VERSION_TYPE} ${VERSION}

**${VERSION_DESC} - 包含 $(echo "$commits" | wc -l | tr -d ' ') 个更改**

> 💡 **点击 "查看更改" 链接可以查看每个功能的具体代码更改**

## What's Changed

EOF
    
    # 按Immich风格的优先级输出分类
    local ordered_categories=(
        "🚀_Features"
        "🌟_Enhancements"
        "🐛_Bug_fixes"
        "📚_Documentation"
        "🌐_Translations"
        "🔒_Security"
        "🧪_Testing"
        "🔧_Build_&_CI"
        "📦_Dependencies"
        "🗑️_Deprecations"
        "🔄_Other_Changes"
    )
    
    local has_changes=false
    for category_file in "${ordered_categories[@]}"; do
        local category_path="${temp_dir}/${category_file}"
        if [ -f "$category_path" ]; then
            local category_name=$(echo "$category_file" | tr '_' ' ')
            echo "### $category_name" >> "$output_file"
            echo "" >> "$output_file"
            cat "$category_path" >> "$output_file"
            echo "" >> "$output_file"
            has_changes=true
        fi
    done
    
    # 收集贡献者信息（参考Immich风格）
    local contributors_file="${temp_dir}/contributors"
    while IFS='|' read -r commit_hash commit_msg; do
        if [ -n "$commit_hash" ] && [ -n "$commit_msg" ]; then
            local author=$(git log -1 --pretty=format:'%an' "$commit_hash" 2>/dev/null || echo "Unknown")
            local author_email=$(git log -1 --pretty=format:'%ae' "$commit_hash" 2>/dev/null || echo "")
            
            # 生成GitHub用户名
            local github_user=""
            if [[ "$author_email" == *"@users.noreply.github.com" ]]; then
                github_user=$(echo "$author_email" | sed 's/@users.noreply.github.com//' | sed 's/^[0-9]*+//')
            else
                github_user=$(echo "$author" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
            fi
            
            # 记录唯一贡献者
            echo "$github_user|$author" >> "$contributors_file"
        fi
    done <<< "$commits"
    
    # 添加贡献者列表（如果有多个贡献者）
    if [ -f "$contributors_file" ] && [ -s "$contributors_file" ]; then
        local unique_contributors=$(sort "$contributors_file" | uniq | wc -l | tr -d ' ')
        if [ "$unique_contributors" -gt 1 ]; then
            echo "" >> "$output_file"
            echo "## Contributors" >> "$output_file"
            echo "" >> "$output_file"
            
            # 去重并排序贡献者
            sort "$contributors_file" | uniq | while IFS='|' read -r github_user author_name; do
                echo "- [@${github_user}](https://github.com/${github_user})" >> "$output_file"
            done
            echo "" >> "$output_file"
        fi
    fi
    
    # 清理临时目录
    rm -rf "$temp_dir"
    
    if [ "$has_changes" = false ]; then
        echo "### 🔄 Other Changes" >> "$output_file"
        echo "" >> "$output_file"
        echo "- 常规更新和维护" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # 添加下载和安装信息
    cat >> "$output_file" << EOF
## 📱 下载说明

本版本提供4种不同架构的APK供下载：

### 🎯 特定架构版本（推荐，体积更小）
- **ARM32 (armeabi-v7a)**: 适用于32位ARM设备
- **ARM64 (arm64-v8a)**: 适用于64位ARM设备（大多数现代Android设备）
- **x64 (x86_64)**: 适用于x86_64架构设备（模拟器等）

### 📦 通用版本
- **Universal**: 包含所有架构，兼容性最好但体积最大

### 🤔 如何选择？
1. **推荐**: 下载ARM64版本（适用于大多数现代Android设备）
2. **不确定**: 下载Universal版本（确保兼容但体积较大）
3. **老设备**: 如果ARM64版本无法安装，尝试ARM32版本

EOF

    # 根据分支添加不同的版本说明
    if [ "${CURRENT_BRANCH}" = "main" ]; then
        cat >> "$output_file" << EOF
## ✅ 正式版本

此为正式发布版本，经过完整测试和验证。

EOF
    elif [ "${CURRENT_BRANCH}" = "dev" ]; then
        cat >> "$output_file" << EOF
## ⚠️ 内测版本

此为内测版本，使用正式构建但包含最新功能，供内测用户体验和反馈。

EOF
    else
        cat >> "$output_file" << EOF
## 🔧 分支构建版本

此为特定分支的构建版本，仅用于功能测试和验证。

EOF
    fi
    
    # 添加Full Changelog链接（参考Immich风格）
    local previous_tag=$(git describe --tags --abbrev=0 HEAD~1 2>/dev/null || echo "")
    local current_tag="v${VERSION}"
    
    cat >> "$output_file" << EOF
## 🐛 问题反馈

遇到问题请在 [Issues](https://github.com/${GITHUB_REPOSITORY}/issues) 反馈。

EOF

    # 如果有之前的tag，添加Full Changelog链接
    if [ -n "$previous_tag" ] && [ "$previous_tag" != "$current_tag" ]; then
        cat >> "$output_file" << EOF
**Full Changelog**: [${previous_tag}...${current_tag}](https://github.com/${GITHUB_REPOSITORY}/compare/${previous_tag}...${current_tag})

EOF
    fi
    
    cat >> "$output_file" << EOF
---
*🤖 自动生成于 $(date -u +'%Y-%m-%d %H:%M:%S UTC')*
EOF
    
    log_success "变更日志已生成: $output_file"
    
    # 显示预览
    echo ""
    echo "========== Release Notes 预览 =========="
    head -20 "$output_file"
    echo "..."
    echo "========================================"
}

# 输出到GitHub Actions环境
output_to_github() {
    if [ -n "${GITHUB_OUTPUT}" ]; then
        echo "changelog-path=${REPO_ROOT}/release_notes.md" >> ${GITHUB_OUTPUT}
        log_success "变更日志路径已输出到GitHub Actions环境"
    fi
}

# 主函数
main() {
    log_info "开始生成自动化变更日志..."
    
    generate_changelog
    output_to_github
    
    log_success "自动化变更日志生成完成！"
}

# 处理命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --since-tag)
            SINCE_TAG="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --build-number)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --since-tag TAG      从指定tag开始生成变更日志"
            echo "  --version VERSION    版本号"
            echo "  --build-number NUM   构建号"
            echo "  --help, -h           显示帮助信息"
            echo ""
            echo "Environment Variables:"
            echo "  VERSION              版本号 (默认: 0.1.0-pre)"
            echo "  BUILD_NUMBER         构建号 (默认: 当前时间戳)"
            echo "  SINCE_TAG            起始tag"
            echo "  GITHUB_REPOSITORY    GitHub仓库名"
            echo "  GITHUB_OUTPUT        GitHub Actions输出文件"
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            exit 1
            ;;
    esac
done

# 如果没有特殊参数，执行主函数
if [ $# -eq 0 ]; then
    main "$@"
fi