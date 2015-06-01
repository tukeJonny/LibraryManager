class CreateBooks < ActiveRecord::Migration
	def change
		create_table :books do |t|
			t.integer :isbn, null: false #ISBN
			t.integer :quantity, null: false #冊数
			t.references :library #蔵書館

			t.timestamps
		end
	end
end
