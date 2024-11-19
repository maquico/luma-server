alter table "public"."Proyectos" drop constraint "Proyectos_Usuario_ID_fkey";

alter table "public"."Proyectos" add constraint "Proyectos_Usuario_ID_fkey" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") ON UPDATE CASCADE not valid;

alter table "public"."Proyectos" validate constraint "Proyectos_Usuario_ID_fkey";
