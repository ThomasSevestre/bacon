
require 'mocha'

#
# This extension ensure that mocha expectations are considered
# as bacon tests. Amongst other thing it allows to have a test
# containing only mocha expectations.
# 
module Bacon
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
        rescue Mocha::ExpectationError => e
          raise Error.new(:failed, "#{e.message}\n#{e.backtrace[0...10].join("\n")}")
        ensure
          mocha_teardown
        end
      end
    end
    
  end
  
  Context.send(:include, MochaSpec)
end
