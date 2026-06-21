---
name: solid_errors.use_solid_errors
description: How to navigate SolidErrors — query errors, occurrences, and backtraces in your Rails database
---

Use this skill when you need to review application errors stored in your Rails
database via the SolidErrors engine.

## Step 1: Understand the Difference

Unlike other service gems, SolidErrors has **no external API** — errors are
stored in your Rails database. `Ask::SolidErrors.client` returns a proxy
to `ActiveRecord::Relation` objects from `SolidErrors::Error`.

## Step 2: Explore the Context

```ruby
Ask::SolidErrors::Context::QUICK_START  # Query examples
```

## Step 3: Use Convenience Helpers

The gem ships with helpers for common queries:

```ruby
# Most recent errors
errors = Ask::SolidErrors.recent(limit: 10)

# Find by ID with occurrences
error = Ask::SolidErrors.find(id)
puts error.exception_class
puts error.message
puts error.backtrace
puts error.context

# Unresolved errors
unresolved = Ask::SolidErrors.unresolved

# Resolved errors
resolved = Ask::SolidErrors.resolved

# Filter by exception class
not_founds = Ask::SolidErrors.by_class("ActiveRecord::RecordNotFound")

# Filter by severity
warnings = Ask::SolidErrors.by_severity("warning")

# Search by message text
results = Ask::SolidErrors.search("timeout")
```

## Step 4: Chaining Queries like ActiveRecord

Since the proxy returns `ActiveRecord::Relation` objects, you can chain:

```ruby
# Count
Ask::SolidErrors.unresolved.count

# Order and limit
Ask::SolidErrors.by_class("NoMethodError").order(created_at: :desc).limit(5)

# Get occurrences for a specific error
error = Ask::SolidErrors.find(id)
error.occurrences.each do |occ|
  occ.parsed_backtrace.each do |trace_line|
    puts "#{trace_line['file']}:#{trace_line['line_number']}"
  end
end
```

## Step 5: Common Issues

- **Table doesn't exist**: Run `bin/rails solid_errors:install:migrations db:migrate`
- **No database configured**: SolidErrors requires a Rails database connection
- **No errors found**: The app may not have encountered errors yet, or the
  table may be empty — check `Ask::SolidErrors.recent` first to confirm
- **Occurrence details**: Each error has multiple occurrences (the same error
  happening multiple times). Use `error.occurrences` to get individual events

## Step 6: Fallback Strategy

1. SolidErrors uses standard ActiveRecord — any valid ActiveRecord query works
2. Call `Ask::SolidErrors.client.methods(false)` to see all available methods
3. The underlying `SolidErrors::Error` model has columns like `exception_class`,
   `message`, `severity`, `backtrace`, `context`, `created_at`
4. For custom queries not covered by helpers, use `Ask::SolidErrors.client`
   directly — it delegates to `SolidErrors::Error`
