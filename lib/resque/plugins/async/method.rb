require 'resque/plugins/async/worker'

module Resque::Plugins::Async::Method
  extend ActiveSupport::Concern

  def enqueue(method, opts, *args)
    my_klass       = Resque::Plugins::Async::Worker
    my_klass.queue = opts[:queue] ||
                     send(:class).name.underscore.pluralize
    if send(:class).name == "Class"
      # this means that the method called is a class method
      id = 0
    else
      # instance, thus there is an ID
      id = send(:id)
    end

    # methods which have an ! in their end, need to move the ! to the end, this creates
    # some rather ugly code, but what we do is we clean the !s, write the method's name,
    # and then check that it did have a ! in the end, finishing the new method name with a bang.
    
    clean_method = method.to_s.gsub("!","")
    method_without_enqueue = "#{clean_method}_without_enqueue#{'!' if clean_method != method.to_s}"
    

    # resque's stupid way of handling ActiveRecord parameters turns the parameter into a hash
    # workaround this issue is to pass them as a hash, and turn them back into their source
    # in the worker (see worker.rb)
    # issue is here: http://librelist.com/browser/resque/2010/5/20/passing-activerecord-arguments-to-jobs/
    # workaround: https://github.com/zapnap/resque_mailer/commit/9a0ad10

    *args = *args.map do |argument|
      if argument.is_a?(ActiveRecord::Base)
        {:class_name => argument.class.name, :id => argument.id}
      else
        argument
      end
    end

    # The enqueu uses the Async plugin class, which allows setting the queue name in the
    # async_method call, a-la delayed_job

    Resque.enqueue(
      my_klass,
      send(:class).name == "Class" ? send(:name) : send(:class).name,
      id,
      :"#{method_without_enqueue}",
      *args
    )
  end
  
  module ClassMethods

    def async_method(method, opts={})
      #we clean the method, please see the documentation above

      clean_method = method.to_s.gsub("!","")
      define_method("#{clean_method}_with_enqueue#{'!' if clean_method != method.to_s}") do |*args|
        enqueue(method, opts, *args)
      end
      alias_method_chain method, :enqueue
    end
  end

end