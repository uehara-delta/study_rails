class Book < ApplicationRecord
  belongs_to :user
  has_many :taggings
  has_many :tags, through: :taggings
  scope :tagged_recommended, -> { joins(:tags).where(tags: {name: 'recommended'}) }
end
