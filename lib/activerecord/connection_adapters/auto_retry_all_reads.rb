# frozen_string_literal: true
module ActiveRecord
  module ConnectionAdapters
    module AutoRetryAllReads
      def raw_execute(sql, *args, **kwargs)
        kwargs[:allow_retry] = true if !write_query?(sql)
        super(sql, *args, **kwargs)
      end
    end

    ActiveSupport.on_load(:active_record) do
      DatabaseStatements.prepend(AutoRetryAllReads)
    end
  end
end
