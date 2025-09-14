class Education < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags

  validates :institution, presence: true
  validates :degree, presence: true

  default_scope { order(position: :asc) }
end
