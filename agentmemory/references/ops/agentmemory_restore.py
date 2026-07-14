"""
agentmemory 自动恢复脚本 - 从 standalone.json 恢复数据到 REST/MCP
被 agentmemory-startup.ps1 调用
"""
import json, os, subprocess, time, sys

home = os.path.expanduser("~")
standalone_path = os.path.join(home, ".agentmemory", "standalone.json")

if not os.path.exists(standalone_path):
    print("standalone.json not found, nothing to restore")
    sys.exit(0)

with open(standalone_path, 'r') as f:
    d = json.load(f)
memories = d.get("mem:memories", {})
if not memories:
    print("No memories to restore")
    sys.exit(0)

# Check if REST is up
import urllib.request
try:
    req = urllib.request.Request("http://localhost:3111/agentmemory/health", method="GET")
    urllib.request.urlopen(req, timeout=3)
except:
    print("REST server not ready, skipping restore")
    sys.exit(1)

# Use @agentmemory/mcp proxy to restore
env = os.environ.copy()
env["AGENTMEMORY_URL"] = "http://localhost:3111"
env["AGENTMEMORY_TOOLS"] = "all"

# First check if data already exists (skip if already restored)
proc = subprocess.Popen(
    ["npx.cmd", "-y", "@agentmemory/mcp"],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    env=env, cwd=home
)
time.sleep(3)

check_msg = json.dumps({
    "jsonrpc": "2.0", "id": 1, "method": "initialize",
    "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "restore", "version": "1.0"}}
}).encode() + b"\n"

search_msg = json.dumps({
    "jsonrpc": "2.0", "id": 2, "method": "tools/call",
    "params": {
        "name": "memory_smart_search",
        "arguments": {"query": "老板 规则 行为 认知 输出", "limit": 5}
    }
}).encode() + b"\n"

(out, err) = proc.communicate(input=check_msg + search_msg, timeout=15)
out_text = out.decode("utf-8", errors="replace")

if '"title":' in out_text and ('老板-称呼' in out_text or '老板-认知' in out_text):
    print(f"Data already exists in MCP, skipping restore")
    sys.exit(0)

# Restore memories
proc2 = subprocess.Popen(
    ["npx.cmd", "-y", "@agentmemory/mcp"],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    env=env, cwd=home
)
time.sleep(3)

messages = []
msg_id = 1
messages.append(json.dumps({
    "jsonrpc": "2.0", "id": msg_id, "method": "initialize",
    "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "restore", "version": "1.0"}}
}).encode() + b"\n")
msg_id += 1

restored = 0
for mid, mem in memories.items():
    content = mem.get("content", "")
    if not content or len(content) < 10:
        continue
    mtype = mem.get("type", "fact")
    concepts = mem.get("concepts", [])
    if isinstance(concepts, list):
        concepts_str = ",".join(concepts)
    else:
        concepts_str = str(concepts)
    
    messages.append(json.dumps({
        "jsonrpc": "2.0", "id": msg_id, "method": "tools/call",
        "params": {
            "name": "memory_save",
            "arguments": {"content": content, "type": mtype, "concepts": concepts_str}
        }
    }).encode() + b"\n")
    msg_id += 1
    restored += 1

(stdout, stderr) = proc2.communicate(input=b"".join(messages), timeout=30)
success = stdout.decode("utf-8", errors="replace").count('"id":')

print(f"Restored {restored} memories ({success} MCP responses)")
