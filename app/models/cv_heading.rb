class CvHeading < ApplicationRecord
  belongs_to :user
  has_many :cv_heading_items, -> { order(:position) }, dependent: :destroy

  validates :full_name, presence: true, length: { maximum: 100 }
end
