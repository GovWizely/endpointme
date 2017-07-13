module DataSources
  class CSVIngester < SVIngester
    def initialize(klass, metadata, data, ingest_pipeline_id)
      super(klass, metadata, data, ingest_pipeline_id, ',')
    end
  end
end
