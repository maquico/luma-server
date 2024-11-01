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
            INSERT INTO "Insignia_Conseguida" ("Usuario_ID", "Insignia_ID")
            VALUES (NEW."Usuario_ID", badge_record."Insignia_ID");
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER trigger_check_user_badges AFTER UPDATE OF nivel, "tareasAprobadas", "totalGemas", "proyectosCreados" ON public."Usuarios" FOR EACH ROW EXECUTE FUNCTION check_user_badges();


