alter table "public"."Dependencias_Tarea" drop constraint "Dependencias_Tarea_pkey";

drop index if exists "public"."Dependencias_Tarea_pkey";

alter table "public"."Dependencias_Tarea" add column "Dependencia_Tarea_ID" integer generated by default as identity not null;

CREATE UNIQUE INDEX "Dependencias_Tarea_Dependencia_Tarea_ID_key" ON public."Dependencias_Tarea" USING btree ("Dependencia_Tarea_ID");

CREATE UNIQUE INDEX "UNIQUE_Tarea_Dependencia" ON public."Dependencias_Tarea" USING btree ("Tarea_ID", "Dependencia_ID");

CREATE UNIQUE INDEX "Usuarios_Usuario_ID_key" ON public."Usuarios" USING btree ("Usuario_ID");

CREATE UNIQUE INDEX "Dependencias_Tarea_pkey" ON public."Dependencias_Tarea" USING btree ("Dependencia_Tarea_ID");

alter table "public"."Dependencias_Tarea" add constraint "Dependencias_Tarea_pkey" PRIMARY KEY using index "Dependencias_Tarea_pkey";

alter table "public"."Dependencias_Tarea" add constraint "Dependencias_Tarea_Dependencia_Tarea_ID_key" UNIQUE using index "Dependencias_Tarea_Dependencia_Tarea_ID_key";

alter table "public"."Dependencias_Tarea" add constraint "UNIQUE_Tarea_Dependencia" UNIQUE using index "UNIQUE_Tarea_Dependencia";

alter table "public"."Insignia_Conseguida" add constraint "UNIQUE_Usuario_Insignia" UNIQUE using index "UNIQUE_Usuario_Insignia";

alter table "public"."Miembro_Proyecto" add constraint "UNIQUE_Usuario_Proyecto" UNIQUE using index "UNIQUE_Usuario_Proyecto";

alter table "public"."Usuarios" add constraint "Usuarios_Usuario_ID_key" UNIQUE using index "Usuarios_Usuario_ID_key";