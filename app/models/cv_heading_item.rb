class CvHeadingItem < ApplicationRecord
  belongs_to :cv_heading

  validates :icon, presence: true
  validates :text, presence: true
  validates :position, presence: true, uniqueness: { scope: :cv_heading_id }

  scope :ordered, -> { order(:position) }
  before_validation :set_position, on: :create

  private

  def set_position
    return if position.present?

    max_position = cv_heading.cv_heading_items.maximum(:position) || 0
    self.position = max_position + 1
  end
end
