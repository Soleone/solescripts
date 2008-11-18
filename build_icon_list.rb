def get_images(path, extension)
  imgs = []
 # path = File.expand_path(path)
  puts ">> #{path}"
  pngs = File.join(path, "**", '*' + extension)
  
  Dir.glob(pngs).each do |f|
    puts "> #{f}"
    if File.directory?(File.expand_path(f)) && (f != '.') && (f != '..')
      directory = File.join(path, f)
      puts "Recursion in directory: #{directory}"
      imgs << get_images(directory, extension)
    elsif f =~ /#{extension}$/
      image = File.expand_path(f)#File.join(path, f)
      puts "adding image file: #{image}"
      imgs << image
    else
      #puts f
    end
  end
  imgs
end

def build_html(images)
  string = "<html><body>"
  string << "<h2>Displaying #{images.size} images</h2>"
  string << append_images("", images)
  string << "</body></html>"
end
  
def append_images(output, images)
  images.each do |img|
    if img.is_a? Array
      output << append_images(output, img)
    else
      output << "<img src='file:///" << img << "' />\n"
    end
  end
  output
end

def write_file(content, location)
  filename = File.join(File.expand_path(location), 'my_icon_list.html')
  File.open(filename, 'w') do |file|
    file.write(content)
  end
  puts "Wrote HTML file to #{filename}"
end

if $0 == __FILE__
	if ARGV.empty?
		puts "\nCreates a new HTML file, which display all images located in a DIRECTORY"
		puts "\nUsage:\nruby build_icon_list.rb DIRECTORY"
		puts "Or: build_icon_list DIRECTORY"
		puts "\n  Examples:\n  build_icon_list .\n  build_icon_list d:/my_icons"
		exit
	end
	dir, ext = ARGV[0], (ARGV[1] || '.png')

	html = build_html(get_images(dir, ext))
	write_file(html, dir)
	puts "Finished!"
end
