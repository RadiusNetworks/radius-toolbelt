# Radius::Toolbelt

Radius Networks' collection of CLI tools and Rake tasks for common activities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'radius-toolbelt', github: 'RadiusNetworks/radius-toolbelt'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
# Download or clone the project from GitHub:
$ git clone git@github.com:RadiusNetworks/radius-toolbelt.git
$ cd radius-toolbelt
$ rake install
```

### Rake

Some of these tools come with handy [Rake](https://github.com/jimweirich/rake)
equivalents. To use these tasks add the following to your `Rakefile`:

```ruby
require 'radius/toolbelt/tasks'
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/radius-toolbelt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
