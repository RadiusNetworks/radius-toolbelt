# Main hook for loading various Rake tasks
require 'rake'
require_relative 'release_helpers'
require_relative 'xcode_helpers'
require_relative 'release_repo'
require_relative 'release_github'

task :git_clean_tree do

  unless system("git diff-files --quiet --ignore-submodules --")
    fail "Error: There are unstaged changes in the working tree. You are trying to run a task that requires a clean git working tree"
  end

  unless system("git diff-index --cached --quiet HEAD --ignore-submodules --")
    fail "Error: Uncommitted changes in the index. You are trying to run a task that requires a clean git working tree"
  end

end

task :git_version_tag => :git_clean_tree do

  unless `git describe --exact-match --tags HEAD`.chomp.include?(agvtool_version)
    fail "Error: The current git HEAD does not have a tag that matches \"#{agvtool_version}\". You are trying to run a task that requires a matching tag on the current git ref."
  end

end

