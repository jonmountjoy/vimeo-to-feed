# generates a feed from the latest videos on a Vimeo pro account.
# expects URL and PASSWORD config vars to be set

require "rss"

class App < Sinatra::Application

  get "/" do
    rss = generate_feed
    rss.to_s
  end
  
  protected

  def generate_feed
        
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'

    # fetch the page and enter the password
    page = agent.get(ENV['URL'])
    form = page.form()
    form.password = ENV['PASSWORD']

    # submit password 
    videopage = agent.submit(form)

    # retrieve videos listed on first page only
    clips = videopage.search(".//ol[@id='clips']/li")

    # generate feed
    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.author="Jon"
      maker.channel.updated = Time.now.to_s
      maker.channel.about=ENV['URL']
      maker.channel.title="Vimeo Recordings"

      clips.each do |clip|
        maker.items.new_item do |item|
          title = clip.xpath('section/h2').text
          time = clip.xpath('section/time').first.attributes['datetime'].text
          url = clip.xpath('div/iframe').first.attributes['src'].text
          item.link = url
          item.title = title
          item.updated = time
          #puts "#{time} #{url} #{title}"
        end
      end
    end

    rss

  end

end
