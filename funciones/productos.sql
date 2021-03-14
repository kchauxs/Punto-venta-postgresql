
CREATE OR REPLACE FUNCTION sh_productos.fn_consultar_productos_administracion()
RETURNS 
    TABLE(
        id               SMALLINT,
        nombre           VARCHAR,
        descripcion      VARCHAR,
        precio           INTEGER,
        costo            INTEGER,
        existencia       SMALLINT,
        fecha            DATE,
        categoria        VARCHAR,
        estado           VARCHAR,
        usuairo          VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY SELECT 
                    p.producto_id id,
                    p.producto_nombre nombre,
                    p.producto_descripcion descripcion,
                    p.precio,
                    p.costo, 
                    p.existencia,
                    p.fecha_creado fecha,
                    cp.categoria_nombre categoria,
                    ce.nombre_estado estado,
                    r.role_nombre usuairo
                FROM sh_productos.productos p
                    INNER JOIN sh_productos.categoria_productos cp ON cp.categoria_id = p.categoria_id
                    INNER JOIN public.catalago_estados ce on ce.estado_id = p.estado_id
                    INNER JOIN sh_roles.usuarios u on u.usuario_id = p.usuario_id
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                ORDER BY p.producto_nombre ASC;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No se econtraron registros, Tabla Vacia.';
        END IF;                         
END;
$$;

ALTER FUNCTION sh_productos.fn_consultar_productos_administracion OWNER TO admin_arbolesmiel;


-- select * from fn_consultar_productos_administracion();

CREATE OR REPLACE FUNCTION sh_productos.fn_consultar_productos_venta()
RETURNS 
    TABLE(
        id               INTEGER,
        nombre           VARCHAR,
        descripcion      VARCHAR,
        precio           INTEGER,
        costo            INTEGER,
        existencia       INTEGER,
        categoria        VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY SELECT 
                    p.producto_id::INTEGER id,
                    p.producto_nombre nombre,
                    p.producto_descripcion descripcion,
                    p.precio,
                    p.costo, 
                    p.existencia::INTEGER,
                    cp.categoria_nombre categoria
                FROM sh_productos.productos p
                    INNER JOIN sh_productos.categoria_productos cp ON cp.categoria_id = p.categoria_id
                    INNER JOIN public.catalago_estados ce on ce.estado_id = p.estado_id
                WHERE ce.nombre_estado = 'activo'
                ORDER BY p.producto_id ASC;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'No se econtraron registros, Tabla Vacia.';
        END IF;                         
END;
$$;

ALTER FUNCTION sh_productos.fn_consultar_productos_venta OWNER TO admin_arbolesmiel;

-- DROP FUNCTION fn_consultar_productos_venta();
select * from sh_productos.fn_consultar_productos_venta();
-- select producto_id from fn_consultar_productos_venta();

--  _producto_id INTEGER,
--     _producto_nombre VARCHAR,
--     _producto_descripcion VARCHAR,
--     _categoria_id INTEGER,
--     _estado_id INTEGER
CREATE OR REPLACE FUNCTION sh_productos.fn_consultar_producto_especifico(_producto_id INTEGER)
RETURNS 
    TABLE(
        id               SMALLINT,
        nombre           VARCHAR,
        descripcion      VARCHAR,
        categoria        VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY SELECT 
                    p.producto_id id,
                    p.producto_nombre nombre,
                    p.producto_descripcion descripcion,
                    cp.categoria_nombre categoria
                FROM sh_productos.productos p
                    INNER JOIN sh_productos.categoria_productos cp ON cp.categoria_id = p.categoria_id
                WHERE p.producto_id = _producto_id;
             
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No se econtraron registros, Producto Inexistente.';
        END IF;                         
END;
$$;


ALTER FUNCTION sh_productos.fn_consultar_producto_especifico OWNER TO admin_arbolesmiel;
-- DROP FUNCTION fn_consultar_producto_especifico(_producto_id INTEGER);
-- select * from sh_productos.fn_consultar_producto_especifico(1);


CREATE OR REPLACE FUNCTION sh_productos.fn_consultar_categoira_productos()
RETURNS
TABLE(
        id               INTEGER,
        nombre           VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE
BEGIN
    RETURN QUERY SELECT 
                   c.categoria_id id,
                   c.categoria_nombre nombre
                FROM sh_productos.categoria_productos c
                WHERE c.estado_id = 1 ORDER BY c.categoria_id;  

                IF NOT FOUND THEN
                    RAISE EXCEPTION 'No se econtraron registros.';
                END IF;       
END;
$$;

