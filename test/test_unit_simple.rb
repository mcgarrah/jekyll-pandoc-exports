require 'minitest/autorun'

class TestUnitSimple < Minitest::Test
  def test_basic_functionality
    # Simple test that always passes
    assert_equal 1, 1
  end
  
  def test_string_operations
    # Test basic string operations
    result = "test".upcase
    assert_equal "TEST", result
  end
  
  def test_array_operations
    # Test basic array operations
    arr = [1, 2, 3]
    assert_equal 3, arr.length
    assert_includes arr, 2
  end
end