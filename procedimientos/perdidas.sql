


CREATE OR REPLACE FUNCTION sh_puntoventa.pr_registrar_perdida
(
   _usuario_id INTEGER
)
RETURNS SETOF sh_puntoventa.perdidas
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_puntoventa.perdidas(
                total,
                usuario_id,
                estado_id
            ) VALUES(
                0,
                _usuario_id,
                1
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la perdida';
        END IF;       
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_registrar_perdida OWNER TO admin_arbolesmiel;

-- select perdida_id from sh_puntoventa.fn_registrar_perdida(1);


CREATE OR REPLACE FUNCTION sh_puntoventa.pr_registrar_detalle_perdida
(
    _producto_id        INTEGER,
    _perida_id          INTEGER,
    _cantidad           INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
BEGIN
        INSERT INTO sh_puntoventa.detalle_perdida(
                producto_id,
                perdida_id,
                cantidad
            ) VALUES(
                _producto_id,
                _perida_id,
                _cantidad
            ); 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del detalle dela perdida';
        END IF;       
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_registrar_detalle_perdida OWNER TO admin_arbolesmiel;

-- select pr_registrar_detalle_perdida(2,1,2);




CREATE OR REPLACE FUNCTION sh_puntoventa.pr_eliminar_perdida
(
    _perdida_id   INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
    _total integer;
BEGIN
        SELECT p.total into _total FROM sh_puntoventa.perdidas p WHERE perdida_id = _perdida_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'No existe el registro de esa perdida';
        ELSE
            IF _total = 0 THEN
                DELETE FROM sh_puntoventa.perdidas
	            WHERE perdida_id = _perdida_id;
            ELSE
                DELETE FROM sh_puntoventa.detalle_perdida
                WHERE perdida_id = _perdida_id;

                DELETE FROM sh_puntoventa.perdidas
	            WHERE perdida_id = _perdida_id;

            END IF;
        END IF;        
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_eliminar_perdida OWNER TO admin_arbolesmiel;


CREATE OR REPLACE FUNCTION sh_puntoventa.pr_editar_perdida
(   
   _perdida_id    INTEGER,
   _estado_id   INTEGER
)
RETURNS SETOF sh_puntoventa.ventas
LANGUAGE PLPGSQL
AS
$$  
BEGIN
        RETURN query 
            UPDATE sh_puntoventa.perdidas SET
                 estado_id = _estado_id
	        WHERE perdida_id = _perdida_id RETURNING *;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en la edicion de la perdida';
        END IF; 
END;
$$;
ALTER FUNCTION sh_puntoventa.pr_editar_perdida OWNER TO admin_arbolesmiel;

-- select * from fn_editar_perdida(1,2);
