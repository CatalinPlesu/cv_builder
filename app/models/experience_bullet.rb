class ExperienceBullet < ApplicationRecord
  belongs_to :experience
  has_and_belongs_to_many :tags

  validates :content, presence: true

  default_scope { order(position: :asc) }
end
