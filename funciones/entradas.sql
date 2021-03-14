


CREATE OR REPLACE FUNCTION sh_puntoventa.fn_consultar_entradas()
RETURNS 
    TABLE(
        id          INTEGER,
        total       INTEGER,
        fecha       DATE,
        proveedor   TEXT,
        telefono    VARCHAR,
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
                    e.entrada_id id,
                    e.total,
                    e.fecha,
                    concat(p.primer_nombre,'  ',p.primer_apellido) proveedor,
                    p.telefono,
                    r.role_nombre usuario,
                    es.nombre_estado estado
                FROM sh_puntoventa.entradas e
                    INNER JOIN sh_personas.personas p on p.persona_id = e.persona_id
                    INNER JOIN sh_roles.usuarios u on u.usuario_id = e.usuario_id
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                    INNER JOIN public.catalago_estados es on es.estado_id = e.estado_id
                    ORDER BY e.entrada_id DESC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tabla vacia';
        END IF;          
END;
$$;
ALTER FUNCTION sh_puntoventa.fn_consultar_entradas OWNER TO admin_arbolesmiel;








CREATE OR REPLACE FUNCTION sh_puntoventa.fn_consultar_entrada_especifica(_entrada_id integer)
RETURNS 
    TABLE(
        producto        VARCHAR,
        cantidad        INTEGER,
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
                   de.cantidad,
                   de.coste_unitario,
                   de.iva
                FROM sh_puntoventa.detalle_entrada de
                    INNER JOIN sh_productos.productos p on p.producto_id = de.producto_id
                    WHERE de.entrada_id = _entrada_id
                    ORDER BY de.entrada_id DESC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Tabla vacia';
        END IF;          
END;
$$;