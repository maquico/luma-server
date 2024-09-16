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
    
    -- Retornar los registros del proyecto y del miembro
    RETURN NEXT;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Deshacer la transacción en caso de cualquier error
        RAISE EXCEPTION 'Transaction failed: %', SQLERRM;
END;
$function$
;


