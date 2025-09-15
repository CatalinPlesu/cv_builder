class ItemTaggingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @educations = @user.educations.includes(:tags)
    @experiences = @user.experiences.includes(:tags, experience_bullets: :tags)
    @projects = @user.projects.includes(:tags, project_bullets: :tags)
    @skill_categories = @user.skill_categories.includes(:tags, skills: :tags)
    @tags = @user.tags
  end

  def update
    user = current_user

    # Rails.logger.debug "Received params for update: #{params.inspect}" # Uncomment for debugging

    process_taggings(user, Education, params.dig(:items, :education))
    process_taggings(user, Experience, params.dig(:items, :experience))
    process_taggings(user, ExperienceBullet, params.dig(:items, :experience_bullet))
    process_taggings(user, Project, params.dig(:items, :project))
    process_taggings(user, ProjectBullet, params.dig(:items, :project_bullet))
    process_taggings(user, Skill, params.dig(:items, :skill))
    process_taggings(user, SkillCategory, params.dig(:items, :skill_category))

    redirect_to master_cv_index_path, notice: "Tags successfully updated!"
  end

  private


  def process_taggings(user, model_class, taggings_params)
    # Rails.logger.debug "Processing #{model_class.name} with params: #{taggings_params.inspect}" # Uncomment for debugging
    # return unless taggings_params # Don't return early if nil, we might need to clear all for this type

    # --- Fetch all items for this model belonging to the user (or accessible) ---
    items_scope = case model_class.name
    when "Skill"
                    Skill.joins(:skill_category).where(skill_categories: { user_id: user.id })
    when "SkillCategory"
                    user.skill_categories
    when "ExperienceBullet"
                    ExperienceBullet.joins(:experience).where(experiences: { user_id: user.id })
    when "ProjectBullet"
                    ProjectBullet.joins(:project).where(projects: { user_id: user.id })
    else # Education, Experience, Project
                    model_class.where(user_id: user.id)
    end

    # Get the IDs of *all* items of this type belonging to the user
    all_user_item_ids = items_scope.pluck(:id)
    # Get the IDs of items *mentioned* in the params
    param_item_ids = taggings_params ? taggings_params.keys.map(&:to_i) : []

    # Items explicitly mentioned in params
    items_to_update = items_scope.where(id: param_item_ids)
    items_hash = items_to_update.index_by(&:id)

    # Items NOT mentioned in params (potential candidates for clearing)
    potentially_cleared_item_ids = all_user_item_ids - param_item_ids
    potentially_cleared_items = items_scope.where(id: potentially_cleared_item_ids)

    # Process items explicitly sent in params
    if taggings_params
      taggings_params.each do |item_id, tag_data|
        item = items_hash[item_id.to_i]
        next unless item

        # Sanitize and validate tag IDs - Ensure it's always an array
        raw_tag_ids = tag_data[:tag_ids]
        tag_ids = if raw_tag_ids.nil? || (raw_tag_ids.respond_to?(:empty?) && raw_tag_ids.empty?)
                    [] # Treat nil or empty as explicitly wanting to remove all tags
        else
                    Array(raw_tag_ids).reject(&:blank?).map(&:to_i)
        end

        # --- Explicitly handle clearing vs. updating ---
        if tag_ids.empty?
          Rails.logger.debug "Clearing all tags for #{model_class.name} ID #{item.id} (from params)" # Indicate source
          item.tags.clear
        else
          # Get allowed tag IDs that belong to the user
          allowed_tag_ids = user.tags.where(id: tag_ids).pluck(:id)
          Rails.logger.debug "Updating #{model_class.name} ID #{item.id} with allowed_tag_ids: #{allowed_tag_ids.inspect}"

          result = item.update(tag_ids: allowed_tag_ids)
          unless result
            Rails.logger.warn "Failed to update #{model_class.name} ID #{item.id}: #{item.errors.full_messages.inspect}"
          end
        end
      end
    end

    # Process items NOT sent in params (assume clear all tags)
    potentially_cleared_items.find_each do |item|
      Rails.logger.debug "Clearing all tags for #{model_class.name} ID #{item.id} (implicitly, not in params)"
      item.tags.clear
    end
  end
end
