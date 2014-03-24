module InsalesAppCore
  module ModelExtensions
    module InsalesEntity
      extend ActiveSupport::Concern

      def set_attributes_by_insales_entity(insales_entity, attributes = {})
        local_attributes = attribute_names.map(&:to_sym)

        insales_entity.attributes.each do |a, v|
          local_field = self.class.get_local_field(a.to_sym)
          next unless local_attributes.include?(local_field)
          self[local_field] = v
        end

        attributes.each do |k, v|
          next unless local_attributes.include?(k.to_sym)
          self[k.to_sym] = v
        end

        self
      end

      module ClassMethods

        def maps_to_insales
          @maps_to_insales = true
          map_insales_fields(id: :insales_id)
        end

        def ids_map
          Hash[pluck(:insales_id, :id)]
        end

        def create_by_insales_entity(insales_entity, attributes = {})
          new_record = new
          new_record.set_attributes_by_insales_entity(insales_entity, attributes)
        end

        def update_by_insales_entity(insales_entity, attributes = {})
          existing_record = find_by_insales_id(insales_entity.id)
          return nil if existing_record.nil?
          existing_record.set_attributes_by_insales_entity(insales_entity)
        end

        def update_or_create_by_insales_entity(insales_entity, attributes = {})
          update_by_insales_entity(insales_entity, attributes) || create_by_insales_entity(insales_entity, attributes)
        end

        def get_local_field(insales_field)
          field_mapping.fetch(insales_field, insales_field)
        end

        def map_insales_fields(fields = {})
          field_mapping.merge!(fields)
        end

        def field_mapping
          @field_mapping ||= {}
        end

      end
    end
  end
end