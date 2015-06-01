class CreateMembers < ActiveRecord::Migration
	def change
		create_table :members do |t|
			t.integer :user_id #登録用のID（図書カードの番号、重複可）
			t.references :library #所属館
			t.string :name #ユーザ名
			t.string :email #メールアドレス（重複不可、ログイン時に使用）
			t.string :hashed_password #ハッシュ化したパスワード
			t.boolean :admin, default: false #管理者フラグ
			t.timestamps
		end
	end
end 
