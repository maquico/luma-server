import supabaseConfig from "../configs/supabase.js";
import badgeService from "./badge.service.js";
import userService from "./user.service.js";

const { supabase } = supabaseConfig;

async function create(badgeObj) {
    console.log("Badge obj: ", badgeObj)
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .insert([
            {
                // required
                Usuario_ID: badgeObj.userId,
                Insignia_ID: badgeObj.badgeId
            },
        ])
        .select()
    
    error ? console.log(error) : console.log(`Badge created: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function get(columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
    
    error ? console.log(error) : console.log(`Badges found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function getByUser(id, columns = 'Insignias(Insignia_ID, nombre, descripcion, foto)') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
        .eq('Usuario_ID', id)
    
    if (error) {
        console.log(error);
        return { data: null, error };
    }

    console.log(`Badge found: ${JSON.stringify(data)}`)

    return { data, error };
}

async function getByUserClient(id){
    const { data: userData, error: userError } = await userService.getById(id, 'Usuario_ID, nombre, apellido, correo');

    if (userError) {
        console.log(userError);
        return { data: null, error: userError };
    }

    const { data: obtainedBadges, error: obtainedBadgesError } = await getByUser(id, 'Insignia_ID');
    
    if (obtainedBadgesError) {
        console.log(obtainedBadgesError);
        return { data: null, error: obtainedBadgesError };
    }

    const { data: badges, error: badgeError } = await badgeService.get('Insignia_ID, nombre, descripcion, foto')
    if (badgeError) {
        console.log(badgeError);
        return { data: null, error: badgeError };
    }

    const userFullName = `${userData[0].nombre} ${userData[0].apellido}`;
    const userEmail = userData[0].correo;
    const userId = userData[0].Usuario_ID;

    const obtainedBadgeIds = obtainedBadges.map(badge => badge.Insignia_ID);
    console.log(`Obtained badge IDs: ${obtainedBadgeIds}`);

    const responseObj = {
        userId: userId,
        userFullName: userFullName,
        userEmail: userEmail,
        badges: badges.map(badge => {
            return {
                title: badge.nombre,
                description: badge.descripcion,
                unlocked: obtainedBadgeIds.includes(badge.Insignia_ID),
                icon: badge.foto
            };
        })
    };
    
    return { data:responseObj, error: null };
}

async function getByBadge(id, columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
        .eq('Insignia_ID', id)
    
    error ? console.log(error) : console.log(`Badge found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function getByUserAndBadge(userId, badgeId, columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
        .eq('Usuario_ID', userId)
        .eq('Insignia_ID', badgeId)
    
    error ? console.log(error) : console.log(`Badge found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function deleteByUserAndBadge(userId, badgeId) {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .delete()
        .eq('Usuario_ID', userId)
        .eq('Insignia_ID', badgeId)
        .select()
    
    error ? console.log(error) : console.log(`Badge deleted: ${JSON.stringify(data)}`)
    
    return { data, error };
}

export default {
    create,
    get,
    getByUser,
    getByUserClient,
    getByBadge,
    getByUserAndBadge,
    deleteByUserAndBadge,
};