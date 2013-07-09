module MWS
  module API
    class Base
      attr_reader :connection, :uri, :version, :verb

      def initialize(connection)
        @verb ||= :get
        @connection = connection
      end

      def call(action, params={})
        @verb = params.delete(:verb) || @verb
        request_params = params.delete(:format, :body)
        query = Query.new({
          verb: @verb,
          uri: @uri,
          host: @connection.host,

          aws_access_key_id: @connection.aws_access_key_id,
          aws_secret_access_key: @connection.aws_access_key_id,
          seller_id: @connection.seller_id,
          action: action.to_s.camelize,
          version: @version,
          params: params
        })

        case @verb.to_s.upcase
        when "GET"
          HTTParty.get(query.request_uri)
        when "POST"
          HTTParty.post(query.request_uri, request_params)
        end
      end
    end
  end
end
