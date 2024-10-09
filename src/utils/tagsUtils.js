// Validation function for tags
function validateTags(tags) {
    if (!tags) return { valid: true, message: "" };

    const tagArray = tags.split(',').map(tag => tag.trim());

    if (tags.length > 84) {
        return { valid: false, message: "Tags string exceeds 84 characters." };
    }

    if (tagArray.length > 5) {
        return { valid: false, message: "More than 5 tags are not allowed." };
    }

    for (const tag of tagArray) {
        if (tag.length > 16) {
            return { valid: false, message: `Tag "${tag}" exceeds 16 characters.` };
        }
        if (tag.includes(',')) {
            return { valid: false, message: `Tag "${tag}" contains a comma, which is not allowed.` };
        }
        if (tag === "") {
            return { valid: false, message: "Empty tags are not allowed." };
        }
    }

    return { valid: true, message: "" };
}

function processTags(tags) {
    if (!tags) return [];

    return tags.split(',').map(tag => tag.trim()).join(',');
}

export default {
    validateTags,
    processTags,
};