# frozen_string_literal: true

require_relative "test_helper"

class ErrorGuideTest < Minitest::Test
  def test_exceptions_cover_common_rails_errors
    %w[
      ActiveRecord::RecordNotFound
      ActiveRecord::RecordInvalid
      ActiveRecord::StatementInvalid
      ActiveRecord::ConnectionNotEstablished
      ActiveRecord::Deadlocked
      ActionController::RoutingError
      ActionController::ParameterMissing
      ActionController::InvalidAuthenticityToken
      Net::ReadTimeout
      Net::OpenTimeout
    ].each do |klass|
      assert Ask::SolidErrors::Errors::EXCEPTIONS.key?(klass), "Missing exception #{klass}"
    end
  end

  def test_for_returns_guidance
    guidance = Ask::SolidErrors::Errors.for("ActiveRecord::RecordNotFound")
    assert guidance.key?(:message)
    assert guidance.key?(:action)
  end

  def test_for_returns_nil_for_unknown
    assert_nil Ask::SolidErrors::Errors.for("Some::Unknown::Error")
  end

  def test_severities_cover_all_levels
    %w[error warning info].each do |level|
      assert Ask::SolidErrors::Errors::SEVERITIES.key?(level), "Missing severity #{level}"
    end
  end

  def test_severity_description_returns_hash
    desc = Ask::SolidErrors::Errors.severity_description("error")
    assert desc.key?(:description)
    assert desc.key?(:action)
  end

  def test_severity_description_returns_nil_for_unknown
    assert_nil Ask::SolidErrors::Errors.severity_description("critical")
  end

  def test_database_info_is_defined
    assert_equal "solid_errors", Ask::SolidErrors::Errors::DATABASE[:table_name]
    assert_equal "solid_errors_occurrences", Ask::SolidErrors::Errors::DATABASE[:occurrences_table_name]
  end

  def test_database_describes_table_structure
    assert Ask::SolidErrors::Errors::DATABASE.key?(:table_structure)
    assert Ask::SolidErrors::Errors::DATABASE[:table_structure].key?("solid_errors")
    assert Ask::SolidErrors::Errors::DATABASE[:table_structure].key?("solid_errors_occurrences")
  end

  def test_database_migration_instructions
    assert_includes Ask::SolidErrors::Errors::DATABASE[:migration_instructions], "solid_errors:install:migrations"
  end

  def test_exception_messages_are_actionable
    error = Ask::SolidErrors::Errors.for("ActiveRecord::RecordNotFound")
    assert_includes error[:message], "not found"
  end

  def test_migration_error_guidance
    error = Ask::SolidErrors::Errors.for("ActiveRecord::Migration::PendingMigrationError")
    assert_includes error[:action], "db:migrate"
  end

  def test_connection_error_guidance
    error = Ask::SolidErrors::Errors.for("ActiveRecord::ConnectionNotEstablished")
    assert_includes error[:message], "connection"
  end

  def test_statement_invalid_guidance
    error = Ask::SolidErrors::Errors.for("ActiveRecord::StatementInvalid")
    assert_includes error[:message], "SQL"
  end
end
