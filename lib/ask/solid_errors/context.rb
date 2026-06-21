# frozen_string_literal: true

module Ask
  module SolidErrors
    # Human-readable description of the SolidErrors service context.
    DESCRIPTION = "SolidErrors — error tracking stored in your Rails database"

    # Gem name for the SolidErrors tracker.
    GEM_NAME = "solid_errors"

    # Quick-start Ruby code snippet for agents to copy-paste.
    QUICK_START = <<~RUBY
      errors = Ask::SolidErrors.recent(limit: 10)
      errors.map { |e| { id: e.id, class: e.exception_class, message: e.message.truncate(200) } }

      # Or get full details:
      error = Ask::SolidErrors.find(id)
      error.backtrace
      error.context

      # Or work with occurrences:
      error = Ask::SolidErrors.find(id)
      error.occurrences.each do |occ|
        puts occ.parsed_backtrace
      end
    RUBY
  end
end
