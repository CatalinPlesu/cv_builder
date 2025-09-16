class TemplatePdfsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template_pdf, only: [ :show, :download, :destroy ]

  def show
    respond_to do |format|
      format.html
      format.json {
        render json: {
          id: @template_pdf.id,
          status: @template_pdf.status,
          error_message: @template_pdf.error_message,
          pdf_available: @template_pdf.pdf_available?,
          created_at: @template_pdf.created_at,
          completed_at: @template_pdf.completed_at,
          duration: @template_pdf.duration,
          queue_position: @template_pdf.queue_position,
          estimated_wait_time: @template_pdf.estimated_wait_time,
          estimated_wait_time_human: @template_pdf.estimated_wait_time_human
        }
      }
    end
  end

  def download
    unless @template_pdf.pdf_available?
      redirect_to template_path(@template_pdf.template), alert: "PDF is not ready for download"
      return
    end

    redirect_to rails_blob_path(@template_pdf.pdf_file, disposition: "attachment")
  end

  def destroy
    template = @template_pdf.template
    @template_pdf.destroy
    redirect_to template_path(template), notice: "PDF deleted successfully"
  end

  private

  def set_template_pdf
    @template_pdf = TemplatePdf.joins(:template)
                               .where(templates: { user: current_user })
                               .find(params[:id])
  end
end
