require "alexandria/response_document/author"
require "alexandria/response_document/category"

class Alexandria
  class Feed < ResponseDocument
    string :id
    string :title
    string :summary
    string :content

    time    :published
    time    :updated

    has_one :author, Author,     "author"
    has_one :category, Category, "category"
  end
end