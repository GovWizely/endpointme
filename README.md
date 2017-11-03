Endpointme
==========

[![Build Status](https://travis-ci.org/GovWizely/endpointme.svg?branch=master)](https://travis-ci.org/GovWizely/endpointme/)
[![Test Coverage](https://codeclimate.com/github/GovWizely/endpointme/badges/coverage.svg)](https://codeclimate.com/github/GovWizely/endpointme)
[![Code Climate](https://codeclimate.com/github/GovWizely/endpointme/badges/gpa.svg)](https://codeclimate.com/github/GovWizely/endpointme)

Endpointme lets you take pretty much any structured data set and turn it into a search API without writing a line of code--- just a RESTful JSON API.

# Features

* understands CSV, TSV, JSON, XLS, or XML file formats
* smart guessing of data types and schemas based on heuristics
* versioned APIs
* easy polling/refresh of URL-based data sources
* simple YAML-based configuration for each data source
* customize the ETL process via built-in transformations


### Ruby version
2.3.5

### Gems

We use bundler to manage gems. You can install bundler and other required gems like this:

    gem install bundler
    bundle install
    
The `charlock_holmes` gem requires the UCI libraries to be installed. If you are using Homebrew, it's probably as simple as this:
     
     brew install icu4c

More information about the gem can be found [here](https://github.com/brianmario/charlock_holmes)             

### ElasticSearch

We're using [Elasticsearch](http://www.elasticsearch.org/) (>= 5.6.3) for fulltext search. On a Mac, it's easy to install with [Homebrew](http://mxcl.github.com/homebrew/).

    brew install elasticsearch

Otherwise, follow the [instructions](http://www.elasticsearch.org/download/) to download and run it.

### Running it

Fire up a server:

    bundle exec rails s
    
### Specs

    bundle exec rspec

Elasticsearch must be running. 


