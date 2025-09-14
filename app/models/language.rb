class Language < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags

  validates :name, presence: true
  validates :proficiency, presence: true

  default_scope { order(position: :asc) }
end
