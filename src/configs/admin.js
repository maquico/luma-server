import AdminJS from 'adminjs';
import { Database, Resource, getModelByName } from '@adminjs/prisma'
import { PrismaClient } from '@prisma/client'
import Connect from 'connect-pg-simple'
import session from 'express-session'

const prisma = new PrismaClient()

const ORANGE = '#FC714A';
const PINK = '#FD7797';
const PURPLE = '#692DD7';
const BG_LIGHT__PURPLE = '#F5F0FF';
const TXT_DARK__PURPLE = '#0E0024';

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
        resource: { model: getModelByName('Dependencias_Tarea'), client: prisma },
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
    branding: {
      companyName: 'Luma - Backoffice',
      logo: '/assets/luma-logo.png',
      favicon: '/assets/luma-favicon.ico',
      theme: {
        colors: {
          primary100: PURPLE,
          primary80: PURPLE,
          primary60: PINK,
          accent: ORANGE,
        },
      },
    },
  });

  const ConnectSession = Connect(session)
  const sessionStore = new ConnectSession({
    conObject: {
      connectionString: process.env.DATABASE_URL,
      ssl: {
        rejectUnauthorized: false,
      },
    },
    tableName: 'session',
    createTableIfMissing: true,
  })

  return { admin, sessionStore };
};

export default { initializeAdminJS };