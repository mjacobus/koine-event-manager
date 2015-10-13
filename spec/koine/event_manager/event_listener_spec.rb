require "spec_helper"

SayHello = Struct.new(:output, :name)
SayGoodBye = Class.new(SayHello)

describe Koine::EventManager::EventListener do
  subject { Koine::EventManager::EventListener.new }

  describe "#listen_to" do
    it "adds listeners"do
      subject.listen_to(SayHello) do
      end

      subject.listen_to("SayHello") do
      end

      subject.listen_to(SayGoodBye) do
      end

      subject.listeners_for(SayHello).length.must_equal 2
      subject.listeners_for("SayHello").length.must_equal 2
      subject.listeners_for(SayGoodBye).length.must_equal 1
      subject.listeners_for("SayGoodBye").length.must_equal 1
    end
  end

  describe "#trigger" do
    it "triggers events of a given type" do
      output = []
      event1 = SayHello.new(output, "foo")
      event2 = SayHello.new(output, "bar")

      subject.listen_to(SayHello) do |event|
        event.output << "hello #{event.name}"
      end

      subject.listen_to("SayGoodBye") do |event|
        event.output << "bye #{event.name}"
      end

      subject.trigger(event1)
      subject.trigger(event2)

      output.must_equal [
        "hello foo",
        "hello bar",
      ]
    end
  end

  describe "#key_for" do
    it "retuns the string representation of a class or string or object" do
      subject.send(:key_for, SayHello).must_equal "SayHello"
      subject.send(:key_for, "SayHello").must_equal "SayHello"
    end
  end
end
