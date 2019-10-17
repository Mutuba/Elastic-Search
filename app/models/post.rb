# frozen_string_literal: true

class Post < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  before_save :add_datetime_now!
  before_save :published!


  def add_datetime_now!
    self.published_on = DateTime.now
  end
  def published!
    self.published = true
  end
  settings do
    mappings dynamic: false do
      indexes :author, type: :text
      indexes :title, type: :text, analyzer: :english
      indexes :body, type: :text, analyzer: :english
      indexes :tags, type: :text, analyzer: :english
      indexes :published, type: :boolean
    end
  end

  def self.search_published(query)
    search(
      query: {
        bool: {
          must: [
            {
              multi_match: {
                query: query,
                fields: %i[author title body tags]
              }
            },
            {
              match: {
                published: true
              }
            }
          ]
        }
      }
    )
  end
end
