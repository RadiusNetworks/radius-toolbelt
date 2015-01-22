module Radius
  module Toolbelt
    class CLI
      module Release
        def self.included(klass)
          klass.class_eval do
            command :release do |c|
              c.syntax = "#{$PROGRAM_NAME} #{c.name} [OPTIONS] TAG"
              c.description = 'Push project release to Github'

              # TODO: Refactor this! UGLY hack need to work around Commander's missing
              #       ability to reference the options or set them from within the
              #       block provided to `c.option`.
              cli_opts = OpenStruct.new(binary: [])

              c.option '-a', '--access_token TOKEN',
                'REQUIRED. OAuth access token for Github authentication.'
              c.option '-o', '--owner OWNER',
                'REQUIRED. GitHub release repository owner (i.e. user)'
              c.option '-r', '--repo REPO',
                'REQUIRED. GitHub release repository name'
              c.option '-n', '--name NAME',
                'Name for the release.'
              c.option '--long-name',
                'Use the name format: "Version TAG - FullMonth Day, Year"'
              c.option '-b', '--body [BODY]',
                'Content for release notes. Omitting the BODY text prompts for it.'
              c.option '--[no-]draft',
                'Mark this release as a draft. (Default: false)'
              c.option '--[no-]prerelease',
                'Mark this release as a pre-release. (Default: false)'
              c.option '--add FILES', Array, 'List of files/globs to add to repo prior to release.' do |f|
                cli_opts.add_files.concat f
              end
              c.option '--remove FILES', Array, 'List of files/globs to remove from repo prior to release.' do |f|
                cli_opts.remove_files.concat f
              end
              c.option '--binary FILES', Array, 'Binary file(s) to attach to the release.' do |files|
                cli_opts.binary.concat files
              end

              # TODO: Use this to generate access token; or just allow --login?; or add --generate?
              #        c.option '-l', '--login USERNAME',
              #          'Username for Github authentication'
              #        c.option '-p', '--password PASSWORD',
              #          'Password for Github authentication'
              c.action do |args, options|
                abort "No TAG provided" if args.empty?
                options.tag = args.shift

                # TODO: Allow hub config as a fallback
                # TODO: Use login and password to generate access token and store it

                # TODO: Move these checks to a release cli specific class
                # Check this first so we don't prompt for user stuff with an invalid
                # set of files.
                cli_opts.binary.each do |f|
                  abort "File not found: #{f}" unless File.exist?(File.expand_path(f))
                end
                options.binary = cli_opts.binary

                if !options.name && options.long_name
                  now = Time.now.utc
                  options.name = "Version #{options.tag} - #{now.strftime('%B %-d, %Y')}"
                end

                # TODO: Refactor this! UGLY hack due to block scoping and not being
                # given the `options` object when providing a block to `c.option`
                if options.body == true
                  options.body = ask_editor('TODO: Replace with release notes')
                end

                # We must send the hash because Commander::Command::Options class is
                # all kinds of bad. It is a faux-struct, faux-hash, faux-OpenStruct.
                #
                # It really wants to _be_ an OpenStruct, it's just an incomplete
                # implementation. It dates back to 2009 and does not follow many
                # modern Ruby conventions. More specifically, it does not implement
                # `respond_to_missing`, does not properly delegate `method_missing`
                # up the call chain, and refrains from implementing standard hash
                # conversion methods such as `to_h` and `to_hash`.
                config = Configuration.new(options.__hash__)

                config.require_options Commands::Release.required_options
                if (opts = config.missing_options)
                  abort "Missing required options: #{opts.join(', ')}"
                end

                # TODO: Make this a command specific configuration class?
                # Massage options for command
                options = config.options
                options.repo = Repository.new(options.owner, options.repo)
                options.delete :owner
                options.client = Client::GithubClient.new(options.access_token)
                options.delete :access_token

                Commands::Release.new(config).upload
              end
            end
          end
        end
      end
    end
  end
end
