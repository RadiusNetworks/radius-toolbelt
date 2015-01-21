module Radius
  module RSpec
    module Helpers

      # By forcing the use of a block, this makes working within the context of
      # a single spec much easier. If this needs to be wrapped around multiple
      # specs, then an appropriate #around(:example) hook may be used.
      def using_env(env_stubs, &lifetime)
        keys_to_delete = env_stubs.keys - ENV.keys
        original_values = env_stubs.each_with_object({}) { |(k, v), env|
          env[k] = ENV[k] if ENV.has_key?(k)
          ENV[k] = v.to_s
        }
        lifetime.call
      ensure
        keys_to_delete.each{ |k| ENV.delete(k) }
        original_values.each{ |k, v| ENV[k] = v }
      end

    end
  end
end

RSpec.configure do |config|
  config.include Radius::RSpec::Helpers
end
