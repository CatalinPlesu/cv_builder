class SkillsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @skill_categories = current_user.skill_categories.includes(:skills).order(:position)
    if @skill_categories.empty?
      category = current_user.skill_categories.build
      skill = category.skills.build
      @skill_categories = [ category ]
    end
  end

  def upsert
    SkillCategory.transaction do
      skill_category_params = params[:skill_categories] || {}

      # Get the keys to iterate over
      category_keys = skill_category_params.keys

      # Get IDs from the parameters
      category_ids_from_params = category_keys.map do |key|
        cat_param = skill_category_params[key]
        cat_param[:id].presence && cat_param[:id].to_i
      end.compact

      # Delete categories not in the new list
      current_user.skill_categories.where.not(id: category_ids_from_params).destroy_all

      # Update or create each skill category
      category_keys.each do |key|
        cat_param = skill_category_params[key]

        # Permit category attributes
        category_permitted = cat_param.permit(:id, :name, :position)

        # Find or initialize the category
        category = current_user.skill_categories.find_or_initialize_by(id: category_permitted[:id])
        category.assign_attributes(category_permitted)
        category.save!

        # Handle skills - process skills parameter whether it exists or not
        # If skills parameter doesn't exist, we delete all skills
        if cat_param.key?(:skills)
          skill_params = cat_param[:skills] || {}

          # Get skill keys
          skill_keys = skill_params.keys

          skill_ids_from_params = skill_keys.map do |skill_key|
            skill_param = skill_params[skill_key]
            skill_param[:id].presence && skill_param[:id].to_i
          end.compact

          # Delete skills not in the new list for this category
          category.skills.where.not(id: skill_ids_from_params).destroy_all

          # Update or create each skill
          skill_keys.each do |skill_key|
            skill_param = skill_params[skill_key]
            skill_permitted = skill_param.permit(:id, :name, :position)
            # Skip empty skills
            next if skill_permitted[:name].blank?
            skill = category.skills.find_or_initialize_by(id: skill_permitted[:id])
            skill.assign_attributes(skill_permitted)
            skill.save!
          end
        else
          # If no skills parameter at all, delete all skills for this category
          category.skills.destroy_all
        end
      end
    end

    respond_to do |format|
      format.html do
        flash[:notice] = "Skills updated successfully."
        redirect_to master_cv_index_path
      end
      format.json { render json: { status: "success" } }
    end
  rescue => e
    Rails.logger.error "Error in SkillsController#upsert: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:alert] = "Error updating skills: #{e.message}"
        redirect_to edit_skills_path
      end
      format.json { render json: { status: "error", message: e.message }, status: :unprocessable_entity }
    end
  end
end
