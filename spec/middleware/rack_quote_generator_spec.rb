GERVAIS_TEST_QUOTES = File.readlines('./test/fixtures/files/rickygervais.txt').map{ |line| line.strip }

require './lib/quote_generator'
require 'rack/mock'

RSpec.describe QuoteGenerator do
  default_app = [200, {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
  let(:env) { double(:env) }

  app = Proc.new do |env|
    default_app
  end

  let(:middleware) { QuoteGenerator.new(app) }

  it 'returns a quote on GET /quote' do
    env = Rack::MockRequest.env_for("/quote")
    status, headers, body = middleware.call(env)
    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/plain")
    expect(GERVAIS_TEST_QUOTES).to include(body[0])
  end

  it 'returns an error with empty body on POST /quote' do
    env = Rack::MockRequest.env_for("/quote",
      "REQUEST_METHOD" => 'POST')
    status, _, body = middleware.call(env)
    expect(status).to eq(404)
    expect(nil).to eq(body[0])
  end

  it 'returns humor on any other request type on /quote' do
    env = Rack::MockRequest.env_for("/quote",
      "REQUEST_METHOD" => 'DELETE')
    status, _, body = middleware.call(env)
    expect(status).to eq(404)
    expect(body).to eq(["These aren't the request types you're looking for. Try a GET."])
  end

  it 'returns the app response on anything else' do
    env = Rack::MockRequest.env_for("/")
    status, _, body = middleware.call(env)
    expect(status).to eq(200)
    expect(body).to eq(default_app[2])
  end
end
