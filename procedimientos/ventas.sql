
------------------------------------------------
--------- OK
------------------------------------------------
CREATE OR REPLACE FUNCTION sh_puntoventa.pr_registrar_venta
(
   _usuario_id INTEGER
)
RETURNS SETOF sh_puntoventa.ventas
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_puntoventa.ventas(
                total,
                subtotal,
                iva,
                usuario_id,
                estado_id
            ) VALUES(
                0,
                0,
                0,
                _usuario_id,
                1
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la venta';
        END IF;       
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_registrar_venta OWNER TO admin_arbolesmiel;

-- select venta_id from sh_puntoventa.pr_registrar_venta(1);


------------------------------------------------
--------- OK
------------------------------------------------
CREATE OR REPLACE FUNCTION sh_puntoventa.pr_registrar_detalle_venta
(
    _producto_id        INTEGER,
    _venta_id           INTEGER,
    _cantidad           INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
BEGIN
        INSERT INTO sh_puntoventa.detalle_venta(
                producto_id,
                venta_id,
                cantidad
            ) VALUES(
                _producto_id,
                _venta_id,
                _cantidad
            ); 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la venta';
        END IF;       
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_registrar_detalle_venta OWNER TO admin_arbolesmiel;

-- select sh_puntoventa.pr_registrar_detalle_venta(1,1,4);

-- select pr_registrar_detalle_venta(1,2,1);
 
------------------------------------------------
--------- OK
------------------------------------------------
CREATE OR REPLACE FUNCTION sh_puntoventa.fn_editar_venta
(   
   _venta_id    INTEGER,
   _estado_id   INTEGER
)
RETURNS SETOF sh_puntoventa.ventas
LANGUAGE PLPGSQL
AS
$$  
BEGIN
        RETURN query 
            UPDATE sh_puntoventa.ventas SET
                 estado_id = _estado_id
	        WHERE venta_id = _venta_id RETURNING *;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en la edicion de la venta';
        END IF; 
END;
$$;
ALTER FUNCTION sh_puntoventa.fn_editar_venta OWNER TO admin_arbolesmiel;

-- select * from fn_editar_venta(1,2);

------------------------------------------------
--------- OK
------------------------------------------------
CREATE OR REPLACE FUNCTION sh_puntoventa.pr_eliminar_venta
(
 _venta_id           INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
   _total integer;
BEGIN

        SELECT v.total into _total FROM sh_puntoventa.ventas v WHERE v.venta_id = _venta_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'No existe el registro de esa venta';
        ELSE
            IF _total = 0 THEN
                DELETE FROM sh_puntoventa.ventas
	            WHERE venta_id = _venta_id;
            ELSE
                -- RAISE EXCEPTION 'Esta venta no se puede eliminar';

                DELETE FROM sh_puntoventa.detalle_venta
                WHERE venta_id = _venta_id;

                DELETE FROM sh_puntoventa.ventas
	            WHERE venta_id = _venta_id;
            END IF;
        END IF;      
  
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_eliminar_venta OWNER TO admin_arbolesmiel;




