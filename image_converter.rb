def file_name(f)
  return f[0...-4]
end

def is_png(f)
  return f[-4..-1] == ".png"
end

BASE_PATH = "d:\\code\\workspaces\\rails\\linklist\\public\\images\\icons\\"
dir = Dir.new(BASE_PATH)

dir.each do |file|
  if is_png(file)
    puts system("convert", BASE_PATH + file, BASE_PATH + "icons_gif\\" + file_name(file) + ".gif")
  end
end