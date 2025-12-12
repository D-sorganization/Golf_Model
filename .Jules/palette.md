## 2025-05-20 - [PyQt Loading Feedback]
**Learning:** Desktop apps often miss "loading" states for file IO, which feels broken. Adding `WaitCursor` and status bar messages is a low-effort, high-impact fix.
**Action:** Always wrap file operations in GUI apps with visual feedback (cursor/status).
