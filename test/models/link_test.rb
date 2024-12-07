require "test_helper"

# Tests validation and association behavior of Link model
class LinkTest < ActiveSupport::TestCase
  setup do
    @link = links(:one)
  end

  # Verifies that a link with valid attributes passes validation
  test "should be valid with valid attributes" do
    assert @link.valid?
  end

  # Ensures target_url is required and cannot be nil
  test "should require target_url" do
    @link.target_url = nil
    assert_not @link.valid?
    assert_includes @link.errors[:target_url], "can't be blank"
  end

  # Tests URL format validation
  # - Rejects invalid formats like plain text and FTP URLs
  # - Accepts valid HTTP URLs
  test "should validate target_url format" do
    invalid_urls = ["not-a-url", "ftp://invalid.com", "just-text"]
    invalid_urls.each do |url|
      @link.target_url = url
      assert_not @link.valid?, "#{url} should not be valid"
    end

    valid_urls = ["https://example.com", "http://test.com/path?param=1"]
    valid_urls.each do |url|
      @link.target_url = url
      assert @link.valid?, "#{url} should be valid"
    end
  end

  # Verifies that short_path must be unique across all links
  test "should have unique short_path" do
    @link.save!

    # Create a new link with the same short_path but different target URL
    duplicate_link = Link.new(
      target_url: "https://different-example.com",
      short_path: @link.short_path
    )

    # Verify the duplicate link is invalid
    assert_not duplicate_link.valid?
    assert_includes duplicate_link.errors[:short_path], "has already been taken"
  end

  # Confirms has_many association with visits is properly set up
  test "should have many visits" do
    # Verify that the link model responds to the visits association method
    assert_respond_to @link, :visits
    # Ensure visits returns the correct type of collection
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @link.visits
  end
end
