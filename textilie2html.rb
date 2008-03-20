require 'rubygems'
require 'redcloth'

input, output = ARGV[0], ARGV[1]
exit "Usage: textile2html SOURCE_FILE_NAME TARGET_FILE_NAME" unless input && output
input, output = File.expand_path(input), File.expand_path(output)

textile = File.new(input).readlines.join("\n")
File.open(output, 'w') do |file|
	file.write(RedCloth.new(textile).to_html)
end
puts "Successfully converted '#{input}' to '#{output}'"