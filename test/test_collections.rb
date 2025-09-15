require_relative 'test_helper'

class TestCollections < Minitest::Test
  def test_process_collections_pages
    site = mock_site_with_collections
    config = { 'collections' => ['pages'] }
    
    Jekyll::PandocExports.stub :process_item, nil do
      Jekyll::PandocExports.process_collections(site, config)
    end
    
    site.verify
  end
  
  def test_process_collections_posts
    site = mock_site_with_posts
    config = { 'collections' => ['posts'] }
    
    Jekyll::PandocExports.stub :process_item, nil do
      Jekyll::PandocExports.process_collections(site, config)
    end
    
    site.verify
  end
  
  def test_process_collections_custom
    site = mock_site_with_custom_collection
    config = { 'collections' => ['portfolio'] }
    
    Jekyll::PandocExports.stub :process_item, nil do
      Jekyll::PandocExports.process_collections(site, config)
    end
    
    site.verify
  end
  
  def test_process_item_skips_without_exports
    site = mock_site
    item = mock_item_without_exports
    config = {}
    
    # Should return early without processing
    Jekyll::PandocExports.process_item(site, item, config)
  end
  
  def test_process_item_processes_with_exports
    site = mock_site
    item = mock_item_with_exports
    config = { 'incremental' => false }
    
    Jekyll::PandocExports.stub :process_page, nil do
      Jekyll::PandocExports.process_item(site, item, config)
    end
  end
  
  private
  
  def mock_site
    site = Minitest::Mock.new
    site.expect :dest, '/tmp/site'
    site
  end
  
  def mock_site_with_collections
    site = Minitest::Mock.new
    pages = [mock_item_with_exports]
    site.expect :pages, pages
    site
  end
  
  def mock_site_with_posts
    site = Minitest::Mock.new
    posts = Minitest::Mock.new
    docs = [mock_item_with_exports]
    posts.expect :docs, docs
    site.expect :posts, posts
    site
  end
  
  def mock_site_with_custom_collection
    site = Minitest::Mock.new
    collection = Minitest::Mock.new
    docs = [mock_item_with_exports]
    collection.expect :docs, docs
    collections = { 'portfolio' => collection }
    site.expect :collections, collections
    site
  end
  
  def mock_item_without_exports
    item = Object.new
    def item.data
      {}
    end
    item
  end
  
  def mock_item_with_exports
    item = Object.new
    def item.data
      { 'docx' => true, 'pdf' => true }
    end
    item
  end
end