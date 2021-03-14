
CREATE OR REPLACE FUNCTION sh_asesoria.pr_registrar_asesoria
(
    _asunto         VARCHAR,
    _mensaje        TEXT,
    _persona_id     INTEGER
)
RETURNS SETOF sh_asesoria.asesorias
LANGUAGE PLPGSQL
AS
$$
BEGIN
        RETURN query INSERT INTO sh_asesoria.asesorias(
                asunto, 
                mensaje, 
                persona_id
            ) VALUES(
                _asunto,
                _mensaje,
                _persona_id
            ) RETURNING *; 

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la persona';
        END IF;       
END;
$$;

ALTER FUNCTION sh_asesoria.pr_registrar_asesoria OWNER TO admin_arbolesmiel;

-- SELECT asesoria_id FROM pr_registrar_asesoria(
--     'Deseo participar en la cosehca meloponita en mi fica',
--     'Buen dia mi fica se encuentra en la verada cristalina, tengo dos hectareas producibles.',
--     5
-- );




CREATE OR REPLACE FUNCTION sh_asesoria.pr_registrar_detalle_asesoria
(
    _asesoria_id       INTEGER,
    _plan_id           INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
BEGIN
        INSERT INTO sh_asesoria.detalle_acesorias(
                asesoria_id,
                plan_id
            ) VALUES(
                _asesoria_id,
                _plan_id
            ); 
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Error en el registro del la asesoria';
        END IF;       
END;
$$;

ALTER FUNCTION sh_asesoria.pr_registrar_detalle_asesoria OWNER TO admin_arbolesmiel;


SELECT pr_registrar_detalle_asesoria(1,1);





CREATE OR REPLACE FUNCTION sh_asesoria.pr_eliminar_asesoria
(
 _asesoria_id  INTEGER
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
  
BEGIN

        DELETE FROM sh_asesoria.detalle_acesorias
        WHERE asesoria_id = _asesoria_id;

        DELETE FROM sh_asesoria.asesorias
	    WHERE asesoria_id = _asesoria_id;   
  
END;
$$;

ALTER FUNCTION pr_eliminar_asesoria OWNER TO admin_arbolesmiel;


