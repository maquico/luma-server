set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_user_badges()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    badge_record RECORD;
    user_value INTEGER;
    has_met_criteria BOOLEAN;
BEGIN
    -- Loop over badges the user hasn't unlocked yet
    FOR badge_record IN 
        SELECT i."Insignia_ID", i."Insignia_Cat_ID", i."meta", c."campoComparativo"
        FROM "Insignias" AS i
        JOIN "Insignia_Categoria" AS c ON i."Insignia_Cat_ID" = c."Insignia_Cat_ID"
        LEFT JOIN "Insignia_Conseguida" AS ic ON ic."Insignia_ID" = i."Insignia_ID" 
                                              AND ic."Usuario_ID" = NEW."Usuario_ID"
        WHERE ic."Insignia_ID" IS NULL  -- Only select badges the user hasn't obtained
    LOOP
        -- Get the user value for the field specified in campoComparativo
        EXECUTE format('SELECT ($1.%I) FROM "Usuarios" WHERE "Usuario_ID" = $2', badge_record."campoComparativo")
        INTO user_value
        USING NEW, NEW."Usuario_ID";
        
        -- Compare the user's value with the badge meta dynamically
        has_met_criteria := (user_value >= badge_record."meta");
        
        -- If criteria met, insert into Insignia_Conseguida
        IF has_met_criteria THEN
            INSERT INTO "Insignia_Conseguida" ("Usuario_ID", "Insignia_ID", "fechaRegistro")
            VALUES (NEW."Usuario_ID", badge_record."Insignia_ID", NOW());
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.increase_user_level()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$DECLARE
    v_experience_required INTEGER := 500;
    v_new_level INTEGER;
BEGIN
    -- Calculate the new level based on the user's updated experience
    v_new_level := FLOOR(NEW."experiencia" / v_experience_required) + 1;

    -- Only update the level if the new level is higher than the old one
    IF v_new_level > OLD."nivel" THEN
        -- Update the user's level
        UPDATE public."Usuarios"
        SET "nivel" = v_new_level
        WHERE "Usuario_ID" = NEW."Usuario_ID";

        -- Increase the user's monedas by 100 coins
        UPDATE public."Usuarios"
        SET "monedas" = "monedas" + 100
        WHERE "Usuario_ID" = NEW."Usuario_ID";
    END IF;

    -- Return the updated row
    RETURN NEW;
END;$function$
;


