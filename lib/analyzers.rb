module Analyzers
  mattr_reader :definitions
  @@definitions = {
    snowball_asciifolding_nostop: {
      tokenizer: 'standard',
      filter:    %w(standard asciifolding lowercase snowball)
    },
    keyword_lowercase:            {
      tokenizer: 'keyword',
      filter:    %w(standard lowercase)
    }
  }.freeze
end
