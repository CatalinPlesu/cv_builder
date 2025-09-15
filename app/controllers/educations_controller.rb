class EducationsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @educations = current_user.educations.includes(:education_bullets).order(:position)
    if @educations.empty?
      education = current_user.educations.build
      @educations = [ education ]
    end
  end

  def upsert
    Education.transaction do
      education_params = params[:educations] || {}

      # Get the keys to iterate over
      education_keys = education_params.keys

      # Get IDs from the parameters
      education_ids_from_params = education_keys.map do |key|
        edu_param = education_params[key]
        edu_param[:id].presence && edu_param[:id].to_i
      end.compact

      # Delete educations not in the new list
      current_user.educations.where.not(id: education_ids_from_params).destroy_all

      # Update or create each education item
      education_keys.each do |key|
        edu_param = education_params[key]

        # Permit education attributes
        education_permitted = edu_param.permit(
          :id, :institution, :location, :degree, :start_date, :end_date, :gpa, :additional_info, :position
        )

        # Find or initialize the education
        education = current_user.educations.find_or_initialize_by(id: education_permitted[:id])
        education.assign_attributes(education_permitted)
        education.save!

        # Handle bullets - process bullets parameter whether it exists or not
        # If bullets parameter doesn't exist, we delete all bullets
        if edu_param.key?(:bullets)
          bullet_params = edu_param[:bullets] || {}

          # Get bullet keys
          bullet_keys = bullet_params.keys

          bullet_ids_from_params = bullet_keys.map do |bullet_key|
            bullet_param = bullet_params[bullet_key]
            bullet_param[:id].presence && bullet_param[:id].to_i
          end.compact

          # Delete bullets not in the new list for this education
          education.education_bullets.where.not(id: bullet_ids_from_params).destroy_all

          # Update or create each bullet
          bullet_keys.each do |bullet_key|
            bullet_param = bullet_params[bullet_key]
            bullet_permitted = bullet_param.permit(:id, :content, :position)
            # Skip empty bullets
            next if bullet_permitted[:content].blank?
            bullet = education.education_bullets.find_or_initialize_by(id: bullet_permitted[:id])
            bullet.assign_attributes(bullet_permitted)
            bullet.save!
          end
        else
          # If no bullets parameter at all, delete all bullets for this education
          education.education_bullets.destroy_all
        end
      end
    end

    respond_to do |format|
      format.html do
        flash[:notice] = "Education updated successfully."
        redirect_to master_cv_index_path
      end
      format.json { render json: { status: "success" } }
    end
  rescue => e
    # Log the error for debugging
    Rails.logger.error "Error in EducationsController#upsert: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:alert] = "Error updating education: #{e.message}" # Display error to user
        redirect_to edit_educations_path # Redirect back to the form
      end
      format.json { render json: { status: "error", message: e.message }, status: :unprocessable_entity }
    end
  end
end
