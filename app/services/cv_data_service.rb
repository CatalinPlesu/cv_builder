class CvDataService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Export user's CV data to JSON
  def export
    {
      version: "1.0",
      exported_at: Time.current.iso8601,
      data: {
        heading: export_heading,
        educations: export_educations,
        experiences: export_experiences,
        projects: export_projects,
        skill_categories: export_skill_categories,
        tags: export_tags,
        templates: export_templates
      }
    }
  end

  # Import CV data from JSON, replacing existing data
  def import(json_data)
    data = parse_and_validate(json_data)

    ActiveRecord::Base.transaction do
      # Clear existing data
      clear_existing_data

      # Import new data
      import_tags(data.dig("data", "tags") || [])
      import_heading(data.dig("data", "heading"))
      import_educations(data.dig("data", "educations") || [])
      import_experiences(data.dig("data", "experiences") || [])
      import_projects(data.dig("data", "projects") || [])
      import_skill_categories(data.dig("data", "skill_categories") || [])
      import_templates(data.dig("data", "templates") || [])
    end

    true
  rescue StandardError => e
    Rails.logger.error "Import failed: #{e.message}"
    raise ActiveRecord::Rollback
  end

  private

  # Export methods
  def export_heading
    return nil unless user.cv_heading

    {
      "full_name" => user.cv_heading.full_name,
      "items" => user.cv_heading.cv_heading_items.order(:position).map do |item|
        {
          "icon" => item.icon,
          "text" => item.text,
          "url" => item.url,
          "position" => item.position
        }
      end
    }
  end

  def export_educations
    user.educations.order(:position).map do |edu|
      {
        "institution" => edu.institution,
        "degree" => edu.degree,
        "location" => edu.location,
        "start_date" => edu.start_date&.iso8601,
        "end_date" => edu.end_date&.iso8601,
        "gpa" => edu.gpa,
        "position" => edu.position,
        "bullets" => edu.education_bullets.order(:position).map do |bullet|
          {
            "content" => bullet.content,
            "position" => bullet.position
          }
        end,
        "tag_names" => edu.tags.pluck(:name)
      }
    end
  end

  def export_experiences
    user.experiences.order(:position).map do |exp|
      {
        "company" => exp.company,
        "position_title" => exp.position_title,
        "location" => exp.location,
        "start_date" => exp.start_date&.iso8601,
        "end_date" => exp.end_date&.iso8601,
        "current" => exp.current,
        "position" => exp.position,
        "bullets" => exp.experience_bullets.order(:position).map do |bullet|
          {
            "content" => bullet.content,
            "position" => bullet.position,
            "tag_names" => bullet.tags.pluck(:name)
          }
        end,
        "tag_names" => exp.tags.pluck(:name)
      }
    end
  end

  def export_projects
    user.projects.order(:position).map do |proj|
      {
        "name" => proj.name,
        "link" => proj.link,
        "link_title" => proj.link_title,
        "start_date" => proj.start_date&.iso8601,
        "end_date" => proj.end_date&.iso8601,
        "position" => proj.position,
        "bullets" => proj.project_bullets.order(:position).map do |bullet|
          {
            "content" => bullet.content,
            "position" => bullet.position,
            "tag_names" => bullet.tags.pluck(:name)
          }
        end,
        "tag_names" => proj.tags.pluck(:name)
      }
    end
  end

  def export_skill_categories
    user.skill_categories.order(:position).map do |cat|
      {
        "name" => cat.name,
        "position" => cat.position,
        "skills" => cat.skills.order(:position).map do |skill|
          {
            "name" => skill.name,
            "position" => skill.position,
            "tag_names" => skill.tags.pluck(:name)
          }
        end,
        "tag_names" => cat.tags.pluck(:name)
      }
    end
  end

  def export_tags
    user.tags.order(:position).map do |tag|
      {
        "name" => tag.name,
        "color" => tag.color,
        "position" => tag.position
      }
    end
  end

  def export_templates
    user.templates.map do |template|
      {
        "name" => template.name,
        "tag_names" => template.tags.pluck(:name),
        "section_names" => template.sections.pluck(:name)
      }
    end
  end

  # Import methods
  def parse_and_validate(json_data)
    data = JSON.parse(json_data)

    unless data["version"] && data["data"]
      raise StandardError, "Invalid CV data format"
    end

    data
  end

  def clear_existing_data
    # Delete in order to handle dependencies
    user.templates.destroy_all
    user.projects.destroy_all
    user.experiences.destroy_all
    user.educations.destroy_all
    user.skill_categories.destroy_all
    user.cv_heading&.cv_heading_items&.destroy_all
    user.cv_heading&.destroy
    user.tags.destroy_all
  end

  def import_tags(tags_data)
    @tag_mapping = {}

    tags_data.each_with_index do |tag_data, index|
      tag = user.tags.create!(
        name: tag_data["name"],
        color: tag_data["color"],
        position: tag_data["position"] || index
      )
      @tag_mapping[tag_data["name"]] = tag
    end
  end

  def import_heading(heading_data)
    return unless heading_data

    heading = user.create_cv_heading!(
      full_name: heading_data["full_name"]
    )

    # Import cv_heading_items
    (heading_data["items"] || []).each_with_index do |item_data, index|
      heading.cv_heading_items.create!(
        icon: item_data["icon"],
        text: item_data["text"],
        url: item_data["url"],
        position: item_data["position"] || index
      )
    end
  end

  def import_educations(educations_data)
    educations_data.each_with_index do |edu_data, index|
      education = user.educations.create!(
        institution: edu_data["institution"],
        degree: edu_data["degree"],
        location: edu_data["location"],
        start_date: parse_date(edu_data["start_date"]),
        end_date: parse_date(edu_data["end_date"]),
        gpa: edu_data["gpa"],
        position: edu_data["position"] || index
      )

      # Import education bullets
      (edu_data["bullets"] || []).each_with_index do |bullet_data, bullet_index|
        education.education_bullets.create!(
          content: bullet_data["content"],
          position: bullet_data["position"] || bullet_index
        )
      end

      assign_tags(education, edu_data["tag_names"])
    end
  end

  def import_experiences(experiences_data)
    experiences_data.each_with_index do |exp_data, index|
      experience = user.experiences.create!(
        company: exp_data["company"],
        position_title: exp_data["position_title"],
        location: exp_data["location"],
        start_date: parse_date(exp_data["start_date"]),
        end_date: parse_date(exp_data["end_date"]),
        current: exp_data["current"] || false,
        position: exp_data["position"] || index
      )

      # Import experience bullets with their tags
      (exp_data["bullets"] || []).each_with_index do |bullet_data, bullet_index|
        bullet = experience.experience_bullets.create!(
          content: bullet_data["content"],
          position: bullet_data["position"] || bullet_index
        )
        assign_tags(bullet, bullet_data["tag_names"])
      end

      assign_tags(experience, exp_data["tag_names"])
    end
  end

  def import_projects(projects_data)
    projects_data.each_with_index do |proj_data, index|
      project = user.projects.create!(
        name: proj_data["name"],
        link: proj_data["link"],
        link_title: proj_data["link_title"],
        start_date: parse_date(proj_data["start_date"]),
        end_date: parse_date(proj_data["end_date"]),
        position: proj_data["position"] || index
      )

      # Import project bullets with their tags
      (proj_data["bullets"] || []).each_with_index do |bullet_data, bullet_index|
        bullet = project.project_bullets.create!(
          content: bullet_data["content"],
          position: bullet_data["position"] || bullet_index
        )
        assign_tags(bullet, bullet_data["tag_names"])
      end

      assign_tags(project, proj_data["tag_names"])
    end
  end

  def import_skill_categories(skill_categories_data)
    skill_categories_data.each_with_index do |cat_data, index|
      category = user.skill_categories.create!(
        name: cat_data["name"],
        position: cat_data["position"] || index
      )

      # Import skills with their tags
      (cat_data["skills"] || []).each_with_index do |skill_data, skill_index|
        skill = category.skills.create!(
          name: skill_data["name"],
          position: skill_data["position"] || skill_index
        )
        assign_tags(skill, skill_data["tag_names"])
      end

      assign_tags(category, cat_data["tag_names"])
    end
  end

  def import_templates(templates_data)
    templates_data.each do |template_data|
      template = user.templates.create!(
        name: template_data["name"]
      )

      # Assign tags
      assign_tags(template, template_data["tag_names"])

      # Assign sections if they exist
      if template_data["section_names"].present?
        sections = Section.where(name: template_data["section_names"])
        template.sections = sections if sections.any?
      end
    end
  end

  def assign_tags(model, tag_names)
    return unless tag_names.present?

    tags = tag_names.map { |name| @tag_mapping[name] }.compact
    model.tags = tags if tags.any?
  end

  def parse_date(date_string)
    return nil unless date_string.present?
    Date.parse(date_string)
  rescue StandardError
    nil
  end
end
