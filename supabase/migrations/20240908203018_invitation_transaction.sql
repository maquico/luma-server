set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_invitation_transaction(invitation_id integer, user_id uuid, project_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Update the invitation to mark it as used
    UPDATE public."Invitaciones"
    SET "fueUsado" = TRUE
    WHERE "Invitacion_ID" = invitation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invitation not found or already used';
    END IF;

    -- Add user to the project members
    INSERT INTO public."Miembro_Proyecto" ("Usuario_ID", "Proyecto_ID", "Rol_ID")
    VALUES (user_id, project_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        -- Raise an error and stop the transaction in case of any failure
        RAISE EXCEPTION 'Transaction failed: %', SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_last_sign_in()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Update the ultimoInicioSesion field in public.Usuarios
  UPDATE public."Usuarios"
  SET "ultimoInicioSesion" = NEW.last_sign_in_at
  WHERE "Usuario_ID" = NEW.id;

  RETURN NEW;
END;
$function$
;


