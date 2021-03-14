
-----------------------------------------------------------

----------------------------------------------------------
--          REGISTRAR PERSONA ESPECIFICA
----------------------------------------------------------


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

ALTER FUNCTION pr_registrar_personas OWNER TO admin_arbolesmiel;


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
ALTER FUNCTION sh_personas.pr_editar_persona OWNER TO admin_arbolesmiel;


----------------------------------------------------------
--          REGISTRAR PERSONA CON DOMICILIO
----------------------------------------------------------


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
-- SELECT fn_registrar_persona_direccion(
--     '1117541522',
--     'JOSE',
--     'EUSTASIO',
--     'RIVERA',
--     'GOMEZ',
--     'josegomez@gmail.com',
--     '3214558794',
--     1,
--     'Carrera 8 # 7-94 Barrio La Estrella',
--     'la atalaya',
--     7
--     );


