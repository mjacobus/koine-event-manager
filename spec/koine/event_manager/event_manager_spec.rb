require "spec_helper"

SayHello = Struct.new(:output, :name)
SayGoodBye = Class.new(SayHello)

describe Koine::EventManager::EventManager do
  subject { Koine::EventManager::EventManager.new }

  describe "#attach_listener" do
    it "appends a listener to the list" do
      listener = Koine::EventManager::EventManager.new
      subject.attach_listener(listener)

      subject.listeners.length.must_equal 1
    end
  end

  describe "#detach_listener" do
    it "removes a listener from the list" do
      listener1 = Koine::EventManager::EventManager.new
      listener2 = Koine::EventManager::EventManager.new
      subject.attach_listener(listener1)
      subject.attach_listener(listener2)

      subject.detach_listener(listener2)
      subject.listeners.must_equal [listener1]
    end
  end

  describe "#trigger" do
    it "triggers event" do
      event = Minitest::Mock.new

      listener = Minitest::Mock.new
      listener.expect(:trigger, nil, [event])

      subject.attach_listener(listener)

      subject.trigger(event)

      listener.verify
    end
  end

  it "listends to events along with listeners" do
    listener = Koine::EventManager::EventListener.new
    subject.attach_listener(listener)

    subject.listen_to(SayHello) do |event|
      event.output << "hello from event manager #{event.name}"
    end

    listener.listen_to(SayHello) do |event|
      event.output << "hello from listener #{event.name}"
    end

    output = []
    event = SayHello.new(output, "bar")
    subject.trigger(event)

    output.must_equal [
      "hello from event manager bar",
      "hello from listener bar",
    ]
  end

  describe ".instance" do
    it "returns a sigleton instance of manager" do
      klass = Koine::EventManager::EventManager
      instance = klass.instance
      instance.must_be_instance_of(klass)
      klass.instance.must_be_same_as(instance)
    end
  end
end
