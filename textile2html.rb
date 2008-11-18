require 'rubygems'
require 'redcloth'

# Check if 2 arguments have been supplied, else quit with usage message
input, output = ARGV[0], ARGV[1]
exit "Usage: textile2html SOURCE_FILE_NAME TARGET_FILE_NAME" unless input && output
input, output = File.expand_path(input), File.expand_path(output)

# Read the input file (textile)
textile = File.new(input).readlines.join('')
# Write the output file (converted html)
File.open(output, 'w') do |file|
	file.write(RedCloth.new(textile).to_html)
end

puts "Successfully converted '#{input}' to '#{output}'"
