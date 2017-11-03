module DataSources
  class TSVIngester < SVIngester
    def initialize(klass, metadata, data, ingest_pipeline_id)
      super(klass, metadata, data, ingest_pipeline_id, "\t")
    end
  end
end
