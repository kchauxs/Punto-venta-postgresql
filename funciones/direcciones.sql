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

ALTER FUNCTION sh_personas.fn_consultar_direcciones_persona OWNER TO admin_arbolesmiel;

-- DROP FUNCTION fn_consultar_direcciones_persona(_persona_id INTEGER);
-- select * from fn_consultar_direcciones_persona(7);

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

ALTER FUNCTION sh_personas.fn_consultar_direcciones OWNER TO admin_arbolesmiel;
-- DROP FUNCTION fn_consultar_direcciones();
-- select * from sh_personas.fn_consultar_direcciones();
-- SELECT documento, concat(nombres, ' ', apellidos) as datos, nacimiento FROM jugador


