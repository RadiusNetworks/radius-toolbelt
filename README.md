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

## Usage

This toolbelt provides a suite of commands. You can see the list of available
commands by running `radius`:

```console
$ radius
  NAME:

    radius

  DESCRIPTION:

    Main CLI tool for working with common Radius Network tasks.

  COMMANDS:

    help                 Display global or [command] help documentation

  GLOBAL OPTIONS:

    -c, --config FILE
        Specify the options file

    -h, --help
        Display help documentation

    -v, --version
        Display version information

    -t, --trace
        Display backtrace when an error occurs

  COPYRIGHT:

    2014 Radius Networks
```

If you need help with a specific command simply pass it the `--help` flag:

```console
$ radius COMMAND --help
```

### Config Files

Configuration options are loaded from `~/.radius-toolbelt`, `.radius-toolbelt`,
`.radius-toolbelt-local`, and the command line switches (listed in lowest to
highest precedence). For example, an option in `~/.radius-toolbelt` can be
overridden by an option in `.radius-toolbelt`, which can be overwritten by the
provided command line flag.

### Rake

Some of these tools come with handy [Rake](https://github.com/jimweirich/rake)
equivalents. To use these tasks add the following to your `Rakefile`:

```ruby
require 'radius/toolbelt/tasks'
```

### Publish Github Release

```console
# From the PROJECT_ROOT directory
$ radius release \
    --org ORG
    --repo REPO
    --target BRANCH
    --tag TAG_VERSION
    --title RELEASE_TITLE
    --no-release-notes
    --[no-]pre
    --binaries FILES...
```

Common settings can be saved in a project's `.radius-release` file:

Settings

- tag
- title
- description
- binaries
- pre-release

```text
--no-source
--org RadiusNetworks
--repo radius-toolbelt
```

This is also available as a Rake task:

```console
$ bin/rake radius:release
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/radius-toolbelt/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
