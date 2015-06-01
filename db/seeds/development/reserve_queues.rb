# coding: utf-8

4.upto(6) do |idx|
  ReserveQueue.create({ reservation_id: idx,
    member_id: idx+3,
    library_id: 1,
    book_id: 1 },without_protection: true
  )
end

ReserveQueue.create({ reservation_id: 11,
  member_id: 14,
  library_id: 2,
  book_id: 3 },without_protection: true
)
