set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.delete_member_from_project(p_project_id integer, p_user_id uuid, p_request_user_id uuid)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    user_role TEXT;
    leader_count INTEGER;
    member_count INTEGER;
    request_user_role TEXT;
BEGIN
    -- Paso 1: Verificar si el usuario que hace el request es líder del proyecto
    SELECT r.nombre INTO request_user_role
    FROM public."Miembro_Proyecto" mp
    JOIN public."Roles" r ON mp."Rol_ID" = r."Rol_ID"
    WHERE mp."Usuario_ID" = p_request_user_id AND mp."Proyecto_ID" = p_project_id;

    IF request_user_role IS NULL OR request_user_role != 'Lider' THEN
        RETURN 'Error: No tienes permisos para eliminar miembros del proyecto';
    END IF;

    -- Paso 2: Verificar si el usuario que se quiere eliminar existe en el proyecto
    SELECT r.nombre INTO user_role
    FROM public."Miembro_Proyecto" mp
    JOIN public."Roles" r ON mp."Rol_ID" = r."Rol_ID"
    WHERE mp."Usuario_ID" = p_user_id AND mp."Proyecto_ID" = p_project_id;

    IF user_role IS NULL THEN
        RETURN 'Error: El usuario especificado no es miembro del proyecto';
    END IF;

    -- Paso 3: Asegurarse de que no sea el único líder en el proyecto
    IF user_role = 'Lider' THEN
        SELECT COUNT(*) INTO leader_count
        FROM public."Miembro_Proyecto" mp
        WHERE mp."Proyecto_ID" = p_project_id AND mp."Rol_ID" = (SELECT "Rol_ID" FROM public."Roles" WHERE nombre = 'Lider');

        IF leader_count <= 1 THEN
            RETURN 'Error: No puedes eliminar al único líder del proyecto';
        END IF;
    END IF;

    -- Paso 4: Asegurarse de que no sea el único miembro del proyecto
    SELECT COUNT(*) INTO member_count
    FROM public."Miembro_Proyecto"
    WHERE "Proyecto_ID" = p_project_id;

    IF member_count <= 1 THEN
        RETURN 'Error: No se puede eliminar al único miembro del proyecto';
    END IF;

    -- Paso 5: Eliminar al miembro del proyecto
    DELETE FROM public."Miembro_Proyecto"
    WHERE "Usuario_ID" = p_user_id AND "Proyecto_ID" = p_project_id;

    RETURN 'El miembro fue eliminado exitosamente del proyecto';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: Ocurrió un problema al intentar eliminar al miembro del proyecto';
END;
$function$
;

