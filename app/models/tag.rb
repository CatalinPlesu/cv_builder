class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :templates
  has_and_belongs_to_many :educations
  has_and_belongs_to_many :experiences
  has_and_belongs_to_many :experience_bullets
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :project_bullets
  has_and_belongs_to_many :skill_categories
  has_and_belongs_to_many :skills
  has_and_belongs_to_many :achievements
  has_and_belongs_to_many :languages
  has_and_belongs_to_many :certificates
  has_and_belongs_to_many :organizations
  has_and_belongs_to_many :references

  validates :name, presence: true, uniqueness: true, length: { maximum: 25 }
  validates :color, presence: true, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, message: "must be a valid hex color" }
end
