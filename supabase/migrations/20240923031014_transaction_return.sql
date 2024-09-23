drop function if exists "public"."buy_with_coins_transaction"(user_id uuid, reward_id integer, reward_type text);

set check_function_bodies = off;

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


