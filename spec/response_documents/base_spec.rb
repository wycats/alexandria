require "spec_helper"

describe "Alexandria::ResponseDocument" do
  before do
    @xml = <<-XML
    <?xml version='1.0' encoding='utf-8'?>
    <feed xmlns='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005' gd:etag='W/"C0QBRXcycSp7ImA9WxRVFUk."'>
      <title>Foo</title>
      <updated>2006-01-23T16:25:00-08:00</updated>
      <id>http://www.example.com/myFeed</id>
      <author><name>Jo March</name></author>
      <time updated="2006-01-23T16:25:00-08:00" />
      <link href='/myFeed' rel='self'/>
    </feed>
    XML
  end

  describe "a response document needing no custom selectors" do
    result_class = Class.new(Alexandria::ResponseDocument) do
      string :title
      string :id
      time   :updated
    end

    before do
      @result = result_class.new(@xml)
    end

    it "can get String elements" do
      @result.title.should   == "Foo"
      @result.id.should      == "http://www.example.com/myFeed"
    end

    it "can get Time elements" do
      @result.updated.should == Time.parse("2006-01-23T16:25:00-08:00")
    end
  end

  describe "a response document needed a custom selector" do
    result_class = Class.new(Alexandria::ResponseDocument) do
      string :title
      string :id
      string :author_name,  "author name"
      string :url,          "link[rel=self]", "href"
      time   :updated
      time   :time_updated, "time", "updated"
    end

    before do
      @result = result_class.new(@xml)
    end

    it "can get elements without custom selectors" do
      @result.title.should   == "Foo"
      @result.id.should      == "http://www.example.com/myFeed"
      @result.updated.should == Time.parse("2006-01-23T16:25:00-08:00")
      @result.author_name.should == "Jo March"
    end

    it "can get String elements with the custom selectors" do
      @result.url.should == "/myFeed"
    end

    it "can get Time elements with the custom selectors" do
      @result.time_updated.should == Time.parse("2006-01-23T16:25:00-08:00")
    end
  end
end