
gem 'mocha', '~> 1.1.0'
require 'mocha/api'

#
# This extension ensure that mocha expectations are considered
# as bacon tests. Amongst other thing it allows to have a test
# containing only mocha expectations.
# 
module Bacon
  def self.freeze_time(t = Time.now)
    Time.stubs(:now).returns(t)
    if block_given?
      begin
        yield
      ensure
        Time.unstub(:now)
      end
    end
  end
  
  class Context
    def freeze_time(*args, &block)
      Bacon.freeze_time(*args, &block)
    end
    
  end
  
  module MochaRequirementsCounter
    def self.increment
      Counter[:requirements] += 1
    end
  end
  
  module MochaSpec
    def self.included(base)
      base.send(:include, Mocha::API)
    end
    
    def execute_spec(&block)
      super do
        begin
          mocha_setup
          block.call
          mocha_verify(MochaRequirementsCounter)
        ensure
          mocha_teardown
        end
      end
    end
    
  end
  
  Context.send(:include, MochaSpec)
end
