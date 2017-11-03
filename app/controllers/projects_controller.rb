require 'zip'

class ProjectsController < AuthenticatedController
  layout 'full_width_column', only: [:show, :edit]
  before_action :setup_project, except: [:index, :new, :create]

  def index
    @projects = Project.all
  end

  def show
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project
    else
      render 'new', status: :unprocessable_entity
    end

  end

  def update
    if @project.update(project_params)
      redirect_to @project
    else
      render 'edit', layout: 'full_width_column', status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy

    redirect_to projects_path
  end

  private

  def setup_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :proxy_url)
  end

end
