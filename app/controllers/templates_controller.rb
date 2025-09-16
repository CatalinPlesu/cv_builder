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

    format.pdf {
      pending_jobs_count = TemplatePdf.pending.count

      if pending_jobs_count >= 500
        redirect_to template_path(@template),
                   alert: "PDF generation queue is full (500 jobs). Please try again later."
        return
      end

      # Find or create the template PDF - this ensures 1:1 relationship
      template_pdf = @template.template_pdf || @template.build_template_pdf(
        user: current_user,
        status: "pending"
      )

      # If it already exists but is completed/failed, update it for regeneration
      unless template_pdf.pending? || template_pdf.processing?
        template_pdf.status = "pending"
        template_pdf.error_message = nil
        template_pdf.started_at = nil
        template_pdf.completed_at = nil
        template_pdf.save!
      end

      # Queue the job
      begin
        PdfGenerationJob.perform_later(template_pdf.id)
        redirect_to template_pdf_path(template_pdf),
                   notice: "PDF generation queued! Position ##{template_pdf.queue_position} in queue."
      rescue => e
        template_pdf.update!(status: "failed", error_message: e.message)
        redirect_to template_path(@template),
                   alert: "Failed to queue PDF generation: #{e.message}"
      end
    }
    end
  end

  private

  def template_params
    params.require(:template).permit(:name, :content)
  end
end
