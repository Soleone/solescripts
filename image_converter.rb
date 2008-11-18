def file_name(f)
  return f[0...-4]
end

def is_png(f)
  return f[-4..-1] == ".png"
end

BASE_PATH = ARGV[0] || '.'
dir = Dir.new(BASE_PATH)

Dir["#{BASE_PATH}/**"].each do |file|
  if is_png(file)
    cmd = "convert " + file + ' ' + File.join(file_name(file) + ".gif")
  puts cmd
  puts system(cmd) ? "Converted" : "Error"
  end
end
