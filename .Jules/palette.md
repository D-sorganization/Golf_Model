## 2025-05-18 - [Initial Entry]

## 2025-05-18 - [Adding Wait Cursor to C3D Viewer]
**Learning:** PyQt's main thread blocks on file I/O. Users receive no feedback during this time. `QApplication.setOverrideCursor` is a simple way to indicate busy state without complex threading, suitable for "micro-UX" fixes.
**Action:** Always wrap blocking UI operations in `try...finally` to ensure cursor restoration, and pair with status bar updates for context.
