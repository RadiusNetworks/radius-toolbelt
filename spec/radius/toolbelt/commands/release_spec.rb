require 'ostruct'
require 'radius/toolbelt/commands/release'

module Radius
  module Toolbelt
    module Commands
      RSpec.describe Release do

        it 'requires client, repo, and a tag' do
          no_options = OpenStruct.new
          expect{ Release.new(no_options) }.to raise_error ArgumentError, "Missing options: client, repo, tag"
        end

        it 'creates the release'

        context 'with a name'

        context 'with a release notes body'

        context 'with binaries'

      end
    end
  end
end
