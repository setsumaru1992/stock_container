module Concerns::Hashable
  extend ActiveSupport::Concern

  def to_h
    self.instance_variables.map do |field|
      field_value = self.instance_variable_get(field)
      field_name = field.to_s.gsub("@","").to_sym
      [field_name, field_value]
    end.to_h
  end
end