import { randomBytes } from 'crypto';

function generateToken() {
    return randomBytes(20).toString('hex');
}

export default generateToken;

 
