require 'open-uri'
require 'nokogiri'
require 'fileutils'


class Scraper
  attr_accessor :base, :counter

  def initialize(base)
    @base = base 
    @counter = 1
    download_photos(@base)
  end 

  def download_photos(pg)
    page = Nokogiri::HTML(open(pg))
    photos = page.css("img").map { |photo| photo['src'] }
    photos.each do |url|
      fname_base = "photo"
      tag = ".jpg"
      begin
        content = open(url).read
      rescue Exception=>e
        puts "Error: #{e}"
        sleep 3
      else
        File.open(fname_base + counter.to_s + tag, 'w') {|file| file.write(content)}
        puts "\t...saving to #{fname_base + counter.to_s + tag}"
      end
    @counter += 1 
    end 
    if pg == @base 
      gather_links(page)
    end 
  end 
  
  def gather_links(page)
    links = page.css(".menu a").map { |link| link['href'] }.uniq
    links.select! { |link| link.is_a?(String) && link[0] == "/" }
    visit_pages(links)
  end 

  def visit_pages(links)
    links.each do |link|
      new_url = @base + link
      download_photos(new_url)
    end 
    puts "Successfully downloaded #{@counter - 1} photos"
  end 
end 


Scraper.new("https://ashleynbreton.com")
