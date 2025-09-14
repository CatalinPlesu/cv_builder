class Project < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :project_bullets, dependent: :destroy

  validates :name, presence: true

  default_scope { order(position: :asc) }
end
