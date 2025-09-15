class TemplatesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @template = @user.templates.find(params[:id])

    # --- Define instance variables for HTML view ---
    # Initialize them as empty arrays by default
    @experiences = []
    @educations = []
    @projects = []
    @skill_categories = []
    @awards = []
    @certificates = []
    @organizations = []
    @coursework = []
    @hobbies = []

    begin
      # Get sections from template
      section_names = @template.sections.pluck(:name)

      # Get tag IDs from template
      tag_ids = @template.tag_ids

      # --- Build locals hash for .tex rendering (as before) ---
      locals = {
        user: @user,
        experiences: [],
        educations: [],
        projects: [],
        skills: []
        # Add others needed for .tex if applicable
      }

      # --- Assign data to instance variables for HTML view ---
      if section_names.include?("experience")
        @experiences = @user.experiences
                            .joins(:tags)
                            .where(tags: { id: tag_ids })
                            .distinct
                            .includes(:experience_bullets)
        locals[:experiences] = @experiences
      end

      if section_names.include?("education")
        @educations = @user.educations
                           .joins(:tags)
                           .where(tags: { id: tag_ids })
                           .distinct
        locals[:educations] = @educations
      end

      if section_names.include?("project")
        @projects = @user.projects
                         .joins(:tags)
                         .where(tags: { id: tag_ids })
                         .distinct
                         .includes(:project_bullets)
        locals[:projects] = @projects
      end

      if section_names.include?("skill")
        @skill_categories = @user.skill_categories
                                       .joins(:tags)
                                       .where(tags: { id: tag_ids })
                                       .distinct
                                       .includes(:skills)
        locals[:skill_categories] = @skill_categories
      end

      # Add similar blocks for awards, certificates, etc. if used in HTML view
      # Example for awards (adjust model/association names as needed):
      # if section_names.include?("award")
      #   @awards = @user.awards.joins(:tags).where(tags: { id: tag_ids }).distinct
      # end


      # Render the ERB template file directly for .tex format
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
      format.html {
        render layout: false
      }

      format.tex {
        send_data @rendered_content,
                  filename: "CV #{@user.cv_heading.full_name} #{@template.name}.tex",
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
