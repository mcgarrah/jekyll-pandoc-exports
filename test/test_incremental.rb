require_relative 'test_helper'

class TestIncremental < Minitest::Test
  def test_skip_unchanged_file_incremental_disabled
    config = { 'incremental' => false }
    item = mock_item('/test.md')
    site = mock_site
    
    refute Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
  end
  
  def test_skip_unchanged_file_source_missing
    config = { 'incremental' => true }
    item = mock_item('/nonexistent.md')
    site = mock_site
    
    File.stub :exist?, false do
      refute Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
    end
  end
  
  def test_skip_unchanged_file_output_missing
    config = { 'incremental' => true, 'output_dir' => '' }
    item = mock_item_with_exports('/test.md')
    site = mock_site
    
    File.stub :exist?, ->(path) { path.end_with?('test.md') } do
      File.stub :mtime, Time.now do
        refute Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
      end
    end
  end
  
  def test_skip_unchanged_file_output_newer
    config = { 'incremental' => true, 'output_dir' => '' }
    item = mock_item_with_exports('/test.md')
    site = mock_site
    
    source_time = Time.now - 3600  # 1 hour ago
    output_time = Time.now         # now
    
    File.stub :exist?, true do
      File.stub :mtime, ->(path) { path.end_with?('.md') ? source_time : output_time } do
        assert Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
      end
    end
  end
  
  def test_skip_unchanged_file_source_newer
    config = { 'incremental' => true, 'output_dir' => '' }
    item = mock_item_with_exports('/test.md')
    site = mock_site
    
    source_time = Time.now         # now
    output_time = Time.now - 3600  # 1 hour ago
    
    File.stub :exist?, true do
      File.stub :mtime, ->(path) { path.end_with?('.md') ? source_time : output_time } do
        refute Jekyll::PandocExports.skip_unchanged_file?(site, item, config)
      end
    end
  end
  
  private
  
  def mock_site
    site = Minitest::Mock.new
    site.expect :dest, '/tmp/site'
    site
  end
  
  def mock_item(path)
    item = Minitest::Mock.new
    item.expect :respond_to?, true, [:path]
    item.expect :path, path
    item
  end
  
  def mock_item_with_exports(path)
    item = mock_item(path)
    data = { 'docx' => true, 'pdf' => true }
    item.expect :data, data
    item.expect :data, data
    item
  end
end