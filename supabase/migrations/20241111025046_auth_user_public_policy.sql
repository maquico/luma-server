create policy "All Public Auth Users Access"
on "auth"."users"
as permissive
for all
to public
using (true);