# frozen_string_literal: true

if ENV['COVERALLS']
  require 'coveralls'
  Coveralls.wear!
end

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'bundler/setup'
require 'koine/event_manager'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

SayHello = Struct.new(:output, :name)
SayGoodBye = Struct.new(:output, :name)
SayHelloAgain = Class.new(SayHello)

class HelloSubscriber
  def publish(event)
    event.output << "Hello #{event.name} from #{self.class}"
  end
end
