require "test_helper"

class LinkTest < ActiveSupport::TestCase
  def setup
    @link = Link.new(
      target_url: "https://example.com/test",
      short_path: "abc123"
    )
  end

  test "should be valid with valid attributes" do
    assert @link.valid?
  end

  test "should require target_url" do
    @link.target_url = nil
    assert_not @link.valid?
    assert_includes @link.errors[:target_url], "can't be blank"
  end

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

  test "should generate short_path before validation if not present" do
    link = Link.new(target_url: "https://example.com")
    assert_nil link.short_path
    assert link.valid?
    assert_not_nil link.short_path
  end

  test "should have unique short_path" do
    @link.save!
    duplicate_link = Link.new(
      target_url: "https://different-example.com",
      short_path: @link.short_path
    )
    assert_not duplicate_link.valid?
    assert_includes duplicate_link.errors[:short_path], "has already been taken"
  end

  test "should have many visits" do
    assert_respond_to @link, :visits
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @link.visits
  end
end
