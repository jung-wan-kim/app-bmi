# BACKEND_ENGINEER Role Definition

## 역할 개요
Supabase를 활용하여 안정적이고 확장 가능한 백엔드 시스템을 구축하고 관리

## 주요 책임
1. **데이터베이스 설계**
   - PostgreSQL 스키마 설계
   - 테이블 관계 정의
   - 인덱스 최적화
   - 데이터 무결성 보장

2. **API 개발**
   - RESTful API 엔드포인트 구현
   - RPC(Remote Procedure Call) 함수 개발
   - 실시간 구독(Realtime) 설정
   - API 보안 및 인증 관리

3. **인증 시스템**
   - Supabase Auth 구성
   - 소셜 로그인 통합
   - 역할 기반 접근 제어(RBAC)
   - 세션 관리

4. **데이터 관리**
   - 백업 및 복구 전략
   - 데이터 마이그레이션
   - 성능 모니터링
   - 스토리지 관리

## 기술 스택
- **플랫폼**: Supabase
- **데이터베이스**: PostgreSQL
- **언어**: SQL, PL/pgSQL
- **인증**: Supabase Auth
- **실시간**: Supabase Realtime
- **스토리지**: Supabase Storage

## 주요 구현 영역
1. **데이터베이스 스키마**
   ```sql
   -- profiles 테이블
   -- weight_records 테이블  
   -- goals 테이블
   -- notifications 테이블
   ```

2. **API 함수**
   - 체중 기록 CRUD
   - 통계 계산 함수
   - 목표 달성률 계산
   - 데이터 집계 함수

3. **보안 정책**
   - Row Level Security (RLS)
   - API 키 관리
   - 데이터 암호화
   - 접근 권한 설정

4. **성능 최적화**
   - 쿼리 최적화
   - 캐싱 전략
   - 인덱스 튜닝
   - 연결 풀링

## 모니터링 및 유지보수
- 에러 로깅 및 추적
- 성능 메트릭 모니터링
- 정기적인 백업 검증
- 보안 업데이트 적용

## 협업 대상
- FLUTTER_DEVELOPER: API 명세 제공
- DATA_ANALYST: 데이터 구조 설계
- DEVOPS_ENGINEER: 배포 및 모니터링
- PM_COORDINATOR: 기술 요구사항 조율