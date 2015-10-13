module Koine
  module EventManager
    class EventListener
      def listen_to(event_name, &block)
        listeners_for(event_name) << block
      end

      def trigger(event_object)
        listeners_for(event_object.class).each do |block|
          block.call(event_object)
        end
      end

      def listeners_for(event)
        listeners[key_for(event)] ||= []
      end

      private

      def key_for(object_or_class)
        object_or_class.to_s
      end

      def listeners
        @listeners ||= {}
      end
    end
  end
end
