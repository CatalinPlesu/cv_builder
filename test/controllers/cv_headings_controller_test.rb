require "test_helper"

class CvHeadingsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get cv_headings_new_url
    assert_response :success
  end

  test "should get create" do
    get cv_headings_create_url
    assert_response :success
  end

  test "should get edit" do
    get cv_headings_edit_url
    assert_response :success
  end

  test "should get update" do
    get cv_headings_update_url
    assert_response :success
  end

  test "should get destroy" do
    get cv_headings_destroy_url
    assert_response :success
  end
end
