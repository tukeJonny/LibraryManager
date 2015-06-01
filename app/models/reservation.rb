class Reservation < ActiveRecord::Base
	attr_accessible :book_id, :member_id, :lend_date, :return_date, :library_id

	belongs_to :book
	belongs_to :member
	belongs_to :library
	has_one :reserve_queue
	has_one :available_queue
	has_one :lend_queue

end
