require 'delegate'

#def this_github_repo
#  remotes = `git remote -v`.lines.map(&:chomp)
#  remotes.each do |remote|
#    match = remote.match /github\.com:([^\\]+)\/([^\.]+)\.git/
#    if match
#      return "#{match[1]}/#{match[2]}"
#    end
#  end
#end

#Github::Release.new(this_github_repo, params[:tag], params[:name], params[:body], files)
#
module Radius
  module Toolbelt
    module Commands
      Repository = Struct.new(:owner, :repo)
      Release = Struct.new(:repo, :tag, :name, :body, :binaries)

      class Release

        def self.required_options
          %i[
            client
            repo
            tag
          ]
        end

        attr_reader :repo, :tag, :name, :body, :binaries

        attr_reader :client
        private :client

        attr_reader :draft, :prerelease
        alias_method :draft?, :draft
        alias_method :prerelease?, :prerelease
        private :draft, :prerelease

        def initialize(config)
          check_required_options! config.options
          set_required_options! config.options
          @client = options.client
          @repo = Repository.new(options.owner, options.repo)
          @tag = options.tag
          @name = options.name
          @draft = !!options.draft
          @prerelease = !!options.prerelease
          @body = options.body
          @binaries = options.binary.dup
        end

        def options
          options = {
            draft: draft?,
            prerelease: prerelease?,
          }
          options.store(:name, name) if name
          options.store(:body, body) if body
          options
        end

        def required_options
          self.class.required_options
        end

        def check_required_options!(options)
          missing = check_missing(options)
          unless missing.empty?
            raise ArgumentError, "Missing options: #{missing.join(', ')}"
          end
        end

        def check_missing(options)
          required_options - options.to_h.keys
        end

        def upload
          client.commit message do |c|
            c.prepend_file 'CHANGELOG.md', changelog_entry
            c.add add_files
            c.remove remove_files, recursive: true
          end
          client.create_release(self)
        end

        def changelog_entry
          return unless body
          divider = '-' * tag.length
          [tag, divider, changelog_spacer, body]
        end

        def changelog_spacer
          nil
        end

        def generate_commit_message
          message_parts = ["Release #{tag}"]
          if body
            message_parts << "Update CHANGELOG with release notes."
          end
          if swap_files
            message_parts << "Swap existing #{swap_files} with #{new_files}."
          end
          message_parts.join("\n\n")
        end

#        def initialize(repo, tag_name, release_name, body, filenames)
#          # pull token from ENV or hub config
#          gh_token = ENV["github_token"] || YAML.load(`cat ~/.config/hub`)["github.com"].first["oauth_token"]
#
#          puts "\nCreating draft release \"#{release_name}\" for repo \"#{repo}\"..."
#          # create the release
#          client = Octokit::Client.new(access_token: gh_token)
#          @release = client.create_release(
#            repo, tag_name,
#            target_commitish: `git rev-parse HEAD`.chomp,
#            name: release_name,
#            body: body,
#            draft: true
#          )
#
#          # upload the files
#          filenames.each do |filename|
#            puts "Uploading #{filename}..."
#            client.upload_asset @release.url, filename
#          end
#
#          puts "\nRelease URL: #{@release.html_url}"
#        end
      end
    end
  end
end

#module Github
#  class Release < Delegator
#    def initialize(repo, tag_name, release_name, body, filenames)
#      # pull token from ENV or hub config
#      gh_token = ENV["github_token"] || YAML.load(`cat ~/.config/hub`)["github.com"].first["oauth_token"]
#
#      puts "\nCreating draft release \"#{release_name}\" for repo \"#{repo}\"..."
#      # create the release
#      client = Octokit::Client.new(access_token: gh_token)
#      @release = client.create_release(
#        repo, tag_name,
#        target_commitish: `git rev-parse HEAD`.chomp,
#        name: release_name,
#        body: body,
#        draft: true
#      )
#
#      # upload the files
#      filenames.each do |filename|
#        puts "Uploading #{filename}..."
#        client.upload_asset @release.url, filename
#      end
#
#      puts "\nRelease URL: #{@release.html_url}"
#    end
#
#    def __getobj__
#      @release
#    end
#  end
#end
#
#
#Github::Release.new(this_github_repo, params[:tag], params[:name], params[:body], files)
