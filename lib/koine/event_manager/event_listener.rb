# frozen_string_literal: true

module Koine
  module EventManager
    class EventListener
      def initialize(on_error: nil)
        @listeners = {}
        @subscribers = {}
        @on_error = on_error
      end

      def listen_to(event_type, &block)
        raise ArgumentError, 'block not given' unless block_given?

        add_listener(event_type, &block)
      end

      def subscribe(subscriber, to:)
        @subscribers[subscriber] ||= []
        @subscribers[subscriber] << to
        @subscribers[subscriber] = @subscribers[subscriber].flatten.map(&:to_s).uniq
      end

      def unsubscribe(subscriber, from:)
        all = Array(subscribers[subscriber])
        filtered = all.reject do |object_type|
          object_type.to_s == from.to_s
        end
        subscribers[subscriber] = filtered
      end

      def trigger(event_object)
        listeners_for(event_object.class).each do |block|
          dispatch(event_object, block) { block.call(event_object) }
        end

        subscribers.each do |subscriber, events|
          events.each do |event|
            if event_object.class.ancestors.map(&:to_s).include?(event.to_s)
              dispatch(event_object, subscriber) { subscriber.publish(event_object) }
            end
          end
        end
      end

      def listeners_for(event_type)
        listeners.select do |class_or_object, _collection|
          event_type.ancestors.map(&:to_s).include?(class_or_object.to_s)
        end.values.flatten
      end

      private

      def dispatch(event, listener)
        yield
      rescue StandardError => e
        raise if @on_error.nil?

        @on_error.call(e, event: event, listener: listener)
      end

      def add_listener(event_type, &block)
        listeners[event_type.to_s] ||= []
        listeners[event_type.to_s] << block
      end

      attr_reader :listeners, :subscribers
    end
  end
end
