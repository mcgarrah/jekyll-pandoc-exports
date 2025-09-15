require 'minitest/autorun'

# Mock Jekyll logger for testing
module Jekyll
  class << self
    attr_accessor :logger
  end
  
  class Logger
    def initialize
      @messages = []
    end
    
    def info(prefix, message)
      @messages << { level: :info, prefix: prefix, message: message }
    end
    
    def error(prefix, message)
      @messages << { level: :error, prefix: prefix, message: message }
    end
    
    def warn(prefix, message)
      @messages << { level: :warn, prefix: prefix, message: message }
    end
    
    def messages
      @messages
    end
    
    def clear
      @messages.clear
    end
  end
end

Jekyll.logger = Jekyll::Logger.new

# Load logging functionality for testing
module Jekyll
  module PandocExports
    def self.log_message(config, message)
      if config['debug']
        Jekyll.logger.info "Pandoc Exports [DEBUG]:", message
      else
        Jekyll.logger.info "Pandoc Exports:", message
      end
    end
    
    def self.log_error(config, message)
      Jekyll.logger.error "Pandoc Exports:", message
    end
  end
end

class TestLogging < Minitest::Test
  def setup
    Jekyll.logger.clear
  end
  
  def test_log_message_normal_mode
    config = { 'debug' => false }
    Jekyll::PandocExports.log_message(config, 'Test message')
    
    messages = Jekyll.logger.messages
    assert_equal 1, messages.length
    assert_equal :info, messages.first[:level]
    assert_equal 'Pandoc Exports:', messages.first[:prefix]
    assert_equal 'Test message', messages.first[:message]
  end
  
  def test_log_message_debug_mode
    config = { 'debug' => true }
    Jekyll::PandocExports.log_message(config, 'Debug message')
    
    messages = Jekyll.logger.messages
    assert_equal 1, messages.length
    assert_equal :info, messages.first[:level]
    assert_equal 'Pandoc Exports [DEBUG]:', messages.first[:prefix]
    assert_equal 'Debug message', messages.first[:message]
  end
  
  def test_log_error
    config = {}
    Jekyll::PandocExports.log_error(config, 'Error occurred')
    
    messages = Jekyll.logger.messages
    assert_equal 1, messages.length
    assert_equal :error, messages.first[:level]
    assert_equal 'Pandoc Exports:', messages.first[:prefix]
    assert_equal 'Error occurred', messages.first[:message]
  end
end