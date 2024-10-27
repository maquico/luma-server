drop policy "Users can update own profile." on "public"."Usuarios";

alter table "public"."Insignias" alter column "foto" set not null;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.approve_task(p_user_id uuid, p_task_id integer, p_new_status_id integer, p_project_id integer, p_task_claimed boolean, p_experience integer, p_gems integer)
 RETURNS TABLE(user_id uuid, task_id integer, new_status_id integer, experience integer, gems integer)
 LANGUAGE plpgsql
AS $function$ 
BEGIN
    
    IF NOT p_task_claimed THEN

        -- Award gems to the project member
        UPDATE public."Miembro_Proyecto"
        SET "gemas" = "gemas" + p_gems
        WHERE "Usuario_ID" = p_user_id AND "Proyecto_ID" = p_project_id;

        -- Award experience and gems to the task's user
        UPDATE public."Usuarios"
        SET "experiencia" = "experiencia" + p_experience, 
            "totalGemas" = "totalGemas" + p_gems,
            "tareasAprobadas" = "tareasAprobadas" + 1
        WHERE "Usuario_ID" = p_user_id;

        -- Award 25% of the experience to project leaders
        UPDATE public."Usuarios" u
        SET "experiencia" = "experiencia" + (p_experience * 0.25)
        FROM public."Miembro_Proyecto" mp
        WHERE mp."Usuario_ID" = u."Usuario_ID" 
          AND mp."Proyecto_ID" = p_project_id 
          AND mp."Rol_ID" = 2; --Leader role id
    END IF;

    -- Update the task status and mark it as claimed
    UPDATE public."Tareas"
    SET "Estado_Tarea_ID" = p_new_status_id, 
        "fueReclamada" = TRUE, 
        "fechaModificacion" = NOW()
    WHERE "Tarea_ID" = p_task_id;

    -- Return the relevant information
    RETURN QUERY 
    SELECT p_user_id, p_task_id, p_new_status_id, p_experience, p_gems;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error occurred: %', SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increase_user_level()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_experience_required INTEGER := 500;
    v_new_level INTEGER;
BEGIN
    -- Calculate the new level based on the user's updated experience
    v_new_level := FLOOR(NEW."experiencia" / v_experience_required) + 1;

    -- Only update the level if the new level is higher than the old one
    IF v_new_level > OLD."nivel" THEN
        UPDATE public."Usuarios"
        SET "nivel" = v_new_level
        WHERE "Usuario_ID" = NEW."Usuario_ID";
    END IF;

    -- Return the updated row
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.buy_with_coins_transaction(p_user_id uuid, p_reward_id integer, p_reward_type text)
 RETURNS TABLE(user_id uuid, reward_type text, reward_id integer, reward_name text, previous_coins numeric, final_coins numeric)
 LANGUAGE plpgsql
AS $function$
DECLARE
    reward_price NUMERIC;
    reward_name TEXT;
    user_coins NUMERIC;
BEGIN
    -- Get the user's current coin amount
    SELECT "monedas" INTO user_coins FROM public."Usuarios" WHERE "Usuario_ID" = p_user_id;

    -- Get the reward price and name based on reward type
    IF p_reward_type = 'font' THEN
        SELECT precio, nombre INTO reward_price, reward_name FROM public."Fuentes" WHERE "Fuente_ID" = p_reward_id;
        
        -- Add record to Historial_Fuentes
        INSERT INTO public."Historial_Fuentes" ("Usuario_ID", "Fuente_ID", "cantidadComprada", "precioCompra")
        VALUES (p_user_id, p_reward_id, 1, reward_price);
    
    ELSIF p_reward_type = 'theme' THEN
        SELECT "precio", "nombre" INTO reward_price, reward_name FROM public."Temas" WHERE "Tema_ID" = p_reward_id;

        -- Add record to Historial_Temas
        INSERT INTO public."Historial_Temas" ("Usuario_ID", "Tema_ID", "cantidadComprada", "precioCompra")
        VALUES (p_user_id, p_reward_id, 1, reward_price);
    ELSE
        RAISE EXCEPTION 'Invalid reward type: %', p_reward_type;
    END IF;

    -- Reduce the user's coins
    UPDATE public."Usuarios"
    SET "monedas" = user_coins - reward_price
    WHERE "Usuario_ID" = p_user_id;

    -- Return the required information
    RETURN QUERY 
    SELECT 
        p_user_id AS "user_id", 
        p_reward_type AS "reward_type", 
        p_reward_id AS "reward_id", 
        reward_name AS "reward_name", 
        user_coins AS "previous_coins", 
        user_coins - reward_price AS "final_coins";

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error occurred: %', SQLERRM;
END;
$function$
;

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
      to_jsonb(NEW."nombre"),  -- New value for first_name
      true                 -- Create the key if it does not exist
    ),
    '{last_name}',         -- Path to update last_name
    to_jsonb(NEW."apellido"),  -- New value for last_name
    true                  -- Create the key if it does not exist
  )
  WHERE id = NEW."Usuario_ID";  -- Assuming Usuario_ID corresponds to id in auth.users

  RETURN NEW;
END;
$function$
;

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

create policy "insert-auth-admin"
on "public"."Usuarios"
as permissive
for insert
to supabase_auth_admin
with check (true);


create policy "select-auth-admin"
on "public"."Usuarios"
as permissive
for select
to supabase_auth_admin
using (true);


create policy "update-auth-admin"
on "public"."Usuarios"
as permissive
for update
to supabase_auth_admin
using (true)
with check (true);


create policy "Users can update own profile."
on "public"."Usuarios"
as permissive
for update
to public
using (true);


CREATE TRIGGER trigger_increase_user_level AFTER UPDATE OF experiencia ON public."Usuarios" FOR EACH ROW WHEN ((new.experiencia > old.experiencia)) EXECUTE FUNCTION increase_user_level();


