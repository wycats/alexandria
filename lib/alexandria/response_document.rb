require "date"
require "nokogiri"
require "active_support/core_ext/class/attribute"

class Alexandria
  class ResponseDocument
    # @todo Do we want to allow modification of a parent class' attributes
    #   at runtime? If so, we need to use a different kind of accessor

    class_attribute :types
    class_attribute :type_attributes
    class_attribute :root_name

    self.types = {}
    self.type_attributes = Hash.new {|h,k| h[k] = [] }
    self.root_name = "feed"

    class << self
      attr_accessor :children
    end

    def children
      self.class.children || []
    end

    # The type method defines a new type that you can use to declare
    # attributes.
    #
    # @param [Symbol] type the name of the type you are creating,
    #   for instance, :string
    # @yields [String] some text that Alexandria extracted from an
    #   XML file
    # @block_returns [Object] a result in the form of the type,
    #   for instance, the :time type would return a Time
    #
    # @todo how to document blocks like this
    def self.type(type, &block)
      self.type_attributes = self.type_attributes.merge(type => [])

      class_eval <<-RUBY
        def self.#{type}(name, selector = name.to_s, attribute = nil)
          self.type_attributes[:#{type}] += [[name, selector, attribute]]
          attr_accessor name
        end
      RUBY

      self.types = self.types.merge(type => block)
    end

    # Define a child model. For instance, a Feed has one Author.
    # This is useful if a single node can model the attributes
    # of a child node:
    #
    # @param [Symbol] name The name of the child model
    # @param [Class] type The class of the child model
    # @param [String] selector The selector, relative to the root
    #   of the current model, that describes how to get to
    #   the location of the node containing the child model's
    #   information. This defaults to the name, converted to
    #   a String.
    #
    # @return
    #
    # @example
    #   <feed>
    #     <author>
    #       <name>Yehuda Katz</name>
    #       <email>wycats@gmail.com</name>
    #     </author>
    #   </feed>
    #
    # @example
    #   class Feed
    #     has_one :author, Author
    #   end
    #
    # @example
    #   class Author
    #     string :name
    #     string :email
    #   end
    #
    # @example
    #   feed = Feed.new(xml)
    #   feed.author.name  #=> "Yehuda Katz"
    #   feed.author.email #=> "wycats@gmail.com"
    #
    # If the root node does not exist, the child model's method
    # on the parent will return nil
    def self.has_one(name, type, selector = name.to_s)
      self.children ||= []
      self.children << [name, type, selector]
      attr_accessor name
    end

    # @todo generate these
    #
    # @param [Symbol] name The name of the attribute you are creating
    # @param [String] selector A selector that describes how to get
    #   to the location of this attribute directly underneath the
    #   root. This defaults to the #name. If you want to specify that
    #   the attribute is anywhere below the root, use "* selector"
    # @param [String] attribute The name of the XML attribute that
    #   contains this attribute. If this is left empty, the text
    #   contents of the node itself will be used
    type(:string) { |text| text }

    # @todo generate these
    #
    # @param [Symbol] name The name of the attribute you are creating
    # @param [String] selector A selector that describes how to get
    #   to the location of this attribute directly underneath the
    #   root. This defaults to the #name. If you want to specify that
    #   the attribute is anywhere below the root, use "* selector"
    # @param [String] attribute The name of the XML attribute that
    #   contains this attribute. If this is left empty, the text
    #   contents of the node itself will be used
    type(:time)   { |text| Time.parse(text) }

    # @param [String, Nokogiri::XML::Document] xml A valid XML document
    #   in String or already parsed form
    # @param [String] root_name A prefix that should be used before the
    #   the selector. If not supplied, the class-level #root_name will
    #   be used
    def initialize(xml, root_name = nil)
      @root = xml.is_a?(String) ? Nokogiri::XML(xml) : xml
      self.root_name = root_name if root_name

      # Loops through all the registered types
      types.each do |type, block|
        # Loop through the registered attributes for each type
        type_attributes[type].each do |name, selector, attribute|
          selector = [self.root_name, selector].compact.join(" > ")
          text = get_node(selector, attribute)
          next unless text
          instance_variable_set("@#{name}", block.call(text))
        end
      end

      children.each do |name, type, selector|
        # Pass in the full XML document, but prefix the root name
        # with the full selector to this point
        selector = [self.root_name, selector].compact.join(" > ")

        # But set the child to nil if the selector doesn't exist
        unless @root.css(selector).empty?
          instance_variable_set("@#{name}", type.new(@root, selector))
        end
      end
    end

  private
    def get_node(selector, attribute)
      result = @root.css(selector)[0]
      return nil unless result
      text   = attribute ? result[attribute] : result.text
      return nil unless text && !text.empty?
      text
    end
  end
end

require "alexandria/response_document/feed"
require "alexandria/response_document/entry"
