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

    # Instead of writing tex file and using local compilation,
    # call the HTTP service and write the result to a PDF file
    pdf_data = compile_with_http_service(latex_content)

    # Write PDF data to file to maintain same interface
    pdf_file = File.join(temp_dir, "cv.pdf")
    File.write(pdf_file, pdf_data, mode: "wb")

    unless File.exist?(pdf_file)
      raise "PDF compilation failed - output file not found"
    end

    pdf_file
  end

  def compile_with_http_service(latex_content)
    require "net/http"
    require "uri"
    require "json"

    service_url = latex_service_url
    uri = URI.parse("#{service_url}/compile")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 60 # 60 second timeout for PDF compilation

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = { latex: latex_content }.to_json

    Rails.logger.info "Sending LaTeX compilation request to #{service_url}"

    response = http.request(request)

    case response.code.to_i
    when 200
      Rails.logger.info "PDF compilation successful via HTTP service"
      response.body
    when 400
      error_data = JSON.parse(response.body) rescue { "error" => "Invalid request" }
      raise "LaTeX compilation failed: #{error_data['error']}"
    when 500
      error_data = JSON.parse(response.body) rescue { "error" => "Internal server error" }
      raise "LaTeX service error: #{error_data['error']}"
    else
      raise "LaTeX service returned unexpected status: #{response.code}"
    end
  rescue Net::TimeoutError
    raise "LaTeX service timeout - compilation took too long"
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
    raise "Cannot connect to LaTeX service at #{service_url}"
  rescue JSON::ParserError
    raise "Invalid response from LaTeX service"
  end

  def latex_service_url
    # Check for environment variable first (for external service)
    if ENV["LATEX_SERVICE_URL"].present?
      ENV["LATEX_SERVICE_URL"]
    else
      # Default to Docker Compose service name
      "http://latex-service:3001"
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
