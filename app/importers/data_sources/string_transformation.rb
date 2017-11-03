module DataSources
  class StringTransformation
    SUPPORTED_INSTANCE_METHODS = %i(downcase from gsub split upcase)

    class << self
      def generate_processor(json, field, method, args = nil)
        raise ArgumentError unless SUPPORTED_INSTANCE_METHODS.include?(method.to_sym)
        args.present? ? send(method, json, field.to_s, args) : send(method, json, field.to_s)
      end

      def downcase(json, field)
        json.lowercase do
          json.field field
          json.ignore_missing true
        end
      end

      def from(json, field, args)
        json.gsub do
          json.field field
          json.pattern "^.{#{args[0]}}"
          json.replacement ''
          json.ignore_missing true
        end
      end

      def gsub(json, field, args)
        json.gsub do
          json.field field
          json.pattern args[0]
          json.replacement args[1]
          json.ignore_missing true
        end
      end

      def split(json, field, args)
        json.split do
          json.field field
          json.separator args[0]
          json.ignore_missing true
        end
      end

      def upcase(json, field)
        json.uppercase do
          json.field field
          json.ignore_missing true
        end
      end
    end
  end
end
