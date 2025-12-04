

-- DROP FUNCTION world.choose_terrain_based_on_neighbors(_int4, int4, int4, int4, int4, int4, int4);

CREATE OR REPLACE FUNCTION world.choose_terrain_based_on_neighbors(terrain_grid integer[], x integer, y integer, width integer, height integer, upper1 integer, lower1 integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    neighbor_terrain INT;
    neighbor_count INT := 0;
    terrain_counts JSONB := '{}'::JSONB;
    most_common_terrain INT;
    new_terrain INT;
BEGIN
    -- Sprawdź sąsiadów (lewy, górny, prawy, dolny)
    FOR dx IN -1..1 LOOP
        FOR dy IN -1..1 LOOP
            IF (dx = 0 AND dy = 0) THEN
                CONTINUE;
            END IF;

            IF x + dx >= 1 AND x + dx <= width AND y + dy >= 1 AND y + dy <= height THEN
                neighbor_terrain := terrain_grid[x + dx][y + dy];
                IF neighbor_terrain IS NOT NULL AND neighbor_terrain != 0 THEN
                    terrain_counts := jsonb_set(
                        terrain_counts,
                        ARRAY[neighbor_terrain::text],
                        (COALESCE((terrain_counts->>(neighbor_terrain::text))::int, 0) + 1)::text::jsonb,
                        true
                    );
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    -- Wybierz najczęściej występujący teren wśród sąsiadów
    most_common_terrain := (
        SELECT key::int
        FROM jsonb_each_text(terrain_counts)
        ORDER BY value::int DESC
        LIMIT 1
    );

    -- Z 80% prawdopodobieństwem wybierz najczęstszy teren, w przeciwnym razie losuj nowy
    IF random() < 0.8 AND most_common_terrain IS NOT NULL THEN
        RETURN most_common_terrain;
    ELSE
        -- Losuj nowy teren, upewniając się, że nie jest to 0
        LOOP
            new_terrain := floor((upper1 - lower1 + 1) * random() + lower1);
            EXIT WHEN new_terrain != 0;
        END LOOP;
        RETURN new_terrain;
    END IF;
END;
$function$
;







-- DROP PROCEDURE world.map_delete();

CREATE OR REPLACE PROCEDURE admin.map_delete()
 LANGUAGE plpgsql
AS $procedure$

BEGIN
TRUNCATE TABLE world.maps RESTART IDENTITY CASCADE;

TRUNCATE TABLE world.map_tiles RESTART IDENTITY CASCADE;
   
END;
$procedure$
;







-- DROP FUNCTION world.random_landscape_types(int4);

CREATE OR REPLACE FUNCTION world.random_landscape_types(terrain_type_id integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    random_value INT;
BEGIN

    IF random() < 0.33 THEN
       
        RETURN NULL;
    ELSE

        IF terrain_type_id = 1 THEN -- Plains
            SELECT landscape_type_id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Forest', 'Hills')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 2 THEN -- Grasslands
            SELECT landscape_type_id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Forest')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 3 THEN -- Shrubland
            SELECT landscape_type_id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Mountain', 'Volcano')
            ORDER BY log(random()) / landscape_type_id
            LIMIT 1;

        ELSIF terrain_type_id = 4 THEN -- Desert
            SELECT landscape_type_id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Dunes')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 5 THEN -- Marsh
            SELECT landscape_type_id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Swamp', 'Jungle')
            ORDER BY random()
            LIMIT 1;

        ELSE
            random_value := NULL;
        END IF;

        RETURN random_value;
    END IF;
END;
$function$
;













-- DROP PROCEDURE world.city_insert(int4, int4, varchar);

CREATE OR REPLACE PROCEDURE world.city_insert(IN p_map_tile_x integer, IN p_map_tile_y integer, IN p_map_name character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    new_city_id INT;
    width INT := 10;
    height INT := 10;
    
    countW INT := 1;
    countH INT := 1;

    p_terrain_type_id INT := (SELECT terrain_type_id FROM world.map_tiles WHERE X = p_map_tile_x AND Y = p_map_tile_y );

BEGIN

    INSERT INTO world.cities( map_tile_x, map_tile_y, name, move_cost, image_url)
    VALUES (p_map_tile_x, p_map_tile_y, p_map_name, 1, 'City_1.png')
    RETURNING id INTO new_city_id;

    WHILE countH <= width LOOP
        WHILE countW <= height LOOP

INSERT INTO world.city_tiles( city_id, x, y, terrain_type_id, landscape_type_id)
VALUES (new_city_id, countW, countH, p_terrain_type_id, NULL);

            countW := countW + 1;    
        END LOOP;
        
        countH := countH + 1;
        countW := 1;
    END LOOP;
END;
$procedure$
;












-- DROP PROCEDURE world.map_insert();

CREATE OR REPLACE PROCEDURE world.map_insert()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    new_map_id INT;
    width INT := 30;
    height INT := 30;
    
    countW INT := 1;
    countH INT := 1;

    upper1 INT := (SELECT MAX(id) FROM world.terrain_types);
    lower1 INT := 1;
    random1 INT := 1;
    random2 INT := NULL;

    terrain_grid INT[][] := array_fill(0, ARRAY[width, height]);
BEGIN

    INSERT INTO world.maps (name)
    VALUES ('NowaMapa')
    RETURNING id INTO new_map_id;

    WHILE countH <= width LOOP
        WHILE countW <= height LOOP

            IF countW = 1 AND countH = 1 THEN
                random1 := floor((upper1 - lower1 + 1) * random() + lower1);
            ELSE
               random1 := world.choose_terrain_based_on_neighbors(terrain_grid, countW, countH, width, height, upper1, lower1);
            END IF;

            --random1 := floor((upper1 - lower1 + 1) * random() + lower1);
                 terrain_grid[countW][countH] := random1;

            
            random2 := world.random_landscape_types(random1);

            INSERT INTO world.map_tiles (
                x,
                y,
                map_id,
                terrain_type_id,
                landscape_type_id
            ) VALUES (
                countW,
                countH,
                new_map_id,
                random1,
                random2
            );

        
            countW := countW + 1;    
        END LOOP;
        
        countH := countH + 1;
        countW := 1;
    END LOOP;
END;
$procedure$
;
