select sum(bookings.total_amount) as total,tickets.passenger_name
from bookings
left join tickets
on bookings.book_ref = tickets.book_ref
group by tickets.passenger_name
order by total desc;


select ticket_flights.fare_conditions,count(*)
from bookings
left join tickets
on bookings.book_ref = tickets.book_ref
left join ticket_flights
on tickets.ticket_no = ticket_flights.ticket_no
where tickets.passenger_name = 'ALEKSANDR IVANOV'
group by ticket_flights.fare_conditions
;

