class CreateReservations < ActiveRecord::Migration
	def change
		create_table :reservations do |t|
			t.references :book
			t.references :member
			t.date :lend_date, default: nil
			t.date :return_date, default: nil
			t.references :library

			t.timestamps
		end
	end
end
