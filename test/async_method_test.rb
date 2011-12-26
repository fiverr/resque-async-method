require 'test_helper'

class AsyncMethodTest < ActiveSupport::TestCase
  test "define methods" do
    assert User.new.respond_to?(:long_method)
    assert User.new.respond_to?(:another_long_method)
    
    assert User.new.respond_to?(:long_method_without_enqueue)
    assert User.new.respond_to?(:another_long_method_without_enqueue)

    assert User.respond_to?(:long_class_method)
    assert User.respond_to?(:long_class_method_without_enqueue)
  end
  
  test "enqueue jobs" do
    user = User.first
    
    assert_equal [], user.long_method
    assert_equal 'success!', user.long_method_without_enqueue

#checks that two methods differing only by (!) can be called

    assert_equal [], user.another_long_method
    assert_equal 'success', user.another_long_method_without_enqueue

    assert_equal [], user.another_long_method!
    assert_equal 'success!!!', user.another_long_method_without_enqueue!

# checks that class methods can be also async
    
    assert_equal [], User.long_class_method
    assert_equal "I am class method!", User.long_class_method_without_enqueue
    
  end
  
  test "lint" do
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::Async::Method)
    end
  end
end
