import supabaseConfig from "../configs/supabase.js"; 
import themesRewardsService from "./themesRewards.service.js";
import themesHistoryService from "./themesHistory.service.js";
import userService from "./user.service.js";

const { supabase } = supabaseConfig; 

async function getByUserId(userId) {
    const continueFunction = true;
    let errorObject = { message: '', status: 200 };
    let rewards = [];

    const [
        { data: themesHistory, error: themesHistoryError },
        { data: themesRewards, error: themesRewardsError }
      ] = await Promise.all([
        themesHistoryService.getByUserId(userId),
        themesRewardsService.get()
      ]);

    if(themesHistoryError) {
        console.log(`Error getting themes history: ${themesHistoryError.message}`);
        errorObject.message = themesHistoryError.message;
        errorObject.status = themesHistoryError.status;
        continueFunction = false;
    }
    else if(themesRewardsError) {
        console.log(`Error getting themes rewards: ${themesRewardsError.message}`);
        errorObject.message = themesRewardsError.message;
        errorObject.status = themesRewardsError.status;
        continueFunction = false;
    }

    if(continueFunction) {
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
                    font: theme.fuente,
                    accentHex: theme.accentHex,
                    primaryHex: theme.primaryHex,
                    secondaryHex: theme.secondaryHex,
                    backgroundHex: theme.backgroundHex,
                    textHex: theme.textHex,
                },
            }
        });

        // Merge rewards on a single list
        rewards = [...themesRewardsMap];
        console.log(`Rewards found: ${JSON.stringify(rewards, null, 2)}`);
        errorObject = null;
    }

    return { 
        data: rewards, 
        error: errorObject
    };
}

async function buyPredefinedReward(userId, rewardId, rewardType) {
    let errorObject = { message: '', status: 200 };
    let continueFunction = true;
    let reward = null;
    let rewardHistory = null;
    let content = null;

    // get the reward
    if (rewardType === "theme") {
        const { data: themeReward, error: themeRewardError } = await themesRewardsService.getById(rewardId);
        reward = themeReward;
        if(themeRewardError) {
            console.log(`Error getting theme reward: ${themeRewardError.message}`);
            errorObject.message = themeRewardError.message;
            errorObject.status = themeRewardError.status;
            continueFunction = false;
        }
    }

    // check if the user has enough coins
    if (continueFunction){
        const { data: user, error: userError } = await userService.getById(userId);
        if(userError) {
            console.log(`Error getting user: ${userError.message}`);
            errorObject.message = userError.message;
            errorObject.status = userError.status;
            continueFunction = false;
        }
        else if(user.monedas < reward.precio) {
            console.log(`User does not have enough coins to buy the reward`);
            errorObject.message = `User does not have enough coins to buy the reward`;
            errorObject.status = 400;
            continueFunction = false;
        }
    }
    
    if (rewardType === "theme" && continueFunction) {
        const { data: themeHistory, error: themeHistoryError } = await themesHistoryService.getByUserId(userId);
        rewardHistory = themeHistory.find(theme => theme.Tema_ID === rewardId);
        if(themeHistoryError) {
            console.log(`Error getting theme history: ${themeHistoryError.message}`);
            errorObject.message = themeHistoryError.message;
            errorObject.status = themeHistoryError.status;
            continueFunction = false;
        }
        else if(rewardHistory) {
            console.log(`User already bought the theme`);
            errorObject.message = `User already bought the theme`;
            errorObject.status = 400;
            continueFunction = false;
        }
    }

    // ON A TRANSACTION:
    console.log(userId, rewardId, rewardType);
    if (continueFunction) {
        const { data, error } = await supabase
        .rpc('buy_with_coins_transaction',
            { 
              "p_user_id": userId,
              "p_reward_id": rewardId,
              "p_reward_type": rewardType 
            });
        
        if(error) {
            console.log(`Error buying reward: ${error.message}`);
            errorObject.message = error.message;
            errorObject.status = 500;
        } else {
            content = {
                message: 'Reward bought successfully',
                function_data: data
            };
            errorObject = null;
        }
    }
    
    return {
        data: content,
        error: errorObject
    };
}

export default {
    getByUserId,
    buyPredefinedReward,
};