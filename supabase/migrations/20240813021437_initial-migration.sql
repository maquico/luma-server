create table "public"."Comentarios_Tarea" (
    "Comentario_ID" integer not null,
    "Tarea_ID" integer not null,
    "Miembro_ID" integer not null,
    "contenido" text not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Estados_Tarea" (
    "Estado_tarea_ID" integer not null,
    "nombre" character varying(100) not null,
    "descripcion" text,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Fuentes" (
    "Fuente_ID" integer not null,
    "nombre" character varying(100) not null,
    "precio" numeric(10,2) not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Historial_Fuentes" (
    "Usuario_ID" integer not null,
    "Fuente_ID" integer not null,
    "cantidadComprada" integer not null,
    "precioCompra" numeric(10,2) not null,
    "fechaRegistro" timestamp without time zone not null default now()
);


create table "public"."Historial_Recompensas" (
    "Usuario_ID" integer not null,
    "Recompensa_ID" integer not null,
    "cantidadComprada" integer not null,
    "precioCompra" numeric(10,2) not null,
    "fechaRegistro" timestamp without time zone not null default now()
);


create table "public"."Historial_Temas" (
    "Usuario_ID" integer not null,
    "Tema_ID" integer not null,
    "cantidadComprada" integer not null,
    "precioCompra" numeric(10,2) not null,
    "fechaRegistro" timestamp without time zone not null default now()
);


create table "public"."Iconos" (
    "Icono_ID" integer not null,
    "nombre" character varying(100) not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Idiomas" (
    "Idioma_ID" integer not null,
    "nombre" character varying(50) not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Insignia_Categoria" (
    "Insignia_Cat_ID" integer not null,
    "nombre" character varying(100) not null,
    "campoComparativo" character varying(50) not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Insignia_Conseguida" (
    "Usuario_ID" integer not null,
    "Insignia_ID" integer not null,
    "fechaRegistro" timestamp without time zone not null default now()
);


create table "public"."Insignias" (
    "Insignia_ID" integer not null,
    "nombre" character varying(100) not null,
    "descripcion" text not null,
    "Insignia_Cat_ID" integer not null,
    "meta" integer not null,
    "foto" character varying(255) not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Miembro_Proyecto" (
    "Miembro_ID" integer not null,
    "Usuario_ID" integer not null,
    "Proyecto_ID" integer not null,
    "Rol_ID" integer not null,
    "gemas" integer not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Preguntas" (
    "Pregunta_ID" integer not null,
    "titulo" character varying(200) not null,
    "contenido" text not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Proyectos" (
    "Proyecto_ID" integer not null,
    "nombre" character varying(100) not null,
    "descripcion" text not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Recompensas" (
    "Recompensa_ID" integer not null,
    "Proyecto_ID" integer not null,
    "Icono_ID" integer not null,
    "nombre" character varying(100) not null,
    "descripcion" text,
    "precio" numeric(10,2) not null,
    "cantidad" integer not null,
    "limite" integer not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Roles" (
    "Rol_ID" integer not null,
    "nombre" character varying(100) not null,
    "descripcion" text not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Tareas" (
    "Tarea_ID" integer not null,
    "Proyecto_ID" integer not null,
    "Estado_tarea_ID" integer not null default 1,
    "Miembro_ID" integer not null,
    "etiquetas" character varying(84),
    "nombre" character varying(100) not null,
    "descripcion" text,
    "esfuerzo" integer not null,
    "prioridad" integer not null,
    "valorGemas" integer not null,
    "fechaFinal" timestamp without time zone,
    "fueReclamada" boolean not null default false,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Temas" (
    "Tema_ID" integer not null,
    "nombre" character varying(100) not null,
    "precio" numeric(10,2) not null,
    "accentHex" character varying(7) not null,
    "primaryHex" character varying(7) not null,
    "secondaryHex" character varying(7) not null,
    "backgroundHex" character varying(7) not null,
    "textHex" character varying(7) not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone
);


create table "public"."Usuarios" (
    "Usuario_ID" integer not null,
    "nombre" character varying(100) not null,
    "apellido" character varying(100) not null,
    "correo" character varying(100) not null,
    "experiencia" integer not null default 0,
    "nivel" integer not null default 1,
    "monedas" integer not null default 0,
    "totalGemas" integer not null default 0,
    "tareasAprobadas" integer not null default 0,
    "proyectosCreados" integer not null default 0,
    "foto" character varying(255) not null,
    "fechaRegistro" timestamp without time zone not null default now(),
    "fechaModificacion" timestamp without time zone,
    "esAdmin" boolean not null default false,
    "Idioma_ID" integer not null default 1,
    "contraseña" character varying(255) not null
);


CREATE UNIQUE INDEX "Comentarios_Tarea_pkey" ON public."Comentarios_Tarea" USING btree ("Comentario_ID");

CREATE UNIQUE INDEX "Estados_Tarea_pkey" ON public."Estados_Tarea" USING btree ("Estado_tarea_ID");

CREATE UNIQUE INDEX "Fuentes_pkey" ON public."Fuentes" USING btree ("Fuente_ID");

CREATE UNIQUE INDEX "Historial_Fuentes_pkey" ON public."Historial_Fuentes" USING btree ("Usuario_ID", "Fuente_ID");

CREATE UNIQUE INDEX "Historial_Recompensas_pkey" ON public."Historial_Recompensas" USING btree ("Usuario_ID", "Recompensa_ID");

CREATE UNIQUE INDEX "Historial_Temas_pkey" ON public."Historial_Temas" USING btree ("Usuario_ID", "Tema_ID");

CREATE UNIQUE INDEX "Iconos_pkey" ON public."Iconos" USING btree ("Icono_ID");

CREATE UNIQUE INDEX "Idiomas_pkey" ON public."Idiomas" USING btree ("Idioma_ID");

CREATE UNIQUE INDEX "Insignia_Categoria_pkey" ON public."Insignia_Categoria" USING btree ("Insignia_Cat_ID");

CREATE UNIQUE INDEX "Insignia_Conseguida_pkey" ON public."Insignia_Conseguida" USING btree ("Usuario_ID", "Insignia_ID");

CREATE UNIQUE INDEX "Insignias_pkey" ON public."Insignias" USING btree ("Insignia_ID");

CREATE UNIQUE INDEX "Miembro_Proyecto_pkey" ON public."Miembro_Proyecto" USING btree ("Miembro_ID");

CREATE UNIQUE INDEX "Preguntas_pkey" ON public."Preguntas" USING btree ("Pregunta_ID");

CREATE UNIQUE INDEX "Proyectos_pkey" ON public."Proyectos" USING btree ("Proyecto_ID");

CREATE UNIQUE INDEX "Recompensas_pkey" ON public."Recompensas" USING btree ("Recompensa_ID");

CREATE UNIQUE INDEX "Roles_pkey" ON public."Roles" USING btree ("Rol_ID");

CREATE UNIQUE INDEX "Tareas_pkey" ON public."Tareas" USING btree ("Tarea_ID");

CREATE UNIQUE INDEX "Temas_pkey" ON public."Temas" USING btree ("Tema_ID");

CREATE UNIQUE INDEX "UNIQUE_Usuario_Proyecto" ON public."Miembro_Proyecto" USING btree ("Usuario_ID", "Proyecto_ID");

CREATE UNIQUE INDEX "Usuarios_pkey" ON public."Usuarios" USING btree ("Usuario_ID");

alter table "public"."Comentarios_Tarea" add constraint "Comentarios_Tarea_pkey" PRIMARY KEY using index "Comentarios_Tarea_pkey";

alter table "public"."Estados_Tarea" add constraint "Estados_Tarea_pkey" PRIMARY KEY using index "Estados_Tarea_pkey";

alter table "public"."Fuentes" add constraint "Fuentes_pkey" PRIMARY KEY using index "Fuentes_pkey";

alter table "public"."Historial_Fuentes" add constraint "Historial_Fuentes_pkey" PRIMARY KEY using index "Historial_Fuentes_pkey";

alter table "public"."Historial_Recompensas" add constraint "Historial_Recompensas_pkey" PRIMARY KEY using index "Historial_Recompensas_pkey";

alter table "public"."Historial_Temas" add constraint "Historial_Temas_pkey" PRIMARY KEY using index "Historial_Temas_pkey";

alter table "public"."Iconos" add constraint "Iconos_pkey" PRIMARY KEY using index "Iconos_pkey";

alter table "public"."Idiomas" add constraint "Idiomas_pkey" PRIMARY KEY using index "Idiomas_pkey";

alter table "public"."Insignia_Categoria" add constraint "Insignia_Categoria_pkey" PRIMARY KEY using index "Insignia_Categoria_pkey";

alter table "public"."Insignia_Conseguida" add constraint "Insignia_Conseguida_pkey" PRIMARY KEY using index "Insignia_Conseguida_pkey";

alter table "public"."Insignias" add constraint "Insignias_pkey" PRIMARY KEY using index "Insignias_pkey";

alter table "public"."Miembro_Proyecto" add constraint "Miembro_Proyecto_pkey" PRIMARY KEY using index "Miembro_Proyecto_pkey";

alter table "public"."Preguntas" add constraint "Preguntas_pkey" PRIMARY KEY using index "Preguntas_pkey";

alter table "public"."Proyectos" add constraint "Proyectos_pkey" PRIMARY KEY using index "Proyectos_pkey";

alter table "public"."Recompensas" add constraint "Recompensas_pkey" PRIMARY KEY using index "Recompensas_pkey";

alter table "public"."Roles" add constraint "Roles_pkey" PRIMARY KEY using index "Roles_pkey";

alter table "public"."Tareas" add constraint "Tareas_pkey" PRIMARY KEY using index "Tareas_pkey";

alter table "public"."Temas" add constraint "Temas_pkey" PRIMARY KEY using index "Temas_pkey";

alter table "public"."Usuarios" add constraint "Usuarios_pkey" PRIMARY KEY using index "Usuarios_pkey";

alter table "public"."Comentarios_Tarea" add constraint "FK_Comentarios_Tarea.Miembro_ID" FOREIGN KEY ("Miembro_ID") REFERENCES "Miembro_Proyecto"("Miembro_ID") not valid;

alter table "public"."Comentarios_Tarea" validate constraint "FK_Comentarios_Tarea.Miembro_ID";

alter table "public"."Comentarios_Tarea" add constraint "FK_Comentarios_Tarea.Tarea_ID" FOREIGN KEY ("Tarea_ID") REFERENCES "Tareas"("Tarea_ID") not valid;

alter table "public"."Comentarios_Tarea" validate constraint "FK_Comentarios_Tarea.Tarea_ID";

alter table "public"."Historial_Fuentes" add constraint "FK_Historial_Recompensas_Fuentes.Fuente_ID" FOREIGN KEY ("Fuente_ID") REFERENCES "Fuentes"("Fuente_ID") not valid;

alter table "public"."Historial_Fuentes" validate constraint "FK_Historial_Recompensas_Fuentes.Fuente_ID";

alter table "public"."Historial_Fuentes" add constraint "FK_Historial_Recompensas_Fuentes.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") not valid;

alter table "public"."Historial_Fuentes" validate constraint "FK_Historial_Recompensas_Fuentes.Usuario_ID";

alter table "public"."Historial_Recompensas" add constraint "FK_Historial_Recompensas.Recompensa_ID" FOREIGN KEY ("Recompensa_ID") REFERENCES "Recompensas"("Recompensa_ID") not valid;

alter table "public"."Historial_Recompensas" validate constraint "FK_Historial_Recompensas.Recompensa_ID";

alter table "public"."Historial_Recompensas" add constraint "FK_Historial_Recompensas.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") not valid;

alter table "public"."Historial_Recompensas" validate constraint "FK_Historial_Recompensas.Usuario_ID";

alter table "public"."Historial_Temas" add constraint "FK_Historial_Recompensas_Temas.Tema_ID" FOREIGN KEY ("Tema_ID") REFERENCES "Temas"("Tema_ID") not valid;

alter table "public"."Historial_Temas" validate constraint "FK_Historial_Recompensas_Temas.Tema_ID";

alter table "public"."Historial_Temas" add constraint "FK_Historial_Recompensas_Temas.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") not valid;

alter table "public"."Historial_Temas" validate constraint "FK_Historial_Recompensas_Temas.Usuario_ID";

alter table "public"."Insignia_Conseguida" add constraint "FK_Insignia_Conseguida.Insignia_ID" FOREIGN KEY ("Insignia_ID") REFERENCES "Insignias"("Insignia_ID") not valid;

alter table "public"."Insignia_Conseguida" validate constraint "FK_Insignia_Conseguida.Insignia_ID";

alter table "public"."Insignia_Conseguida" add constraint "FK_Insignia_Conseguida.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") not valid;

alter table "public"."Insignia_Conseguida" validate constraint "FK_Insignia_Conseguida.Usuario_ID";

alter table "public"."Insignias" add constraint "FK_Insignias.Insignia_Cat_ID" FOREIGN KEY ("Insignia_Cat_ID") REFERENCES "Insignia_Categoria"("Insignia_Cat_ID") not valid;

alter table "public"."Insignias" validate constraint "FK_Insignias.Insignia_Cat_ID";

alter table "public"."Miembro_Proyecto" add constraint "FK_Miembro_Proyecto.Proyecto_ID" FOREIGN KEY ("Proyecto_ID") REFERENCES "Proyectos"("Proyecto_ID") not valid;

alter table "public"."Miembro_Proyecto" validate constraint "FK_Miembro_Proyecto.Proyecto_ID";

alter table "public"."Miembro_Proyecto" add constraint "FK_Miembro_Proyecto.Rol_ID" FOREIGN KEY ("Rol_ID") REFERENCES "Roles"("Rol_ID") not valid;

alter table "public"."Miembro_Proyecto" validate constraint "FK_Miembro_Proyecto.Rol_ID";

alter table "public"."Miembro_Proyecto" add constraint "FK_Miembro_Proyecto.Usuario_ID" FOREIGN KEY ("Usuario_ID") REFERENCES "Usuarios"("Usuario_ID") not valid;

alter table "public"."Miembro_Proyecto" validate constraint "FK_Miembro_Proyecto.Usuario_ID";

alter table "public"."Miembro_Proyecto" add constraint "UNIQUE_Usuario_Proyecto" UNIQUE using index "UNIQUE_Usuario_Proyecto";

alter table "public"."Recompensas" add constraint "FK_Recompensas.Icono_ID" FOREIGN KEY ("Icono_ID") REFERENCES "Iconos"("Icono_ID") not valid;

alter table "public"."Recompensas" validate constraint "FK_Recompensas.Icono_ID";

alter table "public"."Recompensas" add constraint "FK_Recompensas.Proyecto_ID" FOREIGN KEY ("Proyecto_ID") REFERENCES "Proyectos"("Proyecto_ID") not valid;

alter table "public"."Recompensas" validate constraint "FK_Recompensas.Proyecto_ID";

alter table "public"."Tareas" add constraint "FK_Tareas.Estado_tarea_ID" FOREIGN KEY ("Estado_tarea_ID") REFERENCES "Estados_Tarea"("Estado_tarea_ID") not valid;

alter table "public"."Tareas" validate constraint "FK_Tareas.Estado_tarea_ID";

alter table "public"."Tareas" add constraint "FK_Tareas.Miembro_ID" FOREIGN KEY ("Miembro_ID") REFERENCES "Miembro_Proyecto"("Miembro_ID") not valid;

alter table "public"."Tareas" validate constraint "FK_Tareas.Miembro_ID";

alter table "public"."Tareas" add constraint "FK_Tareas.Proyecto_ID" FOREIGN KEY ("Proyecto_ID") REFERENCES "Proyectos"("Proyecto_ID") not valid;

alter table "public"."Tareas" validate constraint "FK_Tareas.Proyecto_ID";

alter table "public"."Usuarios" add constraint "FK_Usuarios.Idioma_ID" FOREIGN KEY ("Idioma_ID") REFERENCES "Idiomas"("Idioma_ID") not valid;

alter table "public"."Usuarios" validate constraint "FK_Usuarios.Idioma_ID";

grant delete on table "public"."Comentarios_Tarea" to "anon";

grant insert on table "public"."Comentarios_Tarea" to "anon";

grant references on table "public"."Comentarios_Tarea" to "anon";

grant select on table "public"."Comentarios_Tarea" to "anon";

grant trigger on table "public"."Comentarios_Tarea" to "anon";

grant truncate on table "public"."Comentarios_Tarea" to "anon";

grant update on table "public"."Comentarios_Tarea" to "anon";

grant delete on table "public"."Comentarios_Tarea" to "authenticated";

grant insert on table "public"."Comentarios_Tarea" to "authenticated";

grant references on table "public"."Comentarios_Tarea" to "authenticated";

grant select on table "public"."Comentarios_Tarea" to "authenticated";

grant trigger on table "public"."Comentarios_Tarea" to "authenticated";

grant truncate on table "public"."Comentarios_Tarea" to "authenticated";

grant update on table "public"."Comentarios_Tarea" to "authenticated";

grant delete on table "public"."Comentarios_Tarea" to "service_role";

grant insert on table "public"."Comentarios_Tarea" to "service_role";

grant references on table "public"."Comentarios_Tarea" to "service_role";

grant select on table "public"."Comentarios_Tarea" to "service_role";

grant trigger on table "public"."Comentarios_Tarea" to "service_role";

grant truncate on table "public"."Comentarios_Tarea" to "service_role";

grant update on table "public"."Comentarios_Tarea" to "service_role";

grant delete on table "public"."Estados_Tarea" to "anon";

grant insert on table "public"."Estados_Tarea" to "anon";

grant references on table "public"."Estados_Tarea" to "anon";

grant select on table "public"."Estados_Tarea" to "anon";

grant trigger on table "public"."Estados_Tarea" to "anon";

grant truncate on table "public"."Estados_Tarea" to "anon";

grant update on table "public"."Estados_Tarea" to "anon";

grant delete on table "public"."Estados_Tarea" to "authenticated";

grant insert on table "public"."Estados_Tarea" to "authenticated";

grant references on table "public"."Estados_Tarea" to "authenticated";

grant select on table "public"."Estados_Tarea" to "authenticated";

grant trigger on table "public"."Estados_Tarea" to "authenticated";

grant truncate on table "public"."Estados_Tarea" to "authenticated";

grant update on table "public"."Estados_Tarea" to "authenticated";

grant delete on table "public"."Estados_Tarea" to "service_role";

grant insert on table "public"."Estados_Tarea" to "service_role";

grant references on table "public"."Estados_Tarea" to "service_role";

grant select on table "public"."Estados_Tarea" to "service_role";

grant trigger on table "public"."Estados_Tarea" to "service_role";

grant truncate on table "public"."Estados_Tarea" to "service_role";

grant update on table "public"."Estados_Tarea" to "service_role";

grant delete on table "public"."Fuentes" to "anon";

grant insert on table "public"."Fuentes" to "anon";

grant references on table "public"."Fuentes" to "anon";

grant select on table "public"."Fuentes" to "anon";

grant trigger on table "public"."Fuentes" to "anon";

grant truncate on table "public"."Fuentes" to "anon";

grant update on table "public"."Fuentes" to "anon";

grant delete on table "public"."Fuentes" to "authenticated";

grant insert on table "public"."Fuentes" to "authenticated";

grant references on table "public"."Fuentes" to "authenticated";

grant select on table "public"."Fuentes" to "authenticated";

grant trigger on table "public"."Fuentes" to "authenticated";

grant truncate on table "public"."Fuentes" to "authenticated";

grant update on table "public"."Fuentes" to "authenticated";

grant delete on table "public"."Fuentes" to "service_role";

grant insert on table "public"."Fuentes" to "service_role";

grant references on table "public"."Fuentes" to "service_role";

grant select on table "public"."Fuentes" to "service_role";

grant trigger on table "public"."Fuentes" to "service_role";

grant truncate on table "public"."Fuentes" to "service_role";

grant update on table "public"."Fuentes" to "service_role";

grant delete on table "public"."Historial_Fuentes" to "anon";

grant insert on table "public"."Historial_Fuentes" to "anon";

grant references on table "public"."Historial_Fuentes" to "anon";

grant select on table "public"."Historial_Fuentes" to "anon";

grant trigger on table "public"."Historial_Fuentes" to "anon";

grant truncate on table "public"."Historial_Fuentes" to "anon";

grant update on table "public"."Historial_Fuentes" to "anon";

grant delete on table "public"."Historial_Fuentes" to "authenticated";

grant insert on table "public"."Historial_Fuentes" to "authenticated";

grant references on table "public"."Historial_Fuentes" to "authenticated";

grant select on table "public"."Historial_Fuentes" to "authenticated";

grant trigger on table "public"."Historial_Fuentes" to "authenticated";

grant truncate on table "public"."Historial_Fuentes" to "authenticated";

grant update on table "public"."Historial_Fuentes" to "authenticated";

grant delete on table "public"."Historial_Fuentes" to "service_role";

grant insert on table "public"."Historial_Fuentes" to "service_role";

grant references on table "public"."Historial_Fuentes" to "service_role";

grant select on table "public"."Historial_Fuentes" to "service_role";

grant trigger on table "public"."Historial_Fuentes" to "service_role";

grant truncate on table "public"."Historial_Fuentes" to "service_role";

grant update on table "public"."Historial_Fuentes" to "service_role";

grant delete on table "public"."Historial_Recompensas" to "anon";

grant insert on table "public"."Historial_Recompensas" to "anon";

grant references on table "public"."Historial_Recompensas" to "anon";

grant select on table "public"."Historial_Recompensas" to "anon";

grant trigger on table "public"."Historial_Recompensas" to "anon";

grant truncate on table "public"."Historial_Recompensas" to "anon";

grant update on table "public"."Historial_Recompensas" to "anon";

grant delete on table "public"."Historial_Recompensas" to "authenticated";

grant insert on table "public"."Historial_Recompensas" to "authenticated";

grant references on table "public"."Historial_Recompensas" to "authenticated";

grant select on table "public"."Historial_Recompensas" to "authenticated";

grant trigger on table "public"."Historial_Recompensas" to "authenticated";

grant truncate on table "public"."Historial_Recompensas" to "authenticated";

grant update on table "public"."Historial_Recompensas" to "authenticated";

grant delete on table "public"."Historial_Recompensas" to "service_role";

grant insert on table "public"."Historial_Recompensas" to "service_role";

grant references on table "public"."Historial_Recompensas" to "service_role";

grant select on table "public"."Historial_Recompensas" to "service_role";

grant trigger on table "public"."Historial_Recompensas" to "service_role";

grant truncate on table "public"."Historial_Recompensas" to "service_role";

grant update on table "public"."Historial_Recompensas" to "service_role";

grant delete on table "public"."Historial_Temas" to "anon";

grant insert on table "public"."Historial_Temas" to "anon";

grant references on table "public"."Historial_Temas" to "anon";

grant select on table "public"."Historial_Temas" to "anon";

grant trigger on table "public"."Historial_Temas" to "anon";

grant truncate on table "public"."Historial_Temas" to "anon";

grant update on table "public"."Historial_Temas" to "anon";

grant delete on table "public"."Historial_Temas" to "authenticated";

grant insert on table "public"."Historial_Temas" to "authenticated";

grant references on table "public"."Historial_Temas" to "authenticated";

grant select on table "public"."Historial_Temas" to "authenticated";

grant trigger on table "public"."Historial_Temas" to "authenticated";

grant truncate on table "public"."Historial_Temas" to "authenticated";

grant update on table "public"."Historial_Temas" to "authenticated";

grant delete on table "public"."Historial_Temas" to "service_role";

grant insert on table "public"."Historial_Temas" to "service_role";

grant references on table "public"."Historial_Temas" to "service_role";

grant select on table "public"."Historial_Temas" to "service_role";

grant trigger on table "public"."Historial_Temas" to "service_role";

grant truncate on table "public"."Historial_Temas" to "service_role";

grant update on table "public"."Historial_Temas" to "service_role";

grant delete on table "public"."Iconos" to "anon";

grant insert on table "public"."Iconos" to "anon";

grant references on table "public"."Iconos" to "anon";

grant select on table "public"."Iconos" to "anon";

grant trigger on table "public"."Iconos" to "anon";

grant truncate on table "public"."Iconos" to "anon";

grant update on table "public"."Iconos" to "anon";

grant delete on table "public"."Iconos" to "authenticated";

grant insert on table "public"."Iconos" to "authenticated";

grant references on table "public"."Iconos" to "authenticated";

grant select on table "public"."Iconos" to "authenticated";

grant trigger on table "public"."Iconos" to "authenticated";

grant truncate on table "public"."Iconos" to "authenticated";

grant update on table "public"."Iconos" to "authenticated";

grant delete on table "public"."Iconos" to "service_role";

grant insert on table "public"."Iconos" to "service_role";

grant references on table "public"."Iconos" to "service_role";

grant select on table "public"."Iconos" to "service_role";

grant trigger on table "public"."Iconos" to "service_role";

grant truncate on table "public"."Iconos" to "service_role";

grant update on table "public"."Iconos" to "service_role";

grant delete on table "public"."Idiomas" to "anon";

grant insert on table "public"."Idiomas" to "anon";

grant references on table "public"."Idiomas" to "anon";

grant select on table "public"."Idiomas" to "anon";

grant trigger on table "public"."Idiomas" to "anon";

grant truncate on table "public"."Idiomas" to "anon";

grant update on table "public"."Idiomas" to "anon";

grant delete on table "public"."Idiomas" to "authenticated";

grant insert on table "public"."Idiomas" to "authenticated";

grant references on table "public"."Idiomas" to "authenticated";

grant select on table "public"."Idiomas" to "authenticated";

grant trigger on table "public"."Idiomas" to "authenticated";

grant truncate on table "public"."Idiomas" to "authenticated";

grant update on table "public"."Idiomas" to "authenticated";

grant delete on table "public"."Idiomas" to "service_role";

grant insert on table "public"."Idiomas" to "service_role";

grant references on table "public"."Idiomas" to "service_role";

grant select on table "public"."Idiomas" to "service_role";

grant trigger on table "public"."Idiomas" to "service_role";

grant truncate on table "public"."Idiomas" to "service_role";

grant update on table "public"."Idiomas" to "service_role";

grant delete on table "public"."Insignia_Categoria" to "anon";

grant insert on table "public"."Insignia_Categoria" to "anon";

grant references on table "public"."Insignia_Categoria" to "anon";

grant select on table "public"."Insignia_Categoria" to "anon";

grant trigger on table "public"."Insignia_Categoria" to "anon";

grant truncate on table "public"."Insignia_Categoria" to "anon";

grant update on table "public"."Insignia_Categoria" to "anon";

grant delete on table "public"."Insignia_Categoria" to "authenticated";

grant insert on table "public"."Insignia_Categoria" to "authenticated";

grant references on table "public"."Insignia_Categoria" to "authenticated";

grant select on table "public"."Insignia_Categoria" to "authenticated";

grant trigger on table "public"."Insignia_Categoria" to "authenticated";

grant truncate on table "public"."Insignia_Categoria" to "authenticated";

grant update on table "public"."Insignia_Categoria" to "authenticated";

grant delete on table "public"."Insignia_Categoria" to "service_role";

grant insert on table "public"."Insignia_Categoria" to "service_role";

grant references on table "public"."Insignia_Categoria" to "service_role";

grant select on table "public"."Insignia_Categoria" to "service_role";

grant trigger on table "public"."Insignia_Categoria" to "service_role";

grant truncate on table "public"."Insignia_Categoria" to "service_role";

grant update on table "public"."Insignia_Categoria" to "service_role";

grant delete on table "public"."Insignia_Conseguida" to "anon";

grant insert on table "public"."Insignia_Conseguida" to "anon";

grant references on table "public"."Insignia_Conseguida" to "anon";

grant select on table "public"."Insignia_Conseguida" to "anon";

grant trigger on table "public"."Insignia_Conseguida" to "anon";

grant truncate on table "public"."Insignia_Conseguida" to "anon";

grant update on table "public"."Insignia_Conseguida" to "anon";

grant delete on table "public"."Insignia_Conseguida" to "authenticated";

grant insert on table "public"."Insignia_Conseguida" to "authenticated";

grant references on table "public"."Insignia_Conseguida" to "authenticated";

grant select on table "public"."Insignia_Conseguida" to "authenticated";

grant trigger on table "public"."Insignia_Conseguida" to "authenticated";

grant truncate on table "public"."Insignia_Conseguida" to "authenticated";

grant update on table "public"."Insignia_Conseguida" to "authenticated";

grant delete on table "public"."Insignia_Conseguida" to "service_role";

grant insert on table "public"."Insignia_Conseguida" to "service_role";

grant references on table "public"."Insignia_Conseguida" to "service_role";

grant select on table "public"."Insignia_Conseguida" to "service_role";

grant trigger on table "public"."Insignia_Conseguida" to "service_role";

grant truncate on table "public"."Insignia_Conseguida" to "service_role";

grant update on table "public"."Insignia_Conseguida" to "service_role";

grant delete on table "public"."Insignias" to "anon";

grant insert on table "public"."Insignias" to "anon";

grant references on table "public"."Insignias" to "anon";

grant select on table "public"."Insignias" to "anon";

grant trigger on table "public"."Insignias" to "anon";

grant truncate on table "public"."Insignias" to "anon";

grant update on table "public"."Insignias" to "anon";

grant delete on table "public"."Insignias" to "authenticated";

grant insert on table "public"."Insignias" to "authenticated";

grant references on table "public"."Insignias" to "authenticated";

grant select on table "public"."Insignias" to "authenticated";

grant trigger on table "public"."Insignias" to "authenticated";

grant truncate on table "public"."Insignias" to "authenticated";

grant update on table "public"."Insignias" to "authenticated";

grant delete on table "public"."Insignias" to "service_role";

grant insert on table "public"."Insignias" to "service_role";

grant references on table "public"."Insignias" to "service_role";

grant select on table "public"."Insignias" to "service_role";

grant trigger on table "public"."Insignias" to "service_role";

grant truncate on table "public"."Insignias" to "service_role";

grant update on table "public"."Insignias" to "service_role";

grant delete on table "public"."Miembro_Proyecto" to "anon";

grant insert on table "public"."Miembro_Proyecto" to "anon";

grant references on table "public"."Miembro_Proyecto" to "anon";

grant select on table "public"."Miembro_Proyecto" to "anon";

grant trigger on table "public"."Miembro_Proyecto" to "anon";

grant truncate on table "public"."Miembro_Proyecto" to "anon";

grant update on table "public"."Miembro_Proyecto" to "anon";

grant delete on table "public"."Miembro_Proyecto" to "authenticated";

grant insert on table "public"."Miembro_Proyecto" to "authenticated";

grant references on table "public"."Miembro_Proyecto" to "authenticated";

grant select on table "public"."Miembro_Proyecto" to "authenticated";

grant trigger on table "public"."Miembro_Proyecto" to "authenticated";

grant truncate on table "public"."Miembro_Proyecto" to "authenticated";

grant update on table "public"."Miembro_Proyecto" to "authenticated";

grant delete on table "public"."Miembro_Proyecto" to "service_role";

grant insert on table "public"."Miembro_Proyecto" to "service_role";

grant references on table "public"."Miembro_Proyecto" to "service_role";

grant select on table "public"."Miembro_Proyecto" to "service_role";

grant trigger on table "public"."Miembro_Proyecto" to "service_role";

grant truncate on table "public"."Miembro_Proyecto" to "service_role";

grant update on table "public"."Miembro_Proyecto" to "service_role";

grant delete on table "public"."Preguntas" to "anon";

grant insert on table "public"."Preguntas" to "anon";

grant references on table "public"."Preguntas" to "anon";

grant select on table "public"."Preguntas" to "anon";

grant trigger on table "public"."Preguntas" to "anon";

grant truncate on table "public"."Preguntas" to "anon";

grant update on table "public"."Preguntas" to "anon";

grant delete on table "public"."Preguntas" to "authenticated";

grant insert on table "public"."Preguntas" to "authenticated";

grant references on table "public"."Preguntas" to "authenticated";

grant select on table "public"."Preguntas" to "authenticated";

grant trigger on table "public"."Preguntas" to "authenticated";

grant truncate on table "public"."Preguntas" to "authenticated";

grant update on table "public"."Preguntas" to "authenticated";

grant delete on table "public"."Preguntas" to "service_role";

grant insert on table "public"."Preguntas" to "service_role";

grant references on table "public"."Preguntas" to "service_role";

grant select on table "public"."Preguntas" to "service_role";

grant trigger on table "public"."Preguntas" to "service_role";

grant truncate on table "public"."Preguntas" to "service_role";

grant update on table "public"."Preguntas" to "service_role";

grant delete on table "public"."Proyectos" to "anon";

grant insert on table "public"."Proyectos" to "anon";

grant references on table "public"."Proyectos" to "anon";

grant select on table "public"."Proyectos" to "anon";

grant trigger on table "public"."Proyectos" to "anon";

grant truncate on table "public"."Proyectos" to "anon";

grant update on table "public"."Proyectos" to "anon";

grant delete on table "public"."Proyectos" to "authenticated";

grant insert on table "public"."Proyectos" to "authenticated";

grant references on table "public"."Proyectos" to "authenticated";

grant select on table "public"."Proyectos" to "authenticated";

grant trigger on table "public"."Proyectos" to "authenticated";

grant truncate on table "public"."Proyectos" to "authenticated";

grant update on table "public"."Proyectos" to "authenticated";

grant delete on table "public"."Proyectos" to "service_role";

grant insert on table "public"."Proyectos" to "service_role";

grant references on table "public"."Proyectos" to "service_role";

grant select on table "public"."Proyectos" to "service_role";

grant trigger on table "public"."Proyectos" to "service_role";

grant truncate on table "public"."Proyectos" to "service_role";

grant update on table "public"."Proyectos" to "service_role";

grant delete on table "public"."Recompensas" to "anon";

grant insert on table "public"."Recompensas" to "anon";

grant references on table "public"."Recompensas" to "anon";

grant select on table "public"."Recompensas" to "anon";

grant trigger on table "public"."Recompensas" to "anon";

grant truncate on table "public"."Recompensas" to "anon";

grant update on table "public"."Recompensas" to "anon";

grant delete on table "public"."Recompensas" to "authenticated";

grant insert on table "public"."Recompensas" to "authenticated";

grant references on table "public"."Recompensas" to "authenticated";

grant select on table "public"."Recompensas" to "authenticated";

grant trigger on table "public"."Recompensas" to "authenticated";

grant truncate on table "public"."Recompensas" to "authenticated";

grant update on table "public"."Recompensas" to "authenticated";

grant delete on table "public"."Recompensas" to "service_role";

grant insert on table "public"."Recompensas" to "service_role";

grant references on table "public"."Recompensas" to "service_role";

grant select on table "public"."Recompensas" to "service_role";

grant trigger on table "public"."Recompensas" to "service_role";

grant truncate on table "public"."Recompensas" to "service_role";

grant update on table "public"."Recompensas" to "service_role";

grant delete on table "public"."Roles" to "anon";

grant insert on table "public"."Roles" to "anon";

grant references on table "public"."Roles" to "anon";

grant select on table "public"."Roles" to "anon";

grant trigger on table "public"."Roles" to "anon";

grant truncate on table "public"."Roles" to "anon";

grant update on table "public"."Roles" to "anon";

grant delete on table "public"."Roles" to "authenticated";

grant insert on table "public"."Roles" to "authenticated";

grant references on table "public"."Roles" to "authenticated";

grant select on table "public"."Roles" to "authenticated";

grant trigger on table "public"."Roles" to "authenticated";

grant truncate on table "public"."Roles" to "authenticated";

grant update on table "public"."Roles" to "authenticated";

grant delete on table "public"."Roles" to "service_role";

grant insert on table "public"."Roles" to "service_role";

grant references on table "public"."Roles" to "service_role";

grant select on table "public"."Roles" to "service_role";

grant trigger on table "public"."Roles" to "service_role";

grant truncate on table "public"."Roles" to "service_role";

grant update on table "public"."Roles" to "service_role";

grant delete on table "public"."Tareas" to "anon";

grant insert on table "public"."Tareas" to "anon";

grant references on table "public"."Tareas" to "anon";

grant select on table "public"."Tareas" to "anon";

grant trigger on table "public"."Tareas" to "anon";

grant truncate on table "public"."Tareas" to "anon";

grant update on table "public"."Tareas" to "anon";

grant delete on table "public"."Tareas" to "authenticated";

grant insert on table "public"."Tareas" to "authenticated";

grant references on table "public"."Tareas" to "authenticated";

grant select on table "public"."Tareas" to "authenticated";

grant trigger on table "public"."Tareas" to "authenticated";

grant truncate on table "public"."Tareas" to "authenticated";

grant update on table "public"."Tareas" to "authenticated";

grant delete on table "public"."Tareas" to "service_role";

grant insert on table "public"."Tareas" to "service_role";

grant references on table "public"."Tareas" to "service_role";

grant select on table "public"."Tareas" to "service_role";

grant trigger on table "public"."Tareas" to "service_role";

grant truncate on table "public"."Tareas" to "service_role";

grant update on table "public"."Tareas" to "service_role";

grant delete on table "public"."Temas" to "anon";

grant insert on table "public"."Temas" to "anon";

grant references on table "public"."Temas" to "anon";

grant select on table "public"."Temas" to "anon";

grant trigger on table "public"."Temas" to "anon";

grant truncate on table "public"."Temas" to "anon";

grant update on table "public"."Temas" to "anon";

grant delete on table "public"."Temas" to "authenticated";

grant insert on table "public"."Temas" to "authenticated";

grant references on table "public"."Temas" to "authenticated";

grant select on table "public"."Temas" to "authenticated";

grant trigger on table "public"."Temas" to "authenticated";

grant truncate on table "public"."Temas" to "authenticated";

grant update on table "public"."Temas" to "authenticated";

grant delete on table "public"."Temas" to "service_role";

grant insert on table "public"."Temas" to "service_role";

grant references on table "public"."Temas" to "service_role";

grant select on table "public"."Temas" to "service_role";

grant trigger on table "public"."Temas" to "service_role";

grant truncate on table "public"."Temas" to "service_role";

grant update on table "public"."Temas" to "service_role";

grant delete on table "public"."Usuarios" to "anon";

grant insert on table "public"."Usuarios" to "anon";

grant references on table "public"."Usuarios" to "anon";

grant select on table "public"."Usuarios" to "anon";

grant trigger on table "public"."Usuarios" to "anon";

grant truncate on table "public"."Usuarios" to "anon";

grant update on table "public"."Usuarios" to "anon";

grant delete on table "public"."Usuarios" to "authenticated";

grant insert on table "public"."Usuarios" to "authenticated";

grant references on table "public"."Usuarios" to "authenticated";

grant select on table "public"."Usuarios" to "authenticated";

grant trigger on table "public"."Usuarios" to "authenticated";

grant truncate on table "public"."Usuarios" to "authenticated";

grant update on table "public"."Usuarios" to "authenticated";

grant delete on table "public"."Usuarios" to "service_role";

grant insert on table "public"."Usuarios" to "service_role";

grant references on table "public"."Usuarios" to "service_role";

grant select on table "public"."Usuarios" to "service_role";

grant trigger on table "public"."Usuarios" to "service_role";

grant truncate on table "public"."Usuarios" to "service_role";

grant update on table "public"."Usuarios" to "service_role";


