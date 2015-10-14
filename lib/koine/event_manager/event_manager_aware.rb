module Koine
  module EventManager
    module EventManagerAware
      def self.included(klass)
        klass.instance_eval do
          define_method "event_manager" do
            Koine::EventManager::EventManager.instance
          end
        end
      end
    end
  end
end
