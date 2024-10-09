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
    raw_user_meta_data,
    '{first_name}',
    to_jsonb(NEW.nombre),  -- Set first_name to the updated nombre
    true  -- Create the key if it does not exist
  ),
  raw_user_meta_data = jsonb_set(
    raw_user_meta_data,
    '{last_name}',
    to_jsonb(NEW.apellido),  -- Set last_name to the updated apellido
    true  -- Create the key if it does not exist
  )
  WHERE id = NEW."Usuario_ID";  -- Assuming Usuario_ID corresponds to id in auth.users

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE TRIGGER trigger_update_auth_metadata
AFTER UPDATE OF nombre, apellido  -- Trigger on both columns
ON public."Usuarios"  -- The table to monitor
FOR EACH ROW
EXECUTE FUNCTION update_auth_metadata();


