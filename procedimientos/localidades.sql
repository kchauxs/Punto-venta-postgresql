
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
ALTER FUNCTION sh_personas.pr_editar_localidad OWNER TO admin_arbolesmiel;
-- DROP FUNCTION fun_editar_localidad
-- (   
--    _localidad_id INTEGER,
--    _localidad_nombre VARCHAR,
--    _localidad_departamento VARCHAR
-- );

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

ALTER FUNCTION sh_personas.pr_registrar_localidad OWNER TO admin_arbolesmiel;
