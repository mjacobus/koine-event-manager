# frozen_string_literal: true

require 'spec_helper'

require 'koine/event_manager/event_manager_aware'

RSpec.describe Koine::EventManager::EventManagerAware do
  it 'makes a class aware of singleton instance of EventManager' do
    klass = Class.new do
      include Koine::EventManager::EventManagerAware
    end

    instance = Koine::EventManager::EventManager.instance

    expect(klass.new.event_manager).to be instance
  end
end
