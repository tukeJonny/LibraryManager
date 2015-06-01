class CreateLendQueues < ActiveRecord::Migration
	def change
		create_table :lend_queues do |t|
			t.references :reservation, null: false #予約（注文）ID
			t.references :member, null: false #会員ID
			t.references :library, null: false #受け取り館
			t.references :book, null: false #本のID

			t.timestamps
		end
	end
end
