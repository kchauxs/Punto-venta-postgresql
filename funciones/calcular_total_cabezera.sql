CREATE OR REPLACE FUNCTION sh_puntoventa.calcular_total_cabezera
(
    cabezera VARCHAR,
    cabecera_id INT,
    cantidad INT,
    costo_precio INT
)
RETURNS VOID
LANGUAGE PLPGSQL
AS
$$
DECLARE
   cabezera_total    integer := 0;
BEGIN

    IF(cabezera = 'ENTRADA') THEN
        
        SELECT 
            total into cabezera_total
        FROM sh_puntoventa.entradas
        WHERE entrada_id = cabecera_id;

        UPDATE sh_puntoventa.entradas
            SET total = cabezera_total + (cantidad*costo_precio)
        WHERE entrada_id = cabecera_id;

    ELSEIF(cabezera = 'VENTA') THEN

        SELECT 
            total into cabezera_total
        FROM sh_puntoventa.ventas
        WHERE venta_id = cabecera_id;

        UPDATE sh_puntoventa.ventas
            SET total = cabezera_total + (cantidad*costo_precio)
        WHERE venta_id = cabecera_id;

    ELSEIF(cabezera = 'PERDIDA') THEN

       SELECT 
            total into cabezera_total
        FROM sh_puntoventa.perdidas
        WHERE perdida_id = cabecera_id;

        UPDATE sh_puntoventa.perdidas
            SET total = cabezera_total + (cantidad*costo_precio)
        WHERE perdida_id = cabecera_id;

    END IF;
 
END;
$$;
