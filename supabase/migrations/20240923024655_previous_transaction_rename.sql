drop function if exists "public"."buy_reward"(user_id uuid, reward_id integer, reward_type text);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.buy_with_coins_transaction(user_id uuid, reward_id integer, reward_type text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    reward_price NUMERIC;
BEGIN
    -- Get the reward price based on reward type
    IF reward_type = 'font' THEN
        SELECT precio INTO reward_price FROM public."Fuentes" WHERE "Fuente_ID" = reward_id;
        
        -- Add record to Historial_Fuentes
        INSERT INTO public."Historial_Fuentes" ("Usuario_ID", "Fuente_ID", "cantidadComprada", "precioCompra")
        VALUES (user_id, reward_id, 1, reward_price);
    
    ELSIF reward_type = 'theme' THEN
        SELECT precio INTO reward_price FROM public."Temas" WHERE "Tema_ID" = reward_id;

        -- Add record to Historial_Temas
        INSERT INTO public."Historial_Temas" ("Usuario_ID", "Tema_ID", "cantidadComprada", "precioCompra")
        VALUES (user_id, reward_id, 1, reward_price);
    ELSE
        RAISE EXCEPTION 'Invalid reward type: %', reward_type;
    END IF;

    -- Reduce the user's coins
    UPDATE public."Usuarios"
    SET monedas = monedas - reward_price
    WHERE "Usuario_ID" = user_id;

    RETURN 'Transaction successful';

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error occurred: ' || SQLERRM;
END;
$function$
;


