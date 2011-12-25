class Resque::Plugins::Async::Worker
  @queue = :async_methods
  
  def self.queue=(name)
    @queue = name
  end
  
  def self.queue
    @queue
  end
  
  def self.perform(klass, *args)
    id = args.shift
    arguments = *args.map { |o| o.is_a?(Hash) && o.has_key?("class_name") && o.has_key?("id") ? o["class_name"].constantize.find(o["id"]) : o }
    if id == 0
      #class method
      klass.constantize.send(args.shift, arguments)
    else
      #instance method
      klass.constantize.find(id).send(args.shift, arguments)
    end
  end
end