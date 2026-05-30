select *from newcustomers
union
select *from oldcustomers;

select *from newcustomers
intersect
select *from oldcustomers;

select city, count(id) from (
    select *from newcustomers
    union
    select *from oldcustomers
) group by city;

select city, count(id) from (
    select *from newcustomers
    union
    select *from oldcustomers
) group by city having count(id) = (
    select count(id) from (
        select *from newcustomers
        union
        select *from oldcustomers
        )group by city
    order by count(id) desc limit 1
);


