class RoutesHelperTest < ActionView::TestCase
  setup do
    @route = create(:route)
  end

  test "route_includes_json_schema should return true if route includes a json_schema" do
    @route.request_body_schema = "{}"
    @route.save
    assert route_includes_json_schema(@route)

    @route.request_body_schema = nil
    @route.save
    create(:response, route: @route, body_schema: "{}")
    assert route_includes_json_schema(@route)
  end

  test "route_includes_json_schema should return false if route does not include a json_schema" do
    assert_equal false, route_includes_json_schema(@route)
  end
end