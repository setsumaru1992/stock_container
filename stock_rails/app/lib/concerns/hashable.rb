module Concerns::Hashable
  extend ActiveSupport::Concern

  def to_h
    self.instance_variables.map do |field|
      field_value = self.instance_variable_get(field)
      field_name = field.to_s.gsub("@","").to_sym
      [field_name, field_value]
    end.to_h
  end

  def merge!(hashable_obj)
    new_value_hash = hashable_obj.to_h
    accesible_fields = methods
      .map(&:to_s)
      .select {|method| method.match(/[a-z]+=/).present?}
      .map{|method| method.gsub("=", "")}
      .map(&:to_sym)

    accesible_fields.each do |field|
      next unless new_value_hash.has_key?(field)
      send("#{field}=", new_value_hash[field])
    end
    nil
  end
end