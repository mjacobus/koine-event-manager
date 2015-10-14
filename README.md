# Koine::EventManager

Event manager for ruby.

[![Build Status](https://travis-ci.org/mjacobus/koine-event-manager.svg)](https://travis-ci.org/mjacobus/koine-event-manager)
[![Code Coverage](https://scrutinizer-ci.com/g/mjacobus/koine-event-manager/badges/coverage.png?b=master)](https://scrutinizer-ci.com/g/mjacobus/koine-event-manager/?branch=master)
[![Code Climate](https://codeclimate.com/github/mjacobus/koine-event-manager/badges/gpa.svg)](https://codeclimate.com/github/mjacobus/koine-event-manager)
[![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/mjacobus/koine-event-manager/badges/quality-score.png?b=master)](https://scrutinizer-ci.com/g/mjacobus/koine-event-manager/?branch=master)
[![Dependency Status](https://gemnasium.com/mjacobus/koine-event-manager.svg)](https://gemnasium.com/mjacobus/koine-event-manager)
[![Gem Version](https://badge.fury.io/rb/koine-event_manager.svg)](https://badge.fury.io/rb/koine-event_manager)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'koine-event_manager'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install koine-event_manager

## Usage

Here follows a simple example

```ruby
event_manager = Koine::EventManager::EventManager.new

event_manager.listen_to(UserSignedIn) do |event|
  WelcomeEmail.new(event.user).send
end
```

In your controller, or service:

```ruby
class UserController < ApplicationController
  def create
    @user = User.create(user_params)

    event_manager.trigger(UserSignedIn.new(@user))

    respond_with(@user)
  end
end
```

You can also create event listeners:

```ruby
class UserListener < Koine::EventManager::EventListener
  def initializer
    listen_to(UserSignedIn) do |event|
      WelcomeEmail.new(event.user).send
    end

    listen_to(UserRemovedAccount) do |event|
      PleaseComeBackEmail.new(event.user).send
    end
  end
end
```

And attach to the event manager:

```ruby
event_manager = Koine::EventManager::EventManager.new
event_manager.attach_listener(UserListener.new)

# and of course later, you can detach listeners, if you want
event_manager.detach_listener(event_manager.listeners.last)
```

And trigger the event on the event manager

```ruby
event_manager.trigger(UserSignedIn.new(some_user))
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mjacobus/koine-event-manager. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

