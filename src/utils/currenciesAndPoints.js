function calculateGemPrice(priority, time) {
  return (10 * time) / priority;
}

function calculateExperiencePoints(priority, time) {
  return (100 * time) / priority;
}

export default {
    calculateGemPrice,
    calculateExperiencePoints,
};