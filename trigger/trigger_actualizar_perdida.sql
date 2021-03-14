
CREATE OR REPLACE FUNCTION sh_puntoventa.tg_actualizar_perdida_devolucion()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    f record; -- detalle_venta%rowtype;
    producto_existencia     integer := 0;
BEGIN
	
    IF (OLD.estado_id = 2) THEN
        RAISE EXCEPTION 'NO SE PUEDE EDITAR ESTA PERDIDA';
    END IF;

    IF (NEW.estado_id = 2) THEN

        FOR f IN SELECT dp.producto_id, dp.cantidad
                FROM sh_puntoventa.detalle_perdida dp
                WHERE dp.perdida_id = NEW.perdida_id
        LOOP 
            -- raise notice '% (% CANTIDAD)', f.producto_id, f.cantidad;

            SELECT p.existencia into producto_existencia
            FROM sh_productos.productos p
            WHERE p.producto_id = f.producto_id;

            UPDATE sh_productos.productos
                SET existencia = producto_existencia + f.cantidad
            WHERE producto_id = f.producto_id;

        END LOOP;

    END IF;
    RETURN NEW;
END;
$$
;

CREATE TRIGGER fn_actualizar_perdida
  BEFORE UPDATE
  ON sh_puntoventa.perdidas
  FOR EACH ROW
  EXECUTE PROCEDURE sh_puntoventa.tg_actualizar_perdida_devolucion();
