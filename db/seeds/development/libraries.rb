# coding: utf-8

names = %w(図書館A 図書館B)
urls = %w(http://www.lib_aaaaaaa.com http://www.lib_bbbbbbb.com)

0.upto(1) do |idx|
  Library.create({ name: names[idx], url: urls[idx] },without_protection: true)
end
