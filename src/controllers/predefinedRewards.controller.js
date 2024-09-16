import predefinedReward from "../services/predefinedRewards.service.js"

// Controller for handling request with error catching
async function getByUserId(req, res) {
    /* #swagger.tags = ['Predefined Rewards']
        #swagger.description = 'Endpoint para obtener todas las recompensas predefinidas segun el usuario.'
    */
   try {
    const { data, error } = await predefinedReward.getByUserId(req.params.userId)
    if (error) {
        const errorStatusCode = parseInt(error.status, 10)
        console.log(errorStatusCode);
        return res.status(errorStatusCode).send(error.message);
      }
      return res.status(200).send(data);
   } catch (error) {
     return res.status(500).send(error.message);
   }
}

export default {
    getByUserId,
};