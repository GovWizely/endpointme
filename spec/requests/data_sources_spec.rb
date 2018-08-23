require 'rails_helper'

RSpec.describe 'DataSources', type: :request do
  let(:valid_create_params) do
    {
      name:           'success_cases',
      api:            'success_cases',
      description:    'success_cases',
      url:            'https://s3.amazonaws.com/search-api-static-files/screening_list/feed2.csv',
      version_number: '1',
      published:      true }
  end

  before do
    begin
      delete '/data_sources/success_cases:v1.json'
      delete '/data_sources/success_cases:v2.json'
    rescue ActionController::RoutingError
    end
  end

  describe 'happy path: user creates, updates, searches on, freshens, shows, and deletes an endpointme data source' do
    it 'supports the full workflow' do
      # create
      VCR.use_cassette('endpointme/success_cases') do
        post '/data_sources.json', params: { data_source: valid_create_params }
      end
      expect(response.content_type).to eq('application/json')
      expect(response).to have_http_status(:created)

      # index list
      get '/data_sources.json'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('https://s3.amazonaws.com/search-api-static-files/screening_list/feed2.csv')

      # update
      valid_update_params = valid_create_params.merge(name: 'Updated name', 'dictionary' => "---\r\ncol1:\r\n  source: col1\r\n  description: Description of col1\r\n  indexed: true\r\n  plural: false\r\n  type: enum\r\ncol2:\r\n  source: col2\r\n  description: Description of col2\r\n  indexed: true\r\n  plural: false\r\n  type: string\r\n")
      put '/data_sources/success_cases:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Updated name')

      # search
      get '/v1/success_cases/search.json?q=pony'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('"col2":"ponies are nice"')

      # freshen
      VCR.use_cassette('endpointme/success_cases') do
        get '/v1/success_cases/freshen.json'
      end
      expect(response).to have_http_status(:success)
      expect(response.body).to include('"success":"success_cases:v1 API freshened"')

      # show
      get '/data_sources/success_cases:v1.json'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('https://s3.amazonaws.com/search-api-static-files/screening_list/feed2.csv')

      # delete
      delete '/data_sources/success_cases:v1.json'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'user tries to create a data source with invalid data' do
    it 'returns an error' do
      invalid_create_params = valid_create_params.merge(api: '')
      VCR.use_cassette('endpointme/success_cases') do
        post '/data_sources.json', params: { data_source: invalid_create_params }
      end
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'user tries to update a data source with invalid data' do
    it 'returns an error' do
      VCR.use_cassette('endpointme/success_cases') do
        post '/data_sources.json', params: { data_source: valid_create_params }
      end
      expect(response).to have_http_status(:success)

      valid_update_params = valid_create_params.merge(name: 'Updated name', 'dictionary' => "---\r\ncol1:\r\n  source: col1\r\n  description: Description of col1\r\n  indexed: true\r\n  plural: false\r\n  type: enum\r\ncol2:\r\n  source: col2\r\n  description: Description of col2\r\n  indexed: true\r\n  plural: false\r\n  type: string\r\n")
      put '/data_sources/success_cases:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)

      invalid_update_params = valid_create_params.merge(name: '', 'dictionary' => "---\r\ncol1:\r\n  source: col1\r\n  description: Description of col1\r\n  indexed: true\r\n  plural: false\r\n  type: enum\r\ncol2:\r\n  source: col2\r\n  description: Description of col2\r\n  indexed: true\r\n  plural: false\r\n  type: string\r\n")
      put '/data_sources/success_cases:v1.json', params: { data_source: invalid_update_params }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'user tries to create an already existing API' do
    it 'returns an error' do
      VCR.use_cassette('endpointme/success_cases', allow_playback_repeats: true) do
        post '/data_sources.json', params: { data_source: valid_create_params }
        expect(response).to have_http_status(:created)
        post '/data_sources.json', params: { data_source: valid_create_params }
      end
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'iterating a version of an API' do
    it 'returns success' do
      VCR.use_cassette('endpointme/success_cases', allow_playback_repeats: true) do
        post '/data_sources.json', params: { data_source: valid_create_params }
        expect(response).to have_http_status(:created)
        post '/data_sources.json', params: { data_source: valid_create_params.merge(version_number: 2) }
      end
      expect(response).to have_http_status(:created)
    end
  end

  describe 'uploading TSV data' do
    it 'returns success' do
      create_params = valid_create_params.merge(url: 'https://s3.amazonaws.com/search-api-static-files/screening_list/tabs.tsv',
                                                api: 'tabs')
      VCR.use_cassette('endpointme/tsv') do
        post '/data_sources.json', params: { data_source: create_params }
        expect(response).to have_http_status(:created)
      end
      valid_update_params = create_params.merge(dictionary: "---\r\nf1:\r\n  source: f1\r\n  description: Description of f1\r\n  indexed: true\r\n  plural: false\r\n  type: string\r\nf2:\r\n  source: f2\r\n  description: Description of f2\r\n  indexed: true\r\n  plural: false\r\n  type: integer\r\n")
      put '/data_sources/tabs:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)

      get '/v1/tabs/search.json'
      expect(response.body).to include('from tabs')
    end
  end

  describe 'uploading XML data' do
    it 'returns success' do
      create_params = valid_create_params.merge(url: 'https://s3.amazonaws.com/search-api-static-files/screening_list/posts.xml',
                                                api: 'posts')
      VCR.use_cassette('endpointme/xml') do
        post '/data_sources.json', params: { data_source: create_params }
        expect(response).to have_http_status(:created)
      end
      valid_update_params = create_params.merge(dictionary: "---\n:_collection_path: \"/POSTLIST/POSTINFO\"\n:post:\n  :source: POST\n  :description: Description of POST\n  :indexed: true\n  :plural: false\n  :type: string\n:postname:\n  :source: POSTNAME\n  :description: Description of POSTNAME\n  :indexed: true\n  :plural: false\n  :type: string\n:officename:\n  :source: OFFICENAME\n  :description: Description of OFFICENAME\n  :indexed: true\n  :plural: false\n  :type: string\n:orgcode:\n  :source: ORGCODE\n  :description: Description of ORGCODE\n  :indexed: true\n  :plural: false\n  :type: enum\n:ctrnumber:\n  :source: CTRNUMBER\n  :description: Description of CTRNUMBER\n  :indexed: true\n  :plural: false\n  :type: integer\n:countryid:\n  :source: COUNTRYID\n  :description: Description of COUNTRYID\n  :indexed: true\n  :plural: false\n  :type: integer\n:state:\n  :source: STATE\n  :description: Description of STATE\n  :indexed: true\n  :plural: false\n  :type: enum\n:posttype:\n  :source: POSTTYPE\n  :description: Description of POSTTYPE\n  :indexed: true\n  :plural: false\n  :type: enum\n:timezone:\n  :source: TIMEZONE\n  :description: Description of TIMEZONE\n  :indexed: true\n  :plural: false\n  :type: integer\n:status:\n  :source: STATUS\n  :description: Description of STATUS\n  :indexed: true\n  :plural: false\n  :type: integer\n:url:\n  :source: URL\n  :description: Description of URL\n  :indexed: true\n  :plural: false\n  :type: string\n:email:\n  :source: EMAIL\n  :description: Description of EMAIL\n  :indexed: true\n  :plural: false\n  :type: string\n:fax:\n  :source: FAX\n  :description: Description of FAX\n  :indexed: true\n  :plural: false\n  :type: string\n:phone:\n  :source: PHONE\n  :description: Description of PHONE\n  :indexed: true\n  :plural: false\n  :type: string\n")
      put '/data_sources/posts:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)

      get '/v1/posts/search.json'
      expect(response.body).to include('"officename":"from XML"')
    end
  end

  describe 'uploading XLS data' do
    # Deprecation warning info: https://github.com/roo-rb/roo-xls/issues/28
    it 'returns success' do
      create_params = valid_create_params.merge(url: 'https://s3.amazonaws.com/search-api-static-files/screening_list/excel.xls',
                                                api: 'xls_records')
      VCR.use_cassette('endpointme/xls') do
        post '/data_sources.json', params: { data_source: create_params }
        expect(response).to have_http_status(:created)
      end
      valid_update_params = create_params.merge(dictionary: "---\n:commodity:\n  :source: Commodity\n  :description: Description of Commodity\n  :indexed: true\n  :plural: false\n  :type: string\n:date:\n  :source: Date\n  :description: Description of Date\n  :indexed: true\n  :plural: false\n  :type: date\n:country:\n  :source: Country\n  :description: Description of Country\n  :indexed: true\n  :plural: false\n  :type: string\n:weekly_export:\n  :source: Weekly Export\n  :description: Description of Weekly Export\n  :indexed: true\n  :plural: false\n  :type: integer\n:accum_exports:\n  :source: Accum. Exports\n  :description: Description of Accum. Exports\n  :indexed: true\n  :plural: false\n  :type: integer\n:cmy_sales:\n  :source: CMY Sales\n  :description: Description of CMY Sales\n  :indexed: true\n  :plural: false\n  :type: integer\n:cmy_gross:\n  :source: CMY Gross\n  :description: Description of CMY Gross\n  :indexed: true\n  :plural: false\n  :type: integer\n:cmy_net:\n  :source: CMY Net\n  :description: Description of CMY Net\n  :indexed: true\n  :plural: false\n  :type: integer\n:cmy_total:\n  :source: CMY Total\n  :description: Description of CMY Total\n  :indexed: true\n  :plural: false\n  :type: integer\n:cmy_outstanding:\n  :source: CMY Outstanding\n  :description: Description of CMY Outstanding\n  :indexed: true\n  :plural: false\n  :type: integer\n:nmy_net:\n  :source: NMY Net\n  :description: Description of NMY Net\n  :indexed: true\n  :plural: false\n  :type: integer\n:unit_desc:\n  :source: Unit Desc\n  :description: Description of Unit Desc\n  :indexed: true\n  :plural: false\n  :type: string\n")
      put '/data_sources/xls_records:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)

      get '/v1/xls_records/search.json'
      expect(response.body).to include('"country":"ALGERIA"')
    end
  end

  describe 'uploading JSON Object data' do
    it 'returns success' do
      create_params = valid_create_params.merge(url: 'https://s3.amazonaws.com/search-api-static-files/screening_list/json.json',
                                                api: 'json_object_records')
      VCR.use_cassette('endpointme/json_object_records') do
        post '/data_sources.json', params: { data_source: create_params }
        expect(response).to have_http_status(:created)
      end
      valid_update_params = create_params.merge(dictionary: "---\n:_collection_path: \"$.bsps.bsp[*]\"\n:site:\n  :source: site\n  :description: Description of site\n  :indexed: true\n  :plural: false\n  :type: string\n:pid:\n  :source: pid\n  :description: Description of pid\n  :indexed: true\n  :plural: false\n  :type: integer\n:url:\n  :source: url\n  :description: Description of url\n  :indexed: true\n  :plural: false\n  :type: string\n")
      put '/data_sources/json_object_records:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)

      get '/v1/json_object_records/search.json'
      expect(response.body).to include('"site":"United Kingdom"')
    end
  end

  describe 'uploading JSON array data' do
    it 'returns success' do
      create_params = valid_create_params.merge(url: 'https://s3.amazonaws.com/search-api-static-files/screening_list/json_array.json',
                                                api: 'json_array_records')
      VCR.use_cassette('endpointme/json_array_records') do
        post '/data_sources.json', params: { data_source: create_params }
        expect(response).to have_http_status(:created)
      end
      valid_update_params = create_params.merge(dictionary: "---\n:_collection_path: \"$[*]\"\n:alpha2code:\n  :source: alpha2Code\n  :description: Description of alpha2Code\n  :indexed: true\n  :plural: false\n  :type: enum\n:alpha3code:\n  :source: alpha3Code\n  :description: Description of alpha3Code\n  :indexed: true\n  :plural: false\n  :type: enum\n:area:\n  :source: area\n  :description: Description of area\n  :indexed: true\n  :plural: false\n  :type: float\n:capital:\n  :source: capital\n  :description: Description of capital\n  :indexed: true\n  :plural: false\n  :type: string\n:demonym:\n  :source: demonym\n  :description: Description of demonym\n  :indexed: true\n  :plural: false\n  :type: string\n:gini:\n  :source: gini\n  :description: Description of gini\n  :indexed: true\n  :plural: false\n  :type: float\n:name:\n  :source: name\n  :description: Description of name\n  :indexed: true\n  :plural: false\n  :type: string\n:nativename:\n  :source: nativeName\n  :description: Description of nativeName\n  :indexed: true\n  :plural: false\n  :type: enum\n:population:\n  :source: population\n  :description: Description of population\n  :indexed: true\n  :plural: false\n  :type: integer\n:region:\n  :source: region\n  :description: Description of region\n  :indexed: true\n  :plural: false\n  :type: enum\n:relevance:\n  :source: relevance\n  :description: Description of relevance\n  :indexed: true\n  :plural: false\n  :type: enum\n:subregion:\n  :source: subregion\n  :description: Description of subregion\n  :indexed: true\n  :plural: false\n  :type: string\n")
      put '/data_sources/json_array_records:v1.json', params: { data_source: valid_update_params }
      expect(response).to have_http_status(:success)

      get '/v1/json_array_records/search.json'
      expect(response.body).to include('"name":"South Korea"')
    end
  end
end
