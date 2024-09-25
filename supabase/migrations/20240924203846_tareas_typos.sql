alter table "public"."Tareas" drop constraint "FK_Tareas.Estado_tarea_ID";

alter table "public"."Estados_Tarea" drop constraint "Estados_Tarea_pkey";

drop index if exists "public"."Estados_Tarea_pkey";

alter table "public"."Estados_Tarea" drop column "Estado_tarea_ID";

create sequence "public"."estados_tarea_estado_tarea_id_seq";

alter table "public"."Estados_Tarea" add column "Estado_Tarea_ID" integer not null default nextval('estados_tarea_estado_tarea_id_seq'::regclass);

alter sequence "public"."estados_tarea_estado_tarea_id_seq" owned by "public"."Estados_Tarea"."Estado_Tarea_ID";

alter table "public"."Tareas" drop column "Estado_tarea_ID";

alter table "public"."Tareas" drop column "escritica";

alter table "public"."Tareas" add column "Estado_Tarea_ID" integer not null default 1;

alter table "public"."Tareas" add column "esCritica" boolean default false;



CREATE UNIQUE INDEX "Estados_Tarea_pkey" ON public."Estados_Tarea" USING btree ("Estado_Tarea_ID");

alter table "public"."Estados_Tarea" add constraint "Estados_Tarea_pkey" PRIMARY KEY using index "Estados_Tarea_pkey";

alter table "public"."Tareas" add constraint "Tareas_Estado_Tarea_ID_fkey" FOREIGN KEY ("Estado_Tarea_ID") REFERENCES "Estados_Tarea"("Estado_Tarea_ID") not valid;

alter table "public"."Tareas" validate constraint "Tareas_Estado_Tarea_ID_fkey";




