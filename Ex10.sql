DO $$
    DECLARE
        id_tk INT := 1;
        suatchieu VARCHAR := 'SC003';
        soluong INT := 2;

        v_balance NUMERIC(15,2);
        v_trangthai VARCHAR(20);
        v_stock INT;
        v_giave NUMERIC(15,2);
    BEGIN
        SELECT so_du, trang_thai INTO v_balance, v_trangthai
        FROM tai_khoan WHERE id = id_tk FOR UPDATE;

        IF v_balance IS NULL THEN
            RAISE EXCEPTION 'Tài khoản không tồn tại';
        ELSIF v_trangthai != 'ACTIVE' THEN
            RAISE EXCEPTION 'Tài khoản đang bị khóa';
        ELSIF v_balance < 5000 THEN
            RAISE EXCEPTION 'Tài khoản không đủ phí chuyển khoản (5000đ)';
        END IF;

        UPDATE tai_khoan SET so_du = so_du - 5000 WHERE id = id_tk;
        RAISE NOTICE 'Đã trừ phí ngân hàng 5000đ thành công.';

        BEGIN
            SELECT so_luong_con, gia_ve INTO v_stock, v_giave
            FROM ve_phim WHERE suat_chieu_id = suatchieu FOR UPDATE;

            IF v_stock IS NULL THEN
                RAISE EXCEPTION 'Không tồn tại suất chiếu %', suatchieu;
            ELSIF v_stock < soluong THEN
                RAISE EXCEPTION 'Số vé còn lại không đủ';
            ELSIF (v_balance - 5000) < (v_giave * soluong) THEN
                RAISE EXCEPTION 'Số dư không đủ để mua vé';
            END IF;

            UPDATE ve_phim SET so_luong_con = so_luong_con - soluong WHERE suat_chieu_id = suatchieu;
            UPDATE tai_khoan SET so_du = so_du - (v_giave * soluong) WHERE id = id_tk;

            RAISE NOTICE 'Mua vé thành công!';

        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Thông báo: %', SQLERRM;
        END;
    END;
$$;
