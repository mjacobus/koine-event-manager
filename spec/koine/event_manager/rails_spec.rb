# frozen_string_literal: true

require 'spec_helper'
require 'koine/event_manager/rails'

RSpec.describe Koine::EventManager::TransactionalEventManager do
  subject(:manager) { described_class.new }

  let(:deferred) { [] }

  before do
    captured = deferred
    fake = Module.new
    fake.define_singleton_method(:after_all_transactions_commit) do |&block|
      captured << block
    end
    stub_const('ActiveRecord', fake)
  end

  it 'defers dispatch until the transaction commits' do
    received = []
    manager.listen_to(SayHello) { |event| received << event.name }

    manager.trigger(SayHello.new([], 'Joe'))
    expect(received).to be_empty

    deferred.each(&:call)
    expect(received).to eq ['Joe']
  end

  it 'raises a clear error when ActiveRecord is unavailable' do
    hide_const('ActiveRecord')

    expect { manager.trigger(SayHello.new([], 'Joe')) }
      .to raise_error(LoadError, /ActiveRecord/)
  end

  describe 'per-subscriber timing' do
    let(:recording_subscriber) do
      Class.new do
        attr_reader :received

        def initialize
          @received = []
        end

        def publish(event)
          @received << event.name
        end
      end.new
    end

    let(:failing_subscriber) do
      Class.new do
        def publish(_event)
          raise 'boom'
        end
      end.new
    end

    it 'dispatches after_commit: false subscribers synchronously, in-transaction' do
      manager.subscribe(recording_subscriber, to: SayHello, after_commit: false)

      manager.trigger(SayHello.new([], 'Joe'))

      # Ran inline, without any deferred block having to fire.
      expect(recording_subscriber.received).to eq ['Joe']
    end

    it 'defers subscribers by default' do
      manager.subscribe(recording_subscriber, to: SayHello)

      manager.trigger(SayHello.new([], 'Joe'))
      expect(recording_subscriber.received).to be_empty

      deferred.each(&:call)
      expect(recording_subscriber.received).to eq ['Joe']
    end

    it 'propagates synchronous subscriber errors so they can abort the transaction' do
      isolated = described_class.new(on_error: ->(*) {})
      isolated.subscribe(failing_subscriber, to: SayHello, after_commit: false)

      expect { isolated.trigger(SayHello.new([], 'x')) }.to raise_error('boom')
    end

    it 'isolates deferred subscriber errors via on_error' do
      errors = []
      isolated = described_class.new(on_error: ->(error, **) { errors << error })
      isolated.subscribe(failing_subscriber, to: SayHello)

      isolated.trigger(SayHello.new([], 'x'))
      deferred.each(&:call)

      expect(errors.first.message).to eq 'boom'
    end
  end
end
