alter table "public"."Insignia_Conseguida" alter column "Usuario_ID" set not null;

CREATE UNIQUE INDEX "Insignia_Conseguida_pkey" ON public."Insignia_Conseguida" USING btree ("Insignia_ID", "Usuario_ID");

alter table "public"."Insignia_Conseguida" add constraint "Insignia_Conseguida_pkey" PRIMARY KEY using index "Insignia_Conseguida_pkey";


