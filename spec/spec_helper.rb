$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

if ENV["COVERALLS"]
  require "coveralls"
  Coveralls.wear!
end

if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/spec/"
  end
end

if ENV["SCRUTINIZER"]
  require "scrutinizer/ocular"
  Scrutinizer::Ocular.watch!
end

require "koine/event_manager"
require "minitest/autorun"
