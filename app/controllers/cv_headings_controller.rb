class CvHeadingsController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_heading, only: %i[ edit ]

  def edit
    @cv_heading = current_user.cv_heading # or however you fetch it
    @full_name = @cv_heading&.full_name || ""
    @heading_items = @cv_heading&.cv_heading_items&.order(:position) || []

    # Convert to the format your template expects
    @heading_items = @heading_items.map do |item|
      {
        icon: item.icon,
        text: item.text,
        url: item.url
      }
    end

    # Ensure at least one empty item if none exist
    @heading_items = [ { icon: "", text: "", url: "" } ] if @heading_items.empty?
  end

  def upsert
    @cv_heading = current_user.cv_heading || current_user.build_cv_heading

    CvHeading.transaction do
      @cv_heading.assign_attributes(cv_heading_params)
      @cv_heading.save!

      # Get the list of item IDs from params (if any)
      item_params = params[:heading_items] || []
      item_ids_from_params = item_params.map { |item| item[:id].to_i }.compact

      # Delete items not in the new list
      @cv_heading.cv_heading_items.where.not(id: item_ids_from_params).destroy_all

      # Update or create each item
      item_params.each do |item_param|
        item_param = item_param.permit(:id, :icon, :text, :position, :url)
        item = @cv_heading.cv_heading_items.find_or_initialize_by(id: item_param[:id])
        item.assign_attributes(item_param)
        item.save!
      end
    end

    respond_to do |format|
      format.html do
        flash[:notice] = "CV heading updated successfully."
        redirect_to master_cv_index_path
      end
      format.json { render json: { status: "success", cv_heading: @cv_heading } }
    end
  rescue => e
    respond_to do |format|
      format.html do
        flash[:alert] = "Error updating CV heading: #{e.message}"
        redirect_to master_cv_index_path
      end
      format.json { render json: { status: "error", message: e.message }, status: :unprocessable_entity }
    end
  end

private

def cv_heading_params
  params.require(:cv_heading).permit(:full_name)
end

  private
    def set_heading
      @full_name = current_user.cv_heading.full_name
      @heading_items = current_user.cv_heading.cv_heading_items
    end
end
