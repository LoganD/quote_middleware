GERVAIS_QUOTES = File.readlines('data/rickygervais.txt').map{ |line| line.strip }

class QuoteGenerator
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    case req.path_info
    when /quote/
      if req.post?
        [404, {"Content-Type" => "text/plain"}, []]
      elsif req.get?
        gen = Random.new()
        [200, {"Content-Type" => "text/plain"}, [GERVAIS_QUOTES[gen.rand(0...GERVAIS_QUOTES.length)]]]
      else
        [404, {"Content-Type" => "text/plain"}, ["These aren't the request types you're looking for. Try a GET."]]
      end
    else
      @app.call(env)
    end
  end
end
