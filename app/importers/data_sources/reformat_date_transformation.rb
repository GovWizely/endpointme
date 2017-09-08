module DataSources
  class ReformatDateTransformation
    def self.generate_processor(json, field, date_format)
      json.date do
        json.field field.to_s
        json.target_field field.to_s
        json.formats [date_format]
      end
    end
  end
end
