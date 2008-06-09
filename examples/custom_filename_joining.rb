#ENV.each do |k,v| puts k, v end
class String
  def /(other_string)
    File.join(self.to_s, other_string.to_s)
  end
end

class Symbol
  def /(other_symbol)
    self.to_s / other_symbol
  end
end

#file = File.join(ENV['HOMEDRIVE'], 'windows', 'inf', '1394.inf')
file = :c/:windows/:inf/'1394.inf'
def fopen(name)
  File.open(file, 'r') do |f|
    while line = f.gets do
      puts line
    end
  end
end
puts file
#fopen(file)


