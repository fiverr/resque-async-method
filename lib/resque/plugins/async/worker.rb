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
    if id == 0
      #class method
      klass.constantize.send(args.shift, *args)
    else
      #instance method
      klass.constantize.find(id).send(args.shift, *args)
    end
  end
end