require 'bundler/setup'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'atom'

get '/' do
  "Use /feed or /feed?pro_token=PRO_TOKEN"
end

get '/feed' do
  if params[:pro_token]
    url = "http://railscasts.com/subscriptions/#{params[:pro_token]}/episodes.rss"
  else
    url = 'http://feeds.feedburner.com/railscasts'
  end

  feed = Nokogiri::XML(open(url))

  output = Atom::Feed.new do |f|
    f.title = "Dropcasts #{"Pro " if params[:pro_token]}Feed"
    f.updated = Time.parse(feed.xpath("//lastBuildDate").first.content)
    feed.xpath("//item").each do |enclosure|
      f.entries << Atom::Entry.new do |e|
        e.title = enclosure.xpath("title").first.content
        e.links << Atom::Link.new(href: enclosure.xpath("enclosure").first[:url])
        e.summary = enclosure.xpath("description").first.content
      end
    end
  end
  output.to_xml

end

