class Resque::Plugins::Async::Worker
  @queue = :async_methods
  
  def self.queue=(name)
    @queue = name
  end
  
  def self.queue
    @queue
  end
  
  # we want to make sure that the objects passed to the worker make sense
  # resque serializes AR arguments, making calls fail miserably
  # thus, we turned them into hashes which look like {:class_name => Class, :id => id}
  # and turn them back to AR records before using them.

  def self.perform(klass, *args)
    id = args.shift
    # the first argument is always the method name.

    arguments = *args.map { |o| o.is_a?(Hash) && o.has_key?("class_name") && o.has_key?("id") ? o["class_name"].constantize.find(o["id"]) : o }
    arguments = arguments.to_a
    if id == 0
      # id = 0 is the de-facto way fo saying "This is a class method"
      klass.constantize.send(arguments.shift, *arguments)
    else
      # instance method
      klass.constantize.find(id).send(arguments.shift, *arguments)
    end      
  end

  
end
