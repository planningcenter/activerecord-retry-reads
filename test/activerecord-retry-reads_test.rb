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
    abstract_module = ActiveRecord::ConnectionAdapters::DatabaseStatements
    assert abstract_module.private_instance_methods.include?(:raw_execute)
  end

  def test_mysql2_module_has_methods_we_expect
    mysql2_module = ActiveRecord::ConnectionAdapters::Mysql2::DatabaseStatements
    assert mysql2_module.private_instance_methods.include?(:raw_execute)

    parameters = mysql2_module.instance_method(:raw_execute).parameters
    assert_parameters_are_what_we_expect parameters
  end

  def test_postgresql_module_has_methods_we_expect
    postgresql_module = ActiveRecord::ConnectionAdapters::PostgreSQL::DatabaseStatements
    assert postgresql_module.instance_methods.include?(:raw_execute)

    parameters = postgresql_module.instance_method(:raw_execute).parameters
    assert_parameters_are_what_we_expect parameters
  end

  def test_sqlite3_module_has_methods_we_expect
    sqlite3_module = ActiveRecord::ConnectionAdapters::SQLite3::DatabaseStatements

    parameters = sqlite3_module.instance_method(:raw_execute).parameters
    assert_parameters_are_what_we_expect parameters
  end

  def test_trilogy_module_has_methods_we_expect
    trilogy_module = ActiveRecord::ConnectionAdapters::Trilogy::DatabaseStatements
    assert trilogy_module.private_instance_methods.include?(:raw_execute)

    parameters = trilogy_module.instance_method(:raw_execute).parameters
    assert_parameters_are_what_we_expect parameters
  end

  def assert_parameters_are_what_we_expect(parameters)
    # We pass `sql` to write_query? so we need to make sure that implementation isn't changing
    assert parameters[0] == [:req, :sql]
    assert parameters[1] == [:req, :name]

    # The rest are all optional keywords
    assert parameters[2..-1].all?{|k, v| k == :key }

    # One of them is `allow_retry`
    assert parameters[2..-1].any?{|k, v| v == :allow_retry }
  end
end
