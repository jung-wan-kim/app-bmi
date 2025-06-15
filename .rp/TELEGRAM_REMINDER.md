# 📱 텔레그램 알림 필수 사항

## ⚠️ 중요: 작업 완료 시 반드시 텔레그램 알림 전송!

### 텔레그램 정보
- **Bot Token**: 8089755627:AAFyW6jMNEBt33cvdZyOOAGOSmGP4PR88xc
- **Chat ID**: 55511334

### 알림 전송 시점
1. ✅ 각 Phase 완료 시
2. ✅ 주요 기능 구현 완료 시
3. ✅ Git 커밋/푸시 완료 시
4. ✅ 중요한 문서 작성 완료 시
5. ✅ 버그 수정 완료 시

### 알림 템플릿
```bash
curl -s -X POST "https://api.telegram.org/bot8089755627:AAFyW6jMNEBt33cvdZyOOAGOSmGP4PR88xc/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{
    "chat_id": "55511334",
    "text": "🎉 [작업명] 완료\n\n📱 프로젝트: app-bmi\n\n✅ 완료된 작업:\n• [작업 내용]\n\n⏱ 작업 시간: [시간]\n\n🔗 GitHub: https://github.com/jung-wan-kim/app-bmi\n\n#BMITracker #[태그]",
    "parse_mode": "HTML"
  }'
```

### 체크리스트
- [ ] 작업 완료
- [ ] Git 커밋/푸시
- [ ] 텔레그램 알림 전송 ← **절대 잊지 말 것!**

---
⚡ 이 파일은 프로젝트 내내 참조해야 함!