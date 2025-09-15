require 'minitest/autorun'
require_relative '../lib/jekyll-pandoc-exports/hooks'

class TestHooks < Minitest::Test
  def setup
    Jekyll::PandocExports::Hooks.clear_hooks
  end
  
  def test_register_pre_conversion_hook
    hook_called = false
    Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
      hook_called = true
      html
    end
    
    Jekyll::PandocExports::Hooks.run_pre_conversion_hooks('<html></html>', {}, {})
    assert hook_called
  end
  
  def test_register_post_conversion_hook
    hook_called = false
    Jekyll::PandocExports::Hooks.register_post_conversion do |content, format, config, context|
      hook_called = true
      content
    end
    
    Jekyll::PandocExports::Hooks.run_post_conversion_hooks('content', :pdf, {}, {})
    assert hook_called
  end
  
  def test_pre_conversion_hook_modifies_content
    Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
      html.gsub('old', 'new')
    end
    
    result = Jekyll::PandocExports::Hooks.run_pre_conversion_hooks('<p>old content</p>', {}, {})
    assert_equal '<p>new content</p>', result
  end
  
  def test_post_conversion_hook_modifies_content
    Jekyll::PandocExports::Hooks.register_post_conversion do |content, format, config, context|
      "#{content} - processed"
    end
    
    result = Jekyll::PandocExports::Hooks.run_post_conversion_hooks('original', :docx, {}, {})
    assert_equal 'original - processed', result
  end
  
  def test_multiple_hooks_chain
    Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
      html.gsub('a', 'b')
    end
    
    Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
      html.gsub('b', 'c')
    end
    
    result = Jekyll::PandocExports::Hooks.run_pre_conversion_hooks('a', {}, {})
    assert_equal 'c', result
  end
  
  def test_hook_receives_context
    received_context = nil
    Jekyll::PandocExports::Hooks.register_pre_conversion do |html, config, context|
      received_context = context
      html
    end
    
    test_context = { format: :pdf, filename: 'test' }
    Jekyll::PandocExports::Hooks.run_pre_conversion_hooks('<html></html>', {}, test_context)
    
    assert_equal test_context, received_context
  end
end