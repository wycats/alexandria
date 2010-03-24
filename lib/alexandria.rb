require "resourceful"
require "alexandria/resourceful_ext"
require "alexandria/constants"

# Alexandria is a library for connecting to APIs that work
# with the Google Data protocol.
#
# For each Google user, create an instance of Alexandria.
# An instance can retrieve a token for a particular service
# that you can use to authenticate the user in future requests
# to the service.
#
# The Alexandria library itself provides the raw functionality
# for accessing Google data. Other libraries, such as
# alexandria-analytics, provide domain-specific wrappers
# around the raw data access.
class Alexandria

  AUTH_URL = "https://www.google.com/accounts/ClientLogin"
  CONTENT_TYPE = "application/x-www-form-urlencoded"

  # Create a new instance of the Alexandria connector.
  #
  # @param [String] user the username of the Google account
  # @param [String] password the password of the Google account
  def initialize(user, password)
    @user, @password = user, password
    @tokens = {}
  end

  # Get a token for use with a particular service. Tokens
  # for a service are remembered, so calling this method
  # a second time with the same service will always return
  # the same token.
  #
  # @param [String, Symbol] service the name of the service.
  #   If a String is provided, it must be a valid internal
  #   Google service name. If a Symbol is provided, it must
  #   be a valid service key. Alexandria defines the valid
  #   services it knows about. You may define additional
  #   ones using Alexandria.add_service.
  #
  # @return [String] The token
  def token_for(service)
    service = Alexandria::ServiceNames[service]

    @tokens[service] ||= begin
      data = body_parameters(
        :accountType => "HOSTED_OR_GOOGLE",
        :Email => @user,
        :Passwd => @password,
        :service => service,
        :source => "alexandria"
      )

      http     = Resourceful::HttpAccessor.new
      resource = http.resource(AUTH_URL)
      response = resource.post(data, :content_type => CONTENT_TYPE)
      response.body.match(/^Auth=([^\n]*)/)[1]
    end
  rescue Resourceful::UnsuccessfulHttpRequestError => e
    response = e.http_response.body
    code     = response.match(/^Error=([^\n]*)/)[1]
    raise AuthenticationFailure.new(code)
  end

private

  def body_parameters(hash)
    uri = Addressable::URI.new
    uri.query_values = hash
    uri.query
  end
  
end