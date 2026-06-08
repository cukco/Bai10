create or replace procedure add_order_and_update_customer(
    p_customer_id INT,
    p_amount NUMERIC
) language plpgsql
as $$
    declare
        check_exist int;
    begin
        select customer_id into check_exist from customers
        where p_customer_id=customer_id;

        if check_exist is null then
            raise exception 'Lỗi không tồn tại khách hàng';
        end if;

        insert into orders (customer_id, total_amount) values
        (p_customer_id,p_amount);

        update customers
        set total_spent=total_spent+p_amount
        where customer_id=p_customer_id;

    exception
        when others then
            raise notice 'Xảy ra lỗi: %',SQLERRM;
        rollback;
    end;
$$;

call add_order_and_update_customer(1,50);
