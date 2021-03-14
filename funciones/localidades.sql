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


ALTER FUNCTION sh_personas.fn_consultar_localidades OWNER TO admin_arbolesmiel;

--SELECT * FROM sh_personas.fn_consultar_localidades();





