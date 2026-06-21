# Changelog

## 0.1.0 (2026-06-10)

### Added

- `Ask::SolidErrors.context` — DESCRIPTION, GEM_NAME, QUICK_START for system prompts
- `Ask::SolidErrors.client` — ClientProxy wrapping `SolidErrors::Error` with ActiveRecord delegation
- `Ask::SolidErrors.recent`, `.find`, `.unresolved`, `.resolved`, `.by_class`, `.by_severity`, `.search`, `.occurrence_count` — module-level convenience helpers
- `Ask::SolidErrors::Errors` — structured error knowledge (18 common Rails exceptions, 3 severity levels, database schema documentation)
- No authentication needed — SolidErrors queries the Rails database directly via ActiveRecord
- Guard clause `ensure_solid_errors_loaded!` with clear error message if gem is missing
- Full Minitest test suite with in-memory SQLite (41 tests, 76 assertions)
