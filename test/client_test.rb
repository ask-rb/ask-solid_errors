# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def setup
    SolidErrors::Error.delete_all
    SolidErrors::Occurrence.delete_all
  end

  # --- factory helpers ---

  def create_error(exception_class:, message:, severity: "error", resolved_at: nil)
    fingerprint = Digest::SHA256.hexdigest([exception_class, message, severity].join)
    SolidErrors::Error.create!(
      exception_class: exception_class,
      message: message,
      severity: severity,
      fingerprint: fingerprint,
      resolved_at: resolved_at
    )
  end

  def create_occurrence(error:, backtrace: nil, context: nil)
    error.occurrences.create!(backtrace: backtrace, context: context)
  end

  # --- client proxy construction ---

  def test_client_returns_proxy
    proxy = Ask::SolidErrors.client
    # The proxy delegates .class to SolidErrors::Error via method_missing.
    # Verify it works by calling a query method.
    result = proxy.recent(limit: 5)
    assert result.respond_to?(:to_a) # ActiveRecord::Relation
  end

  def test_module_level_recent
    e1 = create_error(exception_class: "RuntimeError", message: "first")
    e2 = create_error(exception_class: "RuntimeError", message: "second")

    recent = Ask::SolidErrors.recent(limit: 5)
    assert_equal 2, recent.size
    assert_equal e2.id, recent.first.id
    assert_equal e1.id, recent.last.id
  end

  def test_module_level_recent_respects_limit
    create_error(exception_class: "RuntimeError", message: "one")
    create_error(exception_class: "RuntimeError", message: "two")
    create_error(exception_class: "RuntimeError", message: "three")

    assert_equal 2, Ask::SolidErrors.recent(limit: 2).size
  end

  def test_module_level_find
    error = create_error(exception_class: "ArgumentError", message: "bad arg")
    found = Ask::SolidErrors.find(error.id)
    assert_equal error.id, found.id
    assert_equal "ArgumentError", found.exception_class
  end

  def test_module_level_find_raises_when_not_found
    assert_raises(ActiveRecord::RecordNotFound) { Ask::SolidErrors.find(999_999) }
  end

  def test_module_level_unresolved
    create_error(exception_class: "RuntimeError", message: "unresolved one")
    create_error(exception_class: "RuntimeError", message: "resolved", resolved_at: Time.now)
    create_error(exception_class: "RuntimeError", message: "unresolved two")

    unresolved = Ask::SolidErrors.unresolved
    assert_equal 2, unresolved.size
    unresolved.each { |e| refute e.resolved?, "expected unresolved" }
  end

  def test_module_level_resolved
    create_error(exception_class: "RuntimeError", message: "unresolved one")
    create_error(exception_class: "RuntimeError", message: "resolved", resolved_at: Time.now)

    resolved = Ask::SolidErrors.resolved
    assert_equal 1, resolved.size
    resolved.each { |e| assert e.resolved?, "expected resolved" }
  end

  def test_module_level_by_class
    create_error(exception_class: "RuntimeError", message: "runtime")
    create_error(exception_class: "ArgumentError", message: "argument")
    create_error(exception_class: "RuntimeError", message: "another runtime")

    results = Ask::SolidErrors.by_class("RuntimeError")
    assert_equal 2, results.size
    results.each { |e| assert_equal "RuntimeError", e.exception_class }
  end

  def test_module_level_by_severity
    create_error(exception_class: "RuntimeError", message: "error", severity: "error")
    create_error(exception_class: "RuntimeError", message: "warning", severity: "warning")
    create_error(exception_class: "RuntimeError", message: "info", severity: "info")

    assert_equal 1, Ask::SolidErrors.by_severity("warning").size
    assert_equal 1, Ask::SolidErrors.by_severity("info").size
  end

  def test_module_level_search
    create_error(exception_class: "RuntimeError", message: "connection timeout occurred")
    create_error(exception_class: "RuntimeError", message: "everything is fine")
    create_error(exception_class: "RuntimeError", message: "timeout when reading data")

    results = Ask::SolidErrors.search("timeout")
    assert_equal 2, results.size
  end

  def test_module_level_occurrence_count
    error = create_error(exception_class: "RuntimeError", message: "with occurrences")
    create_occurrence(error: error, backtrace: "line 1")
    create_occurrence(error: error, backtrace: "line 2")

    assert_equal 2, Ask::SolidErrors.occurrence_count(error)
  end

  def test_module_level_occurrence_count_by_id
    error = create_error(exception_class: "RuntimeError", message: "by id")
    create_occurrence(error: error, backtrace: "line 1")

    assert_equal 1, Ask::SolidErrors.occurrence_count(error.id)
  end

  # --- proxy-level tests ---

  def test_client_proxy_recent
    proxy = Ask::SolidErrors.client
    create_error(exception_class: "RuntimeError", message: "test")

    result = proxy.recent(limit: 5)
    assert_equal 1, result.size
  end

  def test_client_proxy_unresolved
    proxy = Ask::SolidErrors.client
    create_error(exception_class: "RuntimeError", message: "unresolved")

    result = proxy.unresolved
    assert_equal 1, result.size
  end

  def test_client_proxy_resolved
    proxy = Ask::SolidErrors.client
    create_error(exception_class: "RuntimeError", message: "resolved", resolved_at: Time.now)

    result = proxy.resolved
    assert_equal 1, result.size
  end

  def test_client_proxy_occurrence_count
    proxy = Ask::SolidErrors.client
    error = create_error(exception_class: "RuntimeError", message: "test")
    create_occurrence(error: error, backtrace: "line 1")

    assert_equal 1, proxy.occurrence_count(error)
  end

  def test_client_proxy_occurrence_count_with_id
    proxy = Ask::SolidErrors.client
    error = create_error(exception_class: "RuntimeError", message: "test")
    create_occurrence(error: error, backtrace: "line 1")

    assert_equal 1, proxy.occurrence_count(error.id)
  end

  def test_client_proxy_delegates_unknown_methods
    create_error(exception_class: "RuntimeError", message: "for delegation")

    proxy = Ask::SolidErrors.client
    result = proxy.where(exception_class: "RuntimeError")
    assert_kind_of ActiveRecord::Relation, result
    assert_equal 1, result.size
  end

  def test_client_proxy_find
    error = create_error(exception_class: "RuntimeError", message: "to find")
    proxy = Ask::SolidErrors.client

    found = proxy.find(error.id)
    assert_equal error.id, found.id
  end

  # --- edge cases ---

  def test_recent_returns_empty_when_no_errors
    assert_equal 0, Ask::SolidErrors.recent.size
  end

  def test_unresolved_returns_empty_when_all_resolved
    create_error(exception_class: "RuntimeError", message: "resolved", resolved_at: Time.now)
    assert_equal 0, Ask::SolidErrors.unresolved.size
  end

  def test_by_class_returns_empty_for_unknown_class
    create_error(exception_class: "RuntimeError", message: "some error")
    assert_equal 0, Ask::SolidErrors.by_class("NoSuchError").size
  end

  def test_search_returns_empty_for_no_match
    create_error(exception_class: "RuntimeError", message: "some error")
    assert_equal 0, Ask::SolidErrors.search("nonexistent").size
  end

  def test_occurrence_count_returns_zero_when_no_occurrences
    error = create_error(exception_class: "RuntimeError", message: "no occurrences")
    assert_equal 0, Ask::SolidErrors.occurrence_count(error)
  end

  # --- safety checks ---

  def test_ensure_solid_errors_loaded_does_not_raise
    Ask::SolidErrors.ensure_solid_errors_loaded!
    assert true
  end
end
