CREATE TABLE "Proyecto" (
  "Proyecto_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "descripcion" TEXT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Iconos" (
  "Icono_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Recompensas_Personalizadas" (
  "Personalizada_ID" INT PRIMARY KEY,
  "Proyecto_ID" INT,
  "Icono_ID" INT,
  "nombre" VARCHAR(100),
  "descripcion" TEXT,
  "precio" NUMERIC(10, 2),
  "cantidad" INT,
  "limite" INT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW(),
  CONSTRAINT "FK_Recompensas_Personalizadas.Proyecto_ID"
    FOREIGN KEY ("Proyecto_ID")
      REFERENCES "Proyecto"("Proyecto_ID"),
  CONSTRAINT "FK_Recompensas_Personalizadas.Icono_ID"
    FOREIGN KEY ("Icono_ID")
      REFERENCES "Iconos"("Icono_ID")
);

CREATE TABLE "Recompensas_Temas" (
  "Tema_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "precio" NUMERIC(10, 2),
  "accentHex" VARCHAR(7),
  "primaryHex" VARCHAR(7),
  "secondaryHex" VARCHAR(7),
  "backgroundHex" VARCHAR(7),
  "textHex" VARCHAR(7),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Preguntas" (
  "Pregunta_ID" INT PRIMARY KEY,
  "titulo" VARCHAR(200),
  "contenido" TEXT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Insignia_Categoria" (
  "Insignia_Cat_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "campoComparativo" VARCHAR(50),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Insignias" (
  "Insignia_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "descripcion" TEXT,
  "Insignia_Cat_ID" INT,
  "meta" INT,
  "foto" VARCHAR(255),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW(),
  CONSTRAINT "FK_Insignias.Insignia_Cat_ID"
    FOREIGN KEY ("Insignia_Cat_ID")
      REFERENCES "Insignia_Categoria"("Insignia_Cat_ID")
);

CREATE TABLE "Idiomas" (
  "Idioma_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(50),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Usuario" (
  "Usuario_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "apellido" VARCHAR(100),
  "correo" VARCHAR(100),
  "experiencia" INT,
  "nivel" INT,
  "monedas" INT,
  "totalGemas" INT,
  "tareasAprobadas" INT,
  "proyectosCreados" INT,
  "foto" VARCHAR(255),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW(),
  "esAdmin" BOOLEAN,
  "Idioma_ID" INT,
  "contraseña" VARCHAR(255),
  CONSTRAINT "FK_Usuario.Idioma_ID"
    FOREIGN KEY ("Idioma_ID")
      REFERENCES "Idiomas"("Idioma_ID")
);

CREATE TABLE "Insignia_Conseguida" (
  "Usuario_ID" INT,
  "Insignia_ID" INT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Insignia_ID"),
  CONSTRAINT "FK_Insignia_Conseguida.Insignia_ID"
    FOREIGN KEY ("Insignia_ID")
      REFERENCES "Insignias"("Insignia_ID"),
  CONSTRAINT "FK_Insignia_Conseguida.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuario"("Usuario_ID")
);

CREATE TABLE "Recompensas_Fuente" (
  "Fuente_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "precio" NUMERIC(10, 2),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Historial_Recompensas_Temas" (
  "Usuario_ID" INT,
  "Recompensa_Tema_ID" INT,
  "cantidadComprada" INT,
  "precioCompra" NUMERIC(10, 2),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Recompensa_Tema_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Temas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuario"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Temas.Recompensa_Tema_ID"
    FOREIGN KEY ("Recompensa_Tema_ID")
      REFERENCES "Recompensas_Temas"("Tema_ID")
);

CREATE TABLE "Historial_Recompensas_Fuentes" (
  "Usuario_ID" INT,
  "Recompensa_Fuente_ID" INT,
  "cantidadComprada" INT,
  "precioCompra" NUMERIC(10, 2),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Recompensa_Fuente_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Fuentes.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuario"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Fuentes.Recompensa_Fuente_ID"
    FOREIGN KEY ("Recompensa_Fuente_ID")
      REFERENCES "Recompensas_Fuente"("Fuente_ID")
);

CREATE TABLE "Historial_Recompensas_Personalizadas" (
  "Usuario_ID" INT,
  "Recompensa_Personalizada_ID" INT,
  "cantidadComprada" INT,
  "precioCompra" NUMERIC(10, 2),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Recompensa_Personalizada_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Personalizadas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuario"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Personalizadas.Recompensa_Personalizada_ID"
    FOREIGN KEY ("Recompensa_Personalizada_ID")
      REFERENCES "Recompensas_Personalizadas"("Personalizada_ID")
);

CREATE TABLE "Roles" (
  "Rol_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "descripcion" TEXT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Miembro_Proyecto" (
  "Miembro_ID" INT PRIMARY KEY,
  "Usuario_ID" INT,
  "Proyecto_ID" INT,
  "Rol_ID" INT,
  "gemas" INT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW(),
  CONSTRAINT "FK_Miembro_Proyecto.Rol_ID"
    FOREIGN KEY ("Rol_ID")
      REFERENCES "Roles"("Rol_ID"),
  CONSTRAINT "FK_Miembro_Proyecto.Proyecto_ID"
    FOREIGN KEY ("Proyecto_ID")
      REFERENCES "Proyecto"("Proyecto_ID"),
  CONSTRAINT "FK_Miembro_Proyecto.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuario"("Usuario_ID"),
  CONSTRAINT "UNIQUE_Usuario_Proyecto" UNIQUE ("Usuario_ID", "Proyecto_ID")
);

CREATE TABLE "Estados_Tarea" (
  "Estado_tarea_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100),
  "descripcion" TEXT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Tareas" (
  "Tarea_ID" INT PRIMARY KEY,
  "Proyecto_ID" INT,
  "Estado_tarea_ID" INT,
  "Miembro_ID" INT,
  "etiquetas" VARCHAR(255),
  "nombre" VARCHAR(100),
  "descripcion" TEXT,
  "esfuerzo" INT,
  "prioridad" INT,
  "valorGemas" INT,
  "fechaFinal" TIMESTAMP,
  "fueReclamada" BOOLEAN,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW(),
  CONSTRAINT "FK_Tareas.Proyecto_ID"
    FOREIGN KEY ("Proyecto_ID")
      REFERENCES "Proyecto"("Proyecto_ID"),
  CONSTRAINT "FK_Tareas.Estado_tarea_ID"
    FOREIGN KEY ("Estado_tarea_ID")
      REFERENCES "Estados_Tarea"("Estado_tarea_ID"),
  CONSTRAINT "FK_Tareas.Miembro_ID"
    FOREIGN KEY ("Miembro_ID")
      REFERENCES "Miembro_Proyecto"("Miembro_ID")
);

CREATE TABLE "Comentarios_Tarea" (
  "Comentario_ID" INT PRIMARY KEY,
  "Tarea_ID" INT,
  "Miembro_ID" INT,
  "contenido" TEXT,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW(),
  CONSTRAINT "FK_Comentarios_Tarea.Miembro_ID"
    FOREIGN KEY ("Miembro_ID")
      REFERENCES "Miembro_Proyecto"("Miembro_ID"),
  CONSTRAINT "FK_Comentarios_Tarea.Tarea_ID"
    FOREIGN KEY ("Tarea_ID")
      REFERENCES "Tareas"("Tarea_ID")
);
