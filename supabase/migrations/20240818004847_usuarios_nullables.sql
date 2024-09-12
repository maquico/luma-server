alter table "public"."Usuarios" alter column "Idioma_ID" drop not null;

alter table "public"."Usuarios" alter column "foto" drop not null;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public."Usuarios" ("Usuario_ID", nombre, apellido, correo)
  values (new.id, new.raw_user_meta_data->>'first_name', new.raw_user_meta_data->>'last_name', new.email);
  return new;
end;
$function$
;

create policy "Public profiles are viewable by everyone."
on "public"."Usuarios"
as permissive
for select
to public
using (true);


create policy "Users can insert their own profile."
on "public"."Usuarios"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = "Usuario_ID"));


create policy "Users can update own profile."
on "public"."Usuarios"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = "Usuario_ID"));



