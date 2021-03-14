
CREATE OR REPLACE FUNCTION sh_puntoventa.fn_consultar_ventas()
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
                    v.venta_id id,
                    v.total,
                    v.fecha,
                    r.role_nombre usuario,
                    es.nombre_estado estado
                FROM sh_puntoventa.ventas v
                    INNER JOIN sh_roles.usuarios u on u.usuario_id = v.usuario_id
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                    INNER JOIN public.catalago_estados es on es.estado_id = v.estado_id
                    WHERE es.nombre_estado = 'activo'
                    ORDER BY v.venta_id ASC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tabla vacia';
        END IF;          
END;
$$;
ALTER FUNCTION sh_puntoventa.fn_consultar_ventas OWNER TO admin_arbolesmiel;

--select * from fn_consultar_ventas();



------------------------------------------------
--------- OK
------------------------------------------------
CREATE OR REPLACE FUNCTION sh_puntoventa.fn_consultar_factura_venta_especifica(_venta_id integer)
RETURNS 
    TABLE(
        id          INTEGER,
        total       INTEGER,
        subtotal    INTEGER,
        iva         INTEGER,
        fecha       DATE,
        vendedor    TEXT, 
        estado      VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    v.venta_id id,
                    v.total,
                    v.subtotal,
                    v.iva,
                    v.fecha,
                    p.primer_nombre || ' ' || p.primer_apellido as vendedor,
                    es.nombre_estado estado
                FROM sh_puntoventa.ventas v
                    INNER JOIN sh_roles.usuarios u on u.usuario_id = v.usuario_id
                    INNER JOIN sh_personas.personas p on p.persona_id = u.persona_id
                    INNER JOIN public.catalago_estados es on es.estado_id = v.estado_id
                    WHERE v.venta_id = _venta_id;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tabla vacia';
        END IF;          
END;
$$;


------------------------------------------------
--------- OK
------------------------------------------------
CREATE OR REPLACE FUNCTION sh_puntoventa.fn_consultar_detalle_factura(_venta_id integer)
RETURNS 
    TABLE(
        producto        VARCHAR,
        cantidad        INTEGER,
        precio_unitario INTEGER,
        coste_unitario  INTEGER,
        iva             INTEGER
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                   p.producto_nombre producto,
                   dv.cantidad,
                   dv.precio_unitario,
                   dv.coste_unitario,
                   dv.iva
                FROM sh_puntoventa.detalle_venta dv
                    INNER JOIN sh_productos.productos p on p.producto_id = dv.producto_id
                    WHERE dv.venta_id = _venta_id
                    ORDER BY dv.venta_id DESC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tabla vacia';
        END IF;          
END;
$$;








