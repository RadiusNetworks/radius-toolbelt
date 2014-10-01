require 'pathname'
require 'tempfile'
require 'tmpdir'
require_relative 'using_env'

module Radius
  module RSpec
    module Helpers

      def in_tmpdir(*args, &block)
        Dir.mktmpdir(*args) do |tmpdir|
          Dir.chdir(tmpdir) do |path|
            block.call(Pathname(path))
          end
        end
      end

      def using_tmphome(*args, &block)
        Dir.mktmpdir(*args) do |home_dir|
          using_env('HOME' => home_dir) do
            block.call(Pathname(home_dir))
          end
        end
      end

      def using_tempfile(*args, data: nil, &block)
        args << 'tmpfile' if args.empty?
        Tempfile.create(*args) do |f|
          f.write(data)
          f.close
          block.call(Pathname(f.path))
        end
      end

    end
  end
end

RSpec.configure do |config|
  config.include Radius::RSpec::Helpers
end
