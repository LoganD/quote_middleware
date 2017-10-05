class QuoteGenerator
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    case req.path_info
    when /quote/
      [200, {"Content-Type" => "text/html"}, ["Hello, World!"]]
    else
      @app.call(env)
    end
  end
end
