class CreateLibraries < ActiveRecord::Migration
	def change
		create_table :libraries do |t|
			t.string :name, null: false #図書館名
			t.string :url, null: false #図書館のURL（とくに使う予定なし）
			t.timestamps
		end
	end
end
