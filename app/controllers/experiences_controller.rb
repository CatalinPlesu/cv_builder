class ExperiencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @experiences = current_user.experiences.includes(:experience_bullets).order(:position)
    if @experiences.empty?
      experience = current_user.experiences.build
      @experiences = [ experience ]
    end
  end

  def upsert
    Experience.transaction do
      experience_params = params[:experiences] || {}

      # Get the keys to iterate over
      experience_keys = experience_params.keys

      # Get IDs from the parameters
      experience_ids_from_params = experience_keys.map do |key|
        exp_param = experience_params[key]
        exp_param[:id].presence && exp_param[:id].to_i
      end.compact

      # Delete experiences not in the new list
      current_user.experiences.where.not(id: experience_ids_from_params).destroy_all

      # Update or create each experience item
      experience_keys.each do |key|
        exp_param = experience_params[key]

        # Permit experience attributes
        experience_permitted = exp_param.permit(
          :id, :company, :location, :position_title, :start_date, :end_date, :current, :position
        )

        # Find or initialize the experience
        experience = current_user.experiences.find_or_initialize_by(id: experience_permitted[:id])
        experience.assign_attributes(experience_permitted)
        experience.save!

        # Handle bullets - process bullets parameter whether it exists or not
        # If bullets parameter doesn't exist, we delete all bullets
        if exp_param.key?(:bullets)
          bullet_params = exp_param[:bullets] || {}

          # Get bullet keys
          bullet_keys = bullet_params.keys

          bullet_ids_from_params = bullet_keys.map do |bullet_key|
            bullet_param = bullet_params[bullet_key]
            bullet_param[:id].presence && bullet_param[:id].to_i
          end.compact

          # Delete bullets not in the new list for this experience
          experience.experience_bullets.where.not(id: bullet_ids_from_params).destroy_all

          # Update or create each bullet
          bullet_keys.each do |bullet_key|
            bullet_param = bullet_params[bullet_key]
            bullet_permitted = bullet_param.permit(:id, :content, :position)
            # Skip empty bullets
            next if bullet_permitted[:content].blank?
            bullet = experience.experience_bullets.find_or_initialize_by(id: bullet_permitted[:id])
            bullet.assign_attributes(bullet_permitted)
            bullet.save!
          end
        else
          # If no bullets parameter at all, delete all bullets for this experience
          experience.experience_bullets.destroy_all
        end
      end
    end

    respond_to do |format|
      format.html do
        flash[:notice] = "Experience updated successfully."
        redirect_to master_cv_index_path
      end
      format.json { render json: { status: "success" } }
    end
  rescue => e
    Rails.logger.error "Error in ExperiencesController#upsert: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:alert] = "Error updating experience: #{e.message}"
        redirect_to edit_experiences_path
      end
      format.json { render json: { status: "error", message: e.message }, status: :unprocessable_entity }
    end
  end
end
