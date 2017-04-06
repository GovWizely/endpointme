class ES
  INDEX_PREFIX = "#{Rails.env}:endpointme".freeze

  def self.client
    @@client ||= Elasticsearch::Client.new(log: Rails.env == 'development')
  end

end
Elasticsearch::Model.client = ES.client
