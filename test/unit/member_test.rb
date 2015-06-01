require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	test "authenticate" do
		member = Factory(:member, name: "taro", password: "happy", password_confirmation: "happy")
		assert_nil Member.authenticate("taro", "lucky")
		assert_equal member, Member.authenticate("taro", "happy")
end
