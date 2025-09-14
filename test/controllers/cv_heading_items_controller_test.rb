require "test_helper"

class CvHeadingItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get cv_heading_items_new_url
    assert_response :success
  end

  test "should get create" do
    get cv_heading_items_create_url
    assert_response :success
  end

  test "should get edit" do
    get cv_heading_items_edit_url
    assert_response :success
  end

  test "should get update" do
    get cv_heading_items_update_url
    assert_response :success
  end

  test "should get destroy" do
    get cv_heading_items_destroy_url
    assert_response :success
  end
end
