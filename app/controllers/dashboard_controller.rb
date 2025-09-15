class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @templates = current_user.templates.includes(:tags, :sections)
    @sections = Section.all
    @tags = current_user.tags
    @template = current_user.templates.new
  end

  def create_template
    # Get the name directly from params, not from template_params
    @template = current_user.templates.build(name: params[:name])

    if @template.save
      # Handle tag associations
      if params[:template] && params[:template][:tag_ids].present?
        tag_ids = params[:template][:tag_ids].reject(&:blank?).map(&:to_i)
        tags = Tag.where(id: tag_ids)
        tags.each { |tag| @template.tags << tag }
      end

      # Handle section associations
      if params[:template] && params[:template][:section_ids].present?
        section_ids = params[:template][:section_ids].reject(&:blank?).map(&:to_i)
        sections = Section.where(id: section_ids)
        sections.each { |section| @template.sections << section }
      else
        # Automatically add all sections if none are selected
        Section.all.each { |section| @template.sections << section }
      end

      redirect_to dashboard_path, notice: "Template '#{@template.name}' was successfully created."
    else
      # Always redirect to dashboard, even on error
      redirect_to dashboard_path, alert: "Error creating template: #{@template.errors.full_messages.join(', ')}"
    end
  end

  def update_template
    @template = current_user.templates.find(params[:id])

    # Update the name directly from params
    if @template.update(name: params[:template][:name])
      # Clear existing associations
      @template.tags.clear
      @template.sections.clear

      # Handle tag associations
      if params[:template][:tag_ids].present?
        tag_ids = params[:template][:tag_ids].reject(&:blank?).map(&:to_i)
        tags = Tag.where(id: tag_ids)
        tags.each { |tag| @template.tags << tag }
      end

      # Handle section associations
      if params[:template][:section_ids].present?
        section_ids = params[:template][:section_ids].reject(&:blank?).map(&:to_i)
        sections = Section.where(id: section_ids)
        sections.each { |section| @template.sections << section }
      end

      redirect_to dashboard_path, notice: "Template '#{@template.name}' was successfully updated."
    else
      # Always redirect to dashboard, even on error
      redirect_to dashboard_path, alert: "Error updating template: #{@template.errors.full_messages.join(', ')}"
    end
  end

  def delete_template
    @template = current_user.templates.find(params[:id])
    template_name = @template.name

    if @template.destroy
      redirect_to dashboard_path, notice: "Template '#{template_name}' was successfully deleted."
    else
      redirect_to dashboard_path, alert: "Error deleting template: #{@template.errors.full_messages.join(', ')}"
    end
  end

  private

  def template_params
    params.require(:template).permit(:name, tag_ids: [], section_ids: [])
  end
end
