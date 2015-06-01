class Library < ActiveRecord::Base
	attr_accessible :name, :url
	has_many :books
	has_many :members
	has_many :notices
	has_many :reservations
	has_many :reserve_queues
	has_many :available_queues
	has_many :lend_queues
end
