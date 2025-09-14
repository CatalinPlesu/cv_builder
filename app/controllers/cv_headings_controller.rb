class CvHeadingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cv_heading, only: [ :edit, :update, :destroy ]

  def new
    @cv_heading = current_user.cv_headings.build
  end

  def create
    @cv_heading = current_user.cv_headings.build(cv_heading_params)

    if @cv_heading.save
      redirect_to root_path, notice: "CV Heading created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @cv_heading.update(cv_heading_params)
      redirect_to root_path, notice: "CV Heading updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @cv_heading.destroy
    redirect_to root_path, notice: "CV Heading deleted successfully."
  end

  private

  def set_cv_heading
    @cv_heading = current_user.cv_headings.find(params[:id])
  end

  def cv_heading_params
    params.require(:cv_heading).permit(:full_name)
  end
end
