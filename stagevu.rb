require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'net/http'

URL = "http://stagevu.com/search?in=Videos&for="
VIDEO_PATH = "/Users/Soleone/Movies/TV series/Trailer Park Boys"
THREADS = 2
COMMANDS = ['download', 'simulate', 'search']
COMMAND_NAME = 'svu'

@command, @keywords, @episodes, @directory  = *ARGV


def search(words)
  url = URL + words.gsub(/ /, '+')
  doc = Hpricot(open(url))
  links = doc.search("div.resultcont h2 a")
  if links.empty?
    puts "Nothing found for keywords: #{words}"
    []
  else
    links.collect{|a| [a.inner_html, a['href']] }
  end
end

def video_link(url)
  doc = Hpricot(open(url))  
  links = doc.search("a")
  video_links = links.select{|a| a['href'] =~ /avi$/}
  video_links.first['href']
end

def output(text)
  return if text.nil? || text.empty?
  jump = "\r\e[0K"
  print jump + text
  $stdout.flush
end

def progress_bar(percentage)
  total_spaces = 25
  full_spaces = percentage.floor / 4
  string = "|#{'=' * full_spaces}"
  rest = percentage % 4
  if rest >= 2.0 && rest < 4.0
    string += '-'
    full_spaces += 1
  end
  string += '>'
  string += ' ' * (total_spaces - full_spaces)
  string += '|'
  string
end

def stream_copy(url, localfile, threadsafe = false)
  dir_path = @directory && File.directory?(@directory) ? @directory : VIDEO_PATH
  filename = "#{dir_path}/#{localfile}.avi"
  puts "Writing video file to: #{filename}"
  uri = URI(url)

  File.open(filename, 'wb') do |file|
    Net::HTTP.get_response(uri) do |res|
      size, total = 0, res.header['Content-Length'].to_i
      last_percentage = 0.0
      start = Time.now.to_i
      res.read_body do |chunk|
        time = Time.now.to_i - start
        size += chunk.size
        speed = (size.to_f / 1024) / time
        
        percentage = (((size * 100.0) / total) * 100).round / 100.0
        # Don't spam the console with too much updates when multi downloading (only update every full percent)
        percentage = percentage.round if threadsafe
        if percentage > last_percentage
          string = progress_bar(percentage) + '    '
          string += "%0.2f%% done (%0.2f of %0.2f mb) at %0.2f kb/s" % [percentage, size.to_f/1024**2, total.to_f/1024**2, speed]

          if threadsafe
            puts string + " [#{localfile}]"
            $stdout.flush
          else
            output string
          end

          last_percentage = percentage
        end
        file.write(chunk)
      end
    end
  end
end

def download(keywords, threadsafe = false)
  links = search(keywords)
  exit if links.empty?  

  title, url = links.first
  video = video_link(url)
  stream_copy(video, title.gsub(/ /, '_'), threadsafe)
end


def handle_episodes(keywords, episodes_string)
  if episodes_string
    episodes = episode_filenames(keywords, episodes_string)
    current_episode = 0
    while current_episode < episodes.size
      open_threads = []
      active_episodes = episodes[current_episode, THREADS]
      current_episode += THREADS
      active_episodes.each do |episode|
        thread = Thread.new do
          download(episode, true)
        end
        open_threads << thread
      end
      open_threads.each{|thread| puts "Joining thread #{thread}"; thread.join; sleep THREADS}
      sleep THREADS * 2
      c = Thread.list.size
      puts "Threads count: #{c}"
      while c > 1
        sleep 1
      end
    end
  else
    download(keywords)
  end
end

def episode_filenames(keywords, episodes_string)
  return keywords unless episodes_string
  
  if episodes_string.include?('+')
    return episodes_string.split('+').map{|eps| episode_filenames(keywords, eps) }.flatten
  end
  if episodes_string =~ /S(\d+)E(\d+)-S\d+E(\d+)/i
    # Format: series S0xEyy
    season, first, last = $1, $2, $3
    range = first.to_i..last.to_i
    episodes = range.map{|ep| "#{keywords} S#{'%02d' % season}E#{'%02d' % ep}" }
  else
    # Format: series xyy
    eps = episodes_string.split('-')
    range = eps.first.to_i..eps.last.to_i
    episodes = range.map{|ep| "#{keywords} #{ep.to_s}" }  
  end
  puts "Downloading episodes: #{episodes.join(', ')}"
  episodes
end

def handle_invalid_user_input
  unless @command && COMMANDS.include?(@command.downcase)
    puts "Unknown command: #{@command}, use one of #{COMMANDS.join(', ')}"
    exit
  end
  @command = @command.downcase

  if @keywords.nil? || @keywords.empty?
    puts "Can't #{@command} without keywords!\nSingle usage:"
    puts "  #{COMMAND_NAME} #{@command} \"your keywords\""
    if @command == 'download' || @command == 'simulate'
      puts "Multi file usage:"
      puts "  #{COMMAND_NAME} #{@command} \"your keywords\" s01e01-s01e10"
      puts "Custom directory download:"
      puts "  #{COMMAND_NAME} #{@command} \"your keywords\" s01e01-s01e10 ~/Movies/My existing directory"
    end
    exit
  end  
end

def execute_command
  print "Trying to #{@command} videos for '#{@keywords}'"
  print " with episodes #{@episodes}" if @episodes
  print " into target directory #{@directory}" if @directory
  puts
  
  case @command.downcase
  when 'download'
    handle_episodes(@keywords, @episodes)
  when'search'
    links = search(@keywords)
    links.each_with_index do |link, index|
      puts "[%02d] #{link.first} - #{link.last}" % (index+1)
    end
    if links.size > 0
      puts "Press a number to download or any other key to quit"
      print "Select: "
      $stdout.flush
      choice = $stdin.gets.chomp
      if number = choice[/\d+/]
        title, url = *links[number.to_i-1]
        puts "Downloading #{title} -> #{url}"
        video = video_link(url)
        stream_copy(video, title.first.gsub(/ /, '_'))
      end
    end
  when 'simulate'
    puts "Simulating download:"
    episode_filenames(@keywords, @episodes)  
  end  
end

# MAIN
handle_invalid_user_input
execute_command