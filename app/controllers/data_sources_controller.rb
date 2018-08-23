class DataSourcesController < ApplicationController
  before_action :set_data_source, only: [:show, :update, :destroy]
  COMMON_PARAMS = %i[name api description url version_number consolidated]
  rescue_from Elasticsearch::Transport::Transport::Errors::Conflict, with: :api_not_unique
  rescue_from Elasticsearch::Persistence::Repository::DocumentNotFound, with: :not_found

  # GET /data_sources
  def index
    @data_sources = DataSource.directory

    render json: @data_sources
  end

  # GET /data_sources/1
  def show
    @data_source.dictionary = @data_source.metadata.deep_stringified_yaml unless @data_source.is_consolidated?
    render json: @data_source
  end

  # POST /data_sources
  def create
    data_source_params = params.require(:data_source).permit(COMMON_PARAMS)
    attributes = { published: true }
    unless data_source_params[:consolidated]
      resource = data_source_params[:url]
      data_extractor = DataSources::DataExtractor.new(resource)
      attributes[:data] = data_extractor.data
    end
    @data_source = DataSource.new(data_source_params.merge(attributes).to_h)
    if @data_source.save(op_type: :create, refresh: true)
      render json: @data_source, status: :created, location: @data_source
    else
      render json: { errors: @data_source.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /data_sources/1
  def update
    attributes = params.require(:data_source).permit(COMMON_PARAMS + %i(dictionary published))
    attributes[:dictionary] = symbolized_yaml(attributes[:dictionary]) unless @data_source.is_consolidated?
    @data_source.name = attributes['name']
    if @data_source.update(attributes.to_h)
      perform_update
      render json: @data_source
    else
      render json: { errors: @data_source.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /data_sources/1
  def destroy
    @data_source.destroy
  end

  private

  def symbolized_yaml(dictionary)
    DataSources::Metadata.new(dictionary).deep_symbolized_yaml
  end

  def set_data_source
    args = request['action'] == 'update' ? {} : { _source_exclude: 'data' }
    @data_source = DataSource.find(params[:id], args)
  end

  def perform_update
    @data_source.ingest unless @data_source.is_consolidated?
    DataSource.refresh_index!
  end

  def api_not_unique
    @data_source.errors.add(:api, "'#{@data_source.api}' already exists.")
    render json: { errors: @data_source.errors }, status: :unprocessable_entity
  end
end
