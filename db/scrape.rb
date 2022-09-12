require 'open-uri'
require 'nokogiri'
require "net/http"

def scrape_meta(url)
  html_file = URI.parse(url)
  return unless url?(html_file)

  html_file = html_file.open.read
  html_doc = Nokogiri::HTML(html_file)

  html_doc.search('.score-meta').children.text.strip.to_i
end

def scrape_rotten(url)
  # encoded_url = URI.encode(url)
  html_file = URI.parse(url)
  return unless url?(html_file)

  html_file = html_file.open.read
  html_doc = Nokogiri::HTML(html_file)

  arr = []
  html_doc.search('score-board').each do |element|
    arr << element.attributes['audiencescore'].value
    arr << element.attributes['tomatometerscore'].value
  end
  arr
end

def url?(html)
  req = Net::HTTP.new(html.host, html.port)
  req.use_ssl = (html.scheme == 'https')
  path = html.path if html.path
  res = req.request_head(path || '/')
  res.code != '404' # false if returns 404 - not found
end
