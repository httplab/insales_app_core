module InsalesAppCore
  module ModelExtensions
    module InsalesEntity
      extend ActiveSupport::Concern

      included do
        include InsalesAppCore::ModelExtensions::Synced
      end

      def is_assignable_attribute?(v)
        attribute_names.map(&:to_sym).include?(v)
      end

      def set_attributes_by_insales_entity(insales_entity, attributes = {})
        insales_entity.attributes.each do |a, v|
          local_field = self.class.get_local_field(a.to_sym)
          next unless is_assignable_attribute?(local_field)
          self.send("#{local_field}=", v)
        end

        attributes.each do |k, v|
          next unless is_assignable_attribute?(k.to_sym)
          self.send("#{k}=", v)
        end

        self
      end

      module ClassMethods
        def maps_to_insales(*args)
          insales_class_arg, fields_arg = *args
          if insales_class_arg.is_a? Hash
            fields_arg = insales_class_arg
            insales_class_arg = nil
          end

          @insales_class_arg = insales_class_arg
          @maps_to_insales = true
          field_mapping[:id] = :insales_id
          field_mapping.merge!(fields_arg || {})
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
          existing_record.set_attributes_by_insales_entity(insales_entity, attributes)
        end

        def update_or_create_by_insales_entity(insales_entity, attributes = {})
          update_by_insales_entity(insales_entity, attributes) || create_by_insales_entity(insales_entity, attributes)
        end

        def get_local_field(insales_field, default = nil)
          field_mapping.fetch(insales_field, insales_field)
        end

        def field_mapping
          @field_mapping ||= {}
        end

        def insales_class
          # Такая странная схема, т.к. при инициализации приложения, например, InsalesApi::Order::ShippingAddress
          # отсутствует, он появится только после запроса к API Insales
          @insales_class ||= @insales_class_arg || Kernel.const_get('InsalesApi::' + self.name)
        end
      end
    end
  end
end
