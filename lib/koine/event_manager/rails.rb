# frozen_string_literal: true

require 'koine/event_manager'

module Koine
  module EventManager
    # Dispatches listeners after the current DB transaction commits (or runs
    # immediately when none is open), so they never react to changes a rollback
    # would undo. Requires ActiveRecord >= 7.2.
    #
    # Individual subscribers/listeners may opt into synchronous, in-transaction
    # dispatch with `after_commit: false`. Those run inline and their errors
    # propagate (bypassing `on_error` isolation), so an integrity reaction can
    # abort the surrounding transaction. Post-commit listeners stay isolated.
    class TransactionalEventManager < EventManager
      alias deferred_dispatch trigger

      def initialize(on_error: nil)
        super
        # In-transaction listeners: no on_error isolation, so a failure propagates
        # and can roll the surrounding transaction back.
        @synchronous = EventListener.new
      end

      def subscribe(subscriber, to:, after_commit: true)
        return @synchronous.subscribe(subscriber, to: to) unless after_commit

        super(subscriber, to: to)
      end

      def listen_to(event, after_commit: true, &block)
        return @synchronous.listen_to(event, &block) unless after_commit

        super(event, &block)
      end

      def unsubscribe(subscriber, from:)
        @synchronous.unsubscribe(subscriber, from: from)
        super
      end

      def trigger(event)
        @synchronous.trigger(event)

        unless active_record_available?
          raise LoadError, 'TransactionalEventManager requires ActiveRecord >= 7.2 ' \
                           '(after_all_transactions_commit). Load Rails before using it.'
        end

        ::ActiveRecord.after_all_transactions_commit do
          deferred_dispatch(event)
        end
      end

      private :deferred_dispatch

      private

      def active_record_available?
        defined?(::ActiveRecord) &&
          ::ActiveRecord.respond_to?(:after_all_transactions_commit)
      end
    end
  end
end
