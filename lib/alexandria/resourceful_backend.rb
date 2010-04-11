class Alexandria
  class ResourcefulBackend
    CONTENT_TYPE = "application/x-www-form-urlencoded"
    AUTH_URL     = "https://www.google.com/accounts/ClientLogin"

    # Instantiate a new Resourceful backend.
    #
    # @param [Object] http an object that looks like a
    #   Resourceful HttpAccessor. It defaults to an instance
    #   of Resourceful::HttpAccessor
    def initialize(http = Resourceful::HttpAccessor.new)
      @http = http
    end

    # Authenticate with a set of parameters.
    #
    # @param [Hash] params The parameters to send to Google
    # @option params [String] accountType
    #   "GOOGLE", "HOSTED", or "HOSTED_OR_GOOGLE"
    # @option params [String] Email An email address or
    #   Google ID
    # @option params [String] Passwd The user's password
    # @option params [String] service The service to
    #   authenticate for.
    # @option params [String] source A short string
    #   identifying the application
    #
    # @todo Add support for logintoken and logincaptcha
    #   parameters for CAPTCHA challenges
    #
    # @todo Handle other possible exceptions
    def authenticate(params)
      data = body_parameters(params)

      resource = @http.resource(AUTH_URL)
      response = resource.post(data, headers)
      response.body.match(/^Auth=([^\n]*)/)[1]
    rescue Resourceful::UnsuccessfulHttpRequestError => e
      response = e.http_response.body
      # TODO Handle other kinds of output
      code     = response.match(/^Error=([^\n]*)/)[1]
      raise AuthenticationFailure.new(code)
    end

    def authenticated_get(token, url, params)
      data = body_parameters(params)

      resource = @http.resource(url)
      full_headers = headers.merge("Authorization" => "GoogleLogin auth=\"#{token}\"")
      resource.get(full_headers)
    end

  private

    def headers
      {
        "Content-Type" => CONTENT_TYPE,
        "GData-Version" => "2"
      }
    end

    def body_parameters(hash)
      uri = Addressable::URI.new
      uri.query_values = hash
      uri.query
    end

  end
end