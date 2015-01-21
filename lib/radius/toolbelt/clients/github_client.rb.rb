require 'octokit'
require 'tmpdir'

module Radius
  module Toolbelt
    module Clients
      class GithubClient
        attr_reader :client
        private :client

        def initialize(access_token)
          @client = Octokit::Client.new(access_token: access_token)
        end

        def create_release(release)
          repository = Octokit::Repository.new(release.repo)
          gh_release = client.create_release(repository, tag, options)
          release.binaries.each do |file|
            client.upload_asset(gh_release.url, file)
          end
        end

        def commit(message)
          raise ArgumentError, 'Action block required' unless block_given?
          in_tmp_repo do |git_repo|
            yield self
            git_repo.commit_all message
          end
        end

        def new_line
          "\n"
        end

        def prepend_file(file, text)
          return if text.nil? || text.empty?

          Tempfile.create(file) do |new_file|
            new_file.write text
            new_file.write new_line
            tf.puts text

            p tf.path
            tf.puts "this is a test\n----------\n\nmy stuff is here!"
            tf.puts "\n"
            File.copy_stream(log, tf)
            tf.close
            puts File.read(tf.path)
          end
        end

        def add(paths = '.', options = {})
          return unless git_repo
          git_repo.add(paths, options)
        end

        def remove(paths = '.', options = {})
          return unless git_repo
          git_repo.remove(paths, options)
        end

      private

        attr_accessor :git_repo

        def in_tmp_repo
          Dir.mktmpdir do |tmpdir|
            repo_path = File.join(tmpdir, repo.repo)
            self.git_repo = Git.clone(
              repo.git_url,
              name,
              working_directory: repo_path,
            )
            # TODO: Check if we need to chdir or just use the working dir for the name....?
            Dir.chdir(repo_path) do
              yield git_repo
            end
          end
        ensure
          self.git_repo = nil
        end
      end
    end
  end
end
