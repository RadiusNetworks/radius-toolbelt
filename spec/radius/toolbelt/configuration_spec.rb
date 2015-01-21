require 'radius/toolbelt/configuration'
require 'support/string'
require 'support/using_env'
require 'support/using_temp'

require 'pry'
module Radius
  module Toolbelt
    ::RSpec.describe Configuration do

      # We need to clear out any user level configs so they don't mess with
      # the expected values of the specs.
      around(:example) do |example|
        in_tmpdir do |project_dir|
          using_env('HOME' => project_dir) do
            example.call
          end
        end
      end

      it 'uses the provided options' do
        config = {
          manual_setting: 'manual',
          doctor: 'who? riiiight',
          a_string: 1234,
        }

        expect(Configuration.new(config).options.to_h).to eq config
      end

      it 'symbolizes the keys' do
        config = {
          manual_setting: 'manual',
          doctor: 'who? riiiight',
          'a_string' => 1234,
        }

        expect(Configuration.new(config).options.to_h).to eq(
          manual_setting: 'manual',
          a_string: 1234,
          doctor: 'who? riiiight',
        )
      end

      context 'with required options' do
        describe 'asking which options are missing' do
          it 'returns nil when all options are required' do
            all_options_set = Configuration.new(tor: true, repo: 'dr-ock')
            all_options_set.require_options :tor, :repo
            expect(all_options_set.missing_options).to be nil
          end

          it 'returns the list of options which are not set' do
            no_options_set = Configuration.new
            no_options_set.require_options :tor, :repo
            expect(no_options_set.missing_options).to match_array [:tor, :repo]
          end
        end
      end

      context 'with system files' do
        around(:example) do |example|
          config_basename = '.radius-toolbelt'
          in_tmpdir do |project_dir|
            project_config = project_dir.join(config_basename)
            File.write project_config, <<-EOF.strip_heredoc
              project_setting: project
              local_setting: project
              manual_setting: project
            EOF
            local_config = project_dir.join("#{config_basename}-local")
            File.write local_config, <<-EOF.strip_heredoc
              local_setting: local
              manual_setting: local
            EOF

            using_tmphome do |home_dir|
              global_config = home_dir.join(config_basename)
              File.write global_config, <<-EOF.strip_heredoc
                global_setting: global
                project_setting: global
                local_setting: global
                manual_setting: global
              EOF

              example.call
            end
          end
        end

        it 'builds the options from provide options and files' do
          manual_config = { manual_setting: 'manual' }
          expect(Configuration.new(manual_config).options.to_h).to eq(
            global_setting: 'global',
            project_setting: 'project',
            local_setting: 'local',
            manual_setting: 'manual',
          )
        end

        it 'providing a configuration file ignores the system files' do
          using_tempfile data: 'custom_setting: custom' do |custom_config|
            manual_config = { config: custom_config.to_path }
            expect(Configuration.new(manual_config).options.to_h).to eq(
              config: custom_config.to_path,
              custom_setting: 'custom',
            )
          end
        end
      end

      it 'warns when a HOME directory cannot be found' do
        using_env('HOME' => nil) do
          expect { Configuration.new }.to output(
            "Unable to find ~/.radius-toolbelt because the HOME environment variable is not set\n"
          ).to_stderr
        end
      end

    end
  end
end
