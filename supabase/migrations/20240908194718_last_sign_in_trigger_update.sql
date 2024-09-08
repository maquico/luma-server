set check_function_bodies = off;

DROP TRIGGER IF EXISTS trigger_update_last_sign_in ON auth.users;

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

CREATE TRIGGER trigger_update_last_sign_in
AFTER UPDATE OF last_sign_in_at
ON auth.users
FOR EACH ROW
WHEN (NEW.last_sign_in_at IS DISTINCT FROM OLD.last_sign_in_at)
EXECUTE FUNCTION update_last_sign_in();

