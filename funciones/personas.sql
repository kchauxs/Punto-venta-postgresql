----------------------------------------------------------
--          CONSULTA PERSONAS
----------------------------------------------------------

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

ALTER FUNCTION sh_personas.fn_consultar_personas OWNER TO admin_arbolesmiel;
-- select * from fn_consultar_personas();


----------------------------------------------------------
--          CONSULTA PERSONA ESPECIFICA
----------------------------------------------------------

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

ALTER FUNCTION sh_personas.fn_consultar_persona_especifica OWNER TO admin_arbolesmiel;
-- DROP FUNCTION consultar_producto_especifico(_producto_id smallint);
-- select * from sh_personas.fn_consultar_persona_especifica('522');





