require "test_helper"

class HelloControllerTest < ActionDispatch::IntegrationTest
  test "should get html_slice" do
    get hello_html_slice_url
    assert_response :success
  end

  test "should get erb" do
    get hello_erb_url
    assert_response :success
  end
end
