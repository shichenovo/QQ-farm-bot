#!/usr/bin/env bash
# qq-farm-bot Linux 一键部署脚本（NapCat 对接版）
# 用法： bash server-deploy.sh
# 前置：Docker 20+ / Docker Compose 2+，内存建议 2GB+（NapCat 里的 QQ 是 Electron）
set -e
cd "$(dirname "$0")"

echo "==> 当前目录: $(pwd)"
command -v docker >/dev/null 2>&1 || { echo "错误: 未安装 docker"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "错误: 需要 docker compose v2"; exit 1; }

echo "==> 构建并启动 (docker compose up -d --build) ..."
docker compose up -d --build

echo "==> 等待服务就绪 (20s) ..."
sleep 20

echo "==> 容器状态:"
docker ps --filter name=qq-farm-bot --filter name=napcat-farm --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo "==> 面板健康检查:"
curl -s -m 10 http://localhost:3007/api/game-version || echo "(面板未就绪，请查看日志: docker logs qq-farm-bot)"

echo
echo "==> 部署完成。面板地址: http://<服务器IP>:3007 (admin/admin，首次登录请改密码)"
echo "==> 添加账号: 面板 → 设置 → 账号管理 → 添加账号 → 「NapCat 扫码登录」，用手机 QQ 扫码即可。"
echo "==> 扫码后 QQ 常驻在线，Code 失效自动刷新（worker 400 触发 + 每 60 分钟兜底），掉线自动重连。"
echo "==> 查看日志:"
echo "    core:   docker logs -f qq-farm-bot"
echo "    napcat: docker logs -f napcat-farm"
