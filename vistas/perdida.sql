CREATE VIEW sh_puntoventa.v_ver_todos_perdidas AS
SELECT 
    (dp.cantidad * dp.coste_unitario) as Total,
    dp.coste_unitario,
    dp.cantidad,
    p.producto_nombre producto,
    us.username usuario,
    rl.role_nombre rol,
    pr.fecha
FROM sh_puntoventa.detalle_perdida dp
INNER JOIN sh_productos.productos p on p.producto_id = dp.producto_id
INNER JOIN sh_puntoventa.perdidas pr on pr.perdida_id = dp.perdida_id
INNER JOIN sh_roles.usuarios us on us.usuario_id = pr.usuario_id
INNER JOIN sh_roles.roles rl on rl.role_id = us.role_id;
