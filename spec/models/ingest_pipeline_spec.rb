require 'rails_helper'

RSpec.describe IngestPipeline do
  context 'pipeline description' do
    let(:metadata) { double(DataSources::Metadata, entries: []) }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:my_index:v1', metadata).pipeline }

    it 'contains a description' do
      expect(pipeline[:description]).to eq('Pipeline for test:endpointme:pipelines:my_index:v1')
    end
  end

  context 'uppercasing field' do
    let(:metadata) { use_yaml_fixture('upcase') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates an uppercase processor' do
      processor = { uppercase: { field: 'blat' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'lowercasing field' do
    let(:metadata) { use_yaml_fixture('downcase') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates an lowercase processor' do
      processor = { lowercase: { field: 'bar' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'globally replacing text' do
    let(:metadata) { use_yaml_fixture('gsub') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates a gsub processor' do
      processor = { gsub: { field: 'bar', pattern: 'å', replacement: 'a' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'splitting into array' do
    let(:metadata) { use_yaml_fixture('split') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates a split processor' do
      processor = { split: { field: 'bar', separator: '-', ignore_missing: true } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'substring from some index into string' do
    let(:metadata) { use_yaml_fixture('from') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates an appropriate gsub processor' do
      processor = { gsub: { field: 'bar', pattern: '^.{4}', replacement: '' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'reformatting non-standard date strings' do
    let(:metadata) { use_yaml_fixture('reformat_date') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates a processor to return the value in the new format' do
      processor = { date: { field: 'bar', target_field: 'bar', formats: ['MM/dd/yyyy'] } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'applying several processors across several fields' do
    let(:metadata) { use_yaml_fixture('several_several') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates all the necessary processors' do
      uppercase_processor = { uppercase: { field: 'bar' } }.with_indifferent_access
      split_processor = { split: { field: 'bar', separator: '-', ignore_missing: true } }.with_indifferent_access
      foreach_gsub_processor = { foreach: { field: 'bar', processor: { gsub: {
        field: '_ingest._value', pattern: '^.{4}', replacement: '' } }, ignore_failure: true } }.with_indifferent_access

      date_processor = { date: { field: 'blat', target_field: 'blat', formats: ['%m/%d/%Y'] } }.with_indifferent_access

      expect(pipeline[:processors]).to eq([uppercase_processor,
                                           split_processor,
                                           foreach_gsub_processor,
                                           date_processor])
    end
  end

  context 'applying processors to nested collections' do
    let(:metadata) { use_yaml_fixture('nested_collections') }
    let(:pipeline) { IngestPipeline.new('test:endpointme:pipelines:pipeline_name:v1', metadata).pipeline }

    it 'generates all the necessary processors' do
      foreach_processor1 = { foreach: {
        field: 'places',
        processor: {
          json_api: {
            field: '_ingest._value.country',
            target_field: '_ingest._value.country',
            url_prefix: 'http://im.govwizely.com/api/terms.json?source=TradeEvent::Ustda&mapped_term={}&cache=false',
            json_path: '$..name',
            multi_value: false,
            ignore_missing: true
          } },
        ignore_failure: true } }.with_indifferent_access

      foreach_processor2 = { foreach: {
        field: 'places',
        processor: {
          json_api: {
            field: '_ingest._value.country',
            target_field: '_ingest._value.country',
            url_prefix: 'https://restcountries.eu/rest/v1/name/{}?fullText=true',
            json_path: '$..alpha2Code',
            multi_value: nil,
            ignore_missing: true
          } },
        ignore_failure: true } }.with_indifferent_access

      expect(pipeline[:processors]).to eq([foreach_processor1, foreach_processor2])
    end
  end

  def use_yaml_fixture(filename)
    file_read = File.read("#{Rails.root}/spec/fixtures/data_sources/#{filename}.yaml")
    symbolized_version = DataSources::Metadata.new(file_read).deep_symbolized_yaml
    DataSources::Metadata.new(symbolized_version.to_s)
  end
end
