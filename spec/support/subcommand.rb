require 'open3'

module Radius
  module RSpec
    module Processes
      def subcommand(*args)
        Subcommand.new(*args).run
      end

      class Subcommand
        TERMINAL_COLORS = /\e\[\d+m/

        attr_reader :raw_stdout, :raw_stderr, :status, :command

        def initialize(*args)
          raise 'Command cannot be empty' if args.empty?

          # Helpfully handle when the command is an array
          args.unshift(*args.shift) if Array === args.first

          @command = args
          @raw_stdout = ''
          @raw_stderr = ''
          @status = nil
        end

        def failure?
          !success?
        end

        def run
          @raw_stdout, @raw_stderr, @status = Open3.capture3(*command)
          self
        end

        def stderr
          raw_stderr.gsub(TERMINAL_COLORS, '')
        end

        def stdout
          raw_stdout.gsub(TERMINAL_COLORS, '')
        end

        def success?
          status == 0
        end
        alias_method :successful?, :success?
      end
    end
  end
end

RSpec.configure do |c|
  c.include Radius::RSpec::Processes, type: :feature
end
