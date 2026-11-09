Nova::API
========
[![Circle Build Status](https://circleci.com/gh/coyosoftware/nova-api.png?style=shield)](https://circleci.com/gh/coyosoftware/nova-api)
[![Maintainability](https://api.codeclimate.com/v1/badges/4592d8beaac2e6a18839/maintainability)](https://codeclimate.com/github/coyosoftware/nova-api/maintainability)
[![Gem Version](https://badge.fury.io/rb/nova-api.svg)](http://badge.fury.io/rb/nova-api)
[![Downloads](https://img.shields.io/gem/dt/nova-api.svg?style=flat)](https://rubygems.org/gems/nova-api)

# Introduction

Gem to consume the [Nova.Money API](https://app.swaggerhub.com/apis-docs/coyosoftware/Nova.Money/v1)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nova-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nova-api

## Usage

First set your credentials and subdomain using the ```configure``` method of the ```Nova::API``` class:

```ruby
Nova::API.configure do |config|
  config.api_key = 'your-api-key'
  config.subdomain = 'your-subdomain'
end
```

Calling ```configure``` on the main thread, as an initializer does at boot, sets the configuration for the whole process. Calling it on any other thread, such as a Puma request thread, only affects that thread.

Web servers reuse their threads, so anything set with ```configure``` during a request is still there for the next request served by that thread. For multi-tenant applications, prefer ```with_configuration```, which only applies during the block:

```ruby
around_action do |_controller, action|
  Nova::API.with_configuration(subdomain: current_tenant.subdomain, api_key: current_tenant.api_key) { action.call }
end
```

After that you can start using the resources either by:

- Instantiating a new ```Nova::API::Client``` object;

or

- Using directly the available resource class (check the resources under [api/resource](lib/nova/api/resource) folder)

To know the operations that are supported by a resource, please check the resource source code under the [api/resource](lib/nova/api/resource) folder.

### Querying

For most of the query methods, you can pass either a Hash with the parameters described in the API documentation or, if you prefer an object oriented way, you can use the [SearchParams classes](lib/nova/api/search_params), that offer the same functionality but as an object.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/coyosoftware/nova-api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
