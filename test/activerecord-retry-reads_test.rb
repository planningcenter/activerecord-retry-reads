require "minitest/autorun"

# This is the minimum amount of active_record required to load the modules we need
require "active_record"
require "active_record/connection_adapters"
require "active_record/connection_adapters/abstract/database_statements"
require "active_record/connection_adapters/mysql2/database_statements"
require "active_record/connection_adapters/sqlite3/database_statements"
# The postgresql/database_statements module requires these to be defined
# Rather than adding a test dependency on `pg`, just define them
module PG
  PQTRANS_IDLE = nil
  PQTRANS_INTRANS = nil
  PQTRANS_INERROR = nil
end
require "active_record/connection_adapters/postgresql/database_statements"
require "active_record/connection_adapters/trilogy/database_statements"

# If you're looking at this and thinking "This is a _weird_ test to have." You
# are not alone! This gem works by prepending a module which changes the
# behavior of a private instance method. These tests are here in order to help
# identify any changes in ActiveRecord that would potentially break this gem

class TestActiveRecordRetryReads < Minitest::Test
  def test_abstract_module_has_methods_we_expect
    abstract_module = ActiveRecord::ConnectionAdapters::AbstractAdapter
    assert abstract_module.private_instance_methods.include?(:raw_execute)

    parameters = abstract_module.instance_method(:raw_execute).parameters
    assert_parameters_are_what_we_expect parameters
  end

  def test_adapter_modules_does_not_have_methods_we_expect
    mysql2_module = ActiveRecord::ConnectionAdapters::Mysql2::DatabaseStatements
    refute mysql2_module.private_instance_methods.include?(:raw_execute)

    postgresql_module = ActiveRecord::ConnectionAdapters::PostgreSQL::DatabaseStatements
    refute postgresql_module.private_instance_methods.include?(:raw_execute)

    sqlite3_module = ActiveRecord::ConnectionAdapters::SQLite3::DatabaseStatements
    refute sqlite3_module.private_instance_methods.include?(:raw_execute)

    trilogy_module = ActiveRecord::ConnectionAdapters::Trilogy::DatabaseStatements
    refute trilogy_module.private_instance_methods.include?(:raw_execute)
  end

  def assert_parameters_are_what_we_expect(parameters)
    # We pass `sql` to write_query? so we need to make sure that implementation isn't changing
    assert parameters[0] == [:req, :sql]

    # One of them is `allow_retry`
    keyword_args = parameters.select{|k, v| k == :key }
    assert keyword_args.any?{|k, v| v == :allow_retry }
  end
end
