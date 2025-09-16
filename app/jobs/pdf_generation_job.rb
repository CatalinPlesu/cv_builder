class PdfGenerationJob < ApplicationJob
  queue_as :default

  # Retry up to 3 times with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(template_pdf_id)
    template_pdf = TemplatePdf.find(template_pdf_id)

    Rails.logger.info "Starting PDF generation for TemplatePdf ID: #{template_pdf_id}"
    Rails.logger.info "Template: #{template_pdf.template.name}"
    Rails.logger.info "User: #{template_pdf.user.email}"

    # Add this check
    if template_pdf.user.nil?
      raise "TemplatePdf #{template_pdf_id} has no associated user (user_id: #{template_pdf.user_id})"
    end

    begin
      # Update status to processing
      template_pdf.update!(status: "processing", started_at: Time.current)
      Rails.logger.info "Updated status to processing"

      # Generate the LaTeX content
      logger.info "#{template_pdf.user}"
      latex_content = generate_latex_content(template_pdf.user, template_pdf.template)
      Rails.logger.info "Generated LaTeX content (#{latex_content.length} characters)"

      # Compile LaTeX to PDF
      pdf_path = compile_latex_to_pdf(latex_content, template_pdf)
      Rails.logger.info "Compiled PDF to: #{pdf_path}"

      # Store the PDF file
      store_pdf_file(template_pdf, pdf_path, template_pdf.pdf_filename)
      Rails.logger.info "Stored PDF file"

      # Update job status to completed
      template_pdf.update!(
        status: "completed",
        completed_at: Time.current
      )
      Rails.logger.info "PDF generation completed successfully"

    rescue => e
      Rails.logger.error "PDF Generation failed for TemplatePdf #{template_pdf_id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      template_pdf.update!(
        status: "failed",
        error_message: e.message,
        completed_at: Time.current
      )
      raise e
    end
  end

  private

  def generate_latex_content(user, template)
    # This mimics what your TemplatesController#show does
    section_names = template.sections.pluck(:name)
    tag_ids = template.tag_ids

    locals = {
      user: user,
      cv_heading: user.cv_heading,
      experiences: [],
      educations: [],
      projects: [],
      skills: []
    }

    # Build the same locals hash as your controller
    if section_names.include?("experience")
      locals[:experiences] = user.experiences
                                .joins(:tags)
                                .where(tags: { id: tag_ids })
                                .distinct
                                .includes(:experience_bullets)
    end

    if section_names.include?("education")
      locals[:educations] = user.educations
                               .joins(:tags)
                               .where(tags: { id: tag_ids })
                               .distinct
    end

    if section_names.include?("project")
      locals[:projects] = user.projects
                             .joins(:tags)
                             .where(tags: { id: tag_ids })
                             .distinct
                             .includes(:project_bullets)
    end

    if section_names.include?("skill")
      locals[:skill_categories] = user.skill_categories
                                     .joins(:tags)
                                     .where(tags: { id: tag_ids })
                                     .distinct
                                     .includes(:skills)
    end

    # Render the template
    ApplicationController.render(
      template: "templates/show",
      formats: [ :tex ],
      locals: locals
    )
  end

  def compile_latex_to_pdf(latex_content, cv_job)
    # Create a temporary directory for this job
    temp_dir = Rails.root.join("tmp", "pdf_generation", cv_job.id.to_s)
    FileUtils.mkdir_p(temp_dir)

    # Write LaTeX content to file
    tex_file = File.join(temp_dir, "cv.tex")
    File.write(tex_file, latex_content)

    # Determine PDF compilation method
    if docker_available?
      compile_with_docker(tex_file, temp_dir)
    else
      compile_with_local_pdflatex(tex_file, temp_dir)
    end

    pdf_file = File.join(temp_dir, "cv.pdf")

    unless File.exist?(pdf_file)
      raise "PDF compilation failed - output file not found"
    end

    pdf_file
  end

  def docker_available?
    # Check if Docker is available and your image exists
    system("docker --version > /dev/null 2>&1") &&
    system("docker images | grep -q your-pdflatex-image > /dev/null 2>&1")
  end

  def compile_with_docker(tex_file, temp_dir)
    # Adjust this command based on your Docker image
    docker_cmd = [
      "docker", "run", "--rm",
      "-v", "#{temp_dir}:/workspace",
      "your-pdflatex-image",  # Replace with your actual image name
      "pdflatex",
      "-interaction=nonstopmode",
      "-output-directory=/workspace",
      "/workspace/cv.tex"
    ]

    Rails.logger.info "Running Docker command: #{docker_cmd.join(' ')}"

    result = system(*docker_cmd, chdir: temp_dir)

    unless result
      raise "Docker pdflatex compilation failed"
    end
  end

    def compile_with_local_pdflatex(tex_file, temp_dir)
      # Convert Pathnames to Strings
      temp_dir_str = temp_dir.to_s
      tex_file_str = tex_file.to_s

      pdflatex_cmd = [
        "pdflatex",
        "-interaction=nonstopmode",
        "-output-directory", temp_dir_str, # Use String
        tex_file_str                       # Use String
      ]

      Rails.logger.info "Running pdflatex command: #{pdflatex_cmd.join(' ')}"

      # Pass the string versions and use string for chdir as well
      result = system(*pdflatex_cmd, chdir: temp_dir_str)

      unless result
        raise "Local pdflatex compilation failed"
      end
    end

  def store_pdf_file(cv_job, pdf_path, pdf_filename)
    # Attach the PDF file using Active Storage
    cv_job.pdf_file.attach(
      io: File.open(pdf_path),
      filename: pdf_filename,
      content_type: "application/pdf"
    )

    # Clean up temp directory
    temp_dir = File.dirname(pdf_path)
    FileUtils.rm_rf(temp_dir)

    Rails.logger.info "PDF attached successfully for CvJob #{cv_job.id}"
  end
end
