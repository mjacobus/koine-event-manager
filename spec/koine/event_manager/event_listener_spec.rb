# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::EventManager::EventListener do
  subject(:listener) { described_class.new }

  describe '#listen_to' do
    it 'adds listeners' do
      listener.listen_to(SayHello) do
      end

      listener.listen_to('SayHello') do
      end

      listener.listen_to(SayGoodBye) do
      end

      expect(listener.listeners_for(SayHello).length).to be 2
      expect(listener.listeners_for('SayHello').length).to be 2
      expect(listener.listeners_for(SayGoodBye).length).to be 1
      expect(listener.listeners_for('SayGoodBye').length).to be 1
    end

    it 'accepts procs as callbacks' do
      callback = proc do |event|
        event.output << "hello #{event.name}"
      end

      listener.listen_to(SayHello, &callback)

      output = []
      listener.trigger(SayHello.new(output, 'foo'))
      expect(output).to eq ['hello foo']
    end

    it 'raises exception if block was not given' do
      expect { listener.listen_to('foo') }.to raise_error ArgumentError
    end
  end

  describe '#trigger' do
    it 'triggers events of a given type' do
      output = []
      event1 = SayHello.new(output, 'foo')
      event2 = SayHello.new(output, 'bar')

      listener.listen_to(SayHello) do |event|
        event.output << "hello #{event.name}"
      end

      listener.listen_to('SayGoodBye') do |event|
        event.output << "bye #{event.name}"
      end

      listener.trigger(event1)
      listener.trigger(event2)

      expect(output).to eq [
        'hello foo',
        'hello bar',
      ]
    end
  end

  describe '#key_for' do
    it 'retuns the string representation of a class or string or object' do
      expect(listener.send(:key_for, SayHello)).to eq 'SayHello'
      expect(listener.send(:key_for, 'SayHello')).to eq 'SayHello'
    end
  end
end
