import predefinedReward from "../services/predefinedRewards.service.js"

// Controller for handling request with error catching
async function getByUserId(req, res) {
    /* #swagger.tags = ['Predefined Rewards']
       #swagger.description = 'Endpoint para obtener todas las recompensas predefinidas segun el usuario.'
       #swagger.parameters['userId'] = {
           in: 'path',
           description: 'Id del usuario',
           required: true,
           type: 'string'
       }
    */
   try {
    const { data, error } = await predefinedReward.getByUserId(req.params.userId)
    if (error) {
        let statusCode;
        error.status ? statusCode = parseInt(error.status) : 500;
        return res.status(statusCode).send(error.message);
      }
      return res.status(200).send(data);
   } catch (error) {
     return res.status(500).send(error.message);
   }
}

async function buyPredefinedReward(req, res) {
    /* #swagger.tags = ['Predefined Rewards']
       #swagger.description = 'Endpoint comprar una recompensa predefinida.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la compra',
           required: true,
           schema: {
               rewardId: 123456,
               userId: 'abc123',
               rewardType: 'font || theme'
           }
       }
    */
    try {
        const { rewardId, userId, rewardType } = req.body;
        const { data, error } = await predefinedReward.buyPredefinedReward(userId, rewardId, rewardType);
        if (error) {
            let statusCode;
            error.status ? statusCode = parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
          }
          return res.status(200).send(data);
       } catch (error) {
         return res.status(500).send(error.message);
       }
} 

export default {
    getByUserId,
    buyPredefinedReward,
};