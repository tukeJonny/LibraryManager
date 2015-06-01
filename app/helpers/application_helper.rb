# coding: utf-8
require "active_support/core_ext"
module ApplicationHelper
	def isbn10_to_13(isbn10)
		isbn13 = "978#{isbn10.to_s[0..8]}"
		#チェックディジット計算用
		check_digit = 0
		arr = isbn13.split(//)
		arr.each_with_index do |chr, idx|
			#Integer#even?はActiveSupportによる拡張
			check_digit += chr.to_i * (idx % 2 == 0 ? 1 : 3)
		end
		#総和を10で割ったものを10から引き、10の場合は0にする
		check_digit = (10 - (check_digit % 10)) % 10
		return "#{isbn13}#{check_digit}".to_i
	end

	def isbn13_to_10(isbn13)
		isbn10 = isbn13.to_s[3..11]
		check_digit = 0
		arr = isbn10.split(//)
		arr.each_with_index do |chr, idx|
			check_digit += chr.to_i * (10 - idx)
		end
		check_digit = 11 - (check_digit % 11)
		#計算結果が10になった場合、10の代わりにX(アルファベット大文字)
		#また、11になった場合は、0となる。
		case check_digit
		when 10
			check_digit = "X"
		when 11
			check_digit = 0
		end
		return "#{isbn10}#{check_digit}".to_i
	end

	def store_location
		session[:return_to] = request.fullpath
		p ":return_to#{request.fullpath}"
	end
end
