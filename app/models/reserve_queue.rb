class ReserveQueue < ActiveRecord::Base
	attr_accessible :reservation_id, :member_id, :library_id, :book_id, :authority
	belongs_to :resevation
	belongs_to :member
	belongs_to :library
	belongs_to :book

	validates :reservation_id, uniqueness: true
	#validate :check_book

	private
	def check_book
		if member_id.present? && book_id.present?
			unless ReserveQueue.find_by_member_id_and_book_id(member_id, book_id)
				errors.add(:book_id, :invalid)
			end
		end
	end
end
