require "time"
require "resourceful"

require "active_support"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/module/introspection"
require "active_support/inflector/inflections"
require "active_support/inflections"

require "alexandria/resourceful_backend"
require "alexandria/constants"
require "alexandria/response_document"

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

  # Create a new instance of the Alexandria connector.
  #
  # @param [String] user the username of the Google account
  # @param [String] password the password of the Google account
  # @param [optional, Object] backend the backend to use to
  #   connect to the Google service. By default, this uses
  #   the ResourcefulBackend, which uses the resourceful
  #   library to connect to Google over HTTP.
  def initialize(user, password, backend = ResourcefulBackend.new)
    @user, @password, @backend = user, password, backend
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
      @backend.authenticate(
        "accountType" => "HOSTED_OR_GOOGLE",
        "Email" => @user,
        "Passwd" => @password,
        "service" => service,
        "source" => "alexandria"
      )
    end
  end

  def get(service, url, params = {})
    token = token_for(service)
    @backend.authenticated_get(token, url, params)
  end
end