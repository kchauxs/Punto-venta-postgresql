CREATE VIEW sh_puntoventa.v_ver_todos_registros AS
SELECT 
    (de.cantidad * de.coste_unitario) as Total,
    de.coste_unitario,
    de.cantidad,
    de.iva,
    p.producto_nombre producto,
    per.primer_nombre || ' ' || per.primer_apellido as proveedor,
    us.username usuario,
    rl.role_nombre rol,
    en.fecha
FROM sh_puntoventa.detalle_entrada de
INNER JOIN sh_productos.productos p on p.producto_id = de.producto_id
INNER JOIN sh_puntoventa.entradas en on en.entrada_id = de.entrada_id
INNER JOIN sh_personas.personas per on per.persona_id = en.persona_id
INNER JOIN sh_roles.usuarios us on us.usuario_id = en.usuario_id
INNER JOIN sh_roles.roles rl on rl.role_id = us.role_id;
