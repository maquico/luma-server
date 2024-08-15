create sequence "public"."comentarios_tarea_comentario_id_seq";

create sequence "public"."estados_tarea_estado_tarea_id_seq";

create sequence "public"."fuentes_fuente_id_seq";

create sequence "public"."iconos_icono_id_seq";

create sequence "public"."idiomas_idioma_id_seq";

create sequence "public"."insignia_categoria_insignia_cat_id_seq";

create sequence "public"."insignias_insignia_id_seq";

create sequence "public"."miembro_proyecto_miembro_id_seq";

create sequence "public"."preguntas_pregunta_id_seq";

create sequence "public"."proyectos_proyecto_id_seq";

create sequence "public"."recompensas_recompensa_id_seq";

create sequence "public"."roles_rol_id_seq";

create sequence "public"."tareas_tarea_id_seq";

create sequence "public"."temas_tema_id_seq";

alter table "public"."Comentarios_Tarea" alter column "Comentario_ID" set default nextval('comentarios_tarea_comentario_id_seq'::regclass);

alter table "public"."Estados_Tarea" alter column "Estado_tarea_ID" set default nextval('estados_tarea_estado_tarea_id_seq'::regclass);

alter table "public"."Fuentes" alter column "Fuente_ID" set default nextval('fuentes_fuente_id_seq'::regclass);

alter table "public"."Iconos" alter column "Icono_ID" set default nextval('iconos_icono_id_seq'::regclass);

alter table "public"."Idiomas" alter column "Idioma_ID" set default nextval('idiomas_idioma_id_seq'::regclass);

alter table "public"."Insignia_Categoria" alter column "Insignia_Cat_ID" set default nextval('insignia_categoria_insignia_cat_id_seq'::regclass);

alter table "public"."Insignias" alter column "Insignia_ID" set default nextval('insignias_insignia_id_seq'::regclass);

alter table "public"."Miembro_Proyecto" alter column "Miembro_ID" set default nextval('miembro_proyecto_miembro_id_seq'::regclass);

alter table "public"."Preguntas" alter column "Pregunta_ID" set default nextval('preguntas_pregunta_id_seq'::regclass);

alter table "public"."Proyectos" alter column "Proyecto_ID" set default nextval('proyectos_proyecto_id_seq'::regclass);

alter table "public"."Recompensas" alter column "Recompensa_ID" set default nextval('recompensas_recompensa_id_seq'::regclass);

alter table "public"."Roles" alter column "Rol_ID" set default nextval('roles_rol_id_seq'::regclass);

alter table "public"."Tareas" alter column "Tarea_ID" set default nextval('tareas_tarea_id_seq'::regclass);

alter table "public"."Temas" alter column "Tema_ID" set default nextval('temas_tema_id_seq'::regclass);

alter sequence "public"."comentarios_tarea_comentario_id_seq" owned by "public"."Comentarios_Tarea"."Comentario_ID";

alter sequence "public"."estados_tarea_estado_tarea_id_seq" owned by "public"."Estados_Tarea"."Estado_tarea_ID";

alter sequence "public"."fuentes_fuente_id_seq" owned by "public"."Fuentes"."Fuente_ID";

alter sequence "public"."iconos_icono_id_seq" owned by "public"."Iconos"."Icono_ID";

alter sequence "public"."idiomas_idioma_id_seq" owned by "public"."Idiomas"."Idioma_ID";

alter sequence "public"."insignia_categoria_insignia_cat_id_seq" owned by "public"."Insignia_Categoria"."Insignia_Cat_ID";

alter sequence "public"."insignias_insignia_id_seq" owned by "public"."Insignias"."Insignia_ID";

alter sequence "public"."miembro_proyecto_miembro_id_seq" owned by "public"."Miembro_Proyecto"."Miembro_ID";

alter sequence "public"."preguntas_pregunta_id_seq" owned by "public"."Preguntas"."Pregunta_ID";

alter sequence "public"."proyectos_proyecto_id_seq" owned by "public"."Proyectos"."Proyecto_ID";

alter sequence "public"."recompensas_recompensa_id_seq" owned by "public"."Recompensas"."Recompensa_ID";

alter sequence "public"."roles_rol_id_seq" owned by "public"."Roles"."Rol_ID";

alter sequence "public"."tareas_tarea_id_seq" owned by "public"."Tareas"."Tarea_ID";

alter sequence "public"."temas_tema_id_seq" owned by "public"."Temas"."Tema_ID";


