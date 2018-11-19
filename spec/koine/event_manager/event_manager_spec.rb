# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::EventManager::EventManager do
  subject(:manager) { described_class.new }

  describe '#attach_listener' do
    it 'appends a listener to the list' do
      listener = described_class.new
      manager.attach_listener(listener)

      expect(manager.listeners.length).to eq 1
    end
  end

  describe '#detach_listener' do
    it 'removes a listener from the list' do
      listener1 = described_class.new
      listener2 = described_class.new
      manager.attach_listener(listener1)
      manager.attach_listener(listener2)

      manager.detach_listener(listener2)
      expect(manager.listeners).to eq [listener1]
    end
  end

  describe '#trigger' do
    it 'triggers event' do
      event = 'some-event'

      listener = instance_double(Koine::EventManager::EventListener)
      allow(listener).to receive(:trigger)

      manager.attach_listener(listener)

      manager.trigger(event)

      expect(listener).to have_received(:trigger).with(event)
    end
  end

  it 'listends to events along with listeners' do
    listener = Koine::EventManager::EventListener.new
    manager.attach_listener(listener)

    manager.listen_to(SayHello) do |event|
      event.output << "hello from event manager #{event.name}"
    end

    listener.listen_to(SayHello) do |event|
      event.output << "hello from listener #{event.name}"
    end

    output = []
    event = SayHello.new(output, 'bar')
    manager.trigger(event)

    expect(output).to eq [
      'hello from event manager bar',
      'hello from listener bar',
    ]
  end

  describe '.instance' do
    it 'returns a sigleton instance of manager' do
      klass = described_class
      instance = klass.instance
      expect(instance).to be_a(klass)
      expect(klass.instance).to be(instance)
    end
  end
end
