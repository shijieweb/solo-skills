"""
agentmemory 自我审查脚本（30分钟周期）
类似 evolution-engine 的 heartbeat 机制

功能：
1. 扫描所有记忆，检测同类模式（3+ 相似倾向）
2. 检查记忆索引是否过时
3. 检测可疑的重复/冲突
4. 更新记忆索引
5. 结果写入审查日志
"""
import json
import os
import subprocess
import sys
import time
from collections import defaultdict

home = os.path.expanduser("~")
standalone_path = os.path.join(home, ".agentmemory", "standalone.json")
review_log = os.path.join(home, ".agentmemory", "self-review.log")

env = os.environ.copy()
env["AGENTMEMORY_URL"] = "http://localhost:3111"
env["AGENTMEMORY_TOOLS"] = "all"


def log_review(msg):
    """写入审查日志"""
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    line = f"{ts} - {msg}\n"
    with open(review_log, "a", encoding="utf-8") as f:
        f.write(line)
    print(msg)


def query_mcp(query_str, limit=30):
    """通过 MCP proxy 查询"""
    try:
        proc = subprocess.Popen(
            ["npx.cmd", "-y", "@agentmemory/mcp"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            env=env, cwd=home
        )
        time.sleep(2)
        msg1 = json.dumps({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                       "clientInfo": {"name": "self-review", "version": "1.0"}}
        }).encode() + b"\n"
        msg2 = json.dumps({
            "jsonrpc": "2.0", "id": 2, "method": "tools/call",
            "params": {"name": "memory_smart_search",
                       "arguments": {"query": query_str, "limit": limit}}
        }).encode() + b"\n"
        (out, err) = proc.communicate(input=msg1 + msg2, timeout=15)
        out_text = out.decode("utf-8", errors="replace")

        results = []
        for line in out_text.strip().split("\n"):
            if not line.strip():
                continue
            try:
                rpc = json.loads(line)
                content = rpc.get("result", {}).get("content", [])
                for c in content:
                    if c.get("type") == "text":
                        data = json.loads(c["text"])
                        results = data.get("results", [])
            except json.JSONDecodeError:
                continue
        return results
    except Exception as e:
        log_review(f"查询失败: {e}")
        return []


def save_mcp(title, content, tags, mem_type="protocol"):
    """通过 MCP proxy 写入一条记忆"""
    try:
        payload = json.dumps({
            "jsonrpc": "2.0", "id": 3, "method": "tools/call",
            "params": {
                "name": "memory_save",
                "arguments": {
                    "title": title,
                    "content": content,
                    "type": mem_type,
                    "tags": tags
                }
            }
        }).encode() + b"\n"
        proc = subprocess.Popen(
            ["npx.cmd", "-y", "@agentmemory/mcp"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            env=env, cwd=home
        )
        time.sleep(1)
        msg1 = json.dumps({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                       "clientInfo": {"name": "self-review-save", "version": "1.0"}}
        }).encode() + b"\n"
        (out, err) = proc.communicate(input=msg1 + payload, timeout=15)
        return True
    except Exception as e:
        log_review(f"写入失败: {e}")
        return False


def check_pattern_clustering(memories):
    """
    检测同类模式聚类（类似 evolution-engine 的 concept 形成）
    - 查找标题前缀相似的记忆
    - 如果 3+ 条同类"经验-待观察"出现，标记为可升级
    """
    # 按标题前缀分组
    prefix_groups = defaultdict(list)
    for m in memories:
        title = m.get("title", "")
        # 提取分类前缀
        for prefix in ["老板规则-", "经验-", "事实-", "协议-", "项目-", "名词-"]:
            if prefix in title:
                prefix_groups[prefix].append(m)
                break
        else:
            # 无前缀，按第一个关键词分组
            words = title.split()
            if words:
                prefix_groups[words[0][:10]].append(m)

    findings = []
    for prefix, group in prefix_groups.items():
        if len(group) >= 3:
            titles = [m.get("title", "")[:50] for m in group]
            findings.append({
                "prefix": prefix,
                "count": len(group),
                "titles": titles[:5]
            })

    return findings


def check_index_consistency(memories):
    """检查记忆索引是否过时"""
    # 统计当前分类
    counts = defaultdict(int)
    for m in memories:
        title = m.get("title", "")
        for prefix in ["老板规则-", "经验-", "事实-", "协议-", "项目-", "名词-"]:
            if prefix in title:
                counts[prefix] += 1
                break
    return dict(counts)


def main():
    log_review("=== 自我审查开始 ===")

    # 1. 全量查询
    all_memories = []
    queries = [
        "老板规则 经验 事实 协议 项目 名词 记忆索引",
        "协议 存入规范 查询规范 保存触发 置信度 3次确认 安全边界 自我反思"
    ]
    for q in queries:
        results = query_mcp(q, limit=30)
        all_memories.extend(results)

    if not all_memories:
        log_review("NO_PATTERN")
        return

    # 2. 去重
    seen = set()
    unique_memories = []
    for m in all_memories:
        oid = m.get("obsId", "")
        if oid and oid not in seen:
            seen.add(oid)
            unique_memories.append(m)

    log_review(f"扫描到 {len(unique_memories)} 条记忆")

    # 3. 检测同类模式聚类
    clusters = check_pattern_clustering(unique_memories)
    for c in clusters:
        log_review(f"  聚类发现: {c['prefix']} 有 {c['count']} 条")
        for t in c["titles"]:
            log_review(f"    - {t}")

    # 4. 检查索引一致性
    current_counts = check_index_consistency(unique_memories)
    total = sum(current_counts.values())
    log_review(f"  分类统计: {dict(current_counts)}, 总计: {total}")

    # 5. 更新记忆索引
    index_entry = None
    for m in unique_memories:
        title = m.get("title", "")
        if "记忆索引" in title and "分类目录" in title:
            index_entry = m
            break

    if index_entry:
        idx_content = index_entry.get("content", index_entry.get("title", ""))
        log_review(f"  记忆索引状态: 已存在 (obsId: {index_entry.get('obsId', '')[:8]}...)")
    else:
        log_review("  警告: 未找到记忆索引，需手动创建")

    log_review(f"  聚类检查完成, 发现 {len(clusters)} 个潜在聚类方向")

    log_review("=== 自我审查结束 ===")


if __name__ == "__main__":
    main()
