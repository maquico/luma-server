alter table "public"."Invitaciones" drop column "fechaexpiracion";

alter table "public"."Invitaciones" drop column "fecharegistro";

alter table "public"."Invitaciones" drop column "fueusado";

alter table "public"."Invitaciones" add column "fechaExpiracion" timestamp without time zone not null default (CURRENT_TIMESTAMP + '1 day'::interval);

alter table "public"."Invitaciones" add column "fechaRegistro" timestamp without time zone default CURRENT_TIMESTAMP;

alter table "public"."Invitaciones" add column "fueUsado" boolean default false;


