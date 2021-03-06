module DataSources
  class Ingester
    include Utils
    BULK_GROUP_SIZE = 25

    def initialize(klass, metadata, data, ingest_pipeline_id)
      @klass = klass
      @metadata = metadata
      @data = data
      @ingest_pipeline_id = ingest_pipeline_id
      fields = @metadata.unique_fields.present? ? @metadata.unique_fields : @metadata.entries
      @keys_for_id = fields.keys
      @timestamp = Time.now.utc
    end

    private

    def insert(rows)
      rows.in_groups_of(BULK_GROUP_SIZE, false) do |group|
        ES.client.bulk(index: @klass.index_name, type: @klass.document_type, body: bulkify(group),
                       pipeline: @ingest_pipeline_id)
      end
    end

    def bulkify(records)
      records.reduce([]) do |bulk_array, record|
        bulk_array << { index: unique_record_id(record) }
        bulk_array << @metadata.transform(record).merge(_updated_at: @timestamp)
      end
    end

    def unique_record_id(record)
      { _id: generate_id(record, @keys_for_id) }
    end
  end
end
