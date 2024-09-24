alter table "public"."Usuarios" add column "eliminado" boolean not null default false;

CREATE INDEX "Usuarios_eliminado_Usuario_ID_idx" ON public."Usuarios" USING btree (eliminado, "Usuario_ID");

CREATE INDEX "Usuarios_eliminado_idx" ON public."Usuarios" USING btree (eliminado);


