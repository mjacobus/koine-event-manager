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
        ::ActiveRecord.after_all_transactions_commit do
          dispatch_now(event)
        end
      end

      private :dispatch_now
    end
  end
end
