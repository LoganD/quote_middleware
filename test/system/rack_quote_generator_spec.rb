GERVAIS_TEST_QUOTES = File.readlines('./test/fixtures/files/rickygervais.txt').map{ |line| line.strip }

require './lib/quote_generator'

RSpec.describe QuoteGenerator do
  it 'returns a quote on GET /quote'
  it 'returns an error with empty body on POST /quote'
  it 'returns humor on any other request type on /quote'
  it 'returns the app response on anything else'
end
