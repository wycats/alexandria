require "spec_helper"

describe "Alexandria#token_for" do
  before do
    @backend = Alexandria::TestBackend.new
  end

  describe "using valid credentials" do
    it "returns a valid token" do
      @alexandria = Alexandria.new("test@example.com", "s3kr17", @backend)
      @alexandria.token_for(:calendar).should be_kind_of(String)
    end
  end

  describe "using invalid credentials" do
    it "raises an exception" do
      @alexandria = Alexandria.new("test@example.com", "s4uce", @backend)
      lambda do
        @alexandria.token_for(:calendar)
      end.should raise_error(Alexandria::AuthenticationFailure)
    end
  end
end