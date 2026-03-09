#!/usr/bin/env bash
# trello.sh — Trello REST API 精细操控封装脚本
# 用法: trello.sh <command> [args...]
# 凭证来源: ~/Obsidian/kevinob/Openclaw/secrets.env

set -euo pipefail

# ── 加载凭证 ──────────────────────────────────────────────
SECRETS_FILE="$HOME/Obsidian/kevinob/Openclaw/secrets.env"
if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "❌ 找不到 secrets.env: $SECRETS_FILE" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$SECRETS_FILE"

KEY="${SECRET_TRELLO_API_KEY:-}"
TOKEN="${SECRET_TRELLO_TOKEN:-}"
BASE="https://api.trello.com/1"

if [[ -z "$KEY" || -z "$TOKEN" ]]; then
  echo "❌ 凭证未配置: 请确认 secrets.env 中包含 SECRET_TRELLO_API_KEY 和 SECRET_TRELLO_TOKEN" >&2
  exit 1
fi

# ── 工具函数 ──────────────────────────────────────────────
AUTH="key=$KEY&token=$TOKEN"

_get() {
  local path="$1"; shift
  local extra_params="${1:-}"
  local sep="&"
  [[ -z "$extra_params" ]] && sep=""
  curl -sf "${BASE}${path}?${AUTH}${sep}${extra_params}" | python3 -m json.tool 2>/dev/null || \
    curl -sf "${BASE}${path}?${AUTH}${sep}${extra_params}"
}

_post() {
  local path="$1"; shift
  local data="${1:-}"
  curl -sf -X POST "${BASE}${path}?${AUTH}" \
    -H "Content-Type: application/json" \
    -d "${data}" | python3 -m json.tool 2>/dev/null || \
  curl -sf -X POST "${BASE}${path}?${AUTH}" -H "Content-Type: application/json" -d "${data}"
}

_put() {
  local path="$1"; shift
  local data="${1:-}"
  curl -sf -X PUT "${BASE}${path}?${AUTH}" \
    -H "Content-Type: application/json" \
    -d "${data}" | python3 -m json.tool 2>/dev/null || \
  curl -sf -X PUT "${BASE}${path}?${AUTH}" -H "Content-Type: application/json" -d "${data}"
}

_delete() {
  local path="$1"
  curl -sf -X DELETE "${BASE}${path}?${AUTH}" | python3 -m json.tool 2>/dev/null || \
    curl -sf -X DELETE "${BASE}${path}?${AUTH}"
}

# ── 命令路由 ───────────────────────────────────────────────
CMD="${1:-help}"
shift || true

case "$CMD" in

  # ======================================================
  # 当前用户
  # ======================================================
  me)
    _get "/members/me" "fields=id,username,fullName,email"
    ;;

  my-cards)
    _get "/members/me/cards" "fields=id,name,idBoard,idList,due,url"
    ;;

  # ======================================================
  # 看板 (Board)
  # ======================================================
  boards)
    _get "/members/me/boards" "fields=id,name,shortLink,url,closed"
    ;;

  board-lists)
    BOARD_ID="${1:?'❌ 用法: trello.sh board-lists <boardId>'}"
    _get "/boards/${BOARD_ID}/lists" "fields=id,name,pos,closed"
    ;;

  board-cards)
    BOARD_ID="${1:?'❌ 用法: trello.sh board-cards <boardId>'}"
    _get "/boards/${BOARD_ID}/cards" "fields=id,name,idList,due,dueComplete,labels,url"
    ;;

  board-labels)
    BOARD_ID="${1:?'❌ 用法: trello.sh board-labels <boardId>'}"
    _get "/boards/${BOARD_ID}/labels" "fields=id,name,color"
    ;;

  board-members)
    BOARD_ID="${1:?'❌ 用法: trello.sh board-members <boardId>'}"
    _get "/boards/${BOARD_ID}/members" "fields=id,username,fullName"
    ;;

  # ======================================================
  # 列表 (List)
  # ======================================================
  list-cards)
    LIST_ID="${1:?'❌ 用法: trello.sh list-cards <listId>'}"
    _get "/lists/${LIST_ID}/cards" "fields=id,name,due,dueComplete,labels,url"
    ;;

  create-list)
    BOARD_ID="${1:?'❌ 用法: trello.sh create-list <boardId> <name>'}"
    NAME="${2:?'❌ 缺少 name 参数'}"
    _post "/lists" "{\"name\":\"${NAME}\",\"idBoard\":\"${BOARD_ID}\"}"
    ;;

  archive-list)
    LIST_ID="${1:?'❌ 用法: trello.sh archive-list <listId>'}"
    _put "/lists/${LIST_ID}" '{"closed":true}'
    ;;

  # ======================================================
  # 卡片 (Card)
  # ======================================================
  get-card)
    CARD_ID="${1:?'❌ 用法: trello.sh get-card <cardId>'}"
    _get "/cards/${CARD_ID}"
    ;;

  create-card)
    LIST_ID="${1:?'❌ 用法: trello.sh create-card <listId> <name> [desc]'}"
    NAME="${2:?'❌ 缺少 name 参数'}"
    DESC="${3:-}"
    _post "/cards" "{\"idList\":\"${LIST_ID}\",\"name\":\"${NAME}\",\"desc\":\"${DESC}\"}"
    ;;

  move-card)
    CARD_ID="${1:?'❌ 用法: trello.sh move-card <cardId> <listId>'}"
    LIST_ID="${2:?'❌ 缺少 listId 参数'}"
    _put "/cards/${CARD_ID}" "{\"idList\":\"${LIST_ID}\"}"
    ;;

  update-card-name)
    CARD_ID="${1:?'❌ 用法: trello.sh update-card-name <cardId> <name>'}"
    NAME="${2:?'❌ 缺少 name 参数'}"
    _put "/cards/${CARD_ID}" "{\"name\":\"${NAME}\"}"
    ;;

  update-card-desc)
    CARD_ID="${1:?'❌ 用法: trello.sh update-card-desc <cardId> <desc>'}"
    DESC="${2:?'❌ 缺少 desc 参数'}"
    _put "/cards/${CARD_ID}" "{\"desc\":\"${DESC}\"}"
    ;;

  set-due)
    CARD_ID="${1:?'❌ 用法: trello.sh set-due <cardId> <ISO日期>'}"
    DUE="${2:?'❌ 缺少日期参数, 格式: 2026-03-31T18:00:00.000Z'}"
    _put "/cards/${CARD_ID}" "{\"due\":\"${DUE}\"}"
    ;;

  complete-due)
    CARD_ID="${1:?'❌ 用法: trello.sh complete-due <cardId>'}"
    _put "/cards/${CARD_ID}" '{"dueComplete":true}'
    ;;

  archive-card)
    CARD_ID="${1:?'❌ 用法: trello.sh archive-card <cardId>'}"
    _put "/cards/${CARD_ID}" '{"closed":true}'
    ;;

  delete-card)
    CARD_ID="${1:?'❌ 用法: trello.sh delete-card <cardId>'}"
    echo "⚠️  即将永久删除卡片 ${CARD_ID}，此操作不可撤销！"
    _delete "/cards/${CARD_ID}"
    echo "✅ 卡片已删除"
    ;;

  # ======================================================
  # 评论 (Comment)
  # ======================================================
  add-comment)
    CARD_ID="${1:?'❌ 用法: trello.sh add-comment <cardId> <text>'}"
    TEXT="${2:?'❌ 缺少评论内容'}"
    _post "/cards/${CARD_ID}/actions/comments" "{\"text\":\"${TEXT}\"}"
    ;;

  card-comments)
    CARD_ID="${1:?'❌ 用法: trello.sh card-comments <cardId>'}"
    _get "/cards/${CARD_ID}/actions" "filter=commentCard"
    ;;

  # ======================================================
  # 标签 (Label)
  # ======================================================
  add-label)
    CARD_ID="${1:?'❌ 用法: trello.sh add-label <cardId> <labelId>'}"
    LABEL_ID="${2:?'❌ 缺少 labelId'}"
    _post "/cards/${CARD_ID}/idLabels" "{\"value\":\"${LABEL_ID}\"}"
    ;;

  remove-label)
    CARD_ID="${1:?'❌ 用法: trello.sh remove-label <cardId> <labelId>'}"
    LABEL_ID="${2:?'❌ 缺少 labelId'}"
    _delete "/cards/${CARD_ID}/idLabels/${LABEL_ID}"
    ;;

  create-label)
    BOARD_ID="${1:?'❌ 用法: trello.sh create-label <boardId> <name> <color>'}"
    NAME="${2:?'❌ 缺少标签名'}"
    COLOR="${3:-null}"
    _post "/labels" "{\"name\":\"${NAME}\",\"color\":\"${COLOR}\",\"idBoard\":\"${BOARD_ID}\"}"
    ;;

  # ======================================================
  # 成员 (Member)
  # ======================================================
  assign-member)
    CARD_ID="${1:?'❌ 用法: trello.sh assign-member <cardId> <memberId>'}"
    MEMBER_ID="${2:?'❌ 缺少 memberId'}"
    _post "/cards/${CARD_ID}/idMembers" "{\"value\":\"${MEMBER_ID}\"}"
    ;;

  remove-member)
    CARD_ID="${1:?'❌ 用法: trello.sh remove-member <cardId> <memberId>'}"
    MEMBER_ID="${2:?'❌ 缺少 memberId'}"
    _delete "/cards/${CARD_ID}/idMembers/${MEMBER_ID}"
    ;;

  # ======================================================
  # 搜索
  # ======================================================
  search)
    QUERY="${1:?'❌ 用法: trello.sh search <query>'}"
    ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${QUERY}'))")
    _get "/search" "query=${ENCODED}&modelTypes=cards,boards&cards_limit=20&boards_limit=5"
    ;;

  # ======================================================
  # 帮助
  # ======================================================
  help|--help|-h|"")
    cat << 'HELP'
🃏 Trello Skill — 精细化看板操控工具

用法: trello.sh <command> [args...]

看板:
  boards                          列出我的所有看板
  board-lists   <boardId>         列出看板的所有列表
  board-cards   <boardId>         列出看板的所有卡片
  board-labels  <boardId>         列出看板的所有标签
  board-members <boardId>         列出看板成员

列表:
  list-cards    <listId>          查看列表下的所有卡片
  create-list   <boardId> <name>  在看板中创建新列表
  archive-list  <listId>          归档列表

卡片:
  get-card      <cardId>                          查看卡片详情
  create-card   <listId> <name> [desc]            创建卡片
  move-card     <cardId> <listId>                 移动卡片到列表
  update-card-name <cardId> <name>                更新卡片标题
  update-card-desc <cardId> <desc>                更新卡片描述
  set-due       <cardId> <ISO日期>                设置截止日期
  complete-due  <cardId>                          标记截止日期完成
  archive-card  <cardId>                          归档卡片
  delete-card   <cardId>                          永久删除卡片

评论:
  add-comment   <cardId> <text>   添加评论
  card-comments <cardId>          查看评论

标签:
  board-labels  <boardId>                         列出看板标签
  add-label     <cardId> <labelId>                添加标签到卡片
  remove-label  <cardId> <labelId>                从卡片移除标签
  create-label  <boardId> <name> <color>          创建新标签

成员:
  me                              查看当前用户信息
  my-cards                        列出分配给我的所有卡片
  assign-member <cardId> <memberId>  分配成员到卡片
  remove-member <cardId> <memberId>  从卡片移除成员

搜索:
  search        <query>           全局搜索卡片/看板

可用颜色: red orange yellow green blue purple pink sky lime null
HELP
    ;;

  *)
    echo "❌ 未知命令: $CMD" >&2
    echo "运行 'trello.sh help' 查看所有可用命令" >&2
    exit 1
    ;;
esac
