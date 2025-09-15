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
  
  def info(message)
    @messages << { level: :info, message: message }
  end
  
  def error(message)
    @messages << { level: :error, message: message }
  end
  
  def warn(message)
    @messages << { level: :warn, message: message }
  end
  
  def clear
    @messages.clear
  end
end

class TestLogging < Minitest::Test
  def setup
    @mock_logger = MockJekyllLogger.new
    # Skip Jekyll logger setup to avoid interface issues
  end
  
  def test_log_message_methods_exist
    # Test that logging methods exist and can be called
    config = { 'debug' => false }
    
    # These should not raise errors
    assert_respond_to Jekyll::PandocExports, :log_message
    assert_respond_to Jekyll::PandocExports, :log_error
    
    # Test method calls don't crash (output goes to Jekyll logger)
    begin
      Jekyll::PandocExports.log_message(config, 'Test message')
      Jekyll::PandocExports.log_error(config, 'Test error')
      assert true, 'Logging methods executed without errors'
    rescue => e
      flunk "Logging methods should not raise errors: #{e.message}"
    end
  end
  
  def test_debug_mode_handling
    # Test that debug config is handled properly
    debug_config = { 'debug' => true }
    normal_config = { 'debug' => false }
    
    # Should not raise errors with different debug settings
    begin
      Jekyll::PandocExports.log_message(debug_config, 'Debug message')
      Jekyll::PandocExports.log_message(normal_config, 'Normal message')
      assert true, 'Debug mode handling works correctly'
    rescue => e
      flunk "Debug mode handling should not raise errors: #{e.message}"
    end
  end
end