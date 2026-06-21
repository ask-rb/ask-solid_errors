# frozen_string_literal: true

require_relative "test_helper"

class ContextTest < Minitest::Test
  def test_description_is_defined
    assert_match(/SolidErrors/, Ask::SolidErrors::DESCRIPTION)
  end

  def test_gem_name_is_solid_errors
    assert_equal "solid_errors", Ask::SolidErrors::GEM_NAME
  end

  def test_quick_start_is_defined
    assert_includes Ask::SolidErrors::QUICK_START, "Ask::SolidErrors.recent"
    assert_includes Ask::SolidErrors::QUICK_START, "Ask::SolidErrors.find"
  end
end
