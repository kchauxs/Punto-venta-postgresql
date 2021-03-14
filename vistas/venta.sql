CREATE VIEW sh_puntoventa.v_ver_todos_registros_ventas AS
SELECT 
    v.venta_id factura,
    p.producto_nombre producto,
    dv.cantidad,
    dv.precio_unitario precio,
    dv.coste_unitario costo,
    dv.iva,
    (dv.cantidad * dv.precio_unitario) as total,
    (dv.cantidad * dv.coste_unitario) as subtotal,
    (dv.cantidad * dv.iva) as total_iva,
    us.username usuario,
    rl.role_nombre rol,
    v.fecha,
    ce.nombre_estado estado
FROM sh_puntoventa.detalle_venta dv
INNER JOIN sh_productos.productos p on p.producto_id = dv.producto_id
INNER JOIN sh_puntoventa.ventas v on v.venta_id = dv.venta_id
INNER JOIN sh_roles.usuarios us on us.usuario_id = v.usuario_id
INNER JOIN sh_roles.roles rl on rl.role_id = us.role_id
INNER JOIN public.catalago_estados ce on ce.estado_id = v.estado_id;