set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_project_with_creator(project_name text, project_description text, creator_user_id uuid)
 RETURNS TABLE(proyecto_id integer, proyecto_nombre text, proyecto_descripcion text, miembro_usuario_id uuid, miembro_rol_id integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Insertar el proyecto en la tabla Proyectos y obtener el ID del nuevo proyecto
    INSERT INTO public."Proyectos" (nombre, descripcion, "Usuario_ID")
    VALUES (project_name, project_description, creator_user_id)
    RETURNING "Proyecto_ID", nombre, descripcion INTO proyecto_id, proyecto_nombre, proyecto_descripcion;

    -- Insertar el creador en la tabla Miembro_Proyecto con Rol_ID = 1
    INSERT INTO public."Miembro_Proyecto" ("Usuario_ID", "Proyecto_ID", "Rol_ID")
    VALUES (creator_user_id, proyecto_id, 2)
    RETURNING "Usuario_ID", "Rol_ID" INTO miembro_usuario_id, miembro_rol_id;
    
        -- Increment the proyectosCreados attribute for the user
    UPDATE public."Usuarios"
    SET "proyectosCreados" = COALESCE("proyectosCreados", 0) + 1
    WHERE "Usuario_ID" = creator_user_id;
    
    -- Retornar los registros del proyecto y del miembro
    RETURN NEXT;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Deshacer la transacción en caso de cualquier error
        RAISE EXCEPTION 'Transaction failed: %', SQLERRM;
END;
$function$
;

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

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public."Usuarios" ("Usuario_ID", nombre, apellido, correo, "contraseña")
  values (new.id, new.raw_user_meta_data->>'first_name', new.raw_user_meta_data->>'last_name', new.email, new.encrypted_password);
  return new;
end;
$function$
;


