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
end
