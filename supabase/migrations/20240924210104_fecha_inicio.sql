alter table "public"."Tareas" drop column "fechaFinal";

alter table "public"."Tareas" add column "fechaFin" timestamp without time zone;

alter table "public"."Tareas" add column "fechaInicio" timestamp without time zone;




