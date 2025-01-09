require "minitest/autorun"
require "active_support"
require "active_record"
require "activerecord-retry-reads"

module ActiveRecord
  module ConnectionAdapters
    module FakeAdapter
      class DatabaseStatements
        def raw_execute(sql, name = nil, binds = [], allow_retry: false)
          # Returning allow_retry just makes the tests here easier
          return allow_retry
        end

        def write_query?(_)
          raise "Stub this out"
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::FakeAdapter::DatabaseStatements.prepend(ActiveRecord::ConnectionAdapters::AutoRetryAllReads)

class TestAutoRetryAllReads < Minitest::Test

  def fake_adapter
    @adapter ||= ActiveRecord::ConnectionAdapters::FakeAdapter::DatabaseStatements.new
  end

  def test_sets_auto_retry_true_when_read_query
    fake_adapter.stub :write_query?, false do
      assert fake_adapter.raw_execute("SELECT *", "Select Test")
    end
  end

  def test_does_not_set_auto_retry_true_when_write_query
    fake_adapter.stub :write_query?, true do
      refute fake_adapter.raw_execute("INSERT INTO", "Insert Test")
    end
  end

  def test_does_not_set_auto_retry_false_when_write_query
    # If something is explicitly setting it to `true`, don't stomp on it.
    fake_adapter.stub :write_query?, true do
      assert fake_adapter.raw_execute("INSERT INTO", "Insert Test with retry", allow_retry: true)
    end
  end
end
