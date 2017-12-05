require 'fileutils'

module Radius
  module Toolbelt
    module ReleaseHelpers
      def validate_clean_git!
        fail "There are uncommitted changes in git" unless system("git diff-files --quiet")
      end

      def validate_version_for_repo!(repo)
        ver = `cd #{repo} && agvtool what-version -terse`.chomp
        puts "Validating matching version for #{repo}: #{ver}"
        fail "Versions do not match (version file: #{ver} #{repo} version: #{sanitized_version}" unless (ver == sanitized_version)
      end

      def current_version
        @current_version ||= File.read("VERSION").chomp
      end

      def sanitized_version
        @sanitized_version ||= /([0-9\.]+)/.match(current_version)[0]
      end

      def tag_version(ver)
        unless system("git tag v#{ver}")
          fail "Error: the tag v#{ver} already exists on this repo."
        end
      end

      def replace(src, dest)
        FileUtils.copy_entry(src, dest, false, false, true)
      end

      def github_token
        @token ||= ENV["GITHUB_TOKEN"] || YAML.load(`cat ~/.config/hub`)["github.com"].first["oauth_token"]
      end

      def clean(dir)
        rm_rf Dir.glob("#{dir}/*.framework")
        rm_rf Dir.glob("#{dir}/*.zip")
      end

      # Clone down the `repo`, copy all the `file` over then commit, tag and push
      # it up to the origin.
      #
      # `files` is an array of files to copy into the root of the local repo.
      def release_repo(repo, version, dir, files)
        dir = File.join "build", File.basename(repo)
        r = ReleaseRepo.new repo, version, dir, files
        r.run
      end


      def release_github(repo, release_name, version, files, &block)
        tag_name = "v#{version}"
        body = <<EOF
Bug Fixes:

 - TODO: Describe any bug fixes

Enhancements:

 - TODO: Describe any new features or enhancements

Deprecations:

 - TODO: Describe any deprecations
EOF
        token = github_token

        r = ReleaseGithub.new repo, token, tag_name, release_name, body, files
        r.run(&block)
      end

    end
  end
end
