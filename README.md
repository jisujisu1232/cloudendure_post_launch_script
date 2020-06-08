# CloudEndure Post Launch Script
CE 로 마이그레이션된 머신 기동 후 Background 에서 수행되는 Script

# Windows
## File Pattern
- 00.init
    - Script 중 최초로 수행됨
    - 02.* 패턴의 파일을 C:\\AWSmigrationTemp\\ 로 이동
- 01.*
    - Background 에서 정상 수행되는 Script
- 02.*
    - Background 에서 정상 수행되지 않아 작업자가 수동으로 돌리는 Script
    - Migration 작업에 도움이 되는 파일 등.

## 삭제 스크립트 생성
### find_uninstall_string.bat
- 프로그램 추가/삭제 에서 Display Name 확인
- 실행 (" 필수)
    - find_uninstall_string.bat "{Display Name}"
    - 삭제 명령어 확인

### uninstall_template.bat
- uninstall_template.bat 복사 후 아래 부분 변경
```
REM #######   삭제 대상 별 변경 필요  ########

set SoftwareName=Bandizip

REM UninstallString 이 MsiExec 로 시작하는 경우 1
REM 아닌 경우 2
REM Reg 상에 MsiExec 와 다른 방식이 공존하는 경우가 있음.

set UninstallType=1
REM set UninstallType=2


set UninstallOptions=/SILENT /VERYSILENT

REM #######      END      ########
```
- SoftwareName
    - Display Name 입력
- UninstallType
    - 삭제 명령어가 MsiExec 로 시작하면 1 아니면 2
    - 2개 이상이 있다면 silent uninstall 지원하는 명령어 사용
- UninstallOptions
    - {Display Name} silent uninstall 등으로 검색
    - silent 옵션 확인 후 입력

### 최종 파일명
- Silent uninstall 지원 및 정상 동작
    - 01.{식별 가능 명칭}.bat
- Silent uninstall 미지원 및 Background Service 에서 비정상 동작
    - 02.{식별 가능 명칭}.bat
