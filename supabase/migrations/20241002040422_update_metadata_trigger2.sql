set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_auth_metadata()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Update the user metadata in the auth table
  UPDATE auth."users"
  SET raw_user_meta_data = jsonb_set(
    jsonb_set(
      raw_user_meta_data,  -- Start with the existing JSONB data
      '{first_name}',      -- Path to update first_name
      to_jsonb(NEW.nombre),  -- New value for first_name
      true                 -- Create the key if it does not exist
    ),
    '{last_name}',         -- Path to update last_name
    to_jsonb(NEW.apellido),  -- New value for last_name
    true                  -- Create the key if it does not exist
  )
  WHERE id = NEW."Usuario_ID";  -- Assuming Usuario_ID corresponds to id in auth.users

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_usuarios_table()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Update the Usuarios table with the changes
  UPDATE public.Usuarios
  SET
    nombre = NEW.raw_user_meta_data->>'first_name',
    apellido = NEW.raw_user_meta_data->>'last_name',
    correo = NEW.email,
    contraseña = NEW.encrypted_password,
    fechaModificacion = NOW()
  WHERE Usuario_ID = NEW.id;  -- Assuming id is the same in both tables

  RETURN NEW;
END;
$function$
;


