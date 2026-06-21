# frozen_string_literal: true

module Ask
  module SolidErrors
    # Structured error knowledge for AI agents working with SolidErrors.
    #
    # Provides human-readable guidance for common Rails exception classes,
    # error severity levels, and database-related issues encountered when
    # querying SolidErrors records.
    module Errors
      # Common Rails exception classes and actionable guidance.
      EXCEPTIONS = {
        "ActiveRecord::RecordNotFound" => {
          message: "A record was not found by its primary key or finder.",
          action: "Check that the ID exists in the database. The record may have been deleted."
        },
        "ActiveRecord::RecordInvalid" => {
          message: "A record failed validation.",
          action: "Inspect the record's errors to see which validations failed."
        },
        "ActiveRecord::RecordNotSaved" => {
          message: "A record could not be saved due to base errors or callbacks.",
          action: "Check for before_save/before_create callbacks that return false."
        },
        "ActiveRecord::RecordNotDestroyed" => {
          message: "A record could not be destroyed due to before_destroy callbacks.",
          action: "Check for before_destroy callbacks that return false."
        },
        "ActiveRecord::StatementInvalid" => {
          message: "An SQL statement failed to execute.",
          action: "Check the SQL statement and database schema. The query may reference a missing column or table."
        },
        "ActiveRecord::ConnectionNotEstablished" => {
          message: "No database connection is available.",
          action: "Check database configuration and that the database server is running."
        },
        "ActiveRecord::Migration::PendingMigrationError" => {
          message: "There are pending database migrations.",
          action: "Run `bin/rails db:migrate` to apply pending migrations."
        },
        "ActiveRecord::NoDatabaseError" => {
          message: "The database does not exist.",
          action: "Run `bin/rails db:create` to create the database."
        },
        "ActiveRecord::Deadlocked" => {
          message: "A database deadlock was detected.",
          action: "Retry the transaction. Ensure consistent lock ordering in concurrent operations."
        },
        "ActiveRecord::LockWaitTimeout" => {
          message: "A database lock wait timeout expired.",
          action: "Reduce contention on the locked resource or increase the lock timeout."
        },
        "ActionController::RoutingError" => {
          message: "No route matches the requested URL.",
          action: "Check the URL and your routes file. Run `bin/rails routes` to see available routes."
        },
        "ActionController::ParameterMissing" => {
          message: "A required parameter was not provided.",
          action: "Check the required parameters for the action and ensure they are included in the request."
        },
        "ActionController::InvalidAuthenticityToken" => {
          message: "The CSRF authenticity token is invalid.",
          action: "Ensure forms include the CSRF token. This can happen after a session expires."
        },
        "ActiveSupport::MessageVerifier::InvalidSignature" => {
          message: "A signed message has an invalid signature.",
          action: "The data may have been tampered with, or the secret key base has changed since signing."
        },
        "Net::ReadTimeout" => {
          message: "An external HTTP request timed out while reading the response.",
          action: "Check the external service availability and response time. Consider increasing the timeout."
        },
        "Net::OpenTimeout" => {
          message: "An external HTTP connection timed out.",
          action: "Check network connectivity and that the external service is reachable."
        },
        "SystemExit" => {
          message: "The process was asked to exit by calling exit or abort.",
          action: "This may be intentional (e.g., abort in a callback). Check the exit code."
        },
        "SignalException" => {
          message: "The process received a signal (e.g., SIGTERM, SIGINT).",
          action: "The process was interrupted externally. This is expected during deploys or shutdowns."
        },
        "NoMemoryError" => {
          message: "The system ran out of memory.",
          action: "Reduce memory usage or increase available memory. Check for memory leaks."
        }
      }.freeze

      # Error severity levels used by SolidErrors and how to respond.
      SEVERITIES = {
        "error" => {
          description: "🔥 An actual error occurred that requires investigation.",
          action: "Prioritize review. Check the backtrace and context for the root cause."
        },
        "warning" => {
          description: "⚠️  An unexpected condition occurred but the request completed.",
          action: "Review when convenient. May indicate an edge case or degraded experience."
        },
        "info" => {
          description: "ℹ️  An informational event was logged.",
          action: "No immediate action needed. Useful for auditing and debugging."
        }
      }.freeze

      # Database-related guidance for SolidErrors configuration.
      DATABASE = {
        table_name: "solid_errors",
        occurrences_table_name: "solid_errors_occurrences",
        migration_instructions: "Run `bin/rails solid_errors:install:migrations` then `bin/rails db:migrate`",
        table_structure: {
          "solid_errors" => [
            "exception_class (text) — the exception class name (e.g. ActiveRecord::RecordNotFound)",
            "message (text) — the exception message",
            "severity (text) — error, warning, or info",
            "source (text, nullable) — source of the error",
            "resolved_at (datetime, nullable) — when the error was resolved",
            "fingerprint (string, unique) — SHA256 hash for deduplication"
          ],
          "solid_errors_occurrences" => [
            "error_id (integer) — FK to solid_errors.id",
            "backtrace (text) — the exception backtrace",
            "context (json) — structured context data from the error"
          ]
        }
      }.freeze

      # Look up guidance for a Rails exception class name.
      #
      # @param exception_class [String] The exception class name (e.g. "ActiveRecord::RecordNotFound")
      # @return [Hash, nil] A hash with +:message+ and +:action+ keys, or nil if unknown
      def self.for(exception_class)
        EXCEPTIONS[exception_class]
      end

      # Describe a severity level.
      #
      # @param severity [String] severity level ("error", "warning", "info")
      # @return [Hash, nil] Description of the severity, or nil if unknown
      def self.severity_description(severity)
        SEVERITIES[severity.to_s]
      end
    end
  end
end
