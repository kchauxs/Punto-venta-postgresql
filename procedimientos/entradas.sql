CREATE OR REPLACE FUNCTION  sh_puntoventa.pr_registrar_entrada
(
   _persona_id INTEGER,
   _usuario_id INTEGER
)
RETURNS SETOF sh_puntoventa.entradas
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_puntoventa.entradas(
                total,
                persona_id,
                usuario_id,
                estado_id
            ) VALUES(
                0,
                _persona_id,
                _usuario_id,
                1
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la entrada';
        END IF;       
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_registrar_entrada OWNER TO admin_arbolesmiel;

-- select entrada_id from fn_registrar_entrada(5,1);


CREATE OR REPLACE FUNCTION sh_puntoventa.pr_registrar_detalle_entrada
(
    _producto_id INTEGER,
    _entrada_id INTEGER,
    _cantidad INTEGER,
    _coste_unitario INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
BEGIN
        INSERT INTO sh_puntoventa.detalle_entrada(
                producto_id,
                entrada_id,
                cantidad,
                coste_unitario
            ) VALUES(
                _producto_id,
                _entrada_id,
                _cantidad,
                _coste_unitario 
            ); 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la entrada';
        END IF;       
END;
$$;

ALTER FUNCTION sh_puntoventa.pr_registrar_detalle_entrada OWNER TO admin_arbolesmiel;

-- select pr_registrar_detalle_entrada(1,1,12,22000);








