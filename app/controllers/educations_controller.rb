class EducationsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @educations = current_user.educations.order(:position)
    if @educations.empty?
      @educations = [ current_user.educations.build ]
    end
  end

  def upsert
    Education.transaction do # Assuming 'Educations' is a valid model or constant for scoping transaction. Consider using 'ActiveRecord::Base.transaction' or scoping to the user's educations association if needed.
      education_params = params[:educations] || []
      education_ids_from_params = education_params.map { |edu_params| edu_params[:id].presence && edu_params[:id].to_i }.compact

      # Delete educations not in the new list
      current_user.educations.where.not(id: education_ids_from_params).destroy_all

      # Update or create each education item
      # Use .each instead of .each_with_index because position comes from params
      education_params.each do |edu_param|
        # Permit ALL attributes coming from the form, including :position
        permitted_params = edu_param.permit(:id, :institution, :location, :degree, :start_date, :end_date, :gpa, :additional_info, :position)

        # Find or initialize the record
        education = current_user.educations.find_or_initialize_by(id: permitted_params[:id])

        # Assign all permitted attributes, including the position from the form
        education.assign_attributes(permitted_params)

        # Save the record (will raise if invalid)
        education.save!
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
