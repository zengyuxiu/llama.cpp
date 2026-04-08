#!/bin/bash

# 开启严格模式：任何命令执行失败(非0退出码)都会立即中断脚本
set -e

# 参数化处理，允许外部传入文件名和 commit message，默认值为 testrepo
FILE_NAME=${1:-"testrepo"}
COMMIT_MSG=${2:-"$FILE_NAME"}

# ---------------------------------------------------------
# 1. 构造 Diff 变更
# ---------------------------------------------------------
if [ ! -f "$FILE_NAME" ]; then
    # 场景 A: 文件不存在，创建一个空文件
    # 这将完美复现你示例中的 "0 insertions(+), 0 deletions(-), create mode 100644"
    touch "$FILE_NAME"
else
    # 场景 B: 文件已存在
    # 追加当前时间戳，强制产生文件变更 (Diff)，防止 Git 提示 "nothing to commit"
    echo "Updated at $(date '+%Y-%m-%d %H:%M:%S')" >> "$FILE_NAME"
fi

# ---------------------------------------------------------
# 2. 自动化 Git 流程
# ---------------------------------------------------------
echo "❯ git add $FILE_NAME"
git add "$FILE_NAME"

echo "❯ git commit -m \"$COMMIT_MSG\""
# 使用 || true 是为了防止在极极端情况下（如文件被 gitignore 忽略）导致脚本异常奔溃
git commit -m "$COMMIT_MSG" || {
    echo "⚠️ 暂存区没有可提交的变更 (可能文件被 .gitignore 忽略了)"
    exit 0
}

echo "❯ git push"
git push

echo "✅ 自动化构建 Diff 并 Push 完成！"
