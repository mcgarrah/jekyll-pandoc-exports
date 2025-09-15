require 'minitest/autorun'
require_relative '../lib/jekyll-pandoc-exports/statistics'

class TestStatistics < Minitest::Test
  def setup
    @stats = Jekyll::PandocExports::Statistics.new
  end
  
  def test_initial_stats
    summary = @stats.summary
    assert_equal 0, summary[:total_files]
    assert_equal 0, summary[:successful]
    assert_equal 0, summary[:failed]
    assert_equal 0, summary[:success_rate]
  end
  
  def test_record_file_processed
    @stats.record_file_processed
    @stats.record_file_processed
    
    summary = @stats.summary
    assert_equal 2, summary[:total_files]
  end
  
  def test_record_conversion_success
    @stats.record_conversion_success(:docx)
    @stats.record_conversion_success(:pdf)
    
    summary = @stats.summary
    assert_equal 2, summary[:successful]
    assert_equal 1, summary[:formats][:docx]
    assert_equal 1, summary[:formats][:pdf]
  end
  
  def test_record_conversion_failure
    error = StandardError.new('Test error')
    @stats.record_conversion_failure(:pdf, error)
    
    summary = @stats.summary
    assert_equal 1, summary[:failed]
    assert_equal 1, summary[:total_errors]
  end
  
  def test_success_rate_calculation
    @stats.record_conversion_success(:docx)
    @stats.record_conversion_success(:pdf)
    @stats.record_conversion_failure(:docx, StandardError.new('Error'))
    
    summary = @stats.summary
    expected_rate = 2.0 / 3.0  # 2 successes out of 3 total
    assert_equal expected_rate.round(2), summary[:success_rate].round(2)
  end
  
  def test_processing_time_tracking
    @stats.record_processing_start
    sleep(0.01)  # Small delay for timing
    @stats.record_processing_end
    
    summary = @stats.summary
    assert summary[:average_processing_time] > 0
  end
  
  def test_processing_time_without_start
    @stats.record_processing_end
    
    summary = @stats.summary
    assert_equal 0, summary[:average_processing_time]
  end
end