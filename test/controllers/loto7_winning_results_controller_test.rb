require "test_helper"

class Loto7WinningResultsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get loto7_winning_results_index_url
    assert_response :success
  end

  test "should get show" do
    get loto7_winning_results_show_url
    assert_response :success
  end
end
