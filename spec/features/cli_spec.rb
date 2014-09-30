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

end
