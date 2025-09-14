class MasterCvController < ApplicationController
  before_action :authenticate_user!
  before_action :set_heading, only: %i[ index edit ]

  def index
    @tags = [
      { name: "frontend", color: "#FF5733" },
      { name: "backend", color: "#33FF57" },
      { name: "core", color: "#3357FF" }
    ]
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
      @full_name = current_user.cv_heading.full_name
      @heading = current_user.cv_heading.cv_heading_items
    end
end
