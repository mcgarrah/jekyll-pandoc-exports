require 'minitest/autorun'

# Load validation functionality for testing
module Jekyll
  module PandocExports
    def self.validate_content_size(html_content, config)
      max_size = config['max_file_size'] || 10_000_000 # 10MB default
      
      if html_content.bytesize > max_size
        return false if config['strict_size_limit']
      end
      
      true
    end
  end
end

class TestValidation < Minitest::Test
  def test_validate_content_size_within_limit
    content = 'Small content'
    config = { 'max_file_size' => 1000 }
    
    assert Jekyll::PandocExports.validate_content_size(content, config)
  end
  
  def test_validate_content_size_exceeds_limit_not_strict
    content = 'A' * 2000
    config = { 'max_file_size' => 1000, 'strict_size_limit' => false }
    
    assert Jekyll::PandocExports.validate_content_size(content, config)
  end
  
  def test_validate_content_size_exceeds_limit_strict
    content = 'A' * 2000
    config = { 'max_file_size' => 1000, 'strict_size_limit' => true }
    
    refute Jekyll::PandocExports.validate_content_size(content, config)
  end
  
  def test_validate_content_size_default_limit
    content = 'Normal content'
    config = {}
    
    assert Jekyll::PandocExports.validate_content_size(content, config)
  end
  
  def test_validate_content_size_large_content_default
    content = 'A' * 15_000_000  # 15MB
    config = {}
    
    assert Jekyll::PandocExports.validate_content_size(content, config)
  end
end