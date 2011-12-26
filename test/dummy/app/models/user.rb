class User < ActiveRecord::Base

  class << self
    def long_class_method
      return "I am class method!"
    end

    async_method :long_class_method
  end

  def long_method
    return "success!"
  end
  async_method :long_method, :queue => 'long-methods'
  
  def another_long_method
    return "success"
  end
  async_method :another_long_method

  def another_long_method!
    return "success!!!"
  end
  async_method :another_long_method!
end
