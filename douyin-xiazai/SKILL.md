---
name: douyin-xiazai
slug: solo-douyin-xiazai
displayName: 抖音无水印下载（SOLO 版）
version: "1.0.0-solo"
description: 抖音无水印视频下载工具。当用户发抖音分享链接要求下载视频时触发。支持三种下载策略自动降级：douyin-downloader API、yt-dlp、浏览器提取（MCP browser + curl）。额外支持视频去水印功能（Inpainting + 真实纹理叠加）。
agent_created: true
tags: ["抖音","视频下载","去水印","短视频","Douyin","SOLO","Trae Work"]
---

# douyin-xiazai（SOLO 版·抖音无水印下载）

## 概述

抖音无水印视频下载与去水印工具。当用户发送抖音分享链接（`v.douyin.com`）要求下载视频时触发。

**SOLO 适配说明**：
- 已完全适配 SOLO (Trae Work) 云端和本地环境
- 优先使用 MCP browser 工具提取视频 URL（最可靠）
- 去水印功能仅依赖 OpenCV + ffmpeg，无需大模型下载

---

## 触发条件

当用户消息包含以下内容时触发：
- 抖音分享链接（`v.douyin.com`、`douyin.com/video/`）
- "下载这个视频"、"下载抖音"等明确下载意图
- 用户发送包含抖音口令的文本（如 `复制打开抖音`）

---

## 下载流程

### Step 1：提取抖音链接

从用户消息中提取 `https://v.douyin.com/xxxxx/` 格式的链接。
如果用户发送的是抖音口令文本（含"复制打开抖音"），需要先提取其中的短链接。

### Step 2：浏览器提取视频 URL（推荐方案）

> 这是当前最可靠的方案，抖音 API 经常变动，浏览器提取始终有效。

1. **`browser_navigate`** 打开抖音分享链接，等待自动跳转到 `douyin.com/video/xxxxx` 页面
   ```
   browser_navigate(url: "提取到的链接")
   ```
   注意：导航后会自动锁定浏览器，操作完成后必须 `browser_unlock`

2. **`browser_wait_for`** 等待 5 秒让视频加载
   ```
   browser_wait_for(time: 5)
   ```

3. **`browser_evaluate`** 执行 JS 提取视频直链
   ```javascript
   const videos = document.querySelectorAll("video");
   const results = [];
   for (const v of videos) {
     if (v.currentSrc && !v.currentSrc.startsWith("blob:")) {
       results.push({currentSrc: v.currentSrc, poster: v.poster});
     }
     for (const s of v.querySelectorAll("source")) {
       if (s.src && !s.src.startsWith("blob:")) results.push({src: s.src});
     }
   }
   return results;
   ```
   取返回结果中第一个非 blob 的 `currentSrc` 或 `src` URL。

4. **`browser_unlock`** 释放浏览器

5. **用 `RunCommand` 调用 curl 下载**，必须带 Referer 头：
   ```bash
   curl -L -o "/workspace/视频标题.mp4" \
     -H "Referer: https://www.douyin.com/" \
     "<提取到的视频URL>"
   ```

6. **用 `ffprobe`** 验证下载结果：
   ```bash
   ffprobe -v quiet -print_format json -show_format <视频路径>
   ```

### Step 3：输出结果

告诉用户：
- 视频标题
- 文件大小、分辨率、时长
- 使用 `computer:///` 链接让用户直接打开文件

---

## 去水印流程（可选）

当用户额外要求去除视频水印时：

### 检测水印位置

1. 从视频中提取关键帧（每隔1秒取一帧）
2. 用 `Read` 工具查看帧图像，识别水印位置和大小
3. 让用户确认水印区域坐标 (x, y, w, h)

### 执行去水印

使用 Python 脚本（OpenCV）执行去水印，算法：**Telea Inpainting + 真实纹理叠加**

```python
# 核心步骤（简化描述，实际使用完整脚本）
import cv2
# 1. 创建水印区域椭圆 mask
# 2. cv2.inpaint(mask, radius=5, flags=cv2.INPAINT_TELEA)
# 3. 从周围提取真实高频纹理叠加
# 4. LAB 颜色空间微调匹配周围光影
# 5. 高斯羽化边缘融合
```

最后用 ffmpeg 转码为 H.264：
```bash
ffmpeg -y -i input.mp4 -c:v libx264 -crf 23 -preset fast -c:a aac output.mp4
```

---

## 注意事项

- **必须带 Referer 头下载**，否则抖音 CDN 会返回空文件或 HTML
- **视频 URL 有时效性**，提取后应立即下载
- **blob: URL 不可用**，JS 中已过滤，只取 `douyinvod.com` 的直链
- 去水印功能需要视频帧中水印位置固定（静态水印），动态水印需要逐帧追踪
- 如果 `browser_navigate` 后页面显示"视频数据加载中"，等待 5 秒后重新 `browser_evaluate`