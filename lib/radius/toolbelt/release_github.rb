require 'yaml'
require 'octokit'
require 'fileutils'
require 'launchy'

module Radius
  module Toolbelt

    class ReleaseGithub

      attr_reader :repo, :tag_name, :release_name, :body, :filenames, :token
      def initialize(repo, token, tag_name, release_name, body, filenames)
        @repo = repo
        @tag_name = tag_name
        @release_name = release_name
        @body = body
        @filenames = filenames
        @token = token
      end

      def run
        # pull token from ENV or hub config

        puts "\nCreating draft release \"#{release_name}\" for repo \"#{repo}\"..."
        # create the release
        client = Octokit::Client.new(access_token: token)
        release = client.create_release(
          repo, tag_name,
          #target_commitish: tag_name,
          name: release_name,
          body: body,
          draft: true
        )

        # upload the files
        filenames.each do |filename|
          puts "Uploading #{filename}..."
          client.upload_asset release.url, filename
        end

        puts "\nRelease URL: #{release.html_url}"
        Launchy.open( release.html_url.gsub("/tag/", "/edit/") )
      end

    end


  end
end
