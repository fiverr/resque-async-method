require 'active_support/dependencies'

module Resque
  module Plugins
    module Async
      autoload :Method, 'resque/plugins/async/method'
      autoload :Worker, 'resque/plugins/async/worker'
    end
  end
end

autoload :ActiveRecord, 'active_record'
include Resque::Plugins::Async::Method