#!/usr/bin/ruby
require 'rubygems'
require 'hpricot'
require 'open-uri'

url = 'http://www.stylegala.com/features/bulletmadness/'

def get_elements_from_webpage(url, regexp=/\.png$/, element_type='img', element_attribute='src')
  values = []
  doc = Hpricot(open(url))
  elements = doc/element_type
  elements.each do |element|
    attribute = element[element_attribute]
    values << attribute if attribute =~ Regexp.new(regexp)
  end
  values
end

def download_resources(target_path, urls)
  urls.each do |url|
		download_resource(url, target_path)
  end
end

def download_resource(url, target_path)
	# create target directory if not existent
	path = File.expand_path(target_path)
  Dir.mkdir(path) unless File.exists?(path)
  # get filename
  filename = url.to_s.split('/').last
  strip_url_params! filename
  # download path
  fullpath = File.join(path, filename)
  puts "Downloading #{url} to #{fullpath}"
  url = URI.escape(url)
  # open a URI and write the content (as binary) to a local file
  open(fullpath, 'wb').write(open(url).read)
end

def download(url, regexp, download_path, element_type='img', element_attribute='src')
  urls = get_elements_from_webpage(url, regexp)
  download_resources(download_path, urls) 
end

def strip_url_params!(url)
	url.gsub!(/\?.*/, '')	
end

if $0 == __FILE__
  case ARGV.size
	when 2
		download_resource ARGV[0], ARGV[1]
	when 3..5
    download ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4]
  else
    puts "\nDownloads files from the internet to your local hard disk."
    puts "\nUsage:   file_downloader.rb URL REGEXP DOWNLOAD_PATH"
    puts "Example: file_downloader.rb http://www.google.de /\.gif$/ download" 
    puts "\nThis would download all images ending with '.gif' from www.google.de to the 'download' folder on your disk."
  end
end
