class CvDataController < ApplicationController
  before_action :authenticate_user!

  # GET /cv_data/export
  def export
    service = CvDataService.new(current_user)
    cv_data = service.export

    respond_to do |format|
      format.json do
        send_data cv_data.to_json,
                  filename: "master_cv for cv-builder; #{current_user.email}; #{DateTime.current.strftime("%Y-%m-%d-%H-%M")}.json",
                  type: "application/json",
                  disposition: "attachment"
      end
    end
  end

  # GET /cv_data/import (shows import form)
  def new_import
    # Renders a form for file upload
  end

  # POST /cv_data/import
  def import
    unless params[:file].present?
      redirect_to new_import_cv_data_path, alert: "Please select a file to import"
      return
    end

    begin
      json_content = params[:file].read
      service = CvDataService.new(current_user)

      if service.import(json_content)
        redirect_to dashboard_path, notice: "CV data imported successfully!"
      else
        redirect_to new_import_cv_data_path, alert: "Import failed. Please check your file format."
      end
    rescue JSON::ParserError => e
      redirect_to new_import_cv_data_path, alert: "Invalid JSON file"
    rescue StandardError => e
      Rails.logger.error "Import error: #{e.message}"
      redirect_to new_import_cv_data_path, alert: "Import failed: #{e.message}"
    end
  end

  def import_demo
    begin
      demo_file_path = Rails.root.join("app/assets/demo.json")
      json_content = File.read(demo_file_path)
      service = CvDataService.new(current_user)

      if service.import(json_content)
        redirect_to dashboard_path, notice: "Demo CV data imported successfully!"
      else
        redirect_to new_import_cv_data_path, alert: "Demo import failed."
      end
    rescue JSON::ParserError => e
      redirect_to new_import_cv_data_path, alert: "Invalid demo JSON file."
    rescue StandardError => e
      Rails.logger.error "Demo import error: #{e.message}"
      redirect_to new_import_cv_data_path, alert: "Import failed: #{e.message}"
    end
  end

  # POST /cv_data/import_json (for API usage)
  def import_json
    begin
      service = CvDataService.new(current_user)

      if service.import(params[:cv_data].to_json)
        render json: { success: true, message: "CV data imported successfully" }
      else
        render json: { success: false, message: "Import failed" }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { success: false, message: e.message }, status: :unprocessable_entity
    end
  end
end
