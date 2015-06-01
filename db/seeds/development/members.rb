# coding: utf-8

names = %w(Taro Jiro Takeshi Satoshi)
library_num = Library.count;

0.upto(library_num) do |idx|
  Member.create({ user_id: idx,
    name: "admin#{idx}",
    email: "admin#{idx}@example.com",
    password: "password",
    admin: true,
    library_id: idx },without_protection: true
  )
end

0.upto(100) do |idx|
  Member.create({ user_id: idx+100,
  name: names[idx%4],
  email: "#{names[idx%4]}_#{idx}@example.com",
  password: "password",
  library_id: idx % library_num + 1 },without_protection: true
  )
end
