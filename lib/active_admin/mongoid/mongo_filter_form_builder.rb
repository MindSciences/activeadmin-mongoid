class ActiveAdmin::Filters::MongoFormBuilder < ::ActiveAdmin::FormBuilder
  include ::ActiveAdmin::Filters::FormtasticAddons
  self.input_namespaces = [::Object, ::ActiveAdmin::Inputs::Filters, ::ActiveAdmin::Inputs, ::Formtastic::Inputs]

  # TODO: remove input class finders after formtastic 4 (where it will be default)
  self.input_class_finder = ::Formtastic::InputClassFinder

  def filter(method, options = {})
    if method.present? && options[:as] ||= default_input_type(method)
      template.concat input(method, options)
    end
  end

  def default_input_type(method, options = {})
    if column = column_for(method)
      case column.type.name.downcase.to_sym
      when :date, :datetime, :time; :date_range
      when :string, :text, :object; :string
      when :float, :decimal; :numeric
      when :integer
        return :select if reflection_for(method.to_s.gsub('_id', '').to_sym)
        return :numeric
      end
    elsif is_association?(method)
      return :select
    else
      # dirty but allows to create filters for hashes
      return :string
    end
  end

  protected

  def is_association?(method)
    @object.klass.associations.to_a.map!(&:first).include?(method.to_s)
  end

  def column_for(method)
    @object.klass.fields[method.to_s] if @object.klass.respond_to?(:fields)
  end

  def reflection_for(method)
    @object.klass.reflect_on_association(method) if @object.klass.respond_to?(:reflect_on_association)
  end
end
