set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_on_delete_usuarios_table()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Update the Usuarios table with the changes
  UPDATE public."Usuarios"
  SET
    "eliminado" = true
  WHERE "Usuario_ID" = NEW.id;  -- Assuming id is the same in both tables

  RETURN NEW;
END;
$function$
;

CREATE TRIGGER auth_user_delete_trigger
AFTER UPDATE OF deleted_at
ON auth.users
FOR EACH ROW
WHEN (
    NEW.deleted_at IS DISTINCT FROM OLD.deleted_at 
)
EXECUTE FUNCTION update_on_delete_usuarios_table();


