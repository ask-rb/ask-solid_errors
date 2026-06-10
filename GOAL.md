# ask-solid_errors — SolidErrors — error tracking stored in your Rails database

## Purpose

Service context gem for SolidErrors. Provides curated context and helpers
so AI agents can read, search, and analyze errors from SolidErrors.

No tool classes. The agent reads the context from the system prompt,
writes Ruby code using the helpers, and executes it with the Code tool.

## Dependencies

- **Runtime:** ask-core
- **Build/test:** minitest, mocha, rake, vcr, webmock
- **This gem MUST wait until ask-core is built, tested, and released.**

## What it provides

Three files, following the ask-github pattern:

### `lib/ask/solid_errors/context.rb`
Metadata for the system prompt:

```ruby
module Ask::SolidErrors
  DESCRIPTION  = "SolidErrors — error tracking stored in your Rails database"
  GEM_NAME     = "solid_errors"
  QUICK_START  = <<~RUBY
      errors = Ask::SolidErrors.recent(limit: 10)
      errors.map { |e| { id: e.id, class: e.exception_class, message: e.message.truncate(200) } }
      
      # Or get full details:
      error = Ask::SolidErrors.find(id)
      error.backtrace
  RUBY
end
```

### `lib/ask/solid_errors/client.rb`
Authenticated client helper:

```ruby
module Ask::SolidErrors
  def self.client
    # Resolve auth token, instantiate HTTP client, return it
  end

  def self.recent(limit: 10)
    # Convenience wrapper for common operations
  end
end
```

### `lib/ask/solid_errors/error_guide.rb`
Structured error knowledge:

```ruby
module Ask::SolidErrors::Errors
  MAP = { ... }
end
```

## Implementation

No auth needed — SolidErrors runs in the same database as the Rails app.

### SolidErrors-specific notes
- SolidErrors runs in the same database as the Rails app. No auth needed.
- The client helper is a thin wrapper around ActiveRecord queries:
  `SolidErrors::Error.order(created_at: :desc).limit(10)`
- No external HTTP calls — it uses the existing DB connection.
- If solid_errors gem is not installed, raise a clear error.

### Sentry-specific notes
- Sentry uses an auth token from https://sentry.io/settings/account/api/auth-tokens/
- The API is REST: https://sentry.io/api/0/
- Common endpoints: GET /projects/ORG/PROJECT/issues/, GET /issues/ID/events/
- Use Faraday or Net::HTTP for the API calls.
- The sentry-ruby gem is only needed for configuration, not for API calls.

### Honeybadger-specific notes
- Honeybadger uses an API token from the user settings page.
- The API is REST: https://api.honeybadger.io/v2/
- Common endpoints: GET /projects/PROJECT_ID/faults, GET /faults/ID
- Use Faraday or Net::HTTP for the API calls.

## Testing

- Unit tests for the client helper construction
- Integration tests with VCR cassettes for API-based services (Sentry, Honeybadger)
- SolidErrors tests can use an in-memory SQLite database with a test table
- Test error handling: timeouts, auth failures, rate limits, missing data

## Reference

Follow the ask-github pattern exactly:
- /Users/kaka/Code/ask-rb/ask-github/lib/ask/github/context.rb
- /Users/kaka/Code/ask-rb/ask-github/lib/ask/github/client.rb
- /Users/kaka/Code/ask-rb/ask-github/lib/ask/github/error_guide.rb

### Documentation
- **Update ask-docs** after releasing v0.1.0 — the docs site at github.com/ask-rb/ask-docs
  must reflect this gems API, usage, and position in the ecosystem.

## Development Workflow

### Git conventions
- The default branch is **master**.
- Follow the git-workflow skill for branch naming, commit messages, and PR structure.
- Conventional commits: feat:, fix:, docs:, test:, refactor:, chore:.
- One logical change per commit.

### Testing
- Minitest (not RSpec).
- Unit tests for every public method.
- Run full suite before every commit: bundle exec rake test.

## v0.1.0 Completion Checklist

- [ ] context.rb defines DESCRIPTION, QUICK_START, and auth info
- [ ] client.rb returns an authenticated client or ActiveRecord proxy
- [ ] error_guide.rb maps common errors to actionable messages
- [ ] Tests pass: bundle exec rake test
- [ ] Gem builds: gem build *.gemspec
- [ ] Gem is released on RubyGems.org
- [ ] CHANGELOG.md exists with v0.1.0 entry
