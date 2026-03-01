

import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {

    function jsonResponse(data: any, status = 200) {
        return new Response(JSON.stringify(data), {
            status,
            headers: { "Content-Type": "application/json" },
        });
    }

    if (req.method !== "POST") {
        return jsonResponse({ error: "Method not allowed" }, 405);
    }

    try {
        const supabase = createClient(
            "https://uxrudvwvfgghhzstawlf.supabase.co",
            "sb_secret_WPAHy_yrSwsKQCKVjWlcZA_POsdzBpT"
        );

        const body = await req.json();

        const { operation, parent_ids, tablesEntitiesIdsRemove,
            device_id, user_id } = body;

        const { data, error } = await supabase.rpc(
            "sync_process_operation",
            {
                p_operation: operation,
                p_parent_ids: parent_ids ?? null,
                p_tables_entities_ids_remove: tablesEntitiesIdsRemove ?? {},
                p_device_id: device_id,
                p_user_id: user_id,
            }
        );

        if (error) {
            console.error("[SYNC RPC ERROR]", error);
            return jsonResponse({ error: error.message }, 500);
        }

        return jsonResponse(data);

    } catch (err: any) {
        console.error("[SYNC ERROR]", err);
        return jsonResponse(
            { error: "internal_server_error", details: err.message },
            500
        );
    }
});