# Main hook for loading various Rake tasks
require 'rake'
require_relative 'release_helpers'
require_relative 'xcode_helpers'
require_relative 'release_repo'
require_relative 'release_github'

namespace :git do
  task :clean do

    unless system("git diff-files --quiet --ignore-submodules --")
      fail "Error: There are unstaged changes in the working tree. You are trying to run a task that requires a clean git working tree"
    end

    unless system("git diff-index --cached --quiet HEAD --ignore-submodules --")
      fail "Error: Uncommitted changes in the index. You are trying to run a task that requires a clean git working tree"
    end

  end

  task :version_tag do

    unless `git describe --exact-match --tags HEAD`.chomp.include?(agvtool_version)
      fail "Error: The current git HEAD does not have a tag that matches \"#{agvtool_version}\". You are trying to run a task that requires a matching tag on the current git ref."
    end

  end
end

namespace :version do
  desc "Bump the version to the next patch number"
  task :bump do
    sh "agvtool next-version -increment-minor-version"
  end

  desc "Set the version via `rake version:set version=\"1.0.0\""
  task :set, [:version] do |t, args|
    v = args[:version]
    fail "Error: no version specified" unless v

    sh "xcrun agvtool new-version #{v}"
  end
end
