module InsalesHelpers
  module MigrationGenerator

    def self.gm(collection)
      Account.last.configure_api
      z =  generate_migration(collection)
      puts z
      z
    end

    def self.generate_migration(entities)
      attributes = {}

      entities.each do |entity|
        known_attrs = entity.known_attributes

        known_attrs.each do |ka|
          val = entity.send(ka)

          if !attributes.has_key?(ka)
            attributes[ka] = {null: false, type: :string}
          end

          if val.nil?
            attributes[ka][:null] = true
          end

          if val.is_a?(Fixnum)
            attributes[ka][:type] = :integer
          elsif val.is_a?(Date) || val.is_a?(DateTime) || val.is_a?(Time)
            attributes[ka][:type] = :date
          elsif val.is_a?(Float) || val.is_a?(BigDecimal)
            attributes[ka][:type] = :decimal
          elsif val.is_a?(TrueClass) || val.is_a?(FalseClass)
            attributes[ka][:type] = :boolean
          elsif val.is_a?(Array)
            attributes[ka][:assoc] = true
          end
        end
      end

      attributes.clone.each do |k,v|

        if k.end_with?('_id') || k=='id'
          attributes["insales_#{k}"] = v
        end

        if ['created_at', 'updated_at', 'id'].include?(k) || v[:assoc]
          attributes.delete(k)
        end
      end

      attributes['account_id'] = {type: :integer, null: false}

      res = []

      attributes.each do |k,v|
        res << "\tt.#{v[:type]} :#{k}, null: false" if !v[:null]
        res << "\tt.#{v[:type]} :#{k}" if v[:null]
      end

      res << "\tt.timestamps"


      res.join("\n")
    end
  end
end
