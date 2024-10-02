CREATE OR REPLACE FUNCTION public.update_usuarios_table()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
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
