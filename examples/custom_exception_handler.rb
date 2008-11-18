def cause_error
  catch { puts((1/0).to_f) }
end

def catch
  yield
  rescue Exception => e
    puts "Rerouting to $stderr output..."
    $stderr.instance_eval do
      backtrace = e.backtrace
      puts "#{backtrace.shift}: #{e.message} (#{e.class})"
      backtrace.each { |ex| puts "\tfrom #{ex}" }
    end
end
  
cause_error