# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "active_record"
require "active_support"
require "active_support/core_ext"

# Set up an in-memory SQLite database.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Create SolidErrors schema tables.
ActiveRecord::Schema.define do
  create_table "solid_errors", force: :cascade do |t|
    t.text "exception_class", null: false
    t.text "message", null: false
    t.text "severity", null: false
    t.text "source"
    t.datetime "resolved_at"
    t.string "fingerprint", limit: 64, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fingerprint"], name: "index_solid_errors_on_fingerprint", unique: true
    t.index ["resolved_at"], name: "index_solid_errors_on_resolved_at"
  end

  create_table "solid_errors_occurrences", force: :cascade do |t|
    t.integer "error_id", null: false
    t.text "backtrace"
    t.json "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["error_id"], name: "index_solid_errors_occurrences_on_error_id"
  end
end

# Test models that mirror SolidErrors::Record, Error, and Occurrence.
module SolidErrors
  class Record < ActiveRecord::Base
    self.abstract_class = true
  end

  class Error < Record
    self.table_name = "solid_errors"

    has_many :occurrences, class_name: "SolidErrors::Occurrence", dependent: :destroy

    validates :exception_class, presence: true
    validates :message, presence: true
    validates :severity, presence: true

    scope :resolved, -> { where.not(resolved_at: nil) }
    scope :unresolved, -> { where(resolved_at: nil) }

    def resolved?
      resolved_at.present?
    end

    def status
      resolved? ? :resolved : :unresolved
    end
  end

  class Occurrence < Record
    self.table_name = "solid_errors_occurrences"

    belongs_to :error, class_name: "SolidErrors::Error"

    def parsed_backtrace
      return [] if backtrace.blank?
      backtrace.split("\n").map do |line|
        parts = line.split(":")
        { file: parts[0], number: parts[1]&.to_i, method: parts[2..]&.join(":") }
      end
    end
  end
end

require "minitest/autorun"
require "mocha/minitest"

require "ask-solid_errors"
