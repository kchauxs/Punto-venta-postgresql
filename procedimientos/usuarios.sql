


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

ALTER FUNCTION sh_roles.pr_registrar_usuario OWNER TO admin_arbolesmiel;

