require 'fileutils'

module Radius
  module Toolbelt
    module XcodeHelpers

      def self.included klass
        klass.class_eval do
          include ReleaseHelpers
        end
      end

      def compress(src, dest)
        system "ditto -ck --rsrc --sequesterRsrc --keepParent #{src} #{dest}"
      end

      def xcode(action, params)
        system "xcodebuild #{params.map {|k,v| "-#{k} #{v}"}.join ' '} #{action} | xcpretty"
      end

      def agvtool_version
        @agvtool_version ||= `xcrun agvtool what-version -terse`.chomp
      end

    end
  end
end
