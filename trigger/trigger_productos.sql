CREATE OR REPLACE FUNCTION sh_productos.tg_editar_control_productos()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
BEGIN
    IF (NEW.existencia = 0) THEN
        UPDATE sh_productos.control_costo
            SET estado_id = 2
        WHERE producto_id = NEW.producto_id;
    END IF;
    RETURN NEW;
END;
$$
;


CREATE TRIGGER tg_control_productos
  BEFORE UPDATE
  ON sh_productos.productos
  FOR EACH ROW
  EXECUTE PROCEDURE sh_productos.tg_editar_control_productos();



   