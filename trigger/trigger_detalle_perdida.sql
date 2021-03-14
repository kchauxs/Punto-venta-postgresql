

CREATE OR REPLACE FUNCTION sh_puntoventa.tg_calcular_total_perdida()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    producto      sh_productos.productos%rowtype;
BEGIN

    --- PRODUCTO
    SELECT
        *
        into producto
    FROM sh_productos.productos
    WHERE producto_id = NEW.producto_id;

    IF FOUND THEN 

        IF NEW.cantidad = 0 THEN
            RAISE EXCEPTION 'la cantidad de producto es de %',NEW.cantidad;
        END IF;

        IF producto.existencia >= NEW.cantidad  THEN

            --- SE ACTUALIZA LA EXISTENCIA DEL PRODCUTO
            UPDATE sh_productos.productos
                SET existencia = existencia - NEW.cantidad
            WHERE producto_id = NEW.producto_id;

            --- DETALLE_PERDIDA
            NEW.coste_unitario = producto.costo;

            -- AJUSTAMOS EL TOTAL DE LA PERDIDA EN LA TABLA PERDIDA
            PERFORM sh_puntoventa.calcular_total_cabezera('PERDIDA',NEW.perdida_id,NEW.cantidad,producto.costo);

        ELSE
            RAISE EXCEPTION 'La cantidad de la perdida no es mayor o igual a la cantidad existente del producto: %',producto.producto_nombre;
        END IF;
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'No exite el producto';
    END IF;
END;
$$
;


CREATE TRIGGER tg_detalle_perdida
  BEFORE INSERT
  ON sh_puntoventa.detalle_perdida
  FOR EACH ROW
  EXECUTE PROCEDURE sh_puntoventa.tg_calcular_total_perdida();