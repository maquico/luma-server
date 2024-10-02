function calculateGemPrice(priority, time) {
  return Math.floor((10 * time) / priority);
}

function calculateExperiencePoints(priority, time) {
  return Math.floor((100 * time) / priority);
}

export default {
    calculateGemPrice,
    calculateExperiencePoints,
};