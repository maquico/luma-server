set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_member_role(p_project_id integer, p_user_id uuid, p_role_id integer, p_request_user_id uuid)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    current_role_id INTEGER;
    leader_count INTEGER;
    request_user_role TEXT;
BEGIN
    -- Step 1: Check if the requesting user is a leader in the project
    SELECT r.nombre INTO request_user_role
    FROM public."Miembro_Proyecto" mp
    JOIN public."Roles" r ON mp."Rol_ID" = r."Rol_ID"
    WHERE mp."Usuario_ID" = p_request_user_id AND mp."Proyecto_ID" = p_project_id;

    IF request_user_role IS NULL OR request_user_role != 'Lider' THEN
        RETURN 'Error: No tienes permisos para cambiar el rol de un miembro';
    END IF;

    -- Step 2: Check the current role of the user being updated
    SELECT "Rol_ID" INTO current_role_id
    FROM public."Miembro_Proyecto"
    WHERE "Usuario_ID" = p_user_id AND "Proyecto_ID" = p_project_id;

    IF current_role_id IS NULL THEN
        RETURN 'Error: El usuario especificado no es miembro del proyecto';
    END IF;

    -- Step 3: Check if the new role is the same as the current role
    IF current_role_id = p_role_id THEN
        RETURN 'El miembro ya tiene el rol especificado, no se requiere ninguna actualización';
    END IF;

    -- Step 4: Ensure at least one leader remains if downgrading from Leader
    IF current_role_id = (SELECT "Rol_ID" FROM public."Roles" WHERE nombre = 'Lider') THEN
        SELECT COUNT(*) INTO leader_count
        FROM public."Miembro_Proyecto" mp
        WHERE mp."Proyecto_ID" = p_project_id AND mp."Rol_ID" = (SELECT "Rol_ID" FROM public."Roles" WHERE nombre = 'Lider');

        IF leader_count <= 1 THEN
            RETURN 'Error: No puedes eliminar al último líder del proyecto';
        END IF;
    END IF;

    -- Step 5: Update the user's role in the project
    UPDATE public."Miembro_Proyecto"
    SET "Rol_ID" = p_role_id,
        "fechaModificacion" = NOW()
    WHERE "Usuario_ID" = p_user_id AND "Proyecto_ID" = p_project_id;

    RETURN 'El rol del miembro fue actualizado exitosamente';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: Ocurrió un problema al intentar actualizar el rol del miembro';
END;
$function$
;


