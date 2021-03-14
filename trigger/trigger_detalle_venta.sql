
CREATE OR REPLACE FUNCTION sh_puntoventa.tg_calcular_total_venta()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    producto     sh_productos.productos%rowtype;
    _venta       sh_puntoventa.ventas%rowtype;
     
BEGIN

    --- PRODUCTO
    SELECT * INTO producto 
    FROM sh_productos.productos 
    WHERE producto_id = NEW.producto_id;

    IF FOUND THEN 

         IF NEW.cantidad = 0 THEN
            RAISE EXCEPTION 'la cantidad de producto es de %',NEW.cantidad;
         END IF;

         IF producto.existencia >= NEW.cantidad  THEN

            UPDATE sh_productos.productos
                SET existencia = existencia - NEW.cantidad
            WHERE producto_id = NEW.producto_id;


            NEW.precio_unitario = producto.precio;
            NEW.coste_unitario = DIV(producto.precio,1.19);

            NEW.iva = NEW.coste_unitario*0.19;
            -- NEW.coste_unitario = producto.costo;

            -- PERFORM calcular_total_cabezera('VENTA',NEW.venta_id,NEW.cantidad,producto.precio);
            
            --CALCULAMOS LA FACTURA
            SELECT 
            * into _venta
            FROM sh_puntoventa.ventas
            WHERE venta_id = NEW.venta_id;


            UPDATE sh_puntoventa.ventas
                SET total    = _venta.total + (NEW.precio_unitario * NEW.cantidad),
                    subtotal = _venta.subtotal + (NEW.coste_unitario*NEW.cantidad),
                    iva      = _venta.iva + (NEW.iva*NEW.cantidad)
            WHERE venta_id = NEW.venta_id;


        ELSE
            RAISE EXCEPTION 'No hay suficiente cantidad para la venta: %',producto.existencia;
        END IF;
        RETURN NEW;
    ELSE
            RAISE EXCEPTION 'No exite el producto';
    END IF;

END;
$$
;


CREATE TRIGGER tg_detalle_venta
  BEFORE INSERT
  ON sh_puntoventa.detalle_venta
  FOR EACH ROW
  EXECUTE PROCEDURE sh_puntoventa.tg_calcular_total_venta();