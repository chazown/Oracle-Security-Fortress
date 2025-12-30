#!/bin/bash

# ---------------------------------------------------------
# Cloud Security Fortress Setup Script (Ultimate)
# ---------------------------------------------------------

echo "================================================="
echo "🛡️ Cloud 지능형 구축을 시작합니다."
echo "================================================="

# 1. 환경 변수 자동 감지
echo "[1/7] 서버의 공용 IP 주소를 확인 중..."
ORACLE_IP=$(curl -s https://ifconfig.me)
if [ -z "$ORACLE_IP" ]; then
    echo "❌ IP 감지 실패. 네트워크 연결을 확인필요"
    exit 1
fi
echo "✅ 감지된 IP: $ORACLE_IP"

# 2. 기존 도커 리소스 청소 (Cleanup)
echo "[2/7] 기존 컨테이너 및 찌꺼기 청소 중..."
sudo docker rm -f wg-easy adguardhome 2>/dev/null
sudo docker system prune -f > /dev/null 2>&1
echo "✅ 도커 청소 완료."

# 3. 도커 브리지 게이트웨이 감지 (DNS 연동용)
echo "[3/7] 도커 네트워크 게이트웨이를 분석 중..."
DOCKER_GATEWAY=$(sudo docker network inspect bridge --format '{{(index .IPAM.Config 0).Gateway}}')
if [ -z "$DOCKER_GATEWAY" ]; then
    DOCKER_GATEWAY="172.17.0.1"
fi
echo "✅ 감지된 DNS 게이트웨이: $DOCKER_GATEWAY"

# 4. 시스템 내부 방화벽 개방 (iptables)
echo "[4/7] 시스템 방화벽을 개방 중..."
sudo iptables -I INPUT -p tcp --dport 51821 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 853 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 51820 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 53 -j ACCEPT
sudo netfilter-persistent save > /dev/null 2>&1
echo "✅ 방화벽 설정 완료."

# 5. AdGuard Home 배포
echo "[5/7] AdGuard Home(광고 차단 엔진) 배포 중..."
sudo docker run -d \
  --name adguardhome \
  --restart unless-stopped \
  -v /home/ubuntu/adguardhome/work:/opt/adguardhome/work \
  -v /home/ubuntu/adguardhome/conf:/opt/adguardhome/conf \
  -p 53:53/tcp -p 53:53/udp \
  -p 3000:3000/tcp \
  -p 853:853/tcp \
  adguard/adguardhome:latest > /dev/null 2>&1
echo "✅ AdGuard Home 설치 완료."

# 6. WireGuard 보안 해시 생성
echo "[6/7] WireGuard 보안 설정을 시작합니다."
echo "-------------------------------------------------"
read -s -p "사용할 비밀번호를 입력하십시오 (화면에 표시되지 않음): " RAW_PWD
echo ""
echo "-------------------------------------------------"
HASH_PWD=$(sudo docker run --rm ghcr.io/wg-easy/wg-easy:latest node -e "console.log(require('bcryptjs').hashSync('$RAW_PWD', 10))")
echo "✅ 보안 해시 생성 성공."

# 7. WireGuard 본진 배포
echo "[7/7] WireGuard(VPN)를 최종 배포합니다..."
sudo docker run -d \
  --name wg-easy \
  --restart unless-stopped \
  -e WG_HOST=$ORACLE_IP \
  -e PASSWORD_HASH="$HASH_PWD" \
  -e WG_DEFAULT_DNS=$DOCKER_GATEWAY \
  -v /home/ubuntu/.wg-easy:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --sysctl="net.ipv4.ip_forward=1" \
  ghcr.io/wg-easy/wg-easy:latest > /dev/null 2>&1

echo "================================================="
echo "🎉 서버에 VPN 구축이 완료되었습니다!"
echo "-------------------------------------------------"
echo "🔓 WireGuard UI: http://$ORACLE_IP:51821"
echo "🛡️ AdGuard Home: http://$ORACLE_IP:3000"
echo "================================================="
