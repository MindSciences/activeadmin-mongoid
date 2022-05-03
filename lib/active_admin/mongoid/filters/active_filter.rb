require 'active_admin/filters/active_filter'
module ActiveAdmin
  module Filters

    class ActiveFilter
      def related_primary_key
        if predicate_association
          predicate_association_key
        elsif related_class
          related_class_key
        end
      end

      def related_class_key
        related_class.include?(Mongoid::Document) ? related_class.key : related_class.primary_key
      end

      def predicate_association_key
        related_class.include?(Mongoid::Document) ? predicate_association.key : predicate_association.association_primary_key
      end
    end
  end
end
