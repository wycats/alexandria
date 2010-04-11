require "spec_helper"

describe "Alexandria::Feed" do
  before do
    xml = File.read(File.expand_path("../feed.xml", __FILE__))
    @feed = Alexandria::Feed.new(xml)

    xml = File.read(File.expand_path("../feed_with_category.xml", __FILE__))
    @feed_with_category = Alexandria::Feed.new(xml)
  end

  it "can find its id" do
    @feed.id.should == "http://www.example.com/myFeed"
  end

  it "can find its title" do
    @feed.title.should == "Foo"
  end

  it "returns an Author object" do
    author = @feed.author
    author.name.should == "Jo March"
    author.email.should == nil
  end

  it "returns nil for a non-existent category" do
    @feed.category.should == nil
  end

  it "returns a Category if it does exist" do
    category = @feed_with_category.category
    category.name.should == "foo"
    category.scheme.should == "bar"
  end

  it "returns nil for a non-existent published date" do
    @feed.published.should == nil
  end

  it "can find its last updated date" do
    @feed.updated.should == Time.parse("2006-01-23T16:28:05-08:00")
  end
end