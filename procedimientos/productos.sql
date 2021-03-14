
CREATE OR REPLACE FUNCTION sh_productos.pr_registrar_producto 
(
    _producto_nombre VARCHAR,
    _producto_descripcion VARCHAR,
    _precio INTEGER, 
    _costo INTEGER,
    _existencia INTEGER,
    _categoria_id INTEGER,
    _usuario_id INTEGER
)
RETURNS SETOF sh_productos.productos
LANGUAGE PLPGSQL
AS
$$
DECLARE
BEGIN 
        RETURN query INSERT INTO sh_productos.productos(
            producto_nombre,
            producto_descripcion,
            precio, 
            costo,
            existencia,
            categoria_id,
            estado_id,
            usuario_id
            ) VALUES(
                _producto_nombre,
                _producto_descripcion,
                _precio, 
                _costo,
                _existencia,
                _categoria_id,
                1,
                _usuario_id 
            ) RETURNING *; 
END;
$$;

ALTER FUNCTION sh_productos.pr_registrar_producto OWNER TO admin_arbolesmiel;

-- select * from sh_productos.pr_registrar_producto('mieles','angelita',0,0,0,'Miel',1);




CREATE OR REPLACE FUNCTION sh_productos.pr_editar_producto_simple 
(
    _producto_id INTEGER,
    _producto_nombre VARCHAR,
    _producto_descripcion VARCHAR,
    _categoria_id INTEGER,
    _estado_id INTEGER
)
RETURNS SETOF sh_productos.productos
LANGUAGE PLPGSQL
AS
$$  
BEGIN
        RETURN query 
            UPDATE sh_productos.productos SET 
                producto_nombre=_producto_nombre,
                producto_descripcion=_producto_descripcion,
                categoria_id=_categoria_id, 
                estado_id=_estado_id   
            WHERE producto_id = _producto_id RETURNING *;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en la edicion del producto';
        END IF; 
END;
$$;
ALTER FUNCTION sh_productos.pr_editar_producto_simple OWNER TO admin_arbolesmiel;
