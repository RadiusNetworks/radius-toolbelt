require 'ostruct'
require 'yaml'

module Radius
  module Toolbelt
    # Responsible for loading external configuration options.
    #
    # Configuration options are loaded from `~/.radius-toolbelt`,
    # `.radius-toolbelt`, `.radius-toolbelt-local`, and the provided manual
    # options (listed in lowest to highest precedence). For example, an option
    # in `~/.radius-toolbelt` can be overridden by an option in
    # `.radius-toolbelt`, which can be overwritten by the provided options.
    class Configuration
      # Create a configuration for the environment.
      #
      # Loads external configuration options from files. If the options hash
      # contains the either key `:config` or `'config'` that file will be
      # used instead of any of the system files.
      #
      # @param options [#to_hash, #to_h] manual options to set
      def initialize(options = nil)
        @required_options = Array.new
        @manual_options = as_hash(options)
        @options = combine_options
      end

      # @return [OpenStruct] the merged options; loaded from all sources
      attr_reader :options

      # @param [Array, String, Symbol] List of options that should be set
      def require_options(*opts)
        self.required_options = opts.flatten.map(&:to_sym)
      end

      # @return [nil, Array<Symbol>]
      #         Options that should be set but are not
      def missing_options
        missing = required_options - options.to_h.keys
        missing.empty? ? nil : missing
      end

      # @private
      attr_reader :manual_options
      private :manual_options

      # @private
      attr_accessor :required_options
      private :required_options, :required_options=

    private

      def combine_options
        OpenStruct.new(file_options.merge(manual_options))
      end

      def as_hash(options)
        if options.respond_to?(:to_hash)
          options.to_hash
        elsif options.respond_to?(:to_h)
          options.to_h
        else
          raise ArgumentError,
                "Cannot convert options into hash: #{options.inspect}"
        end
      end

      def file_options
        if custom_options_file
          custom_options
        else
          [
            global_options,
            project_options,
            local_options,
          ].map(&:to_h).reduce(:merge)
        end
      end

      def custom_options
        options_from(custom_options_file)
      end

      def local_options
        @local_options ||= options_from(local_options_file)
      end

      def project_options
        @project_options ||= options_from(project_options_file)
      end

      def global_options
        @global_options ||= options_from(global_options_file)
      end

      def options_from(path)
        return nil unless path && File.exist?(path)
        YAML.safe_load(File.read(path))
      end

      def custom_options_file
        manual_options[:config] || manual_options['config']
      end

      def project_options_file
        '.radius-toolbelt'
      end

      def local_options_file
        '.radius-toolbelt-local'
      end

      def global_options_file
        File.join(File.expand_path('~'), '.radius-toolbelt')
      rescue ArgumentError
        warn 'Unable to find ~/.radius-toolbelt because the HOME environment variable is not set'
        nil
      end
    end
  end
end
