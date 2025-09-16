class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [ :show, :generate_pdf, :pdf_status ]

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
        cv_heading: @user.cv_heading,
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
                           .includes(:education_bullets)  # Add includes here too
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

  def generate_pdf
      pending_jobs_count = TemplatePdf.pending.count

      if pending_jobs_count >= 500
        render json: {
          success: false,
          error: "PDF generation queue is full (500 jobs). Please try again later."
        }, status: :service_unavailable
        return
      end

      # Find or create the template PDF
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

        render json: {
          success: true,
          template_pdf_id: template_pdf.id,
          status: template_pdf.status,
          queue_position: template_pdf.queue_position,
          message: "PDF generation queued! Position ##{template_pdf.queue_position} in queue."
        }
      rescue => e
        template_pdf.update!(status: "failed", error_message: e.message)

        render json: {
          success: false,
          error: "Failed to queue PDF generation: #{e.message}"
        }, status: :unprocessable_entity
      end
  end

  def pdf_status
      template_pdf = @template.template_pdf

      if template_pdf
        render json: {
          status: template_pdf.status,
          queue_position: template_pdf.queue_position,
          completed_at: template_pdf.completed_at,
          started_at: template_pdf.started_at,
          pdf_size: template_pdf.pdf_size,
          pdf_size_human: template_pdf.pdf_size_human,
          estimated_wait_time_human: template_pdf.estimated_wait_time_human,
          updated_at: template_pdf.updated_at,
          pdf_id: template_pdf.id,
          has_pdf: template_pdf.pdf_file.attached?
        }
      else
        render json: { status: "not_generated" }
      end
  end

  private

  def set_template
    @template = current_user.templates.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:name, :content)
  end
end
