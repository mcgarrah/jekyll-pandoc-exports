require 'minitest/autorun'
require_relative '../lib/jekyll-pandoc-exports/generator'

# Mock Jekyll logger for testing
class MockJekyllLogger
  attr_reader :messages
  
  def initialize
    @messages = []
    @level = :info
  end
  
  def level=(level)
    @level = level
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
  
  def clear
    @messages.clear
  end
end

class TestLogging < Minitest::Test
  def setup
    @original_logger = Jekyll.logger if defined?(Jekyll.logger)
    @mock_logger = MockJekyllLogger.new
    Jekyll.logger = @mock_logger
  end
  
  def teardown
    Jekyll.logger = @original_logger if @original_logger
  end
  
  def test_log_message_normal_mode
    config = { 'debug' => false }
    Jekyll::PandocExports.log_message(config, 'Test message')
    
    messages = @mock_logger.messages
    assert_equal 1, messages.length
    assert_equal :info, messages.first[:level]
    assert_equal 'Pandoc Exports:', messages.first[:prefix]
    assert_equal 'Test message', messages.first[:message]
  end
  
  def test_log_message_debug_mode
    config = { 'debug' => true }
    Jekyll::PandocExports.log_message(config, 'Debug message')
    
    messages = @mock_logger.messages
    assert_equal 1, messages.length
    assert_equal :info, messages.first[:level]
    assert_equal 'Pandoc Exports [DEBUG]:', messages.first[:prefix]
    assert_equal 'Debug message', messages.first[:message]
  end
  
  def test_log_error
    config = {}
    Jekyll::PandocExports.log_error(config, 'Error occurred')
    
    messages = @mock_logger.messages
    assert_equal 1, messages.length
    assert_equal :error, messages.first[:level]
    assert_equal 'Pandoc Exports:', messages.first[:prefix]
    assert_equal 'Error occurred', messages.first[:message]
  end
end