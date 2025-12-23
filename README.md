# Koine::EventManager

A simple and lightweight event management library for Ruby that enables event-driven architecture through a publish-subscribe pattern.

[![CI](https://github.com/mjacobus/koine-event-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/mjacobus/koine-event-manager/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/mjacobus/koine-event-manager/badge.svg?branch=master)](https://coveralls.io/github/mjacobus/koine-event-manager?branch=master)
[![Code Climate](https://codeclimate.com/github/mjacobus/koine-event-manager/badges/gpa.svg)](https://codeclimate.com/github/mjacobus/koine-event-manager)
[![Gem Version](https://badge.fury.io/rb/koine-event_manager.svg)](https://badge.fury.io/rb/koine-event_manager)

## Features

- **Simple API** - Easy to understand and use
- **Block-based listeners** - Quick inline event handlers
- **Object-based subscribers** - Reusable event handling objects
- **Event inheritance** - Listen to parent event classes and receive child events
- **No dependencies** - Pure Ruby implementation
- **Thread-safe operations** - Safe for concurrent use

## Requirements

- Ruby >= 3.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'koine-event_manager'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install koine-event_manager

## Usage

### Basic Example

```ruby
require 'koine/event_manager'

# Define your event
class UserSignedIn
  attr_reader :user

  def initialize(user)
    @user = user
  end
end

# Create the event manager
event_manager = Koine::EventManager::EventManager.new

# Register a listener
event_manager.listen_to(UserSignedIn) do |event|
  puts "Welcome, #{event.user.name}!"
  WelcomeEmail.new(event.user).send
end

# Trigger the event
user = User.find(123)
event_manager.trigger(UserSignedIn.new(user))
```

### Block-based Listeners

Use block-based listeners for simple, inline event handlers:

```ruby
event_manager = Koine::EventManager::EventManager.new

event_manager.listen_to(UserSignedIn) do |event|
  WelcomeEmail.new(event.user).send
end

event_manager.listen_to(UserRemovedAccount) do |event|
  CleanupJob.perform_later(event.user.id)
end

# Trigger events
event_manager.trigger(UserSignedIn.new(user))
```

**When to use:** Quick, one-off event handlers that don't need to be reused.

### Event Listener Classes

For better organization, create reusable listener classes:

```ruby
class UserListener < Koine::EventManager::EventListener
  def initialize
    super

    listen_to(UserSignedIn) do |event|
      WelcomeEmail.new(event.user).send
    end

    listen_to(UserRemovedAccount) do |event|
      PleaseComeBackEmail.new(event.user).send
    end
  end
end

# Attach the listener to the event manager
event_manager = Koine::EventManager::EventManager.new
event_manager.attach_listener(UserListener.new)

# Trigger events
event_manager.trigger(UserSignedIn.new(some_user))

# Later, you can detach listeners if needed
event_manager.detach_listener(event_manager.listeners.last)
```

**When to use:** Related event handlers that should be grouped together and potentially attached/detached as a unit.

### Subscribers

Subscribers are objects that implement a `publish` method. They provide a more object-oriented approach to event handling:

```ruby
class NotificationSubscriber
  def publish(event)
    case event
    when UserSignedIn
      send_welcome_notification(event.user)
    when UserRemovedAccount
      send_goodbye_notification(event.user)
    end
  end

  private

  def send_welcome_notification(user)
    # Send notification logic
  end

  def send_goodbye_notification(user)
    # Send notification logic
  end
end

# Subscribe to specific events
subscriber = NotificationSubscriber.new
event_manager.subscribe(subscriber, to: UserSignedIn)
event_manager.subscribe(subscriber, to: UserRemovedAccount)

# Trigger events - subscriber.publish(event) will be called
event_manager.trigger(UserSignedIn.new(user))

# Unsubscribe when no longer needed
event_manager.unsubscribe(subscriber, from: UserSignedIn)
```

**When to use:** Complex event handling logic that needs to be encapsulated in a class with state and multiple methods.

### Event Inheritance

The event manager supports event inheritance. If you listen to a parent event class, you'll also receive events from child classes:

```ruby
class UserEvent
  attr_reader :user

  def initialize(user)
    @user = user
  end
end

class UserSignedIn < UserEvent
end

class UserSignedOut < UserEvent
end

# Listen to the parent class
event_manager.listen_to(UserEvent) do |event|
  puts "User event occurred for #{event.user.name}"
end

# Both of these will trigger the listener above
event_manager.trigger(UserSignedIn.new(user))
event_manager.trigger(UserSignedOut.new(user))
```

### Using in Rails

Here's a complete example of how to use the event manager in a Rails application:

```ruby
# app/events/user_signed_in.rb
class UserSignedIn
  attr_reader :user, :ip_address

  def initialize(user, ip_address: nil)
    @user = user
    @ip_address = ip_address
  end
end

# app/listeners/user_listener.rb
class UserListener < Koine::EventManager::EventListener
  def initialize
    super

    listen_to(UserSignedIn) do |event|
      WelcomeMailer.welcome_email(event.user).deliver_later
      TrackingService.track_login(event.user, event.ip_address)
    end
  end
end

# config/initializers/event_manager.rb
Rails.application.config.event_manager = Koine::EventManager::EventManager.new
Rails.application.config.event_manager.attach_listener(UserListener.new)

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def event_manager
    Rails.application.config.event_manager
  end
end

# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    @user = User.find_by(email: params[:email])

    if @user&.authenticate(params[:password])
      session[:user_id] = @user.id
      event_manager.trigger(UserSignedIn.new(@user, ip_address: request.remote_ip))
      redirect_to root_path, notice: 'Signed in successfully'
    else
      render :new, alert: 'Invalid credentials'
    end
  end
end
```

## API Reference

### EventManager

- `listen_to(event_class, &block)` - Register a block to handle events
- `trigger(event)` - Dispatch an event to all listeners and subscribers
- `subscribe(subscriber, to: event_type)` - Add a subscriber for an event type
- `unsubscribe(subscriber, from: event_type)` - Remove a subscriber
- `attach_listener(listener)` - Attach an EventListener instance
- `detach_listener(listener)` - Remove a listener
- `listeners` - Get array of attached listeners

### EventListener

- `listen_to(event_type, &block)` - Register a block handler for an event type
- `subscribe(subscriber, to: event_type)` - Register a subscriber object
- `unsubscribe(subscriber, from: event_type)` - Unregister a subscriber
- `trigger(event_object)` - Process the event through all listeners and subscribers

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Running Tests

```bash
bundle exec rspec
```

### Running Linter

```bash
bundle exec rubocop
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mjacobus/koine-event-manager. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
