require "alexandria"
require "randexp"

class Alexandria
  class TestBackend
    def self.valid_params
      {
        "accountType" => "HOSTED_OR_GOOGLE",
        "Email" => "test@example.com",
        "Passwd" => "s3kr17",
        "service" => "cl",
        "source" => "alexandria"
      }
    end

    def authenticate(params)
      if params == self.class.valid_params
        /\w{224}/.gen
      else
        raise AuthenticationFailure.new("BadAuthentication")
      end
    end
  end
end