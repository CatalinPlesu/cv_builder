class Reference < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags

  validates :name, presence: true

  default_scope { order(position: :asc) }
end
