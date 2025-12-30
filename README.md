# 🛡️ Oracle Cloud Security Fortress

개인용 클라우드 환경에서 WireGuard 와 AdGuard Home 을 통합 구축하는 마스터 가이드입니다.

## 🧱 1. 오라클 클라우드 콘솔 설정 (Ingress Rules)
서버 접속 전, 아래 포트들을 반드시 개방하십시오.

| 프로토콜 | 포트 | 용도 |
| :--- | :--- | :--- |
| **TCP** | `51821`, `3000`, `53`, `853` | 관리 UI 및 서비스 |
| **UDP** | `51820`, `53` | VPN 터널 및 DNS 질의 |

## 🚀 2. 빠른 설치 방법
서버에 SSH로 접속한 뒤, 아래 명령어를 실행하여 자동 설치 스크립트를 가동하십시오.

```bash
chmod +x setup.sh
./setup.sh

## 🔐 3. 사후 관리 및 접속 정보 (Post-Installation)

설치가 완료되면 아래 주소로 접속하여 서비스를 관리할 수 있습니다.

### 🛰️ WireGuard 접속
- **주소:** `http://<YOUR_ORACLE_IP>:51821`
- **비밀번호:** `설치 시 생성한 해시값의 원문 비밀번호`
- **특징:** 최신 v14+ UI, QR 코드 생성 및 클라이언트 관리.

### 🛡️ AdGuard Home 접속
- **주소:** `http://<YOUR_ORACLE_IP>:3000`
- **관리자 설정:** 최초 접속 시 본인만의 ID/PW를 생성해야 합니다.
