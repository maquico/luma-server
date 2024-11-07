alter table "public"."Insignia_Conseguida" enable row level security;

create policy "Obtained Badge Anonimous Access"
on "public"."Insignia_Conseguida"
as permissive
for all
to public
using (true);



