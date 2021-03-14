
CREATE OR REPLACE FUNCTION sh_puntoventa.tg_calcular_total_entrada()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    producto_costo      integer := 0;
    producto_existencia integer := 0;
    costo_parcial_v     integer := 0;
    costo_total_v       integer := 0;
    costo_cantidad      integer := 0;
    precio_total_v      integer := 0;
BEGIN


    -- VALIDA DATOS

    IF NEW.cantidad = 0 OR NEW.coste_unitario = 0 THEN
        RAISE EXCEPTION 'la cantidad o el coste unitario tiene valores de 0';
    END IF;

    IF NEW.cantidad < 0 OR NEW.coste_unitario < 0 THEN
        RAISE EXCEPTION 'la cantidad o el coste unitario no puede ser negativa';
    END IF;

    NEW.iva = (NEW.coste_unitario*0.19);



    -- CONSULTA EL PRODUCTO
    SELECT 
        existencia,
        costo 
        into producto_existencia,producto_costo
    FROM sh_productos.productos
    WHERE producto_id = NEW.producto_id;


    -- ACTUALIZA EL COSTO Y EL PRECIO DEL PRODUCTO
    IF (producto_costo = 0 OR producto_existencia = 0) THEN

        precio_total_v = (NEW.coste_unitario + NEW.iva) * 1.3;

        UPDATE sh_productos.productos
            SET existencia = (producto_existencia + NEW.cantidad),
                precio = precio_total_v,
                costo = (NEW.coste_unitario + NEW.iva)
        WHERE producto_id = NEW.producto_id;

        INSERT INTO sh_productos.control_costo(
                costo_sin_iva,
	            costo_iva,
                costo_total,
                precio_sin_iva,
                precio_total,
                fecha,
                producto_id,
                estado_id)
	    VALUES (
                NEW.coste_unitario,
                NEW.coste_unitario + NEW.iva,
                NEW.coste_unitario + NEW.iva,
                NEW.coste_unitario * 1.3,
                precio_total_v,
                DEFAULT,
                NEW.producto_id, 1);

    ELSE
        ------
        SELECT 
            SUM(costo_iva),
            COUNT(costo_iva) 
            into costo_parcial_v,costo_cantidad 
        FROM sh_productos.control_costo
        WHERE producto_id = NEW.producto_id AND estado_id = 1;
        

        costo_parcial_v = costo_parcial_v + (NEW.coste_unitario + NEW.iva);
        costo_cantidad = costo_cantidad + 1;
        costo_total_v = DIV(costo_parcial_v,costo_cantidad);
        precio_total_v = (costo_total_v * 1.3);
        ------
        INSERT INTO sh_productos.control_costo(
	            costo_sin_iva,
	            costo_iva,
                costo_total,
                precio_sin_iva,
                precio_total,
                fecha,
                producto_id,
                estado_id)
	    VALUES (
            NEW.coste_unitario,
            NEW.coste_unitario + NEW.iva,
            costo_total_v,
            NEW.coste_unitario*1.3,
            precio_total_v,
            CURRENT_DATE,
            NEW.producto_id, 1);
        ------
        UPDATE sh_productos.productos
            SET existencia = producto_existencia + NEW.cantidad,
                precio = precio_total_v,
                costo = costo_total_v
        WHERE producto_id = NEW.producto_id;

    END IF;

    -- CALCULA EL TOTAL DE ENTRADA
    PERFORM sh_puntoventa.calcular_total_cabezera('ENTRADA',NEW.entrada_id,NEW.cantidad,NEW.coste_unitario);

    RETURN NEW;
END;
$$
;


CREATE TRIGGER tg_detalle_entrada
    BEFORE INSERT
    ON sh_puntoventa.detalle_entrada
    FOR EACH ROW
    EXECUTE PROCEDURE sh_puntoventa.tg_calcular_total_entrada();





-- DROP TRIGGER tg_detalle_entrada
-- ON detalle_entrada;