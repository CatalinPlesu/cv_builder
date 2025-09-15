class TemplatesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @template = @user.templates.find(params[:id])

    begin
      # Get sections from template
      section_names = @template.sections.pluck(:name)

      # Get tag IDs from template
      tag_ids = @template.tag_ids

      # Build locals hash based on sections & tags
      locals = {
        user: @user,
        experiences: [],
        educations: [],
        projects: [],
        skills: []
      }

      if section_names.include?("experience")
        locals[:experiences] = @user.experiences
                                    .joins(:tags)
                                    .where(tags: { id: tag_ids })
                                    .distinct
                                    .includes(:experience_bullets)
      end

      if section_names.include?("education")
        locals[:educations] = @user.educations
                                   .joins(:tags)
                                   .where(tags: { id: tag_ids })
                                   .distinct
      end

      if section_names.include?("project")
        locals[:projects] = @user.projects
                                 .joins(:tags)
                                 .where(tags: { id: tag_ids })
                                 .distinct
                                 .includes(:project_bullets)
      end

      if section_names.include?("skill")
        locals[:skills] = @user.skill_categories
                                .joins(:tags)
                                .where(tags: { id: tag_ids })
                                .distinct
                                .includes(:skills)
                                .flat_map(&:skills)
      end

      # Render the ERB template file directly
      @rendered_content = render_to_string(
        template: "templates/show",
        formats: [ :tex ],
        locals: locals
      )

    rescue => e
      @error = "Template Error: #{e.message}"
      @rendered_content = "Error rendering template: #{e.message}"
    end

    respond_to do |format|
      format.html # renders show.html.erb

      format.tex {
        send_data @rendered_content,
                  filename: "resume_#{@template.id}.tex",
                  type: "text/plain",
                  disposition: "attachment"
      }

      format.txt {
        render plain: @rendered_content, content_type: "text/plain"
      }
    end
  end

  private

  def template_params
    params.require(:template).permit(:name, :content)
  end
end
