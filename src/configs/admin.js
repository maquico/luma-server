import AdminJS from 'adminjs';
import { Adapter, Resource, Database } from '@adminjs/sql';

// Register the SQL adapter
AdminJS.registerAdapter({
  Database,
  Resource,
});

// Function to initialize AdminJS
const initializeAdminJS = async (connectionString) => {
  const db = await new Adapter('postgresql', {
    connectionString: connectionString,
    database: 'postgres',
  }).init();

  const admin = new AdminJS({
    resources: [
      {
        resource: db.table('Usuarios'),
        options: {},
      },
      {
        resource: db.table('Temas'),
        options: {},
      },
      {
        resource: db.table('Proyectos'),
        options: {},
      },
      {
        resource: db.table('Fuentes'),
        options: {},
      },
      {
        resource: db.table('Recompensas'),
        options: {},
      },
      {
        resource: db.table('Miembro_Proyecto'),
        options: {},
      },
      {
        resource: db.table('Tareas'),
        options: {},
      },
      {
        resource: db.table('Insignia_Categoria'),
        options: {},
      },
      {
        resource: db.table('Insignias'),
        options: {},
      },
      {
        resource: db.table('Insignia_Conseguida'),
        options: {},
      },
      {
        resource: db.table('Roles'),
        options: {},
      },
      {
        resource: db.table('Comentarios_Tarea'),
        options: {},
      },
      {
        resource: db.table('Dependencias_Tarea'),
        options: {},
      },
      {
        resource: db.table('Estados_Tarea'),
        options: {},
      },
      {
        resource: db.table('Historial_Fuentes'),
        options: {},
      },
      {
        resource: db.table('Historial_Recompensas'),
        options: {},
      },
      {
        resource: db.table('Historial_Temas'),
        options: {},
      },
      {
        resource: db.table('Iconos'),
        options: {},
      },
      {
        resource: db.table('Idiomas'),
        options: {},
      },
      {
        resource: db.table('Invitaciones'),
        options: {},
      },
      {
        resource: db.table('Preguntas'),
        options: {},
      }
    ],
  });

  return admin;
};

export default { initializeAdminJS };