class Skill < ApplicationRecord
  belongs_to :skill_category
  has_and_belongs_to_many :tags

  validates :name, presence: true

  default_scope { order(position: :asc) }
end
