require "test_helper"

class ItemTaggingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get item_taggings_index_url
    assert_response :success
  end

  test "should get update" do
    get item_taggings_update_url
    assert_response :success
  end
end
