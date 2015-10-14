module Koine
  module EventManager
    class EventManager
      def initialize
        @internal_listener = EventListener.new
      end

      def listen_to(event, &block)
        @internal_listener.listen_to(event, &block)
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
          listener.trigger(event)
        end
      end

      def listeners
        @listners ||= []
      end
    end
  end
end
