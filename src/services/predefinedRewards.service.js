import supabaseConfig from "../configs/supabase.js"; 
import fontsRewardsService from "./fontsRewards.service.js";
import themesRewardsService from "./themesRewards.service.js";
import fontsHistoryService from "./fontsHistory.service.js";
import themesHistoryService from "./themesHistory.service.js";

const { supabase } = supabaseConfig; 

async function getByUserId(userId) {
    const continueFunction = true;
    let errorObject = { message: '', status: 200 };
    let rewards = [];

    const [
        { data: fontsHistory, error: fontsHistoryError },
        { data: themesHistory, error: themesHistoryError },
        { data: fontsRewards, error: fontsRewardsError },
        { data: themesRewards, error: themesRewardsError }
      ] = await Promise.all([
        fontsHistoryService.getByUserId(userId),
        themesHistoryService.getByUserId(userId),
        fontsRewardsService.get(),
        themesRewardsService.get()
      ]);

    if(fontsHistoryError) {
        console.log(`Error getting fonts history: ${fontsHistoryError.message}`);
        errorObject.message = fontsHistoryError.message;
        errorObject.status = fontsHistoryError.status;
        continueFunction = false;
    }
    else if(themesHistoryError) {
        console.log(`Error getting themes history: ${themesHistoryError.message}`);
        errorObject.message = themesHistoryError.message;
        errorObject.status = themesHistoryError.status;
        continueFunction = false;
    }
    else if(fontsRewardsError) {
        console.log(`Error getting fonts rewards: ${fontsRewardsError.message}`);
        errorObject.message = fontsRewardsError.message;
        errorObject.status = fontsRewardsError.status;
        continueFunction = false;
    }
    else if(themesRewardsError) {
        console.log(`Error getting themes rewards: ${themesRewardsError.message}`);
        errorObject.message = themesRewardsError.message;
        errorObject.status = themesRewardsError.status;
        continueFunction = false;
    }

    if(continueFunction) {
        // map the fonts rewards
        const fontsRewardsMap = fontsRewards.map(font => {
            const fontHistory = fontsHistory.find(fontHistory => fontHistory.Fuente_ID === font.Fuente_ID);
            const fontBought = fontHistory ? fontHistory.cantidadComprada : 0;
            const fontAvailable = fontBought == 1 ? false : true;

            return {
                type: 'font',
                id: font.Fuente_ID,
                name: font.nombre,
                price: font.precio,
                available: fontAvailable,
                totalAvailable: 1,
                totalBought: fontBought,
                totalCapacity: 1,
                metadata: {},
            }
        });

        // map the themes rewards
        const themesRewardsMap = themesRewards.map(theme => {
            const themeHistory = themesHistory.find(themeHistory => themeHistory.Tema_ID === theme.Tema_ID);
            const themeBought = themeHistory ? themeHistory.cantidadComprada : 0;
            const themeAvailable = themeBought == 1 ? false : true;

            return {
                type: 'theme',
                id: theme.Tema_ID,
                name: theme.nombre,
                price: theme.precio,
                available: themeAvailable,
                totalAvailable: 1,
                totalBought: themeBought,
                totalCapacity: 1,
                metadata: {
                    accentHex: theme.accentHex,
                    primaryHex: theme.primaryHex,
                    secondaryHex: theme.secondaryHex,
                    backgroundHex: theme.backgroundHex,
                    textHex: theme.textHex,
                },
            }
        });

        // Merge rewards on a single list
        rewards = [...fontsRewardsMap, ...themesRewardsMap];
        console.log(`Rewards found: ${JSON.stringify(rewards, null, 2)}`);
        errorObject = null;
    }

    return { 
        data: rewards, 
        error: errorObject
    };
}

export default {
    getByUserId,
};