class Notice < ActiveRecord::Base
	attr_accessible :title, :body, :released_at, :library_id

	belongs_to :library

	validates :title, :body, :released_at, presence: true
	validates :title, length: { maximum: 200 }

	scope :newInfo,
		->{ now = Date.today
			where("released_at >= ?", now << 1) }
end
