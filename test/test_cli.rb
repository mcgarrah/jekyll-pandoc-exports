require 'minitest/autorun'
require 'tempfile'

# Mock the CLI class for testing
class CLI
  def initialize
    @options = {
      source: '.',
      destination: '_site',
      format: 'both',
      output_dir: nil,
      debug: false
    }
  end
  
  def parse_options_for_test(args)
    # Simplified option parsing for testing
    args.each_with_index do |arg, i|
      case arg
      when '--file', '-f'
        @options[:file] = args[i + 1]
      when '--format'
        @options[:format] = args[i + 1]
      when '--output', '-o'
        @options[:output_dir] = args[i + 1]
      when '--debug'
        @options[:debug] = true
      end
    end
    @options
  end
  
  def build_config
    config = {
      'enabled' => true,
      'debug' => @options[:debug],
      'pdf_options' => { 'variable' => 'geometry:margin=1in' },
      'unicode_cleanup' => true
    }
    
    config['output_dir'] = @options[:output_dir] if @options[:output_dir]
    config
  end
end

class TestCLI < Minitest::Test
  def setup
    @cli = CLI.new
  end
  
  def test_default_options
    options = @cli.parse_options_for_test([])
    
    assert_equal '.', options[:source]
    assert_equal '_site', options[:destination]
    assert_equal 'both', options[:format]
    assert_nil options[:output_dir]
    assert_equal false, options[:debug]
  end
  
  def test_file_option
    options = @cli.parse_options_for_test(['--file', 'test.html'])
    
    assert_equal 'test.html', options[:file]
  end
  
  def test_format_option
    options = @cli.parse_options_for_test(['--format', 'pdf'])
    
    assert_equal 'pdf', options[:format]
  end
  
  def test_output_option
    options = @cli.parse_options_for_test(['--output', '/tmp/exports'])
    
    assert_equal '/tmp/exports', options[:output_dir]
  end
  
  def test_debug_option
    options = @cli.parse_options_for_test(['--debug'])
    
    assert_equal true, options[:debug]
  end
  
  def test_build_config_default
    config = @cli.build_config
    
    assert_equal true, config['enabled']
    assert_equal false, config['debug']
    assert_equal true, config['unicode_cleanup']
    refute config.key?('output_dir')
  end
  
  def test_build_config_with_options
    @cli.parse_options_for_test(['--debug', '--output', '/tmp'])
    config = @cli.build_config
    
    assert_equal true, config['debug']
    assert_equal '/tmp', config['output_dir']
  end
end