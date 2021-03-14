
CREATE OR REPLACE FUNCTION sh_auditoria.fn_perdidas_auditoria()
RETURNS TRIGGER
LANGUAGE PLPGSQL 
AS
$$
BEGIN
    IF(TG_OP = 'INSERT') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'perdidas',
            row_to_json(NEW.*)
        );

    ELSEIF ( TG_OP = 'UPDATE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior,
            nuevo   
        )VALUES(
            NEW.usuario_id,
            USER,
            TG_OP,
            'perdidas',
            row_to_json(OLD.*),
            row_to_json(NEW.*)
        );
        
    ELSEIF(TG_OP = 'DELETE') THEN
        INSERT INTO sh_auditoria.auditorias(
            usuario_id,
            usuario_db,
            accion,
            tabla,
            anterior
        )VALUES(
            OLD.usuario_id,
            USER,
            TG_OP,
            'perdidas',
            row_to_json(OLD.*)
        );
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$;


CREATE TRIGGER tg_perdidas_auditoria
  AFTER INSERT OR UPDATE OR DELETE
  ON sh_puntoventa.perdidas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_auditoria.fn_perdidas_auditoria();