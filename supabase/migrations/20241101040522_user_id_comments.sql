alter table "public"."Comentarios_Tarea" add column "Usuario_ID" uuid not null;

alter table "public"."Comentarios_Tarea" add constraint "Comentarios_Tarea_Usuario_ID_fkey" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") not valid;

alter table "public"."Comentarios_Tarea" validate constraint "Comentarios_Tarea_Usuario_ID_fkey";


