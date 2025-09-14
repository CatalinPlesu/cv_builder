class Experience < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :experience_bullets, dependent: :destroy

  validates :company, presence: true
  validates :position_title, presence: true

  default_scope { order(position: :asc) }
end
