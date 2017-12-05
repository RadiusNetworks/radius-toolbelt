
module Radius
  module Toolbelt
    module SlackHelpers
      def slack(message, channel = nil)
        uri = URI(ENV['SLACK_WEBHOOK_URL'])

        parms = {
          text: message,
          username: "Travis CI",
          icon_emoji: ":travis:"
        }

        parms[:channel] = channel if channel

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = parms.to_json

        http.request(request)
      end
      module_function :slack

    end
  end
end
