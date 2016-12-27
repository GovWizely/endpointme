require 'rails_helper'

RSpec.describe DataSourcesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/data_sources').to route_to('data_sources#index')
    end

    it 'routes to #show' do
      expect(get: '/data_sources/1').to route_to('data_sources#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/data_sources').to route_to('data_sources#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/data_sources/1').to route_to('data_sources#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/data_sources/1').to route_to('data_sources#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/data_sources/1').to route_to('data_sources#destroy', id: '1')
    end
  end
end
