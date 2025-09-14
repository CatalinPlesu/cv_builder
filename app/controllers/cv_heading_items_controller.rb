class CvHeadingItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cv_heading
  before_action :set_cv_heading_item, only: [ :edit, :update, :destroy ]

  def new
    @cv_heading_item = @cv_heading.cv_heading_items.build
  end

  def create
    @cv_heading_item = @cv_heading.cv_heading_items.build(cv_heading_item_params)

    if @cv_heading_item.save
      redirect_to root_path, notice: "Item created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @cv_heading_item.update(cv_heading_item_params)
      redirect_to root_path, notice: "Item updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @cv_heading_item.destroy
    redirect_to root_path, notice: "Item deleted successfully."
  end

  def reorder
    params[:item_ids].each_with_index do |id, index|
      @cv_heading.cv_heading_items.find(id).update(position: index + 1)
    end

    head :ok
  end

  private

  def set_cv_heading
    @cv_heading = current_user.cv_headings.find(params[:cv_heading_id])
  end

  def set_cv_heading_item
    @cv_heading_item = @cv_heading.cv_heading_items.find(params[:id])
  end

  def cv_heading_item_params
    params.require(:cv_heading_item).permit(:icon, :text, :url, :position)
  end
end
