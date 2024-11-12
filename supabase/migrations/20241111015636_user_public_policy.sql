create policy "All Public Users Access"
on "public"."Usuarios"
as permissive
for all
to public
using (true);



