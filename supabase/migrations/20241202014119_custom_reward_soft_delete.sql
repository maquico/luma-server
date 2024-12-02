alter table "public"."Recompensas" add column "eliminado" boolean not null default false;

CREATE INDEX "Recompensas_eliminado_idx" ON public."Recompensas" USING btree (eliminado);

