# frozen_string_literal: true

module Ask
  module SolidErrors
    # Returns a client proxy for querying SolidErrors.
    #
    # No authentication is needed — SolidErrors runs in the same database as the
    # Rails app. The proxy delegates to +SolidErrors::Error+ and
    # +SolidErrors::Occurrence+ models, returning +ActiveRecord::Relation+
    # objects that can be further chained by the agent.
    #
    # @example
    #   Ask::SolidErrors.recent(limit: 5)
    #   Ask::SolidErrors.unresolved
    #   Ask::SolidErrors.by_class("ActiveRecord::RecordNotFound")
    #
    # @return [ClientProxy] a proxy wrapping +SolidErrors::Error+
    # @raise [LoadError] if the +solid_errors+ gem is not installed
    def self.client
      ensure_solid_errors_loaded!
      ClientProxy.new
    end

    # Convenience — return the most recently recorded errors.
    #
    # @param limit [Integer] number of errors to return (default: 10)
    # @return [ActiveRecord::Relation<SolidErrors::Error>]
    def self.recent(limit: 10)
      client.recent(limit: limit)
    end

    # Convenience — find a single error by its primary key.
    #
    # @param id [Integer, String] error record ID
    # @return [SolidErrors::Error]
    # @raise [ActiveRecord::RecordNotFound] if the record does not exist
    def self.find(id)
      client.find(id)
    end

    # Convenience — return all unresolved errors.
    #
    # @return [ActiveRecord::Relation<SolidErrors::Error>]
    def self.unresolved
      client.unresolved
    end

    # Convenience — return all resolved errors.
    #
    # @return [ActiveRecord::Relation<SolidErrors::Error>]
    def self.resolved
      client.resolved
    end

    # Convenience — filter errors by exception class name.
    #
    # @param klass [String] exception class name (e.g. "ActiveRecord::RecordNotFound")
    # @return [ActiveRecord::Relation<SolidErrors::Error>]
    def self.by_class(klass)
      client.where(exception_class: klass)
    end

    # Convenience — filter errors by severity level.
    #
    # @param severity [String] severity level ("error", "warning", "info")
    # @return [ActiveRecord::Relation<SolidErrors::Error>]
    def self.by_severity(severity)
      client.where(severity: severity)
    end

    # Convenience — search errors whose message contains the given text.
    #
    # @param query [String] search text
    # @return [ActiveRecord::Relation<SolidErrors::Error>]
    def self.search(query)
      client.where("message LIKE ?", "%#{client.sanitize_sql_like(query)}%")
    end

    # Convenience — return the occurrence count for an error.
    #
    # @param error [SolidErrors::Error, Integer] error record or its ID
    # @return [Integer]
    def self.occurrence_count(error)
      client.occurrence_count(error)
    end

    # Wraps +SolidErrors::Error+ and delegates query methods to it while
    # providing a clean interface for AI agents.
    class ClientProxy < BasicObject
      def initialize
        @model = ::SolidErrors::Error
      end

      # Delegate all known query methods to the SolidErrors model.
      def method_missing(name, ...)
        @model.public_send(name, ...)
      rescue ::ActiveRecord::NoDatabaseError => e
        ::Kernel.raise e, "SolidErrors database is not configured. " \
                          "Run `bin/rails solid_errors:install:migrations db:migrate` first."
      rescue ::ActiveRecord::StatementInvalid => e
        if e.message.include?("solid_errors")
          ::Kernel.raise e, "SolidErrors table does not exist. " \
                            "Run `bin/rails solid_errors:install:migrations db:migrate` first."
        else
          ::Kernel.raise e
        end
      end

      def respond_to_missing?(name, include_private = false)
        @model.respond_to?(name, include_private) || super
      end

      # Return the most recent errors.
      def recent(limit: 10)
        @model.order(created_at: :desc).limit(limit)
      end

      # Return all unresolved errors.
      def unresolved
        @model.unresolved.order(created_at: :desc)
      end

      # Return all resolved errors.
      def resolved
        @model.resolved.order(created_at: :desc)
      end

      # Return the occurrence count for an error.
      def occurrence_count(error)
        error = @model.find(error) unless error.is_a?(::ActiveRecord::Base)
        error.occurrences.count
      end
    end

    # Raise +LoadError+ with a clear message when the +solid_errors+ gem
    # is not available.
    def self.ensure_solid_errors_loaded!
      return if defined?(::SolidErrors)

      raise ::LoadError, "The `solid_errors` gem is not installed. " \
                         "Add `gem 'solid_errors'` to your Gemfile and run `bundle install`."
    end
  end
end
