require 'minitest/autorun'
require 'jekyll'
require_relative '../lib/jekyll-pandoc-exports/generator'

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