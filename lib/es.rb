class ES
  INDEX_PREFIX = "#{Rails.env}:endpointme".freeze

  def self.client
    @@client ||= Elasticsearch::Client.new(config)
  end

  def self.config
    config = { url: 'http://127.0.0.1:9200', log: Rails.env == 'development' }

    es_yaml_file = "#{Rails.root}/config/elasticsearch.yml"
    config.merge!(YAML.load_file(es_yaml_file).symbolize_keys) if File.exist?(es_yaml_file)

    config
  end
end
Elasticsearch::Model.client = ES.client
