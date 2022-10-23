require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require_relative 'scrape'

# puts "cleaning database"
# Movie.destroy_all
page = 5
# PARAMETERS
while page < 12
country = 'us'
service = 'netflix' # prime, disney, hbo, hulu, peacock, paramount, starz, showtime, apple
type = 'movie' # or series
genre = ''
url = URI("https://streaming-availability.p.rapidapi.com/search/basic?country=#{country}&service=#{service}&type=#{type}&genre=#{genre}&page=#{page}&output_language=en&language=en")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request['X-RapidAPI-Key'] = 'e4706810edmsh76a8aeb1b1ef015p170630jsneaab7251f736'
request['X-RapidAPI-Host'] = 'streaming-availability.p.rapidapi.com'

response = http.request(request)

db = JSON.parse(response.read_body)

db['results'].each do |result|
  puts "Calculating #{result['title']}"
  next if result['imdbRating'].to_i <= 60

  rotten_array = scrape_rotten("https://www.rottentomatoes.com/m/#{result['title'].gsub(/[#^&@.:%]/, '').gsub(/\s/, '_')}")
  next if rotten_array.nil?

  movies = { title: result['title'],
             year: result['year'],
             cast: result['cast'],
             overview: result['overview'],
             poster_url: result['posterPath'],
             mcscore: scrape_meta("https://www.imdb.com/title/#{result['imdbID']}/").to_i,
             rtscore: rotten_array[1].to_i,
             rtauscore: rotten_array[0].to_i,
             video: result['video'] }

  next if !movies[:rtscore].nil? && movies[:rtscore] < 45
  next if !movies[:mcscore].nil? && movies[:mcscore] < 35

  puts "Sending #{result['title']} your way"
  Movie.create(movies)
end

puts 'End of seeding batch'
page += 1

end
