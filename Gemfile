source 'https://rubygems.org'

ruby '2.3.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'charlock_holmes'
gem 'elasticsearch'
gem 'elasticsearch-model'
gem 'elasticsearch-persistence', git: 'git://github.com/elasticsearch/elasticsearch-rails.git' # remove when 0.10.0
gem 'htmlentities'
gem 'jbuilder'
gem 'jsonpath'
gem 'puma'
gem 'rails', '~> 5.0.2'
gem 'responders'
gem 'roo'
gem 'roo-xls'
gem 'sanitize'
gem 'smarter_csv'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rb-readline'
  gem 'rubocop', '0.39.0', require: false
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
end
