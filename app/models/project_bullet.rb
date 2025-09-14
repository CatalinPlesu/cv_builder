class ProjectBullet < ApplicationRecord
  belongs_to :project
  has_and_belongs_to_many :tags

  validates :content, presence: true

  default_scope { order(position: :asc) }
end
