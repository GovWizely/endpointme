class ES
  INDEX_PREFIX = "#{Rails.env}:endpointme".freeze

  def self.client
    @@client ||= Elasticsearch::Client.new(log: Rails.env == 'development', request_timeout: 30 * 60)
  end
end
Elasticsearch::Model.client = ES.client
