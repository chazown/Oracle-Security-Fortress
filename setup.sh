#!/bin/bash
set -e

echo "=== Cloud Security Fortress 초기 설정 스크립트 ==="
echo "Oracle Cloud Ubuntu 24.04에서 WireGuard + AdGuard Home 준비 중..."

# 1. 시스템 업데이트 & 필수 패키지 설치
echo "시스템 업데이트 및 Docker 설치 중..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git nano docker.io docker-compose-v2
sudo systemctl enable --now docker

# 2. IP 포워딩 영구 활성화 (WireGuard 필수)
echo "IP 포워딩 활성화..."
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.all.src_valid_mark=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 3. Docker 그룹 추가 (sudo 없이 docker 사용 가능)
echo "Docker 그룹 추가..."
sudo usermod -aG docker $USER

# 4. 프로젝트 폴더 생성
echo "프로젝트 폴더 생성..."
mkdir -p ~/fortress/{wireguard/data,adguard/{conf,work}}

echo ""
echo "🎉 초기 설정 완료!"
echo "⚠️ 중요: 'newgrp docker'를 입력하거나 재로그인 후 각 폴더에서 설치를 진행하세요."
echo ""
echo "다음 단계 안내:"
echo "  1. WireGuard 설정"
echo "     cd ~/fortress/wireguard"
echo "     nano docker-compose.yml     # 반드시 WG_HOST와 PASSWORD 수정!"
echo "     docker compose up -d"
echo ""
echo "  2. AdGuard Home 설정"
echo "     cd ../adguard"
echo "     nano docker-compose.yml     # 필요 시 포트 등 수정"
echo "     docker compose up -d"
echo ""
echo "  3. 접속 확인"
echo "     브라우저에서:"
echo "       - AdGuard Home: http://YOUR_PUBLIC_IP:3000"
echo "       - WireGuard UI: http://YOUR_PUBLIC_IP:51821"
echo ""
echo "문제 발생 시 확인 명령어:"
echo "  docker ps"
echo "  docker logs wg-easy"
echo "  docker logs adguardhome"
echo ""
echo "즐겁게 사용하자! 🚀"
