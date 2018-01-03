class ResourceDecorator < Draper::Decorator
  delegate_all

  def rest_name
    "Rest#{name.parameterize(separator: '_', preserve_case: true).camelcase}"
  end

  def should_import_nullable_annotation
    resource_attributes.any?(&:nullable)
  end

  def should_import_java_list
    resource_attributes.any?(&:is_array)
  end

  def resource_attributes_by_name
    # Note: Clément Villain 29/12/17
    # We do the sorting in ruby and not with active record
    # because we want to keep non persited objects
    object.resource_attributes.sort_by(&:name)
  end

  def nullable_attributes
    @nullable_attributes ||= object.resource_attributes.where(nullable: true).decorate.sort_by(&:variable_name)
  end

  def mandatory_attributes
    @mandatory_attributes ||= object.resource_attributes.where.not(nullable: true).decorate.sort_by(&:variable_name)
  end
end