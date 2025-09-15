# app/controllers/tags_controller.rb

class TagsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @tags = current_user.tags.order(:position)
    if @tags.empty?
      @tags = [ current_user.tags.build ]
    end
  end

  def upsert
    Tag.transaction do
      tag_params = params[:tags] || []

      # Extract IDs from params
      tag_ids_from_params = tag_params.map { |t| t[:id].presence && t[:id].to_i }.compact

      # Remove tags not present in the form
      current_user.tags.where.not(id: tag_ids_from_params).destroy_all

      # Update or create tags
      tag_params.each do |tag_param|
        permitted = tag_param.permit(:id, :name, :color, :position)
        tag = current_user.tags.find_or_initialize_by(id: permitted[:id])
        tag.assign_attributes(permitted)
        tag.save!
      end
    end

    redirect_to master_cv_index_path, notice: "Tags updated successfully."
  rescue => e
    flash.now[:alert] = "Error updating tags: #{e.message}"
    @tags = current_user.tags.order(:position)
    render :edit, status: :unprocessable_entity
  end
end
