require 'radius/toolbelt/configuration'
require 'support/string'
require 'support/using_env'
require 'support/using_temp'

module Radius
  module Toolbelt
    ::RSpec.describe Configuration do

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

      it 'it warns when a HOME directory cannot be found' do
        using_env('HOME' => nil) do
          expect { Configuration.new }.to output(
            "Unable to find ~/.radius-toolbelt because the HOME environment variable is not set\n"
          ).to_stderr
        end
      end

    end
  end
end
