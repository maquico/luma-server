import user from "./src/services/user.service.js"
import predefinedReward from "./src/services/predefinedRewards.service.js"

//const {data, error} = await user.sendOtp("angelgmorenor@gmail.com")

// const {data, error} = await user.verifyOtp("angelgmorenor@gmail.com", "864622")

// const {data, error} = await user.resetPassword("37d3b652-d314-4124-9685-add5f0c6fc19", "Test@456")

const {data, error} = await predefinedReward.getByUserId("37d3b652-d314-4124-9685-add5f0c6fc19")

console.log(data, error)