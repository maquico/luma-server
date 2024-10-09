set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_usuarios_table()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Only perform the update if one of the relevant fields has changed
  IF (NEW.email IS DISTINCT FROM OLD.email OR
      NEW.raw_user_meta_data->>'first_name' IS DISTINCT FROM OLD.raw_user_meta_data->>'first_name' OR
      NEW.raw_user_meta_data->>'last_name' IS DISTINCT FROM OLD.raw_user_meta_data->>'last_name' OR
      NEW.encrypted_password IS DISTINCT FROM OLD.encrypted_password) THEN

    -- Update the Usuarios table with the changes
    UPDATE public."Usuarios"
    SET
      nombre = NEW.raw_user_meta_data->>'first_name',
      apellido = NEW.raw_user_meta_data->>'last_name',
      correo = NEW.email,
      contraseña = NEW.encrypted_password,
      fechaModificacion = NOW()
    WHERE Usuario_ID = OLD.id;  -- Assuming id is the same in both tables
  END IF;

  RETURN NEW;
END;
$function$
;


