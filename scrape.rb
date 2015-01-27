# A Sinatra web app that uses open-uri to open other websites and nokogiri to scrape some info.

require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'sentimental'

# Loads the default dictionary that comes with the gem and sets a rating threshold.
Sentimental.load_defaults
Sentimental.threshold = 0.1

# Only used to display the name form.
get '/' do
  erb :main
end

# Gets the name and searches for it on urbandictionary.
post '/result' do

  analyzer = Sentimental.new

  @name = params[:name]
  @name = @name.chomp.strip

  url = "http://www.urbandictionary.com/define.php?term=#{@name}"
  url2 = "http://randomamazonproduct.com/"

  data = Nokogiri::HTML(open(url))
  data2 = Nokogiri::HTML(open(url2))

  # If the text input doesn't have an entry, this will return a default meaning.
  if data.at_css('.meaning') == nil
    @meaning = 'Not popular enough...'
  else
    @meaning = data.at_css('.meaning').text.strip
  end

  # The meaning is analyzed and a random amazon product name and picture are also scraped.
  @sentiment = analyzer.get_sentiment(@meaning)
  @image = data2.at_css('.amazon-image').attr('src')
  @product = data2.at_css('.amazon-title').text.strip

  erb :result
end
