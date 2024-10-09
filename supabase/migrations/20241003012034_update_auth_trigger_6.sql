
CREATE OR REPLACE FUNCTION public.update_usuarios_table()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Skip updates if the user has been deleted (deleted_at is not null)
  IF NEW.deleted_at IS NOT NULL THEN
    RETURN NEW;
  END IF;

  -- Update the Usuarios table with the changes
  UPDATE public."Usuarios"
  SET
    "nombre" = NEW.raw_user_meta_data->>'first_name',
    "apellido" = NEW.raw_user_meta_data->>'last_name',
    "correo" = NEW.email,
    "contraseña" = NEW.encrypted_password,
    "fechaModificacion" = NOW()
  WHERE "Usuario_ID" = NEW.id;  -- Assuming id is the same in both tables

  RETURN NEW;
END;
$function$
;


