# App Forge - MCP 기반 모바일 앱 개발 자동화 시스템

Figma 디자인 변경부터 프로덕션 배포까지의 전체 워크플로우를 완전 자동화하는 통합 iOS/Android 앱 개발 시스템입니다.

## 🎯 프로젝트 개요

App Forge는 MCP(Model Context Protocol) 서버들을 활용하여 모바일 앱 개발의 전체 라이프사이클을 자동화합니다:

- **Figma 디자인 감지** → **코드 생성** → **테스트 실행** → **빌드** → **배포**

## 🛠 주요 MCP 서버

- **TaskManager**: 전체 프로젝트 관리 및 워크플로우 오케스트레이션
- **Context7**: 코드베이스 분석 및 문서화
- **Puppeteer Browser**: 웹 기반 테스트 및 UI 검증
- **Sequential Thinking**: 복잡한 의사결정 프로세스 자동화
- **Terminal**: 빌드 및 배포 명령어 실행

## 🏗 시스템 아키텍처

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Figma Design  │ ─► │   App Forge      │ ─► │   Production    │
│   Changes       │    │   Automation     │    │   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   TaskManager    │
                    │   Orchestrator   │
                    └──────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ iOS Pipeline │    │Android Pipeline│    │  Testing     │
│              │    │              │    │  Pipeline    │
└──────────────┘    └──────────────┘    └──────────────┘
```

## 📱 지원 플랫폼

- **iOS**: Swift/SwiftUI 기반 네이티브 앱
- **Android**: Kotlin/Jetpack Compose 기반 네이티브 앱
- **백엔드**: Supabase (Database, Auth, Storage, Real-time)

## 🔧 환경 설정

프로젝트는 `.env` 파일을 통해 유연하게 구성됩니다:

```env
# 개발 플랫폼 설정
ENABLE_IOS=true
ENABLE_ANDROID=true

# Supabase 설정
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Figma 설정
FIGMA_ACCESS_TOKEN=your_figma_token
FIGMA_FILE_ID=your_figma_file_id

# 배포 설정
IOS_TEAM_ID=your_ios_team_id
ANDROID_KEYSTORE_PATH=path_to_keystore
```

## 🚀 자동화 워크플로우

### 1. 디자인 변경 감지
- Figma API를 통한 디자인 변경 모니터링
- 컴포넌트 변경사항 자동 분석

### 2. 코드 생성
- Figma 디자인 → UI 컴포넌트 코드 자동 생성
- iOS (SwiftUI) / Android (Jetpack Compose) 동시 지원

### 3. 테스트 자동화
- 단위 테스트 자동 생성 및 실행
- UI 테스트 시나리오 자동화
- 크로스 플랫폼 호환성 테스트

### 4. 빌드 & 배포
- 자동 빌드 파이프라인
- TestFlight (iOS) / Play Console (Android) 배포
- 롤백 시스템

## 📂 프로젝트 구조

```
app-forge/
├── README.md
├── .env.example
├── package.json
├── scripts/
│   ├── setup.sh
│   ├── figma-sync.js
│   ├── build-ios.sh
│   ├── build-android.sh
│   └── deploy.sh
├── ios/
│   ├── AppForge/
│   ├── Tests/
│   └── Fastfile
├── android/
│   ├── app/
│   ├── tests/
│   └── fastlane/
├── shared/
│   ├── components/
│   ├── assets/
│   └── config/
├── supabase/
│   ├── migrations/
│   ├── functions/
│   └── config.toml
└── automation/
    ├── workflows/
    ├── tasks/
    └── templates/
```

## 🎮 사용법

### 초기 설정
```bash
# 프로젝트 설정
npm install
cp .env.example .env
# .env 파일 편집 후

# 개발 환경 설정
./scripts/setup.sh
```

### 개발 모드 실행
```bash
# TaskManager 시작
npm run start:taskmanager

# 특정 플랫폼 개발
npm run dev:ios      # iOS만 개발
npm run dev:android  # Android만 개발
npm run dev:both     # 양쪽 플랫폼
```

### 자동화 파이프라인 실행
```bash
# Figma 변경사항 동기화
npm run sync:figma

# 전체 파이프라인 실행
npm run pipeline:full

# 테스트만 실행
npm run test:all
```

## 🧪 테스트 전략

- **단위 테스트**: 각 컴포넌트별 자동 테스트
- **통합 테스트**: Supabase 연동 테스트
- **UI 테스트**: Puppeteer 기반 자동화된 UI 검증
- **E2E 테스트**: 전체 사용자 플로우 테스트

## 🚀 배포 전략

- **스테이징**: 자동 빌드 후 내부 테스트
- **프로덕션**: 승인 후 자동 배포
- **롤백**: 문제 발생 시 이전 버전 자동 복구

## 📋 TaskManager 통합

전체 프로젝트는 MCP TaskManager를 통해 관리됩니다:

- 작업 단위별 자동 할당
- 진행상황 실시간 모니터링
- 의존성 관리 및 순서 제어
- 오류 발생 시 자동 복구

## 🤝 기여하기

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.