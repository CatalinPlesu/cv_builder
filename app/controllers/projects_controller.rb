class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @projects = current_user.projects.includes(:project_bullets).order(:position)
    if @projects.empty?
      project = current_user.projects.build
      @projects = [ project ]
    end
  end

  def upsert
    Project.transaction do
      project_params = params[:projects] || []

      # Handle array structure from form
      project_ids_from_params = project_params.map do |proj_param|
        proj_param[:id].presence && proj_param[:id].to_i
      end.compact

      # Delete projects not in the new list
      current_user.projects.where.not(id: project_ids_from_params).destroy_all

      # Update or create each project
      project_params.each do |proj_param|
        project_permitted = proj_param.permit(
          :id, :name, :link, :date, :link_title, :position
        )

        project = current_user.projects.find_or_initialize_by(id: project_permitted[:id])
        project.assign_attributes(project_permitted)
        project.save!

        # Handle bullets
        if proj_param.key?(:bullets)
          bullet_params = proj_param[:bullets] || {}

          # Check if bullets is an array or hash
          if bullet_params.is_a?(Array)
            # Handle array structure
            bullet_ids_from_params = bullet_params.map do |bullet_param|
              bullet_param[:id].presence && bullet_param[:id].to_i
            end.compact

            project.project_bullets.where.not(id: bullet_ids_from_params).destroy_all

            bullet_params.each do |bullet_param|
              bullet_permitted = bullet_param.permit(:id, :content, :position)
              next if bullet_permitted[:content].blank?

              bullet = project.project_bullets.find_or_initialize_by(id: bullet_permitted[:id])
              bullet.assign_attributes(bullet_permitted)
              bullet.save!
            end
          else
            # Handle hash structure (original way)
            bullet_keys = bullet_params.keys

            bullet_ids_from_params = bullet_keys.map do |bullet_key|
              bullet_param = bullet_params[bullet_key]
              bullet_param[:id].presence && bullet_param[:id].to_i
            end.compact

            project.project_bullets.where.not(id: bullet_ids_from_params).destroy_all

            bullet_keys.each do |bullet_key|
              bullet_param = bullet_params[bullet_key]
              bullet_permitted = bullet_param.permit(:id, :content, :position)
              next if bullet_permitted[:content].blank?

              bullet = project.project_bullets.find_or_initialize_by(id: bullet_permitted[:id])
              bullet.assign_attributes(bullet_permitted)
              bullet.save!
            end
          end
        else
          project.project_bullets.destroy_all
        end
      end
    end

    respond_to do |format|
      format.html do
        flash[:notice] = "Projects updated successfully."
        redirect_to master_cv_index_path
      end
      format.json { render json: { status: "success" } }
    end
  rescue => e
    Rails.logger.error "Error in ProjectsController#upsert: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:alert] = "Error updating projects: #{e.message}"
        redirect_to edit_projects_path
      end
      format.json { render json: { status: "error", message: e.message }, status: :unprocessable_entity }
    end
  end
end
