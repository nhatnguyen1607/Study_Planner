# Database and AI implementation status

> Cấu hình AI hiện tại dùng Gemini trực tiếp + Firestore Spark, không Cloud Functions/Secret Manager. Xem [GEMINI_SETUP.md](GEMINI_SETUP.md); các ghi chú backend phía dưới là lịch sử.


> Tài liệu này ghi lại giai đoạn prototype trước đây. Trạng thái hiện tại, schema đã nối cho HM/GO/PL/AN/PR và hướng dẫn triển khai nằm ở [DATABASE_GUIDE.md](DATABASE_GUIDE.md). appState không còn là nguồn dữ liệu của phiên đăng nhập thật.

## Connected now
- user/{uid}: real profile + existing schema/rules.
- user/{uid}/appState/current: versioned editable prototype state for existing task checkmarks, goal progress, duration, rating, subject/weekly hours and ideal slots. Merge writes preserve future fields. Navigation does not trigger writes. Reads happen before allowing edits; failures have Retry UI.
- user/{uid}/aiUsage/{UTC-day}: backend-only quota (5 attempts/day, failures count).
- user/{uid}/aiDrafts/{requestId}: validated AI output, read-only for client.
- user/{uid}/plans/{draftId}: confirmed AI schedules, backend-only writes, stable IDs prevent duplicate confirms.
- AI entry: Study Planner preview (PL11) → Đề xuất lịch với AI → generate → inspect → confirm save.

## Not yet complete
Many existing screens still contain hardcoded subjects, task/goal titles, chart data and local-only form fields. appState is explicitly transitional state, NOT a normalized task/goal database. It must not be treated as fully integrated CRUD.
The saved AI schedules are not yet rendered in the existing PL day/week/detail screens.
PR04/PR05 notification/appearance editors remain prototype-only.
Next migration: separate user/{uid}/tasks, goals (+milestones), courses, plans (+dated sessions), notification inbox. Give each entity stable IDs, schemaVersion, createdAt, updatedAt and strict owner rules. Update one flow and its tests at a time; do not silently seed prototype content for real users.
Do not persist derived analytics as editable counters. Compute from completed task/session records.

## Deployment (not performed)
Cloud Functions deployment needs a Firebase billing-enabled project (Blaze). Gemini free quota does NOT make Functions hosting free/unlimited.
1. Review/merge local Firestore rules with your deployed rules.
2. Set a NEW key privately: firebase functions:secrets:set GEMINI_API_KEY --project studyplanner-76524
3. In functions/: npm install; npm test.
4. firebase deploy --only functions,firestore:rules --project studyplanner-76524
No exposed chat key is stored in this repository. Old key test timed out and its validity is NOT confirmed.
Model uses gemini-flash-latest (an alias may change). Pin a verified model before production.
Enable Firebase App Check and enforceAppCheck on callable functions before public release; currently authenticated-user access + quota only.
No prompts, passwords, raw keys or model response bodies are logged. Backend requestId is returned for troubleshooting.
Treat document schema changes as additive; increment schemaVersion and implement explicit migration before breaking changes.
Cross-device concurrent appState writes currently use last-write-wins. Move to per-entity transactions before collaborative/multi-device editing.
