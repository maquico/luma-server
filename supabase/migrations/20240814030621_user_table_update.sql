-- Step 1: Drop the primary key constraint with CASCADE to remove all dependent foreign keys
ALTER TABLE "Usuarios"
  DROP CONSTRAINT "Usuarios_pkey" CASCADE;

-- Step 2: Drop the existing Usuario_ID column
ALTER TABLE "Usuarios"
  DROP COLUMN "Usuario_ID";

-- Step 3: Add the new UUID Usuario_ID column and set as the primary key
ALTER TABLE "Usuarios"
  ADD COLUMN "Usuario_ID" UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE;

-- Step 4: Add a new UUID column to dependent tables and populate it with the correct UUIDs

-- Adding a temporary UUID column in the dependent tables
ALTER TABLE "Insignia_Conseguida" ADD COLUMN "Usuario_ID_UUID" UUID;
ALTER TABLE "Historial_Temas" ADD COLUMN "Usuario_ID_UUID" UUID;
ALTER TABLE "Historial_Fuentes" ADD COLUMN "Usuario_ID_UUID" UUID;
ALTER TABLE "Historial_Recompensas" ADD COLUMN "Usuario_ID_UUID" UUID;
ALTER TABLE "Miembro_Proyecto" ADD COLUMN "Usuario_ID_UUID" UUID;

-- Populate the new UUID columns based on the current mapping of integers to UUIDs
UPDATE "Insignia_Conseguida" SET "Usuario_ID_UUID" = (SELECT "Usuario_ID" FROM "Usuarios" WHERE "Usuarios"."Usuario_ID"::text::uuid = "Insignia_Conseguida"."Usuario_ID"::text::uuid);
UPDATE "Historial_Temas" SET "Usuario_ID_UUID" = (SELECT "Usuario_ID" FROM "Usuarios" WHERE "Usuarios"."Usuario_ID"::text::uuid = "Historial_Temas"."Usuario_ID"::text::uuid);
UPDATE "Historial_Fuentes" SET "Usuario_ID_UUID" = (SELECT "Usuario_ID" FROM "Usuarios" WHERE "Usuarios"."Usuario_ID"::text::uuid = "Historial_Fuentes"."Usuario_ID"::text::uuid);
UPDATE "Historial_Recompensas" SET "Usuario_ID_UUID" = (SELECT "Usuario_ID" FROM "Usuarios" WHERE "Usuarios"."Usuario_ID"::text::uuid = "Historial_Recompensas"."Usuario_ID"::text::uuid);
UPDATE "Miembro_Proyecto" SET "Usuario_ID_UUID" = (SELECT "Usuario_ID" FROM "Usuarios" WHERE "Usuarios"."Usuario_ID"::text::uuid = "Miembro_Proyecto"."Usuario_ID"::text::uuid);

-- Step 5: Drop the old INTEGER column and rename the new UUID column
ALTER TABLE "Insignia_Conseguida" DROP COLUMN "Usuario_ID";
ALTER TABLE "Insignia_Conseguida" RENAME COLUMN "Usuario_ID_UUID" TO "Usuario_ID";

ALTER TABLE "Historial_Temas" DROP COLUMN "Usuario_ID";
ALTER TABLE "Historial_Temas" RENAME COLUMN "Usuario_ID_UUID" TO "Usuario_ID";

ALTER TABLE "Historial_Fuentes" DROP COLUMN "Usuario_ID";
ALTER TABLE "Historial_Fuentes" RENAME COLUMN "Usuario_ID_UUID" TO "Usuario_ID";

ALTER TABLE "Historial_Recompensas" DROP COLUMN "Usuario_ID";
ALTER TABLE "Historial_Recompensas" RENAME COLUMN "Usuario_ID_UUID" TO "Usuario_ID";

ALTER TABLE "Miembro_Proyecto" DROP COLUMN "Usuario_ID";
ALTER TABLE "Miembro_Proyecto" RENAME COLUMN "Usuario_ID_UUID" TO "Usuario_ID";

-- Step 6: Re-add the foreign key constraints to dependent tables
ALTER TABLE "Insignia_Conseguida"
  ADD CONSTRAINT "FK_Insignia_Conseguida.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
    REFERENCES "Usuarios" ("Usuario_ID")
    ON DELETE CASCADE;

ALTER TABLE "Historial_Temas"
  ADD CONSTRAINT "FK_Historial_Recompensas_Temas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
    REFERENCES "Usuarios" ("Usuario_ID")
    ON DELETE CASCADE;

ALTER TABLE "Historial_Fuentes"
  ADD CONSTRAINT "FK_Historial_Recompensas_Fuentes.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
    REFERENCES "Usuarios" ("Usuario_ID")
    ON DELETE CASCADE;

ALTER TABLE "Historial_Recompensas"
  ADD CONSTRAINT "FK_Historial_Recompensas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
    REFERENCES "Usuarios" ("Usuario_ID")
    ON DELETE CASCADE;

ALTER TABLE "Miembro_Proyecto"
  ADD CONSTRAINT "FK_Miembro_Proyecto.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
    REFERENCES "Usuarios" ("Usuario_ID")
    ON DELETE CASCADE;

-- Step 7: Enable Row-Level Security (RLS) on Usuarios table
ALTER TABLE "Usuarios" ENABLE ROW LEVEL SECURITY;
