
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

ALTER FUNCTION sh_asesoria.fn_consultar_planes_acesorias OWNER TO admin_arbolesmiel;




