-- Comentário para o Postgres reconhecer a extensão
-- pg_projection--1.0.sql

CREATE OR REPLACE FUNCTION pg_project(
    target jsonb,
    projection jsonb
) RETURNS jsonb AS $$
DECLARE
    result jsonb := '{}'::jsonb;
    key_text text;
    val_json jsonb;
    is_inclusion_mode boolean;
    has_id_explicit boolean := false;
    include_id boolean := true;
BEGIN
    -- MongoDB Logic: Se o primeiro campo (exceto _id) for 1, é inclusão. Se for 0, é exclusão.
    SELECT (value::text::int > 0) INTO is_inclusion_mode 
    FROM jsonb_each(projection) 
    WHERE key != '_id' LIMIT 1;

    -- Se a projeção for apenas {"_id": 0} ou {"_id": 1}
    IF is_inclusion_mode IS NULL THEN
        IF projection ? '_id' THEN
            is_inclusion_mode := (projection->>'_id')::int = 0; -- Se pedir 0, entra em modo exclusão de fato
        ELSE
            RETURN target;
        END IF;
    END IF;

    IF is_inclusion_mode THEN
        -- Começamos do vazio. _id é incluído por padrão a menos que seja {"_id": 0}
        IF (projection->>'_id')::int = 0 THEN
            include_id := false;
        END IF;

        FOR key_text, val_json IN SELECT * FROM jsonb_each(projection)
        LOOP
            IF key_text != '_id' AND (val_json::text::int > 0) AND target ? key_text THEN
                result := result || jsonb_build_object(key_text, target->key_text);
            END IF;
        END LOOP;

        IF include_id AND target ? '_id' THEN
            result := jsonb_build_object('_id', target->'_id') || result;
        END IF;

    ELSE
        result := target;
        FOR key_text, val_json IN SELECT * FROM jsonb_each(projection)
        LOOP
            IF (val_json::text::int = 0) THEN
                result := result - key_text;
            END IF;
        END LOOP;
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pg_project_set(
    query_text text,
    projection_json jsonb
) RETURNS jsonb AS $$
DECLARE
    final_array jsonb := '[]'::jsonb;
    row_data jsonb;
BEGIN
    FOR row_data IN EXECUTE format('SELECT to_jsonb(t) FROM (%s) t', query_text)
    LOOP
        final_array := final_array || pg_project(row_data, projection_json);
    END LOOP;
    
    RETURN final_array;
END;
$$ LANGUAGE plpgsql STABLE;