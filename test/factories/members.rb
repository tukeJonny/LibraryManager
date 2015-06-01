FactoryGirl.define do
	factory :member do
		sequence(:user_id) { |n| n+1}
		sequence(:name)    { |n| "Taro#{n}"}    sequence(:email)   { |n| "taro#{n}@example.com" }
		password "password"
		password_confirmation "password"
	end
end
