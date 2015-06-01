# coding: utf-8

# 1.すべての本が借りられていて、その本に複数の順番待ちがある(id:1~6)
4.upto(6) do |idx|
  Reservation.create({ book_id: 1,
    member_id: idx,
    lend_date: Date.today,
    library_id: 1 },without_protection: true
  )
end
7.upto(9) do |idx|
  Reservation.create({ book_id: 1,
    member_id: idx,
    library_id: 1 },without_protection: true
  )
end

# 2.借りられているが、まだ空きがあるとき(7,8)
10.upto(11) do |idx|
  Reservation.create({ book_id: 2,
    member_id: idx,
    lend_date: Date.today,
    library_id: 2 },without_protection: true
  )
end

# 3.貸出あり、受け取り可あり、順番待ち（受け取り可になってない）あり(9~11)
Reservation.create({ book_id: 3,
  member_id: 12,
  lend_date: Date.today,
  library_id: 1 },without_protection: true
)
Reservation.create({ book_id: 3,
  member_id: 13,
  library_id: 1 },without_protection: true
)
Reservation.create({ book_id: 3,
  member_id: 14,
  library_id: 2 },without_protection: true
)



