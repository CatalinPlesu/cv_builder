class User < ApplicationRecord
  has_one :cv_heading, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_many :experiences, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :skill_categories, dependent: :destroy
  has_many :achievements, dependent: :destroy
  has_many :languages, dependent: :destroy
  has_many :certificates, dependent: :destroy
  has_many :organizations, dependent: :destroy
  has_many :references, dependent: :destroy

  default_scope { includes(:templates) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def full_cv_data
    {
      heading: cv_heading,
      educations: educations,
      experiences: experiences.includes(:experience_bullets),
      projects: projects.includes(:project_bullets),
      skill_categories: skill_categories.includes(:skills),
      achievements: achievements,
      languages: languages,
      certificates: certificates,
      organizations: organizations,
      references: references
    }
  end

  def cv_data_for_tags(tag_ids)
    tags_to_include = tags.where(id: tag_ids)

    {
      heading: cv_heading,
      educations: educations.joins(:tags).where(tags: { id: tag_ids }).distinct,
      experiences: experiences.joins(:tags).where(tags: { id: tag_ids }).distinct.includes(:experience_bullets),
      projects: projects.joins(:tags).where(tags: { id: tag_ids }).distinct.includes(:project_bullets),
      skill_categories: skill_categories.joins(:tags).where(tags: { id: tag_ids }).distinct.includes(:skills),
      achievements: achievements.joins(:tags).where(tags: { id: tag_ids }).distinct,
      languages: languages.joins(:tags).where(tags: { id: tag_ids }).distinct,
      certificates: certificates.joins(:tags).where(tags: { id: tag_ids }).distinct,
      organizations: organizations.joins(:tags).where(tags: { id: tag_ids }).distinct,
      references: references.joins(:tags).where(tags: { id: tag_ids }).distinct
    }
  end
end
