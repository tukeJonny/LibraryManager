class Book < ActiveRecord::Base
	attr_accessible :isbn, :quantity, :library_id, :available

	belongs_to :library

	has_many :reservations
	has_many :reserve_queues
	has_many :available_queues
	has_many :lend_queues

	validates :isbn, :quantity, presence: true
end
