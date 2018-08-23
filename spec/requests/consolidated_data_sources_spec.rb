require 'rails_helper'

RSpec.describe 'Consolidated DataSources', type: :request do
  let(:create_params_template) do
    {
      version_number: '1',
      published:      true }
  end

  let(:dictionary) { "---\r\ncol1:\r\n  source: col1\r\n  description: Description of col1\r\n  indexed: true\r\n  plural: false\r\n  type: enum\r\ncol2:\r\n  source: col2\r\n  description: Description of col2\r\n  indexed: true\r\n  plural: false\r\n  type: string\r\n" }

  describe 'happy path: user creates, searches on, retrieves record from, and deletes a consolidated data source' do
    it 'supports the full workflow' do
      # create
      VCR.use_cassette('endpointme/consolidated') do
        valid_create_params = create_params_template
                              .merge(name:        'testing feed1',
                                     description: 'testing feed1',
                                     api:         'ab_entries',
                                     url:         'https://s3.amazonaws.com/search-api-static-files/screening_list/feed1.csv')
        post '/data_sources.json', params: { data_source: valid_create_params }
        expect(response).to have_http_status(:created)
        valid_update_params = valid_create_params.merge(dictionary: dictionary)
        put '/data_sources/ab_entries:v1.json', params: { data_source: valid_update_params }
        expect(response).to have_http_status(:success)

        valid_create_params = create_params_template
                              .merge(name:        'testing feed2',
                                     description: 'testing feed2',
                                     api:         'cd_entries',
                                     url:         'https://s3.amazonaws.com/search-api-static-files/screening_list/feed2.csv')
        post '/data_sources.json', params: { data_source: valid_create_params }
        expect(response).to have_http_status(:created)
        valid_update_params = valid_create_params.merge(dictionary: dictionary)
        put '/data_sources/cd_entries:v1.json', params: { data_source: valid_update_params }
        expect(response).to have_http_status(:success)
      end

      valid_consolidated_create_params = { consolidated:   true,
                                           version_number: 1,
                                           name:           'testing consolidated feed',
                                           description:    'testing consolidated feed',
                                           api:            'consolidated_entries' }
      post '/data_sources.json', params: { data_source: valid_consolidated_create_params }
      expect(response).to have_http_status(:created)

      # update
      valid_update_params = valid_consolidated_create_params.merge(dictionary: "---\n- source: AB\n  api: ab_entries\n  version_number: 1\n- source: CD\n  api: cd_entries\n  version_number: 1\n")
      put '/data_sources/consolidated_entries:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)

      # search
      get '/v1/consolidated_entries/search.json?sources=AB,CD'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('here is some free text on ponies')
      expect(response.body).to include('this is about a pony')
      expect(response.body).to include('ponies are nice')
      expect(response.body).to include('horses are bigger')

      get '/v1/consolidated_entries/search.json?sources=CD&q=pony'
      expect(response).to have_http_status(:success)
      expect(response.body).not_to include('here is some free text on ponies')
      expect(response.body).not_to include('this is about a pony')
      expect(response.body).to include('ponies are nice')
      expect(response.body).not_to include('horses are bigger')

      get '/v1/consolidated_entries/6982cd2dd350cc4d0729de5db16502da176fa5d6'
      expect(response.body).to include('6982cd2dd350cc4d0729de5db16502da176fa5d6')
    end
  end
end
