require "spec_helper"
require "fakeweb"

describe "With the Alexandria::ResourcefulBackend" do
  before do |example|
    backend_klass = Alexandria::ResourcefulBackend
    url           = backend_klass::AUTH_URL

    @backend = backend_klass.new

    p example.running_example.class

    if example.running_example.metadata[:valid]
      FakeWeb.register_uri(url,
        :body => "Auth=#{/\w{224}/.gen}", :status => 200)
    else
      FakeWeb.register_uri(url,
        :body => "Error=BadAuthentication", :status => 403)
    end
  end

  after do
    FakeWeb.clean_registry
  end

  it "using valid credentials, it returns a token", :valid => true do
    response = @backend.authenticate(Alexandria::TestBackend.valid_params)
    response.should be_kind_of(String)
  end

  it "using invalid credentials, it raises", :valid => false do
    params = Alexandria::TestBackend.valid_params.merge("Passwd" => "s3krit")

    lambda do
      @backend.authenticate(params)
    end.should raise_error(Alexandria::AuthenticationFailure)
  end

  # it_should_behave_like "Alexandria#token_for"
end