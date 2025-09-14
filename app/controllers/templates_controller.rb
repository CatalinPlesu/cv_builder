class TemplatesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user

    begin
      # Create binding with available variables
      binding_obj = binding
      binding_obj.local_variable_set(:user, @user)
      # Add empty arrays for other data types you'll implement later
      binding_obj.local_variable_set(:experiences, [])
      binding_obj.local_variable_set(:educations, [])
      binding_obj.local_variable_set(:projects, [])
      binding_obj.local_variable_set(:skills, [])

      # Render the ERB template file directly
      @rendered_content = render_to_string(
        template: "templates/show",
        formats: [ :tex ],
        locals: {
          user: @user,
          experiences: [],
          educations: [],
          projects: [],
          skills: []
        }
      )

    rescue => e
      @error = "Template Error: #{e.message}"
      @rendered_content = "Error rendering template: #{e.message}"
    end

    # Handle different formats
    respond_to do |format|
      format.html # renders show.html.erb

      format.tex {
        send_data @rendered_content,
                 filename: "resume_#{params[:id]}.tex",
                 type: "text/plain",
                 disposition: "attachment"  # This will download the file
      }

      format.txt {
        render plain: @rendered_content, content_type: "text/plain"  # This will display in browser
      }
    end
  end

  private

  def template_params
    params.require(:template).permit(:name, :content)
  end
end
