class QuoteGenerator
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    case req.path_info
    when /quote/
      gen = Random.new()
      [200, {"Content-Type" => "text/plain"}, [GERVAIS_QUOTES[gen.rand(0...GERVAIS_QUOTES.length)]]]
    else
      @app.call(env)
    end
  end
end
