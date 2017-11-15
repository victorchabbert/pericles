class MockPicker < ApplicationRecord
  belongs_to :mock_profile
  belongs_to :response

  has_and_belongs_to_many :resource_instances

  validates :body_pattern, regexp: true, allow_blank: true
  validates :url_pattern, regexp: true, allow_blank: true

  def match(url, body)
    (body_pattern.blank? || body_regexp.match(body)) && (url_pattern.blank? || url_regexp.match(url))
  end

  def body_regexp
    Regexp.new(body_pattern) unless body_pattern.blank?
  end

  def url_regexp
    Regexp.new(url_pattern) unless url_pattern.blank?
  end

  def mock_instances
    resource_instances.to_a.map { |resource_instance| ResourceRepresentationInstance.new(resource_instance, response) }
  end

  def mock_body
    return GenerateJsonInstanceService.new(response.json_schema).execute unless mock_instances.any?

    if response.is_collection
      body = mock_instances.map(&:body)
    else
      body = mock_instances.first.body
    end
    body = { response.root_key => body } unless response.root_key.blank?

    body
  end
end
