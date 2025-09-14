class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :templates

  validates :name, presence: true, uniqueness: true, length: { maximum: 25 }
  validates :color, presence: true, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, message: "must be a valid hex color" }
end
