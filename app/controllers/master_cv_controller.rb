class MasterCvController < ApplicationController
  before_action :authenticate_user!
  before_action :set_heading, only: %i[ index edit ]

  def index
    @tags = [
      { name: "frontend", color: "#FF5733" },
      { name: "backend", color: "#33FF57" },
      { name: "core", color: "#3357FF" }
    ]

    @educations = current_user.educations.order(:position)
    @experiences = current_user.experiences.order(:position)
    @projects = current_user.projects.order(:position)
    @skill_categories = current_user.skill_categories.includes(:skills).order(:position)
  end

  def edit
    @tags = [
      { name: "frontend", color: "#FF5733" },
      { name: "backend", color: "#33FF57" },
      { name: "core", color: "#3357FF" }
    ]
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
end
