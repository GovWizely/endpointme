Rails.application.routes.draw do
  resources :data_sources
  scope defaults: { format: :json } do
    get '/v:version_number/:api/search(.json)', to: 'api_models#search'
    get '/v:version_number/:api/freshen(.json)', to: 'api_models#freshen'
    get '/v:version_number/:api/:id', to: 'api_models#show'
  end
end
