require 'commander'

module Radius
  module Toolbelt
    class CLI
      extend Commander::Methods

      program :name, 'radius'
      program :version, Radius::Toolbelt::VERSION
      program :description,
              'Main CLI tool for working with common Radius Network tasks.'
      program :help, 'Copyright', '2014 Radius Networks'

      default_command :help

      global_option '-c', '--config FILE', 'Specify the options file'
    end
  end
end
