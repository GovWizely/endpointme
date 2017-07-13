module DataSources
  class TSVIngester < SVIngester
    def initialize(klass, metadata, ingest_pipeline_id, data)
      super(klass, metadata, data, ingest_pipeline_id, "\t")
    end
  end
end
