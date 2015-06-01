# coding: utf-8

1.upto(3) do |idx|
  LendQueue.create({ reservation_id: idx,
    member_id: idx+3,
    library_id: 1,
    book_id: 1 },without_protection: true
  )
end

7.upto(8) do |idx|
  LendQueue.create({ reservation_id: idx,
    member_id: idx+3,
    library_id: 2,
    book_id: 2 },without_protection: true
  )
end

LendQueue.create({ reservation_id: 9,
  member_id: 12,
  book_id: 3,
  library_id: 1 },without_protection: true
)
