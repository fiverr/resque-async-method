require 'resque/plugins/async/worker'

module Resque::Plugins::Async::Method
  extend ActiveSupport::Concern

  def enqueue(method, opts, *args)
    my_klass       = Resque::Plugins::Async::Worker
    my_klass.queue = opts[:queue] ||
                     send(:class).name.underscore.pluralize
    if self.methods(false).include?(method.to_s)
      #class method
      id = 0
    else
      #instance, thus there is an ID
      id = send(:id)
    end
    clean_method = method.to_s.gsub("!","")
    method_without_enqueue = "#{clean_method}_without_enqueue#{'!' if clean_method != method.to_s}"
    Resque.enqueue(
      my_klass,
      send(:class).name == "Class" ? send(:name) : send(:class).name,
      id,
      :"#{method_without_enqueue}",
      *args
    )
    #Delayed::Job.enqueue Delayed::PerformableMethod.new(self, method.to_sym, args)
  end
  
  module ClassMethods
    def async_method(method, opts={})
      clean_method = method.to_s.gsub("!","")
      define_method("#{clean_method}_with_enqueue#{'!' if clean_method != method.to_s}") do |*args|
        enqueue(method, opts, *args)
      end
      alias_method_chain method, :enqueue
    end
  end

end