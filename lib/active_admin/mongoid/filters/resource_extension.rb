require 'active_admin/filters/resource_extension'

module ActiveAdmin::Filters::ResourceExtension
  def default_association_filters
    resource_class.include?(Mongoid::Document) ? default_mongo_association_filters : default_ar_association_filters
  end

  def default_ar_association_filters
    if resource_class.respond_to?(:reflect_on_all_associations)
      poly, not_poly = resource_class.reflect_on_all_associations.partition { |r| r.macro == :belongs_to && r.options[:polymorphic] }

      # remove deeply nested associations
      not_poly.reject! { |r| r.chain.length > 2 }

      filters = poly.map(&:foreign_type) + not_poly.map(&:name)

      # Check high-arity associations for filterable columns
      max = namespace.maximum_association_filter_arity
      if max != :unlimited
        high_arity, low_arity = not_poly.partition do |r|
          r.klass.reorder(nil).limit(max + 1).count > max
        end

        # Remove high-arity associations with no searchable column
        high_arity = high_arity.select(&method(:searchable_column_for))

        high_arity = high_arity.map { |r| r.name.to_s + "_" + searchable_column_for(r) + namespace.filter_method_for_large_association }

        filters = poly.map(&:foreign_type) + low_arity.map(&:name) + high_arity
      end

      filters.map &:to_sym
    else
      []
    end
  end

  def default_mongo_association_filters
    if resource_class.respond_to?(:reflect_on_all_associations)
      without_embedded = resource_class.reflect_on_all_associations.reject { |e| e.embeds? }
      poly, not_poly = without_embedded.partition { |r| r.macro == :belongs_to && r.options[:polymorphic] }

      filters = poly.map(&:foreign_key) + not_poly.map(&:name)
      filters.map &:to_sym
    else
      []
    end
  end

  def filters_sidebar_section
    ActiveAdmin::SidebarSection.new :filters, only: :index, if: -> { active_admin_config.filters.any? } do
      builder = resource_class.include?(Mongoid::Document) ? ActiveAdmin::Filters::MongoFormBuilder : ActiveAdmin::Filters::FormBuilder
      active_admin_filters_form_for assigns[:search], active_admin_config.filters, builder: builder
    end
  end
end
