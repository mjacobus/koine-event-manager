# frozen_string_literal: true

module Koine
  module EventManager
    class EventListener
      def initialize
        @listeners = {}
      end

      def listen_to(event_type, &block)
        raise ArgumentError, 'block not given' unless block_given?
        add_listener(event_type, &block)
      end

      def trigger(event_object)
        listeners_for(event_object.class).each do |block|
          block.call(event_object)
        end
      end

      def listeners_for(event_type)
        listeners.select do |class_or_object, _collection|
          event_type.ancestors.map(&:to_s).include?(class_or_object.to_s)
        end.values.flatten
      end

      private

      def add_listener(event_type, &block)
        listeners[event_type.to_s] ||= []
        listeners[event_type.to_s] << block
      end

      def key_for(object_or_class)
        object_or_class.to_s
      end

      attr_reader :listeners
    end
  end
end
