# Sentinel's Journal 🛡️

## 2025-12-12 - CSV Injection in Scientific Data
**Vulnerability:** CSV Injection (Excel Formula Injection) in `C3DDataReader.export_points`.
**Learning:** Even "read-only" data viewers/exporters can propagate vulnerabilities if they output formats used by office software (like CSV). Scientific data (marker names) can contain malicious payloads.
**Prevention:** Sanitize all string fields in CSV exports by prepending `'` if they start with dangerous characters (`=`, `+`, `-`, `@`), even if it slightly alters the data representation.
