require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.LOCAL_SUPABASE_URL || process.env.SUPABASE_URL;
const supabaseKey = process.env.LOCAL_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY;


const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;

