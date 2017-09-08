module DataSources
  class ExternalMappingTransformation
    def self.generate_processor(json, field, options)
      json.json_api do
        json.field field.to_s
        json.target_field field.to_s
        json.json_path options['result_path']
        json.url_prefix options['url']
        json.multi_value options['multi_value']
        json.ignore_missing true
      end
    end
  end
end
