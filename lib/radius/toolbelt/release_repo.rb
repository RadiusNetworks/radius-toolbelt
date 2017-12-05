require 'fileutils'

module Radius
  module Toolbelt

    class ReleaseRepo
      include Rake::DSL

      attr_reader :repo, :ver, :dir, :files
      def initialize(repo, ver, dir, files)
        @repo = repo
        @dir = dir
        @ver = ver
        @files = files
      end

      def run
        puts "Releasing to repo in #{dir}"
        checkout
        copy
        tag_commit_push
      end

      private

      def checkout
        if File.exists? "#{dir}/.git"
          FileUtils.chdir dir do
            sh "git checkout master --quiet"
            sh "git reset --hard origin/master"
          end
        else
          system "git clone --depth 1 git@github.com:#{repo}.git #{dir}"
        end
      end

      def copy
        files.each do |src|
          dest = File.join dir, File.basename(src)
          FileUtils.copy_entry(src, dest, false, false, true)
        end
      end

      def tag_commit_push
        FileUtils.chdir dir do
          sh "git add ."
          sh "git commit -m 'Version #{ver}'"
          sh "git tag --force v#{ver}"
          sh "git push --force origin v#{ver}"
        end
      end
    end

  end
end
