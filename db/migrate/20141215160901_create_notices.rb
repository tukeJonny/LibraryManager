class CreateNotices < ActiveRecord::Migration
	def change
		create_table :notices do |t|
			t.string :title #タイトル
			t.string :body #本文
			t.date :released_at, null: false #掲載日
			t.references :library #発信者（0はシステム、それ以外は図書館のIDに対応）
			t.timestamps
		end
	end
end
