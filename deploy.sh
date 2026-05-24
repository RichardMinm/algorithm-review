#!/usr/bin/env bash
# 用法：
#   export GITEE_USER=你的用户名
#   export GITEE_TOKEN=你的私人令牌   # 在 Gitee → 设置 → 私人令牌 创建
#   ./deploy.sh
set -euo pipefail
REPO="${GITEE_REPO:-algorithm-review}"
USER="${GITEE_USER:?请设置 GITEE_USER}"
TOKEN="${GITEE_TOKEN:?请设置 GITEE_TOKEN（需 repo 权限）}"

cd "$(dirname "$0")"
git init -b master 2>/dev/null || git checkout -B master
git add index.html assets/ README.md .gitignore
git commit -m "Deploy algorithm review site" || true

REMOTE="https://${USER}:${TOKEN}@gitee.com/${USER}/${REPO}.git"
if git remote get-url origin &>/dev/null; then
  git remote set-url origin "$REMOTE"
else
  git remote add origin "$REMOTE"
fi

# 若远程仓库不存在，尝试创建
curl -sf -X POST "https://gitee.com/api/v5/user/repos" \
  -H "Content-Type: application/json" \
  -d "{\"access_token\":\"${TOKEN}\",\"name\":\"${REPO}\",\"public\":true,\"has_issues\":false,\"has_wiki\":false}" \
  || true

git push -u origin master --force
echo ""
echo "代码已推送。请到 https://gitee.com/${USER}/${REPO}/pages 启动 Gitee Pages。"
