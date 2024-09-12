set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.update_confirmed_status()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Check if email_confirmed_at changed from NULL to a non-NULL value
    IF OLD.email_confirmed_at IS NULL AND NEW.email_confirmed_at IS NOT NULL THEN
        -- Update the confirmed field in the Usuarios table
        UPDATE public."Usuarios"
        SET confirmado = true
        WHERE correo = NEW.email; -- Assuming email matches between auth.users and public.Usuarios
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER email_confirmed_trigger
AFTER UPDATE OF email_confirmed_at ON auth.users
FOR EACH ROW
EXECUTE FUNCTION update_confirmed_status();

