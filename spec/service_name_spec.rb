require "spec_helper"

describe "Alexandria::ServiceNames#[]" do
  it "returns a String for a valid service Symbol" do
    Alexandria::ServiceNames[:calendar].should == "cl"
  end

  it "returns a String for a valid service String" do
    Alexandria::ServiceNames["cl"].should == "cl"
  end

  it "raises an exception for an invalid service Symbol" do
    lambda { Alexandria::ServiceNames[:omg] }.
      should raise_error(Alexandria::InvalidServiceName, /:calendar/)
  end

  it "raises an exception for an invalid service String" do
    lambda { Alexandria::ServiceNames["omg"] }.
      should raise_error(Alexandria::InvalidServiceName, /"cl"/)
  end
end