class Achievement < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags

  validates :title, presence: true

  default_scope { order(position: :asc) }
end
