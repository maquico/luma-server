set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  insert into public.Usuarios (
    Usuario_ID,
    nombre,
    apellido,
    correo)
  values (new.id,
   new.raw_user_meta_data ->> 'first_name',
   new.raw_user_meta_data ->> 'last_name',
   new.email);
  UPDATE auth.users
  SET raw_user_meta_data = raw_user_meta_data || '{"role": "user"}'::jsonb
  WHERE auth.users.id = new.id;
  RETURN NEW;
end;
$function$
;

create policy "user-public-insert"
on "public"."Usuarios"
as permissive
for insert
to public
with check (true);



