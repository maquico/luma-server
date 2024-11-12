import AdminJS from 'adminjs';
import { Database, Resource, getModelByName } from '@adminjs/prisma'
import { PrismaClient } from '@prisma/client'


const prisma = new PrismaClient()

// Register the SQL adapter
AdminJS.registerAdapter({
  Database,
  Resource,
});

// Function to initialize AdminJS
const initializeAdminJS = async () => {
  const admin = new AdminJS({
    resources: [
      {
        resource: { model: getModelByName('Usuarios'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('users'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Temas'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Proyectos'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Fuentes'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Recompensas'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Miembro_Proyecto'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Tareas'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Insignia_Categoria'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Insignias'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Insignia_Conseguida'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Roles'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Comentarios_Tarea'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Estados_Tarea'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Historial_Fuentes'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Historial_Recompensas'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Historial_Temas'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Iconos'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Idiomas'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Invitaciones'), client: prisma },
        options: {},
      },
      {
        resource: { model: getModelByName('Preguntas'), client: prisma },
        options: {},
      }
    ],
  });

  return admin;
};

export default { initializeAdminJS };