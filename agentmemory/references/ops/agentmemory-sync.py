"""
同步 MCP 数据到 standalone.json（由 backup-agent 每 10 分钟调用）
先通过 MCP proxy 查询现有数据，再写入 standalone.json
"""
import json, os, subprocess, time, sys

home = os.path.expanduser("~")
standalone_path = os.path.join(home, ".agentmemory", "standalone.json")

env = os.environ.copy()
env["AGENTMEMORY_URL"] = "http://localhost:3111"
env["AGENTMEMORY_TOOLS"] = "all"

# 查询全部数据（使用完整短语，不拆词）
queries = [
    "老板规则 行为准则 认知闭环 输出格式 双轨输出 进度展示 错误修复 错误处理 测试验证 称呼规范",
    "经验 教训 踩坑 规则注入 内存型存储风险 写入验证",
    "事实 端口 viewer MCP 3113 3111 写入验证",
    "协议 记忆索引 存入规范 查询规范 保存触发 置信度 3次确认 安全边界 不从沉默推断 自我反思 引用溯源 衰减感知",
    "项目 名词 术语 解释 含义 缩写"
]

all_data = {}
seen_ids = set()

for q in queries:
    try:
        proc = subprocess.Popen(
            ["npx.cmd", "-y", "@agentmemory/mcp"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            env=env, cwd=home
        )
        time.sleep(2)
        msg1 = json.dumps({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "sync", "version": "1.0"}}
        }).encode() + b"\n"
        msg2 = json.dumps({
            "jsonrpc": "2.0", "id": 2, "method": "tools/call",
            "params": {"name": "memory_smart_search", "arguments": {"query": q, "limit": 20}}
        }).encode() + b"\n"
        (out, err) = proc.communicate(input=msg1 + msg2, timeout=15)
        out_text = out.decode("utf-8", errors="replace")
        
        # Extract results from JSON-RPC response
        lines = out_text.strip().split('\n')
        for line in lines:
            if not line.strip():
                continue
            try:
                rpc = json.loads(line)
                content = rpc.get("result", {}).get("content", [])
                for c in content:
                    if c.get("type") == "text":
                        data = json.loads(c["text"])
                        results = data.get("results", [])
                        for m in results:
                            oid = m.get("obsId", m.get("id", ""))
                            if oid and oid not in seen_ids:
                                seen_ids.add(oid)
                                all_data[oid] = m
            except json.JSONDecodeError:
                continue
    except Exception as e:
        sys.stderr.write(f"Query '{q}' failed: {e}\n")

if not all_data:
    print("NO_DATA")
    sys.exit(0)

# 读取现有 standalone.json
if os.path.exists(standalone_path):
    with open(standalone_path, 'r', encoding='utf-8') as f:
        existing = json.load(f)
else:
    existing = {}

memories = existing.get("mem:memories", {})
new_count = 0

for oid, m in all_data.items():
    if oid not in memories:
        title = m.get("title", m.get("content", ""))[:80]
        content = m.get("content", m.get("title", ""))
        if not content:
            continue
        memories[oid] = {
            "id": oid,
            "type": m.get("type", "fact"),
            "title": title,
            "content": content,
            "concepts": m.get("concepts", []),
            "files": [],
            "strength": 7, "version": 1, "isLatest": True,
            "createdAt": m.get("timestamp", ""),
            "updatedAt": m.get("timestamp", ""),
            "sessionIds": []
        }
        new_count += 1

existing["mem:memories"] = memories

# 原子写入：先写 .tmp 再 rename（类似 evolution-engine 的 persistence 策略）
tmp_path = standalone_path + ".tmp"
with open(tmp_path, 'w', encoding='utf-8') as f:
    json.dump(existing, f, ensure_ascii=False, indent=2)
# 原子替换
import shutil
shutil.move(tmp_path, standalone_path)

print(f"SYNC_OK:{new_count}")
