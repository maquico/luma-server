alter table "public"."Comentarios_Tarea" drop constraint "FK_Comentarios_Tarea.Tarea_ID";

alter table "public"."Comentarios_Tarea" add constraint "Comentarios_Tarea_Tarea_ID_fkey" FOREIGN KEY ("Tarea_ID") REFERENCES "Tareas"("Tarea_ID") ON DELETE CASCADE not valid;

alter table "public"."Comentarios_Tarea" validate constraint "Comentarios_Tarea_Tarea_ID_fkey";
