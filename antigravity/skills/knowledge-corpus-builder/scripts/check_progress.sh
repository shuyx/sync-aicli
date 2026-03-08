#!/bin/bash
# check_progress.sh — 检查知识库构建进度
# 用法: bash check_progress.sh <topic>
# 示例: bash check_progress.sh 智能制造

TOPIC="${1:?用法: check_progress.sh <topic>}"
STATE_FILE="/tmp/kcb-state-${TOPIC}.json"

if [ ! -f "$STATE_FILE" ]; then
  echo "❌ 未找到状态文件: $STATE_FILE"
  echo "   该 topic 可能尚未开始处理，或状态文件已被清理。"
  exit 1
fi

echo "📊 Knowledge Corpus Builder 进度报告"
echo "---"
echo "🏷️  Topic: $TOPIC"
echo "📄 状态文件: $STATE_FILE"
echo ""

# 用 python3 解析 JSON（macOS 自带）
python3 -c "
import json, sys
with open('$STATE_FILE') as f:
    state = json.load(f)

print(f\"📋 模式: {state.get('mode', 'unknown')}\")
print(f\"📂 源目录: {state.get('source_dir', 'unknown')}\")
print(f\"📁 输出目录: {state.get('output_dir', 'unknown')}\")
if state.get('project_path'):
    print(f\"🔗 锚定项目: {state.get('project_path')}\")
print(f\"⏱️  阶段: {state.get('phase', 'unknown')}\")
print()

total = state.get('total_docs', 0)
scanned = state.get('scanned_docs', 0)
classified = state.get('classified_docs', 0)
read = state.get('read_docs', 0)

print(f\"📊 进度:\")
print(f\"  扫描: {scanned}/{total} ({scanned*100//total if total else 0}%)\")
print(f\"  分类: {classified}/{total} ({classified*100//total if total else 0}%)\")
print(f\"  深读: {read}/{total} ({read*100//total if total else 0}%)\")
print()

taxonomy = state.get('taxonomy', {})
generated = state.get('generated_files', [])
print(f\"📂 技术方向: {len(taxonomy)} 个\")
for name, info in taxonomy.items():
    docs = info.get('docs', [])
    read_docs = info.get('read', [])
    status = info.get('status', 'pending')
    icon = '✅' if status == 'done' else '🔄' if status == 'in_progress' else '⏳'
    print(f\"  {icon} {name}: {len(read_docs)}/{len(docs)} 篇已读\")

print()
print(f\"📝 已生成文档: {len(generated)} 篇\")
for f in generated:
    print(f\"  - {f}\")

print()
print(f\"🕐 最后更新: {state.get('last_updated', 'unknown')}\")
" 2>/dev/null

if [ $? -ne 0 ]; then
  echo "⚠️ 状态文件解析失败，可能格式损坏。"
  echo "   原始内容:"
  cat "$STATE_FILE"
fi
