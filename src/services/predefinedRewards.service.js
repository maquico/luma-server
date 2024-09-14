import supabaseConfig from "../configs/supabase.js"; 
import fontsRewardsService from "./fontsRewards.service.js";
import themesRewardsService from "./themesRewards.service.js";
import fontsHistoryService from "./fontsHistory.service.js";
import themesHistoryService from "./themesHistory.service.js";

const { supabase } = supabaseConfig; 

async function getByUserId(userId) {
    const continueFunction = true;

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

    if(fontsHistoryError || themesHistoryError || fontsRewardsError || themesRewardsError) {
        console.log(`Fonts history error: ${fontsHistoryError}`);
        console.log(`Themes history error: ${themesHistoryError}`);
        console.log(`Fonts rewards error: ${fontsRewardsError}`);
        console.log(`Themes rewards error: ${themesRewardsError}`);
        continueFunction = false;
    }

    if(continueFunction) {
        // map the fonts rewards
        const fontsRewardsMap = fontsRewards.map(font => {
            const fontHistory = fontsHistory.find(fontHistory => fontHistory.Fuente_ID === font.Fuente_ID);
            const fontBought = fontHistory ? fontHistory.cantidadComprada : 0;

            return {
                type: 'font',
                id: font.Fuente_ID,
                name: font.nombre,
                price: font.precio,
                total: 1,
                totalBought: fontBought,
                metadata: {},
            }
        });

        // map the themes rewards
        const themesRewardsMap = themesRewards.map(theme => {
            const themeHistory = themesHistory.find(themeHistory => themeHistory.Tema_ID === theme.Tema_ID);
            const themeBought = themeHistory ? themeHistory.cantidadComprada : 0;

            return {
                type: 'theme',
                id: theme.Tema_ID,
                name: theme.nombre,
                price: theme.precio,
                total: 1,
                totalBought: themeBought,
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
        const rewards = [...fontsRewardsMap, ...themesRewardsMap];
        console.log(`Rewards found: ${rewards}`);
    }

    
    
}