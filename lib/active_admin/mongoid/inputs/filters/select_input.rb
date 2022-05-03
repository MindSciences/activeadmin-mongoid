require 'active_admin/inputs/filters/select_input'

class ActiveAdmin::Inputs::Filters::SelectInput
  def searchable_method_name
    name = if searchable_has_many_through?
             "#{reflection.through_reflection.name}_#{reflection.foreign_key}"
           elsif reflection_searchable? && klass.include?(Mongoid::Document)
             reflection.key
           else
             name = method.to_s
             name.concat "_#{reflection.association_primary_key}" if reflection_searchable?
             name
           end
    (name == '_id') ? 'id' : name
  end
end
