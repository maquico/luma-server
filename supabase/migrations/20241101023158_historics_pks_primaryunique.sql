alter table "public"."Historial_Fuentes" alter column "HFuente_ID" set not null;

alter table "public"."Historial_Recompensas" alter column "HRecompensa_ID" set not null;

alter table "public"."Historial_Temas" alter column "HTema_ID" set not null;

CREATE UNIQUE INDEX "Historial_Fuentes_HFuente_ID_key" ON public."Historial_Fuentes" USING btree ("HFuente_ID");

CREATE UNIQUE INDEX "Historial_Fuentes_pkey" ON public."Historial_Fuentes" USING btree ("HFuente_ID");

CREATE UNIQUE INDEX "Historial_Recompensas_HRecompensa_ID_key" ON public."Historial_Recompensas" USING btree ("HRecompensa_ID");

CREATE UNIQUE INDEX "Historial_Recompensas_pkey" ON public."Historial_Recompensas" USING btree ("HRecompensa_ID");

CREATE UNIQUE INDEX "Historial_Temas_HTema_ID_key" ON public."Historial_Temas" USING btree ("HTema_ID");

CREATE UNIQUE INDEX "Historial_Temas_pkey" ON public."Historial_Temas" USING btree ("HTema_ID");

alter table "public"."Historial_Fuentes" add constraint "Historial_Fuentes_pkey" PRIMARY KEY using index "Historial_Fuentes_pkey";

alter table "public"."Historial_Recompensas" add constraint "Historial_Recompensas_pkey" PRIMARY KEY using index "Historial_Recompensas_pkey";

alter table "public"."Historial_Temas" add constraint "Historial_Temas_pkey" PRIMARY KEY using index "Historial_Temas_pkey";

alter table "public"."Historial_Fuentes" add constraint "Historial_Fuentes_HFuente_ID_key" UNIQUE using index "Historial_Fuentes_HFuente_ID_key";

alter table "public"."Historial_Recompensas" add constraint "Historial_Recompensas_HRecompensa_ID_key" UNIQUE using index "Historial_Recompensas_HRecompensa_ID_key";

alter table "public"."Historial_Temas" add constraint "Historial_Temas_HTema_ID_key" UNIQUE using index "Historial_Temas_HTema_ID_key";
