



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
ALTER FUNCTION sh_personas.pr_editar_direccion OWNER TO admin_arbolesmiel;


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

ALTER FUNCTION sh_personas.pr_registrar_direccion OWNER TO admin_arbolesmiel;


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

ALTER FUNCTION sh_personas.pr_registrar_direccion_persona OWNER TO admin_arbolesmiel;




-- SELECT sh_personas.pr_registrar_direccion_persona(
--     '111478478',
--     'KILOMETRO 2 VIA NEIVA LAVADERO DE MOTOS',
--     'VIA NEIVA',
--     7
--     );