require 'fileutils'

module Radius
  module Toolbelt
    module ReleaseHelpers

      def tag_version(ver)
        unless system("git tag v#{agvtool_version}")
          fail "Error: the tag v#{agvtool_version} already exists on this repo."
        end
      end

      def replace(src, dest)
        FileUtils.copy_entry(src, dest, false, false, true)
      end

      def github_token
        @token ||= ENV["github_token"] || YAML.load(`cat ~/.config/hub`)["github.com"].first["oauth_token"]
      end

      def clean(dir)
        rm_rf Dir.glob("#{dir}/*.framework")
        rm_rf Dir.glob("#{dir}/*.zip")
      end

      def release_github(repo, release_name, version, files)
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
        r.run
      end

      # Clone down the `repo`, copy all the `file` over then commit, tag and push
      # it up to the origin.
      #
      # `files` is an array of files to copy into the root of the local repo.
      def release_repo(repo, version, files, dir = "build/release-repo")
        r = ReleaseRepo.new repo, version, dir, files
        r.run
      end

    end
  end
end
