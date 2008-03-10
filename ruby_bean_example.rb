#// the same Bean in Ruby (~6 lines)
class User
	attr_accessor :id, :name, :emails
	
	def initialize(id=0, name="", emails=[])
		@id, @name, @emails = id, name, emails
	end
  
  def ==(user)
    return self.id == user.id && self.name == user.name && self.emails == user.emails
  end
end
#// now instantiate two actual users. watch the syntactic sugar and 
#// how we can instantiate an array (works like a java List) with a literal []
user = User.new
user.name = "sole"
user.emails << "test@bla.de"
#// compare both users, they should be equal
puts user == User.new(0, "sole", ["test@bla.de"])
#// should return true