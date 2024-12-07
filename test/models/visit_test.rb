require "test_helper"

# This class tests the validation and association requirements for Visit records
class VisitTest < ActiveSupport::TestCase
  setup do
    @visit = visits(:one)  # This loads the entire fixture with all its values
  end

  # Test that a visit with all required attributes is valid
  test "should be valid with all required attributes" do 
    assert @visit.valid?
  end

  # Test the belongs_to association with Link model
  test "should belong to a link" do
    assert @visit.valid?
    assert_equal links(:one), @visit.link
  end

  # Test that ip_address is required
  test "should require an ip_address" do
    @visit.ip_address = nil
    assert_not @visit.valid?
    assert_includes @visit.errors[:ip_address], "cannot be blank"
  end

  # Test that user_agent is required
  test "should require a user_agent" do
    @visit.user_agent = nil
    assert_not @visit.valid?
    assert_includes @visit.errors[:user_agent], "can't be blank"
  end
  
  # Test that geolocation attributes are correctly set
  # Verifies both country and city are present and match expected values
  test "should have valid geolocation attributes" do
    visit = visits(:one)

    assert_not_nil visit.country
    assert_not_nil visit.city
    assert_equal "Malaysia", visit.country
    assert_equal "Kuala Lumpur", visit.city
  end

end
