alter table "public"."Proyectos" add column "Usuario_ID" uuid not null;

alter table "public"."Proyectos" add constraint "Proyectos_Usuario_ID_fkey" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."Proyectos" validate constraint "Proyectos_Usuario_ID_fkey";


