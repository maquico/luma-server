set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_user_projects(user_id uuid)
 RETURNS TABLE(proyecto_id integer, nombre character varying, descripcion text, fecharegistro timestamp without time zone, members json, creator text, currentusergems integer, queryinguserrole character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        p."Proyecto_ID",
        p."nombre",
        p."descripcion",
        p."fechaRegistro",
        json_agg(u."nombre" || ' ' || u."apellido") AS "members",
        (SELECT u2."nombre" || ' ' || u2."apellido"
         FROM "Usuarios" u2
         WHERE u2."Usuario_ID" = p."Usuario_ID") AS "creator",
        COALESCE(
            (SELECT mp."gemas"
             FROM "Miembro_Proyecto" mp
             WHERE mp."Proyecto_ID" = p."Proyecto_ID"
               AND mp."Usuario_ID" = user_id), 0) AS "currentUserGems",
        (SELECT r."nombre"
         FROM "Roles" r
         INNER JOIN "Miembro_Proyecto" mp ON mp."Rol_ID" = r."Rol_ID"
         WHERE mp."Proyecto_ID" = p."Proyecto_ID"
           AND mp."Usuario_ID" = user_id) AS "queryingUserRole"
    FROM "Proyectos" p
    LEFT JOIN "Miembro_Proyecto" mp ON p."Proyecto_ID" = mp."Proyecto_ID"
    LEFT JOIN "Usuarios" u ON u."Usuario_ID" = mp."Usuario_ID"
    WHERE EXISTS (
        SELECT 1
        FROM "Miembro_Proyecto" mp2
        WHERE mp2."Proyecto_ID" = p."Proyecto_ID"
          AND mp2."Usuario_ID" = user_id
    )
    AND p."eliminado" = false
    GROUP BY p."Proyecto_ID", p."nombre", p."descripcion", p."fechaRegistro", p."Usuario_ID";
END;
$function$
;


