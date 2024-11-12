--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: approve_task(uuid, integer, integer, integer, boolean, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.approve_task(p_user_id uuid, p_task_id integer, p_new_status_id integer, p_project_id integer, p_task_claimed boolean, p_experience integer, p_gems integer) RETURNS TABLE(user_id uuid, task_id integer, new_status_id integer, experience integer, gems integer)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
    
    IF NOT p_task_claimed THEN

        -- Award gems to the project member
        UPDATE public."Miembro_Proyecto"
        SET "gemas" = "gemas" + p_gems
        WHERE "Usuario_ID" = p_user_id AND "Proyecto_ID" = p_project_id;

        -- Award experience and gems to the task's user
        UPDATE public."Usuarios"
        SET "experiencia" = "experiencia" + p_experience, 
            "totalGemas" = "totalGemas" + p_gems,
            "tareasAprobadas" = "tareasAprobadas" + 1
        WHERE "Usuario_ID" = p_user_id;

        -- Award 25% of the experience to project leaders
        UPDATE public."Usuarios" u
        SET "experiencia" = "experiencia" + (p_experience * 0.25)
        FROM public."Miembro_Proyecto" mp
        WHERE mp."Usuario_ID" = u."Usuario_ID" 
          AND mp."Proyecto_ID" = p_project_id 
          AND mp."Rol_ID" = 2; --Leader role id
    END IF;

    -- Update the task status and mark it as claimed
    UPDATE public."Tareas"
    SET "Estado_Tarea_ID" = p_new_status_id, 
        "fueReclamada" = TRUE, 
        "fechaModificacion" = NOW()
    WHERE "Tarea_ID" = p_task_id;

    -- Return the relevant information
    RETURN QUERY 
    SELECT p_user_id, p_task_id, p_new_status_id, p_experience, p_gems;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error occurred: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.approve_task(p_user_id uuid, p_task_id integer, p_new_status_id integer, p_project_id integer, p_task_claimed boolean, p_experience integer, p_gems integer) OWNER TO postgres;

--
-- Name: buy_with_coins_transaction(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buy_with_coins_transaction(p_user_id uuid, p_reward_id integer, p_reward_type text) RETURNS TABLE(user_id uuid, reward_type text, reward_id integer, reward_name text, previous_coins numeric, final_coins numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    reward_price NUMERIC;
    reward_name TEXT;
    user_coins NUMERIC;
BEGIN
    -- Get the user's current coin amount
    SELECT "monedas" INTO user_coins FROM public."Usuarios" WHERE "Usuario_ID" = p_user_id;

    -- Get the reward price and name based on reward type
    IF p_reward_type = 'font' THEN
        SELECT precio, nombre INTO reward_price, reward_name FROM public."Fuentes" WHERE "Fuente_ID" = p_reward_id;
        
        -- Add record to Historial_Fuentes
        INSERT INTO public."Historial_Fuentes" ("Usuario_ID", "Fuente_ID", "cantidadComprada", "precioCompra")
        VALUES (p_user_id, p_reward_id, 1, reward_price);
    
    ELSIF p_reward_type = 'theme' THEN
        SELECT "precio", "nombre" INTO reward_price, reward_name FROM public."Temas" WHERE "Tema_ID" = p_reward_id;

        -- Add record to Historial_Temas
        INSERT INTO public."Historial_Temas" ("Usuario_ID", "Tema_ID", "cantidadComprada", "precioCompra")
        VALUES (p_user_id, p_reward_id, 1, reward_price);
    ELSE
        RAISE EXCEPTION 'Invalid reward type: %', p_reward_type;
    END IF;

    -- Reduce the user's coins
    UPDATE public."Usuarios"
    SET "monedas" = user_coins - reward_price
    WHERE "Usuario_ID" = p_user_id;

    -- Return the required information
    RETURN QUERY 
    SELECT 
        p_user_id AS "user_id", 
        p_reward_type AS "reward_type", 
        p_reward_id AS "reward_id", 
        reward_name AS "reward_name", 
        user_coins AS "previous_coins", 
        user_coins - reward_price AS "final_coins";

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error occurred: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.buy_with_coins_transaction(p_user_id uuid, p_reward_id integer, p_reward_type text) OWNER TO postgres;

--
-- Name: buy_with_gems_transaction(uuid, integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buy_with_gems_transaction(p_usuario_id uuid, p_recompensa_id integer, p_precio numeric) RETURNS TABLE(recompensa_id integer, usuario_id uuid, gemas_restantes integer, total_compras_actualizadas integer, cantidad_comprada integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insertar el historial de recompensas
    INSERT INTO "Historial_Recompensas" (
        "Recompensa_ID", "Usuario_ID", "cantidadComprada", "precioCompra", "fechaRegistro"
    ) 
    VALUES (
        p_recompensa_id, p_usuario_id, 1, p_precio, NOW()
    );

    -- Actualizar el total de compras en la tabla de Recompensas
    UPDATE "Recompensas"
    SET "totalCompras" = "totalCompras" + 1
    WHERE "Recompensa_ID" = p_recompensa_id;

    -- Descontar las gemas del usuario en la tabla Miembro_Proyecto
    UPDATE "Miembro_Proyecto"
    SET gemas = gemas - p_precio
    WHERE "Usuario_ID" = p_usuario_id
    AND "Proyecto_ID" = (SELECT "Proyecto_ID" FROM "Recompensas" WHERE "Recompensa_ID" = p_recompensa_id);

    -- Retornar los datos actualizados
    RETURN QUERY
    SELECT 
        r."Recompensa_ID",
        mp."Usuario_ID",
        mp.gemas,
        r."totalCompras",
        hr."cantidadComprada"
    FROM 
        "Recompensas" r
        JOIN "Miembro_Proyecto" mp ON mp."Proyecto_ID" = r."Proyecto_ID"
        JOIN "Historial_Recompensas" hr ON hr."Usuario_ID" = mp."Usuario_ID"
    WHERE 
        r."Recompensa_ID" = p_recompensa_id
        AND hr."Usuario_ID" = p_usuario_id
    ORDER BY hr."fechaRegistro" DESC
    LIMIT 1;

END;
$$;


ALTER FUNCTION public.buy_with_gems_transaction(p_usuario_id uuid, p_recompensa_id integer, p_precio numeric) OWNER TO postgres;

--
-- Name: check_user_badges(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_user_badges() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
DECLARE
    badge_record RECORD;
    user_value INTEGER;
    has_met_criteria BOOLEAN;
BEGIN
    -- Loop over badges the user hasn't unlocked yet
    FOR badge_record IN 
        SELECT i."Insignia_ID", i."Insignia_Cat_ID", i."meta", c."campoComparativo"
        FROM "Insignias" AS i
        JOIN "Insignia_Categoria" AS c ON i."Insignia_Cat_ID" = c."Insignia_Cat_ID"
        LEFT JOIN "Insignia_Conseguida" AS ic ON ic."Insignia_ID" = i."Insignia_ID" 
                                              AND ic."Usuario_ID" = NEW."Usuario_ID"
        WHERE ic."Insignia_ID" IS NULL  -- Only select badges the user hasn't obtained
    LOOP
        -- Get the user value for the field specified in campoComparativo
        EXECUTE format('SELECT ($1.%I) FROM "Usuarios" WHERE "Usuario_ID" = $2', badge_record."campoComparativo")
        INTO user_value
        USING NEW, NEW."Usuario_ID";
        
        -- Compare the user's value with the badge meta dynamically
        has_met_criteria := (user_value >= badge_record."meta");
        
        -- If criteria met, insert into Insignia_Conseguida
        IF has_met_criteria THEN
            INSERT INTO "Insignia_Conseguida" ("Usuario_ID", "Insignia_ID")
            VALUES (NEW."Usuario_ID", badge_record."Insignia_ID");
        END IF;
    END LOOP;
    
    RETURN NEW;
END;
$_$;


ALTER FUNCTION public.check_user_badges() OWNER TO postgres;

--
-- Name: create_project_with_creator(text, text, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_project_with_creator(project_name text, project_description text, creator_user_id uuid) RETURNS TABLE(proyecto_id integer, proyecto_nombre text, proyecto_descripcion text, miembro_usuario_id uuid, miembro_rol_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insertar el proyecto en la tabla Proyectos y obtener el ID del nuevo proyecto
    INSERT INTO public."Proyectos" (nombre, descripcion, "Usuario_ID")
    VALUES (project_name, project_description, creator_user_id)
    RETURNING "Proyecto_ID", nombre, descripcion INTO proyecto_id, proyecto_nombre, proyecto_descripcion;

    -- Insertar el creador en la tabla Miembro_Proyecto con Rol_ID = 1
    INSERT INTO public."Miembro_Proyecto" ("Usuario_ID", "Proyecto_ID", "Rol_ID")
    VALUES (creator_user_id, proyecto_id, 2)
    RETURNING "Usuario_ID", "Rol_ID" INTO miembro_usuario_id, miembro_rol_id;
    
    -- Retornar los registros del proyecto y del miembro
    RETURN NEXT;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Deshacer la transacción en caso de cualquier error
        RAISE EXCEPTION 'Transaction failed: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.create_project_with_creator(project_name text, project_description text, creator_user_id uuid) OWNER TO postgres;

--
-- Name: handle_invitation_transaction(integer, uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_invitation_transaction(invitation_id integer, user_id uuid, project_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update the invitation to mark it as used
    UPDATE public."Invitaciones"
    SET "fueUsado" = TRUE
    WHERE "Invitacion_ID" = invitation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invitation not found or already used';
    END IF;

    -- Add user to the project members
    INSERT INTO public."Miembro_Proyecto" ("Usuario_ID", "Proyecto_ID", "Rol_ID")
    VALUES (user_id, project_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        -- Raise an error and stop the transaction in case of any failure
        RAISE EXCEPTION 'Transaction failed: %', SQLERRM;
END;
$$;


ALTER FUNCTION public.handle_invitation_transaction(invitation_id integer, user_id uuid, project_id integer) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
begin
  insert into public."Usuarios" ("Usuario_ID", nombre, apellido, correo)
  values (new.id, new.raw_user_meta_data->>'first_name', new.raw_user_meta_data->>'last_name', new.email);
  return new;
end;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: increase_user_level(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increase_user_level() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$DECLARE
    v_experience_required INTEGER := 500;
    v_new_level INTEGER;
BEGIN
    -- Calculate the new level based on the user's updated experience
    v_new_level := FLOOR(NEW."experiencia" / v_experience_required) + 1;

    -- Only update the level if the new level is higher than the old one
    IF v_new_level > OLD."nivel" THEN
        -- Update the user's level
        UPDATE public."Usuarios"
        SET "nivel" = v_new_level
        WHERE "Usuario_ID" = NEW."Usuario_ID";

        -- Increase the user's monedas by 100 coins
        UPDATE public."Usuarios"
        SET "monedas" = "monedas" + 100
        WHERE "Usuario_ID" = NEW."Usuario_ID";
    END IF;

    -- Return the updated row
    RETURN NEW;
END;$$;


ALTER FUNCTION public.increase_user_level() OWNER TO postgres;

--
-- Name: update_auth_metadata(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_auth_metadata() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  -- Update the user metadata in the auth table
  UPDATE auth."users"
  SET raw_user_meta_data = jsonb_set(
    jsonb_set(
      raw_user_meta_data,  -- Start with the existing JSONB data
      '{first_name}',      -- Path to update first_name
      to_jsonb(NEW."nombre"),  -- New value for first_name
      true                 -- Create the key if it does not exist
    ),
    '{last_name}',         -- Path to update last_name
    to_jsonb(NEW."apellido"),  -- New value for last_name
    true                  -- Create the key if it does not exist
  )
  WHERE id = NEW."Usuario_ID";  -- Assuming Usuario_ID corresponds to id in auth.users

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_auth_metadata() OWNER TO postgres;

--
-- Name: update_last_sign_in(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_last_sign_in() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  -- Update the ultimoInicioSesion field in public.Usuarios
  UPDATE public."Usuarios"
  SET "ultimoInicioSesion" = NEW.last_sign_in_at
  WHERE "Usuario_ID" = NEW.id;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_last_sign_in() OWNER TO postgres;

--
-- Name: update_on_delete_usuarios_table(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_on_delete_usuarios_table() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  -- Update the Usuarios table with the changes
  UPDATE public."Usuarios"
  SET
    "eliminado" = true
  WHERE "Usuario_ID" = NEW.id;  -- Assuming id is the same in both tables

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_on_delete_usuarios_table() OWNER TO postgres;

--
-- Name: update_usuarios_table(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_usuarios_table() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  -- Skip updates if the user has been deleted (deleted_at is not null)
  IF NEW.deleted_at IS NOT NULL THEN
    RETURN NEW;
  END IF;

  -- Update the Usuarios table with the changes
  UPDATE public."Usuarios"
  SET
    "nombre" = NEW.raw_user_meta_data->>'first_name',
    "apellido" = NEW.raw_user_meta_data->>'last_name',
    "correo" = NEW.email,
    "contraseña" = NEW.encrypted_password,
    "fechaModificacion" = NOW()
  WHERE "Usuario_ID" = NEW.id;  -- Assuming id is the same in both tables

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_usuarios_table() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: Comentarios_Tarea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Comentarios_Tarea" (
    "Comentario_ID" integer NOT NULL,
    "Tarea_ID" integer NOT NULL,
    contenido text NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    "Usuario_ID" uuid NOT NULL
);


ALTER TABLE public."Comentarios_Tarea" OWNER TO postgres;

--
-- Name: Dependencias_Tarea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Dependencias_Tarea" (
    "Tarea_ID" integer NOT NULL,
    "Dependencia_ID" integer NOT NULL,
    fecharegistro timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public."Dependencias_Tarea" OWNER TO postgres;

--
-- Name: Estados_Tarea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Estados_Tarea" (
    nombre character varying(100) NOT NULL,
    descripcion text,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    "Estado_Tarea_ID" integer NOT NULL
);


ALTER TABLE public."Estados_Tarea" OWNER TO postgres;

--
-- Name: Fuentes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Fuentes" (
    "Fuente_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    precio numeric(10,2) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone
);


ALTER TABLE public."Fuentes" OWNER TO postgres;

--
-- Name: historial_fuentes_hfuente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_fuentes_hfuente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_fuentes_hfuente_id_seq OWNER TO postgres;

--
-- Name: Historial_Fuentes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Historial_Fuentes" (
    "Fuente_ID" integer NOT NULL,
    "cantidadComprada" integer NOT NULL,
    "precioCompra" numeric(10,2) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "Usuario_ID" uuid NOT NULL,
    "HFuente_ID" bigint DEFAULT nextval('public.historial_fuentes_hfuente_id_seq'::regclass) NOT NULL
);


ALTER TABLE public."Historial_Fuentes" OWNER TO postgres;

--
-- Name: historial_recompensas_hrecompensa_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_recompensas_hrecompensa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_recompensas_hrecompensa_id_seq OWNER TO postgres;

--
-- Name: Historial_Recompensas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Historial_Recompensas" (
    "Recompensa_ID" integer NOT NULL,
    "cantidadComprada" integer NOT NULL,
    "precioCompra" numeric(10,2) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "Usuario_ID" uuid NOT NULL,
    "HRecompensa_ID" bigint DEFAULT nextval('public.historial_recompensas_hrecompensa_id_seq'::regclass) NOT NULL
);


ALTER TABLE public."Historial_Recompensas" OWNER TO postgres;

--
-- Name: historial_temas_htema_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historial_temas_htema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historial_temas_htema_id_seq OWNER TO postgres;

--
-- Name: Historial_Temas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Historial_Temas" (
    "Tema_ID" integer NOT NULL,
    "cantidadComprada" integer NOT NULL,
    "precioCompra" numeric(10,2) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "Usuario_ID" uuid NOT NULL,
    "HTema_ID" bigint DEFAULT nextval('public.historial_temas_htema_id_seq'::regclass) NOT NULL
);


ALTER TABLE public."Historial_Temas" OWNER TO postgres;

--
-- Name: Iconos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Iconos" (
    "Icono_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone
);


ALTER TABLE public."Iconos" OWNER TO postgres;

--
-- Name: Idiomas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Idiomas" (
    "Idioma_ID" integer NOT NULL,
    nombre character varying(50) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone
);


ALTER TABLE public."Idiomas" OWNER TO postgres;

--
-- Name: Insignia_Categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Insignia_Categoria" (
    "Insignia_Cat_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    "campoComparativo" character varying(50) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone
);


ALTER TABLE public."Insignia_Categoria" OWNER TO postgres;

--
-- Name: Insignia_Conseguida; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Insignia_Conseguida" (
    "Insignia_ID" integer NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "Usuario_ID" uuid NOT NULL
);


ALTER TABLE public."Insignia_Conseguida" OWNER TO postgres;

--
-- Name: Insignias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Insignias" (
    "Insignia_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text NOT NULL,
    "Insignia_Cat_ID" integer NOT NULL,
    meta integer NOT NULL,
    foto text,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone
);


ALTER TABLE public."Insignias" OWNER TO postgres;

--
-- Name: Invitaciones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Invitaciones" (
    "Invitacion_ID" integer NOT NULL,
    "Proyecto_ID" integer NOT NULL,
    correo character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    "fechaExpiracion" timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '1 day'::interval) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "fueUsado" boolean DEFAULT false
);


ALTER TABLE public."Invitaciones" OWNER TO postgres;

--
-- Name: Invitaciones_Invitacion_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Invitaciones_Invitacion_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Invitaciones_Invitacion_ID_seq" OWNER TO postgres;

--
-- Name: Invitaciones_Invitacion_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Invitaciones_Invitacion_ID_seq" OWNED BY public."Invitaciones"."Invitacion_ID";


--
-- Name: Miembro_Proyecto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Miembro_Proyecto" (
    "Proyecto_ID" integer NOT NULL,
    "Rol_ID" integer DEFAULT 1 NOT NULL,
    gemas integer DEFAULT 0 NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    "Usuario_ID" uuid NOT NULL
);


ALTER TABLE public."Miembro_Proyecto" OWNER TO postgres;

--
-- Name: Preguntas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Preguntas" (
    "Pregunta_ID" integer NOT NULL,
    titulo character varying(200) NOT NULL,
    contenido text NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone
);


ALTER TABLE public."Preguntas" OWNER TO postgres;

--
-- Name: Proyectos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Proyectos" (
    "Proyecto_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    gastos numeric,
    presupuesto numeric,
    "Usuario_ID" uuid NOT NULL,
    eliminado boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Proyectos" OWNER TO postgres;

--
-- Name: Recompensas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Recompensas" (
    "Recompensa_ID" integer NOT NULL,
    "Proyecto_ID" integer NOT NULL,
    "Icono_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    precio numeric(10,2) NOT NULL,
    cantidad integer NOT NULL,
    limite integer NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    "totalCompras" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."Recompensas" OWNER TO postgres;

--
-- Name: Roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Roles" (
    "Rol_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone
);


ALTER TABLE public."Roles" OWNER TO postgres;

--
-- Name: Tareas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Tareas" (
    "Tarea_ID" integer NOT NULL,
    "Proyecto_ID" integer NOT NULL,
    etiquetas character varying(84),
    nombre character varying(100) NOT NULL,
    descripcion text,
    prioridad integer NOT NULL,
    "valorGemas" integer NOT NULL,
    "fueReclamada" boolean DEFAULT false NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    "Usuario_ID" uuid,
    gastos numeric,
    presupuesto numeric,
    tiempo integer NOT NULL,
    "Estado_Tarea_ID" integer DEFAULT 1 NOT NULL,
    "esCritica" boolean DEFAULT false,
    "fechaFin" timestamp without time zone,
    "fechaInicio" timestamp without time zone,
    "puntosExperiencia" integer NOT NULL
);


ALTER TABLE public."Tareas" OWNER TO postgres;

--
-- Name: Temas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Temas" (
    "Tema_ID" integer NOT NULL,
    nombre character varying(100) NOT NULL,
    precio numeric(10,2) NOT NULL,
    "accentHex" character varying(7) NOT NULL,
    "primaryHex" character varying(7) NOT NULL,
    "secondaryHex" character varying(7) NOT NULL,
    "backgroundHex" character varying(7) NOT NULL,
    "textHex" character varying(7) NOT NULL,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    fuente character varying NOT NULL
);


ALTER TABLE public."Temas" OWNER TO postgres;

--
-- Name: Usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Usuarios" (
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    correo character varying(100) NOT NULL,
    experiencia integer DEFAULT 0 NOT NULL,
    nivel integer DEFAULT 1 NOT NULL,
    monedas integer DEFAULT 0 NOT NULL,
    "totalGemas" integer DEFAULT 0 NOT NULL,
    "tareasAprobadas" integer DEFAULT 0 NOT NULL,
    "proyectosCreados" integer DEFAULT 0 NOT NULL,
    foto text,
    "fechaRegistro" timestamp without time zone DEFAULT now() NOT NULL,
    "fechaModificacion" timestamp without time zone,
    "esAdmin" boolean DEFAULT false NOT NULL,
    "Idioma_ID" integer,
    "contraseña" character varying(255),
    "Usuario_ID" uuid NOT NULL,
    confirmado boolean DEFAULT false NOT NULL,
    "ultimoInicioSesion" timestamp without time zone,
    eliminado boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Usuarios" OWNER TO postgres;

--
-- Name: comentarios_tarea_comentario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comentarios_tarea_comentario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comentarios_tarea_comentario_id_seq OWNER TO postgres;

--
-- Name: comentarios_tarea_comentario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comentarios_tarea_comentario_id_seq OWNED BY public."Comentarios_Tarea"."Comentario_ID";


--
-- Name: estados_tarea_estado_tarea_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.estados_tarea_estado_tarea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.estados_tarea_estado_tarea_id_seq OWNER TO postgres;

--
-- Name: estados_tarea_estado_tarea_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.estados_tarea_estado_tarea_id_seq OWNED BY public."Estados_Tarea"."Estado_Tarea_ID";


--
-- Name: fuentes_fuente_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fuentes_fuente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fuentes_fuente_id_seq OWNER TO postgres;

--
-- Name: fuentes_fuente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fuentes_fuente_id_seq OWNED BY public."Fuentes"."Fuente_ID";


--
-- Name: iconos_icono_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.iconos_icono_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.iconos_icono_id_seq OWNER TO postgres;

--
-- Name: iconos_icono_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.iconos_icono_id_seq OWNED BY public."Iconos"."Icono_ID";


--
-- Name: idiomas_idioma_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.idiomas_idioma_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.idiomas_idioma_id_seq OWNER TO postgres;

--
-- Name: idiomas_idioma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.idiomas_idioma_id_seq OWNED BY public."Idiomas"."Idioma_ID";


--
-- Name: insignia_categoria_insignia_cat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.insignia_categoria_insignia_cat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.insignia_categoria_insignia_cat_id_seq OWNER TO postgres;

--
-- Name: insignia_categoria_insignia_cat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.insignia_categoria_insignia_cat_id_seq OWNED BY public."Insignia_Categoria"."Insignia_Cat_ID";


--
-- Name: insignias_insignia_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.insignias_insignia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.insignias_insignia_id_seq OWNER TO postgres;

--
-- Name: insignias_insignia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.insignias_insignia_id_seq OWNED BY public."Insignias"."Insignia_ID";


--
-- Name: preguntas_pregunta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.preguntas_pregunta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.preguntas_pregunta_id_seq OWNER TO postgres;

--
-- Name: preguntas_pregunta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.preguntas_pregunta_id_seq OWNED BY public."Preguntas"."Pregunta_ID";


--
-- Name: proyectos_proyecto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.proyectos_proyecto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.proyectos_proyecto_id_seq OWNER TO postgres;

--
-- Name: proyectos_proyecto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.proyectos_proyecto_id_seq OWNED BY public."Proyectos"."Proyecto_ID";


--
-- Name: recompensas_recompensa_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.recompensas_recompensa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recompensas_recompensa_id_seq OWNER TO postgres;

--
-- Name: recompensas_recompensa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.recompensas_recompensa_id_seq OWNED BY public."Recompensas"."Recompensa_ID";


--
-- Name: roles_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_rol_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_rol_id_seq OWNER TO postgres;

--
-- Name: roles_rol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_rol_id_seq OWNED BY public."Roles"."Rol_ID";


--
-- Name: tareas_tarea_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tareas_tarea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tareas_tarea_id_seq OWNER TO postgres;

--
-- Name: tareas_tarea_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tareas_tarea_id_seq OWNED BY public."Tareas"."Tarea_ID";


--
-- Name: temas_tema_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.temas_tema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.temas_tema_id_seq OWNER TO postgres;

--
-- Name: temas_tema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.temas_tema_id_seq OWNED BY public."Temas"."Tema_ID";


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: Comentarios_Tarea Comentario_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Comentarios_Tarea" ALTER COLUMN "Comentario_ID" SET DEFAULT nextval('public.comentarios_tarea_comentario_id_seq'::regclass);


--
-- Name: Estados_Tarea Estado_Tarea_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Estados_Tarea" ALTER COLUMN "Estado_Tarea_ID" SET DEFAULT nextval('public.estados_tarea_estado_tarea_id_seq'::regclass);


--
-- Name: Fuentes Fuente_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fuentes" ALTER COLUMN "Fuente_ID" SET DEFAULT nextval('public.fuentes_fuente_id_seq'::regclass);


--
-- Name: Iconos Icono_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Iconos" ALTER COLUMN "Icono_ID" SET DEFAULT nextval('public.iconos_icono_id_seq'::regclass);


--
-- Name: Idiomas Idioma_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Idiomas" ALTER COLUMN "Idioma_ID" SET DEFAULT nextval('public.idiomas_idioma_id_seq'::regclass);


--
-- Name: Insignia_Categoria Insignia_Cat_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignia_Categoria" ALTER COLUMN "Insignia_Cat_ID" SET DEFAULT nextval('public.insignia_categoria_insignia_cat_id_seq'::regclass);


--
-- Name: Insignias Insignia_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignias" ALTER COLUMN "Insignia_ID" SET DEFAULT nextval('public.insignias_insignia_id_seq'::regclass);


--
-- Name: Invitaciones Invitacion_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invitaciones" ALTER COLUMN "Invitacion_ID" SET DEFAULT nextval('public."Invitaciones_Invitacion_ID_seq"'::regclass);


--
-- Name: Preguntas Pregunta_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Preguntas" ALTER COLUMN "Pregunta_ID" SET DEFAULT nextval('public.preguntas_pregunta_id_seq'::regclass);


--
-- Name: Proyectos Proyecto_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Proyectos" ALTER COLUMN "Proyecto_ID" SET DEFAULT nextval('public.proyectos_proyecto_id_seq'::regclass);


--
-- Name: Recompensas Recompensa_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recompensas" ALTER COLUMN "Recompensa_ID" SET DEFAULT nextval('public.recompensas_recompensa_id_seq'::regclass);


--
-- Name: Roles Rol_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Roles" ALTER COLUMN "Rol_ID" SET DEFAULT nextval('public.roles_rol_id_seq'::regclass);


--
-- Name: Tareas Tarea_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tareas" ALTER COLUMN "Tarea_ID" SET DEFAULT nextval('public.tareas_tarea_id_seq'::regclass);


--
-- Name: Temas Tema_ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Temas" ALTER COLUMN "Tema_ID" SET DEFAULT nextval('public.temas_tema_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	97fe87cf-ac5a-4473-915d-e48b47377317	{"action":"user_confirmation_requested","actor_id":"108b654a-4925-415f-9e36-0b43f8096f2b","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-08-18 02:37:18.346453+00	
00000000-0000-0000-0000-000000000000	afdf2bd9-eba4-4211-97f9-bfb0a576435f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"108b654a-4925-415f-9e36-0b43f8096f2b","user_phone":""}}	2024-08-18 03:44:24.651782+00	
00000000-0000-0000-0000-000000000000	90a74609-ee8d-4a06-80e3-7e9abcfb58a6	{"action":"user_confirmation_requested","actor_id":"a9741a03-f027-432b-864a-4a121b4cf65f","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-08-18 03:45:07.584856+00	
00000000-0000-0000-0000-000000000000	b8b38be4-a228-471e-8fc8-64ccc3faae5c	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rolbikurbaez@gmail.com","user_id":"9173a0f9-c01f-4a2d-8e9a-c27b4ec79408","user_phone":""}}	2024-08-18 19:26:51.974343+00	
00000000-0000-0000-0000-000000000000	5a4696d9-3b2e-477d-8656-b8c8d51edb84	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rolbikurbaez@gmail.com","user_id":"9173a0f9-c01f-4a2d-8e9a-c27b4ec79408","user_phone":""}}	2024-08-18 19:35:32.307736+00	
00000000-0000-0000-0000-000000000000	94dd80f5-cdd8-44e8-95f7-9d111129e8f0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"a9741a03-f027-432b-864a-4a121b4cf65f","user_phone":""}}	2024-08-18 21:26:05.475073+00	
00000000-0000-0000-0000-000000000000	1f13ee23-ab2a-405b-ac5f-27fce5bbe13d	{"action":"user_confirmation_requested","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-08-18 21:58:58.752962+00	
00000000-0000-0000-0000-000000000000	436dc3bd-64b5-4632-8a58-1ecc583de82d	{"action":"user_signedup","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"team"}	2024-08-18 21:59:24.179457+00	
00000000-0000-0000-0000-000000000000	efa548af-4a7e-433c-9e7c-ea04f112f266	{"action":"login","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-18 22:00:21.94333+00	
00000000-0000-0000-0000-000000000000	e7ce57f7-08d3-4adb-8f12-3958eadd01ac	{"action":"login","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-18 22:02:20.128883+00	
00000000-0000-0000-0000-000000000000	5618c7f3-4350-4c6a-8cbd-50ff8aacf2ed	{"action":"login","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-18 22:06:36.467718+00	
00000000-0000-0000-0000-000000000000	22a16592-0e1e-4781-92fe-85aed1c66e1c	{"action":"user_confirmation_requested","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-08-21 01:38:05.503637+00	
00000000-0000-0000-0000-000000000000	786f130f-2147-457c-b9f6-7bc0a63fc418	{"action":"user_signedup","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"team"}	2024-08-21 01:42:57.674491+00	
00000000-0000-0000-0000-000000000000	5dc8e178-061c-458a-b460-b52af244be4d	{"action":"login","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-21 01:54:17.149741+00	
00000000-0000-0000-0000-000000000000	68896989-8708-437a-85f4-256d3f73cb1f	{"action":"login","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-21 01:54:48.910064+00	
00000000-0000-0000-0000-000000000000	83259b5c-eb55-458e-b00d-261fec75ad86	{"action":"login","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-21 01:55:32.916143+00	
00000000-0000-0000-0000-000000000000	991d668a-60aa-4c30-9372-a8dbb0e1c781	{"action":"login","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-21 01:56:21.370737+00	
00000000-0000-0000-0000-000000000000	eaa2deae-c37a-49f9-9bb3-a9de6c779d9a	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-21 03:50:35.1233+00	
00000000-0000-0000-0000-000000000000	c278582c-9d32-4342-b58e-536e36fa8059	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-21 03:50:35.125133+00	
00000000-0000-0000-0000-000000000000	d850fbb8-eeed-4dca-acdc-315dbc19c6a6	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 01:02:46.418575+00	
00000000-0000-0000-0000-000000000000	c72bfbc0-e96f-46d9-ba8f-f852bd88ae9e	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 01:02:46.423351+00	
00000000-0000-0000-0000-000000000000	2ea3b55f-26a6-4033-8d4b-ac27be9c0cfb	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 02:00:48.93916+00	
00000000-0000-0000-0000-000000000000	087226ef-3f81-4778-a9f5-041f87bee4a8	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 02:00:48.941713+00	
00000000-0000-0000-0000-000000000000	b1fcb2a8-0c72-493b-8bb8-693a84673059	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 02:58:52.140081+00	
00000000-0000-0000-0000-000000000000	f5b8681d-efaf-4db2-9e99-27ae438901af	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 02:58:52.143239+00	
00000000-0000-0000-0000-000000000000	06ea0425-3be0-4d44-82e1-e1baf4efa585	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 03:56:55.248763+00	
00000000-0000-0000-0000-000000000000	0ac6bf94-1be9-42ef-8b4b-d1b8cf964475	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 03:56:55.250006+00	
00000000-0000-0000-0000-000000000000	a7a860e3-2469-411d-9bf6-7d6db5cb7df9	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 22:51:06.122601+00	
00000000-0000-0000-0000-000000000000	194d8ee5-29f1-4a2e-98eb-969dee912ab6	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 22:51:06.126435+00	
00000000-0000-0000-0000-000000000000	459cf7b2-591f-42b1-85c7-7ed43d5daadf	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 23:49:23.323263+00	
00000000-0000-0000-0000-000000000000	7be14501-4fc3-4c3e-9e23-b939ee29f28b	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-22 23:49:23.326605+00	
00000000-0000-0000-0000-000000000000	6ac3ca58-297c-490d-918b-9add404b512e	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 00:47:36.56771+00	
00000000-0000-0000-0000-000000000000	9d6ff69c-03e8-4a2b-bea4-9f44531452ed	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 00:47:36.572433+00	
00000000-0000-0000-0000-000000000000	03d11131-eec3-4894-986e-83c63cb3b1a4	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 01:45:45.710931+00	
00000000-0000-0000-0000-000000000000	c1c7c36c-5b75-4bf7-bb27-378caaa37204	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 01:45:45.712188+00	
00000000-0000-0000-0000-000000000000	1740f5ef-2a0e-415a-a275-5375c124d566	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 02:43:49.230909+00	
00000000-0000-0000-0000-000000000000	a29b997b-c4db-4aec-9844-1008f5787f47	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 02:43:49.232109+00	
00000000-0000-0000-0000-000000000000	f49d6de0-dbbc-4bbc-a34a-152f9ed696f3	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 03:41:52.573496+00	
00000000-0000-0000-0000-000000000000	12f699a3-0c50-468d-a83a-8b455c92f0fa	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 03:41:52.574655+00	
00000000-0000-0000-0000-000000000000	bce54a2f-6813-4a83-bbd5-5328a940cb9d	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 04:40:12.481514+00	
00000000-0000-0000-0000-000000000000	ae485e96-90b2-4651-b8be-6279be6f58cb	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-23 04:40:12.482823+00	
00000000-0000-0000-0000-000000000000	93f7542b-168f-4f2a-85ad-57372332a9ec	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 01:51:54.587038+00	
00000000-0000-0000-0000-000000000000	b0ea3a3c-10a3-4675-8d96-146fee5c021e	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 01:51:54.592093+00	
00000000-0000-0000-0000-000000000000	d821d01c-a86c-4353-b07a-adbaee3366e9	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 02:49:58.199757+00	
00000000-0000-0000-0000-000000000000	97938e73-6a83-45db-9b06-2d994124ad76	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 02:49:58.201368+00	
00000000-0000-0000-0000-000000000000	f0e8f4d9-281d-49bb-ae96-6fbfb15cd85c	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 22:24:10.824376+00	
00000000-0000-0000-0000-000000000000	008aa606-ab37-4171-b95f-2eac0b1746cf	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 22:24:10.830638+00	
00000000-0000-0000-0000-000000000000	c1f692d8-251c-48d3-8397-bee644688db5	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 23:22:23.568993+00	
00000000-0000-0000-0000-000000000000	4c8fda3b-880e-45c5-8c46-09306f0e4abb	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-26 23:22:23.571436+00	
00000000-0000-0000-0000-000000000000	b509a78a-61dd-4785-94d7-e5f594b49481	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 00:20:39.666313+00	
00000000-0000-0000-0000-000000000000	1ec0d062-e2ac-4a69-abe9-c5b5b278c103	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 00:20:39.668143+00	
00000000-0000-0000-0000-000000000000	6f98c875-6618-4bce-8b7f-4b71f7127872	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 01:18:52.659941+00	
00000000-0000-0000-0000-000000000000	a473b1ca-e723-4611-a56c-4ada8818cf0c	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 01:18:52.662702+00	
00000000-0000-0000-0000-000000000000	8baa3bee-11cd-46a7-8253-847f6cc8aa97	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 02:16:55.520727+00	
00000000-0000-0000-0000-000000000000	1aefdbd9-cfab-4342-8c97-407967f6aa25	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 02:16:55.522304+00	
00000000-0000-0000-0000-000000000000	2dfc692a-b86b-4734-affa-ab91689f6303	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 03:15:16.746882+00	
00000000-0000-0000-0000-000000000000	27feeadd-0e47-4597-ae7f-be37d347b11f	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 03:15:16.748929+00	
00000000-0000-0000-0000-000000000000	f295d216-37d3-48d9-959f-8bb3aad0050e	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 11:57:17.035821+00	
00000000-0000-0000-0000-000000000000	26751eae-5fab-490c-ab20-5b1dde9f4b73	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 11:57:17.039548+00	
00000000-0000-0000-0000-000000000000	aaf0342a-3314-470c-a47c-c64c277db579	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 12:55:39.994207+00	
00000000-0000-0000-0000-000000000000	eb132fbc-4888-43c9-abe1-0fc7e6e5532d	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 12:55:39.99618+00	
00000000-0000-0000-0000-000000000000	9eb3d3d1-6372-4a5e-a8ce-67a3e42bf2ab	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 13:53:43.733642+00	
00000000-0000-0000-0000-000000000000	9ebfc940-63eb-4a43-b57d-53012fb451eb	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 13:53:43.735654+00	
00000000-0000-0000-0000-000000000000	ebd99331-79d4-4501-8f1e-4a1f2c670488	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 16:43:34.791384+00	
00000000-0000-0000-0000-000000000000	45c7234b-f1fc-41a6-8a80-080927ab9014	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 16:43:34.794233+00	
00000000-0000-0000-0000-000000000000	84c88cfd-a00a-4e3f-9d2e-434f096b8253	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 17:41:35.864814+00	
00000000-0000-0000-0000-000000000000	f0a47aaa-3c14-4525-b68b-eea7950f430f	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 17:41:35.866236+00	
00000000-0000-0000-0000-000000000000	9d5bed78-419d-41a8-a2c4-d4611e56de1d	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 21:10:12.93825+00	
00000000-0000-0000-0000-000000000000	8fc8f1c0-656d-439e-8a37-3e57f5bd1970	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 21:10:12.939794+00	
00000000-0000-0000-0000-000000000000	40474b86-50be-48eb-a5d6-a7092383105b	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 22:08:42.170207+00	
00000000-0000-0000-0000-000000000000	811b9311-c1ed-4743-8ba0-a390133941a8	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 22:08:42.173161+00	
00000000-0000-0000-0000-000000000000	1ffdc736-b63a-4939-95a6-b602bb482811	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 23:06:45.092144+00	
00000000-0000-0000-0000-000000000000	7e30b022-5566-4b40-bf17-f1456dd362e1	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-27 23:06:45.093435+00	
00000000-0000-0000-0000-000000000000	d916a183-17c3-45de-943e-8cf3c4c64c6c	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-28 00:04:48.270029+00	
00000000-0000-0000-0000-000000000000	b709502c-6138-4b35-a0d9-c5329837941d	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-28 00:04:48.271213+00	
00000000-0000-0000-0000-000000000000	92609821-ea55-4ef7-b313-1128a24c3d5d	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-28 01:03:05.589034+00	
00000000-0000-0000-0000-000000000000	89d91240-c317-40b9-b774-0250c53ff8bb	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-28 01:03:05.591635+00	
00000000-0000-0000-0000-000000000000	6b33f356-d62e-40b3-8dc6-b6a4c6f0946b	{"action":"login","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-28 01:52:44.127237+00	
00000000-0000-0000-0000-000000000000	b40c107d-cda5-4a0e-9cf9-2a6eeabc17c1	{"action":"login","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-28 01:53:58.596671+00	
00000000-0000-0000-0000-000000000000	a4c4cce1-4bb8-4484-b0d4-85b6697b259e	{"action":"login","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-28 02:13:07.959832+00	
00000000-0000-0000-0000-000000000000	b5e62ffa-6d2f-466f-8974-3d38e0a5dca8	{"action":"login","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-28 02:15:16.356245+00	
00000000-0000-0000-0000-000000000000	364e565b-3ff3-44ab-b8af-bed2751f4c2f	{"action":"login","actor_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","actor_username":"rolbikurbaez@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-08-28 02:40:17.492926+00	
00000000-0000-0000-0000-000000000000	efd360e5-989c-4f1a-90c0-02adda46d64f	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-28 02:52:08.375746+00	
00000000-0000-0000-0000-000000000000	afe45e62-7b12-40ad-bc15-331170ab6ee2	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-28 02:52:08.377291+00	
00000000-0000-0000-0000-000000000000	693fc9b0-de47-4192-94f9-0b6eba3c9852	{"action":"user_confirmation_requested","actor_id":"630b18ca-43ae-449b-b799-7203272084c4","actor_username":"prueba@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-08-28 03:16:31.448995+00	
00000000-0000-0000-0000-000000000000	b6a3381d-256e-46fb-aad2-7d21abbab53d	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 00:36:39.164901+00	
00000000-0000-0000-0000-000000000000	0e73c492-d1bc-4003-885e-8c63c5f410b3	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 00:36:39.173981+00	
00000000-0000-0000-0000-000000000000	f0602104-e5f3-4c3f-9d98-935cd10875f7	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 01:34:42.254614+00	
00000000-0000-0000-0000-000000000000	9c978644-8a4e-4234-b5d1-5a30744af5ff	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 01:34:42.256417+00	
00000000-0000-0000-0000-000000000000	ad9f7306-223b-46db-8c83-559f12bc9c0f	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 02:32:44.762262+00	
00000000-0000-0000-0000-000000000000	e0028659-c33a-4f03-8a43-bb4f8ec71317	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 02:32:44.76423+00	
00000000-0000-0000-0000-000000000000	2ce594c6-39a6-4373-aa9e-f799306c8846	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"prueba@gmail.com","user_id":"630b18ca-43ae-449b-b799-7203272084c4","user_phone":""}}	2024-08-29 02:36:15.096941+00	
00000000-0000-0000-0000-000000000000	4324ca0a-445c-4ad1-a52a-44848955dfd7	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 03:30:48.374623+00	
00000000-0000-0000-0000-000000000000	b47393cc-0f60-42d5-90e1-d5ae1df9b253	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 03:30:48.376894+00	
00000000-0000-0000-0000-000000000000	56e24c3b-5dd4-49ff-b842-10ff54014ef8	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 22:06:45.322633+00	
00000000-0000-0000-0000-000000000000	e2158c37-fec0-4628-bd34-89ffd4d717a4	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 22:06:45.327635+00	
00000000-0000-0000-0000-000000000000	c2f37a61-08d6-4d8c-8f0a-a7c29054cea8	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 23:05:14.602709+00	
00000000-0000-0000-0000-000000000000	9a6429a5-d5ea-4265-9427-cf48202dcc7a	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-29 23:05:14.603908+00	
00000000-0000-0000-0000-000000000000	a0cbf6d3-6337-45f0-ab35-d63e791dcd6b	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 00:03:16.82189+00	
00000000-0000-0000-0000-000000000000	71cdaff9-aed1-4c97-b07f-cae6cd22dd2d	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 00:03:16.823459+00	
00000000-0000-0000-0000-000000000000	6e1dee5e-eb70-4926-9758-e9855f2bd49a	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 02:26:17.452325+00	
00000000-0000-0000-0000-000000000000	3dc3676b-f7c8-4673-bfb9-dd7e7b5a8376	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 02:26:17.454986+00	
00000000-0000-0000-0000-000000000000	56903c7e-45c2-4811-aa90-9a6246cb2766	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 03:24:43.006279+00	
00000000-0000-0000-0000-000000000000	c9324cc2-d85f-4671-9d7e-4f3c3d622cb8	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 03:24:43.00811+00	
00000000-0000-0000-0000-000000000000	5d5e05ee-9768-43ef-9d5a-e06732d28470	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 04:22:59.25174+00	
00000000-0000-0000-0000-000000000000	59d7a675-aeb4-48ae-a009-14f19b838ab3	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-30 04:22:59.25312+00	
00000000-0000-0000-0000-000000000000	51eac446-7799-4268-9371-2911c99f1bc9	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 05:08:13.589732+00	
00000000-0000-0000-0000-000000000000	9cecf596-97a0-4cc0-b76f-4333b42d1616	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 05:08:13.597935+00	
00000000-0000-0000-0000-000000000000	467d0938-5135-4c7e-a743-b9763bd2a393	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 14:01:21.179798+00	
00000000-0000-0000-0000-000000000000	13c625b1-bdbf-4076-abdf-c95283c177ad	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 14:01:21.182493+00	
00000000-0000-0000-0000-000000000000	bd41e2d7-38e7-4f5f-8433-0bf4429b295b	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 14:59:24.130295+00	
00000000-0000-0000-0000-000000000000	f2222662-fa7b-4802-97d8-4d508baa65c4	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 14:59:24.133069+00	
00000000-0000-0000-0000-000000000000	1ab6c03d-5ef3-4513-97e2-10ae3bcba9ea	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 17:42:28.001671+00	
00000000-0000-0000-0000-000000000000	20a849e2-c9ac-4da3-accb-1d8f9caff613	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 17:42:28.004503+00	
00000000-0000-0000-0000-000000000000	390a6c74-5174-48f5-9fb0-c0dc2d21cdc5	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 18:40:30.998445+00	
00000000-0000-0000-0000-000000000000	1e3df49f-7202-42a5-a6d0-05fc64fc0142	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 18:40:31.000166+00	
00000000-0000-0000-0000-000000000000	d05021f4-fcd1-4d49-8443-8abf8203cdb2	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 23:19:36.5797+00	
00000000-0000-0000-0000-000000000000	6e99a686-6997-43a0-8cb8-e926be2992ee	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-08-31 23:19:36.581403+00	
00000000-0000-0000-0000-000000000000	c6945181-6205-4936-a9c6-920658c0e45b	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 00:17:38.268852+00	
00000000-0000-0000-0000-000000000000	ce5d941e-94de-42dc-ba78-7034eadc74d7	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 00:17:38.270488+00	
00000000-0000-0000-0000-000000000000	56361e9e-6c4e-49fe-a0c1-4af2484d0587	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 03:05:03.883476+00	
00000000-0000-0000-0000-000000000000	f8f54a72-9267-471b-8c20-00e6421707e5	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 03:05:03.885161+00	
00000000-0000-0000-0000-000000000000	777838cf-fdc4-4051-8f5f-968e3b9e4f6b	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 04:03:23.633459+00	
00000000-0000-0000-0000-000000000000	2866d277-2745-4542-bcdf-c7ec2656e755	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 04:03:23.635052+00	
00000000-0000-0000-0000-000000000000	cf9df105-1aeb-4bf6-b5e6-bae521eaf6af	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 05:01:26.783288+00	
00000000-0000-0000-0000-000000000000	753f9733-5883-4190-ad48-f9c81db8ee89	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 05:01:26.786269+00	
00000000-0000-0000-0000-000000000000	a134f9ae-886c-4606-b0cb-fdd328382338	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 16:02:09.048577+00	
00000000-0000-0000-0000-000000000000	8b5d6b3a-ca9c-4a45-82ad-e1a378046283	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 16:02:09.052196+00	
00000000-0000-0000-0000-000000000000	a4d8e60f-455c-4d40-9496-f7a79440baa8	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 17:00:09.702243+00	
00000000-0000-0000-0000-000000000000	0a71327a-a6c6-46de-959f-28e573ec28fa	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 17:00:09.704798+00	
00000000-0000-0000-0000-000000000000	4e4fdfbf-bb1f-4594-b416-94d3e5af7c91	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 18:30:44.189592+00	
00000000-0000-0000-0000-000000000000	682085d3-e11a-4c86-910b-31327b3e3138	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 18:30:44.190423+00	
00000000-0000-0000-0000-000000000000	c3cd2f9c-87e9-4d90-be2f-2d6c803bd07e	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 19:28:53.724184+00	
00000000-0000-0000-0000-000000000000	46ded184-f46a-4c8c-8702-8ccff3d9b817	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 19:28:53.726298+00	
00000000-0000-0000-0000-000000000000	98f46f84-fed1-460a-983f-4402656cf76e	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 21:02:46.676762+00	
00000000-0000-0000-0000-000000000000	b4af6361-03c7-4e5e-ae22-514ad872665c	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 21:02:46.679376+00	
00000000-0000-0000-0000-000000000000	5e2a04d7-b021-4c33-b17d-84301d41ca50	{"action":"token_refreshed","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 22:00:49.754503+00	
00000000-0000-0000-0000-000000000000	6199654b-83d8-4d9b-98bc-1d6d90c230d0	{"action":"token_revoked","actor_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-01 22:00:49.756727+00	
00000000-0000-0000-0000-000000000000	8a1282a4-ed8e-410b-a48b-0483de378718	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"rolbikurbaez@gmail.com","user_id":"a7bc6f7b-eb55-402f-b590-97dcbb55a118","user_phone":""}}	2024-09-02 02:58:14.469025+00	
00000000-0000-0000-0000-000000000000	6908ff96-3771-4dcb-9bf1-d49f069a78a7	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"40b7f4ab-8d5d-40d3-967d-bb97f2d9cbac","user_phone":""}}	2024-09-02 02:58:19.777402+00	
00000000-0000-0000-0000-000000000000	e21b8038-4751-4a14-856b-f66d335d1ce7	{"action":"user_confirmation_requested","actor_id":"67a4fba7-c278-4081-a146-0d867815643f","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-02 02:59:12.561004+00	
00000000-0000-0000-0000-000000000000	1c74a969-793a-4335-95f4-9bcad3ba8bec	{"action":"user_signedup","actor_id":"67a4fba7-c278-4081-a146-0d867815643f","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"team"}	2024-09-02 02:59:36.211734+00	
00000000-0000-0000-0000-000000000000	fda607da-2e19-467d-ab09-d55d624324d0	{"action":"user_signedup","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"elrealchocolate@gmail.com","user_id":"01826f46-12fd-4b78-bf65-72284b0c5113","user_phone":""}}	2024-09-02 03:12:24.266358+00	
00000000-0000-0000-0000-000000000000	3be73598-6e09-402c-8e69-6287f41243a0	{"action":"user_confirmation_requested","actor_id":"6b0950da-7eb6-4457-8b93-30c338e1cbf3","actor_username":"sknyqlywgomvkswjwb@poplk.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-03 03:36:22.804399+00	
00000000-0000-0000-0000-000000000000	8316f28f-8f07-4ac2-b531-7c916b45ef30	{"action":"user_confirmation_requested","actor_id":"629ff752-c218-4029-afdb-e7213b783c02","actor_username":"pwrlwzggmiavjmwqls@poplk.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-03 03:38:53.342716+00	
00000000-0000-0000-0000-000000000000	897db35c-583b-4969-8cf9-89dc0e3a7f4a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"pwrlwzggmiavjmwqls@poplk.com","user_id":"629ff752-c218-4029-afdb-e7213b783c02","user_phone":""}}	2024-09-04 00:19:39.698368+00	
00000000-0000-0000-0000-000000000000	bb5f3079-5b91-4129-8f24-0c6066309be3	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"sknyqlywgomvkswjwb@poplk.com","user_id":"6b0950da-7eb6-4457-8b93-30c338e1cbf3","user_phone":""}}	2024-09-04 00:19:43.910818+00	
00000000-0000-0000-0000-000000000000	b4390562-0af3-477a-995f-f29144e1226e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"elrealchocolate@gmail.com","user_id":"01826f46-12fd-4b78-bf65-72284b0c5113","user_phone":""}}	2024-09-04 00:19:47.850226+00	
00000000-0000-0000-0000-000000000000	beacd3cf-bdc9-4d19-8bfa-c4a7724db514	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"67a4fba7-c278-4081-a146-0d867815643f","user_phone":""}}	2024-09-04 00:19:51.975874+00	
00000000-0000-0000-0000-000000000000	24897d1c-9900-4001-a76c-f926576c1bd6	{"action":"user_confirmation_requested","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-04 00:21:22.033148+00	
00000000-0000-0000-0000-000000000000	551f0ea3-2f1f-4779-a554-26a72676e594	{"action":"user_signedup","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"team"}	2024-09-04 00:22:12.519146+00	
00000000-0000-0000-0000-000000000000	e836495e-ce47-438b-94fe-a055e10bd666	{"action":"user_confirmation_requested","actor_id":"c33cab15-b64f-43d0-a733-0c795bd448a1","actor_username":"elrealchocolate@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-05 03:10:33.36788+00	
00000000-0000-0000-0000-000000000000	7c960c4c-9e7a-4e4e-865e-2e24d31cb9f0	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"elrealchocolate@gmail.com","user_id":"c33cab15-b64f-43d0-a733-0c795bd448a1","user_phone":""}}	2024-09-08 18:48:42.81852+00	
00000000-0000-0000-0000-000000000000	0d2d5bdc-139f-404a-bd5f-4d3b31e1c983	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-08 19:50:05.544601+00	
00000000-0000-0000-0000-000000000000	9a043440-84fe-46f9-a22f-68353050c253	{"action":"user_confirmation_requested","actor_id":"dd3f6685-376d-4e7b-a4fa-7749826cc4af","actor_username":"elrealchocolate@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-08 20:43:07.150158+00	
00000000-0000-0000-0000-000000000000	bd6baf62-652a-4b8a-ae48-55f7150694e0	{"action":"user_signedup","actor_id":"dd3f6685-376d-4e7b-a4fa-7749826cc4af","actor_username":"elrealchocolate@gmail.com","actor_via_sso":false,"log_type":"team"}	2024-09-08 21:14:08.20203+00	
00000000-0000-0000-0000-000000000000	26cc1f0b-4351-4393-8cdf-ee4260dd052c	{"action":"user_confirmation_requested","actor_id":"c0a38777-0e95-4a04-bb64-629c6295eebd","actor_username":"1104666@est.intec.edu.do","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-10 20:00:34.689982+00	
00000000-0000-0000-0000-000000000000	98ed4254-5b18-44d1-a84a-bedc577c5473	{"action":"user_signedup","actor_id":"c0a38777-0e95-4a04-bb64-629c6295eebd","actor_username":"1104666@est.intec.edu.do","actor_via_sso":false,"log_type":"team"}	2024-09-10 20:00:50.954276+00	
00000000-0000-0000-0000-000000000000	620e2f6d-e378-4a6d-9174-5bd5f0758d39	{"action":"user_recovery_requested","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user"}	2024-09-11 02:16:14.90623+00	
00000000-0000-0000-0000-000000000000	d69bc9d4-9bc0-4f05-af56-ad093e26d85b	{"action":"user_recovery_requested","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user"}	2024-09-11 02:18:48.115708+00	
00000000-0000-0000-0000-000000000000	a28ed425-de13-4c4c-87b9-4e2abeeaf610	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-11 02:45:48.029671+00	
00000000-0000-0000-0000-000000000000	b4a21ec9-c4dc-4794-94ea-10cf29e4d522	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"37d3b652-d314-4124-9685-add5f0c6fc19","user_phone":""}}	2024-09-11 03:25:45.953412+00	
00000000-0000-0000-0000-000000000000	e34e5783-f212-429d-b3e8-01c1b031ce57	{"action":"user_confirmation_requested","actor_id":"a3f25f7f-1399-43cc-b36e-2c95829a0fca","actor_username":"zlhndseutqdvzxqpgb@ytnhy.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-11 03:43:34.461657+00	
00000000-0000-0000-0000-000000000000	f55a95a5-1b86-4865-9652-182ebb64fe16	{"action":"user_recovery_requested","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user"}	2024-09-11 03:48:19.170205+00	
00000000-0000-0000-0000-000000000000	2dc69ee6-d8df-42eb-8248-e4d4f2f96d20	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-11 03:49:06.676099+00	
00000000-0000-0000-0000-000000000000	cad21943-58e0-49be-b2fd-db164d78bf3d	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"37d3b652-d314-4124-9685-add5f0c6fc19","user_phone":""}}	2024-09-11 03:49:45.261972+00	
00000000-0000-0000-0000-000000000000	8d70f5b0-4989-4392-a6bb-6c37024b4305	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"37d3b652-d314-4124-9685-add5f0c6fc19","user_phone":""}}	2024-09-11 03:50:17.477+00	
00000000-0000-0000-0000-000000000000	b9b7098c-642f-40e5-b1ea-129abd72aa55	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"angelgmorenor@gmail.com","user_id":"37d3b652-d314-4124-9685-add5f0c6fc19","user_phone":""}}	2024-09-11 03:50:58.542549+00	
00000000-0000-0000-0000-000000000000	38ec74ae-806e-4b9c-899f-1a9c81d7e041	{"action":"user_confirmation_requested","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-17 22:33:17.32033+00	
00000000-0000-0000-0000-000000000000	a0656381-f6d4-4436-a9c2-bcf9418761c3	{"action":"user_signedup","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"team"}	2024-09-17 22:33:42.187644+00	
00000000-0000-0000-0000-000000000000	d125a6ee-543a-443a-b9ba-947c0c56976a	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-17 22:37:56.409643+00	
00000000-0000-0000-0000-000000000000	6fdd1b13-d357-4095-b460-6b360cd2a75e	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-18 01:55:11.684971+00	
00000000-0000-0000-0000-000000000000	60f50de4-5e5b-49c2-b81d-04ad7f7bf22a	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-18 01:55:11.996582+00	
00000000-0000-0000-0000-000000000000	f810ff86-baf8-4f88-8dd0-14b1c78cf4ee	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-18 01:56:17.520819+00	
00000000-0000-0000-0000-000000000000	c271ec10-ba5d-4f3a-aa77-4963c19f3313	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 14:28:24.257461+00	
00000000-0000-0000-0000-000000000000	f2361394-44b5-4fe3-aaac-33f1e120a0d6	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 14:30:40.282031+00	
00000000-0000-0000-0000-000000000000	fe35e818-c86b-4955-8cb5-d909308e491e	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 14:30:49.447133+00	
00000000-0000-0000-0000-000000000000	0d5a3be0-f605-43d4-a217-26a3d9995c38	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 14:56:29.832692+00	
00000000-0000-0000-0000-000000000000	a5c1075c-0b21-44c1-adbf-e5f02291c1fd	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 14:57:24.458948+00	
00000000-0000-0000-0000-000000000000	9b73f05f-3fac-4e32-9650-656d11808024	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 14:58:54.251285+00	
00000000-0000-0000-0000-000000000000	a9bd9d00-431f-4085-a06f-70f3c6b54dde	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 15:08:29.692955+00	
00000000-0000-0000-0000-000000000000	69a61a70-03c0-42e7-8f90-e67fd959925b	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 15:08:42.686173+00	
00000000-0000-0000-0000-000000000000	66611c58-d1fe-4b0e-a44b-007880f5e302	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 15:09:22.332514+00	
00000000-0000-0000-0000-000000000000	2c2ba74a-e47d-44f9-9cd4-81e2cb0e261c	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 15:09:34.127604+00	
00000000-0000-0000-0000-000000000000	be2fde39-dc18-43bc-9fe3-2bae8c864779	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:37:44.25585+00	
00000000-0000-0000-0000-000000000000	5ed18484-0ed0-4041-9d92-fc8c0be9d0da	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:37:59.25795+00	
00000000-0000-0000-0000-000000000000	b7dcc0d5-eb73-4761-88eb-57a0a2e730b5	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:38:19.566006+00	
00000000-0000-0000-0000-000000000000	21fd7ad1-dab1-47cb-a681-b15c121af2fd	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:38:20.997289+00	
00000000-0000-0000-0000-000000000000	c15f91d4-0a1b-4f05-9bbd-a19b4a2c93b8	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:39:24.477365+00	
00000000-0000-0000-0000-000000000000	e44983f0-265c-40fd-8bf8-135b473c1712	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:39:57.402405+00	
00000000-0000-0000-0000-000000000000	a89cd46d-219d-46b0-a7c8-89e7551b0df3	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:43:05.873919+00	
00000000-0000-0000-0000-000000000000	2bbaa441-1d42-48dd-9232-76ff3cf66622	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:43:21.698417+00	
00000000-0000-0000-0000-000000000000	367f958a-c948-4dbb-a529-eb34aa6099dd	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:43:23.24195+00	
00000000-0000-0000-0000-000000000000	f00ebb15-3c62-485e-a74d-9d7c32e94c79	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:43:24.274176+00	
00000000-0000-0000-0000-000000000000	6551483f-f34c-4870-a395-891c7951ae6d	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 18:43:25.221783+00	
00000000-0000-0000-0000-000000000000	a49c437a-0661-449d-b774-cd88ea02165d	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:33:22.812667+00	
00000000-0000-0000-0000-000000000000	e6e4b6ff-bc8f-439e-9b47-d9ea7ea55eae	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:50:24.418957+00	
00000000-0000-0000-0000-000000000000	d23589fb-2f43-490f-896d-cb50be933982	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:50:24.612383+00	
00000000-0000-0000-0000-000000000000	86f1181f-2efa-407f-a1f9-ba4515c3d0d7	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:50:24.612964+00	
00000000-0000-0000-0000-000000000000	c94f701d-2fa7-4be5-b9fe-3bd90ede5a5d	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:51:01.221883+00	
00000000-0000-0000-0000-000000000000	f996bb35-16e5-4258-83de-ee2f07a38fdb	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:51:01.378157+00	
00000000-0000-0000-0000-000000000000	b7b7a358-393c-4f81-a007-e26aa4f88b11	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:51:01.378742+00	
00000000-0000-0000-0000-000000000000	0a95f1a4-a765-4e87-a9fd-b62e757b6a03	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:51:14.517925+00	
00000000-0000-0000-0000-000000000000	9ddd0540-62fa-42e2-97be-db2d49dae1ec	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:51:14.674086+00	
00000000-0000-0000-0000-000000000000	f119fb56-0dee-4df6-8afd-5cb7d723be42	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:51:14.674646+00	
00000000-0000-0000-0000-000000000000	e1b28bfe-b7b2-4ae8-96d5-729c81db8eb0	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:51:45.460093+00	
00000000-0000-0000-0000-000000000000	b62c736e-4f74-4a1f-ab3b-c4f8aa50c3b5	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:51:45.619407+00	
00000000-0000-0000-0000-000000000000	e3568183-aac2-4504-9737-66abe582e099	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:51:45.620016+00	
00000000-0000-0000-0000-000000000000	ea7b2d0e-3450-41f7-bed4-c8da16b05bad	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:52:06.142523+00	
00000000-0000-0000-0000-000000000000	29303bfc-671c-4239-b052-911c8f3539d1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:52:06.287811+00	
00000000-0000-0000-0000-000000000000	bf764aca-950a-4879-9a50-62ca0421a77e	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:52:06.28839+00	
00000000-0000-0000-0000-000000000000	a6972c1d-6419-4961-b453-e8dc979717e0	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:53:38.146001+00	
00000000-0000-0000-0000-000000000000	e7ec26c1-7a1e-4c9f-840c-b9a915338c79	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:53:38.304295+00	
00000000-0000-0000-0000-000000000000	424590f6-9b76-4118-b53d-163a68fa7fea	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:53:38.30485+00	
00000000-0000-0000-0000-000000000000	d308067b-9cf2-474e-9d46-3bae79c970c2	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:54:45.076524+00	
00000000-0000-0000-0000-000000000000	56757764-bce5-48b0-9417-829e7b724fdd	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:54:45.241166+00	
00000000-0000-0000-0000-000000000000	6e2dd6e4-eb10-40e1-a18b-97672595368b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:54:45.241703+00	
00000000-0000-0000-0000-000000000000	4ea205c0-3307-401f-b11c-fdfd6435aee4	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:55:39.017654+00	
00000000-0000-0000-0000-000000000000	8d733c46-07d1-4f4d-80f1-501c5eec04ec	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:55:39.345242+00	
00000000-0000-0000-0000-000000000000	25e638a0-a6ad-48e6-a19d-4b9237cf145d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:55:39.345829+00	
00000000-0000-0000-0000-000000000000	dd2caf77-d1e7-446f-b788-1d00aeb6b271	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:56:00.186095+00	
00000000-0000-0000-0000-000000000000	188bf9d9-aefc-4ee4-88f3-3c5f378662ea	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:56:00.324785+00	
00000000-0000-0000-0000-000000000000	74ce8822-07d2-4400-80d9-2524efbbb4fb	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:56:00.325398+00	
00000000-0000-0000-0000-000000000000	4f56f68a-0960-42c9-9bc9-3a3695029b37	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 19:56:02.60441+00	
00000000-0000-0000-0000-000000000000	d9472779-8bb0-4d97-ae14-7f9debdc2a2c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:56:02.889704+00	
00000000-0000-0000-0000-000000000000	cbbc65f3-e2c9-414b-ac0c-55472ae1b076	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 19:56:02.89027+00	
00000000-0000-0000-0000-000000000000	d9ca8264-8354-4c73-929f-f07575ab6c5c	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 19:56:05.540232+00	
00000000-0000-0000-0000-000000000000	56720222-16c2-43a4-9b14-d7e7a94c5da0	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:04:28.396319+00	
00000000-0000-0000-0000-000000000000	4473055b-c69c-463f-a59c-17e913eb1ec2	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:04:42.605774+00	
00000000-0000-0000-0000-000000000000	a55dd78b-b510-4b78-8da4-d985b3e3b7a6	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:05:07.135098+00	
00000000-0000-0000-0000-000000000000	62069faf-4d50-410a-ab54-1350060c70ae	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:09:46.784113+00	
00000000-0000-0000-0000-000000000000	c30f0e74-1bd2-4458-9eb6-fb7a88b8ec10	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:11:40.458657+00	
00000000-0000-0000-0000-000000000000	8fe17903-9c1f-4731-9ba8-587022a7b011	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:11:40.789968+00	
00000000-0000-0000-0000-000000000000	41990e70-5de3-4023-a909-c2cfacaf2694	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:11:40.790517+00	
00000000-0000-0000-0000-000000000000	ad68d0f2-3469-4b04-be9c-e4d7bb51f9cc	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:13:45.002345+00	
00000000-0000-0000-0000-000000000000	664d254b-bc82-4738-924c-e57d6fb44235	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:13:45.150155+00	
00000000-0000-0000-0000-000000000000	b0cf87c0-6a62-4c91-83d2-1bf8a3b376c6	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:13:45.150699+00	
00000000-0000-0000-0000-000000000000	a18d70f8-ea49-4a1e-b400-f123b8fb8ea3	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:26:06.270131+00	
00000000-0000-0000-0000-000000000000	d7b14ee4-ba82-4dd1-be61-c071bf7f46b4	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:26:06.614056+00	
00000000-0000-0000-0000-000000000000	68662344-fbde-4da0-9084-f6d288c9fd89	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:26:06.614646+00	
00000000-0000-0000-0000-000000000000	6560e7ea-18ea-4009-acf3-856b7797f502	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 20:26:29.279283+00	
00000000-0000-0000-0000-000000000000	8f511aed-b864-4f98-b22a-d761c88265b7	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:26:57.106051+00	
00000000-0000-0000-0000-000000000000	03583c4d-b48d-4f61-95bb-c9db02c8e800	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:26:57.25483+00	
00000000-0000-0000-0000-000000000000	a144cb14-ad57-474d-8247-c7f77c0abf10	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:26:57.255502+00	
00000000-0000-0000-0000-000000000000	e99d57eb-bedd-4310-989c-9d132344841b	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 20:27:00.371683+00	
00000000-0000-0000-0000-000000000000	e4556f2f-3c2d-465e-85e2-22fda101fa74	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:32:55.071688+00	
00000000-0000-0000-0000-000000000000	86a6ecfe-a360-4826-8567-4f97483f7ac0	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:32:55.21898+00	
00000000-0000-0000-0000-000000000000	41889b9e-ad0c-44f7-9322-f35608443530	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:32:55.219532+00	
00000000-0000-0000-0000-000000000000	c7cfdf2c-f2e4-420f-bae1-787b13f91b5c	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:33:14.905302+00	
00000000-0000-0000-0000-000000000000	95a50c0b-8cd1-40d7-960d-f3759b489059	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:33:15.076536+00	
00000000-0000-0000-0000-000000000000	cfe6f036-f824-4a5b-accf-c62e4ee3bfd7	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:33:15.077086+00	
00000000-0000-0000-0000-000000000000	b5a0fd4e-b582-4aa0-a66e-9dde400dd1ff	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:35:34.973153+00	
00000000-0000-0000-0000-000000000000	82e6907d-4204-4c38-b18d-641457a46110	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:35:35.132669+00	
00000000-0000-0000-0000-000000000000	aa577fb4-069f-4e36-b350-e1b590e4b3ba	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:35:35.133275+00	
00000000-0000-0000-0000-000000000000	45c6b84f-0584-4140-9fb4-f9bf71b33a76	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:37:38.38992+00	
00000000-0000-0000-0000-000000000000	2ea964e3-600f-4075-b8e5-877a9cac5b4c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:37:38.555491+00	
00000000-0000-0000-0000-000000000000	5b31a863-25dd-44d6-bb30-857e71100c08	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:37:38.556031+00	
00000000-0000-0000-0000-000000000000	7222ca91-4eee-4832-9725-9192958cc60c	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 20:37:41.166484+00	
00000000-0000-0000-0000-000000000000	1d883a23-547e-440a-94e6-5c588e4e3b32	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-24 20:40:35.372505+00	
00000000-0000-0000-0000-000000000000	74783d7c-e77c-4e69-b0e6-642bd6824a79	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:40:35.563674+00	
00000000-0000-0000-0000-000000000000	740d1213-4704-4427-bc33-2b5942a55a3b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-24 20:40:35.564253+00	
00000000-0000-0000-0000-000000000000	b77fd35b-b28e-477b-b763-bc5abbf4821c	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-24 20:45:39.728799+00	
00000000-0000-0000-0000-000000000000	7f59f9b3-9c27-44a4-b923-7bd8f5e02fb0	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 01:57:53.414174+00	
00000000-0000-0000-0000-000000000000	a304ae04-17d4-4518-a5da-832bd4d0d2b1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 01:57:53.658143+00	
00000000-0000-0000-0000-000000000000	e6d78753-f7a8-4cf0-885b-d90063b65ebe	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 01:57:53.658702+00	
00000000-0000-0000-0000-000000000000	5ac2bbaf-f35c-443f-aead-be7dddffdd92	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 01:58:09.959492+00	
00000000-0000-0000-0000-000000000000	4abb76f6-d551-4fc1-ae29-124546c9ba17	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 01:58:10.330769+00	
00000000-0000-0000-0000-000000000000	d6643d6d-ff62-4ae2-8231-4487455a0a1d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 01:58:10.331395+00	
00000000-0000-0000-0000-000000000000	70259d42-5f51-44c6-8ba4-dcd7c802a7c2	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 20:34:21.340373+00	
00000000-0000-0000-0000-000000000000	2e65c08b-9328-4a16-a06f-c1faa00a71f2	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"1104666@est.intec.edu.do","user_id":"c0a38777-0e95-4a04-bb64-629c6295eebd","user_phone":""}}	2024-09-25 20:35:18.490861+00	
00000000-0000-0000-0000-000000000000	3146eafb-60f1-47ca-a6c5-a5d47f0ea70a	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 20:48:28.284654+00	
00000000-0000-0000-0000-000000000000	74787f68-d3bb-4547-a266-efb596532fa5	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 20:48:28.647664+00	
00000000-0000-0000-0000-000000000000	fdb9a15d-0f18-40f5-9ac8-e5123ff5d582	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 21:32:47.194538+00	
00000000-0000-0000-0000-000000000000	02fbf425-fa3c-4a3b-abbe-99403f6c8d2c	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 21:32:47.197675+00	
00000000-0000-0000-0000-000000000000	ba2f4eaa-6180-46ab-9a0f-18d9c59cf7c7	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 22:51:48.857539+00	
00000000-0000-0000-0000-000000000000	653776a6-28bc-42cb-9a45-0c7c2a1c98a8	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 22:51:48.859487+00	
00000000-0000-0000-0000-000000000000	d0e98cb0-9be3-41d6-a70e-646df530526c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:09:03.297706+00	
00000000-0000-0000-0000-000000000000	cadfe04d-4f70-45fc-957a-0c2143aa569a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:09:03.30007+00	
00000000-0000-0000-0000-000000000000	3a0acd66-234d-48cc-a051-d7f2e04609b8	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-25 23:11:28.43437+00	
00000000-0000-0000-0000-000000000000	e5865f62-45b3-43db-9c38-7001a8107dee	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 23:11:39.417844+00	
00000000-0000-0000-0000-000000000000	b2ad51f5-2674-4156-b07d-6705aff64f7d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:11:39.784709+00	
00000000-0000-0000-0000-000000000000	b34ac4db-6b9a-422c-8566-db99887f5d4c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:11:39.785294+00	
00000000-0000-0000-0000-000000000000	fe30e374-c617-4a4c-9708-4937f0471159	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 23:41:18.356087+00	
00000000-0000-0000-0000-000000000000	f5917c17-5fc9-43a9-88ab-d04a3c29af40	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 23:41:35.151203+00	
00000000-0000-0000-0000-000000000000	3d361047-1968-45ba-871c-def7d8b3c970	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:50:16.086524+00	
00000000-0000-0000-0000-000000000000	1f80a6c1-46be-4077-8edc-c917a57908d4	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:50:16.087997+00	
00000000-0000-0000-0000-000000000000	5c1635c9-845e-41b1-82a5-5ee00d003dd7	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-25 23:53:21.689215+00	
00000000-0000-0000-0000-000000000000	d8e2994f-668f-418e-9e00-e29356a61c34	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 23:53:24.793247+00	
00000000-0000-0000-0000-000000000000	1ae85e65-72cd-408c-b978-378b490b79be	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:53:25.171385+00	
00000000-0000-0000-0000-000000000000	c991e606-c529-4835-b1f4-50fd191d57e4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:53:25.172019+00	
00000000-0000-0000-0000-000000000000	3ae647c2-2101-4ce2-ac3d-1b2ba82a6b16	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-25 23:53:50.177602+00	
00000000-0000-0000-0000-000000000000	e2cc9ae9-2d12-41be-8b87-db3537e4f013	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:53:50.350297+00	
00000000-0000-0000-0000-000000000000	6e2b55c5-84db-4b6c-abe5-90c70171e0bc	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-25 23:53:50.350848+00	
00000000-0000-0000-0000-000000000000	845d3314-26fd-4a09-8fa7-e853e7ee2f8a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-26 02:16:05.609922+00	
00000000-0000-0000-0000-000000000000	af954a89-3cd1-4473-8605-57e5232f5251	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-26 02:16:05.612682+00	
00000000-0000-0000-0000-000000000000	4a498eff-4fd7-4bcc-a250-a5f46506e9de	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-26 02:45:40.612602+00	
00000000-0000-0000-0000-000000000000	c1ebd255-c449-4603-a684-bed37ec43d99	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-27 00:33:16.527577+00	
00000000-0000-0000-0000-000000000000	1d195e6a-8981-4f9b-bc7d-5492fb559cd8	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 00:33:17.034522+00	
00000000-0000-0000-0000-000000000000	28afc46e-f376-4334-b974-f3b451251a52	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 00:33:17.035068+00	
00000000-0000-0000-0000-000000000000	4410a562-cb50-4c42-9ff6-99b5da5a2efb	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-27 00:33:56.087741+00	
00000000-0000-0000-0000-000000000000	551c6e98-8a07-4ebc-91c4-bc1c87929234	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 00:33:56.470644+00	
00000000-0000-0000-0000-000000000000	9437545c-87e3-41ba-b870-b683356b4b8a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 00:33:56.471229+00	
00000000-0000-0000-0000-000000000000	3a499022-8d1b-4276-9d65-b8ab1970b468	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-27 00:34:43.406796+00	
00000000-0000-0000-0000-000000000000	ae019494-8f5b-403e-91b1-823e0860e963	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-27 00:34:52.571883+00	
00000000-0000-0000-0000-000000000000	41e60496-8daf-4195-9c58-03a8f4d4746c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 00:34:52.775615+00	
00000000-0000-0000-0000-000000000000	02dad3e9-54fa-4ed2-b24e-5eb6658c554b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 00:34:52.776361+00	
00000000-0000-0000-0000-000000000000	98b95c4e-648e-4ad7-8d06-baab76513916	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:31:55.019873+00	
00000000-0000-0000-0000-000000000000	82d52708-c340-4eae-8eaa-9984d8778486	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:31:55.020717+00	
00000000-0000-0000-0000-000000000000	11dc1d53-9d3b-40fa-8a26-27548dafddb4	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-27 02:33:19.539833+00	
00000000-0000-0000-0000-000000000000	96e9780d-f75b-406c-8bff-1dfe9ea83cb6	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:33:19.912165+00	
00000000-0000-0000-0000-000000000000	c448bd57-1fce-4f0b-8af0-c1ff17495c6e	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:33:19.912776+00	
00000000-0000-0000-0000-000000000000	a1fba729-9f52-4d2c-9a8e-1d3018e26975	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-27 02:42:23.92338+00	
00000000-0000-0000-0000-000000000000	992e8953-aca6-493d-bc26-12192b89e12b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:42:24.090496+00	
00000000-0000-0000-0000-000000000000	7a2736e1-faa2-47a1-8f2a-c9a65d8fce38	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:42:24.091059+00	
00000000-0000-0000-0000-000000000000	92966002-f5da-4e33-83ae-173171a83925	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-27 02:46:23.411478+00	
00000000-0000-0000-0000-000000000000	36ffee05-8d07-40b8-b813-0a9a34be048a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:46:23.569228+00	
00000000-0000-0000-0000-000000000000	4f834d40-4fdc-47ea-b1c3-92bcabf49f9f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-27 02:46:23.569775+00	
00000000-0000-0000-0000-000000000000	763ac8c0-14af-46f0-b1ff-2dbeafcad585	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 20:40:56.987444+00	
00000000-0000-0000-0000-000000000000	3b1ed294-d9e1-4578-b592-c7d0cae63eaf	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 20:40:56.993961+00	
00000000-0000-0000-0000-000000000000	fd1bada4-b729-4714-84c8-2d0851f7e881	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-28 20:41:16.530984+00	
00000000-0000-0000-0000-000000000000	800b0414-4e3e-4129-8cc4-58a2833724bb	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 20:41:16.707387+00	
00000000-0000-0000-0000-000000000000	93feec48-b8be-430c-989e-6cf7581abcdc	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 20:41:16.707943+00	
00000000-0000-0000-0000-000000000000	f3661eea-ecfd-47f5-bb30-660fb86924ac	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-28 20:41:23.004585+00	
00000000-0000-0000-0000-000000000000	09fb4c6c-2cd1-474c-ba7d-a69570286e9b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 20:41:23.363801+00	
00000000-0000-0000-0000-000000000000	7b9ac112-672a-496a-90d9-29463b226922	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 20:41:23.364371+00	
00000000-0000-0000-0000-000000000000	cef0a926-236b-466a-81c9-485ecf2037f9	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-09-28 21:29:39.09628+00	
00000000-0000-0000-0000-000000000000	ee669170-4861-4fdb-961c-8088243d7898	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-28 21:29:52.840607+00	
00000000-0000-0000-0000-000000000000	8a786234-c28c-4d16-8d6c-7548c304417a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 21:29:53.236195+00	
00000000-0000-0000-0000-000000000000	563c4385-cb1b-46b0-b5e6-3f2fd0d8e955	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 21:29:53.23678+00	
00000000-0000-0000-0000-000000000000	403e03fd-51b0-4666-9796-1dfcb5ace4cb	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-09-28 21:30:21.650486+00	
00000000-0000-0000-0000-000000000000	1ef47ce9-8a70-4743-bcd4-f8c7eacf3cb5	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 21:30:21.806916+00	
00000000-0000-0000-0000-000000000000	c2a2b301-ec4f-40c3-8b75-d1c508996eb8	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-09-28 21:30:21.807493+00	
00000000-0000-0000-0000-000000000000	0226192b-8fe6-4bd5-9bfd-40f6107895d4	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"zlhndseutqdvzxqpgb@ytnhy.com","user_id":"a3f25f7f-1399-43cc-b36e-2c95829a0fca","user_phone":""}}	2024-09-29 01:09:43.652303+00	
00000000-0000-0000-0000-000000000000	08df707a-1510-49b1-b421-dbfcec962660	{"action":"user_confirmation_requested","actor_id":"e33d18ae-872a-4932-b25f-c57372ac3f84","actor_username":"jdfaqcpwraksugpiuf@ytnhy.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-09-29 01:14:43.721687+00	
00000000-0000-0000-0000-000000000000	add61721-d785-4f79-8346-d906a1493efb	{"action":"user_signedup","actor_id":"e33d18ae-872a-4932-b25f-c57372ac3f84","actor_username":"jdfaqcpwraksugpiuf@ytnhy.com","actor_via_sso":false,"log_type":"team"}	2024-09-29 01:14:58.358993+00	
00000000-0000-0000-0000-000000000000	53b53208-ff3e-48c0-a1dc-e733d4d4e818	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:11:37.896549+00	
00000000-0000-0000-0000-000000000000	e6a53192-5b39-4891-b63f-b31cec9c1b98	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"sabej53043@abevw.com","user_id":"e33d18ae-872a-4932-b25f-c57372ac3f84","user_phone":""}}	2024-09-29 02:04:40.923429+00	
00000000-0000-0000-0000-000000000000	02314f83-591e-4ea8-8c78-18560b235d9f	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"sabej53043@abevw.com","user_id":"e33d18ae-872a-4932-b25f-c57372ac3f84","user_phone":""}}	2024-09-30 02:23:23.60346+00	
00000000-0000-0000-0000-000000000000	fbe7d2eb-d849-492b-af14-009c27a3045a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:28:54.35423+00	
00000000-0000-0000-0000-000000000000	7a28c680-7746-4370-b89e-b1028ccb893b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:28:54.3625+00	
00000000-0000-0000-0000-000000000000	36b78c48-bf2f-46ca-917c-53c8adba319f	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 01:28:55.133515+00	
00000000-0000-0000-0000-000000000000	449c425c-adc0-49e7-84ab-c040135cd6c3	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:28:55.532247+00	
00000000-0000-0000-0000-000000000000	49bf4cd2-ffdb-4df0-8056-f755067b834a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:28:55.532939+00	
00000000-0000-0000-0000-000000000000	761327d2-3d60-4066-804e-fa915d792f1b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 01:30:24.120827+00	
00000000-0000-0000-0000-000000000000	e03da376-e13b-48ac-82f0-f7375551d027	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:30:24.28804+00	
00000000-0000-0000-0000-000000000000	7b4c74e6-14ea-4c56-98c6-6c13fac49e0f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:30:24.289386+00	
00000000-0000-0000-0000-000000000000	582a570a-d678-4150-81ab-da45fe94b2c9	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 01:30:38.92194+00	
00000000-0000-0000-0000-000000000000	5d627e41-4504-4d1d-b6b2-92101dab717a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:30:39.271359+00	
00000000-0000-0000-0000-000000000000	b32c57fe-29ef-476e-a59d-f1cde65af5ac	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 01:30:39.272558+00	
00000000-0000-0000-0000-000000000000	e26aa6db-00cd-4fb6-b36f-aa3ed2e93ed0	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-01 01:47:26.46291+00	
00000000-0000-0000-0000-000000000000	9a8f8dbe-9407-4ca2-9b5a-2794aae02499	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 01:47:29.865397+00	
00000000-0000-0000-0000-000000000000	7485ddf6-5f33-4cc7-ad64-2e5b1acb5194	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 01:47:30.227264+00	
00000000-0000-0000-0000-000000000000	a5bb438d-97f0-4839-8392-7da68467cbe8	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-01 02:05:44.118895+00	
00000000-0000-0000-0000-000000000000	af0edc11-329c-4209-b4ee-098d80dd6c33	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:05:55.105655+00	
00000000-0000-0000-0000-000000000000	65e7390b-9a44-4040-904a-359d99be7ffc	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:05:55.39923+00	
00000000-0000-0000-0000-000000000000	b492541f-675a-402d-ae38-8c4c01f2dacd	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-01 02:06:44.386329+00	
00000000-0000-0000-0000-000000000000	9f097943-e46f-4ab8-8c09-83149d639f6b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:06:50.265612+00	
00000000-0000-0000-0000-000000000000	2d1a3f6b-be87-468e-91c4-ec94b078aca9	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:06:50.477067+00	
00000000-0000-0000-0000-000000000000	17dcfe75-646e-4f52-8d3a-32454c6509f3	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:07:06.198343+00	
00000000-0000-0000-0000-000000000000	704d4f4b-ee79-4219-abd2-62063dde0067	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:07:06.295158+00	
00000000-0000-0000-0000-000000000000	efdec615-0938-4a52-b173-bf193acc6c94	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:08:31.450627+00	
00000000-0000-0000-0000-000000000000	530b00ad-d25e-4305-b2ef-7bb74691d176	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:08:31.503725+00	
00000000-0000-0000-0000-000000000000	3153db0e-4be0-448a-9a36-5a95ccd98762	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:08:53.461783+00	
00000000-0000-0000-0000-000000000000	ec37e029-63ed-48b5-9360-cf19c01c39f8	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:08:54.036143+00	
00000000-0000-0000-0000-000000000000	45384837-2a7b-448d-b188-f5d102a84725	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-01 02:10:31.146107+00	
00000000-0000-0000-0000-000000000000	85f531e7-628a-4612-b35a-e0f585ad7f53	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:10:34.973494+00	
00000000-0000-0000-0000-000000000000	75a7168f-84e2-4677-bd51-0a5177b58f6d	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:10:34.985646+00	
00000000-0000-0000-0000-000000000000	b0a26830-d8f4-44c3-9153-0809b4c26259	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:11:37.972352+00	
00000000-0000-0000-0000-000000000000	5041d632-7f26-4cb5-90a2-b46f5eefde37	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:11:41.445916+00	
00000000-0000-0000-0000-000000000000	ac687424-17eb-40d8-99d0-11f0a9de9eb8	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:11:41.477068+00	
00000000-0000-0000-0000-000000000000	f38e612b-80f0-4410-bbab-32cfc8f8db74	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:16:24.761444+00	
00000000-0000-0000-0000-000000000000	5875997a-2eb8-4e6d-a0fb-d9afd4fa63f8	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:16:24.777082+00	
00000000-0000-0000-0000-000000000000	008b1f1a-012d-4a11-a81e-6095fc758fe3	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:18:44.759489+00	
00000000-0000-0000-0000-000000000000	7df64bb8-31b1-400f-ade8-e9978e83aca7	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:21:38.409776+00	
00000000-0000-0000-0000-000000000000	ddfb1853-9b48-4fc5-802a-0540ae005521	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:22:19.121568+00	
00000000-0000-0000-0000-000000000000	257b346f-27ad-42c7-8413-4af4ab339454	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:23:14.177067+00	
00000000-0000-0000-0000-000000000000	2a248d4a-d8b8-4252-8f02-48315dbe6498	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:23:17.203009+00	
00000000-0000-0000-0000-000000000000	d4c367d1-4035-4725-b293-162771ab7233	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:23:26.375104+00	
00000000-0000-0000-0000-000000000000	2cf433f0-ad31-4ff1-81e0-1ed5828fe008	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:23:47.11855+00	
00000000-0000-0000-0000-000000000000	d215112d-9ca1-4397-b23e-fcbb416d0324	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:38:36.551815+00	
00000000-0000-0000-0000-000000000000	b911305b-8af7-46cf-beef-9295806c583b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:38:54.599226+00	
00000000-0000-0000-0000-000000000000	1f22d839-8aad-4730-ba22-5fc82f633aa9	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:39:36.251959+00	
00000000-0000-0000-0000-000000000000	506c9355-2da9-4fae-b0cf-9cde0f196ae4	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:39:56.283908+00	
00000000-0000-0000-0000-000000000000	51f61ab8-25b6-4f71-a1f6-7fa48e1f893c	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-01 02:40:16.728135+00	
00000000-0000-0000-0000-000000000000	a1ae4a97-2924-49d4-bc5e-437644ce2840	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 06:34:52.662564+00	
00000000-0000-0000-0000-000000000000	b625e96e-2ea6-492b-b368-c64cee2ece47	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-01 06:34:52.666444+00	
00000000-0000-0000-0000-000000000000	1f063c16-a341-47ae-836a-dfe1ca2fbe76	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 00:24:06.258513+00	
00000000-0000-0000-0000-000000000000	c6c6ebde-2862-4d58-9027-6cabe6c6829c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 00:24:06.262919+00	
00000000-0000-0000-0000-000000000000	6ce4d10a-7ae3-4ea6-b019-0a9a5cb06f1a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 01:22:31.679243+00	
00000000-0000-0000-0000-000000000000	38820a1b-7754-471c-890c-0ef1f764f347	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 01:22:31.682432+00	
00000000-0000-0000-0000-000000000000	b568a3d4-92f8-4926-95a4-6dd53e226144	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 01:44:55.915316+00	
00000000-0000-0000-0000-000000000000	6d8e3df6-73e4-4c9b-8d1e-9162e3ac4567	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 01:44:55.994106+00	
00000000-0000-0000-0000-000000000000	1abaa814-8ee9-4a5a-afb7-90ccf474866f	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:25:49.688467+00	
00000000-0000-0000-0000-000000000000	0896c76a-6bac-4b13-be08-6e997839833f	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:25:49.803009+00	
00000000-0000-0000-0000-000000000000	567dd801-8758-40b3-9177-a3aaa8aa39b9	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:26:16.619289+00	
00000000-0000-0000-0000-000000000000	22ed0c22-413f-490e-a906-f01bc6097574	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:26:16.752944+00	
00000000-0000-0000-0000-000000000000	d466aa61-8d31-44df-922c-3c18b86df1fe	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:26:47.734186+00	
00000000-0000-0000-0000-000000000000	a715ee11-7a40-4b6f-bcf2-e2e2c16439f5	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:26:48.791714+00	
00000000-0000-0000-0000-000000000000	b64efb88-5708-4677-a14a-9a1cecacc34b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:28:51.429879+00	
00000000-0000-0000-0000-000000000000	dc2bd36c-cbf8-48c2-8cdf-971f600ced5e	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 02:28:51.477228+00	
00000000-0000-0000-0000-000000000000	85f9b0fa-5653-441a-8119-98ed7b8121f5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"Mf27AmPksSkvXRI5nzgJWFZOucyDc0-stpiNVPe4pO0","user_id":"e33d18ae-872a-4932-b25f-c57372ac3f84","user_phone":"nIh4vKX4phSa4sL"}}	2024-10-02 02:55:53.323106+00	
00000000-0000-0000-0000-000000000000	1bcb7988-a79e-486f-9890-0b458ce8ec72	{"action":"user_confirmation_requested","actor_id":"40addfbf-eb76-4168-a03b-ac07036832fc","actor_username":"dcykbowxhxjhifjfmw@ytnhy.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-10-02 02:57:47.292927+00	
00000000-0000-0000-0000-000000000000	8753d92b-f4b4-4e86-a2b2-b211b8e7d299	{"action":"user_signedup","actor_id":"40addfbf-eb76-4168-a03b-ac07036832fc","actor_username":"dcykbowxhxjhifjfmw@ytnhy.com","actor_via_sso":false,"log_type":"team"}	2024-10-02 02:58:31.495354+00	
00000000-0000-0000-0000-000000000000	89d53aeb-b3c5-4444-b895-59fa2eac5985	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"sabej53043@abevw.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 02:59:27.307552+00	
00000000-0000-0000-0000-000000000000	9785b882-10f0-4b25-b430-650b79f1909d	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"dcykbowxhxjhifjfmw@ytnhy.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:10:42.366089+00	
00000000-0000-0000-0000-000000000000	b0a7c387-5068-49eb-bb24-cdc0e1f8070a	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"sabej53043@abevw.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:11:08.591314+00	
00000000-0000-0000-0000-000000000000	065362a0-6434-463a-9876-f8a40d768191	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"dcykbowxhxjhifjfmw@ytnhy.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:24:41.936145+00	
00000000-0000-0000-0000-000000000000	0a803555-b32f-4fe3-8176-9df4cc48c617	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"sabej53043@abevw.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:24:59.910821+00	
00000000-0000-0000-0000-000000000000	cf8c0ef4-1465-40db-a7fc-e83e8a510485	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 03:29:07.049013+00	
00000000-0000-0000-0000-000000000000	028935b1-34db-489b-9400-11d24eac27d6	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 03:29:07.050705+00	
00000000-0000-0000-0000-000000000000	5406dcfa-5ba1-4e98-a19e-40e0ecae4d8f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 03:29:11.174471+00	
00000000-0000-0000-0000-000000000000	72fb52f3-ef71-4cf2-97af-1f38b8a42e4c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 03:29:11.175034+00	
00000000-0000-0000-0000-000000000000	a7aa41c7-03bf-496c-8d41-0e19fa5662b6	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-02 03:35:19.291887+00	
00000000-0000-0000-0000-000000000000	bf5c5bed-b325-4508-a16f-30f2c0a76278	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 03:35:37.703823+00	
00000000-0000-0000-0000-000000000000	de3c58eb-6366-4fb2-8fce-6420cfe6540f	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 03:35:37.831867+00	
00000000-0000-0000-0000-000000000000	efbdd756-b3c5-4669-a511-cd169a937ab5	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-02 03:35:54.244849+00	
00000000-0000-0000-0000-000000000000	3c405931-521f-4f3d-b00f-416348850761	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 03:38:42.217437+00	
00000000-0000-0000-0000-000000000000	5b18e500-1b6d-47d5-bf32-83e0451c250e	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 03:38:42.26996+00	
00000000-0000-0000-0000-000000000000	44a48122-1769-4676-824e-cb7bb99756aa	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"example@gmail.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:44:04.705397+00	
00000000-0000-0000-0000-000000000000	143939a2-c81d-468e-8d8b-be6a1a306a09	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"sabej53043@abevw.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:45:08.958535+00	
00000000-0000-0000-0000-000000000000	44de3391-98e1-440e-b9e3-a3e9ea334981	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"example@gmail.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:53:11.906478+00	
00000000-0000-0000-0000-000000000000	bd7cbb86-b926-47f2-9ee4-4de6bb912b50	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"example@gmail.com","user_id":"40addfbf-eb76-4168-a03b-ac07036832fc","user_phone":""}}	2024-10-02 03:53:54.237559+00	
00000000-0000-0000-0000-000000000000	79e07abb-4000-46bf-bfd0-0be4c7ebe4fa	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 06:59:35.994512+00	
00000000-0000-0000-0000-000000000000	23f14ae6-53e1-4063-920f-6ed721a4fbbb	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 06:59:36.006347+00	
00000000-0000-0000-0000-000000000000	01c9da9e-8809-49b6-bb3c-25393ef48cea	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 18:06:58.723576+00	
00000000-0000-0000-0000-000000000000	9b2dd82d-b5b9-4053-9c59-262d51531696	{"action":"user_confirmation_requested","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-10-02 18:50:34.99553+00	
00000000-0000-0000-0000-000000000000	0cc465d4-772d-4479-a085-a1090dd36495	{"action":"user_signedup","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"team"}	2024-10-02 18:50:44.202337+00	
00000000-0000-0000-0000-000000000000	7addcc12-2826-48d5-bcfd-41a6ab698bb6	{"action":"login","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 18:51:25.686042+00	
00000000-0000-0000-0000-000000000000	67179c9e-2838-486d-97e4-67e1c5c914d7	{"action":"login","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-02 18:51:25.901563+00	
00000000-0000-0000-0000-000000000000	d71a63ae-ff2f-4b8e-9acf-17c138c6e640	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 19:05:23.399747+00	
00000000-0000-0000-0000-000000000000	956f5074-2ce6-44a9-b596-5c6e8642a55f	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 19:05:23.400523+00	
00000000-0000-0000-0000-000000000000	e18cd92f-61d1-42bb-9978-5e6180792ca9	{"action":"token_refreshed","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 19:49:34.937431+00	
00000000-0000-0000-0000-000000000000	529c3bd5-ac9e-4913-8ee3-67047f4e79e5	{"action":"token_revoked","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 19:49:34.938245+00	
00000000-0000-0000-0000-000000000000	0654e1cb-7890-4b70-ac3b-8eb18348e777	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 20:03:24.17809+00	
00000000-0000-0000-0000-000000000000	3f0d94c0-7544-4d46-8f1f-1c730080025e	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 20:03:24.178885+00	
00000000-0000-0000-0000-000000000000	8f4704f9-e428-4246-95dd-c3330d1ec5a2	{"action":"token_refreshed","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 20:47:35.63381+00	
00000000-0000-0000-0000-000000000000	5d173cf0-1c84-47ec-9921-f941c0b1fc93	{"action":"token_revoked","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 20:47:35.634592+00	
00000000-0000-0000-0000-000000000000	cc26ddbd-26c2-4c0e-a05f-bdbdcafcbed2	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 21:01:24.944636+00	
00000000-0000-0000-0000-000000000000	8e2cf4dc-52ec-4aa1-9c84-2f35a103fb81	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 21:01:24.945428+00	
00000000-0000-0000-0000-000000000000	e736ec2d-4524-45d3-bf2e-b183fc241166	{"action":"token_refreshed","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 22:03:17.720384+00	
00000000-0000-0000-0000-000000000000	eea8aa05-2892-4f83-b1f2-a815971c0dc6	{"action":"token_revoked","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 22:03:17.722036+00	
00000000-0000-0000-0000-000000000000	77a65770-5d01-4a41-807d-3a9323fc4113	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 22:03:17.757357+00	
00000000-0000-0000-0000-000000000000	791c2fe6-76e4-4420-bceb-c282e88b95aa	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 22:03:17.757911+00	
00000000-0000-0000-0000-000000000000	d28995d6-dd32-46e7-bd2e-fea0248fccf1	{"action":"token_refreshed","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 22:04:55.930557+00	
00000000-0000-0000-0000-000000000000	771b4a4a-b9f7-4ff2-9a6f-ea61e670b156	{"action":"token_revoked","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-02 22:04:55.931418+00	
00000000-0000-0000-0000-000000000000	afccc610-072c-46d1-8ee7-38afd6200f42	{"action":"token_refreshed","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-03 00:29:48.808217+00	
00000000-0000-0000-0000-000000000000	37028708-d7c8-44c4-ba5e-1eae54372d26	{"action":"token_revoked","actor_id":"c15bca29-43e1-4536-a709-7e8da1d11758","actor_username":"tuadmndoatnfqbeebp@hthlm.com","actor_via_sso":false,"log_type":"token"}	2024-10-03 00:29:48.814842+00	
00000000-0000-0000-0000-000000000000	1f13d6be-bb38-4a90-b7f0-802fd83efe89	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"tuadmndoatnfqbeebp@hthlm.com","user_id":"c15bca29-43e1-4536-a709-7e8da1d11758","user_phone":""}}	2024-10-03 01:28:32.681879+00	
00000000-0000-0000-0000-000000000000	6fb697e5-6b56-47c5-b816-0ae138de2461	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 00:50:23.637609+00	
00000000-0000-0000-0000-000000000000	98d19a27-c713-4305-9d99-158c1075a9a4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 00:50:23.645163+00	
00000000-0000-0000-0000-000000000000	2d783d53-cb33-41ef-9190-176e8698d3ee	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 00:50:54.018828+00	
00000000-0000-0000-0000-000000000000	6fb5f2ce-a9b0-4c72-a4b5-009f79874add	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 00:50:54.019401+00	
00000000-0000-0000-0000-000000000000	28b68b09-43a2-4dce-b94b-209209ae7eb8	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 01:48:51.161862+00	
00000000-0000-0000-0000-000000000000	2f693fd2-62f1-4931-b2c1-1d2ccc9ad573	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 01:48:51.163655+00	
00000000-0000-0000-0000-000000000000	aac30e32-1b55-4046-a112-f491275ec0d0	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 05:38:42.271889+00	
00000000-0000-0000-0000-000000000000	b317b8a1-91b5-4863-8509-fc87a83fe26b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-04 05:38:42.273995+00	
00000000-0000-0000-0000-000000000000	567b102b-9ae7-4bd1-8b32-07556031ac4f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 13:41:22.609975+00	
00000000-0000-0000-0000-000000000000	c0e073cc-f47f-4116-8c81-a7f001580f7e	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 13:41:22.619969+00	
00000000-0000-0000-0000-000000000000	b47ccf7f-fcd3-4da0-9863-e9415ccc8da3	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 13:42:18.004191+00	
00000000-0000-0000-0000-000000000000	90739e61-1f91-4e18-bfdf-306e1a9670e1	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 13:42:18.00663+00	
00000000-0000-0000-0000-000000000000	0f811745-dacb-4883-8be8-ad624101328c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 14:39:24.236511+00	
00000000-0000-0000-0000-000000000000	dc017016-a81e-4af2-b253-71f3404f0c7b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 14:39:24.239424+00	
00000000-0000-0000-0000-000000000000	7d717fdb-9a0d-4d8e-b573-7654703311e5	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 14:50:27.703422+00	
00000000-0000-0000-0000-000000000000	9bc66bb3-1d35-4946-ac10-292fed9a4d29	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 14:50:27.705329+00	
00000000-0000-0000-0000-000000000000	bc485fbf-109e-491d-96a9-d3255673ba87	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 15:37:25.010772+00	
00000000-0000-0000-0000-000000000000	b1e93e0e-9c14-4cd3-86b2-53bb30e00de4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 15:37:25.012834+00	
00000000-0000-0000-0000-000000000000	1a31619b-49f7-4434-87a4-d38b034cfebd	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 20:30:11.909808+00	
00000000-0000-0000-0000-000000000000	7cace131-7bf8-47cc-ad7e-c05777655674	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 20:30:11.911892+00	
00000000-0000-0000-0000-000000000000	0496184a-6810-486a-92ba-c8bc0b96ceb0	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 23:45:21.847574+00	
00000000-0000-0000-0000-000000000000	f744284d-8679-4b33-9c03-b89701d6969c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-06 23:45:21.848839+00	
00000000-0000-0000-0000-000000000000	62990fe6-c08d-4715-8bc3-95b0d61b569b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-08 02:14:02.480252+00	
00000000-0000-0000-0000-000000000000	ccdcff19-6fd9-4153-9af5-484878d3a2bf	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-08 02:14:02.487152+00	
00000000-0000-0000-0000-000000000000	79ab5d1e-c5e2-425c-9b4c-18dc0ec4fd9f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-08 02:35:11.655065+00	
00000000-0000-0000-0000-000000000000	ebde1016-85ff-4571-a2a8-58dbde697611	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-08 02:35:11.657304+00	
00000000-0000-0000-0000-000000000000	e7ac5807-cb4d-4b9a-8baf-35a3ada27c55	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 01:36:02.905399+00	
00000000-0000-0000-0000-000000000000	eecd0d3d-31ba-4032-bdbe-00abbc9d7593	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 01:36:02.913819+00	
00000000-0000-0000-0000-000000000000	05287b61-3e4e-4bef-9823-354212fda7c6	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 02:56:27.780842+00	
00000000-0000-0000-0000-000000000000	20f863db-fcc4-48e8-b9f7-b24ae29e03e1	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 02:56:27.787253+00	
00000000-0000-0000-0000-000000000000	047a3635-8ac0-4ea2-aee2-c3208efa9c55	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-09 22:02:06.955806+00	
00000000-0000-0000-0000-000000000000	d0acc271-8cac-4aab-8c5f-2eb4ce41e64e	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-09 22:02:06.953347+00	
00000000-0000-0000-0000-000000000000	e2fbfb16-b53e-41bb-b56f-2cb4346500cc	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:00:24.97681+00	
00000000-0000-0000-0000-000000000000	c1021c73-f239-46df-a4df-150c4a766d85	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:00:24.980519+00	
00000000-0000-0000-0000-000000000000	414dfa5e-a6a6-44ae-b591-c7b84fd1e5e4	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:17:20.174846+00	
00000000-0000-0000-0000-000000000000	3cdf4b84-d60d-4319-888d-3395f0dd83be	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:17:20.177826+00	
00000000-0000-0000-0000-000000000000	4d119f21-e09a-4f60-915d-04ba34994956	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:54:36.091196+00	
00000000-0000-0000-0000-000000000000	c26c26bc-0dd3-40ed-8247-70d856f34ff4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:54:36.092626+00	
00000000-0000-0000-0000-000000000000	b5c59385-9106-43aa-8788-cdfa1e972200	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-09 23:54:38.379449+00	
00000000-0000-0000-0000-000000000000	d6dd0434-f2e1-447c-aa6e-9de514b486cd	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-09 23:54:49.781824+00	
00000000-0000-0000-0000-000000000000	74d71c31-53c3-43ed-b8eb-fb8b718772ad	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-09 23:56:09.101236+00	
00000000-0000-0000-0000-000000000000	83d2e8ff-67c1-4095-924e-329c8ba37475	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-09 23:56:09.118141+00	
00000000-0000-0000-0000-000000000000	eb923900-6c17-4de7-b347-b2baa42aca93	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:58:28.815255+00	
00000000-0000-0000-0000-000000000000	bce14ca4-49c5-4485-ba9b-af95d65f7bdc	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-09 23:58:28.817731+00	
00000000-0000-0000-0000-000000000000	2b53f9dd-8230-406f-ad90-19f0aa1ecd86	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-10 00:00:26.550586+00	
00000000-0000-0000-0000-000000000000	21dca631-bad6-4d7a-a2f3-fae6d3111ab7	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-10 00:00:26.783786+00	
00000000-0000-0000-0000-000000000000	abac1a45-8e05-4873-b735-271a17deba26	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-10 00:03:08.167172+00	
00000000-0000-0000-0000-000000000000	5becbc9a-ba01-4034-94b1-71d9d906aa4a	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:34:01.387144+00	
00000000-0000-0000-0000-000000000000	a90837af-fefc-4eaf-a6eb-10e4df2c33dc	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:34:01.394024+00	
00000000-0000-0000-0000-000000000000	5b4e6494-dd7a-4238-8aef-162475b2011b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:37:45.266232+00	
00000000-0000-0000-0000-000000000000	b22eb8cf-6e72-45ad-befc-ac4908926475	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:37:45.290307+00	
00000000-0000-0000-0000-000000000000	d8e64170-95f2-48fb-90f9-d9818ed2b42a	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:38:35.321587+00	
00000000-0000-0000-0000-000000000000	b4eb1239-a288-4eb7-8c55-83c538344ccb	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:38:35.484429+00	
00000000-0000-0000-0000-000000000000	3e0b75ee-1a70-4832-b65d-80b7465d4251	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:45:08.700292+00	
00000000-0000-0000-0000-000000000000	863caac7-a1b5-4145-aee9-c32f16ba38aa	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 03:45:08.714183+00	
00000000-0000-0000-0000-000000000000	045a26e6-06d2-4dce-9598-9357ffaa9ecf	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-11 07:12:38.753347+00	
00000000-0000-0000-0000-000000000000	0764c2f6-8b7b-4cb6-a93e-9417af40dfc5	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-11 07:12:38.758363+00	
00000000-0000-0000-0000-000000000000	8970db84-138c-47b0-b516-efcf4b2de218	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-11 22:33:57.814064+00	
00000000-0000-0000-0000-000000000000	40f4ad6a-eb69-4408-ac4b-c6f76acc0e13	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-11 22:33:57.820383+00	
00000000-0000-0000-0000-000000000000	9e5dfe1f-6cd9-4e25-900c-f5037947d21f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-11 22:43:17.237817+00	
00000000-0000-0000-0000-000000000000	fb8f424e-7850-4ba4-bb1a-9da77cb4ce5a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-11 22:43:17.238581+00	
00000000-0000-0000-0000-000000000000	9b4e1393-c60c-45e5-aa68-89b35f443d14	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-11 22:47:34.926237+00	
00000000-0000-0000-0000-000000000000	e6bca6c9-706b-4066-9d92-071f88beec9d	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 23:14:45.641667+00	
00000000-0000-0000-0000-000000000000	e27c99ae-bc30-46fb-a448-56820c490c75	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 23:14:45.891926+00	
00000000-0000-0000-0000-000000000000	9984d14c-fbe7-4d59-a810-d40177f46d1b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 23:31:53.431175+00	
00000000-0000-0000-0000-000000000000	3dc1fdd8-7859-4163-bdc6-f60a15091cd2	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-11 23:31:53.445909+00	
00000000-0000-0000-0000-000000000000	eb27c66d-a9e4-451d-8666-2fa2c6ad7567	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 00:39:22.403836+00	
00000000-0000-0000-0000-000000000000	3e440dba-d2ce-4213-bbe5-76f7dba29b7e	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 00:39:22.407073+00	
00000000-0000-0000-0000-000000000000	4796ea00-603c-4c6f-8165-c8f38ebb6d73	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 02:28:10.979377+00	
00000000-0000-0000-0000-000000000000	9cfb580a-cf1e-4865-95fb-82eb7c95238b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 02:28:10.982858+00	
00000000-0000-0000-0000-000000000000	2e51ec20-dd10-4123-883c-14272502ed61	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 03:30:46.269379+00	
00000000-0000-0000-0000-000000000000	368a8144-8cce-494b-bf87-65aa762acf37	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 03:30:46.270634+00	
00000000-0000-0000-0000-000000000000	8ffa846d-8c3d-4aae-8970-944f6f78a8e8	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 07:24:19.436515+00	
00000000-0000-0000-0000-000000000000	3ddf6c07-2fa6-42ab-be0e-3977b0432ba6	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 07:24:19.448107+00	
00000000-0000-0000-0000-000000000000	e0e1abec-2ca6-4ea0-a15c-17d82ed64831	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 12:55:52.708203+00	
00000000-0000-0000-0000-000000000000	3f905866-0d23-44b7-abe2-774b01b63f4a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 12:55:52.710295+00	
00000000-0000-0000-0000-000000000000	7ad43648-f187-47ff-b603-b6d9187ed648	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 13:53:59.10202+00	
00000000-0000-0000-0000-000000000000	d74c51aa-1450-4051-b4e2-b41f2605addc	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 13:53:59.104768+00	
00000000-0000-0000-0000-000000000000	83904127-fdee-47ba-a64f-3363a567780b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 14:52:00.150079+00	
00000000-0000-0000-0000-000000000000	2a7c8a43-af98-4eec-8040-a8e8d3af2d90	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 14:52:00.151737+00	
00000000-0000-0000-0000-000000000000	6b231cc0-ab01-4c3c-82e5-b723f695001a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 15:03:43.754061+00	
00000000-0000-0000-0000-000000000000	8305aed2-f4e3-4bf6-a92d-47b60e0d895d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 15:03:43.756035+00	
00000000-0000-0000-0000-000000000000	6f5ec146-d8f0-4455-8606-c833c0a838da	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-12 15:03:46.053715+00	
00000000-0000-0000-0000-000000000000	cd12a4a7-d3a2-4899-abd2-e661b6b77869	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-12 15:03:54.3532+00	
00000000-0000-0000-0000-000000000000	9893d0f3-ec57-4694-b9dd-423356d5c347	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-12 15:03:54.365753+00	
00000000-0000-0000-0000-000000000000	381cae63-29c7-4c7a-968f-f74be60f2227	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 17:39:02.667594+00	
00000000-0000-0000-0000-000000000000	8f859036-c75d-4ff2-a75e-3ada1edc16f5	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 17:39:02.676912+00	
00000000-0000-0000-0000-000000000000	a0dbceff-84de-40f0-b032-433a643a5ea1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 18:54:37.718406+00	
00000000-0000-0000-0000-000000000000	dd848370-7d77-425f-8ae8-9a1e101e5c66	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 18:54:37.720206+00	
00000000-0000-0000-0000-000000000000	9086edef-177f-4295-aabc-a20d3c42d50e	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 21:07:12.375898+00	
00000000-0000-0000-0000-000000000000	b902a717-b8f5-430d-acea-3998ea96beca	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 21:07:12.37925+00	
00000000-0000-0000-0000-000000000000	3335cbd1-b891-4c4d-a834-8d0667922c31	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-12 21:28:33.474003+00	
00000000-0000-0000-0000-000000000000	5fcdd38d-389a-4fdf-bd05-447453eccf22	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-12 21:28:33.577114+00	
00000000-0000-0000-0000-000000000000	4ea55c2b-d0c6-4ad8-8cb4-b93f10b6908f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 22:48:09.740221+00	
00000000-0000-0000-0000-000000000000	a53f5c3e-3228-4e1a-b1e1-b1252412fa63	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-12 22:48:09.743141+00	
00000000-0000-0000-0000-000000000000	1e17a20e-8fec-45a9-9b48-2478e1d9f922	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 00:01:17.191237+00	
00000000-0000-0000-0000-000000000000	7b7a6f20-8ae9-408e-8378-022046f7679b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 00:59:43.663096+00	
00000000-0000-0000-0000-000000000000	e1ea6aee-fb7d-4f6f-a71d-561ef538e909	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 00:59:43.665615+00	
00000000-0000-0000-0000-000000000000	61e84e4e-bffe-4a48-a103-4478134ffd30	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 01:57:44.734507+00	
00000000-0000-0000-0000-000000000000	dbddfbd7-b6af-44ef-8dd9-66b72569b859	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 01:57:44.738144+00	
00000000-0000-0000-0000-000000000000	45d61433-6d10-4516-a08a-adab0c48f277	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 02:55:45.654885+00	
00000000-0000-0000-0000-000000000000	1135567d-de11-4bd1-9e2c-72da345640e3	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 02:55:45.657746+00	
00000000-0000-0000-0000-000000000000	843e6654-4c06-45e3-b215-1655442409cc	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 03:56:17.7648+00	
00000000-0000-0000-0000-000000000000	613259f9-df4d-4120-9857-8ae33d160bc5	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 03:56:17.771804+00	
00000000-0000-0000-0000-000000000000	8726fa60-c801-442d-96b3-48992c73f58f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 04:54:17.956685+00	
00000000-0000-0000-0000-000000000000	9257cd37-457c-44d5-98cb-9fdbd8e1303d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 04:54:17.965501+00	
00000000-0000-0000-0000-000000000000	294a4df3-16eb-440e-a73d-d1af088655f6	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 13:51:50.5425+00	
00000000-0000-0000-0000-000000000000	63ab72b3-2e0f-44c9-86b3-bb1b76a14b2b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 13:51:50.548084+00	
00000000-0000-0000-0000-000000000000	4c61fe30-97e8-4294-91a4-403c16cd18bb	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 14:50:17.185452+00	
00000000-0000-0000-0000-000000000000	b2048a7b-a15c-4c0a-ab26-75e5c652deb7	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 14:50:17.187344+00	
00000000-0000-0000-0000-000000000000	5ce9320c-280a-43ba-a55b-540ba86ebcf2	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 15:48:44.683296+00	
00000000-0000-0000-0000-000000000000	38ae20a2-386d-4b76-a7f7-912fda5662c7	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 15:48:44.693049+00	
00000000-0000-0000-0000-000000000000	b7e4d1b9-f0f4-49c7-9377-0e04f3bf794f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 16:46:42.45174+00	
00000000-0000-0000-0000-000000000000	ebf12d61-a71b-4b0a-a044-e59ab4a15b65	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 16:46:42.454583+00	
00000000-0000-0000-0000-000000000000	3f529d76-d31a-4359-beaa-f71232177cad	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 18:21:36.759189+00	
00000000-0000-0000-0000-000000000000	afe6a249-b0e2-4073-9d39-90e4e3d3ea71	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 18:21:36.76206+00	
00000000-0000-0000-0000-000000000000	1b818318-6472-41f1-a284-defdfd767c2c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 18:45:40.223847+00	
00000000-0000-0000-0000-000000000000	485d74b0-d6d3-47bc-9cd1-c94e6ddfa71b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 18:45:40.225171+00	
00000000-0000-0000-0000-000000000000	37317aa2-8e1f-4443-a655-81c85927c914	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 19:19:36.399994+00	
00000000-0000-0000-0000-000000000000	1959fc2b-f670-4916-bd5f-a731f657116d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 19:19:36.40282+00	
00000000-0000-0000-0000-000000000000	27a04d57-b626-4c36-8813-3caebc69c7dd	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 20:06:05.00008+00	
00000000-0000-0000-0000-000000000000	6413dd69-bbf3-477e-957f-1f4688dc470d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 20:06:05.003703+00	
00000000-0000-0000-0000-000000000000	59f4300b-2d5f-49e2-b43a-0cb7a5299f98	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:07:06.257018+00	
00000000-0000-0000-0000-000000000000	3f41be69-b954-4546-b33f-af5f59bd1a09	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-13 20:29:26.922293+00	
00000000-0000-0000-0000-000000000000	bc00b28c-cf02-422d-992c-f76ec18ec662	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:43:50.369252+00	
00000000-0000-0000-0000-000000000000	8815bb5a-0c4b-4b4a-808f-91ff127ee091	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:43:50.552152+00	
00000000-0000-0000-0000-000000000000	99a75616-8189-452f-b288-a478afb0c785	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-13 20:44:48.59731+00	
00000000-0000-0000-0000-000000000000	b960f4a8-0bb7-44ac-9802-f7c72fd7b6a9	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:46:28.63544+00	
00000000-0000-0000-0000-000000000000	e5614caa-8a1d-4b34-a8f7-f5c2ff3fd853	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:46:28.701882+00	
00000000-0000-0000-0000-000000000000	c4403ea8-bd2b-41c0-9a1a-d87d933d8aff	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-13 20:46:39.827894+00	
00000000-0000-0000-0000-000000000000	e4b05055-7465-437c-ae04-f226c5ff4b7b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:47:14.770569+00	
00000000-0000-0000-0000-000000000000	ed0a0f92-1de9-4960-a925-2cbc5d9d6d3b	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:47:14.803659+00	
00000000-0000-0000-0000-000000000000	deba7cbd-7515-483f-bdce-a828a19c290d	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-13 20:47:25.115152+00	
00000000-0000-0000-0000-000000000000	9856d31c-78d6-4772-b5ed-2583cbe1c5cc	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:52:56.470488+00	
00000000-0000-0000-0000-000000000000	dd300238-3dc4-40f3-b5ff-adde983b6100	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:52:56.814833+00	
00000000-0000-0000-0000-000000000000	d17d647c-c1f2-4c4a-9f56-1462a8c45e13	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-13 20:53:10.506853+00	
00000000-0000-0000-0000-000000000000	5b63da92-094e-4db0-91ac-fef3856374b5	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:54:35.5767+00	
00000000-0000-0000-0000-000000000000	48c3c989-97a8-4615-b3d4-eb128220da6f	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-13 20:54:35.595628+00	
00000000-0000-0000-0000-000000000000	edf87af6-ea89-4882-9158-fb9910e9f8bc	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 21:52:44.18106+00	
00000000-0000-0000-0000-000000000000	b4885631-c23f-4501-88ef-3356614a6c0c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 21:52:44.185768+00	
00000000-0000-0000-0000-000000000000	05e0d3d2-16bb-4f23-8ba3-b578f28da219	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 22:02:10.007582+00	
00000000-0000-0000-0000-000000000000	00f7b3a2-8830-4fd3-ab81-187ab1ec67ed	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 22:02:10.009359+00	
00000000-0000-0000-0000-000000000000	1bed3a3d-add6-4394-bb31-d536960d43a3	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 22:50:46.808829+00	
00000000-0000-0000-0000-000000000000	0294fca1-5065-43fa-9406-a72deda7a310	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 22:50:46.809617+00	
00000000-0000-0000-0000-000000000000	d026af70-6283-4418-b353-9b6dfc76ea28	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 23:48:47.971943+00	
00000000-0000-0000-0000-000000000000	166dbf54-9483-4dcb-9980-745ac7dffa9c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-13 23:48:47.974808+00	
00000000-0000-0000-0000-000000000000	edbd5b60-fed9-46bf-863e-ce56197b5715	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 00:46:48.800625+00	
00000000-0000-0000-0000-000000000000	1bf7f268-a4d7-42bf-a75b-1e69d6870d08	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 00:46:48.805292+00	
00000000-0000-0000-0000-000000000000	ddc08989-9a87-4796-ac9f-a38bd3aa5e78	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-14 01:42:41.914957+00	
00000000-0000-0000-0000-000000000000	55879fa7-c02f-4ef8-9d9e-d734ea53b95f	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-14 01:42:42.089698+00	
00000000-0000-0000-0000-000000000000	7808a57f-af1b-4352-b4d9-362630b8f766	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-14 01:53:18.521756+00	
00000000-0000-0000-0000-000000000000	87326461-0b55-4f0c-ba49-9dc41c44adb7	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-14 01:54:51.003574+00	
00000000-0000-0000-0000-000000000000	40f4eb95-f83c-4728-8186-31d662c53f42	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-14 01:54:51.017189+00	
00000000-0000-0000-0000-000000000000	8c888249-931c-4fd6-998c-4adec7ee376e	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-14 02:50:17.362714+00	
00000000-0000-0000-0000-000000000000	bf8ce64c-c499-41e5-90c2-e3408c48e3bd	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-14 02:50:17.517896+00	
00000000-0000-0000-0000-000000000000	13b8fb32-d3fb-4a55-8ce9-014d14244d05	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 02:53:01.093902+00	
00000000-0000-0000-0000-000000000000	d3d77b25-af35-421e-98f6-d3b6b9232c0f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 02:53:01.094914+00	
00000000-0000-0000-0000-000000000000	4c1a07e1-7188-4891-b9a6-93b1fa7433af	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 02:55:43.964376+00	
00000000-0000-0000-0000-000000000000	c6ed8e30-4cf5-453c-859b-171f03eb4281	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 02:55:43.965275+00	
00000000-0000-0000-0000-000000000000	fcfd7d43-1d68-446e-b5a1-81846f8bdf03	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 04:10:16.904821+00	
00000000-0000-0000-0000-000000000000	2d8ca6ec-abe0-4bd2-b344-498d417a9566	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 04:10:16.906065+00	
00000000-0000-0000-0000-000000000000	a55f5912-c24d-4343-bab7-31670674d118	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 04:19:34.419471+00	
00000000-0000-0000-0000-000000000000	cb063689-b3d7-4530-bf40-52773bcbdfcc	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 04:19:34.422015+00	
00000000-0000-0000-0000-000000000000	d36ab222-a591-44d4-9d2f-3e950ee46224	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 21:54:06.80528+00	
00000000-0000-0000-0000-000000000000	a386cad7-2c1d-40e4-bf44-0a2cff6a0005	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 21:54:06.811468+00	
00000000-0000-0000-0000-000000000000	66bfeb2c-8191-437a-9648-19f23b7699e9	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 23:21:31.981874+00	
00000000-0000-0000-0000-000000000000	b300b8ff-57dd-4517-a517-89fd1a5da664	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-14 23:21:31.985221+00	
00000000-0000-0000-0000-000000000000	77aa7c63-f38c-42a9-8227-e31f3a1cd7b5	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 01:43:21.798604+00	
00000000-0000-0000-0000-000000000000	1ff81d97-44bb-47b4-8b81-36dbff746e2f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 01:43:21.803787+00	
00000000-0000-0000-0000-000000000000	084e8fb8-9460-4419-b6e0-58e333d9a9c5	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 02:08:11.856728+00	
00000000-0000-0000-0000-000000000000	78093d64-a48f-49d1-a3e2-6913d23b9918	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 02:08:11.85907+00	
00000000-0000-0000-0000-000000000000	7a6a416f-8739-4f85-b2ca-03a0ff0b64a8	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 22:21:21.425538+00	
00000000-0000-0000-0000-000000000000	99f25304-ef43-4860-a78a-bda306ce0cc2	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 22:21:21.433832+00	
00000000-0000-0000-0000-000000000000	fffd21ae-4004-4986-93ce-2b54d2de797e	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 23:19:44.355982+00	
00000000-0000-0000-0000-000000000000	de1de421-6438-4db9-a475-4e3fe1f2d902	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-15 23:19:44.357693+00	
00000000-0000-0000-0000-000000000000	38b850ac-5067-485b-98f1-b4396e37ca7c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 00:44:24.583822+00	
00000000-0000-0000-0000-000000000000	e71bc57d-2e5e-4cd7-9f67-45ed906de9b5	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 00:44:24.585441+00	
00000000-0000-0000-0000-000000000000	177f2152-bd1d-4d67-b21e-ada857f69ecb	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 01:39:42.878204+00	
00000000-0000-0000-0000-000000000000	498cb7aa-b1da-4cc3-92ea-34c2ef6ab035	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 01:39:42.972617+00	
00000000-0000-0000-0000-000000000000	28cbfab5-07c7-4a5a-963c-06993a3021af	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 01:42:27.652521+00	
00000000-0000-0000-0000-000000000000	63a348f1-4e39-4079-8734-26479091b12d	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 01:44:25.344245+00	
00000000-0000-0000-0000-000000000000	aa883bb9-77a3-4e76-83f0-c5a6037fb899	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 01:44:25.417596+00	
00000000-0000-0000-0000-000000000000	4cb490f6-2232-4e80-b370-75d5d63aea89	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:04:41.486083+00	
00000000-0000-0000-0000-000000000000	44336fd1-8223-41f1-83f3-ac06f5388d56	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:04:41.59792+00	
00000000-0000-0000-0000-000000000000	e98e319c-2266-4f37-adf9-e35282be2829	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 02:04:52.026738+00	
00000000-0000-0000-0000-000000000000	2678dbbb-9db4-4759-b582-8d010f83b2ca	{"action":"logout","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 02:05:18.009491+00	
00000000-0000-0000-0000-000000000000	8f5630c8-9abe-4c39-a7e2-b782f88fdd1d	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:05:44.781822+00	
00000000-0000-0000-0000-000000000000	0eea94a6-9b52-45f3-8ccb-a73bef351ab6	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:05:44.852927+00	
00000000-0000-0000-0000-000000000000	760a11f3-8b6a-459e-894f-18b5e7c11bb6	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:11:51.476208+00	
00000000-0000-0000-0000-000000000000	fff8d83f-932c-403d-895e-9a96823f277e	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:11:52.782674+00	
00000000-0000-0000-0000-000000000000	283946e8-9ffc-443f-8dc7-b293915e6951	{"action":"logout","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 02:21:54.068018+00	
00000000-0000-0000-0000-000000000000	79892db1-af54-4168-aefa-24c5b6af2cbb	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:23:35.17515+00	
00000000-0000-0000-0000-000000000000	f38ae0ad-c01d-4094-95e0-c3ad918aac11	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 02:23:35.232501+00	
00000000-0000-0000-0000-000000000000	e60cf0ff-0145-4797-8b04-8538a3c9a857	{"action":"user_confirmation_requested","actor_id":"d9f130fe-d9e1-4d1c-a160-03c8ad109af4","actor_username":"jubhcivoflhbeaoqhm@nbmbb.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-10-16 02:26:33.399462+00	
00000000-0000-0000-0000-000000000000	125f8bcf-078a-4139-a539-8699ad3dec4b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 03:27:42.633438+00	
00000000-0000-0000-0000-000000000000	0479ea24-d3d8-426c-8f75-006100ffa5a2	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 03:27:42.635575+00	
00000000-0000-0000-0000-000000000000	dcd7e7d8-7a36-4ee0-8af5-f4306e26eca8	{"action":"token_refreshed","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 21:25:23.17268+00	
00000000-0000-0000-0000-000000000000	3a9cd12c-14b6-4ea3-909f-094d57a2cce8	{"action":"token_revoked","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 21:25:23.179064+00	
00000000-0000-0000-0000-000000000000	b345686c-2fda-4d21-b1f9-172bf47010e8	{"action":"logout","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 21:42:57.981913+00	
00000000-0000-0000-0000-000000000000	8194bd59-d165-4a4f-afd5-f46e13b0e721	{"action":"user_confirmation_requested","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-10-16 21:51:03.286887+00	
00000000-0000-0000-0000-000000000000	cda5ba2e-202b-46e6-82bc-d628778abb3f	{"action":"user_signedup","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"team"}	2024-10-16 21:51:15.581423+00	
00000000-0000-0000-0000-000000000000	9d32fcb6-a711-4cd9-80cd-10e418c24c2e	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 21:49:55.519607+00	
00000000-0000-0000-0000-000000000000	4506607f-29cd-4afa-a894-838c34cffb28	{"action":"login","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 21:51:41.360706+00	
00000000-0000-0000-0000-000000000000	8abcc455-f4f1-4986-b8ae-36ff84c21be6	{"action":"login","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 21:51:41.386188+00	
00000000-0000-0000-0000-000000000000	346ecc58-8564-4489-84fc-e9031734c952	{"action":"logout","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 21:54:25.643602+00	
00000000-0000-0000-0000-000000000000	50145c38-aae3-441b-a5d6-53e672ee5c50	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 21:54:53.775713+00	
00000000-0000-0000-0000-000000000000	e917023b-f046-4489-948c-d50cd4e7a235	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 21:54:53.818+00	
00000000-0000-0000-0000-000000000000	1caa9520-98ea-4d3d-8e84-2f58da9f90c0	{"action":"logout","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 22:11:11.899531+00	
00000000-0000-0000-0000-000000000000	9b184e8b-1bd6-44bc-9f20-e2a381004b48	{"action":"login","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 22:13:44.360567+00	
00000000-0000-0000-0000-000000000000	f6dc5685-f335-46b6-91d2-850db24036e3	{"action":"login","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 22:13:44.696048+00	
00000000-0000-0000-0000-000000000000	432a7842-58d4-413a-9a89-198c91a6f2f3	{"action":"logout","actor_id":"94d84199-abd0-4390-af51-8d1e40715a6e","actor_username":"gyqobnlnkkytjbaych@poplk.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 22:14:14.864309+00	
00000000-0000-0000-0000-000000000000	167975d8-16d6-471c-94f2-eeeed7a9141d	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 22:15:57.169778+00	
00000000-0000-0000-0000-000000000000	40295cd8-85c2-4192-922e-dca39f8e8f80	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 22:15:57.238685+00	
00000000-0000-0000-0000-000000000000	41c78814-8051-4ddc-a252-103b0e458c4c	{"action":"logout","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 22:23:31.484618+00	
00000000-0000-0000-0000-000000000000	a93c2037-f48c-4c87-81a9-64b79c5541c9	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 22:23:44.415975+00	
00000000-0000-0000-0000-000000000000	b3a7d863-8ea9-4f0e-94a0-903a563d4ac6	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 22:23:44.571563+00	
00000000-0000-0000-0000-000000000000	7c332ff4-d2ef-4432-b247-97498c043ffc	{"action":"logout","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 22:27:53.557786+00	
00000000-0000-0000-0000-000000000000	82576c9d-4cb3-4a4f-979d-a7fce35e57e9	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 23:39:35.170399+00	
00000000-0000-0000-0000-000000000000	1e3e2d3b-fe4c-42d9-b3f4-1b4cbee42e81	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-16 23:39:35.171205+00	
00000000-0000-0000-0000-000000000000	11edee29-1146-4582-888a-55d4c249d8e6	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-16 23:40:23.298725+00	
00000000-0000-0000-0000-000000000000	ae2d394c-075e-4650-be65-ed653da95443	{"action":"user_confirmation_requested","actor_id":"24c17fbe-5b94-4f07-a473-5225a245263c","actor_username":"ghsfzsiovtsavnjeog@poplk.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-10-16 23:42:22.837202+00	
00000000-0000-0000-0000-000000000000	8caee2dd-cf5a-43d1-8591-671fc8053533	{"action":"user_signedup","actor_id":"24c17fbe-5b94-4f07-a473-5225a245263c","actor_username":"ghsfzsiovtsavnjeog@poplk.com","actor_via_sso":false,"log_type":"team"}	2024-10-16 23:43:01.132928+00	
00000000-0000-0000-0000-000000000000	d2d5de9b-ec46-4250-8055-b851ce188ca3	{"action":"login","actor_id":"24c17fbe-5b94-4f07-a473-5225a245263c","actor_username":"ghsfzsiovtsavnjeog@poplk.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 23:44:21.345144+00	
00000000-0000-0000-0000-000000000000	177264fa-3bc7-42a8-813e-e0ed0ca31b4b	{"action":"login","actor_id":"24c17fbe-5b94-4f07-a473-5225a245263c","actor_username":"ghsfzsiovtsavnjeog@poplk.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-16 23:44:21.365486+00	
00000000-0000-0000-0000-000000000000	6e269c3e-5c35-4648-89fe-82f9f8f8f250	{"action":"logout","actor_id":"24c17fbe-5b94-4f07-a473-5225a245263c","actor_username":"ghsfzsiovtsavnjeog@poplk.com","actor_via_sso":false,"log_type":"account"}	2024-10-17 00:05:31.167932+00	
00000000-0000-0000-0000-000000000000	425d67b0-6e81-4d36-9904-b508134ec213	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-17 00:05:32.409573+00	
00000000-0000-0000-0000-000000000000	ae0e84e8-e34c-4580-bf98-61fd4709b6de	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-17 00:05:32.667174+00	
00000000-0000-0000-0000-000000000000	4d563a54-e23e-4740-9336-0c00886f76fb	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 01:03:39.347254+00	
00000000-0000-0000-0000-000000000000	de18b2ae-e772-4cc6-b927-7b92020dfdc5	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 01:03:39.348726+00	
00000000-0000-0000-0000-000000000000	ebea7791-a84a-4627-8d47-13b4b620afab	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 02:01:40.225538+00	
00000000-0000-0000-0000-000000000000	ac7532fd-ae22-4730-b6b0-4eebe00d8383	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 02:01:40.229299+00	
00000000-0000-0000-0000-000000000000	7b659038-a674-41fc-b620-8a67e07f00b7	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 21:41:48.995475+00	
00000000-0000-0000-0000-000000000000	52e684f1-32c9-4df5-8450-5fa40f6b5ed7	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 21:41:49.003412+00	
00000000-0000-0000-0000-000000000000	f55b1f6d-055c-498a-b938-a0936de118bf	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 21:49:55.527026+00	
00000000-0000-0000-0000-000000000000	b334428f-0bb8-4fff-a6c5-6230d694e3c1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 22:40:15.040609+00	
00000000-0000-0000-0000-000000000000	d7ffaf81-4b66-4723-9fd7-eb4425251c5b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 22:40:15.04146+00	
00000000-0000-0000-0000-000000000000	e54a2273-11a6-46c2-b104-4ac585570de6	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 22:49:19.802447+00	
00000000-0000-0000-0000-000000000000	31962688-45ca-4dbb-a898-5117a5720119	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-17 22:49:19.803304+00	
00000000-0000-0000-0000-000000000000	2b2acd6b-e449-496a-856a-f608b59cc228	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 00:15:04.326527+00	
00000000-0000-0000-0000-000000000000	4f6aa887-8a6f-48f8-a9f3-f14467f8b83c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 00:15:04.339269+00	
00000000-0000-0000-0000-000000000000	9edb7281-323d-4025-9559-a643f53ed81b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 03:32:07.939463+00	
00000000-0000-0000-0000-000000000000	5ba49021-ef5d-4ece-bf75-466a3703dea2	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 03:32:07.94275+00	
00000000-0000-0000-0000-000000000000	85c4d008-f27f-46c5-8f35-dc5670aa83c9	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 22:31:30.286928+00	
00000000-0000-0000-0000-000000000000	4fff78ad-db71-421b-985a-2f08bd9f70ae	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 22:31:30.300587+00	
00000000-0000-0000-0000-000000000000	bb5a4774-6abe-4aa6-a148-939083c4508d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 22:31:33.867043+00	
00000000-0000-0000-0000-000000000000	236b0ed5-adcb-4173-be66-f16b517bd441	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-18 22:31:33.869009+00	
00000000-0000-0000-0000-000000000000	9c2d5c35-b98f-40a0-82ca-cfe94e0aab5c	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-18 22:33:47.755787+00	
00000000-0000-0000-0000-000000000000	e3422587-f81d-42d0-940d-8fb19077d583	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-18 22:33:53.266756+00	
00000000-0000-0000-0000-000000000000	4477809d-82cb-42c0-b3a6-c68cff75d480	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-18 22:33:53.323435+00	
00000000-0000-0000-0000-000000000000	cdd0b62b-6ff8-4279-a66b-02d5c69bad98	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-18 22:43:04.306165+00	
00000000-0000-0000-0000-000000000000	1b3f706f-8130-4ae6-b203-d99ca92ae4e6	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-18 22:43:36.201633+00	
00000000-0000-0000-0000-000000000000	89ae9bdc-916e-42cf-938a-1eab10c10406	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-18 22:43:37.092897+00	
00000000-0000-0000-0000-000000000000	dc7988cc-a601-4c4c-93a9-4aac66b29356	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-18 23:22:33.978765+00	
00000000-0000-0000-0000-000000000000	f6a8e844-d24b-4801-af04-f6d31e0593e6	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-18 23:22:43.470696+00	
00000000-0000-0000-0000-000000000000	d99f8e7e-ee9a-48e0-be53-7646cecc66e4	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-18 23:22:43.745779+00	
00000000-0000-0000-0000-000000000000	9d437dd8-071e-433d-9f2f-770b552f51d4	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 02:04:43.929885+00	
00000000-0000-0000-0000-000000000000	d87a569a-4ad8-4681-b698-654f0a1e3d77	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 02:04:43.931662+00	
00000000-0000-0000-0000-000000000000	54a889ec-8749-463b-9a21-f981c8b8f7f3	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 03:03:11.167+00	
00000000-0000-0000-0000-000000000000	38ce8fce-7647-48b5-b3a0-c97654cda562	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 03:03:11.169486+00	
00000000-0000-0000-0000-000000000000	354df8ce-a8fa-461e-b442-0489538082a3	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 13:37:06.130438+00	
00000000-0000-0000-0000-000000000000	0d60e1d7-96a4-48bd-81d5-f5f48ff60757	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 13:37:06.142563+00	
00000000-0000-0000-0000-000000000000	57001c16-1ae4-48dd-ab60-214e5940a9bf	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 21:13:59.716102+00	
00000000-0000-0000-0000-000000000000	f1017bf2-14b3-43c5-8b73-cbb4f6c0431b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 21:13:59.724322+00	
00000000-0000-0000-0000-000000000000	020c5a02-405a-40e1-a39b-a3244ebc2226	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 22:12:06.803679+00	
00000000-0000-0000-0000-000000000000	d8a76707-6941-4541-9650-93fc5ad8cc57	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-19 22:12:06.805816+00	
00000000-0000-0000-0000-000000000000	bf4a9824-c1e4-40f6-b5f6-35f955588f27	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 00:52:58.696938+00	
00000000-0000-0000-0000-000000000000	a0e49eeb-025c-4c9a-8ab9-b2c1ac130c80	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 00:52:58.701077+00	
00000000-0000-0000-0000-000000000000	99653c2a-cc00-4777-adad-835f12e3bf6a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 01:53:52.192206+00	
00000000-0000-0000-0000-000000000000	fd84b39e-79da-46f3-a42e-25f0daf924c4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 01:53:52.193032+00	
00000000-0000-0000-0000-000000000000	6e923de0-12eb-46a3-800d-56b3ecebef96	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 03:05:34.417694+00	
00000000-0000-0000-0000-000000000000	dbec2c33-cb92-40b9-aa50-19cebfe872c1	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 03:05:34.419927+00	
00000000-0000-0000-0000-000000000000	78338394-0ed3-43df-bff9-69f34b07873c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 04:03:48.605416+00	
00000000-0000-0000-0000-000000000000	116e3ef9-40c3-4698-83f3-75ec871611cb	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 04:03:48.607487+00	
00000000-0000-0000-0000-000000000000	6a5e3724-1e39-4df0-9bf1-d5415e232f91	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 11:35:31.741748+00	
00000000-0000-0000-0000-000000000000	e8516304-3aa6-4b83-bb09-0667a250fc8c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 11:35:31.748722+00	
00000000-0000-0000-0000-000000000000	08cebdae-0e27-4630-bfc9-b3ff883f3f93	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 17:42:35.557924+00	
00000000-0000-0000-0000-000000000000	3f86fb4d-12a1-4055-ab5e-345c0763d333	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 17:42:35.562038+00	
00000000-0000-0000-0000-000000000000	4f7d7536-1ae0-4dd6-9de3-0c2da3272115	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 21:40:33.162244+00	
00000000-0000-0000-0000-000000000000	7bc0eb3a-76ca-4493-941c-e8e6be2322a8	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 21:40:33.16745+00	
00000000-0000-0000-0000-000000000000	c4617c51-80f5-436a-a2e4-bdb8adddec1b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 22:39:01.27639+00	
00000000-0000-0000-0000-000000000000	71f0d08f-adfc-4347-810d-f44f10ecee49	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-20 22:39:01.281287+00	
00000000-0000-0000-0000-000000000000	6c24dc48-80e2-4553-983c-32836f5926aa	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-21 02:06:31.427589+00	
00000000-0000-0000-0000-000000000000	e06e3e0e-3566-428e-8112-c9ba99c13775	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-21 02:06:31.432632+00	
00000000-0000-0000-0000-000000000000	8dff4e4f-aa56-483f-96e0-7ee63a846e1d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 01:21:26.851674+00	
00000000-0000-0000-0000-000000000000	d4503ece-a85a-46f3-98e3-ab0c5e0774fe	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 01:21:26.870338+00	
00000000-0000-0000-0000-000000000000	bd4cb1b5-aac8-4aa8-bd13-d81d60938acb	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-23 01:31:26.695094+00	
00000000-0000-0000-0000-000000000000	2ea92abb-8f72-4220-9316-50767a20f3c2	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-23 01:32:49.795152+00	
00000000-0000-0000-0000-000000000000	6cbd15d2-bd55-4110-b75e-ca267096d981	{"action":"login","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-23 01:32:50.05238+00	
00000000-0000-0000-0000-000000000000	0bc3a490-9d0a-4838-91e0-e729d39fe050	{"action":"logout","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-23 02:01:17.353226+00	
00000000-0000-0000-0000-000000000000	6a1488f8-0c49-43be-962a-82bef1ba9f16	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-23 02:01:18.739411+00	
00000000-0000-0000-0000-000000000000	940a9c9e-0954-4837-bd7b-4974c093c41a	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-23 02:01:18.798304+00	
00000000-0000-0000-0000-000000000000	f61ba70a-ed30-458c-b2fb-313dace41328	{"action":"logout","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account"}	2024-10-23 02:15:09.848583+00	
00000000-0000-0000-0000-000000000000	3546780b-628f-4c57-837d-2da7268c6ce5	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-23 02:15:10.908913+00	
00000000-0000-0000-0000-000000000000	232aead7-1247-45c6-95cc-22091a678b78	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-23 02:15:10.933258+00	
00000000-0000-0000-0000-000000000000	2e642d11-6d77-4176-884f-e14a8b14c2e0	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 05:36:46.79701+00	
00000000-0000-0000-0000-000000000000	de9caac1-c66d-4c23-b4f9-05c295dc7ac4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 05:36:46.801423+00	
00000000-0000-0000-0000-000000000000	525f4c37-f527-4cfb-9503-3cdbb17e7bd1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 23:02:35.72619+00	
00000000-0000-0000-0000-000000000000	4d9344f5-fbcf-4dfc-807f-b2e30607cc54	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 23:02:35.743432+00	
00000000-0000-0000-0000-000000000000	405f14f2-b3d7-44af-8999-6575d7a5ae94	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 23:03:14.242686+00	
00000000-0000-0000-0000-000000000000	7ee5adf5-6912-4cb5-957d-df8b619f7167	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-23 23:03:14.244993+00	
00000000-0000-0000-0000-000000000000	0d15b537-08e7-4b6f-95f6-75901d63a9f5	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-24 00:00:56.509822+00	
00000000-0000-0000-0000-000000000000	1113f625-3356-443d-a443-0ae108b1546f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-24 00:00:56.511694+00	
00000000-0000-0000-0000-000000000000	b4edcd3f-57a7-4005-8d3f-ccb55c8e47cf	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-24 00:05:28.322193+00	
00000000-0000-0000-0000-000000000000	cda75f85-8451-4bca-a600-215b5b7a117d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-24 00:05:28.32411+00	
00000000-0000-0000-0000-000000000000	55690c77-fca3-4886-b2ab-9ddb6fdcbdb8	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-24 01:04:30.747594+00	
00000000-0000-0000-0000-000000000000	3cf81976-c999-4e6b-9446-eab9ea4b14d4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-24 01:04:30.756964+00	
00000000-0000-0000-0000-000000000000	5f018ad3-28f9-4b2c-b6e1-d60a94275c32	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-24 03:51:29.801644+00	
00000000-0000-0000-0000-000000000000	26f9d366-2758-42ca-93d1-986b3c19a35c	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-24 03:51:29.806027+00	
00000000-0000-0000-0000-000000000000	73ebbc64-f0fc-4adc-a829-444349a3716d	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-10-24 03:52:35.93789+00	
00000000-0000-0000-0000-000000000000	2da3883a-d888-43fa-ac5a-1c6183e727b2	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 12:17:47.585431+00	
00000000-0000-0000-0000-000000000000	2095803b-056a-444b-9e6b-dbb3ff4e7b4b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 12:17:47.602935+00	
00000000-0000-0000-0000-000000000000	56d4d6f6-3529-4fb2-92be-2a1b74afa3ff	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 13:18:08.536627+00	
00000000-0000-0000-0000-000000000000	1c59d066-3595-483a-9171-6159efbb055d	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 13:18:08.53983+00	
00000000-0000-0000-0000-000000000000	034e75cd-9956-4416-9757-3578de616c3d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 20:21:45.070096+00	
00000000-0000-0000-0000-000000000000	b59eaa64-8fa9-42ed-9050-9f9f35c1abab	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 20:21:45.082352+00	
00000000-0000-0000-0000-000000000000	0857bd62-88ef-4bd1-b505-6873bfe94785	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 21:34:21.845253+00	
00000000-0000-0000-0000-000000000000	8a346fb4-3933-4e0e-8b35-82773d419121	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-27 21:34:21.850652+00	
00000000-0000-0000-0000-000000000000	2639b4a6-2773-4300-b657-ec775f5b2c90	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-28 00:22:31.846513+00	
00000000-0000-0000-0000-000000000000	b017b942-6b1d-48c0-93f8-6c3a67ebec06	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-28 00:22:31.862462+00	
00000000-0000-0000-0000-000000000000	599a1c8f-a258-4c04-b62e-9e65607f937a	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-28 01:22:20.305691+00	
00000000-0000-0000-0000-000000000000	2f441bb8-f6e1-490e-82b3-dbd8833c2832	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-28 01:22:20.311245+00	
00000000-0000-0000-0000-000000000000	f430d1ce-b043-41b7-b2cf-4ba849494a38	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-28 02:49:49.095779+00	
00000000-0000-0000-0000-000000000000	7d3f5378-0f7f-4425-bfe1-2d43a3c5407f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-28 02:49:49.108032+00	
00000000-0000-0000-0000-000000000000	b5fbd4b8-47ae-402d-8bf3-5e23c8da3f6f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 00:41:39.134045+00	
00000000-0000-0000-0000-000000000000	fe741c01-2cdc-4ebe-88a4-0cc2a3107dac	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 00:41:39.148519+00	
00000000-0000-0000-0000-000000000000	00e5d398-b00b-4264-b42a-7005b2b16d4c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 02:04:28.504385+00	
00000000-0000-0000-0000-000000000000	016df7ac-110d-4677-a0cb-789e7ae0fafb	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 02:04:28.51451+00	
00000000-0000-0000-0000-000000000000	0ccfc939-7d1a-4c3e-8c43-f905e1af6efc	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 02:20:38.509859+00	
00000000-0000-0000-0000-000000000000	bddf19cf-910e-4674-a96a-ec7ce8a77902	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 02:20:38.512618+00	
00000000-0000-0000-0000-000000000000	368025ac-0265-46bb-8ad5-164cc8bddde1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 03:04:45.131878+00	
00000000-0000-0000-0000-000000000000	c3ea371a-61e0-476f-99a0-21a0a04cfc9f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 03:04:45.134229+00	
00000000-0000-0000-0000-000000000000	5e910bfd-645d-42b8-8720-ad8359f41d48	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 23:43:41.498614+00	
00000000-0000-0000-0000-000000000000	90335fcf-2e8a-4caf-87e3-6c02929f0074	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-29 23:43:41.518047+00	
00000000-0000-0000-0000-000000000000	a966a902-8112-42be-a3dc-7fbef33dfcac	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-30 01:09:32.341723+00	
00000000-0000-0000-0000-000000000000	177fb4f6-3bef-4a77-a58e-3955c47d6839	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-30 01:09:32.351148+00	
00000000-0000-0000-0000-000000000000	265cc479-f757-4b48-96ac-8f69733e5eb6	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-30 02:07:39.952311+00	
00000000-0000-0000-0000-000000000000	b912cdb2-7ad5-4537-8155-d2d6c647b504	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-30 02:07:39.954698+00	
00000000-0000-0000-0000-000000000000	18a3e00f-3570-4018-a49b-77cd5353330d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-30 03:05:55.236245+00	
00000000-0000-0000-0000-000000000000	63365fab-986c-4c84-8ed4-f72bb3299a80	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-10-30 03:05:55.239176+00	
00000000-0000-0000-0000-000000000000	7fce3ad1-332f-40de-8a26-676d7ae11dbe	{"action":"user_repeated_signup","actor_id":"37d3b652-d314-4124-9685-add5f0c6fc19","actor_username":"angelgmorenor@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2024-10-31 23:09:47.580027+00	
00000000-0000-0000-0000-000000000000	ae62094e-31a7-455e-bb10-fd1c686bffe4	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-02 11:52:00.862908+00	
00000000-0000-0000-0000-000000000000	578979b1-cfeb-4ef4-ae78-75ca61074cf1	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-02 11:52:00.877227+00	
00000000-0000-0000-0000-000000000000	f3858289-7a8f-4156-a62a-20fb7fac3ed1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-02 19:43:29.139514+00	
00000000-0000-0000-0000-000000000000	145fca1a-892e-41e6-8cfc-02f62d9734a2	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-02 19:43:29.164059+00	
00000000-0000-0000-0000-000000000000	58380c58-8c5e-4907-93fb-19363dc6ade2	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-03 12:34:04.474915+00	
00000000-0000-0000-0000-000000000000	4ba5c1be-c020-442d-bc8e-a676a3f1ae6b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-03 12:34:04.491735+00	
00000000-0000-0000-0000-000000000000	1c23ca88-ddc9-409c-88c2-271ea34319fd	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-03 19:24:30.196163+00	
00000000-0000-0000-0000-000000000000	38d586af-015d-476c-9a62-63dc4b2a0968	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-03 19:24:30.203816+00	
00000000-0000-0000-0000-000000000000	9062babe-774f-4805-99fb-e821c759e061	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-03 19:24:39.844217+00	
00000000-0000-0000-0000-000000000000	56b0de21-0d12-40f4-ad56-4f8f1d4ff73d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 12:49:51.37702+00	
00000000-0000-0000-0000-000000000000	06ccd5c1-f0ea-46c4-b91e-9b8b8c3a6881	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 12:49:51.392791+00	
00000000-0000-0000-0000-000000000000	62f7cf5e-a8a6-4bba-8ad0-6844cb6f8c62	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 12:49:59.543122+00	
00000000-0000-0000-0000-000000000000	33c9dae0-f270-43ef-9e3b-9e27f6102903	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 18:23:10.313624+00	
00000000-0000-0000-0000-000000000000	732fb156-a80d-46f5-8cfe-c47355f8cb18	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 18:23:10.321889+00	
00000000-0000-0000-0000-000000000000	a900f024-5def-44be-a3dc-5e0932bbf753	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 20:04:26.16244+00	
00000000-0000-0000-0000-000000000000	2ff497f6-6a33-4571-bdf1-3a308e93e91f	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 20:04:26.167455+00	
00000000-0000-0000-0000-000000000000	8cea64ff-298c-4abf-888b-5a19ea5be492	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 21:25:31.700594+00	
00000000-0000-0000-0000-000000000000	8546fc7d-1893-4dda-92b7-2deae047e882	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-04 21:25:31.712078+00	
00000000-0000-0000-0000-000000000000	7db7447c-746f-4d1c-8740-757aca92d72c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-05 02:09:10.247357+00	
00000000-0000-0000-0000-000000000000	c58f16cf-23da-40c8-b11c-e5125e0c6742	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-05 02:09:10.252682+00	
00000000-0000-0000-0000-000000000000	abd89911-a99d-459e-b5bd-7910e949eb96	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-05 22:45:10.608931+00	
00000000-0000-0000-0000-000000000000	325c0c0e-1fa6-47aa-897d-1a64b3d575b5	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-05 22:45:10.625599+00	
00000000-0000-0000-0000-000000000000	8e8f6768-1943-49a5-a51d-5e452d87d0b1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-06 02:35:39.838188+00	
00000000-0000-0000-0000-000000000000	249e38fc-0992-48d4-950f-22c83cfd52c9	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-06 02:35:39.851309+00	
00000000-0000-0000-0000-000000000000	36d67d0a-6b18-4ff3-a9ed-d270572d9424	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-06 22:54:26.762452+00	
00000000-0000-0000-0000-000000000000	00190f13-074f-4d46-8bc9-73cf2a192b25	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-06 22:54:26.780714+00	
00000000-0000-0000-0000-000000000000	db062dd1-c3e9-45e0-b207-ae1ae5e18a7c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-06 23:54:11.504756+00	
00000000-0000-0000-0000-000000000000	3078247c-a82e-4e79-952d-aa22624dc784	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-06 23:54:11.516421+00	
00000000-0000-0000-0000-000000000000	d581914e-6718-41fc-bb2e-45d899e026a1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 00:45:04.327022+00	
00000000-0000-0000-0000-000000000000	999ae0e9-26cc-4a2f-9324-4be10c108cca	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 00:45:04.342703+00	
00000000-0000-0000-0000-000000000000	5382ce6f-9879-4f58-99c7-9929f4703615	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-11-08 01:17:54.039457+00	
00000000-0000-0000-0000-000000000000	fa280592-0f79-47ed-83db-5b4e29919762	{"action":"login","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2024-11-08 01:17:54.076957+00	
00000000-0000-0000-0000-000000000000	1e3583fe-9cdc-4dc9-80fb-a4fd0d1b4d08	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 02:16:03.581472+00	
00000000-0000-0000-0000-000000000000	a536b632-c050-42c6-bbb8-70998c41c819	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 02:16:03.584254+00	
00000000-0000-0000-0000-000000000000	1c8ee551-515f-478e-b5ea-7170abcff777	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 04:34:22.938265+00	
00000000-0000-0000-0000-000000000000	4ed455da-8048-4e36-838c-cf26092f4a52	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 04:34:22.942404+00	
00000000-0000-0000-0000-000000000000	77f06370-6a17-4241-8ce7-1a3cf490e1bd	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 05:32:21.569611+00	
00000000-0000-0000-0000-000000000000	5e072b1d-fe5a-41b8-8423-59ab97918e29	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 05:32:21.572432+00	
00000000-0000-0000-0000-000000000000	6f8170f1-2029-404f-935c-51771a7e7c87	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 06:30:22.797923+00	
00000000-0000-0000-0000-000000000000	f08faeef-7bc9-4aec-8a3b-39f2da52f3d5	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 06:30:22.798794+00	
00000000-0000-0000-0000-000000000000	7956659d-abb6-4c1e-adb1-c9399e7a44f6	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 07:28:23.899524+00	
00000000-0000-0000-0000-000000000000	1be30eb4-d8e4-4c27-8051-f64a13159d54	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 07:28:23.911072+00	
00000000-0000-0000-0000-000000000000	46fd8273-9cb1-48ac-bb8f-10777d0ee1ce	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 08:26:24.889208+00	
00000000-0000-0000-0000-000000000000	a8346c26-7f70-4b55-8f15-f4ea28f854e3	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 08:26:24.891568+00	
00000000-0000-0000-0000-000000000000	959ede9b-c0f6-4478-a2e4-62e0ae67541c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 09:24:25.919391+00	
00000000-0000-0000-0000-000000000000	7c9e377e-e3e4-41f9-a078-0bafade7ad2c	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 09:24:25.922878+00	
00000000-0000-0000-0000-000000000000	dcadb1a9-549d-437e-a97a-90d66db4625f	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 10:22:26.836726+00	
00000000-0000-0000-0000-000000000000	3e135fe8-0240-4e28-977d-1c47f969b256	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 10:22:26.841186+00	
00000000-0000-0000-0000-000000000000	c11afc29-71fb-472c-8054-9d32efb3e555	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 11:20:28.279198+00	
00000000-0000-0000-0000-000000000000	61dcc520-fba8-4475-81e2-438bf776b87e	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 11:20:28.280652+00	
00000000-0000-0000-0000-000000000000	9ce4f2fe-6b2f-4652-a1ad-3564363659f9	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 12:18:28.967221+00	
00000000-0000-0000-0000-000000000000	eabf76ce-a70d-4a33-afe2-367c5ba4f553	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 12:18:28.969017+00	
00000000-0000-0000-0000-000000000000	dcbcbe42-bc67-4f66-9498-e6d2801ff34c	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 13:16:30.213372+00	
00000000-0000-0000-0000-000000000000	c48ee1c6-bf63-457c-903f-3f765fe6b123	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 13:16:30.215701+00	
00000000-0000-0000-0000-000000000000	c9fe6e99-c64f-489e-b28e-dc1e2c81a421	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 14:15:01.171252+00	
00000000-0000-0000-0000-000000000000	6a7c1a90-c575-4234-b917-5d3d8884d930	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 14:15:01.172853+00	
00000000-0000-0000-0000-000000000000	2d74aaca-d9ea-4248-a3b8-83dddc15486d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 15:13:32.236776+00	
00000000-0000-0000-0000-000000000000	a8a9dfba-8f20-4ecd-baf2-d9431a1b40fb	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 15:13:32.240491+00	
00000000-0000-0000-0000-000000000000	47dbb2be-5408-4ab0-840a-9dc0c61bde98	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 16:12:03.373054+00	
00000000-0000-0000-0000-000000000000	772c6e8e-f77c-4099-982d-ecbfc454b6c0	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 16:12:03.377102+00	
00000000-0000-0000-0000-000000000000	e9dd66b9-756e-4c87-85da-d6a1c51e7412	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 17:10:34.495961+00	
00000000-0000-0000-0000-000000000000	ffd1035d-aa3a-4bba-932f-fcde9341918e	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 17:10:34.496964+00	
00000000-0000-0000-0000-000000000000	865d3938-1087-4399-afce-245d17b2791b	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 18:09:05.50816+00	
00000000-0000-0000-0000-000000000000	8bb57693-a4fd-4ee6-b125-7e903079fa5a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 18:09:05.509694+00	
00000000-0000-0000-0000-000000000000	b193212f-aead-4b87-a021-3195b7f8e6c1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 19:07:36.604464+00	
00000000-0000-0000-0000-000000000000	585fb87a-e0b3-4406-b55b-692829d985ff	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 19:07:36.605808+00	
00000000-0000-0000-0000-000000000000	dd9875cd-e2b1-45dc-b873-0233b4dcc023	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 20:06:07.791398+00	
00000000-0000-0000-0000-000000000000	82ae1ca7-795c-4706-85f1-bb85f2b305d2	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 20:06:07.798239+00	
00000000-0000-0000-0000-000000000000	5f89f974-281e-46ba-925b-8db7797a14b0	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 21:04:38.85088+00	
00000000-0000-0000-0000-000000000000	4666187f-dab4-42cb-923c-bf2412520fe0	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 21:04:38.853255+00	
00000000-0000-0000-0000-000000000000	f4bc35fd-d3ed-49ce-82fb-eace84ec45b1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 22:46:20.904753+00	
00000000-0000-0000-0000-000000000000	3455845f-3bd2-4473-bf36-97609f77c969	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-08 22:46:20.907877+00	
00000000-0000-0000-0000-000000000000	1f890163-47de-4447-be96-92d087d064f4	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 01:39:11.679728+00	
00000000-0000-0000-0000-000000000000	1f98b517-f5ca-4adf-9c73-025d5c4885f3	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 01:39:11.681767+00	
00000000-0000-0000-0000-000000000000	68ddb0b4-a089-4722-bd40-d2ef73a184f1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 03:26:04.241267+00	
00000000-0000-0000-0000-000000000000	3a984935-6483-4f57-8973-6748322fce88	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 03:26:04.243822+00	
00000000-0000-0000-0000-000000000000	d7bac57d-e57c-48df-84b3-a809a08ff425	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 04:24:33.055099+00	
00000000-0000-0000-0000-000000000000	94a4fe9b-393b-4efa-a066-089e32f08289	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 04:24:33.057481+00	
00000000-0000-0000-0000-000000000000	ca65314a-9262-45d6-a08a-ba32bcb2e2fe	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 05:30:21.273739+00	
00000000-0000-0000-0000-000000000000	c8a91a52-91d3-4b22-ba5f-2993cbe9937a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 05:30:21.276187+00	
00000000-0000-0000-0000-000000000000	cc4e878b-4040-4240-81b4-723308d88fa2	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 08:50:46.620484+00	
00000000-0000-0000-0000-000000000000	c86228bd-63cf-4a9b-9f15-a7d0219c0aed	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 08:50:46.632697+00	
00000000-0000-0000-0000-000000000000	9677fb05-3ef9-4fc1-a87e-0c5fa1827d48	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 12:50:03.188333+00	
00000000-0000-0000-0000-000000000000	34872098-7619-4fe2-93f3-4db7a132014b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-09 12:50:03.195585+00	
00000000-0000-0000-0000-000000000000	084f9656-b3b2-4268-a96d-2e29f56aa9b1	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-10 02:39:29.281857+00	
00000000-0000-0000-0000-000000000000	c33c349a-51d9-4386-a52c-5ff543504e10	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-10 02:39:29.292602+00	
00000000-0000-0000-0000-000000000000	6253f59f-6dbf-4b70-8966-7aa9fc11f902	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-10 17:31:20.684089+00	
00000000-0000-0000-0000-000000000000	d324f784-51c5-425b-ae46-b38c6aa286c9	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-10 17:31:20.699607+00	
00000000-0000-0000-0000-000000000000	8c8976be-532d-416b-aac9-4f6af8ee1809	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-10 18:29:34.203699+00	
00000000-0000-0000-0000-000000000000	1d883b8d-c086-48b7-b5b7-2ea9039249c6	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-10 18:29:34.205069+00	
00000000-0000-0000-0000-000000000000	afae1c56-5808-4884-b889-42f0d93b6f69	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 01:51:45.893863+00	
00000000-0000-0000-0000-000000000000	decac9af-04b4-4165-aca2-3743db619e72	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 01:51:45.906455+00	
00000000-0000-0000-0000-000000000000	e95d3753-623d-40d3-89bd-3d70523da5fb	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 03:01:37.334191+00	
00000000-0000-0000-0000-000000000000	92ad8eda-ac8c-4df8-8683-e1e9b0cdbce4	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 03:01:37.352498+00	
00000000-0000-0000-0000-000000000000	f49ead6e-aa3f-40cb-8adc-d3ca28c7c877	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 03:08:41.148014+00	
00000000-0000-0000-0000-000000000000	e89530af-4281-4c01-98a3-06b5caae9979	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 03:08:41.151882+00	
00000000-0000-0000-0000-000000000000	892030c7-0b4f-4322-9c47-070aa1635f2d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 03:11:42.898191+00	
00000000-0000-0000-0000-000000000000	93d87e65-e280-48d8-8f01-e056250cb426	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 03:11:42.900064+00	
00000000-0000-0000-0000-000000000000	7e293e9e-9fad-40d3-9164-62d5bb01599d	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 06:48:50.463824+00	
00000000-0000-0000-0000-000000000000	3aeeca86-97d3-4644-97ee-195ea9169a56	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 06:48:50.48058+00	
00000000-0000-0000-0000-000000000000	37e823d0-a359-4d62-b62f-9492d1530e67	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 22:14:39.204517+00	
00000000-0000-0000-0000-000000000000	f44e538e-140b-4b4a-a5e9-a507d1f5743b	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 22:14:39.217591+00	
00000000-0000-0000-0000-000000000000	b435bde4-734b-47e0-a0e0-a31f1d1aee30	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 22:58:24.053641+00	
00000000-0000-0000-0000-000000000000	97a19f53-6665-4698-843b-3c333dd3906a	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 22:58:24.059753+00	
00000000-0000-0000-0000-000000000000	a9aa5363-1f7d-4fae-ba6a-69586c6136ef	{"action":"token_refreshed","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 23:00:53.734397+00	
00000000-0000-0000-0000-000000000000	955d518d-8ce8-4950-8c43-f5bc1834a281	{"action":"token_revoked","actor_id":"c563f82f-cd5b-4187-a8b1-07d7038c74ce","actor_username":"huanhaowu28@gmail.com","actor_via_sso":false,"log_type":"token"}	2024-11-11 23:00:53.735287+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
37d3b652-d314-4124-9685-add5f0c6fc19	37d3b652-d314-4124-9685-add5f0c6fc19	{"sub": "37d3b652-d314-4124-9685-add5f0c6fc19", "email": "angelgmorenor@gmail.com", "last_name": "Moreno", "first_name": "Angel", "email_verified": false, "phone_verified": false}	email	2024-09-04 00:21:22.02975+00	2024-09-04 00:21:22.029806+00	2024-09-04 00:21:22.029806+00	7081051a-6434-4840-959f-f4bbbf2e7465
dd3f6685-376d-4e7b-a4fa-7749826cc4af	dd3f6685-376d-4e7b-a4fa-7749826cc4af	{"sub": "dd3f6685-376d-4e7b-a4fa-7749826cc4af", "email": "elrealchocolate@gmail.com", "last_name": "Moreno", "first_name": "Angel", "email_verified": false, "phone_verified": false}	email	2024-09-08 20:43:07.139351+00	2024-09-08 20:43:07.139407+00	2024-09-08 20:43:07.139407+00	ca7afb6e-ea86-479f-8cda-9cd7fdc9d891
c563f82f-cd5b-4187-a8b1-07d7038c74ce	c563f82f-cd5b-4187-a8b1-07d7038c74ce	{"sub": "c563f82f-cd5b-4187-a8b1-07d7038c74ce", "email": "huanhaowu28@gmail.com", "last_name": "Wu Wu", "first_name": "Huan Hao", "email_verified": false, "phone_verified": false}	email	2024-09-17 22:33:17.315463+00	2024-09-17 22:33:17.315517+00	2024-09-17 22:33:17.315517+00	c4a3547c-f2e3-4fdc-8cde-ded4dc6c7076
40addfbf-eb76-4168-a03b-ac07036832fc	40addfbf-eb76-4168-a03b-ac07036832fc	{"sub": "40addfbf-eb76-4168-a03b-ac07036832fc", "email": "example@gmail.com", "last_name": "Last", "first_name": "First", "email_verified": false, "phone_verified": false}	email	2024-10-02 02:57:47.289476+00	2024-10-02 02:57:47.28953+00	2024-10-02 02:57:47.28953+00	5289f588-3075-4afa-9b46-2690bcc128ae
NN5b_rehjubJebbck5Jo3iJ8TbJIDu5rQautNzU1jGQ	c15bca29-43e1-4536-a709-7e8da1d11758	{}	email	2024-10-02 18:50:34.991231+00	2024-10-02 18:50:34.991283+00	2024-10-02 18:50:34.991283+00	d0faf656-710b-42f8-814a-a14c5a90409d
d9f130fe-d9e1-4d1c-a160-03c8ad109af4	d9f130fe-d9e1-4d1c-a160-03c8ad109af4	{"sub": "d9f130fe-d9e1-4d1c-a160-03c8ad109af4", "email": "jubhcivoflhbeaoqhm@nbmbb.com", "last_name": "Alcachofa", "first_name": "Juanito", "email_verified": false, "phone_verified": false}	email	2024-10-16 02:26:33.393119+00	2024-10-16 02:26:33.393172+00	2024-10-16 02:26:33.393172+00	d075efc6-7ef8-41b1-aaf5-34e3022f1850
94d84199-abd0-4390-af51-8d1e40715a6e	94d84199-abd0-4390-af51-8d1e40715a6e	{"sub": "94d84199-abd0-4390-af51-8d1e40715a6e", "email": "gyqobnlnkkytjbaych@poplk.com", "last_name": "Perez", "first_name": "Pedro", "email_verified": false, "phone_verified": false}	email	2024-10-16 21:51:03.282104+00	2024-10-16 21:51:03.282159+00	2024-10-16 21:51:03.282159+00	08353845-6076-4cf9-a5a6-198ef0fe7e8a
24c17fbe-5b94-4f07-a473-5225a245263c	24c17fbe-5b94-4f07-a473-5225a245263c	{"sub": "24c17fbe-5b94-4f07-a473-5225a245263c", "email": "ghsfzsiovtsavnjeog@poplk.com", "last_name": "Perez", "first_name": "Pepito", "email_verified": false, "phone_verified": false}	email	2024-10-16 23:42:22.834672+00	2024-10-16 23:42:22.83472+00	2024-10-16 23:42:22.83472+00	d7d33d2c-8c1b-4394-86c9-116251507d63
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
82d59a09-1b43-45d9-a8e9-0896f5e80e49	2024-09-08 21:14:08.231079+00	2024-09-08 21:14:08.231079+00	otp	6d503451-2abe-423a-9de4-90f0f936af4b
9dbc77f7-b628-482f-b713-4f1656abb00a	2024-10-23 02:15:10.91434+00	2024-10-23 02:15:10.91434+00	password	37a42eff-af8b-44c4-8819-089bb60a17ae
658ff57d-95a8-4c50-bfdd-df7b5cf0c246	2024-10-23 02:15:10.935822+00	2024-10-23 02:15:10.935822+00	password	42e6fd9f-4ed9-489e-a086-4de8fc0add53
71bf5cd8-222e-428b-abe3-c29f82636f6e	2024-10-24 03:51:29.842038+00	2024-10-24 03:51:29.842038+00	password	eab996ac-7f23-4518-ad57-addbe42c2ed4
52a734b1-cd24-4936-ac8b-a4a34a3c16aa	2024-10-24 03:51:29.856629+00	2024-10-24 03:51:29.856629+00	password	d0f36382-ec0e-4d37-95ec-96c78470c6d8
0f44dfc3-004f-466a-a6c6-3ec4c494c742	2024-10-24 03:52:35.948191+00	2024-10-24 03:52:35.948191+00	password	a62c0d4b-2a47-412a-86b0-eb908fa927cb
c19be8b2-f154-467b-b24b-977e99370b94	2024-11-08 01:17:54.052883+00	2024-11-08 01:17:54.052883+00	password	32294f36-1e4e-4961-a4fe-0451c5e8e4f5
8e3e4b95-cce8-421c-a7fb-5750344d8730	2024-11-08 01:17:54.081434+00	2024-11-08 01:17:54.081434+00	password	8300f03d-1328-41c2-852b-bac592ac442f
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
0a92d2fc-45d2-44c5-bca6-b9b0f7b07955	d9f130fe-d9e1-4d1c-a160-03c8ad109af4	confirmation_token	cd4e5144b4c47a7c527b85e0bcaa52ee4808083f5960e6b36f6279c8	jubhcivoflhbeaoqhm@nbmbb.com	2024-10-16 02:26:34.783475	2024-10-16 02:26:34.783475
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	451	3yytnLELbXcS9jTSJv2zOg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-29 02:04:28.518357+00	2024-10-29 03:04:45.136857+00	o-SaVOa2q7F2S1viem_Q2A	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	453	HUmoolAYMLkzAMSgp825yw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-29 03:04:45.138037+00	2024-10-29 23:43:41.521037+00	3yytnLELbXcS9jTSJv2zOg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	76	w87iFS1rSQ_XBZwPQfK74A	dd3f6685-376d-4e7b-a4fa-7749826cc4af	f	2024-09-08 21:14:08.22012+00	2024-09-08 21:14:08.22012+00	\N	82d59a09-1b43-45d9-a8e9-0896f5e80e49
00000000-0000-0000-0000-000000000000	454	Ge5IG1bpE1dOTTlJGvrzMA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-29 23:43:41.529566+00	2024-10-30 01:09:32.352604+00	HUmoolAYMLkzAMSgp825yw	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	455	pQTuAPig6DgSIcFd6Nnpsg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-30 01:09:32.356911+00	2024-10-30 02:07:39.957006+00	Ge5IG1bpE1dOTTlJGvrzMA	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	456	dPppWiT1OVSKC9r7xAj06A	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-30 02:07:39.958512+00	2024-10-30 03:05:55.240222+00	pQTuAPig6DgSIcFd6Nnpsg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	457	JsL1vdNZMK7Xit8x3F2fzg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-30 03:05:55.241617+00	2024-11-02 11:52:00.879967+00	dPppWiT1OVSKC9r7xAj06A	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	458	fLmheYeEjmRx7CfZK-hmdw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-02 11:52:00.885649+00	2024-11-02 19:43:29.166315+00	JsL1vdNZMK7Xit8x3F2fzg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	459	cwsZTXkNtDEN2gzjGlB61A	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-02 19:43:29.178835+00	2024-11-03 12:34:04.49231+00	fLmheYeEjmRx7CfZK-hmdw	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	460	atDQ8eUqm_vSrYWw7tlgFg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-03 12:34:04.501539+00	2024-11-03 19:24:30.204373+00	cwsZTXkNtDEN2gzjGlB61A	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	461	1od-V7ot_8zLtyZ9n0wh4g	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-03 19:24:30.212345+00	2024-11-04 12:49:51.394683+00	atDQ8eUqm_vSrYWw7tlgFg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	462	KYAEwuC3w_4d_LdkOLg7JQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-04 12:49:51.403088+00	2024-11-04 18:23:10.323632+00	1od-V7ot_8zLtyZ9n0wh4g	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	463	q5gz6rkMIS03b5bHXRD7GA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-04 18:23:10.328696+00	2024-11-04 20:04:26.16855+00	KYAEwuC3w_4d_LdkOLg7JQ	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	464	EchWrN_Lg3LZkTvvl-R0UQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-04 20:04:26.170457+00	2024-11-04 21:25:31.712638+00	q5gz6rkMIS03b5bHXRD7GA	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	465	LcvRwSzcDpsx8jcag6M0Ng	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-04 21:25:31.717342+00	2024-11-05 02:09:10.254182+00	EchWrN_Lg3LZkTvvl-R0UQ	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	466	Azr0AZ9mgTE7rISHboUd3w	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-05 02:09:10.257479+00	2024-11-05 22:45:10.627095+00	LcvRwSzcDpsx8jcag6M0Ng	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	467	PaRlBycMaTNdvq496w_XjA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-05 22:45:10.636856+00	2024-11-06 02:35:39.854269+00	Azr0AZ9mgTE7rISHboUd3w	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	468	Xw3sG-649372XMWr3bbafA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-06 02:35:39.861303+00	2024-11-06 22:54:26.781673+00	PaRlBycMaTNdvq496w_XjA	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	469	X9fMjJYJuvURcPHiEsvfLg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-06 22:54:26.788186+00	2024-11-06 23:54:11.517456+00	Xw3sG-649372XMWr3bbafA	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	433	5JdmG1OFFto2dMCkbDx9OQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-23 02:15:10.934609+00	2024-10-23 05:36:46.801968+00	\N	658ff57d-95a8-4c50-bfdd-df7b5cf0c246
00000000-0000-0000-0000-000000000000	452	8BcQxF2jSVIb70hgo66a-Q	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-29 02:20:38.514794+00	2024-11-08 00:45:04.345096+00	qQMS-r4ZMrjtzcyYPQfljg	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	434	bjT2kqrQobYbQuS76M0qiA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-23 05:36:46.806908+00	2024-10-23 23:02:35.747665+00	5JdmG1OFFto2dMCkbDx9OQ	658ff57d-95a8-4c50-bfdd-df7b5cf0c246
00000000-0000-0000-0000-000000000000	471	CZ_3HggHErLgjUMOBB5sZw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-11-08 00:45:04.353133+00	2024-11-08 00:45:04.353133+00	8BcQxF2jSVIb70hgo66a-Q	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	432	VlsYP_4L0T1pKO9rEy6oxA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-23 02:15:10.911409+00	2024-10-23 23:03:14.245532+00	\N	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	435	LOZaB1rPFcMt5mcr0cV_-A	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-23 23:02:35.759216+00	2024-10-24 00:00:56.512199+00	bjT2kqrQobYbQuS76M0qiA	658ff57d-95a8-4c50-bfdd-df7b5cf0c246
00000000-0000-0000-0000-000000000000	437	4WFqVbUzAtIlMMPZtDU7Bw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-10-24 00:00:56.513583+00	2024-10-24 00:00:56.513583+00	LOZaB1rPFcMt5mcr0cV_-A	658ff57d-95a8-4c50-bfdd-df7b5cf0c246
00000000-0000-0000-0000-000000000000	436	f83mjn7dehHMJBFoBrGdNA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-23 23:03:14.245858+00	2024-10-24 00:05:28.324664+00	VlsYP_4L0T1pKO9rEy6oxA	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	438	E1HteNCSmN8XIBQcDzi6rw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-24 00:05:28.325281+00	2024-10-24 01:04:30.75806+00	f83mjn7dehHMJBFoBrGdNA	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	472	EwCPP0OS2r29YYJxUTBsAA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 01:17:54.048375+00	2024-11-08 02:16:03.585273+00	\N	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	441	rKvLCe7SCfu541psMtbeJQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-10-24 03:51:29.823634+00	2024-10-24 03:51:29.823634+00	\N	52a734b1-cd24-4936-ac8b-a4a34a3c16aa
00000000-0000-0000-0000-000000000000	440	tdbfrAPmA0ujXMrH92Cfew	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-10-24 03:51:29.823634+00	2024-10-24 03:51:29.823634+00	\N	71bf5cd8-222e-428b-abe3-c29f82636f6e
00000000-0000-0000-0000-000000000000	439	aLvaNsDYVqaOg22YDir6Ag	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-24 01:04:30.761983+00	2024-10-27 12:17:47.603512+00	E1HteNCSmN8XIBQcDzi6rw	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	474	VYOe5ygVEWhGhxGUDmLXuA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 02:16:03.589187+00	2024-11-08 04:34:22.943508+00	EwCPP0OS2r29YYJxUTBsAA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	475	v4xQFPexyODECkcZepFRzQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 04:34:22.946566+00	2024-11-08 05:32:21.572947+00	VYOe5ygVEWhGhxGUDmLXuA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	443	pMBDhZogpBqZlW5bT5lYrg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-27 12:17:47.611752+00	2024-10-27 13:18:08.540904+00	aLvaNsDYVqaOg22YDir6Ag	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	442	m_n_SfM-KePdfQBDr6jgKg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-24 03:52:35.944004+00	2024-10-27 20:21:45.084904+00	\N	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	476	1cuD1WTjFcBDjQzqf2ILFA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 05:32:21.57408+00	2024-11-08 06:30:22.799984+00	v4xQFPexyODECkcZepFRzQ	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	445	gj-4qTxmI0XvAs4GnOtiNw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-27 20:21:45.092285+00	2024-10-27 21:34:21.852505+00	m_n_SfM-KePdfQBDr6jgKg	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	470	wHrDl68qIIz1gxc5vWMZug	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-06 23:54:11.519069+00	2024-11-09 12:50:03.197666+00	X9fMjJYJuvURcPHiEsvfLg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	446	20EYLh4wRUth-g8rpn_-NA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-27 21:34:21.856925+00	2024-10-28 00:22:31.86459+00	gj-4qTxmI0XvAs4GnOtiNw	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	473	UnFoRZl4R_Z9hEednYiIYQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 01:17:54.080129+00	2024-11-11 03:11:42.900746+00	\N	8e3e4b95-cce8-421c-a7fb-5750344d8730
00000000-0000-0000-0000-000000000000	447	mv8zzUz4XvQbWIR_Sc3YGQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-28 00:22:31.870224+00	2024-10-28 01:22:20.311759+00	20EYLh4wRUth-g8rpn_-NA	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	448	tDlnmUV1-q5fUYpiOAVjkg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-28 01:22:20.313891+00	2024-10-28 02:49:49.111194+00	mv8zzUz4XvQbWIR_Sc3YGQ	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	444	zO-fQ2CpFWAh_hDvOpAYeQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-27 13:18:08.542707+00	2024-10-29 00:41:39.150157+00	pMBDhZogpBqZlW5bT5lYrg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	450	o-SaVOa2q7F2S1viem_Q2A	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-29 00:41:39.157671+00	2024-10-29 02:04:28.515055+00	zO-fQ2CpFWAh_hDvOpAYeQ	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	449	qQMS-r4ZMrjtzcyYPQfljg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-10-28 02:49:49.11756+00	2024-10-29 02:20:38.514192+00	tDlnmUV1-q5fUYpiOAVjkg	0f44dfc3-004f-466a-a6c6-3ec4c494c742
00000000-0000-0000-0000-000000000000	477	cZBCGrTlX6qcXe6wEIrIQA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 06:30:22.801124+00	2024-11-08 07:28:23.912873+00	1cuD1WTjFcBDjQzqf2ILFA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	478	Dot8v7bE37vLExXRJMxELA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 07:28:23.919886+00	2024-11-08 08:26:24.894198+00	cZBCGrTlX6qcXe6wEIrIQA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	479	D0qOth1KwRJYf1F7vf5ihA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 08:26:24.896801+00	2024-11-08 09:24:25.923877+00	Dot8v7bE37vLExXRJMxELA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	480	FNP_bJmg2iXuaSW7iLVlPA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 09:24:25.926957+00	2024-11-08 10:22:26.842709+00	D0qOth1KwRJYf1F7vf5ihA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	481	YzPuFGAOEvE-NYotXxPzHA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 10:22:26.846325+00	2024-11-08 11:20:28.281177+00	FNP_bJmg2iXuaSW7iLVlPA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	482	PdEVQzyLMk4vvx2FAP4-Xw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 11:20:28.282888+00	2024-11-08 12:18:28.97089+00	YzPuFGAOEvE-NYotXxPzHA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	483	tne1Cf08uKaT-WStoFbEzg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 12:18:28.973301+00	2024-11-08 13:16:30.216219+00	PdEVQzyLMk4vvx2FAP4-Xw	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	484	DjcDa3gFA_a8fLpCA-T2Nw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 13:16:30.219654+00	2024-11-08 14:15:01.173994+00	tne1Cf08uKaT-WStoFbEzg	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	485	owyq1PUOgDFeskMIoD0pHQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 14:15:01.175337+00	2024-11-08 15:13:32.241005+00	DjcDa3gFA_a8fLpCA-T2Nw	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	486	wh0urDMdH4NtDb6RGa08vA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 15:13:32.242291+00	2024-11-08 16:12:03.378094+00	owyq1PUOgDFeskMIoD0pHQ	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	487	BYSasqf73UY57EvjF5PZNg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 16:12:03.379664+00	2024-11-08 17:10:34.497448+00	wh0urDMdH4NtDb6RGa08vA	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	488	Utf42djKRGEr0ESvw1pr-Q	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 17:10:34.498739+00	2024-11-08 18:09:05.510186+00	BYSasqf73UY57EvjF5PZNg	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	489	Kwt1oJie9VFx2T4i-cys6Q	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 18:09:05.512643+00	2024-11-08 19:07:36.606309+00	Utf42djKRGEr0ESvw1pr-Q	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	490	gyQWOPQQOVdAG2FnYXx-AQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 19:07:36.606924+00	2024-11-08 20:06:07.79876+00	Kwt1oJie9VFx2T4i-cys6Q	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	491	hnmAW3qycUZJldSBRA67JQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 20:06:07.803458+00	2024-11-08 21:04:38.853764+00	gyQWOPQQOVdAG2FnYXx-AQ	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	492	GuNNaHJGK8E6zhdL-hgimQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 21:04:38.856572+00	2024-11-08 22:46:20.909262+00	hnmAW3qycUZJldSBRA67JQ	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	493	C46U48NUlU3qk6QFzPikZw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-08 22:46:20.909855+00	2024-11-09 01:39:11.68229+00	GuNNaHJGK8E6zhdL-hgimQ	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	494	EdTditr9z9_tYaTew3g4pw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-09 01:39:11.684471+00	2024-11-09 03:26:04.245596+00	C46U48NUlU3qk6QFzPikZw	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	495	--qIu5y5WPT53F4jpGBrvg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-09 03:26:04.247276+00	2024-11-09 04:24:33.058971+00	EdTditr9z9_tYaTew3g4pw	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	496	50aPr6sfGa-aZz4DdaHkqw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-09 04:24:33.060114+00	2024-11-09 05:30:21.276717+00	--qIu5y5WPT53F4jpGBrvg	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	497	2ElpPL0X58nVvX_pA2M2AQ	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-09 05:30:21.278829+00	2024-11-09 08:50:46.633248+00	50aPr6sfGa-aZz4DdaHkqw	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	499	0_Umese83YzrqwXHOLSi3g	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-09 12:50:03.202878+00	2024-11-10 02:39:29.295289+00	wHrDl68qIIz1gxc5vWMZug	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	500	zaublz1AuRVMIvSJ5OcnCg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-10 02:39:29.300817+00	2024-11-10 17:31:20.701241+00	0_Umese83YzrqwXHOLSi3g	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	501	xPqfotAoPs_db3zIYM2Vtg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-10 17:31:20.707997+00	2024-11-10 18:29:34.206721+00	zaublz1AuRVMIvSJ5OcnCg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	502	RE9B22yyBIyT1jSr5ZvFQA	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-10 18:29:34.207344+00	2024-11-11 01:51:45.908327+00	xPqfotAoPs_db3zIYM2Vtg	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	498	pkDopfxNsbVuVDsgqbOl_A	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-09 08:50:46.639744+00	2024-11-11 03:01:37.353554+00	2ElpPL0X58nVvX_pA2M2AQ	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	503	YPpCuSqT155oaHLdY7ZL1w	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-11 01:51:45.915051+00	2024-11-11 03:08:41.152418+00	RE9B22yyBIyT1jSr5ZvFQA	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	504	eZYjHMsv00qb5pZ79uDgMg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-11 03:01:37.362378+00	2024-11-11 06:48:50.482614+00	pkDopfxNsbVuVDsgqbOl_A	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	505	Prq2pkLQ7ypW2AIiA0ra6Q	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-11 03:08:41.155611+00	2024-11-11 22:14:39.21866+00	YPpCuSqT155oaHLdY7ZL1w	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	508	x91Ff855wdBMg7B27X7l5A	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-11-11 22:14:39.226284+00	2024-11-11 22:14:39.226284+00	Prq2pkLQ7ypW2AIiA0ra6Q	9dbc77f7-b628-482f-b713-4f1656abb00a
00000000-0000-0000-0000-000000000000	507	EfJgAYFONvGIui4iXMijbg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-11 06:48:50.493138+00	2024-11-11 22:58:24.060771+00	eZYjHMsv00qb5pZ79uDgMg	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	509	54UjGvXJp8qaSbdovWLsCg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-11-11 22:58:24.063866+00	2024-11-11 22:58:24.063866+00	EfJgAYFONvGIui4iXMijbg	c19be8b2-f154-467b-b24b-977e99370b94
00000000-0000-0000-0000-000000000000	506	-PqmBdOHfe4Gs1I3B_P8rg	c563f82f-cd5b-4187-a8b1-07d7038c74ce	t	2024-11-11 03:11:42.903198+00	2024-11-11 23:00:53.735772+00	UnFoRZl4R_Z9hEednYiIYQ	8e3e4b95-cce8-421c-a7fb-5750344d8730
00000000-0000-0000-0000-000000000000	510	_7IthWPeBBKgcKuE-4wmnw	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-11-11 23:00:53.736887+00	2024-11-11 23:00:53.736887+00	-PqmBdOHfe4Gs1I3B_P8rg	8e3e4b95-cce8-421c-a7fb-5750344d8730
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
82d59a09-1b43-45d9-a8e9-0896f5e80e49	dd3f6685-376d-4e7b-a4fa-7749826cc4af	2024-09-08 21:14:08.212847+00	2024-09-08 21:14:08.212847+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36	186.149.177.167	\N
658ff57d-95a8-4c50-bfdd-df7b5cf0c246	c563f82f-cd5b-4187-a8b1-07d7038c74ce	2024-10-23 02:15:10.933953+00	2024-10-24 00:00:56.516803+00	\N	aal1	\N	2024-10-24 00:00:56.516734	node	186.149.100.94	\N
52a734b1-cd24-4936-ac8b-a4a34a3c16aa	c563f82f-cd5b-4187-a8b1-07d7038c74ce	2024-10-24 03:51:29.809628+00	2024-10-24 03:51:29.809628+00	\N	aal1	\N	\N	node	152.166.130.197	\N
71bf5cd8-222e-428b-abe3-c29f82636f6e	c563f82f-cd5b-4187-a8b1-07d7038c74ce	2024-10-24 03:51:29.810239+00	2024-10-24 03:51:29.810239+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36	152.166.130.197	\N
0f44dfc3-004f-466a-a6c6-3ec4c494c742	c563f82f-cd5b-4187-a8b1-07d7038c74ce	2024-10-24 03:52:35.942885+00	2024-11-08 00:45:04.366229+00	\N	aal1	\N	2024-11-08 00:45:04.365717	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36	181.37.211.123	\N
9dbc77f7-b628-482f-b713-4f1656abb00a	c563f82f-cd5b-4187-a8b1-07d7038c74ce	2024-10-23 02:15:10.910123+00	2024-11-11 22:14:39.236889+00	\N	aal1	\N	2024-11-11 22:14:39.236809	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36	186.149.100.94	\N
c19be8b2-f154-467b-b24b-977e99370b94	c563f82f-cd5b-4187-a8b1-07d7038c74ce	2024-11-08 01:17:54.042097+00	2024-11-11 22:58:24.067853+00	\N	aal1	\N	2024-11-11 22:58:24.067786	node	181.37.211.123	\N
8e3e4b95-cce8-421c-a7fb-5750344d8730	c563f82f-cd5b-4187-a8b1-07d7038c74ce	2024-11-08 01:17:54.078558+00	2024-11-11 23:00:53.741229+00	\N	aal1	\N	2024-11-11 23:00:53.741159	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36	181.37.211.123	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	c15bca29-43e1-4536-a709-7e8da1d11758	authenticated	authenticated	UmJ1nIWLXUPaJayMbkBuW6lwHqpG5Mh59lwvIKTN8Lo	\N	2024-10-02 18:50:44.204143+00	\N		2024-10-02 18:50:34.99929+00		\N		pjevynVGUI9Jmtl3mmp2JpJhKwHv158MVp14OgywbX8	\N	2024-10-02 18:51:25.903356+00	{}	{}	\N	2024-10-02 18:50:34.971261+00	2024-10-03 01:28:32.688564+00	pjevynVGUI9Jmtl	\N	pjevynVGUI9Jmtl		\N		0	\N		\N	f	2024-10-03 01:28:32.684092+00	f
00000000-0000-0000-0000-000000000000	37d3b652-d314-4124-9685-add5f0c6fc19	authenticated	authenticated	angelgmorenor@gmail.com	$2a$10$y3zVJN1Ch3ypPQP6Brxxie21dQBy9LXqI5.av587xmxUbcXgP7t3K	2024-09-04 00:22:12.519725+00	\N		\N		\N			\N	2024-10-23 01:32:50.054115+00	{"provider": "email", "providers": ["email"]}	{"sub": "37d3b652-d314-4124-9685-add5f0c6fc19", "email": "angelgmorenor@gmail.com", "last_name": "Moreno", "first_name": "Angel", "email_verified": false, "phone_verified": false}	\N	2024-09-04 00:21:22.023712+00	2024-10-23 01:32:50.055836+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	40addfbf-eb76-4168-a03b-ac07036832fc	authenticated	authenticated	example@gmail.com	$2a$10$HfYMLs.rSlbI02e76gdgvOoUOe7YU0fbfZOJ0/9/M58UyTn2jLKmq	2024-10-02 02:58:31.495974+00	\N		\N		\N			\N	2024-10-02 02:58:31.502+00	{"provider": "email", "providers": ["email"]}	{"sub": "40addfbf-eb76-4168-a03b-ac07036832fc", "email": "dcykbowxhxjhifjfmw@ytnhy.com", "last_name": "Last", "first_name": "El loco mio", "email_verified": false, "phone_verified": false}	\N	2024-10-02 02:57:47.274299+00	2024-10-02 03:53:54.237216+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	dd3f6685-376d-4e7b-a4fa-7749826cc4af	authenticated	authenticated	elrealchocolate@gmail.com	$2a$10$bRuWw9WBvhE3/qEp3jGwIOEu3xcxXmrN7L2fjtQqu0CTLGhZdDtnq	2024-09-08 21:14:08.20413+00	\N		2024-09-08 20:43:07.154925+00		\N			\N	2024-09-08 21:14:08.212316+00	{"provider": "email", "providers": ["email"]}	{"sub": "dd3f6685-376d-4e7b-a4fa-7749826cc4af", "email": "elrealchocolate@gmail.com", "last_name": "Moreno", "first_name": "Angel", "email_verified": false, "phone_verified": false}	\N	2024-09-08 20:43:07.123729+00	2024-09-08 21:14:08.229942+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	94d84199-abd0-4390-af51-8d1e40715a6e	authenticated	authenticated	gyqobnlnkkytjbaych@poplk.com	$2a$10$b/dkPB0u2tADEli0am1eE.mcjsCQKMZCC3ehfyQ4.aeuHeGZMAo7a	2024-10-16 21:51:15.582849+00	\N		2024-10-16 21:51:03.292758+00		\N			\N	2024-10-16 22:13:44.696763+00	{"provider": "email", "providers": ["email"]}	{"sub": "94d84199-abd0-4390-af51-8d1e40715a6e", "email": "gyqobnlnkkytjbaych@poplk.com", "last_name": "Perez", "first_name": "Pedro", "email_verified": false, "phone_verified": false}	\N	2024-10-16 21:51:03.265204+00	2024-10-16 22:13:44.698905+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d9f130fe-d9e1-4d1c-a160-03c8ad109af4	authenticated	authenticated	jubhcivoflhbeaoqhm@nbmbb.com	$2a$10$6.o7S9a5t7PhNqznQY4gjuOsMsMEgYIKC3GFTcRTnJc1FX/OdTc1K	\N	\N	cd4e5144b4c47a7c527b85e0bcaa52ee4808083f5960e6b36f6279c8	2024-10-16 02:26:33.405951+00		\N			\N	\N	{"provider": "email", "providers": ["email"]}	{"sub": "d9f130fe-d9e1-4d1c-a160-03c8ad109af4", "email": "jubhcivoflhbeaoqhm@nbmbb.com", "last_name": "Alcachofa", "first_name": "Juanito", "email_verified": false, "phone_verified": false}	\N	2024-10-16 02:26:33.372653+00	2024-10-16 02:26:34.778746+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	24c17fbe-5b94-4f07-a473-5225a245263c	authenticated	authenticated	ghsfzsiovtsavnjeog@poplk.com	$2a$10$1fbBMfI6peVjjdjejkbyPOVY1oCN42sAT4JdeQ2Q3AfA0ImdzmU5G	2024-10-16 23:43:01.133537+00	\N		2024-10-16 23:42:22.83845+00		\N			\N	2024-10-16 23:44:21.366683+00	{"provider": "email", "providers": ["email"]}	{"sub": "24c17fbe-5b94-4f07-a473-5225a245263c", "email": "ghsfzsiovtsavnjeog@poplk.com", "last_name": "Perez", "first_name": "Pepito", "email_verified": false, "phone_verified": false}	\N	2024-10-16 23:42:22.823182+00	2024-10-16 23:44:21.368223+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c563f82f-cd5b-4187-a8b1-07d7038c74ce	authenticated	authenticated	huanhaowu28@gmail.com	$2a$10$rCshGVtGgYAwNILb1/VxiugMpQR5Ym2IVbVjfYTpr0kSvOf9JvgR6	2024-09-17 22:33:42.188325+00	\N		2024-09-17 22:33:17.332956+00		\N			\N	2024-11-08 01:17:54.078473+00	{"provider": "email", "providers": ["email"]}	{"sub": "c563f82f-cd5b-4187-a8b1-07d7038c74ce", "email": "huanhaowu28@gmail.com", "last_name": "Wu Wu", "first_name": "Huan Hao", "email_verified": false, "phone_verified": false}	\N	2024-09-17 22:33:17.291583+00	2024-11-11 23:00:53.738843+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: Comentarios_Tarea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Comentarios_Tarea" ("Comentario_ID", "Tarea_ID", contenido, "fechaRegistro", "fechaModificacion", "Usuario_ID") FROM stdin;
7	4	Este es un comentario de prueba.	2024-11-08 03:03:14.674381	\N	37d3b652-d314-4124-9685-add5f0c6fc19
8	7	Este es un comentario de prueba.	2024-11-08 03:03:19.882331	\N	37d3b652-d314-4124-9685-add5f0c6fc19
\.


--
-- Data for Name: Dependencias_Tarea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Dependencias_Tarea" ("Tarea_ID", "Dependencia_ID", fecharegistro) FROM stdin;
\.


--
-- Data for Name: Estados_Tarea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Estados_Tarea" (nombre, descripcion, "fechaRegistro", "fechaModificacion", "Estado_Tarea_ID") FROM stdin;
Nuevo	\N	2024-09-29 01:37:06.571603	\N	1
En Progreso	\N	2024-09-29 01:37:20.156675	\N	2
Completadas	\N	2024-09-29 01:37:53.210367	\N	3
Aprobadas	\N	2024-09-29 01:38:01.606225	\N	4
\.


--
-- Data for Name: Fuentes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Fuentes" ("Fuente_ID", nombre, precio, "fechaRegistro", "fechaModificacion") FROM stdin;
1	Arial	10.00	2024-09-14 20:59:14.382907	\N
2	Calibri	10.00	2024-09-14 21:20:41.026551	\N
3	Roboto	10.00	2024-09-14 21:20:46.393409	\N
4	Times New Romans	30.00	2024-09-24 15:31:03.01463	\N
\.


--
-- Data for Name: Historial_Fuentes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Historial_Fuentes" ("Fuente_ID", "cantidadComprada", "precioCompra", "fechaRegistro", "Usuario_ID", "HFuente_ID") FROM stdin;
1	1	10.00	2024-09-15 20:05:16.031415	37d3b652-d314-4124-9685-add5f0c6fc19	1
2	1	10.00	2024-09-23 02:38:05.661396	37d3b652-d314-4124-9685-add5f0c6fc19	2
3	1	10.00	2024-09-23 03:08:58.775925	37d3b652-d314-4124-9685-add5f0c6fc19	3
4	1	30.00	2024-09-24 15:50:11.323803	37d3b652-d314-4124-9685-add5f0c6fc19	4
\.


--
-- Data for Name: Historial_Recompensas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Historial_Recompensas" ("Recompensa_ID", "cantidadComprada", "precioCompra", "fechaRegistro", "Usuario_ID", "HRecompensa_ID") FROM stdin;
1	1	30.00	2024-09-16 01:21:38.721521	37d3b652-d314-4124-9685-add5f0c6fc19	1
2	1	80.00	2024-09-16 01:22:18.489602	37d3b652-d314-4124-9685-add5f0c6fc19	2
3	1	200.00	2024-09-16 01:22:45.515279	37d3b652-d314-4124-9685-add5f0c6fc19	3
1	1	30.00	2024-10-24 03:54:50.715096	37d3b652-d314-4124-9685-add5f0c6fc19	4
5	1	100.00	2024-11-08 01:21:04.830359	37d3b652-d314-4124-9685-add5f0c6fc19	5
\.


--
-- Data for Name: Historial_Temas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Historial_Temas" ("Tema_ID", "cantidadComprada", "precioCompra", "fechaRegistro", "Usuario_ID", "HTema_ID") FROM stdin;
1	1	50.00	2024-09-15 20:05:42.001735	37d3b652-d314-4124-9685-add5f0c6fc19	1
2	1	70.00	2024-09-15 20:06:19.393394	37d3b652-d314-4124-9685-add5f0c6fc19	2
3	1	100.00	2024-10-15 02:06:54.600668	37d3b652-d314-4124-9685-add5f0c6fc19	3
5	1	0.00	2024-10-16 02:19:11.028859	37d3b652-d314-4124-9685-add5f0c6fc19	4
4	1	0.00	2024-10-16 02:35:44.759435	37d3b652-d314-4124-9685-add5f0c6fc19	5
6	1	50.00	2024-10-16 02:37:25.702996	37d3b652-d314-4124-9685-add5f0c6fc19	6
7	1	200.00	2024-10-16 22:09:53.80766	37d3b652-d314-4124-9685-add5f0c6fc19	7
8	1	200.00	2024-11-01 02:50:45.642127	37d3b652-d314-4124-9685-add5f0c6fc19	17
\.


--
-- Data for Name: Iconos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Iconos" ("Icono_ID", nombre, "fechaRegistro", "fechaModificacion") FROM stdin;
1	iconoPrueba	2024-09-05 18:08:57.017356	\N
\.


--
-- Data for Name: Idiomas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Idiomas" ("Idioma_ID", nombre, "fechaRegistro", "fechaModificacion") FROM stdin;
\.


--
-- Data for Name: Insignia_Categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Insignia_Categoria" ("Insignia_Cat_ID", nombre, "campoComparativo", "fechaRegistro", "fechaModificacion") FROM stdin;
1	Approved Tasks	tareasAprobadas	2024-10-20 23:21:27.549758	\N
2	Reached Level	nivel	2024-10-20 23:21:59.123455	\N
3	Total Gems Obtained	totalGemas	2024-10-20 23:23:03.107001	\N
4	Total created projects	proyectosCreados	2024-10-20 23:23:15.353838	2024-10-20 23:36:51.935
\.


--
-- Data for Name: Insignia_Conseguida; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Insignia_Conseguida" ("Insignia_ID", "fechaRegistro", "Usuario_ID") FROM stdin;
18	2024-10-22 04:03:09.101356	37d3b652-d314-4124-9685-add5f0c6fc19
8	2024-11-06 02:08:21.442714	37d3b652-d314-4124-9685-add5f0c6fc19
13	2024-11-06 02:08:21.442714	37d3b652-d314-4124-9685-add5f0c6fc19
14	2024-11-06 02:08:21.442714	37d3b652-d314-4124-9685-add5f0c6fc19
15	2024-11-06 02:08:21.442714	37d3b652-d314-4124-9685-add5f0c6fc19
16	2024-11-06 02:08:21.442714	37d3b652-d314-4124-9685-add5f0c6fc19
17	2024-11-06 02:08:21.442714	37d3b652-d314-4124-9685-add5f0c6fc19
3	2024-11-06 02:08:21.442714	37d3b652-d314-4124-9685-add5f0c6fc19
8	2024-11-06 02:09:42.257506	c563f82f-cd5b-4187-a8b1-07d7038c74ce
4	2024-11-06 02:12:33.680332	37d3b652-d314-4124-9685-add5f0c6fc19
5	2024-11-06 02:13:59.264016	37d3b652-d314-4124-9685-add5f0c6fc19
\.


--
-- Data for Name: Insignias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Insignias" ("Insignia_ID", nombre, descripcion, "Insignia_Cat_ID", meta, foto, "fechaRegistro", "fechaModificacion") FROM stdin;
4	Steady Progress	Get 5 task approved	1	5	\N	2024-10-22 02:52:36.256954	\N
5	Making a Dent	Get 20 task approved	1	20	\N	2024-10-22 02:53:08.00423	\N
6	C'mon bring the tasks	Get 50 task approved	1	50	\N	2024-10-22 02:54:07.542563	\N
7	Maybe take a break?	Get 100 task approved	1	100	\N	2024-10-22 02:54:30.87895	\N
8	Novice No More	Reach level 5	2	5	\N	2024-10-22 02:54:55.585612	\N
9	Climbing the Ladder	Reach level 10	2	10	\N	2024-10-22 02:55:11.550457	\N
10	Serious Contender	Reach level 20	2	20	\N	2024-10-22 02:55:55.333685	\N
11	Pro Status	Reach level 50	2	50	\N	2024-10-22 02:56:29.147827	\N
12	Trying to Impress the Boss?	Reach level 100	2	100	\N	2024-10-22 02:59:49.513058	\N
13	Gem Hunter	Collect a total of 10 gems	3	10	\N	2024-10-22 03:01:51.817836	\N
14	Treasure Seeker	Collect a total of 50 gems	3	50	\N	2024-10-22 03:04:02.628466	\N
15	Hoarder	Collect a total of 100 gems	3	100	\N	2024-10-22 03:04:16.824437	\N
16	Wealth Builder	Collect a total of 250 gems	3	250	\N	2024-10-22 03:04:35.463041	\N
17	Pizza Day Enjoyer	Collect a total of 500 gems	3	500	\N	2024-10-22 03:04:57.544808	\N
18	Taking the Reins	Create 1 project	4	1	\N	2024-10-22 03:09:26.201927	\N
19	Natural Leader	Create 3 projects	4	3	\N	2024-10-22 03:10:08.341312	\N
20	Team Captain	Create 5 projects	4	5	\N	2024-10-22 03:10:30.987625	\N
21	Project Prodigy	Create 10 projects	4	10	\N	2024-10-22 03:10:47.273324	\N
22	Master Coordinator	Create 20 projects	4	20	\N	2024-10-22 03:11:01.314006	\N
3	Getting Started	Get 1 task approved	1	1	\N	2024-10-22 02:52:07.251249	2024-10-22 03:13:58.73
\.


--
-- Data for Name: Invitaciones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Invitaciones" ("Invitacion_ID", "Proyecto_ID", correo, token, "fechaExpiracion", "fechaRegistro", "fueUsado") FROM stdin;
46	1	gyqobnlnkkytjbaych@poplk.com	79696c8ca4d81365e83abb6a35e15dd10a497923	2024-10-17 22:26:01.874462	2024-10-16 22:26:01.874462	f
1	1	elrealchocolate@gmail.com	f690129ef893f6d6ef2c191c4c77a80326cd179d	2024-09-09 18:53:39.065914	2024-09-08 18:53:39.065914	t
2	1	1104666@est.intec.edu.do	339a53ff4d27a1b2770d685ad7ea0107387e211b	2024-09-11 19:58:27.460895	2024-09-10 19:58:27.460895	f
3	1	angelgmorenor@gmail.com	f63b2b9f9a2567034d8297922ac3e0ab0482a251	2024-09-11 21:31:53.640038	2024-09-10 21:31:53.640038	f
4	1	angelgmorenor@gmail.com	0b6e0080c23e70dfe13239b01b1907e1a9d35a62	2024-09-11 21:33:17.965215	2024-09-10 21:33:17.965215	f
5	1	angelgmorenor@gmail.com	502bc1274e0200b2974d715924046f7749f71d7c	2024-09-11 21:33:21.135738	2024-09-10 21:33:21.135738	f
6	1	angelgmorenor@gmail.com	5552f7d300f637cef4c8862375b580fa70f8bbeb	2024-09-12 01:44:31.985472	2024-09-11 01:44:31.985472	f
7	1	angelgmorenor@gmail.com	7990d64b57f87732bead7fbd15867977cd75d4cd	2024-09-12 01:46:46.035033	2024-09-11 01:46:46.035033	f
8	1	angelgmorenor@gmail.com	9dccfa0a3281b058d9c0609ec2b2261e590072cc	2024-09-12 01:50:01.559495	2024-09-11 01:50:01.559495	f
9	1	angelgmorenor@gmail.com	26a5661486993c731c400e7f759325df3fc3e869	2024-09-12 01:51:09.569008	2024-09-11 01:51:09.569008	f
10	1	angelgmorenor@gmail.com	ecc9370d85af37c7057f46759545677c492d667d	2024-09-14 22:14:30.257156	2024-09-13 22:14:30.257156	f
11	1	angelgmorenor@gmail.com	81ea43cef9526b3de0636795a9159d173222b604	2024-09-14 22:18:25.054851	2024-09-13 22:18:25.054851	f
12	3	example@gmail.com	c6817fb3b9e10e18143b9555fed9dbf37acec5a1	2024-10-10 02:02:33.240648	2024-10-09 02:02:33.240648	f
13	1	angelgmorenor@gmail.com	903b5f4b69b43c84eb025f46a9f7051ef14997d9	2024-10-10 02:24:02.266426	2024-10-09 02:24:02.266426	f
14	4	example@gmail.com	b2eb0d440cdab8e6394e71c222c3ea954481deb7	2024-10-10 02:50:18.065187	2024-10-09 02:50:18.065187	f
15	5	example@gmail.com	7f25f864bb582a437275b79924e9acffb71469a0	2024-10-10 02:59:49.640105	2024-10-09 02:59:49.640105	f
16	5	example@gmail.com	8c5e63dfe6d21e2bbf52013b0eb86233701b6dd8	2024-10-10 03:07:48.734962	2024-10-09 03:07:48.734962	f
17	5	example@gmail.com	3da6bd68a4eceb69d28e5c3c900dd0cb552599b7	2024-10-11 00:03:38.160122	2024-10-10 00:03:38.160122	f
18	2	example@gmail.com	6a73af673db1172d21f6e2b095cde061a56bd38a	2024-10-12 02:06:03.86134	2024-10-11 02:06:03.86134	f
19	3	example@gmail.com	e4a43dbfda57833e28d56223b720d4beaa14f0ef	2024-10-12 03:07:58.668888	2024-10-11 03:07:58.668888	f
20	3	examplde@gmail.com	a658046dcd14a59845276f1d663d49c17efb2ac6	2024-10-12 03:08:44.741279	2024-10-11 03:08:44.741279	f
21	4	example1@gmail.com	432316ede19e4db8f74e7c8acdb8629ec35e26db	2024-10-12 03:10:49.899588	2024-10-11 03:10:49.899588	f
22	4	example@gmail.com	5e18b6932585da35a366da7c1ff4ef4838544726	2024-10-12 03:13:02.888832	2024-10-11 03:13:02.888832	f
23	4	hwu@gmail.com	d3488e4aa2644dbfa24bbac27cbdb87b8721bd25	2024-10-12 03:13:51.281776	2024-10-11 03:13:51.281776	f
24	4	huanhaowu28@gmail.com	fc0d668428b844fc2fa6b51bd68e7b3eb0a6cad2	2024-10-12 03:36:04.852392	2024-10-11 03:36:04.852392	t
25	3	huanhaowu28@gmail.com	efe430419bc0c1378cf096452e7a1401990eef61	2024-10-12 03:49:41.67564	2024-10-11 03:49:41.67564	t
26	2	huanhaowu28@gmail.com	c0908fe68becb9bc48c9c80b304fd5802add54df	2024-10-12 03:50:12.932145	2024-10-11 03:50:12.932145	t
27	2	huanhaowu28@gmail.com	b30bb4599ba7319cb6ab0ef0ccd44a7ae1f9aeef	2024-10-12 22:45:45.155521	2024-10-11 22:45:45.155521	f
28	1	huanhaowu28@gmail.com	94bfb2b6116f189cf3402ea2dce1ee35b26a3842	2024-10-12 22:45:50.389833	2024-10-11 22:45:50.389833	f
29	1	angelgmorenor@gmail.com	fbaa5807dcedb6136ac54de0ae18a233bcff24da	2024-10-12 22:58:39.279331	2024-10-11 22:58:39.279331	f
30	1	example@gmail.com	c483edd916cb2ec86cf3065cd906a916ee4d682d	2024-10-12 22:59:25.247526	2024-10-11 22:59:25.247526	f
31	1	untestvacano@gmail.com	c8a82ba52a002773501e743a5ea78e7396ff9a39	2024-10-12 23:01:05.605331	2024-10-11 23:01:05.605331	f
32	5	example@gmail.com	83152433d05785df1c2bfb0ae7d29e43456702fb	2024-10-12 23:09:35.514428	2024-10-11 23:09:35.514428	f
33	6	huanhaowu28@gmail.com	c3354316650d052ba0540a537673b9d335c7682b	2024-10-12 23:31:15.368072	2024-10-11 23:31:15.368072	t
34	1	huanhaowu28@gmail.com	93c69cd8ca86a6383e6633341a8337772ecd6b89	2024-10-14 20:17:37.069931	2024-10-13 20:17:37.069931	f
35	7	huanhaowu28@gmail.com	261aea63a296ec819ed4202985dbbe4ea346042d	2024-10-14 21:08:33.853108	2024-10-13 21:08:33.853108	t
36	7	huanhaowu28@gmaisl.com	9f64aca959d95b6171e60db301b4891f31cbc3d8	2024-10-14 22:12:38.942172	2024-10-13 22:12:38.942172	f
37	7	hsuanhaowu28@gmaisl.com	946933a1772ce676627d903f334da165f75fc32c	2024-10-14 22:39:04.155927	2024-10-13 22:39:04.155927	f
38	7	pepitogonzalez@gmaisl.com	cf3edb1b67f7aad83cfe684d119a1263aa180157	2024-10-14 22:39:48.229717	2024-10-13 22:39:48.229717	f
40	1	pepito@gmail.com	61bd168dfd71e3057bd42be2bac70937bdd7591b	2024-10-17 02:14:30.016851	2024-10-16 02:14:30.016851	f
41	1	pepito@gmail.com	a46938afae3370b0c4ff5d779e7137276c78e63c	2024-10-17 02:14:31.626181	2024-10-16 02:14:31.626181	f
42	1	fhzujkhblinlmulcip@hthlm.com	02b73ff8514e6e2ec4246825f0eb5931d407fbc2	2024-10-17 02:15:29.213878	2024-10-16 02:15:29.213878	f
43	1	fhzujkhblinlmulcip@hthlm.com	a32d05c8457d6d3280863c95de323a705ef42fbe	2024-10-17 02:16:07.753552	2024-10-16 02:16:07.753552	f
44	1	jubhcivoflhbeaoqhm@nbmbb.com	5703c50afbf2bfdfd0c1543c5b16483a9438a9d1	2024-10-17 02:24:35.754387	2024-10-16 02:24:35.754387	f
\.


--
-- Data for Name: Miembro_Proyecto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Miembro_Proyecto" ("Proyecto_ID", "Rol_ID", gemas, "fechaRegistro", "fechaModificacion", "Usuario_ID") FROM stdin;
1	1	0	2024-09-08 21:30:00.305756	\N	dd3f6685-376d-4e7b-a4fa-7749826cc4af
2	1	0	2024-09-14 23:21:09.310666	\N	dd3f6685-376d-4e7b-a4fa-7749826cc4af
3	2	0	2024-09-24 14:32:16.154384	\N	37d3b652-d314-4124-9685-add5f0c6fc19
4	2	0	2024-09-24 14:40:06.313835	\N	37d3b652-d314-4124-9685-add5f0c6fc19
5	2	0	2024-09-24 14:48:36.820187	\N	37d3b652-d314-4124-9685-add5f0c6fc19
6	2	0	2024-09-24 14:51:08.389923	\N	37d3b652-d314-4124-9685-add5f0c6fc19
7	2	0	2024-09-24 14:52:54.683372	\N	37d3b652-d314-4124-9685-add5f0c6fc19
8	2	0	2024-09-24 14:55:26.611039	\N	37d3b652-d314-4124-9685-add5f0c6fc19
9	2	0	2024-09-24 14:56:54.966405	\N	37d3b652-d314-4124-9685-add5f0c6fc19
10	2	0	2024-09-24 15:02:01.043954	\N	37d3b652-d314-4124-9685-add5f0c6fc19
11	2	0	2024-09-24 15:03:26.223274	\N	37d3b652-d314-4124-9685-add5f0c6fc19
12	2	0	2024-09-24 15:10:49.254586	\N	37d3b652-d314-4124-9685-add5f0c6fc19
13	2	0	2024-09-24 15:18:21.122277	\N	37d3b652-d314-4124-9685-add5f0c6fc19
14	2	0	2024-09-24 15:23:10.951254	\N	37d3b652-d314-4124-9685-add5f0c6fc19
15	2	0	2024-09-24 15:23:39.051177	\N	37d3b652-d314-4124-9685-add5f0c6fc19
2	1	0	2024-09-24 19:26:53.216548	\N	37d3b652-d314-4124-9685-add5f0c6fc19
16	2	0	2024-09-29 03:06:18.921916	\N	37d3b652-d314-4124-9685-add5f0c6fc19
17	2	0	2024-09-29 03:06:19.960095	\N	37d3b652-d314-4124-9685-add5f0c6fc19
18	2	0	2024-09-29 19:03:23.685462	\N	37d3b652-d314-4124-9685-add5f0c6fc19
19	2	0	2024-09-29 19:08:58.970577	\N	37d3b652-d314-4124-9685-add5f0c6fc19
20	2	0	2024-09-29 19:09:00.162051	\N	37d3b652-d314-4124-9685-add5f0c6fc19
21	2	0	2024-09-29 19:09:00.188206	\N	37d3b652-d314-4124-9685-add5f0c6fc19
22	2	0	2024-09-29 19:09:00.378524	\N	37d3b652-d314-4124-9685-add5f0c6fc19
23	2	0	2024-09-29 19:09:00.712134	\N	37d3b652-d314-4124-9685-add5f0c6fc19
24	2	0	2024-10-02 18:10:01.491154	\N	37d3b652-d314-4124-9685-add5f0c6fc19
25	2	0	2024-10-02 18:10:31.652042	\N	37d3b652-d314-4124-9685-add5f0c6fc19
26	2	0	2024-10-02 18:15:25.194721	\N	37d3b652-d314-4124-9685-add5f0c6fc19
27	2	0	2024-10-02 18:18:57.388912	\N	37d3b652-d314-4124-9685-add5f0c6fc19
28	2	0	2024-10-02 18:19:46.298061	\N	37d3b652-d314-4124-9685-add5f0c6fc19
1	1	0	2024-10-03 01:30:48.513343	\N	c15bca29-43e1-4536-a709-7e8da1d11758
29	2	0	2024-10-09 23:19:44.445931	\N	37d3b652-d314-4124-9685-add5f0c6fc19
4	1	0	2024-10-11 03:48:19.019458	\N	c563f82f-cd5b-4187-a8b1-07d7038c74ce
3	1	0	2024-10-11 03:49:51.523249	\N	c563f82f-cd5b-4187-a8b1-07d7038c74ce
2	1	0	2024-10-11 03:50:23.142214	\N	c563f82f-cd5b-4187-a8b1-07d7038c74ce
6	1	0	2024-10-11 23:32:23.89383	\N	c563f82f-cd5b-4187-a8b1-07d7038c74ce
30	2	0	2024-10-13 00:06:28.370408	\N	37d3b652-d314-4124-9685-add5f0c6fc19
1	1	0	2024-10-13 20:10:46.215554	\N	c563f82f-cd5b-4187-a8b1-07d7038c74ce
7	1	0	2024-10-13 21:09:06.686604	\N	c563f82f-cd5b-4187-a8b1-07d7038c74ce
31	2	0	2024-10-16 21:53:49.819971	\N	37d3b652-d314-4124-9685-add5f0c6fc19
1	2	0	2024-09-14 23:17:13.451393	\N	37d3b652-d314-4124-9685-add5f0c6fc19
\.


--
-- Data for Name: Preguntas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Preguntas" ("Pregunta_ID", titulo, contenido, "fechaRegistro", "fechaModificacion") FROM stdin;
\.


--
-- Data for Name: Proyectos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Proyectos" ("Proyecto_ID", nombre, descripcion, "fechaRegistro", "fechaModificacion", gastos, presupuesto, "Usuario_ID", eliminado) FROM stdin;
1	Proyecto Luma	Proyeto de prueba	2024-09-05 13:13:15.09251	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
2	Proyecto 2	Prueba	2024-09-05 14:33:49.126638	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
3	test Glei	El test de Gleidy	2024-09-24 14:32:16.154384	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
4	test nuevo	descripcion de test nuevo 	2024-09-24 14:40:06.313835	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
5	Test	Descripcion	2024-09-24 14:48:36.820187	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
6	proyecto Glei 2	Este es el proyecto de Gleidy 2	2024-09-24 14:51:08.389923	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
7	test Glei 3	test 	2024-09-24 14:52:54.683372	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
8	test 4	testttt	2024-09-24 14:55:26.611039	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
9	Test	Descripcion	2024-09-24 14:56:54.966405	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
10	test final	descripcion	2024-09-24 15:02:01.043954	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
11	Test 12	Descripcion	2024-09-24 15:03:26.223274	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
12	test Huan	descripcion	2024-09-24 15:10:49.254586	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
13	Proyecto 13	Descripcion	2024-09-24 15:18:21.122277	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
14	Proyecto 14	Descripcion	2024-09-24 15:23:10.951254	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
15	Test 15	Descripcion	2024-09-24 15:23:39.051177	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
16	trs	gui	2024-09-29 03:06:18.921916	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
17	trs	gui	2024-09-29 03:06:19.960095	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
18	TEST	PROYECTO	2024-09-29 19:03:23.685462	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
19	TEST	PROYECTO	2024-09-29 19:08:58.970577	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
20	TEST	PROYECTO	2024-09-29 19:09:00.162051	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
21	TEST	PROYECTO	2024-09-29 19:09:00.188206	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
22	TEST	PROYECTO	2024-09-29 19:09:00.378524	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
23	TEST	PROYECTO	2024-09-29 19:09:00.712134	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
24	Proyecto A1	El mejor proyecto	2024-10-02 18:10:01.491154	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
25	Proyecto A1	El mejor proyecto	2024-10-02 18:10:31.652042	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
26	Proyecto A1	El mejor proyecto	2024-10-02 18:15:25.194721	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
27	Proyecto A2	El verdadero proyecto	2024-10-02 18:18:57.388912	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
28	Proyecto A3	La tercera es la vencida	2024-10-02 18:19:46.298061	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
29	Prueba en vivo	Proyecto Jevi	2024-10-09 23:19:44.445931	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
30	test	test	2024-10-13 00:06:28.370408	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
31	Prueba Durisima	El mejor proyecto	2024-10-16 21:53:49.819971	\N	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f
\.


--
-- Data for Name: Recompensas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Recompensas" ("Recompensa_ID", "Proyecto_ID", "Icono_ID", nombre, descripcion, precio, cantidad, limite, "fechaRegistro", "fechaModificacion", "totalCompras") FROM stdin;
2	1	1	Nintendo Giftcard	\N	80.00	4	1	2024-09-16 01:18:44.545335	\N	1
3	2	1	Dia Libre	\N	200.00	1	1	2024-09-16 01:19:12.250934	\N	1
4	2	1	Dia de Pizza	Un dia de pizza jevi jevi	100.00	3	1	2024-09-24 19:21:21.412931	\N	0
1	1	1	Amazon Giftcard	\N	30.00	8	2	2024-09-16 01:15:12.023408	\N	2
6	1	1	test	\N	4.00	4	2	2024-10-28 03:10:33.437123	\N	0
5	1	1	Recompensa	Descripción de la recompensa	100.00	10	5	2024-10-28 02:56:37.450257	\N	1
\.


--
-- Data for Name: Roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Roles" ("Rol_ID", nombre, descripcion, "fechaRegistro", "fechaModificacion") FROM stdin;
1	Miembro	Rol base de miembro de proyecto	2024-09-08 21:27:59.006213	\N
2	Lider	Lider de un proyecto	2024-09-08 21:28:10.879588	\N
3	Creador	Creador de un proyecto	2024-09-14 23:16:22.206273	\N
\.


--
-- Data for Name: Tareas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Tareas" ("Tarea_ID", "Proyecto_ID", etiquetas, nombre, descripcion, prioridad, "valorGemas", "fueReclamada", "fechaRegistro", "fechaModificacion", "Usuario_ID", gastos, presupuesto, tiempo, "Estado_Tarea_ID", "esCritica", "fechaFin", "fechaInicio", "puntosExperiencia") FROM stdin;
6	1	back,c++	primera tarea glei	buenas noches	5	10	f	2024-09-30 03:29:35.056461	\N	\N	\N	\N	5	1	\N	\N	\N	100
4	1	JS,PYTHON,CODE	Test Task 2	\N	1	30	t	2024-09-29 02:38:47.77764	2024-10-30 18:41:00.570558	37d3b652-d314-4124-9685-add5f0c6fc19	\N	\N	3	2	\N	2021-12-02 00:00:00	2021-12-01 00:00:00	300
15	1	FINAL,TASK	TASK FINAL 	SIIIII	1	10	f	2024-10-14 04:55:43.030811	\N	37d3b652-d314-4124-9685-add5f0c6fc19	\N	\N	1	2	\N	2024-10-10 00:00:00	2024-10-14 00:00:00	100
8	1	front,React	test 2	tet2	1	10	f	2024-10-01 01:49:21.830284	\N	\N	\N	\N	1	3	\N	\N	\N	100
12	1	\N	TEST	HOLLLLL	1	20	f	2024-10-14 03:39:34.468901	\N	\N	\N	\N	2	2	\N	\N	\N	200
3	1	sprint01,back,python	Test Task	\N	1	30	t	2024-09-29 02:38:14.075677	2024-10-30 18:39:35.769816	c563f82f-cd5b-4187-a8b1-07d7038c74ce	\N	\N	3	2	\N	2021-09-02 00:00:00	2021-09-01 00:00:00	300
5	1	back	Test Task 3	\N	3	6	f	2024-09-29 02:40:46.181363	\N	\N	\N	\N	2	1	\N	2021-09-02 00:00:00	2021-09-01 00:00:00	66
9	1	front,React,JS	Tarea test	Una tarea durisima	1	30	f	2024-10-02 18:25:00.149627	\N	\N	\N	\N	3	2	\N	\N	\N	300
13	1	api,python	test 3	aaaaaaaaaaaaaaaaaaaaaa	2	5	f	2024-10-14 04:38:36.828868	\N	37d3b652-d314-4124-9685-add5f0c6fc19	\N	\N	1	1	\N	\N	\N	50
16	1		Integrar endpoint	Pendiente la integracion del endpoint para este punto	3	10	f	2024-11-06 02:43:39.634104	\N	37d3b652-d314-4124-9685-add5f0c6fc19	\N	\N	3	3	\N	2024-11-06 00:00:00	2024-11-06 00:00:00	100
14	1	api,ai	test 6	aaaaaaaaaaaaa	1	10	f	2024-10-14 04:40:15.56712	\N	37d3b652-d314-4124-9685-add5f0c6fc19	\N	\N	1	2	\N	\N	\N	100
7	1	sprint01	primera tarea glei	buenas noches	5	10	f	2024-10-01 01:32:03.376099	\N	\N	\N	\N	5	2	\N	\N	\N	100
\.


--
-- Data for Name: Temas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Temas" ("Tema_ID", nombre, precio, "accentHex", "primaryHex", "secondaryHex", "backgroundHex", "textHex", "fechaRegistro", "fechaModificacion", fuente) FROM stdin;
1	cupcake	50.00	#65c3c8	#fcd2d1	#f9a8d4	#fff7f5	#3d4451	2024-09-14 21:19:18.861849	\N	Figtree
2	bumblebee	70.00	#e0a82e	#f9d72f	#fcd34d	#fffdef	#373f51	2024-09-14 21:19:43.18045	\N	Font
3	emerald	100.00	#4ade80	#34d399	#10b981	#d1fae5	#065f46	2024-09-14 21:20:07.135833	\N	Font
4	light	0.00	AAA	AAA	AAA	AAA	AAA	2024-10-16 02:09:21.596543	\N	Fuente
5	dark	0.00	AAA	AAA	AAA	AAA	AAA	2024-10-16 02:09:43.797968	\N	Fuente
6	corporate	50.00	AAA	AAA	AAA	AAA	AAA	2024-10-16 02:10:22.480571	\N	Fuente
7	synthwave	200.00	AAA	AAA	AAA	AAA	AAA	2024-10-16 02:11:59.605493	\N	Fuente
8	retro	200.00	AAA	AAA	AAA	AAA	AAA	2024-10-16 02:12:51.833378	\N	Fuente
9	cyberpunk	500.00	AAA	AAA	AAA	AAA	AAA	2024-10-16 02:13:30.984313	\N	Fuente
\.


--
-- Data for Name: Usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Usuarios" (nombre, apellido, correo, experiencia, nivel, monedas, "totalGemas", "tareasAprobadas", "proyectosCreados", foto, "fechaRegistro", "fechaModificacion", "esAdmin", "Idioma_ID", "contraseña", "Usuario_ID", confirmado, "ultimoInicioSesion", eliminado) FROM stdin;
Angel	Moreno	angelgmorenor@gmail.com	2000	5	100	1060	20	0	https://kyttbsnmnrayejpbxmpp.supabase.co/storage/v1/object/sign/luma-assets/avatars/37d3b652-d314-4124-9685-add5f0c6fc19-gatococo1.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsdW1hLWFzc2V0cy9hdmF0YXJzLzM3ZDNiNjUyLWQzMTQtNDEyNC05Njg1LWFkZDVmMGM2ZmMxOS1nYXRvY29jbzEuanBnIiwiaWF0IjoxNzMwMDg1NTgzLCJleHAiOjE3NjE2MjE1ODN9.O8bKeK4aQQP9aAvb0phE0h7P70R9Zpbkv-lVkBAhhNA	2024-09-04 00:21:22.022788	\N	f	\N	\N	37d3b652-d314-4124-9685-add5f0c6fc19	f	2024-10-23 01:32:50.054115	f
Huan Hao	Wu Wu	huanhaowu28@gmail.com	2000	5	200	0	0	0	\N	2024-09-17 22:33:17.291193	\N	f	\N	\N	c563f82f-cd5b-4187-a8b1-07d7038c74ce	f	2024-11-08 01:17:54.078473	f
Angel	Moreno	elrealchocolate@gmail.com	0	1	0	0	0	0	\N	2024-09-08 20:43:07.122863	\N	f	\N	\N	dd3f6685-376d-4e7b-a4fa-7749826cc4af	f	2024-09-08 21:14:08.212316	f
Juanito	Alcachofa	jubhcivoflhbeaoqhm@nbmbb.com	0	1	0	0	0	0	\N	2024-10-16 02:26:33.372236	\N	f	\N	\N	d9f130fe-d9e1-4d1c-a160-03c8ad109af4	f	\N	f
El loco mio	Last	example@gmail.com	100	2	100	100	10	5	ruta foto	2024-10-02 02:57:47.273529	2024-10-02 04:09:04.070999	f	\N	$2a$10$HfYMLs.rSlbI02e76gdgvOoUOe7YU0fbfZOJ0/9/M58UyTn2jLKmq	40addfbf-eb76-4168-a03b-ac07036832fc	f	2024-10-02 02:58:31.502	f
Pedro	Perez	gyqobnlnkkytjbaych@poplk.com	0	1	0	0	0	0	\N	2024-10-16 21:51:03.264803	\N	f	\N	\N	94d84199-abd0-4390-af51-8d1e40715a6e	f	2024-10-16 22:13:44.696763	f
Juanito	Alcachofa	tuadmndoatnfqbeebp@hthlm.com	0	1	0	0	0	0	\N	2024-10-02 18:50:34.97088	\N	f	\N	\N	c15bca29-43e1-4536-a709-7e8da1d11758	f	2024-10-02 18:51:25.903356	t
Pepito	Perez	ghsfzsiovtsavnjeog@poplk.com	0	1	0	0	0	0	\N	2024-10-16 23:42:22.822801	\N	f	\N	\N	24c17fbe-5b94-4f07-a473-5225a245263c	f	2024-10-16 23:44:21.366683	f
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 510, true);


--
-- Name: Invitaciones_Invitacion_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Invitaciones_Invitacion_ID_seq"', 46, true);


--
-- Name: comentarios_tarea_comentario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comentarios_tarea_comentario_id_seq', 8, true);


--
-- Name: estados_tarea_estado_tarea_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estados_tarea_estado_tarea_id_seq', 4, true);


--
-- Name: fuentes_fuente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fuentes_fuente_id_seq', 4, true);


--
-- Name: historial_fuentes_hfuente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_fuentes_hfuente_id_seq', 4, true);


--
-- Name: historial_recompensas_hrecompensa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_recompensas_hrecompensa_id_seq', 5, true);


--
-- Name: historial_temas_htema_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historial_temas_htema_id_seq', 17, true);


--
-- Name: iconos_icono_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.iconos_icono_id_seq', 1, true);


--
-- Name: idiomas_idioma_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.idiomas_idioma_id_seq', 1, false);


--
-- Name: insignia_categoria_insignia_cat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.insignia_categoria_insignia_cat_id_seq', 4, true);


--
-- Name: insignias_insignia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.insignias_insignia_id_seq', 32, true);


--
-- Name: preguntas_pregunta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.preguntas_pregunta_id_seq', 1, false);


--
-- Name: proyectos_proyecto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.proyectos_proyecto_id_seq', 31, true);


--
-- Name: recompensas_recompensa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.recompensas_recompensa_id_seq', 7, true);


--
-- Name: roles_rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_rol_id_seq', 3, true);


--
-- Name: tareas_tarea_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tareas_tarea_id_seq', 16, true);


--
-- Name: temas_tema_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.temas_tema_id_seq', 9, true);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: Comentarios_Tarea Comentarios_Tarea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Comentarios_Tarea"
    ADD CONSTRAINT "Comentarios_Tarea_pkey" PRIMARY KEY ("Comentario_ID");


--
-- Name: Dependencias_Tarea Dependencias_Tarea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dependencias_Tarea"
    ADD CONSTRAINT "Dependencias_Tarea_pkey" PRIMARY KEY ("Tarea_ID", "Dependencia_ID");


--
-- Name: Estados_Tarea Estados_Tarea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Estados_Tarea"
    ADD CONSTRAINT "Estados_Tarea_pkey" PRIMARY KEY ("Estado_Tarea_ID");


--
-- Name: Fuentes Fuentes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Fuentes"
    ADD CONSTRAINT "Fuentes_pkey" PRIMARY KEY ("Fuente_ID");


--
-- Name: Historial_Fuentes Historial_Fuentes_HFuente_ID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Fuentes"
    ADD CONSTRAINT "Historial_Fuentes_HFuente_ID_key" UNIQUE ("HFuente_ID");


--
-- Name: Historial_Fuentes Historial_Fuentes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Fuentes"
    ADD CONSTRAINT "Historial_Fuentes_pkey" PRIMARY KEY ("HFuente_ID");


--
-- Name: Historial_Recompensas Historial_Recompensas_HRecompensa_ID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Recompensas"
    ADD CONSTRAINT "Historial_Recompensas_HRecompensa_ID_key" UNIQUE ("HRecompensa_ID");


--
-- Name: Historial_Recompensas Historial_Recompensas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Recompensas"
    ADD CONSTRAINT "Historial_Recompensas_pkey" PRIMARY KEY ("HRecompensa_ID");


--
-- Name: Historial_Temas Historial_Temas_HTema_ID_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Temas"
    ADD CONSTRAINT "Historial_Temas_HTema_ID_key" UNIQUE ("HTema_ID");


--
-- Name: Historial_Temas Historial_Temas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Temas"
    ADD CONSTRAINT "Historial_Temas_pkey" PRIMARY KEY ("HTema_ID");


--
-- Name: Iconos Iconos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Iconos"
    ADD CONSTRAINT "Iconos_pkey" PRIMARY KEY ("Icono_ID");


--
-- Name: Idiomas Idiomas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Idiomas"
    ADD CONSTRAINT "Idiomas_pkey" PRIMARY KEY ("Idioma_ID");


--
-- Name: Insignia_Categoria Insignia_Categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignia_Categoria"
    ADD CONSTRAINT "Insignia_Categoria_pkey" PRIMARY KEY ("Insignia_Cat_ID");


--
-- Name: Insignia_Conseguida Insignia_Conseguida_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignia_Conseguida"
    ADD CONSTRAINT "Insignia_Conseguida_pkey" PRIMARY KEY ("Insignia_ID", "Usuario_ID");


--
-- Name: Insignias Insignias_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignias"
    ADD CONSTRAINT "Insignias_pkey" PRIMARY KEY ("Insignia_ID");


--
-- Name: Invitaciones Invitaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invitaciones"
    ADD CONSTRAINT "Invitaciones_pkey" PRIMARY KEY ("Invitacion_ID");


--
-- Name: Miembro_Proyecto Miembro_Proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Miembro_Proyecto"
    ADD CONSTRAINT "Miembro_Proyecto_pkey" PRIMARY KEY ("Usuario_ID", "Proyecto_ID");


--
-- Name: Preguntas Preguntas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Preguntas"
    ADD CONSTRAINT "Preguntas_pkey" PRIMARY KEY ("Pregunta_ID");


--
-- Name: Proyectos Proyectos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Proyectos"
    ADD CONSTRAINT "Proyectos_pkey" PRIMARY KEY ("Proyecto_ID");


--
-- Name: Recompensas Recompensas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recompensas"
    ADD CONSTRAINT "Recompensas_pkey" PRIMARY KEY ("Recompensa_ID");


--
-- Name: Roles Roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Roles"
    ADD CONSTRAINT "Roles_pkey" PRIMARY KEY ("Rol_ID");


--
-- Name: Tareas Tareas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tareas"
    ADD CONSTRAINT "Tareas_pkey" PRIMARY KEY ("Tarea_ID");


--
-- Name: Temas Temas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Temas"
    ADD CONSTRAINT "Temas_pkey" PRIMARY KEY ("Tema_ID");


--
-- Name: Usuarios Usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Usuarios"
    ADD CONSTRAINT "Usuarios_pkey" PRIMARY KEY ("Usuario_ID");


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: Usuarios_eliminado_Usuario_ID_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Usuarios_eliminado_Usuario_ID_idx" ON public."Usuarios" USING btree (eliminado, "Usuario_ID");


--
-- Name: Usuarios_eliminado_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Usuarios_eliminado_idx" ON public."Usuarios" USING btree (eliminado);


--
-- Name: users auth_user_delete_trigger; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER auth_user_delete_trigger AFTER UPDATE OF deleted_at ON auth.users FOR EACH ROW WHEN ((new.deleted_at IS DISTINCT FROM old.deleted_at)) EXECUTE FUNCTION public.update_on_delete_usuarios_table();


--
-- Name: users auth_user_update_trigger; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER auth_user_update_trigger AFTER UPDATE OF email, raw_user_meta_data, encrypted_password ON auth.users FOR EACH ROW WHEN ((((new.email)::text IS DISTINCT FROM (old.email)::text) OR ((new.raw_user_meta_data ->> 'first_name'::text) IS DISTINCT FROM (old.raw_user_meta_data ->> 'first_name'::text)) OR ((new.raw_user_meta_data ->> 'last_name'::text) IS DISTINCT FROM (old.raw_user_meta_data ->> 'last_name'::text)) OR ((new.encrypted_password)::text IS DISTINCT FROM (old.encrypted_password)::text))) EXECUTE FUNCTION public.update_usuarios_table();


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: users trigger_update_last_sign_in; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER trigger_update_last_sign_in AFTER UPDATE OF last_sign_in_at ON auth.users FOR EACH ROW WHEN ((new.last_sign_in_at IS DISTINCT FROM old.last_sign_in_at)) EXECUTE FUNCTION public.update_last_sign_in();


--
-- Name: Usuarios trigger_check_user_badges; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_check_user_badges AFTER UPDATE OF nivel, "tareasAprobadas", "totalGemas", "proyectosCreados" ON public."Usuarios" FOR EACH ROW EXECUTE FUNCTION public.check_user_badges();


--
-- Name: Usuarios trigger_increase_user_level; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_increase_user_level AFTER UPDATE OF experiencia ON public."Usuarios" FOR EACH ROW WHEN ((new.experiencia > old.experiencia)) EXECUTE FUNCTION public.increase_user_level();


--
-- Name: Usuarios trigger_update_auth_metadata; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_auth_metadata AFTER UPDATE OF nombre, apellido ON public."Usuarios" FOR EACH ROW EXECUTE FUNCTION public.update_auth_metadata();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: Comentarios_Tarea Comentarios_Tarea_Tarea_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Comentarios_Tarea"
    ADD CONSTRAINT "Comentarios_Tarea_Tarea_ID_fkey" FOREIGN KEY ("Tarea_ID") REFERENCES public."Tareas"("Tarea_ID") ON DELETE CASCADE;


--
-- Name: Comentarios_Tarea Comentarios_Tarea_Usuario_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Comentarios_Tarea"
    ADD CONSTRAINT "Comentarios_Tarea_Usuario_ID_fkey" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID");


--
-- Name: Dependencias_Tarea Dependencias_Tarea_Dependencia_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dependencias_Tarea"
    ADD CONSTRAINT "Dependencias_Tarea_Dependencia_ID_fkey" FOREIGN KEY ("Dependencia_ID") REFERENCES public."Tareas"("Tarea_ID");


--
-- Name: Dependencias_Tarea Dependencias_Tarea_Tarea_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dependencias_Tarea"
    ADD CONSTRAINT "Dependencias_Tarea_Tarea_ID_fkey" FOREIGN KEY ("Tarea_ID") REFERENCES public."Tareas"("Tarea_ID");


--
-- Name: Historial_Recompensas FK_Historial_Recompensas.Recompensa_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Recompensas"
    ADD CONSTRAINT "FK_Historial_Recompensas.Recompensa_ID" FOREIGN KEY ("Recompensa_ID") REFERENCES public."Recompensas"("Recompensa_ID");


--
-- Name: Historial_Recompensas FK_Historial_Recompensas.Usuario_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Recompensas"
    ADD CONSTRAINT "FK_Historial_Recompensas.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID") ON DELETE CASCADE;


--
-- Name: Historial_Fuentes FK_Historial_Recompensas_Fuentes.Fuente_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Fuentes"
    ADD CONSTRAINT "FK_Historial_Recompensas_Fuentes.Fuente_ID" FOREIGN KEY ("Fuente_ID") REFERENCES public."Fuentes"("Fuente_ID");


--
-- Name: Historial_Fuentes FK_Historial_Recompensas_Fuentes.Usuario_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Fuentes"
    ADD CONSTRAINT "FK_Historial_Recompensas_Fuentes.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID") ON DELETE CASCADE;


--
-- Name: Historial_Temas FK_Historial_Recompensas_Temas.Tema_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Temas"
    ADD CONSTRAINT "FK_Historial_Recompensas_Temas.Tema_ID" FOREIGN KEY ("Tema_ID") REFERENCES public."Temas"("Tema_ID");


--
-- Name: Historial_Temas FK_Historial_Recompensas_Temas.Usuario_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Historial_Temas"
    ADD CONSTRAINT "FK_Historial_Recompensas_Temas.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID") ON DELETE CASCADE;


--
-- Name: Insignia_Conseguida FK_Insignia_Conseguida.Insignia_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignia_Conseguida"
    ADD CONSTRAINT "FK_Insignia_Conseguida.Insignia_ID" FOREIGN KEY ("Insignia_ID") REFERENCES public."Insignias"("Insignia_ID");


--
-- Name: Insignia_Conseguida FK_Insignia_Conseguida.Usuario_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignia_Conseguida"
    ADD CONSTRAINT "FK_Insignia_Conseguida.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID") ON DELETE CASCADE;


--
-- Name: Insignias FK_Insignias.Insignia_Cat_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Insignias"
    ADD CONSTRAINT "FK_Insignias.Insignia_Cat_ID" FOREIGN KEY ("Insignia_Cat_ID") REFERENCES public."Insignia_Categoria"("Insignia_Cat_ID");


--
-- Name: Miembro_Proyecto FK_Miembro_Proyecto.Proyecto_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Miembro_Proyecto"
    ADD CONSTRAINT "FK_Miembro_Proyecto.Proyecto_ID" FOREIGN KEY ("Proyecto_ID") REFERENCES public."Proyectos"("Proyecto_ID");


--
-- Name: Miembro_Proyecto FK_Miembro_Proyecto.Rol_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Miembro_Proyecto"
    ADD CONSTRAINT "FK_Miembro_Proyecto.Rol_ID" FOREIGN KEY ("Rol_ID") REFERENCES public."Roles"("Rol_ID");


--
-- Name: Miembro_Proyecto FK_Miembro_Proyecto.Usuario_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Miembro_Proyecto"
    ADD CONSTRAINT "FK_Miembro_Proyecto.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID") ON DELETE CASCADE;


--
-- Name: Recompensas FK_Recompensas.Icono_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recompensas"
    ADD CONSTRAINT "FK_Recompensas.Icono_ID" FOREIGN KEY ("Icono_ID") REFERENCES public."Iconos"("Icono_ID");


--
-- Name: Recompensas FK_Recompensas.Proyecto_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Recompensas"
    ADD CONSTRAINT "FK_Recompensas.Proyecto_ID" FOREIGN KEY ("Proyecto_ID") REFERENCES public."Proyectos"("Proyecto_ID");


--
-- Name: Tareas FK_Tareas.Proyecto_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tareas"
    ADD CONSTRAINT "FK_Tareas.Proyecto_ID" FOREIGN KEY ("Proyecto_ID") REFERENCES public."Proyectos"("Proyecto_ID");


--
-- Name: Tareas FK_Tareas.Usuario_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tareas"
    ADD CONSTRAINT "FK_Tareas.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID");


--
-- Name: Usuarios FK_Usuarios.Idioma_ID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Usuarios"
    ADD CONSTRAINT "FK_Usuarios.Idioma_ID" FOREIGN KEY ("Idioma_ID") REFERENCES public."Idiomas"("Idioma_ID");


--
-- Name: Invitaciones Invitaciones_Proyecto_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Invitaciones"
    ADD CONSTRAINT "Invitaciones_Proyecto_ID_fkey" FOREIGN KEY ("Proyecto_ID") REFERENCES public."Proyectos"("Proyecto_ID");


--
-- Name: Proyectos Proyectos_Usuario_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Proyectos"
    ADD CONSTRAINT "Proyectos_Usuario_ID_fkey" FOREIGN KEY ("Usuario_ID") REFERENCES public."Usuarios"("Usuario_ID") ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Tareas Tareas_Estado_Tarea_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tareas"
    ADD CONSTRAINT "Tareas_Estado_Tarea_ID_fkey" FOREIGN KEY ("Estado_Tarea_ID") REFERENCES public."Estados_Tarea"("Estado_Tarea_ID");


--
-- Name: Usuarios Usuarios_Usuario_ID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Usuarios"
    ADD CONSTRAINT "Usuarios_Usuario_ID_fkey" FOREIGN KEY ("Usuario_ID") REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: users All Public Auth Users Access; Type: POLICY; Schema: auth; Owner: supabase_auth_admin
--

CREATE POLICY "All Public Auth Users Access" ON auth.users USING (true);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: Usuarios All Public Users Access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "All Public Users Access" ON public."Usuarios" USING (true);


--
-- Name: Insignia_Conseguida; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public."Insignia_Conseguida" ENABLE ROW LEVEL SECURITY;

--
-- Name: Insignia_Conseguida Obtained Badge Anonimous Access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Obtained Badge Anonimous Access" ON public."Insignia_Conseguida" USING (true);


--
-- Name: Usuarios Public profiles are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public profiles are viewable by everyone." ON public."Usuarios" FOR SELECT USING (true);


--
-- Name: Usuarios Users can insert their own profile.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own profile." ON public."Usuarios" FOR INSERT WITH CHECK ((( SELECT auth.uid() AS uid) = "Usuario_ID"));


--
-- Name: Usuarios Users can update own profile.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own profile." ON public."Usuarios" FOR UPDATE USING (true);


--
-- Name: Usuarios; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public."Usuarios" ENABLE ROW LEVEL SECURITY;

--
-- Name: Usuarios insert-auth-admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "insert-auth-admin" ON public."Usuarios" FOR INSERT TO supabase_auth_admin WITH CHECK (true);


--
-- Name: Usuarios select-auth-admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "select-auth-admin" ON public."Usuarios" FOR SELECT TO supabase_auth_admin USING (true);


--
-- Name: Usuarios update-auth-admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "update-auth-admin" ON public."Usuarios" FOR UPDATE TO supabase_auth_admin USING (true) WITH CHECK (true);


--
-- Name: Usuarios user-public-insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "user-public-insert" ON public."Usuarios" FOR INSERT WITH CHECK (true);


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;
GRANT ALL ON FUNCTION auth.email() TO postgres;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;
GRANT ALL ON FUNCTION auth.role() TO postgres;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;
GRANT ALL ON FUNCTION auth.uid() TO postgres;


--
-- Name: FUNCTION approve_task(p_user_id uuid, p_task_id integer, p_new_status_id integer, p_project_id integer, p_task_claimed boolean, p_experience integer, p_gems integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.approve_task(p_user_id uuid, p_task_id integer, p_new_status_id integer, p_project_id integer, p_task_claimed boolean, p_experience integer, p_gems integer) TO anon;
GRANT ALL ON FUNCTION public.approve_task(p_user_id uuid, p_task_id integer, p_new_status_id integer, p_project_id integer, p_task_claimed boolean, p_experience integer, p_gems integer) TO authenticated;
GRANT ALL ON FUNCTION public.approve_task(p_user_id uuid, p_task_id integer, p_new_status_id integer, p_project_id integer, p_task_claimed boolean, p_experience integer, p_gems integer) TO service_role;


--
-- Name: FUNCTION buy_with_coins_transaction(p_user_id uuid, p_reward_id integer, p_reward_type text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.buy_with_coins_transaction(p_user_id uuid, p_reward_id integer, p_reward_type text) TO anon;
GRANT ALL ON FUNCTION public.buy_with_coins_transaction(p_user_id uuid, p_reward_id integer, p_reward_type text) TO authenticated;
GRANT ALL ON FUNCTION public.buy_with_coins_transaction(p_user_id uuid, p_reward_id integer, p_reward_type text) TO service_role;


--
-- Name: FUNCTION buy_with_gems_transaction(p_usuario_id uuid, p_recompensa_id integer, p_precio numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.buy_with_gems_transaction(p_usuario_id uuid, p_recompensa_id integer, p_precio numeric) TO anon;
GRANT ALL ON FUNCTION public.buy_with_gems_transaction(p_usuario_id uuid, p_recompensa_id integer, p_precio numeric) TO authenticated;
GRANT ALL ON FUNCTION public.buy_with_gems_transaction(p_usuario_id uuid, p_recompensa_id integer, p_precio numeric) TO service_role;


--
-- Name: FUNCTION check_user_badges(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.check_user_badges() TO anon;
GRANT ALL ON FUNCTION public.check_user_badges() TO authenticated;
GRANT ALL ON FUNCTION public.check_user_badges() TO service_role;


--
-- Name: FUNCTION create_project_with_creator(project_name text, project_description text, creator_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_project_with_creator(project_name text, project_description text, creator_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.create_project_with_creator(project_name text, project_description text, creator_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.create_project_with_creator(project_name text, project_description text, creator_user_id uuid) TO service_role;


--
-- Name: FUNCTION handle_invitation_transaction(invitation_id integer, user_id uuid, project_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_invitation_transaction(invitation_id integer, user_id uuid, project_id integer) TO anon;
GRANT ALL ON FUNCTION public.handle_invitation_transaction(invitation_id integer, user_id uuid, project_id integer) TO authenticated;
GRANT ALL ON FUNCTION public.handle_invitation_transaction(invitation_id integer, user_id uuid, project_id integer) TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION increase_user_level(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.increase_user_level() TO anon;
GRANT ALL ON FUNCTION public.increase_user_level() TO authenticated;
GRANT ALL ON FUNCTION public.increase_user_level() TO service_role;


--
-- Name: FUNCTION update_auth_metadata(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_auth_metadata() TO anon;
GRANT ALL ON FUNCTION public.update_auth_metadata() TO authenticated;
GRANT ALL ON FUNCTION public.update_auth_metadata() TO service_role;


--
-- Name: FUNCTION update_last_sign_in(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_last_sign_in() TO anon;
GRANT ALL ON FUNCTION public.update_last_sign_in() TO authenticated;
GRANT ALL ON FUNCTION public.update_last_sign_in() TO service_role;


--
-- Name: FUNCTION update_on_delete_usuarios_table(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_on_delete_usuarios_table() TO anon;
GRANT ALL ON FUNCTION public.update_on_delete_usuarios_table() TO authenticated;
GRANT ALL ON FUNCTION public.update_on_delete_usuarios_table() TO service_role;


--
-- Name: FUNCTION update_usuarios_table(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_usuarios_table() TO anon;
GRANT ALL ON FUNCTION public.update_usuarios_table() TO authenticated;
GRANT ALL ON FUNCTION public.update_usuarios_table() TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.schema_migrations TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.schema_migrations TO postgres;
GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE "Comentarios_Tarea"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Comentarios_Tarea" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Comentarios_Tarea" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Comentarios_Tarea" TO service_role;


--
-- Name: TABLE "Dependencias_Tarea"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Dependencias_Tarea" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Dependencias_Tarea" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Dependencias_Tarea" TO service_role;


--
-- Name: TABLE "Estados_Tarea"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Estados_Tarea" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Estados_Tarea" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Estados_Tarea" TO service_role;


--
-- Name: TABLE "Fuentes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Fuentes" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Fuentes" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Fuentes" TO service_role;


--
-- Name: SEQUENCE historial_fuentes_hfuente_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.historial_fuentes_hfuente_id_seq TO anon;
GRANT ALL ON SEQUENCE public.historial_fuentes_hfuente_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.historial_fuentes_hfuente_id_seq TO service_role;


--
-- Name: TABLE "Historial_Fuentes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Fuentes" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Fuentes" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Fuentes" TO service_role;


--
-- Name: SEQUENCE historial_recompensas_hrecompensa_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.historial_recompensas_hrecompensa_id_seq TO anon;
GRANT ALL ON SEQUENCE public.historial_recompensas_hrecompensa_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.historial_recompensas_hrecompensa_id_seq TO service_role;


--
-- Name: TABLE "Historial_Recompensas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Recompensas" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Recompensas" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Recompensas" TO service_role;


--
-- Name: SEQUENCE historial_temas_htema_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.historial_temas_htema_id_seq TO anon;
GRANT ALL ON SEQUENCE public.historial_temas_htema_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.historial_temas_htema_id_seq TO service_role;


--
-- Name: TABLE "Historial_Temas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Temas" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Temas" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Historial_Temas" TO service_role;


--
-- Name: TABLE "Iconos"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Iconos" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Iconos" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Iconos" TO service_role;


--
-- Name: TABLE "Idiomas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Idiomas" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Idiomas" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Idiomas" TO service_role;


--
-- Name: TABLE "Insignia_Categoria"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignia_Categoria" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignia_Categoria" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignia_Categoria" TO service_role;


--
-- Name: TABLE "Insignia_Conseguida"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignia_Conseguida" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignia_Conseguida" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignia_Conseguida" TO service_role;


--
-- Name: TABLE "Insignias"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignias" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignias" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Insignias" TO service_role;


--
-- Name: TABLE "Invitaciones"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Invitaciones" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Invitaciones" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Invitaciones" TO service_role;


--
-- Name: SEQUENCE "Invitaciones_Invitacion_ID_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."Invitaciones_Invitacion_ID_seq" TO anon;
GRANT ALL ON SEQUENCE public."Invitaciones_Invitacion_ID_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."Invitaciones_Invitacion_ID_seq" TO service_role;


--
-- Name: TABLE "Miembro_Proyecto"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Miembro_Proyecto" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Miembro_Proyecto" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Miembro_Proyecto" TO service_role;


--
-- Name: TABLE "Preguntas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Preguntas" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Preguntas" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Preguntas" TO service_role;


--
-- Name: TABLE "Proyectos"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Proyectos" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Proyectos" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Proyectos" TO service_role;


--
-- Name: TABLE "Recompensas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Recompensas" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Recompensas" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Recompensas" TO service_role;


--
-- Name: TABLE "Roles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Roles" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Roles" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Roles" TO service_role;


--
-- Name: TABLE "Tareas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Tareas" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Tareas" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Tareas" TO service_role;


--
-- Name: TABLE "Temas"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Temas" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Temas" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Temas" TO service_role;


--
-- Name: TABLE "Usuarios"; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Usuarios" TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Usuarios" TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public."Usuarios" TO service_role;


--
-- Name: SEQUENCE comentarios_tarea_comentario_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.comentarios_tarea_comentario_id_seq TO anon;
GRANT ALL ON SEQUENCE public.comentarios_tarea_comentario_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.comentarios_tarea_comentario_id_seq TO service_role;


--
-- Name: SEQUENCE estados_tarea_estado_tarea_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.estados_tarea_estado_tarea_id_seq TO anon;
GRANT ALL ON SEQUENCE public.estados_tarea_estado_tarea_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.estados_tarea_estado_tarea_id_seq TO service_role;


--
-- Name: SEQUENCE fuentes_fuente_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.fuentes_fuente_id_seq TO anon;
GRANT ALL ON SEQUENCE public.fuentes_fuente_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.fuentes_fuente_id_seq TO service_role;


--
-- Name: SEQUENCE iconos_icono_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.iconos_icono_id_seq TO anon;
GRANT ALL ON SEQUENCE public.iconos_icono_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.iconos_icono_id_seq TO service_role;


--
-- Name: SEQUENCE idiomas_idioma_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.idiomas_idioma_id_seq TO anon;
GRANT ALL ON SEQUENCE public.idiomas_idioma_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.idiomas_idioma_id_seq TO service_role;


--
-- Name: SEQUENCE insignia_categoria_insignia_cat_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.insignia_categoria_insignia_cat_id_seq TO anon;
GRANT ALL ON SEQUENCE public.insignia_categoria_insignia_cat_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.insignia_categoria_insignia_cat_id_seq TO service_role;


--
-- Name: SEQUENCE insignias_insignia_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.insignias_insignia_id_seq TO anon;
GRANT ALL ON SEQUENCE public.insignias_insignia_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.insignias_insignia_id_seq TO service_role;


--
-- Name: SEQUENCE preguntas_pregunta_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.preguntas_pregunta_id_seq TO anon;
GRANT ALL ON SEQUENCE public.preguntas_pregunta_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.preguntas_pregunta_id_seq TO service_role;


--
-- Name: SEQUENCE proyectos_proyecto_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.proyectos_proyecto_id_seq TO anon;
GRANT ALL ON SEQUENCE public.proyectos_proyecto_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.proyectos_proyecto_id_seq TO service_role;


--
-- Name: SEQUENCE recompensas_recompensa_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.recompensas_recompensa_id_seq TO anon;
GRANT ALL ON SEQUENCE public.recompensas_recompensa_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.recompensas_recompensa_id_seq TO service_role;


--
-- Name: SEQUENCE roles_rol_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.roles_rol_id_seq TO anon;
GRANT ALL ON SEQUENCE public.roles_rol_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.roles_rol_id_seq TO service_role;


--
-- Name: SEQUENCE tareas_tarea_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.tareas_tarea_id_seq TO anon;
GRANT ALL ON SEQUENCE public.tareas_tarea_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.tareas_tarea_id_seq TO service_role;


--
-- Name: SEQUENCE temas_tema_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.temas_tema_id_seq TO anon;
GRANT ALL ON SEQUENCE public.temas_tema_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.temas_tema_id_seq TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

