class Section < ApplicationRecord
  has_and_belongs_to_many :templates

  validates :name, presence: true, uniqueness: true

  enum :name, {
    education: "education",
    experience: "experience",
    project: "project",
    skill: "skill"
  }

  # Helper method to get human-readable labels
  def label
    case name
    when "education"
      "Education"
    when "experience"
      "Work Experience"
    when "project"
      "Projects"
    when "skill"
      "Skills"
    else
      "Unknown"
    end
  end

  # Class method to get all available sections with labels
  def self.available_sections
    {
      education: "Education",
      experience: "Work Experience",
      project: "Projects",
      skill: "Skills"
    }
  end
end
