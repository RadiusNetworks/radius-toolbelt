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
      # @param options [#to_hash, #to_h, #__hash__] manual options to set
      def initialize(options = nil)
        @manual_options = as_hash(options)
        @options = combine_options
      end

      # @return [OpenStruct] the merged options; loaded from all sources
      attr_reader :options

      # @private
      attr_reader :manual_options
      private :manual_options

    private

      def combine_options
        OpenStruct.new(file_options.merge(manual_options))
      end

      # Commander's options are a faux-struct, faux-hash, faux-OpenStruct.
      #
      # It really wants to _be_ an OpenStruct, it's just an incomplete
      # implementation.  It dates back to 2009 and does not follow many modern
      # Ruby conventions.  More specifically, it does not implement
      # `respond_to_missing`, does not properly delegate `method_missing` up
      # the call chain, and refrains from implementing standard hash conversion
      # methods such as `to_h` and `to_hash`.
      #
      # Instead of spending time fixing the Command gem we just implement out
      # own wrapper to get a proper hash.
      def as_hash(options)
        if options.respond_to?(:to_hash)
          options.to_hash
        elsif options.respond_to?(:to_h)
          options.to_h
        elsif options.respond_to?(:__hash__)    # Commander gem
          options.__hash__
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
