# frozen_string_literal: true

module Koine
  module EventManager
    class EventManager
      def initialize(on_error: nil)
        @on_error = on_error
        @internal_listener = EventListener.new(on_error: on_error)
      end

      def publish(event)
        trigger(event)
      end

      def listen_to(event, &block)
        @internal_listener.listen_to(event, &block)
      end

      def subscribe(subscriber, to:)
        @internal_listener.subscribe(subscriber, to: to)
      end

      def unsubscribe(subscriber, from:)
        @internal_listener.unsubscribe(subscriber, from: from)
      end

      def attach_listener(listener)
        listeners << listener
      end

      def detach_listener(listener)
        listeners.delete(listener)
      end

      def trigger(event)
        @internal_listener.trigger(event)

        listeners.each do |listener|
          dispatch(event, listener) { listener.trigger(event) }
        end
      end

      def listeners
        @listeners ||= []
      end

      private

      def dispatch(event, listener)
        yield
      rescue StandardError => e
        raise if @on_error.nil?

        @on_error.call(e, event: event, listener: listener)
      end
    end
  end
end
