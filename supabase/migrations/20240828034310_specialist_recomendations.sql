create sequence "public"."Invitaciones_Invitacion_ID_seq";

alter table "public"."Comentarios_Tarea" drop constraint "FK_Comentarios_Tarea.Miembro_ID";

alter table "public"."Tareas" drop constraint "FK_Tareas.Miembro_ID";

alter table "public"."Miembro_Proyecto" drop constraint "Miembro_Proyecto_pkey";

drop index if exists "public"."Miembro_Proyecto_pkey";

create table "public"."Dependencias_Tarea" (
    "Tarea_ID" integer not null,
    "Dependencia_ID" integer not null,
    "fecharegistro" timestamp without time zone default CURRENT_TIMESTAMP
);


create table "public"."Invitaciones" (
    "Invitacion_ID" integer not null default nextval('"Invitaciones_Invitacion_ID_seq"'::regclass),
    "Proyecto_ID" integer not null,
    "correo" character varying(255) not null,
    "token" character varying(255) not null,
    "fechaexpiracion" timestamp without time zone not null default (CURRENT_TIMESTAMP + '1 day'::interval),
    "fecharegistro" timestamp without time zone default CURRENT_TIMESTAMP,
    "fueusado" boolean default false
);


alter table "public"."Comentarios_Tarea" drop column "Miembro_ID";

alter table "public"."Miembro_Proyecto" drop column "Miembro_ID";

alter table "public"."Miembro_Proyecto" alter column "Usuario_ID" set not null;

alter table "public"."Proyectos" add column "gastos" numeric;

alter table "public"."Proyectos" add column "presupuesto" numeric;

alter table "public"."Tareas" drop column "Miembro_ID";

alter table "public"."Tareas" drop column "esfuerzo";

alter table "public"."Tareas" add column "Usuario_ID" uuid;

alter table "public"."Tareas" add column "escritica" boolean default false;

alter table "public"."Tareas" add column "gastos" numeric;

alter table "public"."Tareas" add column "presupuesto" numeric;

alter table "public"."Tareas" add column "tiempo" integer not null;

alter sequence "public"."Invitaciones_Invitacion_ID_seq" owned by "public"."Invitaciones"."Invitacion_ID";

drop sequence if exists "public"."miembro_proyecto_miembro_id_seq";

CREATE UNIQUE INDEX "Dependencias_Tarea_pkey" ON public."Dependencias_Tarea" USING btree ("Tarea_ID", "Dependencia_ID");

CREATE UNIQUE INDEX "Invitaciones_pkey" ON public."Invitaciones" USING btree ("Invitacion_ID");

CREATE UNIQUE INDEX "Miembro_Proyecto_pkey" ON public."Miembro_Proyecto" USING btree ("Usuario_ID", "Proyecto_ID");

alter table "public"."Dependencias_Tarea" add constraint "Dependencias_Tarea_pkey" PRIMARY KEY using index "Dependencias_Tarea_pkey";

alter table "public"."Invitaciones" add constraint "Invitaciones_pkey" PRIMARY KEY using index "Invitaciones_pkey";

alter table "public"."Miembro_Proyecto" add constraint "Miembro_Proyecto_pkey" PRIMARY KEY using index "Miembro_Proyecto_pkey";

alter table "public"."Dependencias_Tarea" add constraint "Dependencias_Tarea_Dependencia_ID_fkey" FOREIGN KEY ("Dependencia_ID") REFERENCES "Tareas"("Tarea_ID") not valid;

alter table "public"."Dependencias_Tarea" validate constraint "Dependencias_Tarea_Dependencia_ID_fkey";

alter table "public"."Dependencias_Tarea" add constraint "Dependencias_Tarea_Tarea_ID_fkey" FOREIGN KEY ("Tarea_ID") REFERENCES "Tareas"("Tarea_ID") not valid;

alter table "public"."Dependencias_Tarea" validate constraint "Dependencias_Tarea_Tarea_ID_fkey";

alter table "public"."Invitaciones" add constraint "Invitaciones_Proyecto_ID_fkey" FOREIGN KEY ("Proyecto_ID") REFERENCES "Proyectos"("Proyecto_ID") not valid;

alter table "public"."Invitaciones" validate constraint "Invitaciones_Proyecto_ID_fkey";

alter table "public"."Tareas" add constraint "FK_Tareas.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") not valid;

alter table "public"."Tareas" validate constraint "FK_Tareas.Usuario_ID";

grant delete on table "public"."Dependencias_Tarea" to "anon";

grant insert on table "public"."Dependencias_Tarea" to "anon";

grant references on table "public"."Dependencias_Tarea" to "anon";

grant select on table "public"."Dependencias_Tarea" to "anon";

grant trigger on table "public"."Dependencias_Tarea" to "anon";

grant truncate on table "public"."Dependencias_Tarea" to "anon";

grant update on table "public"."Dependencias_Tarea" to "anon";

grant delete on table "public"."Dependencias_Tarea" to "authenticated";

grant insert on table "public"."Dependencias_Tarea" to "authenticated";

grant references on table "public"."Dependencias_Tarea" to "authenticated";

grant select on table "public"."Dependencias_Tarea" to "authenticated";

grant trigger on table "public"."Dependencias_Tarea" to "authenticated";

grant truncate on table "public"."Dependencias_Tarea" to "authenticated";

grant update on table "public"."Dependencias_Tarea" to "authenticated";

grant delete on table "public"."Dependencias_Tarea" to "service_role";

grant insert on table "public"."Dependencias_Tarea" to "service_role";

grant references on table "public"."Dependencias_Tarea" to "service_role";

grant select on table "public"."Dependencias_Tarea" to "service_role";

grant trigger on table "public"."Dependencias_Tarea" to "service_role";

grant truncate on table "public"."Dependencias_Tarea" to "service_role";

grant update on table "public"."Dependencias_Tarea" to "service_role";

grant delete on table "public"."Invitaciones" to "anon";

grant insert on table "public"."Invitaciones" to "anon";

grant references on table "public"."Invitaciones" to "anon";

grant select on table "public"."Invitaciones" to "anon";

grant trigger on table "public"."Invitaciones" to "anon";

grant truncate on table "public"."Invitaciones" to "anon";

grant update on table "public"."Invitaciones" to "anon";

grant delete on table "public"."Invitaciones" to "authenticated";

grant insert on table "public"."Invitaciones" to "authenticated";

grant references on table "public"."Invitaciones" to "authenticated";

grant select on table "public"."Invitaciones" to "authenticated";

grant trigger on table "public"."Invitaciones" to "authenticated";

grant truncate on table "public"."Invitaciones" to "authenticated";

grant update on table "public"."Invitaciones" to "authenticated";

grant delete on table "public"."Invitaciones" to "service_role";

grant insert on table "public"."Invitaciones" to "service_role";

grant references on table "public"."Invitaciones" to "service_role";

grant select on table "public"."Invitaciones" to "service_role";

grant trigger on table "public"."Invitaciones" to "service_role";

grant truncate on table "public"."Invitaciones" to "service_role";

grant update on table "public"."Invitaciones" to "service_role";


