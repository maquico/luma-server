import { config } from 'dotenv';
import { createClient } from '@supabase/supabase-js';

config();
const supabaseUrl = process.env.LOCAL_SUPABASE_URL || process.env.SUPABASE_URL;
const supabaseKey = process.env.LOCAL_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false
    }
});

export default {
    supabase,
    supabaseAdmin,
};

