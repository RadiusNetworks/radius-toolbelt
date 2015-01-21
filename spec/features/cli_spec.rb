require 'support/string'
require 'support/subcommand'

RSpec.describe 'The `radius` CLI:', type: :feature do

  def bin_radius
    @_bin_radius ||= if File.exist?('sbin/radius')
                       %w[ sbin/radius ]
                     else
                       %w[ bundle exec bin/radius ]
                     end
  end

  def radius_release
    @_radius_releas ||= bin_radius << 'release'
  end

  it 'running `radius` is successful' do
    expect(subcommand bin_radius).to be_successful
  end

  it 'running `radius` defaults to showing the help message' do
    expect(subcommand(bin_radius).stdout.strip_heredoc).to start_with(
      <<-OUT.strip_heredoc
        NAME:

          radius

        DESCRIPTION:

          Main CLI tool for working with common Radius Network tasks.

        COMMANDS:
      OUT
    )
  end

  describe 'running `radius release` with no TAG' do
    it 'is not successful' do
      expect(subcommand radius_release).not_to be_successful
    end

    it 'states a TAG is required' do
      expect(subcommand(radius_release).stderr.chomp).to eq 'No TAG provided'
    end
  end

  describe 'running `radius release TAG --binary no-such-file`' do
    let(:radius_cmd) {
      radius_release + %w[
        v0.0.0
        --binary no-such-file
      ]
    }

    it 'is not successful' do
      expect(subcommand radius_cmd).not_to be_successful
    end

    it 'states a the file is not found' do
      expect(subcommand(radius_cmd).stderr.chomp).to eq(
        'File not found: no-such-file'
      )
    end
  end

  describe 'running `radius release TAG --name`'

  describe 'running `radius release TAG --long-name`'

  describe 'running `radius release TAG`' do
    def radius_release_tag
      @_radius_releas_tag ||= radius_release.concat(
        %w[
          v0.0.0
          --owner RadiusNetworks
          --repo dr-ock
        ]
      )
    end

    it 'is successful', :vcr, pending: 'TODO: Setup VCR' do
      expect(subcommand radius_release_tag).to be_successful
    end

    it 'with `--body` flag prompts for the release body in a text editor',
       pending: 'TODO: Figure out how to simular a text editor in RSpec'
  end

end
