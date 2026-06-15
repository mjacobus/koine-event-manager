# frozen_string_literal: true

require 'koine/event_manager'

module Koine
  module EventManager
    # Defers dispatch until the current DB transaction commits (or runs
    # immediately when none is open). Loads ActiveRecord lazily so the core
    # stays dependency-free.
    class TransactionalEventManager < EventManager
      alias dispatch_now trigger

      def trigger(event)
        available = defined?(::ActiveRecord) &&
          ::ActiveRecord.respond_to?(:after_all_transactions_commit)
        unless available
          raise LoadError, 'TransactionalEventManager requires ActiveRecord >= 7.2 ' \
                           '(after_all_transactions_commit). Load Rails before using it.'
        end

        ::ActiveRecord.after_all_transactions_commit do
          dispatch_now(event)
        end
      end

      private :dispatch_now
    end
  end
end
