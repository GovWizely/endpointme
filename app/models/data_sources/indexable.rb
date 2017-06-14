module DataSources
  module Indexable
    extend ActiveSupport::Concern
    include Findable
    include Utils

    module ClassMethods
      def freshen(api)
        data_source = current_version(api)
        data_source.freshen
      end
    end

    def ingest
      delete_api_index
      # TODO
      # 1. delete existing pipeline if it exists
      # 1. create IngestPipeline.new(name_builder('pipelines'),dictionary)
      # 1. register pipeline with elasticsearch
      puts "1"*80
      puts dictionary
      with_api_model do |klass|
        klass.create_index!
        _ingest(klass)
      end
    end

    def freshen
      data_extractor = DataSources::DataExtractor.new(url)
      data = data_extractor.data
      new_message_digest = Digest::SHA1.hexdigest data
      timestamp = updated_timestamp
      if message_digest != new_message_digest
        update(data: data, message_digest: new_message_digest, data_changed_at: timestamp, data_imported_at: timestamp)
        ingest_and_prune
      else
        touch(:data_imported_at)
      end
    end

    private

    def delete_api_index
      ES.client.indices.delete(index: name_builder('api_models'), ignore: 404)
      DataSource.refresh_index!
    end

    def name_builder(namespace)
      [ES::INDEX_PREFIX, namespace, api, "v#{version_number}"].join(':')
    end

    def initialize_timestamps
      @data_imported_at = @data_changed_at = updated_timestamp
    end

    def ingest_and_prune
      with_api_model do |klass|
        _ingest(klass)
        ES.client.delete_by_query(index: klass.index_name, type: klass.document_type, body: older_than(:_updated_at, updated_at))
        klass.refresh_index!
      end
    end

    def _ingest(klass)
      "DataSources::#{data_format}Ingester".constantize.new(klass, metadata, data).ingest
      klass.refresh_index!
    end

    def data_format
      case data
      when /\A<\?xml /
        'XML'
      when /\A[{\[]/
        'JSON'
      when /\t/
        'TSV'
      else
        'CSV'
      end
    end

    def updated_timestamp
      Time.now.utc
    end
  end
end
