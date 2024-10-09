import user from "./src/services/user.service.js"
import predefinedReward from "./src/services/predefinedRewards.service.js"
import customRewardsHistoryService from "./src/services/customRewardsHistory.service.js"
import projectsService from "./src/services/projects.service.js"
import customRewardsService from "./src/services/customRewards.service.js"
// import taskService from "./src/services/task.service.js"
import validateTags from "./src/utils/tagsUtils.js"

//const {data, error} = await user.sendOtp("angelgmorenor@gmail.com")

// const {data, error} = await user.verifyOtp("angelgmorenor@gmail.com", "864622")

// const {data, error} = await user.resetPassword("37d3b652-d314-4124-9685-add5f0c6fc19", "Test@456")

// const {data, error} = await predefinedReward.getByUserId("37d3b652-d314-4124-9685-add5f0c6fc19")


// const {data, error} = await projectsService.getById("a")

// test get by id user service
// const {data, error} = await user.getById(123)

// test custom rewards get by user shop
// const {data, error} = await customRewardsHistoryService.getByUser("37d3b652-d314-4124-9685-add5f0c6fc19")
// const {data, error} = await customRewardsService.getByUserShop("37d3b652-d314-4124-9685-add5f0c6fc19")

// test get tags from tasks by project id
// const {data, error} = await taskService.getTagsByProjectId(1)


// test validate tags
const data = validateTags("tag0,,tag2")
console.log(data)