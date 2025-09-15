module Jekyll
  module PandocExports
    class Hooks
      @pre_conversion_hooks = []
      @post_conversion_hooks = []
      
      class << self
        attr_reader :pre_conversion_hooks, :post_conversion_hooks
        
        def register_pre_conversion(&block)
          @pre_conversion_hooks << block
        end
        
        def register_post_conversion(&block)
          @post_conversion_hooks << block
        end
        
        def run_pre_conversion_hooks(html_content, config, context = {})
          @pre_conversion_hooks.each do |hook|
            html_content = hook.call(html_content, config, context) || html_content
          end
          html_content
        end
        
        def run_post_conversion_hooks(content, format, config, context = {})
          @post_conversion_hooks.each do |hook|
            content = hook.call(content, format, config, context) || content
          end
          content
        end
        
        def clear_hooks
          @pre_conversion_hooks.clear
          @post_conversion_hooks.clear
        end
      end
    end
  end
end