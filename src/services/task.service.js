import supabaseConfig from "../configs/supabase.js";
import currenciesAndPoints from "../utils/currenciesAndPoints.js";
import tagsUtils from "../utils/tagsUtils.js";
import projectMemberService from "./projectMember.service.js";
import userService from "./user.service.js";

const { supabase } = supabaseConfig;

async function create(taskObj) {

    if (taskObj.tags) {
        // Validate tags
        const { valid, message } = tagsUtils.validateTags(taskObj.tags);
        if (!valid) {
            console.log(`Error validating tags when creating task: ${message}`);
            return { data: null, error: { message: message } };
        }
        const processedTags = tagsUtils.processTags(taskObj.tags);
        taskObj.tags = processedTags;
    }

    const { data, error } = await supabase
        .from('Tareas')
        .insert([
            {
                // requerido
                Proyecto_ID: taskObj.projectId,
                nombre: taskObj.name,
                prioridad: taskObj.priority,
                tiempo: taskObj.time,
                // automatico
                valorGemas: currenciesAndPoints.calculateGemPrice(taskObj.priority, taskObj.time),
                puntosExperiencia: currenciesAndPoints.calculateExperiencePoints(taskObj.priority, taskObj.time),
                // opcional
                fechaInicio: taskObj.startDate,
                fechaFin: taskObj.endDate,
                Usuario_ID: taskObj.userId,
                esCritica: taskObj.isCritical,
                gastos: taskObj.cost,
                presupuesto: taskObj.budget,
                descripcion: taskObj.description,
                etiquetas: taskObj.tags,
            },
        ])
        .select()
    return { data, error };
}

async function update(taskId, taskObj) {

    if (taskObj.etiquetas) {
        // Validate tags
        const { valid, message } = tagsUtils.validateTags(taskObj.etiquetas);
        if (!valid) {
            console.log(`Error validating tags when updating task with ID ${taskId}: ${message}`);
            return { data: null, error: { message: message } };
        }
        const processedTags = tagsUtils.processTags(taskObj.etiquetas);
        taskObj.etiquetas = processedTags;
    }

    taskObj.valorGemas = currenciesAndPoints.calculateGemPrice(taskObj.prioridad, taskObj.tiempo);
    taskObj.puntosExperiencia = currenciesAndPoints.calculateExperiencePoints(taskObj.prioridad, taskObj.tiempo);

    let returnData = { message: "", data: {} };
    const { data, error } = await supabase
        .from('Tareas')
        .update(taskObj)
        .eq('Tarea_ID', taskId);
    if (error) {
        console.log("Error updating task on supabase: ", error);
    } else {
        returnData.message = `Task with id ${taskId} updated with: ${JSON.stringify(taskObj, null, 2)}`;
        returnData.data.taskId = taskId;
    }
    return { data: returnData, error };
}

async function getById(taskId, columns = '*') {
    const { data, error } = await supabase
        .from('Tareas')
        .select(columns)
        .eq('Tarea_ID', taskId);

    error ? console.log(error) : console.log(`Task with ID ${taskId} found: ${JSON.stringify(data, null, 2)}`);
    return { data, error };
}

async function formatTasks(data) {
    // Mapear los estados de las tareas a categorías
    const estadosMap = {
        1: { id: 1, name: "TODO", items: [] },
        2: { id: 2, name: "DOING", items: [] },
        3: { id: 3, name: "DONE", items: [] },
        4: { id: 4, name: "APPROVED", items: [] }
    };

    const usersIds = data.map(task => task.Usuario_ID).filter(userId => userId !== null);

    const { data: usersData, error: usersError } = await userService.getByIds(usersIds, 'Usuario_ID, nombre, apellido');

    if (usersError) {
        console.log(usersError);
        return { data: null, error: usersError };
    }

    // Transformar cada tarea en el formato adecuado
    data.forEach(task => {
        const estado = estadosMap[task.Estado_Tarea_ID];

        // Preparar las etiquetas (tags)
        const tags = task.etiquetas ? task.etiquetas.split(',') : [];

        // Formato final de cada ítem
        const item = {
            id: task.Tarea_ID,
            name: task.nombre,
            assignedUser: task.Usuario_ID ? `${usersData.find(user => user.Usuario_ID === task.Usuario_ID).nombre} ${usersData.find(user => user.Usuario_ID === task.Usuario_ID).apellido}` : null,
            description: task.descripcion || "Sin descripción",
            projectName: `${task.Proyectos.nombre}`,
            tags: tags,
            endDate: task.fechaFin
                ? new Date(task.fechaFin).toLocaleDateString('es-ES', { day: 'numeric', month: 'short', year: 'numeric' })
                : "Sin fecha"
        };

        // Agregar el ítem a la categoría correspondiente
        estado.items.push(item);
    });

    // Convertir los estados en un array
    const result = Object.values(estadosMap);

    console.log(`Transformed Data: ${JSON.stringify(result, null, 2)}`);
    return result;
}

// Función para transformar las tareas en el formato necesario
async function getByProjectId(projectId, columns = '*, Proyectos(nombre)', format = false) {
    const { data, error } = await supabase
        .from('Tareas')
        .select(columns)
        .eq('Proyecto_ID', projectId);

    if (error) {
        console.log(error);
        return { data: null, error };
    }

    console.log(`Tasks found for project with ID ${projectId}: ${JSON.stringify(data, null, 2)}`);

    let result = data;
    if (format === true) {
        console.log("Formatting tasks...");
        result = await formatTasks(data);
    }
    return { data: result, error: null };
}

async function getTagsByProjectId(projectId) {
    const { data, error } = await getByProjectId(projectId, 'etiquetas');

    if (error) {
        console.log(error);
        return { data: null, error };
    } else {
        // Extract and process tags
        const tags = data
            .filter(item => item.etiquetas !== null) // Filter out items with no tags
            .map(item => item.etiquetas.split(',')) // Split tags by comma
            .flat() // Flatten the array
            .map(tag => tag.trim()) // Trim whitespace
            .filter((tag, index, self) => tag && self.indexOf(tag) === index); // Remove duplicates and empty strings

        console.log(`Tags found for project with ID ${projectId}: ${JSON.stringify(tags, null, 2)}`);
        return { data: tags, error: null };
    }
}

async function get() {
    const { data, error } = await supabase
        .from('Tareas')
        .select()
    error ? console.log(error) : console.log(`All tasks found: ${JSON.stringify(data, null, 2)}`);
    return { data, error };
}

async function deleteById(taskId, userId, projectId) {
    const LIDER_ROLE_NAME = "Lider"; // Nombre del rol líder

    // Verificar si el usuario tiene el rol de líder en el proyecto
    const { data: hasRole, error: roleError } = await projectMemberService.checkMemberRole(userId, projectId, LIDER_ROLE_NAME);

    if (roleError) {
        console.error("Error al verificar el rol del usuario:", roleError);
        return { data: null, error: roleError };
    }

    if (!hasRole) {
        return {
            data: null,
            error: {
                message: "Permiso denegado: solo los usuarios con el rol de líder pueden eliminar tareas.",
                status: 403,
            },
        };
    }

    // Proceder con la eliminación si el usuario es líder
    let returnData = { message: "", data: {} };
    const { data, error } = await supabase
        .from("Tareas")
        .delete()
        .eq("Tarea_ID", taskId);

    if (error) {
        console.error("Error al eliminar la tarea en Supabase:", error);
        return { data: null, error };
    }

    returnData.message = `Tarea con ID ${taskId} eliminada correctamente.`;
    returnData.data.taskId = taskId;

    return { data: returnData, error: null };
}


async function updateTaskStatus(taskId, projectId, newStatusId, userId) {
    let returnData = { message: "", data: {} };
    let task = null;

    const taskColumns = 'Tarea_ID, Estado_Tarea_ID, Usuario_ID, fueReclamada, puntosExperiencia, valorGemas';
    const { data: taskData, error: taskError } = await getById(taskId, taskColumns);
    if (taskError) {
        console.log("Error getting task on supabase: ", taskError);
        return { data: null, error: taskError };
    }
    task = taskData[0];

    // Validate user role if status id is 4 (approved)
    if (newStatusId === 4) {
        // Check if task has a user associated
        if (!task.Usuario_ID) {
            return { data: null, error: { message: "Task has no user associated", status: 400 } };
        }
        // Check if user has permission to approve tasks
        const { data: userData, error: userError } = await projectMemberService
            .getByUserProject(userId, projectId, 'Usuario_ID, Proyecto_ID, Rol_ID, Roles (nombre)');
        console.log(userData);

        if (userError) {
            console.log("Error getting user role on supabase: ", userError);
            return { data: null, error: userError };
        }
        if (userData[0].Roles.nombre !== 'Lider' && userData[0].Rol_ID !== 2) {
            return { data: null, error: { message: "User does not have permission to approve tasks", status: 400 } };
        }

        // Call procedure to update task status
        const { data: procedureData, error: procedureError } = await supabase.rpc('approve_task', {
            p_experience: task.puntosExperiencia,
            p_gems: task.valorGemas,
            p_new_status_id: newStatusId,
            p_project_id: projectId,
            p_task_claimed: task.fueReclamada,
            p_task_id: taskId,
            p_user_id: task.Usuario_ID
        });

        if (procedureError) {
            console.log("Error executing procedure on supabase: ", procedureError);
            return { data: null, error: procedureError };
        }
        returnData.message = `Task with id ${taskId} approved and status updated to ${newStatusId}`;
        returnData.data = procedureData;

    }
    else if (newStatusId !== task.Estado_Tarea_ID) {
        const { data, error: updateError } = await update(taskId, { Estado_Tarea_ID: newStatusId });

        if (updateError) {
            console.log("Error updating task status on supabase: ", updateError);
            return { data: null, error: updateError };
        } else {
            returnData.message = `Task with id ${taskId} updated with status ${newStatusId}`;
            returnData.data.taskId = taskId;
            returnData.data.newStatusId = newStatusId;
        }
    }
    else {
        return { data: null, error: { message: "Task already has the new status", status: 400 } };
    }

    return { data: returnData, error: null };
}

async function approvedTasksByProject(projectId, count = true) {
    const { data, error } = await supabase
        .from('Tareas')
        .select()
        .eq('Proyecto_ID', projectId)
        .eq('Estado_Tarea_ID', 4);

    if (error) {
        console.log(error);
        return { data: null, error };
    }

    if (data && count) {
        return { data: { count: data.length }, error };
    }

    return { data, error };
}

async function updateByRole(taskObj, userId) {
    const { Proyecto_ID, Task_ID, ...updates } = taskObj;

    // Verificar si el usuario pertenece al proyecto y obtener su Rol_ID
    const { data: memberData, error: memberError } = await projectMemberService.getByUserProject(
        userId,
        Proyecto_ID,
        "Rol_ID"
    );

    if (memberError) {
        console.error("Error al verificar el rol del usuario:", memberError);
        return { data: null, error: memberError };
    }

    if (!memberData || memberData.length === 0) {
        return {
            data: null,
            error: { message: "El usuario no es miembro del proyecto", status: 403 },
        };
    }

    const userRoleId = memberData[0].Rol_ID;

    // Definir los campos permitidos según el rol
    let allowedFields = [];
    if (userRoleId === 2) {
        // Líder
        allowedFields = [
            "nombre",
            "descripcion",
            "prioridad",
            "tiempo",
            "etiquetas",
            "gastos",
            "presupuesto",
            "Usuario_ID",
            "fechaInicio",
            "fechaFin",
            "esCritica",

        ];
    } else if (userRoleId === 1) {
        // Miembro
        allowedFields = ["nombre", "descripcion", "etiquetas"];
    } else {
        return {
            data: null,
            error: { message: "Rol de usuario sin permisos para actualizar tareas", status: 403 },
        };
    }

    // Filtrar los campos del objeto tarea según los permitidos
    const filteredUpdates = Object.keys(updates)
        .filter((key) => allowedFields.includes(key))
        .reduce((obj, key) => {
            obj[key] = updates[key];
            return obj;
        }, {});

    if (Object.keys(filteredUpdates).length === 0) {
        return {
            data: null,
            error: { message: "No hay campos válidos para actualizar", status: 400 },
        };
    }

    // Usar el método `update` del servicio `taskService`
    const { data, error } = await update(Task_ID, filteredUpdates);

    if (error) {
        console.error("Error al actualizar la tarea:", error);
        return { data: null, error };
    }

    return {
        data: {
            message: `Tarea actualizada exitosamente con los campos: ${Object.keys(filteredUpdates).join(", ")}`,
            Task_ID,
        },
        error: null,
    };
}


export default {
    create,
    get,
    getById,
    getByProjectId,
    getTagsByProjectId,
    update,
    deleteById,
    updateTaskStatus,
    approvedTasksByProject,
    updateByRole,
};