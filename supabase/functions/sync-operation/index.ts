import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";



serve(async (req) => {
    try {

        const supabase = createClient(
            "https://uxrudvwvfgghhzstawlf.supabase.co",
            "sb_secret_WPAHy_yrSwsKQCKVjWlcZA_POsdzBpT"
        );




        const body = await req.json();

        const operation = body.operation;
        const parent_ids = body.parent_ids ?? null;
        const tablesEntitiesIdsRemove = body.tablesEntitiesIdsRemove ?? {};
        const device_id = body.device_id;
        const user_id = body.user_id;
        const operation_id = operation.operation_id;
        const center_id = operation.center_id;

        function jsonResponse(data: any, status = 200) {
            return new Response(JSON.stringify(data), {
                status,
                headers: { "Content-Type": "application/json" },
            });
        }

        console.log(`[SYNC] Operation received: ${operation_id}, user: ${user_id}, center: ${center_id}`);

        // =========================
        // 1️⃣ Idempotency Check
        // =========================
        const { error: opError } = await supabase
            .from("processed_operations")
            .insert({ operation_id });

        if (opError) {
            console.warn(`[SYNC] Operation already processed: ${operation_id}`);
            return jsonResponse({ success: true, message: "Operation already processed" });
        }

        const table = operation.table;
        const action = operation.action;
        const entityId = operation.entity_id;
        const version = operation.version;
        let sendedTableRecord = operation.table_record;

        // ---------- ensure ISO format ----------
        if (sendedTableRecord?.created_at)
            sendedTableRecord.created_at = new Date(sendedTableRecord.created_at).toISOString();
        if (sendedTableRecord?.updated_at)
            sendedTableRecord.updated_at = new Date(sendedTableRecord.updated_at).toISOString();

        // ---------- Helpers ----------
        async function getRecord(id: string, tableName: string) {
            const { data, error } = await supabase
                .from(tableName)
                .select("*")
                .eq("id", id)
                .eq("center_id", center_id)
                .maybeSingle();
            if (error) throw new Error(`DB Error on getRecord: ${error.message}`);
            return data;
        }

        async function insertRecord(tableName: string, record: any) {
            const { error } = await supabase.from(tableName).insert(record);
            if (error) throw new Error(`DB Error on insertRecord: ${error.message}`);
        }

        async function upsertRecord(id: string, tableName: string, record: any) {
            const { error } = await supabase
                .from(tableName)
                .upsert(record)
                .eq("id", id)
                .eq("center_id", center_id);
            if (error) throw new Error(`DB Error on upsertRecord: ${error.message}`);
        }

        async function getRecordsByIds(tableName: string, ids: string[]) {
            const { data, error } = await supabase
                .from(tableName)
                .select("*")
                .in("id", ids)
                .eq("center_id", center_id);
            if (error) throw new Error(`DB Error on getRecordsByIds: ${error.message}`);
            return data;
        }

        async function validateParentsBulk(parent_ids: Record<string, string[]>) {
            const invalidParents: Record<string, string[]> = {};
            for (const [parentTable, ids] of Object.entries(parent_ids)) {
                const records = await getRecordsByIds(parentTable, ids as string[]);
                const foundIds = records.map(r => r.id);
                const deletedIds = records.filter(r => r.is_deleted).map(r => r.id);
                const notFoundIds = (ids as string[]).filter(id => !foundIds.includes(id));
                const combined = [...deletedIds, ...notFoundIds];
                if (combined.length > 0) invalidParents[parentTable] = combined;
            }
            if (Object.keys(invalidParents).length > 0) return invalidParents;
            return null;
        }

        const serverTableRecord = await getRecord(entityId, table);

        // ==============================
        // 1️⃣ CREATE
        // ==============================
        if (action === "create") {
            if (parent_ids) {
                const validation = await validateParentsBulk(parent_ids);
                if (validation)
                    return jsonResponse({ message: "parent_is_deleted", parent_ids: validation }, 409);
            }
            sendedTableRecord.version = 1;
            sendedTableRecord.push_time = new Date().toISOString();
            await insertRecord(table, sendedTableRecord);
            return jsonResponse({ success: true });
        }

        // ==============================
        // 2️⃣ CHECK ENTITY
        // ==============================
        if (!serverTableRecord) return jsonResponse({ message: "entity_not_found" }, 404);
        if (serverTableRecord.is_deleted) return jsonResponse({ message: "entity_is_deleted" }, 409);

        // ==============================
        // 3️⃣ DELETE (atomic + children)
        // ==============================
        if (action === "delete") {
            if (parent_ids) {
                const validation = await validateParentsBulk(parent_ids);
                if (validation)
                    return jsonResponse({ message: "parent_is_deleted", parent_ids: validation }, 409);
            }

            await supabase.rpc("sync_delete_entity", {
                main_table: table,
                main_id: entityId,
                center_id,
                children: tablesEntitiesIdsRemove,
                user_id,
                device_id,
                user_role: operation.user_role,
                main_updated_at: sendedTableRecord.updated_at
            });

            console.log(`[SYNC] Deleted ${entityId} with children`);
            return jsonResponse({ success: true });
        }

        // ==============================
        // 4️⃣ VERSION CONFLICT
        // ==============================
        if (version < serverTableRecord.version)
            return jsonResponse({ message: "version_conflict", server_record: serverTableRecord }, 409);

        // ==============================
        // 5️⃣ UPDATE
        // ==============================
        if (parent_ids) {
            const validation = await validateParentsBulk(parent_ids);
            if (validation) return jsonResponse({ message: "parent_is_deleted", parent_ids: validation }, 409);
        }

        const updatedRecord = {
            ...sendedTableRecord,
            version: serverTableRecord.version + 1,
            push_time: new Date().toISOString()
        };
        await upsertRecord(entityId, table, updatedRecord);

        console.log(`[SYNC] Updated ${entityId}`);
        return jsonResponse({ success: true });
    } catch (err) {

        function jsonResponse(data: any, status = 200) {
            return new Response(JSON.stringify(data), {
                status,
                headers: { "Content-Type": "application/json" },
            });
        }

        console.error("[SYNC ERROR]", err);
        return jsonResponse({ error: "internal_server_error", details: err.message }, 500);
    }
});
