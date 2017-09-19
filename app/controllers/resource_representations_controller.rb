class ResourceRepresentationsController < AuthenticatedController
  before_action :setup_project_and_resource, except: [:index]
  before_action :setup_resource_representation, except: [:index, :new, :create]

  def show
    respond_to do |format|
      format.html do
        render layout: 'full_width_column'
      end
      format.json_schema do
        render(
          json: @representation,
          serializer: ResourceRepresentationSchemaSerializer,
          adapter: :attributes,
          is_collection: ActiveModel::Type::Boolean.new.cast(params[:is_collection]),
          root_key: params[:root_key]
        )
      end
    end
  end

  def new
    @representation = @resource.resource_representations.build
    build_missing_attributes_resource_representations(@representation)
    render layout: 'generic'
  end

  def edit
    build_missing_attributes_resource_representations(@representation)
    render layout: 'generic'
  end

  def create
    @representation = @resource.resource_representations.build(resource_rep_params)
    if @representation.save
      redirect_to resource_resource_representation_path(@resource, @representation)
    else
      build_missing_attributes_resource_representations(@representation)
      render 'new', layout: 'generic', status: :unprocessable_entity
    end
  end

  def update
    if @representation.update(resource_rep_params)
      redirect_to resource_resource_representation_path(@resource, @representation)
    else
      build_missing_attributes_resource_representations(@representation)
      render 'edit', layout: 'generic', status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @representation.destroy

      redirect_to project_resource_path(@project, @resource)
    rescue ActiveRecord::InvalidForeignKey
      flash.now[:error] = t('activerecord.errors.models.resource_representation.attributes.base.destroy_failed_foreign_key')
      render 'show', layout: 'full_width_column', status: :conflict
    end
  end

  private

  def setup_project_and_resource
    @resource = Resource.find(params[:resource_id])
    @project = @resource.project
  end

  def setup_resource_representation
    @representation = ResourceRepresentation.find(params[:id])
  end

  def build_missing_attributes_resource_representations(resource_representation)
    @attributes_resource_representations_ordered_by_attribute_name = []
    @resource.resource_attributes.sorted_by_name.each do |attribute|
      attributes_resource_representation = resource_representation.attributes_resource_representations.detect {
       |arr| arr.attribute_id == attribute.id }
      unless attributes_resource_representation
        attributes_resource_representation = resource_representation.attributes_resource_representations
        .build(resource_attribute: attribute)
      end
      @attributes_resource_representations_ordered_by_attribute_name << attributes_resource_representation
    end
  end

  def resource_rep_params
    params.require(:resource_representation).permit(:name, :description,
      attributes_resource_representations_attributes: [:id, :custom_nullable, :custom_enum,
        :custom_pattern, :resource_representation_id, :is_required, :attribute_id, :_destroy])
  end
end
