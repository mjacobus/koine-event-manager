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

  it 'subscribes/unsubscribes an publisher and triggers only one per subscriber' do
    event = SayHelloAgain.new([], 'John Doe')

    manager.listen_to(SayHello) do |e|
      e.output << "Hi #{e.name} from block"
    end

    subscriber = HelloSubscriber.new
    manager.subscribe(subscriber, to: 'SayHello')
    manager.subscribe(subscriber, to: [SayHelloAgain])
    manager.subscribe(subscriber, to: [SayHelloAgain])
    manager.subscribe(subscriber, to: SayHelloAgain)

    manager.trigger(event)

    manager.unsubscribe(subscriber, from: 'SayHello')

    manager.trigger(event)

    expect(event.output).to eq([
      'Hi John Doe from block',
      'Hello John Doe from HelloSubscriber',
      'Hello John Doe from HelloSubscriber',
      'Hi John Doe from block',
      'Hello John Doe from HelloSubscriber',
    ])
  end
end
