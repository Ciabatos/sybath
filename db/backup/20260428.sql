--
-- PostgreSQL database dump
--

\restrict HpcjojgdnyCeTCeaevKyezktex95GdwRdDVcydqJe2GEaARUsNgUYRI31KQqMpX

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-04-28 22:33:37

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 22415)
-- Name: admin; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA admin;


ALTER SCHEMA admin OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 22416)
-- Name: attributes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA attributes;


ALTER SCHEMA attributes OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 22417)
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 22418)
-- Name: buildings; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA buildings;


ALTER SCHEMA buildings OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 22419)
-- Name: cities; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA cities;


ALTER SCHEMA cities OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 22420)
-- Name: districts; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA districts;


ALTER SCHEMA districts OWNER TO postgres;

--
-- TOC entry 12 (class 2615 OID 22421)
-- Name: inventory; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA inventory;


ALTER SCHEMA inventory OWNER TO postgres;

--
-- TOC entry 13 (class 2615 OID 22422)
-- Name: items; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA items;


ALTER SCHEMA items OWNER TO postgres;

--
-- TOC entry 14 (class 2615 OID 22423)
-- Name: knowledge; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA knowledge;


ALTER SCHEMA knowledge OWNER TO postgres;

--
-- TOC entry 15 (class 2615 OID 22424)
-- Name: players; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA players;


ALTER SCHEMA players OWNER TO postgres;

--
-- TOC entry 19 (class 2615 OID 25546)
-- Name: squad; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA squad;


ALTER SCHEMA squad OWNER TO postgres;

--
-- TOC entry 16 (class 2615 OID 22425)
-- Name: tasks; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tasks;


ALTER SCHEMA tasks OWNER TO postgres;

--
-- TOC entry 17 (class 2615 OID 22426)
-- Name: util; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA util;


ALTER SCHEMA util OWNER TO postgres;

--
-- TOC entry 18 (class 2615 OID 22427)
-- Name: world; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA world;


ALTER SCHEMA world OWNER TO postgres;

--
-- TOC entry 1286 (class 1247 OID 484722)
-- Name: ct_other_player; Type: TYPE; Schema: world; Owner: postgres
--

CREATE TYPE world.ct_other_player AS (
	other_player_id text,
	image_map text,
	in_squad boolean
);


ALTER TYPE world.ct_other_player OWNER TO postgres;

--
-- TOC entry 5685 (class 0 OID 0)
-- Dependencies: 1286
-- Name: TYPE ct_other_player; Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON TYPE world.ct_other_player IS 'world.get_known_players_positions';


--
-- TOC entry 1289 (class 1247 OID 484733)
-- Name: ct_path; Type: TYPE; Schema: world; Owner: postgres
--

CREATE TYPE world.ct_path AS (
	"order" integer,
	map_id integer,
	x integer,
	y integer,
	total_move_cost integer
);


ALTER TYPE world.ct_path OWNER TO postgres;

--
-- TOC entry 5686 (class 0 OID 0)
-- Dependencies: 1289
-- Name: TYPE ct_path; Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON TYPE world.ct_path IS 'world.do_player_movement';


--
-- TOC entry 450 (class 1255 OID 22428)
-- Name: choose_terrain_based_on_neighbors(integer[], integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.choose_terrain_based_on_neighbors(terrain_grid integer[], x integer, y integer, width integer, height integer, upper1 integer, lower1 integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    neighbor_terrain INT;
    terrain_counts JSONB := '{}'::JSONB;
    most_common_terrain INT;
    new_terrain INT;
    river_chance FLOAT := 0.05;
    sea_chance FLOAT := 0.003;
    river_neighbor_count INT := 0;
    river_diagonal_count INT := 0;
    sea_neighbor_count INT := 0;
    river_next_to_sea BOOLEAN := FALSE;
    is_diagonal BOOLEAN;
BEGIN
    FOR dx IN -1..1 LOOP
        FOR dy IN -1..1 LOOP
            IF (dx = 0 AND dy = 0) THEN CONTINUE; END IF;

            IF x + dx >= 1 AND x + dx <= width AND y + dy >= 1 AND y + dy <= height THEN
                neighbor_terrain := terrain_grid[x + dx][y + dy];
                is_diagonal := (dx != 0 AND dy != 0);

                IF neighbor_terrain IS NOT NULL AND neighbor_terrain != 0 THEN
                    IF neighbor_terrain = 9 THEN
                        -- Rzeka: kierunki proste vs ukosy
                        IF NOT is_diagonal THEN
                            river_neighbor_count := river_neighbor_count + 1;
                        ELSE
                            river_diagonal_count := river_diagonal_count + 1;
                        END IF;
                    ELSIF neighbor_terrain = 8 THEN
                        -- Morze: licz wszystkie 8 kierunków
                        sea_neighbor_count := sea_neighbor_count + 1;
                    ELSE
                        terrain_counts := jsonb_set(
                            terrain_counts,
                            ARRAY[neighbor_terrain::text],
                            (COALESCE((terrain_counts->>(neighbor_terrain::text))::int, 0) + 1)::text::jsonb,
                            true
                        );
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    -- Sprawdź czy rzeka sąsiaduje z morzem (ujście rzeki)
    -- Szukamy: czy w sąsiedztwie jest i rzeka i morze
    IF river_neighbor_count > 0 AND sea_neighbor_count > 0 THEN
        river_next_to_sea := TRUE;
    END IF;

    -- === LOGIKA MORZA ===
    -- Morze rozlewa się szeroko (8 kierunków)
    IF sea_neighbor_count >= 3 THEN
        IF random() < 0.95 THEN RETURN 8; END IF;
    ELSIF sea_neighbor_count = 2 THEN
        IF random() < 0.55 THEN RETURN 8; END IF;
    ELSIF sea_neighbor_count = 1 THEN
        IF random() < 0.35 THEN RETURN 8; END IF;
    ELSIF sea_neighbor_count = 0 AND river_neighbor_count = 0 AND random() < sea_chance THEN
        -- Nowe morze tylko jeśli nie ma rzeki w pobliżu
        RETURN 8;
    END IF;

    -- === LOGIKA RZEKI ===
    -- Ujście: rzeka wpada do morza z dużą szansą
    IF river_next_to_sea THEN
        IF random() < 0.80 THEN RETURN 8; END IF; -- rzeka zamienia się w morze
    END IF;

    IF river_diagonal_count > 0 AND river_neighbor_count = 0 THEN
        NULL; -- blokuj rzekę przy ukośnym sąsiedzie bez prostego
    ELSE
        IF river_neighbor_count = 1 THEN
            IF random() < 0.50 THEN RETURN 9; END IF;
        ELSIF river_neighbor_count >= 2 THEN
            IF random() < 0.1 THEN RETURN 9; END IF;
        END IF;

        IF river_neighbor_count = 0 AND sea_neighbor_count = 0 AND random() < river_chance THEN
            RETURN 9;
        END IF;
    END IF;

    -- === ZWYKŁY TEREN ===
    most_common_terrain := (
        SELECT key::int
        FROM jsonb_each_text(terrain_counts)
        ORDER BY value::int DESC
        LIMIT 1
    );

    IF random() < 0.8 AND most_common_terrain IS NOT NULL THEN
        RETURN most_common_terrain;
    ELSE
        LOOP
            new_terrain := floor((upper1 - lower1 + 1) * random() + lower1);
            EXIT WHEN new_terrain != 0 AND new_terrain != 9 AND new_terrain != 8;
        END LOOP;
        RETURN new_terrain;
    END IF;
END;
$$;


ALTER FUNCTION admin.choose_terrain_based_on_neighbors(terrain_grid integer[], x integer, y integer, width integer, height integer, upper1 integer, lower1 integer) OWNER TO postgres;

--
-- TOC entry 379 (class 1255 OID 22429)
-- Name: city_insert(integer, integer, character varying); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.city_insert(IN p_map_tile_x integer, IN p_map_tile_y integer, IN p_map_name character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER PROCEDURE admin.city_insert(IN p_map_tile_x integer, IN p_map_tile_y integer, IN p_map_name character varying) OWNER TO postgres;

--
-- TOC entry 405 (class 1255 OID 22430)
-- Name: map_delete(); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.map_delete()
    LANGUAGE plpgsql
    AS $$

BEGIN
TRUNCATE TABLE world.map_tiles_map_regions RESTART IDENTITY CASCADE;
TRUNCATE TABLE world.map_regions RESTART IDENTITY CASCADE;
TRUNCATE TABLE world.map_tiles RESTART IDENTITY CASCADE;
TRUNCATE TABLE world.maps RESTART IDENTITY CASCADE;
   
END;
$$;


ALTER PROCEDURE admin.map_delete() OWNER TO postgres;

--
-- TOC entry 429 (class 1255 OID 22431)
-- Name: map_insert(); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.map_insert()
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_map_id INT;
    width INT := 60;
    height INT := 60;
    
    countW INT := 1;
    countH INT := 1;

    upper1 INT := (SELECT MAX(id) FROM world.terrain_types);
    lower1 INT := 1;
    random1 INT := 1;
    random2 INT := NULL;

    terrain_grid INT[][] := array_fill(0, ARRAY[width, height]);


    --------------------------------------------------
    -- regiony
    --------------------------------------------------
    assigned BOOLEAN[][] := array_fill(false, ARRAY[width, height]);

    region_id INT;
    region_size_target INT;
    region_size INT;

    cur_x INT;
    cur_y INT;

    fx INT[];
    fy INT[];

    base_x INT;
    base_y INT;

    nx INT;
    ny INT;

    pick INT;
    frontier_count INT;

    i INT;



BEGIN

    INSERT INTO world.maps (name)
    VALUES ('NowaMapa')
    RETURNING id INTO new_map_id;

    WHILE countH <= width LOOP
        WHILE countW <= height LOOP

            IF countW = 1 AND countH = 1 THEN
                random1 := floor((upper1 - lower1 + 1) * random() + lower1);
            ELSE
               random1 := admin.choose_terrain_based_on_neighbors(terrain_grid, countW, countH, width, height, upper1, lower1);
            END IF;

            terrain_grid[countW][countH] := random1;
            random2 := admin.random_landscape_types(random1);

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


  --------------------------------------------------
    -- tworzenie regionów
    --------------------------------------------------
FOR cur_y IN 1..height LOOP
    FOR cur_x IN 1..width LOOP
    
            IF terrain_grid[cur_x][cur_y] IN (8,9) THEN
                assigned[cur_x][cur_y] := true;
                CONTINUE;
            END IF;
    
            IF assigned[cur_x][cur_y] THEN
                CONTINUE;
            END IF;
            ------------------------------------------
            -- nowy region
            ------------------------------------------
            INSERT INTO world.map_regions
            ("name", region_type_id, image_outline, image_fill)
            VALUES(
                'Region'
                , 1
                ,'#9ca3af' --gray
                , NULL)
            RETURNING id INTO region_id;



            region_size_target := floor(random() * 3) + 8; -- 5..8
            region_size := 0;

            ------------------------------------------
            -- pierwszy tile
            ------------------------------------------
            assigned[cur_x][cur_y] := true;
            region_size := 1;

            INSERT INTO world.map_tiles_map_regions
                (region_id, map_id, map_tile_x, map_tile_y)
            VALUES
                (region_id, new_map_id, cur_x, cur_y);

            fx := ARRAY[cur_x];
            fy := ARRAY[cur_y];

            ------------------------------------------
            -- rozrastanie regionu
            ------------------------------------------
            WHILE region_size < region_size_target LOOP

                frontier_count := array_length(fx, 1);

                IF frontier_count IS NULL THEN
                    EXIT;
                END IF;

                pick := floor(random() * frontier_count + 1);

				base_x := fx[pick];
				base_y := fy[pick];
				
				fx := fx[1:pick-1] || fx[pick+1:array_length(fx,1)];
				fy := fy[1:pick-1] || fy[pick+1:array_length(fy,1)];

                --------------------------------------
                -- 4 sąsiadów
                --------------------------------------
                FOR i IN 1..4 LOOP

                    nx := base_x;
                    ny := base_y;

                    IF i = 1 THEN
                        nx := nx + 1;
                    ELSIF i = 2 THEN
                        nx := nx - 1;
                    ELSIF i = 3 THEN
                        ny := ny + 1;
                    ELSE
                        ny := ny - 1;
                    END IF;

                    IF nx < 1 OR nx > width OR ny < 1 OR ny > height THEN
                        CONTINUE;
                    END IF;

                    IF terrain_grid[nx][ny] IN (8,9) THEN
                        assigned[nx][ny] := true;
                        CONTINUE;
                    END IF;

                    IF assigned[nx][ny] THEN
                        CONTINUE;
                    END IF;

                    assigned[nx][ny] := true;
                    region_size := region_size + 1;

                    INSERT INTO world.map_tiles_map_regions
                        (region_id, map_id, map_tile_x, map_tile_y)
                    VALUES
                        (region_id, new_map_id, nx, ny);

                    fx := array_append(fx, nx);
                    fy := array_append(fy, ny);

                    EXIT WHEN region_size >= region_size_target;

                END LOOP;

            END LOOP;

        END LOOP;
    END LOOP;


CALL "admin".map_tiles_resources_random_spawn(new_map_id);

END;
$$;


ALTER PROCEDURE admin.map_insert() OWNER TO postgres;

--
-- TOC entry 396 (class 1255 OID 271624)
-- Name: map_tiles_resources_random_spawn(integer); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.map_tiles_resources_random_spawn(IN p_map_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO world.map_tiles_resources (
        map_id,
        map_tile_x,
        map_tile_y,
        item_id,
        quantity
    )
    SELECT
        mt.map_id,
        mt.x,
        mt.y,
        cfg.item_id,

        -- losowanie ilości
        FLOOR(
            random() * (cfg.max_quantity - cfg.min_quantity + 1)
            + cfg.min_quantity
        )::INT AS quantity

    FROM world.map_tiles mt

    JOIN world.map_tiles_resources_spawn cfg
        ON cfg.terrain_type_id = mt.terrain_type_id
        AND cfg.landscape_type_id = mt.landscape_type_id
        

    WHERE mt.map_id = p_map_id

    -- spawn chance
    AND random() <= cfg.spawn_chance;

END;
$$;


ALTER PROCEDURE admin.map_tiles_resources_random_spawn(IN p_map_id integer) OWNER TO postgres;

--
-- TOC entry 440 (class 1255 OID 22432)
-- Name: new_player(integer, character varying, character varying); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.new_player(IN p_user_id integer, IN p_name character varying, IN p_second_name character varying)
    LANGUAGE plpgsql
    AS $$

DECLARE
p_player_id int;
p_is_active boolean;

BEGIN

SELECT NOT EXISTS (
    SELECT 1
    FROM players.players
    WHERE user_id = p_user_id
)
INTO p_is_active;

INSERT INTO players.players
(user_id, "name", image_map, image_portrait, is_active, second_name, nickname)
VALUES(p_user_id, p_name, 'default.png'::character varying, 'default.png'::character varying, p_is_active, p_second_name, NULL)
  RETURNING id INTO p_player_id;

INSERT INTO world.map_tiles_players_positions
(player_id, map_id, map_tile_x, map_tile_y)
VALUES(p_player_id, 1, floor(random() * 3) + 5, floor(random() * 3) + 5);

INSERT INTO "attributes".player_stats
(player_id, stat_id, value)
SELECT 
p_player_id
,T1.id
,floor(random() * 10 + 1)::int
FROM "attributes".stats T1;

INSERT INTO "attributes".player_skills
(player_id, skill_id, value)
SELECT 
p_player_id
,T1.id
,floor(random() * 10 + 1)::int
FROM "attributes".skills T1;

PERFORM attributes.unlock_player_abilities(p_player_id);

PERFORM inventory.add_inventory_container('player', p_player_id);

PERFORM inventory.add_inventory_container_player_access_to_user(p_player_id);

PERFORM "admin".new_player_knowledge(p_user_id, p_player_id);


END;
$$;


ALTER PROCEDURE admin.new_player(IN p_user_id integer, IN p_name character varying, IN p_second_name character varying) OWNER TO postgres;

--
-- TOC entry 370 (class 1255 OID 435409)
-- Name: new_player_knowledge(integer, integer); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.new_player_knowledge(p_user_id integer, p_player_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    
INSERT INTO knowledge.known_map_tiles
(player_id, map_id, map_tile_x, map_tile_y)
SELECT p_player_id, map_id, x, y
FROM world.map_tiles
WHERE X <= 15 AND Y <= 15;
    
INSERT INTO knowledge.known_players_positions
(player_id, other_player_id)
SELECT
p_player_id
,id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_positions
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_profiles
(player_id, other_player_id)
SELECT
p_player_id
,id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_profiles
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_stats
(player_id, other_player_id)
SELECT
p_player_id
,id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_stats
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_skills
(player_id, other_player_id)
SELECT
p_player_id
,id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_skills
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_abilities
(player_id, other_player_id)
SELECT
p_player_id
,id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;

INSERT INTO knowledge.known_players_abilities
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
ON CONFLICT DO NOTHING;  

INSERT INTO knowledge.known_players_containers
(player_id, container_id)
SELECT 
p2.id 
,ic.id 
FROM inventory.inventory_containers ic
JOIN players.players p2 ON 1 = 1
WHERE ic.inventory_container_type_id IN (1,2)
AND ic.owner_id IN ( SELECT id FROM players.players p WHERE p.user_id = p_user_id)
AND p2.user_id = p_user_id
ON CONFLICT DO NOTHING;

    
END;
$$;


ALTER FUNCTION admin.new_player_knowledge(p_user_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 474 (class 1255 OID 22433)
-- Name: random_landscape_types(integer); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.random_landscape_types(terrain_type_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    random_value INT;
BEGIN

    IF random() < 0.33 THEN
       
        RETURN NULL;
    ELSE

        IF terrain_type_id = 1 THEN -- Plains
            SELECT id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Forest', 'Hills')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 2 THEN -- Grasslands
            SELECT id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Forest')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 3 THEN -- Shrubland
            SELECT id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Mountain', 'Volcano')
            ORDER BY log(random()) / id
            LIMIT 1;

        ELSIF terrain_type_id = 4 THEN -- Desert
            SELECT id INTO random_value
            FROM world.landscape_types
            WHERE name IN ('Dunes')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 5 THEN -- Marsh
            SELECT id INTO random_value
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
$$;


ALTER FUNCTION admin.random_landscape_types(terrain_type_id integer) OWNER TO postgres;

--
-- TOC entry 430 (class 1255 OID 22434)
-- Name: reset_all(); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.reset_all()
    LANGUAGE plpgsql
    AS $$
BEGIN

CALL "admin".map_delete();
TRUNCATE TABLE  players.players 					RESTART IDENTITY CASCADE;
TRUNCATE TABLE  world.map_tiles_players_positions RESTART IDENTITY CASCADE;
TRUNCATE TABLE  "attributes".player_stats     	RESTART IDENTITY CASCADE;
TRUNCATE TABLE  "attributes".player_skills     	RESTART IDENTITY CASCADE;
TRUNCATE TABLE  "attributes".player_abilities  	   RESTART IDENTITY CASCADE;
TRUNCATE TABLE  inventory.inventory_containers     RESTART IDENTITY CASCADE;
TRUNCATE TABLE  inventory.inventory_slots           RESTART IDENTITY CASCADE;
TRUNCATE TABLE inventory.inventory_container_player_access RESTART IDENTITY CASCADE;
TRUNCATE TABLE  tasks.tasks          RESTART IDENTITY CASCADE;
TRUNCATE TABLE	knowledge.known_map_tiles RESTART IDENTITY CASCADE;
TRUNCATE TABLE knowledge.known_players_positions RESTART IDENTITY CASCADE;
TRUNCATE TABLE world.map_tiles_resources RESTART IDENTITY CASCADE;


CALL "admin".map_insert();
CALL "admin".new_player(1, 'Ciabat', 'Ciabatos');
CALL "admin".new_player(1, 'Pawlak', 'Ciabatos');
CALL "admin".new_player(1, 'Jachuren', 'Koczkodanen');
CALL "admin".new_player(1, 'Ziomo', 'Fotono');

    RAISE NOTICE 'All have been truncated and reset';
END;
$$;


ALTER PROCEDURE admin.reset_all() OWNER TO postgres;

--
-- TOC entry 363 (class 1255 OID 22435)
-- Name: add_player_ability(integer, integer, integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.add_player_ability(p_player_id integer, p_ability_id integer, p_value integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    INSERT INTO attributes.player_abilities(player_id, ability_id, value)
    VALUES (p_player_id, p_ability_id, p_value);
    RETURN QUERY SELECT true, FORMAT('Added ability %s to player %s', p_ability_id, p_player_id);
EXCEPTION WHEN unique_violation THEN
    RETURN QUERY SELECT false, FORMAT('Player %s already has ability %s', p_player_id, p_ability_id);

END;
$$;


ALTER FUNCTION attributes.add_player_ability(p_player_id integer, p_ability_id integer, p_value integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 233 (class 1259 OID 22436)
-- Name: abilities; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.abilities (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    image character varying(255) DEFAULT 'default.png'::character varying NOT NULL
);


ALTER TABLE attributes.abilities OWNER TO postgres;

--
-- TOC entry 459 (class 1255 OID 22444)
-- Name: get_abilities(); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_abilities() RETURNS SETOF attributes.abilities
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.abilities;
      END;
      $$;


ALTER FUNCTION attributes.get_abilities() OWNER TO postgres;

--
-- TOC entry 5687 (class 0 OID 0)
-- Dependencies: 459
-- Name: FUNCTION get_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities() IS 'automatic_get_api';


--
-- TOC entry 336 (class 1255 OID 22445)
-- Name: get_abilities_by_key(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_abilities_by_key(p_id integer) RETURNS SETOF attributes.abilities
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.abilities
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION attributes.get_abilities_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5688 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION get_abilities_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 390 (class 1255 OID 287895)
-- Name: get_abilities_by_key(character varying); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_abilities_by_key(p_name character varying) RETURNS SETOF attributes.abilities
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.abilities
          WHERE "name" = p_name;
      END;
      $$;


ALTER FUNCTION attributes.get_abilities_by_key(p_name character varying) OWNER TO postgres;

--
-- TOC entry 5689 (class 0 OID 0)
-- Dependencies: 390
-- Name: FUNCTION get_abilities_by_key(p_name character varying); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_name character varying) IS 'automatic_get_api';


--
-- TOC entry 359 (class 1255 OID 353472)
-- Name: get_all_abilities(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_all_abilities(p_player_id integer) RETURNS TABLE(id integer, name character varying, description character varying, image character varying, value integer)
    LANGUAGE plpgsql
    AS $$
      BEGIN

          RETURN QUERY
        SELECT 
        T1.id
        ,T1."name" 
        ,T1.description 
        ,T1.image 
        ,COALESCE(T2.value,0) AS value
        FROM attributes.abilities T1
        LEFT JOIN attributes.player_abilities T2 ON T1.id = T2.ability_id 
                                                AND T2.player_id = p_player_id;

      END;
      $$;


ALTER FUNCTION attributes.get_all_abilities(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5690 (class 0 OID 0)
-- Dependencies: 359
-- Name: FUNCTION get_all_abilities(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_all_abilities(p_player_id integer) IS 'get_api';


--
-- TOC entry 435 (class 1255 OID 353475)
-- Name: get_all_skills(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_all_skills(p_player_id integer) RETURNS TABLE(id integer, name character varying, description character varying, image character varying, value integer)
    LANGUAGE plpgsql
    AS $$
      BEGIN

          RETURN QUERY
        SELECT 
        T1.id
        ,T1."name" 
        ,T1.description 
        ,T1.image 
        ,COALESCE(T2.value,0) AS value
        FROM "attributes".skills T1
        LEFT JOIN "attributes".player_skills T2 ON T1.id = T2.skill_id  
        AND T2.player_id = p_player_id;

      END;
      $$;


ALTER FUNCTION attributes.get_all_skills(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5691 (class 0 OID 0)
-- Dependencies: 435
-- Name: FUNCTION get_all_skills(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_all_skills(p_player_id integer) IS 'get_api';


--
-- TOC entry 470 (class 1255 OID 25614)
-- Name: get_other_player_abilities(integer, text); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_other_player_abilities(p_player_id integer, p_other_player_id text) RETURNS TABLE(ability_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

 RETURN QUERY
 SELECT 
    t1.ability_id,
    t1.value,
    t2.name
   FROM players.players p
   JOIN attributes.player_abilities t1 ON p.id = t1.player_id
   JOIN knowledge.known_players_abilities kpa ON kpa.player_id = p_player_id
                                          AND kpa.other_player_id = t1.player_id
     JOIN attributes.abilities t2 ON t1.ability_id = t2.id
WHERE p.id = players.get_real_player_id(p_other_player_id)
ORDER BY t1.id;

END;

$$;


ALTER FUNCTION attributes.get_other_player_abilities(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5692 (class 0 OID 0)
-- Dependencies: 470
-- Name: FUNCTION get_other_player_abilities(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_abilities(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 365 (class 1255 OID 25613)
-- Name: get_other_player_skills(integer, text); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_other_player_skills(p_player_id integer, p_other_player_id text) RETURNS TABLE(skill_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

 RETURN QUERY
 SELECT 
    t1.skill_id,
    t1.value,
    t2.name
   FROM players.players p
   JOIN attributes.player_skills t1 ON p.id = t1.player_id
   JOIN knowledge.known_players_skills kps ON kps.player_id = p_player_id
                                          AND kps.other_player_id = t1.player_id
     JOIN attributes.skills t2 ON t1.skill_id = t2.id
WHERE p.id = players.get_real_player_id(p_other_player_id)
ORDER BY t1.id;
    
END;
$$;


ALTER FUNCTION attributes.get_other_player_skills(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5693 (class 0 OID 0)
-- Dependencies: 365
-- Name: FUNCTION get_other_player_skills(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_skills(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 376 (class 1255 OID 25612)
-- Name: get_other_player_stats(integer, text); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_other_player_stats(p_player_id integer, p_other_player_id text) RETURNS TABLE(stat_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

 RETURN QUERY
 SELECT 
    t1.stat_id,
    t1.value,
    t2.name
   FROM players.players p
   JOIN attributes.player_stats t1 ON p.id = t1.player_id
   JOIN knowledge.known_players_stats kps ON kps.player_id = p_player_id
                                          AND kps.other_player_id = t1.player_id
   JOIN attributes.stats t2 ON t1.stat_id = t2.id
WHERE p.id = players.get_real_player_id(p_other_player_id)
ORDER BY t1.id;

END;

$$;


ALTER FUNCTION attributes.get_other_player_stats(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5694 (class 0 OID 0)
-- Dependencies: 376
-- Name: FUNCTION get_other_player_stats(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_stats(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 340 (class 1255 OID 22454)
-- Name: get_player_abilities(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_player_abilities(p_player_id integer) RETURNS TABLE(ability_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

 RETURN QUERY
 SELECT 
    t1.ability_id,
    t1.value,
    t2.name
   FROM attributes.player_abilities t1
     JOIN attributes.abilities t2 ON t1.ability_id = t2.id
  WHERE t1.player_id = p_player_id
    ORDER BY t1.id;
END;

$$;


ALTER FUNCTION attributes.get_player_abilities(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5695 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION get_player_abilities(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities(p_player_id integer) IS 'get_api';


--
-- TOC entry 385 (class 1255 OID 22456)
-- Name: get_player_skills(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_player_skills(p_player_id integer) RETURNS TABLE(skill_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

 RETURN QUERY
 SELECT 
    t1.skill_id,
    t1.value,
    t2.name
   FROM attributes.player_skills t1
     JOIN attributes.skills t2 ON t1.skill_id = t2.id
   WHERE t1.player_id = p_player_id
    ORDER BY t1.id;
    
END;
$$;


ALTER FUNCTION attributes.get_player_skills(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5696 (class 0 OID 0)
-- Dependencies: 385
-- Name: FUNCTION get_player_skills(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_skills(p_player_id integer) IS 'get_api';


--
-- TOC entry 344 (class 1255 OID 22457)
-- Name: get_player_stats(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_player_stats(p_player_id integer) RETURNS TABLE(stat_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

 RETURN QUERY
 SELECT 
    t1.stat_id,
    t1.value,
    t2.name
   FROM attributes.player_stats t1
     JOIN attributes.stats t2 ON t1.stat_id = t2.id
  WHERE t1.player_id = p_player_id
    ORDER BY t1.id;
END;

$$;


ALTER FUNCTION attributes.get_player_stats(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5697 (class 0 OID 0)
-- Dependencies: 344
-- Name: FUNCTION get_player_stats(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_stats(p_player_id integer) IS 'get_api';


--
-- TOC entry 235 (class 1259 OID 22458)
-- Name: roles; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.roles (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE attributes.roles OWNER TO postgres;

--
-- TOC entry 342 (class 1255 OID 22462)
-- Name: get_roles(); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_roles() RETURNS SETOF attributes.roles
    LANGUAGE plpgsql
    AS $$
      BEGIN
          RETURN QUERY
          SELECT * FROM attributes.roles;
      END;
      $$;


ALTER FUNCTION attributes.get_roles() OWNER TO postgres;

--
-- TOC entry 5698 (class 0 OID 0)
-- Dependencies: 342
-- Name: FUNCTION get_roles(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles() IS 'automatic_get_api';


--
-- TOC entry 433 (class 1255 OID 22463)
-- Name: get_roles_by_key(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_roles_by_key(p_id integer) RETURNS SETOF attributes.roles
    LANGUAGE plpgsql
    AS $$
      BEGIN
          RETURN QUERY
          SELECT * FROM attributes.roles
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION attributes.get_roles_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5699 (class 0 OID 0)
-- Dependencies: 433
-- Name: FUNCTION get_roles_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 236 (class 1259 OID 22464)
-- Name: skills; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.skills (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    image character varying(255) DEFAULT 'default.png'::character varying NOT NULL
);


ALTER TABLE attributes.skills OWNER TO postgres;

--
-- TOC entry 350 (class 1255 OID 22472)
-- Name: get_skills(); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_skills() RETURNS SETOF attributes.skills
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.skills;
      END;
      $$;


ALTER FUNCTION attributes.get_skills() OWNER TO postgres;

--
-- TOC entry 5700 (class 0 OID 0)
-- Dependencies: 350
-- Name: FUNCTION get_skills(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills() IS 'automatic_get_api';


--
-- TOC entry 403 (class 1255 OID 22473)
-- Name: get_skills_by_key(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_skills_by_key(p_id integer) RETURNS SETOF attributes.skills
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.skills
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION attributes.get_skills_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5701 (class 0 OID 0)
-- Dependencies: 403
-- Name: FUNCTION get_skills_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 237 (class 1259 OID 22474)
-- Name: stats; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.stats (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    image character varying(255) DEFAULT 'default.png'::character varying NOT NULL
);


ALTER TABLE attributes.stats OWNER TO postgres;

--
-- TOC entry 419 (class 1255 OID 22482)
-- Name: get_stats(); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_stats() RETURNS SETOF attributes.stats
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.stats;
      END;
      $$;


ALTER FUNCTION attributes.get_stats() OWNER TO postgres;

--
-- TOC entry 5702 (class 0 OID 0)
-- Dependencies: 419
-- Name: FUNCTION get_stats(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats() IS 'automatic_get_api';


--
-- TOC entry 445 (class 1255 OID 22483)
-- Name: get_stats_by_key(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_stats_by_key(p_id integer) RETURNS SETOF attributes.stats
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.stats
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION attributes.get_stats_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5703 (class 0 OID 0)
-- Dependencies: 445
-- Name: FUNCTION get_stats_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 348 (class 1255 OID 22484)
-- Name: player_unlocked_abilities(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.player_unlocked_abilities(p_player_id integer) RETURNS TABLE(ability_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
		    SELECT DISTINCT a.id
		FROM attributes.abilities a
		WHERE NOT EXISTS (
		
		    -- skill requirements, które NIE są spełnione
		    SELECT 1
		    FROM attributes.ability_skill_requirements r
		    LEFT JOIN attributes.player_skills ps
		           ON ps.skill_id = r.skill_id
		          AND ps.player_id = p_player_id
		    WHERE r.ability_id = a.id
		      AND ps.value < r.min_value
		
		)
		AND NOT EXISTS (
		
		    -- stat requirements, które NIE są spełnione
		    SELECT 1
		    FROM attributes.ability_stat_requirements r
		    LEFT JOIN attributes.player_stats ps
		           ON ps.stat_id = r.stat_id
		          AND ps.player_id = p_player_id
		    WHERE r.ability_id = a.id
		      AND ps.value < r.min_value
		
		);

END;
$$;


ALTER FUNCTION attributes.player_unlocked_abilities(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 455 (class 1255 OID 22485)
-- Name: unlock_player_abilities(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.unlock_player_abilities(p_player_id integer) RETURNS TABLE(status boolean, message text, ability_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ability_id INTEGER;
BEGIN

    FOR v_ability_id IN
        SELECT t1.ability_id FROM attributes.player_unlocked_abilities(p_player_id) t1
    LOOP
        RETURN QUERY
        SELECT  a.status, a.message, v_ability_id
        FROM attributes.add_player_ability(
            p_player_id := p_player_id,
            p_ability_id := v_ability_id,
            p_value := 1
        ) AS a;
    END LOOP;

END;
$$;


ALTER FUNCTION attributes.unlock_player_abilities(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 428 (class 1255 OID 22486)
-- Name: insert_user(text, text); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.insert_user(p_email text, p_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO auth.users (email, password)
  VALUES (p_email, p_password);
END;
$$;


ALTER FUNCTION auth.insert_user(p_email text, p_password text) OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 22487)
-- Name: building_types; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    image_url character varying(255)
);


ALTER TABLE buildings.building_types OWNER TO postgres;

--
-- TOC entry 434 (class 1255 OID 22492)
-- Name: get_building_types(); Type: FUNCTION; Schema: buildings; Owner: postgres
--

CREATE FUNCTION buildings.get_building_types() RETURNS SETOF buildings.building_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM buildings.building_types;
      END;
      $$;


ALTER FUNCTION buildings.get_building_types() OWNER TO postgres;

--
-- TOC entry 5704 (class 0 OID 0)
-- Dependencies: 434
-- Name: FUNCTION get_building_types(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types() IS 'automatic_get_api';


--
-- TOC entry 421 (class 1255 OID 22493)
-- Name: get_building_types_by_key(integer); Type: FUNCTION; Schema: buildings; Owner: postgres
--

CREATE FUNCTION buildings.get_building_types_by_key(p_id integer) RETURNS SETOF buildings.building_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM buildings.building_types
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION buildings.get_building_types_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5705 (class 0 OID 0)
-- Dependencies: 421
-- Name: FUNCTION get_building_types_by_key(p_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 239 (class 1259 OID 22494)
-- Name: buildings; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.buildings (
    id integer NOT NULL,
    city_id integer NOT NULL,
    city_tile_x integer NOT NULL,
    city_tile_y integer NOT NULL,
    building_type_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE buildings.buildings OWNER TO postgres;

--
-- TOC entry 457 (class 1255 OID 22503)
-- Name: get_buildings(); Type: FUNCTION; Schema: buildings; Owner: postgres
--

CREATE FUNCTION buildings.get_buildings() RETURNS SETOF buildings.buildings
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM buildings.buildings;
      END;
      $$;


ALTER FUNCTION buildings.get_buildings() OWNER TO postgres;

--
-- TOC entry 5706 (class 0 OID 0)
-- Dependencies: 457
-- Name: FUNCTION get_buildings(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings() IS 'automatic_get_api';


--
-- TOC entry 402 (class 1255 OID 22504)
-- Name: get_buildings_by_key(integer); Type: FUNCTION; Schema: buildings; Owner: postgres
--

CREATE FUNCTION buildings.get_buildings_by_key(p_city_id integer) RETURNS SETOF buildings.buildings
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM buildings.buildings
          WHERE "city_id" = p_city_id;
      END;
      $$;


ALTER FUNCTION buildings.get_buildings_by_key(p_city_id integer) OWNER TO postgres;

--
-- TOC entry 5707 (class 0 OID 0)
-- Dependencies: 402
-- Name: FUNCTION get_buildings_by_key(p_city_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 240 (class 1259 OID 22505)
-- Name: cities; Type: TABLE; Schema: cities; Owner: postgres
--

CREATE TABLE cities.cities (
    id integer NOT NULL,
    map_id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE cities.cities OWNER TO postgres;

--
-- TOC entry 441 (class 1255 OID 22514)
-- Name: get_cities(); Type: FUNCTION; Schema: cities; Owner: postgres
--

CREATE FUNCTION cities.get_cities() RETURNS SETOF cities.cities
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM cities.cities;
      END;
      $$;


ALTER FUNCTION cities.get_cities() OWNER TO postgres;

--
-- TOC entry 5708 (class 0 OID 0)
-- Dependencies: 441
-- Name: FUNCTION get_cities(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities() IS 'automatic_get_api';


--
-- TOC entry 464 (class 1255 OID 22515)
-- Name: get_cities_by_key(integer); Type: FUNCTION; Schema: cities; Owner: postgres
--

CREATE FUNCTION cities.get_cities_by_key(p_map_id integer) RETURNS SETOF cities.cities
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM cities.cities
          WHERE "map_id" = p_map_id;
      END;
      $$;


ALTER FUNCTION cities.get_cities_by_key(p_map_id integer) OWNER TO postgres;

--
-- TOC entry 5709 (class 0 OID 0)
-- Dependencies: 464
-- Name: FUNCTION get_cities_by_key(p_map_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 241 (class 1259 OID 22516)
-- Name: city_tiles; Type: TABLE; Schema: cities; Owner: postgres
--

CREATE TABLE cities.city_tiles (
    city_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    terrain_type_id integer DEFAULT 1 NOT NULL,
    landscape_type_id integer
);


ALTER TABLE cities.city_tiles OWNER TO postgres;

--
-- TOC entry 399 (class 1255 OID 22524)
-- Name: get_city_tiles(); Type: FUNCTION; Schema: cities; Owner: postgres
--

CREATE FUNCTION cities.get_city_tiles() RETURNS SETOF cities.city_tiles
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM cities.city_tiles;
      END;
      $$;


ALTER FUNCTION cities.get_city_tiles() OWNER TO postgres;

--
-- TOC entry 5710 (class 0 OID 0)
-- Dependencies: 399
-- Name: FUNCTION get_city_tiles(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles() IS 'automatic_get_api';


--
-- TOC entry 382 (class 1255 OID 22525)
-- Name: get_city_tiles_by_key(integer); Type: FUNCTION; Schema: cities; Owner: postgres
--

CREATE FUNCTION cities.get_city_tiles_by_key(p_city_id integer) RETURNS SETOF cities.city_tiles
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM cities.city_tiles
          WHERE "city_id" = p_city_id;
      END;
      $$;


ALTER FUNCTION cities.get_city_tiles_by_key(p_city_id integer) OWNER TO postgres;

--
-- TOC entry 5711 (class 0 OID 0)
-- Dependencies: 382
-- Name: FUNCTION get_city_tiles_by_key(p_city_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 371 (class 1255 OID 22526)
-- Name: get_player_city(integer); Type: FUNCTION; Schema: cities; Owner: postgres
--

CREATE FUNCTION cities.get_player_city(p_player_id integer) RETURNS TABLE(city_id integer)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
          SELECT  T3.id AS city_id 
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            JOIN cities.cities T3 ON T1.map_id = T3.map_id
                                  AND T1.map_tile_x = T3.map_tile_x 
                                  AND T1.map_tile_y = T3.map_tile_y 
            WHERE T1.player_id = p_player_id;
      END;
      $$;


ALTER FUNCTION cities.get_player_city(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5712 (class 0 OID 0)
-- Dependencies: 371
-- Name: FUNCTION get_player_city(p_player_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_player_city(p_player_id integer) IS 'get_api';


--
-- TOC entry 242 (class 1259 OID 22527)
-- Name: district_types; Type: TABLE; Schema: districts; Owner: postgres
--

CREATE TABLE districts.district_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE districts.district_types OWNER TO postgres;

--
-- TOC entry 417 (class 1255 OID 22533)
-- Name: get_district_types(); Type: FUNCTION; Schema: districts; Owner: postgres
--

CREATE FUNCTION districts.get_district_types() RETURNS SETOF districts.district_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM districts.district_types;
      END;
      $$;


ALTER FUNCTION districts.get_district_types() OWNER TO postgres;

--
-- TOC entry 5713 (class 0 OID 0)
-- Dependencies: 417
-- Name: FUNCTION get_district_types(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types() IS 'automatic_get_api';


--
-- TOC entry 453 (class 1255 OID 22534)
-- Name: get_district_types_by_key(integer); Type: FUNCTION; Schema: districts; Owner: postgres
--

CREATE FUNCTION districts.get_district_types_by_key(p_id integer) RETURNS SETOF districts.district_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM districts.district_types
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION districts.get_district_types_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5714 (class 0 OID 0)
-- Dependencies: 453
-- Name: FUNCTION get_district_types_by_key(p_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 243 (class 1259 OID 22535)
-- Name: districts; Type: TABLE; Schema: districts; Owner: postgres
--

CREATE TABLE districts.districts (
    id integer NOT NULL,
    map_id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL,
    district_type_id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE districts.districts OWNER TO postgres;

--
-- TOC entry 422 (class 1255 OID 22543)
-- Name: get_districts(); Type: FUNCTION; Schema: districts; Owner: postgres
--

CREATE FUNCTION districts.get_districts() RETURNS SETOF districts.districts
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM districts.districts;
      END;
      $$;


ALTER FUNCTION districts.get_districts() OWNER TO postgres;

--
-- TOC entry 5715 (class 0 OID 0)
-- Dependencies: 422
-- Name: FUNCTION get_districts(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts() IS 'automatic_get_api';


--
-- TOC entry 366 (class 1255 OID 22544)
-- Name: get_districts_by_key(integer); Type: FUNCTION; Schema: districts; Owner: postgres
--

CREATE FUNCTION districts.get_districts_by_key(p_map_id integer) RETURNS SETOF districts.districts
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM districts.districts
          WHERE "map_id" = p_map_id;
      END;
      $$;


ALTER FUNCTION districts.get_districts_by_key(p_map_id integer) OWNER TO postgres;

--
-- TOC entry 5716 (class 0 OID 0)
-- Dependencies: 366
-- Name: FUNCTION get_districts_by_key(p_map_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 360 (class 1255 OID 353444)
-- Name: add_inventory_container(text, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer DEFAULT 9) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    p_container_id INT;
    p_player_gear_size INT;
    p_inventory_container_type_id INT;
BEGIN


    IF  p_owner_type != 'player' 
    AND p_owner_type != 'building' 
    AND p_owner_type != 'district'  THEN
        PERFORM util.raise_error('Not correct type');
END IF;


    IF p_owner_type = 'player' THEN p_inventory_container_type_id := 1;
    ELSIF p_owner_type = 'building' THEN p_inventory_container_type_id := 3;
    ELSIF p_owner_type = 'district' THEN p_inventory_container_type_id := 4;
    END IF;


        INSERT INTO inventory.inventory_containers (inventory_size, inventory_container_type_id, owner_id)
        VALUES (p_inventory_size, p_inventory_container_type_id, p_owner_id)
        RETURNING id INTO p_container_id;

    FOR x IN 1..p_inventory_size LOOP
            INSERT INTO inventory.inventory_slots (inventory_container_id,inventory_slot_type_id)
            VALUES (p_container_id, 1);
        END LOOP;



IF p_owner_type = 'player' THEN

     p_player_gear_size := (SELECT count(*) FROM inventory.inventory_slot_types ist WHERE ist.id NOT IN (1));

        INSERT INTO inventory.inventory_containers (inventory_size, inventory_container_type_id, owner_id)
        VALUES (p_player_gear_size, 2, p_owner_id)
        RETURNING id INTO p_container_id;

            INSERT INTO inventory.inventory_slots(inventory_container_id, item_id, quantity, inventory_slot_type_id)
                SELECT
                    p_container_id,
                    NULL,
                    NULL,
                    ist.id
                FROM inventory.inventory_slot_types ist
                WHERE ist.id NOT IN (1);

END IF;

PERFORM inventory.add_inventory_container_player_access_to_user(p_owner_id);


END;
$$;


ALTER FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer) OWNER TO postgres;

--
-- TOC entry 446 (class 1255 OID 288322)
-- Name: add_inventory_container_player_access_to_user(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.add_inventory_container_player_access_to_user(p_player_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

INSERT INTO inventory.inventory_container_player_access(inventory_container_id, player_id)
SELECT
T2.id 
,T1.id
FROM players.players T1
JOIN inventory.inventory_containers T2 ON 1=1
WHERE T1.user_id = (SELECT p.user_id FROM players.players p WHERE p.id = p_player_id)
ON CONFLICT DO NOTHING;

END;
$$;


ALTER FUNCTION inventory.add_inventory_container_player_access_to_user(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 456 (class 1255 OID 353457)
-- Name: add_item_to_inventory(integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    next_slot_id int;
BEGIN

PERFORM items.check_item_exists(p_item_id);
PERFORM items.check_quantity_positive(p_quantity);
PERFORM inventory.check_inventory_container_exists(p_inventory_container_id);
PERFORM inventory.check_free_inventory_slots(p_inventory_container_id);

    SELECT id INTO next_slot_id
    FROM inventory.inventory_slots
    WHERE inventory_container_id = p_inventory_container_id
      AND item_id IS NULL
    ORDER BY id
    LIMIT 1;


    UPDATE inventory.inventory_slots
    SET item_id = p_item_id,
        quantity = COALESCE(quantity,0)+p_quantity
    WHERE id = next_slot_id;

END;
$$;


ALTER FUNCTION inventory.add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) OWNER TO postgres;

--
-- TOC entry 469 (class 1255 OID 353456)
-- Name: add_item_to_player_inventory(integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_container_id integer;
    next_slot_id int;
BEGIN

PERFORM items.check_item_exists(p_item_id);
PERFORM items.check_quantity_positive(p_quantity);
SELECT inventory.player_inventory_container(p_player_id) INTO v_container_id;
PERFORM inventory.check_free_inventory_slots(v_container_id);
PERFORM inventory.check_inventory_container_exists(v_container_id);

    SELECT id INTO next_slot_id
    FROM inventory.inventory_slots
    WHERE inventory_container_id = v_container_id
      AND item_id IS NULL
    ORDER BY id
    LIMIT 1;


    UPDATE inventory.inventory_slots
    SET item_id = p_item_id,
        quantity = COALESCE(quantity,0)+p_quantity
    WHERE id = next_slot_id;

END;
$$;


ALTER FUNCTION inventory.add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer) OWNER TO postgres;

--
-- TOC entry 468 (class 1255 OID 22547)
-- Name: check_free_inventory_slots(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.check_free_inventory_slots(p_inventory_container_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.inventory_slots WHERE inventory_container_id = p_inventory_container_id AND item_id IS NULL) THEN
        PERFORM util.raise_error('No free spot in inventory container');
    END IF;
END;
$$;


ALTER FUNCTION inventory.check_free_inventory_slots(p_inventory_container_id integer) OWNER TO postgres;

--
-- TOC entry 355 (class 1255 OID 25491)
-- Name: check_inventory_container_access(integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.check_inventory_container_access(p_player_id integer, p_inventory_container_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.inventory_container_player_access WHERE inventory_container_id = p_inventory_container_id AND player_id = p_player_id) THEN
        PERFORM util.raise_error('You have no access of inventory container');
    END IF;
END;
$$;


ALTER FUNCTION inventory.check_inventory_container_access(p_player_id integer, p_inventory_container_id integer) OWNER TO postgres;

--
-- TOC entry 427 (class 1255 OID 22548)
-- Name: check_inventory_container_exists(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.check_inventory_container_exists(p_inventory_container_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.inventory_containers WHERE id = p_inventory_container_id) THEN
        PERFORM util.raise_error('Inventory container does not exist');
    END IF;
END;
$$;


ALTER FUNCTION inventory.check_inventory_container_exists(p_inventory_container_id integer) OWNER TO postgres;

--
-- TOC entry 384 (class 1255 OID 22550)
-- Name: check_inventory_containers_same_tile(integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.check_inventory_containers_same_tile(p_inventory_container_id_first integer, p_inventory_container_id_second integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF EXISTS (
    SELECT 1
    FROM inventory.get_container_tile(p_inventory_container_id_first) t1
    FULL JOIN inventory.get_container_tile(p_inventory_container_id_second) t2 ON 1=1
    WHERE (t1.map_id, t1.map_tile_x, t1.map_tile_y)
          IS DISTINCT FROM
          (t2.map_id, t2.map_tile_x, t2.map_tile_y)
	) THEN

    PERFORM util.raise_error('Inventories are too far away from each other');
    END IF;
END;
$$;


ALTER FUNCTION inventory.check_inventory_containers_same_tile(p_inventory_container_id_first integer, p_inventory_container_id_second integer) OWNER TO postgres;

--
-- TOC entry 346 (class 1255 OID 22551)
-- Name: check_inventory_slot_exists(integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.check_inventory_slot_exists(p_inventory_container_id integer, p_slot_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.inventory_slots WHERE inventory_container_id = p_inventory_container_id AND id = p_slot_id) THEN
        PERFORM util.raise_error('No spot in inventory container');
    END IF;
END;
$$;


ALTER FUNCTION inventory.check_inventory_slot_exists(p_inventory_container_id integer, p_slot_id integer) OWNER TO postgres;

--
-- TOC entry 466 (class 1255 OID 22552)
-- Name: do_add_item_to_inventory(integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

PERFORM inventory.add_item_to_inventory(p_inventory_container_id, p_item_id, p_quantity); 
        
    RETURN QUERY SELECT true, 'Item added successfully';
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) OWNER TO postgres;

--
-- TOC entry 5717 (class 0 OID 0)
-- Dependencies: 466
-- Name: FUNCTION do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 423 (class 1255 OID 337048)
-- Name: do_add_item_to_player_inventory(integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.do_add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

PERFORM inventory.add_item_to_player_inventory(p_player_id , p_item_id, p_quantity);

        
    RETURN QUERY SELECT true, 'Item added successfully';
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION inventory.do_add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer) OWNER TO postgres;

--
-- TOC entry 5718 (class 0 OID 0)
-- Dependencies: 423
-- Name: FUNCTION do_add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 375 (class 1255 OID 22553)
-- Name: do_move_or_swap_item(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$

BEGIN

PERFORM inventory.move_or_swap_item(
    p_player_id,
    p_from_slot_id,
    p_to_slot_id,
    p_from_inventory_container_id,
	p_to_inventory_container_id
);

        
    RETURN QUERY SELECT true, 'Item transferred successfully';
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) OWNER TO postgres;

--
-- TOC entry 5719 (class 0 OID 0)
-- Dependencies: 375
-- Name: FUNCTION do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) IS 'action_api';


--
-- TOC entry 461 (class 1255 OID 22554)
-- Name: get_building_inventory(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_building_inventory(p_building_id integer) RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           t1.inventory_container_type_id,
           t3.inventory_slot_type_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_containers t1  
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t1.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.owner_id = p_building_id AND t1.inventory_container_type_id = 3
    ORDER BY t3.id ASC;
END;
$$;


ALTER FUNCTION inventory.get_building_inventory(p_building_id integer) OWNER TO postgres;

--
-- TOC entry 5720 (class 0 OID 0)
-- Dependencies: 461
-- Name: FUNCTION get_building_inventory(p_building_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_building_inventory(p_building_id integer) IS 'get_api';


--
-- TOC entry 362 (class 1255 OID 22555)
-- Name: get_container_tile(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_container_tile(p_container_id integer) RETURNS TABLE(map_id integer, map_tile_x integer, map_tile_y integer)
    LANGUAGE sql
    AS $$



	SELECT T2.map_id,
	T2.map_tile_x,
	T2.map_tile_y
	FROM inventory.inventory_containers T1
	JOIN districts.districts T2 ON T1.owner_id = T2.id
	WHERE T1.id = p_container_id
    AND T1.inventory_container_type_id = 4

    UNION ALL

	SELECT T2.map_id,
	T2.map_tile_x,
	T2.map_tile_y
	FROM inventory.inventory_containers T1
	JOIN world.map_tiles_players_positions T2 ON T1.owner_id = T2.player_id
	WHERE T1.id = p_container_id
    AND T1.inventory_container_type_id = 1

    UNION ALL

    SELECT T2.map_id,
    T2.map_tile_x,
    T2.map_tile_y
    FROM inventory.inventory_containers T1
    JOIN world.map_tiles_players_positions T2 ON T1.owner_id = T2.player_id
    WHERE T1.id = p_container_id
    AND T1.inventory_container_type_id = 2

    LIMIT 1;
$$;


ALTER FUNCTION inventory.get_container_tile(p_container_id integer) OWNER TO postgres;

--
-- TOC entry 361 (class 1255 OID 22556)
-- Name: get_district_inventory(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_district_inventory(p_district_id integer) RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           t1.inventory_container_type_id,
           t3.inventory_slot_type_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_containers t1  
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t1.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.owner_id = p_district_id AND t1.inventory_container_type_id = 4
    ORDER BY t3.id ASC;
END;
$$;


ALTER FUNCTION inventory.get_district_inventory(p_district_id integer) OWNER TO postgres;

--
-- TOC entry 5721 (class 0 OID 0)
-- Dependencies: 361
-- Name: FUNCTION get_district_inventory(p_district_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_district_inventory(p_district_id integer) IS 'get_api';


--
-- TOC entry 244 (class 1259 OID 22557)
-- Name: inventory_slot_types; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slot_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE inventory.inventory_slot_types OWNER TO postgres;

--
-- TOC entry 449 (class 1255 OID 22561)
-- Name: get_inventory_slot_types(); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_inventory_slot_types() RETURNS SETOF inventory.inventory_slot_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM inventory.inventory_slot_types;
      END;
      $$;


ALTER FUNCTION inventory.get_inventory_slot_types() OWNER TO postgres;

--
-- TOC entry 5722 (class 0 OID 0)
-- Dependencies: 449
-- Name: FUNCTION get_inventory_slot_types(); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types() IS 'automatic_get_api';


--
-- TOC entry 407 (class 1255 OID 22562)
-- Name: get_inventory_slot_types_by_key(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_inventory_slot_types_by_key(p_id integer) RETURNS SETOF inventory.inventory_slot_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM inventory.inventory_slot_types
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION inventory.get_inventory_slot_types_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5723 (class 0 OID 0)
-- Dependencies: 407
-- Name: FUNCTION get_inventory_slot_types_by_key(p_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 357 (class 1255 OID 25611)
-- Name: get_other_player_gear_inventory(integer, text); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_other_player_gear_inventory(p_player_id integer, p_other_player_id text) RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           t1.inventory_container_type_id,
           t3.inventory_slot_type_id,
           t3.item_id,
           t4.name,
           t3.quantity        
            FROM players.players p
            JOIN inventory.inventory_containers t1 ON t1.owner_id = p.id
                                                   AND t1.inventory_container_type_id = 2
            JOIN knowledge.known_players_containers kpc ON kpc.player_id = p_player_id
                                               AND kpc.container_id = t1.id
            JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t1.id
            LEFT JOIN items.items T4 ON T3.item_id = T4.id
            WHERE p.id = players.get_real_player_id(p_other_player_id)
            ORDER BY t3.id ASC;

END;
$$;


ALTER FUNCTION inventory.get_other_player_gear_inventory(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5724 (class 0 OID 0)
-- Dependencies: 357
-- Name: FUNCTION get_other_player_gear_inventory(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_other_player_gear_inventory(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 387 (class 1255 OID 25610)
-- Name: get_other_player_inventory(integer, text); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_other_player_inventory(p_player_id integer, p_other_player_id text) RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           t1.inventory_container_type_id,
           t3.inventory_slot_type_id,
           t3.item_id,
           t4.name,
           t3.quantity        
            FROM players.players p
            JOIN inventory.inventory_containers t1 ON t1.owner_id = p.id
                                                   AND t1.inventory_container_type_id = 1
            JOIN knowledge.known_players_containers kpc ON kpc.player_id = p_player_id
                                               AND kpc.container_id = t1.id
            JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t1.id
            LEFT JOIN items.items T4 ON T3.item_id = T4.id
            WHERE p.id = players.get_real_player_id(p_other_player_id)
            ORDER BY t3.id ASC;

END;
$$;


ALTER FUNCTION inventory.get_other_player_inventory(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5725 (class 0 OID 0)
-- Dependencies: 387
-- Name: FUNCTION get_other_player_inventory(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_other_player_inventory(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 378 (class 1255 OID 25483)
-- Name: get_player_gear_inventory(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_player_gear_inventory(p_player_id integer) RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           t1.inventory_container_type_id,
           t3.inventory_slot_type_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_containers t1  
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t1.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.owner_id = p_player_id AND t1.inventory_container_type_id = 2
    ORDER BY t3.id ASC;
END;
$$;


ALTER FUNCTION inventory.get_player_gear_inventory(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5726 (class 0 OID 0)
-- Dependencies: 378
-- Name: FUNCTION get_player_gear_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_gear_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 413 (class 1255 OID 25482)
-- Name: get_player_inventory(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_player_inventory(p_player_id integer) RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           t1.inventory_container_type_id,
           t3.inventory_slot_type_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_containers t1  
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t1.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.owner_id = p_player_id AND t1.inventory_container_type_id = 1
    ORDER BY t3.id ASC;
END;
$$;


ALTER FUNCTION inventory.get_player_inventory(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5727 (class 0 OID 0)
-- Dependencies: 413
-- Name: FUNCTION get_player_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 381 (class 1255 OID 353445)
-- Name: move_or_swap_item(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_from_item_id   integer;
    v_from_quantity  integer;

    v_to_item_id     integer;
    v_to_quantity    integer;
BEGIN
    PERFORM inventory.check_inventory_container_access(p_player_id, p_from_inventory_container_id);
    PERFORM inventory.check_inventory_container_access(p_player_id, p_to_inventory_container_id);
    PERFORM inventory.check_inventory_slot_exists(p_from_inventory_container_id, p_from_slot_id);
    PERFORM inventory.check_inventory_slot_exists(p_to_inventory_container_id, p_to_slot_id);
    PERFORM inventory.check_inventory_containers_same_tile(p_from_inventory_container_id, p_to_inventory_container_id);


    -- Pobierz slot źródłowy (z blokadą)
    SELECT item_id, quantity
    INTO v_from_item_id, v_from_quantity
    FROM inventory.inventory_slots
    WHERE id = p_from_slot_id
      AND inventory_container_id = p_from_inventory_container_id
    FOR UPDATE;

    IF v_from_item_id IS NULL THEN
        PERFORM util.raise_error('Source slot is empty');
    END IF;

    -- Pobierz slot docelowy (z blokadą)
    SELECT item_id, quantity
    INTO v_to_item_id, v_to_quantity
    FROM inventory.inventory_slots
    WHERE id = p_to_slot_id
      AND inventory_container_id = p_to_inventory_container_id
    FOR UPDATE;

    -- Jeśli docelowy slot jest pusty → move
    IF v_to_item_id IS NULL THEN

        UPDATE inventory.inventory_slots
        SET item_id = v_from_item_id,
            quantity = v_from_quantity
        WHERE id = p_to_slot_id;

        UPDATE inventory.inventory_slots
        SET item_id = NULL,
            quantity = NULL
        WHERE id = p_from_slot_id;

    -- Jeśli zajęty → swap
    ELSE

        UPDATE inventory.inventory_slots
        SET item_id = v_to_item_id,
            quantity = v_to_quantity
        WHERE id = p_from_slot_id;

        UPDATE inventory.inventory_slots
        SET item_id = v_from_item_id,
            quantity = v_from_quantity
        WHERE id = p_to_slot_id;

    END IF;

END;
$$;


ALTER FUNCTION inventory.move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) OWNER TO postgres;

--
-- TOC entry 451 (class 1255 OID 353441)
-- Name: player_inventory_container(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.player_inventory_container(p_player_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_container_id integer;

BEGIN

SELECT id INTO v_container_id 
FROM inventory.inventory_containers 
WHERE owner_id = p_player_id 
  AND inventory_container_type_id = 1
LIMIT 1;

RETURN v_container_id;

END;
$$;


ALTER FUNCTION inventory.player_inventory_container(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 374 (class 1255 OID 361674)
-- Name: check_can_craft_item(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.check_can_craft_item(p_player_id integer, p_recipe_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- 1. Sprawdź skill dla GŁÓWNEJ receptury
    IF EXISTS (
        SELECT 1
        FROM items.recipes r
        WHERE r.id = p_recipe_id
          AND r.skill_requirement_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM "attributes".player_skills ps
              WHERE ps.player_id = p_player_id
                AND ps.skill_id  = r.skill_requirement_id
          )
    ) THEN
        RETURN FALSE;
    END IF;

    -- 2. Sprawdź materiały + skille półfabrykatów rekurencyjnie
    RETURN NOT EXISTS (
        WITH RECURSIVE craft_check AS (
            SELECT
                rm.item_id,
                rm.quantity AS required_quantity,
                EXISTS (
                    SELECT 1 FROM items.recipes r2
                    WHERE r2.item_id = rm.item_id
                ) AS is_craftable
            FROM items.recipe_materials rm
            WHERE rm.recipe_id = p_recipe_id

            UNION ALL

            -- Rozwijaj półfabrykaty których gracz NIE MA w inventory
            SELECT
                rm.item_id,
                rm.quantity * cc.required_quantity AS required_quantity,
                EXISTS (
                    SELECT 1 FROM items.recipes r2
                    WHERE r2.item_id = rm.item_id
                ) AS is_craftable
            FROM craft_check cc
            JOIN items.recipes r         ON r.item_id    = cc.item_id
            JOIN items.recipe_materials rm ON rm.recipe_id = r.id
            WHERE cc.is_craftable = TRUE
              AND NOT EXISTS (
                SELECT 1
                FROM inventory.inventory_slots s
                JOIN inventory.inventory_containers c ON s.inventory_container_id = c.id
                WHERE c.owner_id                  = p_player_id
                  AND c.inventory_container_type_id = 1
                  AND s.item_id                   = cc.item_id
                  AND COALESCE(s.quantity, 0)     >= cc.required_quantity
              )
        ),
        aggregated AS (
            SELECT
                item_id,
                SUM(required_quantity) AS total_required
            FROM craft_check
            WHERE is_craftable = FALSE
               OR EXISTS (
                    SELECT 1
                    FROM inventory.inventory_slots s
                    JOIN inventory.inventory_containers c ON s.inventory_container_id = c.id
                    WHERE c.owner_id                  = p_player_id
                      AND c.inventory_container_type_id = 1
                      AND s.item_id                   = craft_check.item_id
               )
            GROUP BY item_id
        ),
        player_inventory AS (
            SELECT
                s.item_id,
                SUM(COALESCE(s.quantity, 0)) AS total_owned
            FROM inventory.inventory_slots s
            JOIN inventory.inventory_containers c ON s.inventory_container_id = c.id
            WHERE c.owner_id                  = p_player_id
              AND c.inventory_container_type_id = 1
            GROUP BY s.item_id
        ),
        -- Półfabrykaty które będą craftowane (rozwinięte, brak w inventory)
        -- i wymagają sprawdzenia skillu
        sub_recipe_skill_check AS (
            SELECT
                r.skill_requirement_id
            FROM craft_check cc
            JOIN items.recipes r ON r.item_id = cc.item_id
            WHERE cc.is_craftable = TRUE
              AND r.skill_requirement_id IS NOT NULL
              -- Tylko te które faktycznie będziemy craftować (brak w inventory)
              AND NOT EXISTS (
                SELECT 1
                FROM inventory.inventory_slots s
                JOIN inventory.inventory_containers c ON s.inventory_container_id = c.id
                WHERE c.owner_id                  = p_player_id
                  AND c.inventory_container_type_id = 1
                  AND s.item_id                   = cc.item_id
                  AND COALESCE(s.quantity, 0)     >= cc.required_quantity
              )
        )

        -- Brakujące materiały
        SELECT 1
        FROM aggregated a
        LEFT JOIN player_inventory pi ON pi.item_id = a.item_id
        WHERE COALESCE(pi.total_owned, 0) < a.total_required

        UNION ALL

        -- Brakujące skille do półfabrykatów
        SELECT 1
        FROM sub_recipe_skill_check sc
        WHERE NOT EXISTS (
            SELECT 1
            FROM "attributes".player_skills ps
            WHERE ps.player_id = p_player_id
              AND ps.skill_id  = sc.skill_requirement_id
        )

        LIMIT 1
    );
END;
$$;


ALTER FUNCTION items.check_can_craft_item(p_player_id integer, p_recipe_id integer) OWNER TO postgres;

--
-- TOC entry 424 (class 1255 OID 22566)
-- Name: check_item_exists(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.check_item_exists(p_item_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM items.items WHERE id = p_item_id) THEN
        PERFORM util.raise_error('Item does not exist');
    END IF;
END;
$$;


ALTER FUNCTION items.check_item_exists(p_item_id integer) OWNER TO postgres;

--
-- TOC entry 338 (class 1255 OID 361686)
-- Name: check_player_has_material(integer, integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.check_player_has_material(p_player_id integer, p_item_id integer, p_required_quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_owned_quantity integer;
BEGIN
    SELECT COALESCE(SUM(s.quantity), 0) INTO v_owned_quantity
    FROM inventory.inventory_slots s
    JOIN inventory.inventory_containers c ON s.inventory_container_id = c.id
    WHERE c.owner_id                   = p_player_id
      AND c.inventory_container_type_id = 1
      AND s.item_id                    = p_item_id;

    IF v_owned_quantity < p_required_quantity THEN
        PERFORM util.raise_error('Insufficient materials to craft this recipe');
    END IF;
END;
$$;


ALTER FUNCTION items.check_player_has_material(p_player_id integer, p_item_id integer, p_required_quantity integer) OWNER TO postgres;

--
-- TOC entry 418 (class 1255 OID 22567)
-- Name: check_quantity_positive(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.check_quantity_positive(p_quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF p_quantity <= 0 THEN
        PERFORM util.raise_error('Quantity must be greater than 0');
    END IF;
END;
$$;


ALTER FUNCTION items.check_quantity_positive(p_quantity integer) OWNER TO postgres;

--
-- TOC entry 386 (class 1255 OID 361685)
-- Name: check_recipe_exists(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.check_recipe_exists(p_recipe_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM items.recipes WHERE id = p_recipe_id) THEN
        PERFORM util.raise_error('Recipe does not exist');
    END IF;
END;
$$;


ALTER FUNCTION items.check_recipe_exists(p_recipe_id integer) OWNER TO postgres;

--
-- TOC entry 380 (class 1255 OID 361684)
-- Name: check_recipe_skill_requirement(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.check_recipe_skill_requirement(p_player_id integer, p_recipe_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM items.recipes r
        WHERE r.id = p_recipe_id
          AND r.skill_requirement_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM "attributes".player_skills ps
              WHERE ps.player_id = p_player_id
                AND ps.skill_id  = r.skill_requirement_id
          )
    ) THEN
        PERFORM util.raise_error('Player does not have required skill for this recipe');
    END IF;
END;
$$;


ALTER FUNCTION items.check_recipe_skill_requirement(p_player_id integer, p_recipe_id integer) OWNER TO postgres;

--
-- TOC entry 454 (class 1255 OID 361687)
-- Name: craft_recipe(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.craft_recipe(p_player_id integer, p_recipe_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_item_id  integer;
    v_material record;
BEGIN
    -- Walidacja
    PERFORM items.check_recipe_exists(p_recipe_id);
    PERFORM items.check_recipe_skill_requirement(p_player_id, p_recipe_id);

    FOR v_material IN
        SELECT item_id, quantity AS required_quantity
        FROM items.recipe_materials
        WHERE recipe_id = p_recipe_id
    LOOP
        PERFORM items.check_player_has_material(p_player_id, v_material.item_id, v_material.required_quantity);
    END LOOP;

    -- Pobierz item który powstanie
    SELECT item_id INTO v_item_id
    FROM items.recipes
    WHERE id = p_recipe_id;

    -- Odejmij wszystkie materiały jednym UPDATE per item używając CTE
    WITH materials AS (
        SELECT item_id, quantity AS required_quantity
        FROM items.recipe_materials
        WHERE recipe_id = p_recipe_id
    ),
    slots_to_update AS (
        SELECT
            s.id AS slot_id,
            s.quantity AS current_quantity,
            m.required_quantity,
        
            LEAST(
                s.quantity,
                m.required_quantity - COALESCE(
                    SUM(s.quantity) OVER (
                        PARTITION BY s.item_id
                        ORDER BY s.id
                        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                    ), 0
                )
            ) AS consume_quantity
        
        FROM inventory.inventory_slots s
        JOIN inventory.inventory_containers c ON s.inventory_container_id = c.id
        JOIN materials m ON m.item_id = s.item_id
        WHERE c.owner_id                   = p_player_id
          AND c.inventory_container_type_id = 1
          AND s.quantity                   > 0
    )
    UPDATE inventory.inventory_slots upd
    SET
        quantity = CASE
            WHEN stu.current_quantity - stu.consume_quantity = 0 THEN NULL
            ELSE stu.current_quantity - stu.consume_quantity
        END,
        item_id = CASE
            WHEN stu.current_quantity - stu.consume_quantity = 0 THEN NULL
            ELSE upd.item_id
        END
    FROM slots_to_update stu
    WHERE upd.id = stu.slot_id
      AND stu.consume_quantity > 0;

    -- Dodaj skraftowany item
    PERFORM inventory.add_item_to_player_inventory(p_player_id, v_item_id, 1);

END;
$$;


ALTER FUNCTION items.craft_recipe(p_player_id integer, p_recipe_id integer) OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 361688)
-- Name: do_craft_recipe(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.do_craft_recipe(p_player_id integer, p_recipe_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

    PERFORM items.craft_recipe(p_player_id, p_recipe_id);

    RETURN QUERY SELECT true, 'Item crafted successfully';
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION items.do_craft_recipe(p_player_id integer, p_recipe_id integer) OWNER TO postgres;

--
-- TOC entry 5728 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION do_craft_recipe(p_player_id integer, p_recipe_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.do_craft_recipe(p_player_id integer, p_recipe_id integer) IS 'action_api';


--
-- TOC entry 347 (class 1255 OID 296085)
-- Name: do_gather_resources_on_map_tile(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.do_gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

    PERFORM items.gather_resources_on_map_tile(
        p_player_id,
        p_map_id,
        p_x,
        p_y,
        p_map_tiles_resource_id,
        p_gather_amount
    );

    RETURN QUERY SELECT true, 'Item gathered successfully';
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION items.do_gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer) OWNER TO postgres;

--
-- TOC entry 5729 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION do_gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.do_gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer) IS 'action_api';


--
-- TOC entry 337 (class 1255 OID 353446)
-- Name: gather_resources_on_map_tile(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_resource_item_id  integer;
    v_resource_quantity integer;
    v_status boolean;
    v_message text;
BEGIN

    PERFORM world.check_player_is_on_tile(p_player_id, p_map_id, p_x, p_y);

    SELECT item_id, quantity
      INTO v_resource_item_id, v_resource_quantity
      FROM world.map_tiles_resources
     WHERE id         = p_map_tiles_resource_id
       AND map_id     = p_map_id
       AND map_tile_x = p_x       
       AND map_tile_y = p_y;       

    IF v_resource_item_id IS NULL THEN
        PERFORM util.raise_error('Resource not found at this tile or resource ID is invalid');
    END IF;

    PERFORM items.check_quantity_positive(p_gather_amount);
    
    IF p_gather_amount > v_resource_quantity THEN
         PERFORM util.raise_error('There is not sufficent amount on tile');
    END IF;



    UPDATE world.map_tiles_resources
        SET quantity = quantity - p_gather_amount
    WHERE id = p_map_tiles_resource_id;

PERFORM inventory.add_item_to_player_inventory(p_player_id, v_resource_item_id, p_gather_amount);

END;
$$;


ALTER FUNCTION items.gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer) OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 22568)
-- Name: item_stats; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.item_stats (
    id integer NOT NULL,
    item_id integer NOT NULL,
    stat_id integer NOT NULL,
    value integer NOT NULL
);


ALTER TABLE items.item_stats OWNER TO postgres;

--
-- TOC entry 467 (class 1255 OID 22575)
-- Name: get_item_stats(); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_item_stats() RETURNS SETOF items.item_stats
    LANGUAGE plpgsql
    AS $$
      BEGIN
          RETURN QUERY
          SELECT * FROM items.item_stats;
      END;
      $$;


ALTER FUNCTION items.get_item_stats() OWNER TO postgres;

--
-- TOC entry 5730 (class 0 OID 0)
-- Dependencies: 467
-- Name: FUNCTION get_item_stats(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats() IS 'automatic_get_api';


--
-- TOC entry 406 (class 1255 OID 22576)
-- Name: get_item_stats_by_key(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_item_stats_by_key(p_id integer) RETURNS SETOF items.item_stats
    LANGUAGE plpgsql
    AS $$
      BEGIN
          RETURN QUERY
          SELECT * FROM items.item_stats
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION items.get_item_stats_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5731 (class 0 OID 0)
-- Dependencies: 406
-- Name: FUNCTION get_item_stats_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 246 (class 1259 OID 22577)
-- Name: items; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.items (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    image character varying(255) DEFAULT 'default'::character varying NOT NULL,
    item_type_id integer DEFAULT 1 NOT NULL
);


ALTER TABLE items.items OWNER TO postgres;

--
-- TOC entry 389 (class 1255 OID 22587)
-- Name: get_items(); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_items() RETURNS SETOF items.items
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM items.items;
      END;
      $$;


ALTER FUNCTION items.get_items() OWNER TO postgres;

--
-- TOC entry 5732 (class 0 OID 0)
-- Dependencies: 389
-- Name: FUNCTION get_items(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items() IS 'automatic_get_api';


--
-- TOC entry 358 (class 1255 OID 22588)
-- Name: get_items_by_key(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_items_by_key(p_id integer) RETURNS SETOF items.items
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM items.items
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION items.get_items_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5733 (class 0 OID 0)
-- Dependencies: 358
-- Name: FUNCTION get_items_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 420 (class 1255 OID 361683)
-- Name: get_player_recipe_materials(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_player_recipe_materials(p_player_id integer, p_recipe_id integer) RETURNS TABLE(id integer, recipe_id integer, item_id integer, quantity integer, owned_quantity bigint, missing_quantity bigint, can_craft_missing boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE
    player_inventory AS (
        SELECT
            s.item_id,
            SUM(COALESCE(s.quantity, 0)) AS total_owned
        FROM inventory.inventory_slots s
        JOIN inventory.inventory_containers c ON s.inventory_container_id = c.id
        WHERE c.owner_id                   = p_player_id
          AND c.inventory_container_type_id = 1
        GROUP BY s.item_id
    ),
    direct_materials AS (
        SELECT
            rm.id,
            rm.recipe_id,
            rm.item_id,
            rm.quantity,
            COALESCE(pi.total_owned, 0)                             AS owned_quantity,
            GREATEST(rm.quantity - COALESCE(pi.total_owned, 0), 0) AS missing_quantity,
            EXISTS (
                SELECT 1 FROM items.recipes r2 WHERE r2.item_id = rm.item_id
            ) AS is_craftable
        FROM items.recipe_materials rm
        LEFT JOIN player_inventory pi ON pi.item_id = rm.item_id
        WHERE rm.recipe_id = p_recipe_id
    ),
    sub_craft AS (
        -- Start: brakujące materiały które są craftable
        SELECT
            dm.item_id AS root_item_id,
            rm.item_id AS sub_item_id,
            rm.quantity * GREATEST(dm.missing_quantity, 0) AS required_quantity,
            EXISTS (
                SELECT 1 FROM items.recipes r2 WHERE r2.item_id = rm.item_id
            ) AS is_craftable
        FROM direct_materials dm
        JOIN items.recipes r           ON r.item_id    = dm.item_id
        JOIN items.recipe_materials rm ON rm.recipe_id = r.id
        WHERE dm.is_craftable = TRUE
          AND dm.missing_quantity > 0

        UNION ALL

        -- Rozwijaj dalej jeśli sub-materiału też brakuje
        SELECT
            sc.root_item_id,
            rm.item_id,
            rm.quantity * sc.required_quantity AS required_quantity,
            EXISTS (
                SELECT 1 FROM items.recipes r2 WHERE r2.item_id = rm.item_id
            ) AS is_craftable
        FROM sub_craft sc
        JOIN items.recipes r           ON r.item_id    = sc.sub_item_id
        JOIN items.recipe_materials rm ON rm.recipe_id = r.id
        WHERE sc.is_craftable = TRUE
          AND NOT EXISTS (
            SELECT 1 FROM player_inventory pi
            WHERE pi.item_id    = sc.sub_item_id
              AND pi.total_owned >= sc.required_quantity
          )
    ),
    sub_aggregated AS (
        SELECT
            sc.root_item_id,
            sc.sub_item_id AS item_id,
            SUM(sc.required_quantity) AS total_required
        FROM sub_craft sc
        WHERE sc.is_craftable = FALSE
           OR EXISTS (
                SELECT 1 FROM player_inventory pi WHERE pi.item_id = sc.sub_item_id
           )
        GROUP BY sc.root_item_id, sc.sub_item_id
    ),
    can_craft_sub AS (
        SELECT
            sa.root_item_id,
            BOOL_AND(COALESCE(pi.total_owned, 0) >= sa.total_required) AS craftable
        FROM sub_aggregated sa
        LEFT JOIN player_inventory pi ON pi.item_id = sa.item_id
        GROUP BY sa.root_item_id
    )
    SELECT
        dm.id::integer,
        dm.recipe_id::integer,
        dm.item_id::integer,
        dm.quantity::integer,
        dm.owned_quantity,
        dm.missing_quantity,
        CASE
            WHEN dm.missing_quantity = 0    THEN FALSE
            WHEN dm.is_craftable    = FALSE THEN FALSE
            ELSE COALESCE(ccs.craftable, FALSE)
        END AS can_craft_missing
    FROM direct_materials dm
    LEFT JOIN can_craft_sub ccs ON ccs.root_item_id = dm.item_id;
END;
$$;


ALTER FUNCTION items.get_player_recipe_materials(p_player_id integer, p_recipe_id integer) OWNER TO postgres;

--
-- TOC entry 5734 (class 0 OID 0)
-- Dependencies: 420
-- Name: FUNCTION get_player_recipe_materials(p_player_id integer, p_recipe_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_player_recipe_materials(p_player_id integer, p_recipe_id integer) IS 'get_api';


--
-- TOC entry 416 (class 1255 OID 361679)
-- Name: get_player_recipes(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_player_recipes(p_player_id integer) RETURNS TABLE(id integer, item_id integer, description character varying, image character varying, skill_id integer, value integer, can_craft boolean)
    LANGUAGE plpgsql
    AS $$
      BEGIN

          RETURN QUERY
      SELECT 
        T1.id 
        ,T1.item_id 
        ,T1.description 
        ,T1.image
        ,T2.skill_id 
        ,T2.value 
        ,items.check_can_craft_item(p_player_id, T1.id ) AS can_craft
        FROM items.recipes T1
        JOIN "attributes".player_skills T2 ON T1.skill_requirement_id = T2.skill_id 
        WHERE T2.player_id = p_player_id;

      END;
      $$;


ALTER FUNCTION items.get_player_recipes(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5735 (class 0 OID 0)
-- Dependencies: 416
-- Name: FUNCTION get_player_recipes(p_player_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_player_recipes(p_player_id integer) IS 'get_api';


--
-- TOC entry 326 (class 1259 OID 353512)
-- Name: recipe_materials; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.recipe_materials (
    id integer NOT NULL,
    recipe_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    CONSTRAINT recipe_materials_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE items.recipe_materials OWNER TO postgres;

--
-- TOC entry 349 (class 1255 OID 353540)
-- Name: get_recipe_materials(); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_recipe_materials() RETURNS SETOF items.recipe_materials
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM items.recipe_materials;
      END;
      $$;


ALTER FUNCTION items.get_recipe_materials() OWNER TO postgres;

--
-- TOC entry 5736 (class 0 OID 0)
-- Dependencies: 349
-- Name: FUNCTION get_recipe_materials(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_recipe_materials() IS 'automatic_get_api';


--
-- TOC entry 368 (class 1255 OID 353541)
-- Name: get_recipe_materials_by_key(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.get_recipe_materials_by_key(p_recipe_id integer) RETURNS SETOF items.recipe_materials
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM items.recipe_materials
          WHERE "recipe_id" = p_recipe_id;
      END;
      $$;


ALTER FUNCTION items.get_recipe_materials_by_key(p_recipe_id integer) OWNER TO postgres;

--
-- TOC entry 5737 (class 0 OID 0)
-- Dependencies: 368
-- Name: FUNCTION get_recipe_materials_by_key(p_recipe_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_recipe_materials_by_key(p_recipe_id integer) IS 'automatic_get_api';


--
-- TOC entry 475 (class 1255 OID 353452)
-- Name: get_player_known_players(integer); Type: FUNCTION; Schema: knowledge; Owner: postgres
--

CREATE FUNCTION knowledge.get_player_known_players(p_player_id integer) RETURNS TABLE(other_player_id text, name character varying, second_name character varying, nickname character varying, image_portrait character varying, map_id integer, x integer, y integer, image_map character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

RETURN QUERY

WITH player_profiles AS (
           SELECT 
            p.id
            ,p.name AS name
            ,p.second_name AS second_name
            ,p.nickname AS nickname
            ,p.image_portrait AS image_portrait
            FROM players.players p
            JOIN knowledge.known_players_profiles T2 ON T2.other_player_id = p.id
            WHERE T2.player_id = p_player_id
)

,players_positions AS (
             SELECT  T2.id
                     ,CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE T2.masked_id::text END AS other_player_id 
                     ,T1.map_id
                     ,T1.map_tile_x AS X 
                     ,T1.map_tile_y AS Y
                     ,t2.image_map AS image_map
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            JOIN knowledge.known_players_positions T3 ON T3.other_player_id = T2.id
            LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                           AND kpp.other_player_id = T2.id
            WHERE  T3.player_id = p_player_id
)


SELECT
T2.other_player_id
,T1.name
,T1.second_name
,T1.nickname
,T1.image_portrait
,T2.map_id
,T2.x
,T2.y
,T2.image_map
FROM player_profiles T1
FULL JOIN players_positions T2 ON T1.ID = T2.ID;



           
END;
$$;


ALTER FUNCTION knowledge.get_player_known_players(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5738 (class 0 OID 0)
-- Dependencies: 475
-- Name: FUNCTION get_player_known_players(p_player_id integer); Type: COMMENT; Schema: knowledge; Owner: postgres
--

COMMENT ON FUNCTION knowledge.get_player_known_players(p_player_id integer) IS 'get_api';


--
-- TOC entry 409 (class 1255 OID 22589)
-- Name: do_switch_active_player(integer, integer); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

PERFORM players.switch_active_player(p_player_id, p_switch_to_player_id);

    RETURN QUERY SELECT true, 'Player switched';
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) OWNER TO postgres;

--
-- TOC entry 5739 (class 0 OID 0)
-- Dependencies: 409
-- Name: FUNCTION do_switch_active_player(p_player_id integer, p_switch_to_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) IS 'action_api';


--
-- TOC entry 391 (class 1255 OID 22590)
-- Name: get_active_player(integer); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.get_active_player(p_user_id integer) RETURNS TABLE(id integer)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
            SELECT 
            t1.id
            FROM players.players t1
            WHERE t1.user_id = p_user_id
             AND t1.is_active = true
            LIMIT 1;
      END;
      $$;


ALTER FUNCTION players.get_active_player(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 465 (class 1255 OID 22591)
-- Name: get_active_player_profile(integer); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.get_active_player_profile(p_player_id integer) RETURNS TABLE(name character varying, second_name character varying, nickname character varying, image_map character varying, image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
            SELECT 
            t1.name,
			t1.second_name,
			t1.nickname,
            t1.image_map,
            t1.image_portrait
            FROM players.players t1
            WHERE t1.id = p_player_id
             AND t1.is_active = true
            LIMIT 1;
      END;
      $$;


ALTER FUNCTION players.get_active_player_profile(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5740 (class 0 OID 0)
-- Dependencies: 465
-- Name: FUNCTION get_active_player_profile(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_profile(p_player_id integer) IS 'get_api';


--
-- TOC entry 354 (class 1255 OID 22592)
-- Name: get_active_player_switch_profiles(integer); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.get_active_player_switch_profiles(p_player_id integer) RETURNS TABLE(id integer, name character varying, second_name character varying, nickname character varying, image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
              SELECT 
                p2.id,
                p2.name,
				p2.second_name,
				p2.nickname,
                p2.image_portrait
              FROM players.players p1
              JOIN players.players p2 ON p2.user_id = p1.user_id
              WHERE p1.id = p_player_id;
      END;
      $$;


ALTER FUNCTION players.get_active_player_switch_profiles(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5741 (class 0 OID 0)
-- Dependencies: 354
-- Name: FUNCTION get_active_player_switch_profiles(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_switch_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 458 (class 1255 OID 25605)
-- Name: get_other_player_profile(integer, text); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.get_other_player_profile(p_player_id integer, p_other_player_id text) RETURNS TABLE(name character varying, second_name character varying, nickname character varying, image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN

            RETURN QUERY
            SELECT 
            CASE WHEN kpp.other_player_id IS NOT NULL THEN p.name ELSE NULL END AS name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.second_name ELSE NULL END AS second_name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.nickname ELSE NULL END AS nickname
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.image_portrait ELSE NULL END AS image_portrait
            FROM players.players p
            LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                               AND kpp.other_player_id = p.id
            WHERE p.id = players.get_real_player_id(p_other_player_id)
            LIMIT 1;
      END;
      $$;


ALTER FUNCTION players.get_other_player_profile(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5742 (class 0 OID 0)
-- Dependencies: 458
-- Name: FUNCTION get_other_player_profile(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_other_player_profile(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 377 (class 1255 OID 25602)
-- Name: get_real_player_id(text); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.get_real_player_id(p_other_player_id text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_player_id int;
BEGIN
    ------------------------------------------------------------------
    -- 1. spróbuj potraktować jako normalne player.id (int)
    ------------------------------------------------------------------
    BEGIN
        v_player_id := p_other_player_id::int;

        PERFORM 1
        FROM players.players p
        WHERE p.id = v_player_id;

        IF FOUND THEN
            RETURN v_player_id;
        END IF;

    EXCEPTION WHEN invalid_text_representation THEN
        -- nie jest int – lecimy dalej
    END;

    ------------------------------------------------------------------
    -- 2. spróbuj potraktować jako masked uuid
    ------------------------------------------------------------------
    BEGIN
        SELECT p.id
        INTO v_player_id
        FROM players.players p
        WHERE p.masked_id = p_other_player_id::uuid;

        IF FOUND THEN
            RETURN v_player_id;
        END IF;

    EXCEPTION WHEN invalid_text_representation THEN
        -- nie jest uuid
    END;

    ------------------------------------------------------------------
    -- 3. nic nie znaleziono
    ------------------------------------------------------------------
    RETURN NULL;
END;
$$;


ALTER FUNCTION players.get_real_player_id(p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 438 (class 1255 OID 22593)
-- Name: switch_active_player(integer, integer); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.switch_active_player(p_player_id integer, p_switch_to_player_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

UPDATE players.players
SET is_active = false
WHERE id = p_player_id;

UPDATE players.players
SET is_active = true
WHERE id = p_switch_to_player_id;

END;
$$;


ALTER FUNCTION players.switch_active_player(p_player_id integer, p_switch_to_player_id integer) OWNER TO postgres;

--
-- TOC entry 398 (class 1255 OID 484714)
-- Name: check_player_and_squad_same_tile(integer, integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.check_player_and_squad_same_tile(p_player_id integer, p_squad_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF NOT EXISTS (
        SELECT
        1
        FROM world.map_tiles_players_positions MTPP
        JOIN world.map_tiles_squads_positions MTSP ON MTPP.map_id = MTSP.map_id 
                                                   AND MTPP.map_tile_x = MTSP.map_tile_x 
                                                   AND MTPP.map_tile_y = MTSP.map_tile_y 
        WHERE MTPP.player_id  = p_player_id
        AND  MTSP.squad_id  = p_squad_id
    ) THEN

    PERFORM util.raise_error('Squad is too far away');
    END IF;
END;
$$;


ALTER FUNCTION squad.check_player_and_squad_same_tile(p_player_id integer, p_squad_id integer) OWNER TO postgres;

--
-- TOC entry 425 (class 1255 OID 476398)
-- Name: check_player_not_in_squad(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.check_player_not_in_squad(p_player_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM squad.squad_players
        WHERE player_id = p_player_id
    ) THEN
        PERFORM util.raise_error('Player is in squad');
    END IF;
END;
$$;


ALTER FUNCTION squad.check_player_not_in_squad(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 408 (class 1255 OID 476394)
-- Name: do_squad_create(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.do_squad_create(p_player_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

PERFORM squad.squad_create(p_player_id);

    RETURN QUERY SELECT true, 'Squad Created';

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION squad.do_squad_create(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5743 (class 0 OID 0)
-- Dependencies: 408
-- Name: FUNCTION do_squad_create(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.do_squad_create(p_player_id integer) IS 'action_api';


--
-- TOC entry 353 (class 1255 OID 476475)
-- Name: do_squad_invite(integer, text, integer, integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.do_squad_invite(p_player_id integer, p_invited_player_id text, p_invite_type integer, p_squad_role integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

PERFORM squad.squad_invite(p_player_id,p_invited_player_id, p_invite_type, p_squad_role);

    RETURN QUERY SELECT true, 'Invited to squad';

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION squad.do_squad_invite(p_player_id integer, p_invited_player_id text, p_invite_type integer, p_squad_role integer) OWNER TO postgres;

--
-- TOC entry 5744 (class 0 OID 0)
-- Dependencies: 353
-- Name: FUNCTION do_squad_invite(p_player_id integer, p_invited_player_id text, p_invite_type integer, p_squad_role integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.do_squad_invite(p_player_id integer, p_invited_player_id text, p_invite_type integer, p_squad_role integer) IS 'action_api';


--
-- TOC entry 356 (class 1255 OID 476455)
-- Name: do_squad_join(integer, integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.do_squad_join(p_player_id integer, p_squad_invite_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

PERFORM squad.squad_join(p_player_id, p_squad_invite_id);

    RETURN QUERY SELECT true, 'Squad Joined';

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION squad.do_squad_join(p_player_id integer, p_squad_invite_id integer) OWNER TO postgres;

--
-- TOC entry 5745 (class 0 OID 0)
-- Dependencies: 356
-- Name: FUNCTION do_squad_join(p_player_id integer, p_squad_invite_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.do_squad_join(p_player_id integer, p_squad_invite_id integer) IS 'action_api';


--
-- TOC entry 452 (class 1255 OID 476405)
-- Name: do_squad_leave(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.do_squad_leave(p_player_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

PERFORM squad.squad_leave(p_player_id);

    RETURN QUERY SELECT true, 'Squad leaved';

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION squad.do_squad_leave(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5746 (class 0 OID 0)
-- Dependencies: 452
-- Name: FUNCTION do_squad_leave(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.do_squad_leave(p_player_id integer) IS 'action_api';


--
-- TOC entry 410 (class 1255 OID 484742)
-- Name: get_active_player_squad(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.get_active_player_squad(p_player_id integer) RETURNS TABLE(squad_id integer, squad_name character varying, squad_image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
            SELECT 
            s.id AS squad_id
            ,s.squad_name
            ,s.squad_image_portrait
            FROM squad.squads s
            JOIN squad.squad_players sp ON s.id = sp.squad_id
            WHERE sp.player_id = p_player_id
            LIMIT 1;


      END;
      $$;


ALTER FUNCTION squad.get_active_player_squad(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5747 (class 0 OID 0)
-- Dependencies: 410
-- Name: FUNCTION get_active_player_squad(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_active_player_squad(p_player_id integer) IS 'get_api';


--
-- TOC entry 411 (class 1255 OID 25619)
-- Name: get_active_player_squad_players_profiles(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.get_active_player_squad_players_profiles(p_player_id integer) RETURNS TABLE(other_player_id text, name character varying, second_name character varying, nickname character varying, image_map character varying, image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
            SELECT 
            p.id::text AS other_player_id,
            p.name,
            p.second_name,
            p.nickname,
            p.image_map,
            p.image_portrait
            FROM players.players p
            JOIN squad.squad_players sp ON p.id = sp.player_id
                                        AND sp.squad_id = (SELECT squad_id FROM squad.get_active_player_squad(p_player_id));
      END;
      $$;


ALTER FUNCTION squad.get_active_player_squad_players_profiles(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5748 (class 0 OID 0)
-- Dependencies: 411
-- Name: FUNCTION get_active_player_squad_players_profiles(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_active_player_squad_players_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 415 (class 1255 OID 25620)
-- Name: get_other_squad_players_profiles(integer, integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.get_other_squad_players_profiles(p_player_id integer, p_squad_id integer) RETURNS TABLE(other_player_id text, name character varying, second_name character varying, nickname character varying, image_map character varying, image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
 
            SELECT 
             CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS other_player_id
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.name ELSE NULL END AS name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.second_name ELSE NULL END AS second_name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.nickname ELSE NULL END AS nickname
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.image_portrait ELSE NULL END AS image_portrait
            FROM players.players p
            JOIN squad.squad_players sp ON p.id = sp.player_id
                                        AND sp.squad_id = p_squad_id
            JOIN knowledge.known_players_squad_profiles kpsp ON kpsp.player_id = p_player_id
                                                             AND kpsp.squad_id = sp.squad_id
            LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                           AND kpp.other_player_id = p.id;

      END;
      $$;


ALTER FUNCTION squad.get_other_squad_players_profiles(p_player_id integer, p_squad_id integer) OWNER TO postgres;

--
-- TOC entry 5749 (class 0 OID 0)
-- Dependencies: 415
-- Name: FUNCTION get_other_squad_players_profiles(p_player_id integer, p_squad_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_other_squad_players_profiles(p_player_id integer, p_squad_id integer) IS 'get_api';


--
-- TOC entry 460 (class 1255 OID 484739)
-- Name: get_squad_invites(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.get_squad_invites(p_player_id integer) RETURNS TABLE(id integer, squad_name character varying, name character varying, nickname character varying, second_name character varying, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
      BEGIN

            RETURN QUERY
            SELECT si.id, s.squad_name, p."name" ,p.nickname , p.second_name , si.created_at
            FROM squad.squad_invites si
            JOIN squad.squads s ON si.squad_id = s.id
            JOIN players.players AS p ON p.id = si.inviter_player_id 
            WHERE si.invited_player_id = p_player_id
            AND si.status IN (1,4);


      END;
      $$;


ALTER FUNCTION squad.get_squad_invites(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5750 (class 0 OID 0)
-- Dependencies: 460
-- Name: FUNCTION get_squad_invites(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_squad_invites(p_player_id integer) IS 'get_api';


--
-- TOC entry 436 (class 1255 OID 476396)
-- Name: squad_create(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.squad_create(p_player_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_squad_id integer;
BEGIN
PERFORM squad.check_player_not_in_squad(p_player_id);

INSERT INTO squad.squads
DEFAULT VALUES
RETURNING id INTO v_squad_id;

INSERT INTO world.map_tiles_squads_positions
(squad_id, map_id, map_tile_x, map_tile_y)
SELECT
v_squad_id
,map_id
,map_tile_x
,map_tile_y
FROM world.map_tiles_players_positions
WHERE player_id = p_player_id;

INSERT INTO squad.squad_players(squad_id, player_id, squad_role_id)
VALUES(v_squad_id, p_player_id, 1);

END;
$$;


ALTER FUNCTION squad.squad_create(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 463 (class 1255 OID 476474)
-- Name: squad_invite(integer, text, integer, integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.squad_invite(p_player_id integer, p_invited_player_id text, p_invite_type integer, p_squad_role integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_squad_id int;
    v_role_id int;
    v_invited_player_id int;
BEGIN

    v_invited_player_id := players.get_real_player_id(p_invited_player_id);

    -- nie można zaprosić samego siebie
    IF p_player_id = v_invited_player_id THEN
        PERFORM util.raise_error('Cannot invite yourself');
    END IF;

    -- pobierz squad + rolę jednym strzałem
    SELECT squad_id, squad_role_id
    INTO v_squad_id, v_role_id
    FROM squad.squad_players
    WHERE player_id = p_player_id;

    IF v_squad_id IS NULL THEN
        PERFORM util.raise_error('Inviter is not in squad');
    END IF;

    -- tylko lider
    IF v_role_id <> 1 THEN
        PERFORM util.raise_error('Only leader can invite');
    END IF;

    -- target nie może być w squadzie
    PERFORM squad.check_player_not_in_squad(v_invited_player_id);

    -- brak duplikatu (pending)
    IF EXISTS (
        SELECT 1
        FROM squad.squad_invites
        WHERE squad_id = v_squad_id
          AND invited_player_id = v_invited_player_id
          AND status = 1
    ) THEN
        PERFORM util.raise_error('Invite already exists');
    END IF;

    INSERT INTO squad.squad_invites(
        squad_id,
        inviter_player_id,
        invited_player_id,
        status,
        squad_role_id
    )
    VALUES (
        v_squad_id,
        p_player_id,
        v_invited_player_id,
        p_invite_type,
        p_squad_role
    );

END;
$$;


ALTER FUNCTION squad.squad_invite(p_player_id integer, p_invited_player_id text, p_invite_type integer, p_squad_role integer) OWNER TO postgres;

--
-- TOC entry 443 (class 1255 OID 476454)
-- Name: squad_join(integer, integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.squad_join(p_player_id integer, p_squad_invite_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_squad_id integer;
    v_status_id integer;
    v_squad_role_id integer;
BEGIN

PERFORM squad.check_player_not_in_squad(p_player_id);

SELECT
squad_id, status, squad_role_id INTO v_squad_id, v_status_id, v_squad_role_id
FROM squad.squad_invites
WHERE id = p_squad_invite_id
AND invited_player_id = p_player_id
AND status in (1,4)
LIMIT 1;

PERFORM squad.check_player_and_squad_same_tile(p_player_id, v_squad_id);

    IF v_squad_id IS NULL THEN
        PERFORM util.raise_error('Player not invited');
    END IF;

    INSERT INTO squad.squad_players(squad_id, player_id, squad_role_id)
    VALUES(v_squad_id, p_player_id, v_squad_role_id);

IF v_status_id = 1 THEN

    UPDATE squad.squad_invites
    SET status = 2, responded_at = now()
    WHERE id = p_squad_invite_id;

END IF;

END;
$$;


ALTER FUNCTION squad.squad_join(p_player_id integer, p_squad_invite_id integer) OWNER TO postgres;

--
-- TOC entry 345 (class 1255 OID 476404)
-- Name: squad_leave(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.squad_leave(p_player_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_squad_id integer;
    v_players_count integer;
    v_no_leader_left integer;
BEGIN

    SELECT sp.squad_id
    INTO v_squad_id
    FROM squad.squad_players sp
    WHERE sp.player_id = p_player_id;

    IF v_squad_id IS NULL THEN
        PERFORM util.raise_error('Player is not in squad');
    END IF;

    DELETE FROM squad.squad_players
    WHERE squad_id = v_squad_id
    AND player_id = p_player_id;



    SELECT COUNT(*), MIN(squad_role_id)
    INTO v_players_count, v_no_leader_left
    FROM squad.squad_players
    WHERE squad_id = v_squad_id;

    IF v_players_count = 0 THEN
        DELETE FROM squad.squad_invites
        WHERE squad_id = v_squad_id;

        DELETE FROM world.map_tiles_squads_positions
        WHERE squad_id = v_squad_id;

        DELETE FROM squad.squads
        WHERE id = v_squad_id;

    ELSEIF  v_no_leader_left != 1 THEN

        UPDATE squad.squad_players
        SET squad_role_id = 1
        WHERE squad_id = v_squad_id
          AND player_id = (
              SELECT player_id
              FROM squad.squad_players
              WHERE squad_id = v_squad_id
              ORDER BY RANDOM()
              LIMIT 1
          );

    END IF;

END;
$$;


ALTER FUNCTION squad.squad_leave(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 473 (class 1255 OID 22594)
-- Name: cancel_task(integer, character varying); Type: FUNCTION; Schema: tasks; Owner: postgres
--

CREATE FUNCTION tasks.cancel_task(p_player_id integer, p_method_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN


UPDATE tasks.tasks T1 
SET  status = 5
WHERE T1.player_id = p_player_id
    AND T1.method_name = p_method_name
    AND T1.status in (1,2,4);

END;

$$;


ALTER FUNCTION tasks.cancel_task(p_player_id integer, p_method_name character varying) OWNER TO postgres;

--
-- TOC entry 364 (class 1255 OID 22595)
-- Name: insert_task(integer, timestamp without time zone, character varying, jsonb); Type: FUNCTION; Schema: tasks; Owner: postgres
--

CREATE FUNCTION tasks.insert_task(p_player_id integer, scheduled_at timestamp without time zone, p_method_name character varying, p_parameters jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN


INSERT
    INTO
    tasks.tasks (
            player_id,
            status,
            created_at,
            scheduled_at,
            last_executed_at,
            "error",
            method_name,
            method_parameters

        )
VALUES (
            p_player_id,
            1,
            NOW(),
            scheduled_at,
            NULL,
            NULL,
            p_method_name,
            p_parameters

        );

END;

$$;


ALTER FUNCTION tasks.insert_task(p_player_id integer, scheduled_at timestamp without time zone, p_method_name character varying, p_parameters jsonb) OWNER TO postgres;

--
-- TOC entry 400 (class 1255 OID 22596)
-- Name: raise_error(text, text[]); Type: FUNCTION; Schema: util; Owner: postgres
--

CREATE FUNCTION util.raise_error(p_message text, VARIADIC p_args text[] DEFAULT ARRAY[]::text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    msg text;
BEGIN
    -- jeśli nie podano argumentów, używa samego tekstu
    -- przykład użycia PERFORM utils.raise_error('Cannot add % units of item %', p_quantity::text, p_item_id::text);
    msg := format(p_message, VARIADIC p_args);

    RAISE EXCEPTION
        USING ERRCODE = 'P0001',
              MESSAGE = msg;
END;
$$;


ALTER FUNCTION util.raise_error(p_message text, VARIADIC p_args text[]) OWNER TO postgres;

--
-- TOC entry 432 (class 1255 OID 369863)
-- Name: check_is_tile_water(integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.check_is_tile_water(p_map_id integer, p_x integer, p_y integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM world.map_tiles
        WHERE map_id = p_map_id
          AND x = p_x
          AND y = p_y
          AND terrain_type_id IN (8,9)
    );
END;
$$;


ALTER FUNCTION world.check_is_tile_water(p_map_id integer, p_x integer, p_y integer) OWNER TO postgres;

--
-- TOC entry 397 (class 1255 OID 337045)
-- Name: check_player_is_on_tile(integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.check_player_is_on_tile(p_player_id integer, p_map_id integer, p_position_x integer, p_position_y integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM world.map_tiles_players_positions
        WHERE player_id = p_player_id
          AND map_id = p_map_id
          AND map_tile_x = p_position_x
          AND map_tile_y = p_position_y
    ) THEN
        PERFORM util.raise_error('Player is not at the specified map tile position');
    END IF;
END;
$$;


ALTER FUNCTION world.check_player_is_on_tile(p_player_id integer, p_map_id integer, p_position_x integer, p_position_y integer) OWNER TO postgres;

--
-- TOC entry 351 (class 1255 OID 287898)
-- Name: do_map_tile_exploration(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.do_map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_exploration_level integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

    PERFORM world.map_tile_exploration(
        p_player_id,
        p_map_id,
        p_x,
        p_y
    );

    RETURN QUERY SELECT true, 'Exploration completed';

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION world.do_map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_exploration_level integer) OWNER TO postgres;

--
-- TOC entry 5751 (class 0 OID 0)
-- Dependencies: 351
-- Name: FUNCTION do_map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_exploration_level integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_exploration_level integer) IS 'action_api';


--
-- TOC entry 394 (class 1255 OID 287894)
-- Name: do_player_movement(integer, jsonb); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    param jsonb;
    is_success bool;
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

    PERFORM squad.check_player_not_in_squad(p_player_id);

    FOR param IN
        SELECT value
        FROM jsonb_array_elements(p_path)
        ORDER BY (value->>'order')::int ASC
    LOOP
        is_success = world.player_movement(
            p_player_id,
            (param->>'x')::int,
            (param->>'y')::int,
            (param->>'mapId')::int
        );

        IF NOT is_success THEN
            RETURN QUERY SELECT true, 'Stopped';
            RETURN;
        END IF;

    END LOOP;

    RETURN QUERY SELECT true, 'Movement completed';

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$$;


ALTER FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) OWNER TO postgres;

--
-- TOC entry 5752 (class 0 OID 0)
-- Dependencies: 394
-- Name: FUNCTION do_player_movement(p_player_id integer, p_path jsonb); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) IS 'action_api';


--
-- TOC entry 448 (class 1255 OID 23168)
-- Name: get_known_map_region(integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer) RETURNS TABLE(region_id integer, map_id integer, map_tile_x integer, map_tile_y integer, region_name character varying, image_fill character varying, image_outline character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

    RETURN QUERY
    select 
    T1.region_id
    ,T1.map_id 
    ,T1.map_tile_x 
    ,T1.map_tile_y 
    ,T2."name" as region_name
    ,T2.image_fill 
    ,T2.image_outline 
    from world.map_tiles_map_regions T1
    join world.map_regions T2 on T1.region_id = T2.id  
    join world.region_types T3 on T2.region_type_id  = T3.id 
    join knowledge.known_map_tiles T4 on T4.map_id = T1.map_id
                                      AND T4.map_tile_x = T1.map_tile_x
                                      AND T4.map_tile_y = T1.map_tile_y
    where T3.ID = p_region_type
    AND T1.map_id = p_map_id
    AND T4.player_id = p_player_id;

END;
$$;


ALTER FUNCTION world.get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer) OWNER TO postgres;

--
-- TOC entry 5753 (class 0 OID 0)
-- Dependencies: 448
-- Name: FUNCTION get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer) IS 'get_api';


--
-- TOC entry 412 (class 1255 OID 23190)
-- Name: get_known_map_tiles(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_known_map_tiles(p_map_id integer, p_player_id integer) RETURNS TABLE(map_id integer, x integer, y integer, terrain_type_id integer, landscape_type_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

RETURN QUERY
 SELECT 
 T1.map_id,
 T1.x,
 T1.y,

 CASE WHEN T2.player_id IS NULL THEN NULL
    ELSE T1.terrain_type_id 
 END AS terrain_type_id,

 CASE WHEN T2.player_id IS NULL THEN NULL
    ELSE T1.landscape_type_id 
 END AS landscape_type_id

 FROM world.map_tiles T1
 LEFT JOIN knowledge.known_map_tiles T2 on T2.map_id = T1.map_id
                                      AND T2.map_tile_x = T1.x
                                      AND T2.map_tile_y = T1.y
                                      AND T2.player_id = p_player_id
WHERE T1.map_id = p_map_id
;

END;
$$;


ALTER FUNCTION world.get_known_map_tiles(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5754 (class 0 OID 0)
-- Dependencies: 412
-- Name: FUNCTION get_known_map_tiles(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_tiles(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 472 (class 1255 OID 25668)
-- Name: get_known_map_tiles_resources_on_tile(integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) RETURNS TABLE(map_tiles_resource_id integer, item_id integer, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

RETURN QUERY
    SELECT
    mtr.id AS map_tiles_resource_id
    ,CASE WHEN kmtr.map_tiles_resource_id IS NOT NULL THEN  mtr.item_id  ELSE NULL END AS item_id
    ,CASE WHEN kmtr.map_tiles_resource_id IS NOT NULL THEN  mtr.quantity  ELSE NULL END AS quantity
    FROM world.map_tiles_resources mtr
    LEFT JOIN knowledge.known_map_tiles_resources kmtr ON mtr.id = kmtr.map_tiles_resource_id
                                                       AND kmtr.player_id = p_player_id
    WHERE mtr.map_id = p_map_id
    AND mtr.map_tile_x = p_map_tile_x
    AND mtr.map_tile_y = p_map_tile_y
;

END;
$$;


ALTER FUNCTION world.get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5755 (class 0 OID 0)
-- Dependencies: 472
-- Name: FUNCTION get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 404 (class 1255 OID 484727)
-- Name: get_known_players_positions(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) RETURNS TABLE(x integer, y integer, other_players jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN

RETURN QUERY

WITH player_tiles_view_range AS (
    SELECT 
         mp.map_tile_x
         ,mp.map_tile_y
    FROM world.map_tiles_players_positions mp
    WHERE mp.player_id = p_player_id
      AND mp.map_id = p_map_id
    LIMIT 1
)

SELECT
    T1.x,
    T1.y,
    jsonb_agg(
        jsonb_build_object(
            'otherPlayerId',T1.otherPlayerId,
            'imageMap',T1.imageMap,
            'inSquad',T1.inSquad
        )
    ) AS other_players
    
FROM (

    
        SELECT
            COALESCE(MTSP.map_tile_x, mp.map_tile_x) AS x
            ,COALESCE(MTSP.map_tile_y, mp.map_tile_y) AS y
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS otherPlayerId
            ,COALESCE(S.squad_image_map, p.image_map) AS imageMap
            ,MTSP.squad_id IS NOT NULL AS inSquad
                    FROM world.map_tiles_players_positions mp
                    JOIN players.players p ON mp.player_id = p.id
                    JOIN player_tiles_view_range ptvr ON ptvr.map_tile_x = mp.map_tile_x
                                       AND ptvr.map_tile_y = mp.map_tile_y
                    LEFT JOIN knowledge.known_players_positions kp ON kp.other_player_id = p.id
                                                                    AND kp.player_id = p_player_id
                    LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                                   AND kpp.other_player_id = p.id
                    LEFT JOIN squad.squad_players SP ON SP.player_id = mp.player_id
                    LEFT JOIN squad.squads S ON S.id = SP.squad_id
                    LEFT JOIN world.map_tiles_squads_positions MTSP ON MTSP.squad_id = SP.squad_id
                    WHERE mp.map_id = p_map_id
                     AND mp.player_id != 1          
UNION
        SELECT
            COALESCE(MTSP.map_tile_x, mp.map_tile_x) AS x
            ,COALESCE(MTSP.map_tile_y, mp.map_tile_y) AS y
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS otherPlayerId
            ,COALESCE(S.squad_image_map, p.image_map) AS imageMap
            ,MTSP.squad_id IS NOT NULL AS inSquad
                    FROM world.map_tiles_players_positions mp
                    JOIN players.players p ON mp.player_id = p.id
                    JOIN knowledge.known_players_positions kp ON kp.other_player_id = p.id
                    LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                                   AND kpp.other_player_id = p.id
                    LEFT JOIN squad.squad_players SP ON SP.player_id = mp.player_id
                    LEFT JOIN squad.squads S ON S.id = SP.squad_id
                    LEFT JOIN world.map_tiles_squads_positions MTSP ON MTSP.squad_id = SP.squad_id
                    WHERE mp.map_id = p_map_id
                     AND kp.player_id = p_player_id
                     AND mp.player_id != p_player_id
) T1
        GROUP BY
            T1.x,
            T1.y;

END;
$$;


ALTER FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5756 (class 0 OID 0)
-- Dependencies: 404
-- Name: FUNCTION get_known_players_positions(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 247 (class 1259 OID 22599)
-- Name: landscape_types; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.landscape_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE world.landscape_types OWNER TO postgres;

--
-- TOC entry 392 (class 1255 OID 22605)
-- Name: get_landscape_types(); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_landscape_types() RETURNS SETOF world.landscape_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.landscape_types;
      END;
      $$;


ALTER FUNCTION world.get_landscape_types() OWNER TO postgres;

--
-- TOC entry 5757 (class 0 OID 0)
-- Dependencies: 392
-- Name: FUNCTION get_landscape_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types() IS 'automatic_get_api';


--
-- TOC entry 414 (class 1255 OID 22606)
-- Name: get_landscape_types_by_key(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_landscape_types_by_key(p_id integer) RETURNS SETOF world.landscape_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.landscape_types
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION world.get_landscape_types_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5758 (class 0 OID 0)
-- Dependencies: 414
-- Name: FUNCTION get_landscape_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 248 (class 1259 OID 22607)
-- Name: map_tiles; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.map_tiles (
    map_id integer CONSTRAINT map_tiles_map_id_not_null1 NOT NULL,
    x integer CONSTRAINT map_tiles_x_not_null1 NOT NULL,
    y integer CONSTRAINT map_tiles_y_not_null1 NOT NULL,
    terrain_type_id integer DEFAULT 1 CONSTRAINT map_tiles_terrain_type_id_not_null1 NOT NULL,
    landscape_type_id integer
);


ALTER TABLE world.map_tiles OWNER TO postgres;

--
-- TOC entry 471 (class 1255 OID 22615)
-- Name: get_map_tiles(); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_map_tiles() RETURNS SETOF world.map_tiles
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.map_tiles;
      END;
      $$;


ALTER FUNCTION world.get_map_tiles() OWNER TO postgres;

--
-- TOC entry 5759 (class 0 OID 0)
-- Dependencies: 471
-- Name: FUNCTION get_map_tiles(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles() IS 'automatic_get_api';


--
-- TOC entry 401 (class 1255 OID 22616)
-- Name: get_map_tiles_by_key(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_map_tiles_by_key(p_map_id integer) RETURNS SETOF world.map_tiles
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.map_tiles
          WHERE "map_id" = p_map_id;
      END;
      $$;


ALTER FUNCTION world.get_map_tiles_by_key(p_map_id integer) OWNER TO postgres;

--
-- TOC entry 5760 (class 0 OID 0)
-- Dependencies: 401
-- Name: FUNCTION get_map_tiles_by_key(p_map_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 373 (class 1255 OID 22617)
-- Name: get_player_map(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_map(p_player_id integer) RETURNS TABLE(map_id integer)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
             SELECT  T1.map_id 
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            WHERE T1.player_id = p_player_id;
      END;
      $$;


ALTER FUNCTION world.get_player_map(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5761 (class 0 OID 0)
-- Dependencies: 373
-- Name: FUNCTION get_player_map(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_map(p_player_id integer) IS 'get_api';


--
-- TOC entry 426 (class 1255 OID 484711)
-- Name: get_player_position(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) RETURNS TABLE(x integer, y integer, image_map character varying, in_squad boolean)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
             SELECT   COALESCE(MTSP.map_tile_x ,T1.map_tile_x) AS X 
                     ,COALESCE(MTSP.map_tile_y, T1.map_tile_y) AS Y
                     ,COALESCE(S.squad_image_map, t2.image_map) AS image_map
                     ,CASE WHEN MTSP.squad_id IS NOT NULL THEN TRUE
                      ELSE FALSE END AS in_squad
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            LEFT JOIN squad.squad_players SP ON SP.player_id = T1.player_id
            LEFT JOIN squad.squads S ON S.id = SP.squad_id
            LEFT JOIN world.map_tiles_squads_positions MTSP ON MTSP.squad_id = SP.squad_id
            WHERE T1.map_id = p_map_id
             AND T1.player_id = p_player_id;
      END;
      $$;


ALTER FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5762 (class 0 OID 0)
-- Dependencies: 426
-- Name: FUNCTION get_player_position(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 388 (class 1255 OID 484743)
-- Name: get_players_on_tile(integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_players_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) RETURNS TABLE(other_player_id text, name character varying, second_name character varying, nickname character varying, image_portrait character varying, squad_id integer, squad_name character varying, squad_image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

IF EXISTS (
    SELECT 1
     FROM world.map_tiles_players_positions
     WHERE map_id = p_map_id
      AND player_id = p_player_id
      AND map_tile_x = p_map_tile_x
      AND map_tile_y = p_map_tile_y
    ) THEN

RETURN QUERY          
SELECT       CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS other_player_id
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.name ELSE NULL END AS name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.second_name ELSE NULL END AS second_name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.nickname ELSE NULL END AS nickname
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.image_portrait ELSE NULL END AS image_portrait
            ,S.id AS squad_id
            ,S.squad_name
            ,S.squad_image_portrait 
FROM world.map_tiles_players_positions mp
JOIN players.players p ON mp.player_id = p.id
LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                               AND kpp.other_player_id = p.id
LEFT JOIN squad.squad_players SP ON SP.player_id = mp.player_id
LEFT JOIN squad.squads S ON S.id = SP.squad_id
WHERE mp.map_tile_x = p_map_tile_x
AND mp.map_tile_y = p_map_tile_y
AND mp.map_id = p_map_id
AND mp.player_id != p_player_id;

ELSE

RETURN QUERY          
SELECT       CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS other_player_id
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.name ELSE NULL END AS name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.second_name ELSE NULL END AS second_name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.nickname ELSE NULL END AS nickname
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.image_portrait ELSE NULL END AS image_portrait
            ,S.id AS squad_id
            ,S.squad_name
            ,S.squad_image_portrait 
FROM world.map_tiles_players_positions mp
JOIN players.players p ON mp.player_id = p.id
JOIN knowledge.known_players_positions kp ON p.id = kp.other_player_id
LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                               AND kpp.other_player_id = p.id
LEFT JOIN squad.squad_players SP ON SP.player_id = mp.player_id
LEFT JOIN squad.squads S ON S.id = SP.squad_id
WHERE mp.map_tile_x = p_map_tile_x
AND mp.map_tile_y = p_map_tile_y
AND mp.map_id = p_map_id
AND kp.player_id = p_player_id
AND mp.player_id != p_player_id ;

END IF;


END;
$$;


ALTER FUNCTION world.get_players_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5763 (class 0 OID 0)
-- Dependencies: 388
-- Name: FUNCTION get_players_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_players_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 249 (class 1259 OID 22621)
-- Name: terrain_types; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.terrain_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE world.terrain_types OWNER TO postgres;

--
-- TOC entry 442 (class 1255 OID 22627)
-- Name: get_terrain_types(); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_terrain_types() RETURNS SETOF world.terrain_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.terrain_types;
      END;
      $$;


ALTER FUNCTION world.get_terrain_types() OWNER TO postgres;

--
-- TOC entry 5764 (class 0 OID 0)
-- Dependencies: 442
-- Name: FUNCTION get_terrain_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types() IS 'automatic_get_api';


--
-- TOC entry 339 (class 1255 OID 22628)
-- Name: get_terrain_types_by_key(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_terrain_types_by_key(p_id integer) RETURNS SETOF world.terrain_types
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM world.terrain_types
          WHERE "id" = p_id;
      END;
      $$;


ALTER FUNCTION world.get_terrain_types_by_key(p_id integer) OWNER TO postgres;

--
-- TOC entry 5765 (class 0 OID 0)
-- Dependencies: 339
-- Name: FUNCTION get_terrain_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 372 (class 1255 OID 353447)
-- Name: map_tile_exploration(integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_map_tiles_resource_id integer;
BEGIN

SELECT id
INTO v_map_tiles_resource_id
FROM world.map_tiles_resources
WHERE map_id = p_map_id
AND map_tile_x = p_x
AND map_tile_y = p_y
AND id NOT IN (SELECT map_tiles_resource_id FROM knowledge.known_map_tiles_resources WHERE player_id = p_player_id)
ORDER BY random()
LIMIT 1;

IF v_map_tiles_resource_id IS NOT NULL THEN

    INSERT INTO knowledge.known_map_tiles_resources
    (player_id, map_tiles_resource_id)
    VALUES(p_player_id, v_map_tiles_resource_id);

END IF;

END;
$$;


ALTER FUNCTION world.map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer) OWNER TO postgres;

--
-- TOC entry 352 (class 1255 OID 369862)
-- Name: map_tile_reveal(integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.map_tile_reveal(p_player_id integer, p_map_id integer, p_x integer, p_y integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

IF NOT EXISTS (
SELECT 1
FROM knowledge.known_map_tiles
WHERE player_id = p_player_id
AND map_id = p_map_id
AND map_tile_x = p_x
AND map_tile_y = p_y
LIMIT 1
)
 THEN

    INSERT INTO knowledge.known_map_tiles
    (player_id, map_id, map_tile_x, map_tile_y)
    VALUES(p_player_id, p_map_id, p_x, p_y);

END IF;

END;
$$;


ALTER FUNCTION world.map_tile_reveal(p_player_id integer, p_map_id integer, p_x integer, p_y integer) OWNER TO postgres;

--
-- TOC entry 439 (class 1255 OID 369864)
-- Name: player_movement(integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.player_movement(p_player_id integer, p_x integer, p_y integer, p_map_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

PERFORM squad.check_player_not_in_squad(p_player_id);
PERFORM world.map_tile_reveal(p_player_id,p_map_id, p_x, p_y );

    IF world.check_is_tile_water(p_map_id, p_x, p_y) THEN
        RETURN false;
    END IF;

    UPDATE world.map_tiles_players_positions
    SET
        map_tile_x = p_x,
        map_tile_y = p_y
    WHERE player_id = p_player_id
      AND map_id = p_map_id;


RETURN true;

END;
$$;


ALTER FUNCTION world.player_movement(p_player_id integer, p_x integer, p_y integer, p_map_id integer) OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 22630)
-- Name: abilities_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

ALTER TABLE attributes.abilities ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME attributes.abilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 251 (class 1259 OID 22631)
-- Name: ability_skill_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_skill_requirements (
    ability_id integer NOT NULL,
    skill_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_skill_requirements OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 22638)
-- Name: ability_stat_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_stat_requirements (
    ability_id integer NOT NULL,
    stat_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_stat_requirements OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 22446)
-- Name: player_abilities; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.player_abilities (
    id integer NOT NULL,
    player_id integer NOT NULL,
    ability_id integer NOT NULL,
    value integer NOT NULL
);


ALTER TABLE attributes.player_abilities OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 22645)
-- Name: player_abilities_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

ALTER TABLE attributes.player_abilities ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME attributes.player_abilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 254 (class 1259 OID 22646)
-- Name: player_skills; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.player_skills (
    id integer NOT NULL,
    player_id integer NOT NULL,
    skill_id integer NOT NULL,
    value integer NOT NULL
);


ALTER TABLE attributes.player_skills OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 22653)
-- Name: player_skills_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

ALTER TABLE attributes.player_skills ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME attributes.player_skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 256 (class 1259 OID 22654)
-- Name: player_stats; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.player_stats (
    id integer NOT NULL,
    player_id integer NOT NULL,
    stat_id integer NOT NULL,
    value integer NOT NULL
);


ALTER TABLE attributes.player_stats OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 22661)
-- Name: player_stats_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

ALTER TABLE attributes.player_stats ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME attributes.player_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 258 (class 1259 OID 22662)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

ALTER TABLE attributes.roles ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME attributes.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 259 (class 1259 OID 22663)
-- Name: skills_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

ALTER TABLE attributes.skills ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME attributes.skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 260 (class 1259 OID 22664)
-- Name: stats_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

ALTER TABLE attributes.stats ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME attributes.stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 261 (class 1259 OID 22665)
-- Name: accounts; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.accounts (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    type character varying(255) NOT NULL,
    provider character varying(255) NOT NULL,
    "providerAccountId" character varying(255) NOT NULL,
    refresh_token text,
    access_token text,
    expires_at bigint,
    id_token text,
    scope text,
    session_state text,
    token_type text
);


ALTER TABLE auth.accounts OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 22675)
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

ALTER TABLE auth.accounts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME auth.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 263 (class 1259 OID 22676)
-- Name: sessions; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.sessions (
    id integer NOT NULL,
    "userId" integer NOT NULL,
    expires timestamp with time zone NOT NULL,
    "sessionToken" character varying(255) NOT NULL
);


ALTER TABLE auth.sessions OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 22683)
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

ALTER TABLE auth.sessions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME auth.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 265 (class 1259 OID 22684)
-- Name: users; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.users (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    "emailVerified" timestamp with time zone,
    image text,
    password character varying(255)
);


ALTER TABLE auth.users OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 22690)
-- Name: users_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

ALTER TABLE auth.users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME auth.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 267 (class 1259 OID 22691)
-- Name: verification_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.verification_token (
    identifier text NOT NULL,
    expires timestamp with time zone NOT NULL,
    token text NOT NULL
);


ALTER TABLE auth.verification_token OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 22699)
-- Name: building_roles; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_roles (
    building_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE buildings.building_roles OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 22705)
-- Name: building_types_id_seq; Type: SEQUENCE; Schema: buildings; Owner: postgres
--

ALTER TABLE buildings.building_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME buildings.building_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 270 (class 1259 OID 22706)
-- Name: buildings_id_seq; Type: SEQUENCE; Schema: buildings; Owner: postgres
--

ALTER TABLE buildings.buildings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME buildings.buildings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 271 (class 1259 OID 22707)
-- Name: cities_id_seq; Type: SEQUENCE; Schema: cities; Owner: postgres
--

ALTER TABLE cities.cities ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME cities.cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 272 (class 1259 OID 22708)
-- Name: city_roles; Type: TABLE; Schema: cities; Owner: postgres
--

CREATE TABLE cities.city_roles (
    city_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE cities.city_roles OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 22714)
-- Name: district_roles; Type: TABLE; Schema: districts; Owner: postgres
--

CREATE TABLE districts.district_roles (
    district_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE districts.district_roles OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 22720)
-- Name: district_types_id_seq; Type: SEQUENCE; Schema: districts; Owner: postgres
--

ALTER TABLE districts.district_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME districts.district_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 275 (class 1259 OID 22721)
-- Name: districts_id_seq; Type: SEQUENCE; Schema: districts; Owner: postgres
--

ALTER TABLE districts.districts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME districts.districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 310 (class 1259 OID 25486)
-- Name: inventory_container_player_access; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_container_player_access (
    inventory_container_id integer CONSTRAINT inventory_container_player_acce_inventory_container_id_not_null NOT NULL,
    player_id integer NOT NULL
);


ALTER TABLE inventory.inventory_container_player_access OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 22722)
-- Name: inventory_container_types; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_container_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE inventory.inventory_container_types OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 22726)
-- Name: inventory_container_types_id_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory.inventory_container_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory.inventory_container_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 278 (class 1259 OID 22727)
-- Name: inventory_containers; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_containers (
    id integer NOT NULL,
    inventory_size integer NOT NULL,
    inventory_container_type_id integer DEFAULT 1 NOT NULL,
    owner_id integer NOT NULL,
    CONSTRAINT inventory_containers_inventory_size_check CHECK ((inventory_size > 0))
);


ALTER TABLE inventory.inventory_containers OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 22736)
-- Name: inventory_containers_id_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory.inventory_containers ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory.inventory_containers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 280 (class 1259 OID 22737)
-- Name: inventory_slot_type_item_type; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slot_type_item_type (
    inventory_slot_type_id integer NOT NULL,
    item_type_id integer NOT NULL
);


ALTER TABLE inventory.inventory_slot_type_item_type OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 22742)
-- Name: inventory_slot_types_id_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory.inventory_slot_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory.inventory_slot_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 282 (class 1259 OID 22743)
-- Name: inventory_slots; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slots (
    id integer NOT NULL,
    inventory_container_id integer NOT NULL,
    item_id integer,
    quantity integer,
    inventory_slot_type_id integer NOT NULL,
    CONSTRAINT inventory_slots_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE inventory.inventory_slots OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 22750)
-- Name: inventory_slots_id_seq; Type: SEQUENCE; Schema: inventory; Owner: postgres
--

ALTER TABLE inventory.inventory_slots ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME inventory.inventory_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 284 (class 1259 OID 22751)
-- Name: item_stats_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

ALTER TABLE items.item_stats ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME items.item_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 285 (class 1259 OID 22752)
-- Name: item_types; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.item_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE items.item_types OWNER TO postgres;

--
-- TOC entry 286 (class 1259 OID 22756)
-- Name: item_types_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

ALTER TABLE items.item_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME items.item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 287 (class 1259 OID 22757)
-- Name: items_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

ALTER TABLE items.items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME items.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 325 (class 1259 OID 353511)
-- Name: recipe_materials_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

CREATE SEQUENCE items.recipe_materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE items.recipe_materials_id_seq OWNER TO postgres;

--
-- TOC entry 5766 (class 0 OID 0)
-- Dependencies: 325
-- Name: recipe_materials_id_seq; Type: SEQUENCE OWNED BY; Schema: items; Owner: postgres
--

ALTER SEQUENCE items.recipe_materials_id_seq OWNED BY items.recipe_materials.id;


--
-- TOC entry 324 (class 1259 OID 353495)
-- Name: recipes; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.recipes (
    id integer NOT NULL,
    item_id integer NOT NULL,
    description character varying(500),
    skill_requirement_id integer,
    image character varying(255) DEFAULT 'default_recipe.png'::character varying
);


ALTER TABLE items.recipes OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 353494)
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

CREATE SEQUENCE items.recipes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE items.recipes_id_seq OWNER TO postgres;

--
-- TOC entry 5767 (class 0 OID 0)
-- Dependencies: 323
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: items; Owner: postgres
--

ALTER SEQUENCE items.recipes_id_seq OWNED BY items.recipes.id;


--
-- TOC entry 307 (class 1259 OID 23161)
-- Name: known_map_tiles; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_map_tiles (
    player_id integer NOT NULL,
    map_id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL
);


ALTER TABLE knowledge.known_map_tiles OWNER TO postgres;

--
-- TOC entry 320 (class 1259 OID 25653)
-- Name: known_map_tiles_resources; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_map_tiles_resources (
    player_id integer NOT NULL,
    map_tiles_resource_id integer CONSTRAINT known_map_tiles_resources_map_tiles_resources_id_not_null NOT NULL
);


ALTER TABLE knowledge.known_map_tiles_resources OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 25530)
-- Name: known_players_abilities; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_abilities (
    player_id integer NOT NULL,
    other_player_id integer NOT NULL
);


ALTER TABLE knowledge.known_players_abilities OWNER TO postgres;

--
-- TOC entry 309 (class 1259 OID 25460)
-- Name: known_players_containers; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_containers (
    player_id integer NOT NULL,
    container_id integer NOT NULL
);


ALTER TABLE knowledge.known_players_containers OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 22758)
-- Name: known_players_positions; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_positions (
    player_id integer CONSTRAINT known_players_positions_observer_player_id_not_null NOT NULL,
    other_player_id integer CONSTRAINT known_players_positions_observed_player_id_not_null NOT NULL
);


ALTER TABLE knowledge.known_players_positions OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 25440)
-- Name: known_players_profiles; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_profiles (
    player_id integer NOT NULL,
    other_player_id integer NOT NULL
);


ALTER TABLE knowledge.known_players_profiles OWNER TO postgres;

--
-- TOC entry 312 (class 1259 OID 25514)
-- Name: known_players_skills; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_skills (
    player_id integer NOT NULL,
    other_player_id integer NOT NULL
);


ALTER TABLE knowledge.known_players_skills OWNER TO postgres;

--
-- TOC entry 317 (class 1259 OID 25593)
-- Name: known_players_squad_profiles; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_squad_profiles (
    player_id integer NOT NULL,
    squad_id integer NOT NULL
);


ALTER TABLE knowledge.known_players_squad_profiles OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 25492)
-- Name: known_players_stats; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_stats (
    player_id integer NOT NULL,
    other_player_id integer NOT NULL
);


ALTER TABLE knowledge.known_players_stats OWNER TO postgres;

--
-- TOC entry 289 (class 1259 OID 22763)
-- Name: players; Type: TABLE; Schema: players; Owner: postgres
--

CREATE TABLE players.players (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying(255) NOT NULL,
    image_map character varying(255) DEFAULT 'default.png'::character varying CONSTRAINT players_image_url_not_null NOT NULL,
    image_portrait character varying(255) DEFAULT 'default.png'::character varying NOT NULL,
    is_active boolean DEFAULT false,
    second_name character varying(255) DEFAULT 'Nomad'::character varying NOT NULL,
    nickname character varying(255),
    masked_id uuid DEFAULT gen_random_uuid()
);


ALTER TABLE players.players OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 22779)
-- Name: players_id_seq; Type: SEQUENCE; Schema: players; Owner: postgres
--

ALTER TABLE players.players ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME players.players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 330 (class 1259 OID 476407)
-- Name: squad_invites; Type: TABLE; Schema: squad; Owner: postgres
--

CREATE TABLE squad.squad_invites (
    id integer NOT NULL,
    squad_id integer NOT NULL,
    inviter_player_id integer NOT NULL,
    invited_player_id integer NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    responded_at timestamp without time zone,
    squad_role_id integer DEFAULT 2 NOT NULL
);


ALTER TABLE squad.squad_invites OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 476406)
-- Name: squad_invites_id_seq; Type: SEQUENCE; Schema: squad; Owner: postgres
--

CREATE SEQUENCE squad.squad_invites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE squad.squad_invites_id_seq OWNER TO postgres;

--
-- TOC entry 5768 (class 0 OID 0)
-- Dependencies: 329
-- Name: squad_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: squad; Owner: postgres
--

ALTER SEQUENCE squad.squad_invites_id_seq OWNED BY squad.squad_invites.id;


--
-- TOC entry 332 (class 1259 OID 476460)
-- Name: squad_invites_statuses; Type: TABLE; Schema: squad; Owner: postgres
--

CREATE TABLE squad.squad_invites_statuses (
    id integer NOT NULL,
    description character varying(255)
);


ALTER TABLE squad.squad_invites_statuses OWNER TO postgres;

--
-- TOC entry 331 (class 1259 OID 476459)
-- Name: squad_invites_statuses_id_seq; Type: SEQUENCE; Schema: squad; Owner: postgres
--

CREATE SEQUENCE squad.squad_invites_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE squad.squad_invites_statuses_id_seq OWNER TO postgres;

--
-- TOC entry 5769 (class 0 OID 0)
-- Dependencies: 331
-- Name: squad_invites_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: squad; Owner: postgres
--

ALTER SEQUENCE squad.squad_invites_statuses_id_seq OWNED BY squad.squad_invites_statuses.id;


--
-- TOC entry 314 (class 1259 OID 25567)
-- Name: squad_players; Type: TABLE; Schema: squad; Owner: postgres
--

CREATE TABLE squad.squad_players (
    squad_id integer NOT NULL,
    player_id integer NOT NULL,
    squad_role_id integer DEFAULT 2 NOT NULL
);


ALTER TABLE squad.squad_players OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 476381)
-- Name: squad_roles; Type: TABLE; Schema: squad; Owner: postgres
--

CREATE TABLE squad.squad_roles (
    id integer NOT NULL,
    description character varying(255)
);


ALTER TABLE squad.squad_roles OWNER TO postgres;

--
-- TOC entry 327 (class 1259 OID 476380)
-- Name: squad_roles_id_seq; Type: SEQUENCE; Schema: squad; Owner: postgres
--

ALTER TABLE squad.squad_roles ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME squad.squad_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 316 (class 1259 OID 25575)
-- Name: squads; Type: TABLE; Schema: squad; Owner: postgres
--

CREATE TABLE squad.squads (
    id integer NOT NULL,
    squad_name character varying(255) DEFAULT 'Squad'::character varying CONSTRAINT squads_description_not_null NOT NULL,
    squad_image_map character varying(255) DEFAULT 'default.png'::character varying CONSTRAINT squads_image_map_not_null NOT NULL,
    squad_image_portrait character varying(255) DEFAULT 'default.png'::character varying CONSTRAINT squads_image_portrait_not_null NOT NULL,
    masked_id uuid DEFAULT gen_random_uuid()
);


ALTER TABLE squad.squads OWNER TO postgres;

--
-- TOC entry 315 (class 1259 OID 25574)
-- Name: squads_id_seq; Type: SEQUENCE; Schema: squad; Owner: postgres
--

ALTER TABLE squad.squads ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME squad.squads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 291 (class 1259 OID 22780)
-- Name: status_types; Type: TABLE; Schema: tasks; Owner: postgres
--

CREATE TABLE tasks.status_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE tasks.status_types OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 22785)
-- Name: status_types_id_seq; Type: SEQUENCE; Schema: tasks; Owner: postgres
--

ALTER TABLE tasks.status_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME tasks.status_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 293 (class 1259 OID 22786)
-- Name: tasks; Type: TABLE; Schema: tasks; Owner: postgres
--

CREATE TABLE tasks.tasks (
    id integer NOT NULL,
    player_id integer NOT NULL,
    status integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    scheduled_at timestamp without time zone NOT NULL,
    last_executed_at timestamp without time zone,
    error text,
    method_name character varying(100),
    method_parameters jsonb
);


ALTER TABLE tasks.tasks OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 22796)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: tasks; Owner: postgres
--

ALTER TABLE tasks.tasks ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME tasks.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 295 (class 1259 OID 22797)
-- Name: landscape_types_id_seq; Type: SEQUENCE; Schema: world; Owner: postgres
--

ALTER TABLE world.landscape_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME world.landscape_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 296 (class 1259 OID 22798)
-- Name: map_regions; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.map_regions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    region_type_id integer DEFAULT 1 CONSTRAINT map_regions_type_id_not_null NOT NULL,
    image_outline character varying(255),
    image_fill character varying(255)
);


ALTER TABLE world.map_regions OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 22807)
-- Name: map_regions_id_seq; Type: SEQUENCE; Schema: world; Owner: postgres
--

ALTER TABLE world.map_regions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME world.map_regions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 298 (class 1259 OID 22808)
-- Name: map_tiles_map_regions; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.map_tiles_map_regions (
    region_id integer NOT NULL,
    map_id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL
);


ALTER TABLE world.map_tiles_map_regions OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 22815)
-- Name: map_tiles_players_positions; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.map_tiles_players_positions (
    player_id integer NOT NULL,
    map_id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL
);


ALTER TABLE world.map_tiles_players_positions OWNER TO postgres;

--
-- TOC entry 319 (class 1259 OID 25631)
-- Name: map_tiles_resources; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.map_tiles_resources (
    id integer NOT NULL,
    map_id integer NOT NULL,
    map_tile_x integer CONSTRAINT map_tiles_resources_x_not_null NOT NULL,
    map_tile_y integer CONSTRAINT map_tiles_resources_y_not_null NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 0 NOT NULL
);


ALTER TABLE world.map_tiles_resources OWNER TO postgres;

--
-- TOC entry 318 (class 1259 OID 25630)
-- Name: map_tiles_resources_id_seq; Type: SEQUENCE; Schema: world; Owner: postgres
--

ALTER TABLE world.map_tiles_resources ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME world.map_tiles_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 322 (class 1259 OID 271592)
-- Name: map_tiles_resources_spawn; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.map_tiles_resources_spawn (
    id integer NOT NULL,
    terrain_type_id integer NOT NULL,
    landscape_type_id integer,
    item_id integer NOT NULL,
    min_quantity integer DEFAULT 1 NOT NULL,
    max_quantity integer DEFAULT 1 NOT NULL,
    spawn_chance double precision DEFAULT 1.0 NOT NULL
);


ALTER TABLE world.map_tiles_resources_spawn OWNER TO postgres;

--
-- TOC entry 321 (class 1259 OID 271591)
-- Name: map_tiles_resources_spawn_id_seq; Type: SEQUENCE; Schema: world; Owner: postgres
--

CREATE SEQUENCE world.map_tiles_resources_spawn_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE world.map_tiles_resources_spawn_id_seq OWNER TO postgres;

--
-- TOC entry 5770 (class 0 OID 0)
-- Dependencies: 321
-- Name: map_tiles_resources_spawn_id_seq; Type: SEQUENCE OWNED BY; Schema: world; Owner: postgres
--

ALTER SEQUENCE world.map_tiles_resources_spawn_id_seq OWNED BY world.map_tiles_resources_spawn.id;


--
-- TOC entry 333 (class 1259 OID 484686)
-- Name: map_tiles_squads_positions; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.map_tiles_squads_positions (
    squad_id integer NOT NULL,
    map_id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL
);


ALTER TABLE world.map_tiles_squads_positions OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 22822)
-- Name: maps; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.maps (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE world.maps OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 22827)
-- Name: maps_id_seq; Type: SEQUENCE; Schema: world; Owner: postgres
--

ALTER TABLE world.maps ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME world.maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 302 (class 1259 OID 22828)
-- Name: region_types; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.region_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE world.region_types OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 22833)
-- Name: region_types_id_seq; Type: SEQUENCE; Schema: world; Owner: postgres
--

ALTER TABLE world.region_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME world.region_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 304 (class 1259 OID 22834)
-- Name: terrain_types_id_seq; Type: SEQUENCE; Schema: world; Owner: postgres
--

ALTER TABLE world.terrain_types ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME world.terrain_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 305 (class 1259 OID 22835)
-- Name: v_buildings; Type: VIEW; Schema: world; Owner: postgres
--

CREATE VIEW world.v_buildings AS
 SELECT t1.id,
    t1.city_id,
    t1.city_tile_x,
    t1.city_tile_y,
    t1.name,
    t2.name AS type_name,
    t2.image_url
   FROM (buildings.buildings t1
     JOIN buildings.building_types t2 ON ((t1.building_type_id = t2.id)));


ALTER VIEW world.v_buildings OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 22839)
-- Name: v_districts; Type: VIEW; Schema: world; Owner: postgres
--

CREATE VIEW world.v_districts AS
 SELECT t1.id,
    t1.map_tile_x,
    t1.map_tile_y,
    t1.name,
    t2.name AS type_name,
    t2.move_cost,
    t2.image_url
   FROM (districts.districts t1
     JOIN districts.district_types t2 ON ((t1.district_type_id = t2.id)));


ALTER VIEW world.v_districts OWNER TO postgres;

--
-- TOC entry 5219 (class 2604 OID 353515)
-- Name: recipe_materials id; Type: DEFAULT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipe_materials ALTER COLUMN id SET DEFAULT nextval('items.recipe_materials_id_seq'::regclass);


--
-- TOC entry 5217 (class 2604 OID 353498)
-- Name: recipes id; Type: DEFAULT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipes ALTER COLUMN id SET DEFAULT nextval('items.recipes_id_seq'::regclass);


--
-- TOC entry 5221 (class 2604 OID 476410)
-- Name: squad_invites id; Type: DEFAULT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites ALTER COLUMN id SET DEFAULT nextval('squad.squad_invites_id_seq'::regclass);


--
-- TOC entry 5225 (class 2604 OID 476463)
-- Name: squad_invites_statuses id; Type: DEFAULT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites_statuses ALTER COLUMN id SET DEFAULT nextval('squad.squad_invites_statuses_id_seq'::regclass);


--
-- TOC entry 5213 (class 2604 OID 271595)
-- Name: map_tiles_resources_spawn id; Type: DEFAULT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn ALTER COLUMN id SET DEFAULT nextval('world.map_tiles_resources_spawn_id_seq'::regclass);


--
-- TOC entry 5581 (class 0 OID 22436)
-- Dependencies: 233
-- Data for Name: abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.abilities (id, name, description, image) FROM stdin;
1	Craft	Craft	GiCrafting
2	Explore	Explore	Eye
\.


--
-- TOC entry 5599 (class 0 OID 22631)
-- Dependencies: 251
-- Data for Name: ability_skill_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_skill_requirements (ability_id, skill_id, min_value) FROM stdin;
1	1	1
2	2	1
\.


--
-- TOC entry 5600 (class 0 OID 22638)
-- Dependencies: 252
-- Data for Name: ability_stat_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_stat_requirements (ability_id, stat_id, min_value) FROM stdin;
\.


--
-- TOC entry 5582 (class 0 OID 22446)
-- Dependencies: 234
-- Data for Name: player_abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_abilities (id, player_id, ability_id, value) FROM stdin;
1	1	1	1
2	1	2	1
3	2	1	1
4	2	2	1
5	3	1	1
6	3	2	1
7	4	1	1
8	4	2	1
9	5	1	1
10	5	2	1
\.


--
-- TOC entry 5602 (class 0 OID 22646)
-- Dependencies: 254
-- Data for Name: player_skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_skills (id, player_id, skill_id, value) FROM stdin;
1	1	1	2
2	1	2	2
3	1	3	6
4	1	4	6
5	1	5	2
6	1	6	9
7	2	1	9
8	2	2	8
9	2	3	4
10	2	4	9
11	2	5	1
12	2	6	3
13	3	1	3
14	3	2	8
15	3	3	4
16	3	4	1
17	3	5	9
18	3	6	4
19	4	1	5
20	4	2	2
21	4	3	5
22	4	4	4
23	4	5	8
24	4	6	6
25	5	1	7
26	5	2	6
27	5	3	5
28	5	4	3
29	5	5	5
30	5	6	8
\.


--
-- TOC entry 5604 (class 0 OID 22654)
-- Dependencies: 256
-- Data for Name: player_stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_stats (id, player_id, stat_id, value) FROM stdin;
1	1	1	6
2	1	4	8
3	1	7	3
4	1	2	5
5	1	3	4
6	1	6	9
7	1	9	4
8	1	5	6
9	1	8	4
10	2	1	4
11	2	4	3
12	2	7	5
13	2	2	7
14	2	3	2
15	2	6	2
16	2	9	8
17	2	5	6
18	2	8	4
19	3	1	7
20	3	4	6
21	3	7	6
22	3	2	4
23	3	3	1
24	3	6	7
25	3	9	10
26	3	5	10
27	3	8	3
28	4	1	1
29	4	4	4
30	4	7	8
31	4	2	5
32	4	3	8
33	4	6	3
34	4	9	4
35	4	5	9
36	4	8	10
37	5	1	4
38	5	4	3
39	5	7	5
40	5	2	9
41	5	3	6
42	5	6	9
43	5	9	4
44	5	5	8
45	5	8	5
\.


--
-- TOC entry 5583 (class 0 OID 22458)
-- Dependencies: 235
-- Data for Name: roles; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.roles (id, name) FROM stdin;
1	Owner
\.


--
-- TOC entry 5584 (class 0 OID 22464)
-- Dependencies: 236
-- Data for Name: skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.skills (id, name, description, image) FROM stdin;
1	Crafting	Crafting	GiCrafting
2	Survival	Survival	TreePine
3	Pathfinding	Pathfinding	GiFootsteps
4	Crafting Stone Axe	Crafting Stone Axe	GiStoneAxe
5	Stone Axe	Stone Axe	GiStoneAxe
6	Crafting Rope	Crafting Rope	GiRopeCoil
\.


--
-- TOC entry 5585 (class 0 OID 22474)
-- Dependencies: 237
-- Data for Name: stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.stats (id, name, description, image) FROM stdin;
1	Health	Health	Heart
4	Dexterity	Dexterity	Rabbit
7	Charisma	Charisma	Speech
2	Strength	Strength	HandFist
3	Stamina	Stamina	Activity
6	Intuition	Intuition	GiCrystalBall
9	Wisdom	Wisdom	BookOpenText
5	Perception	Perception	GiEyeTarget
8	Intelligence	Intelligence	Brain
\.


--
-- TOC entry 5609 (class 0 OID 22665)
-- Dependencies: 261
-- Data for Name: accounts; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.accounts (id, "userId", type, provider, "providerAccountId", refresh_token, access_token, expires_at, id_token, scope, session_state, token_type) FROM stdin;
\.


--
-- TOC entry 5611 (class 0 OID 22676)
-- Dependencies: 263
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.sessions (id, "userId", expires, "sessionToken") FROM stdin;
\.


--
-- TOC entry 5613 (class 0 OID 22684)
-- Dependencies: 265
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.users (id, name, email, "emailVerified", image, password) FROM stdin;
1	ciabat	pszabat001@gmail.com	\N	\N	$2b$10$4IQKRdaQ8l29u9KEdy6G6esjYGPJe9rQsWlAqPSe0OgbzyjsV6rCW
3	siabat	example@example.com	\N	\N	$2b$10$mA6YTp9nbDRMb2LbiCg0oOS3d0ivwISpT3Fp7JPmGvWkGJ840I9kW
\.


--
-- TOC entry 5615 (class 0 OID 22691)
-- Dependencies: 267
-- Data for Name: verification_token; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.verification_token (identifier, expires, token) FROM stdin;
\.


--
-- TOC entry 5616 (class 0 OID 22699)
-- Dependencies: 268
-- Data for Name: building_roles; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_roles (building_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5586 (class 0 OID 22487)
-- Dependencies: 238
-- Data for Name: building_types; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_types (id, name, image_url) FROM stdin;
1	Townhall	Townhall.png
2	Marketplace	Marketplace.png
3	Shacks	Shacks.png
4	Logistics	Logistics.png
\.


--
-- TOC entry 5587 (class 0 OID 22494)
-- Dependencies: 239
-- Data for Name: buildings; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.buildings (id, city_id, city_tile_x, city_tile_y, building_type_id, name) FROM stdin;
\.


--
-- TOC entry 5588 (class 0 OID 22505)
-- Dependencies: 240
-- Data for Name: cities; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.cities (id, map_id, map_tile_x, map_tile_y, name, move_cost, image_url) FROM stdin;
\.


--
-- TOC entry 5620 (class 0 OID 22708)
-- Dependencies: 272
-- Data for Name: city_roles; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.city_roles (city_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5589 (class 0 OID 22516)
-- Dependencies: 241
-- Data for Name: city_tiles; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.city_tiles (city_id, x, y, terrain_type_id, landscape_type_id) FROM stdin;
2	1	1	1	\N
2	2	1	1	\N
2	3	1	1	\N
2	4	1	1	\N
2	5	1	1	\N
2	6	1	1	\N
2	7	1	1	\N
2	8	1	1	\N
2	9	1	1	\N
2	10	1	1	\N
2	1	2	1	\N
2	2	2	1	\N
2	3	2	1	\N
2	4	2	1	\N
2	5	2	1	\N
2	6	2	1	\N
2	7	2	1	\N
2	8	2	1	\N
2	9	2	1	\N
2	10	2	1	\N
2	1	3	1	\N
2	2	3	1	\N
2	3	3	1	\N
2	4	3	1	\N
2	5	3	1	\N
2	6	3	1	\N
2	7	3	1	\N
2	8	3	1	\N
2	9	3	1	\N
2	10	3	1	\N
2	1	4	1	\N
2	2	4	1	\N
2	3	4	1	\N
2	4	4	1	\N
2	5	4	1	\N
2	6	4	1	\N
2	7	4	1	\N
2	8	4	1	\N
2	9	4	1	\N
2	10	4	1	\N
2	1	5	1	\N
2	2	5	1	\N
2	3	5	1	\N
2	4	5	1	\N
2	5	5	1	\N
2	6	5	1	\N
2	7	5	1	\N
2	8	5	1	\N
2	9	5	1	\N
2	10	5	1	\N
2	1	6	1	\N
2	2	6	1	\N
2	3	6	1	\N
2	4	6	1	\N
2	5	6	1	\N
2	6	6	1	\N
2	7	6	1	\N
2	8	6	1	\N
2	9	6	1	\N
2	10	6	1	\N
2	1	7	1	\N
2	2	7	1	\N
2	3	7	1	\N
2	4	7	1	\N
2	5	7	1	\N
2	6	7	1	\N
2	7	7	1	\N
2	8	7	1	\N
2	9	7	1	\N
2	10	7	1	\N
2	1	8	1	\N
2	2	8	1	\N
2	3	8	1	\N
2	4	8	1	\N
2	5	8	1	\N
2	6	8	1	\N
2	7	8	1	\N
2	8	8	1	\N
2	9	8	1	\N
2	10	8	1	\N
2	1	9	1	\N
2	2	9	1	\N
2	3	9	1	\N
2	4	9	1	\N
2	5	9	1	\N
2	6	9	1	\N
2	7	9	1	\N
2	8	9	1	\N
2	9	9	1	\N
2	10	9	1	\N
2	1	10	1	\N
2	2	10	1	\N
2	3	10	1	\N
2	4	10	1	\N
2	5	10	1	\N
2	6	10	1	\N
2	7	10	1	\N
2	8	10	1	\N
2	9	10	1	\N
2	10	10	1	\N
\.


--
-- TOC entry 5621 (class 0 OID 22714)
-- Dependencies: 273
-- Data for Name: district_roles; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_roles (district_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5590 (class 0 OID 22527)
-- Dependencies: 242
-- Data for Name: district_types; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_types (id, name, move_cost, image_url) FROM stdin;
1	Farmland	1	full_farmland.png
\.


--
-- TOC entry 5591 (class 0 OID 22535)
-- Dependencies: 243
-- Data for Name: districts; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.districts (id, map_id, map_tile_x, map_tile_y, district_type_id, name) FROM stdin;
\.


--
-- TOC entry 5656 (class 0 OID 25486)
-- Dependencies: 310
-- Data for Name: inventory_container_player_access; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_container_player_access (inventory_container_id, player_id) FROM stdin;
1	1
2	1
1	2
2	2
3	1
3	2
4	1
4	2
1	3
2	3
3	3
4	3
5	1
5	2
5	3
6	1
6	2
6	3
1	4
2	4
3	4
4	4
5	4
6	4
7	1
7	2
7	3
7	4
8	1
8	2
8	3
8	4
1	5
2	5
3	5
4	5
5	5
6	5
7	5
8	5
9	5
10	5
\.


--
-- TOC entry 5624 (class 0 OID 22722)
-- Dependencies: 276
-- Data for Name: inventory_container_types; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_container_types (id, name) FROM stdin;
1	Player
2	PlayerGear
3	Building
4	District
\.


--
-- TOC entry 5626 (class 0 OID 22727)
-- Dependencies: 278
-- Data for Name: inventory_containers; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_containers (id, inventory_size, inventory_container_type_id, owner_id) FROM stdin;
1	9	1	1
2	13	2	1
3	9	1	2
4	13	2	2
5	9	1	3
6	13	2	3
7	9	1	4
8	13	2	4
9	9	1	5
10	13	2	5
\.


--
-- TOC entry 5628 (class 0 OID 22737)
-- Dependencies: 280
-- Data for Name: inventory_slot_type_item_type; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slot_type_item_type (inventory_slot_type_id, item_type_id) FROM stdin;
1	1
2	3
3	10
4	10
5	4
6	7
14	2
13	5
13	6
12	5
12	6
11	8
10	9
9	9
8	5
7	5
\.


--
-- TOC entry 5592 (class 0 OID 22557)
-- Dependencies: 244
-- Data for Name: inventory_slot_types; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slot_types (id, name) FROM stdin;
2	Neck
3	Left hand
4	Right hand
5	Chest
6	Waist
7	Left waist
8	Right waist
9	Left finger
10	Right finger
11	Feets
12	Left hand gear
13	Right hand gear
1	Any
14	Head
\.


--
-- TOC entry 5630 (class 0 OID 22743)
-- Dependencies: 282
-- Data for Name: inventory_slots; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slots (id, inventory_container_id, item_id, quantity, inventory_slot_type_id) FROM stdin;
10	2	\N	\N	2
32	4	\N	\N	2
33	4	\N	\N	3
34	4	\N	\N	4
35	4	\N	\N	5
36	4	\N	\N	6
38	4	\N	\N	8
39	4	\N	\N	9
40	4	\N	\N	10
41	4	\N	\N	11
43	4	\N	\N	13
44	4	\N	\N	14
53	5	\N	\N	1
54	6	\N	\N	2
55	6	\N	\N	3
56	6	\N	\N	4
57	6	\N	\N	5
58	6	\N	\N	6
60	6	\N	\N	8
62	6	\N	\N	10
63	6	\N	\N	11
64	6	\N	\N	12
65	6	\N	\N	13
66	6	\N	\N	14
67	7	\N	\N	1
68	7	\N	\N	1
69	7	\N	\N	1
70	7	\N	\N	1
71	7	\N	\N	1
72	7	\N	\N	1
73	7	\N	\N	1
74	7	\N	\N	1
75	7	\N	\N	1
76	8	\N	\N	2
77	8	\N	\N	3
78	8	\N	\N	4
79	8	\N	\N	5
80	8	\N	\N	6
81	8	\N	\N	7
82	8	\N	\N	8
83	8	\N	\N	9
84	8	\N	\N	10
85	8	\N	\N	11
86	8	\N	\N	12
87	8	\N	\N	13
88	8	\N	\N	14
42	4	\N	\N	12
51	5	\N	\N	1
15	2	\N	\N	7
3	1	7	1	1
47	5	6	1	1
21	2	\N	\N	13
16	2	\N	\N	8
45	5	5	1	1
4	1	7	1	1
50	5	\N	\N	1
48	5	6	1	1
49	5	\N	\N	1
22	2	\N	\N	14
2	1	1	1	1
5	1	6	1	1
9	1	\N	\N	1
89	9	\N	\N	1
90	9	\N	\N	1
91	9	\N	\N	1
92	9	\N	\N	1
93	9	\N	\N	1
94	9	\N	\N	1
95	9	\N	\N	1
96	9	\N	\N	1
97	9	\N	\N	1
98	10	\N	\N	2
99	10	\N	\N	3
100	10	\N	\N	4
101	10	\N	\N	5
102	10	\N	\N	6
103	10	\N	\N	7
104	10	\N	\N	8
105	10	\N	\N	9
106	10	\N	\N	10
107	10	\N	\N	11
108	10	\N	\N	12
109	10	\N	\N	13
110	10	\N	\N	14
24	3	5	1	1
37	4	\N	\N	7
20	2	8	1	12
6	1	\N	\N	1
13	2	\N	\N	5
19	2	\N	\N	11
23	3	7	1	1
59	6	\N	\N	7
46	5	5	1	1
61	6	\N	\N	9
14	2	\N	\N	6
52	5	\N	\N	1
28	3	7	1	1
12	2	\N	\N	4
29	3	7	1	1
11	2	\N	\N	3
18	2	\N	\N	10
30	3	6	1	1
7	1	\N	\N	1
25	3	7	1	1
8	1	\N	\N	1
1	1	6	1	1
17	2	\N	\N	9
26	3	6	1	1
31	3	6	1	1
27	3	1	1	1
\.


--
-- TOC entry 5593 (class 0 OID 22568)
-- Dependencies: 245
-- Data for Name: item_stats; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_stats (id, item_id, stat_id, value) FROM stdin;
\.


--
-- TOC entry 5633 (class 0 OID 22752)
-- Dependencies: 285
-- Data for Name: item_types; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_types (id, name) FROM stdin;
2	Helmet
3	Trinket
4	Armor
5	Weapon
6	Shield
7	Belt
8	Boots
9	Ring
10	Glove
1	Material
\.


--
-- TOC entry 5594 (class 0 OID 22577)
-- Dependencies: 246
-- Data for Name: items; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.items (id, name, description, image, item_type_id) FROM stdin;
2	Sword	Sword	Sword	5
3	Helmet	Helmet	GiCrestedHelmet	2
4	Wood	Wood	GiWoodPile	1
8	Stone Axe	Stone Axe	GiStoneAxe	5
5	Stone	Stone	GiStoneBlock	1
1	Straw	Straw	GiHighGrass	1
6	Mushroom	Mushroom	GiMushroomGills	1
7	Rope	Rope	GiRopeCoil	1
\.


--
-- TOC entry 5672 (class 0 OID 353512)
-- Dependencies: 326
-- Data for Name: recipe_materials; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.recipe_materials (id, recipe_id, item_id, quantity) FROM stdin;
1	1	7	1
2	1	4	4
3	1	5	3
4	2	1	2
\.


--
-- TOC entry 5670 (class 0 OID 353495)
-- Dependencies: 324
-- Data for Name: recipes; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.recipes (id, item_id, description, skill_requirement_id, image) FROM stdin;
1	8	Crafting Stone Axe	4	GiStoneAxe
2	7	Crafting Rope	6	GiRopeCoil
\.


--
-- TOC entry 5653 (class 0 OID 23161)
-- Dependencies: 307
-- Data for Name: known_map_tiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_map_tiles (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
1	1	1	1
1	1	2	1
1	1	3	1
1	1	4	1
1	1	5	1
1	1	6	1
1	1	7	1
1	1	8	1
1	1	9	1
1	1	10	1
1	1	11	1
1	1	12	1
1	1	13	1
1	1	14	1
1	1	15	1
1	1	1	2
1	1	2	2
1	1	3	2
1	1	4	2
1	1	5	2
1	1	6	2
1	1	7	2
1	1	8	2
1	1	9	2
1	1	10	2
1	1	11	2
1	1	12	2
1	1	13	2
1	1	14	2
1	1	15	2
1	1	1	3
1	1	2	3
1	1	3	3
1	1	4	3
1	1	5	3
1	1	6	3
1	1	7	3
1	1	8	3
1	1	9	3
1	1	10	3
1	1	11	3
1	1	12	3
1	1	13	3
1	1	14	3
1	1	15	3
1	1	1	4
1	1	2	4
1	1	3	4
1	1	4	4
1	1	5	4
1	1	6	4
1	1	7	4
1	1	8	4
1	1	9	4
1	1	10	4
1	1	11	4
1	1	12	4
1	1	13	4
1	1	14	4
1	1	15	4
1	1	1	5
1	1	2	5
1	1	3	5
1	1	4	5
1	1	5	5
1	1	6	5
1	1	7	5
1	1	8	5
1	1	9	5
1	1	10	5
1	1	11	5
1	1	12	5
1	1	13	5
1	1	14	5
1	1	15	5
1	1	1	6
1	1	2	6
1	1	3	6
1	1	4	6
1	1	5	6
1	1	6	6
1	1	7	6
1	1	8	6
1	1	9	6
1	1	10	6
1	1	11	6
1	1	12	6
1	1	13	6
1	1	14	6
1	1	15	6
1	1	1	7
1	1	2	7
1	1	3	7
1	1	4	7
1	1	5	7
1	1	6	7
1	1	7	7
1	1	8	7
1	1	9	7
1	1	10	7
1	1	11	7
1	1	12	7
1	1	13	7
1	1	14	7
1	1	15	7
1	1	1	8
1	1	2	8
1	1	3	8
1	1	4	8
1	1	5	8
1	1	6	8
1	1	7	8
1	1	8	8
1	1	9	8
1	1	10	8
1	1	11	8
1	1	12	8
1	1	13	8
1	1	14	8
1	1	15	8
1	1	1	9
1	1	2	9
1	1	3	9
1	1	4	9
1	1	5	9
1	1	6	9
1	1	7	9
1	1	8	9
1	1	9	9
1	1	10	9
1	1	11	9
1	1	12	9
1	1	13	9
1	1	14	9
1	1	15	9
1	1	1	10
1	1	2	10
1	1	3	10
1	1	4	10
1	1	5	10
1	1	6	10
1	1	7	10
1	1	8	10
1	1	9	10
1	1	10	10
1	1	11	10
1	1	12	10
1	1	13	10
1	1	14	10
1	1	15	10
1	1	1	11
1	1	2	11
1	1	3	11
1	1	4	11
1	1	5	11
1	1	6	11
1	1	7	11
1	1	8	11
1	1	9	11
1	1	10	11
1	1	11	11
1	1	12	11
1	1	13	11
1	1	14	11
1	1	15	11
1	1	1	12
1	1	2	12
1	1	3	12
1	1	4	12
1	1	5	12
1	1	6	12
1	1	7	12
1	1	8	12
1	1	9	12
1	1	10	12
1	1	11	12
1	1	12	12
1	1	13	12
1	1	14	12
1	1	15	12
1	1	1	13
1	1	2	13
1	1	3	13
1	1	4	13
1	1	5	13
1	1	6	13
1	1	7	13
1	1	8	13
1	1	9	13
1	1	10	13
1	1	11	13
1	1	12	13
1	1	13	13
1	1	14	13
1	1	15	13
1	1	1	14
1	1	2	14
1	1	3	14
1	1	4	14
1	1	5	14
1	1	6	14
1	1	7	14
1	1	8	14
1	1	9	14
1	1	10	14
1	1	11	14
1	1	12	14
1	1	13	14
1	1	14	14
1	1	15	14
1	1	1	15
1	1	2	15
1	1	3	15
1	1	4	15
1	1	5	15
1	1	6	15
1	1	7	15
1	1	8	15
1	1	9	15
1	1	10	15
1	1	11	15
1	1	12	15
1	1	13	15
1	1	14	15
1	1	15	15
2	1	1	1
2	1	2	1
2	1	3	1
2	1	4	1
2	1	5	1
2	1	6	1
2	1	7	1
2	1	8	1
2	1	9	1
2	1	10	1
2	1	11	1
2	1	12	1
2	1	13	1
2	1	14	1
2	1	15	1
2	1	1	2
2	1	2	2
2	1	3	2
2	1	4	2
2	1	5	2
2	1	6	2
2	1	7	2
2	1	8	2
2	1	9	2
2	1	10	2
2	1	11	2
2	1	12	2
2	1	13	2
2	1	14	2
2	1	15	2
2	1	1	3
2	1	2	3
2	1	3	3
2	1	4	3
2	1	5	3
2	1	6	3
2	1	7	3
2	1	8	3
2	1	9	3
2	1	10	3
2	1	11	3
2	1	12	3
2	1	13	3
2	1	14	3
2	1	15	3
2	1	1	4
2	1	2	4
2	1	3	4
2	1	4	4
2	1	5	4
2	1	6	4
2	1	7	4
2	1	8	4
2	1	9	4
2	1	10	4
2	1	11	4
2	1	12	4
2	1	13	4
2	1	14	4
2	1	15	4
2	1	1	5
2	1	2	5
2	1	3	5
2	1	4	5
2	1	5	5
2	1	6	5
2	1	7	5
2	1	8	5
2	1	9	5
2	1	10	5
2	1	11	5
2	1	12	5
2	1	13	5
2	1	14	5
2	1	15	5
2	1	1	6
2	1	2	6
2	1	3	6
2	1	4	6
2	1	5	6
2	1	6	6
2	1	7	6
2	1	8	6
2	1	9	6
2	1	10	6
2	1	11	6
2	1	12	6
2	1	13	6
2	1	14	6
2	1	15	6
2	1	1	7
2	1	2	7
2	1	3	7
2	1	4	7
2	1	5	7
2	1	6	7
2	1	7	7
2	1	8	7
2	1	9	7
2	1	10	7
2	1	11	7
2	1	12	7
2	1	13	7
2	1	14	7
2	1	15	7
2	1	1	8
2	1	2	8
2	1	3	8
2	1	4	8
2	1	5	8
2	1	6	8
2	1	7	8
2	1	8	8
2	1	9	8
2	1	10	8
2	1	11	8
2	1	12	8
2	1	13	8
2	1	14	8
2	1	15	8
2	1	1	9
2	1	2	9
2	1	3	9
2	1	4	9
2	1	5	9
2	1	6	9
2	1	7	9
2	1	8	9
2	1	9	9
2	1	10	9
2	1	11	9
2	1	12	9
2	1	13	9
2	1	14	9
2	1	15	9
2	1	1	10
2	1	2	10
2	1	3	10
2	1	4	10
2	1	5	10
2	1	6	10
2	1	7	10
2	1	8	10
2	1	9	10
2	1	10	10
2	1	11	10
2	1	12	10
2	1	13	10
2	1	14	10
2	1	15	10
2	1	1	11
2	1	2	11
2	1	3	11
2	1	4	11
2	1	5	11
2	1	6	11
2	1	7	11
2	1	8	11
2	1	9	11
2	1	10	11
2	1	11	11
2	1	12	11
2	1	13	11
2	1	14	11
2	1	15	11
2	1	1	12
2	1	2	12
2	1	3	12
2	1	4	12
2	1	5	12
2	1	6	12
2	1	7	12
2	1	8	12
2	1	9	12
2	1	10	12
2	1	11	12
2	1	12	12
2	1	13	12
2	1	14	12
2	1	15	12
2	1	1	13
2	1	2	13
2	1	3	13
2	1	4	13
2	1	5	13
2	1	6	13
2	1	7	13
2	1	8	13
2	1	9	13
2	1	10	13
2	1	11	13
2	1	12	13
2	1	13	13
2	1	14	13
2	1	15	13
2	1	1	14
2	1	2	14
2	1	3	14
2	1	4	14
2	1	5	14
2	1	6	14
2	1	7	14
2	1	8	14
2	1	9	14
2	1	10	14
2	1	11	14
2	1	12	14
2	1	13	14
2	1	14	14
2	1	15	14
2	1	1	15
2	1	2	15
2	1	3	15
2	1	4	15
2	1	5	15
2	1	6	15
2	1	7	15
2	1	8	15
2	1	9	15
2	1	10	15
2	1	11	15
2	1	12	15
2	1	13	15
2	1	14	15
2	1	15	15
3	1	1	1
3	1	2	1
3	1	3	1
3	1	4	1
3	1	5	1
3	1	6	1
3	1	7	1
3	1	8	1
3	1	9	1
3	1	10	1
3	1	11	1
3	1	12	1
3	1	13	1
3	1	14	1
3	1	15	1
3	1	1	2
3	1	2	2
3	1	3	2
3	1	4	2
3	1	5	2
3	1	6	2
3	1	7	2
3	1	8	2
3	1	9	2
3	1	10	2
3	1	11	2
3	1	12	2
3	1	13	2
3	1	14	2
3	1	15	2
3	1	1	3
3	1	2	3
3	1	3	3
3	1	4	3
3	1	5	3
3	1	6	3
3	1	7	3
3	1	8	3
3	1	9	3
3	1	10	3
3	1	11	3
3	1	12	3
3	1	13	3
3	1	14	3
3	1	15	3
3	1	1	4
3	1	2	4
3	1	3	4
3	1	4	4
3	1	5	4
3	1	6	4
3	1	7	4
3	1	8	4
3	1	9	4
3	1	10	4
3	1	11	4
3	1	12	4
3	1	13	4
3	1	14	4
3	1	15	4
3	1	1	5
3	1	2	5
3	1	3	5
3	1	4	5
3	1	5	5
3	1	6	5
3	1	7	5
3	1	8	5
3	1	9	5
3	1	10	5
3	1	11	5
3	1	12	5
3	1	13	5
3	1	14	5
3	1	15	5
3	1	1	6
3	1	2	6
3	1	3	6
3	1	4	6
3	1	5	6
3	1	6	6
3	1	7	6
3	1	8	6
3	1	9	6
3	1	10	6
3	1	11	6
3	1	12	6
3	1	13	6
3	1	14	6
3	1	15	6
3	1	1	7
3	1	2	7
3	1	3	7
3	1	4	7
3	1	5	7
3	1	6	7
3	1	7	7
3	1	8	7
3	1	9	7
3	1	10	7
3	1	11	7
3	1	12	7
3	1	13	7
3	1	14	7
3	1	15	7
3	1	1	8
3	1	2	8
3	1	3	8
3	1	4	8
3	1	5	8
3	1	6	8
3	1	7	8
3	1	8	8
3	1	9	8
3	1	10	8
3	1	11	8
3	1	12	8
3	1	13	8
3	1	14	8
3	1	15	8
3	1	1	9
3	1	2	9
3	1	3	9
3	1	4	9
3	1	5	9
3	1	6	9
3	1	7	9
3	1	8	9
3	1	9	9
3	1	10	9
3	1	11	9
3	1	12	9
3	1	13	9
3	1	14	9
3	1	15	9
3	1	1	10
3	1	2	10
3	1	3	10
3	1	4	10
3	1	5	10
3	1	6	10
3	1	7	10
3	1	8	10
3	1	9	10
3	1	10	10
3	1	11	10
3	1	12	10
3	1	13	10
3	1	14	10
3	1	15	10
3	1	1	11
3	1	2	11
3	1	3	11
3	1	4	11
3	1	5	11
3	1	6	11
3	1	7	11
3	1	8	11
3	1	9	11
3	1	10	11
3	1	11	11
3	1	12	11
3	1	13	11
3	1	14	11
3	1	15	11
3	1	1	12
3	1	2	12
3	1	3	12
3	1	4	12
3	1	5	12
3	1	6	12
3	1	7	12
3	1	8	12
3	1	9	12
3	1	10	12
3	1	11	12
3	1	12	12
3	1	13	12
3	1	14	12
3	1	15	12
3	1	1	13
3	1	2	13
3	1	3	13
3	1	4	13
3	1	5	13
3	1	6	13
3	1	7	13
3	1	8	13
3	1	9	13
3	1	10	13
3	1	11	13
3	1	12	13
3	1	13	13
3	1	14	13
3	1	15	13
3	1	1	14
3	1	2	14
3	1	3	14
3	1	4	14
3	1	5	14
3	1	6	14
3	1	7	14
3	1	8	14
3	1	9	14
3	1	10	14
3	1	11	14
3	1	12	14
3	1	13	14
3	1	14	14
3	1	15	14
3	1	1	15
3	1	2	15
3	1	3	15
3	1	4	15
3	1	5	15
3	1	6	15
3	1	7	15
3	1	8	15
3	1	9	15
3	1	10	15
3	1	11	15
3	1	12	15
3	1	13	15
3	1	14	15
3	1	15	15
4	1	1	1
4	1	2	1
4	1	3	1
4	1	4	1
4	1	5	1
4	1	6	1
4	1	7	1
4	1	8	1
4	1	9	1
4	1	10	1
4	1	11	1
4	1	12	1
4	1	13	1
4	1	14	1
4	1	15	1
4	1	1	2
4	1	2	2
4	1	3	2
4	1	4	2
4	1	5	2
4	1	6	2
4	1	7	2
4	1	8	2
4	1	9	2
4	1	10	2
4	1	11	2
4	1	12	2
4	1	13	2
4	1	14	2
4	1	15	2
4	1	1	3
4	1	2	3
4	1	3	3
4	1	4	3
4	1	5	3
4	1	6	3
4	1	7	3
4	1	8	3
4	1	9	3
4	1	10	3
4	1	11	3
4	1	12	3
4	1	13	3
4	1	14	3
4	1	15	3
4	1	1	4
4	1	2	4
4	1	3	4
4	1	4	4
4	1	5	4
4	1	6	4
4	1	7	4
4	1	8	4
4	1	9	4
4	1	10	4
4	1	11	4
4	1	12	4
4	1	13	4
4	1	14	4
4	1	15	4
4	1	1	5
4	1	2	5
4	1	3	5
4	1	4	5
4	1	5	5
4	1	6	5
4	1	7	5
4	1	8	5
4	1	9	5
4	1	10	5
4	1	11	5
4	1	12	5
4	1	13	5
4	1	14	5
4	1	15	5
4	1	1	6
4	1	2	6
4	1	3	6
4	1	4	6
4	1	5	6
4	1	6	6
4	1	7	6
4	1	8	6
4	1	9	6
4	1	10	6
4	1	11	6
4	1	12	6
4	1	13	6
4	1	14	6
4	1	15	6
4	1	1	7
4	1	2	7
4	1	3	7
4	1	4	7
4	1	5	7
4	1	6	7
4	1	7	7
4	1	8	7
4	1	9	7
4	1	10	7
4	1	11	7
4	1	12	7
4	1	13	7
4	1	14	7
4	1	15	7
4	1	1	8
4	1	2	8
4	1	3	8
4	1	4	8
4	1	5	8
4	1	6	8
4	1	7	8
4	1	8	8
4	1	9	8
4	1	10	8
4	1	11	8
4	1	12	8
4	1	13	8
4	1	14	8
4	1	15	8
4	1	1	9
4	1	2	9
4	1	3	9
4	1	4	9
4	1	5	9
4	1	6	9
4	1	7	9
4	1	8	9
4	1	9	9
4	1	10	9
4	1	11	9
4	1	12	9
4	1	13	9
4	1	14	9
4	1	15	9
4	1	1	10
4	1	2	10
4	1	3	10
4	1	4	10
4	1	5	10
4	1	6	10
4	1	7	10
4	1	8	10
4	1	9	10
4	1	10	10
4	1	11	10
4	1	12	10
4	1	13	10
4	1	14	10
4	1	15	10
4	1	1	11
4	1	2	11
4	1	3	11
4	1	4	11
4	1	5	11
4	1	6	11
4	1	7	11
4	1	8	11
4	1	9	11
4	1	10	11
4	1	11	11
4	1	12	11
4	1	13	11
4	1	14	11
4	1	15	11
4	1	1	12
4	1	2	12
4	1	3	12
4	1	4	12
4	1	5	12
4	1	6	12
4	1	7	12
4	1	8	12
4	1	9	12
4	1	10	12
4	1	11	12
4	1	12	12
4	1	13	12
4	1	14	12
4	1	15	12
4	1	1	13
4	1	2	13
4	1	3	13
4	1	4	13
4	1	5	13
4	1	6	13
4	1	7	13
4	1	8	13
4	1	9	13
4	1	10	13
4	1	11	13
4	1	12	13
4	1	13	13
4	1	14	13
4	1	15	13
4	1	1	14
4	1	2	14
4	1	3	14
4	1	4	14
4	1	5	14
4	1	6	14
4	1	7	14
4	1	8	14
4	1	9	14
4	1	10	14
4	1	11	14
4	1	12	14
4	1	13	14
4	1	14	14
4	1	15	14
4	1	1	15
4	1	2	15
4	1	3	15
4	1	4	15
4	1	5	15
4	1	6	15
4	1	7	15
4	1	8	15
4	1	9	15
4	1	10	15
4	1	11	15
4	1	12	15
4	1	13	15
4	1	14	15
4	1	15	15
5	1	1	1
5	1	1	2
5	1	1	3
5	1	1	4
5	1	1	5
5	1	1	6
5	1	1	7
5	1	1	8
5	1	1	9
5	1	1	10
5	1	1	11
5	1	1	12
5	1	1	13
5	1	1	14
5	1	1	15
5	1	2	1
5	1	2	2
5	1	2	3
5	1	2	4
5	1	2	5
5	1	2	6
5	1	2	7
5	1	2	8
5	1	2	9
5	1	2	10
5	1	2	11
5	1	2	12
5	1	2	13
5	1	2	14
5	1	2	15
5	1	3	1
5	1	3	2
5	1	3	3
5	1	3	4
5	1	3	5
5	1	3	6
5	1	3	7
5	1	3	8
5	1	3	9
5	1	3	10
5	1	3	11
5	1	3	12
5	1	3	13
5	1	3	14
5	1	3	15
5	1	4	1
5	1	4	2
5	1	4	3
5	1	4	4
5	1	4	5
5	1	4	6
5	1	4	7
5	1	4	8
5	1	4	9
5	1	4	10
5	1	4	11
5	1	4	12
5	1	4	13
5	1	4	14
5	1	4	15
5	1	5	1
5	1	5	2
5	1	5	3
5	1	5	4
5	1	5	5
5	1	5	6
5	1	5	7
5	1	5	8
5	1	5	9
5	1	5	10
5	1	5	11
5	1	5	12
5	1	5	13
5	1	5	14
5	1	5	15
5	1	6	1
5	1	6	2
5	1	6	3
5	1	6	4
5	1	6	5
5	1	6	6
5	1	6	7
5	1	6	8
5	1	6	9
5	1	6	10
5	1	6	11
5	1	6	12
5	1	6	13
5	1	6	14
5	1	6	15
5	1	7	1
5	1	7	2
5	1	7	3
5	1	7	4
5	1	7	5
5	1	7	6
5	1	7	7
5	1	7	8
5	1	7	9
5	1	7	10
5	1	7	11
5	1	7	12
5	1	7	13
5	1	7	14
5	1	7	15
5	1	8	1
5	1	8	2
5	1	8	3
5	1	8	4
5	1	8	5
5	1	8	6
5	1	8	7
5	1	8	8
5	1	8	9
5	1	8	10
5	1	8	11
5	1	8	12
5	1	8	13
5	1	8	14
5	1	8	15
5	1	9	1
5	1	9	2
5	1	9	3
5	1	9	4
5	1	9	5
5	1	9	6
5	1	9	7
5	1	9	8
5	1	9	9
5	1	9	10
5	1	9	11
5	1	9	12
5	1	9	13
5	1	9	14
5	1	9	15
5	1	10	1
5	1	10	2
5	1	10	3
5	1	10	4
5	1	10	5
5	1	10	6
5	1	10	7
5	1	10	8
5	1	10	9
5	1	10	10
5	1	10	11
5	1	10	12
5	1	10	13
5	1	10	14
5	1	10	15
5	1	11	1
5	1	11	2
5	1	11	3
5	1	11	4
5	1	11	5
5	1	11	6
5	1	11	7
5	1	11	8
5	1	11	9
5	1	11	10
5	1	11	11
5	1	11	12
5	1	11	13
5	1	11	14
5	1	11	15
5	1	12	1
5	1	12	2
5	1	12	3
5	1	12	4
5	1	12	5
5	1	12	6
5	1	12	7
5	1	12	8
5	1	12	9
5	1	12	10
5	1	12	11
5	1	12	12
5	1	12	13
5	1	12	14
5	1	12	15
5	1	13	1
5	1	13	2
5	1	13	3
5	1	13	4
5	1	13	5
5	1	13	6
5	1	13	7
5	1	13	8
5	1	13	9
5	1	13	10
5	1	13	11
5	1	13	12
5	1	13	13
5	1	13	14
5	1	13	15
5	1	14	1
5	1	14	2
5	1	14	3
5	1	14	4
5	1	14	5
5	1	14	6
5	1	14	7
5	1	14	8
5	1	14	9
5	1	14	10
5	1	14	11
5	1	14	12
5	1	14	13
5	1	14	14
5	1	14	15
5	1	15	1
5	1	15	2
5	1	15	3
5	1	15	4
5	1	15	5
5	1	15	6
5	1	15	7
5	1	15	8
5	1	15	9
5	1	15	10
5	1	15	11
5	1	15	12
5	1	15	13
5	1	15	14
5	1	15	15
\.


--
-- TOC entry 5666 (class 0 OID 25653)
-- Dependencies: 320
-- Data for Name: known_map_tiles_resources; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_map_tiles_resources (player_id, map_tiles_resource_id) FROM stdin;
1	573
1	572
1	571
1	1039
1	1038
1	2412
1	2413
1	2411
1	1756
1	1754
1	1851
1	1850
1	1852
1	1307
1	1306
3	1571
3	1573
1	375
1	373
1	374
\.


--
-- TOC entry 5659 (class 0 OID 25530)
-- Dependencies: 313
-- Data for Name: known_players_abilities; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_abilities (player_id, other_player_id) FROM stdin;
1	1
2	1
2	2
1	2
3	1
3	2
3	3
1	3
2	3
4	1
4	2
4	3
4	4
1	4
2	4
3	4
5	5
\.


--
-- TOC entry 5655 (class 0 OID 25460)
-- Dependencies: 309
-- Data for Name: known_players_containers; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_containers (player_id, container_id) FROM stdin;
1	1
1	2
2	1
2	2
1	3
2	3
1	4
2	4
3	1
3	2
3	3
3	4
1	5
2	5
3	5
1	6
2	6
3	6
4	1
4	2
4	3
4	4
4	5
4	6
1	7
2	7
3	7
4	7
1	8
2	8
3	8
4	8
5	9
5	10
\.


--
-- TOC entry 5636 (class 0 OID 22758)
-- Dependencies: 288
-- Data for Name: known_players_positions; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_positions (player_id, other_player_id) FROM stdin;
1	1
2	1
2	2
1	2
3	1
3	2
3	3
1	3
2	3
4	1
4	2
4	3
4	4
1	4
2	4
3	4
5	5
\.


--
-- TOC entry 5654 (class 0 OID 25440)
-- Dependencies: 308
-- Data for Name: known_players_profiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_profiles (player_id, other_player_id) FROM stdin;
1	1
2	1
2	2
1	2
3	1
3	2
3	3
1	3
2	3
4	1
4	2
4	3
4	4
1	4
2	4
3	4
5	5
\.


--
-- TOC entry 5658 (class 0 OID 25514)
-- Dependencies: 312
-- Data for Name: known_players_skills; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_skills (player_id, other_player_id) FROM stdin;
1	1
2	1
2	2
1	2
3	1
3	2
3	3
1	3
2	3
4	1
4	2
4	3
4	4
1	4
2	4
3	4
5	5
\.


--
-- TOC entry 5663 (class 0 OID 25593)
-- Dependencies: 317
-- Data for Name: known_players_squad_profiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_squad_profiles (player_id, squad_id) FROM stdin;
1	1
4	1
\.


--
-- TOC entry 5657 (class 0 OID 25492)
-- Dependencies: 311
-- Data for Name: known_players_stats; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_stats (player_id, other_player_id) FROM stdin;
1	1
2	1
2	2
1	2
3	1
3	2
3	3
1	3
2	3
4	1
4	2
4	3
4	4
1	4
2	4
3	4
5	5
\.


--
-- TOC entry 5637 (class 0 OID 22763)
-- Dependencies: 289
-- Data for Name: players; Type: TABLE DATA; Schema: players; Owner: postgres
--

COPY players.players (id, user_id, name, image_map, image_portrait, is_active, second_name, nickname, masked_id) FROM stdin;
5	2	Piotruniu	default.png	default.png	t	Pigeon	\N	dd22b411-4311-4fec-8d90-325244d8d97d
4	1	Ziomo	default.png	default.png	f	Fotono	\N	82e40615-d586-4e5f-a893-4939c222fec2
3	1	Jachuren	default.png	default.png	f	Koczkodanen	\N	20df0439-7f09-4e90-8e38-2fe4f92bb62b
2	1	Pawlak	default.png	default.png	f	Ciabatos	\N	a59fb84d-6250-4f9e-9a71-0aa8dd54e1c3
1	1	Ciabat	default.png	default.png	t	Ciabatos	\N	c7d7086d-2054-49b8-b630-b97451ad5e3f
\.


--
-- TOC entry 5676 (class 0 OID 476407)
-- Dependencies: 330
-- Data for Name: squad_invites; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squad_invites (id, squad_id, inviter_player_id, invited_player_id, status, created_at, responded_at, squad_role_id) FROM stdin;
19	32	1	2	4	2026-04-21 01:12:42.372906	\N	2
20	32	1	3	4	2026-04-21 01:12:44.59899	\N	2
21	32	1	4	4	2026-04-21 01:12:46.485001	\N	2
22	32	2	1	4	2026-04-21 01:18:42.6091	\N	2
\.


--
-- TOC entry 5678 (class 0 OID 476460)
-- Dependencies: 332
-- Data for Name: squad_invites_statuses; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squad_invites_statuses (id, description) FROM stdin;
1	Invited
2	Accepted
3	Rejected
4	Pernament
\.


--
-- TOC entry 5660 (class 0 OID 25567)
-- Dependencies: 314
-- Data for Name: squad_players; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squad_players (squad_id, player_id, squad_role_id) FROM stdin;
32	4	2
32	3	1
32	2	2
\.


--
-- TOC entry 5674 (class 0 OID 476381)
-- Dependencies: 328
-- Data for Name: squad_roles; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squad_roles (id, description) FROM stdin;
1	Leader
2	Member
\.


--
-- TOC entry 5662 (class 0 OID 25575)
-- Dependencies: 316
-- Data for Name: squads; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squads (id, squad_name, squad_image_map, squad_image_portrait, masked_id) FROM stdin;
32	Squad	default.png	default.png	52dc2202-31cf-4c6a-8b72-b0a39d2fdb04
\.


--
-- TOC entry 5639 (class 0 OID 22780)
-- Dependencies: 291
-- Data for Name: status_types; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

COPY tasks.status_types (id, name) FROM stdin;
1	to_process
2	in_process
3	done
4	retry
5	cancelled
6	error
\.


--
-- TOC entry 5641 (class 0 OID 22786)
-- Dependencies: 293
-- Data for Name: tasks; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

COPY tasks.tasks (id, player_id, status, created_at, scheduled_at, last_executed_at, error, method_name, method_parameters) FROM stdin;
\.


--
-- TOC entry 5595 (class 0 OID 22599)
-- Dependencies: 247
-- Data for Name: landscape_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.landscape_types (id, name, move_cost, image_url) FROM stdin;
1	Forest	2	forest.png
5	Forest Savanna	1	forest_savanna.png
9	Hills	2	hills.png
6	Jungle	4	jungle.png
7	Dunes	4	dunes.png
8	Swamp	4	swamp.png
2	Mountain	10	mountain.png
3	Volcano	10	volcano.png
4	Volcano Activated	15	volcano_activated.png
\.


--
-- TOC entry 5644 (class 0 OID 22798)
-- Dependencies: 296
-- Data for Name: map_regions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_regions (id, name, region_type_id, image_outline, image_fill) FROM stdin;
1	Region	1	#9ca3af	\N
2	Region	1	#9ca3af	\N
3	Region	1	#9ca3af	\N
4	Region	1	#9ca3af	\N
5	Region	1	#9ca3af	\N
6	Region	1	#9ca3af	\N
7	Region	1	#9ca3af	\N
8	Region	1	#9ca3af	\N
9	Region	1	#9ca3af	\N
10	Region	1	#9ca3af	\N
11	Region	1	#9ca3af	\N
12	Region	1	#9ca3af	\N
13	Region	1	#9ca3af	\N
14	Region	1	#9ca3af	\N
15	Region	1	#9ca3af	\N
16	Region	1	#9ca3af	\N
17	Region	1	#9ca3af	\N
18	Region	1	#9ca3af	\N
19	Region	1	#9ca3af	\N
20	Region	1	#9ca3af	\N
21	Region	1	#9ca3af	\N
22	Region	1	#9ca3af	\N
23	Region	1	#9ca3af	\N
24	Region	1	#9ca3af	\N
25	Region	1	#9ca3af	\N
26	Region	1	#9ca3af	\N
27	Region	1	#9ca3af	\N
28	Region	1	#9ca3af	\N
29	Region	1	#9ca3af	\N
30	Region	1	#9ca3af	\N
31	Region	1	#9ca3af	\N
32	Region	1	#9ca3af	\N
33	Region	1	#9ca3af	\N
34	Region	1	#9ca3af	\N
35	Region	1	#9ca3af	\N
36	Region	1	#9ca3af	\N
37	Region	1	#9ca3af	\N
38	Region	1	#9ca3af	\N
39	Region	1	#9ca3af	\N
40	Region	1	#9ca3af	\N
41	Region	1	#9ca3af	\N
42	Region	1	#9ca3af	\N
43	Region	1	#9ca3af	\N
44	Region	1	#9ca3af	\N
45	Region	1	#9ca3af	\N
46	Region	1	#9ca3af	\N
47	Region	1	#9ca3af	\N
48	Region	1	#9ca3af	\N
49	Region	1	#9ca3af	\N
50	Region	1	#9ca3af	\N
51	Region	1	#9ca3af	\N
52	Region	1	#9ca3af	\N
53	Region	1	#9ca3af	\N
54	Region	1	#9ca3af	\N
55	Region	1	#9ca3af	\N
56	Region	1	#9ca3af	\N
57	Region	1	#9ca3af	\N
58	Region	1	#9ca3af	\N
59	Region	1	#9ca3af	\N
60	Region	1	#9ca3af	\N
61	Region	1	#9ca3af	\N
62	Region	1	#9ca3af	\N
63	Region	1	#9ca3af	\N
64	Region	1	#9ca3af	\N
65	Region	1	#9ca3af	\N
66	Region	1	#9ca3af	\N
67	Region	1	#9ca3af	\N
68	Region	1	#9ca3af	\N
69	Region	1	#9ca3af	\N
70	Region	1	#9ca3af	\N
71	Region	1	#9ca3af	\N
72	Region	1	#9ca3af	\N
73	Region	1	#9ca3af	\N
74	Region	1	#9ca3af	\N
75	Region	1	#9ca3af	\N
76	Region	1	#9ca3af	\N
77	Region	1	#9ca3af	\N
78	Region	1	#9ca3af	\N
79	Region	1	#9ca3af	\N
80	Region	1	#9ca3af	\N
81	Region	1	#9ca3af	\N
82	Region	1	#9ca3af	\N
83	Region	1	#9ca3af	\N
84	Region	1	#9ca3af	\N
85	Region	1	#9ca3af	\N
86	Region	1	#9ca3af	\N
87	Region	1	#9ca3af	\N
88	Region	1	#9ca3af	\N
89	Region	1	#9ca3af	\N
90	Region	1	#9ca3af	\N
91	Region	1	#9ca3af	\N
92	Region	1	#9ca3af	\N
93	Region	1	#9ca3af	\N
94	Region	1	#9ca3af	\N
95	Region	1	#9ca3af	\N
96	Region	1	#9ca3af	\N
97	Region	1	#9ca3af	\N
98	Region	1	#9ca3af	\N
99	Region	1	#9ca3af	\N
100	Region	1	#9ca3af	\N
101	Region	1	#9ca3af	\N
102	Region	1	#9ca3af	\N
103	Region	1	#9ca3af	\N
104	Region	1	#9ca3af	\N
105	Region	1	#9ca3af	\N
106	Region	1	#9ca3af	\N
107	Region	1	#9ca3af	\N
108	Region	1	#9ca3af	\N
109	Region	1	#9ca3af	\N
110	Region	1	#9ca3af	\N
111	Region	1	#9ca3af	\N
112	Region	1	#9ca3af	\N
113	Region	1	#9ca3af	\N
114	Region	1	#9ca3af	\N
115	Region	1	#9ca3af	\N
116	Region	1	#9ca3af	\N
117	Region	1	#9ca3af	\N
118	Region	1	#9ca3af	\N
119	Region	1	#9ca3af	\N
120	Region	1	#9ca3af	\N
121	Region	1	#9ca3af	\N
122	Region	1	#9ca3af	\N
123	Region	1	#9ca3af	\N
124	Region	1	#9ca3af	\N
125	Region	1	#9ca3af	\N
126	Region	1	#9ca3af	\N
127	Region	1	#9ca3af	\N
128	Region	1	#9ca3af	\N
129	Region	1	#9ca3af	\N
130	Region	1	#9ca3af	\N
131	Region	1	#9ca3af	\N
132	Region	1	#9ca3af	\N
133	Region	1	#9ca3af	\N
134	Region	1	#9ca3af	\N
135	Region	1	#9ca3af	\N
136	Region	1	#9ca3af	\N
137	Region	1	#9ca3af	\N
138	Region	1	#9ca3af	\N
139	Region	1	#9ca3af	\N
140	Region	1	#9ca3af	\N
141	Region	1	#9ca3af	\N
142	Region	1	#9ca3af	\N
143	Region	1	#9ca3af	\N
144	Region	1	#9ca3af	\N
145	Region	1	#9ca3af	\N
146	Region	1	#9ca3af	\N
147	Region	1	#9ca3af	\N
148	Region	1	#9ca3af	\N
149	Region	1	#9ca3af	\N
150	Region	1	#9ca3af	\N
151	Region	1	#9ca3af	\N
152	Region	1	#9ca3af	\N
153	Region	1	#9ca3af	\N
154	Region	1	#9ca3af	\N
155	Region	1	#9ca3af	\N
156	Region	1	#9ca3af	\N
157	Region	1	#9ca3af	\N
158	Region	1	#9ca3af	\N
159	Region	1	#9ca3af	\N
160	Region	1	#9ca3af	\N
161	Region	1	#9ca3af	\N
162	Region	1	#9ca3af	\N
163	Region	1	#9ca3af	\N
164	Region	1	#9ca3af	\N
165	Region	1	#9ca3af	\N
166	Region	1	#9ca3af	\N
167	Region	1	#9ca3af	\N
168	Region	1	#9ca3af	\N
169	Region	1	#9ca3af	\N
170	Region	1	#9ca3af	\N
171	Region	1	#9ca3af	\N
172	Region	1	#9ca3af	\N
173	Region	1	#9ca3af	\N
174	Region	1	#9ca3af	\N
175	Region	1	#9ca3af	\N
176	Region	1	#9ca3af	\N
177	Region	1	#9ca3af	\N
178	Region	1	#9ca3af	\N
179	Region	1	#9ca3af	\N
180	Region	1	#9ca3af	\N
181	Region	1	#9ca3af	\N
182	Region	1	#9ca3af	\N
183	Region	1	#9ca3af	\N
184	Region	1	#9ca3af	\N
185	Region	1	#9ca3af	\N
186	Region	1	#9ca3af	\N
187	Region	1	#9ca3af	\N
188	Region	1	#9ca3af	\N
189	Region	1	#9ca3af	\N
190	Region	1	#9ca3af	\N
191	Region	1	#9ca3af	\N
192	Region	1	#9ca3af	\N
193	Region	1	#9ca3af	\N
194	Region	1	#9ca3af	\N
195	Region	1	#9ca3af	\N
196	Region	1	#9ca3af	\N
197	Region	1	#9ca3af	\N
198	Region	1	#9ca3af	\N
199	Region	1	#9ca3af	\N
200	Region	1	#9ca3af	\N
201	Region	1	#9ca3af	\N
202	Region	1	#9ca3af	\N
203	Region	1	#9ca3af	\N
204	Region	1	#9ca3af	\N
205	Region	1	#9ca3af	\N
206	Region	1	#9ca3af	\N
207	Region	1	#9ca3af	\N
208	Region	1	#9ca3af	\N
209	Region	1	#9ca3af	\N
210	Region	1	#9ca3af	\N
211	Region	1	#9ca3af	\N
212	Region	1	#9ca3af	\N
213	Region	1	#9ca3af	\N
214	Region	1	#9ca3af	\N
215	Region	1	#9ca3af	\N
216	Region	1	#9ca3af	\N
217	Region	1	#9ca3af	\N
218	Region	1	#9ca3af	\N
219	Region	1	#9ca3af	\N
220	Region	1	#9ca3af	\N
221	Region	1	#9ca3af	\N
222	Region	1	#9ca3af	\N
223	Region	1	#9ca3af	\N
224	Region	1	#9ca3af	\N
225	Region	1	#9ca3af	\N
226	Region	1	#9ca3af	\N
227	Region	1	#9ca3af	\N
228	Region	1	#9ca3af	\N
229	Region	1	#9ca3af	\N
230	Region	1	#9ca3af	\N
231	Region	1	#9ca3af	\N
232	Region	1	#9ca3af	\N
233	Region	1	#9ca3af	\N
234	Region	1	#9ca3af	\N
235	Region	1	#9ca3af	\N
236	Region	1	#9ca3af	\N
237	Region	1	#9ca3af	\N
238	Region	1	#9ca3af	\N
239	Region	1	#9ca3af	\N
240	Region	1	#9ca3af	\N
241	Region	1	#9ca3af	\N
242	Region	1	#9ca3af	\N
243	Region	1	#9ca3af	\N
244	Region	1	#9ca3af	\N
245	Region	1	#9ca3af	\N
246	Region	1	#9ca3af	\N
247	Region	1	#9ca3af	\N
248	Region	1	#9ca3af	\N
249	Region	1	#9ca3af	\N
250	Region	1	#9ca3af	\N
251	Region	1	#9ca3af	\N
252	Region	1	#9ca3af	\N
253	Region	1	#9ca3af	\N
254	Region	1	#9ca3af	\N
255	Region	1	#9ca3af	\N
256	Region	1	#9ca3af	\N
257	Region	1	#9ca3af	\N
258	Region	1	#9ca3af	\N
259	Region	1	#9ca3af	\N
260	Region	1	#9ca3af	\N
261	Region	1	#9ca3af	\N
262	Region	1	#9ca3af	\N
263	Region	1	#9ca3af	\N
264	Region	1	#9ca3af	\N
265	Region	1	#9ca3af	\N
266	Region	1	#9ca3af	\N
267	Region	1	#9ca3af	\N
268	Region	1	#9ca3af	\N
269	Region	1	#9ca3af	\N
270	Region	1	#9ca3af	\N
271	Region	1	#9ca3af	\N
272	Region	1	#9ca3af	\N
273	Region	1	#9ca3af	\N
274	Region	1	#9ca3af	\N
275	Region	1	#9ca3af	\N
276	Region	1	#9ca3af	\N
277	Region	1	#9ca3af	\N
278	Region	1	#9ca3af	\N
279	Region	1	#9ca3af	\N
280	Region	1	#9ca3af	\N
281	Region	1	#9ca3af	\N
282	Region	1	#9ca3af	\N
283	Region	1	#9ca3af	\N
284	Region	1	#9ca3af	\N
285	Region	1	#9ca3af	\N
286	Region	1	#9ca3af	\N
287	Region	1	#9ca3af	\N
288	Region	1	#9ca3af	\N
289	Region	1	#9ca3af	\N
290	Region	1	#9ca3af	\N
291	Region	1	#9ca3af	\N
292	Region	1	#9ca3af	\N
293	Region	1	#9ca3af	\N
294	Region	1	#9ca3af	\N
295	Region	1	#9ca3af	\N
296	Region	1	#9ca3af	\N
297	Region	1	#9ca3af	\N
298	Region	1	#9ca3af	\N
299	Region	1	#9ca3af	\N
300	Region	1	#9ca3af	\N
301	Region	1	#9ca3af	\N
302	Region	1	#9ca3af	\N
303	Region	1	#9ca3af	\N
304	Region	1	#9ca3af	\N
305	Region	1	#9ca3af	\N
306	Region	1	#9ca3af	\N
307	Region	1	#9ca3af	\N
308	Region	1	#9ca3af	\N
309	Region	1	#9ca3af	\N
310	Region	1	#9ca3af	\N
311	Region	1	#9ca3af	\N
312	Region	1	#9ca3af	\N
313	Region	1	#9ca3af	\N
314	Region	1	#9ca3af	\N
315	Region	1	#9ca3af	\N
316	Region	1	#9ca3af	\N
317	Region	1	#9ca3af	\N
318	Region	1	#9ca3af	\N
319	Region	1	#9ca3af	\N
320	Region	1	#9ca3af	\N
321	Region	1	#9ca3af	\N
322	Region	1	#9ca3af	\N
323	Region	1	#9ca3af	\N
324	Region	1	#9ca3af	\N
325	Region	1	#9ca3af	\N
326	Region	1	#9ca3af	\N
327	Region	1	#9ca3af	\N
328	Region	1	#9ca3af	\N
329	Region	1	#9ca3af	\N
330	Region	1	#9ca3af	\N
331	Region	1	#9ca3af	\N
332	Region	1	#9ca3af	\N
333	Region	1	#9ca3af	\N
334	Region	1	#9ca3af	\N
335	Region	1	#9ca3af	\N
336	Region	1	#9ca3af	\N
337	Region	1	#9ca3af	\N
338	Region	1	#9ca3af	\N
339	Region	1	#9ca3af	\N
340	Region	1	#9ca3af	\N
341	Region	1	#9ca3af	\N
342	Region	1	#9ca3af	\N
343	Region	1	#9ca3af	\N
344	Region	1	#9ca3af	\N
\.


--
-- TOC entry 5596 (class 0 OID 22607)
-- Dependencies: 248
-- Data for Name: map_tiles; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles (map_id, x, y, terrain_type_id, landscape_type_id) FROM stdin;
1	1	1	4	7
1	2	1	4	\N
1	3	1	1	9
1	4	1	1	9
1	5	1	9	\N
1	6	1	2	1
1	7	1	2	\N
1	8	1	2	\N
1	9	1	2	1
1	10	1	1	1
1	11	1	1	9
1	12	1	1	\N
1	13	1	1	1
1	14	1	1	1
1	15	1	1	\N
1	16	1	1	1
1	17	1	9	\N
1	18	1	7	\N
1	19	1	7	\N
1	20	1	3	2
1	21	1	3	2
1	22	1	3	2
1	23	1	3	2
1	24	1	3	2
1	25	1	3	3
1	26	1	4	7
1	27	1	4	7
1	28	1	4	7
1	29	1	4	7
1	30	1	4	7
1	31	1	4	\N
1	32	1	4	7
1	33	1	4	7
1	34	1	4	\N
1	35	1	3	3
1	36	1	3	2
1	37	1	3	2
1	38	1	3	\N
1	39	1	3	3
1	40	1	2	1
1	41	1	2	\N
1	42	1	2	1
1	43	1	2	1
1	44	1	2	1
1	45	1	3	2
1	46	1	3	\N
1	47	1	3	\N
1	48	1	3	\N
1	49	1	3	3
1	50	1	3	2
1	51	1	3	2
1	52	1	2	1
1	53	1	2	1
1	54	1	2	\N
1	55	1	2	1
1	56	1	2	1
1	57	1	2	1
1	58	1	9	\N
1	59	1	9	\N
1	60	1	2	1
1	1	2	4	7
1	2	2	4	7
1	3	2	1	9
1	4	2	1	1
1	5	2	1	9
1	6	2	2	\N
1	7	2	2	\N
1	8	2	5	\N
1	9	2	2	1
1	10	2	1	1
1	11	2	1	\N
1	12	2	1	9
1	13	2	1	1
1	14	2	1	9
1	15	2	1	1
1	16	2	2	\N
1	17	2	9	\N
1	18	2	7	\N
1	19	2	9	\N
1	20	2	9	\N
1	21	2	4	7
1	22	2	3	2
1	23	2	3	3
1	24	2	4	7
1	25	2	9	\N
1	26	2	9	\N
1	27	2	9	\N
1	28	2	9	\N
1	29	2	9	\N
1	30	2	4	7
1	31	2	4	7
1	32	2	4	\N
1	33	2	4	7
1	34	2	4	7
1	35	2	3	3
1	36	2	3	2
1	37	2	4	7
1	38	2	3	2
1	39	2	3	3
1	40	2	2	\N
1	41	2	2	\N
1	42	2	2	1
1	43	2	2	\N
1	44	2	5	8
1	45	2	3	2
1	46	2	3	3
1	47	2	6	\N
1	48	2	3	2
1	49	2	5	6
1	50	2	1	1
1	51	2	3	\N
1	52	2	2	\N
1	53	2	2	1
1	54	2	2	1
1	55	2	2	\N
1	56	2	2	1
1	57	2	2	\N
1	58	2	9	\N
1	59	2	2	1
1	60	2	7	\N
1	1	3	4	7
1	2	3	3	\N
1	3	3	1	\N
1	4	3	1	\N
1	5	3	1	\N
1	6	3	1	1
1	7	3	3	\N
1	8	3	2	1
1	9	3	2	1
1	10	3	1	\N
1	11	3	1	9
1	12	3	1	9
1	13	3	1	\N
1	14	3	1	1
1	15	3	1	9
1	16	3	1	\N
1	17	3	9	\N
1	18	3	9	\N
1	19	3	7	\N
1	20	3	9	\N
1	21	3	9	\N
1	22	3	5	8
1	23	3	3	\N
1	24	3	3	2
1	25	3	9	\N
1	26	3	7	\N
1	27	3	7	\N
1	28	3	7	\N
1	29	3	9	\N
1	30	3	9	\N
1	31	3	9	\N
1	32	3	4	7
1	33	3	4	7
1	34	3	4	\N
1	35	3	3	2
1	36	3	3	\N
1	37	3	9	\N
1	38	3	9	\N
1	39	3	3	\N
1	40	3	2	1
1	41	3	9	\N
1	42	3	9	\N
1	43	3	1	9
1	44	3	1	1
1	45	3	3	\N
1	46	3	3	2
1	47	3	3	3
1	48	3	3	3
1	49	3	9	\N
1	50	3	1	9
1	51	3	2	\N
1	52	3	3	3
1	53	3	2	1
1	54	3	2	\N
1	55	3	2	\N
1	56	3	2	1
1	57	3	2	\N
1	58	3	9	\N
1	59	3	2	1
1	60	3	2	\N
1	1	4	3	2
1	2	4	3	2
1	3	4	1	\N
1	4	4	1	\N
1	5	4	1	\N
1	6	4	1	1
1	7	4	6	\N
1	8	4	2	\N
1	9	4	2	1
1	10	4	1	\N
1	11	4	1	1
1	12	4	1	9
1	13	4	1	9
1	14	4	4	7
1	15	4	2	\N
1	16	4	1	9
1	17	4	1	\N
1	18	4	9	\N
1	19	4	7	\N
1	20	4	9	\N
1	21	4	5	6
1	22	4	5	8
1	23	4	1	9
1	24	4	3	3
1	25	4	9	\N
1	26	4	9	\N
1	27	4	9	\N
1	28	4	9	\N
1	29	4	7	\N
1	30	4	7	\N
1	31	4	9	\N
1	32	4	9	\N
1	33	4	9	\N
1	34	4	4	7
1	35	4	7	\N
1	36	4	6	\N
1	37	4	9	\N
1	38	4	3	\N
1	39	4	3	3
1	40	4	3	\N
1	41	4	9	\N
1	42	4	9	\N
1	43	4	9	\N
1	44	4	9	\N
1	45	4	3	3
1	46	4	6	\N
1	47	4	3	2
1	48	4	3	2
1	49	4	9	\N
1	50	4	1	1
1	51	4	1	9
1	52	4	2	\N
1	53	4	2	1
1	54	4	2	\N
1	55	4	2	1
1	56	4	2	1
1	57	4	1	\N
1	58	4	9	\N
1	59	4	2	\N
1	60	4	2	\N
1	1	5	3	2
1	2	5	3	2
1	3	5	1	1
1	4	5	1	9
1	5	5	1	9
1	6	5	1	\N
1	7	5	2	\N
1	8	5	2	1
1	9	5	2	\N
1	10	5	1	9
1	11	5	1	9
1	12	5	1	9
1	13	5	1	9
1	14	5	1	\N
1	15	5	1	\N
1	16	5	1	9
1	17	5	1	9
1	18	5	9	\N
1	19	5	9	\N
1	20	5	5	8
1	21	5	5	8
1	22	5	2	1
1	23	5	1	1
1	24	5	1	9
1	25	5	1	9
1	26	5	9	\N
1	27	5	1	9
1	28	5	1	9
1	29	5	7	\N
1	30	5	7	\N
1	31	5	9	\N
1	32	5	5	8
1	33	5	4	\N
1	34	5	4	\N
1	35	5	4	\N
1	36	5	4	7
1	37	5	9	\N
1	38	5	9	\N
1	39	5	3	3
1	40	5	3	\N
1	41	5	9	\N
1	42	5	6	\N
1	43	5	9	\N
1	44	5	3	2
1	45	5	3	2
1	46	5	3	\N
1	47	5	3	\N
1	48	5	3	3
1	49	5	9	\N
1	50	5	9	\N
1	51	5	1	1
1	52	5	1	\N
1	53	5	2	1
1	54	5	6	\N
1	55	5	2	1
1	56	5	9	\N
1	57	5	9	\N
1	58	5	1	1
1	59	5	2	\N
1	60	5	2	1
1	1	6	3	3
1	2	6	3	\N
1	3	6	1	1
1	4	6	4	7
1	5	6	3	\N
1	6	6	1	1
1	7	6	1	\N
1	8	6	2	1
1	9	6	2	1
1	10	6	1	1
1	11	6	3	3
1	12	6	1	1
1	13	6	1	1
1	14	6	2	1
1	15	6	1	\N
1	16	6	5	8
1	17	6	1	9
1	18	6	9	\N
1	19	6	5	6
1	20	6	5	6
1	21	6	5	8
1	22	6	5	\N
1	23	6	1	1
1	24	6	9	\N
1	25	6	9	\N
1	26	6	2	1
1	27	6	1	9
1	28	6	3	2
1	29	6	7	\N
1	30	6	7	\N
1	31	6	9	\N
1	32	6	4	7
1	33	6	4	7
1	34	6	4	7
1	35	6	4	\N
1	36	6	6	\N
1	37	6	9	\N
1	38	6	3	3
1	39	6	3	\N
1	40	6	3	2
1	41	6	3	2
1	42	6	1	1
1	43	6	9	\N
1	44	6	9	\N
1	45	6	9	\N
1	46	6	9	\N
1	47	6	3	2
1	48	6	3	2
1	49	6	9	\N
1	50	6	1	1
1	51	6	1	\N
1	52	6	1	\N
1	53	6	9	\N
1	54	6	9	\N
1	55	6	9	\N
1	56	6	2	1
1	57	6	1	9
1	58	6	1	9
1	59	6	1	\N
1	60	6	2	1
1	1	7	3	3
1	2	7	3	\N
1	3	7	3	2
1	4	7	3	3
1	5	7	9	\N
1	6	7	9	\N
1	7	7	9	\N
1	8	7	2	\N
1	9	7	2	1
1	10	7	2	1
1	11	7	1	1
1	12	7	1	9
1	13	7	1	\N
1	14	7	4	7
1	15	7	1	\N
1	16	7	1	1
1	17	7	2	1
1	18	7	4	7
1	19	7	5	\N
1	20	7	3	3
1	21	7	5	\N
1	22	7	5	\N
1	23	7	5	8
1	24	7	6	\N
1	25	7	2	1
1	26	7	2	1
1	27	7	2	1
1	28	7	1	\N
1	29	7	7	\N
1	30	7	7	\N
1	31	7	9	\N
1	32	7	9	\N
1	33	7	4	7
1	34	7	4	\N
1	35	7	6	\N
1	36	7	6	\N
1	37	7	6	\N
1	38	7	3	\N
1	39	7	3	\N
1	40	7	3	2
1	41	7	3	\N
1	42	7	3	2
1	43	7	1	1
1	44	7	1	\N
1	45	7	1	9
1	46	7	9	\N
1	47	7	9	\N
1	48	7	3	3
1	49	7	9	\N
1	50	7	9	\N
1	51	7	1	9
1	52	7	1	9
1	53	7	1	9
1	54	7	9	\N
1	55	7	2	1
1	56	7	2	1
1	57	7	1	1
1	58	7	1	\N
1	59	7	1	\N
1	60	7	8	\N
1	1	8	3	3
1	2	8	3	2
1	3	8	3	\N
1	4	8	3	2
1	5	8	3	2
1	6	8	3	2
1	7	8	2	\N
1	8	8	2	1
1	9	8	2	\N
1	10	8	2	\N
1	11	8	1	1
1	12	8	1	9
1	13	8	1	\N
1	14	8	1	9
1	15	8	6	\N
1	16	8	1	9
1	17	8	1	\N
1	18	8	1	\N
1	19	8	1	\N
1	20	8	5	\N
1	21	8	5	8
1	22	8	5	6
1	23	8	5	8
1	24	8	5	8
1	25	8	1	9
1	26	8	3	2
1	27	8	2	1
1	28	8	6	\N
1	29	8	7	\N
1	30	8	7	\N
1	31	8	9	\N
1	32	8	4	\N
1	33	8	4	7
1	34	8	4	7
1	35	8	4	\N
1	36	8	6	\N
1	37	8	1	\N
1	38	8	3	\N
1	39	8	3	2
1	40	8	3	2
1	41	8	3	\N
1	42	8	3	3
1	43	8	1	9
1	44	8	1	1
1	45	8	1	1
1	46	8	9	\N
1	47	8	3	2
1	48	8	5	\N
1	49	8	3	2
1	50	8	1	\N
1	51	8	1	9
1	52	8	1	1
1	53	8	1	9
1	54	8	1	\N
1	55	8	2	1
1	56	8	2	1
1	57	8	1	9
1	58	8	5	8
1	59	8	1	9
1	60	8	1	\N
1	1	9	3	2
1	2	9	3	2
1	3	9	3	3
1	4	9	3	3
1	5	9	5	\N
1	6	9	3	2
1	7	9	2	1
1	8	9	1	9
1	9	9	2	1
1	10	9	6	\N
1	11	9	3	2
1	12	9	1	1
1	13	9	1	\N
1	14	9	9	\N
1	15	9	9	\N
1	16	9	1	1
1	17	9	1	1
1	18	9	1	\N
1	19	9	1	\N
1	20	9	1	\N
1	21	9	5	8
1	22	9	5	6
1	23	9	5	8
1	24	9	5	6
1	25	9	5	8
1	26	9	3	\N
1	27	9	3	3
1	28	9	2	1
1	29	9	7	\N
1	30	9	4	7
1	31	9	4	7
1	32	9	7	\N
1	33	9	4	\N
1	34	9	4	7
1	35	9	4	7
1	36	9	6	\N
1	37	9	6	\N
1	38	9	3	2
1	39	9	3	2
1	40	9	3	3
1	41	9	3	2
1	42	9	3	\N
1	43	9	6	\N
1	44	9	1	1
1	45	9	1	1
1	46	9	1	1
1	47	9	1	\N
1	48	9	3	\N
1	49	9	3	2
1	50	9	1	9
1	51	9	3	\N
1	52	9	1	1
1	53	9	1	1
1	54	9	1	1
1	55	9	1	1
1	56	9	1	\N
1	57	9	4	\N
1	58	9	1	1
1	59	9	1	9
1	60	9	5	8
1	1	10	3	\N
1	2	10	3	\N
1	3	10	3	\N
1	4	10	3	2
1	5	10	3	\N
1	6	10	3	2
1	7	10	3	\N
1	8	10	1	1
1	9	10	1	\N
1	10	10	1	9
1	11	10	1	1
1	12	10	1	9
1	13	10	1	1
1	14	10	9	\N
1	15	10	5	\N
1	16	10	6	\N
1	17	10	9	\N
1	18	10	9	\N
1	19	10	1	9
1	20	10	1	1
1	21	10	1	\N
1	22	10	9	\N
1	23	10	5	6
1	24	10	7	\N
1	25	10	1	9
1	26	10	3	3
1	27	10	3	\N
1	28	10	5	6
1	29	10	2	\N
1	30	10	4	7
1	31	10	1	\N
1	32	10	4	\N
1	33	10	4	\N
1	34	10	4	7
1	35	10	4	\N
1	36	10	4	7
1	37	10	6	\N
1	38	10	3	2
1	39	10	2	\N
1	40	10	6	\N
1	41	10	3	2
1	42	10	3	3
1	43	10	3	3
1	44	10	1	9
1	45	10	1	9
1	46	10	1	1
1	47	10	1	1
1	48	10	1	1
1	49	10	1	\N
1	50	10	1	\N
1	51	10	1	\N
1	52	10	1	1
1	53	10	1	9
1	54	10	1	\N
1	55	10	1	1
1	56	10	5	\N
1	57	10	7	\N
1	58	10	1	1
1	59	10	6	\N
1	60	10	1	9
1	1	11	3	\N
1	2	11	3	2
1	3	11	3	\N
1	4	11	3	2
1	5	11	3	\N
1	6	11	3	2
1	7	11	3	\N
1	8	11	5	\N
1	9	11	1	9
1	10	11	1	1
1	11	11	5	8
1	12	11	1	9
1	13	11	1	9
1	14	11	9	\N
1	15	11	9	\N
1	16	11	5	\N
1	17	11	9	\N
1	18	11	1	9
1	19	11	1	9
1	20	11	1	9
1	21	11	1	\N
1	22	11	9	\N
1	23	11	9	\N
1	24	11	9	\N
1	25	11	9	\N
1	26	11	9	\N
1	27	11	9	\N
1	28	11	2	\N
1	29	11	6	\N
1	30	11	4	\N
1	31	11	4	7
1	32	11	4	7
1	33	11	4	\N
1	34	11	4	7
1	35	11	4	7
1	36	11	4	7
1	37	11	4	7
1	38	11	2	\N
1	39	11	2	1
1	40	11	2	\N
1	41	11	3	\N
1	42	11	3	2
1	43	11	3	2
1	44	11	1	\N
1	45	11	1	\N
1	46	11	1	1
1	47	11	1	\N
1	48	11	1	1
1	49	11	1	1
1	50	11	1	9
1	51	11	1	9
1	52	11	1	1
1	53	11	3	\N
1	54	11	7	\N
1	55	11	1	\N
1	56	11	1	9
1	57	11	4	7
1	58	11	1	1
1	59	11	1	9
1	60	11	1	1
1	1	12	3	\N
1	2	12	4	7
1	3	12	3	2
1	4	12	3	3
1	5	12	7	\N
1	6	12	3	2
1	7	12	3	3
1	8	12	3	3
1	9	12	9	\N
1	10	12	9	\N
1	11	12	9	\N
1	12	12	1	\N
1	13	12	1	1
1	14	12	9	\N
1	15	12	5	\N
1	16	12	5	8
1	17	12	5	\N
1	18	12	1	1
1	19	12	7	\N
1	20	12	1	1
1	21	12	1	9
1	22	12	2	1
1	23	12	9	\N
1	24	12	3	3
1	25	12	3	2
1	26	12	3	3
1	27	12	2	\N
1	28	12	2	\N
1	29	12	2	1
1	30	12	4	\N
1	31	12	4	7
1	32	12	7	\N
1	33	12	3	3
1	34	12	9	\N
1	35	12	4	\N
1	36	12	4	\N
1	37	12	4	7
1	38	12	2	1
1	39	12	2	\N
1	40	12	2	1
1	41	12	7	\N
1	42	12	3	2
1	43	12	3	\N
1	44	12	2	1
1	45	12	1	1
1	46	12	1	9
1	47	12	1	9
1	48	12	2	1
1	49	12	2	1
1	50	12	1	9
1	51	12	1	\N
1	52	12	1	1
1	53	12	4	7
1	54	12	1	9
1	55	12	1	\N
1	56	12	1	\N
1	57	12	9	\N
1	58	12	9	\N
1	59	12	1	1
1	60	12	1	1
1	1	13	3	\N
1	2	13	3	3
1	3	13	3	\N
1	4	13	3	\N
1	5	13	3	3
1	6	13	3	\N
1	7	13	3	3
1	8	13	3	2
1	9	13	9	\N
1	10	13	3	\N
1	11	13	1	9
1	12	13	1	9
1	13	13	1	9
1	14	13	9	\N
1	15	13	9	\N
1	16	13	5	8
1	17	13	5	\N
1	18	13	5	6
1	19	13	7	\N
1	20	13	2	\N
1	21	13	1	\N
1	22	13	2	\N
1	23	13	9	\N
1	24	13	9	\N
1	25	13	5	8
1	26	13	3	3
1	27	13	2	\N
1	28	13	2	1
1	29	13	2	\N
1	30	13	2	\N
1	31	13	4	7
1	32	13	4	\N
1	33	13	3	2
1	34	13	9	\N
1	35	13	4	\N
1	36	13	1	1
1	37	13	3	3
1	38	13	2	1
1	39	13	2	1
1	40	13	2	\N
1	41	13	2	1
1	42	13	3	2
1	43	13	3	\N
1	44	13	3	2
1	45	13	1	9
1	46	13	1	\N
1	47	13	1	1
1	48	13	1	9
1	49	13	2	1
1	50	13	2	\N
1	51	13	1	\N
1	52	13	1	\N
1	53	13	1	\N
1	54	13	1	9
1	55	13	6	\N
1	56	13	6	\N
1	57	13	7	\N
1	58	13	1	9
1	59	13	4	7
1	60	13	2	\N
1	1	14	3	3
1	2	14	3	\N
1	3	14	3	2
1	4	14	3	2
1	5	14	3	\N
1	6	14	3	2
1	7	14	3	3
1	8	14	7	\N
1	9	14	9	\N
1	10	14	9	\N
1	11	14	1	9
1	12	14	1	1
1	13	14	1	1
1	14	14	1	1
1	15	14	9	\N
1	16	14	5	\N
1	17	14	5	6
1	18	14	5	8
1	19	14	5	\N
1	20	14	6	\N
1	21	14	2	\N
1	22	14	2	\N
1	23	14	2	1
1	24	14	2	1
1	25	14	2	1
1	26	14	2	1
1	27	14	2	1
1	28	14	2	1
1	29	14	2	1
1	30	14	2	1
1	31	14	2	1
1	32	14	4	7
1	33	14	4	\N
1	34	14	9	\N
1	35	14	1	1
1	36	14	1	\N
1	37	14	9	\N
1	38	14	9	\N
1	39	14	2	1
1	40	14	2	1
1	41	14	3	\N
1	42	14	3	\N
1	43	14	3	3
1	44	14	3	\N
1	45	14	1	1
1	46	14	1	\N
1	47	14	4	7
1	48	14	1	1
1	49	14	1	\N
1	50	14	1	\N
1	51	14	1	9
1	52	14	1	9
1	53	14	1	\N
1	54	14	1	1
1	55	14	1	1
1	56	14	6	\N
1	57	14	6	\N
1	58	14	6	\N
1	59	14	1	1
1	60	14	1	1
1	1	15	3	2
1	2	15	5	\N
1	3	15	3	\N
1	4	15	3	3
1	5	15	3	\N
1	6	15	3	\N
1	7	15	7	\N
1	8	15	7	\N
1	9	15	9	\N
1	10	15	6	\N
1	11	15	1	\N
1	12	15	1	1
1	13	15	9	\N
1	14	15	1	\N
1	15	15	1	\N
1	16	15	5	\N
1	17	15	5	8
1	18	15	5	8
1	19	15	5	\N
1	20	15	5	\N
1	21	15	3	\N
1	22	15	2	1
1	23	15	9	\N
1	24	15	9	\N
1	25	15	9	\N
1	26	15	2	1
1	27	15	2	1
1	28	15	2	\N
1	29	15	2	\N
1	30	15	2	1
1	31	15	2	1
1	32	15	2	\N
1	33	15	4	7
1	34	15	4	7
1	35	15	1	\N
1	36	15	1	1
1	37	15	1	\N
1	38	15	1	9
1	39	15	4	7
1	40	15	2	1
1	41	15	2	1
1	42	15	7	\N
1	43	15	3	2
1	44	15	3	3
1	45	15	1	9
1	46	15	1	\N
1	47	15	1	1
1	48	15	9	\N
1	49	15	9	\N
1	50	15	9	\N
1	51	15	9	\N
1	52	15	9	\N
1	53	15	1	\N
1	54	15	1	9
1	55	15	5	6
1	56	15	6	\N
1	57	15	6	\N
1	58	15	6	\N
1	59	15	1	9
1	60	15	1	1
1	1	16	3	2
1	2	16	3	2
1	3	16	3	2
1	4	16	3	2
1	5	16	3	\N
1	6	16	3	2
1	7	16	3	3
1	8	16	7	\N
1	9	16	7	\N
1	10	16	1	\N
1	11	16	7	\N
1	12	16	1	\N
1	13	16	9	\N
1	14	16	1	1
1	15	16	1	1
1	16	16	1	1
1	17	16	5	\N
1	18	16	5	6
1	19	16	5	8
1	20	16	5	8
1	21	16	5	8
1	22	16	1	9
1	23	16	9	\N
1	24	16	3	\N
1	25	16	2	1
1	26	16	2	1
1	27	16	7	\N
1	28	16	2	1
1	29	16	5	8
1	30	16	2	1
1	31	16	9	\N
1	32	16	9	\N
1	33	16	4	7
1	34	16	4	\N
1	35	16	1	\N
1	36	16	1	9
1	37	16	1	\N
1	38	16	5	\N
1	39	16	1	1
1	40	16	2	\N
1	41	16	2	\N
1	42	16	2	\N
1	43	16	5	8
1	44	16	2	1
1	45	16	1	\N
1	46	16	9	\N
1	47	16	9	\N
1	48	16	1	\N
1	49	16	1	1
1	50	16	9	\N
1	51	16	3	2
1	52	16	1	9
1	53	16	1	\N
1	54	16	1	1
1	55	16	6	\N
1	56	16	6	\N
1	57	16	6	\N
1	58	16	6	\N
1	59	16	1	\N
1	60	16	1	\N
1	1	17	3	\N
1	2	17	3	\N
1	3	17	3	2
1	4	17	3	\N
1	5	17	3	\N
1	6	17	3	\N
1	7	17	3	2
1	8	17	3	2
1	9	17	6	\N
1	10	17	7	\N
1	11	17	1	1
1	12	17	1	1
1	13	17	1	9
1	14	17	1	1
1	15	17	1	\N
1	16	17	7	\N
1	17	17	5	8
1	18	17	5	\N
1	19	17	5	8
1	20	17	5	\N
1	21	17	5	8
1	22	17	7	\N
1	23	17	2	1
1	24	17	2	1
1	25	17	2	1
1	26	17	2	1
1	27	17	6	\N
1	28	17	2	1
1	29	17	4	7
1	30	17	3	\N
1	31	17	2	1
1	32	17	2	1
1	33	17	4	7
1	34	17	4	7
1	35	17	1	9
1	36	17	1	9
1	37	17	1	\N
1	38	17	1	1
1	39	17	1	9
1	40	17	1	1
1	41	17	2	\N
1	42	17	2	\N
1	43	17	2	1
1	44	17	2	\N
1	45	17	2	1
1	46	17	1	9
1	47	17	1	\N
1	48	17	7	\N
1	49	17	1	1
1	50	17	4	7
1	51	17	4	\N
1	52	17	1	\N
1	53	17	4	\N
1	54	17	1	1
1	55	17	1	9
1	56	17	6	\N
1	57	17	6	\N
1	58	17	6	\N
1	59	17	1	9
1	60	17	1	9
1	1	18	3	2
1	2	18	9	\N
1	3	18	3	2
1	4	18	3	\N
1	5	18	3	2
1	6	18	6	\N
1	7	18	3	3
1	8	18	3	2
1	9	18	3	3
1	10	18	5	\N
1	11	18	1	1
1	12	18	1	1
1	13	18	1	\N
1	14	18	1	\N
1	15	18	7	\N
1	16	18	7	\N
1	17	18	5	6
1	18	18	5	\N
1	19	18	5	\N
1	20	18	5	8
1	21	18	5	\N
1	22	18	5	8
1	23	18	2	1
1	24	18	2	\N
1	25	18	2	1
1	26	18	2	\N
1	27	18	2	\N
1	28	18	5	6
1	29	18	2	\N
1	30	18	2	1
1	31	18	1	9
1	32	18	2	1
1	33	18	2	1
1	34	18	4	7
1	35	18	1	1
1	36	18	1	9
1	37	18	1	9
1	38	18	1	\N
1	39	18	1	\N
1	40	18	1	1
1	41	18	3	2
1	42	18	2	\N
1	43	18	2	\N
1	44	18	2	\N
1	45	18	2	1
1	46	18	1	9
1	47	18	9	\N
1	48	18	1	1
1	49	18	9	\N
1	50	18	9	\N
1	51	18	9	\N
1	52	18	4	\N
1	53	18	1	9
1	54	18	1	9
1	55	18	1	1
1	56	18	1	\N
1	57	18	6	\N
1	58	18	4	7
1	59	18	1	1
1	60	18	1	1
1	1	19	3	\N
1	2	19	9	\N
1	3	19	3	2
1	4	19	3	2
1	5	19	3	3
1	6	19	3	2
1	7	19	3	\N
1	8	19	3	2
1	9	19	3	3
1	10	19	3	2
1	11	19	1	9
1	12	19	1	9
1	13	19	1	9
1	14	19	1	9
1	15	19	5	\N
1	16	19	5	8
1	17	19	5	6
1	18	19	5	8
1	19	19	5	8
1	20	19	5	8
1	21	19	7	\N
1	22	19	5	6
1	23	19	2	1
1	24	19	2	\N
1	25	19	2	1
1	26	19	2	\N
1	27	19	9	\N
1	28	19	9	\N
1	29	19	9	\N
1	30	19	9	\N
1	31	19	9	\N
1	32	19	9	\N
1	33	19	2	\N
1	34	19	2	1
1	35	19	6	\N
1	36	19	1	9
1	37	19	1	1
1	38	19	1	9
1	39	19	1	\N
1	40	19	5	6
1	41	19	1	9
1	42	19	2	1
1	43	19	2	1
1	44	19	2	1
1	45	19	2	1
1	46	19	7	\N
1	47	19	9	\N
1	48	19	9	\N
1	49	19	1	\N
1	50	19	1	9
1	51	19	9	\N
1	52	19	9	\N
1	53	19	9	\N
1	54	19	9	\N
1	55	19	1	\N
1	56	19	1	\N
1	57	19	1	\N
1	58	19	1	9
1	59	19	8	\N
1	60	19	1	9
1	1	20	4	7
1	2	20	9	\N
1	3	20	3	3
1	4	20	3	3
1	5	20	3	2
1	6	20	3	2
1	7	20	3	\N
1	8	20	3	\N
1	9	20	3	2
1	10	20	3	2
1	11	20	1	1
1	12	20	3	2
1	13	20	4	7
1	14	20	1	\N
1	15	20	1	1
1	16	20	5	6
1	17	20	5	\N
1	18	20	5	8
1	19	20	5	8
1	20	20	5	6
1	21	20	6	\N
1	22	20	9	\N
1	23	20	9	\N
1	24	20	9	\N
1	25	20	4	7
1	26	20	2	\N
1	27	20	5	8
1	28	20	5	8
1	29	20	5	8
1	30	20	9	\N
1	31	20	9	\N
1	32	20	9	\N
1	33	20	2	1
1	34	20	2	1
1	35	20	5	8
1	36	20	1	\N
1	37	20	6	\N
1	38	20	1	1
1	39	20	1	9
1	40	20	1	\N
1	41	20	1	\N
1	42	20	1	9
1	43	20	2	1
1	44	20	6	\N
1	45	20	1	9
1	46	20	1	\N
1	47	20	9	\N
1	48	20	1	9
1	49	20	7	\N
1	50	20	1	9
1	51	20	9	\N
1	52	20	6	\N
1	53	20	6	\N
1	54	20	9	\N
1	55	20	9	\N
1	56	20	7	\N
1	57	20	1	\N
1	58	20	8	\N
1	59	20	1	1
1	60	20	1	\N
1	1	21	4	\N
1	2	21	9	\N
1	3	21	9	\N
1	4	21	9	\N
1	5	21	3	\N
1	6	21	3	2
1	7	21	3	\N
1	8	21	3	2
1	9	21	2	1
1	10	21	4	7
1	11	21	4	7
1	12	21	4	\N
1	13	21	4	7
1	14	21	6	\N
1	15	21	1	\N
1	16	21	1	9
1	17	21	5	8
1	18	21	1	1
1	19	21	5	6
1	20	21	5	8
1	21	21	5	8
1	22	21	9	\N
1	23	21	6	\N
1	24	21	9	\N
1	25	21	9	\N
1	26	21	9	\N
1	27	21	5	6
1	28	21	5	6
1	29	21	1	9
1	30	21	9	\N
1	31	21	6	\N
1	32	21	2	1
1	33	21	2	\N
1	34	21	1	1
1	35	21	2	1
1	36	21	1	\N
1	37	21	1	\N
1	38	21	9	\N
1	39	21	9	\N
1	40	21	9	\N
1	41	21	1	\N
1	42	21	9	\N
1	43	21	9	\N
1	44	21	1	1
1	45	21	1	\N
1	46	21	1	1
1	47	21	1	9
1	48	21	1	1
1	49	21	1	1
1	50	21	6	\N
1	51	21	9	\N
1	52	21	9	\N
1	53	21	9	\N
1	54	21	6	\N
1	55	21	9	\N
1	56	21	1	9
1	57	21	4	7
1	58	21	1	9
1	59	21	1	\N
1	60	21	1	9
1	1	22	4	7
1	2	22	9	\N
1	3	22	5	\N
1	4	22	3	\N
1	5	22	3	2
1	6	22	3	3
1	7	22	9	\N
1	8	22	6	\N
1	9	22	2	\N
1	10	22	2	\N
1	11	22	4	\N
1	12	22	4	\N
1	13	22	4	\N
1	14	22	4	7
1	15	22	1	\N
1	16	22	1	9
1	17	22	3	\N
1	18	22	9	\N
1	19	22	5	\N
1	20	22	5	8
1	21	22	5	8
1	22	22	9	\N
1	23	22	9	\N
1	24	22	6	\N
1	25	22	6	\N
1	26	22	5	\N
1	27	22	5	6
1	28	22	5	6
1	29	22	5	8
1	30	22	3	2
1	31	22	2	1
1	32	22	2	1
1	33	22	2	1
1	34	22	2	1
1	35	22	1	1
1	36	22	1	\N
1	37	22	1	\N
1	38	22	1	9
1	39	22	1	\N
1	40	22	9	\N
1	41	22	1	9
1	42	22	1	9
1	43	22	1	1
1	44	22	2	\N
1	45	22	9	\N
1	46	22	1	1
1	47	22	2	\N
1	48	22	1	9
1	49	22	1	9
1	50	22	1	9
1	51	22	1	\N
1	52	22	1	\N
1	53	22	1	9
1	54	22	1	9
1	55	22	9	\N
1	56	22	9	\N
1	57	22	1	1
1	58	22	9	\N
1	59	22	9	\N
1	60	22	9	\N
1	1	23	6	\N
1	2	23	9	\N
1	3	23	3	\N
1	4	23	3	\N
1	5	23	3	\N
1	6	23	3	\N
1	7	23	9	\N
1	8	23	2	1
1	9	23	2	\N
1	10	23	2	\N
1	11	23	2	1
1	12	23	4	7
1	13	23	4	7
1	14	23	4	7
1	15	23	1	9
1	16	23	1	\N
1	17	23	1	9
1	18	23	1	\N
1	19	23	3	2
1	20	23	3	3
1	21	23	5	8
1	22	23	5	8
1	23	23	5	8
1	24	23	6	\N
1	25	23	6	\N
1	26	23	1	9
1	27	23	5	6
1	28	23	5	8
1	29	23	5	\N
1	30	23	6	\N
1	31	23	2	1
1	32	23	2	1
1	33	23	2	\N
1	34	23	2	\N
1	35	23	1	1
1	36	23	1	9
1	37	23	1	9
1	38	23	1	\N
1	39	23	1	\N
1	40	23	9	\N
1	41	23	9	\N
1	42	23	1	\N
1	43	23	1	9
1	44	23	1	1
1	45	23	1	\N
1	46	23	1	9
1	47	23	2	1
1	48	23	1	1
1	49	23	1	\N
1	50	23	1	1
1	51	23	1	1
1	52	23	1	9
1	53	23	5	6
1	54	23	1	1
1	55	23	1	1
1	56	23	6	\N
1	57	23	1	1
1	58	23	9	\N
1	59	23	3	\N
1	60	23	3	3
1	1	24	6	\N
1	2	24	6	\N
1	3	24	3	3
1	4	24	3	\N
1	5	24	3	2
1	6	24	3	\N
1	7	24	3	2
1	8	24	2	1
1	9	24	2	1
1	10	24	1	1
1	11	24	2	1
1	12	24	2	1
1	13	24	4	7
1	14	24	4	7
1	15	24	1	9
1	16	24	1	1
1	17	24	5	\N
1	18	24	7	\N
1	19	24	3	2
1	20	24	3	\N
1	21	24	3	\N
1	22	24	5	6
1	23	24	5	\N
1	24	24	5	\N
1	25	24	6	\N
1	26	24	9	\N
1	27	24	9	\N
1	28	24	9	\N
1	29	24	5	\N
1	30	24	9	\N
1	31	24	9	\N
1	32	24	9	\N
1	33	24	2	1
1	34	24	2	1
1	35	24	1	1
1	36	24	1	1
1	37	24	9	\N
1	38	24	9	\N
1	39	24	9	\N
1	40	24	1	\N
1	41	24	1	1
1	42	24	1	\N
1	43	24	1	\N
1	44	24	6	\N
1	45	24	1	9
1	46	24	1	9
1	47	24	1	\N
1	48	24	1	9
1	49	24	7	\N
1	50	24	1	\N
1	51	24	8	\N
1	52	24	8	\N
1	53	24	8	\N
1	54	24	1	\N
1	55	24	1	9
1	56	24	1	9
1	57	24	1	1
1	58	24	9	\N
1	59	24	3	3
1	60	24	3	\N
1	1	25	6	\N
1	2	25	6	\N
1	3	25	7	\N
1	4	25	6	\N
1	5	25	2	\N
1	6	25	3	\N
1	7	25	3	2
1	8	25	2	\N
1	9	25	4	7
1	10	25	2	1
1	11	25	5	\N
1	12	25	2	\N
1	13	25	2	1
1	14	25	4	7
1	15	25	1	1
1	16	25	1	9
1	17	25	1	9
1	18	25	1	\N
1	19	25	3	\N
1	20	25	3	2
1	21	25	3	2
1	22	25	3	2
1	23	25	5	\N
1	24	25	1	1
1	25	25	1	9
1	26	25	9	\N
1	27	25	1	\N
1	28	25	1	1
1	29	25	1	1
1	30	25	2	1
1	31	25	2	1
1	32	25	9	\N
1	33	25	9	\N
1	34	25	9	\N
1	35	25	9	\N
1	36	25	1	\N
1	37	25	9	\N
1	38	25	1	1
1	39	25	1	\N
1	40	25	7	\N
1	41	25	1	9
1	42	25	1	\N
1	43	25	1	\N
1	44	25	1	\N
1	45	25	4	7
1	46	25	1	\N
1	47	25	1	9
1	48	25	1	9
1	49	25	3	2
1	50	25	8	\N
1	51	25	8	\N
1	52	25	8	\N
1	53	25	8	\N
1	54	25	8	\N
1	55	25	1	9
1	56	25	1	1
1	57	25	1	1
1	58	25	1	1
1	59	25	3	2
1	60	25	9	\N
1	1	26	9	\N
1	2	26	9	\N
1	3	26	6	\N
1	4	26	6	\N
1	5	26	3	\N
1	6	26	3	\N
1	7	26	3	2
1	8	26	3	\N
1	9	26	2	1
1	10	26	2	\N
1	11	26	2	\N
1	12	26	3	2
1	13	26	6	\N
1	14	26	1	9
1	15	26	1	9
1	16	26	1	\N
1	17	26	1	9
1	18	26	6	\N
1	19	26	3	2
1	20	26	3	\N
1	21	26	3	3
1	22	26	3	3
1	23	26	3	\N
1	24	26	4	\N
1	25	26	1	\N
1	26	26	1	1
1	27	26	4	7
1	28	26	1	\N
1	29	26	6	\N
1	30	26	2	1
1	31	26	2	1
1	32	26	9	\N
1	33	26	7	\N
1	34	26	3	\N
1	35	26	1	1
1	36	26	1	9
1	37	26	1	\N
1	38	26	1	\N
1	39	26	1	9
1	40	26	1	9
1	41	26	1	\N
1	42	26	9	\N
1	43	26	1	\N
1	44	26	1	\N
1	45	26	1	\N
1	46	26	1	1
1	47	26	1	\N
1	48	26	7	\N
1	49	26	1	\N
1	50	26	1	1
1	51	26	8	\N
1	52	26	8	\N
1	53	26	8	\N
1	54	26	8	\N
1	55	26	8	\N
1	56	26	1	1
1	57	26	1	9
1	58	26	5	6
1	59	26	1	9
1	60	26	1	\N
1	1	27	9	\N
1	2	27	6	\N
1	3	27	6	\N
1	4	27	6	\N
1	5	27	3	3
1	6	27	3	\N
1	7	27	1	1
1	8	27	3	\N
1	9	27	2	1
1	10	27	2	1
1	11	27	2	1
1	12	27	2	\N
1	13	27	1	\N
1	14	27	1	9
1	15	27	1	1
1	16	27	1	1
1	17	27	1	\N
1	18	27	1	1
1	19	27	3	2
1	20	27	3	2
1	21	27	3	2
1	22	27	3	\N
1	23	27	4	7
1	24	27	4	7
1	25	27	1	\N
1	26	27	1	9
1	27	27	1	\N
1	28	27	1	1
1	29	27	1	\N
1	30	27	2	1
1	31	27	2	1
1	32	27	9	\N
1	33	27	3	2
1	34	27	3	2
1	35	27	2	1
1	36	27	8	\N
1	37	27	1	1
1	38	27	1	\N
1	39	27	1	1
1	40	27	1	1
1	41	27	1	9
1	42	27	1	9
1	43	27	1	\N
1	44	27	1	\N
1	45	27	1	\N
1	46	27	1	1
1	47	27	4	\N
1	48	27	4	\N
1	49	27	1	9
1	50	27	1	1
1	51	27	3	2
1	52	27	8	\N
1	53	27	8	\N
1	54	27	8	\N
1	55	27	1	\N
1	56	27	1	\N
1	57	27	1	9
1	58	27	1	\N
1	59	27	3	3
1	60	27	1	1
1	1	28	9	\N
1	2	28	6	\N
1	3	28	6	\N
1	4	28	6	\N
1	5	28	3	\N
1	6	28	4	\N
1	7	28	6	\N
1	8	28	1	1
1	9	28	2	1
1	10	28	5	8
1	11	28	2	1
1	12	28	2	1
1	13	28	1	9
1	14	28	9	\N
1	15	28	1	9
1	16	28	1	1
1	17	28	1	1
1	18	28	1	9
1	19	28	1	1
1	20	28	3	\N
1	21	28	3	2
1	22	28	3	3
1	23	28	3	2
1	24	28	4	7
1	25	28	1	\N
1	26	28	2	1
1	27	28	6	\N
1	28	28	1	9
1	29	28	1	\N
1	30	28	1	\N
1	31	28	2	1
1	32	28	7	\N
1	33	28	3	\N
1	34	28	2	\N
1	35	28	2	\N
1	36	28	2	1
1	37	28	1	\N
1	38	28	1	\N
1	39	28	1	1
1	40	28	1	9
1	41	28	7	\N
1	42	28	1	\N
1	43	28	1	1
1	44	28	1	\N
1	45	28	1	1
1	46	28	1	\N
1	47	28	1	9
1	48	28	7	\N
1	49	28	1	\N
1	50	28	1	1
1	51	28	8	\N
1	52	28	8	\N
1	53	28	8	\N
1	54	28	8	\N
1	55	28	8	\N
1	56	28	1	\N
1	57	28	1	\N
1	58	28	1	9
1	59	28	1	9
1	60	28	5	\N
1	1	29	6	\N
1	2	29	2	\N
1	3	29	6	\N
1	4	29	6	\N
1	5	29	6	\N
1	6	29	6	\N
1	7	29	6	\N
1	8	29	2	\N
1	9	29	2	\N
1	10	29	3	\N
1	11	29	2	1
1	12	29	4	7
1	13	29	4	\N
1	14	29	9	\N
1	15	29	9	\N
1	16	29	9	\N
1	17	29	9	\N
1	18	29	9	\N
1	19	29	9	\N
1	20	29	3	2
1	21	29	3	2
1	22	29	7	\N
1	23	29	3	3
1	24	29	3	\N
1	25	29	9	\N
1	26	29	1	1
1	27	29	1	9
1	28	29	1	\N
1	29	29	1	\N
1	30	29	1	\N
1	31	29	2	\N
1	32	29	2	\N
1	33	29	2	\N
1	34	29	2	\N
1	35	29	2	\N
1	36	29	2	1
1	37	29	1	9
1	38	29	1	9
1	39	29	1	1
1	40	29	5	6
1	41	29	1	\N
1	42	29	1	1
1	43	29	1	9
1	44	29	1	\N
1	45	29	1	9
1	46	29	1	\N
1	47	29	1	\N
1	48	29	1	1
1	49	29	1	9
1	50	29	1	9
1	51	29	8	\N
1	52	29	8	\N
1	53	29	8	\N
1	54	29	8	\N
1	55	29	8	\N
1	56	29	8	\N
1	57	29	8	\N
1	58	29	8	\N
1	59	29	8	\N
1	60	29	8	\N
1	1	30	6	\N
1	2	30	4	\N
1	3	30	6	\N
1	4	30	9	\N
1	5	30	6	\N
1	6	30	6	\N
1	7	30	6	\N
1	8	30	2	1
1	9	30	2	1
1	10	30	2	1
1	11	30	9	\N
1	12	30	9	\N
1	13	30	9	\N
1	14	30	4	\N
1	15	30	9	\N
1	16	30	4	7
1	17	30	9	\N
1	18	30	5	6
1	19	30	9	\N
1	20	30	9	\N
1	21	30	4	\N
1	22	30	4	7
1	23	30	3	2
1	24	30	3	2
1	25	30	9	\N
1	26	30	9	\N
1	27	30	9	\N
1	28	30	9	\N
1	29	30	9	\N
1	30	30	1	1
1	31	30	1	\N
1	32	30	2	1
1	33	30	2	1
1	34	30	9	\N
1	35	30	9	\N
1	36	30	2	1
1	37	30	1	9
1	38	30	7	\N
1	39	30	1	\N
1	40	30	1	1
1	41	30	4	7
1	42	30	1	\N
1	43	30	1	9
1	44	30	1	9
1	45	30	1	\N
1	46	30	1	9
1	47	30	1	9
1	48	30	1	1
1	49	30	1	1
1	50	30	1	\N
1	51	30	8	\N
1	52	30	8	\N
1	53	30	8	\N
1	54	30	8	\N
1	55	30	8	\N
1	56	30	8	\N
1	57	30	8	\N
1	58	30	8	\N
1	59	30	8	\N
1	60	30	8	\N
1	1	31	4	\N
1	2	31	4	7
1	3	31	4	7
1	4	31	6	\N
1	5	31	6	\N
1	6	31	6	\N
1	7	31	6	\N
1	8	31	2	\N
1	9	31	2	\N
1	10	31	2	1
1	11	31	2	1
1	12	31	9	\N
1	13	31	4	7
1	14	31	4	7
1	15	31	7	\N
1	16	31	4	7
1	17	31	9	\N
1	18	31	9	\N
1	19	31	5	6
1	20	31	4	7
1	21	31	4	\N
1	22	31	4	\N
1	23	31	3	2
1	24	31	3	\N
1	25	31	3	\N
1	26	31	9	\N
1	27	31	7	\N
1	28	31	9	\N
1	29	31	3	\N
1	30	31	1	9
1	31	31	1	\N
1	32	31	1	\N
1	33	31	2	1
1	34	31	9	\N
1	35	31	2	1
1	36	31	2	\N
1	37	31	2	1
1	38	31	1	1
1	39	31	1	1
1	40	31	1	1
1	41	31	9	\N
1	42	31	9	\N
1	43	31	9	\N
1	44	31	7	\N
1	45	31	9	\N
1	46	31	9	\N
1	47	31	2	1
1	48	31	3	3
1	49	31	1	\N
1	50	31	1	1
1	51	31	1	9
1	52	31	8	\N
1	53	31	8	\N
1	54	31	8	\N
1	55	31	8	\N
1	56	31	8	\N
1	57	31	8	\N
1	58	31	8	\N
1	59	31	8	\N
1	60	31	8	\N
1	1	32	4	7
1	2	32	4	7
1	3	32	4	7
1	4	32	4	\N
1	5	32	6	\N
1	6	32	6	\N
1	7	32	6	\N
1	8	32	2	1
1	9	32	2	\N
1	10	32	3	3
1	11	32	2	1
1	12	32	2	\N
1	13	32	4	\N
1	14	32	4	7
1	15	32	4	7
1	16	32	4	7
1	17	32	9	\N
1	18	32	3	2
1	19	32	3	3
1	20	32	6	\N
1	21	32	4	7
1	22	32	4	7
1	23	32	3	3
1	24	32	8	\N
1	25	32	3	2
1	26	32	1	\N
1	27	32	1	\N
1	28	32	1	1
1	29	32	1	1
1	30	32	2	1
1	31	32	1	\N
1	32	32	1	\N
1	33	32	1	\N
1	34	32	9	\N
1	35	32	9	\N
1	36	32	9	\N
1	37	32	9	\N
1	38	32	9	\N
1	39	32	9	\N
1	40	32	9	\N
1	41	32	1	1
1	42	32	9	\N
1	43	32	7	\N
1	44	32	7	\N
1	45	32	9	\N
1	46	32	2	\N
1	47	32	2	1
1	48	32	7	\N
1	49	32	1	1
1	50	32	1	1
1	51	32	1	\N
1	52	32	8	\N
1	53	32	8	\N
1	54	32	8	\N
1	55	32	8	\N
1	56	32	8	\N
1	57	32	8	\N
1	58	32	8	\N
1	59	32	8	\N
1	60	32	8	\N
1	1	33	4	\N
1	2	33	4	7
1	3	33	9	\N
1	4	33	4	7
1	5	33	4	7
1	6	33	5	\N
1	7	33	6	\N
1	8	33	2	1
1	9	33	7	\N
1	10	33	2	1
1	11	33	2	\N
1	12	33	2	\N
1	13	33	2	1
1	14	33	4	7
1	15	33	4	7
1	16	33	4	7
1	17	33	4	7
1	18	33	3	\N
1	19	33	3	2
1	20	33	7	\N
1	21	33	4	7
1	22	33	7	\N
1	23	33	3	\N
1	24	33	8	\N
1	25	33	8	\N
1	26	33	1	1
1	27	33	2	1
1	28	33	1	9
1	29	33	1	\N
1	30	33	1	\N
1	31	33	1	9
1	32	33	1	9
1	33	33	1	9
1	34	33	9	\N
1	35	33	6	\N
1	36	33	6	\N
1	37	33	9	\N
1	38	33	3	3
1	39	33	3	2
1	40	33	1	\N
1	41	33	1	\N
1	42	33	9	\N
1	43	33	7	\N
1	44	33	7	\N
1	45	33	7	\N
1	46	33	2	1
1	47	33	8	\N
1	48	33	1	1
1	49	33	1	1
1	50	33	4	7
1	51	33	1	9
1	52	33	1	9
1	53	33	8	\N
1	54	33	8	\N
1	55	33	8	\N
1	56	33	8	\N
1	57	33	8	\N
1	58	33	8	\N
1	59	33	8	\N
1	60	33	8	\N
1	1	34	4	\N
1	2	34	4	7
1	3	34	4	7
1	4	34	4	7
1	5	34	3	2
1	6	34	3	3
1	7	34	2	\N
1	8	34	2	\N
1	9	34	2	\N
1	10	34	2	1
1	11	34	2	1
1	12	34	9	\N
1	13	34	9	\N
1	14	34	4	7
1	15	34	4	\N
1	16	34	4	7
1	17	34	4	7
1	18	34	6	\N
1	19	34	3	\N
1	20	34	3	2
1	21	34	2	1
1	22	34	1	9
1	23	34	8	\N
1	24	34	8	\N
1	25	34	8	\N
1	26	34	1	1
1	27	34	1	\N
1	28	34	3	2
1	29	34	4	\N
1	30	34	1	\N
1	31	34	1	1
1	32	34	1	\N
1	33	34	1	\N
1	34	34	9	\N
1	35	34	9	\N
1	36	34	6	\N
1	37	34	9	\N
1	38	34	3	\N
1	39	34	3	2
1	40	34	9	\N
1	41	34	9	\N
1	42	34	1	\N
1	43	34	7	\N
1	44	34	9	\N
1	45	34	9	\N
1	46	34	8	\N
1	47	34	1	\N
1	48	34	1	\N
1	49	34	1	1
1	50	34	1	9
1	51	34	1	1
1	52	34	1	1
1	53	34	1	9
1	54	34	8	\N
1	55	34	7	\N
1	56	34	8	\N
1	57	34	8	\N
1	58	34	8	\N
1	59	34	8	\N
1	60	34	8	\N
1	1	35	4	\N
1	2	35	4	\N
1	3	35	4	\N
1	4	35	9	\N
1	5	35	3	3
1	6	35	3	\N
1	7	35	2	\N
1	8	35	2	1
1	9	35	2	1
1	10	35	9	\N
1	11	35	3	3
1	12	35	9	\N
1	13	35	4	7
1	14	35	4	7
1	15	35	4	\N
1	16	35	4	7
1	17	35	4	\N
1	18	35	4	\N
1	19	35	3	\N
1	20	35	3	3
1	21	35	3	2
1	22	35	1	9
1	23	35	8	\N
1	24	35	8	\N
1	25	35	8	\N
1	26	35	8	\N
1	27	35	1	\N
1	28	35	1	\N
1	29	35	6	\N
1	30	35	1	1
1	31	35	1	9
1	32	35	9	\N
1	33	35	9	\N
1	34	35	1	9
1	35	35	9	\N
1	36	35	9	\N
1	37	35	3	2
1	38	35	3	3
1	39	35	3	\N
1	40	35	9	\N
1	41	35	4	7
1	42	35	1	\N
1	43	35	1	1
1	44	35	9	\N
1	45	35	8	\N
1	46	35	8	\N
1	47	35	1	9
1	48	35	1	9
1	49	35	5	6
1	50	35	5	6
1	51	35	1	\N
1	52	35	1	9
1	53	35	1	1
1	54	35	8	\N
1	55	35	8	\N
1	56	35	8	\N
1	57	35	8	\N
1	58	35	8	\N
1	59	35	8	\N
1	60	35	8	\N
1	1	36	4	7
1	2	36	4	\N
1	3	36	4	7
1	4	36	4	7
1	5	36	3	2
1	6	36	5	8
1	7	36	2	1
1	8	36	2	1
1	9	36	2	1
1	10	36	9	\N
1	11	36	9	\N
1	12	36	3	2
1	13	36	5	8
1	14	36	4	7
1	15	36	4	7
1	16	36	4	7
1	17	36	1	\N
1	18	36	3	\N
1	19	36	3	2
1	20	36	3	\N
1	21	36	3	2
1	22	36	3	\N
1	23	36	1	9
1	24	36	8	\N
1	25	36	8	\N
1	26	36	8	\N
1	27	36	1	9
1	28	36	1	\N
1	29	36	1	1
1	30	36	1	9
1	31	36	6	\N
1	32	36	9	\N
1	33	36	3	\N
1	34	36	1	1
1	35	36	1	1
1	36	36	9	\N
1	37	36	7	\N
1	38	36	9	\N
1	39	36	3	\N
1	40	36	9	\N
1	41	36	1	9
1	42	36	1	\N
1	43	36	1	9
1	44	36	8	\N
1	45	36	8	\N
1	46	36	8	\N
1	47	36	1	9
1	48	36	1	9
1	49	36	1	1
1	50	36	1	1
1	51	36	1	\N
1	52	36	1	9
1	53	36	1	\N
1	54	36	8	\N
1	55	36	8	\N
1	56	36	8	\N
1	57	36	8	\N
1	58	36	5	\N
1	59	36	8	\N
1	60	36	8	\N
1	1	37	4	7
1	2	37	4	\N
1	3	37	4	7
1	4	37	4	7
1	5	37	6	\N
1	6	37	2	1
1	7	37	2	\N
1	8	37	2	\N
1	9	37	2	\N
1	10	37	9	\N
1	11	37	6	\N
1	12	37	3	3
1	13	37	9	\N
1	14	37	4	7
1	15	37	4	\N
1	16	37	4	\N
1	17	37	6	\N
1	18	37	3	3
1	19	37	5	8
1	20	37	3	2
1	21	37	6	\N
1	22	37	3	\N
1	23	37	3	2
1	24	37	8	\N
1	25	37	5	8
1	26	37	1	\N
1	27	37	8	\N
1	28	37	7	\N
1	29	37	1	1
1	30	37	1	\N
1	31	37	3	3
1	32	37	3	\N
1	33	37	3	3
1	34	37	1	\N
1	35	37	1	\N
1	36	37	9	\N
1	37	37	9	\N
1	38	37	3	3
1	39	37	3	3
1	40	37	9	\N
1	41	37	1	\N
1	42	37	1	9
1	43	37	8	\N
1	44	37	8	\N
1	45	37	8	\N
1	46	37	1	\N
1	47	37	8	\N
1	48	37	1	1
1	49	37	1	\N
1	50	37	1	9
1	51	37	1	\N
1	52	37	3	2
1	53	37	1	\N
1	54	37	1	\N
1	55	37	8	\N
1	56	37	8	\N
1	57	37	8	\N
1	58	37	8	\N
1	59	37	8	\N
1	60	37	8	\N
1	1	38	4	\N
1	2	38	4	\N
1	3	38	4	7
1	4	38	4	7
1	5	38	9	\N
1	6	38	9	\N
1	7	38	1	1
1	8	38	2	\N
1	9	38	2	1
1	10	38	9	\N
1	11	38	9	\N
1	12	38	3	2
1	13	38	3	\N
1	14	38	3	3
1	15	38	4	7
1	16	38	2	\N
1	17	38	2	1
1	18	38	8	\N
1	19	38	8	\N
1	20	38	3	2
1	21	38	3	2
1	22	38	4	7
1	23	38	8	\N
1	24	38	5	\N
1	25	38	5	6
1	26	38	5	\N
1	27	38	1	9
1	28	38	1	\N
1	29	38	7	\N
1	30	38	1	\N
1	31	38	1	9
1	32	38	3	\N
1	33	38	3	2
1	34	38	1	1
1	35	38	1	1
1	36	38	1	1
1	37	38	1	\N
1	38	38	4	7
1	39	38	3	2
1	40	38	9	\N
1	41	38	9	\N
1	42	38	8	\N
1	43	38	8	\N
1	44	38	8	\N
1	45	38	8	\N
1	46	38	8	\N
1	47	38	8	\N
1	48	38	8	\N
1	49	38	1	1
1	50	38	1	1
1	51	38	4	\N
1	52	38	1	\N
1	53	38	3	2
1	54	38	8	\N
1	55	38	8	\N
1	56	38	4	\N
1	57	38	8	\N
1	58	38	8	\N
1	59	38	8	\N
1	60	38	8	\N
1	1	39	4	\N
1	2	39	4	7
1	3	39	4	\N
1	4	39	4	7
1	5	39	4	\N
1	6	39	1	1
1	7	39	1	9
1	8	39	1	\N
1	9	39	4	7
1	10	39	9	\N
1	11	39	3	3
1	12	39	3	3
1	13	39	2	\N
1	14	39	3	3
1	15	39	3	2
1	16	39	2	1
1	17	39	2	1
1	18	39	8	\N
1	19	39	8	\N
1	20	39	8	\N
1	21	39	8	\N
1	22	39	8	\N
1	23	39	8	\N
1	24	39	8	\N
1	25	39	8	\N
1	26	39	5	8
1	27	39	1	1
1	28	39	1	9
1	29	39	1	1
1	30	39	1	9
1	31	39	1	\N
1	32	39	3	3
1	33	39	5	\N
1	34	39	1	9
1	35	39	6	\N
1	36	39	1	9
1	37	39	1	\N
1	38	39	1	\N
1	39	39	1	\N
1	40	39	9	\N
1	41	39	8	\N
1	42	39	8	\N
1	43	39	8	\N
1	44	39	1	\N
1	45	39	8	\N
1	46	39	8	\N
1	47	39	8	\N
1	48	39	8	\N
1	49	39	1	\N
1	50	39	5	\N
1	51	39	6	\N
1	52	39	1	\N
1	53	39	1	\N
1	54	39	8	\N
1	55	39	8	\N
1	56	39	8	\N
1	57	39	8	\N
1	58	39	8	\N
1	59	39	8	\N
1	60	39	8	\N
1	1	40	4	7
1	2	40	3	3
1	3	40	4	7
1	4	40	6	\N
1	5	40	4	7
1	6	40	9	\N
1	7	40	1	\N
1	8	40	1	\N
1	9	40	1	1
1	10	40	1	9
1	11	40	3	2
1	12	40	1	1
1	13	40	3	\N
1	14	40	6	\N
1	15	40	3	3
1	16	40	2	1
1	17	40	2	\N
1	18	40	2	1
1	19	40	8	\N
1	20	40	4	7
1	21	40	8	\N
1	22	40	8	\N
1	23	40	8	\N
1	24	40	8	\N
1	25	40	8	\N
1	26	40	1	9
1	27	40	1	\N
1	28	40	9	\N
1	29	40	9	\N
1	30	40	1	\N
1	31	40	1	1
1	32	40	1	\N
1	33	40	6	\N
1	34	40	6	\N
1	35	40	2	1
1	36	40	1	\N
1	37	40	1	9
1	38	40	7	\N
1	39	40	1	\N
1	40	40	8	\N
1	41	40	8	\N
1	42	40	8	\N
1	43	40	8	\N
1	44	40	8	\N
1	45	40	8	\N
1	46	40	8	\N
1	47	40	8	\N
1	48	40	8	\N
1	49	40	1	9
1	50	40	1	\N
1	51	40	1	\N
1	52	40	9	\N
1	53	40	8	\N
1	54	40	8	\N
1	55	40	8	\N
1	56	40	8	\N
1	57	40	8	\N
1	58	40	8	\N
1	59	40	8	\N
1	60	40	8	\N
1	1	41	3	3
1	2	41	3	\N
1	3	41	2	1
1	4	41	4	7
1	5	41	4	\N
1	6	41	4	7
1	7	41	5	8
1	8	41	1	\N
1	9	41	1	9
1	10	41	1	9
1	11	41	1	1
1	12	41	1	1
1	13	41	1	1
1	14	41	7	\N
1	15	41	2	1
1	16	41	2	1
1	17	41	1	9
1	18	41	8	\N
1	19	41	2	\N
1	20	41	2	1
1	21	41	8	\N
1	22	41	8	\N
1	23	41	8	\N
1	24	41	8	\N
1	25	41	8	\N
1	26	41	4	7
1	27	41	6	\N
1	28	41	1	\N
1	29	41	1	9
1	30	41	1	1
1	31	41	1	9
1	32	41	1	1
1	33	41	3	\N
1	34	41	6	\N
1	35	41	6	\N
1	36	41	3	2
1	37	41	1	1
1	38	41	1	1
1	39	41	8	\N
1	40	41	8	\N
1	41	41	8	\N
1	42	41	8	\N
1	43	41	8	\N
1	44	41	8	\N
1	45	41	8	\N
1	46	41	8	\N
1	47	41	8	\N
1	48	41	8	\N
1	49	41	8	\N
1	50	41	8	\N
1	51	41	8	\N
1	52	41	8	\N
1	53	41	6	\N
1	54	41	8	\N
1	55	41	8	\N
1	56	41	8	\N
1	57	41	8	\N
1	58	41	8	\N
1	59	41	8	\N
1	60	41	8	\N
1	1	42	3	2
1	2	42	3	2
1	3	42	3	\N
1	4	42	4	\N
1	5	42	4	\N
1	6	42	4	7
1	7	42	4	\N
1	8	42	1	\N
1	9	42	1	\N
1	10	42	1	9
1	11	42	1	1
1	12	42	1	\N
1	13	42	1	1
1	14	42	1	9
1	15	42	8	\N
1	16	42	8	\N
1	17	42	3	2
1	18	42	8	\N
1	19	42	8	\N
1	20	42	8	\N
1	21	42	8	\N
1	22	42	8	\N
1	23	42	8	\N
1	24	42	8	\N
1	25	42	8	\N
1	26	42	8	\N
1	27	42	3	\N
1	28	42	1	1
1	29	42	3	3
1	30	42	1	\N
1	31	42	1	9
1	32	42	1	\N
1	33	42	1	\N
1	34	42	7	\N
1	35	42	4	7
1	36	42	1	\N
1	37	42	1	9
1	38	42	1	1
1	39	42	8	\N
1	40	42	1	1
1	41	42	8	\N
1	42	42	8	\N
1	43	42	8	\N
1	44	42	8	\N
1	45	42	7	\N
1	46	42	8	\N
1	47	42	8	\N
1	48	42	8	\N
1	49	42	8	\N
1	50	42	8	\N
1	51	42	8	\N
1	52	42	8	\N
1	53	42	8	\N
1	54	42	8	\N
1	55	42	8	\N
1	56	42	8	\N
1	57	42	8	\N
1	58	42	8	\N
1	59	42	8	\N
1	60	42	8	\N
1	1	43	3	2
1	2	43	3	\N
1	3	43	3	2
1	4	43	3	2
1	5	43	4	7
1	6	43	2	1
1	7	43	9	\N
1	8	43	9	\N
1	9	43	5	6
1	10	43	1	9
1	11	43	1	9
1	12	43	1	\N
1	13	43	1	\N
1	14	43	1	\N
1	15	43	1	9
1	16	43	8	\N
1	17	43	8	\N
1	18	43	8	\N
1	19	43	8	\N
1	20	43	5	6
1	21	43	8	\N
1	22	43	8	\N
1	23	43	8	\N
1	24	43	8	\N
1	25	43	8	\N
1	26	43	8	\N
1	27	43	8	\N
1	28	43	3	\N
1	29	43	1	\N
1	30	43	1	\N
1	31	43	1	\N
1	32	43	1	\N
1	33	43	4	7
1	34	43	4	7
1	35	43	4	\N
1	36	43	1	\N
1	37	43	5	\N
1	38	43	8	\N
1	39	43	8	\N
1	40	43	8	\N
1	41	43	8	\N
1	42	43	8	\N
1	43	43	8	\N
1	44	43	8	\N
1	45	43	8	\N
1	46	43	8	\N
1	47	43	8	\N
1	48	43	8	\N
1	49	43	8	\N
1	50	43	8	\N
1	51	43	8	\N
1	52	43	8	\N
1	53	43	8	\N
1	54	43	8	\N
1	55	43	8	\N
1	56	43	8	\N
1	57	43	8	\N
1	58	43	8	\N
1	59	43	8	\N
1	60	43	8	\N
1	1	44	9	\N
1	2	44	3	2
1	3	44	3	\N
1	4	44	3	2
1	5	44	3	2
1	6	44	6	\N
1	7	44	9	\N
1	8	44	6	\N
1	9	44	1	9
1	10	44	1	\N
1	11	44	1	9
1	12	44	1	1
1	13	44	4	\N
1	14	44	1	9
1	15	44	5	6
1	16	44	8	\N
1	17	44	8	\N
1	18	44	8	\N
1	19	44	8	\N
1	20	44	8	\N
1	21	44	8	\N
1	22	44	8	\N
1	23	44	8	\N
1	24	44	8	\N
1	25	44	8	\N
1	26	44	8	\N
1	27	44	8	\N
1	28	44	8	\N
1	29	44	8	\N
1	30	44	8	\N
1	31	44	8	\N
1	32	44	1	\N
1	33	44	1	1
1	34	44	4	7
1	35	44	4	\N
1	36	44	7	\N
1	37	44	1	9
1	38	44	3	3
1	39	44	8	\N
1	40	44	8	\N
1	41	44	8	\N
1	42	44	8	\N
1	43	44	8	\N
1	44	44	8	\N
1	45	44	8	\N
1	46	44	8	\N
1	47	44	8	\N
1	48	44	8	\N
1	49	44	8	\N
1	50	44	8	\N
1	51	44	8	\N
1	52	44	8	\N
1	53	44	8	\N
1	54	44	8	\N
1	55	44	8	\N
1	56	44	8	\N
1	57	44	8	\N
1	58	44	8	\N
1	59	44	8	\N
1	60	44	8	\N
1	1	45	9	\N
1	2	45	3	\N
1	3	45	3	\N
1	4	45	3	\N
1	5	45	2	\N
1	6	45	2	1
1	7	45	5	6
1	8	45	1	9
1	9	45	1	1
1	10	45	1	9
1	11	45	1	9
1	12	45	1	9
1	13	45	1	\N
1	14	45	1	9
1	15	45	8	\N
1	16	45	8	\N
1	17	45	8	\N
1	18	45	8	\N
1	19	45	8	\N
1	20	45	8	\N
1	21	45	8	\N
1	22	45	8	\N
1	23	45	8	\N
1	24	45	8	\N
1	25	45	8	\N
1	26	45	8	\N
1	27	45	8	\N
1	28	45	8	\N
1	29	45	2	\N
1	30	45	8	\N
1	31	45	8	\N
1	32	45	8	\N
1	33	45	1	1
1	34	45	1	9
1	35	45	4	7
1	36	45	4	\N
1	37	45	1	1
1	38	45	8	\N
1	39	45	8	\N
1	40	45	8	\N
1	41	45	8	\N
1	42	45	8	\N
1	43	45	8	\N
1	44	45	8	\N
1	45	45	8	\N
1	46	45	8	\N
1	47	45	8	\N
1	48	45	8	\N
1	49	45	8	\N
1	50	45	8	\N
1	51	45	8	\N
1	52	45	8	\N
1	53	45	8	\N
1	54	45	8	\N
1	55	45	8	\N
1	56	45	8	\N
1	57	45	8	\N
1	58	45	8	\N
1	59	45	8	\N
1	60	45	8	\N
1	1	46	9	\N
1	2	46	9	\N
1	3	46	3	2
1	4	46	3	2
1	5	46	2	1
1	6	46	3	3
1	7	46	1	9
1	8	46	1	9
1	9	46	1	9
1	10	46	1	9
1	11	46	1	1
1	12	46	7	\N
1	13	46	1	1
1	14	46	2	\N
1	15	46	1	\N
1	16	46	8	\N
1	17	46	8	\N
1	18	46	8	\N
1	19	46	8	\N
1	20	46	8	\N
1	21	46	8	\N
1	22	46	8	\N
1	23	46	8	\N
1	24	46	8	\N
1	25	46	8	\N
1	26	46	8	\N
1	27	46	8	\N
1	28	46	8	\N
1	29	46	8	\N
1	30	46	8	\N
1	31	46	8	\N
1	32	46	8	\N
1	33	46	8	\N
1	34	46	1	9
1	35	46	6	\N
1	36	46	4	7
1	37	46	4	\N
1	38	46	1	\N
1	39	46	8	\N
1	40	46	8	\N
1	41	46	8	\N
1	42	46	8	\N
1	43	46	8	\N
1	44	46	8	\N
1	45	46	8	\N
1	46	46	4	\N
1	47	46	8	\N
1	48	46	8	\N
1	49	46	8	\N
1	50	46	8	\N
1	51	46	8	\N
1	52	46	8	\N
1	53	46	8	\N
1	54	46	8	\N
1	55	46	8	\N
1	56	46	8	\N
1	57	46	8	\N
1	58	46	8	\N
1	59	46	8	\N
1	60	46	8	\N
1	1	47	9	\N
1	2	47	3	3
1	3	47	3	2
1	4	47	3	\N
1	5	47	3	3
1	6	47	3	\N
1	7	47	1	\N
1	8	47	1	9
1	9	47	1	1
1	10	47	1	\N
1	11	47	1	9
1	12	47	1	\N
1	13	47	1	1
1	14	47	6	\N
1	15	47	5	6
1	16	47	1	9
1	17	47	8	\N
1	18	47	8	\N
1	19	47	8	\N
1	20	47	8	\N
1	21	47	8	\N
1	22	47	8	\N
1	23	47	8	\N
1	24	47	8	\N
1	25	47	8	\N
1	26	47	1	\N
1	27	47	8	\N
1	28	47	8	\N
1	29	47	8	\N
1	30	47	8	\N
1	31	47	8	\N
1	32	47	8	\N
1	33	47	8	\N
1	34	47	1	\N
1	35	47	1	9
1	36	47	9	\N
1	37	47	9	\N
1	38	47	8	\N
1	39	47	8	\N
1	40	47	8	\N
1	41	47	8	\N
1	42	47	8	\N
1	43	47	8	\N
1	44	47	8	\N
1	45	47	8	\N
1	46	47	8	\N
1	47	47	8	\N
1	48	47	8	\N
1	49	47	8	\N
1	50	47	8	\N
1	51	47	8	\N
1	52	47	8	\N
1	53	47	8	\N
1	54	47	8	\N
1	55	47	8	\N
1	56	47	3	2
1	57	47	8	\N
1	58	47	8	\N
1	59	47	7	\N
1	60	47	8	\N
1	1	48	9	\N
1	2	48	3	2
1	3	48	3	\N
1	4	48	3	3
1	5	48	3	3
1	6	48	3	\N
1	7	48	1	\N
1	8	48	1	\N
1	9	48	1	\N
1	10	48	1	9
1	11	48	1	9
1	12	48	1	1
1	13	48	1	9
1	14	48	1	\N
1	15	48	1	9
1	16	48	8	\N
1	17	48	8	\N
1	18	48	8	\N
1	19	48	8	\N
1	20	48	8	\N
1	21	48	8	\N
1	22	48	8	\N
1	23	48	8	\N
1	24	48	8	\N
1	25	48	8	\N
1	26	48	1	1
1	27	48	8	\N
1	28	48	8	\N
1	29	48	8	\N
1	30	48	8	\N
1	31	48	8	\N
1	32	48	8	\N
1	33	48	8	\N
1	34	48	1	\N
1	35	48	1	1
1	36	48	1	1
1	37	48	8	\N
1	38	48	8	\N
1	39	48	8	\N
1	40	48	8	\N
1	41	48	8	\N
1	42	48	8	\N
1	43	48	8	\N
1	44	48	8	\N
1	45	48	8	\N
1	46	48	8	\N
1	47	48	8	\N
1	48	48	8	\N
1	49	48	8	\N
1	50	48	8	\N
1	51	48	8	\N
1	52	48	8	\N
1	53	48	8	\N
1	54	48	5	8
1	55	48	3	3
1	56	48	8	\N
1	57	48	8	\N
1	58	48	8	\N
1	59	48	8	\N
1	60	48	8	\N
1	1	49	3	\N
1	2	49	3	\N
1	3	49	3	3
1	4	49	3	\N
1	5	49	5	6
1	6	49	3	3
1	7	49	1	\N
1	8	49	1	\N
1	9	49	1	\N
1	10	49	1	1
1	11	49	1	9
1	12	49	1	\N
1	13	49	1	9
1	14	49	1	1
1	15	49	1	1
1	16	49	8	\N
1	17	49	8	\N
1	18	49	8	\N
1	19	49	8	\N
1	20	49	8	\N
1	21	49	8	\N
1	22	49	8	\N
1	23	49	8	\N
1	24	49	8	\N
1	25	49	8	\N
1	26	49	1	\N
1	27	49	7	\N
1	28	49	8	\N
1	29	49	8	\N
1	30	49	8	\N
1	31	49	8	\N
1	32	49	8	\N
1	33	49	8	\N
1	34	49	8	\N
1	35	49	8	\N
1	36	49	1	1
1	37	49	8	\N
1	38	49	8	\N
1	39	49	8	\N
1	40	49	8	\N
1	41	49	8	\N
1	42	49	8	\N
1	43	49	8	\N
1	44	49	8	\N
1	45	49	8	\N
1	46	49	8	\N
1	47	49	8	\N
1	48	49	8	\N
1	49	49	8	\N
1	50	49	8	\N
1	51	49	8	\N
1	52	49	8	\N
1	53	49	8	\N
1	54	49	8	\N
1	55	49	8	\N
1	56	49	8	\N
1	57	49	8	\N
1	58	49	8	\N
1	59	49	2	\N
1	60	49	8	\N
1	1	50	7	\N
1	2	50	3	3
1	3	50	3	3
1	4	50	3	\N
1	5	50	4	7
1	6	50	7	\N
1	7	50	1	\N
1	8	50	5	\N
1	9	50	1	\N
1	10	50	7	\N
1	11	50	1	9
1	12	50	1	9
1	13	50	6	\N
1	14	50	1	1
1	15	50	1	9
1	16	50	1	9
1	17	50	8	\N
1	18	50	8	\N
1	19	50	8	\N
1	20	50	7	\N
1	21	50	8	\N
1	22	50	8	\N
1	23	50	8	\N
1	24	50	8	\N
1	25	50	8	\N
1	26	50	1	\N
1	27	50	1	\N
1	28	50	8	\N
1	29	50	3	2
1	30	50	8	\N
1	31	50	8	\N
1	32	50	8	\N
1	33	50	8	\N
1	34	50	8	\N
1	35	50	8	\N
1	36	50	8	\N
1	37	50	8	\N
1	38	50	8	\N
1	39	50	8	\N
1	40	50	8	\N
1	41	50	8	\N
1	42	50	8	\N
1	43	50	8	\N
1	44	50	8	\N
1	45	50	8	\N
1	46	50	8	\N
1	47	50	8	\N
1	48	50	8	\N
1	49	50	8	\N
1	50	50	8	\N
1	51	50	8	\N
1	52	50	8	\N
1	53	50	8	\N
1	54	50	8	\N
1	55	50	8	\N
1	56	50	8	\N
1	57	50	8	\N
1	58	50	8	\N
1	59	50	2	1
1	60	50	8	\N
1	1	51	3	3
1	2	51	3	\N
1	3	51	4	\N
1	4	51	5	\N
1	5	51	3	\N
1	6	51	1	1
1	7	51	1	\N
1	8	51	1	\N
1	9	51	9	\N
1	10	51	9	\N
1	11	51	1	\N
1	12	51	1	1
1	13	51	3	2
1	14	51	1	1
1	15	51	6	\N
1	16	51	5	\N
1	17	51	1	1
1	18	51	8	\N
1	19	51	8	\N
1	20	51	8	\N
1	21	51	8	\N
1	22	51	8	\N
1	23	51	8	\N
1	24	51	8	\N
1	25	51	8	\N
1	26	51	1	9
1	27	51	1	1
1	28	51	8	\N
1	29	51	8	\N
1	30	51	8	\N
1	31	51	8	\N
1	32	51	8	\N
1	33	51	8	\N
1	34	51	8	\N
1	35	51	8	\N
1	36	51	8	\N
1	37	51	8	\N
1	38	51	8	\N
1	39	51	8	\N
1	40	51	8	\N
1	41	51	8	\N
1	42	51	8	\N
1	43	51	8	\N
1	44	51	8	\N
1	45	51	8	\N
1	46	51	8	\N
1	47	51	6	\N
1	48	51	8	\N
1	49	51	8	\N
1	50	51	8	\N
1	51	51	8	\N
1	52	51	8	\N
1	53	51	8	\N
1	54	51	8	\N
1	55	51	8	\N
1	56	51	8	\N
1	57	51	8	\N
1	58	51	8	\N
1	59	51	8	\N
1	60	51	2	1
1	1	52	3	\N
1	2	52	3	2
1	3	52	3	\N
1	4	52	3	3
1	5	52	4	7
1	6	52	1	9
1	7	52	1	\N
1	8	52	1	\N
1	9	52	9	\N
1	10	52	1	9
1	11	52	1	9
1	12	52	1	\N
1	13	52	1	1
1	14	52	1	9
1	15	52	1	\N
1	16	52	1	\N
1	17	52	8	\N
1	18	52	8	\N
1	19	52	8	\N
1	20	52	8	\N
1	21	52	8	\N
1	22	52	8	\N
1	23	52	8	\N
1	24	52	8	\N
1	25	52	8	\N
1	26	52	8	\N
1	27	52	8	\N
1	28	52	8	\N
1	29	52	8	\N
1	30	52	8	\N
1	31	52	8	\N
1	32	52	1	\N
1	33	52	8	\N
1	34	52	8	\N
1	35	52	8	\N
1	36	52	8	\N
1	37	52	8	\N
1	38	52	8	\N
1	39	52	8	\N
1	40	52	8	\N
1	41	52	8	\N
1	42	52	8	\N
1	43	52	8	\N
1	44	52	8	\N
1	45	52	8	\N
1	46	52	8	\N
1	47	52	8	\N
1	48	52	8	\N
1	49	52	8	\N
1	50	52	8	\N
1	51	52	8	\N
1	52	52	8	\N
1	53	52	8	\N
1	54	52	8	\N
1	55	52	8	\N
1	56	52	8	\N
1	57	52	8	\N
1	58	52	8	\N
1	59	52	8	\N
1	60	52	8	\N
1	1	53	3	2
1	2	53	3	2
1	3	53	7	\N
1	4	53	7	\N
1	5	53	3	2
1	6	53	1	\N
1	7	53	6	\N
1	8	53	1	\N
1	9	53	1	\N
1	10	53	1	\N
1	11	53	9	\N
1	12	53	9	\N
1	13	53	1	9
1	14	53	1	9
1	15	53	1	\N
1	16	53	1	9
1	17	53	1	\N
1	18	53	8	\N
1	19	53	8	\N
1	20	53	8	\N
1	21	53	8	\N
1	22	53	8	\N
1	23	53	8	\N
1	24	53	8	\N
1	25	53	7	\N
1	26	53	8	\N
1	27	53	8	\N
1	28	53	8	\N
1	29	53	8	\N
1	30	53	2	\N
1	31	53	8	\N
1	32	53	8	\N
1	33	53	8	\N
1	34	53	8	\N
1	35	53	8	\N
1	36	53	8	\N
1	37	53	8	\N
1	38	53	8	\N
1	39	53	8	\N
1	40	53	8	\N
1	41	53	5	6
1	42	53	8	\N
1	43	53	6	\N
1	44	53	8	\N
1	45	53	8	\N
1	46	53	8	\N
1	47	53	8	\N
1	48	53	8	\N
1	49	53	8	\N
1	50	53	8	\N
1	51	53	8	\N
1	52	53	8	\N
1	53	53	8	\N
1	54	53	8	\N
1	55	53	8	\N
1	56	53	8	\N
1	57	53	8	\N
1	58	53	8	\N
1	59	53	8	\N
1	60	53	8	\N
1	1	54	3	\N
1	2	54	3	\N
1	3	54	3	2
1	4	54	9	\N
1	5	54	9	\N
1	6	54	1	9
1	7	54	2	1
1	8	54	3	2
1	9	54	1	1
1	10	54	2	\N
1	11	54	1	1
1	12	54	9	\N
1	13	54	9	\N
1	14	54	1	1
1	15	54	9	\N
1	16	54	1	1
1	17	54	1	1
1	18	54	1	1
1	19	54	8	\N
1	20	54	8	\N
1	21	54	8	\N
1	22	54	8	\N
1	23	54	8	\N
1	24	54	8	\N
1	25	54	8	\N
1	26	54	8	\N
1	27	54	8	\N
1	28	54	8	\N
1	29	54	8	\N
1	30	54	8	\N
1	31	54	8	\N
1	32	54	8	\N
1	33	54	8	\N
1	34	54	8	\N
1	35	54	8	\N
1	36	54	8	\N
1	37	54	8	\N
1	38	54	8	\N
1	39	54	8	\N
1	40	54	8	\N
1	41	54	8	\N
1	42	54	8	\N
1	43	54	8	\N
1	44	54	8	\N
1	45	54	8	\N
1	46	54	8	\N
1	47	54	2	1
1	48	54	8	\N
1	49	54	8	\N
1	50	54	8	\N
1	51	54	8	\N
1	52	54	8	\N
1	53	54	8	\N
1	54	54	8	\N
1	55	54	2	1
1	56	54	2	1
1	57	54	8	\N
1	58	54	8	\N
1	59	54	8	\N
1	60	54	8	\N
1	1	55	3	3
1	2	55	3	\N
1	3	55	3	2
1	4	55	9	\N
1	5	55	1	1
1	6	55	1	1
1	7	55	9	\N
1	8	55	9	\N
1	9	55	6	\N
1	10	55	1	9
1	11	55	1	9
1	12	55	9	\N
1	13	55	1	1
1	14	55	1	\N
1	15	55	9	\N
1	16	55	1	\N
1	17	55	1	\N
1	18	55	1	1
1	19	55	8	\N
1	20	55	8	\N
1	21	55	8	\N
1	22	55	8	\N
1	23	55	8	\N
1	24	55	8	\N
1	25	55	8	\N
1	26	55	8	\N
1	27	55	8	\N
1	28	55	8	\N
1	29	55	8	\N
1	30	55	8	\N
1	31	55	8	\N
1	32	55	8	\N
1	33	55	8	\N
1	34	55	8	\N
1	35	55	8	\N
1	36	55	8	\N
1	37	55	8	\N
1	38	55	8	\N
1	39	55	8	\N
1	40	55	8	\N
1	41	55	8	\N
1	42	55	8	\N
1	43	55	8	\N
1	44	55	8	\N
1	45	55	8	\N
1	46	55	8	\N
1	47	55	8	\N
1	48	55	8	\N
1	49	55	8	\N
1	50	55	8	\N
1	51	55	8	\N
1	52	55	8	\N
1	53	55	8	\N
1	54	55	8	\N
1	55	55	8	\N
1	56	55	8	\N
1	57	55	8	\N
1	58	55	3	2
1	59	55	8	\N
1	60	55	8	\N
1	1	56	3	2
1	2	56	3	2
1	3	56	3	\N
1	4	56	9	\N
1	5	56	9	\N
1	6	56	9	\N
1	7	56	4	7
1	8	56	4	7
1	9	56	1	1
1	10	56	1	\N
1	11	56	1	1
1	12	56	9	\N
1	13	56	9	\N
1	14	56	1	1
1	15	56	1	9
1	16	56	1	1
1	17	56	1	9
1	18	56	1	1
1	19	56	8	\N
1	20	56	8	\N
1	21	56	8	\N
1	22	56	8	\N
1	23	56	8	\N
1	24	56	8	\N
1	25	56	8	\N
1	26	56	8	\N
1	27	56	8	\N
1	28	56	8	\N
1	29	56	8	\N
1	30	56	8	\N
1	31	56	8	\N
1	32	56	8	\N
1	33	56	8	\N
1	34	56	8	\N
1	35	56	8	\N
1	36	56	8	\N
1	37	56	8	\N
1	38	56	8	\N
1	39	56	8	\N
1	40	56	8	\N
1	41	56	8	\N
1	42	56	8	\N
1	43	56	8	\N
1	44	56	8	\N
1	45	56	8	\N
1	46	56	8	\N
1	47	56	8	\N
1	48	56	8	\N
1	49	56	8	\N
1	50	56	8	\N
1	51	56	8	\N
1	52	56	8	\N
1	53	56	8	\N
1	54	56	8	\N
1	55	56	8	\N
1	56	56	8	\N
1	57	56	8	\N
1	58	56	8	\N
1	59	56	8	\N
1	60	56	8	\N
1	1	57	5	\N
1	2	57	3	3
1	3	57	3	2
1	4	57	3	3
1	5	57	3	\N
1	6	57	9	\N
1	7	57	9	\N
1	8	57	4	7
1	9	57	4	7
1	10	57	1	\N
1	11	57	1	1
1	12	57	9	\N
1	13	57	1	9
1	14	57	1	\N
1	15	57	1	1
1	16	57	1	1
1	17	57	1	1
1	18	57	8	\N
1	19	57	8	\N
1	20	57	8	\N
1	21	57	8	\N
1	22	57	8	\N
1	23	57	8	\N
1	24	57	8	\N
1	25	57	8	\N
1	26	57	8	\N
1	27	57	8	\N
1	28	57	8	\N
1	29	57	8	\N
1	30	57	8	\N
1	31	57	8	\N
1	32	57	8	\N
1	33	57	8	\N
1	34	57	8	\N
1	35	57	8	\N
1	36	57	7	\N
1	37	57	8	\N
1	38	57	8	\N
1	39	57	8	\N
1	40	57	8	\N
1	41	57	8	\N
1	42	57	8	\N
1	43	57	8	\N
1	44	57	8	\N
1	45	57	8	\N
1	46	57	8	\N
1	47	57	8	\N
1	48	57	8	\N
1	49	57	8	\N
1	50	57	8	\N
1	51	57	8	\N
1	52	57	8	\N
1	53	57	8	\N
1	54	57	8	\N
1	55	57	8	\N
1	56	57	8	\N
1	57	57	8	\N
1	58	57	8	\N
1	59	57	8	\N
1	60	57	2	1
1	1	58	5	\N
1	2	58	3	2
1	3	58	3	3
1	4	58	3	3
1	5	58	7	\N
1	6	58	9	\N
1	7	58	4	7
1	8	58	1	\N
1	9	58	1	\N
1	10	58	7	\N
1	11	58	1	9
1	12	58	1	1
1	13	58	1	9
1	14	58	1	\N
1	15	58	9	\N
1	16	58	1	9
1	17	58	8	\N
1	18	58	8	\N
1	19	58	8	\N
1	20	58	1	\N
1	21	58	8	\N
1	22	58	8	\N
1	23	58	8	\N
1	24	58	8	\N
1	25	58	8	\N
1	26	58	6	\N
1	27	58	8	\N
1	28	58	8	\N
1	29	58	8	\N
1	30	58	8	\N
1	31	58	8	\N
1	32	58	8	\N
1	33	58	8	\N
1	34	58	8	\N
1	35	58	8	\N
1	36	58	8	\N
1	37	58	8	\N
1	38	58	8	\N
1	39	58	8	\N
1	40	58	8	\N
1	41	58	8	\N
1	42	58	8	\N
1	43	58	8	\N
1	44	58	8	\N
1	45	58	8	\N
1	46	58	8	\N
1	47	58	8	\N
1	48	58	8	\N
1	49	58	3	3
1	50	58	8	\N
1	51	58	8	\N
1	52	58	8	\N
1	53	58	8	\N
1	54	58	3	2
1	55	58	8	\N
1	56	58	8	\N
1	57	58	8	\N
1	58	58	1	9
1	59	58	8	\N
1	60	58	2	1
1	1	59	3	\N
1	2	59	3	3
1	3	59	3	\N
1	4	59	3	2
1	5	59	3	\N
1	6	59	9	\N
1	7	59	9	\N
1	8	59	9	\N
1	9	59	7	\N
1	10	59	1	\N
1	11	59	9	\N
1	12	59	9	\N
1	13	59	1	\N
1	14	59	1	\N
1	15	59	9	\N
1	16	59	8	\N
1	17	59	8	\N
1	18	59	8	\N
1	19	59	8	\N
1	20	59	1	9
1	21	59	8	\N
1	22	59	8	\N
1	23	59	8	\N
1	24	59	8	\N
1	25	59	8	\N
1	26	59	8	\N
1	27	59	8	\N
1	28	59	8	\N
1	29	59	8	\N
1	30	59	8	\N
1	31	59	8	\N
1	32	59	8	\N
1	33	59	8	\N
1	34	59	8	\N
1	35	59	8	\N
1	36	59	8	\N
1	37	59	8	\N
1	38	59	8	\N
1	39	59	8	\N
1	40	59	8	\N
1	41	59	8	\N
1	42	59	8	\N
1	43	59	8	\N
1	44	59	8	\N
1	45	59	8	\N
1	46	59	8	\N
1	47	59	8	\N
1	48	59	8	\N
1	49	59	8	\N
1	50	59	8	\N
1	51	59	8	\N
1	52	59	8	\N
1	53	59	8	\N
1	54	59	8	\N
1	55	59	8	\N
1	56	59	8	\N
1	57	59	8	\N
1	58	59	8	\N
1	59	59	8	\N
1	60	59	2	1
1	1	60	3	3
1	2	60	3	3
1	3	60	3	3
1	4	60	3	2
1	5	60	6	\N
1	6	60	3	3
1	7	60	9	\N
1	8	60	7	\N
1	9	60	7	\N
1	10	60	7	\N
1	11	60	2	\N
1	12	60	9	\N
1	13	60	1	\N
1	14	60	1	\N
1	15	60	8	\N
1	16	60	8	\N
1	17	60	8	\N
1	18	60	8	\N
1	19	60	8	\N
1	20	60	8	\N
1	21	60	8	\N
1	22	60	8	\N
1	23	60	8	\N
1	24	60	8	\N
1	25	60	8	\N
1	26	60	8	\N
1	27	60	8	\N
1	28	60	8	\N
1	29	60	6	\N
1	30	60	8	\N
1	31	60	8	\N
1	32	60	8	\N
1	33	60	8	\N
1	34	60	8	\N
1	35	60	8	\N
1	36	60	8	\N
1	37	60	8	\N
1	38	60	8	\N
1	39	60	8	\N
1	40	60	8	\N
1	41	60	8	\N
1	42	60	8	\N
1	43	60	8	\N
1	44	60	8	\N
1	45	60	8	\N
1	46	60	8	\N
1	47	60	8	\N
1	48	60	2	1
1	49	60	8	\N
1	50	60	8	\N
1	51	60	8	\N
1	52	60	8	\N
1	53	60	8	\N
1	54	60	8	\N
1	55	60	8	\N
1	56	60	8	\N
1	57	60	8	\N
1	58	60	8	\N
1	59	60	8	\N
1	60	60	2	1
\.


--
-- TOC entry 5646 (class 0 OID 22808)
-- Dependencies: 298
-- Data for Name: map_tiles_map_regions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_map_regions (region_id, map_id, map_tile_x, map_tile_y) FROM stdin;
1	1	1	1
1	1	2	1
1	1	1	2
1	1	3	1
1	1	2	2
1	1	1	3
1	1	2	3
1	1	1	4
2	1	4	1
2	1	4	2
2	1	5	2
2	1	3	2
2	1	4	3
2	1	3	3
2	1	6	2
2	1	5	3
3	1	6	1
3	1	7	1
3	1	8	1
3	1	7	2
3	1	8	2
3	1	7	3
3	1	8	3
3	1	6	3
3	1	7	4
4	1	9	1
4	1	10	1
4	1	9	2
4	1	10	2
4	1	9	3
4	1	11	2
4	1	10	3
4	1	12	2
5	1	11	1
5	1	12	1
5	1	13	1
5	1	14	1
5	1	13	2
5	1	14	2
5	1	13	3
5	1	14	3
6	1	15	1
6	1	16	1
6	1	15	2
6	1	16	2
6	1	15	3
6	1	16	3
6	1	15	4
6	1	16	4
7	1	18	1
7	1	19	1
7	1	18	2
7	1	20	1
7	1	21	1
7	1	22	1
7	1	21	2
7	1	22	2
7	1	23	2
7	1	22	3
8	1	23	1
8	1	24	1
8	1	25	1
8	1	24	2
8	1	24	3
8	1	23	3
8	1	24	4
8	1	23	4
8	1	22	4
9	1	26	1
9	1	27	1
9	1	28	1
9	1	29	1
9	1	30	1
9	1	31	1
9	1	30	2
9	1	31	2
9	1	32	2
10	1	32	1
10	1	33	1
10	1	34	1
10	1	33	2
10	1	35	1
10	1	34	2
10	1	36	1
10	1	35	2
10	1	37	1
10	1	36	2
11	1	38	1
11	1	39	1
11	1	38	2
11	1	39	2
11	1	37	2
11	1	40	1
11	1	40	2
11	1	39	3
12	1	41	1
12	1	42	1
12	1	41	2
12	1	42	2
12	1	43	1
12	1	44	1
12	1	43	2
12	1	44	2
13	1	45	1
13	1	46	1
13	1	45	2
13	1	47	1
13	1	46	2
13	1	47	2
13	1	46	3
13	1	47	3
13	1	45	3
14	1	48	1
14	1	49	1
14	1	48	2
14	1	49	2
14	1	48	3
14	1	48	4
14	1	50	1
14	1	51	1
14	1	50	2
15	1	52	1
15	1	53	1
15	1	52	2
15	1	53	2
15	1	51	2
15	1	52	3
15	1	54	1
15	1	53	3
15	1	51	3
16	1	55	1
16	1	56	1
16	1	55	2
16	1	56	2
16	1	54	2
16	1	55	3
16	1	54	3
16	1	57	2
16	1	56	3
16	1	54	4
17	1	57	1
18	1	60	1
18	1	60	2
18	1	59	2
18	1	60	3
18	1	59	3
18	1	59	4
18	1	60	4
18	1	60	5
19	1	11	3
19	1	12	3
19	1	11	4
19	1	12	4
19	1	10	4
19	1	11	5
19	1	13	4
19	1	12	5
19	1	10	5
20	1	19	3
20	1	19	4
21	1	26	3
21	1	27	3
21	1	28	3
22	1	32	3
22	1	33	3
22	1	34	3
22	1	35	3
22	1	34	4
22	1	36	3
22	1	35	4
22	1	34	5
22	1	35	5
23	1	40	3
23	1	40	4
23	1	39	4
23	1	40	5
23	1	39	5
23	1	40	6
23	1	41	6
23	1	39	6
23	1	40	7
23	1	38	6
24	1	43	3
24	1	44	3
25	1	50	3
25	1	50	4
25	1	51	4
25	1	52	4
25	1	51	5
25	1	53	4
25	1	52	5
25	1	53	5
25	1	51	6
26	1	57	3
26	1	57	4
26	1	56	4
26	1	55	4
26	1	55	5
26	1	54	5
27	1	2	4
27	1	3	4
27	1	2	5
27	1	3	5
27	1	1	5
27	1	2	6
27	1	3	6
27	1	1	6
27	1	2	7
27	1	1	7
28	1	4	4
28	1	5	4
28	1	4	5
28	1	6	4
28	1	5	5
28	1	4	6
28	1	5	6
28	1	4	7
28	1	6	5
29	1	8	4
29	1	9	4
29	1	8	5
29	1	9	5
29	1	7	5
29	1	8	6
29	1	9	6
29	1	7	6
29	1	8	7
30	1	14	4
30	1	14	5
30	1	15	5
30	1	13	5
30	1	14	6
30	1	15	6
30	1	13	6
30	1	14	7
31	1	17	4
31	1	17	5
31	1	16	5
31	1	17	6
31	1	16	6
31	1	17	7
31	1	16	7
31	1	18	7
31	1	17	8
31	1	18	8
32	1	21	4
32	1	21	5
32	1	22	5
32	1	20	5
32	1	21	6
32	1	20	6
32	1	22	6
32	1	21	7
32	1	23	6
32	1	22	7
33	1	29	4
33	1	30	4
33	1	29	5
33	1	30	5
33	1	28	5
33	1	29	6
33	1	27	5
33	1	28	6
34	1	36	4
34	1	36	5
34	1	36	6
34	1	35	6
34	1	36	7
34	1	34	6
34	1	35	7
34	1	37	7
35	1	38	4
36	1	45	4
36	1	46	4
36	1	45	5
36	1	47	4
36	1	46	5
36	1	44	5
36	1	47	5
36	1	48	5
36	1	47	6
36	1	48	6
37	1	23	5
37	1	24	5
37	1	25	5
38	1	32	5
38	1	33	5
38	1	32	6
38	1	33	6
38	1	33	7
38	1	34	7
38	1	33	8
38	1	34	8
38	1	32	8
39	1	42	5
39	1	42	6
39	1	42	7
39	1	43	7
39	1	41	7
39	1	42	8
39	1	44	7
39	1	43	8
40	1	58	5
40	1	59	5
40	1	58	6
40	1	59	6
40	1	57	6
40	1	58	7
40	1	59	7
40	1	57	7
41	1	6	6
42	1	10	6
42	1	11	6
42	1	10	7
42	1	12	6
42	1	11	7
42	1	12	7
42	1	13	7
42	1	12	8
43	1	19	6
43	1	19	7
43	1	20	7
43	1	19	8
43	1	20	8
43	1	19	9
43	1	21	8
43	1	20	9
44	1	26	6
44	1	27	6
44	1	26	7
44	1	27	7
44	1	25	7
44	1	26	8
44	1	28	7
44	1	27	8
45	1	30	6
45	1	30	7
45	1	29	7
45	1	30	8
45	1	29	8
45	1	30	9
45	1	28	8
45	1	29	9
45	1	28	9
46	1	50	6
47	1	52	6
47	1	52	7
47	1	53	7
47	1	51	7
47	1	52	8
47	1	51	8
47	1	53	8
47	1	52	9
47	1	50	8
48	1	56	6
48	1	56	7
48	1	55	7
48	1	56	8
48	1	55	8
48	1	57	8
48	1	56	9
48	1	58	8
48	1	57	9
48	1	58	9
49	1	60	6
50	1	3	7
50	1	3	8
50	1	4	8
50	1	2	8
50	1	3	9
50	1	4	9
50	1	2	9
50	1	3	10
50	1	1	8
50	1	4	10
51	1	9	7
51	1	9	8
51	1	10	8
51	1	8	8
51	1	9	9
51	1	7	8
51	1	8	9
51	1	11	8
52	1	15	7
52	1	15	8
52	1	16	8
52	1	14	8
52	1	16	9
52	1	17	9
52	1	16	10
52	1	18	9
52	1	15	10
53	1	23	7
53	1	24	7
53	1	23	8
53	1	24	8
53	1	25	8
53	1	24	9
53	1	25	9
53	1	23	9
53	1	24	10
54	1	38	7
54	1	39	7
54	1	38	8
54	1	39	8
54	1	40	8
54	1	39	9
54	1	37	8
54	1	38	9
54	1	36	8
55	1	45	7
55	1	45	8
55	1	44	8
55	1	45	9
55	1	44	9
55	1	46	9
55	1	45	10
55	1	47	9
55	1	46	10
55	1	47	10
56	1	48	7
56	1	48	8
56	1	49	8
56	1	47	8
56	1	48	9
56	1	49	9
56	1	48	10
56	1	50	9
56	1	49	10
57	1	5	8
57	1	6	8
57	1	5	9
57	1	6	9
57	1	7	9
57	1	6	10
57	1	5	10
57	1	7	10
58	1	13	8
58	1	13	9
58	1	12	9
58	1	13	10
58	1	12	10
58	1	13	11
58	1	11	10
58	1	12	11
58	1	11	11
58	1	12	12
59	1	22	8
59	1	22	9
59	1	21	9
59	1	21	10
59	1	20	10
59	1	21	11
59	1	20	11
59	1	21	12
59	1	22	12
59	1	20	12
60	1	35	8
60	1	35	9
60	1	36	9
60	1	34	9
60	1	35	10
60	1	33	9
60	1	34	10
60	1	33	10
60	1	34	11
61	1	41	8
61	1	41	9
61	1	42	9
61	1	40	9
61	1	41	10
61	1	40	10
61	1	42	10
61	1	41	11
61	1	43	9
61	1	43	10
62	1	54	8
62	1	54	9
62	1	55	9
62	1	53	9
62	1	54	10
62	1	53	10
62	1	55	10
62	1	52	10
62	1	53	11
62	1	56	10
63	1	59	8
63	1	60	8
63	1	59	9
63	1	60	9
63	1	59	10
63	1	60	10
63	1	58	10
63	1	59	11
64	1	1	9
64	1	1	10
64	1	2	10
64	1	1	11
64	1	2	11
64	1	1	12
64	1	3	11
64	1	2	12
65	1	10	9
65	1	11	9
65	1	10	10
65	1	9	10
65	1	10	11
65	1	8	10
65	1	9	11
65	1	8	11
66	1	26	9
66	1	27	9
66	1	26	10
66	1	27	10
66	1	25	10
66	1	28	10
66	1	29	10
66	1	28	11
66	1	30	10
66	1	29	11
67	1	31	9
67	1	32	9
67	1	31	10
67	1	32	10
67	1	31	11
67	1	32	11
67	1	30	11
67	1	31	12
68	1	37	9
68	1	37	10
68	1	38	10
68	1	36	10
68	1	37	11
68	1	39	10
68	1	38	11
68	1	36	11
69	1	51	9
69	1	51	10
69	1	50	10
69	1	51	11
69	1	50	11
69	1	52	11
69	1	51	12
69	1	49	11
70	1	19	10
70	1	19	11
70	1	18	11
70	1	19	12
70	1	18	12
70	1	19	13
70	1	17	12
70	1	18	13
70	1	20	13
70	1	19	14
71	1	23	10
72	1	44	10
72	1	44	11
72	1	45	11
72	1	43	11
72	1	44	12
72	1	46	11
72	1	45	12
72	1	47	11
72	1	46	12
72	1	43	12
73	1	57	10
73	1	57	11
73	1	58	11
73	1	56	11
73	1	55	11
73	1	56	12
73	1	54	11
73	1	55	12
73	1	56	13
73	1	57	13
74	1	4	11
74	1	5	11
74	1	4	12
74	1	5	12
74	1	3	12
74	1	4	13
74	1	6	11
74	1	3	13
74	1	7	11
74	1	6	12
75	1	16	11
75	1	16	12
75	1	15	12
75	1	16	13
75	1	17	13
75	1	16	14
75	1	17	14
75	1	16	15
75	1	18	14
76	1	33	11
76	1	33	12
76	1	32	12
76	1	33	13
76	1	32	13
76	1	33	14
76	1	31	13
76	1	32	14
76	1	33	15
76	1	31	14
77	1	35	11
77	1	35	12
77	1	36	12
77	1	35	13
77	1	36	13
77	1	35	14
77	1	37	13
77	1	36	14
77	1	35	15
77	1	38	13
78	1	39	11
78	1	40	11
78	1	39	12
78	1	40	12
78	1	38	12
78	1	39	13
78	1	37	12
78	1	40	13
78	1	39	14
79	1	42	11
79	1	42	12
79	1	41	12
79	1	42	13
79	1	41	13
79	1	41	14
79	1	42	14
79	1	40	14
80	1	48	11
80	1	48	12
80	1	49	12
80	1	47	12
80	1	48	13
80	1	47	13
80	1	50	12
80	1	49	13
80	1	48	14
80	1	50	13
81	1	60	11
81	1	60	12
81	1	59	12
81	1	60	13
81	1	59	13
81	1	60	14
81	1	58	13
81	1	59	14
81	1	58	14
82	1	7	12
82	1	8	12
82	1	7	13
82	1	8	13
82	1	6	13
82	1	7	14
82	1	8	14
82	1	6	14
82	1	7	15
82	1	8	15
83	1	13	12
83	1	13	13
83	1	12	13
83	1	13	14
83	1	14	14
83	1	12	14
83	1	11	14
83	1	12	15
84	1	24	12
84	1	25	12
84	1	26	12
84	1	25	13
84	1	26	13
84	1	25	14
84	1	26	14
84	1	24	14
84	1	27	12
85	1	28	12
85	1	29	12
85	1	28	13
85	1	29	13
85	1	27	13
85	1	28	14
85	1	27	14
85	1	30	13
85	1	29	14
86	1	30	12
87	1	52	12
87	1	53	12
87	1	52	13
87	1	54	12
87	1	53	13
87	1	54	13
87	1	53	14
87	1	54	14
87	1	52	14
87	1	53	15
88	1	1	13
88	1	2	13
88	1	1	14
88	1	2	14
88	1	3	14
88	1	2	15
88	1	3	15
88	1	1	15
88	1	2	16
89	1	5	13
89	1	5	14
89	1	4	14
89	1	5	15
89	1	6	15
89	1	4	15
89	1	5	16
89	1	6	16
89	1	4	16
90	1	10	13
90	1	11	13
91	1	21	13
91	1	22	13
91	1	21	14
91	1	22	14
91	1	20	14
91	1	21	15
91	1	20	15
91	1	22	15
91	1	21	16
91	1	22	16
92	1	43	13
92	1	44	13
92	1	43	14
92	1	44	14
92	1	43	15
92	1	45	13
92	1	44	15
92	1	42	15
92	1	43	16
93	1	46	13
93	1	46	14
93	1	47	14
93	1	45	14
93	1	46	15
93	1	47	15
93	1	45	15
93	1	45	16
94	1	51	13
94	1	51	14
94	1	50	14
94	1	49	14
95	1	55	13
95	1	55	14
95	1	56	14
95	1	55	15
95	1	56	15
95	1	54	15
95	1	55	16
95	1	56	16
96	1	23	14
97	1	30	14
97	1	30	15
97	1	31	15
97	1	29	15
97	1	30	16
97	1	32	15
97	1	28	15
97	1	29	16
98	1	57	14
98	1	57	15
98	1	58	15
98	1	57	16
98	1	59	15
98	1	58	16
98	1	60	15
98	1	59	16
99	1	10	15
99	1	11	15
99	1	10	16
99	1	11	16
99	1	9	16
99	1	10	17
99	1	11	17
99	1	9	17
99	1	10	18
99	1	11	18
100	1	14	15
100	1	15	15
100	1	14	16
100	1	15	16
100	1	16	16
100	1	15	17
100	1	16	17
100	1	14	17
101	1	17	15
101	1	18	15
101	1	17	16
101	1	18	16
101	1	17	17
101	1	18	17
101	1	17	18
101	1	19	16
102	1	19	15
103	1	26	15
103	1	27	15
103	1	26	16
103	1	27	16
103	1	25	16
103	1	26	17
103	1	27	17
103	1	25	17
104	1	34	15
104	1	34	16
104	1	35	16
104	1	33	16
104	1	34	17
104	1	33	17
104	1	32	17
104	1	33	18
104	1	36	16
105	1	36	15
105	1	37	15
105	1	38	15
105	1	37	16
105	1	39	15
105	1	38	16
105	1	37	17
105	1	39	16
105	1	38	17
105	1	39	17
106	1	40	15
106	1	41	15
106	1	40	16
106	1	41	16
106	1	40	17
106	1	42	16
106	1	41	17
106	1	42	17
106	1	41	18
107	1	1	16
107	1	1	17
107	1	2	17
107	1	1	18
107	1	1	19
107	1	1	20
107	1	1	21
107	1	3	17
107	1	1	22
107	1	1	23
108	1	3	16
109	1	7	16
109	1	8	16
109	1	7	17
109	1	8	17
109	1	6	17
109	1	7	18
109	1	5	17
109	1	6	18
109	1	4	17
109	1	5	18
110	1	12	16
110	1	12	17
110	1	13	17
110	1	12	18
110	1	13	18
110	1	12	19
110	1	14	18
110	1	13	19
110	1	11	19
111	1	20	16
111	1	20	17
111	1	21	17
111	1	19	17
111	1	20	18
111	1	19	18
111	1	18	18
111	1	19	19
111	1	18	19
111	1	20	19
112	1	24	16
112	1	24	17
112	1	23	17
112	1	24	18
112	1	25	18
112	1	23	18
112	1	24	19
112	1	25	19
112	1	23	19
113	1	28	16
113	1	28	17
113	1	29	17
113	1	28	18
113	1	29	18
113	1	27	18
113	1	26	18
113	1	30	17
114	1	44	16
114	1	44	17
114	1	45	17
114	1	43	17
114	1	44	18
114	1	45	18
114	1	43	18
114	1	44	19
114	1	46	18
114	1	45	19
115	1	48	16
115	1	49	16
115	1	48	17
115	1	49	17
115	1	47	17
115	1	48	18
115	1	50	17
115	1	46	17
115	1	51	17
116	1	51	16
116	1	52	16
116	1	53	16
116	1	52	17
116	1	54	16
116	1	53	17
116	1	54	17
116	1	53	18
117	1	60	16
117	1	60	17
117	1	59	17
117	1	60	18
117	1	58	17
117	1	59	18
117	1	58	18
117	1	57	17
117	1	57	18
118	1	22	17
118	1	22	18
118	1	21	18
118	1	22	19
118	1	21	19
118	1	21	20
118	1	20	20
118	1	21	21
119	1	31	17
119	1	31	18
119	1	32	18
119	1	30	18
120	1	35	17
120	1	36	17
120	1	35	18
120	1	36	18
120	1	34	18
120	1	35	19
120	1	36	19
120	1	34	19
120	1	35	20
120	1	37	19
121	1	55	17
121	1	56	17
121	1	55	18
121	1	56	18
121	1	56	19
121	1	57	19
121	1	55	19
121	1	56	20
121	1	58	19
121	1	57	20
122	1	3	18
122	1	4	18
122	1	3	19
122	1	4	19
122	1	5	19
122	1	4	20
122	1	5	20
122	1	3	20
122	1	6	20
123	1	8	18
123	1	9	18
123	1	8	19
123	1	9	19
123	1	7	19
123	1	8	20
123	1	9	20
123	1	7	20
124	1	15	18
124	1	16	18
124	1	15	19
124	1	16	19
124	1	17	19
124	1	16	20
124	1	17	20
124	1	15	20
125	1	37	18
125	1	38	18
125	1	39	18
125	1	38	19
125	1	39	19
125	1	38	20
125	1	40	18
125	1	40	19
126	1	42	18
126	1	42	19
126	1	43	19
126	1	41	19
126	1	42	20
126	1	43	20
126	1	41	20
126	1	44	20
127	1	52	18
128	1	54	18
129	1	6	19
130	1	10	19
130	1	10	20
130	1	11	20
130	1	10	21
130	1	11	21
130	1	9	21
130	1	10	22
130	1	12	21
131	1	14	19
131	1	14	20
131	1	13	20
131	1	14	21
131	1	15	21
131	1	13	21
131	1	14	22
131	1	16	21
131	1	15	22
131	1	17	21
132	1	26	19
132	1	26	20
132	1	27	20
132	1	25	20
132	1	28	20
132	1	27	21
132	1	29	20
132	1	28	21
133	1	33	19
133	1	33	20
133	1	34	20
133	1	33	21
133	1	34	21
133	1	35	21
133	1	34	22
133	1	35	22
134	1	46	19
134	1	46	20
134	1	45	20
134	1	46	21
134	1	47	21
134	1	45	21
134	1	46	22
134	1	47	22
134	1	46	23
135	1	49	19
135	1	50	19
135	1	49	20
135	1	50	20
135	1	50	21
135	1	48	20
135	1	49	21
135	1	50	22
135	1	48	21
135	1	51	22
136	1	60	19
136	1	60	20
136	1	59	20
136	1	60	21
136	1	59	21
136	1	58	21
136	1	57	21
136	1	56	21
137	1	12	20
138	1	18	20
138	1	19	20
138	1	18	21
138	1	19	21
138	1	20	21
138	1	19	22
138	1	20	22
138	1	19	23
138	1	20	23
139	1	36	20
139	1	37	20
139	1	36	21
139	1	37	21
139	1	36	22
139	1	37	22
139	1	36	23
139	1	38	22
140	1	39	20
140	1	40	20
141	1	52	20
141	1	53	20
142	1	5	21
142	1	6	21
142	1	5	22
142	1	7	21
142	1	6	22
142	1	4	22
142	1	5	23
142	1	3	22
143	1	8	21
143	1	8	22
143	1	9	22
143	1	8	23
143	1	9	23
143	1	8	24
143	1	9	24
143	1	7	24
143	1	8	25
144	1	23	21
145	1	29	21
145	1	29	22
145	1	30	22
145	1	28	22
145	1	29	23
145	1	31	22
145	1	30	23
145	1	31	23
145	1	28	23
145	1	29	24
146	1	31	21
146	1	32	21
146	1	32	22
146	1	33	22
146	1	32	23
146	1	33	23
146	1	34	23
146	1	33	24
146	1	34	24
146	1	35	24
147	1	41	21
147	1	41	22
147	1	42	22
147	1	43	22
147	1	42	23
147	1	44	22
147	1	43	23
147	1	42	24
148	1	44	21
149	1	54	21
149	1	54	22
149	1	53	22
149	1	54	23
149	1	52	22
149	1	53	23
149	1	52	23
149	1	51	23
150	1	11	22
150	1	12	22
150	1	11	23
150	1	13	22
150	1	12	23
150	1	13	23
150	1	12	24
150	1	10	23
151	1	16	22
151	1	17	22
151	1	16	23
151	1	17	23
151	1	18	23
151	1	17	24
151	1	15	23
151	1	16	24
151	1	15	24
151	1	16	25
152	1	21	22
152	1	21	23
152	1	22	23
152	1	21	24
152	1	23	23
152	1	22	24
152	1	23	24
152	1	22	25
152	1	20	24
153	1	24	22
153	1	25	22
153	1	24	23
153	1	25	23
153	1	24	24
153	1	26	22
153	1	26	23
153	1	25	24
153	1	27	22
153	1	27	23
154	1	39	22
154	1	39	23
154	1	38	23
154	1	37	23
155	1	48	22
155	1	49	22
155	1	48	23
155	1	49	23
155	1	47	23
155	1	48	24
155	1	50	23
155	1	49	24
155	1	47	24
156	1	57	22
156	1	57	23
156	1	56	23
156	1	57	24
156	1	55	23
156	1	56	24
156	1	55	24
156	1	56	25
156	1	57	25
157	1	3	23
157	1	4	23
157	1	3	24
157	1	4	24
157	1	2	24
157	1	3	25
157	1	1	24
157	1	2	25
158	1	6	23
158	1	6	24
158	1	5	24
158	1	6	25
158	1	5	25
158	1	4	25
158	1	5	26
158	1	7	25
159	1	14	23
159	1	14	24
159	1	13	24
159	1	14	25
159	1	13	25
159	1	15	25
159	1	14	26
159	1	15	26
159	1	13	26
159	1	14	27
160	1	35	23
161	1	44	23
161	1	45	23
161	1	44	24
161	1	45	24
161	1	43	24
161	1	44	25
161	1	45	25
161	1	43	25
161	1	44	26
161	1	46	24
162	1	59	23
162	1	60	23
162	1	59	24
162	1	60	24
162	1	59	25
162	1	58	25
162	1	59	26
162	1	60	26
162	1	58	26
163	1	10	24
163	1	11	24
163	1	10	25
163	1	11	25
163	1	12	25
163	1	11	26
163	1	9	25
163	1	10	26
164	1	18	24
164	1	19	24
164	1	18	25
164	1	19	25
164	1	17	25
164	1	18	26
164	1	17	26
164	1	19	26
164	1	18	27
165	1	36	24
165	1	36	25
165	1	36	26
165	1	37	26
165	1	35	26
165	1	34	26
165	1	35	27
165	1	38	26
165	1	37	27
165	1	33	26
166	1	40	24
166	1	41	24
166	1	40	25
166	1	41	25
166	1	42	25
166	1	41	26
166	1	40	26
166	1	41	27
166	1	39	25
167	1	50	24
168	1	54	24
169	1	1	25
170	1	20	25
170	1	21	25
170	1	20	26
170	1	21	26
170	1	20	27
170	1	22	26
170	1	21	27
170	1	22	27
171	1	23	25
171	1	24	25
171	1	23	26
171	1	25	25
171	1	24	26
171	1	25	26
171	1	24	27
171	1	26	26
171	1	25	27
172	1	27	25
172	1	28	25
172	1	27	26
172	1	28	26
172	1	27	27
172	1	28	27
172	1	26	27
172	1	27	28
172	1	26	28
173	1	29	25
173	1	30	25
173	1	29	26
173	1	31	25
173	1	30	26
173	1	29	27
173	1	31	26
173	1	31	27
173	1	30	27
173	1	29	28
174	1	38	25
175	1	46	25
175	1	47	25
175	1	46	26
175	1	48	25
175	1	47	26
175	1	48	26
175	1	47	27
175	1	49	25
175	1	49	26
175	1	45	26
176	1	55	25
177	1	3	26
177	1	4	26
177	1	3	27
177	1	4	27
177	1	2	27
177	1	3	28
177	1	4	28
177	1	2	28
177	1	3	29
177	1	5	27
178	1	6	26
178	1	7	26
178	1	6	27
178	1	7	27
178	1	6	28
178	1	8	26
178	1	9	26
178	1	8	27
178	1	7	28
178	1	5	28
179	1	12	26
179	1	12	27
179	1	13	27
179	1	11	27
179	1	12	28
179	1	10	27
179	1	11	28
179	1	9	27
179	1	10	28
179	1	9	28
180	1	16	26
180	1	16	27
180	1	17	27
180	1	15	27
180	1	16	28
180	1	15	28
180	1	17	28
180	1	18	28
180	1	19	28
181	1	39	26
181	1	39	27
181	1	40	27
181	1	38	27
181	1	39	28
181	1	40	28
181	1	38	28
181	1	39	29
182	1	43	26
182	1	43	27
182	1	44	27
182	1	42	27
182	1	43	28
182	1	44	28
182	1	42	28
182	1	43	29
182	1	45	28
183	1	50	26
183	1	50	27
183	1	51	27
183	1	49	27
183	1	50	28
183	1	48	27
183	1	49	28
183	1	48	28
184	1	56	26
184	1	57	26
184	1	56	27
184	1	57	27
184	1	55	27
184	1	56	28
184	1	57	28
184	1	58	28
184	1	58	27
184	1	59	28
185	1	19	27
186	1	23	27
186	1	23	28
186	1	24	28
186	1	22	28
186	1	23	29
186	1	21	28
186	1	22	29
186	1	24	29
186	1	23	30
186	1	21	29
187	1	33	27
187	1	34	27
187	1	33	28
187	1	34	28
187	1	32	28
187	1	33	29
187	1	34	29
187	1	32	29
188	1	45	27
188	1	46	27
188	1	46	28
188	1	47	28
188	1	46	29
188	1	47	29
188	1	45	29
188	1	46	30
188	1	47	30
189	1	59	27
189	1	60	27
189	1	60	28
190	1	8	28
190	1	8	29
190	1	9	29
190	1	7	29
190	1	8	30
190	1	10	29
190	1	9	30
190	1	11	29
191	1	13	28
191	1	13	29
191	1	12	29
192	1	20	28
192	1	20	29
193	1	25	28
194	1	28	28
194	1	28	29
194	1	29	29
194	1	27	29
194	1	26	29
194	1	30	29
194	1	31	29
194	1	30	30
194	1	30	28
194	1	31	30
195	1	31	28
196	1	35	28
196	1	36	28
196	1	35	29
196	1	36	29
196	1	37	28
196	1	37	29
196	1	36	30
196	1	37	30
197	1	41	28
197	1	41	29
197	1	42	29
197	1	40	29
197	1	41	30
197	1	42	30
197	1	40	30
197	1	43	30
197	1	44	30
198	1	1	29
198	1	2	29
198	1	1	30
198	1	2	30
198	1	1	31
198	1	3	30
198	1	2	31
198	1	1	32
198	1	3	31
198	1	2	32
199	1	4	29
199	1	5	29
199	1	6	29
199	1	5	30
199	1	6	30
199	1	5	31
199	1	7	30
199	1	6	31
200	1	38	29
200	1	38	30
200	1	39	30
200	1	38	31
200	1	39	31
200	1	40	31
200	1	37	31
200	1	36	31
200	1	35	31
201	1	44	29
202	1	48	29
202	1	49	29
202	1	48	30
202	1	49	30
202	1	48	31
202	1	49	31
202	1	47	31
202	1	48	32
202	1	50	31
203	1	50	29
203	1	50	30
204	1	10	30
204	1	10	31
204	1	11	31
204	1	9	31
204	1	10	32
204	1	11	32
204	1	9	32
204	1	10	33
204	1	8	32
204	1	9	33
205	1	14	30
205	1	14	31
205	1	15	31
205	1	13	31
205	1	14	32
205	1	16	31
205	1	15	32
205	1	16	32
205	1	16	30
205	1	13	32
206	1	18	30
207	1	21	30
207	1	22	30
207	1	21	31
207	1	22	31
207	1	20	31
207	1	21	32
207	1	23	31
207	1	22	32
208	1	24	30
208	1	24	31
208	1	25	31
208	1	25	32
208	1	26	32
208	1	27	32
208	1	26	33
208	1	27	33
209	1	32	30
209	1	33	30
209	1	32	31
209	1	33	31
209	1	31	31
209	1	32	32
209	1	33	32
209	1	31	32
209	1	32	33
210	1	45	30
211	1	4	31
211	1	4	32
211	1	5	32
211	1	3	32
211	1	4	33
211	1	5	33
211	1	4	34
211	1	6	32
212	1	7	31
212	1	8	31
212	1	7	32
212	1	7	33
212	1	8	33
212	1	6	33
212	1	7	34
212	1	8	34
212	1	6	34
213	1	19	31
213	1	19	32
213	1	20	32
213	1	18	32
213	1	19	33
213	1	18	33
213	1	20	33
213	1	19	34
213	1	17	33
214	1	27	31
215	1	29	31
215	1	30	31
215	1	29	32
215	1	30	32
215	1	28	32
215	1	29	33
215	1	28	33
215	1	28	34
216	1	44	31
216	1	44	32
216	1	43	32
216	1	44	33
216	1	45	33
216	1	43	33
216	1	43	34
216	1	42	34
217	1	51	31
217	1	51	32
217	1	50	32
217	1	51	33
217	1	52	33
217	1	50	33
217	1	51	34
217	1	52	34
218	1	12	32
218	1	12	33
218	1	13	33
218	1	11	33
218	1	11	34
218	1	14	33
218	1	15	33
218	1	14	34
218	1	16	33
218	1	15	34
219	1	23	32
219	1	23	33
219	1	22	33
219	1	21	33
219	1	22	34
219	1	21	34
219	1	20	34
219	1	21	35
219	1	20	35
220	1	41	32
220	1	41	33
220	1	40	33
220	1	39	33
220	1	38	33
220	1	39	34
220	1	38	34
220	1	39	35
220	1	38	35
221	1	46	32
221	1	47	32
221	1	46	33
222	1	49	32
222	1	49	33
222	1	48	33
222	1	49	34
222	1	50	34
222	1	48	34
222	1	49	35
222	1	50	35
223	1	1	33
223	1	2	33
223	1	1	34
223	1	2	34
223	1	1	35
223	1	3	34
223	1	2	35
223	1	3	35
223	1	2	36
224	1	30	33
224	1	31	33
224	1	30	34
224	1	31	34
224	1	32	34
224	1	31	35
224	1	29	34
224	1	30	35
224	1	33	34
224	1	33	33
225	1	35	33
225	1	36	33
225	1	36	34
226	1	5	34
226	1	5	35
226	1	6	35
226	1	5	36
226	1	6	36
226	1	4	36
226	1	5	37
226	1	7	36
226	1	6	37
226	1	4	37
227	1	9	34
227	1	10	34
227	1	9	35
227	1	8	35
227	1	9	36
227	1	8	36
227	1	9	37
227	1	8	37
228	1	16	34
228	1	17	34
228	1	16	35
228	1	17	35
228	1	15	35
228	1	16	36
228	1	14	35
228	1	15	36
228	1	13	35
228	1	14	36
229	1	18	34
229	1	18	35
229	1	19	35
229	1	18	36
229	1	19	36
229	1	20	36
229	1	19	37
229	1	20	37
229	1	18	37
229	1	17	36
230	1	26	34
230	1	27	34
230	1	27	35
230	1	28	35
230	1	27	36
230	1	28	36
230	1	29	36
230	1	28	37
230	1	30	36
231	1	47	34
231	1	47	35
231	1	48	35
231	1	47	36
231	1	48	36
231	1	49	36
231	1	48	37
231	1	49	37
231	1	50	37
231	1	49	38
232	1	53	34
232	1	53	35
232	1	52	35
232	1	53	36
232	1	51	35
232	1	52	36
232	1	51	36
232	1	52	37
232	1	50	36
232	1	51	37
233	1	55	34
234	1	7	35
235	1	11	35
236	1	22	35
236	1	22	36
236	1	23	36
236	1	21	36
236	1	22	37
236	1	21	37
236	1	23	37
236	1	21	38
236	1	22	38
236	1	20	38
237	1	29	35
238	1	34	35
238	1	34	36
238	1	35	36
238	1	33	36
238	1	34	37
238	1	33	37
238	1	35	37
238	1	34	38
239	1	37	35
239	1	37	36
240	1	41	35
240	1	42	35
240	1	41	36
240	1	42	36
240	1	41	37
240	1	43	35
240	1	43	36
240	1	42	37
241	1	1	36
241	1	1	37
241	1	2	37
241	1	1	38
241	1	3	37
241	1	2	38
241	1	3	38
241	1	3	36
241	1	2	39
242	1	12	36
242	1	13	36
242	1	12	37
242	1	11	37
242	1	12	38
242	1	13	38
242	1	12	39
242	1	13	39
242	1	11	39
242	1	12	40
243	1	31	36
243	1	31	37
243	1	32	37
243	1	30	37
243	1	31	38
243	1	32	38
243	1	29	37
243	1	30	38
244	1	39	36
244	1	39	37
244	1	38	37
244	1	39	38
244	1	38	38
244	1	39	39
244	1	37	38
244	1	38	39
244	1	36	38
245	1	58	36
246	1	7	37
246	1	7	38
246	1	8	38
246	1	7	39
246	1	8	39
246	1	6	39
246	1	7	40
246	1	5	39
246	1	9	38
247	1	14	37
247	1	15	37
247	1	14	38
247	1	16	37
247	1	15	38
247	1	17	37
247	1	16	38
247	1	17	38
247	1	15	39
248	1	25	37
248	1	26	37
248	1	25	38
248	1	26	38
248	1	24	38
248	1	27	38
248	1	26	39
248	1	27	39
248	1	26	40
248	1	28	38
249	1	46	37
250	1	53	37
250	1	54	37
250	1	53	38
250	1	52	38
250	1	53	39
250	1	52	39
250	1	51	38
250	1	50	38
250	1	51	39
250	1	50	39
251	1	4	38
251	1	4	39
251	1	3	39
251	1	4	40
251	1	3	40
251	1	5	40
251	1	4	41
251	1	2	40
251	1	3	41
252	1	29	38
252	1	29	39
252	1	30	39
252	1	28	39
252	1	31	39
252	1	30	40
252	1	31	40
252	1	30	41
252	1	32	40
253	1	33	38
253	1	33	39
253	1	34	39
253	1	32	39
253	1	33	40
253	1	35	39
253	1	34	40
253	1	33	41
254	1	35	38
255	1	56	38
256	1	1	39
256	1	1	40
256	1	1	41
256	1	2	41
256	1	1	42
256	1	2	42
256	1	1	43
256	1	2	43
256	1	3	42
256	1	3	43
257	1	9	39
257	1	9	40
257	1	10	40
257	1	8	40
257	1	9	41
257	1	10	41
257	1	8	41
257	1	9	42
257	1	11	40
257	1	11	41
258	1	14	39
258	1	14	40
258	1	15	40
258	1	13	40
258	1	14	41
258	1	15	41
258	1	13	41
258	1	14	42
258	1	12	41
259	1	16	39
259	1	17	39
259	1	16	40
259	1	17	40
259	1	16	41
259	1	17	41
259	1	18	40
259	1	17	42
260	1	36	39
260	1	37	39
260	1	36	40
260	1	37	40
260	1	35	40
260	1	36	41
260	1	38	40
260	1	37	41
260	1	38	41
261	1	44	39
262	1	49	39
262	1	49	40
262	1	50	40
262	1	51	40
263	1	20	40
263	1	20	41
263	1	19	41
264	1	27	40
264	1	27	41
264	1	28	41
264	1	26	41
264	1	27	42
264	1	28	42
264	1	29	42
264	1	28	43
265	1	39	40
266	1	5	41
266	1	6	41
266	1	5	42
266	1	7	41
266	1	6	42
266	1	7	42
266	1	6	43
266	1	5	43
267	1	29	41
268	1	31	41
268	1	32	41
268	1	31	42
268	1	32	42
268	1	30	42
268	1	31	43
268	1	33	42
268	1	32	43
268	1	30	43
268	1	29	43
269	1	34	41
269	1	35	41
269	1	34	42
269	1	35	42
269	1	34	43
269	1	36	42
269	1	35	43
269	1	33	43
269	1	34	44
269	1	37	42
270	1	53	41
271	1	4	42
271	1	4	43
271	1	4	44
271	1	5	44
271	1	3	44
271	1	4	45
271	1	2	44
271	1	3	45
271	1	5	45
272	1	8	42
273	1	10	42
273	1	11	42
273	1	10	43
273	1	12	42
273	1	11	43
273	1	9	43
273	1	10	44
273	1	12	43
274	1	13	42
274	1	13	43
274	1	14	43
274	1	13	44
274	1	14	44
274	1	12	44
274	1	13	45
274	1	11	44
275	1	38	42
276	1	40	42
277	1	45	42
278	1	15	43
278	1	15	44
279	1	20	43
280	1	36	43
280	1	37	43
280	1	36	44
280	1	37	44
280	1	35	44
280	1	36	45
280	1	38	44
280	1	37	45
280	1	35	45
280	1	36	46
281	1	6	44
281	1	6	45
281	1	7	45
281	1	6	46
281	1	8	45
281	1	7	46
281	1	9	45
281	1	8	46
281	1	8	44
282	1	9	44
283	1	32	44
283	1	33	44
283	1	33	45
283	1	34	45
283	1	34	46
283	1	35	46
283	1	34	47
283	1	35	47
283	1	34	48
284	1	2	45
285	1	10	45
285	1	11	45
285	1	10	46
285	1	12	45
285	1	11	46
285	1	12	46
285	1	11	47
285	1	12	47
285	1	10	47
286	1	14	45
286	1	14	46
286	1	15	46
286	1	13	46
286	1	14	47
286	1	15	47
286	1	16	47
286	1	15	48
286	1	13	47
287	1	29	45
288	1	3	46
288	1	4	46
288	1	3	47
288	1	4	47
288	1	2	47
288	1	3	48
288	1	2	48
288	1	4	48
289	1	5	46
289	1	5	47
289	1	6	47
289	1	5	48
289	1	7	47
289	1	6	48
289	1	7	48
289	1	6	49
290	1	9	46
290	1	9	47
290	1	8	47
290	1	9	48
290	1	8	48
290	1	10	48
290	1	9	49
290	1	11	48
290	1	10	49
291	1	37	46
291	1	38	46
292	1	46	46
293	1	26	47
293	1	26	48
293	1	26	49
293	1	27	49
293	1	26	50
293	1	27	50
293	1	26	51
293	1	27	51
294	1	56	47
295	1	59	47
296	1	12	48
296	1	13	48
296	1	12	49
296	1	13	49
296	1	11	49
296	1	12	50
296	1	13	50
296	1	11	50
296	1	12	51
297	1	14	48
297	1	14	49
297	1	15	49
297	1	14	50
297	1	15	50
297	1	14	51
297	1	15	51
297	1	13	51
297	1	14	52
298	1	35	48
298	1	36	48
298	1	36	49
299	1	54	48
299	1	55	48
300	1	1	49
300	1	2	49
300	1	1	50
300	1	3	49
300	1	2	50
300	1	3	50
300	1	2	51
300	1	3	51
301	1	4	49
301	1	5	49
301	1	4	50
301	1	5	50
301	1	4	51
301	1	5	51
301	1	4	52
301	1	5	52
301	1	3	52
302	1	7	49
302	1	8	49
302	1	7	50
302	1	8	50
302	1	6	50
302	1	7	51
302	1	6	51
302	1	6	52
302	1	7	52
302	1	6	53
303	1	59	49
303	1	59	50
304	1	9	50
304	1	10	50
305	1	16	50
305	1	16	51
305	1	17	51
305	1	16	52
305	1	15	52
305	1	16	53
305	1	15	53
305	1	17	53
305	1	16	54
306	1	20	50
307	1	29	50
308	1	1	51
308	1	1	52
308	1	2	52
308	1	1	53
308	1	2	53
308	1	1	54
308	1	2	54
308	1	1	55
308	1	3	53
309	1	8	51
309	1	8	52
309	1	8	53
309	1	9	53
309	1	7	53
309	1	8	54
309	1	7	54
309	1	6	54
309	1	9	54
309	1	6	55
310	1	11	51
310	1	11	52
310	1	12	52
310	1	10	52
310	1	10	53
310	1	13	52
310	1	10	54
310	1	11	54
311	1	47	51
312	1	60	51
313	1	32	52
314	1	4	53
314	1	5	53
315	1	13	53
315	1	14	53
315	1	14	54
315	1	14	55
315	1	13	55
315	1	14	56
315	1	15	56
315	1	14	57
316	1	25	53
317	1	30	53
318	1	41	53
319	1	43	53
320	1	3	54
320	1	3	55
320	1	2	55
320	1	3	56
320	1	2	56
320	1	3	57
320	1	1	56
320	1	2	57
321	1	17	54
321	1	18	54
321	1	17	55
321	1	18	55
321	1	16	55
321	1	17	56
321	1	18	56
321	1	16	56
322	1	47	54
323	1	55	54
323	1	56	54
324	1	5	55
325	1	9	55
325	1	10	55
325	1	9	56
325	1	10	56
325	1	8	56
325	1	9	57
325	1	11	55
325	1	7	56
326	1	58	55
327	1	11	56
327	1	11	57
327	1	10	57
327	1	11	58
327	1	10	58
327	1	12	58
327	1	9	58
327	1	10	59
327	1	13	58
328	1	1	57
328	1	1	58
328	1	2	58
328	1	1	59
328	1	3	58
328	1	2	59
328	1	3	59
328	1	2	60
328	1	4	58
328	1	3	60
329	1	4	57
329	1	5	57
329	1	5	58
329	1	5	59
329	1	4	59
329	1	5	60
329	1	4	60
329	1	6	60
330	1	8	57
330	1	8	58
330	1	7	58
331	1	13	57
332	1	15	57
332	1	16	57
332	1	17	57
332	1	16	58
333	1	36	57
334	1	60	57
334	1	60	58
334	1	60	59
334	1	60	60
335	1	14	58
335	1	14	59
335	1	13	59
335	1	14	60
335	1	13	60
336	1	20	58
336	1	20	59
337	1	26	58
338	1	49	58
339	1	54	58
340	1	58	58
341	1	9	59
341	1	9	60
341	1	10	60
341	1	8	60
341	1	11	60
342	1	1	60
343	1	29	60
344	1	48	60
\.


--
-- TOC entry 5647 (class 0 OID 22815)
-- Dependencies: 299
-- Data for Name: map_tiles_players_positions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_players_positions (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
2	1	4	5
5	1	6	6
1	1	4	5
4	1	4	5
3	1	4	5
\.


--
-- TOC entry 5665 (class 0 OID 25631)
-- Dependencies: 319
-- Data for Name: map_tiles_resources; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_resources (id, map_id, map_tile_x, map_tile_y, item_id, quantity) FROM stdin;
1	1	29	25	4	50215
2	1	29	25	5	35383
3	1	29	25	6	86731
4	1	20	10	4	72066
5	1	20	10	5	66531
6	1	20	10	6	23384
7	1	49	33	4	50031
8	1	49	33	5	8412
9	1	49	33	6	92491
10	1	48	33	4	50335
11	1	48	33	5	53113
12	1	48	33	6	91826
13	1	16	16	4	19073
14	1	16	16	5	66248
15	1	16	16	6	44191
16	1	60	18	4	32064
17	1	60	18	5	17046
18	1	60	18	6	79880
19	1	59	18	4	8232
20	1	59	18	5	31927
21	1	59	18	6	52347
22	1	6	4	4	24196
23	1	6	4	5	38045
24	1	6	4	6	22737
25	1	36	48	4	18901
26	1	36	48	5	59718
27	1	36	48	6	5813
28	1	15	16	4	1387
29	1	15	16	5	21583
30	1	15	16	6	25324
31	1	14	16	4	11075
32	1	14	16	5	50502
33	1	14	16	6	86862
34	1	26	33	4	5367
35	1	26	33	5	21914
36	1	26	33	6	90536
37	1	38	25	4	55420
38	1	38	25	5	23474
39	1	38	25	6	25773
40	1	46	10	4	50015
41	1	46	10	5	23439
42	1	46	10	6	49484
43	1	47	10	4	15106
44	1	47	10	5	58310
45	1	47	10	6	53395
46	1	48	10	4	73535
47	1	48	10	5	14933
48	1	48	10	6	82963
49	1	35	23	4	9659
50	1	35	23	5	31213
51	1	35	23	6	71798
52	1	52	10	4	5747
53	1	52	10	5	39639
54	1	52	10	6	59299
55	1	11	4	4	48488
56	1	11	4	5	28793
57	1	11	4	6	63761
58	1	55	10	4	72869
59	1	55	10	5	20098
60	1	55	10	6	31756
61	1	50	32	4	82285
62	1	50	32	5	18829
63	1	50	32	6	10205
64	1	58	10	4	38168
65	1	58	10	5	53571
66	1	58	10	6	19149
67	1	49	32	4	35225
68	1	49	32	5	28131
69	1	49	32	6	28686
70	1	41	32	4	15928
71	1	41	32	5	32842
72	1	41	32	6	52603
73	1	35	48	4	80987
74	1	35	48	5	62067
75	1	35	48	6	5512
76	1	38	20	4	50887
77	1	38	20	5	29303
78	1	38	20	6	36611
79	1	29	32	4	72075
80	1	29	32	5	24033
81	1	29	32	6	51865
82	1	28	32	4	52480
83	1	28	32	5	3679
84	1	28	32	6	73393
85	1	10	11	4	4076
86	1	10	11	5	55935
87	1	10	11	6	34521
88	1	56	25	4	58512
89	1	56	25	5	45782
90	1	56	25	6	2767
91	1	60	15	4	32580
92	1	60	15	5	59056
93	1	60	15	6	24795
94	1	11	20	4	63908
95	1	11	20	5	17851
96	1	11	20	6	60587
97	1	50	31	4	41617
98	1	50	31	5	44487
99	1	50	31	6	97346
100	1	26	48	4	50256
101	1	26	48	5	1080
102	1	26	48	6	99647
103	1	40	31	4	46732
104	1	40	31	5	16411
105	1	40	31	6	34436
106	1	39	31	4	9396
107	1	39	31	5	7560
108	1	39	31	6	79087
109	1	38	31	4	83214
110	1	38	31	5	15597
111	1	38	31	6	55866
112	1	17	57	4	10231
113	1	17	57	5	57847
114	1	17	57	6	11901
115	1	57	25	4	71696
116	1	57	25	5	24350
117	1	57	25	6	13667
118	1	58	25	4	72431
119	1	58	25	5	45691
120	1	58	25	6	85215
121	1	16	57	4	25226
122	1	16	57	5	27477
123	1	16	57	6	87172
124	1	15	57	4	42251
125	1	15	57	5	8821
126	1	15	57	6	32895
127	1	49	30	4	9175
128	1	49	30	5	31712
129	1	49	30	6	25881
130	1	48	30	4	1737
131	1	48	30	5	57692
132	1	48	30	6	30038
133	1	12	48	4	88314
134	1	12	48	5	51426
135	1	12	48	6	65576
136	1	46	11	4	58193
137	1	46	11	5	51226
138	1	46	11	6	37151
139	1	48	11	4	71325
140	1	48	11	5	25245
141	1	48	11	6	9592
142	1	49	11	4	73181
143	1	49	11	5	31803
144	1	49	11	6	24298
145	1	52	11	4	1018
146	1	52	11	5	53428
147	1	52	11	6	21402
148	1	58	11	4	32419
149	1	58	11	5	40973
150	1	58	11	6	51899
151	1	60	11	4	90485
152	1	60	11	5	14259
153	1	60	11	6	76627
154	1	44	21	4	85783
155	1	44	21	5	13953
156	1	44	21	6	95869
157	1	40	30	4	46637
158	1	40	30	5	1672
159	1	40	30	6	71812
160	1	15	20	4	78021
161	1	15	20	5	16567
162	1	15	20	6	83434
163	1	26	26	4	6968
164	1	26	26	5	48484
165	1	26	26	6	9803
166	1	47	15	4	64480
167	1	47	15	5	34851
168	1	47	15	6	50758
169	1	30	30	4	65532
170	1	30	30	5	50748
171	1	30	30	6	99908
172	1	35	26	4	35994
173	1	35	26	5	4038
174	1	35	26	6	18693
175	1	10	2	4	57693
176	1	10	2	5	60871
177	1	10	2	6	61886
178	1	13	12	4	3880
179	1	13	12	5	69329
180	1	13	12	6	14560
181	1	36	15	4	45302
182	1	36	15	5	17159
183	1	36	15	6	48896
184	1	18	12	4	81066
185	1	18	12	5	11500
186	1	18	12	6	23224
187	1	48	29	4	60625
188	1	48	29	5	34049
189	1	48	29	6	62873
190	1	20	12	4	11384
191	1	20	12	5	45963
192	1	20	12	6	78114
193	1	13	47	4	72863
194	1	13	47	5	30213
195	1	13	47	6	61147
196	1	14	56	4	98207
197	1	14	56	5	23641
198	1	14	56	6	85319
199	1	42	29	4	29895
200	1	42	29	5	22195
201	1	42	29	6	20307
202	1	39	29	4	42141
203	1	39	29	5	69135
204	1	39	29	6	16578
205	1	13	2	4	96609
206	1	13	2	5	54718
207	1	13	2	6	62021
208	1	46	26	4	29837
209	1	46	26	5	47220
210	1	46	26	6	84597
211	1	12	15	4	52470
212	1	12	15	5	4880
213	1	12	15	6	40228
214	1	9	47	4	48507
215	1	9	47	5	63011
216	1	9	47	6	67890
217	1	50	26	4	86760
218	1	50	26	5	66143
219	1	50	26	6	99853
220	1	45	12	4	92719
221	1	45	12	5	28362
222	1	45	12	6	86773
223	1	56	26	4	56744
224	1	56	26	5	54971
225	1	56	26	6	46785
226	1	52	12	4	15382
227	1	52	12	5	66124
228	1	52	12	6	93089
229	1	26	29	4	10686
230	1	26	29	5	1395
231	1	26	29	6	28794
232	1	15	2	4	84475
233	1	15	2	5	21003
234	1	15	2	6	10966
235	1	59	12	4	61895
236	1	59	12	5	63447
237	1	59	12	6	29526
238	1	60	12	4	13344
239	1	60	12	5	26695
240	1	60	12	6	70025
241	1	13	46	4	73796
242	1	13	46	5	9403
243	1	13	46	6	99246
244	1	50	28	4	33603
245	1	50	28	5	17847
246	1	50	28	6	79252
247	1	11	46	4	21758
248	1	11	46	5	67048
249	1	11	46	6	7012
250	1	45	28	4	92386
251	1	45	28	5	9104
252	1	45	28	6	12976
253	1	43	28	4	36772
254	1	43	28	5	49196
255	1	43	28	6	37484
256	1	39	28	4	77492
257	1	39	28	5	25658
258	1	39	28	6	76296
259	1	50	4	4	79678
260	1	50	4	5	19292
261	1	50	4	6	7424
262	1	7	27	4	39082
263	1	7	27	5	52580
264	1	7	27	6	87716
265	1	60	14	4	4212
266	1	60	14	5	44048
267	1	60	14	6	68547
268	1	59	14	4	41841
269	1	59	14	5	12789
270	1	59	14	6	64498
271	1	15	27	4	3330
272	1	15	27	5	69946
273	1	15	27	6	98049
274	1	16	27	4	3635
275	1	16	27	5	33180
276	1	16	27	6	79784
277	1	11	57	4	29171
278	1	11	57	5	56876
279	1	11	57	6	12991
280	1	55	14	4	66070
281	1	55	14	5	68745
282	1	55	14	6	93730
283	1	19	28	4	39404
284	1	19	28	5	16032
285	1	19	28	6	51841
286	1	17	28	4	9372
287	1	17	28	5	32195
288	1	17	28	6	99838
289	1	36	13	4	77787
290	1	36	13	5	6553
291	1	36	13	6	14566
292	1	16	28	4	45609
293	1	16	28	5	47827
294	1	16	28	6	26143
295	1	54	14	4	37033
296	1	54	14	5	25982
297	1	54	14	6	71549
298	1	48	14	4	34503
299	1	48	14	5	45773
300	1	48	14	6	36548
301	1	47	13	4	29759
302	1	47	13	5	10891
303	1	47	13	6	78087
304	1	45	14	4	69388
305	1	45	14	5	56557
306	1	45	14	6	62953
307	1	18	56	4	40422
308	1	18	56	5	41818
309	1	18	56	6	40254
310	1	13	55	4	39094
311	1	13	55	5	66396
312	1	13	55	6	37492
313	1	18	27	4	33975
314	1	18	27	5	22855
315	1	18	27	6	77000
316	1	8	28	4	91883
317	1	8	28	5	56100
318	1	8	28	6	95641
319	1	60	27	4	86736
320	1	60	27	5	30902
321	1	60	27	6	50239
322	1	37	45	4	90658
323	1	37	45	5	28163
324	1	37	45	6	88963
325	1	50	27	4	74358
326	1	50	27	5	23733
327	1	50	27	6	53098
328	1	46	27	4	15017
329	1	46	27	5	11421
330	1	46	27	6	85491
331	1	3	5	4	41895
332	1	3	5	5	23719
333	1	3	5	6	64724
334	1	12	14	4	99749
335	1	12	14	5	1955
336	1	12	14	6	79283
337	1	13	14	4	38277
338	1	13	14	5	68539
339	1	13	14	6	48951
340	1	14	14	4	8910
341	1	14	14	5	7334
342	1	14	14	6	29787
343	1	40	27	4	33150
344	1	40	27	5	1945
345	1	40	27	6	99767
346	1	39	27	4	5952
347	1	39	27	5	53446
348	1	39	27	6	46412
349	1	37	27	4	35345
350	1	37	27	5	60654
351	1	37	27	6	78343
352	1	16	56	4	3783
353	1	16	56	5	55172
354	1	16	56	6	24088
355	1	28	27	4	26403
356	1	28	27	5	49134
357	1	28	27	6	59595
358	1	35	14	4	39440
359	1	35	14	5	30230
360	1	35	14	6	20551
361	1	44	23	4	99764
362	1	44	23	5	12073
363	1	44	23	6	28136
364	1	6	55	4	64221
365	1	6	55	5	50003
366	1	6	55	6	51128
367	1	5	55	4	3192
368	1	5	55	5	50887
369	1	5	55	6	16454
370	1	33	45	4	98867
371	1	33	45	5	22991
372	1	33	45	6	72458
373	1	4	2	4	34931
374	1	4	2	5	11703
375	1	4	2	6	30464
376	1	23	5	4	60476
377	1	23	5	5	30458
378	1	23	5	6	49014
379	1	9	45	4	50358
380	1	9	45	5	58934
381	1	9	45	6	87277
382	1	54	17	4	92682
383	1	54	17	5	47594
384	1	54	17	6	7239
385	1	33	44	4	99973
386	1	33	44	5	7275
387	1	33	44	6	66045
388	1	12	44	4	93245
389	1	12	44	5	13218
390	1	12	44	6	99971
391	1	40	18	4	50950
392	1	40	18	5	54750
393	1	40	18	6	33272
394	1	18	54	4	23190
395	1	18	54	5	34632
396	1	18	54	6	71535
397	1	17	54	4	73260
398	1	17	54	5	50457
399	1	17	54	6	77809
400	1	16	54	4	65976
401	1	16	54	5	49219
402	1	16	54	6	42401
403	1	14	54	4	35381
404	1	14	54	5	28927
405	1	14	54	6	21586
406	1	11	54	4	57701
407	1	11	54	5	48650
408	1	11	54	6	4407
409	1	9	54	4	21804
410	1	9	54	5	56299
411	1	9	54	6	53032
412	1	51	5	4	98912
413	1	51	5	5	24257
414	1	51	5	6	34596
415	1	49	17	4	45866
416	1	49	17	5	46731
417	1	49	17	6	84291
418	1	48	23	4	29258
419	1	48	23	5	67016
420	1	48	23	6	56301
421	1	40	42	4	8290
422	1	40	42	5	23357
423	1	40	42	6	54890
424	1	58	5	4	97667
425	1	58	5	5	57574
426	1	58	5	6	21918
427	1	38	42	4	28330
428	1	38	42	5	34353
429	1	38	42	6	97438
430	1	3	6	4	52278
431	1	3	6	5	61815
432	1	3	6	6	60223
433	1	34	21	4	64694
434	1	34	21	5	69297
435	1	34	21	6	81134
436	1	6	6	4	55905
437	1	6	6	5	34128
438	1	6	6	6	61218
439	1	11	56	4	69428
440	1	11	56	5	20831
441	1	11	56	6	92518
442	1	40	17	4	99034
443	1	40	17	5	51642
444	1	40	17	6	78298
445	1	10	6	4	69497
446	1	10	6	5	65985
447	1	10	6	6	3440
448	1	12	6	4	91208
449	1	12	6	5	9976
450	1	12	6	6	6871
451	1	13	6	4	96243
452	1	13	6	5	55904
453	1	13	6	6	72752
454	1	10	1	4	51767
455	1	10	1	5	10004
456	1	10	1	6	73205
457	1	35	18	4	50002
458	1	35	18	5	52413
459	1	35	18	6	21641
460	1	28	42	4	38341
461	1	28	42	5	41074
462	1	28	42	6	69504
463	1	13	42	4	80652
464	1	13	42	5	61438
465	1	13	42	6	87302
466	1	23	6	4	76521
467	1	23	6	5	14505
468	1	23	6	6	21991
469	1	11	42	4	7217
470	1	11	42	5	1502
471	1	11	42	6	45950
472	1	38	17	4	82475
473	1	38	17	5	57881
474	1	38	17	6	66728
475	1	55	18	4	35796
476	1	55	18	5	45151
477	1	55	18	6	51122
478	1	38	41	4	73874
479	1	38	41	5	59764
480	1	38	41	6	8597
481	1	37	41	4	54632
482	1	37	41	5	61746
483	1	37	41	6	18426
484	1	32	41	4	16336
485	1	32	41	5	49714
486	1	32	41	6	76463
487	1	30	41	4	54056
488	1	30	41	5	21670
489	1	30	41	6	2557
490	1	50	23	4	68543
491	1	50	23	5	45296
492	1	50	23	6	71618
493	1	13	41	4	71270
494	1	13	41	5	49176
495	1	13	41	6	11092
496	1	42	6	4	99953
497	1	42	6	5	64779
498	1	42	6	6	27379
499	1	12	41	4	37015
500	1	12	41	5	27867
501	1	12	41	6	47082
502	1	11	41	4	48186
503	1	11	41	5	7331
504	1	11	41	6	47136
505	1	51	23	4	60188
506	1	51	23	5	36538
507	1	51	23	6	81572
508	1	37	19	4	39027
509	1	37	19	5	7115
510	1	37	19	6	5034
511	1	50	6	4	86350
512	1	50	6	5	49107
513	1	50	6	6	41532
514	1	50	2	4	86871
515	1	50	2	5	61505
516	1	50	2	6	23981
517	1	54	23	4	31345
518	1	54	23	5	19674
519	1	54	23	6	83210
520	1	55	23	4	82144
521	1	55	23	5	14948
522	1	55	23	6	21316
523	1	13	1	4	43037
524	1	13	1	5	52495
525	1	13	1	6	25554
526	1	31	40	4	4703
527	1	31	40	5	66242
528	1	31	40	6	43650
529	1	14	1	4	75480
530	1	14	1	5	3993
531	1	14	1	6	2879
532	1	57	23	4	87887
533	1	57	23	5	66389
534	1	57	23	6	56253
535	1	10	24	4	6852
536	1	10	24	5	32265
537	1	10	24	6	94609
538	1	11	7	4	90749
539	1	11	7	5	38497
540	1	11	7	6	63354
541	1	18	55	4	67713
542	1	18	55	5	51599
543	1	18	55	6	27866
544	1	16	7	4	87219
545	1	16	7	5	69846
546	1	16	7	6	9874
547	1	14	17	4	75513
548	1	14	17	5	45118
549	1	14	17	6	72012
550	1	12	17	4	99597
551	1	12	17	5	16857
552	1	12	17	6	30616
553	1	12	40	4	30331
554	1	12	40	5	1426
555	1	12	40	6	90153
556	1	9	40	4	33246
557	1	9	40	5	40770
558	1	9	40	6	76942
559	1	13	52	4	38694
560	1	13	52	5	51764
561	1	13	52	6	27583
562	1	11	17	4	28459
563	1	11	17	5	11315
564	1	11	17	6	38975
565	1	16	24	4	51802
566	1	16	24	5	4547
567	1	16	24	6	15195
568	1	43	22	4	44251
569	1	43	22	5	25968
570	1	43	22	6	59437
574	1	9	56	4	53496
575	1	9	56	5	64635
576	1	9	56	6	38979
577	1	46	22	4	3871
578	1	46	22	5	45026
579	1	46	22	6	64692
580	1	29	39	4	75574
581	1	29	39	5	21852
582	1	29	39	6	31695
583	1	27	39	4	30143
584	1	27	39	5	5098
585	1	27	39	6	50300
586	1	43	7	4	17591
587	1	43	7	5	22049
588	1	43	7	6	9157
589	1	35	24	4	89980
590	1	35	24	5	19213
591	1	35	24	6	72078
592	1	36	24	4	27722
593	1	36	24	5	41026
594	1	36	24	6	87420
595	1	6	39	4	52212
596	1	6	39	5	50046
597	1	6	39	6	84558
598	1	18	21	4	61018
599	1	18	21	5	12074
600	1	18	21	6	95978
601	1	41	24	4	37236
602	1	41	24	5	48353
603	1	41	24	6	77151
604	1	57	7	4	91414
605	1	57	7	5	52095
606	1	57	7	6	18183
607	1	14	3	4	5335
608	1	14	3	5	15686
609	1	14	3	6	20034
610	1	50	38	4	5601
611	1	50	38	5	16459
612	1	50	38	6	25476
613	1	49	38	4	8563
614	1	49	38	5	37626
615	1	49	38	6	65234
616	1	36	38	4	73980
617	1	36	38	5	3068
618	1	36	38	6	10643
619	1	35	38	4	59911
620	1	35	38	5	59810
621	1	35	38	6	64247
622	1	34	38	4	21584
623	1	34	38	5	40777
624	1	34	38	6	33796
625	1	12	58	4	10027
626	1	12	58	5	4925
627	1	12	58	6	20258
628	1	11	8	4	89578
572	1	6	3	5	38952
629	1	11	8	5	56592
630	1	11	8	6	84237
631	1	27	51	4	23198
632	1	27	51	5	43828
633	1	27	51	6	70936
634	1	17	51	4	55011
635	1	17	51	5	58527
636	1	17	51	6	64316
637	1	54	16	4	6483
638	1	54	16	5	53407
639	1	54	16	6	41976
640	1	7	38	4	99462
641	1	7	38	5	25965
642	1	7	38	6	66643
643	1	14	51	4	80645
644	1	14	51	5	47286
645	1	14	51	6	54935
646	1	12	51	4	87201
647	1	12	51	5	29400
648	1	12	51	6	50701
649	1	48	18	4	49183
650	1	48	18	5	6576
651	1	48	18	6	5841
652	1	48	37	4	79449
653	1	48	37	5	16677
654	1	48	37	6	47656
655	1	49	21	4	51746
656	1	49	21	5	14606
657	1	49	21	6	27339
658	1	6	51	4	41666
659	1	6	51	5	13969
660	1	6	51	6	42145
661	1	57	22	4	15308
662	1	57	22	5	68948
663	1	57	22	6	22288
664	1	59	20	4	92084
665	1	59	20	5	30999
666	1	59	20	6	34878
667	1	48	21	4	91955
668	1	48	21	5	40174
669	1	48	21	6	40845
670	1	29	37	4	32761
671	1	29	37	5	14584
672	1	29	37	6	78700
673	1	49	16	4	6999
674	1	49	16	5	51159
675	1	49	16	6	37657
676	1	44	8	4	50261
677	1	44	8	5	61133
678	1	44	8	6	27944
679	1	45	8	4	41707
680	1	45	8	5	22153
681	1	45	8	6	84943
682	1	14	50	4	12146
683	1	14	50	5	40964
684	1	14	50	6	20702
685	1	50	36	4	97931
686	1	50	36	5	32878
687	1	50	36	6	28631
688	1	52	8	4	21358
689	1	52	8	5	67161
690	1	52	8	6	21872
691	1	49	36	4	59108
692	1	49	36	5	56848
693	1	49	36	6	36006
694	1	46	21	4	7336
695	1	46	21	5	39553
696	1	46	21	6	73301
697	1	35	36	4	9472
698	1	35	36	5	53381
699	1	35	36	6	72600
700	1	57	24	4	93743
701	1	57	24	5	55737
702	1	57	24	6	18412
703	1	39	16	4	11353
704	1	39	16	5	25725
705	1	39	16	6	84872
706	1	34	36	4	57106
707	1	34	36	5	6635
708	1	34	36	6	58505
709	1	12	9	4	66439
710	1	12	9	5	51422
711	1	12	9	6	85804
712	1	36	49	4	58779
713	1	36	49	5	2099
714	1	36	49	6	56134
715	1	29	36	4	29722
716	1	29	36	5	61238
717	1	29	36	6	19598
718	1	16	9	4	52399
719	1	16	9	5	65361
720	1	16	9	6	1159
721	1	17	9	4	97037
722	1	17	9	5	1767
723	1	17	9	6	91667
724	1	44	3	4	5266
725	1	44	3	5	26606
726	1	44	3	6	72338
727	1	15	49	4	99133
728	1	15	49	5	63705
729	1	15	49	6	64124
730	1	14	49	4	36987
731	1	14	49	5	61339
732	1	14	49	6	67000
733	1	15	25	4	71887
734	1	15	25	5	33096
735	1	15	25	6	32397
736	1	53	35	4	25644
737	1	53	35	5	8627
738	1	53	35	6	55315
739	1	43	35	4	17679
740	1	43	35	5	52550
741	1	43	35	6	26434
742	1	30	35	4	19807
743	1	30	35	5	19919
744	1	30	35	6	83844
745	1	24	25	4	47305
746	1	24	25	5	53991
747	1	24	25	6	82893
748	1	44	9	4	69323
749	1	44	9	5	69998
750	1	44	9	6	18777
751	1	45	9	4	96701
752	1	45	9	5	13269
753	1	45	9	6	46052
754	1	46	9	4	51690
755	1	46	9	5	12868
756	1	46	9	6	45913
757	1	52	34	4	47254
758	1	52	34	5	69061
759	1	52	34	6	79189
760	1	51	34	4	25853
761	1	51	34	5	55221
762	1	51	34	6	1462
763	1	52	9	4	20966
764	1	52	9	5	31667
765	1	52	9	6	1492
766	1	53	9	4	94023
767	1	53	9	5	14186
768	1	53	9	6	7217
769	1	54	9	4	96952
770	1	54	9	5	56045
771	1	54	9	6	36565
772	1	55	9	4	65612
773	1	55	9	5	26015
774	1	55	9	6	34115
775	1	10	49	4	46132
776	1	10	49	5	13298
777	1	10	49	6	13762
778	1	49	34	4	92262
779	1	49	34	5	59737
780	1	49	34	6	11069
781	1	58	9	4	28233
782	1	58	9	5	59523
783	1	58	9	6	25680
784	1	12	18	4	57662
785	1	12	18	5	21722
786	1	12	18	6	77954
787	1	16	1	4	77067
788	1	16	1	5	1590
789	1	16	1	6	21281
790	1	11	18	4	4239
791	1	11	18	5	13023
792	1	11	18	6	85264
793	1	31	34	4	44642
794	1	31	34	5	14627
795	1	31	34	6	1122
796	1	35	22	4	33626
797	1	35	22	5	68813
798	1	35	22	6	58429
799	1	8	10	4	83577
800	1	8	10	5	10923
801	1	8	10	6	94320
802	1	11	10	4	27512
803	1	11	10	5	56100
804	1	11	10	6	33874
805	1	13	10	4	65547
806	1	13	10	5	18061
807	1	13	10	6	17580
808	1	26	34	4	94793
809	1	26	34	5	60839
810	1	26	34	6	38211
811	1	28	25	4	32205
812	1	28	25	5	17739
813	1	28	25	6	19687
814	1	8	9	1	222630
815	1	8	9	5	118249
816	1	37	44	1	326419
817	1	37	44	5	117046
818	1	45	24	1	280766
819	1	45	24	5	50916
820	1	49	22	1	380103
821	1	49	22	5	90450
822	1	14	44	1	393812
823	1	14	44	5	85600
824	1	25	25	1	285340
825	1	25	25	5	46145
826	1	11	44	1	375522
827	1	11	44	5	68351
828	1	53	34	1	211837
829	1	53	34	5	74298
830	1	9	44	1	347222
831	1	9	44	5	76318
832	1	15	3	1	349519
833	1	15	3	5	55609
834	1	30	36	1	435908
835	1	30	36	5	116986
836	1	17	23	1	217251
837	1	17	23	5	48060
838	1	16	21	1	488223
839	1	16	21	5	89095
840	1	19	10	1	444075
841	1	19	10	5	45751
842	1	15	43	1	442943
843	1	15	43	5	105819
844	1	59	9	1	401361
845	1	59	9	5	101927
846	1	37	18	1	241052
847	1	37	18	5	55962
848	1	6	54	1	413371
849	1	6	54	5	59365
850	1	45	20	1	477552
851	1	45	20	5	74116
852	1	52	33	1	311636
853	1	52	33	5	116334
854	1	51	33	1	447500
855	1	51	33	5	93434
856	1	11	43	1	378350
857	1	11	43	5	61515
858	1	25	10	1	443094
859	1	25	10	5	113072
860	1	60	21	1	409859
861	1	60	21	5	105705
862	1	38	22	1	251986
863	1	38	22	5	42283
864	1	48	22	1	449578
865	1	48	22	5	51854
866	1	42	20	1	478267
867	1	42	20	5	90136
868	1	46	23	1	247225
869	1	46	23	5	99522
870	1	10	43	1	486033
871	1	10	43	5	98573
872	1	33	33	1	376662
873	1	33	33	5	45204
874	1	32	33	1	263693
875	1	32	33	5	42648
876	1	31	33	1	216158
877	1	31	33	5	71328
878	1	31	38	1	442415
879	1	31	38	5	79832
880	1	50	20	1	332887
881	1	50	20	5	82245
882	1	28	33	1	374560
883	1	28	33	5	82059
884	1	46	24	1	366287
885	1	46	24	5	87861
886	1	11	58	1	406987
887	1	11	58	5	118643
888	1	16	53	1	424715
889	1	16	53	5	52003
890	1	46	17	1	421995
891	1	46	17	5	101379
892	1	41	25	1	463665
893	1	41	25	5	105874
894	1	47	25	1	382150
895	1	47	25	5	104029
896	1	44	10	1	229793
897	1	44	10	5	96566
898	1	45	10	1	248125
899	1	45	10	5	80543
900	1	58	21	1	448858
901	1	58	21	5	87863
902	1	37	42	1	354990
903	1	37	42	5	75701
904	1	26	23	1	270994
905	1	26	23	5	50161
906	1	20	59	1	354101
907	1	20	59	5	91435
908	1	12	8	1	303465
909	1	12	8	5	48503
910	1	39	20	1	200192
911	1	39	20	5	103922
912	1	14	53	1	489075
913	1	14	53	5	109554
914	1	53	10	1	348778
915	1	53	10	5	85802
916	1	56	21	1	286626
917	1	56	21	5	84980
918	1	13	53	1	310533
919	1	13	53	5	71714
920	1	12	4	1	356685
921	1	12	4	5	119258
922	1	14	8	1	420500
923	1	14	8	5	68021
924	1	6	52	1	322235
925	1	6	52	5	60757
926	1	16	8	1	332392
927	1	16	8	5	112890
928	1	60	10	1	382516
929	1	60	10	5	59627
930	1	48	25	1	377263
931	1	48	25	5	53046
932	1	36	18	1	476867
933	1	36	18	5	42829
934	1	13	4	1	229377
935	1	13	4	5	40891
936	1	54	22	1	437209
937	1	54	22	5	51305
938	1	43	3	1	463695
939	1	43	3	5	59772
940	1	55	25	1	208618
941	1	55	25	5	91636
942	1	39	17	1	249730
943	1	39	17	5	101074
944	1	26	51	1	337653
945	1	26	51	5	56451
946	1	9	11	1	475786
947	1	9	11	5	89598
948	1	31	42	1	204774
949	1	31	42	5	45766
950	1	16	4	1	385400
951	1	16	4	5	60859
952	1	12	11	1	342681
953	1	12	11	5	79158
954	1	13	11	1	358088
955	1	13	11	5	63736
956	1	11	19	1	335186
957	1	11	19	5	110296
958	1	17	6	1	480042
959	1	17	6	5	118019
960	1	10	10	1	319114
961	1	10	10	5	79588
962	1	51	31	1	487218
963	1	51	31	5	102674
964	1	18	11	1	274676
965	1	18	11	5	51399
966	1	19	11	1	292161
967	1	19	11	5	80842
968	1	20	11	1	348313
969	1	20	11	5	40260
970	1	27	38	1	445636
971	1	27	38	5	81860
972	1	14	42	1	428247
973	1	14	42	5	61291
974	1	48	24	1	306848
975	1	48	24	5	59187
976	1	59	15	1	317713
977	1	59	15	5	89266
978	1	11	1	1	450528
979	1	11	1	5	63170
980	1	50	9	1	243800
981	1	50	9	5	84981
982	1	27	36	1	219482
983	1	27	36	5	71936
984	1	10	42	1	451959
985	1	10	42	5	100099
986	1	25	8	1	423013
987	1	25	8	5	96281
988	1	27	6	1	410095
989	1	27	6	5	67056
990	1	14	26	1	380140
991	1	14	26	5	103347
992	1	15	48	1	358379
993	1	15	48	5	65123
994	1	46	18	1	201474
995	1	46	18	5	43398
996	1	30	31	1	473594
997	1	30	31	5	75589
998	1	54	15	1	435304
999	1	54	15	5	46564
1000	1	15	26	1	319903
1001	1	15	26	5	116992
1002	1	13	48	1	385837
1003	1	13	48	5	77063
1004	1	23	36	1	320262
1005	1	23	36	5	109437
1006	1	17	26	1	249368
1007	1	17	26	5	54653
1008	1	54	18	1	276920
1009	1	54	18	5	105687
1010	1	52	16	1	483798
1011	1	52	16	5	87815
1012	1	50	34	1	272019
1013	1	50	34	5	51571
1014	1	47	30	1	401593
1015	1	47	30	5	59264
1016	1	23	4	1	492283
1017	1	23	4	5	71270
1018	1	50	19	1	206507
1019	1	50	19	5	78204
1020	1	31	41	1	322753
1021	1	31	41	5	113002
1022	1	11	48	1	398772
1023	1	11	48	5	81547
1024	1	50	37	1	353828
1025	1	50	37	5	81455
1026	1	29	41	1	256377
1027	1	29	41	5	61853
1028	1	50	11	1	354751
1029	1	50	11	5	54859
1030	1	51	11	1	336983
1031	1	51	11	5	106378
1032	1	53	18	1	222936
1033	1	53	18	5	73732
1034	1	46	30	1	277536
1035	1	46	30	5	43940
1036	1	10	48	1	345362
1037	1	10	48	5	60523
1039	1	5	2	5	45803
1040	1	56	11	1	313827
1041	1	56	11	5	66233
1042	1	44	30	1	294175
1043	1	44	30	5	89420
1044	1	36	17	1	426172
1045	1	36	17	5	92381
1046	1	59	11	1	475525
1047	1	59	11	5	98409
1048	1	17	41	1	338157
1049	1	17	41	5	41010
1050	1	43	30	1	484855
1051	1	43	30	5	40837
1052	1	35	17	1	206959
1053	1	35	17	5	72494
1054	1	36	16	1	322182
1055	1	36	16	5	44277
1056	1	60	19	1	361082
1057	1	60	19	5	97210
1058	1	37	30	1	486582
1059	1	37	30	5	78894
1060	1	16	25	1	480331
1061	1	16	25	5	101731
1062	1	42	37	1	391452
1063	1	42	37	5	58930
1064	1	45	15	1	261620
1065	1	45	15	5	86617
1066	1	35	47	1	286743
1067	1	35	47	5	71393
1068	1	22	34	1	478977
1069	1	22	34	5	54792
1070	1	10	41	1	400153
1071	1	10	41	5	83059
1072	1	9	41	1	373705
1073	1	9	41	5	85779
1074	1	36	19	1	388200
1075	1	36	19	5	110860
1076	1	38	15	1	245008
1077	1	38	15	5	46861
1078	1	17	25	1	403295
1079	1	17	25	5	79700
1080	1	50	29	1	403084
1081	1	50	29	5	99063
1082	1	49	29	1	410457
1083	1	49	29	5	119769
1084	1	52	35	1	483419
1085	1	52	35	5	79634
1086	1	13	49	1	362749
1087	1	13	49	5	79229
1088	1	38	19	1	337477
1089	1	38	19	5	93862
1090	1	21	12	1	453995
1091	1	21	12	5	50268
1092	1	36	26	1	489801
1093	1	36	26	5	89869
1094	1	12	19	1	498606
1095	1	12	19	5	70011
1096	1	16	47	1	468790
1097	1	16	47	5	93582
1098	1	45	29	1	257082
1099	1	45	29	5	74909
1100	1	16	50	1	340717
1101	1	16	50	5	96228
1102	1	12	2	1	376008
1103	1	12	2	5	54988
1104	1	13	57	1	327592
1105	1	13	57	5	86791
1106	1	16	22	1	303709
1107	1	16	22	5	108877
1108	1	43	29	1	410431
1109	1	43	29	5	119460
1110	1	49	40	1	279786
1111	1	49	40	5	104437
1112	1	11	47	1	202225
1113	1	11	47	5	90408
1114	1	29	21	1	257099
1115	1	29	21	5	51467
1116	1	38	29	1	359338
1117	1	38	29	5	89333
1118	1	37	29	1	227924
1119	1	37	29	5	51020
1120	1	39	26	1	226296
1121	1	39	26	5	75793
1122	1	52	23	1	307419
1123	1	52	23	5	57141
1124	1	40	26	1	412076
1125	1	40	26	5	61605
1126	1	57	6	1	325987
1127	1	57	6	5	95485
1128	1	58	6	1	308666
1129	1	58	6	5	63792
1130	1	50	22	1	350425
1131	1	50	22	5	75708
1132	1	8	47	1	359880
1133	1	8	47	5	43600
1134	1	27	29	1	271562
1135	1	27	29	5	65068
1136	1	48	35	1	429121
1137	1	48	35	5	70311
1138	1	37	40	1	354051
1139	1	37	40	5	105097
1140	1	46	12	1	254950
1141	1	46	12	5	116911
1142	1	47	12	1	321017
1143	1	47	12	5	115240
1144	1	31	18	1	445065
1145	1	31	18	5	86099
1146	1	57	26	1	489599
1147	1	57	26	5	97771
1148	1	50	12	1	252671
1149	1	50	12	5	68603
1150	1	14	2	1	342654
1151	1	14	2	5	57501
1152	1	15	50	1	336775
1153	1	15	50	5	119028
1154	1	47	35	1	385052
1155	1	47	35	5	50987
1156	1	54	12	1	384383
1157	1	54	12	5	60177
1158	1	43	8	1	481496
1159	1	43	8	5	112732
1160	1	34	46	1	242441
1161	1	34	46	5	59914
1162	1	59	26	1	319656
1163	1	59	26	5	117824
1164	1	59	28	1	350583
1165	1	59	28	5	57613
1166	1	3	2	1	451292
1167	1	3	2	5	60400
1168	1	48	20	1	253802
1169	1	48	20	5	114581
1170	1	58	28	1	380563
1171	1	58	28	5	67765
1172	1	3	1	1	242444
1173	1	3	1	5	101134
1174	1	13	58	1	421360
1175	1	13	58	5	102771
1176	1	58	19	1	281875
1177	1	58	19	5	46570
1178	1	34	35	1	333908
1179	1	34	35	5	80789
1180	1	47	28	1	210878
1181	1	47	28	5	112992
1182	1	10	46	1	337783
1183	1	10	46	5	44856
1184	1	52	36	1	206814
1185	1	52	36	5	88358
1186	1	9	46	1	395277
1187	1	9	46	5	110999
1188	1	12	7	1	392727
1189	1	12	7	5	101049
1190	1	11	13	1	381283
1191	1	11	13	5	75218
1192	1	12	13	1	366118
1193	1	12	13	5	104588
1194	1	13	13	1	319997
1195	1	13	13	5	59065
1196	1	8	46	1	435428
1197	1	8	46	5	118778
1198	1	40	28	1	260444
1199	1	40	28	5	70643
1200	1	14	52	1	382649
1201	1	14	52	5	98039
1202	1	7	46	1	419116
1203	1	7	46	5	84289
1204	1	26	40	1	211024
1205	1	26	40	5	73129
1206	1	12	50	1	432101
1207	1	12	50	5	71757
1208	1	4	1	1	353121
1209	1	4	1	5	95042
1210	1	51	4	1	290670
1211	1	51	4	5	105837
1212	1	31	35	1	411874
1213	1	31	35	5	60570
1214	1	11	50	1	449685
1215	1	11	50	5	49009
1216	1	13	19	1	403587
1217	1	13	19	5	65859
1218	1	36	23	1	237933
1219	1	36	23	5	102347
1220	1	28	28	1	263120
1221	1	28	28	5	93096
1222	1	14	27	1	267802
1223	1	14	27	5	46998
1224	1	13	17	1	247602
1225	1	13	17	5	45706
1226	1	51	8	1	436250
1227	1	51	8	5	63871
1228	1	12	10	1	220988
1229	1	12	10	5	51029
1230	1	10	40	1	395305
1231	1	10	40	5	50167
1232	1	14	19	1	264057
1233	1	14	19	5	101297
1234	1	53	8	1	232694
1235	1	53	8	5	110898
1236	1	18	28	1	253948
1237	1	18	28	5	75940
1238	1	47	21	1	223919
1239	1	47	21	5	103477
1240	1	41	19	1	206284
1241	1	41	19	5	82014
1242	1	55	24	1	251711
1243	1	55	24	5	83209
1244	1	15	24	1	410066
1245	1	15	24	5	79945
1246	1	52	14	1	400148
1247	1	52	14	5	107720
1248	1	37	23	1	431199
1249	1	37	23	5	114350
1250	1	51	14	1	252838
1251	1	51	14	5	97000
1252	1	15	28	1	448183
1253	1	15	28	5	100348
1254	1	13	28	1	474022
1255	1	13	28	5	93384
1256	1	56	24	1	414641
1257	1	56	24	5	82183
1258	1	45	13	1	444642
1259	1	45	13	5	68053
1260	1	60	17	1	417912
1261	1	60	17	5	109295
1262	1	11	52	1	226707
1263	1	11	52	5	54450
1264	1	48	13	1	207933
1265	1	48	13	5	59315
1266	1	41	22	1	416886
1267	1	41	22	5	58200
1268	1	42	22	1	299900
1269	1	42	22	5	77382
1270	1	57	8	1	278929
1271	1	57	8	5	91019
1272	1	59	17	1	239535
1273	1	59	17	5	76585
1274	1	43	23	1	430318
1275	1	43	23	5	79627
1276	1	54	13	1	234021
1277	1	54	13	5	109611
1278	1	11	49	1	341663
1279	1	11	49	5	54916
1280	1	26	27	1	231220
1281	1	26	27	5	65334
1282	1	10	52	1	470169
1283	1	10	52	5	78413
1284	1	58	13	1	350827
1285	1	58	13	5	84039
1286	1	59	8	1	454245
1287	1	59	8	5	48171
1288	1	17	56	1	308514
1289	1	17	56	5	68682
1290	1	58	58	1	318151
1291	1	58	58	5	108621
1292	1	57	27	1	429677
1293	1	57	27	5	108551
1294	1	53	22	1	364314
1295	1	53	22	5	99876
1296	1	34	45	1	484606
1297	1	34	45	5	93300
1298	1	36	39	1	229862
1299	1	36	39	5	71378
1300	1	49	27	1	269845
1301	1	49	27	5	83628
1302	1	34	39	1	392717
1303	1	34	39	5	48478
1304	1	50	3	1	363418
1305	1	50	3	5	111459
1307	1	4	5	5	42199
1308	1	5	5	1	495424
1309	1	5	5	5	63362
1310	1	11	14	1	307995
1311	1	11	14	5	63445
1312	1	30	39	1	350082
1313	1	30	39	5	81165
1314	1	48	36	1	371212
1315	1	48	36	5	79165
1316	1	28	39	1	471788
1317	1	28	39	5	98313
1318	1	42	27	1	297673
1319	1	42	27	5	112860
1320	1	41	27	1	334299
1321	1	41	27	5	86644
1322	1	47	36	1	478829
1323	1	47	36	5	58493
1324	1	43	36	1	409792
1325	1	43	36	5	66984
1326	1	11	55	1	382504
1327	1	11	55	5	54968
1328	1	11	3	1	262411
1329	1	11	3	5	119480
1330	1	45	7	1	404169
1331	1	45	7	5	71205
1332	1	15	56	1	304646
1333	1	15	56	5	47237
1334	1	15	23	1	295334
1335	1	15	23	5	48779
1336	1	41	36	1	368153
1337	1	41	36	5	52026
1338	1	10	55	1	294131
1339	1	10	55	5	115960
1340	1	12	3	1	463544
1341	1	12	3	5	86658
1342	1	16	58	1	276160
1343	1	16	58	5	83078
1344	1	10	5	1	327746
1345	1	10	5	5	119580
1346	1	11	5	1	456046
1347	1	11	5	5	53203
1348	1	12	5	1	233595
1349	1	12	5	5	84509
1350	1	13	5	1	336321
1351	1	13	5	5	115362
1352	1	7	39	1	339963
1353	1	7	39	5	97176
1354	1	22	35	1	381685
1355	1	22	35	5	81866
1356	1	16	5	1	397305
1357	1	16	5	5	78569
1358	1	17	5	1	340797
1359	1	17	5	5	94558
1360	1	51	7	1	472207
1361	1	51	7	5	112384
1362	1	14	45	1	247536
1363	1	14	45	5	42692
1364	1	52	7	1	290538
1365	1	52	7	5	116184
1366	1	12	45	1	446647
1367	1	12	45	5	62202
1368	1	55	17	1	471223
1369	1	55	17	5	90580
1370	1	53	7	1	243233
1371	1	53	7	5	58686
1372	1	24	5	1	488844
1373	1	24	5	5	70482
1374	1	25	5	1	458639
1375	1	25	5	5	54122
1376	1	11	45	1	276190
1377	1	11	45	5	92786
1378	1	27	5	1	376178
1379	1	27	5	5	62967
1380	1	28	5	1	207874
1381	1	28	5	5	46109
1382	1	10	45	1	489682
1383	1	10	45	5	65531
1384	1	22	16	1	249768
1385	1	22	16	5	50003
1386	1	8	45	1	492128
1387	1	8	45	5	115406
1388	1	9	30	6	128460
1389	1	9	30	4	105336
1390	1	9	30	5	50534
1391	1	10	30	6	87270
1392	1	10	30	4	274784
1393	1	10	30	5	35174
1394	1	40	15	6	147541
1395	1	40	15	4	199306
1396	1	40	15	5	53255
1397	1	41	15	6	88390
1398	1	41	15	4	127446
1399	1	41	15	5	20244
1400	1	31	26	6	67117
1401	1	31	26	4	249712
1402	1	31	26	5	20931
1403	1	30	26	6	130994
1404	1	30	26	4	149454
1405	1	30	26	5	38226
1406	1	11	23	6	127354
1407	1	11	23	4	291980
1408	1	11	23	5	49385
1409	1	32	30	6	65261
1410	1	32	30	4	133093
1411	1	32	30	5	49078
1412	1	8	23	6	68247
1413	1	8	23	4	299477
1414	1	8	23	5	60560
1415	1	33	30	6	60140
1416	1	33	30	4	151911
1417	1	33	30	5	42918
1418	1	36	30	6	72193
1419	1	36	30	4	181729
1420	1	36	30	5	9741
1421	1	59	50	6	118555
1422	1	59	50	4	125736
1423	1	59	50	5	18606
1424	1	39	11	6	53389
1425	1	39	11	4	285922
1426	1	39	11	5	57449
1427	1	60	51	6	127118
1428	1	60	51	4	256179
1429	1	60	51	5	65928
1430	1	10	31	6	142198
1431	1	10	31	4	230834
1432	1	10	31	5	16636
1433	1	9	3	6	103714
1434	1	9	3	4	273576
1435	1	9	3	5	65861
1436	1	11	31	6	65496
1437	1	11	31	4	189234
1438	1	11	31	5	57337
1439	1	33	31	6	105385
1440	1	33	31	4	148916
1441	1	33	31	5	38404
1442	1	9	26	6	71220
1443	1	9	26	4	270976
1444	1	9	26	5	59297
1445	1	35	31	6	113181
1446	1	35	31	4	282985
1447	1	35	31	5	65734
1448	1	37	31	6	101452
1449	1	37	31	4	242194
1450	1	37	31	5	43766
1451	1	47	31	6	58918
1452	1	47	31	4	276855
1453	1	47	31	5	62786
1454	1	8	32	6	76117
1455	1	8	32	4	223751
1456	1	8	32	5	58265
1457	1	11	32	6	88042
1458	1	11	32	4	271256
1459	1	11	32	5	7209
1460	1	30	32	6	97445
1461	1	30	32	4	278134
1462	1	30	32	5	66414
1463	1	47	32	6	135011
1464	1	47	32	4	102789
1465	1	47	32	5	34395
1466	1	8	33	6	50007
1467	1	8	33	4	223934
1468	1	8	33	5	17829
1469	1	25	19	6	114403
1470	1	25	19	4	102801
1471	1	25	19	5	14279
1472	1	23	18	6	75634
1473	1	23	18	4	109648
1474	1	23	18	5	11233
1475	1	60	1	6	72516
1476	1	60	1	4	203178
1477	1	60	1	5	18242
1478	1	25	18	6	75731
1479	1	25	18	4	160209
1480	1	25	18	5	59722
1481	1	10	33	6	121717
1482	1	10	33	4	219352
1483	1	10	33	5	11480
1484	1	8	3	6	132778
1485	1	8	3	4	282458
1486	1	8	3	5	58350
1487	1	59	2	6	109132
1488	1	59	2	4	128894
1489	1	59	2	5	6115
1490	1	60	60	6	125026
1491	1	60	60	4	212804
1492	1	60	60	5	57789
1493	1	13	33	6	81461
1494	1	13	33	4	161157
1495	1	13	33	5	27621
1496	1	60	57	6	124821
1497	1	60	57	4	277343
1498	1	60	57	5	11268
1499	1	27	33	6	77889
1500	1	27	33	4	111734
1501	1	27	33	5	11434
1502	1	46	33	6	91612
1503	1	46	33	4	168476
1504	1	46	33	5	69951
1505	1	56	2	6	101130
1506	1	56	2	4	273169
1507	1	56	2	5	47854
1508	1	31	25	6	143275
1509	1	31	25	4	298583
1510	1	31	25	5	59488
1511	1	30	25	6	105114
1512	1	30	25	4	109172
1513	1	30	25	5	62712
1514	1	10	34	6	58553
1515	1	10	34	4	121374
1516	1	10	34	5	4223
1517	1	11	34	6	107113
1518	1	11	34	4	171680
1519	1	11	34	5	41678
1520	1	21	34	6	93748
1521	1	21	34	4	232786
1522	1	21	34	5	24102
1523	1	30	18	6	96682
1524	1	30	18	4	138947
1525	1	30	18	5	21371
1526	1	8	35	6	88499
1527	1	8	35	4	159807
1528	1	8	35	5	37820
1529	1	25	16	6	56496
1530	1	25	16	4	108323
1531	1	25	16	5	21637
1532	1	26	16	6	58333
1533	1	26	16	4	169082
1534	1	26	16	5	7225
1535	1	9	35	6	86149
1536	1	9	35	4	140030
1537	1	9	35	5	66334
1538	1	28	16	6	79853
1539	1	28	16	4	237033
1540	1	28	16	5	68280
1541	1	54	2	6	135180
1542	1	54	2	4	176537
1543	1	54	2	5	63906
1544	1	30	16	6	77111
1545	1	30	16	4	111040
1546	1	30	16	5	64306
1547	1	28	9	6	148138
1548	1	28	9	4	128753
1549	1	28	9	5	58546
1550	1	7	36	6	95678
1551	1	7	36	4	279184
1552	1	7	36	5	21296
1553	1	8	36	6	61356
1554	1	8	36	4	255225
1555	1	8	36	5	53253
1556	1	13	25	6	52454
1557	1	13	25	4	148086
1558	1	13	25	5	14563
1559	1	32	18	6	110860
1560	1	32	18	4	247590
1561	1	32	18	5	61784
1562	1	9	36	6	143045
1563	1	9	36	4	199793
1564	1	9	36	5	2227
1565	1	33	18	6	141289
1566	1	33	18	4	122452
1567	1	33	18	5	45302
1568	1	10	25	6	53488
1569	1	10	25	4	159040
1570	1	10	25	5	61937
1572	1	9	9	4	290903
1574	1	48	60	6	117840
1575	1	48	60	4	292454
1576	1	48	60	5	29985
1577	1	55	1	6	50454
1578	1	55	1	4	252306
1579	1	55	1	5	58946
1580	1	56	1	6	120046
1581	1	56	1	4	143280
1582	1	56	1	5	6385
1583	1	7	9	6	93687
1584	1	7	9	4	159872
1585	1	7	9	5	19476
1586	1	44	16	6	126879
1587	1	44	16	4	107213
1588	1	44	16	5	56891
1589	1	53	2	6	85897
1590	1	53	2	4	196273
1591	1	53	2	5	53823
1592	1	56	8	6	134895
1593	1	56	8	4	117667
1594	1	56	8	5	37447
1595	1	55	8	6	87437
1596	1	55	8	4	187320
1597	1	55	8	5	43773
1598	1	42	2	6	121372
1599	1	42	2	4	203231
1600	1	42	2	5	49461
1601	1	6	37	6	101379
1602	1	6	37	4	227291
1603	1	6	37	5	2573
1604	1	9	1	6	89832
1605	1	9	1	4	146382
1606	1	9	1	5	19547
1607	1	7	54	6	79523
1608	1	7	54	4	253908
1609	1	7	54	5	53239
1610	1	27	8	6	77701
1611	1	27	8	4	124564
1612	1	27	8	5	34207
1613	1	33	22	6	120438
1614	1	33	22	4	235633
1615	1	33	22	5	16978
1616	1	9	38	6	68397
1617	1	9	38	4	212117
1618	1	9	38	5	63833
1619	1	17	38	6	109726
1620	1	17	38	4	129863
1621	1	17	38	5	43140
1622	1	32	22	6	77783
1623	1	32	22	4	189414
1624	1	32	22	5	50831
1625	1	8	8	6	111342
1626	1	8	8	4	195052
1627	1	8	8	5	60388
1628	1	56	7	6	66273
1629	1	56	7	4	159424
1630	1	56	7	5	51038
1631	1	47	54	6	104519
1632	1	47	54	4	171470
1633	1	47	54	5	33352
1634	1	55	54	6	114077
1635	1	55	54	4	122980
1636	1	55	54	5	60289
1637	1	56	54	6	137630
1638	1	56	54	4	117010
1639	1	56	54	5	45916
1640	1	33	20	6	116727
1641	1	33	20	4	123372
1642	1	33	20	5	10804
1643	1	55	7	6	72926
1644	1	55	7	4	260732
1645	1	55	7	5	20892
1646	1	6	1	6	91644
1647	1	6	1	4	119431
1648	1	6	1	5	29243
1649	1	16	39	6	94551
1650	1	16	39	4	179094
1651	1	16	39	5	54178
1652	1	17	39	6	138157
1653	1	17	39	4	121537
1654	1	17	39	5	51387
1655	1	34	24	6	51513
1656	1	34	24	4	132713
1657	1	34	24	5	49972
1658	1	33	24	6	106680
1659	1	33	24	4	150447
1660	1	33	24	5	26831
1661	1	27	7	6	83535
1662	1	27	7	4	181328
1663	1	27	7	5	39281
1664	1	26	7	6	109061
1665	1	26	7	4	143840
1666	1	26	7	5	6352
1667	1	25	7	6	141127
1668	1	25	7	4	147064
1669	1	25	7	5	65402
1670	1	16	40	6	148560
1671	1	16	40	4	253648
1672	1	16	40	5	57920
1673	1	18	40	6	103517
1674	1	18	40	4	115913
1675	1	18	40	5	55820
1676	1	17	7	6	102777
1677	1	17	7	4	284348
1678	1	17	7	5	13905
1679	1	45	18	6	66938
1680	1	45	18	4	101537
1681	1	45	18	5	4733
1682	1	12	24	6	107102
1683	1	12	24	4	164920
1684	1	12	24	5	65027
1685	1	11	24	6	109122
1686	1	11	24	4	159186
1687	1	11	24	5	68256
1688	1	10	7	6	65526
1689	1	10	7	4	223632
1690	1	10	7	5	63741
1691	1	9	24	6	77340
1692	1	9	24	4	275648
1693	1	9	24	5	12399
1694	1	8	24	6	71380
1695	1	8	24	4	291732
1696	1	8	24	5	25664
1697	1	9	7	6	81137
1698	1	9	7	4	216313
1699	1	9	7	5	9117
1700	1	35	40	6	98465
1701	1	35	40	4	101247
1702	1	35	40	5	56727
1703	1	23	17	6	128189
1704	1	23	17	4	157972
1705	1	23	17	5	52610
1706	1	24	17	6	114550
1707	1	24	17	4	258427
1708	1	24	17	5	52662
1709	1	25	17	6	136574
1710	1	25	17	4	211563
1711	1	25	17	5	16307
1712	1	26	17	6	119033
1713	1	26	17	4	281352
1714	1	26	17	5	68747
1715	1	60	6	6	91345
1716	1	60	6	4	270150
1717	1	60	6	5	55730
1718	1	28	17	6	135859
1719	1	28	17	4	193606
1720	1	28	17	5	59883
1721	1	56	6	6	66065
1722	1	56	6	4	147938
1723	1	56	6	5	16144
1724	1	3	41	6	82239
1725	1	3	41	4	232549
1726	1	3	41	5	26671
1727	1	31	17	6	75875
1728	1	31	17	4	176554
1729	1	31	17	5	20244
1730	1	32	17	6	68409
1731	1	32	17	4	234211
1732	1	32	17	5	55191
1733	1	15	41	6	51650
1734	1	15	41	4	197645
1735	1	15	41	5	21530
1736	1	34	20	6	98992
1737	1	34	20	4	122079
1738	1	34	20	5	38560
1739	1	16	41	6	138176
1740	1	16	41	4	141703
1741	1	16	41	5	10782
1742	1	20	41	6	53013
1743	1	20	41	4	105304
1744	1	20	41	5	33040
1745	1	43	20	6	97802
1746	1	43	20	4	191917
1747	1	43	20	5	51971
1748	1	26	6	6	64665
1749	1	26	6	4	144996
1750	1	26	6	5	4590
1751	1	14	6	6	145997
1752	1	14	6	4	282714
1753	1	14	6	5	44537
1755	1	9	6	4	265443
1756	1	9	6	5	14694
1757	1	57	1	6	110722
1758	1	57	1	4	182282
1759	1	57	1	5	2844
1760	1	8	6	6	119043
1761	1	8	6	4	283872
1762	1	8	6	5	67096
1763	1	43	17	6	76237
1764	1	43	17	4	135580
1765	1	43	17	5	30719
1766	1	9	21	6	54348
1767	1	9	21	4	125903
1768	1	9	21	5	10231
1769	1	45	17	6	129701
1770	1	45	17	4	230765
1771	1	45	17	5	9976
1772	1	60	5	6	64141
1773	1	60	5	4	157745
1774	1	60	5	5	2138
1775	1	45	19	6	77165
1776	1	45	19	4	136019
1777	1	45	19	5	59821
1778	1	6	43	6	95976
1779	1	6	43	4	167634
1780	1	6	43	5	42489
1781	1	55	5	6	134890
1782	1	55	5	4	180077
1783	1	55	5	5	40810
1784	1	47	23	6	100872
1785	1	47	23	4	122660
1786	1	47	23	5	54654
1787	1	53	5	6	91357
1788	1	53	5	4	269929
1789	1	53	5	5	2698
1790	1	44	19	6	59057
1791	1	44	19	4	194698
1792	1	44	19	5	14345
1793	1	43	19	6	139345
1794	1	43	19	4	129151
1795	1	43	19	5	16693
1796	1	25	14	6	127747
1797	1	25	14	4	101769
1798	1	25	14	5	23007
1799	1	26	14	6	130641
1800	1	26	14	4	146360
1801	1	26	14	5	31510
1802	1	27	14	6	123513
1803	1	27	14	4	287198
1804	1	27	14	5	26053
1805	1	28	14	6	98838
1806	1	28	14	4	273182
1807	1	28	14	5	22234
1808	1	29	14	6	57995
1809	1	29	14	4	136829
1810	1	29	14	5	67347
1811	1	30	14	6	116249
1812	1	30	14	4	218960
1813	1	30	14	5	41334
1814	1	31	14	6	129046
1815	1	31	14	4	115263
1816	1	31	14	5	41830
1817	1	35	27	6	105556
1818	1	35	27	4	146411
1819	1	35	27	5	19535
1820	1	31	27	6	148027
1821	1	31	27	4	246376
1822	1	31	27	5	31547
1823	1	30	27	6	91187
1824	1	30	27	4	175506
1825	1	30	27	5	15817
1826	1	24	14	6	89471
1827	1	24	14	4	261683
1828	1	24	14	5	14363
1829	1	31	22	6	140730
1830	1	31	22	4	247804
1831	1	31	22	5	5112
1832	1	6	45	6	56965
1833	1	6	45	4	105105
1834	1	6	45	5	42177
1835	1	23	14	6	142569
1836	1	23	14	4	251646
1837	1	23	14	5	53942
1838	1	39	14	6	71654
1839	1	39	14	4	256781
1840	1	39	14	5	56754
1841	1	40	14	6	126692
1842	1	40	14	4	140328
1843	1	40	14	5	14034
1844	1	22	5	6	115191
1845	1	22	5	4	258092
1846	1	22	5	5	46292
1847	1	9	28	6	110017
1848	1	9	28	4	192448
1849	1	9	28	5	34461
1851	1	8	5	4	186126
1852	1	8	5	5	21115
1853	1	11	28	6	113168
1854	1	11	28	4	155843
1855	1	11	28	5	66299
1856	1	49	13	6	95111
1857	1	49	13	4	200636
1858	1	49	13	5	16692
1859	1	60	58	6	124717
1860	1	60	58	4	225647
1861	1	60	58	5	35413
1862	1	42	19	6	85193
1863	1	42	19	4	180465
1864	1	42	19	5	57555
1865	1	12	28	6	130084
1866	1	12	28	4	176035
1867	1	12	28	5	60022
1868	1	5	46	6	83646
1869	1	5	46	4	127129
1870	1	5	46	5	51269
1871	1	56	4	6	89520
1872	1	56	4	4	242265
1873	1	56	4	5	45191
1874	1	41	13	6	92553
1875	1	41	13	4	236324
1876	1	41	13	5	5631
1877	1	39	13	6	61544
1878	1	39	13	4	195406
1879	1	39	13	5	64064
1880	1	32	21	6	90593
1881	1	32	21	4	263394
1882	1	32	21	5	17556
1883	1	38	13	6	84268
1884	1	38	13	4	279805
1885	1	38	13	5	31963
1886	1	26	28	6	146958
1887	1	26	28	4	258165
1888	1	26	28	5	49457
1889	1	44	1	6	122098
1890	1	44	1	4	121581
1891	1	44	1	5	60055
1892	1	28	13	6	142612
1893	1	28	13	4	247697
1894	1	28	13	5	36559
1895	1	43	1	6	116910
1896	1	43	1	4	237927
1897	1	43	1	5	60178
1898	1	31	28	6	116814
1899	1	31	28	4	141344
1900	1	31	28	5	34868
1901	1	42	1	6	91106
1902	1	42	1	4	129086
1903	1	42	1	5	9923
1904	1	34	19	6	111763
1905	1	34	19	4	148654
1906	1	34	19	5	31113
1907	1	11	27	6	109546
1908	1	11	27	4	283807
1909	1	11	27	5	69824
1910	1	10	27	6	109805
1911	1	10	27	4	201677
1912	1	10	27	5	17936
1913	1	9	27	6	93776
1914	1	9	27	4	125018
1915	1	9	27	5	30041
1916	1	36	28	6	124476
1917	1	36	28	4	268032
1918	1	36	28	5	13969
1919	1	55	4	6	118568
1920	1	55	4	4	148981
1921	1	55	4	5	34641
1922	1	11	29	6	52841
1923	1	11	29	4	114319
1924	1	11	29	5	2067
1925	1	49	12	6	66053
1926	1	49	12	4	139962
1927	1	49	12	5	40432
1928	1	48	12	6	147132
1929	1	48	12	4	222956
1930	1	48	12	5	28323
1931	1	44	12	6	135840
1932	1	44	12	4	275226
1933	1	44	12	5	56712
1934	1	53	4	6	112541
1935	1	53	4	4	199174
1936	1	53	4	5	44663
1937	1	40	12	6	95342
1938	1	40	12	4	272343
1939	1	40	12	5	57208
1940	1	9	4	6	86369
1941	1	9	4	4	176767
1942	1	9	4	5	67936
1943	1	32	23	6	63469
1944	1	32	23	4	256574
1945	1	32	23	5	20563
1946	1	31	23	6	110956
1947	1	31	23	4	224160
1948	1	31	23	5	43955
1949	1	60	59	6	88884
1950	1	60	59	4	178667
1951	1	60	59	5	9888
1952	1	40	1	6	75905
1953	1	40	1	4	202368
1954	1	40	1	5	15526
1955	1	9	2	6	70056
1956	1	9	2	4	232333
1957	1	9	2	5	59842
1958	1	59	3	6	99131
1959	1	59	3	4	270099
1960	1	59	3	5	60305
1961	1	56	3	6	118331
1962	1	56	3	4	117579
1963	1	56	3	5	41518
1964	1	53	3	6	104804
1965	1	53	3	4	166565
1966	1	53	3	5	55196
1967	1	22	15	6	105661
1968	1	22	15	4	260457
1969	1	22	15	5	59279
1970	1	38	12	6	148722
1971	1	38	12	4	293905
1972	1	38	12	5	41867
1973	1	36	29	6	59202
1974	1	36	29	4	152321
1975	1	36	29	5	15526
1976	1	23	19	6	77678
1977	1	23	19	4	228270
1978	1	23	19	5	20494
1979	1	26	15	6	73101
1980	1	26	15	4	182724
1981	1	26	15	5	15025
1982	1	27	15	6	98026
1983	1	27	15	4	253770
1984	1	27	15	5	8171
1985	1	29	12	6	80019
1986	1	29	12	4	188348
1987	1	29	12	5	19736
1988	1	52	1	6	53816
1989	1	52	1	4	256409
1990	1	52	1	5	54853
1991	1	30	15	6	100241
1992	1	30	15	4	285905
1993	1	30	15	5	61152
1994	1	31	15	6	78082
1995	1	31	15	4	207297
1996	1	31	15	5	54374
1997	1	53	1	6	98695
1998	1	53	1	4	109148
1999	1	53	1	5	58333
2000	1	34	22	6	75213
2001	1	34	22	4	187935
2002	1	34	22	5	55854
2003	1	22	12	6	122954
2004	1	22	12	4	173099
2005	1	22	12	5	12510
2006	1	35	21	6	103330
2007	1	35	21	4	117281
2008	1	35	21	5	15652
2009	1	8	30	6	116347
2010	1	8	30	4	290325
2011	1	8	30	5	46683
2012	1	40	3	6	141430
2013	1	40	3	4	131340
2014	1	40	3	5	11918
2015	1	8	21	1	157122
2016	1	8	21	5	182912
2017	1	8	21	4	45409
2018	1	10	19	1	170753
2019	1	10	19	5	253666
2020	1	10	19	4	21129
2021	1	5	22	1	143957
2022	1	5	22	5	242528
2023	1	5	22	4	39119
2024	1	8	19	1	115937
2025	1	8	19	5	145966
2026	1	8	19	4	76490
2027	1	30	22	1	191268
2028	1	30	22	5	193344
2029	1	30	22	4	54761
2030	1	6	19	1	151135
2031	1	6	19	5	298305
2032	1	6	19	4	44173
2033	1	4	19	1	70910
2034	1	4	19	5	228818
2035	1	4	19	4	39863
2036	1	3	19	1	134503
2037	1	3	19	5	151923
2038	1	3	19	4	69002
2039	1	41	18	1	121974
2040	1	41	18	5	151579
2041	1	41	18	4	9575
2042	1	19	23	1	174450
2043	1	19	23	5	212116
2044	1	19	23	4	62073
2045	1	8	18	1	71711
2046	1	8	18	5	112198
2047	1	8	18	4	89057
2048	1	5	18	1	175858
2049	1	5	18	5	159341
2050	1	5	18	4	86722
2051	1	3	18	1	132825
2052	1	3	18	5	250539
2053	1	3	18	4	12102
2054	1	1	18	1	101863
2055	1	1	18	5	260266
2056	1	1	18	4	94649
2057	1	5	24	1	99778
2058	1	5	24	5	236470
2059	1	5	24	4	56908
2060	1	7	24	1	105051
2061	1	7	24	5	298640
2062	1	7	24	4	84315
2063	1	19	24	1	196801
2064	1	19	24	5	124454
2065	1	19	24	4	51454
2066	1	8	17	1	195460
2067	1	8	17	5	282720
2068	1	8	17	4	9689
2069	1	7	17	1	166219
2070	1	7	17	5	138137
2071	1	7	17	4	16419
2072	1	3	17	1	78838
2073	1	3	17	5	118612
2074	1	3	17	4	51122
2075	1	51	16	1	79202
2076	1	51	16	5	297038
2077	1	51	16	4	81777
2078	1	7	25	1	102074
2079	1	7	25	5	157131
2080	1	7	25	4	84642
2081	1	20	25	1	179181
2082	1	20	25	5	272690
2083	1	20	25	4	77838
2084	1	21	25	1	187527
2085	1	21	25	5	113321
2086	1	21	25	4	8462
2087	1	22	25	1	108343
2088	1	22	25	5	102274
2089	1	22	25	4	25011
2090	1	6	16	1	150447
2091	1	6	16	5	139935
2092	1	6	16	4	52201
2093	1	4	16	1	183818
2094	1	4	16	5	282792
2095	1	4	16	4	6545
2096	1	3	16	1	164409
2097	1	3	16	5	259283
2098	1	3	16	4	88113
2099	1	49	25	1	169788
2100	1	49	25	5	178125
2101	1	49	25	4	18873
2102	1	2	16	1	90620
2103	1	2	16	5	208747
2104	1	2	16	4	19569
2105	1	1	16	1	102013
2106	1	1	16	5	290462
2107	1	1	16	4	3666
2108	1	59	25	1	115211
2109	1	59	25	5	134073
2110	1	59	25	4	41409
2111	1	7	26	1	175580
2112	1	7	26	5	172423
2113	1	7	26	4	10211
2114	1	12	26	1	102679
2115	1	12	26	5	287595
2116	1	12	26	4	62423
2117	1	19	26	1	109522
2118	1	19	26	5	238695
2119	1	19	26	4	47820
2120	1	43	15	1	147827
2121	1	43	15	5	148996
2122	1	43	15	4	18630
2123	1	1	15	1	151558
2124	1	1	15	5	166390
2125	1	1	15	4	18550
2126	1	19	27	1	83068
2127	1	19	27	5	116867
2128	1	19	27	4	54623
2129	1	20	27	1	123990
2130	1	20	27	5	143227
2131	1	20	27	4	76015
2132	1	21	27	1	171710
2133	1	21	27	5	167339
2134	1	21	27	4	55191
2135	1	33	27	1	166378
2136	1	33	27	5	253395
2137	1	33	27	4	88400
2138	1	34	27	1	126549
2139	1	34	27	5	194404
2140	1	34	27	4	80949
2141	1	6	14	1	101822
2142	1	6	14	5	207147
2143	1	6	14	4	4872
2144	1	51	27	1	123581
2145	1	51	27	5	123119
2146	1	51	27	4	49911
2147	1	4	14	1	136316
2148	1	4	14	5	124358
2149	1	4	14	4	55066
2150	1	3	14	1	97296
2151	1	3	14	5	263722
2152	1	3	14	4	92331
2153	1	44	13	1	152565
2154	1	44	13	5	104695
2155	1	44	13	4	76863
2156	1	42	13	1	124509
2157	1	42	13	5	107759
2158	1	42	13	4	69037
2159	1	33	13	1	172857
2160	1	33	13	5	275171
2161	1	33	13	4	38427
2162	1	21	28	1	198784
2163	1	21	28	5	273213
2164	1	21	28	4	96143
2165	1	23	28	1	116618
2166	1	23	28	5	288414
2167	1	23	28	4	13418
2168	1	8	13	1	100793
2169	1	8	13	5	283336
2170	1	8	13	4	26531
2171	1	20	29	1	171759
2172	1	20	29	5	193337
2173	1	20	29	4	22832
2174	1	21	29	1	122570
2175	1	21	29	5	250325
2176	1	21	29	4	43542
2177	1	42	12	1	105305
2178	1	42	12	5	189252
2179	1	42	12	4	72600
2180	1	25	12	1	199106
2181	1	25	12	5	155205
2182	1	25	12	4	17127
2183	1	23	30	1	136207
2184	1	23	30	5	190906
2185	1	23	30	4	88738
2186	1	24	30	1	139890
2187	1	24	30	5	158715
2188	1	24	30	4	45206
2189	1	6	12	1	146406
2190	1	6	12	5	239540
2191	1	6	12	4	2356
2192	1	3	12	1	120936
2193	1	3	12	5	169464
2194	1	3	12	4	19096
2195	1	43	11	1	106139
2196	1	43	11	5	268342
2197	1	43	11	4	94128
2198	1	42	11	1	172412
2199	1	42	11	5	124186
2200	1	42	11	4	59349
2201	1	23	31	1	125582
2202	1	23	31	5	250341
2203	1	23	31	4	41440
2204	1	18	32	1	86899
2205	1	18	32	5	172629
2206	1	18	32	4	11384
2207	1	25	32	1	181181
2208	1	25	32	5	155991
2209	1	25	32	4	55131
2210	1	6	11	1	79713
2211	1	6	11	5	263168
2212	1	6	11	4	5283
2213	1	4	11	1	152463
2214	1	4	11	5	123514
2215	1	4	11	4	12725
2216	1	2	11	1	105266
2217	1	2	11	5	254157
2218	1	2	11	4	54318
2219	1	41	10	1	115844
2220	1	41	10	5	120438
2221	1	41	10	4	79129
2222	1	19	33	1	86818
2223	1	19	33	5	203635
2224	1	19	33	4	68661
2225	1	38	10	1	91654
2226	1	38	10	5	149570
2227	1	38	10	4	23229
2228	1	39	33	1	153142
2229	1	39	33	5	112835
2230	1	39	33	4	87750
2231	1	5	34	1	95124
2232	1	5	34	5	188158
2233	1	5	34	4	66875
2234	1	20	34	1	141319
2235	1	20	34	5	192125
2236	1	20	34	4	50314
2237	1	28	34	1	126436
2238	1	28	34	5	288057
2239	1	28	34	4	15470
2240	1	6	10	1	124018
2241	1	6	10	5	210388
2242	1	6	10	4	45734
2243	1	4	10	1	111434
2244	1	4	10	5	221331
2245	1	4	10	4	45147
2246	1	39	34	1	88144
2247	1	39	34	5	280063
2248	1	39	34	4	43708
2249	1	49	9	1	142088
2250	1	49	9	5	232929
2251	1	49	9	4	66608
2252	1	41	9	1	74414
2253	1	41	9	5	121385
2254	1	41	9	4	3693
2255	1	21	35	1	134422
2256	1	21	35	5	242471
2257	1	21	35	4	43019
2258	1	39	9	1	90838
2259	1	39	9	5	257309
2260	1	39	9	4	22179
2261	1	38	9	1	136389
2262	1	38	9	5	209133
2263	1	38	9	4	3694
2264	1	37	35	1	114861
2265	1	37	35	5	102141
2266	1	37	35	4	10953
2267	1	5	36	1	125511
2268	1	5	36	5	144892
2269	1	5	36	4	24986
2270	1	12	36	1	175797
2271	1	12	36	5	168700
2272	1	12	36	4	47341
2273	1	19	36	1	170434
2274	1	19	36	5	149837
2275	1	19	36	4	66533
2276	1	21	36	1	110052
2277	1	21	36	5	275899
2278	1	21	36	4	44221
2279	1	11	9	1	71594
2280	1	11	9	5	147158
2281	1	11	9	4	92664
2282	1	6	9	1	93651
2283	1	6	9	5	226124
2284	1	6	9	4	61732
2285	1	2	9	1	143321
2286	1	2	9	5	277400
2287	1	2	9	4	93470
2288	1	1	9	1	188151
2289	1	1	9	5	137942
2290	1	1	9	4	97857
2291	1	49	8	1	155465
2292	1	49	8	5	279973
2293	1	49	8	4	78691
2294	1	47	8	1	119203
2295	1	47	8	5	174688
2296	1	47	8	4	51897
2297	1	20	37	1	175679
2298	1	20	37	5	195807
2299	1	20	37	4	8460
2300	1	23	37	1	109763
2301	1	23	37	5	101586
2302	1	23	37	4	2280
2303	1	40	8	1	134837
2304	1	40	8	5	273297
2305	1	40	8	4	49210
2306	1	39	8	1	76055
2307	1	39	8	5	285352
2308	1	39	8	4	94982
2309	1	52	37	1	104105
2310	1	52	37	5	244254
2311	1	52	37	4	74332
2312	1	26	8	1	179024
2313	1	26	8	5	107110
2314	1	26	8	4	20540
2315	1	12	38	1	128831
2316	1	12	38	5	183471
2317	1	12	38	4	94376
2318	1	20	38	1	111299
2319	1	20	38	5	182220
2320	1	20	38	4	37572
2321	1	21	38	1	97640
2322	1	21	38	5	232127
2323	1	21	38	4	41988
2324	1	6	8	1	142325
2325	1	6	8	5	171083
2326	1	6	8	4	76972
2327	1	33	38	1	118874
2328	1	33	38	5	107264
2329	1	33	38	4	68243
2330	1	5	8	1	125082
2331	1	5	8	5	185717
2332	1	5	8	4	9773
2333	1	4	8	1	191977
2334	1	4	8	5	210902
2335	1	4	8	4	99789
2336	1	2	8	1	168109
2337	1	2	8	5	141429
2338	1	2	8	4	82403
2339	1	39	38	1	185994
2340	1	39	38	5	295688
2341	1	39	38	4	97350
2342	1	53	38	1	195885
2343	1	53	38	5	102872
2344	1	53	38	4	17436
2345	1	15	39	1	188535
2346	1	15	39	5	113283
2347	1	15	39	4	42612
2348	1	42	7	1	160143
2349	1	42	7	5	206047
2350	1	42	7	4	24066
2351	1	40	7	1	152594
2352	1	40	7	5	132349
2353	1	40	7	4	27129
2354	1	11	40	1	195329
2355	1	11	40	5	205367
2356	1	11	40	4	82102
2357	1	3	7	1	101263
2358	1	3	7	5	248756
2359	1	3	7	4	64905
2360	1	48	6	1	72354
2361	1	48	6	5	131960
2362	1	48	6	4	4185
2363	1	47	6	1	126381
2364	1	47	6	5	293690
2365	1	47	6	4	33170
2366	1	41	6	1	95144
2367	1	41	6	5	104707
2368	1	41	6	4	66598
2369	1	40	6	1	174021
2370	1	40	6	5	284390
2371	1	40	6	4	18724
2372	1	36	41	1	73581
2373	1	36	41	5	133480
2374	1	36	41	4	95907
2375	1	1	42	1	109297
2376	1	1	42	5	297225
2377	1	1	42	4	91020
2378	1	2	42	1	123751
2379	1	2	42	5	195798
2380	1	2	42	4	89004
2381	1	28	6	1	191066
2382	1	28	6	5	263359
2383	1	28	6	4	76635
2384	1	17	42	1	140386
2385	1	17	42	5	247398
2386	1	17	42	4	96276
2387	1	1	43	1	169498
2388	1	1	43	5	132212
2389	1	1	43	4	90045
2390	1	3	43	1	160664
2391	1	3	43	5	272723
2392	1	3	43	4	51764
2393	1	4	43	1	101156
2394	1	4	43	5	235292
2395	1	4	43	4	27334
2396	1	45	5	1	158436
2397	1	45	5	5	287528
2398	1	45	5	4	3387
2399	1	44	5	1	92268
2400	1	44	5	5	111768
2401	1	44	5	4	28363
2402	1	2	44	1	115655
2403	1	2	44	5	278387
2404	1	2	44	4	72695
2405	1	4	44	1	131247
2406	1	4	44	5	133276
2407	1	4	44	4	84545
2408	1	5	44	1	73013
2409	1	5	44	5	204560
2410	1	5	44	4	62464
2412	1	2	5	5	141156
2413	1	2	5	4	99873
2414	1	1	5	1	86168
2415	1	1	5	5	166864
2416	1	1	5	4	39055
2417	1	3	46	1	191546
2418	1	3	46	5	140872
2419	1	3	46	4	87697
2420	1	4	46	1	173072
2421	1	4	46	5	243060
2422	1	4	46	4	37058
2423	1	48	4	1	179278
2424	1	48	4	5	167739
2425	1	48	4	4	97500
2426	1	47	4	1	84711
2427	1	47	4	5	240787
2428	1	47	4	4	88648
2429	1	3	47	1	195761
2430	1	3	47	5	128779
2431	1	3	47	4	37567
2432	1	56	47	1	143512
2433	1	56	47	5	120787
2434	1	56	47	4	36602
2435	1	2	48	1	146222
2436	1	2	48	5	209724
2437	1	2	48	4	39022
2438	1	2	4	1	100654
2439	1	2	4	5	205413
2440	1	2	4	4	97273
2441	1	1	4	1	146089
2442	1	1	4	5	247315
2443	1	1	4	4	88904
2444	1	46	3	1	146268
2445	1	46	3	5	139546
2446	1	46	3	4	55195
2447	1	35	3	1	131739
2448	1	35	3	5	183405
2449	1	35	3	4	65392
2450	1	29	50	1	118200
2451	1	29	50	5	202480
2452	1	29	50	4	92191
2453	1	13	51	1	188093
2454	1	13	51	5	234398
2455	1	13	51	4	78312
2456	1	24	3	1	196436
2457	1	24	3	5	290804
2458	1	24	3	4	8875
2459	1	2	52	1	165527
2460	1	2	52	5	187064
2461	1	2	52	4	53178
2462	1	48	2	1	110973
2463	1	48	2	5	229212
2464	1	48	2	4	97626
2465	1	1	53	1	176668
2466	1	1	53	5	162132
2467	1	1	53	4	42439
2468	1	2	53	1	135684
2469	1	2	53	5	105341
2470	1	2	53	4	53450
2471	1	5	53	1	178442
2472	1	5	53	5	100559
2473	1	5	53	4	53982
2474	1	45	2	1	100335
2475	1	45	2	5	173061
2476	1	45	2	4	46956
2477	1	38	2	1	183575
2478	1	38	2	5	112145
2479	1	38	2	4	72959
2480	1	36	2	1	71046
2481	1	36	2	5	217840
2482	1	36	2	4	58921
2483	1	3	54	1	101040
2484	1	3	54	5	293174
2485	1	3	54	4	84716
2486	1	8	54	1	138253
2487	1	8	54	5	259299
2488	1	8	54	4	10735
2489	1	3	55	1	124723
2490	1	3	55	5	202299
2491	1	3	55	4	63781
2492	1	22	2	1	165253
2493	1	22	2	5	297959
2494	1	22	2	4	29007
2495	1	58	55	1	109163
2496	1	58	55	5	225683
2497	1	58	55	4	17344
2498	1	1	56	1	154304
2499	1	1	56	5	135123
2500	1	1	56	4	36819
2501	1	2	56	1	77006
2502	1	2	56	5	221293
2503	1	2	56	4	95389
2504	1	51	1	1	192921
2505	1	51	1	5	238186
2506	1	51	1	4	38473
2507	1	50	1	1	124512
2508	1	50	1	5	256707
2509	1	50	1	4	31406
2510	1	3	57	1	107552
2511	1	3	57	5	177728
2512	1	3	57	4	27709
2513	1	45	1	1	142356
2514	1	45	1	5	152098
2515	1	45	1	4	32882
2516	1	37	1	1	170287
2517	1	37	1	5	143957
2518	1	37	1	4	66131
2519	1	36	1	1	173369
2520	1	36	1	5	272277
2521	1	36	1	4	49650
2522	1	2	58	1	180326
2523	1	2	58	5	219070
2524	1	2	58	4	51391
2525	1	54	58	1	143479
2526	1	54	58	5	223063
2527	1	54	58	4	30587
2528	1	24	1	1	90966
2529	1	24	1	5	187044
2530	1	24	1	4	28044
2531	1	4	59	1	70697
2532	1	4	59	5	238186
2533	1	4	59	4	82576
2534	1	23	1	1	167824
2535	1	23	1	5	109660
2536	1	23	1	4	17187
2537	1	22	1	1	170692
2538	1	22	1	5	249454
2539	1	22	1	4	88026
2540	1	21	1	1	199905
2541	1	21	1	5	201007
2542	1	21	1	4	90529
2543	1	20	1	1	153257
2544	1	20	1	5	118123
2545	1	20	1	4	98318
2546	1	4	60	1	116798
2547	1	4	60	5	151146
2548	1	4	60	4	43330
2549	1	12	20	1	126245
2550	1	12	20	5	151447
2551	1	12	20	4	91511
2552	1	10	20	1	75044
2553	1	10	20	5	120307
2554	1	10	20	4	53163
2555	1	9	20	1	125269
2556	1	9	20	5	263765
2557	1	9	20	4	19311
2558	1	6	20	1	198188
2559	1	6	20	5	186689
2560	1	6	20	4	58781
2561	1	5	20	1	180553
2562	1	5	20	5	294810
2563	1	5	20	4	27120
2564	1	6	21	1	158130
2565	1	6	21	5	294028
2566	1	6	21	4	20100
2567	1	26	13	1	86023
2568	1	26	13	4	41905
2569	1	26	13	5	271647
2570	1	4	9	1	189601
2571	1	4	9	4	95786
2572	1	4	9	5	276050
2573	1	22	28	1	153549
2574	1	22	28	4	35800
2575	1	22	28	5	137705
2576	1	37	13	1	162461
2577	1	37	13	4	31535
2578	1	37	13	5	290940
2579	1	14	39	1	178901
2580	1	14	39	4	58651
2581	1	14	39	5	239050
2582	1	1	7	1	199526
2583	1	1	7	4	17650
2584	1	1	7	5	217019
2585	1	59	27	1	169908
2586	1	59	27	4	81179
2587	1	59	27	5	224042
2588	1	1	14	1	167864
2589	1	1	14	4	2818
2590	1	1	14	5	176322
2591	1	12	39	1	92929
2592	1	12	39	4	70422
2593	1	12	39	5	118650
2594	1	11	39	1	72887
2595	1	11	39	4	90985
2596	1	11	39	5	128616
2597	1	6	22	1	110394
2598	1	6	22	4	2586
2599	1	6	22	5	258128
2600	1	7	14	1	198919
2601	1	7	14	4	81854
2602	1	7	14	5	154579
2603	1	9	19	1	95760
2604	1	9	19	4	66904
2605	1	9	19	5	273049
2606	1	1	41	1	103049
2607	1	1	41	4	96590
2608	1	1	41	5	248128
2609	1	21	26	1	162638
2610	1	21	26	4	20772
2611	1	21	26	5	141286
2612	1	22	26	1	184714
2613	1	22	26	4	31775
2614	1	22	26	5	158036
2615	1	48	7	1	110968
2616	1	48	7	4	7685
2617	1	48	7	5	147220
2618	1	43	14	1	110053
2619	1	43	14	4	9484
2620	1	43	14	5	216579
2621	1	4	15	1	120329
2622	1	4	15	4	38373
2623	1	4	15	5	248123
2624	1	5	27	1	189207
2625	1	5	27	4	14452
2626	1	5	27	5	297745
2627	1	5	19	1	167576
2628	1	5	19	4	50109
2629	1	5	19	5	219873
2630	1	44	15	1	98359
2631	1	44	15	4	36186
2632	1	44	15	5	208646
2633	1	3	58	1	109192
2634	1	3	58	4	32068
2635	1	3	58	5	194579
2636	1	4	58	1	164371
2637	1	4	58	4	40812
2638	1	4	58	5	156115
2639	1	38	6	1	164218
2640	1	38	6	4	8615
2641	1	38	6	5	175612
2642	1	27	9	1	105386
2643	1	27	9	4	5226
2644	1	27	9	5	288381
2645	1	59	24	1	170448
2646	1	59	24	4	3465
2647	1	59	24	5	197045
2648	1	38	35	1	130475
2649	1	38	35	4	63328
2650	1	38	35	5	293939
2651	1	29	42	1	172543
2652	1	29	42	4	98913
2653	1	29	42	5	245880
2654	1	11	6	1	156021
2655	1	11	6	4	40464
2656	1	11	6	5	256208
2657	1	40	9	1	189566
2658	1	40	9	4	66537
2659	1	40	9	5	290137
2660	1	1	6	1	163360
2661	1	1	6	4	11103
2662	1	1	6	5	211618
2663	1	20	35	1	93560
2664	1	20	35	4	63922
2665	1	20	35	5	116492
2666	1	1	60	1	126090
2667	1	1	60	4	72903
2668	1	1	60	5	125554
2669	1	11	35	1	81162
2670	1	11	35	4	40821
2671	1	11	35	5	116535
2672	1	2	60	1	95144
2673	1	2	60	4	79916
2674	1	2	60	5	223935
2675	1	3	60	1	184159
2676	1	3	60	4	10537
2677	1	3	60	5	276895
2678	1	1	8	1	132135
2679	1	1	8	4	19619
2680	1	1	8	5	222158
2681	1	5	35	1	70538
2682	1	5	35	4	21254
2683	1	5	35	5	147852
2684	1	38	37	1	195834
2685	1	38	37	4	26502
2686	1	38	37	5	242199
2687	1	14	38	1	151396
2688	1	14	38	4	2495
2689	1	14	38	5	153851
2690	1	48	5	1	183633
2691	1	48	5	4	975
2692	1	48	5	5	177728
2693	1	39	37	1	153362
2694	1	39	37	4	49705
2695	1	39	37	5	229654
2696	1	6	60	1	139775
2697	1	6	60	4	82528
2698	1	6	60	5	244699
2699	1	12	37	1	199638
2700	1	12	37	4	12143
2701	1	12	37	5	244669
2702	1	39	5	1	113930
2703	1	39	5	4	40412
2704	1	39	5	5	260884
2705	1	38	44	1	155818
2706	1	38	44	4	27193
2707	1	38	44	5	239977
2708	1	6	34	1	146758
2709	1	6	34	4	91073
2710	1	6	34	5	139277
2711	1	26	10	1	130089
2712	1	26	10	4	53896
2713	1	26	10	5	249417
2714	1	60	23	1	103944
2715	1	60	23	4	22372
2716	1	60	23	5	106009
2717	1	6	46	1	74231
2718	1	6	46	4	16456
2719	1	6	46	5	290322
2720	1	38	33	1	159084
2721	1	38	33	4	53035
2722	1	38	33	5	269446
2723	1	45	4	1	126421
2724	1	45	4	4	41668
2725	1	45	4	5	269883
2726	1	2	40	1	146411
2727	1	2	40	4	46395
2728	1	2	40	5	294061
2729	1	42	8	1	158874
2730	1	42	8	4	24568
2731	1	42	8	5	200734
2732	1	42	10	1	146727
2733	1	42	10	4	84157
2734	1	42	10	5	157393
2735	1	43	10	1	137567
2736	1	43	10	4	49342
2737	1	43	10	5	141391
2738	1	2	47	1	90911
2739	1	2	47	4	10365
2740	1	2	47	5	205925
2741	1	5	47	1	94917
2742	1	5	47	4	53760
2743	1	5	47	5	226983
2744	1	39	4	1	148132
2745	1	39	4	4	49938
2746	1	39	4	5	162353
2747	1	4	48	1	88780
2748	1	4	48	4	39216
2749	1	4	48	5	286581
2750	1	5	48	1	151192
2751	1	5	48	4	88061
2752	1	5	48	5	123353
2753	1	24	4	1	86988
2754	1	24	4	4	63992
2755	1	24	4	5	225117
2756	1	2	59	1	133541
2757	1	2	59	4	42807
2758	1	2	59	5	109553
2759	1	55	48	1	176021
2760	1	55	48	4	39849
2761	1	55	48	5	168862
2762	1	23	32	1	97972
2763	1	23	32	4	95497
2764	1	23	32	5	104361
2765	1	19	32	1	129328
2766	1	19	32	4	90225
2767	1	19	32	5	177984
2768	1	32	39	1	120408
2769	1	32	39	4	53152
2770	1	32	39	5	173395
2771	1	3	49	1	165463
2772	1	3	49	4	50326
2773	1	3	49	5	115079
2774	1	10	32	1	139642
2775	1	10	32	4	88946
2776	1	10	32	5	147616
2777	1	6	49	1	99920
2778	1	6	49	4	54714
2779	1	6	49	5	151742
2780	1	52	3	1	96819
2781	1	52	3	4	68186
2782	1	52	3	5	255550
2783	1	48	3	1	135832
2784	1	48	3	4	88155
2785	1	48	3	5	231830
2786	1	33	37	1	135456
2787	1	33	37	4	62226
2788	1	33	37	5	190605
2789	1	47	3	1	158723
2790	1	47	3	4	79730
2791	1	47	3	5	284308
2792	1	2	50	1	198189
2793	1	2	50	4	29804
2794	1	2	50	5	276847
2795	1	3	50	1	122427
2796	1	3	50	4	15024
2797	1	3	50	5	240696
2798	1	48	31	1	180925
2799	1	48	31	4	82278
2800	1	48	31	5	260799
2801	1	1	51	1	83315
2802	1	1	51	4	33653
2803	1	1	51	5	108795
2804	1	4	52	1	172648
2805	1	4	52	4	47990
2806	1	4	52	5	211681
2807	1	31	37	1	81561
2808	1	31	37	4	40556
2809	1	31	37	5	197772
2810	1	25	1	1	178208
2811	1	25	1	4	87891
2812	1	25	1	5	125166
2813	1	4	12	1	192150
2814	1	4	12	4	36217
2815	1	4	12	5	282629
2816	1	7	18	1	145742
2817	1	7	18	4	13487
2818	1	7	18	5	141331
2819	1	3	24	1	151596
2820	1	3	24	4	7743
2821	1	3	24	5	298943
2822	1	46	2	1	106801
2823	1	46	2	4	45605
2824	1	46	2	5	183061
2825	1	7	12	1	77350
2826	1	7	12	4	1678
2827	1	7	12	5	223432
2828	1	8	12	1	197228
2829	1	8	12	4	8092
2830	1	8	12	5	115612
2831	1	39	2	1	94025
2832	1	39	2	4	17438
2833	1	39	2	5	163640
2834	1	20	7	1	120774
2835	1	20	7	4	68470
2836	1	20	7	5	284435
2837	1	18	37	1	175966
2838	1	18	37	4	72246
2839	1	18	37	5	124234
2840	1	7	16	1	90265
2841	1	7	16	4	67976
2842	1	7	16	5	254962
2843	1	35	2	1	151530
2844	1	35	2	4	86009
2845	1	35	2	5	203192
2846	1	1	55	1	164900
2847	1	1	55	4	20361
2848	1	1	55	5	253601
2849	1	15	40	1	195284
2850	1	15	40	4	60781
2851	1	15	40	5	274820
2852	1	23	2	1	153582
2853	1	23	2	4	82503
2854	1	23	2	5	243512
2855	1	4	20	1	185265
2856	1	4	20	4	11666
2857	1	4	20	5	260242
2858	1	3	20	1	165622
2859	1	3	20	4	91752
2860	1	3	20	5	189413
2861	1	24	12	1	199914
2862	1	24	12	4	59226
2863	1	24	12	5	222164
2864	1	26	12	1	113986
2865	1	26	12	4	76877
2866	1	26	12	5	139127
2867	1	33	12	1	81074
2868	1	33	12	4	65242
2869	1	33	12	5	252977
2870	1	49	1	1	162936
2871	1	49	1	4	73352
2872	1	49	1	5	159856
2873	1	20	23	1	161272
2874	1	20	23	4	82595
2875	1	20	23	5	266367
2876	1	2	57	1	93679
2877	1	2	57	4	52402
2878	1	2	57	5	105944
2879	1	9	18	1	126888
2880	1	9	18	4	85043
2881	1	9	18	5	287113
2882	1	4	57	1	168650
2883	1	4	57	4	74118
2884	1	4	57	5	273794
2885	1	23	29	1	175017
2886	1	23	29	4	4367
2887	1	23	29	5	105769
2888	1	49	58	1	124729
2889	1	49	58	4	73835
2890	1	49	58	5	189334
2891	1	39	1	1	133336
2892	1	39	1	4	23074
2893	1	39	1	5	270533
2894	1	35	1	1	124282
2895	1	35	1	4	99570
2896	1	35	1	5	106778
2897	1	2	13	1	76284
2898	1	2	13	4	84065
2899	1	2	13	5	150723
2900	1	5	13	1	113598
2901	1	5	13	4	94596
2902	1	5	13	5	223603
2903	1	7	13	1	141484
2904	1	7	13	4	8043
2905	1	7	13	5	206131
2906	1	4	7	1	191227
2907	1	4	7	4	54902
2908	1	4	7	5	212207
2909	1	3	9	1	77394
2910	1	3	9	4	74343
2911	1	3	9	5	284157
2912	1	28	21	4	70914
2913	1	28	21	6	71830
2914	1	18	30	4	148802
2915	1	18	30	6	85559
2916	1	49	2	4	53508
2917	1	49	2	6	110871
2918	1	53	23	4	98774
2919	1	53	23	6	82469
2920	1	15	47	4	50617
2921	1	15	47	6	98021
2922	1	17	14	4	104432
2923	1	17	14	6	72694
2924	1	28	10	4	75249
2925	1	28	10	6	72697
2926	1	55	15	4	100394
2927	1	55	15	6	63838
2928	1	22	24	4	79953
2929	1	22	24	6	107366
2930	1	24	9	4	80149
2931	1	24	9	6	59694
2932	1	9	43	4	65122
2933	1	9	43	6	111710
2934	1	19	31	4	70104
2935	1	19	31	6	123278
2936	1	40	19	4	140694
2937	1	40	19	6	147842
2938	1	41	53	4	87876
2939	1	41	53	6	127949
2940	1	20	43	4	76461
2941	1	20	43	6	125423
2942	1	22	9	4	55255
2943	1	22	9	6	143340
2944	1	16	20	4	75753
2945	1	16	20	6	55225
2946	1	22	19	4	74581
2947	1	22	19	6	148013
2948	1	50	35	4	133630
2949	1	50	35	6	90812
2950	1	19	6	4	113108
2951	1	19	6	6	71364
2952	1	17	18	4	63507
2953	1	17	18	6	82862
2954	1	19	21	4	114027
2955	1	19	21	6	93053
2956	1	7	45	4	66187
2957	1	7	45	6	74568
2958	1	23	10	4	83708
2959	1	23	10	6	75145
2960	1	27	22	4	129308
2961	1	27	22	6	137347
2962	1	49	35	4	71345
2963	1	49	35	6	109549
2964	1	20	6	4	147359
2965	1	20	6	6	131863
2966	1	15	44	4	144371
2967	1	15	44	6	112475
2968	1	21	4	4	82129
2969	1	21	4	6	81899
2970	1	17	19	4	146411
2971	1	17	19	6	94822
2972	1	18	13	4	70726
2973	1	18	13	6	70608
2974	1	25	38	4	85372
2975	1	25	38	6	127323
2976	1	18	16	4	130010
2977	1	18	16	6	76176
2978	1	22	8	4	94279
2979	1	22	8	6	118010
2980	1	20	20	4	77126
2981	1	20	20	6	116588
2982	1	28	22	4	52822
2983	1	28	22	6	139706
2984	1	27	21	4	88302
2985	1	27	21	6	125140
2986	1	27	23	4	144022
2987	1	27	23	6	95097
2988	1	40	29	4	101001
2989	1	40	29	6	70049
2990	1	5	49	4	141887
2991	1	5	49	6	127873
2992	1	58	26	4	101604
2993	1	58	26	6	114715
2994	1	28	18	4	117224
2995	1	28	18	6	141776
2996	1	24	8	4	64721
2997	1	24	8	6	78227
2998	1	25	9	4	144582
2999	1	25	9	6	96445
3000	1	60	9	4	89137
3001	1	60	9	6	110954
3002	1	21	16	4	85501
3003	1	21	16	6	135239
3004	1	23	9	4	142683
3005	1	23	9	6	88826
3006	1	43	16	4	132361
3007	1	43	16	6	124808
3008	1	27	20	4	131863
3009	1	27	20	6	77140
3010	1	22	3	4	100773
3011	1	22	3	6	146990
3012	1	28	23	4	105637
3013	1	28	23	6	107770
3014	1	19	19	4	55729
3015	1	19	19	6	70458
3016	1	22	18	4	149771
3017	1	22	18	6	111832
3018	1	17	21	4	116511
3019	1	17	21	6	136237
3020	1	16	6	4	53241
3021	1	16	6	6	144018
3022	1	18	19	4	130580
3023	1	18	19	6	81228
3024	1	44	2	4	89530
3025	1	44	2	6	56386
3026	1	10	28	4	60630
3027	1	10	28	6	63063
3028	1	19	37	4	138678
3029	1	19	37	6	76164
3030	1	58	8	4	120544
3031	1	58	8	6	127223
3032	1	21	23	4	141385
3033	1	21	23	6	52951
3034	1	20	18	4	81189
3035	1	20	18	6	60701
3036	1	35	20	4	110280
3037	1	35	20	6	138023
3038	1	22	23	4	93873
3039	1	22	23	6	83871
3040	1	21	8	4	92710
3041	1	21	8	6	84363
3042	1	23	23	4	109400
3043	1	23	23	6	86964
3044	1	25	37	4	107036
3045	1	25	37	6	110327
3046	1	19	17	4	68933
3047	1	19	17	6	109655
3048	1	17	15	4	71908
3049	1	17	15	6	145220
3050	1	16	12	4	63943
3051	1	16	12	6	115342
3052	1	20	5	4	97041
3053	1	20	5	6	82947
3054	1	21	5	4	67059
3055	1	21	5	6	91548
3056	1	16	13	4	61796
3057	1	16	13	6	127728
3058	1	16	19	4	116115
3059	1	16	19	6	147114
3060	1	18	14	4	102851
3061	1	18	14	6	108379
3062	1	29	22	4	87998
3063	1	29	22	6	95973
3064	1	29	16	4	59601
3065	1	29	16	6	68444
3066	1	13	36	4	76758
3067	1	13	36	6	56650
3068	1	19	20	4	145148
3069	1	19	20	6	111849
3070	1	17	17	4	54368
3071	1	17	17	6	107817
3072	1	25	13	4	52891
3073	1	25	13	6	95796
3074	1	32	5	4	52939
3075	1	32	5	6	116067
3076	1	21	17	4	116962
3077	1	21	17	6	131654
3078	1	20	22	4	77033
3079	1	20	22	6	55488
3080	1	21	21	4	132238
3081	1	21	21	6	122016
3082	1	21	22	4	50681
3083	1	21	22	6	146790
3084	1	7	41	4	59150
3085	1	7	41	6	61609
3086	1	19	16	4	62577
3087	1	19	16	6	96346
3088	1	29	20	4	142397
3089	1	29	20	6	65588
3090	1	18	20	4	64220
3091	1	18	20	6	103258
3092	1	18	15	4	61747
3093	1	18	15	6	95763
3094	1	54	48	4	68466
3095	1	54	48	6	136792
3096	1	11	11	4	53013
3097	1	11	11	6	94087
3098	1	20	19	4	145562
3099	1	20	19	6	118229
3100	1	28	20	4	104593
3101	1	28	20	6	102063
3102	1	26	39	4	147964
3103	1	26	39	6	65118
3104	1	22	4	4	100615
3105	1	22	4	6	94676
3106	1	23	7	4	146972
3107	1	23	7	6	146322
3108	1	21	9	4	97584
3109	1	21	9	6	68539
3110	1	23	8	4	143675
3111	1	23	8	6	90889
3112	1	6	36	4	107412
3113	1	6	36	6	89660
3114	1	20	21	4	99659
3115	1	20	21	6	118207
3116	1	21	6	4	135139
3117	1	21	6	6	90272
3118	1	20	16	4	125635
3119	1	20	16	6	138749
573	1	6	3	6	30501
571	1	6	3	4	30194
2411	1	2	5	1	107072
1038	1	5	2	1	370192
1754	1	9	6	6	85615
1850	1	8	5	6	81439
1573	1	9	9	5	53169
1571	1	9	9	6	119163
1306	1	4	5	1	441320
\.


--
-- TOC entry 5668 (class 0 OID 271592)
-- Dependencies: 322
-- Data for Name: map_tiles_resources_spawn; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_resources_spawn (id, terrain_type_id, landscape_type_id, item_id, min_quantity, max_quantity, spawn_chance) FROM stdin;
1	1	\N	1	1000	100000	1
2	1	1	4	1000	100000	1
7	2	\N	1	60000	600000	1
10	2	1	4	100000	300000	1
13	1	9	1	200000	500000	1
14	1	9	5	40000	120000	1
15	3	\N	1	70000	200000	1
16	3	\N	4	1	100000	1
17	3	2	1	70000	200000	1
18	3	2	4	1	100000	1
19	3	2	5	100000	300000	1
20	3	3	1	70000	200000	1
21	3	3	4	1	100000	1
22	3	3	5	100000	300000	1
23	4	\N	5	1	100000	1
25	5	\N	6	50000	150000	1
26	5	8	4	50000	150000	1
27	5	8	6	50000	150000	1
28	5	6	4	50000	150000	1
29	5	6	6	50000	150000	1
6	1	1	5	1000	70000	1
8	2	\N	6	1000	150000	1
9	2	\N	5	1000	50000	1
12	2	1	5	1000	70000	1
4	1	\N	6	1000	100000	1
5	1	\N	5	1000	50000	1
3	1	1	6	1000	100000	1
11	2	1	6	50000	150000	1
30	5	\N	4	50000	150000	1
24	6	\N	1	50000	400000	1
\.


--
-- TOC entry 5679 (class 0 OID 484686)
-- Dependencies: 333
-- Data for Name: map_tiles_squads_positions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_squads_positions (squad_id, map_id, map_tile_x, map_tile_y) FROM stdin;
32	1	4	5
\.


--
-- TOC entry 5648 (class 0 OID 22822)
-- Dependencies: 300
-- Data for Name: maps; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.maps (id, name) FROM stdin;
1	NowaMapa
\.


--
-- TOC entry 5650 (class 0 OID 22828)
-- Dependencies: 302
-- Data for Name: region_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.region_types (id, name) FROM stdin;
2	River
3	Sea
1	Province
\.


--
-- TOC entry 5597 (class 0 OID 22621)
-- Dependencies: 249
-- Data for Name: terrain_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.terrain_types (id, name, move_cost, image_url) FROM stdin;
1	Plains	1	plains.png
2	Grasslands	1	grasslands.png
3	Shrubland	1	shrubland.png
7	Jungle	4	jungle.png
8	Sea	99	sea.png
9	River	99	river.png
4	Desert	4	desert.png
6	Savannah	1	savannah.png
5	Marsh	4	marsh.png
\.


--
-- TOC entry 5771 (class 0 OID 0)
-- Dependencies: 250
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.abilities_id_seq', 3, true);


--
-- TOC entry 5772 (class 0 OID 0)
-- Dependencies: 253
-- Name: player_abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_abilities_id_seq', 10, true);


--
-- TOC entry 5773 (class 0 OID 0)
-- Dependencies: 255
-- Name: player_skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_skills_id_seq', 30, true);


--
-- TOC entry 5774 (class 0 OID 0)
-- Dependencies: 257
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_stats_id_seq', 45, true);


--
-- TOC entry 5775 (class 0 OID 0)
-- Dependencies: 258
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.roles_id_seq', 1, false);


--
-- TOC entry 5776 (class 0 OID 0)
-- Dependencies: 259
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.skills_id_seq', 6, true);


--
-- TOC entry 5777 (class 0 OID 0)
-- Dependencies: 260
-- Name: stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.stats_id_seq', 9, true);


--
-- TOC entry 5778 (class 0 OID 0)
-- Dependencies: 262
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.accounts_id_seq', 1, false);


--
-- TOC entry 5779 (class 0 OID 0)
-- Dependencies: 264
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.sessions_id_seq', 1, false);


--
-- TOC entry 5780 (class 0 OID 0)
-- Dependencies: 266
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_id_seq', 4, true);


--
-- TOC entry 5781 (class 0 OID 0)
-- Dependencies: 269
-- Name: building_types_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.building_types_id_seq', 1, false);


--
-- TOC entry 5782 (class 0 OID 0)
-- Dependencies: 270
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.buildings_id_seq', 1, false);


--
-- TOC entry 5783 (class 0 OID 0)
-- Dependencies: 271
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: cities; Owner: postgres
--

SELECT pg_catalog.setval('cities.cities_id_seq', 1, false);


--
-- TOC entry 5784 (class 0 OID 0)
-- Dependencies: 274
-- Name: district_types_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.district_types_id_seq', 1, false);


--
-- TOC entry 5785 (class 0 OID 0)
-- Dependencies: 275
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.districts_id_seq', 1, false);


--
-- TOC entry 5786 (class 0 OID 0)
-- Dependencies: 277
-- Name: inventory_container_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_container_types_id_seq', 4, true);


--
-- TOC entry 5787 (class 0 OID 0)
-- Dependencies: 279
-- Name: inventory_containers_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_containers_id_seq', 10, true);


--
-- TOC entry 5788 (class 0 OID 0)
-- Dependencies: 281
-- Name: inventory_slot_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slot_types_id_seq', 14, true);


--
-- TOC entry 5789 (class 0 OID 0)
-- Dependencies: 283
-- Name: inventory_slots_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slots_id_seq', 110, true);


--
-- TOC entry 5790 (class 0 OID 0)
-- Dependencies: 284
-- Name: item_stats_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_stats_id_seq', 1, false);


--
-- TOC entry 5791 (class 0 OID 0)
-- Dependencies: 286
-- Name: item_types_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_types_id_seq', 10, true);


--
-- TOC entry 5792 (class 0 OID 0)
-- Dependencies: 287
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.items_id_seq', 8, true);


--
-- TOC entry 5793 (class 0 OID 0)
-- Dependencies: 325
-- Name: recipe_materials_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.recipe_materials_id_seq', 4, true);


--
-- TOC entry 5794 (class 0 OID 0)
-- Dependencies: 323
-- Name: recipes_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.recipes_id_seq', 2, true);


--
-- TOC entry 5795 (class 0 OID 0)
-- Dependencies: 290
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.players_id_seq', 5, true);


--
-- TOC entry 5796 (class 0 OID 0)
-- Dependencies: 329
-- Name: squad_invites_id_seq; Type: SEQUENCE SET; Schema: squad; Owner: postgres
--

SELECT pg_catalog.setval('squad.squad_invites_id_seq', 22, true);


--
-- TOC entry 5797 (class 0 OID 0)
-- Dependencies: 331
-- Name: squad_invites_statuses_id_seq; Type: SEQUENCE SET; Schema: squad; Owner: postgres
--

SELECT pg_catalog.setval('squad.squad_invites_statuses_id_seq', 4, true);


--
-- TOC entry 5798 (class 0 OID 0)
-- Dependencies: 327
-- Name: squad_roles_id_seq; Type: SEQUENCE SET; Schema: squad; Owner: postgres
--

SELECT pg_catalog.setval('squad.squad_roles_id_seq', 2, true);


--
-- TOC entry 5799 (class 0 OID 0)
-- Dependencies: 315
-- Name: squads_id_seq; Type: SEQUENCE SET; Schema: squad; Owner: postgres
--

SELECT pg_catalog.setval('squad.squads_id_seq', 34, true);


--
-- TOC entry 5800 (class 0 OID 0)
-- Dependencies: 292
-- Name: status_types_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.status_types_id_seq', 1, false);


--
-- TOC entry 5801 (class 0 OID 0)
-- Dependencies: 294
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.tasks_id_seq', 1, false);


--
-- TOC entry 5802 (class 0 OID 0)
-- Dependencies: 295
-- Name: landscape_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.landscape_types_id_seq', 1, false);


--
-- TOC entry 5803 (class 0 OID 0)
-- Dependencies: 297
-- Name: map_regions_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_regions_id_seq', 344, true);


--
-- TOC entry 5804 (class 0 OID 0)
-- Dependencies: 318
-- Name: map_tiles_resources_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_tiles_resources_id_seq', 3119, true);


--
-- TOC entry 5805 (class 0 OID 0)
-- Dependencies: 321
-- Name: map_tiles_resources_spawn_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_tiles_resources_spawn_id_seq', 30, true);


--
-- TOC entry 5806 (class 0 OID 0)
-- Dependencies: 301
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.maps_id_seq', 1, true);


--
-- TOC entry 5807 (class 0 OID 0)
-- Dependencies: 303
-- Name: region_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.region_types_id_seq', 3, true);


--
-- TOC entry 5808 (class 0 OID 0)
-- Dependencies: 304
-- Name: terrain_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.terrain_types_id_seq', 3, true);


--
-- TOC entry 5230 (class 2606 OID 22844)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5265 (class 2606 OID 22846)
-- Name: ability_skill_requirements ability_skill_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_pkey PRIMARY KEY (ability_id, skill_id);


--
-- TOC entry 5267 (class 2606 OID 22848)
-- Name: ability_stat_requirements ability_stat_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_pkey PRIMARY KEY (ability_id, stat_id);


--
-- TOC entry 5232 (class 2606 OID 22850)
-- Name: player_abilities player_abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5269 (class 2606 OID 22852)
-- Name: player_skills player_skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5271 (class 2606 OID 22854)
-- Name: player_stats player_stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5234 (class 2606 OID 22856)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5236 (class 2606 OID 22858)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5238 (class 2606 OID 22860)
-- Name: stats stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5273 (class 2606 OID 22862)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 5275 (class 2606 OID 22864)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5277 (class 2606 OID 22866)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5279 (class 2606 OID 22868)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5281 (class 2606 OID 22870)
-- Name: verification_token verification_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.verification_token
    ADD CONSTRAINT verification_token_pkey PRIMARY KEY (identifier, token);


--
-- TOC entry 5283 (class 2606 OID 22872)
-- Name: building_roles building_owners_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_owners_pkey PRIMARY KEY (building_id, player_id, role_id);


--
-- TOC entry 5240 (class 2606 OID 22874)
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5242 (class 2606 OID 22876)
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- TOC entry 5244 (class 2606 OID 22878)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 5285 (class 2606 OID 22880)
-- Name: city_roles city_owners_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_roles
    ADD CONSTRAINT city_owners_pkey PRIMARY KEY (city_id, player_id, role_id);


--
-- TOC entry 5247 (class 2606 OID 22882)
-- Name: city_tiles city_tiles_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_tiles
    ADD CONSTRAINT city_tiles_pkey PRIMARY KEY (city_id, x, y);


--
-- TOC entry 5287 (class 2606 OID 22884)
-- Name: district_roles district_owners_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_owners_pkey PRIMARY KEY (district_id, player_id, role_id);


--
-- TOC entry 5249 (class 2606 OID 22886)
-- Name: district_types district_types_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_types
    ADD CONSTRAINT district_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5251 (class 2606 OID 22888)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 5322 (class 2606 OID 288321)
-- Name: inventory_container_player_access inventory_container_player_access_unique; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_player_access
    ADD CONSTRAINT inventory_container_player_access_unique UNIQUE (inventory_container_id, player_id);


--
-- TOC entry 5289 (class 2606 OID 22890)
-- Name: inventory_container_types inventory_container_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_types
    ADD CONSTRAINT inventory_container_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5291 (class 2606 OID 22892)
-- Name: inventory_containers inventory_containers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_pkey PRIMARY KEY (id);


--
-- TOC entry 5253 (class 2606 OID 22894)
-- Name: inventory_slot_types inventory_slot_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_types
    ADD CONSTRAINT inventory_slot_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5293 (class 2606 OID 22896)
-- Name: inventory_slots inventory_slots_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 5255 (class 2606 OID 22898)
-- Name: item_stats item_stats_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5295 (class 2606 OID 22900)
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5257 (class 2606 OID 22902)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 5342 (class 2606 OID 353523)
-- Name: recipe_materials recipe_materials_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipe_materials
    ADD CONSTRAINT recipe_materials_pkey PRIMARY KEY (id);


--
-- TOC entry 5340 (class 2606 OID 353505)
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- TOC entry 5316 (class 2606 OID 25562)
-- Name: known_map_tiles known_map_tiles_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_pk PRIMARY KEY (player_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5328 (class 2606 OID 25558)
-- Name: known_players_abilities known_players_abilities_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5320 (class 2606 OID 25556)
-- Name: known_players_containers known_players_containers_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_pk PRIMARY KEY (player_id, container_id);


--
-- TOC entry 5297 (class 2606 OID 25554)
-- Name: known_players_positions known_players_positions_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5318 (class 2606 OID 25552)
-- Name: known_players_profiles known_players_profiles_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5326 (class 2606 OID 25550)
-- Name: known_players_skills known_players_skills_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5324 (class 2606 OID 25548)
-- Name: known_players_stats known_players_stats_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5300 (class 2606 OID 22904)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 5346 (class 2606 OID 476420)
-- Name: squad_invites squad_invites_pkey; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites
    ADD CONSTRAINT squad_invites_pkey PRIMARY KEY (id);


--
-- TOC entry 5349 (class 2606 OID 476466)
-- Name: squad_invites_statuses squad_invites_statuses_pkey; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites_statuses
    ADD CONSTRAINT squad_invites_statuses_pkey PRIMARY KEY (id);


--
-- TOC entry 5330 (class 2606 OID 25573)
-- Name: squad_players squad_players_pkey; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_pkey PRIMARY KEY (squad_id, player_id);


--
-- TOC entry 5344 (class 2606 OID 476387)
-- Name: squad_roles squad_roles_pk; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_roles
    ADD CONSTRAINT squad_roles_pk PRIMARY KEY (id);


--
-- TOC entry 5332 (class 2606 OID 25580)
-- Name: squads squads_pk; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squads
    ADD CONSTRAINT squads_pk PRIMARY KEY (id);


--
-- TOC entry 5302 (class 2606 OID 22906)
-- Name: status_types status_types_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types
    ADD CONSTRAINT status_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5304 (class 2606 OID 22908)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 5259 (class 2606 OID 22910)
-- Name: landscape_types landscape_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.landscape_types
    ADD CONSTRAINT landscape_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5306 (class 2606 OID 22912)
-- Name: map_regions map_regions_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_regions
    ADD CONSTRAINT map_regions_pkey PRIMARY KEY (id);


--
-- TOC entry 5308 (class 2606 OID 25566)
-- Name: map_tiles_map_regions map_tiles_map_regions_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_pk PRIMARY KEY (region_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5261 (class 2606 OID 22914)
-- Name: map_tiles map_tiles_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_pkey PRIMARY KEY (map_id, x, y);


--
-- TOC entry 5310 (class 2606 OID 25564)
-- Name: map_tiles_players_positions map_tiles_players_positions_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_pk PRIMARY KEY (player_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5334 (class 2606 OID 25642)
-- Name: map_tiles_resources map_tiles_resources_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_pk PRIMARY KEY (id);


--
-- TOC entry 5336 (class 2606 OID 271606)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_pkey PRIMARY KEY (id);


--
-- TOC entry 5338 (class 2606 OID 271608)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_terrain_type_id_landscape_type_id_key; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_terrain_type_id_landscape_type_id_key UNIQUE (terrain_type_id, landscape_type_id, item_id);


--
-- TOC entry 5351 (class 2606 OID 484694)
-- Name: map_tiles_squads_positions map_tiles_squads_positions_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_squads_positions
    ADD CONSTRAINT map_tiles_squads_positions_pk PRIMARY KEY (squad_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5312 (class 2606 OID 22918)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- TOC entry 5314 (class 2606 OID 22920)
-- Name: region_types region_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.region_types
    ADD CONSTRAINT region_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5263 (class 2606 OID 22922)
-- Name: terrain_types terrain_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.terrain_types
    ADD CONSTRAINT terrain_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5245 (class 1259 OID 22923)
-- Name: unique_city_position; Type: INDEX; Schema: cities; Owner: postgres
--

CREATE UNIQUE INDEX unique_city_position ON cities.cities USING btree (map_tile_x, map_tile_y);


--
-- TOC entry 5298 (class 1259 OID 22924)
-- Name: one_active_player_per_user; Type: INDEX; Schema: players; Owner: postgres
--

CREATE UNIQUE INDEX one_active_player_per_user ON players.players USING btree (user_id) WHERE (is_active = true);


--
-- TOC entry 5347 (class 1259 OID 484672)
-- Name: squad_invites_unique_active; Type: INDEX; Schema: squad; Owner: postgres
--

CREATE UNIQUE INDEX squad_invites_unique_active ON squad.squad_invites USING btree (squad_id, invited_player_id) WHERE (status = ANY (ARRAY[1, 2]));


--
-- TOC entry 5368 (class 2606 OID 22925)
-- Name: ability_skill_requirements ability_skill_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5369 (class 2606 OID 22930)
-- Name: ability_skill_requirements ability_skill_requirements_skill_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5370 (class 2606 OID 22935)
-- Name: ability_stat_requirements ability_stat_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5371 (class 2606 OID 22940)
-- Name: ability_stat_requirements ability_stat_requirements_stat_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_stat_id_fkey FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5352 (class 2606 OID 22945)
-- Name: player_abilities player_abilities_abilities_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_abilities_fk FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5353 (class 2606 OID 22950)
-- Name: player_abilities player_abilities_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5372 (class 2606 OID 22955)
-- Name: player_skills player_skills_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5373 (class 2606 OID 22960)
-- Name: player_skills player_skills_skills_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_skills_fk FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5374 (class 2606 OID 22965)
-- Name: player_stats player_stats_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5375 (class 2606 OID 22970)
-- Name: player_stats player_stats_stats_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5376 (class 2606 OID 22975)
-- Name: accounts accounts_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_users_fk FOREIGN KEY ("userId") REFERENCES auth.users(id);


--
-- TOC entry 5377 (class 2606 OID 22980)
-- Name: sessions sessions_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_users_fk FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- TOC entry 5378 (class 2606 OID 22985)
-- Name: building_roles building_roles_buildings_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_buildings_fk FOREIGN KEY (building_id) REFERENCES buildings.buildings(id);


--
-- TOC entry 5379 (class 2606 OID 22990)
-- Name: building_roles building_roles_players_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5380 (class 2606 OID 22995)
-- Name: building_roles building_roles_roles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5354 (class 2606 OID 23000)
-- Name: buildings buildings_building_types_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_building_types_fk FOREIGN KEY (building_type_id) REFERENCES buildings.building_types(id);


--
-- TOC entry 5355 (class 2606 OID 23005)
-- Name: buildings buildings_cities_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_cities_fk FOREIGN KEY (city_id) REFERENCES cities.cities(id);


--
-- TOC entry 5356 (class 2606 OID 23010)
-- Name: buildings buildings_city_tiles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_city_tiles_fk FOREIGN KEY (city_id, city_tile_x, city_tile_y) REFERENCES cities.city_tiles(city_id, x, y);


--
-- TOC entry 5357 (class 2606 OID 23015)
-- Name: cities cities_map_tiles_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5358 (class 2606 OID 23020)
-- Name: cities cities_maps_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5381 (class 2606 OID 23025)
-- Name: district_roles district_roles_districts_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_districts_fk FOREIGN KEY (district_id) REFERENCES districts.districts(id);


--
-- TOC entry 5382 (class 2606 OID 23030)
-- Name: district_roles district_roles_players_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5383 (class 2606 OID 23035)
-- Name: district_roles district_roles_roles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5359 (class 2606 OID 23040)
-- Name: districts districts_district_types_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_district_types_fk FOREIGN KEY (district_type_id) REFERENCES districts.district_types(id);


--
-- TOC entry 5360 (class 2606 OID 23045)
-- Name: districts districts_map_tiles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5361 (class 2606 OID 23050)
-- Name: districts districts_maps_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5384 (class 2606 OID 23055)
-- Name: inventory_containers inventory_containers_inventory_container_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_inventory_container_types_fk FOREIGN KEY (inventory_container_type_id) REFERENCES inventory.inventory_container_types(id);


--
-- TOC entry 5385 (class 2606 OID 23060)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5386 (class 2606 OID 23065)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_item_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5387 (class 2606 OID 23070)
-- Name: inventory_slots inventory_slots_inventory_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5388 (class 2606 OID 23075)
-- Name: inventory_slots inventory_slots_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5389 (class 2606 OID 23080)
-- Name: inventory_slots inventory_slots_items_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5362 (class 2606 OID 23085)
-- Name: item_stats item_stats_items_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5363 (class 2606 OID 23090)
-- Name: item_stats item_stats_stats_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5364 (class 2606 OID 23095)
-- Name: items items_item_types_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5423 (class 2606 OID 353529)
-- Name: recipe_materials recipe_materials_item_id_fkey; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipe_materials
    ADD CONSTRAINT recipe_materials_item_id_fkey FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5424 (class 2606 OID 353524)
-- Name: recipe_materials recipe_materials_recipe_id_fkey; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipe_materials
    ADD CONSTRAINT recipe_materials_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES items.recipes(id);


--
-- TOC entry 5420 (class 2606 OID 361663)
-- Name: recipes recipes_items_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipes
    ADD CONSTRAINT recipes_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5421 (class 2606 OID 353506)
-- Name: recipes recipes_skill_requirement_id_fkey; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipes
    ADD CONSTRAINT recipes_skill_requirement_id_fkey FOREIGN KEY (skill_requirement_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5422 (class 2606 OID 361668)
-- Name: recipes recipes_skills_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.recipes
    ADD CONSTRAINT recipes_skills_fk FOREIGN KEY (skill_requirement_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5398 (class 2606 OID 23184)
-- Name: known_map_tiles known_map_tiles_map_tiles_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5399 (class 2606 OID 23179)
-- Name: known_map_tiles known_map_tiles_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5415 (class 2606 OID 25663)
-- Name: known_map_tiles_resources known_map_tiles_resources_map_tiles_resources_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles_resources
    ADD CONSTRAINT known_map_tiles_resources_map_tiles_resources_fk FOREIGN KEY (map_tiles_resource_id) REFERENCES world.map_tiles_resources(id);


--
-- TOC entry 5416 (class 2606 OID 25658)
-- Name: known_map_tiles_resources known_map_tiles_resources_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles_resources
    ADD CONSTRAINT known_map_tiles_resources_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5408 (class 2606 OID 25535)
-- Name: known_players_abilities known_players_abilities_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5409 (class 2606 OID 25540)
-- Name: known_players_abilities known_players_abilities_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5402 (class 2606 OID 25470)
-- Name: known_players_containers known_players_containers_inventory_containers_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_inventory_containers_fk FOREIGN KEY (container_id) REFERENCES inventory.inventory_containers(id);


--
-- TOC entry 5403 (class 2606 OID 25465)
-- Name: known_players_containers known_players_containers_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5390 (class 2606 OID 23100)
-- Name: known_players_positions known_players_positions_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5391 (class 2606 OID 23105)
-- Name: known_players_positions known_players_positions_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5400 (class 2606 OID 25450)
-- Name: known_players_profiles known_players_profiles_other_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_other_players_fk FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5401 (class 2606 OID 25445)
-- Name: known_players_profiles known_players_profiles_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5406 (class 2606 OID 25519)
-- Name: known_players_skills known_players_skills_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5407 (class 2606 OID 25524)
-- Name: known_players_skills known_players_skills_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5404 (class 2606 OID 25508)
-- Name: known_players_stats known_players_stats_player_stats_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_player_stats_fk FOREIGN KEY (other_player_id) REFERENCES attributes.player_stats(id);


--
-- TOC entry 5405 (class 2606 OID 25497)
-- Name: known_players_stats known_players_stats_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5425 (class 2606 OID 476433)
-- Name: squad_invites squad_invites_invited_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites
    ADD CONSTRAINT squad_invites_invited_fk FOREIGN KEY (invited_player_id) REFERENCES players.players(id);


--
-- TOC entry 5426 (class 2606 OID 476428)
-- Name: squad_invites squad_invites_inviter_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites
    ADD CONSTRAINT squad_invites_inviter_fk FOREIGN KEY (inviter_player_id) REFERENCES players.players(id);


--
-- TOC entry 5427 (class 2606 OID 476423)
-- Name: squad_invites squad_invites_squad_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites
    ADD CONSTRAINT squad_invites_squad_fk FOREIGN KEY (squad_id) REFERENCES squad.squads(id);


--
-- TOC entry 5428 (class 2606 OID 476467)
-- Name: squad_invites squad_invites_squad_invites_statuses_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_invites
    ADD CONSTRAINT squad_invites_squad_invites_statuses_fk FOREIGN KEY (status) REFERENCES squad.squad_invites_statuses(id);


--
-- TOC entry 5410 (class 2606 OID 25586)
-- Name: squad_players squad_players_players_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5411 (class 2606 OID 476388)
-- Name: squad_players squad_players_squad_roles_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_squad_roles_fk FOREIGN KEY (squad_role_id) REFERENCES squad.squad_roles(id);


--
-- TOC entry 5412 (class 2606 OID 25581)
-- Name: squad_players squad_players_squads_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_squads_fk FOREIGN KEY (squad_id) REFERENCES squad.squads(id);


--
-- TOC entry 5365 (class 2606 OID 23110)
-- Name: map_tiles map_tiles_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5392 (class 2606 OID 23115)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_regions_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_regions_fk FOREIGN KEY (region_id) REFERENCES world.map_regions(id);


--
-- TOC entry 5393 (class 2606 OID 23120)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5394 (class 2606 OID 23125)
-- Name: map_tiles_map_regions map_tiles_map_regions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5366 (class 2606 OID 23130)
-- Name: map_tiles map_tiles_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5395 (class 2606 OID 23135)
-- Name: map_tiles_players_positions map_tiles_players_positions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5396 (class 2606 OID 23140)
-- Name: map_tiles_players_positions map_tiles_players_positions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5397 (class 2606 OID 23145)
-- Name: map_tiles_players_positions map_tiles_players_positions_players_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5413 (class 2606 OID 25648)
-- Name: map_tiles_resources map_tiles_resources_items_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5414 (class 2606 OID 25643)
-- Name: map_tiles_resources map_tiles_resources_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5417 (class 2606 OID 271619)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_items_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5418 (class 2606 OID 271614)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5419 (class 2606 OID 271609)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


--
-- TOC entry 5429 (class 2606 OID 484695)
-- Name: map_tiles_squads_positions map_tiles_squads_positions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_squads_positions
    ADD CONSTRAINT map_tiles_squads_positions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5430 (class 2606 OID 484700)
-- Name: map_tiles_squads_positions map_tiles_squads_positions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_squads_positions
    ADD CONSTRAINT map_tiles_squads_positions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5431 (class 2606 OID 484705)
-- Name: map_tiles_squads_positions map_tiles_squads_positions_squads_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_squads_positions
    ADD CONSTRAINT map_tiles_squads_positions_squads_fk FOREIGN KEY (squad_id) REFERENCES squad.squads(id);


--
-- TOC entry 5367 (class 2606 OID 23150)
-- Name: map_tiles map_tiles_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


-- Completed on 2026-04-28 22:33:37

--
-- PostgreSQL database dump complete
--

\unrestrict HpcjojgdnyCeTCeaevKyezktex95GdwRdDVcydqJe2GEaARUsNgUYRI31KQqMpX

