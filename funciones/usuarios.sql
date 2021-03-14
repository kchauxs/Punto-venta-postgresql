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

-- ALTER FUNCTION sh_roles.autenticacion OWNER TO admin_arbolesmiel;

-- SELECT * FROM sh_roles.autenticacion('sandramora','1234');


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

ALTER FUNCTION sh_roles.fn_validar_usuario_auth OWNER TO admin_arbolesmiel;

-- SELECT * FROM sh_roles.fn_validar_usuario_auth('sandramora');




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

ALTER FUNCTION sh_roles.fn_consultar_usuario OWNER TO admin_arbolesmiel;




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

ALTER FUNCTION sh_roles.fn_consultar_usuarios OWNER TO admin_arbolesmiel;

-- select * from sh_roles.fn_consultar_usuarios();

