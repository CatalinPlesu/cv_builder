class MasterCvController < ApplicationController
  before_action :authenticate_user!
  before_action :set_heading, only: %i[ index edit ]
  before_action :ensure_core_tag

  def index
    @educations = current_user.educations.order(:position)
    @experiences = current_user.experiences.order(:position)
    @projects = current_user.projects.order(:position)
    @skill_categories = current_user.skill_categories.includes(:skills).order(:position)
    @tags = current_user.tags.order(:position)
  end

  def edit
  end

  private
    def set_heading
      if current_user.cv_heading.present?
        @full_name = current_user.cv_heading.full_name
        @heading = current_user.cv_heading.cv_heading_items
      else
        @full_name = current_user.email
        @heading = [] # or however you want to handle missing cv_heading_items
      end
    end

   def ensure_core_tag
      return if current_user.tags.exists?(name: "base")

      current_user.tags.create!(
        name: "base",
        color: "#808080", # blue color
        position: 1
      )
    end
end
