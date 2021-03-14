--------------------------------------------------
--              USUAROP POSTGRES
--------------------------------------------------


-- CREACION DEL USUARIO

CREATE USER admin_arbolesmiel PASSWORD 'passarbolesmiel';


-- CREACION DEL TABLESPACE
CREATE TABLESPACE ts_arbolesmiel
    OWNER admin_arbolesmiel
    LOCATION 'D:\ARBOLES_MIEL';


-- CREACION DE LA BASE DE DATOS
CREATE DATABASE arbolesmiel
    OWNER = admin_arbolesmiel
    TABLESPACE = ts_arbolesmiel;


-- Crear roles de inicio de sesión
CREATE ROLE servidor 
LOGIN 
PASSWORD 'passserver';

CREATE ROLE desarrollador 
LOGIN 
PASSWORD 'passdesarrollador';


-- asignando privilegios
GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_auditoria"
TO servidor;

GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_asesoria"
TO servidor;

GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_personas"
TO servidor;

GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_productos"
TO servidor;

GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_puntoventa"
TO servidor;

GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_roles"
TO servidor;

GRANT ALL
ON ALL TABLES
IN SCHEMA "public"
TO servidor;


GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_asesoria"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_personas"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_productos"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_puntoventa"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_asesoria"
TO desarrollador;

GRANT SELECT
ON ALL TABLES
IN SCHEMA "public"
TO desarrollador;

GRANT SELECT
ON ALL TABLES
IN SCHEMA "sh_auditoria"
TO desarrollador;


--------------------------------------------------
--              USUAROP admin_arbolesmiel
--------------------------------------------------

\q

psql -U admin_arbolesmiel -d arbolesmiel



CREATE TABLE IF NOT EXISTS public.catalago_estados(
    estado_id               SMALLSERIAL PRIMARY KEY,
    nombre_estado           VARCHAR(30)
); 

--------------------------------------------------
--              SCHEMA - PERSONAS
--------------------------------------------------
CREATE SCHEMA IF NOT EXISTS sh_personas;


--------------------------------------------------
--              TABLAS
--------------------------------------------------
CREATE TABLE IF NOT EXISTS sh_personas.localidades (
    localidad_id            SMALLSERIAL PRIMARY KEY,
    localidad_nombre        VARCHAR (60) UNIQUE NOT NULL,
    localidad_departamento  VARCHAR (30)  NOT NULL
);


CREATE TABLE IF NOT EXISTS sh_personas.personas (
    persona_id              SERIAL NOT NULL,
    documento               VARCHAR(15) UNIQUE NOT NULL,
    primer_nombre           VARCHAR(60) NOT NULL,
    segundo_nombre          VARCHAR(60),
    primer_apellido         VARCHAR(60) NOT NULL,
    segundo_apellido        VARCHAR(60),
    email                   VARCHAR(90) NOT NULL,
    telefono                VARCHAR (13) NOT NULL,
    fecha_creado            DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (persona_id)
);


CREATE TABLE IF NOT EXISTS sh_personas.direcciones (
    domicilio_id            SERIAL PRIMARY KEY,
    direccion               VARCHAR(255) NOT NULL,    
    barrio                  VARCHAR NOT NULL,
    localidad_id            INTEGER NOT NULL,
    FOREIGN KEY (localidad_id) REFERENCES sh_personas.localidades (localidad_id)
);



CREATE TABLE IF NOT EXISTS sh_personas.detalle_direccion(
    domicilio_id            INTEGER NOT NULL, 
    persona_id              INTEGER NOT NULL,
    fecha                   DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY(domicilio_id,persona_id),
    FOREIGN KEY (domicilio_id) REFERENCES sh_personas.direcciones (domicilio_id),   
    FOREIGN KEY (persona_id) REFERENCES sh_personas.personas (persona_id)  
);




--------------------------------------------------
--              SCHEMA - ROLES
--------------------------------------------------
CREATE SCHEMA IF NOT EXISTS sh_roles;
--------------------------------------------------
--              TABLAS
--------------------------------------------------

CREATE TABLE IF NOT EXISTS sh_roles.roles(
    role_id                 SMALLSERIAL PRIMARY KEY,
    role_nombre                  VARCHAR (30) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS sh_roles.modulos(
    modulo_id               SMALLSERIAL PRIMARY KEY,
    modulo_nombre           VARCHAR (40) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS sh_roles.acciones(
    accion_id               SMALLSERIAL PRIMARY KEY,
    accion_nombre           VARCHAR (40) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS sh_roles.operaciones(
    operacion_id            SMALLSERIAL PRIMARY KEY,
    fecha_creado            DATE NOT NULL DEFAULT CURRENT_DATE,
    accion_id               SMALLINT NOT NULL,
    modulo_id               SMALLINT NOT NULL,
    FOREIGN KEY (accion_id) REFERENCES sh_roles.acciones (accion_id),
    FOREIGN KEY (modulo_id) REFERENCES sh_roles.modulos (modulo_id)
);

CREATE TABLE IF NOT EXISTS sh_roles.rol_operaciones(
    role_id                 SMALLINT NOT NULL,
    operacion_id            SMALLINT NOT NULL,
    fecha_creado            DATE NOT NULL DEFAULT CURRENT_DATE,
    estado_id               SMALLINT NOT NULL,               
    PRIMARY KEY (role_id, operacion_id),
    FOREIGN KEY (role_id) REFERENCES sh_roles.roles (role_id),
    FOREIGN KEY (operacion_id) REFERENCES sh_roles.operaciones (operacion_id),
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)
);


CREATE TABLE IF NOT EXISTS sh_roles.usuarios (
    usuario_id              SMALLSERIAL PRIMARY KEY,
    username                VARCHAR(60) UNIQUE NOT NULL,
    password                VARCHAR(128) NOT NULL,
    fecha_creado            DATE NOT NULL DEFAULT CURRENT_DATE,
    persona_id              INTEGER UNIQUE NOT NULL,
    role_id                 SMALLINT NOT NULL,
    estado_id               SMALLINT NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES sh_personas.personas (persona_id),
    FOREIGN KEY (role_id)   REFERENCES sh_roles.roles (role_id),
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)
);



--------------------------------------------------
--              SCHEMA - ASESORIAS
--------------------------------------------------
CREATE SCHEMA IF NOT EXISTS sh_asesoria;
--------------------------------------------------
--              TABLAS
--------------------------------------------------
CREATE TABLE IF NOT EXISTS sh_asesoria.asesorias (
    asesoria_id             SERIAL PRIMARY KEY,
    asunto                  VARCHAR(255) NOT NULL,
    mensaje                 TEXT NOT NULL,
    persona_id               INTEGER NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES sh_personas.personas (persona_id)
);


CREATE TABLE IF NOT EXISTS sh_asesoria.categoria_planes(
    categoria_planes_id     SMALLSERIAL PRIMARY KEY,
    nombre                  VARCHAR (255) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS sh_asesoria.planes_acesorias (
    plan_id                 SERIAL PRIMARY KEY,
    plan_nombre             VARCHAR(255) NOT NULL,
    descripcion             TEXT,
    categoria_planes_id     SMALLINT NOT NULL,
    FOREIGN KEY (categoria_planes_id) REFERENCES sh_asesoria.categoria_planes (categoria_planes_id)
);

CREATE TABLE IF NOT EXISTS sh_asesoria.detalle_acesorias (
    asesoria_id             INTEGER NOT NULL,
    plan_id                 INTEGER NOT NULL,
    fecha_creado            DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (asesoria_id, plan_id),
    FOREIGN KEY (asesoria_id) REFERENCES sh_asesoria.asesorias (asesoria_id),
    FOREIGN KEY (plan_id) REFERENCES sh_asesoria.planes_acesorias (plan_id)   
);

--------------------------------------------------
--              SCHEMA - PRODUCTOS
--------------------------------------------------
CREATE SCHEMA IF NOT EXISTS sh_productos;
--------------------------------------------------
--              TABLAS
--------------------------------------------------

CREATE TABLE IF NOT EXISTS sh_productos.categoria_productos(
    categoria_id            SERIAL PRIMARY KEY,
    categoria_nombre        VARCHAR (50) UNIQUE NOT NULL,
    categoria_descripcion   VARCHAR (255),
    estado_id               INTEGER NOT NULL,
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)   
);


CREATE TABLE IF NOT EXISTS sh_productos.productos (
    producto_id             SMALLSERIAL PRIMARY KEY,
    producto_nombre         VARCHAR(80) UNIQUE NOT NULL,
    producto_descripcion    VARCHAR(150),
    precio                  INTEGER NOT NULL,
    costo                   INTEGER NOT NULL,
    existencia              SMALLINT NOT NULL,
    fecha_creado            DATE NOT NULL DEFAULT CURRENT_DATE,
    categoria_id            SMALLINT NOT NULL,
    estado_id               SMALLINT NOT NULL,
    usuario_id              SMALLINT NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES sh_productos.categoria_productos (categoria_id),
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id),
    FOREIGN KEY (usuario_id) REFERENCES sh_roles.usuarios (usuario_id)
);

CREATE TABLE IF NOT EXISTS sh_productos.control_costo(
    control_id              SERIAL PRIMARY KEY,
    costo_sin_iva           INTEGER NOT NULL,
    costo_iva               INTEGER NOT NULL,
    costo_total             INTEGER NOT NULL,
    precio_sin_iva          INTEGER NOT NULL,
    precio_total            INTEGER NOT NULL,
    fecha                   TIMESTAMP NOT NULL DEFAULT NOW(),
    producto_id             SMALLINT NOT NULL,
    estado_id               SMALLINT NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES sh_productos.productos (producto_id),   
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)   
);

--------------------------------------------------
--              SCHEMA - PUNTO-VENTA
--------------------------------------------------
CREATE SCHEMA IF NOT EXISTS sh_puntoventa;
--------------------------------------------------
--              TABLAS
--------------------------------------------------

CREATE TABLE IF NOT EXISTS sh_puntoventa.entradas(
    entrada_id              SERIAL PRIMARY KEY,
    total                   INTEGER NOT NULL,
    fecha                   DATE NOT NULL DEFAULT CURRENT_DATE,
    persona_id              INTEGER NOT NULL,
    usuario_id              SMALLINT NOT NULL, 
    estado_id               SMALLINT NOT NULL,
    FOREIGN KEY (persona_id) REFERENCES sh_personas.personas (persona_id),   
    FOREIGN KEY (usuario_id) REFERENCES sh_roles.usuarios (usuario_id),   
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)   
);

CREATE TABLE IF NOT EXISTS sh_puntoventa.detalle_entrada(
    producto_id             SMALLINT NOT NULL, 
    entrada_id              INTEGER NOT NULL,
    cantidad                INTEGER NOT NULL,
    coste_unitario          INTEGER NOT NULL,
    iva                     INTEGER NOT NULL,
    PRIMARY KEY(producto_id,entrada_id),
    FOREIGN KEY (producto_id) REFERENCES sh_productos.productos (producto_id),   
    FOREIGN KEY (entrada_id) REFERENCES sh_puntoventa.entradas (entrada_id)  
);


CREATE TABLE IF NOT EXISTS sh_puntoventa.ventas(
    venta_id                SERIAL PRIMARY KEY,
    total                   INTEGER NOT NULL,
    subtotal                INTEGER NOT NULL,
    iva                     INTEGER NOT NULL,
    fecha                   DATE NOT NULL DEFAULT CURRENT_DATE,
    usuario_id              SMALLINT NOT NULL, 
    estado_id               SMALLINT NOT NULL, 
    FOREIGN KEY (usuario_id) REFERENCES sh_roles.usuarios (usuario_id),   
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)   
);

CREATE TABLE IF NOT EXISTS sh_puntoventa.detalle_venta(
    producto_id             SMALLINT NOT NULL, 
    venta_id                INTEGER NOT NULL,
    cantidad                INTEGER NOT NULL,
    precio_unitario         INTEGER NOT NULL,
    coste_unitario          INTEGER NOT NULL,
    iva                     INTEGER NOT NULL,
    PRIMARY KEY(producto_id,venta_id),
    FOREIGN KEY (producto_id) REFERENCES sh_productos.productos (producto_id),   
    FOREIGN KEY (venta_id) REFERENCES sh_puntoventa.ventas (venta_id)  
);


CREATE TABLE IF NOT EXISTS sh_puntoventa.perdidas(
    perdida_id              SERIAL PRIMARY KEY,
    total                   INTEGER NOT NULL,
    fecha                   DATE NOT NULL DEFAULT CURRENT_DATE,
    usuario_id              SMALLINT NOT NULL, 
    estado_id               SMALLINT NOT NULL, 
    FOREIGN KEY (usuario_id) REFERENCES sh_roles.usuarios (usuario_id),   
    FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)   
);

CREATE TABLE IF NOT EXISTS sh_puntoventa.detalle_perdida(
    producto_id             SMALLINT NOT NULL, 
    perdida_id              INTEGER NOT NULL,
    cantidad                INTEGER NOT NULL,
    coste_unitario          INTEGER NOT NULL,
    PRIMARY KEY(producto_id,perdida_id),
    FOREIGN KEY (producto_id) REFERENCES sh_productos.productos (producto_id),   
    FOREIGN KEY (perdida_id) REFERENCES sh_puntoventa.perdidas (perdida_id)  
);

-- --------------------------------------------------
-- --              SCHEMA - ORDEN
-- --------------------------------------------------
-- CREATE SCHEMA IF NOT EXISTS sh_ordenes;
-- --------------------------------------------------
-- --              TABLAS
-- --------------------------------------------------

-- CREATE TABLE IF NOT EXISTS sh_ordenes.tokens(
--     token_id                VARCHAR (128) NOT NULL,
--     fecha                   DATE NOT NULL DEFAULT CURRENT_DATE,
--     estado_id               SMALLINT NOT NULL,
--     PRIMARY KEY(token_id),
--     FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)
-- );

-- CREATE TABLE IF NOT EXISTS sh_ordenes.carritos(
--     carrito_id              SERIAL PRIMARY KEY, 
--     cantidad                INTEGER NOT NULL,
--     fecha                   DATE NOT NULL DEFAULT CURRENT_DATE,
--     producto_id             SMALLINT NOT NULL,
--     estado_id               SMALLINT NOT NULL,
--     token_id                VARCHAR (128) NOT NULL,
--     FOREIGN KEY (producto_id) REFERENCES sh_productos.productos (producto_id),   
--     FOREIGN KEY (token_id) REFERENCES sh_ordenes.tokens (token_id),   
--     FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)  
-- );

-- CREATE TABLE IF NOT EXISTS sh_ordenes.metodo_pago(
--     metodo_id               SMALLSERIAL PRIMARY KEY,
--     producto_nombre         VARCHAR(110) NOT NULL,
--     fecha                   DATE NOT NULL DEFAULT CURRENT_DATE
-- );

-- CREATE TABLE IF NOT EXISTS sh_ordenes.ordenes(
--     orden_id                SERIAL PRIMARY KEY,
--     total                   INTEGER NOT NULL,
--     fecha                   DATE NOT NULL DEFAULT CURRENT_DATE,
--     persona_id               INTEGER NOT NULL,
--     metodo_id               SMALLINT NOT NULL,
--     usuario_id              SMALLINT NOT NULL, 
--     estado_id               SMALLINT NOT NULL,
--     FOREIGN KEY (persona_id) REFERENCES sh_personas.personas (persona_id),   
--     FOREIGN KEY (metodo_id) REFERENCES sh_ordenes.metodo_pago (metodo_id),   
--     FOREIGN KEY (usuario_id) REFERENCES sh_roles.usuarios (usuario_id),   
--     FOREIGN KEY (estado_id) REFERENCES public.catalago_estados (estado_id)   
-- );

-- CREATE TABLE IF NOT EXISTS sh_ordenes.detalle_orden(
--     producto_id             SMALLINT NOT NULL, 
--     orden_id                INTEGER NOT NULL,
--     cantidad                INTEGER NOT NULL,
--     precio_unitario         INTEGER NOT NULL,
--     coste_unitario          INTEGER NOT NULL,
--     carrito_id              INTEGER NOT NULL,
--     PRIMARY KEY(producto_id,orden_id),
--     FOREIGN KEY (producto_id) REFERENCES sh_productos.productos (producto_id),   
--     FOREIGN KEY (orden_id) REFERENCES sh_ordenes.ordenes (orden_id),  
--     FOREIGN KEY (carrito_id) REFERENCES sh_ordenes.carritos (carrito_id)
-- );


--------------------------------------------------
--              SCHEMA - AUDITORIA
--------------------------------------------------
CREATE SCHEMA IF NOT EXISTS sh_auditoria;
--------------------------------------------------
--              TABLAS
--------------------------------------------------
CREATE TABLE sh_auditoria.auditorias(
    auditoria_id            SERIAL,
    fecha                   TIMESTAMP NOT NULL DEFAULT NOW(),
    usuario_id              SMALLINT NOT NULL,
    usuario_db              VARCHAR(45) NOT NULL,
    accion                  VARCHAR(20) NOT NULL,
    tabla                   VARCHAR(20) NOT NULL,
    anterior                JSON,
    nuevo                   JSON,
    PRIMARY KEY (auditoria_id),
    FOREIGN KEY (usuario_id) REFERENCES sh_roles.usuarios (usuario_id)
);




---------------------------------------------
--              INSERTANDO DATOS
---------------------------------------------



INSERT INTO public.catalago_estados(
	 nombre_estado)
	VALUES 
        ('activo'),
	    ('inactivo'),
	    ('pendiente'),
	    ('cancelado');


INSERT INTO sh_roles.roles(
         role_nombre
         )
	VALUES 
        ('administrador'),
        ('vendedor'),
        ('cejero');

INSERT INTO sh_asesoria.categoria_planes(
         nombre
         )
	VALUES 
        ('COSECHAS'),
        ('REFORESTACION');


INSERT INTO sh_asesoria.planes_acesorias(
         plan_nombre,
         categoria_planes_id
         )
	VALUES 
        ('CONSECHAS MELIFERAS',1),
        ('REFORESTACION CON ARBOLES MELIFEROS',2);



INSERT INTO sh_personas.localidades(
	    localidad_nombre,
        localidad_departamento)
	VALUES 
        ( 'Albania', 'Caqueta'),
        ( 'Belén de los Andaquíes', 'Caqueta'),
        ( 'Cartagena del Chairá', 'Caqueta'),
        ( 'Curillo', 'Caqueta'),
        ( 'El Doncello', 'Caqueta'),
        ( 'El Paujil', 'Caqueta'),
        ( 'Florencia', 'Caqueta'),
        ( 'La Montañita', 'Caqueta'),
        ( 'Morelia', 'Caqueta'),
        ( 'Puerto Milán', 'Caqueta'),
        ( 'Puerto Rico', 'Caqueta'),
        ( 'San José del Fragua', 'Caqueta'),
        ( 'San Vicente del Caguán', 'Caqueta'),
        ( 'Solano', 'Caqueta'),
        ( 'Solita', 'Caqueta'),
        ( 'Valparaíso', 'Caqueta');


INSERT INTO sh_roles.modulos(
	    modulo_nombre
        )
	VALUES 
        ('Localidades'),
        ('Roles'),
        ('Productos'),
        ('Ventas'),
        ('Entradas'),
        ('Ordenes'),
        ('Peridas'),
        ('Asesorias');

INSERT INTO sh_roles.acciones(
	    accion_nombre
        )
	VALUES 
        ('insertar'),
        ('editar'),
        ('listar'),
        ('eliminar');


INSERT INTO sh_roles.operaciones(
	    accion_id,
        modulo_id
        )
	VALUES 
        (1,1),
        (2,1),
        (3,1),
        (4,1),
        (1,2),
        (2,2),
        (3,2),
        (4,2),
        (1,3),
        (2,3),
        (3,3),
        (4,3),
        (1,4),
        (2,4),
        (3,4),
        (4,4),
        (1,5),
        (2,5),
        (3,5),
        (4,5),
        (1,6),
        (2,6),
        (3,6),
        (4,6),
        (1,7),
        (2,7),
        (3,7),
        (4,7);

INSERT INTO sh_roles.rol_operaciones(
	    role_id,
        operacion_id,
        estado_id
        )
	VALUES 
        (1,1,1),
        (1,2,1),
        (1,3,1),
        (1,4,1),
        (1,5,1),
        (1,6,1),
        (1,7,1),
        (1,8,1),
        (1,9,1),
        (1,10,1),
        (1,11,1),
        (1,12,1),
        (1,13,1),
        (1,14,1),
        (1,15,1),
        (1,16,1),
        (1,17,1),
        (1,18,1),
        (1,19,1),
        (1,20,1),
        (1,21,1),
        (1,22,1),
        (1,23,1),
        (1,24,1),
        (1,25,1),
        (1,26,1),
        (1,27,1),
        (1,28,1);

INSERT INTO sh_personas.personas(
	    documento,
        primer_nombre,
        segundo_nombre,
        primer_apellido,
        segundo_apellido,
        email,
        telefono,
        fecha_creado
        )
	VALUES 
        (111712478, 'Stephen', 'Gary', 'Wozniak', DEFAULT, 'stevewozniak@gmail.com',3202569805, DEFAULT);


 INSERT INTO sh_roles.usuarios(
	    username, 
        password, 
        fecha_creado,
        persona_id,
        role_id, 
        estado_id
       )
	VALUES 
        ('stevewozniak', '1234', DEFAULT, 1, 1, 1);
        


ALTER TABLE sh_personas.personas
    ADD COLUMN usuario_id INTEGER;

ALTER TABLE sh_personas.personas 
    ADD FOREIGN KEY (usuario_id) 
    REFERENCES sh_roles.usuarios (usuario_id);

ALTER TABLE sh_roles.usuarios
    ADD COLUMN r_usuario_id INTEGER;

ALTER TABLE sh_roles.usuarios 
    ADD FOREIGN KEY (r_usuario_id) 
    REFERENCES sh_roles.usuarios (usuario_id);


UPDATE sh_personas.personas
	SET  usuario_id=1
	WHERE persona_id = 1;

UPDATE sh_roles.usuarios
	SET r_usuario_id=1
	WHERE usuario_id = 1;

ALTER TABLE sh_personas.personas
    ALTER COLUMN usuario_id SET NOT NULL;

ALTER TABLE sh_roles.usuarios
    ALTER COLUMN r_usuario_id SET NOT NULL;



INSERT INTO sh_productos.categoria_productos(
        categoria_nombre,
        categoria_descripcion,
        estado_id
        )
	VALUES 
        ('Polen',DEFAULT, 1),
        ('Miel',DEFAULT, 1),
        ('Colmena',DEFAULT, 1),
        ('Propoleo',DEFAULT, 1),
        ('Cera',DEFAULT, 1);
----------------------------------------------------
INSERT INTO sh_productos.productos(
        producto_nombre,
        producto_descripcion,
        precio, 
        costo,
        existencia,
        fecha_creado,
        categoria_id,
        estado_id,
        usuario_id
        )
	VALUES 
        ('Miel Botella 1.000gr', DEFAULT, 0, 0, 0, DEFAULT, 2, 1,1),
        ('Miel Pura de Abejas 500gr', DEFAULT, 0, 0, 0, DEFAULT, 2, 1,1),
        ('Polen Frasco 140gr', DEFAULT, 0, 0, 0, DEFAULT, 1, 1,1),
        ('Propóleo 300gr',  DEFAULT, 0, 0, 0, DEFAULT, 4, 1,1),
        ('Colmena Estándar', DEFAULT, 0, 0, 0, DEFAULT, 3, 1,1),
        ('Colmena Melipona',  DEFAULT, 0, 0, 0, DEFAULT, 3, 1,1),
        ('Alza Mediana con Cuadros y Cera',  DEFAULT, 0, 0, 0, DEFAULT, 3, 1,1),
        ('Alza Mediana Vacía',  DEFAULT, 0, 0, 0, DEFAULT, 3, 1,1),
        ('Propóleo Extrato 30ml',  DEFAULT, 0, 0, 0, DEFAULT, 4, 1,1);




--------------------------------------------------
--              SCHEMA - PRODUCTOS 
--------------------------------------------------
--              FUNCIONES
--------------------------------------------------


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

-- ALTER FUNCTION sh_productos.fn_consultar_productos_administracion OWNER TO admin_arbolesmiel;



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

-- ALTER FUNCTION sh_productos.fn_consultar_productos_venta OWNER TO admin_arbolesmiel;


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

--------------------------------------------------
--              PROCEDIMIENTOS
--------------------------------------------------

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


--------------------------------------------------
--              SCHEMA - ASESORIAS 
--------------------------------------------------
--              FUNCIONES
--------------------------------------------------

CREATE OR REPLACE FUNCTION sh_asesoria.fn_consultar_planes_acesorias()
RETURNS SETOF sh_asesoria.planes_acesorias
LANGUAGE PLPGSQL
AS
$$
DECLARE
BEGIN
    RETURN QUERY SELECT 
                    p.plan_id,
                    p.plan_nombre,
                    p.descripcion,
                    p.categoria_planes_id
                FROM sh_asesoria.planes_acesorias p
                ORDER BY p.plan_nombre ASC;
END;
$$;

--------------------------------------------------
--              PROCEDIMIENTOS
--------------------------------------------------

CREATE OR REPLACE FUNCTION sh_asesoria.pr_registrar_asesoria
(
    _asunto         VARCHAR,
    _mensaje        TEXT,
    _persona_id     INTEGER
)
RETURNS SETOF sh_asesoria.asesorias
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_asesoria.asesorias(
                asunto, 
                mensaje, 
                persona_id
            ) VALUES(
                _asunto,
                _mensaje,
                _persona_id
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la persona';
        END IF;       
END;
$$;


CREATE OR REPLACE FUNCTION sh_asesoria.pr_registrar_detalle_asesoria
(
    _asesoria_id       INTEGER,
    _plan_id           INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
BEGIN
        INSERT INTO sh_asesoria.detalle_acesorias(
                asesoria_id,
                plan_id
            ) VALUES(
                _asesoria_id,
                _plan_id
            ); 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la asesoria';
        END IF;       
END;
$$;


CREATE OR REPLACE FUNCTION sh_asesoria.pr_eliminar_asesoria
(
 _asesoria_id  INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
  
BEGIN

        DELETE FROM sh_asesoria.detalle_acesorias
        WHERE asesoria_id = _asesoria_id;

        DELETE FROM sh_asesoria.asesorias
	    WHERE asesoria_id = _asesoria_id;   
  
END;
$$;

--------------------------------------------------
--              SCHEMA - PERSONAS 
--------------------------------------------------
--              FUNCIONES
--------------------------------------------------

CREATE OR REPLACE FUNCTION sh_personas.fn_consultar_direcciones_persona(_persona_id INTEGER)
RETURNS 
    TABLE(
        id              INTEGER,
        direccion       VARCHAR,
        barrio          VARCHAR,
        localidad       VARCHAR,
        departamento    VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    d.domicilio_id id,
                    d.direccion,
                    d.barrio,
                    l.localidad_nombre localidad,
                    l.localidad_departamento departamento
                FROM sh_personas.detalle_direccion dt
                    INNER JOIN sh_personas.direcciones d on d.domicilio_id = dt.domicilio_id
                    INNER JOIN sh_personas.localidades l on l.localidad_id = d.localidad_id
                    WHERE dt.persona_id = _persona_id
                    ORDER BY d.domicilio_id ASC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La personas no se encuentra registrada o no ha registrado direcciones';
        END IF;          
END;
$$;



CREATE OR REPLACE FUNCTION sh_personas.fn_consultar_direcciones()
RETURNS 
    TABLE(
        id              INTEGER,
        direccion       VARCHAR,
        barrio          VARCHAR,
        persona         TEXT,
        localidad       TEXT
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    d.domicilio_id id,
                    d.direccion,
                    d.barrio,
                    concat(p.primer_nombre,'  ',p.primer_apellido) persona,
                    concat(l.localidad_nombre,' - ',l.localidad_departamento) localidad
                FROM sh_personas.direcciones d
                    INNER JOIN sh_personas.localidades l on l.localidad_id = d.localidad_id
                    INNER JOIN sh_personas.detalle_direccion dt on dt.domicilio_id = d.domicilio_id
                    INNER JOIN sh_personas.personas p on p.persona_id = dt.persona_id
                    ORDER BY persona ASC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La se encuentra vacia';
        END IF;          
END;
$$;

CREATE OR REPLACE FUNCTION sh_personas.fn_consultar_localidades()
RETURNS SETOF sh_personas.localidades
LANGUAGE PLPGSQL
AS
$$
DECLARE
BEGIN
    RETURN QUERY SELECT 
                    l.localidad_id,
                    l.localidad_nombre,
                    l.localidad_departamento
                FROM sh_personas.localidades l
                ORDER BY l.localidad_nombre ASC;
END;
$$;

--------------------------------------------------
--              PROCEDIMIENTO
--------------------------------------------------

CREATE OR REPLACE FUNCTION sh_personas.pr_editar_direccion
(   
   _domicilio_id INTEGER,
   _direccion VARCHAR,
   _barrio VARCHAR,
   _localidad_id INTEGER
)
RETURNS SETOF sh_personas.direcciones
LANGUAGE PLPGSQL
AS
$$  
BEGIN
        RETURN query 
            UPDATE sh_personas.direcciones SET
                 direccion = _direccion,
                 barrio = _barrio,
                 localidad_id = _localidad_id     
	        WHERE domicilio_id = _domicilio_id RETURNING *;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en la edicion de la direccion';
        END IF; 
END;
$$;



CREATE OR REPLACE FUNCTION sh_personas.pr_registrar_direccion
(
   _direccion VARCHAR,
   _barrio VARCHAR,
   _localidad_id INTEGER
)
RETURNS SETOF sh_personas.direcciones
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_personas.direcciones(
                direccion, 
                barrio, 
                localidad_id
            ) VALUES(
                _direccion,
                _barrio,
                _localidad_id
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la persona';
        END IF;       
END;
$$;


CREATE OR REPLACE FUNCTION sh_personas.pr_registrar_direccion_persona
(   
    _documento VARCHAR,
    _direccion VARCHAR,
    _barrio VARCHAR,
    _localidad INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
_persona INTEGER;
_direccion_t INTEGER;
BEGIN

        SELECT p.persona_id INTO _persona FROM sh_personas.personas p WHERE p.documento = _documento;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'La persona no se encuentra registrada';
        END IF; 
        
        SELECT domicilio_id INTO _direccion_t FROM sh_personas.pr_registrar_direccion(
                _direccion,
                _barrio,    
                 _localidad
                );

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro de la direccion de la persona';
        END IF; 

        INSERT INTO sh_personas.detalle_direccion(
            domicilio_id,
            persona_id
            )
        VALUES(
            _direccion_t,
            _persona 
            );

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del detalle de la direccion';
        END IF;      
END;
$$;



CREATE OR REPLACE FUNCTION sh_personas.pr_editar_localidad
(   
   _localidad_id INTEGER,
   _localidad_nombre VARCHAR,
   _localidad_departamento VARCHAR
)
RETURNS SETOF sh_personas.localidades
LANGUAGE PLPGSQL
AS
$$  
BEGIN
        RETURN query 
            UPDATE sh_personas.localidades SET
                 localidad_nombre = _localidad_nombre,
                 localidad_departamento = _localidad_departamento  
	        WHERE localidad_id = _localidad_id RETURNING *;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en la edicion de la localidad';
        END IF; 
END;
$$;


CREATE OR REPLACE FUNCTION sh_personas.pr_registrar_localidad
(
   _localidad_nombre VARCHAR,
   _localidad_departamento VARCHAR
)
RETURNS SETOF sh_personas.localidades
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_personas.localidades(
                localidad_nombre,
                localidad_departamento
            ) VALUES(
                _localidad_nombre,
                _localidad_departamento
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la localidad';
        END IF;       
END;
$$;



CREATE OR REPLACE FUNCTION sh_personas.fn_consultar_personas()
RETURNS 
    TABLE(
            id INTEGER,
            documento VARCHAR,
            primer_nombre VARCHAR,
            segundo_nombre VARCHAR,
            primer_apellido VARCHAR,
            segundo_apellido VARCHAR,
            email VARCHAR,
            telefono VARCHAR,
            fecha DATE,
            usuario VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    p.persona_id id,
                    p.documento,
                    p.primer_nombre,
                    p.segundo_nombre,
                    p.primer_apellido,
                    p.segundo_apellido,
                    p.email,
                    p.telefono,
                    p.fecha_creado fecha,
                    r.role_nombre usuairo
                FROM sh_personas.personas p
                    INNER JOIN sh_roles.usuarios u on u.usuario_id = p.usuario_id
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                    ORDER BY p.persona_id ASC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La tabla esta vacia';
        END IF;          
END;
$$;


CREATE OR REPLACE FUNCTION sh_personas.fn_consultar_persona_especifica(_documento VARCHAR)
RETURNS SETOF sh_personas.personas
LANGUAGE PLPGSQL
AS
$$
DECLARE
BEGIN
    RETURN QUERY SELECT 
                    p.persona_id,
                    p.documento,
                    p.primer_nombre,
                    p.segundo_nombre,
                    p.primer_apellido, 
                    p.segundo_apellido,
                    p.email,
                    p.telefono,
                    p.fecha_creado,
                    p.usuario_id
                FROM sh_personas.personas p
                WHERE p.documento = _documento;      
END;
$$;



CREATE OR REPLACE FUNCTION sh_personas.pr_registrar_personas
(
    _documento VARCHAR,
    _primer_nombre VARCHAR ,
    _segundo_nombre VARCHAR,
    _primer_apellido VARCHAR,
    _segundo_apellido VARCHAR,
    _email VARCHAR,
    _telefono VARCHAR,
    _usuario_id INTEGER
)
RETURNS SETOF sh_personas.personas
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_personas.personas(
            documento, 
            primer_nombre, 
            segundo_nombre, 
            primer_apellido,
            segundo_apellido, 
            email,
            telefono,
            usuario_id
            ) VALUES(
                _documento,
                _primer_nombre,
                _segundo_nombre,
                _primer_apellido,
                _segundo_apellido,
                _email,
                _telefono,
                _usuario_id 
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la persona';
        END IF;       
END;
$$;




CREATE OR REPLACE FUNCTION sh_personas.pr_editar_persona 
(   
    _persona_id INTEGER,
    _documento VARCHAR,
    _primer_nombre VARCHAR ,
    _segundo_nombre VARCHAR,
    _primer_apellido VARCHAR,
    _segundo_apellido VARCHAR,
    _email VARCHAR,
    _telefono VARCHAR,
    _usuario_id INTEGER
)
RETURNS SETOF sh_personas.personas
LANGUAGE PLPGSQL
AS
$$  
BEGIN
        RETURN query 
            UPDATE sh_personas.personas SET 
                    documento = _documento,
                    primer_nombre=_primer_nombre, 
                    segundo_nombre=_segundo_nombre, 
                    primer_apellido=_primer_apellido, 
                    segundo_apellido=_segundo_apellido, 
                    email=_email,
                    telefono=_telefono,
                    usuario_id = _usuario_id  
	        WHERE persona_id = _persona_id RETURNING *;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en la edicion de la persona';
        END IF; 
END;
$$;






CREATE OR REPLACE FUNCTION sh_personas.pr_registrar_persona_direccion
(
    _documento VARCHAR,
    _primer_nombre VARCHAR ,
    _segundo_nombre VARCHAR,
    _primer_apellido VARCHAR,
    _segundo_apellido VARCHAR,
    _email VARCHAR,
    _telefono VARCHAR,
    _usuario_id INTEGER,
    _direccion VARCHAR,
    _barrio VARCHAR,
    _localidad INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
 _persona INTEGER;
 _direccion_t INTEGER;
BEGIN
        SELECT persona_id INTO _persona 
        FROM sh_personas.pr_registrar_personas(
                _documento ,
                _primer_nombre  ,
                _segundo_nombre ,
                _primer_apellido ,
                _segundo_apellido ,
                _email,
                _telefono,
                _usuario_id
            );

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la persona';
        END IF;      

        SELECT domicilio_id INTO _direccion_t FROM sh_personas.pr_registrar_direccion(
                _direccion,
                _barrio,    
                 _localidad
                );

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la direccion de la persona';
        END IF; 

        INSERT INTO sh_personas.detalle_direccion(
            domicilio_id,
            persona_id
            )
        VALUES(
            _direccion_t,
            _persona 
            ); 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del detalle de la direccion';
        END IF; 
END;
$$;


CREATE OR REPLACE FUNCTION sh_personas.pr_registrar_persona_acesoria
(
    _documento VARCHAR,
    _primer_nombre VARCHAR ,
    _segundo_nombre VARCHAR,
    _primer_apellido VARCHAR,
    _segundo_apellido VARCHAR,
    _email VARCHAR,
    _telefono VARCHAR,
    _usuario_id INTEGER,
    _asunto VARCHAR,
    _descripcion TEXT,
    _plan INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
 _persona INTEGER;
 _asesoria_t INTEGER;
BEGIN
        SELECT persona_id INTO _persona 
        FROM sh_personas.pr_registrar_personas(
                _documento ,
                _primer_nombre  ,
                _segundo_nombre ,
                _primer_apellido ,
                _segundo_apellido ,
                _email,
                _telefono,
                _usuario_id
            );

        IF NOT FOUND THEN
            SELECT persona_id into _persona FROM  sh_personas.fn_consultar_persona_especifica(_documento);
        END IF;      

        SELECT asesoria_id INTO _asesoria_t FROM sh_asesoria.pr_registrar_asesoria(
            _asunto,         
            _descripcion,       
            _persona
            );

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la direccion de la asesoria';
        END IF; 

        INSERT INTO sh_asesoria.detalle_acesorias(
            asesoria_id,
            plan_id
            )
        VALUES(
            _plan,
            _asesoria_t 
            ); 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del detalle de la direccion';
        END IF; 
END;
$$;





--------------------------------------------------
--              SCHEMA - ROLES 
--------------------------------------------------
--              FUNCIONES
--------------------------------------------------
CREATE OR REPLACE FUNCTION sh_roles.autenticacion(_username VARCHAR,_password VARCHAR)
RETURNS 
    TABLE(
        usuario_id smallint,
        username varchar,
        -- password varchar,
        role_nombre varchar,
        role_id smallint
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    u.usuario_id,
                    u.username,
                    r.role_nombre,
                    r.role_id
                FROM sh_roles.usuarios u
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                WHERE u.username = _username AND u.password = _password AND u.estado_id = 1;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'El usuairo o la contrasenia no coincide';
        END IF;          
END;
$$;


CREATE OR REPLACE FUNCTION sh_roles.fn_validar_usuario_auth(_username VARCHAR)
RETURNS 
    TABLE(
        usuario_id smallint,
        username varchar,
        password varchar,
        role_nombre varchar,
        role_id smallint
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    u.usuario_id,
                    u.username,
                    u.password,
                    r.role_nombre,
                    r.role_id
                FROM sh_roles.usuarios u
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                WHERE u.username = _username AND u.estado_id = 1 limit 1;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Los credenciales no conincides o el usuario se encuentra impedido';
        END IF;          
END;
$$;

CREATE OR REPLACE FUNCTION sh_roles.fun_consultar_opreraciones_rol(
   _role_id          INTEGER,
   _operacion_id     INTEGER
)
RETURNS INTEGER
LANGUAGE PLPGSQL
AS
$$
DECLARE
     _role_name INTEGER;
BEGIN
        SELECT
            ro.role_id INTO _role_name
        FROM sh_roles.rol_operaciones ro
        WHERE 
            ro.role_id = _role_id and 
            ro.operacion_id = _operacion_id and
            ro.estado_id = 1;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'No tiene permisos';
        ELSE
            RETURN _role_name;
        END IF; 
END;
$$;

CREATE OR REPLACE FUNCTION sh_roles.fn_consultar_usuario(_usuario_id INTEGER)
RETURNS SETOF sh_roles.usuarios
LANGUAGE PLPGSQL
AS
$$
DECLARE
BEGIN
    RETURN QUERY SELECT 
                    u.usuario_id,
                    u.username,
                    u.password,
                    u.fecha_creado,
                    u.persona_id, 
                    u.role_id,
                    u.estado_id,
                    u.r_usuario_id
                FROM sh_roles.usuarios u
                WHERE u.usuario_id = _usuario_id;   

                IF NOT FOUND THEN
                    RAISE EXCEPTION 'El usuairo no existe';
                END IF;   
END;
$$;




CREATE OR REPLACE FUNCTION sh_roles.fn_consultar_usuarios()
RETURNS 
    TABLE(
            id SMALLINT,
            username VARCHAR,
            fecha DATE,
            persona TEXT,
            email VARCHAR,
            telefono VARCHAR,
            rol VARCHAR,
            estado VARCHAR,
            creado_por VARCHAR
        )
LANGUAGE PLPGSQL
AS
$$
DECLARE

BEGIN
    RETURN QUERY 
                SELECT 
                    u.usuario_id id,
                    u.username,
                    u.fecha_creado fecha,
                    concat(p.primer_nombre,'  ',p.primer_apellido) persona,
                    p.email,
                    p.telefono,
                    r.role_nombre rol,
                    ce.nombre_estado estado,
                    (SELECT us.username from sh_roles.usuarios us where us.usuario_id = u.r_usuario_id ) creado_por
                FROM sh_roles.usuarios u
                    INNER JOIN sh_personas.personas p on p.persona_id = u.persona_id
                    INNER JOIN sh_roles.roles r on r.role_id = u.role_id
                    INNER JOIN public.catalago_estados ce on ce.estado_id = u.estado_id
                    ORDER BY u.usuario_id ASC;
            
        IF NOT FOUND THEN
            RAISE EXCEPTION 'La tabla esta vacia';
        END IF;          
END;
$$;



CREATE OR REPLACE FUNCTION sh_roles.pr_registrar_usuario
(
   _username    VARCHAR,
   _password    VARCHAR,
   _persona     INTEGER,
   _role        INTEGER,
   _estado      INTEGER,
   _r_usuario   INTEGER
)
RETURNS SETOF sh_roles.usuarios
LANGUAGE PLPGSQL
AS
$$
BEGIN
    RETURN QUERY 
        INSERT INTO sh_roles.usuarios(
                username,
                password,
                persona_id,
                role_id,
                estado_id,
                r_usuario_id
            ) VALUES(
                _username,
                _password,
                _persona,
                _role,
                _estado,
                _r_usuario
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del Usuario';
        END IF;       
END;
$$;


--------------------------------------------------
--              SCHEMA - PUNTOVENTA 
--------------------------------------------------
--              FUNCIONES
--------------------------------------------------
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



------------------------------------------------
--------- OK
------------------------------------------------
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


----------------------------------------------
--          VISTAS
----------------------------------------------



--- VENTAS
CREATE VIEW sh_puntoventa.v_ver_todos_registros_ventas AS
SELECT 
    v.venta_id factura,
    p.producto_nombre producto,
    dv.cantidad,
    dv.precio_unitario precio,
    dv.coste_unitario costo,
    dv.iva,
    (dv.cantidad * dv.precio_unitario) as total,
    (dv.cantidad * dv.coste_unitario) as subtotal,
    (dv.cantidad * dv.iva) as total_iva,
    us.username usuario,
    rl.role_nombre rol,
    v.fecha,
    ce.nombre_estado estado
FROM sh_puntoventa.detalle_venta dv
INNER JOIN sh_productos.productos p on p.producto_id = dv.producto_id
INNER JOIN sh_puntoventa.ventas v on v.venta_id = dv.venta_id
INNER JOIN sh_roles.usuarios us on us.usuario_id = v.usuario_id
INNER JOIN sh_roles.roles rl on rl.role_id = us.role_id
INNER JOIN public.catalago_estados ce on ce.estado_id = v.estado_id;


--- PERDIDAS
CREATE VIEW sh_puntoventa.v_ver_todos_perdidas AS
SELECT 
    (dp.cantidad * dp.coste_unitario) as Total,
    dp.coste_unitario,
    dp.cantidad,
    p.producto_nombre producto,
    us.username usuario,
    rl.role_nombre rol,
    pr.fecha
FROM sh_puntoventa.detalle_perdida dp
INNER JOIN sh_productos.productos p on p.producto_id = dp.producto_id
INNER JOIN sh_puntoventa.perdidas pr on pr.perdida_id = dp.perdida_id
INNER JOIN sh_roles.usuarios us on us.usuario_id = pr.usuario_id
INNER JOIN sh_roles.roles rl on rl.role_id = us.role_id;

--- ENTRADA

CREATE VIEW sh_puntoventa.v_ver_todos_registros AS
SELECT 
    (de.cantidad * de.coste_unitario) as Total,
    de.coste_unitario,
    de.cantidad,
    de.iva,
    p.producto_nombre producto,
    per.primer_nombre || ' ' || per.primer_apellido as proveedor,
    us.username usuario,
    rl.role_nombre rol,
    en.fecha
FROM sh_puntoventa.detalle_entrada de
INNER JOIN sh_productos.productos p on p.producto_id = de.producto_id
INNER JOIN sh_puntoventa.entradas en on en.entrada_id = de.entrada_id
INNER JOIN sh_personas.personas per on per.persona_id = en.persona_id
INNER JOIN sh_roles.usuarios us on us.usuario_id = en.usuario_id
INNER JOIN sh_roles.roles rl on rl.role_id = us.role_id;


CREATE OR REPLACE FUNCTION sh_puntoventa.calcular_total_cabezera
(
    cabezera VARCHAR,
    cabecera_id INT,
    cantidad INT,
    costo_precio INT
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
   cabezera_total    integer := 0;
BEGIN

    IF(cabezera = 'ENTRADA') THEN
        
        SELECT 
            total into cabezera_total
        FROM sh_puntoventa.entradas
        WHERE entrada_id = cabecera_id;

        UPDATE sh_puntoventa.entradas
            SET total = cabezera_total + (cantidad*costo_precio)
        WHERE entrada_id = cabecera_id;

    ELSEIF(cabezera = 'VENTA') THEN

        SELECT 
            total into cabezera_total
        FROM sh_puntoventa.ventas
        WHERE venta_id = cabecera_id;

        UPDATE sh_puntoventa.ventas
            SET total = cabezera_total + (cantidad*costo_precio)
        WHERE venta_id = cabecera_id;

    ELSEIF(cabezera = 'PERDIDA') THEN

       SELECT 
            total into cabezera_total
        FROM sh_puntoventa.perdidas
        WHERE perdida_id = cabecera_id;

        UPDATE sh_puntoventa.perdidas
            SET total = cabezera_total + (cantidad*costo_precio)
        WHERE perdida_id = cabecera_id;

    END IF;
 
END;
$$;
----------------------------------------------
--          TRIGGER
----------------------------------------------
--ENTRADA

CREATE OR REPLACE FUNCTION sh_puntoventa.tg_calcular_total_entrada()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    producto_costo      integer := 0;
    producto_existencia integer := 0;
    costo_parcial_v     integer := 0;
    costo_total_v       integer := 0;
    costo_cantidad      integer := 0;
    precio_total_v      integer := 0;
BEGIN


    -- VALIDA DATOS

    IF NEW.cantidad = 0 OR NEW.coste_unitario = 0 THEN
        RAISE EXCEPTION 'la cantidad o el coste unitario tiene valores de 0';
    END IF;

    IF NEW.cantidad < 0 OR NEW.coste_unitario < 0 THEN
        RAISE EXCEPTION 'la cantidad o el coste unitario no puede ser negativa';
    END IF;

    NEW.iva = (NEW.coste_unitario*0.19);



    -- CONSULTA EL PRODUCTO
    SELECT 
        existencia,
        costo 
        into producto_existencia,producto_costo
    FROM sh_productos.productos
    WHERE producto_id = NEW.producto_id;


    -- ACTUALIZA EL COSTO Y EL PRECIO DEL PRODUCTO
    IF (producto_costo = 0 OR producto_existencia = 0) THEN

        precio_total_v = (NEW.coste_unitario + NEW.iva) * 1.3;

        UPDATE sh_productos.productos
            SET existencia = (producto_existencia + NEW.cantidad),
                precio = precio_total_v,
                costo = (NEW.coste_unitario + NEW.iva)
        WHERE producto_id = NEW.producto_id;

        INSERT INTO sh_productos.control_costo(
                costo_sin_iva,
	            costo_iva,
                costo_total,
                precio_sin_iva,
                precio_total,
                fecha,
                producto_id,
                estado_id)
	    VALUES (
                NEW.coste_unitario,
                NEW.coste_unitario + NEW.iva,
                NEW.coste_unitario + NEW.iva,
                NEW.coste_unitario * 1.3,
                precio_total_v,
                DEFAULT,
                NEW.producto_id, 1);

    ELSE
        ------
        SELECT 
            SUM(costo_iva),
            COUNT(costo_iva) 
            into costo_parcial_v,costo_cantidad 
        FROM sh_productos.control_costo
        WHERE producto_id = NEW.producto_id AND estado_id = 1;
        

        costo_parcial_v = costo_parcial_v + (NEW.coste_unitario + NEW.iva);
        costo_cantidad = costo_cantidad + 1;
        costo_total_v = DIV(costo_parcial_v,costo_cantidad);
        precio_total_v = (costo_total_v * 1.3);
        ------
        INSERT INTO sh_productos.control_costo(
	            costo_sin_iva,
	            costo_iva,
                costo_total,
                precio_sin_iva,
                precio_total,
                fecha,
                producto_id,
                estado_id)
	    VALUES (
            NEW.coste_unitario,
            NEW.coste_unitario + NEW.iva,
            costo_total_v,
            NEW.coste_unitario*1.3,
            precio_total_v,
            CURRENT_DATE,
            NEW.producto_id, 1);
        ------
        UPDATE sh_productos.productos
            SET existencia = producto_existencia + NEW.cantidad,
                precio = precio_total_v,
                costo = costo_total_v
        WHERE producto_id = NEW.producto_id;

    END IF;

    -- CALCULA EL TOTAL DE ENTRADA
    PERFORM sh_puntoventa.calcular_total_cabezera('ENTRADA',NEW.entrada_id,NEW.cantidad,NEW.coste_unitario);

    RETURN NEW;
END;
$$
;


CREATE TRIGGER tg_detalle_entrada
    BEFORE INSERT
    ON sh_puntoventa.detalle_entrada
    FOR EACH ROW
    EXECUTE PROCEDURE sh_puntoventa.tg_calcular_total_entrada();




CREATE OR REPLACE FUNCTION sh_puntoventa.tg_actualizar_venta_devolucion()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    f record; -- detalle_venta%rowtype;
    producto_existencia     integer := 0;
BEGIN
	IF (OLD.estado_id = 2) THEN
        RAISE EXCEPTION 'NO SE PUEDE EDITAR ESTA VENTA';
    END IF;


    IF (NEW.estado_id = 2) THEN

        FOR f IN SELECT dv.producto_id, dv.cantidad
                FROM sh_puntoventa.detalle_venta dv
                -- INNER JOIN ventas v ON v.venta_id = dv.venta_id
                WHERE dv.venta_id = NEW.venta_id
        LOOP 
            -- raise notice '% (% CANTIDAD)', f.producto_id, f.cantidad;

            SELECT p.existencia into producto_existencia
            FROM sh_productos.productos p
            WHERE p.producto_id = f.producto_id;

            UPDATE sh_productos.productos
                SET existencia = producto_existencia + f.cantidad
            WHERE producto_id = f.producto_id;

        END LOOP;

    END IF;
    RETURN NEW;
END;
$$
;


CREATE TRIGGER tg_actualizar_venta
--   AFTER UPDATE
  BEFORE UPDATE
  ON sh_puntoventa.ventas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_puntoventa.tg_actualizar_venta_devolucion();



CREATE OR REPLACE FUNCTION sh_puntoventa.tg_calcular_total_venta()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    producto     sh_productos.productos%rowtype;
    _venta       sh_puntoventa.ventas%rowtype;
     
BEGIN

    --- PRODUCTO
    SELECT * INTO producto 
    FROM sh_productos.productos 
    WHERE producto_id = NEW.producto_id;

    IF FOUND THEN 

         IF NEW.cantidad = 0 THEN
            RAISE EXCEPTION 'la cantidad de producto es de %',NEW.cantidad;
         END IF;

         IF producto.existencia >= NEW.cantidad  THEN

            UPDATE sh_productos.productos
                SET existencia = existencia - NEW.cantidad
            WHERE producto_id = NEW.producto_id;


            NEW.precio_unitario = producto.precio;
            NEW.coste_unitario = DIV(producto.precio,1.19);

            NEW.iva = NEW.coste_unitario*0.19;
            -- NEW.coste_unitario = producto.costo;

            -- PERFORM calcular_total_cabezera('VENTA',NEW.venta_id,NEW.cantidad,producto.precio);
            
            --CALCULAMOS LA FACTURA
            SELECT 
            * into _venta
            FROM sh_puntoventa.ventas
            WHERE venta_id = NEW.venta_id;


            UPDATE sh_puntoventa.ventas
                SET total    = _venta.total + (NEW.precio_unitario * NEW.cantidad),
                    subtotal = _venta.subtotal + (NEW.coste_unitario*NEW.cantidad),
                    iva      = _venta.iva + (NEW.iva*NEW.cantidad)
            WHERE venta_id = NEW.venta_id;


        ELSE
            RAISE EXCEPTION 'No hay suficiente cantidad para la venta: %',producto.existencia;
        END IF;
        RETURN NEW;
    ELSE
            RAISE EXCEPTION 'No exite el producto';
    END IF;

END;
$$
;


CREATE TRIGGER tg_detalle_venta
  BEFORE INSERT
  ON sh_puntoventa.detalle_venta
  FOR EACH ROW
  EXECUTE PROCEDURE sh_puntoventa.tg_calcular_total_venta();




CREATE OR REPLACE FUNCTION sh_puntoventa.tg_actualizar_perdida_devolucion()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    f record; -- detalle_venta%rowtype;
    producto_existencia     integer := 0;
BEGIN
	
    IF (OLD.estado_id = 2) THEN
        RAISE EXCEPTION 'NO SE PUEDE EDITAR ESTA PERDIDA';
    END IF;

    IF (NEW.estado_id = 2) THEN

        FOR f IN SELECT dp.producto_id, dp.cantidad
                FROM sh_puntoventa.detalle_perdida dp
                WHERE dp.perdida_id = NEW.perdida_id
        LOOP 
            -- raise notice '% (% CANTIDAD)', f.producto_id, f.cantidad;

            SELECT p.existencia into producto_existencia
            FROM sh_productos.productos p
            WHERE p.producto_id = f.producto_id;

            UPDATE sh_productos.productos
                SET existencia = producto_existencia + f.cantidad
            WHERE producto_id = f.producto_id;

        END LOOP;

    END IF;
    RETURN NEW;
END;
$$
;

CREATE TRIGGER fn_actualizar_perdida
  BEFORE UPDATE
  ON sh_puntoventa.perdidas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_puntoventa.tg_actualizar_perdida_devolucion();

CREATE OR REPLACE FUNCTION sh_puntoventa.tg_calcular_total_perdida()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    producto      sh_productos.productos%rowtype;
BEGIN

    --- PRODUCTO
    SELECT
        *
        into producto
    FROM sh_productos.productos
    WHERE producto_id = NEW.producto_id;

    IF FOUND THEN 

        IF NEW.cantidad = 0 THEN
            RAISE EXCEPTION 'la cantidad de producto es de %',NEW.cantidad;
        END IF;

        IF producto.existencia >= NEW.cantidad  THEN

            --- SE ACTUALIZA LA EXISTENCIA DEL PRODCUTO
            UPDATE sh_productos.productos
                SET existencia = existencia - NEW.cantidad
            WHERE producto_id = NEW.producto_id;

            --- DETALLE_PERDIDA
            NEW.coste_unitario = producto.costo;

            -- AJUSTAMOS EL TOTAL DE LA PERDIDA EN LA TABLA PERDIDA
            PERFORM sh_puntoventa.calcular_total_cabezera('PERDIDA',NEW.perdida_id,NEW.cantidad,producto.costo);

        ELSE
            RAISE EXCEPTION 'La cantidad de la perdida no es mayor o igual a la cantidad existente del producto: %',producto.producto_nombre;
        END IF;
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'No exite el producto';
    END IF;
END;
$$
;


CREATE TRIGGER tg_detalle_perdida
  BEFORE INSERT
  ON sh_puntoventa.detalle_perdida
  FOR EACH ROW
  EXECUTE PROCEDURE sh_puntoventa.tg_calcular_total_perdida();

  CREATE OR REPLACE FUNCTION sh_productos.tg_editar_control_productos()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
BEGIN
    IF (NEW.existencia = 0) THEN
        UPDATE sh_productos.control_costo
            SET estado_id = 2
        WHERE producto_id = NEW.producto_id;
    END IF;
    RETURN NEW;
END;
$$
;


CREATE TRIGGER tg_control_productos
  BEFORE UPDATE
  ON sh_productos.productos
  FOR EACH ROW
  EXECUTE PROCEDURE sh_productos.tg_editar_control_productos();




CREATE OR REPLACE FUNCTION sh_auditoria.fn_entradas_auditoria()
RETURNS TRIGGER
LANGUAGE PLPGSQL 
AS
$$
BEGIN
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'entradas',
            row_to_json(NEW.*)
        );

    ELSEIF ( TG_OP = 'UPDATE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'entradas',
            row_to_json(OLD.*),
            row_to_json(NEW.*)
        );
        
    ELSEIF(TG_OP = 'DELETE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior
        )VALUES(
            OLD.usuario_id,
            USER,
            TG_OP,
            'entradas',
            row_to_json(OLD.*)
        );
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


CREATE TRIGGER tg_entradas_auditoria
  AFTER INSERT OR UPDATE OR DELETE
  ON sh_puntoventa.entradas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_auditoria.fn_entradas_auditoria();



CREATE OR REPLACE FUNCTION sh_auditoria.fn_perdidas_auditoria()
RETURNS TRIGGER
LANGUAGE PLPGSQL 
AS
$$
BEGIN
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'perdidas',
            row_to_json(NEW.*)
        );

    ELSEIF ( TG_OP = 'UPDATE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'perdidas',
            row_to_json(OLD.*),
            row_to_json(NEW.*)
        );
        
    ELSEIF(TG_OP = 'DELETE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior
        )VALUES(
            OLD.usuario_id,
            USER,
            TG_OP,
            'perdidas',
            row_to_json(OLD.*)
        );
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


CREATE TRIGGER tg_perdidas_auditoria
  AFTER INSERT OR UPDATE OR DELETE
  ON sh_puntoventa.perdidas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_auditoria.fn_perdidas_auditoria();



CREATE OR REPLACE FUNCTION sh_auditoria.fn_personas_auditoria()
RETURNS TRIGGER
LANGUAGE PLPGSQL 
AS
$$
BEGIN
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'personas',
            row_to_json(NEW.*)
        );

    ELSEIF ( TG_OP = 'UPDATE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'personas',
            row_to_json(OLD.*),
            row_to_json(NEW.*)
        );
        
    ELSEIF(TG_OP = 'DELETE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior
        )VALUES(
            OLD.usuario_id,
            USER,
            TG_OP,
            'personas',
            row_to_json(OLD.*)
        );
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


CREATE TRIGGER tg_personas_auditoria
  AFTER INSERT OR UPDATE OR DELETE
  ON sh_personas.personas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_auditoria.fn_personas_auditoria();



CREATE OR REPLACE FUNCTION sh_auditoria.fn_producto_auditoria()
RETURNS TRIGGER
LANGUAGE PLPGSQL 
AS
$$
BEGIN
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'productos',
            row_to_json(NEW.*)
        );

    ELSEIF ( TG_OP = 'UPDATE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'productos',
            row_to_json(OLD.*),
            row_to_json(NEW.*)
        );
        
    ELSEIF(TG_OP = 'DELETE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior
        )VALUES(
            OLD.usuario_id,
            USER,
            TG_OP,
            'productos',
            row_to_json(OLD.*)
        );
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


CREATE TRIGGER tg_producto_auditoria
  AFTER INSERT OR UPDATE OR DELETE
  ON sh_productos.productos
  FOR EACH ROW
  EXECUTE PROCEDURE sh_auditoria.fn_producto_auditoria();

  CREATE OR REPLACE FUNCTION sh_auditoria.fn_usuarios_auditoria()
RETURNS TRIGGER
LANGUAGE PLPGSQL 
AS
$$
BEGIN
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            nuevo   
        )VALUES(
            NEW.r_usuario_id,
            USER,
            TG_OP,
            'usuarios',
            row_to_json(NEW.*)
        );

    ELSEIF ( TG_OP = 'UPDATE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior,
            nuevo   
        )VALUES(
            NEW.r_usuario_id,
            USER,
            TG_OP,
            'usuarios',
            row_to_json(OLD.*),
            row_to_json(NEW.*)
        );
        
    ELSEIF(TG_OP = 'DELETE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior
        )VALUES(
            OLD.r_usuario_id,
            USER,
            TG_OP,
            'usuarios',
            row_to_json(OLD.*)
        );
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


CREATE TRIGGER tg_usuarios_auditoria
  AFTER INSERT OR UPDATE OR DELETE
  ON sh_roles.usuarios
  FOR EACH ROW
  EXECUTE PROCEDURE sh_auditoria.fn_usuarios_auditoria();




CREATE OR REPLACE FUNCTION sh_auditoria.fn_ventas_auditoria()
RETURNS TRIGGER
LANGUAGE PLPGSQL 
AS
$$
BEGIN
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'ventas',
            row_to_json(NEW.*)
        );

    ELSEIF ( TG_OP = 'UPDATE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'ventas',
            row_to_json(OLD.*),
            row_to_json(NEW.*)
        );
        
    ELSEIF(TG_OP = 'DELETE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior
        )VALUES(
            OLD.usuario_id,
            USER,
            TG_OP,
            'ventas',
            row_to_json(OLD.*)
        );
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


CREATE TRIGGER tg_ventas_auditoria
  AFTER INSERT OR UPDATE OR DELETE
  ON sh_puntoventa.ventas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_auditoria.fn_ventas_auditoria();




