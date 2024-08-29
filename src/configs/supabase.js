import { config } from 'dotenv';
import { createClient } from '@supabase/supabase-js';

config();
const supabaseUrl = process.env.LOCAL_SUPABASE_URL || process.env.SUPABASE_URL;
const supabaseKey = process.env.LOCAL_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY;


const supabase = createClient(supabaseUrl, supabaseKey);

export default supabase;

