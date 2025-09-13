require "test_helper"

class MasterCvControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get master_cv_index_url
    assert_response :success
  end

  test "should get show" do
    get master_cv_show_url
    assert_response :success
  end

  test "should get new" do
    get master_cv_new_url
    assert_response :success
  end

  test "should get edit" do
    get master_cv_edit_url
    assert_response :success
  end

  test "should get create" do
    get master_cv_create_url
    assert_response :success
  end

  test "should get update" do
    get master_cv_update_url
    assert_response :success
  end

  test "should get destroy" do
    get master_cv_destroy_url
    assert_response :success
  end
end
