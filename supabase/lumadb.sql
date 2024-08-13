CREATE TABLE "Proyectos" (
  "Proyecto_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "descripcion" TEXT NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP 
);

CREATE TABLE "Iconos" (
  "Icono_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Recompensas" (
  "Recompensa_ID" INT PRIMARY KEY,
  "Proyecto_ID" INT NOT NULL,
  "Icono_ID" INT NOT NULL,
  "nombre" VARCHAR(100) NOT NULL,
  "descripcion" TEXT,
  "precio" NUMERIC(10, 2) NOT NULL,
  "cantidad" INT NOT NULL,
  "limite" INT NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP,
  CONSTRAINT "FK_Recompensas.Proyecto_ID"
    FOREIGN KEY ("Proyecto_ID")
      REFERENCES "Proyectos"("Proyecto_ID"),
  CONSTRAINT "FK_Recompensas.Icono_ID"
    FOREIGN KEY ("Icono_ID")
      REFERENCES "Iconos"("Icono_ID")
);

CREATE TABLE "Temas" (
  "Tema_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "precio" NUMERIC(10, 2) NOT NULL,
  "accentHex" VARCHAR(7) NOT NULL,
  "primaryHex" VARCHAR(7) NOT NULL,
  "secondaryHex" VARCHAR(7) NOT NULL,
  "backgroundHex" VARCHAR(7) NOT NULL,
  "textHex" VARCHAR(7) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Preguntas" (
  "Pregunta_ID" INT PRIMARY KEY,
  "titulo" VARCHAR(200) NOT NULL,
  "contenido" TEXT NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Insignia_Categoria" (
  "Insignia_Cat_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "campoComparativo" VARCHAR(50) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Insignias" (
  "Insignia_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "descripcion" TEXT NOT NULL,
  "Insignia_Cat_ID" INT NOT NULL,
  "meta" INT NOT NULL,
  "foto" VARCHAR(255) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP,
  CONSTRAINT "FK_Insignias.Insignia_Cat_ID"
    FOREIGN KEY ("Insignia_Cat_ID")
      REFERENCES "Insignia_Categoria"("Insignia_Cat_ID")
);

CREATE TABLE "Idiomas" (
  "Idioma_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Usuarios" (
  "Usuario_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "apellido" VARCHAR(100) NOT NULL,
  "correo" VARCHAR(100) NOT NULL,
  "experiencia" INT NOT NULL DEFAULT 0,
  "nivel" INT NOT NULL DEFAULT 1,
  "monedas" INT NOT NULL DEFAULT 0,
  "totalGemas" INT NOT NULL DEFAULT 0,
  "tareasAprobadas" INT NOT NULL DEFAULT 0,
  "proyectosCreados" INT NOT NULL DEFAULT 0,
  "foto" VARCHAR(255) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP,
  "esAdmin" BOOLEAN NOT NULL DEFAULT False,
  "Idioma_ID" INT NOT NULL DEFAULT 1,
  "contraseña" VARCHAR(255) NOT NULL,
  CONSTRAINT "FK_Usuarios.Idioma_ID"
    FOREIGN KEY ("Idioma_ID")
      REFERENCES "Idiomas"("Idioma_ID")
);

CREATE TABLE "Insignia_Conseguida" (
  "Usuario_ID" INT NOT NULL,
  "Insignia_ID" INT NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Insignia_ID"),
  CONSTRAINT "FK_Insignia_Conseguida.Insignia_ID"
    FOREIGN KEY ("Insignia_ID")
      REFERENCES "Insignias"("Insignia_ID"),
  CONSTRAINT "FK_Insignia_Conseguida.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID")
);

CREATE TABLE "Fuentes" (
  "Fuente_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "precio" NUMERIC(10, 2) NOT NULL,
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP DEFAULT NOW()
);

CREATE TABLE "Historial_Temas" (
  "Usuario_ID" INT,
  "Tema_ID" INT,
  "cantidadComprada" INT,
  "precioCompra" NUMERIC(10, 2),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Tema_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Temas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Temas.Tema_ID"
    FOREIGN KEY ("Tema_ID")
      REFERENCES "Temas"("Tema_ID")
);

CREATE TABLE "Historial_Fuentes" (
  "Usuario_ID" INT,
  "Fuente_ID" INT,
  "cantidadComprada" INT,
  "precioCompra" NUMERIC(10, 2),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Fuente_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Fuentes.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Fuentes.Fuente_ID"
    FOREIGN KEY ("Fuente_ID")
      REFERENCES "Fuentes"("Fuente_ID")
);

CREATE TABLE "Historial_Recompensas" (
  "Usuario_ID" INT,
  "Recompensa_ID" INT,
  "cantidadComprada" INT,
  "precioCompra" NUMERIC(10, 2),
  "fechaRegistro" TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Recompensa_ID"),
  CONSTRAINT "FK_Historial_Recompensas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas.Recompensa_ID"
    FOREIGN KEY ("Recompensa_ID")
      REFERENCES "Recompensas"("Recompensa_ID")
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
      REFERENCES "Proyectos"("Proyecto_ID"),
  CONSTRAINT "FK_Miembro_Proyecto.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "UNIQUE_Usuario_Proyecto" UNIQUE ("Usuario_ID", "Proyecto_ID")
);

CREATE TABLE "Fuentes" (
  "Fuente_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "precio" NUMERIC(10, 2) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Historial_Temas" (
  "Usuario_ID" INT NOT NULL,
  "Tema_ID" INT NOT NULL,
  "cantidadComprada" INT NOT NULL,
  "precioCompra" NUMERIC(10, 2) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Tema_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Temas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Temas.Tema_ID"
    FOREIGN KEY ("Tema_ID")
      REFERENCES "Temas"("Tema_ID")
);

CREATE TABLE "Historial_Fuentes" (
  "Usuario_ID" INT NOT NULL,
  "Fuente_ID" INT NOT NULL,
  "cantidadComprada" INT NOT NULL,
  "precioCompra" NUMERIC(10, 2) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Fuente_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Fuentes.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas_Fuentes.Fuente_ID"
    FOREIGN KEY ("Fuente_ID")
      REFERENCES "Fuentes"("Fuente_ID")
);

CREATE TABLE "Historial_Recompensas" (
  "Usuario_ID" INT NOT NULL,
  "Recompensa_ID" INT NOT NULL,
  "cantidadComprada" INT NOT NULL,
  "precioCompra" NUMERIC(10, 2) NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("Usuario_ID", "Recompensa_ID"),
  CONSTRAINT "FK_Historial_Recompensas.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "FK_Historial_Recompensas.Recompensa_ID"
    FOREIGN KEY ("Recompensa_ID")
      REFERENCES "Recompensas"("Recompensa_ID")
);

CREATE TABLE "Roles" (
  "Rol_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "descripcion" TEXT NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Miembro_Proyecto" (
  "Miembro_ID" INT PRIMARY KEY,
  "Usuario_ID" INT NOT NULL,
  "Proyecto_ID" INT NOT NULL,
  "Rol_ID" INT NOT NULL,
  "gemas" INT NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP,
  CONSTRAINT "FK_Miembro_Proyecto.Rol_ID"
    FOREIGN KEY ("Rol_ID")
      REFERENCES "Roles"("Rol_ID"),
  CONSTRAINT "FK_Miembro_Proyecto.Proyecto_ID"
    FOREIGN KEY ("Proyecto_ID")
      REFERENCES "Proyectos"("Proyecto_ID"),
  CONSTRAINT "FK_Miembro_Proyecto.Usuario_ID"
    FOREIGN KEY ("Usuario_ID")
      REFERENCES "Usuarios"("Usuario_ID"),
  CONSTRAINT "UNIQUE_Usuario_Proyecto" UNIQUE ("Usuario_ID", "Proyecto_ID")
);

CREATE TABLE "Estados_Tarea" (
  "Estado_tarea_ID" INT PRIMARY KEY,
  "nombre" VARCHAR(100) NOT NULL,
  "descripcion" TEXT,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP
);

CREATE TABLE "Tareas" (
  "Tarea_ID" INT PRIMARY KEY,
  "Proyecto_ID" INT NOT NULL,
  "Estado_tarea_ID" INT NOT NULL DEFAULT 1,
  "Miembro_ID" INT NOT NULL,
  "etiquetas" VARCHAR(84),
  "nombre" VARCHAR(100) NOT NULL,
  "descripcion" TEXT,
  "esfuerzo" INT NOT NULL,
  "prioridad" INT NOT NULL,
  "valorGemas" INT NOT NULL,
  "fechaFinal" TIMESTAMP,
  "fueReclamada" BOOLEAN NOT NULL DEFAULT False,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP,
  CONSTRAINT "FK_Tareas.Proyecto_ID"
    FOREIGN KEY ("Proyecto_ID")
      REFERENCES "Proyectos"("Proyecto_ID"),
  CONSTRAINT "FK_Tareas.Estado_tarea_ID"
    FOREIGN KEY ("Estado_tarea_ID")
      REFERENCES "Estados_Tarea"("Estado_tarea_ID"),
  CONSTRAINT "FK_Tareas.Miembro_ID"
    FOREIGN KEY ("Miembro_ID")
      REFERENCES "Miembro_Proyecto"("Miembro_ID")
);

CREATE TABLE "Comentarios_Tarea" (
  "Comentario_ID" INT PRIMARY KEY,
  "Tarea_ID" INT NOT NULL,
  "Miembro_ID" INT NOT NULL,
  "contenido" TEXT NOT NULL,
  "fechaRegistro" TIMESTAMP NOT NULL DEFAULT NOW(),
  "fechaModificacion" TIMESTAMP,
  CONSTRAINT "FK_Comentarios_Tarea.Miembro_ID"
    FOREIGN KEY ("Miembro_ID")
      REFERENCES "Miembro_Proyecto"("Miembro_ID"),
  CONSTRAINT "FK_Comentarios_Tarea.Tarea_ID"
    FOREIGN KEY ("Tarea_ID")
      REFERENCES "Tareas"("Tarea_ID")
);

