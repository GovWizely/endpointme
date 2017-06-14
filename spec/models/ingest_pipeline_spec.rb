require 'rails_helper'

RSpec.describe IngestPipeline do

  context 'pipeline description' do
    let(:metadata) { double(DataSources::Metadata, entries: []) }
    let(:pipeline) { IngestPipeline.new('my_index', metadata).pipeline }

    it 'contains a description' do
      expect(pipeline[:description]).to eq('Pipeline for my_index')
    end
  end

  context 'field is renamed' do
    let(:metadata) { use_yaml_fixture('rename') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates a processor to rename the field' do
      processor = { rename: { field: 'bar', target_field: 'foo' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'uppercasing field' do
    let(:metadata) { use_yaml_fixture('upcase') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates an uppercase processor' do
      processor = { uppercase: { field: 'bar' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'lowercasing field' do
    let(:metadata) { use_yaml_fixture('downcase') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates an lowercase processor' do
      processor = { lowercase: { field: 'bar' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'globally replacing text' do
    let(:metadata) { use_yaml_fixture('gsub') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates a gsub processor' do
      processor = { gsub: { field: 'bar', pattern: 'å', replacement: 'a' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'splitting into array' do
    let(:metadata) { use_yaml_fixture('split') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates a split processor' do
      processor = { split: { field: 'bar', separator: '-' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'substring from some index into string' do
    let(:metadata) { use_yaml_fixture('from') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates an appropriate gsub processor' do
      processor = { gsub: { field: 'bar', pattern: '^.{4}', replacement: '' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'reformatting non-standard date strings' do
    let(:metadata) { use_yaml_fixture('reformat_date') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates a processor to return the value in the new format' do
      processor = { date: { field: 'bar', formats: ['%m/%d/%Y'] } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'setting a constant value' do
    let(:metadata) { use_yaml_fixture('constant') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates a set processor' do
      processor = { set: { field: 'bar', value: 'blat' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([processor])
    end
  end

  context 'copying a field and applying a transformation' do
    let(:metadata) { use_yaml_fixture('copy_from') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates a trim processor with new target field and an uppercase processor' do
      trim_processor = { trim: { field: 'blat', target_field: 'bar' } }.with_indifferent_access
      uppercase_processor = { uppercase: { field: 'bar' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([trim_processor, uppercase_processor])
    end
  end

  context 'renaming field and applying several processors' do
    let(:metadata) { use_yaml_fixture('several') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates all the necessary processors' do
      rename_processor = { rename: { field: 'foo', target_field: 'bar' } }.with_indifferent_access
      uppercase_processor = { uppercase: { field: 'bar' } }.with_indifferent_access
      split_processor = { split: { field: 'bar', separator: '-' } }.with_indifferent_access
      gsub_processor = { gsub: { field: 'bar', pattern: '^.{4}', replacement: '' } }.with_indifferent_access
      expect(pipeline[:processors]).to eq([rename_processor, uppercase_processor, split_processor, gsub_processor])
    end
  end

  context 'applying several processors across several fields' do
    let(:metadata) { use_yaml_fixture('several_several') }
    let(:pipeline) { IngestPipeline.new('pipeline_name', metadata).pipeline }

    it 'generates all the necessary processors' do
      rename_processor = { rename: { field: 'foo', target_field: 'bar' } }.with_indifferent_access
      uppercase_processor = { uppercase: { field: 'bar' } }.with_indifferent_access
      split_processor = { split: { field: 'bar', separator: '-' } }.with_indifferent_access
      gsub_processor = { gsub: { field: 'bar', pattern: '^.{4}', replacement: '' } }.with_indifferent_access

      trim_processor = { trim: { field: 'foo', target_field: 'blat' } }.with_indifferent_access
      date_processor = { date: { field: 'blat', formats: ['%m/%d/%Y'] } }.with_indifferent_access

      expect(pipeline[:processors]).to eq([rename_processor, uppercase_processor, split_processor, gsub_processor,
                                           trim_processor, date_processor])
    end
  end


  def use_yaml_fixture(filename)
    DataSources::Metadata.new(File.read("#{Rails.root}/spec/fixtures/data_sources/#{filename}.yaml"))
  end
end