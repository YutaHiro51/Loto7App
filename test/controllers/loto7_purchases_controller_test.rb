require "test_helper"

class Loto7PurchasesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get loto7_purchases_index_url
    assert_response :success
  end

  test "should get create" do
    get loto7_purchases_create_url
    assert_response :success
  end

  test "should get destroy" do
    get loto7_purchases_destroy_url
    assert_response :success
  end
end
