CODE = <<'END_CODE'
class Ninja
  def self.hire(target_description, &instructions)
    self.new(target_description, instructions)
  end
 
  private
 
  # target_description can be either an object which responds to +#===+, or a
  # Proc which returns true or false.
  def initialize(target_description, instructions)
    @target_description = if target_description.kind_of?(Proc) then
                            target_description
                          else
                            lambda {|obj| target_description === obj}
                          end
    @instructions       = instructions
    @target             = acquire_target(@target_description)
    if @target.equal?(self)
      $stderr.puts "Never double-cross a Ninja!"
      exit
    elsif @target
      stalk(@target)
    else
      raise "No such object found!"
    end
  end
 
  def acquire_target(target_description)
    ObjectSpace.each_object do |object|
      if target_description.call(object)
        return object
      end
    end
    nil
  end
 
  def stalk(target)
    Thread.new do
      sleep(rand(60))
      attack!(target)
    end
  end
 
  def attack!(target)
    target.instance_eval(&@instructions)
  end
end
END_CODE
 
# Using eval conceals the Ninja in the stack trace
eval CODE