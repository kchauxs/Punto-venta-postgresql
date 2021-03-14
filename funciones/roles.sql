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