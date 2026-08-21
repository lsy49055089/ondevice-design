# On-Device RTL / FPGA Design

온디바이스 과정에서 진행한 **Verilog RTL 및 FPGA 설계 프로젝트**를 정리한 포트폴리오 저장소입니다.

## Projects

### [FPGA Stopwatch & Watch](./fpga-stopwatch-watch)

Digilent Basys3 보드에서 동작하는 디지털 시계와 스톱워치 통합 시스템입니다.

- **Stack:** Verilog HDL, Xilinx Vivado, Basys3 FPGA
- **Architecture:** Control Unit / Datapath 분리, FSM 기반 모드 제어
- **Key Features:** 100 Hz tick, 시간 계수, 버튼 디바운싱, Moment 캡처, 4자리 7-Segment 표시
- **My Role:** Stopwatch FSM·Datapath 설계, Moment 기능 구현, 테스트벤치 작성 및 시뮬레이션 검증

소스 코드, Basys3 제약 파일, 테스트벤치와 시스템 구조도는 프로젝트 폴더에서 확인할 수 있습니다.

## Focus Areas

- FSM 및 Datapath 기반 RTL 설계
- FPGA 주변장치 및 디지털 시스템 통합
- Verilog 테스트벤치와 파형 기반 기능 검증
- 문제 상황 재현과 설계 개선
