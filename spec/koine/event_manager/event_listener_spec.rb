# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::EventManager::EventListener do
  subject(:listener) { described_class.new }

  let(:output) { [] }
  let(:event) { SayHelloAgain.new(output, 'John Doe') }

  before do
    # proc example
    callback = proc do |event|
      event.output << "hello #{event.name}"
    end

    listener.listen_to(SayHello, &callback)

    # subclass as string
    listener.listen_to('SayHelloAgain') do |e|
      output << "hello again #{e.name}"
    end

    listener.listen_to('SayGoodBye') do |e|
      event.output << "bye #{e.name}"
    end
  end

  describe '#listen_to' do
    it 'raises exception if block was not given' do
      expect { listener.listen_to('foo') }.to raise_error ArgumentError
    end
  end

  describe '#trigger' do
    it 'triggers for events and their' do
      listener.trigger(event)

      expect(output).to eq(['hello John Doe', 'hello again John Doe'])
    end
  end
end
