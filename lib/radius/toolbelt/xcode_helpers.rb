require 'fileutils'

module Radius
  module Toolbelt
    module XcodeHelpers

      def self.included klass
        klass.class_eval do
          include ReleaseHelpers
          include SlackHelpers
        end
      end

      def compress(src, dest)
        sh "ditto -ck --rsrc --sequesterRsrc --keepParent #{src} #{dest}"
      end

      def xcodebuild(args, pretty=true)
        output_dir = File.expand_path("./build")
        cmd = "xcodebuild #{args} UNIVERSAL_OUTPUT_DIR=#{output_dir} CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' #{ "| ./bin/xcpretty" if pretty }"
        puts cmd
        sh cmd
      end

      def schemes
        schemes = `xcodebuild -workspace Monsters.xcworkspace -list`
        schemes.each_line.map { |l| l.strip if l[/^        /]}.compact
      end

      def agvtool(repo = ".")
        `cd #{repo} && xcrun agvtool what-version -terse`.strip
      end


      def appledoc(name, framework, repo)
          sh <<-EOF
            ./bin/appledoc \
              --output "build/#{framework}Docs" \
              --create-html  \
              --no-create-docset \
              --project-name "#{name}" \
              --project-company "Radius Networks" \
              --project-version #{agvtool repo} \
              --company-id "com.radiusnetworks.#{framework}" \
              --exit-threshold 2 \
              "./build/#{framework}.framework/Headers"
          EOF
      end

      #def xcode(action, params)
      #  system "xcodebuild #{params.map {|k,v| "-#{k} #{v}"}.join ' '} #{action}"
      #end

      #def agvtool_version
      #  @agvtool_version ||= `xcrun agvtool what-version -terse`.chomp
      #end

    end
  end
end
