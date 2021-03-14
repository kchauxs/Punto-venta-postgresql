CREATE OR REPLACE FUNCTION sh_puntoventa.fn_consultar_peridas()
RETURNS 
    TABLE(
        id          INTEGER,
        total       INTEGER,
        fecha       DATE,
        usuario     VARCHAR, 
        estado      VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    p.perdida_id id,
                    p.total,
                    p.fecha,
                    r.role_nombre usuario,
                    es.nombre_estado estado
                FROM sh_puntoventa.perdidas p
                    INNER JOIN sh_roles.usuarios u on u.usuario_id = p.usuario_id
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                    INNER JOIN public.catalago_estados es on es.estado_id = p.estado_id
                    ORDER BY p.perdida_id ASC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tabla vacia';
        END IF;          
END;
$$;
-- ALTER FUNCTION sh_puntoventa.fn_consultar_peridas OWNER TO admin_arbolesmiel;

-- SELECT * FROM sh_puntoventa.fn_consultar_peridas();

-- DELETE FROM sh_puntoventa.perdidas
-- 	WHERE perdida_id = 1; 

CREATE OR REPLACE FUNCTION sh_puntoventa.fn_consultar_perdida_especifica(_perdida_id integer)
RETURNS 
    TABLE(
        producto        VARCHAR,
        cantidad        INTEGER,
        coste_unitario  INTEGER
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                   p.producto_nombre producto,
                   dp.cantidad,
                   dp.coste_unitario
                FROM sh_puntoventa.detalle_perdida dp
                    INNER JOIN sh_productos.productos p on p.producto_id = dp.producto_id
                    WHERE dp.perdida_id = _perdida_id
                    ORDER BY dp.perdida_id DESC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tabla vacia';
        END IF;          
END;
$$;