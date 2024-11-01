create sequence "public"."historial_fuentes_hfuente_id_seq";

create sequence "public"."historial_recompensas_hrecompensa_id_seq";

create sequence "public"."historial_temas_htema_id_seq";

alter table "public"."Historial_Fuentes" alter column "HFuente_ID" set default nextval('historial_fuentes_hfuente_id_seq'::regclass);

alter table "public"."Historial_Recompensas" alter column "HRecompensa_ID" set default nextval('historial_recompensas_hrecompensa_id_seq'::regclass);

alter table "public"."Historial_Temas" alter column "HTema_ID" set default nextval('historial_temas_htema_id_seq'::regclass);




