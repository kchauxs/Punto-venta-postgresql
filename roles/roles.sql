

-- Crear roles de inicio de sesión
CREATE ROLE servidor 
LOGIN 
PASSWORD 'passserver';


GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_auditoria"
TO servidor;
GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_asesoria"
TO servidor;
GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_personas"
TO servidor;
GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_productos"
TO servidor;
GRANT ALL
ON ALL TABLES
IN SCHEMA "sh_puntoventa"
TO servidor;
ON ALL TABLES
IN SCHEMA "sh_roles"
TO servidor;

ON ALL TABLES
IN SCHEMA "public"
TO servidor;


--  public        | postgres
--  sh_asesoria   | admin_arbolesmiel
--  sh_auditoria  | admin_arbolesmiel
--  sh_personas   | admin_arbolesmiel
--  sh_productos  | admin_arbolesmiel
--  sh_puntoventa | admin_arbolesmiel
--  sh_roles      | admin_arbolesmiel 


CREATE ROLE desarrollador 
LOGIN 
PASSWORD 'passdesarrollador';

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_asesoria"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_personas"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_productos"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_puntoventa"
TO desarrollador;

GRANT SELECT,INSERT,UPDATE
ON ALL TABLES
IN SCHEMA "sh_asesoria"
TO desarrollador;

GRANT SELECT
ON ALL TABLES
IN SCHEMA "public"
TO desarrollador;

GRANT SELECT
ON ALL TABLES
IN SCHEMA "sh_auditoria"
TO desarrollador;