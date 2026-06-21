# ask-solid_errors

SolidErrors — error tracking stored in your Rails database

## Installation

```ruby
gem "ask-solid_errors"
```

## Prerequisites

This gem requires the `solid_errors` gem to be installed and configured in your Rails app:

```ruby
gem "solid_errors"
```

Run the SolidErrors migration:

```bash
bin/rails solid_errors:install:migrations
bin/rails db:migrate
```

## Usage

```ruby
# Recent errors
errors = Ask::SolidErrors.recent(limit: 10)
errors.map { |e| { id: e.id, class: e.exception_class, message: e.message.truncate(200) } }

# Find by ID
error = Ask::SolidErrors.find(42)
error.backtrace
error.context
error.occurrences

# Filter by status
Ask::SolidErrors.unresolved   # errors needing attention
Ask::SolidErrors.resolved     # previously resolved errors

# Filter by class or severity
Ask::SolidErrors.by_class("ActiveRecord::RecordNotFound")
Ask::SolidErrors.by_severity("error")

# Search messages
Ask::SolidErrors.search("timeout")

# Occurrence count
Ask::SolidErrors.occurrence_count(error)
Ask::SolidErrors.occurrence_count(42)

# Low-level client for custom queries
client = Ask::SolidErrors.client
client.where(exception_class: "RuntimeError").order(created_at: :desc)
```

## Development

```bash
bundle exec rake test
```

## License

MIT
