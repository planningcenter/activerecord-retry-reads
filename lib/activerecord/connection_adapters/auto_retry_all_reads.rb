# frozen_string_literal: true
module ActiveRecord
  module ConnectionAdapters
    module AutoRetryAllReads
      def raw_execute(sql, name, **kwargs)
        kwargs[:allow_retry] = true if !write_query?(sql)
        super(sql, name, **kwargs)
      end
    end

    ActiveSupport.on_load(:active_record_mysql2adapter) do
      Mysql2::DatabaseStatements.prepend(AutoRetryAllReads)
    end
    ActiveSupport.on_load(:active_record_postgresqladapter) do
      PostgreSQL::DatabaseStatements.prepend(AutoRetryAllReads)
    end
    ActiveSupport.on_load(:active_record_sqlite3adapter) do
      SQLite3::DatabaseStatements.prepend(AutoRetryAllReads)
    end
    ActiveSupport.on_load(:active_record_trilogyadapter) do
      Trilogy::DatabaseStatements.prepend(AutoRetryAllReads)
    end
  end
end
