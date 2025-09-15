module Jekyll
  module PandocExports
    class Statistics
      def initialize
        @stats = {
          total_processed: 0,
          successful_conversions: 0,
          failed_conversions: 0,
          formats: { docx: 0, pdf: 0 },
          processing_times: [],
          errors: []
        }
      end
      
      def record_processing_start
        @start_time = Time.now
      end
      
      def record_processing_end
        return unless @start_time
        @stats[:processing_times] << Time.now - @start_time
        @start_time = nil
      end
      
      def record_conversion_success(format)
        @stats[:successful_conversions] += 1
        @stats[:formats][format] += 1
      end
      
      def record_conversion_failure(format, error)
        @stats[:failed_conversions] += 1
        @stats[:errors] << { format: format, error: error.message, time: Time.now }
      end
      
      def record_file_processed
        @stats[:total_processed] += 1
      end
      
      def summary
        avg_time = @stats[:processing_times].empty? ? 0 : @stats[:processing_times].sum / @stats[:processing_times].length
        
        {
          total_files: @stats[:total_processed],
          successful: @stats[:successful_conversions],
          failed: @stats[:failed_conversions],
          success_rate: success_rate,
          formats: @stats[:formats],
          average_processing_time: avg_time.round(3),
          total_errors: @stats[:errors].length
        }
      end
      
      def print_summary(config)
        return unless config['performance_monitoring'] || config['debug']
        
        stats = summary
        Jekyll.logger.info "Pandoc Exports Stats:", "Processed #{stats[:total_files]} files"
        Jekyll.logger.info "Pandoc Exports Stats:", "Success rate: #{(stats[:success_rate] * 100).round(1)}%"
        Jekyll.logger.info "Pandoc Exports Stats:", "Average time: #{stats[:average_processing_time]}s"
        Jekyll.logger.info "Pandoc Exports Stats:", "Formats - DOCX: #{stats[:formats][:docx]}, PDF: #{stats[:formats][:pdf]}"
        
        if stats[:total_errors] > 0 && config['debug']
          Jekyll.logger.warn "Pandoc Exports Stats:", "#{stats[:total_errors]} errors occurred"
        end
      end
      
      private
      
      def success_rate
        total_conversions = @stats[:successful_conversions] + @stats[:failed_conversions]
        return 0 if total_conversions == 0
        @stats[:successful_conversions].to_f / total_conversions
      end
    end
  end
end