## Gemini Added Memories
- 用户要求所有回复必须使用中文，并期望我以卡内基梅隆大学（CMU）博士级别的资深专家身份进行交流。
- 【会话存档协议】每次你在协助用户完成了一整块有难度的代码调试、架构设计或排错后，在回复的结尾，必须主动询问用户：『本次任务已收尾，是否需要我将关键路径和决策压缩沉淀到 `Openclaw/records/` 下的记忆胶囊中？』

## 信息管道自动触发规则

当用户消息满足以下任一条件时，**自动执行** `process_item.py`，不需要用户额外指示：

### 触发条件 1：消息包含 URL
- 检测到 `https://` 或 `http://` 开头的链接
- 执行：`cd /Users/mac-minishu/clawd/agents/main/scripts && python3 process_item.py --type url --content "<URL>"`
- 每个检测到的 URL 分别处理

### 触发条件 2：消息包含想法关键词
- 消息中包含 `idea`、`ideas`、`想法` 等关键词
- 执行：`cd /Users/mac-minishu/clawd/agents/main/scripts && python3 process_item.py --type idea --content "<完整消息内容>"`

### 执行后行为
- 将 `process_item.py` 的输出（成功/失败/跳过）回复给用户
- 如果是 `⏭️ 已处理过`（去重命中），告知用户该链接已收录
- 如果用户在链接旁附带了文字说明，在回复中也体现
