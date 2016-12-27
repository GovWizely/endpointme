class ApiModelsController < ApplicationController
  respond_to :json
  before_action :setup_data_source
  before_action :setup_search_params, only: :search
  class_attribute :search_params

  def search
    query = ApiModelQuery.new(@data_source.metadata, params.permit(search_params))
    data_source_search = DataSources::Search.new(@data_source, query, params[:sources])
    search_response_hash = data_source_search.search
    respond_with search_response_hash
  end

  def show
    query = IdsQuery.new([params[:id]])
    data_source_search = DataSources::Search.new(@data_source, query, nil)
    search_response_hash = data_source_search.search
    record = search_response_hash[:results].first
    record ? respond_with(record) : not_found
  end

  def freshen
    @data_source.freshen
    DataSource.refresh_index!
    render json: { success: "#{@data_source.id} API freshened" }, status: :ok
  end

  private

  def setup_data_source
    @data_source = DataSource.find_published(params[:api], params[:version_number])
    not_found unless @data_source.present?
  end

  def setup_search_params
    self.search_params = %i(api_key callback format offset size sort api version_number) + @data_source.search_params
  end
end
