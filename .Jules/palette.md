# Palette's Journal

## 2025-12-11 - [C3D Viewer Async Feedback]
**Learning:** Synchronous operations in desktop GUIs freeze the interface, confusing users.
**Action:** Use `Qt.CursorShape.WaitCursor` during file loading to indicate processing.

## 2025-12-13 - [Adding Wait Cursor to C3D Viewer]
**Learning:** PyQt's main thread blocks on file I/O. Users receive no feedback during this time. `QApplication.setOverrideCursor` is a simple way to indicate busy state without complex threading, suitable for "micro-UX" fixes.
**Action:** Always wrap blocking UI operations in `try...finally` to ensure cursor restoration, and pair with status bar updates for context.
