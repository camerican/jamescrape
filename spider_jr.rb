# spider_jr.rb
require 'nokogiri'
require 'open-uri'
require 'json'

# Note: Please run this script via the Rails runner
# ex: rails runner ./spider_jr.rb
#
# ref: http://stackoverflow.com/questions/16836633/how-to-connect-to-database-from-script-in-lib-dir

base_pr_uri = 'https://www.princetonreview.com/college-search'

def process_school doc, state_id
  p "Processing school..."
  doc.css(".school-col").each do |school_data|
    begin
      url = school_data.at_css("h2.margin-top-none > a")[:href]

      url_match = /\/schools\/(\d+)\/college\/(.+)/.match(url)
    rescue
      p "Wah, I broke my scraper!!!! #{url}"
      next
    end

    school_params = {
      name: school_data.at_css("h2.margin-top-none > a").text,
      location: school_data.at_css(".location").text,
      state_id: state_id,
      pr_id: url_match[1],
      pr_code: url_match[2]
    }

    p school_params

    School.create(school_params)

  end
end


# iterate over each state
State.all[2..10].each do |state|
  # first, find the number of results and calculate the number of pages
  # that we need to scrape
  doc = Nokogiri::HTML(open("#{base_pr_uri}/?states=#{state.code.downcase}"))
  begin 
    pages = (doc.at_css(".col-sm-6 > h4").to_s.downcase.match(/\W(\d+)\Wresults/)[1].to_f/20).ceil
  rescue
    pages = 1
  end

  process_school(doc,state.id)

  # next pages 2 and up
  (2..pages).each do |page|
    sleep(10)
    next_doc = Nokogiri::HTML(open("#{base_pr_uri}?states=#{state.code.downcase}&page=#{page}"))
    process_school(next_doc,state.id)
  end
  sleep(10)
  # then go and grab all the school urls for this state for each page
end



