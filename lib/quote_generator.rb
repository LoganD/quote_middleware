GERVAIS_QUOTES = File.readlines('data/rickygervais.txt').map{ |line| line.strip + " - Gervais" }
MERCHANT_QUOTES = File.readlines('data/merchant_quotes.txt').map{ |line| line.strip + " - Merchant"}

class QuoteGenerator
  def initialize(app)
    @app = app
    @quotes = GERVAIS_QUOTES + MERCHANT_QUOTES
    generate_quote_index
    @all_quotes_range = get_randomized_array_of_quote_indexes
  end

  def call(env)
    req = Rack::Request.new(env)
    case req.path_info
    when /all-quotes/
      @all_quotes_range.shuffle()
      quotes = @all_quotes_range.map { |i, index| @quotes[i] + "\n" }.join("")
      [200, {"Content-Type" => "text/plain"}, [quotes]]
    when /quote/
      if req.post?
        [404, {"Content-Type" => "text/plain"}, []]
      elsif req.get?
        generate_quote_index if @quote_index.length == 0
        [200, {"Content-Type" => "text/plain"}, [@quotes[@quote_index.pop()]]]
      else
        [404, {"Content-Type" => "text/plain"}, ["These aren't the request types you're looking for. Try a GET."]]
      end
    else
      @app.call(env)
    end
  end

  def generate_quote_index
    @quote_index ||= Queue.new
    get_randomized_array_of_quote_indexes.each { |elem| @quote_index.push(elem) }
  end

  def get_randomized_array_of_quote_indexes
    (0...@quotes.length).to_a.shuffle()
  end
end
