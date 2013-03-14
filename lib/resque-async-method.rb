require 'active_support/dependencies'

module Resque
  module Plugins
    module Async
      autoload :Method, 	'resque/plugins/async/method'
      autoload :Worker, 'resque/plugins/async/worker'
      autoload :ClassWorker, 'resque/plugins/async/class_worker'
    end
  end
end

autoload :ActiveRecord, 'active_record'
include Resque::Plugins::Async::Method