require "artifice"
require "sinatra"

class FakeGoogle < Sinatra::Base
  post "/accounts/ClientLogin" do
    if params["Passwd"] == "s3kr17"
      "Auth=#{/\w{224}/.gen}"
    else
      status 403
      "Error=BadAuthentication"
    end
  end
end

require "spec_helper"

Artifice.activate_with(FakeGoogle.new)

describe "With the Alexandria::ResourcefulBackend" do
  before do |example|
    backend_klass = Alexandria::ResourcefulBackend
    url           = backend_klass::AUTH_URL

    @backend = backend_klass.new
  end

  it "using valid credentials, it returns a token" do
    response = @backend.authenticate(Alexandria::TestBackend.valid_params)
    response.should be_kind_of(String)
  end

  it "using invalid credentials, it raises" do
    params = Alexandria::TestBackend.valid_params.merge("Passwd" => "s3krit")

    lambda do
      @backend.authenticate(params)
    end.should raise_error(Alexandria::AuthenticationFailure)
  end

  # it_should_behave_like "Alexandria#token_for"
end