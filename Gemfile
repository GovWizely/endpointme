source 'https://rubygems.org'

ruby '2.3.4'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2'

gem 'airbrake-ruby'
gem 'charlock_holmes'
gem 'elasticsearch'
gem 'elasticsearch-model', github: 'elastic/elasticsearch-rails', branch: '5.x'
gem 'elasticsearch-persistence', github: 'elastic/elasticsearch-rails', branch: '5.x'
gem 'htmlentities'
gem 'jbuilder'
gem 'jsonpath'
gem 'puma'
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
  gem 'listen'
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
