--
-- PostgreSQL database dump
--

\restrict XAI5NawaLQdjFW7pzfvdsTY08TLwpCFb21YPx6IT55WDZ6EWppj2T8m6PfzaE8Q

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-04-01 00:33:46

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
-- TOC entry 392 (class 1255 OID 22428)
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
-- TOC entry 402 (class 1255 OID 22429)
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
-- TOC entry 328 (class 1255 OID 22430)
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
-- TOC entry 360 (class 1255 OID 22431)
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
-- TOC entry 428 (class 1255 OID 271624)
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
-- TOC entry 374 (class 1255 OID 22432)
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
AND id != p_player_id;

INSERT INTO knowledge.known_players_positions
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
AND id != p_player_id;

INSERT INTO knowledge.known_players_profiles
(player_id, other_player_id)
SELECT
p_player_id
,id
FROM players.players
WHERE user_id = p_user_id
AND id != p_player_id;

INSERT INTO knowledge.known_players_profiles
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
AND id != p_player_id;

INSERT INTO knowledge.known_players_abilities
(player_id, other_player_id)
SELECT
p_player_id
,id
FROM players.players
WHERE user_id = p_user_id
AND id != p_player_id;

INSERT INTO knowledge.known_players_abilities
(player_id, other_player_id)
SELECT
id
,p_player_id
FROM players.players
WHERE user_id = p_user_id
AND id != p_player_id;

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

END;
$$;


ALTER PROCEDURE admin.new_player(IN p_user_id integer, IN p_name character varying, IN p_second_name character varying) OWNER TO postgres;

--
-- TOC entry 426 (class 1255 OID 22433)
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
-- TOC entry 361 (class 1255 OID 22434)
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
-- TOC entry 365 (class 1255 OID 22435)
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
    name character varying(255),
    description character varying(255),
    image character varying(255) DEFAULT 'default.png'::character varying NOT NULL
);


ALTER TABLE attributes.abilities OWNER TO postgres;

--
-- TOC entry 403 (class 1255 OID 22444)
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
-- TOC entry 5567 (class 0 OID 0)
-- Dependencies: 403
-- Name: FUNCTION get_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities() IS 'automatic_get_api';


--
-- TOC entry 323 (class 1255 OID 22445)
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
-- TOC entry 5568 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION get_abilities_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 415 (class 1255 OID 287895)
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
-- TOC entry 5569 (class 0 OID 0)
-- Dependencies: 415
-- Name: FUNCTION get_abilities_by_key(p_name character varying); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_name character varying) IS 'automatic_get_api';


--
-- TOC entry 420 (class 1255 OID 25614)
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
AND p.id != p_player_id
ORDER BY t1.id;

END;

$$;


ALTER FUNCTION attributes.get_other_player_abilities(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5570 (class 0 OID 0)
-- Dependencies: 420
-- Name: FUNCTION get_other_player_abilities(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_abilities(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 370 (class 1255 OID 25613)
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
AND p.id != p_player_id
ORDER BY t1.id;
    
END;
$$;


ALTER FUNCTION attributes.get_other_player_skills(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5571 (class 0 OID 0)
-- Dependencies: 370
-- Name: FUNCTION get_other_player_skills(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_skills(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 399 (class 1255 OID 25612)
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
AND p.id != p_player_id
ORDER BY t1.id;

END;

$$;


ALTER FUNCTION attributes.get_other_player_stats(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5572 (class 0 OID 0)
-- Dependencies: 399
-- Name: FUNCTION get_other_player_stats(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_stats(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 327 (class 1255 OID 22454)
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
-- TOC entry 5573 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION get_player_abilities(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities(p_player_id integer) IS 'get_api';


--
-- TOC entry 409 (class 1255 OID 22456)
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
-- TOC entry 5574 (class 0 OID 0)
-- Dependencies: 409
-- Name: FUNCTION get_player_skills(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_skills(p_player_id integer) IS 'get_api';


--
-- TOC entry 334 (class 1255 OID 22457)
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
-- TOC entry 5575 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION get_player_stats(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_stats(p_player_id integer) IS 'get_api';


--
-- TOC entry 235 (class 1259 OID 22458)
-- Name: roles; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.roles (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE attributes.roles OWNER TO postgres;

--
-- TOC entry 331 (class 1255 OID 22462)
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
-- TOC entry 5576 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION get_roles(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles() IS 'automatic_get_api';


--
-- TOC entry 368 (class 1255 OID 22463)
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
-- TOC entry 5577 (class 0 OID 0)
-- Dependencies: 368
-- Name: FUNCTION get_roles_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 236 (class 1259 OID 22464)
-- Name: skills; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.skills (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    image character varying(255) DEFAULT 'default.png'::character varying NOT NULL
);


ALTER TABLE attributes.skills OWNER TO postgres;

--
-- TOC entry 347 (class 1255 OID 22472)
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
-- TOC entry 5578 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION get_skills(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills() IS 'automatic_get_api';


--
-- TOC entry 325 (class 1255 OID 22473)
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
-- TOC entry 5579 (class 0 OID 0)
-- Dependencies: 325
-- Name: FUNCTION get_skills_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 237 (class 1259 OID 22474)
-- Name: stats; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.stats (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    image character varying(255) DEFAULT 'default.png'::character varying NOT NULL
);


ALTER TABLE attributes.stats OWNER TO postgres;

--
-- TOC entry 348 (class 1255 OID 22482)
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
-- TOC entry 5580 (class 0 OID 0)
-- Dependencies: 348
-- Name: FUNCTION get_stats(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats() IS 'automatic_get_api';


--
-- TOC entry 384 (class 1255 OID 22483)
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
-- TOC entry 5581 (class 0 OID 0)
-- Dependencies: 384
-- Name: FUNCTION get_stats_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 346 (class 1255 OID 22484)
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
-- TOC entry 395 (class 1255 OID 22485)
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
-- TOC entry 359 (class 1255 OID 22486)
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
-- TOC entry 369 (class 1255 OID 22492)
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
-- TOC entry 5582 (class 0 OID 0)
-- Dependencies: 369
-- Name: FUNCTION get_building_types(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types() IS 'automatic_get_api';


--
-- TOC entry 350 (class 1255 OID 22493)
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
-- TOC entry 5583 (class 0 OID 0)
-- Dependencies: 350
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
-- TOC entry 396 (class 1255 OID 22503)
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
-- TOC entry 5584 (class 0 OID 0)
-- Dependencies: 396
-- Name: FUNCTION get_buildings(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings() IS 'automatic_get_api';


--
-- TOC entry 324 (class 1255 OID 22504)
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
-- TOC entry 5585 (class 0 OID 0)
-- Dependencies: 324
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
-- TOC entry 376 (class 1255 OID 22514)
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
-- TOC entry 5586 (class 0 OID 0)
-- Dependencies: 376
-- Name: FUNCTION get_cities(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities() IS 'automatic_get_api';


--
-- TOC entry 410 (class 1255 OID 22515)
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
-- TOC entry 5587 (class 0 OID 0)
-- Dependencies: 410
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
-- TOC entry 431 (class 1255 OID 22524)
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
-- TOC entry 5588 (class 0 OID 0)
-- Dependencies: 431
-- Name: FUNCTION get_city_tiles(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles() IS 'automatic_get_api';


--
-- TOC entry 405 (class 1255 OID 22525)
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
-- TOC entry 5589 (class 0 OID 0)
-- Dependencies: 405
-- Name: FUNCTION get_city_tiles_by_key(p_city_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 381 (class 1255 OID 22526)
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
-- TOC entry 5590 (class 0 OID 0)
-- Dependencies: 381
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
-- TOC entry 343 (class 1255 OID 22533)
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
-- TOC entry 5591 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION get_district_types(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types() IS 'automatic_get_api';


--
-- TOC entry 394 (class 1255 OID 22534)
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
-- TOC entry 5592 (class 0 OID 0)
-- Dependencies: 394
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
-- TOC entry 351 (class 1255 OID 22543)
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
-- TOC entry 5593 (class 0 OID 0)
-- Dependencies: 351
-- Name: FUNCTION get_districts(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts() IS 'automatic_get_api';


--
-- TOC entry 372 (class 1255 OID 22544)
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
-- TOC entry 5594 (class 0 OID 0)
-- Dependencies: 372
-- Name: FUNCTION get_districts_by_key(p_map_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 379 (class 1255 OID 22545)
-- Name: add_inventory_container(text, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer DEFAULT 9) RETURNS TABLE(status boolean, message text)
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
        RETURN QUERY SELECT 'fail', 'Invalid owner type', NULL;
        RETURN;
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

    RETURN QUERY SELECT true, 'Container created successfully';


END;
$$;


ALTER FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer) OWNER TO postgres;

--
-- TOC entry 385 (class 1255 OID 288322)
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
-- TOC entry 386 (class 1255 OID 22546)
-- Name: add_item_to_inventory_free_slot(integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.add_item_to_inventory_free_slot(p_inventory_container_id integer, p_item_id integer, p_quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    next_slot_id int;
BEGIN

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


ALTER FUNCTION inventory.add_item_to_inventory_free_slot(p_inventory_container_id integer, p_item_id integer, p_quantity integer) OWNER TO postgres;

--
-- TOC entry 418 (class 1255 OID 22547)
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
-- TOC entry 353 (class 1255 OID 25491)
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
-- TOC entry 358 (class 1255 OID 22548)
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
-- TOC entry 407 (class 1255 OID 22550)
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
-- TOC entry 341 (class 1255 OID 22551)
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
-- TOC entry 413 (class 1255 OID 22552)
-- Name: do_add_item_to_inventory(integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN

PERFORM items.check_item_exists(p_item_id);
PERFORM items.check_quantity_positive(p_quantity);
PERFORM inventory.check_inventory_container_exists(p_inventory_container_id);
PERFORM inventory.check_free_inventory_slots(p_inventory_container_id);


PERFORM inventory.add_item_to_inventory_free_slot(p_inventory_container_id, p_item_id, p_quantity);

        
        
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
-- TOC entry 5595 (class 0 OID 0)
-- Dependencies: 413
-- Name: FUNCTION do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 354 (class 1255 OID 337048)
-- Name: do_add_item_to_player_inventory(integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.do_add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer) RETURNS TABLE(status boolean, message text)
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

PERFORM items.check_item_exists(p_item_id);
PERFORM items.check_quantity_positive(p_quantity);
PERFORM inventory.check_inventory_container_exists(v_container_id);
PERFORM inventory.check_free_inventory_slots(v_container_id);


PERFORM inventory.add_item_to_inventory_free_slot(v_container_id, p_item_id, p_quantity);

        
        
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
-- TOC entry 5596 (class 0 OID 0)
-- Dependencies: 354
-- Name: FUNCTION do_add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_player_inventory(p_player_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 397 (class 1255 OID 22553)
-- Name: do_move_or_swap_item(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$

BEGIN
	PERFORM inventory.check_inventory_container_access(p_player_id, p_from_inventory_container_id);
	PERFORM inventory.check_inventory_container_access(p_player_id, p_to_inventory_container_id);
    PERFORM inventory.check_inventory_slot_exists(p_from_inventory_container_id, p_from_slot_id);
    PERFORM inventory.check_inventory_slot_exists(p_to_inventory_container_id, p_to_slot_id);
    PERFORM inventory.check_inventory_containers_same_tile(p_from_inventory_container_id, p_to_inventory_container_id);

PERFORM inventory.move_or_swap_item(
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
-- TOC entry 5597 (class 0 OID 0)
-- Dependencies: 397
-- Name: FUNCTION do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) IS 'action_api';


--
-- TOC entry 404 (class 1255 OID 22554)
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
-- TOC entry 5598 (class 0 OID 0)
-- Dependencies: 404
-- Name: FUNCTION get_building_inventory(p_building_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_building_inventory(p_building_id integer) IS 'get_api';


--
-- TOC entry 364 (class 1255 OID 22555)
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
-- TOC entry 363 (class 1255 OID 22556)
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
-- TOC entry 5599 (class 0 OID 0)
-- Dependencies: 363
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
-- TOC entry 390 (class 1255 OID 22561)
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
-- TOC entry 5600 (class 0 OID 0)
-- Dependencies: 390
-- Name: FUNCTION get_inventory_slot_types(); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types() IS 'automatic_get_api';


--
-- TOC entry 333 (class 1255 OID 22562)
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
-- TOC entry 5601 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION get_inventory_slot_types_by_key(p_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 355 (class 1255 OID 25611)
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
            AND p.id != p_player_id
            ORDER BY t3.id ASC;

END;
$$;


ALTER FUNCTION inventory.get_other_player_gear_inventory(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5602 (class 0 OID 0)
-- Dependencies: 355
-- Name: FUNCTION get_other_player_gear_inventory(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_other_player_gear_inventory(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 412 (class 1255 OID 25610)
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
            AND p.id != p_player_id
            ORDER BY t3.id ASC;

END;
$$;


ALTER FUNCTION inventory.get_other_player_inventory(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5603 (class 0 OID 0)
-- Dependencies: 412
-- Name: FUNCTION get_other_player_inventory(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_other_player_inventory(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 401 (class 1255 OID 25483)
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
-- TOC entry 5604 (class 0 OID 0)
-- Dependencies: 401
-- Name: FUNCTION get_player_gear_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_gear_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 338 (class 1255 OID 25482)
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
-- TOC entry 5605 (class 0 OID 0)
-- Dependencies: 338
-- Name: FUNCTION get_player_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 387 (class 1255 OID 22565)
-- Name: move_or_swap_item(integer, integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.move_or_swap_item(p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_from_item_id   integer;
    v_from_quantity  integer;

    v_to_item_id     integer;
    v_to_quantity    integer;
BEGIN


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


ALTER FUNCTION inventory.move_or_swap_item(p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 22566)
-- Name: check_item_exists(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.check_item_exists(p_item_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.items WHERE id = p_item_id) THEN
        PERFORM util.raise_error('Item does not exist');
    END IF;
END;
$$;


ALTER FUNCTION items.check_item_exists(p_item_id integer) OWNER TO postgres;

--
-- TOC entry 344 (class 1255 OID 22567)
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
-- TOC entry 342 (class 1255 OID 296085)
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

    CALL items.gather_resources_on_map_tile(
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
-- TOC entry 5606 (class 0 OID 0)
-- Dependencies: 342
-- Name: FUNCTION do_gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.do_gather_resources_on_map_tile(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_map_tiles_resource_id integer, p_gather_amount integer) IS 'action_api';


--
-- TOC entry 345 (class 1255 OID 345240)
-- Name: gather_resources_on_map_tile(integer, integer, integer, integer, integer, integer); Type: PROCEDURE; Schema: items; Owner: postgres
--

CREATE PROCEDURE items.gather_resources_on_map_tile(IN p_player_id integer, IN p_map_id integer, IN p_x integer, IN p_y integer, IN p_map_tiles_resource_id integer, IN p_gather_amount integer)
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


SELECT status, message
INTO v_status, v_message
FROM inventory.do_add_item_to_player_inventory(
    p_player_id,
    v_resource_item_id,
    p_gather_amount
);

IF NOT v_status THEN
    PERFORM util.raise_error(v_message);
END IF;


END;
$$;


ALTER PROCEDURE items.gather_resources_on_map_tile(IN p_player_id integer, IN p_map_id integer, IN p_x integer, IN p_y integer, IN p_map_tiles_resource_id integer, IN p_gather_amount integer) OWNER TO postgres;

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
-- TOC entry 416 (class 1255 OID 22575)
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
-- TOC entry 5607 (class 0 OID 0)
-- Dependencies: 416
-- Name: FUNCTION get_item_stats(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats() IS 'automatic_get_api';


--
-- TOC entry 330 (class 1255 OID 22576)
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
-- TOC entry 5608 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION get_item_stats_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 246 (class 1259 OID 22577)
-- Name: items; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.items (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    image character varying(255) DEFAULT 'default.png'::character varying NOT NULL,
    item_type_id integer DEFAULT 1 NOT NULL
);


ALTER TABLE items.items OWNER TO postgres;

--
-- TOC entry 414 (class 1255 OID 22587)
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
-- TOC entry 5609 (class 0 OID 0)
-- Dependencies: 414
-- Name: FUNCTION get_items(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items() IS 'automatic_get_api';


--
-- TOC entry 357 (class 1255 OID 22588)
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
-- TOC entry 5610 (class 0 OID 0)
-- Dependencies: 357
-- Name: FUNCTION get_items_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 335 (class 1255 OID 22589)
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
-- TOC entry 5611 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION do_switch_active_player(p_player_id integer, p_switch_to_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) IS 'action_api';


--
-- TOC entry 417 (class 1255 OID 22590)
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
-- TOC entry 411 (class 1255 OID 22591)
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
-- TOC entry 5612 (class 0 OID 0)
-- Dependencies: 411
-- Name: FUNCTION get_active_player_profile(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_profile(p_player_id integer) IS 'get_api';


--
-- TOC entry 352 (class 1255 OID 22592)
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
-- TOC entry 5613 (class 0 OID 0)
-- Dependencies: 352
-- Name: FUNCTION get_active_player_switch_profiles(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_switch_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 398 (class 1255 OID 25605)
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
            AND p.id != p_player_id
            LIMIT 1;
      END;
      $$;


ALTER FUNCTION players.get_other_player_profile(p_player_id integer, p_other_player_id text) OWNER TO postgres;

--
-- TOC entry 5614 (class 0 OID 0)
-- Dependencies: 398
-- Name: FUNCTION get_other_player_profile(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_other_player_profile(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 400 (class 1255 OID 25602)
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
-- TOC entry 373 (class 1255 OID 22593)
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
-- TOC entry 332 (class 1255 OID 25592)
-- Name: get_active_player_squad(integer); Type: FUNCTION; Schema: squad; Owner: postgres
--

CREATE FUNCTION squad.get_active_player_squad(p_player_id integer) RETURNS TABLE(squad_id integer)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
            SELECT 
            s.id AS squad_id
            FROM squad.squads s
            JOIN squad.squad_players sp ON s.id = sp.squad_id
            WHERE sp.player_id = p_player_id
            LIMIT 1;


      END;
      $$;


ALTER FUNCTION squad.get_active_player_squad(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5615 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION get_active_player_squad(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_active_player_squad(p_player_id integer) IS 'get_api';


--
-- TOC entry 336 (class 1255 OID 25619)
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
                                        AND sp.squad_id = (SELECT squad.get_active_player_squad(p_player_id));
      END;
      $$;


ALTER FUNCTION squad.get_active_player_squad_players_profiles(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5616 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION get_active_player_squad_players_profiles(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_active_player_squad_players_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 340 (class 1255 OID 25620)
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
-- TOC entry 5617 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION get_other_squad_players_profiles(p_player_id integer, p_squad_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_other_squad_players_profiles(p_player_id integer, p_squad_id integer) IS 'get_api';


--
-- TOC entry 423 (class 1255 OID 22594)
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
-- TOC entry 367 (class 1255 OID 22595)
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
-- TOC entry 432 (class 1255 OID 22596)
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
-- TOC entry 430 (class 1255 OID 337045)
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
-- TOC entry 349 (class 1255 OID 287898)
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

    CALL world.map_tile_exploration(
        p_player_id,
        p_map_id,
        p_x,
        p_y
    );

    RETURN QUERY SELECT true, 'Exploration completed';
END;
$$;


ALTER FUNCTION world.do_map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_exploration_level integer) OWNER TO postgres;

--
-- TOC entry 5618 (class 0 OID 0)
-- Dependencies: 349
-- Name: FUNCTION do_map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_exploration_level integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_map_tile_exploration(p_player_id integer, p_map_id integer, p_x integer, p_y integer, p_exploration_level integer) IS 'action_api';


--
-- TOC entry 425 (class 1255 OID 287894)
-- Name: do_player_movement(integer, jsonb); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    param jsonb;
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

    FOR param IN
        SELECT value
        FROM jsonb_array_elements(p_path)
        ORDER BY (value->>'order')::int ASC
    LOOP
        CALL world.player_movement(
            p_player_id,
            (param->>'x')::int,
            (param->>'y')::int,
            (param->>'mapId')::int
        );
    END LOOP;

    RETURN QUERY SELECT true, 'Movement completed';
END;
$$;


ALTER FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) OWNER TO postgres;

--
-- TOC entry 5619 (class 0 OID 0)
-- Dependencies: 425
-- Name: FUNCTION do_player_movement(p_player_id integer, p_path jsonb); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) IS 'action_api';


--
-- TOC entry 389 (class 1255 OID 23168)
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
-- TOC entry 5620 (class 0 OID 0)
-- Dependencies: 389
-- Name: FUNCTION get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer) IS 'get_api';


--
-- TOC entry 337 (class 1255 OID 23190)
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
-- TOC entry 5621 (class 0 OID 0)
-- Dependencies: 337
-- Name: FUNCTION get_known_map_tiles(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_tiles(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 422 (class 1255 OID 25668)
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
-- TOC entry 5622 (class 0 OID 0)
-- Dependencies: 422
-- Name: FUNCTION get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 380 (class 1255 OID 25609)
-- Name: get_known_players_positions(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) RETURNS TABLE(other_player_id text, x integer, y integer, image_map character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
             SELECT  CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE T2.masked_id::text END AS other_player_id 
                     ,T1.map_tile_x AS X 
                     ,T1.map_tile_y AS Y
                     ,t2.image_map AS image_map
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            JOIN knowledge.known_players_positions T3 ON T3.other_player_id = T2.id
            LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                           AND kpp.other_player_id = T2.id
            WHERE T1.map_id = p_map_id
             AND T3.player_id = p_player_id;
      END;
      $$;


ALTER FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5623 (class 0 OID 0)
-- Dependencies: 380
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
-- TOC entry 419 (class 1255 OID 22605)
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
-- TOC entry 5624 (class 0 OID 0)
-- Dependencies: 419
-- Name: FUNCTION get_landscape_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types() IS 'automatic_get_api';


--
-- TOC entry 339 (class 1255 OID 22606)
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
-- TOC entry 5625 (class 0 OID 0)
-- Dependencies: 339
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
-- TOC entry 421 (class 1255 OID 22615)
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
-- TOC entry 5626 (class 0 OID 0)
-- Dependencies: 421
-- Name: FUNCTION get_map_tiles(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles() IS 'automatic_get_api';


--
-- TOC entry 433 (class 1255 OID 22616)
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
-- TOC entry 5627 (class 0 OID 0)
-- Dependencies: 433
-- Name: FUNCTION get_map_tiles_by_key(p_map_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 393 (class 1255 OID 22617)
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
-- TOC entry 5628 (class 0 OID 0)
-- Dependencies: 393
-- Name: FUNCTION get_player_map(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_map(p_player_id integer) IS 'get_api';


--
-- TOC entry 377 (class 1255 OID 22619)
-- Name: get_player_position(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) RETURNS TABLE(x integer, y integer, image_map character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
             SELECT  T1.map_tile_x AS X 
                     ,T1.map_tile_y AS Y
                     ,t2.image_map AS image_map
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            WHERE T1.map_id = p_map_id
             AND T1.player_id = p_player_id;
      END;
      $$;


ALTER FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5629 (class 0 OID 0)
-- Dependencies: 377
-- Name: FUNCTION get_player_position(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 391 (class 1255 OID 25603)
-- Name: get_players_on_tile(integer, integer, integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_players_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) RETURNS TABLE(other_player_id text, name character varying, second_name character varying, nickname character varying, image_portrait character varying)
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
FROM world.map_tiles_players_positions mp
JOIN players.players p ON mp.player_id = p.id
LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                               AND kpp.other_player_id = p.id
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
FROM world.map_tiles_players_positions mp
JOIN players.players p ON mp.player_id = p.id
JOIN knowledge.known_players_positions kp ON p.id = kp.other_player_id
LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                               AND kpp.other_player_id = p.id
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
-- TOC entry 5630 (class 0 OID 0)
-- Dependencies: 391
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
-- TOC entry 382 (class 1255 OID 22627)
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
-- TOC entry 5631 (class 0 OID 0)
-- Dependencies: 382
-- Name: FUNCTION get_terrain_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types() IS 'automatic_get_api';


--
-- TOC entry 326 (class 1255 OID 22628)
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
-- TOC entry 5632 (class 0 OID 0)
-- Dependencies: 326
-- Name: FUNCTION get_terrain_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 429 (class 1255 OID 287899)
-- Name: map_tile_exploration(integer, integer, integer, integer); Type: PROCEDURE; Schema: world; Owner: postgres
--

CREATE PROCEDURE world.map_tile_exploration(IN p_player_id integer, IN p_map_id integer, IN p_x integer, IN p_y integer)
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


ALTER PROCEDURE world.map_tile_exploration(IN p_player_id integer, IN p_map_id integer, IN p_x integer, IN p_y integer) OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 287893)
-- Name: player_movement(integer, integer, integer, integer); Type: PROCEDURE; Schema: world; Owner: postgres
--

CREATE PROCEDURE world.player_movement(IN p_player_id integer, IN p_x integer, IN p_y integer, IN p_map_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE world.map_tiles_players_positions
    SET
        map_tile_x = p_x,
        map_tile_y = p_y
    WHERE player_id = p_player_id
      AND map_id = p_map_id;
END;
$$;


ALTER PROCEDURE world.player_movement(IN p_player_id integer, IN p_x integer, IN p_y integer, IN p_map_id integer) OWNER TO postgres;

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
-- TOC entry 314 (class 1259 OID 25567)
-- Name: squad_players; Type: TABLE; Schema: squad; Owner: postgres
--

CREATE TABLE squad.squad_players (
    squad_id integer NOT NULL,
    player_id integer NOT NULL
);


ALTER TABLE squad.squad_players OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 25575)
-- Name: squads; Type: TABLE; Schema: squad; Owner: postgres
--

CREATE TABLE squad.squads (
    id integer NOT NULL
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
-- TOC entry 5633 (class 0 OID 0)
-- Dependencies: 321
-- Name: map_tiles_resources_spawn_id_seq; Type: SEQUENCE OWNED BY; Schema: world; Owner: postgres
--

ALTER SEQUENCE world.map_tiles_resources_spawn_id_seq OWNED BY world.map_tiles_resources_spawn.id;


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
-- TOC entry 5142 (class 2604 OID 271595)
-- Name: map_tiles_resources_spawn id; Type: DEFAULT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn ALTER COLUMN id SET DEFAULT nextval('world.map_tiles_resources_spawn_id_seq'::regclass);


--
-- TOC entry 5474 (class 0 OID 22436)
-- Dependencies: 233
-- Data for Name: abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.abilities (id, name, description, image) FROM stdin;
2	Explore	Explore new land's	Eye
1	Colonize	Settle Nomad's	Tent
\.


--
-- TOC entry 5492 (class 0 OID 22631)
-- Dependencies: 251
-- Data for Name: ability_skill_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_skill_requirements (ability_id, skill_id, min_value) FROM stdin;
1	1	1
2	2	1
\.


--
-- TOC entry 5493 (class 0 OID 22638)
-- Dependencies: 252
-- Data for Name: ability_stat_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_stat_requirements (ability_id, stat_id, min_value) FROM stdin;
\.


--
-- TOC entry 5475 (class 0 OID 22446)
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
\.


--
-- TOC entry 5495 (class 0 OID 22646)
-- Dependencies: 254
-- Data for Name: player_skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_skills (id, player_id, skill_id, value) FROM stdin;
1	1	1	6
2	1	2	2
3	1	3	6
4	2	1	9
5	2	2	5
6	2	3	7
7	3	1	5
8	3	2	1
9	3	3	8
10	4	1	3
11	4	2	10
12	4	3	6
\.


--
-- TOC entry 5497 (class 0 OID 22654)
-- Dependencies: 256
-- Data for Name: player_stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_stats (id, player_id, stat_id, value) FROM stdin;
1	1	1	3
2	1	4	1
3	1	7	4
4	1	2	4
5	1	3	3
6	1	6	8
7	1	9	8
8	1	5	9
9	1	8	9
10	2	1	3
11	2	4	1
12	2	7	1
13	2	2	1
14	2	3	6
15	2	6	5
16	2	9	9
17	2	5	3
18	2	8	4
19	3	1	6
20	3	4	7
21	3	7	4
22	3	2	4
23	3	3	4
24	3	6	4
25	3	9	9
26	3	5	4
27	3	8	6
28	4	1	5
29	4	4	3
30	4	7	1
31	4	2	1
32	4	3	6
33	4	6	3
34	4	9	5
35	4	5	2
36	4	8	10
\.


--
-- TOC entry 5476 (class 0 OID 22458)
-- Dependencies: 235
-- Data for Name: roles; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.roles (id, name) FROM stdin;
1	Owner
\.


--
-- TOC entry 5477 (class 0 OID 22464)
-- Dependencies: 236
-- Data for Name: skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.skills (id, name, description, image) FROM stdin;
1	Colonization	Settle new world's !	Tent
2	Survival	Navigate wilderness and find resources stay alive	TreePine
3	Trade	How cheap can you buy ?	HandCoinsIcon
\.


--
-- TOC entry 5478 (class 0 OID 22474)
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
-- TOC entry 5502 (class 0 OID 22665)
-- Dependencies: 261
-- Data for Name: accounts; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.accounts (id, "userId", type, provider, "providerAccountId", refresh_token, access_token, expires_at, id_token, scope, session_state, token_type) FROM stdin;
\.


--
-- TOC entry 5504 (class 0 OID 22676)
-- Dependencies: 263
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.sessions (id, "userId", expires, "sessionToken") FROM stdin;
\.


--
-- TOC entry 5506 (class 0 OID 22684)
-- Dependencies: 265
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.users (id, name, email, "emailVerified", image, password) FROM stdin;
1	ciabat	pszabat001@gmail.com	\N	\N	$2b$10$4IQKRdaQ8l29u9KEdy6G6esjYGPJe9rQsWlAqPSe0OgbzyjsV6rCW
3	\N	example@example.com	\N	\N	$2b$10$mA6YTp9nbDRMb2LbiCg0oOS3d0ivwISpT3Fp7JPmGvWkGJ840I9kW
\.


--
-- TOC entry 5508 (class 0 OID 22691)
-- Dependencies: 267
-- Data for Name: verification_token; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.verification_token (identifier, expires, token) FROM stdin;
\.


--
-- TOC entry 5509 (class 0 OID 22699)
-- Dependencies: 268
-- Data for Name: building_roles; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_roles (building_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5479 (class 0 OID 22487)
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
-- TOC entry 5480 (class 0 OID 22494)
-- Dependencies: 239
-- Data for Name: buildings; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.buildings (id, city_id, city_tile_x, city_tile_y, building_type_id, name) FROM stdin;
\.


--
-- TOC entry 5481 (class 0 OID 22505)
-- Dependencies: 240
-- Data for Name: cities; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.cities (id, map_id, map_tile_x, map_tile_y, name, move_cost, image_url) FROM stdin;
\.


--
-- TOC entry 5513 (class 0 OID 22708)
-- Dependencies: 272
-- Data for Name: city_roles; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.city_roles (city_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5482 (class 0 OID 22516)
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
-- TOC entry 5514 (class 0 OID 22714)
-- Dependencies: 273
-- Data for Name: district_roles; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_roles (district_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5483 (class 0 OID 22527)
-- Dependencies: 242
-- Data for Name: district_types; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_types (id, name, move_cost, image_url) FROM stdin;
1	Farmland	1	full_farmland.png
\.


--
-- TOC entry 5484 (class 0 OID 22535)
-- Dependencies: 243
-- Data for Name: districts; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.districts (id, map_id, map_tile_x, map_tile_y, district_type_id, name) FROM stdin;
\.


--
-- TOC entry 5549 (class 0 OID 25486)
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
\.


--
-- TOC entry 5517 (class 0 OID 22722)
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
-- TOC entry 5519 (class 0 OID 22727)
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
\.


--
-- TOC entry 5521 (class 0 OID 22737)
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
-- TOC entry 5485 (class 0 OID 22557)
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
-- TOC entry 5523 (class 0 OID 22743)
-- Dependencies: 282
-- Data for Name: inventory_slots; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slots (id, inventory_container_id, item_id, quantity, inventory_slot_type_id) FROM stdin;
6	1	\N	\N	1
10	2	\N	\N	2
12	2	\N	\N	4
14	2	\N	\N	6
17	2	\N	\N	9
18	2	\N	\N	10
21	2	\N	\N	13
23	3	\N	\N	1
24	3	\N	\N	1
25	3	\N	\N	1
26	3	\N	\N	1
27	3	\N	\N	1
28	3	\N	\N	1
29	3	\N	\N	1
30	3	\N	\N	1
31	3	\N	\N	1
32	4	\N	\N	2
33	4	\N	\N	3
34	4	\N	\N	4
35	4	\N	\N	5
36	4	\N	\N	6
37	4	\N	\N	7
38	4	\N	\N	8
39	4	\N	\N	9
40	4	\N	\N	10
41	4	\N	\N	11
42	4	\N	\N	12
43	4	\N	\N	13
44	4	\N	\N	14
45	5	\N	\N	1
46	5	\N	\N	1
47	5	\N	\N	1
48	5	\N	\N	1
49	5	\N	\N	1
50	5	\N	\N	1
51	5	\N	\N	1
52	5	\N	\N	1
53	5	\N	\N	1
54	6	\N	\N	2
55	6	\N	\N	3
56	6	\N	\N	4
57	6	\N	\N	5
58	6	\N	\N	6
59	6	\N	\N	7
60	6	\N	\N	8
61	6	\N	\N	9
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
15	2	\N	\N	7
5	1	\N	\N	1
9	1	\N	\N	1
19	2	\N	\N	11
4	1	\N	\N	1
8	1	\N	\N	1
2	1	\N	\N	1
16	2	\N	\N	8
3	1	\N	\N	1
13	2	\N	\N	5
22	2	\N	\N	14
1	1	\N	\N	1
7	1	\N	\N	1
11	2	1	1	3
20	2	\N	\N	12
\.


--
-- TOC entry 5486 (class 0 OID 22568)
-- Dependencies: 245
-- Data for Name: item_stats; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_stats (id, item_id, stat_id, value) FROM stdin;
\.


--
-- TOC entry 5526 (class 0 OID 22752)
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
-- TOC entry 5487 (class 0 OID 22577)
-- Dependencies: 246
-- Data for Name: items; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.items (id, name, description, image, item_type_id) FROM stdin;
2	Sword	\N	Sword	5
3	Helmet	\N	default.png	2
4	Wood	\N	default.png	1
5	Stone	\N	default.png	1
1	Straw	\N	Herbalism	1
6	Mushroom	\N	default.png	1
\.


--
-- TOC entry 5546 (class 0 OID 23161)
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
\.


--
-- TOC entry 5559 (class 0 OID 25653)
-- Dependencies: 320
-- Data for Name: known_map_tiles_resources; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_map_tiles_resources (player_id, map_tiles_resource_id) FROM stdin;
2	1626
2	1625
2	1628
2	1624
2	1627
2	292
2	294
2	293
2	290
2	291
2	733
2	734
2	575
2	574
2	572
2	573
2	571
2	426
2	424
2	425
2	427
\.


--
-- TOC entry 5552 (class 0 OID 25530)
-- Dependencies: 313
-- Data for Name: known_players_abilities; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_abilities (player_id, other_player_id) FROM stdin;
2	1
1	2
3	1
3	2
1	3
2	3
4	1
4	2
4	3
1	4
2	4
3	4
\.


--
-- TOC entry 5548 (class 0 OID 25460)
-- Dependencies: 309
-- Data for Name: known_players_containers; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_containers (player_id, container_id) FROM stdin;
\.


--
-- TOC entry 5529 (class 0 OID 22758)
-- Dependencies: 288
-- Data for Name: known_players_positions; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_positions (player_id, other_player_id) FROM stdin;
2	1
1	2
3	1
3	2
1	3
2	3
4	1
4	2
4	3
1	4
2	4
3	4
\.


--
-- TOC entry 5547 (class 0 OID 25440)
-- Dependencies: 308
-- Data for Name: known_players_profiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_profiles (player_id, other_player_id) FROM stdin;
2	1
1	2
3	1
3	2
1	3
2	3
4	1
4	2
4	3
1	4
2	4
3	4
\.


--
-- TOC entry 5551 (class 0 OID 25514)
-- Dependencies: 312
-- Data for Name: known_players_skills; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_skills (player_id, other_player_id) FROM stdin;
\.


--
-- TOC entry 5556 (class 0 OID 25593)
-- Dependencies: 317
-- Data for Name: known_players_squad_profiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_squad_profiles (player_id, squad_id) FROM stdin;
1	1
4	1
\.


--
-- TOC entry 5550 (class 0 OID 25492)
-- Dependencies: 311
-- Data for Name: known_players_stats; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_stats (player_id, other_player_id) FROM stdin;
\.


--
-- TOC entry 5530 (class 0 OID 22763)
-- Dependencies: 289
-- Data for Name: players; Type: TABLE DATA; Schema: players; Owner: postgres
--

COPY players.players (id, user_id, name, image_map, image_portrait, is_active, second_name, nickname, masked_id) FROM stdin;
3	1	Jachuren	default.png	default.png	f	Koczkodanen	\N	24bdb1ef-11e5-4ec0-ab6e-e25295a77bf0
4	1	Ziomo	default.png	default.png	f	Fotono	\N	e2b86c07-cab2-41a2-b4b6-002c079579cd
1	1	Ciabat	default.png	default.png	f	Ciabatos	\N	7a020d05-1d41-4453-bdb1-2db34de547db
2	1	Pawlak	default.png	default.png	t	Ciabatos	\N	88974824-4306-4ccc-9c37-900eae76f15c
\.


--
-- TOC entry 5553 (class 0 OID 25567)
-- Dependencies: 314
-- Data for Name: squad_players; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squad_players (squad_id, player_id) FROM stdin;
\.


--
-- TOC entry 5555 (class 0 OID 25575)
-- Dependencies: 316
-- Data for Name: squads; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squads (id) FROM stdin;
1
\.


--
-- TOC entry 5532 (class 0 OID 22780)
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
-- TOC entry 5534 (class 0 OID 22786)
-- Dependencies: 293
-- Data for Name: tasks; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

COPY tasks.tasks (id, player_id, status, created_at, scheduled_at, last_executed_at, error, method_name, method_parameters) FROM stdin;
1	2	5	2026-03-26 23:07:42.700776	2026-06-03 19:47:42.700776	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 11, "gatherAmount": 99160, "mapTilesResourceId": 1624}
2	2	5	2026-03-26 23:07:48.333677	2026-05-19 20:46:48.333677	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 11, "gatherAmount": 77619, "mapTilesResourceId": 1626}
3	2	5	2026-03-27 17:04:06.210197	2026-03-27 17:05:06.210197	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 292}
4	2	5	2026-03-27 17:04:07.74654	2026-03-27 17:05:07.74654	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 292}
5	2	5	2026-03-27 17:04:37.486201	2026-03-27 17:05:37.486201	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 292}
6	2	5	2026-03-27 17:07:48.696884	2026-03-27 17:08:48.696884	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 294}
7	2	5	2026-03-27 17:09:20.906312	2026-03-27 17:10:20.906312	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 290}
8	2	5	2026-03-27 17:09:22.576777	2026-03-27 17:10:22.576777	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 290}
9	2	5	2026-03-27 17:09:23.229002	2026-03-27 17:10:23.229002	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 290}
10	2	5	2026-03-27 17:09:31.906707	2026-03-27 17:10:31.906707	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 291}
11	2	5	2026-03-27 17:09:33.695347	2026-03-27 17:10:33.695347	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 291}
12	2	5	2026-03-27 17:09:36.087147	2026-03-27 17:10:36.087147	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 290}
13	2	5	2026-03-27 17:09:37.454354	2026-03-27 17:10:37.454354	\N	\N	items.gather_resources_on_map_tile	{"x": 8, "y": 3, "gatherAmount": 1, "mapTilesResourceId": 290}
14	2	5	2026-03-27 17:09:42.730651	2026-03-27 17:10:42.730651	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 6, "gatherAmount": 1, "mapTilesResourceId": 733}
15	2	5	2026-03-27 17:09:43.553807	2026-03-27 17:10:43.553807	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 6, "gatherAmount": 1, "mapTilesResourceId": 733}
16	2	5	2026-03-27 17:09:44.99392	2026-03-27 17:10:44.99392	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 6, "gatherAmount": 1, "mapTilesResourceId": 734}
17	2	5	2026-03-27 17:09:45.689584	2026-03-27 17:10:45.689584	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 6, "gatherAmount": 1, "mapTilesResourceId": 734}
18	2	5	2026-03-27 17:09:46.317989	2026-03-27 17:10:46.317989	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 6, "gatherAmount": 1, "mapTilesResourceId": 734}
19	2	5	2026-03-27 17:09:48.540244	2026-03-27 17:10:48.540244	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 6, "gatherAmount": 1, "mapTilesResourceId": 734}
20	2	1	2026-03-27 17:09:49.067347	2026-03-27 17:10:49.067347	\N	\N	items.gather_resources_on_map_tile	{"x": 7, "y": 6, "gatherAmount": 1, "mapTilesResourceId": 734}
\.


--
-- TOC entry 5488 (class 0 OID 22599)
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
-- TOC entry 5537 (class 0 OID 22798)
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
\.


--
-- TOC entry 5489 (class 0 OID 22607)
-- Dependencies: 248
-- Data for Name: map_tiles; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles (map_id, x, y, terrain_type_id, landscape_type_id) FROM stdin;
1	1	1	7	\N
1	2	1	7	\N
1	3	1	7	\N
1	4	1	7	\N
1	5	1	7	\N
1	6	1	7	\N
1	7	1	7	\N
1	8	1	7	\N
1	9	1	7	\N
1	10	1	7	\N
1	11	1	7	\N
1	12	1	7	\N
1	13	1	7	\N
1	14	1	7	\N
1	15	1	7	\N
1	16	1	7	\N
1	17	1	2	1
1	18	1	2	1
1	19	1	2	1
1	20	1	2	\N
1	21	1	2	\N
1	22	1	3	2
1	23	1	3	2
1	24	1	3	2
1	25	1	3	2
1	26	1	6	\N
1	27	1	6	\N
1	28	1	6	\N
1	29	1	9	\N
1	30	1	9	\N
1	31	1	2	1
1	32	1	2	1
1	33	1	2	\N
1	34	1	2	\N
1	35	1	2	\N
1	36	1	2	\N
1	37	1	2	\N
1	38	1	2	1
1	39	1	2	\N
1	40	1	2	1
1	41	1	7	\N
1	42	1	7	\N
1	43	1	7	\N
1	44	1	7	\N
1	45	1	7	\N
1	46	1	7	\N
1	47	1	7	\N
1	48	1	7	\N
1	49	1	5	8
1	50	1	5	\N
1	51	1	5	8
1	52	1	5	8
1	53	1	5	8
1	54	1	2	1
1	55	1	2	1
1	56	1	2	1
1	57	1	2	\N
1	58	1	2	\N
1	59	1	2	1
1	60	1	2	1
1	1	2	7	\N
1	2	2	7	\N
1	3	2	7	\N
1	4	2	7	\N
1	5	2	7	\N
1	6	2	7	\N
1	7	2	7	\N
1	8	2	1	1
1	9	2	7	\N
1	10	2	7	\N
1	11	2	7	\N
1	12	2	4	7
1	13	2	7	\N
1	14	2	2	\N
1	15	2	7	\N
1	16	2	7	\N
1	17	2	2	1
1	18	2	2	1
1	19	2	9	\N
1	20	2	7	\N
1	21	2	2	1
1	22	2	2	1
1	23	2	3	2
1	24	2	3	3
1	25	2	3	\N
1	26	2	3	3
1	27	2	6	\N
1	28	2	6	\N
1	29	2	9	\N
1	30	2	9	\N
1	31	2	9	\N
1	32	2	9	\N
1	33	2	2	\N
1	34	2	2	1
1	35	2	2	1
1	36	2	2	1
1	37	2	2	1
1	38	2	3	\N
1	39	2	2	\N
1	40	2	2	1
1	41	2	5	\N
1	42	2	7	\N
1	43	2	7	\N
1	44	2	4	\N
1	45	2	7	\N
1	46	2	7	\N
1	47	2	7	\N
1	48	2	7	\N
1	49	2	7	\N
1	50	2	5	6
1	51	2	5	6
1	52	2	5	8
1	53	2	5	\N
1	54	2	7	\N
1	55	2	2	\N
1	56	2	2	\N
1	57	2	2	1
1	58	2	2	\N
1	59	2	2	1
1	60	2	2	1
1	1	3	3	3
1	2	3	3	\N
1	3	3	5	6
1	4	3	7	\N
1	5	3	7	\N
1	6	3	7	\N
1	7	3	7	\N
1	8	3	3	2
1	9	3	7	\N
1	10	3	7	\N
1	11	3	7	\N
1	12	3	4	\N
1	13	3	4	7
1	14	3	7	\N
1	15	3	9	\N
1	16	3	7	\N
1	17	3	2	1
1	18	3	2	1
1	19	3	9	\N
1	20	3	9	\N
1	21	3	9	\N
1	22	3	9	\N
1	23	3	9	\N
1	24	3	9	\N
1	25	3	9	\N
1	26	3	9	\N
1	27	3	6	\N
1	28	3	6	\N
1	29	3	9	\N
1	30	3	7	\N
1	31	3	9	\N
1	32	3	2	1
1	33	3	2	1
1	34	3	2	1
1	35	3	2	1
1	36	3	2	1
1	37	3	1	1
1	38	3	9	\N
1	39	3	2	\N
1	40	3	2	1
1	41	3	2	1
1	42	3	7	\N
1	43	3	7	\N
1	44	3	5	\N
1	45	3	9	\N
1	46	3	7	\N
1	47	3	7	\N
1	48	3	7	\N
1	49	3	7	\N
1	50	3	5	8
1	51	3	5	8
1	52	3	5	6
1	53	3	5	8
1	54	3	5	\N
1	55	3	2	1
1	56	3	2	1
1	57	3	2	1
1	58	3	2	1
1	59	3	2	1
1	60	3	4	7
1	1	4	3	2
1	2	4	4	\N
1	3	4	3	2
1	4	4	7	\N
1	5	4	7	\N
1	6	4	7	\N
1	7	4	7	\N
1	8	4	7	\N
1	9	4	7	\N
1	10	4	5	6
1	11	4	7	\N
1	12	4	4	7
1	13	4	4	7
1	14	4	4	7
1	15	4	7	\N
1	16	4	6	\N
1	17	4	2	1
1	18	4	2	\N
1	19	4	9	\N
1	20	4	6	\N
1	21	4	9	\N
1	22	4	3	2
1	23	4	5	\N
1	24	4	9	\N
1	25	4	9	\N
1	26	4	6	\N
1	27	4	6	\N
1	28	4	6	\N
1	29	4	9	\N
1	30	4	7	\N
1	31	4	7	\N
1	32	4	2	1
1	33	4	2	1
1	34	4	2	1
1	35	4	2	1
1	36	4	2	1
1	37	4	2	\N
1	38	4	7	\N
1	39	4	1	1
1	40	4	2	1
1	41	4	2	1
1	42	4	2	1
1	43	4	7	\N
1	44	4	7	\N
1	45	4	9	\N
1	46	4	9	\N
1	47	4	9	\N
1	48	4	9	\N
1	49	4	9	\N
1	50	4	9	\N
1	51	4	5	6
1	52	4	5	\N
1	53	4	2	1
1	54	4	2	1
1	55	4	2	\N
1	56	4	2	1
1	57	4	2	1
1	58	4	2	1
1	59	4	2	1
1	60	4	2	\N
1	1	5	3	\N
1	2	5	3	\N
1	3	5	3	3
1	4	5	3	3
1	5	5	7	\N
1	6	5	7	\N
1	7	5	7	\N
1	8	5	7	\N
1	9	5	1	9
1	10	5	7	\N
1	11	5	7	\N
1	12	5	4	7
1	13	5	6	\N
1	14	5	4	7
1	15	5	4	7
1	16	5	9	\N
1	17	5	2	1
1	18	5	2	1
1	19	5	9	\N
1	20	5	9	\N
1	21	5	1	1
1	22	5	1	\N
1	23	5	1	\N
1	24	5	1	9
1	25	5	1	9
1	26	5	6	\N
1	27	5	6	\N
1	28	5	6	\N
1	29	5	6	\N
1	30	5	7	\N
1	31	5	7	\N
1	32	5	2	1
1	33	5	4	\N
1	34	5	2	\N
1	35	5	2	1
1	36	5	9	\N
1	37	5	2	1
1	38	5	2	\N
1	39	5	2	1
1	40	5	2	1
1	41	5	2	\N
1	42	5	2	1
1	43	5	2	1
1	44	5	7	\N
1	45	5	9	\N
1	46	5	7	\N
1	47	5	4	7
1	48	5	9	\N
1	49	5	9	\N
1	50	5	5	8
1	51	5	5	6
1	52	5	5	6
1	53	5	4	\N
1	54	5	2	1
1	55	5	2	\N
1	56	5	2	\N
1	57	5	2	\N
1	58	5	2	1
1	59	5	2	1
1	60	5	2	1
1	1	6	3	\N
1	2	6	3	2
1	3	6	3	\N
1	4	6	3	2
1	5	6	3	\N
1	6	6	7	\N
1	7	6	5	\N
1	8	6	7	\N
1	9	6	7	\N
1	10	6	7	\N
1	11	6	4	\N
1	12	6	4	7
1	13	6	9	\N
1	14	6	9	\N
1	15	6	9	\N
1	16	6	2	1
1	17	6	2	\N
1	18	6	2	\N
1	19	6	9	\N
1	20	6	1	9
1	21	6	1	9
1	22	6	1	\N
1	23	6	1	1
1	24	6	1	1
1	25	6	3	\N
1	26	6	6	\N
1	27	6	6	\N
1	28	6	6	\N
1	29	6	6	\N
1	30	6	6	\N
1	31	6	7	\N
1	32	6	9	\N
1	33	6	9	\N
1	34	6	2	1
1	35	6	2	1
1	36	6	9	\N
1	37	6	9	\N
1	38	6	9	\N
1	39	6	2	\N
1	40	6	1	\N
1	41	6	7	\N
1	42	6	3	2
1	43	6	2	\N
1	44	6	2	\N
1	45	6	9	\N
1	46	6	9	\N
1	47	6	9	\N
1	48	6	4	7
1	49	6	9	\N
1	50	6	9	\N
1	51	6	5	8
1	52	6	2	1
1	53	6	2	1
1	54	6	2	\N
1	55	6	6	\N
1	56	6	9	\N
1	57	6	2	1
1	58	6	2	1
1	59	6	2	1
1	60	6	2	1
1	1	7	3	\N
1	2	7	3	3
1	3	7	3	2
1	4	7	3	2
1	5	7	3	3
1	6	7	3	\N
1	7	7	4	\N
1	8	7	7	\N
1	9	7	7	\N
1	10	7	7	\N
1	11	7	9	\N
1	12	7	9	\N
1	13	7	6	\N
1	14	7	1	\N
1	15	7	1	\N
1	16	7	2	\N
1	17	7	2	\N
1	18	7	2	1
1	19	7	9	\N
1	20	7	1	1
1	21	7	1	1
1	22	7	1	\N
1	23	7	1	\N
1	24	7	1	9
1	25	7	1	9
1	26	7	6	\N
1	27	7	3	2
1	28	7	9	\N
1	29	7	6	\N
1	30	7	6	\N
1	31	7	5	6
1	32	7	5	\N
1	33	7	2	1
1	34	7	2	1
1	35	7	2	\N
1	36	7	9	\N
1	37	7	2	\N
1	38	7	9	\N
1	39	7	9	\N
1	40	7	1	\N
1	41	7	1	\N
1	42	7	1	1
1	43	7	2	1
1	44	7	2	1
1	45	7	2	1
1	46	7	2	1
1	47	7	2	1
1	48	7	2	\N
1	49	7	9	\N
1	50	7	5	6
1	51	7	3	2
1	52	7	2	\N
1	53	7	2	\N
1	54	7	2	1
1	55	7	2	1
1	56	7	2	1
1	57	7	2	1
1	58	7	2	1
1	59	7	2	1
1	60	7	2	1
1	1	8	3	2
1	2	8	9	\N
1	3	8	3	2
1	4	8	3	2
1	5	8	3	3
1	6	8	3	2
1	7	8	3	\N
1	8	8	7	\N
1	9	8	3	2
1	10	8	7	\N
1	11	8	7	\N
1	12	8	9	\N
1	13	8	9	\N
1	14	8	1	9
1	15	8	5	\N
1	16	8	3	\N
1	17	8	2	\N
1	18	8	2	1
1	19	8	9	\N
1	20	8	6	\N
1	21	8	1	1
1	22	8	1	9
1	23	8	1	\N
1	24	8	1	9
1	25	8	1	9
1	26	8	9	\N
1	27	8	9	\N
1	28	8	3	2
1	29	8	6	\N
1	30	8	6	\N
1	31	8	5	\N
1	32	8	5	8
1	33	8	2	\N
1	34	8	1	9
1	35	8	2	\N
1	36	8	2	1
1	37	8	2	1
1	38	8	9	\N
1	39	8	1	1
1	40	8	7	\N
1	41	8	1	1
1	42	8	9	\N
1	43	8	9	\N
1	44	8	9	\N
1	45	8	2	1
1	46	8	2	1
1	47	8	2	1
1	48	8	1	9
1	49	8	1	\N
1	50	8	1	\N
1	51	8	3	2
1	52	8	2	\N
1	53	8	2	\N
1	54	8	9	\N
1	55	8	9	\N
1	56	8	9	\N
1	57	8	9	\N
1	58	8	9	\N
1	59	8	2	1
1	60	8	2	1
1	1	9	3	3
1	2	9	9	\N
1	3	9	3	\N
1	4	9	3	3
1	5	9	3	\N
1	6	9	3	2
1	7	9	3	2
1	8	9	3	2
1	9	9	2	\N
1	10	9	7	\N
1	11	9	7	\N
1	12	9	9	\N
1	13	9	1	1
1	14	9	1	1
1	15	9	1	1
1	16	9	1	\N
1	17	9	2	1
1	18	9	4	7
1	19	9	2	1
1	20	9	1	9
1	21	9	1	\N
1	22	9	1	1
1	23	9	1	1
1	24	9	1	\N
1	25	9	1	9
1	26	9	9	\N
1	27	9	9	\N
1	28	9	3	\N
1	29	9	3	\N
1	30	9	6	\N
1	31	9	5	\N
1	32	9	9	\N
1	33	9	9	\N
1	34	9	9	\N
1	35	9	9	\N
1	36	9	2	1
1	37	9	2	1
1	38	9	2	1
1	39	9	1	1
1	40	9	5	8
1	41	9	1	9
1	42	9	5	\N
1	43	9	9	\N
1	44	9	5	8
1	45	9	2	1
1	46	9	6	\N
1	47	9	7	\N
1	48	9	1	1
1	49	9	1	9
1	50	9	4	7
1	51	9	1	\N
1	52	9	2	\N
1	53	9	2	1
1	54	9	9	\N
1	55	9	3	2
1	56	9	9	\N
1	57	9	4	7
1	58	9	9	\N
1	59	9	2	1
1	60	9	2	1
1	1	10	3	2
1	2	10	3	3
1	3	10	3	3
1	4	10	3	2
1	5	10	3	3
1	6	10	3	2
1	7	10	3	3
1	8	10	5	6
1	9	10	2	\N
1	10	10	2	1
1	11	10	7	\N
1	12	10	9	\N
1	13	10	9	\N
1	14	10	9	\N
1	15	10	9	\N
1	16	10	9	\N
1	17	10	1	1
1	18	10	2	1
1	19	10	2	1
1	20	10	7	\N
1	21	10	6	\N
1	22	10	7	\N
1	23	10	6	\N
1	24	10	1	\N
1	25	10	1	1
1	26	10	1	\N
1	27	10	9	\N
1	28	10	9	\N
1	29	10	9	\N
1	30	10	9	\N
1	31	10	9	\N
1	32	10	5	8
1	33	10	7	\N
1	34	10	7	\N
1	35	10	9	\N
1	36	10	2	1
1	37	10	2	1
1	38	10	2	1
1	39	10	3	2
1	40	10	1	9
1	41	10	1	9
1	42	10	1	9
1	43	10	5	6
1	44	10	5	6
1	45	10	5	\N
1	46	10	2	1
1	47	10	1	1
1	48	10	1	9
1	49	10	2	\N
1	50	10	1	9
1	51	10	1	1
1	52	10	1	9
1	53	10	6	\N
1	54	10	9	\N
1	55	10	9	\N
1	56	10	3	2
1	57	10	3	2
1	58	10	9	\N
1	59	10	2	1
1	60	10	2	\N
1	1	11	7	\N
1	2	11	3	3
1	3	11	9	\N
1	4	11	9	\N
1	5	11	3	3
1	6	11	6	\N
1	7	11	3	2
1	8	11	3	\N
1	9	11	2	1
1	10	11	2	1
1	11	11	2	1
1	12	11	9	\N
1	13	11	3	2
1	14	11	3	\N
1	15	11	1	\N
1	16	11	9	\N
1	17	11	9	\N
1	18	11	2	\N
1	19	11	2	1
1	20	11	1	9
1	21	11	7	\N
1	22	11	6	\N
1	23	11	6	\N
1	24	11	1	9
1	25	11	1	9
1	26	11	1	\N
1	27	11	1	\N
1	28	11	9	\N
1	29	11	1	9
1	30	11	1	\N
1	31	11	1	1
1	32	11	1	\N
1	33	11	7	\N
1	34	11	3	\N
1	35	11	9	\N
1	36	11	9	\N
1	37	11	9	\N
1	38	11	2	1
1	39	11	3	3
1	40	11	1	1
1	41	11	1	\N
1	42	11	1	1
1	43	11	4	7
1	44	11	5	\N
1	45	11	5	6
1	46	11	1	9
1	47	11	2	1
1	48	11	7	\N
1	49	11	1	9
1	50	11	1	\N
1	51	11	1	\N
1	52	11	6	\N
1	53	11	6	\N
1	54	11	6	\N
1	55	11	3	2
1	56	11	3	2
1	57	11	3	\N
1	58	11	9	\N
1	59	11	9	\N
1	60	11	2	1
1	1	12	3	\N
1	2	12	1	1
1	3	12	9	\N
1	4	12	3	2
1	5	12	3	\N
1	6	12	5	6
1	7	12	2	\N
1	8	12	2	1
1	9	12	2	1
1	10	12	2	1
1	11	12	3	\N
1	12	12	3	\N
1	13	12	3	3
1	14	12	4	7
1	15	12	1	9
1	16	12	1	1
1	17	12	9	\N
1	18	12	2	1
1	19	12	2	\N
1	20	12	2	1
1	21	12	1	1
1	22	12	6	\N
1	23	12	6	\N
1	24	12	5	\N
1	25	12	1	\N
1	26	12	3	\N
1	27	12	1	1
1	28	12	1	\N
1	29	12	4	7
1	30	12	1	\N
1	31	12	1	1
1	32	12	1	9
1	33	12	1	9
1	34	12	1	1
1	35	12	1	9
1	36	12	1	\N
1	37	12	9	\N
1	38	12	9	\N
1	39	12	1	1
1	40	12	1	1
1	41	12	6	\N
1	42	12	1	9
1	43	12	3	2
1	44	12	9	\N
1	45	12	9	\N
1	46	12	9	\N
1	47	12	1	1
1	48	12	1	9
1	49	12	1	1
1	50	12	1	\N
1	51	12	1	1
1	52	12	1	\N
1	53	12	7	\N
1	54	12	6	\N
1	55	12	3	2
1	56	12	3	3
1	57	12	4	7
1	58	12	3	2
1	59	12	2	1
1	60	12	5	6
1	1	13	1	9
1	2	13	1	\N
1	3	13	1	1
1	4	13	3	\N
1	5	13	3	2
1	6	13	3	2
1	7	13	2	\N
1	8	13	2	\N
1	9	13	2	1
1	10	13	2	1
1	11	13	5	6
1	12	13	3	\N
1	13	13	3	2
1	14	13	3	2
1	15	13	1	9
1	16	13	1	1
1	17	13	9	\N
1	18	13	9	\N
1	19	13	9	\N
1	20	13	9	\N
1	21	13	1	\N
1	22	13	1	9
1	23	13	6	\N
1	24	13	6	\N
1	25	13	1	9
1	26	13	1	1
1	27	13	9	\N
1	28	13	1	\N
1	29	13	6	\N
1	30	13	1	1
1	31	13	1	\N
1	32	13	1	9
1	33	13	1	\N
1	34	13	1	\N
1	35	13	1	\N
1	36	13	1	\N
1	37	13	1	1
1	38	13	9	\N
1	39	13	1	\N
1	40	13	1	\N
1	41	13	1	9
1	42	13	5	8
1	43	13	1	9
1	44	13	1	9
1	45	13	1	1
1	46	13	1	\N
1	47	13	1	9
1	48	13	1	1
1	49	13	1	\N
1	50	13	1	9
1	51	13	1	1
1	52	13	1	1
1	53	13	1	9
1	54	13	1	9
1	55	13	3	\N
1	56	13	2	\N
1	57	13	3	2
1	58	13	3	2
1	59	13	3	\N
1	60	13	2	1
1	1	14	1	1
1	2	14	1	1
1	3	14	1	9
1	4	14	1	1
1	5	14	3	\N
1	6	14	3	2
1	7	14	2	1
1	8	14	2	\N
1	9	14	2	\N
1	10	14	9	\N
1	11	14	9	\N
1	12	14	9	\N
1	13	14	3	\N
1	14	14	3	2
1	15	14	1	1
1	16	14	1	9
1	17	14	4	\N
1	18	14	4	\N
1	19	14	9	\N
1	20	14	1	1
1	21	14	1	\N
1	22	14	6	\N
1	23	14	6	\N
1	24	14	6	\N
1	25	14	1	9
1	26	14	1	\N
1	27	14	9	\N
1	28	14	7	\N
1	29	14	1	\N
1	30	14	4	7
1	31	14	1	1
1	32	14	4	7
1	33	14	1	9
1	34	14	4	7
1	35	14	6	\N
1	36	14	1	1
1	37	14	1	1
1	38	14	9	\N
1	39	14	1	1
1	40	14	1	1
1	41	14	1	\N
1	42	14	1	\N
1	43	14	1	9
1	44	14	1	\N
1	45	14	1	1
1	46	14	1	9
1	47	14	1	9
1	48	14	1	\N
1	49	14	1	\N
1	50	14	1	9
1	51	14	1	9
1	52	14	1	9
1	53	14	1	9
1	54	14	3	2
1	55	14	3	2
1	56	14	3	\N
1	57	14	2	\N
1	58	14	3	\N
1	59	14	3	2
1	60	14	1	9
1	1	15	1	1
1	2	15	1	9
1	3	15	1	1
1	4	15	1	1
1	5	15	9	\N
1	6	15	9	\N
1	7	15	2	1
1	8	15	2	1
1	9	15	2	1
1	10	15	9	\N
1	11	15	1	\N
1	12	15	9	\N
1	13	15	3	\N
1	14	15	3	2
1	15	15	1	\N
1	16	15	1	9
1	17	15	9	\N
1	18	15	4	7
1	19	15	9	\N
1	20	15	9	\N
1	21	15	1	1
1	22	15	1	1
1	23	15	6	\N
1	24	15	6	\N
1	25	15	1	\N
1	26	15	1	\N
1	27	15	9	\N
1	28	15	9	\N
1	29	15	9	\N
1	30	15	9	\N
1	31	15	9	\N
1	32	15	9	\N
1	33	15	9	\N
1	34	15	9	\N
1	35	15	1	1
1	36	15	1	\N
1	37	15	4	7
1	38	15	1	1
1	39	15	1	1
1	40	15	1	9
1	41	15	1	9
1	42	15	1	\N
1	43	15	1	\N
1	44	15	1	1
1	45	15	3	2
1	46	15	1	1
1	47	15	1	\N
1	48	15	6	\N
1	49	15	1	9
1	50	15	9	\N
1	51	15	7	\N
1	52	15	5	6
1	53	15	1	9
1	54	15	1	9
1	55	15	3	\N
1	56	15	3	\N
1	57	15	1	9
1	58	15	3	2
1	59	15	3	2
1	60	15	3	2
1	1	16	1	1
1	2	16	9	\N
1	3	16	1	\N
1	4	16	2	1
1	5	16	1	\N
1	6	16	1	1
1	7	16	5	6
1	8	16	2	1
1	9	16	2	1
1	10	16	9	\N
1	11	16	9	\N
1	12	16	1	1
1	13	16	6	\N
1	14	16	3	\N
1	15	16	1	\N
1	16	16	1	9
1	17	16	9	\N
1	18	16	4	\N
1	19	16	4	\N
1	20	16	9	\N
1	21	16	9	\N
1	22	16	9	\N
1	23	16	9	\N
1	24	16	3	2
1	25	16	1	\N
1	26	16	1	1
1	27	16	9	\N
1	28	16	6	\N
1	29	16	6	\N
1	30	16	9	\N
1	31	16	1	\N
1	32	16	9	\N
1	33	16	9	\N
1	34	16	1	1
1	35	16	1	1
1	36	16	1	1
1	37	16	1	9
1	38	16	9	\N
1	39	16	1	1
1	40	16	1	9
1	41	16	1	9
1	42	16	5	6
1	43	16	1	9
1	44	16	1	\N
1	45	16	4	7
1	46	16	4	7
1	47	16	1	\N
1	48	16	7	\N
1	49	16	1	9
1	50	16	9	\N
1	51	16	9	\N
1	52	16	9	\N
1	53	16	9	\N
1	54	16	9	\N
1	55	16	3	2
1	56	16	3	\N
1	57	16	3	3
1	58	16	3	2
1	59	16	3	\N
1	60	16	3	3
1	1	17	1	1
1	2	17	3	2
1	3	17	1	1
1	4	17	1	\N
1	5	17	1	1
1	6	17	1	\N
1	7	17	1	1
1	8	17	2	\N
1	9	17	2	1
1	10	17	9	\N
1	11	17	9	\N
1	12	17	1	\N
1	13	17	1	\N
1	14	17	1	1
1	15	17	4	\N
1	16	17	1	1
1	17	17	9	\N
1	18	17	4	\N
1	19	17	4	7
1	20	17	9	\N
1	21	17	4	7
1	22	17	9	\N
1	23	17	3	3
1	24	17	3	\N
1	25	17	1	9
1	26	17	1	\N
1	27	17	9	\N
1	28	17	9	\N
1	29	17	9	\N
1	30	17	1	\N
1	31	17	6	\N
1	32	17	1	9
1	33	17	9	\N
1	34	17	9	\N
1	35	17	1	9
1	36	17	1	9
1	37	17	1	\N
1	38	17	1	\N
1	39	17	1	\N
1	40	17	1	1
1	41	17	1	9
1	42	17	7	\N
1	43	17	1	\N
1	44	17	1	9
1	45	17	6	\N
1	46	17	4	\N
1	47	17	4	7
1	48	17	1	\N
1	49	17	1	9
1	50	17	1	1
1	51	17	9	\N
1	52	17	1	9
1	53	17	5	6
1	54	17	3	2
1	55	17	3	\N
1	56	17	3	3
1	57	17	3	2
1	58	17	3	\N
1	59	17	9	\N
1	60	17	3	2
1	1	18	1	9
1	2	18	3	2
1	3	18	3	3
1	4	18	2	\N
1	5	18	1	\N
1	6	18	1	9
1	7	18	1	9
1	8	18	1	9
1	9	18	2	\N
1	10	18	9	\N
1	11	18	1	\N
1	12	18	1	1
1	13	18	1	9
1	14	18	1	\N
1	15	18	1	9
1	16	18	4	7
1	17	18	4	7
1	18	18	4	7
1	19	18	5	8
1	20	18	9	\N
1	21	18	9	\N
1	22	18	3	2
1	23	18	5	6
1	24	18	4	\N
1	25	18	1	\N
1	26	18	1	\N
1	27	18	2	1
1	28	18	2	1
1	29	18	9	\N
1	30	18	9	\N
1	31	18	1	9
1	32	18	1	9
1	33	18	9	\N
1	34	18	7	\N
1	35	18	1	\N
1	36	18	1	1
1	37	18	1	9
1	38	18	1	\N
1	39	18	1	1
1	40	18	9	\N
1	41	18	1	1
1	42	18	1	9
1	43	18	1	1
1	44	18	1	1
1	45	18	1	\N
1	46	18	4	7
1	47	18	4	7
1	48	18	1	\N
1	49	18	9	\N
1	50	18	9	\N
1	51	18	7	\N
1	52	18	6	\N
1	53	18	7	\N
1	54	18	3	2
1	55	18	3	\N
1	56	18	3	\N
1	57	18	3	2
1	58	18	3	2
1	59	18	9	\N
1	60	18	9	\N
1	1	19	1	9
1	2	19	7	\N
1	3	19	3	\N
1	4	19	3	2
1	5	19	1	9
1	6	19	1	9
1	7	19	1	9
1	8	19	1	1
1	9	19	1	9
1	10	19	1	9
1	11	19	1	1
1	12	19	1	1
1	13	19	1	9
1	14	19	1	9
1	15	19	1	1
1	16	19	1	9
1	17	19	4	7
1	18	19	4	7
1	19	19	4	7
1	20	19	9	\N
1	21	19	3	\N
1	22	19	3	2
1	23	19	3	2
1	24	19	1	\N
1	25	19	1	\N
1	26	19	1	\N
1	27	19	1	\N
1	28	19	2	1
1	29	19	2	1
1	30	19	2	\N
1	31	19	1	\N
1	32	19	4	7
1	33	19	1	1
1	34	19	1	9
1	35	19	1	9
1	36	19	1	1
1	37	19	1	1
1	38	19	9	\N
1	39	19	1	\N
1	40	19	9	\N
1	41	19	1	\N
1	42	19	1	\N
1	43	19	1	9
1	44	19	1	9
1	45	19	1	\N
1	46	19	1	9
1	47	19	7	\N
1	48	19	1	1
1	49	19	1	\N
1	50	19	9	\N
1	51	19	6	\N
1	52	19	2	\N
1	53	19	2	1
1	54	19	3	3
1	55	19	3	3
1	56	19	3	3
1	57	19	3	2
1	58	19	3	2
1	59	19	9	\N
1	60	19	9	\N
1	1	20	1	\N
1	2	20	1	9
1	3	20	3	2
1	4	20	6	\N
1	5	20	1	9
1	6	20	9	\N
1	7	20	1	1
1	8	20	1	9
1	9	20	1	9
1	10	20	1	\N
1	11	20	4	7
1	12	20	6	\N
1	13	20	1	1
1	14	20	3	\N
1	15	20	1	\N
1	16	20	1	9
1	17	20	1	9
1	18	20	4	7
1	19	20	4	7
1	20	20	9	\N
1	21	20	9	\N
1	22	20	3	\N
1	23	20	3	\N
1	24	20	1	\N
1	25	20	1	9
1	26	20	1	\N
1	27	20	1	9
1	28	20	1	1
1	29	20	9	\N
1	30	20	9	\N
1	31	20	9	\N
1	32	20	9	\N
1	33	20	9	\N
1	34	20	1	1
1	35	20	1	\N
1	36	20	6	\N
1	37	20	1	\N
1	38	20	1	1
1	39	20	1	\N
1	40	20	9	\N
1	41	20	1	\N
1	42	20	6	\N
1	43	20	1	\N
1	44	20	1	1
1	45	20	1	9
1	46	20	1	\N
1	47	20	1	\N
1	48	20	1	\N
1	49	20	1	1
1	50	20	9	\N
1	51	20	9	\N
1	52	20	2	1
1	53	20	3	2
1	54	20	9	\N
1	55	20	3	2
1	56	20	6	\N
1	57	20	3	2
1	58	20	7	\N
1	59	20	9	\N
1	60	20	6	\N
1	1	21	1	1
1	2	21	1	9
1	3	21	1	1
1	4	21	1	1
1	5	21	7	\N
1	6	21	9	\N
1	7	21	1	9
1	8	21	1	1
1	9	21	1	1
1	10	21	1	9
1	11	21	1	9
1	12	21	1	9
1	13	21	1	1
1	14	21	1	\N
1	15	21	7	\N
1	16	21	1	\N
1	17	21	4	\N
1	18	21	4	7
1	19	21	4	\N
1	20	21	9	\N
1	21	21	3	2
1	22	21	3	\N
1	23	21	3	3
1	24	21	1	9
1	25	21	9	\N
1	26	21	9	\N
1	27	21	1	9
1	28	21	1	1
1	29	21	1	\N
1	30	21	1	\N
1	31	21	9	\N
1	32	21	3	3
1	33	21	1	\N
1	34	21	1	1
1	35	21	6	\N
1	36	21	1	\N
1	37	21	1	9
1	38	21	1	1
1	39	21	1	9
1	40	21	9	\N
1	41	21	9	\N
1	42	21	1	9
1	43	21	1	1
1	44	21	9	\N
1	45	21	1	9
1	46	21	9	\N
1	47	21	9	\N
1	48	21	9	\N
1	49	21	1	\N
1	50	21	9	\N
1	51	21	2	\N
1	52	21	2	1
1	53	21	2	\N
1	54	21	9	\N
1	55	21	3	\N
1	56	21	3	\N
1	57	21	2	1
1	58	21	2	1
1	59	21	2	\N
1	60	21	2	1
1	1	22	1	\N
1	2	22	1	9
1	3	22	1	\N
1	4	22	1	1
1	5	22	1	1
1	6	22	1	1
1	7	22	1	9
1	8	22	6	\N
1	9	22	1	9
1	10	22	4	7
1	11	22	1	1
1	12	22	1	9
1	13	22	1	1
1	14	22	9	\N
1	15	22	9	\N
1	16	22	9	\N
1	17	22	6	\N
1	18	22	4	\N
1	19	22	4	7
1	20	22	4	7
1	21	22	3	2
1	22	22	2	1
1	23	22	3	\N
1	24	22	3	2
1	25	22	1	\N
1	26	22	9	\N
1	27	22	9	\N
1	28	22	2	1
1	29	22	1	9
1	30	22	1	1
1	31	22	1	9
1	32	22	1	\N
1	33	22	1	9
1	34	22	6	\N
1	35	22	9	\N
1	36	22	1	1
1	37	22	5	8
1	38	22	4	7
1	39	22	1	9
1	40	22	6	\N
1	41	22	1	9
1	42	22	1	9
1	43	22	1	9
1	44	22	1	9
1	45	22	1	9
1	46	22	9	\N
1	47	22	2	1
1	48	22	9	\N
1	49	22	9	\N
1	50	22	1	1
1	51	22	3	2
1	52	22	4	7
1	53	22	2	1
1	54	22	9	\N
1	55	22	9	\N
1	56	22	3	\N
1	57	22	2	1
1	58	22	3	2
1	59	22	2	\N
1	60	22	2	1
1	1	23	1	9
1	2	23	7	\N
1	3	23	1	9
1	4	23	1	\N
1	5	23	1	1
1	6	23	1	1
1	7	23	1	9
1	8	23	5	\N
1	9	23	1	\N
1	10	23	1	1
1	11	23	1	9
1	12	23	1	\N
1	13	23	1	9
1	14	23	1	1
1	15	23	9	\N
1	16	23	6	\N
1	17	23	6	\N
1	18	23	4	\N
1	19	23	1	\N
1	20	23	4	\N
1	21	23	4	7
1	22	23	3	3
1	23	23	3	3
1	24	23	3	3
1	25	23	3	2
1	26	23	1	9
1	27	23	9	\N
1	28	23	9	\N
1	29	23	9	\N
1	30	23	5	6
1	31	23	1	9
1	32	23	9	\N
1	33	23	9	\N
1	34	23	1	1
1	35	23	1	\N
1	36	23	1	1
1	37	23	1	\N
1	38	23	1	9
1	39	23	1	1
1	40	23	1	9
1	41	23	4	7
1	42	23	1	1
1	43	23	1	9
1	44	23	1	9
1	45	23	1	9
1	46	23	9	\N
1	47	23	2	\N
1	48	23	9	\N
1	49	23	1	1
1	50	23	1	9
1	51	23	1	\N
1	52	23	1	9
1	53	23	1	1
1	54	23	1	1
1	55	23	9	\N
1	56	23	9	\N
1	57	23	9	\N
1	58	23	2	\N
1	59	23	2	1
1	60	23	2	1
1	1	24	6	\N
1	2	24	1	9
1	3	24	1	1
1	4	24	1	9
1	5	24	1	9
1	6	24	1	\N
1	7	24	1	1
1	8	24	1	\N
1	9	24	1	1
1	10	24	1	9
1	11	24	1	9
1	12	24	1	\N
1	13	24	9	\N
1	14	24	1	9
1	15	24	9	\N
1	16	24	6	\N
1	17	24	7	\N
1	18	24	1	1
1	19	24	1	9
1	20	24	9	\N
1	21	24	4	7
1	22	24	3	3
1	23	24	9	\N
1	24	24	3	\N
1	25	24	3	\N
1	26	24	2	1
1	27	24	1	9
1	28	24	9	\N
1	29	24	9	\N
1	30	24	6	\N
1	31	24	1	1
1	32	24	9	\N
1	33	24	1	\N
1	34	24	3	2
1	35	24	1	\N
1	36	24	1	\N
1	37	24	5	8
1	38	24	1	9
1	39	24	1	\N
1	40	24	5	\N
1	41	24	1	\N
1	42	24	1	\N
1	43	24	1	\N
1	44	24	1	\N
1	45	24	5	\N
1	46	24	7	\N
1	47	24	2	1
1	48	24	2	\N
1	49	24	1	\N
1	50	24	1	9
1	51	24	1	1
1	52	24	7	\N
1	53	24	6	\N
1	54	24	1	1
1	55	24	9	\N
1	56	24	5	6
1	57	24	2	1
1	58	24	2	\N
1	59	24	2	\N
1	60	24	7	\N
1	1	25	1	\N
1	2	25	1	9
1	3	25	1	1
1	4	25	5	6
1	5	25	1	1
1	6	25	1	\N
1	7	25	1	1
1	8	25	1	9
1	9	25	7	\N
1	10	25	1	\N
1	11	25	1	1
1	12	25	1	\N
1	13	25	9	\N
1	14	25	9	\N
1	15	25	1	9
1	16	25	4	\N
1	17	25	3	2
1	18	25	1	1
1	19	25	1	\N
1	20	25	9	\N
1	21	25	3	\N
1	22	25	3	\N
1	23	25	9	\N
1	24	25	9	\N
1	25	25	3	\N
1	26	25	3	2
1	27	25	1	1
1	28	25	9	\N
1	29	25	6	\N
1	30	25	6	\N
1	31	25	7	\N
1	32	25	2	\N
1	33	25	1	9
1	34	25	1	1
1	35	25	1	9
1	36	25	1	9
1	37	25	9	\N
1	38	25	1	9
1	39	25	3	2
1	40	25	5	6
1	41	25	1	1
1	42	25	1	\N
1	43	25	1	9
1	44	25	1	1
1	45	25	1	9
1	46	25	1	\N
1	47	25	1	\N
1	48	25	9	\N
1	49	25	2	1
1	50	25	1	1
1	51	25	1	1
1	52	25	5	8
1	53	25	1	1
1	54	25	1	1
1	55	25	9	\N
1	56	25	9	\N
1	57	25	9	\N
1	58	25	2	1
1	59	25	2	1
1	60	25	2	\N
1	1	26	1	1
1	2	26	3	2
1	3	26	1	\N
1	4	26	1	1
1	5	26	1	1
1	6	26	1	9
1	7	26	1	\N
1	8	26	1	9
1	9	26	1	1
1	10	26	1	\N
1	11	26	1	9
1	12	26	1	1
1	13	26	1	\N
1	14	26	1	9
1	15	26	1	1
1	16	26	1	1
1	17	26	1	\N
1	18	26	7	\N
1	19	26	1	1
1	20	26	9	\N
1	21	26	3	\N
1	22	26	3	2
1	23	26	9	\N
1	24	26	3	3
1	25	26	5	8
1	26	26	3	2
1	27	26	3	2
1	28	26	1	9
1	29	26	6	\N
1	30	26	6	\N
1	31	26	6	\N
1	32	26	1	1
1	33	26	9	\N
1	34	26	1	1
1	35	26	1	1
1	36	26	1	1
1	37	26	9	\N
1	38	26	9	\N
1	39	26	1	9
1	40	26	1	9
1	41	26	1	1
1	42	26	1	9
1	43	26	1	\N
1	44	26	5	\N
1	45	26	1	\N
1	46	26	5	\N
1	47	26	1	\N
1	48	26	9	\N
1	49	26	9	\N
1	50	26	1	\N
1	51	26	1	\N
1	52	26	1	\N
1	53	26	1	9
1	54	26	1	9
1	55	26	2	1
1	56	26	2	1
1	57	26	9	\N
1	58	26	2	1
1	59	26	2	\N
1	60	26	2	1
1	1	27	1	9
1	2	27	1	9
1	3	27	1	\N
1	4	27	1	9
1	5	27	1	\N
1	6	27	1	1
1	7	27	9	\N
1	8	27	1	9
1	9	27	1	9
1	10	27	1	9
1	11	27	1	1
1	12	27	2	1
1	13	27	1	1
1	14	27	1	9
1	15	27	1	\N
1	16	27	1	1
1	17	27	1	9
1	18	27	1	\N
1	19	27	2	\N
1	20	27	1	9
1	21	27	3	3
1	22	27	3	\N
1	23	27	3	2
1	24	27	3	\N
1	25	27	3	\N
1	26	27	9	\N
1	27	27	9	\N
1	28	27	1	\N
1	29	27	1	9
1	30	27	9	\N
1	31	27	6	\N
1	32	27	4	\N
1	33	27	1	\N
1	34	27	1	9
1	35	27	1	1
1	36	27	1	\N
1	37	27	9	\N
1	38	27	1	1
1	39	27	1	9
1	40	27	1	9
1	41	27	7	\N
1	42	27	1	1
1	43	27	8	\N
1	44	27	1	9
1	45	27	1	\N
1	46	27	1	\N
1	47	27	1	1
1	48	27	2	\N
1	49	27	1	1
1	50	27	1	9
1	51	27	2	1
1	52	27	9	\N
1	53	27	1	1
1	54	27	1	1
1	55	27	6	\N
1	56	27	3	2
1	57	27	3	3
1	58	27	2	1
1	59	27	4	7
1	60	27	2	1
1	1	28	2	1
1	2	28	1	\N
1	3	28	1	\N
1	4	28	1	9
1	5	28	1	\N
1	6	28	1	9
1	7	28	9	\N
1	8	28	9	\N
1	9	28	9	\N
1	10	28	9	\N
1	11	28	9	\N
1	12	28	4	7
1	13	28	1	9
1	14	28	1	1
1	15	28	1	\N
1	16	28	1	\N
1	17	28	1	9
1	18	28	1	9
1	19	28	1	1
1	20	28	1	\N
1	21	28	1	\N
1	22	28	3	2
1	23	28	3	3
1	24	28	1	1
1	25	28	3	\N
1	26	28	3	3
1	27	28	9	\N
1	28	28	9	\N
1	29	28	9	\N
1	30	28	1	9
1	31	28	1	1
1	32	28	1	1
1	33	28	1	1
1	34	28	1	1
1	35	28	8	\N
1	36	28	1	1
1	37	28	1	9
1	38	28	1	1
1	39	28	1	1
1	40	28	1	9
1	41	28	1	9
1	42	28	1	\N
1	43	28	8	\N
1	44	28	1	\N
1	45	28	1	1
1	46	28	1	\N
1	47	28	1	1
1	48	28	3	3
1	49	28	1	\N
1	50	28	3	3
1	51	28	1	9
1	52	28	9	\N
1	53	28	2	\N
1	54	28	1	1
1	55	28	1	1
1	56	28	3	\N
1	57	28	3	2
1	58	28	3	2
1	59	28	2	\N
1	60	28	2	\N
1	1	29	1	\N
1	2	29	1	1
1	3	29	9	\N
1	4	29	1	\N
1	5	29	1	\N
1	6	29	1	\N
1	7	29	1	1
1	8	29	1	\N
1	9	29	9	\N
1	10	29	2	\N
1	11	29	2	1
1	12	29	1	\N
1	13	29	1	\N
1	14	29	1	9
1	15	29	1	9
1	16	29	1	\N
1	17	29	1	1
1	18	29	8	\N
1	19	29	4	7
1	20	29	1	1
1	21	29	9	\N
1	22	29	3	\N
1	23	29	3	2
1	24	29	6	\N
1	25	29	3	2
1	26	29	3	2
1	27	29	3	3
1	28	29	3	2
1	29	29	9	\N
1	30	29	9	\N
1	31	29	9	\N
1	32	29	1	\N
1	33	29	1	9
1	34	29	1	9
1	35	29	1	\N
1	36	29	1	1
1	37	29	1	\N
1	38	29	1	9
1	39	29	7	\N
1	40	29	1	9
1	41	29	1	9
1	42	29	1	\N
1	43	29	1	9
1	44	29	1	9
1	45	29	1	1
1	46	29	9	\N
1	47	29	1	9
1	48	29	4	7
1	49	29	7	\N
1	50	29	1	9
1	51	29	5	6
1	52	29	1	9
1	53	29	1	\N
1	54	29	9	\N
1	55	29	1	1
1	56	29	1	\N
1	57	29	3	3
1	58	29	3	2
1	59	29	1	1
1	60	29	2	1
1	1	30	9	\N
1	2	30	9	\N
1	3	30	7	\N
1	4	30	5	6
1	5	30	1	1
1	6	30	1	\N
1	7	30	1	\N
1	8	30	1	9
1	9	30	1	1
1	10	30	2	1
1	11	30	2	\N
1	12	30	1	\N
1	13	30	1	1
1	14	30	1	1
1	15	30	1	\N
1	16	30	1	\N
1	17	30	5	8
1	18	30	8	\N
1	19	30	8	\N
1	20	30	8	\N
1	21	30	8	\N
1	22	30	8	\N
1	23	30	3	2
1	24	30	3	3
1	25	30	3	\N
1	26	30	3	2
1	27	30	6	\N
1	28	30	3	\N
1	29	30	9	\N
1	30	30	4	\N
1	31	30	1	1
1	32	30	1	9
1	33	30	1	\N
1	34	30	1	1
1	35	30	1	9
1	36	30	1	\N
1	37	30	3	3
1	38	30	1	9
1	39	30	1	1
1	40	30	1	1
1	41	30	1	\N
1	42	30	1	9
1	43	30	1	9
1	44	30	1	1
1	45	30	1	1
1	46	30	1	1
1	47	30	1	1
1	48	30	1	\N
1	49	30	1	9
1	50	30	1	\N
1	51	30	1	9
1	52	30	1	1
1	53	30	1	9
1	54	30	1	9
1	55	30	1	\N
1	56	30	1	9
1	57	30	1	1
1	58	30	1	1
1	59	30	1	\N
1	60	30	3	2
1	1	31	9	\N
1	2	31	7	\N
1	3	31	3	2
1	4	31	1	1
1	5	31	1	\N
1	6	31	1	9
1	7	31	1	\N
1	8	31	1	9
1	9	31	1	\N
1	10	31	1	\N
1	11	31	1	9
1	12	31	9	\N
1	13	31	9	\N
1	14	31	1	9
1	15	31	1	1
1	16	31	1	9
1	17	31	8	\N
1	18	31	8	\N
1	19	31	8	\N
1	20	31	8	\N
1	21	31	8	\N
1	22	31	8	\N
1	23	31	3	3
1	24	31	3	2
1	25	31	4	7
1	26	31	3	2
1	27	31	3	3
1	28	31	3	\N
1	29	31	9	\N
1	30	31	9	\N
1	31	31	1	9
1	32	31	1	\N
1	33	31	1	9
1	34	31	6	\N
1	35	31	1	\N
1	36	31	1	1
1	37	31	1	9
1	38	31	1	9
1	39	31	6	\N
1	40	31	1	9
1	41	31	1	1
1	42	31	1	\N
1	43	31	1	1
1	44	31	2	1
1	45	31	1	9
1	46	31	6	\N
1	47	31	4	7
1	48	31	9	\N
1	49	31	1	\N
1	50	31	1	9
1	51	31	3	\N
1	52	31	9	\N
1	53	31	1	1
1	54	31	1	\N
1	55	31	1	9
1	56	31	1	\N
1	57	31	1	9
1	58	31	1	\N
1	59	31	1	1
1	60	31	1	\N
1	1	32	7	\N
1	2	32	4	7
1	3	32	9	\N
1	4	32	1	1
1	5	32	1	9
1	6	32	1	9
1	7	32	1	\N
1	8	32	1	9
1	9	32	1	\N
1	10	32	1	1
1	11	32	1	9
1	12	32	9	\N
1	13	32	4	\N
1	14	32	1	\N
1	15	32	1	1
1	16	32	1	9
1	17	32	8	\N
1	18	32	8	\N
1	19	32	8	\N
1	20	32	8	\N
1	21	32	8	\N
1	22	32	8	\N
1	23	32	8	\N
1	24	32	8	\N
1	25	32	3	2
1	26	32	7	\N
1	27	32	3	\N
1	28	32	3	2
1	29	32	3	3
1	30	32	9	\N
1	31	32	1	9
1	32	32	1	9
1	33	32	1	9
1	34	32	1	1
1	35	32	1	1
1	36	32	3	3
1	37	32	1	9
1	38	32	6	\N
1	39	32	9	\N
1	40	32	9	\N
1	41	32	9	\N
1	42	32	9	\N
1	43	32	9	\N
1	44	32	9	\N
1	45	32	1	1
1	46	32	2	1
1	47	32	2	1
1	48	32	9	\N
1	49	32	9	\N
1	50	32	1	\N
1	51	32	1	1
1	52	32	1	1
1	53	32	1	\N
1	54	32	1	9
1	55	32	2	1
1	56	32	4	7
1	57	32	4	7
1	58	32	1	9
1	59	32	9	\N
1	60	32	9	\N
1	1	33	4	\N
1	2	33	4	7
1	3	33	9	\N
1	4	33	9	\N
1	5	33	5	\N
1	6	33	1	\N
1	7	33	7	\N
1	8	33	8	\N
1	9	33	8	\N
1	10	33	8	\N
1	11	33	8	\N
1	12	33	8	\N
1	13	33	3	3
1	14	33	7	\N
1	15	33	1	1
1	16	33	1	\N
1	17	33	1	\N
1	18	33	8	\N
1	19	33	8	\N
1	20	33	8	\N
1	21	33	8	\N
1	22	33	8	\N
1	23	33	8	\N
1	24	33	8	\N
1	25	33	3	2
1	26	33	2	\N
1	27	33	3	3
1	28	33	3	2
1	29	33	3	2
1	30	33	3	3
1	31	33	1	1
1	32	33	1	\N
1	33	33	9	\N
1	34	33	9	\N
1	35	33	1	1
1	36	33	1	1
1	37	33	1	9
1	38	33	1	9
1	39	33	9	\N
1	40	33	6	\N
1	41	33	6	\N
1	42	33	6	\N
1	43	33	9	\N
1	44	33	1	\N
1	45	33	5	6
1	46	33	2	1
1	47	33	2	\N
1	48	33	9	\N
1	49	33	9	\N
1	50	33	1	\N
1	51	33	1	\N
1	52	33	1	9
1	53	33	1	9
1	54	33	7	\N
1	55	33	1	9
1	56	33	7	\N
1	57	33	4	7
1	58	33	4	\N
1	59	33	1	9
1	60	33	1	1
1	1	34	4	\N
1	2	34	4	7
1	3	34	9	\N
1	4	34	5	8
1	5	34	5	8
1	6	34	5	\N
1	7	34	1	9
1	8	34	1	1
1	9	34	1	9
1	10	34	8	\N
1	11	34	7	\N
1	12	34	8	\N
1	13	34	8	\N
1	14	34	8	\N
1	15	34	1	1
1	16	34	1	1
1	17	34	1	9
1	18	34	8	\N
1	19	34	8	\N
1	20	34	8	\N
1	21	34	8	\N
1	22	34	3	3
1	23	34	8	\N
1	24	34	8	\N
1	25	34	8	\N
1	26	34	8	\N
1	27	34	3	2
1	28	34	3	2
1	29	34	3	2
1	30	34	3	2
1	31	34	1	\N
1	32	34	1	\N
1	33	34	9	\N
1	34	34	1	\N
1	35	34	1	9
1	36	34	1	\N
1	37	34	1	9
1	38	34	6	\N
1	39	34	6	\N
1	40	34	6	\N
1	41	34	6	\N
1	42	34	4	7
1	43	34	9	\N
1	44	34	9	\N
1	45	34	1	1
1	46	34	2	1
1	47	34	2	\N
1	48	34	9	\N
1	49	34	1	9
1	50	34	1	\N
1	51	34	1	1
1	52	34	1	\N
1	53	34	1	9
1	54	34	1	9
1	55	34	1	9
1	56	34	1	9
1	57	34	5	\N
1	58	34	4	7
1	59	34	1	1
1	60	34	1	\N
1	1	35	4	\N
1	2	35	4	7
1	3	35	9	\N
1	4	35	5	8
1	5	35	5	8
1	6	35	7	\N
1	7	35	1	\N
1	8	35	9	\N
1	9	35	8	\N
1	10	35	8	\N
1	11	35	8	\N
1	12	35	8	\N
1	13	35	8	\N
1	14	35	8	\N
1	15	35	1	1
1	16	35	1	1
1	17	35	8	\N
1	18	35	8	\N
1	19	35	8	\N
1	20	35	8	\N
1	21	35	8	\N
1	22	35	8	\N
1	23	35	8	\N
1	24	35	8	\N
1	25	35	8	\N
1	26	35	8	\N
1	27	35	8	\N
1	28	35	3	\N
1	29	35	2	\N
1	30	35	3	\N
1	31	35	1	9
1	32	35	1	1
1	33	35	9	\N
1	34	35	9	\N
1	35	35	1	9
1	36	35	1	9
1	37	35	1	\N
1	38	35	1	1
1	39	35	5	6
1	40	35	6	\N
1	41	35	6	\N
1	42	35	6	\N
1	43	35	5	\N
1	44	35	9	\N
1	45	35	3	2
1	46	35	2	1
1	47	35	2	1
1	48	35	9	\N
1	49	35	9	\N
1	50	35	1	1
1	51	35	2	\N
1	52	35	1	9
1	53	35	1	9
1	54	35	1	9
1	55	35	1	9
1	56	35	1	9
1	57	35	1	1
1	58	35	1	1
1	59	35	2	1
1	60	35	1	\N
1	1	36	5	8
1	2	36	4	\N
1	3	36	9	\N
1	4	36	5	\N
1	5	36	5	6
1	6	36	5	8
1	7	36	1	1
1	8	36	8	\N
1	9	36	8	\N
1	10	36	8	\N
1	11	36	8	\N
1	12	36	8	\N
1	13	36	8	\N
1	14	36	8	\N
1	15	36	1	9
1	16	36	7	\N
1	17	36	1	1
1	18	36	8	\N
1	19	36	8	\N
1	20	36	8	\N
1	21	36	8	\N
1	22	36	8	\N
1	23	36	8	\N
1	24	36	8	\N
1	25	36	8	\N
1	26	36	8	\N
1	27	36	8	\N
1	28	36	2	1
1	29	36	8	\N
1	30	36	3	2
1	31	36	1	9
1	32	36	2	\N
1	33	36	1	\N
1	34	36	1	1
1	35	36	7	\N
1	36	36	9	\N
1	37	36	9	\N
1	38	36	9	\N
1	39	36	3	\N
1	40	36	6	\N
1	41	36	6	\N
1	42	36	9	\N
1	43	36	5	\N
1	44	36	5	8
1	45	36	2	\N
1	46	36	2	\N
1	47	36	2	\N
1	48	36	5	6
1	49	36	9	\N
1	50	36	9	\N
1	51	36	9	\N
1	52	36	1	1
1	53	36	1	1
1	54	36	9	\N
1	55	36	1	\N
1	56	36	1	1
1	57	36	1	\N
1	58	36	1	\N
1	59	36	6	\N
1	60	36	1	9
1	1	37	7	\N
1	2	37	4	7
1	3	37	4	7
1	4	37	5	8
1	5	37	5	6
1	6	37	2	1
1	7	37	1	9
1	8	37	8	\N
1	9	37	8	\N
1	10	37	3	3
1	11	37	8	\N
1	12	37	8	\N
1	13	37	8	\N
1	14	37	8	\N
1	15	37	7	\N
1	16	37	1	\N
1	17	37	6	\N
1	18	37	8	\N
1	19	37	8	\N
1	20	37	8	\N
1	21	37	8	\N
1	22	37	8	\N
1	23	37	8	\N
1	24	37	8	\N
1	25	37	8	\N
1	26	37	8	\N
1	27	37	8	\N
1	28	37	8	\N
1	29	37	3	2
1	30	37	2	1
1	31	37	2	\N
1	32	37	1	9
1	33	37	1	\N
1	34	37	1	\N
1	35	37	5	\N
1	36	37	5	6
1	37	37	4	7
1	38	37	3	3
1	39	37	3	\N
1	40	37	3	3
1	41	37	6	\N
1	42	37	6	\N
1	43	37	5	\N
1	44	37	6	\N
1	45	37	2	\N
1	46	37	2	1
1	47	37	2	\N
1	48	37	2	\N
1	49	37	2	\N
1	50	37	9	\N
1	51	37	3	3
1	52	37	1	1
1	53	37	1	\N
1	54	37	9	\N
1	55	37	9	\N
1	56	37	9	\N
1	57	37	9	\N
1	58	37	1	9
1	59	37	1	9
1	60	37	1	9
1	1	38	4	7
1	2	38	4	7
1	3	38	4	7
1	4	38	4	\N
1	5	38	5	\N
1	6	38	5	\N
1	7	38	4	7
1	8	38	8	\N
1	9	38	8	\N
1	10	38	8	\N
1	11	38	8	\N
1	12	38	8	\N
1	13	38	8	\N
1	14	38	8	\N
1	15	38	8	\N
1	16	38	8	\N
1	17	38	8	\N
1	18	38	1	1
1	19	38	8	\N
1	20	38	8	\N
1	21	38	8	\N
1	22	38	8	\N
1	23	38	8	\N
1	24	38	8	\N
1	25	38	8	\N
1	26	38	8	\N
1	27	38	8	\N
1	28	38	8	\N
1	29	38	2	1
1	30	38	2	1
1	31	38	5	\N
1	32	38	1	9
1	33	38	8	\N
1	34	38	1	\N
1	35	38	1	9
1	36	38	5	\N
1	37	38	4	7
1	38	38	3	\N
1	39	38	3	3
1	40	38	3	3
1	41	38	6	\N
1	42	38	6	\N
1	43	38	2	1
1	44	38	7	\N
1	45	38	2	1
1	46	38	2	1
1	47	38	2	1
1	48	38	2	1
1	49	38	2	1
1	50	38	9	\N
1	51	38	9	\N
1	52	38	1	\N
1	53	38	1	1
1	54	38	9	\N
1	55	38	1	9
1	56	38	1	9
1	57	38	9	\N
1	58	38	1	9
1	59	38	1	\N
1	60	38	4	\N
1	1	39	4	\N
1	2	39	4	7
1	3	39	4	7
1	4	39	4	\N
1	5	39	4	7
1	6	39	4	7
1	7	39	8	\N
1	8	39	8	\N
1	9	39	8	\N
1	10	39	8	\N
1	11	39	8	\N
1	12	39	8	\N
1	13	39	8	\N
1	14	39	8	\N
1	15	39	8	\N
1	16	39	8	\N
1	17	39	8	\N
1	18	39	1	9
1	19	39	1	9
1	20	39	8	\N
1	21	39	8	\N
1	22	39	8	\N
1	23	39	8	\N
1	24	39	8	\N
1	25	39	8	\N
1	26	39	8	\N
1	27	39	8	\N
1	28	39	8	\N
1	29	39	2	1
1	30	39	2	\N
1	31	39	2	1
1	32	39	1	\N
1	33	39	8	\N
1	34	39	1	\N
1	35	39	1	\N
1	36	39	1	1
1	37	39	1	9
1	38	39	3	2
1	39	39	3	\N
1	40	39	3	2
1	41	39	1	9
1	42	39	1	1
1	43	39	1	9
1	44	39	2	\N
1	45	39	2	\N
1	46	39	2	1
1	47	39	2	\N
1	48	39	3	2
1	49	39	2	1
1	50	39	2	\N
1	51	39	9	\N
1	52	39	9	\N
1	53	39	9	\N
1	54	39	9	\N
1	55	39	9	\N
1	56	39	9	\N
1	57	39	1	1
1	58	39	1	9
1	59	39	1	\N
1	60	39	1	\N
1	1	40	1	\N
1	2	40	6	\N
1	3	40	4	\N
1	4	40	4	\N
1	5	40	9	\N
1	6	40	8	\N
1	7	40	8	\N
1	8	40	8	\N
1	9	40	8	\N
1	10	40	8	\N
1	11	40	8	\N
1	12	40	8	\N
1	13	40	8	\N
1	14	40	8	\N
1	15	40	8	\N
1	16	40	8	\N
1	17	40	8	\N
1	18	40	1	\N
1	19	40	8	\N
1	20	40	8	\N
1	21	40	8	\N
1	22	40	8	\N
1	23	40	8	\N
1	24	40	8	\N
1	25	40	8	\N
1	26	40	8	\N
1	27	40	8	\N
1	28	40	8	\N
1	29	40	8	\N
1	30	40	2	1
1	31	40	2	1
1	32	40	8	\N
1	33	40	1	\N
1	34	40	1	\N
1	35	40	1	1
1	36	40	1	\N
1	37	40	1	1
1	38	40	1	1
1	39	40	3	2
1	40	40	3	2
1	41	40	1	9
1	42	40	1	1
1	43	40	2	1
1	44	40	2	1
1	45	40	2	1
1	46	40	2	1
1	47	40	1	1
1	48	40	2	\N
1	49	40	7	\N
1	50	40	4	7
1	51	40	9	\N
1	52	40	7	\N
1	53	40	9	\N
1	54	40	5	6
1	55	40	9	\N
1	56	40	6	\N
1	57	40	1	1
1	58	40	1	1
1	59	40	1	9
1	60	40	9	\N
1	1	41	1	9
1	2	41	1	9
1	3	41	3	2
1	4	41	4	7
1	5	41	8	\N
1	6	41	8	\N
1	7	41	8	\N
1	8	41	8	\N
1	9	41	8	\N
1	10	41	8	\N
1	11	41	8	\N
1	12	41	8	\N
1	13	41	8	\N
1	14	41	1	9
1	15	41	8	\N
1	16	41	8	\N
1	17	41	8	\N
1	18	41	8	\N
1	19	41	8	\N
1	20	41	8	\N
1	21	41	8	\N
1	22	41	8	\N
1	23	41	8	\N
1	24	41	8	\N
1	25	41	8	\N
1	26	41	8	\N
1	27	41	8	\N
1	28	41	8	\N
1	29	41	8	\N
1	30	41	2	1
1	31	41	2	1
1	32	41	2	\N
1	33	41	8	\N
1	34	41	8	\N
1	35	41	1	1
1	36	41	6	\N
1	37	41	1	\N
1	38	41	1	1
1	39	41	1	\N
1	40	41	4	\N
1	41	41	5	\N
1	42	41	1	\N
1	43	41	1	9
1	44	41	2	\N
1	45	41	2	1
1	46	41	2	1
1	47	41	2	\N
1	48	41	2	1
1	49	41	1	9
1	50	41	6	\N
1	51	41	9	\N
1	52	41	7	\N
1	53	41	7	\N
1	54	41	5	8
1	55	41	9	\N
1	56	41	1	\N
1	57	41	3	3
1	58	41	1	1
1	59	41	1	1
1	60	41	1	9
1	1	42	1	9
1	2	42	1	1
1	3	42	5	8
1	4	42	8	\N
1	5	42	8	\N
1	6	42	8	\N
1	7	42	8	\N
1	8	42	8	\N
1	9	42	8	\N
1	10	42	8	\N
1	11	42	8	\N
1	12	42	8	\N
1	13	42	8	\N
1	14	42	8	\N
1	15	42	8	\N
1	16	42	8	\N
1	17	42	8	\N
1	18	42	8	\N
1	19	42	8	\N
1	20	42	3	3
1	21	42	8	\N
1	22	42	8	\N
1	23	42	8	\N
1	24	42	8	\N
1	25	42	8	\N
1	26	42	8	\N
1	27	42	8	\N
1	28	42	8	\N
1	29	42	8	\N
1	30	42	8	\N
1	31	42	2	1
1	32	42	2	1
1	33	42	4	7
1	34	42	1	9
1	35	42	8	\N
1	36	42	1	1
1	37	42	1	\N
1	38	42	1	1
1	39	42	1	\N
1	40	42	5	\N
1	41	42	5	6
1	42	42	9	\N
1	43	42	9	\N
1	44	42	2	\N
1	45	42	2	1
1	46	42	2	\N
1	47	42	2	\N
1	48	42	2	1
1	49	42	2	1
1	50	42	1	1
1	51	42	9	\N
1	52	42	9	\N
1	53	42	4	7
1	54	42	4	\N
1	55	42	2	1
1	56	42	1	\N
1	57	42	1	1
1	58	42	1	1
1	59	42	1	9
1	60	42	9	\N
1	1	43	1	1
1	2	43	1	9
1	3	43	1	1
1	4	43	1	\N
1	5	43	8	\N
1	6	43	8	\N
1	7	43	8	\N
1	8	43	8	\N
1	9	43	8	\N
1	10	43	8	\N
1	11	43	8	\N
1	12	43	8	\N
1	13	43	8	\N
1	14	43	8	\N
1	15	43	8	\N
1	16	43	8	\N
1	17	43	8	\N
1	18	43	8	\N
1	19	43	8	\N
1	20	43	8	\N
1	21	43	8	\N
1	22	43	8	\N
1	23	43	8	\N
1	24	43	8	\N
1	25	43	8	\N
1	26	43	8	\N
1	27	43	8	\N
1	28	43	8	\N
1	29	43	8	\N
1	30	43	8	\N
1	31	43	8	\N
1	32	43	8	\N
1	33	43	7	\N
1	34	43	1	1
1	35	43	1	9
1	36	43	8	\N
1	37	43	8	\N
1	38	43	1	9
1	39	43	5	8
1	40	43	5	\N
1	41	43	5	\N
1	42	43	9	\N
1	43	43	9	\N
1	44	43	2	\N
1	45	43	2	1
1	46	43	2	\N
1	47	43	2	\N
1	48	43	6	\N
1	49	43	2	1
1	50	43	2	1
1	51	43	1	\N
1	52	43	1	\N
1	53	43	4	7
1	54	43	4	\N
1	55	43	4	\N
1	56	43	1	\N
1	57	43	1	\N
1	58	43	3	2
1	59	43	1	\N
1	60	43	1	9
1	1	44	5	6
1	2	44	9	\N
1	3	44	9	\N
1	4	44	8	\N
1	5	44	8	\N
1	6	44	8	\N
1	7	44	8	\N
1	8	44	8	\N
1	9	44	8	\N
1	10	44	8	\N
1	11	44	8	\N
1	12	44	8	\N
1	13	44	8	\N
1	14	44	8	\N
1	15	44	8	\N
1	16	44	8	\N
1	17	44	7	\N
1	18	44	8	\N
1	19	44	8	\N
1	20	44	8	\N
1	21	44	8	\N
1	22	44	8	\N
1	23	44	8	\N
1	24	44	8	\N
1	25	44	8	\N
1	26	44	1	1
1	27	44	8	\N
1	28	44	8	\N
1	29	44	8	\N
1	30	44	8	\N
1	31	44	8	\N
1	32	44	8	\N
1	33	44	8	\N
1	34	44	1	1
1	35	44	1	9
1	36	44	1	\N
1	37	44	8	\N
1	38	44	8	\N
1	39	44	8	\N
1	40	44	8	\N
1	41	44	5	6
1	42	44	5	6
1	43	44	2	1
1	44	44	4	7
1	45	44	2	1
1	46	44	9	\N
1	47	44	9	\N
1	48	44	3	2
1	49	44	2	\N
1	50	44	2	\N
1	51	44	1	\N
1	52	44	1	1
1	53	44	1	1
1	54	44	4	\N
1	55	44	4	7
1	56	44	1	1
1	57	44	4	\N
1	58	44	1	\N
1	59	44	1	1
1	60	44	1	1
1	1	45	5	\N
1	2	45	5	\N
1	3	45	8	\N
1	4	45	8	\N
1	5	45	8	\N
1	6	45	8	\N
1	7	45	8	\N
1	8	45	8	\N
1	9	45	8	\N
1	10	45	8	\N
1	11	45	8	\N
1	12	45	8	\N
1	13	45	8	\N
1	14	45	8	\N
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
1	29	45	8	\N
1	30	45	8	\N
1	31	45	8	\N
1	32	45	8	\N
1	33	45	8	\N
1	34	45	8	\N
1	35	45	8	\N
1	36	45	4	\N
1	37	45	1	9
1	38	45	8	\N
1	39	45	8	\N
1	40	45	8	\N
1	41	45	5	\N
1	42	45	9	\N
1	43	45	2	1
1	44	45	2	\N
1	45	45	2	1
1	46	45	1	1
1	47	45	1	1
1	48	45	4	\N
1	49	45	2	1
1	50	45	2	\N
1	51	45	1	9
1	52	45	6	\N
1	53	45	1	1
1	54	45	1	1
1	55	45	1	9
1	56	45	1	\N
1	57	45	7	\N
1	58	45	1	\N
1	59	45	1	\N
1	60	45	1	1
1	1	46	5	6
1	2	46	8	\N
1	3	46	8	\N
1	4	46	8	\N
1	5	46	8	\N
1	6	46	8	\N
1	7	46	8	\N
1	8	46	8	\N
1	9	46	8	\N
1	10	46	8	\N
1	11	46	8	\N
1	12	46	8	\N
1	13	46	8	\N
1	14	46	8	\N
1	15	46	8	\N
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
1	27	46	7	\N
1	28	46	8	\N
1	29	46	8	\N
1	30	46	8	\N
1	31	46	8	\N
1	32	46	8	\N
1	33	46	8	\N
1	34	46	8	\N
1	35	46	8	\N
1	36	46	1	1
1	37	46	1	9
1	38	46	1	1
1	39	46	8	\N
1	40	46	8	\N
1	41	46	5	6
1	42	46	9	\N
1	43	46	9	\N
1	44	46	9	\N
1	45	46	2	1
1	46	46	1	1
1	47	46	5	\N
1	48	46	9	\N
1	49	46	9	\N
1	50	46	4	7
1	51	46	4	\N
1	52	46	1	1
1	53	46	1	9
1	54	46	1	9
1	55	46	1	9
1	56	46	1	\N
1	57	46	6	\N
1	58	46	1	\N
1	59	46	1	1
1	60	46	9	\N
1	1	47	5	\N
1	2	47	8	\N
1	3	47	8	\N
1	4	47	8	\N
1	5	47	8	\N
1	6	47	8	\N
1	7	47	8	\N
1	8	47	8	\N
1	9	47	8	\N
1	10	47	8	\N
1	11	47	8	\N
1	12	47	8	\N
1	13	47	6	\N
1	14	47	8	\N
1	15	47	8	\N
1	16	47	8	\N
1	17	47	8	\N
1	18	47	8	\N
1	19	47	8	\N
1	20	47	8	\N
1	21	47	8	\N
1	22	47	8	\N
1	23	47	8	\N
1	24	47	8	\N
1	25	47	8	\N
1	26	47	7	\N
1	27	47	8	\N
1	28	47	8	\N
1	29	47	6	\N
1	30	47	8	\N
1	31	47	8	\N
1	32	47	8	\N
1	33	47	8	\N
1	34	47	8	\N
1	35	47	8	\N
1	36	47	8	\N
1	37	47	1	\N
1	38	47	1	\N
1	39	47	8	\N
1	40	47	8	\N
1	41	47	5	6
1	42	47	9	\N
1	43	47	4	7
1	44	47	9	\N
1	45	47	1	9
1	46	47	3	3
1	47	47	1	1
1	48	47	1	9
1	49	47	9	\N
1	50	47	9	\N
1	51	47	4	\N
1	52	47	1	1
1	53	47	2	1
1	54	47	1	1
1	55	47	1	9
1	56	47	1	\N
1	57	47	1	\N
1	58	47	9	\N
1	59	47	1	1
1	60	47	9	\N
1	1	48	5	\N
1	2	48	7	\N
1	3	48	8	\N
1	4	48	8	\N
1	5	48	8	\N
1	6	48	8	\N
1	7	48	8	\N
1	8	48	8	\N
1	9	48	8	\N
1	10	48	8	\N
1	11	48	8	\N
1	12	48	8	\N
1	13	48	8	\N
1	14	48	8	\N
1	15	48	8	\N
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
1	26	48	8	\N
1	27	48	8	\N
1	28	48	8	\N
1	29	48	8	\N
1	30	48	8	\N
1	31	48	8	\N
1	32	48	8	\N
1	33	48	8	\N
1	34	48	8	\N
1	35	48	8	\N
1	36	48	8	\N
1	37	48	8	\N
1	38	48	8	\N
1	39	48	8	\N
1	40	48	8	\N
1	41	48	8	\N
1	42	48	4	7
1	43	48	4	\N
1	44	48	9	\N
1	45	48	9	\N
1	46	48	1	9
1	47	48	1	9
1	48	48	1	\N
1	49	48	2	1
1	50	48	2	1
1	51	48	1	1
1	52	48	1	9
1	53	48	1	\N
1	54	48	1	\N
1	55	48	1	1
1	56	48	1	9
1	57	48	1	\N
1	58	48	9	\N
1	59	48	9	\N
1	60	48	1	1
1	1	49	5	8
1	2	49	5	6
1	3	49	8	\N
1	4	49	8	\N
1	5	49	8	\N
1	6	49	8	\N
1	7	49	8	\N
1	8	49	8	\N
1	9	49	8	\N
1	10	49	8	\N
1	11	49	8	\N
1	12	49	7	\N
1	13	49	8	\N
1	14	49	8	\N
1	15	49	8	\N
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
1	26	49	8	\N
1	27	49	8	\N
1	28	49	8	\N
1	29	49	8	\N
1	30	49	8	\N
1	31	49	8	\N
1	32	49	8	\N
1	33	49	8	\N
1	34	49	7	\N
1	35	49	8	\N
1	36	49	8	\N
1	37	49	8	\N
1	38	49	8	\N
1	39	49	8	\N
1	40	49	8	\N
1	41	49	8	\N
1	42	49	8	\N
1	43	49	4	7
1	44	49	9	\N
1	45	49	1	\N
1	46	49	1	1
1	47	49	1	9
1	48	49	1	\N
1	49	49	1	9
1	50	49	1	1
1	51	49	1	1
1	52	49	1	\N
1	53	49	1	9
1	54	49	1	\N
1	55	49	1	\N
1	56	49	1	\N
1	57	49	1	9
1	58	49	9	\N
1	59	49	2	1
1	60	49	1	1
1	1	50	5	6
1	2	50	8	\N
1	3	50	8	\N
1	4	50	8	\N
1	5	50	8	\N
1	6	50	8	\N
1	7	50	8	\N
1	8	50	8	\N
1	9	50	8	\N
1	10	50	8	\N
1	11	50	8	\N
1	12	50	8	\N
1	13	50	8	\N
1	14	50	8	\N
1	15	50	7	\N
1	16	50	8	\N
1	17	50	8	\N
1	18	50	8	\N
1	19	50	1	\N
1	20	50	8	\N
1	21	50	8	\N
1	22	50	8	\N
1	23	50	8	\N
1	24	50	8	\N
1	25	50	8	\N
1	26	50	8	\N
1	27	50	8	\N
1	28	50	8	\N
1	29	50	8	\N
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
1	43	50	4	\N
1	44	50	9	\N
1	45	50	9	\N
1	46	50	9	\N
1	47	50	9	\N
1	48	50	9	\N
1	49	50	9	\N
1	50	50	1	1
1	51	50	1	9
1	52	50	1	\N
1	53	50	1	\N
1	54	50	5	\N
1	55	50	1	1
1	56	50	7	\N
1	57	50	1	9
1	58	50	9	\N
1	59	50	6	\N
1	60	50	9	\N
1	1	51	5	6
1	2	51	5	\N
1	3	51	8	\N
1	4	51	8	\N
1	5	51	8	\N
1	6	51	8	\N
1	7	51	8	\N
1	8	51	8	\N
1	9	51	8	\N
1	10	51	8	\N
1	11	51	8	\N
1	12	51	8	\N
1	13	51	8	\N
1	14	51	1	1
1	15	51	7	\N
1	16	51	7	\N
1	17	51	8	\N
1	18	51	8	\N
1	19	51	8	\N
1	20	51	8	\N
1	21	51	8	\N
1	22	51	8	\N
1	23	51	8	\N
1	24	51	8	\N
1	25	51	3	3
1	26	51	8	\N
1	27	51	8	\N
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
1	47	51	8	\N
1	48	51	8	\N
1	49	51	8	\N
1	50	51	1	1
1	51	51	4	\N
1	52	51	6	\N
1	53	51	1	9
1	54	51	1	1
1	55	51	1	\N
1	56	51	1	\N
1	57	51	1	\N
1	58	51	2	1
1	59	51	2	1
1	60	51	9	\N
1	1	52	3	2
1	2	52	8	\N
1	3	52	8	\N
1	4	52	8	\N
1	5	52	8	\N
1	6	52	8	\N
1	7	52	8	\N
1	8	52	8	\N
1	9	52	8	\N
1	10	52	8	\N
1	11	52	8	\N
1	12	52	8	\N
1	13	52	8	\N
1	14	52	8	\N
1	15	52	8	\N
1	16	52	7	\N
1	17	52	1	\N
1	18	52	8	\N
1	19	52	8	\N
1	20	52	8	\N
1	21	52	8	\N
1	22	52	8	\N
1	23	52	2	1
1	24	52	2	1
1	25	52	2	\N
1	26	52	2	\N
1	27	52	8	\N
1	28	52	8	\N
1	29	52	8	\N
1	30	52	8	\N
1	31	52	8	\N
1	32	52	8	\N
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
1	50	52	1	1
1	51	52	1	1
1	52	52	9	\N
1	53	52	1	\N
1	54	52	9	\N
1	55	52	9	\N
1	56	52	2	1
1	57	52	2	1
1	58	52	2	1
1	59	52	2	1
1	60	52	9	\N
1	1	53	3	3
1	2	53	8	\N
1	3	53	8	\N
1	4	53	8	\N
1	5	53	8	\N
1	6	53	8	\N
1	7	53	8	\N
1	8	53	8	\N
1	9	53	8	\N
1	10	53	8	\N
1	11	53	8	\N
1	12	53	8	\N
1	13	53	8	\N
1	14	53	8	\N
1	15	53	8	\N
1	16	53	8	\N
1	17	53	8	\N
1	18	53	8	\N
1	19	53	8	\N
1	20	53	8	\N
1	21	53	8	\N
1	22	53	8	\N
1	23	53	8	\N
1	24	53	2	\N
1	25	53	3	2
1	26	53	2	\N
1	27	53	3	\N
1	28	53	6	\N
1	29	53	8	\N
1	30	53	8	\N
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
1	41	53	8	\N
1	42	53	8	\N
1	43	53	8	\N
1	44	53	8	\N
1	45	53	8	\N
1	46	53	8	\N
1	47	53	8	\N
1	48	53	8	\N
1	49	53	8	\N
1	50	53	8	\N
1	51	53	2	\N
1	52	53	1	\N
1	53	53	1	9
1	54	53	9	\N
1	55	53	2	1
1	56	53	2	\N
1	57	53	2	1
1	58	53	2	\N
1	59	53	2	\N
1	60	53	2	1
1	1	54	3	3
1	2	54	8	\N
1	3	54	8	\N
1	4	54	3	3
1	5	54	8	\N
1	6	54	8	\N
1	7	54	8	\N
1	8	54	8	\N
1	9	54	8	\N
1	10	54	8	\N
1	11	54	8	\N
1	12	54	8	\N
1	13	54	8	\N
1	14	54	8	\N
1	15	54	8	\N
1	16	54	8	\N
1	17	54	8	\N
1	18	54	8	\N
1	19	54	8	\N
1	20	54	8	\N
1	21	54	8	\N
1	22	54	8	\N
1	23	54	8	\N
1	24	54	2	1
1	25	54	2	1
1	26	54	2	1
1	27	54	2	1
1	28	54	2	\N
1	29	54	2	1
1	30	54	8	\N
1	31	54	8	\N
1	32	54	8	\N
1	33	54	8	\N
1	34	54	8	\N
1	35	54	8	\N
1	36	54	8	\N
1	37	54	8	\N
1	38	54	8	\N
1	39	54	3	\N
1	40	54	8	\N
1	41	54	8	\N
1	42	54	8	\N
1	43	54	8	\N
1	44	54	8	\N
1	45	54	8	\N
1	46	54	8	\N
1	47	54	3	2
1	48	54	8	\N
1	49	54	8	\N
1	50	54	8	\N
1	51	54	8	\N
1	52	54	3	\N
1	53	54	1	1
1	54	54	9	\N
1	55	54	9	\N
1	56	54	2	1
1	57	54	2	1
1	58	54	2	\N
1	59	54	2	\N
1	60	54	2	1
1	1	55	8	\N
1	2	55	8	\N
1	3	55	8	\N
1	4	55	8	\N
1	5	55	8	\N
1	6	55	5	\N
1	7	55	8	\N
1	8	55	8	\N
1	9	55	8	\N
1	10	55	8	\N
1	11	55	8	\N
1	12	55	8	\N
1	13	55	8	\N
1	14	55	8	\N
1	15	55	8	\N
1	16	55	8	\N
1	17	55	8	\N
1	18	55	8	\N
1	19	55	8	\N
1	20	55	8	\N
1	21	55	8	\N
1	22	55	8	\N
1	23	55	8	\N
1	24	55	8	\N
1	25	55	2	1
1	26	55	2	\N
1	27	55	5	\N
1	28	55	9	\N
1	29	55	8	\N
1	30	55	8	\N
1	31	55	8	\N
1	32	55	8	\N
1	33	55	8	\N
1	34	55	8	\N
1	35	55	8	\N
1	36	55	8	\N
1	37	55	8	\N
1	38	55	3	\N
1	39	55	8	\N
1	40	55	8	\N
1	41	55	8	\N
1	42	55	6	\N
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
1	53	55	1	\N
1	54	55	1	\N
1	55	55	9	\N
1	56	55	2	1
1	57	55	2	1
1	58	55	2	1
1	59	55	2	\N
1	60	55	3	2
1	1	56	8	\N
1	2	56	8	\N
1	3	56	8	\N
1	4	56	8	\N
1	5	56	8	\N
1	6	56	8	\N
1	7	56	8	\N
1	8	56	8	\N
1	9	56	8	\N
1	10	56	8	\N
1	11	56	8	\N
1	12	56	8	\N
1	13	56	8	\N
1	14	56	8	\N
1	15	56	8	\N
1	16	56	8	\N
1	17	56	8	\N
1	18	56	8	\N
1	19	56	8	\N
1	20	56	8	\N
1	21	56	8	\N
1	22	56	8	\N
1	23	56	8	\N
1	24	56	8	\N
1	25	56	5	8
1	26	56	2	1
1	27	56	2	\N
1	28	56	8	\N
1	29	56	2	1
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
1	53	56	1	1
1	54	56	1	1
1	55	56	1	\N
1	56	56	2	\N
1	57	56	2	\N
1	58	56	9	\N
1	59	56	9	\N
1	60	56	2	1
1	1	57	8	\N
1	2	57	8	\N
1	3	57	8	\N
1	4	57	8	\N
1	5	57	8	\N
1	6	57	8	\N
1	7	57	8	\N
1	8	57	8	\N
1	9	57	8	\N
1	10	57	8	\N
1	11	57	8	\N
1	12	57	8	\N
1	13	57	8	\N
1	14	57	8	\N
1	15	57	8	\N
1	16	57	8	\N
1	17	57	8	\N
1	18	57	8	\N
1	19	57	8	\N
1	20	57	8	\N
1	21	57	8	\N
1	22	57	8	\N
1	23	57	8	\N
1	24	57	8	\N
1	25	57	8	\N
1	26	57	2	1
1	27	57	5	6
1	28	57	8	\N
1	29	57	8	\N
1	30	57	8	\N
1	31	57	8	\N
1	32	57	8	\N
1	33	57	8	\N
1	34	57	8	\N
1	35	57	8	\N
1	36	57	8	\N
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
1	54	57	1	\N
1	55	57	1	9
1	56	57	1	\N
1	57	57	2	1
1	58	57	9	\N
1	59	57	2	1
1	60	57	2	1
1	1	58	4	\N
1	2	58	8	\N
1	3	58	8	\N
1	4	58	8	\N
1	5	58	8	\N
1	6	58	8	\N
1	7	58	8	\N
1	8	58	8	\N
1	9	58	8	\N
1	10	58	8	\N
1	11	58	8	\N
1	12	58	8	\N
1	13	58	8	\N
1	14	58	8	\N
1	15	58	5	8
1	16	58	8	\N
1	17	58	1	1
1	18	58	8	\N
1	19	58	8	\N
1	20	58	8	\N
1	21	58	8	\N
1	22	58	8	\N
1	23	58	8	\N
1	24	58	8	\N
1	25	58	8	\N
1	26	58	8	\N
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
1	40	58	5	8
1	41	58	8	\N
1	42	58	8	\N
1	43	58	8	\N
1	44	58	8	\N
1	45	58	8	\N
1	46	58	8	\N
1	47	58	8	\N
1	48	58	8	\N
1	49	58	8	\N
1	50	58	8	\N
1	51	58	8	\N
1	52	58	8	\N
1	53	58	8	\N
1	54	58	1	\N
1	55	58	1	9
1	56	58	1	1
1	57	58	1	\N
1	58	58	9	\N
1	59	58	9	\N
1	60	58	9	\N
1	1	59	8	\N
1	2	59	8	\N
1	3	59	8	\N
1	4	59	8	\N
1	5	59	8	\N
1	6	59	8	\N
1	7	59	8	\N
1	8	59	8	\N
1	9	59	8	\N
1	10	59	8	\N
1	11	59	2	1
1	12	59	8	\N
1	13	59	8	\N
1	14	59	8	\N
1	15	59	8	\N
1	16	59	8	\N
1	17	59	8	\N
1	18	59	8	\N
1	19	59	8	\N
1	20	59	8	\N
1	21	59	8	\N
1	22	59	8	\N
1	23	59	8	\N
1	24	59	8	\N
1	25	59	8	\N
1	26	59	8	\N
1	27	59	8	\N
1	28	59	1	\N
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
1	45	59	7	\N
1	46	59	8	\N
1	47	59	8	\N
1	48	59	8	\N
1	49	59	4	7
1	50	59	8	\N
1	51	59	8	\N
1	52	59	8	\N
1	53	59	8	\N
1	54	59	1	1
1	55	59	1	\N
1	56	59	1	\N
1	57	59	1	9
1	58	59	5	8
1	59	59	5	\N
1	60	59	9	\N
1	1	60	8	\N
1	2	60	8	\N
1	3	60	8	\N
1	4	60	2	\N
1	5	60	8	\N
1	6	60	8	\N
1	7	60	8	\N
1	8	60	8	\N
1	9	60	8	\N
1	10	60	8	\N
1	11	60	8	\N
1	12	60	8	\N
1	13	60	8	\N
1	14	60	8	\N
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
1	27	60	1	\N
1	28	60	1	\N
1	29	60	8	\N
1	30	60	8	\N
1	31	60	2	\N
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
1	48	60	8	\N
1	49	60	8	\N
1	50	60	8	\N
1	51	60	8	\N
1	52	60	8	\N
1	53	60	8	\N
1	54	60	8	\N
1	55	60	8	\N
1	56	60	8	\N
1	57	60	1	9
1	58	60	9	\N
1	59	60	4	7
1	60	60	9	\N
\.


--
-- TOC entry 5539 (class 0 OID 22808)
-- Dependencies: 298
-- Data for Name: map_tiles_map_regions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_map_regions (region_id, map_id, map_tile_x, map_tile_y) FROM stdin;
1	1	1	1
1	1	2	1
1	1	1	2
1	1	2	2
1	1	1	3
1	1	3	1
1	1	4	1
1	1	3	2
1	1	2	3
2	1	5	1
2	1	6	1
2	1	5	2
2	1	7	1
2	1	6	2
2	1	8	1
2	1	7	2
2	1	4	2
3	1	9	1
3	1	10	1
3	1	9	2
3	1	11	1
3	1	10	2
3	1	11	2
3	1	10	3
3	1	12	2
4	1	12	1
4	1	13	1
4	1	14	1
4	1	13	2
4	1	15	1
4	1	14	2
4	1	15	2
4	1	14	3
5	1	16	1
5	1	17	1
5	1	16	2
5	1	17	2
5	1	16	3
5	1	17	3
5	1	16	4
5	1	18	2
5	1	18	1
6	1	19	1
6	1	20	1
6	1	21	1
6	1	20	2
6	1	22	1
6	1	21	2
6	1	22	2
6	1	23	1
6	1	23	2
7	1	24	1
7	1	25	1
7	1	24	2
7	1	26	1
7	1	25	2
7	1	27	1
7	1	26	2
7	1	28	1
7	1	27	2
7	1	28	2
8	1	31	1
8	1	32	1
8	1	33	1
8	1	34	1
8	1	33	2
8	1	34	2
8	1	33	3
8	1	35	2
9	1	35	1
9	1	36	1
9	1	37	1
9	1	36	2
9	1	37	2
9	1	36	3
9	1	37	3
9	1	35	3
10	1	38	1
10	1	39	1
10	1	38	2
10	1	39	2
10	1	40	2
10	1	39	3
10	1	40	3
10	1	39	4
10	1	40	1
11	1	41	1
11	1	42	1
11	1	41	2
11	1	43	1
11	1	42	2
11	1	41	3
11	1	43	2
11	1	42	3
12	1	44	1
12	1	45	1
12	1	44	2
12	1	45	2
12	1	44	3
12	1	46	2
12	1	46	1
12	1	43	3
13	1	47	1
13	1	48	1
13	1	47	2
13	1	49	1
13	1	48	2
13	1	47	3
13	1	50	1
13	1	49	2
13	1	50	2
13	1	49	3
14	1	51	1
14	1	52	1
14	1	51	2
14	1	52	2
14	1	51	3
14	1	53	1
14	1	53	2
14	1	52	3
14	1	54	2
14	1	53	3
15	1	54	1
15	1	55	1
15	1	56	1
15	1	55	2
15	1	56	2
15	1	55	3
15	1	57	2
15	1	56	3
16	1	57	1
16	1	58	1
16	1	59	1
16	1	58	2
16	1	59	2
16	1	58	3
16	1	60	2
16	1	59	3
17	1	60	1
18	1	8	2
18	1	8	3
18	1	9	3
18	1	7	3
18	1	8	4
18	1	6	3
18	1	7	4
18	1	6	4
18	1	7	5
19	1	3	3
19	1	4	3
19	1	3	4
19	1	4	4
19	1	2	4
19	1	3	5
19	1	1	4
19	1	2	5
19	1	5	3
20	1	11	3
20	1	12	3
20	1	11	4
20	1	12	4
20	1	10	4
20	1	11	5
20	1	13	3
20	1	9	4
20	1	10	5
20	1	9	5
21	1	18	3
21	1	18	4
21	1	17	4
21	1	18	5
21	1	17	5
21	1	18	6
21	1	17	6
21	1	18	7
21	1	16	6
22	1	27	3
22	1	28	3
22	1	27	4
22	1	28	4
22	1	26	4
22	1	27	5
22	1	28	5
22	1	26	5
22	1	27	6
22	1	25	5
23	1	30	3
23	1	30	4
23	1	31	4
23	1	30	5
23	1	31	5
23	1	29	5
23	1	30	6
23	1	29	6
23	1	28	6
24	1	32	3
24	1	32	4
24	1	33	4
24	1	32	5
24	1	34	4
24	1	33	5
24	1	34	5
24	1	35	4
24	1	34	3
24	1	36	4
25	1	46	3
26	1	48	3
27	1	50	3
28	1	54	3
28	1	54	4
28	1	55	4
28	1	53	4
28	1	54	5
28	1	56	4
28	1	55	5
28	1	56	5
29	1	57	3
29	1	57	4
29	1	58	4
29	1	57	5
29	1	59	4
29	1	58	5
29	1	59	5
29	1	58	6
29	1	57	6
30	1	60	3
30	1	60	4
30	1	60	5
30	1	60	6
30	1	59	6
30	1	60	7
30	1	59	7
30	1	60	8
30	1	58	7
30	1	59	8
31	1	5	4
31	1	5	5
31	1	6	5
31	1	4	5
31	1	5	6
31	1	6	6
31	1	4	6
31	1	5	7
32	1	13	4
32	1	14	4
32	1	13	5
32	1	14	5
32	1	12	5
32	1	12	6
32	1	15	5
32	1	15	4
32	1	11	6
32	1	10	6
33	1	20	4
34	1	22	4
34	1	23	4
34	1	22	5
34	1	23	5
34	1	24	5
34	1	23	6
34	1	21	5
34	1	22	6
34	1	24	6
35	1	37	4
35	1	38	4
35	1	37	5
35	1	38	5
35	1	39	5
35	1	40	5
35	1	39	6
35	1	40	6
35	1	41	6
35	1	40	7
36	1	40	4
36	1	41	4
36	1	42	4
36	1	41	5
36	1	43	4
36	1	42	5
36	1	44	4
36	1	43	5
36	1	44	5
37	1	51	4
37	1	52	4
37	1	51	5
37	1	52	5
37	1	53	5
37	1	52	6
37	1	53	6
37	1	51	6
37	1	52	7
37	1	54	6
38	1	1	5
38	1	1	6
38	1	2	6
38	1	1	7
38	1	2	7
38	1	1	8
38	1	3	6
38	1	3	7
39	1	8	5
39	1	8	6
39	1	9	6
39	1	7	6
39	1	8	7
39	1	9	7
39	1	7	7
39	1	6	7
39	1	7	8
39	1	8	8
40	1	35	5
40	1	35	6
40	1	34	6
40	1	35	7
40	1	34	7
40	1	35	8
40	1	36	8
40	1	34	8
41	1	46	5
41	1	47	5
42	1	50	5
43	1	20	6
43	1	21	6
43	1	20	7
43	1	21	7
43	1	20	8
43	1	22	7
43	1	21	8
43	1	20	9
43	1	23	7
44	1	25	6
44	1	26	6
44	1	25	7
44	1	26	7
44	1	24	7
44	1	25	8
44	1	24	8
44	1	25	9
44	1	27	7
44	1	23	8
45	1	31	6
45	1	31	7
45	1	32	7
45	1	30	7
45	1	31	8
45	1	29	7
45	1	30	8
45	1	29	8
46	1	42	6
46	1	43	6
46	1	42	7
46	1	44	6
46	1	43	7
46	1	44	7
46	1	45	7
46	1	46	7
46	1	45	8
47	1	48	6
47	1	48	7
47	1	47	7
47	1	48	8
47	1	47	8
47	1	49	8
47	1	48	9
47	1	50	8
48	1	55	6
48	1	55	7
48	1	56	7
48	1	54	7
48	1	57	7
48	1	53	7
48	1	53	8
48	1	52	8
48	1	53	9
48	1	52	9
49	1	4	7
49	1	4	8
49	1	5	8
49	1	3	8
49	1	4	9
49	1	3	9
49	1	5	9
49	1	4	10
50	1	10	7
50	1	10	8
50	1	11	8
50	1	9	8
50	1	10	9
50	1	11	9
50	1	9	9
50	1	10	10
51	1	13	7
51	1	14	7
51	1	15	7
51	1	14	8
51	1	16	7
51	1	15	8
51	1	14	9
51	1	15	9
51	1	13	9
51	1	16	8
52	1	17	7
52	1	17	8
52	1	18	8
52	1	17	9
52	1	18	9
52	1	16	9
52	1	17	10
52	1	18	10
52	1	19	10
53	1	33	7
53	1	33	8
53	1	32	8
54	1	37	7
54	1	37	8
54	1	37	9
54	1	38	9
54	1	36	9
54	1	37	10
54	1	39	9
54	1	38	10
54	1	36	10
55	1	41	7
55	1	41	8
55	1	40	8
55	1	41	9
55	1	39	8
55	1	40	9
55	1	40	10
55	1	42	9
56	1	50	7
56	1	51	7
56	1	51	8
56	1	51	9
56	1	50	9
56	1	51	10
56	1	49	9
56	1	50	10
56	1	49	10
57	1	6	8
57	1	6	9
57	1	7	9
57	1	6	10
57	1	7	10
57	1	5	10
57	1	6	11
57	1	8	10
58	1	22	8
58	1	22	9
58	1	23	9
58	1	21	9
58	1	22	10
58	1	21	10
58	1	20	10
58	1	21	11
59	1	28	8
59	1	28	9
59	1	29	9
59	1	30	9
59	1	31	9
60	1	46	8
60	1	46	9
60	1	47	9
60	1	45	9
60	1	46	10
60	1	47	10
60	1	45	10
60	1	46	11
60	1	44	9
61	1	1	9
61	1	1	10
61	1	2	10
61	1	1	11
61	1	2	11
61	1	1	12
61	1	2	12
61	1	1	13
61	1	3	10
62	1	8	9
63	1	19	9
64	1	24	9
64	1	24	10
64	1	25	10
64	1	23	10
64	1	24	11
64	1	26	10
64	1	25	11
64	1	23	11
64	1	24	12
65	1	55	9
66	1	57	9
66	1	57	10
66	1	56	10
66	1	57	11
66	1	56	11
66	1	55	11
66	1	56	12
66	1	57	12
66	1	55	12
67	1	59	9
67	1	60	9
67	1	59	10
67	1	60	10
67	1	60	11
67	1	60	12
67	1	59	12
67	1	60	13
67	1	58	12
68	1	9	10
68	1	9	11
68	1	10	11
68	1	8	11
68	1	9	12
68	1	10	12
68	1	8	12
68	1	9	13
69	1	11	10
69	1	11	11
69	1	11	12
69	1	12	12
69	1	11	13
69	1	12	13
69	1	10	13
69	1	13	12
69	1	13	13
69	1	14	13
70	1	32	10
70	1	33	10
70	1	32	11
70	1	34	10
70	1	33	11
70	1	34	11
70	1	33	12
70	1	34	12
70	1	32	12
70	1	33	13
71	1	39	10
71	1	39	11
71	1	40	11
71	1	38	11
71	1	39	12
71	1	41	11
71	1	40	12
71	1	39	13
71	1	40	13
72	1	41	10
72	1	42	10
72	1	43	10
72	1	42	11
72	1	43	11
72	1	42	12
72	1	44	11
72	1	43	12
72	1	45	11
72	1	44	10
73	1	48	10
73	1	48	11
73	1	49	11
73	1	47	11
73	1	48	12
73	1	49	12
73	1	47	12
73	1	48	13
73	1	47	13
74	1	52	10
74	1	53	10
74	1	52	11
74	1	53	11
74	1	51	11
74	1	52	12
74	1	53	12
74	1	51	12
75	1	5	11
75	1	5	12
75	1	6	12
75	1	4	12
75	1	5	13
75	1	6	13
75	1	4	13
75	1	5	14
75	1	3	13
76	1	7	11
76	1	7	12
76	1	7	13
76	1	8	13
76	1	7	14
76	1	8	14
76	1	9	14
76	1	8	15
76	1	9	15
77	1	13	11
77	1	14	11
77	1	15	11
77	1	14	12
77	1	15	12
77	1	16	12
77	1	15	13
77	1	16	13
77	1	15	14
77	1	16	14
78	1	18	11
78	1	19	11
78	1	18	12
78	1	20	11
78	1	19	12
78	1	20	12
78	1	21	12
78	1	22	12
78	1	21	13
78	1	23	12
79	1	22	11
80	1	26	11
80	1	27	11
80	1	26	12
80	1	27	12
80	1	25	12
80	1	26	13
80	1	25	13
80	1	26	14
80	1	25	14
80	1	26	15
81	1	29	11
81	1	30	11
81	1	29	12
81	1	31	11
81	1	30	12
81	1	28	12
81	1	29	13
81	1	31	12
81	1	31	13
82	1	50	11
82	1	50	12
82	1	50	13
82	1	51	13
82	1	49	13
82	1	50	14
82	1	49	14
82	1	52	13
82	1	51	14
82	1	52	14
83	1	54	11
83	1	54	12
83	1	54	13
83	1	55	13
83	1	53	13
83	1	54	14
83	1	56	13
83	1	55	14
83	1	56	14
84	1	35	12
84	1	36	12
84	1	35	13
84	1	36	13
84	1	34	13
84	1	35	14
84	1	34	14
84	1	36	14
85	1	41	12
85	1	41	13
85	1	42	13
85	1	41	14
85	1	43	13
85	1	42	14
85	1	40	14
85	1	41	15
85	1	39	14
85	1	40	15
86	1	2	13
86	1	2	14
86	1	3	14
86	1	1	14
86	1	2	15
86	1	4	14
86	1	3	15
86	1	4	15
87	1	22	13
87	1	23	13
87	1	22	14
87	1	24	13
87	1	23	14
87	1	24	14
87	1	21	14
87	1	22	15
87	1	24	15
88	1	28	13
88	1	28	14
88	1	29	14
88	1	30	14
88	1	31	14
88	1	30	13
88	1	32	14
88	1	33	14
89	1	32	13
90	1	37	13
90	1	37	14
90	1	37	15
90	1	38	15
90	1	36	15
90	1	37	16
90	1	39	15
90	1	39	16
91	1	44	13
91	1	45	13
91	1	44	14
91	1	46	13
91	1	45	14
91	1	43	14
91	1	44	15
91	1	46	14
91	1	45	15
91	1	43	15
92	1	57	13
92	1	58	13
92	1	57	14
92	1	59	13
92	1	58	14
92	1	57	15
92	1	58	15
92	1	56	15
93	1	6	14
94	1	13	14
94	1	14	14
94	1	13	15
94	1	14	15
94	1	13	16
94	1	15	15
94	1	14	16
94	1	15	16
94	1	14	17
94	1	15	17
95	1	17	14
95	1	18	14
95	1	18	15
95	1	18	16
95	1	19	16
95	1	18	17
95	1	19	17
95	1	18	18
95	1	19	18
95	1	19	19
96	1	20	14
97	1	47	14
97	1	48	14
97	1	47	15
97	1	48	15
97	1	46	15
97	1	47	16
97	1	46	16
97	1	45	16
98	1	53	14
98	1	53	15
98	1	54	15
98	1	52	15
98	1	51	15
98	1	55	15
98	1	55	16
98	1	56	16
98	1	55	17
98	1	57	16
99	1	59	14
99	1	60	14
99	1	59	15
99	1	60	15
99	1	59	16
99	1	60	16
99	1	58	16
99	1	58	17
99	1	60	17
99	1	57	17
100	1	1	15
100	1	1	16
100	1	1	17
100	1	2	17
100	1	1	18
100	1	3	17
100	1	2	18
100	1	3	18
101	1	7	15
101	1	7	16
101	1	8	16
101	1	6	16
101	1	7	17
101	1	9	16
101	1	8	17
101	1	5	16
102	1	11	15
103	1	16	15
103	1	16	16
103	1	16	17
103	1	16	18
103	1	17	18
103	1	15	18
103	1	16	19
103	1	17	19
103	1	14	18
104	1	21	15
105	1	23	15
106	1	25	15
106	1	25	16
106	1	26	16
106	1	24	16
106	1	25	17
106	1	26	17
106	1	24	17
106	1	25	18
107	1	35	15
107	1	35	16
107	1	36	16
107	1	34	16
107	1	35	17
107	1	36	17
107	1	37	17
107	1	36	18
108	1	42	15
108	1	42	16
108	1	43	16
108	1	41	16
108	1	42	17
108	1	44	16
108	1	43	17
108	1	40	16
108	1	41	17
109	1	49	15
109	1	49	16
109	1	48	16
109	1	49	17
109	1	48	17
109	1	50	17
109	1	47	17
109	1	48	18
110	1	3	16
110	1	4	16
110	1	4	17
110	1	5	17
110	1	4	18
110	1	6	17
110	1	5	18
110	1	6	18
111	1	12	16
111	1	12	17
111	1	13	17
111	1	12	18
111	1	13	18
111	1	11	18
111	1	12	19
111	1	13	19
112	1	28	16
112	1	29	16
113	1	31	16
113	1	31	17
113	1	32	17
113	1	30	17
113	1	31	18
113	1	32	18
113	1	31	19
113	1	32	19
114	1	9	17
114	1	9	18
114	1	8	18
114	1	9	19
114	1	10	19
114	1	8	19
114	1	9	20
114	1	7	19
114	1	8	20
114	1	7	20
115	1	21	17
116	1	23	17
116	1	23	18
116	1	24	18
116	1	22	18
116	1	23	19
116	1	24	19
116	1	22	19
116	1	25	19
116	1	24	20
116	1	23	20
117	1	38	17
117	1	39	17
117	1	38	18
117	1	39	18
117	1	37	18
117	1	37	19
117	1	40	17
117	1	39	19
118	1	44	17
118	1	45	17
118	1	44	18
118	1	45	18
118	1	43	18
118	1	44	19
118	1	45	19
118	1	43	19
118	1	44	20
118	1	46	18
119	1	46	17
120	1	52	17
120	1	53	17
120	1	52	18
120	1	54	17
120	1	53	18
120	1	54	18
120	1	55	18
120	1	54	19
121	1	56	17
121	1	56	18
121	1	57	18
121	1	56	19
121	1	58	18
121	1	57	19
121	1	58	19
121	1	57	20
122	1	7	18
123	1	26	18
123	1	27	18
123	1	26	19
123	1	28	18
123	1	27	19
123	1	26	20
123	1	27	20
123	1	25	20
124	1	34	18
124	1	35	18
124	1	34	19
124	1	35	19
124	1	36	19
124	1	35	20
124	1	33	19
124	1	34	20
125	1	41	18
125	1	42	18
125	1	41	19
125	1	42	19
125	1	42	20
125	1	43	20
125	1	41	20
125	1	42	21
125	1	43	21
126	1	47	18
126	1	47	19
126	1	48	19
126	1	46	19
126	1	47	20
126	1	49	19
126	1	48	20
126	1	49	20
126	1	49	21
127	1	51	18
127	1	51	19
127	1	52	19
127	1	53	19
127	1	52	20
127	1	53	20
127	1	52	21
127	1	53	21
128	1	1	19
128	1	2	19
128	1	1	20
128	1	3	19
128	1	2	20
128	1	4	19
128	1	3	20
128	1	4	20
128	1	3	21
129	1	5	19
129	1	6	19
129	1	5	20
129	1	5	21
129	1	4	21
129	1	5	22
129	1	6	22
129	1	4	22
129	1	5	23
129	1	6	23
130	1	11	19
130	1	11	20
130	1	12	20
130	1	10	20
130	1	11	21
130	1	12	21
130	1	10	21
130	1	11	22
130	1	12	22
130	1	10	22
131	1	14	19
131	1	15	19
131	1	14	20
131	1	15	20
131	1	13	20
131	1	14	21
131	1	16	20
131	1	15	21
131	1	16	21
132	1	18	19
132	1	18	20
132	1	19	20
132	1	17	20
132	1	18	21
132	1	19	21
132	1	19	22
132	1	20	22
132	1	18	22
133	1	21	19
134	1	28	19
134	1	29	19
134	1	28	20
134	1	30	19
134	1	28	21
134	1	29	21
134	1	27	21
134	1	28	22
134	1	30	21
134	1	29	22
135	1	55	19
135	1	55	20
135	1	56	20
135	1	55	21
135	1	56	21
135	1	57	21
135	1	56	22
135	1	58	21
135	1	57	22
136	1	22	20
136	1	22	21
136	1	23	21
136	1	21	21
136	1	22	22
136	1	23	22
136	1	21	22
136	1	22	23
136	1	21	23
137	1	36	20
137	1	37	20
137	1	36	21
137	1	37	21
137	1	35	21
137	1	36	22
137	1	38	20
137	1	37	22
137	1	36	23
137	1	37	23
138	1	39	20
138	1	39	21
138	1	38	21
138	1	39	22
138	1	40	22
138	1	38	22
138	1	39	23
138	1	41	22
138	1	40	23
139	1	45	20
139	1	46	20
139	1	45	21
139	1	45	22
139	1	44	22
139	1	45	23
139	1	44	23
139	1	45	24
140	1	58	20
141	1	60	20
141	1	60	21
141	1	59	21
141	1	60	22
141	1	59	22
141	1	60	23
141	1	58	22
141	1	59	23
141	1	60	24
141	1	59	24
142	1	1	21
142	1	2	21
142	1	1	22
142	1	2	22
142	1	1	23
142	1	2	23
142	1	1	24
142	1	3	23
142	1	2	24
143	1	7	21
143	1	8	21
143	1	7	22
143	1	8	22
143	1	7	23
143	1	9	22
143	1	8	23
143	1	9	23
143	1	9	21
143	1	8	24
144	1	13	21
144	1	13	22
144	1	13	23
144	1	14	23
144	1	12	23
144	1	11	23
144	1	12	24
144	1	10	23
144	1	11	24
145	1	17	21
145	1	17	22
145	1	17	23
145	1	18	23
145	1	16	23
145	1	17	24
145	1	19	23
145	1	18	24
145	1	16	24
146	1	24	21
146	1	24	22
146	1	25	22
146	1	24	23
146	1	25	23
146	1	23	23
146	1	24	24
146	1	25	24
146	1	26	23
146	1	26	24
147	1	32	21
147	1	33	21
147	1	32	22
147	1	34	21
147	1	33	22
147	1	34	22
147	1	31	22
147	1	34	23
147	1	35	23
148	1	51	21
148	1	51	22
148	1	52	22
148	1	50	22
148	1	51	23
148	1	53	22
148	1	52	23
148	1	50	23
149	1	3	22
150	1	30	22
150	1	30	23
150	1	31	23
150	1	30	24
150	1	31	24
150	1	30	25
150	1	31	25
150	1	29	25
151	1	42	22
151	1	43	22
151	1	42	23
151	1	43	23
151	1	41	23
151	1	42	24
151	1	43	24
151	1	41	24
151	1	42	25
152	1	47	22
152	1	47	23
152	1	47	24
152	1	48	24
152	1	46	24
152	1	47	25
152	1	49	24
152	1	50	24
153	1	4	23
153	1	4	24
153	1	5	24
153	1	3	24
153	1	4	25
153	1	6	24
153	1	5	25
153	1	3	25
154	1	20	23
155	1	38	23
155	1	38	24
155	1	39	24
155	1	37	24
155	1	38	25
155	1	40	24
155	1	39	25
155	1	40	25
155	1	41	25
155	1	40	26
156	1	49	23
157	1	53	23
157	1	54	23
157	1	53	24
157	1	54	24
157	1	52	24
157	1	53	25
157	1	54	25
157	1	54	26
157	1	55	26
158	1	58	23
158	1	58	24
158	1	57	24
158	1	58	25
158	1	56	24
158	1	59	25
158	1	58	26
158	1	59	26
159	1	7	24
159	1	7	25
159	1	8	25
159	1	6	25
159	1	7	26
159	1	6	26
159	1	9	25
159	1	8	26
159	1	10	25
159	1	9	26
160	1	9	24
160	1	10	24
161	1	14	24
162	1	19	24
162	1	19	25
162	1	18	25
162	1	19	26
162	1	17	25
162	1	18	26
162	1	16	25
162	1	17	26
163	1	21	24
163	1	22	24
163	1	21	25
163	1	22	25
163	1	21	26
163	1	22	26
163	1	21	27
163	1	22	27
163	1	23	27
163	1	22	28
164	1	27	24
164	1	27	25
164	1	26	25
164	1	27	26
164	1	25	25
164	1	26	26
164	1	25	26
164	1	28	26
164	1	24	26
164	1	25	27
165	1	33	24
165	1	34	24
165	1	33	25
165	1	35	24
165	1	34	25
165	1	35	25
165	1	34	26
165	1	36	24
165	1	36	25
166	1	44	24
166	1	44	25
166	1	45	25
166	1	43	25
166	1	44	26
166	1	45	26
166	1	43	26
166	1	44	27
166	1	45	27
167	1	51	24
167	1	51	25
167	1	52	25
167	1	50	25
167	1	51	26
167	1	52	26
167	1	53	26
167	1	49	25
167	1	50	26
168	1	1	25
168	1	2	25
168	1	1	26
168	1	2	26
168	1	1	27
168	1	3	26
168	1	2	27
168	1	1	28
168	1	3	27
169	1	11	25
169	1	12	25
169	1	11	26
169	1	12	26
169	1	10	26
169	1	11	27
169	1	10	27
169	1	12	27
169	1	13	27
169	1	12	28
170	1	15	25
170	1	15	26
170	1	16	26
170	1	14	26
170	1	15	27
170	1	13	26
170	1	14	27
170	1	16	27
170	1	15	28
171	1	32	25
171	1	32	26
171	1	31	26
171	1	32	27
171	1	33	27
171	1	31	27
171	1	32	28
171	1	31	28
172	1	46	25
172	1	46	26
172	1	47	26
172	1	46	27
172	1	47	27
172	1	48	27
172	1	47	28
172	1	49	27
172	1	48	28
173	1	60	25
173	1	60	26
173	1	60	27
173	1	59	27
173	1	60	28
173	1	58	27
173	1	59	28
173	1	60	29
173	1	58	28
174	1	4	26
174	1	5	26
174	1	4	27
174	1	5	27
174	1	4	28
174	1	5	28
174	1	3	28
174	1	4	29
174	1	6	28
174	1	5	29
175	1	29	26
175	1	30	26
175	1	29	27
175	1	28	27
176	1	35	26
176	1	36	26
176	1	35	27
176	1	36	27
176	1	34	27
176	1	36	28
176	1	34	28
176	1	33	28
177	1	39	26
177	1	39	27
177	1	40	27
177	1	38	27
177	1	39	28
177	1	40	28
177	1	38	28
177	1	39	29
177	1	40	29
178	1	41	26
178	1	42	26
178	1	41	27
178	1	42	27
178	1	41	28
178	1	42	28
178	1	41	29
178	1	42	29
178	1	43	29
178	1	42	30
179	1	56	26
179	1	56	27
179	1	57	27
179	1	55	27
179	1	56	28
179	1	57	28
179	1	57	29
179	1	55	28
179	1	56	29
180	1	6	27
181	1	8	27
181	1	9	27
182	1	17	27
182	1	18	27
182	1	17	28
182	1	19	27
182	1	18	28
182	1	19	28
182	1	16	28
182	1	17	29
182	1	16	29
183	1	20	27
183	1	20	28
183	1	21	28
183	1	20	29
183	1	19	29
184	1	24	27
184	1	24	28
184	1	25	28
184	1	23	28
184	1	24	29
184	1	23	29
184	1	26	28
184	1	25	29
185	1	50	27
185	1	51	27
185	1	50	28
185	1	51	28
185	1	51	29
185	1	52	29
185	1	50	29
185	1	51	30
186	1	53	27
186	1	54	27
186	1	53	28
186	1	54	28
186	1	53	29
186	1	53	30
186	1	54	30
186	1	52	30
187	1	2	28
187	1	2	29
187	1	1	29
188	1	13	28
188	1	14	28
188	1	13	29
188	1	14	29
188	1	12	29
188	1	13	30
188	1	11	29
188	1	12	30
188	1	15	29
189	1	30	28
190	1	37	28
190	1	37	29
190	1	38	29
190	1	36	29
190	1	37	30
190	1	35	29
190	1	36	30
190	1	34	29
191	1	44	28
191	1	45	28
191	1	44	29
191	1	45	29
191	1	44	30
191	1	45	30
191	1	43	30
191	1	44	31
191	1	43	31
192	1	46	28
193	1	49	28
193	1	49	29
193	1	48	29
193	1	49	30
193	1	47	29
193	1	48	30
193	1	47	30
193	1	46	30
194	1	6	29
194	1	7	29
194	1	6	30
194	1	8	29
194	1	7	30
194	1	8	30
194	1	7	31
194	1	9	30
195	1	10	29
195	1	10	30
195	1	11	30
195	1	10	31
195	1	11	31
195	1	11	32
195	1	9	31
195	1	10	32
196	1	22	29
197	1	26	29
197	1	27	29
197	1	26	30
197	1	27	30
197	1	25	30
197	1	26	31
197	1	27	31
197	1	25	31
197	1	26	32
197	1	24	30
198	1	28	29
198	1	28	30
198	1	28	31
198	1	28	32
198	1	29	32
198	1	27	32
198	1	28	33
198	1	29	33
198	1	30	33
199	1	32	29
199	1	33	29
199	1	32	30
199	1	33	30
199	1	34	30
199	1	33	31
199	1	34	31
199	1	32	31
199	1	33	32
200	1	55	29
200	1	55	30
200	1	56	30
200	1	55	31
200	1	57	30
200	1	56	31
200	1	58	30
200	1	57	31
200	1	59	30
200	1	58	31
201	1	58	29
201	1	59	29
202	1	3	30
202	1	4	30
202	1	3	31
202	1	5	30
202	1	4	31
202	1	5	31
202	1	2	31
202	1	6	31
203	1	14	30
203	1	15	30
203	1	14	31
203	1	15	31
203	1	14	32
203	1	16	31
203	1	15	32
203	1	16	30
204	1	17	30
205	1	23	30
205	1	23	31
205	1	24	31
206	1	30	30
206	1	31	30
206	1	31	31
206	1	31	32
206	1	32	32
206	1	31	33
206	1	32	33
206	1	32	34
206	1	31	34
206	1	32	35
207	1	35	30
207	1	35	31
207	1	36	31
207	1	35	32
207	1	36	32
207	1	34	32
207	1	35	33
207	1	36	33
207	1	35	34
207	1	37	31
208	1	38	30
208	1	39	30
208	1	38	31
208	1	40	30
208	1	39	31
208	1	38	32
208	1	41	30
208	1	40	31
209	1	50	30
209	1	50	31
209	1	51	31
209	1	49	31
209	1	50	32
209	1	51	32
209	1	52	32
209	1	51	33
209	1	50	33
209	1	50	34
210	1	60	30
210	1	60	31
210	1	59	31
211	1	8	31
211	1	8	32
211	1	9	32
211	1	7	32
211	1	6	32
211	1	7	33
211	1	5	32
211	1	6	33
212	1	41	31
212	1	42	31
213	1	45	31
213	1	46	31
213	1	45	32
213	1	47	31
213	1	46	32
213	1	47	32
213	1	46	33
213	1	45	33
214	1	53	31
214	1	54	31
214	1	53	32
214	1	54	32
214	1	55	32
214	1	54	33
214	1	53	33
214	1	52	33
214	1	53	34
215	1	1	32
215	1	2	32
215	1	1	33
215	1	2	33
215	1	1	34
215	1	2	34
215	1	1	35
215	1	2	35
216	1	4	32
217	1	13	32
217	1	13	33
217	1	14	33
217	1	15	33
217	1	16	33
217	1	15	34
217	1	17	33
217	1	16	34
218	1	16	32
219	1	25	32
219	1	25	33
219	1	26	33
219	1	27	33
219	1	27	34
219	1	28	34
219	1	29	34
219	1	28	35
219	1	30	34
219	1	29	35
220	1	37	32
220	1	37	33
220	1	38	33
220	1	37	34
220	1	38	34
220	1	36	34
220	1	37	35
220	1	36	35
220	1	35	35
221	1	56	32
221	1	57	32
221	1	56	33
221	1	57	33
221	1	55	33
221	1	56	34
221	1	58	33
221	1	57	34
221	1	58	34
221	1	57	35
222	1	58	32
223	1	5	33
223	1	5	34
223	1	6	34
223	1	4	34
223	1	5	35
223	1	7	34
223	1	6	35
223	1	4	35
224	1	40	33
224	1	41	33
224	1	40	34
224	1	41	34
224	1	39	34
224	1	40	35
224	1	39	35
224	1	41	35
225	1	42	33
225	1	42	34
225	1	42	35
225	1	43	35
225	1	43	36
225	1	44	36
225	1	43	37
225	1	44	37
225	1	42	37
225	1	43	38
226	1	44	33
227	1	47	33
227	1	47	34
227	1	46	34
227	1	47	35
227	1	46	35
227	1	47	36
227	1	45	35
227	1	46	36
228	1	59	33
228	1	60	33
228	1	59	34
228	1	60	34
228	1	59	35
228	1	60	35
228	1	60	36
228	1	59	36
228	1	60	37
229	1	8	34
229	1	9	34
230	1	11	34
231	1	17	34
232	1	22	34
233	1	34	34
234	1	45	34
235	1	49	34
236	1	51	34
236	1	52	34
236	1	51	35
236	1	52	35
236	1	50	35
236	1	53	35
236	1	52	36
236	1	54	35
236	1	53	36
236	1	55	35
237	1	54	34
237	1	55	34
238	1	7	35
238	1	7	36
238	1	6	36
238	1	7	37
238	1	5	36
238	1	6	37
238	1	4	36
238	1	5	37
238	1	4	37
239	1	15	35
239	1	16	35
239	1	15	36
239	1	16	36
239	1	17	36
239	1	16	37
239	1	17	37
239	1	15	37
240	1	30	35
240	1	31	35
240	1	30	36
240	1	31	36
240	1	30	37
240	1	32	36
240	1	31	37
240	1	33	36
241	1	38	35
242	1	56	35
242	1	56	36
242	1	57	36
242	1	55	36
242	1	58	36
242	1	58	37
242	1	58	35
242	1	59	37
242	1	58	38
243	1	1	36
243	1	2	36
243	1	1	37
243	1	2	37
243	1	1	38
243	1	2	38
243	1	1	39
243	1	3	38
243	1	2	39
244	1	28	36
245	1	34	36
245	1	35	36
245	1	34	37
245	1	35	37
245	1	33	37
245	1	34	38
245	1	36	37
245	1	35	38
245	1	34	39
245	1	36	38
246	1	39	36
246	1	40	36
246	1	39	37
246	1	40	37
246	1	38	37
246	1	39	38
246	1	37	37
246	1	38	38
246	1	41	37
246	1	40	38
247	1	41	36
248	1	45	36
248	1	45	37
248	1	46	37
248	1	45	38
248	1	46	38
248	1	44	38
248	1	45	39
248	1	46	39
249	1	48	36
249	1	48	37
249	1	49	37
249	1	47	37
249	1	48	38
249	1	47	38
249	1	49	38
249	1	48	39
249	1	49	39
250	1	3	37
251	1	10	37
252	1	29	37
252	1	29	38
252	1	30	38
252	1	29	39
252	1	30	39
252	1	31	38
252	1	31	39
252	1	30	40
253	1	32	37
253	1	32	38
253	1	32	39
254	1	51	37
254	1	52	37
254	1	53	37
254	1	52	38
254	1	53	38
255	1	4	38
255	1	5	38
255	1	4	39
255	1	6	38
255	1	5	39
255	1	6	39
255	1	3	39
255	1	4	40
255	1	3	40
255	1	7	38
256	1	18	38
256	1	18	39
256	1	19	39
256	1	18	40
257	1	37	38
257	1	37	39
257	1	38	39
257	1	36	39
257	1	37	40
257	1	38	40
257	1	36	40
257	1	37	41
257	1	35	40
258	1	41	38
258	1	42	38
258	1	41	39
258	1	42	39
258	1	40	39
258	1	41	40
258	1	39	39
258	1	40	40
258	1	39	40
258	1	40	41
259	1	55	38
259	1	56	38
260	1	59	38
260	1	60	38
260	1	59	39
260	1	60	39
260	1	58	39
260	1	59	40
260	1	58	40
260	1	59	41
261	1	35	39
262	1	43	39
262	1	44	39
262	1	43	40
262	1	44	40
262	1	45	40
262	1	44	41
262	1	45	41
262	1	43	41
262	1	44	42
263	1	47	39
263	1	47	40
263	1	48	40
263	1	46	40
263	1	47	41
263	1	49	40
263	1	48	41
263	1	50	40
263	1	49	41
263	1	46	41
264	1	50	39
265	1	57	39
265	1	57	40
265	1	56	40
265	1	57	41
265	1	56	41
265	1	56	42
265	1	58	41
265	1	57	42
265	1	58	42
265	1	57	43
266	1	1	40
266	1	2	40
266	1	1	41
266	1	2	41
266	1	1	42
266	1	3	41
266	1	2	42
266	1	3	42
266	1	2	43
267	1	31	40
267	1	31	41
267	1	32	41
267	1	30	41
267	1	31	42
267	1	32	42
267	1	33	42
267	1	34	42
267	1	33	43
267	1	34	43
268	1	33	40
268	1	34	40
269	1	42	40
269	1	42	41
269	1	41	41
269	1	41	42
269	1	40	42
269	1	41	43
269	1	39	42
269	1	40	43
269	1	41	44
270	1	52	40
270	1	52	41
270	1	53	41
270	1	54	41
270	1	53	42
270	1	54	42
270	1	53	43
270	1	54	43
270	1	52	43
271	1	54	40
272	1	4	41
273	1	14	41
274	1	35	41
274	1	36	41
274	1	36	42
274	1	37	42
274	1	38	42
274	1	38	43
274	1	38	41
274	1	39	43
274	1	39	41
275	1	50	41
275	1	50	42
275	1	49	42
275	1	50	43
275	1	48	42
275	1	49	43
275	1	47	42
275	1	48	43
275	1	47	43
275	1	48	44
276	1	60	41
277	1	20	42
278	1	45	42
278	1	46	42
278	1	45	43
278	1	46	43
278	1	44	43
278	1	45	44
278	1	44	44
278	1	45	45
278	1	43	44
278	1	44	45
279	1	55	42
279	1	55	43
279	1	56	43
279	1	55	44
279	1	56	44
279	1	57	44
279	1	56	45
279	1	54	44
279	1	55	45
280	1	59	42
280	1	59	43
280	1	60	43
280	1	58	43
280	1	59	44
280	1	60	44
280	1	58	44
280	1	60	45
280	1	58	45
280	1	59	45
281	1	1	43
281	1	1	44
281	1	1	45
281	1	2	45
281	1	1	46
281	1	1	47
281	1	1	48
281	1	2	48
281	1	1	49
281	1	2	49
282	1	3	43
282	1	4	43
283	1	35	43
283	1	35	44
283	1	36	44
283	1	34	44
283	1	36	45
283	1	37	45
283	1	36	46
283	1	37	46
283	1	38	46
284	1	51	43
284	1	51	44
284	1	52	44
284	1	50	44
284	1	51	45
284	1	49	44
284	1	50	45
284	1	49	45
284	1	50	46
285	1	17	44
286	1	26	44
287	1	42	44
288	1	53	44
288	1	53	45
288	1	54	45
288	1	52	45
288	1	53	46
288	1	54	46
288	1	52	46
288	1	53	47
288	1	51	46
288	1	52	47
289	1	41	45
289	1	41	46
289	1	41	47
290	1	43	45
291	1	46	45
291	1	47	45
291	1	46	46
291	1	47	46
291	1	45	46
291	1	46	47
291	1	47	47
291	1	45	47
291	1	46	48
292	1	48	45
293	1	57	45
293	1	57	46
293	1	58	46
293	1	56	46
293	1	57	47
293	1	56	47
293	1	57	48
293	1	55	47
293	1	56	48
294	1	27	46
295	1	55	46
296	1	59	46
296	1	59	47
297	1	13	47
298	1	26	47
299	1	29	47
300	1	37	47
300	1	38	47
301	1	43	47
301	1	43	48
301	1	42	48
301	1	43	49
301	1	43	50
302	1	48	47
302	1	48	48
302	1	49	48
302	1	47	48
302	1	48	49
302	1	50	48
302	1	49	49
302	1	50	49
303	1	51	47
303	1	51	48
303	1	52	48
303	1	51	49
303	1	53	48
303	1	52	49
303	1	51	50
303	1	52	50
303	1	50	50
303	1	51	51
304	1	54	47
304	1	54	48
304	1	55	48
304	1	54	49
304	1	55	49
304	1	53	49
304	1	54	50
304	1	53	50
304	1	56	49
304	1	55	50
305	1	60	48
305	1	60	49
305	1	59	49
305	1	59	50
305	1	59	51
305	1	58	51
305	1	59	52
305	1	57	51
305	1	58	52
305	1	57	52
306	1	12	49
307	1	34	49
308	1	45	49
308	1	46	49
308	1	47	49
309	1	57	49
309	1	57	50
309	1	56	50
309	1	56	51
309	1	55	51
309	1	56	52
309	1	54	51
309	1	56	53
309	1	53	51
309	1	52	51
310	1	1	50
310	1	1	51
310	1	2	51
310	1	1	52
310	1	1	53
310	1	1	54
311	1	15	50
311	1	15	51
311	1	16	51
311	1	14	51
311	1	16	52
311	1	17	52
312	1	19	50
313	1	25	51
313	1	25	52
313	1	26	52
313	1	24	52
313	1	25	53
313	1	23	52
313	1	24	53
313	1	24	54
313	1	26	53
314	1	50	51
314	1	50	52
314	1	51	52
314	1	51	53
314	1	52	53
314	1	53	53
314	1	52	54
314	1	53	54
315	1	53	52
316	1	27	53
316	1	28	53
316	1	27	54
316	1	28	54
316	1	26	54
316	1	27	55
316	1	29	54
316	1	25	54
316	1	26	55
317	1	55	53
318	1	57	53
318	1	58	53
318	1	57	54
318	1	59	53
318	1	58	54
318	1	56	54
318	1	57	55
318	1	58	55
319	1	60	53
319	1	60	54
319	1	59	54
319	1	60	55
319	1	59	55
319	1	60	56
319	1	60	57
319	1	59	57
320	1	4	54
321	1	39	54
322	1	47	54
323	1	6	55
324	1	25	55
324	1	25	56
324	1	26	56
324	1	27	56
324	1	26	57
324	1	27	57
325	1	38	55
326	1	42	55
327	1	53	55
327	1	54	55
327	1	53	56
327	1	54	56
327	1	55	56
327	1	54	57
327	1	56	56
327	1	55	57
327	1	57	56
328	1	56	55
329	1	29	56
330	1	56	57
330	1	57	57
330	1	56	58
330	1	57	58
330	1	55	58
330	1	56	59
330	1	57	59
330	1	55	59
330	1	54	58
331	1	1	58
332	1	15	58
333	1	17	58
334	1	40	58
335	1	11	59
336	1	28	59
336	1	28	60
336	1	27	60
337	1	45	59
338	1	49	59
339	1	54	59
340	1	58	59
340	1	59	59
340	1	59	60
341	1	4	60
342	1	31	60
343	1	57	60
\.


--
-- TOC entry 5540 (class 0 OID 22815)
-- Dependencies: 299
-- Data for Name: map_tiles_players_positions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_players_positions (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
3	1	6	5
4	1	7	5
1	1	6	6
2	1	10	4
\.


--
-- TOC entry 5558 (class 0 OID 25631)
-- Dependencies: 319
-- Data for Name: map_tiles_resources; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_resources (id, map_id, map_tile_x, map_tile_y, item_id, quantity) FROM stdin;
1	1	17	1	6	50808
2	1	17	1	5	56329
3	1	17	1	5	1965
4	1	17	1	6	114617
5	1	17	1	4	151420
6	1	17	1	1	446011
7	1	18	1	6	60501
8	1	18	1	5	52860
9	1	18	1	5	38414
10	1	18	1	6	64362
11	1	18	1	4	153386
12	1	18	1	1	110861
13	1	19	1	6	60538
14	1	19	1	5	11423
15	1	19	1	5	26751
16	1	19	1	6	103163
17	1	19	1	4	277334
18	1	19	1	1	438763
19	1	20	1	5	14438
20	1	20	1	6	31201
21	1	20	1	1	522378
22	1	21	1	5	7055
23	1	21	1	6	60365
24	1	21	1	1	268121
25	1	22	1	5	142278
26	1	22	1	4	90251
27	1	22	1	1	115582
28	1	22	1	4	94538
29	1	22	1	1	128379
30	1	23	1	5	217803
31	1	23	1	4	10945
32	1	23	1	1	151409
33	1	23	1	4	7203
34	1	23	1	1	188600
35	1	24	1	5	205602
36	1	24	1	4	76933
37	1	24	1	1	170478
38	1	24	1	4	62653
39	1	24	1	1	162646
40	1	25	1	5	158059
41	1	25	1	4	12124
42	1	25	1	1	182620
43	1	25	1	4	68975
44	1	25	1	1	171022
45	1	26	1	1	95511
46	1	27	1	1	267531
47	1	28	1	1	195691
48	1	31	1	6	55888
49	1	31	1	5	33815
50	1	31	1	5	27422
51	1	31	1	6	5739
52	1	31	1	4	174619
53	1	31	1	1	459790
54	1	32	1	6	132366
55	1	32	1	5	31868
56	1	32	1	5	36806
57	1	32	1	6	47082
58	1	32	1	4	232066
59	1	32	1	1	570623
60	1	33	1	5	2952
61	1	33	1	6	20608
62	1	33	1	1	503543
63	1	34	1	5	15410
64	1	34	1	6	63424
65	1	34	1	1	264211
66	1	35	1	5	31112
67	1	35	1	6	77891
68	1	35	1	1	82122
69	1	36	1	5	16837
70	1	36	1	6	116555
71	1	36	1	1	372342
72	1	37	1	5	4188
73	1	37	1	6	128110
74	1	37	1	1	370998
75	1	38	1	6	139842
76	1	38	1	5	28466
77	1	38	1	5	21494
78	1	38	1	6	9679
79	1	38	1	4	195328
80	1	38	1	1	68663
81	1	39	1	5	1828
82	1	39	1	6	100853
83	1	39	1	1	210095
84	1	40	1	6	110649
85	1	40	1	5	31468
86	1	40	1	5	19635
87	1	40	1	6	125759
88	1	40	1	4	129564
89	1	40	1	1	466736
90	1	49	1	4	74177
91	1	49	1	6	70995
92	1	49	1	4	137214
93	1	49	1	6	106859
94	1	50	1	4	141487
95	1	50	1	6	140998
96	1	51	1	4	56290
97	1	51	1	6	146072
98	1	51	1	4	54526
99	1	51	1	6	58295
100	1	52	1	4	98543
101	1	52	1	6	112525
102	1	52	1	4	82226
103	1	52	1	6	68150
104	1	53	1	4	108668
105	1	53	1	6	109942
106	1	53	1	4	113113
107	1	53	1	6	104705
108	1	54	1	6	146066
109	1	54	1	5	10155
110	1	54	1	5	6652
111	1	54	1	6	57463
112	1	54	1	4	299868
113	1	54	1	1	207122
114	1	55	1	6	87912
115	1	55	1	5	26465
116	1	55	1	5	5472
117	1	55	1	6	137345
118	1	55	1	4	294744
119	1	55	1	1	477413
120	1	56	1	6	51262
121	1	56	1	5	7156
122	1	56	1	5	32144
123	1	56	1	6	142312
124	1	56	1	4	165064
125	1	56	1	1	108043
126	1	57	1	5	39151
127	1	57	1	6	101214
128	1	57	1	1	75965
129	1	58	1	5	25918
130	1	58	1	6	109652
131	1	58	1	1	171038
132	1	59	1	6	112526
133	1	59	1	5	40763
134	1	59	1	5	8490
135	1	59	1	6	82575
136	1	59	1	4	221407
137	1	59	1	1	228717
138	1	60	1	6	148452
139	1	60	1	5	3054
140	1	60	1	5	3996
141	1	60	1	6	105422
142	1	60	1	4	147098
143	1	60	1	1	351798
144	1	8	2	6	22809
145	1	8	2	5	16393
146	1	8	2	6	66168
147	1	8	2	5	61826
148	1	8	2	4	77649
149	1	8	2	1	11190
150	1	12	2	5	33375
151	1	14	2	5	27290
152	1	14	2	6	51545
153	1	14	2	1	369436
154	1	17	2	6	116877
155	1	17	2	5	39445
156	1	17	2	5	28413
157	1	17	2	6	83633
158	1	17	2	4	159900
159	1	17	2	1	588672
160	1	18	2	6	102991
161	1	18	2	5	55484
162	1	18	2	5	18312
163	1	18	2	6	3689
164	1	18	2	4	142770
165	1	18	2	1	146395
166	1	21	2	6	119758
167	1	21	2	5	62697
168	1	21	2	5	42603
169	1	21	2	6	106452
170	1	21	2	4	287723
171	1	21	2	1	326242
172	1	22	2	6	123998
173	1	22	2	5	51992
174	1	22	2	5	19421
175	1	22	2	6	143752
176	1	22	2	4	205731
177	1	22	2	1	292860
178	1	23	2	5	199986
179	1	23	2	4	16897
180	1	23	2	1	148278
181	1	23	2	4	16511
182	1	23	2	1	150880
183	1	24	2	5	132023
184	1	24	2	4	44294
185	1	24	2	1	193149
186	1	24	2	4	27155
187	1	24	2	1	78894
188	1	25	2	4	25932
189	1	25	2	1	171772
190	1	26	2	5	163757
191	1	26	2	4	96056
192	1	26	2	1	74933
193	1	26	2	4	92740
194	1	26	2	1	81618
195	1	27	2	1	249860
196	1	28	2	1	224390
197	1	33	2	5	48585
198	1	33	2	6	33074
199	1	33	2	1	501843
200	1	34	2	6	54939
201	1	34	2	5	56309
202	1	34	2	5	36858
203	1	34	2	6	40932
204	1	34	2	4	205596
205	1	34	2	1	313634
206	1	35	2	6	118403
207	1	35	2	5	23790
208	1	35	2	5	46749
209	1	35	2	6	82213
210	1	35	2	4	150453
211	1	35	2	1	336235
212	1	36	2	6	145509
213	1	36	2	5	58490
214	1	36	2	5	35131
215	1	36	2	6	11019
216	1	36	2	4	253076
217	1	36	2	1	594732
218	1	37	2	6	112032
219	1	37	2	5	38493
220	1	37	2	5	45802
221	1	37	2	6	45846
222	1	37	2	4	151361
223	1	37	2	1	409767
224	1	38	2	4	74253
225	1	38	2	1	98992
226	1	39	2	5	26087
227	1	39	2	6	70986
228	1	39	2	1	279757
229	1	40	2	6	115743
230	1	40	2	5	36204
231	1	40	2	5	40325
232	1	40	2	6	147565
233	1	40	2	4	192304
234	1	40	2	1	317778
235	1	41	2	4	97712
236	1	41	2	6	123291
237	1	44	2	5	95236
238	1	50	2	4	96613
239	1	50	2	6	117030
240	1	50	2	4	109483
241	1	50	2	6	149279
242	1	51	2	4	81611
243	1	51	2	6	89296
244	1	51	2	4	130953
245	1	51	2	6	58762
246	1	52	2	4	52369
247	1	52	2	6	117035
248	1	52	2	4	116931
249	1	52	2	6	108867
250	1	53	2	4	125021
251	1	53	2	6	73703
252	1	55	2	5	20066
253	1	55	2	6	8589
254	1	55	2	1	530769
255	1	56	2	5	29490
256	1	56	2	6	104642
257	1	56	2	1	411190
258	1	57	2	6	92246
259	1	57	2	5	4281
260	1	57	2	5	23171
261	1	57	2	6	42578
262	1	57	2	4	221069
263	1	57	2	1	315612
264	1	58	2	5	14353
265	1	58	2	6	35842
266	1	58	2	1	305173
267	1	59	2	6	72683
268	1	59	2	5	42345
269	1	59	2	5	3650
270	1	59	2	6	50026
271	1	59	2	4	294421
272	1	59	2	1	404361
273	1	60	2	6	92289
274	1	60	2	5	39545
275	1	60	2	5	11793
276	1	60	2	6	140865
277	1	60	2	4	284195
278	1	60	2	1	512617
279	1	1	3	5	267154
280	1	1	3	4	4427
281	1	1	3	1	131584
282	1	1	3	4	93876
283	1	1	3	1	90881
284	1	2	3	4	37589
285	1	2	3	1	100487
286	1	3	3	4	67594
287	1	3	3	6	92876
288	1	3	3	4	67196
289	1	3	3	6	136689
290	1	8	3	5	145760
291	1	8	3	4	65142
292	1	8	3	1	100568
293	1	8	3	4	37088
294	1	8	3	1	137488
295	1	12	3	5	6744
296	1	13	3	5	19238
297	1	17	3	6	73213
298	1	17	3	5	3899
299	1	17	3	5	11392
300	1	17	3	6	129792
301	1	17	3	4	122891
302	1	17	3	1	257161
303	1	18	3	6	119555
304	1	18	3	5	8320
305	1	18	3	5	19678
306	1	18	3	6	28099
307	1	18	3	4	114416
308	1	18	3	1	174065
309	1	27	3	1	379313
310	1	28	3	1	385757
311	1	32	3	6	109845
312	1	32	3	5	8532
313	1	32	3	5	19135
314	1	32	3	6	25831
315	1	32	3	4	255191
316	1	32	3	1	394861
317	1	33	3	6	114795
318	1	33	3	5	24974
319	1	33	3	5	34799
320	1	33	3	6	40579
321	1	33	3	4	102189
322	1	33	3	1	60843
323	1	34	3	6	65229
324	1	34	3	5	3237
325	1	34	3	5	31512
326	1	34	3	6	131810
327	1	34	3	4	134378
328	1	34	3	1	127499
329	1	35	3	6	91087
330	1	35	3	5	60924
331	1	35	3	5	14824
332	1	35	3	6	98039
333	1	35	3	4	203847
334	1	35	3	1	165631
335	1	36	3	6	102367
336	1	36	3	5	49915
337	1	36	3	5	41152
338	1	36	3	6	77967
339	1	36	3	4	159840
340	1	36	3	1	116139
341	1	37	3	6	65653
342	1	37	3	5	46197
343	1	37	3	6	44934
344	1	37	3	5	14460
345	1	37	3	4	94875
346	1	37	3	1	71484
347	1	39	3	5	19955
348	1	39	3	6	78758
349	1	39	3	1	344345
350	1	40	3	6	133126
351	1	40	3	5	52240
352	1	40	3	5	7829
353	1	40	3	6	52058
354	1	40	3	4	281666
355	1	40	3	1	211534
356	1	41	3	6	120596
357	1	41	3	5	8162
358	1	41	3	5	26755
359	1	41	3	6	128273
360	1	41	3	4	296656
361	1	41	3	1	584145
362	1	44	3	4	92458
363	1	44	3	6	96854
364	1	50	3	4	90145
365	1	50	3	6	101444
366	1	50	3	4	146003
367	1	50	3	6	144505
368	1	51	3	4	101535
369	1	51	3	6	50443
370	1	51	3	4	100097
371	1	51	3	6	54741
372	1	52	3	4	70860
373	1	52	3	6	95566
374	1	52	3	4	111169
375	1	52	3	6	113227
376	1	53	3	4	71530
377	1	53	3	6	87059
378	1	53	3	4	56365
379	1	53	3	6	123535
380	1	54	3	4	62324
381	1	54	3	6	76430
382	1	55	3	6	63120
383	1	55	3	5	49580
384	1	55	3	5	45446
385	1	55	3	6	95675
386	1	55	3	4	247805
387	1	55	3	1	482986
388	1	56	3	6	102080
389	1	56	3	5	45224
390	1	56	3	5	2022
391	1	56	3	6	7132
392	1	56	3	4	174181
393	1	56	3	1	104915
394	1	57	3	6	80581
395	1	57	3	5	14317
396	1	57	3	5	39462
397	1	57	3	6	11045
398	1	57	3	4	187800
399	1	57	3	1	247954
400	1	58	3	6	133552
401	1	58	3	5	6217
402	1	58	3	5	47230
403	1	58	3	6	95815
404	1	58	3	4	189004
405	1	58	3	1	298138
406	1	59	3	6	100802
407	1	59	3	5	64790
408	1	59	3	5	40719
409	1	59	3	6	38180
410	1	59	3	4	262142
411	1	59	3	1	567357
412	1	60	3	5	46639
413	1	1	4	5	145012
414	1	1	4	4	66286
415	1	1	4	1	186947
416	1	1	4	4	41413
417	1	1	4	1	113450
418	1	2	4	5	16446
419	1	3	4	5	288679
420	1	3	4	4	46452
421	1	3	4	1	116299
422	1	3	4	4	46345
423	1	3	4	1	192611
424	1	10	4	4	114877
425	1	10	4	6	93928
426	1	10	4	4	67140
427	1	10	4	6	129835
428	1	12	4	5	43732
429	1	13	4	5	71968
430	1	14	4	5	97298
431	1	16	4	1	299791
432	1	17	4	6	126766
433	1	17	4	5	35326
434	1	17	4	5	15113
435	1	17	4	6	96720
436	1	17	4	4	210248
437	1	17	4	1	171958
438	1	18	4	5	3198
439	1	18	4	6	110717
440	1	18	4	1	446347
441	1	20	4	1	385232
442	1	22	4	5	279123
443	1	22	4	4	33428
444	1	22	4	1	194188
445	1	22	4	4	38979
446	1	22	4	1	83826
447	1	23	4	4	95583
448	1	23	4	6	76050
449	1	26	4	1	156594
450	1	27	4	1	284865
451	1	28	4	1	276249
452	1	32	4	6	69936
453	1	32	4	5	63338
454	1	32	4	5	4725
455	1	32	4	6	66733
456	1	32	4	4	142237
457	1	32	4	1	271801
458	1	33	4	6	58756
459	1	33	4	5	15228
460	1	33	4	5	12404
461	1	33	4	6	21015
462	1	33	4	4	235289
463	1	33	4	1	160985
464	1	34	4	6	134102
465	1	34	4	5	12179
466	1	34	4	5	40448
467	1	34	4	6	38476
468	1	34	4	4	270258
469	1	34	4	1	61258
470	1	35	4	6	59907
471	1	35	4	5	36328
472	1	35	4	5	29328
473	1	35	4	6	13409
474	1	35	4	4	167042
475	1	35	4	1	67834
476	1	36	4	6	68785
477	1	36	4	5	41427
478	1	36	4	5	16174
479	1	36	4	6	81645
480	1	36	4	4	231379
481	1	36	4	1	173792
482	1	37	4	5	3589
483	1	37	4	6	41735
484	1	37	4	1	523057
485	1	39	4	6	52672
486	1	39	4	5	9113
487	1	39	4	6	26197
488	1	39	4	5	34869
489	1	39	4	4	66164
490	1	39	4	1	76583
491	1	40	4	6	119339
492	1	40	4	5	41851
493	1	40	4	5	9593
494	1	40	4	6	58871
495	1	40	4	4	201572
496	1	40	4	1	90279
497	1	41	4	6	60058
498	1	41	4	5	56166
499	1	41	4	5	28526
500	1	41	4	6	11131
501	1	41	4	4	275993
502	1	41	4	1	580325
503	1	42	4	6	140538
504	1	42	4	5	41604
505	1	42	4	5	25704
506	1	42	4	6	124153
507	1	42	4	4	127207
508	1	42	4	1	365220
509	1	51	4	4	51702
510	1	51	4	6	128676
511	1	51	4	4	72362
512	1	51	4	6	91675
513	1	52	4	4	140396
514	1	52	4	6	109058
515	1	53	4	6	144134
516	1	53	4	5	11839
517	1	53	4	5	3940
518	1	53	4	6	10900
519	1	53	4	4	285578
520	1	53	4	1	481586
521	1	54	4	6	54877
522	1	54	4	5	27057
523	1	54	4	5	23913
524	1	54	4	6	36281
525	1	54	4	4	109862
526	1	54	4	1	530768
527	1	55	4	5	18229
528	1	55	4	6	146865
529	1	55	4	1	160309
530	1	56	4	6	93166
531	1	56	4	5	22368
532	1	56	4	5	48123
533	1	56	4	6	122103
534	1	56	4	4	145750
535	1	56	4	1	367546
536	1	57	4	6	94627
537	1	57	4	5	21195
538	1	57	4	5	16115
539	1	57	4	6	147101
540	1	57	4	4	291486
541	1	57	4	1	452169
542	1	58	4	6	64857
543	1	58	4	5	28994
544	1	58	4	5	36770
545	1	58	4	6	71048
546	1	58	4	4	184128
547	1	58	4	1	496696
548	1	59	4	6	52292
549	1	59	4	5	44328
550	1	59	4	5	43849
551	1	59	4	6	28190
552	1	59	4	4	253013
553	1	59	4	1	292031
554	1	60	4	5	23199
555	1	60	4	6	15872
556	1	60	4	1	85553
557	1	1	5	4	34303
558	1	1	5	1	197719
559	1	2	5	4	29172
560	1	2	5	1	121535
561	1	3	5	5	192553
562	1	3	5	4	39333
563	1	3	5	1	92574
564	1	3	5	4	85642
565	1	3	5	1	122952
566	1	4	5	5	174002
567	1	4	5	4	20321
568	1	4	5	1	185740
569	1	4	5	4	75236
570	1	4	5	1	98978
571	1	9	5	5	38886
572	1	9	5	6	45713
573	1	9	5	5	76603
574	1	9	5	1	325190
575	1	9	5	1	67114
576	1	12	5	5	57482
577	1	13	5	1	105416
578	1	14	5	5	11861
579	1	15	5	5	81356
580	1	17	5	6	118274
581	1	17	5	5	57947
582	1	17	5	5	30918
583	1	17	5	6	58782
584	1	17	5	4	100646
585	1	17	5	1	376628
586	1	18	5	6	87895
587	1	18	5	5	44025
588	1	18	5	5	2220
589	1	18	5	6	99861
590	1	18	5	4	120788
591	1	18	5	1	211391
592	1	21	5	6	7193
593	1	21	5	5	38201
594	1	21	5	6	96997
595	1	21	5	5	63589
596	1	21	5	4	57865
597	1	21	5	1	94995
598	1	22	5	5	38670
599	1	22	5	6	63274
600	1	22	5	1	84237
601	1	23	5	5	6187
602	1	23	5	6	93968
603	1	23	5	1	58424
604	1	24	5	5	2816
605	1	24	5	6	44289
606	1	24	5	5	76906
607	1	24	5	1	209449
608	1	24	5	1	65363
609	1	25	5	5	41612
610	1	25	5	6	56493
611	1	25	5	5	77921
612	1	25	5	1	392093
613	1	25	5	1	94283
614	1	26	5	1	84030
615	1	27	5	1	63916
616	1	28	5	1	238219
617	1	29	5	1	237195
618	1	32	5	6	129474
619	1	32	5	5	50485
620	1	32	5	5	8012
621	1	32	5	6	66033
622	1	32	5	4	164512
623	1	32	5	1	511880
624	1	33	5	5	62593
625	1	34	5	5	19492
626	1	34	5	6	54032
627	1	34	5	1	170209
628	1	35	5	6	55539
629	1	35	5	5	30318
630	1	35	5	5	7809
631	1	35	5	6	9489
632	1	35	5	4	297214
633	1	35	5	1	436386
634	1	37	5	6	68652
635	1	37	5	5	39991
636	1	37	5	5	44855
637	1	37	5	6	56869
638	1	37	5	4	255726
639	1	37	5	1	249346
640	1	38	5	5	41138
641	1	38	5	6	20134
642	1	38	5	1	137772
643	1	39	5	6	117404
644	1	39	5	5	33789
645	1	39	5	5	8604
646	1	39	5	6	85080
647	1	39	5	4	175741
648	1	39	5	1	463648
649	1	40	5	6	99401
650	1	40	5	5	39384
651	1	40	5	5	37760
652	1	40	5	6	77313
653	1	40	5	4	125616
654	1	40	5	1	115913
655	1	41	5	5	48594
656	1	41	5	6	63112
657	1	41	5	1	419949
658	1	42	5	6	119375
659	1	42	5	5	65218
660	1	42	5	5	20900
661	1	42	5	6	125833
662	1	42	5	4	159063
663	1	42	5	1	513527
664	1	43	5	6	120543
665	1	43	5	5	56632
666	1	43	5	5	16699
667	1	43	5	6	77935
668	1	43	5	4	162386
669	1	43	5	1	155507
670	1	47	5	5	50079
671	1	50	5	4	118793
672	1	50	5	6	70247
673	1	50	5	4	81551
674	1	50	5	6	137014
675	1	51	5	4	80686
676	1	51	5	6	133349
677	1	51	5	4	117701
678	1	51	5	6	100831
679	1	52	5	4	144064
680	1	52	5	6	91918
681	1	52	5	4	80303
682	1	52	5	6	50612
683	1	53	5	5	40181
684	1	54	5	6	112977
685	1	54	5	5	48553
686	1	54	5	5	4184
687	1	54	5	6	20061
688	1	54	5	4	164805
689	1	54	5	1	199028
690	1	55	5	5	6035
691	1	55	5	6	30234
692	1	55	5	1	334170
693	1	56	5	5	34649
694	1	56	5	6	127701
695	1	56	5	1	376042
696	1	57	5	5	13450
697	1	57	5	6	146835
698	1	57	5	1	156608
699	1	58	5	6	106691
700	1	58	5	5	13165
701	1	58	5	5	49845
702	1	58	5	6	134718
703	1	58	5	4	166911
704	1	58	5	1	591076
705	1	59	5	6	58684
706	1	59	5	5	31079
707	1	59	5	5	24002
708	1	59	5	6	57113
709	1	59	5	4	275058
710	1	59	5	1	107469
711	1	60	5	6	58481
712	1	60	5	5	65548
713	1	60	5	5	41427
714	1	60	5	6	12811
715	1	60	5	4	133186
716	1	60	5	1	151964
717	1	1	6	4	71417
718	1	1	6	1	83173
719	1	2	6	5	154302
720	1	2	6	4	45117
721	1	2	6	1	159403
722	1	2	6	4	34198
723	1	2	6	1	116238
724	1	3	6	4	47555
725	1	3	6	1	154702
726	1	4	6	5	111386
727	1	4	6	4	94317
728	1	4	6	1	136038
729	1	4	6	4	69592
730	1	4	6	1	137986
731	1	5	6	4	98857
732	1	5	6	1	145254
733	1	7	6	4	58632
734	1	7	6	6	105083
735	1	11	6	5	81716
736	1	12	6	5	59736
737	1	16	6	6	109554
738	1	16	6	5	24754
739	1	16	6	5	43315
740	1	16	6	6	31505
741	1	16	6	4	286543
742	1	16	6	1	344952
743	1	17	6	5	38459
744	1	17	6	6	61538
745	1	17	6	1	83455
746	1	18	6	5	19140
747	1	18	6	6	28729
748	1	18	6	1	549302
749	1	20	6	5	49216
750	1	20	6	6	69184
751	1	20	6	5	91705
752	1	20	6	1	247292
753	1	20	6	1	90257
754	1	21	6	5	44519
755	1	21	6	6	80196
756	1	21	6	5	78620
757	1	21	6	1	380623
758	1	21	6	1	35765
759	1	22	6	5	24143
760	1	22	6	6	88799
761	1	22	6	1	97377
762	1	23	6	6	90248
763	1	23	6	5	29417
764	1	23	6	6	62295
765	1	23	6	5	64743
766	1	23	6	4	40274
767	1	23	6	1	93301
768	1	24	6	6	93692
769	1	24	6	5	32048
770	1	24	6	6	99279
771	1	24	6	5	10349
772	1	24	6	4	71444
773	1	24	6	1	50717
774	1	25	6	4	61089
775	1	25	6	1	144055
776	1	26	6	1	54747
777	1	27	6	1	93933
778	1	28	6	1	252943
779	1	29	6	1	160286
780	1	30	6	1	289867
781	1	34	6	6	86737
782	1	34	6	5	20550
783	1	34	6	5	31319
784	1	34	6	6	125850
785	1	34	6	4	196474
786	1	34	6	1	292497
787	1	35	6	6	50208
788	1	35	6	5	61579
789	1	35	6	5	34869
790	1	35	6	6	137067
791	1	35	6	4	283921
792	1	35	6	1	281048
793	1	39	6	5	3924
794	1	39	6	6	111332
795	1	39	6	1	90073
796	1	40	6	5	42260
797	1	40	6	6	42246
798	1	40	6	1	97572
799	1	42	6	5	114726
800	1	42	6	4	97720
801	1	42	6	1	129340
802	1	42	6	4	64514
803	1	42	6	1	131241
804	1	43	6	5	37650
805	1	43	6	6	139409
806	1	43	6	1	247242
807	1	44	6	5	19268
808	1	44	6	6	137451
809	1	44	6	1	450294
810	1	48	6	5	79565
811	1	51	6	4	119967
812	1	51	6	6	64923
813	1	51	6	4	55029
814	1	51	6	6	80823
815	1	52	6	6	64889
816	1	52	6	5	12466
817	1	52	6	5	33665
818	1	52	6	6	146960
819	1	52	6	4	264700
820	1	52	6	1	503093
821	1	53	6	6	57396
822	1	53	6	5	14085
823	1	53	6	5	11739
824	1	53	6	6	133149
825	1	53	6	4	257802
826	1	53	6	1	270774
827	1	54	6	5	18246
828	1	54	6	6	49981
829	1	54	6	1	82732
830	1	55	6	1	186575
831	1	57	6	6	137891
832	1	57	6	5	22474
833	1	57	6	5	39095
834	1	57	6	6	15946
835	1	57	6	4	140571
836	1	57	6	1	563037
837	1	58	6	6	69064
838	1	58	6	5	59346
839	1	58	6	5	14144
840	1	58	6	6	57376
841	1	58	6	4	151276
842	1	58	6	1	527037
843	1	59	6	6	56201
844	1	59	6	5	22220
845	1	59	6	5	29489
846	1	59	6	6	86306
847	1	59	6	4	140701
848	1	59	6	1	360504
849	1	60	6	6	111287
850	1	60	6	5	42037
851	1	60	6	5	40448
852	1	60	6	6	123023
853	1	60	6	4	170210
854	1	60	6	1	424861
855	1	1	7	4	46801
856	1	1	7	1	84289
857	1	2	7	5	133494
858	1	2	7	4	82405
859	1	2	7	1	107178
860	1	2	7	4	46538
861	1	2	7	1	119912
862	1	3	7	5	299258
863	1	3	7	4	734
864	1	3	7	1	117353
865	1	3	7	4	486
866	1	3	7	1	162287
867	1	4	7	5	153604
868	1	4	7	4	59024
869	1	4	7	1	89419
870	1	4	7	4	93488
871	1	4	7	1	97858
872	1	5	7	5	287331
873	1	5	7	4	37853
874	1	5	7	1	186712
875	1	5	7	4	50922
876	1	5	7	1	74620
877	1	6	7	4	12580
878	1	6	7	1	91701
879	1	7	7	5	36010
880	1	13	7	1	195760
881	1	14	7	5	28194
882	1	14	7	6	92289
883	1	14	7	1	1234
884	1	15	7	5	14741
885	1	15	7	6	30933
886	1	15	7	1	37175
887	1	16	7	5	22929
888	1	16	7	6	46367
889	1	16	7	1	434454
890	1	17	7	5	21182
891	1	17	7	6	69573
892	1	17	7	1	383671
893	1	18	7	6	91148
894	1	18	7	5	5536
895	1	18	7	5	29831
896	1	18	7	6	148089
897	1	18	7	4	182720
898	1	18	7	1	326620
899	1	20	7	6	8747
900	1	20	7	5	12969
901	1	20	7	6	75688
902	1	20	7	5	4098
903	1	20	7	4	15317
904	1	20	7	1	39736
905	1	21	7	6	15246
906	1	21	7	5	3357
907	1	21	7	6	31232
908	1	21	7	5	3245
909	1	21	7	4	88214
910	1	21	7	1	15310
911	1	22	7	5	27094
912	1	22	7	6	81640
913	1	22	7	1	37665
914	1	23	7	5	19390
915	1	23	7	6	96825
916	1	23	7	1	50378
917	1	24	7	5	47631
918	1	24	7	6	15239
919	1	24	7	5	88674
920	1	24	7	1	301535
921	1	24	7	1	42100
922	1	25	7	5	35671
923	1	25	7	6	83881
924	1	25	7	5	105620
925	1	25	7	1	471837
926	1	25	7	1	27960
927	1	26	7	1	174396
928	1	27	7	5	284429
929	1	27	7	4	87801
930	1	27	7	1	164088
931	1	27	7	4	95416
932	1	27	7	1	141150
933	1	29	7	1	336131
934	1	30	7	1	242551
935	1	31	7	4	131937
936	1	31	7	6	122332
937	1	31	7	4	128496
938	1	31	7	6	61254
939	1	32	7	4	135849
940	1	32	7	6	50041
941	1	33	7	6	82108
942	1	33	7	5	26979
943	1	33	7	5	5601
944	1	33	7	6	115699
945	1	33	7	4	263149
946	1	33	7	1	154192
947	1	34	7	6	54604
948	1	34	7	5	2118
949	1	34	7	5	21557
950	1	34	7	6	31441
951	1	34	7	4	107201
952	1	34	7	1	210165
953	1	35	7	5	20817
954	1	35	7	6	99214
955	1	35	7	1	419758
956	1	37	7	5	24254
957	1	37	7	6	26556
958	1	37	7	1	301167
959	1	40	7	5	42997
960	1	40	7	6	3157
961	1	40	7	1	51213
962	1	41	7	5	46620
963	1	41	7	6	97208
964	1	41	7	1	98889
965	1	42	7	6	33866
966	1	42	7	5	35867
967	1	42	7	6	80253
968	1	42	7	5	59472
969	1	42	7	4	1130
970	1	42	7	1	74764
971	1	43	7	6	126688
972	1	43	7	5	9153
973	1	43	7	5	24002
974	1	43	7	6	133686
975	1	43	7	4	176832
976	1	43	7	1	413255
977	1	44	7	6	126651
978	1	44	7	5	40563
979	1	44	7	5	38892
980	1	44	7	6	149592
981	1	44	7	4	291484
982	1	44	7	1	265712
983	1	45	7	6	146053
984	1	45	7	5	52228
985	1	45	7	5	29843
986	1	45	7	6	136384
987	1	45	7	4	166875
988	1	45	7	1	266694
989	1	46	7	6	108396
990	1	46	7	5	37655
991	1	46	7	5	39002
992	1	46	7	6	11845
993	1	46	7	4	224441
994	1	46	7	1	124972
995	1	47	7	6	149454
996	1	47	7	5	13729
997	1	47	7	5	30109
998	1	47	7	6	26858
999	1	47	7	4	146498
1000	1	47	7	1	562163
1001	1	48	7	5	19681
1002	1	48	7	6	15022
1003	1	48	7	1	592095
1004	1	50	7	4	54900
1005	1	50	7	6	79440
1006	1	50	7	4	91339
1007	1	50	7	6	54525
1008	1	51	7	5	122906
1009	1	51	7	4	93294
1010	1	51	7	1	174522
1011	1	51	7	4	52674
1012	1	51	7	1	199101
1013	1	52	7	5	47391
1014	1	52	7	6	103935
1015	1	52	7	1	203234
1016	1	53	7	5	4795
1017	1	53	7	6	19788
1018	1	53	7	1	176114
1019	1	54	7	6	103135
1020	1	54	7	5	23287
1021	1	54	7	5	31978
1022	1	54	7	6	55654
1023	1	54	7	4	244626
1024	1	54	7	1	347686
1025	1	55	7	6	137988
1026	1	55	7	5	5173
1027	1	55	7	5	10174
1028	1	55	7	6	94530
1029	1	55	7	4	190963
1030	1	55	7	1	174398
1031	1	56	7	6	118696
1032	1	56	7	5	62737
1033	1	56	7	5	12915
1034	1	56	7	6	67961
1035	1	56	7	4	261748
1036	1	56	7	1	150546
1037	1	57	7	6	91698
1038	1	57	7	5	66225
1039	1	57	7	5	30716
1040	1	57	7	6	103350
1041	1	57	7	4	200445
1042	1	57	7	1	559533
1043	1	58	7	6	103418
1044	1	58	7	5	51917
1045	1	58	7	5	9996
1046	1	58	7	6	13787
1047	1	58	7	4	146188
1048	1	58	7	1	445352
1049	1	59	7	6	142796
1050	1	59	7	5	57349
1051	1	59	7	5	22650
1052	1	59	7	6	128570
1053	1	59	7	4	202874
1054	1	59	7	1	535032
1055	1	60	7	6	113295
1056	1	60	7	5	13097
1057	1	60	7	5	34831
1058	1	60	7	6	22990
1059	1	60	7	4	252323
1060	1	60	7	1	405025
1061	1	1	8	5	186377
1062	1	1	8	4	48737
1063	1	1	8	1	143080
1064	1	1	8	4	27159
1065	1	1	8	1	115187
1066	1	3	8	5	162663
1067	1	3	8	4	22027
1068	1	3	8	1	109736
1069	1	3	8	4	3805
1070	1	3	8	1	133170
1071	1	4	8	5	265677
1072	1	4	8	4	40384
1073	1	4	8	1	123962
1074	1	4	8	4	5391
1075	1	4	8	1	134283
1076	1	5	8	5	153312
1077	1	5	8	4	95969
1078	1	5	8	1	91128
1079	1	5	8	4	97173
1080	1	5	8	1	115027
1081	1	6	8	5	199296
1082	1	6	8	4	84786
1083	1	6	8	1	134203
1084	1	6	8	4	9719
1085	1	6	8	1	162616
1086	1	7	8	4	27124
1087	1	7	8	1	194834
1088	1	9	8	5	246099
1089	1	9	8	4	27322
1090	1	9	8	1	111316
1091	1	9	8	4	79374
1092	1	9	8	1	83985
1093	1	14	8	5	13091
1094	1	14	8	6	51868
1095	1	14	8	5	68362
1096	1	14	8	1	476659
1097	1	14	8	1	47729
1098	1	15	8	4	147379
1099	1	15	8	6	115160
1100	1	16	8	4	12693
1101	1	16	8	1	179377
1102	1	17	8	5	11363
1103	1	17	8	6	34603
1104	1	17	8	1	390578
1105	1	18	8	6	57062
1106	1	18	8	5	10771
1107	1	18	8	5	5718
1108	1	18	8	6	72362
1109	1	18	8	4	117763
1110	1	18	8	1	245757
1111	1	20	8	1	175006
1112	1	21	8	6	50822
1113	1	21	8	5	11662
1114	1	21	8	6	7921
1115	1	21	8	5	60933
1116	1	21	8	4	12743
1117	1	21	8	1	84038
1118	1	22	8	5	49794
1119	1	22	8	6	81712
1120	1	22	8	5	109182
1121	1	22	8	1	313421
1122	1	22	8	1	47200
1123	1	23	8	5	27526
1124	1	23	8	6	36924
1125	1	23	8	1	56131
1126	1	24	8	5	11861
1127	1	24	8	6	97564
1128	1	24	8	5	84951
1129	1	24	8	1	330255
1130	1	24	8	1	53414
1131	1	25	8	5	5658
1132	1	25	8	6	46896
1133	1	25	8	5	98289
1134	1	25	8	1	211805
1135	1	25	8	1	17992
1136	1	28	8	5	123621
1137	1	28	8	4	14654
1138	1	28	8	1	82709
1139	1	28	8	4	36673
1140	1	28	8	1	149873
1141	1	29	8	1	333594
1142	1	30	8	1	365854
1143	1	31	8	4	138348
1144	1	31	8	6	58797
1145	1	32	8	4	73175
1146	1	32	8	6	130501
1147	1	32	8	4	70155
1148	1	32	8	6	54660
1149	1	33	8	5	36600
1150	1	33	8	6	129298
1151	1	33	8	1	92451
1152	1	34	8	5	15845
1153	1	34	8	6	91798
1154	1	34	8	5	112278
1155	1	34	8	1	293584
1156	1	34	8	1	21494
1157	1	35	8	5	17211
1158	1	35	8	6	147121
1159	1	35	8	1	563872
1160	1	36	8	6	102553
1161	1	36	8	5	44644
1162	1	36	8	5	32869
1163	1	36	8	6	7358
1164	1	36	8	4	241584
1165	1	36	8	1	584614
1166	1	37	8	6	93089
1167	1	37	8	5	14042
1168	1	37	8	5	3906
1169	1	37	8	6	53843
1170	1	37	8	4	145696
1171	1	37	8	1	420635
1172	1	39	8	6	36074
1173	1	39	8	5	28561
1174	1	39	8	6	41752
1175	1	39	8	5	63402
1176	1	39	8	4	28911
1177	1	39	8	1	10869
1178	1	41	8	6	22254
1179	1	41	8	5	49451
1180	1	41	8	6	49922
1181	1	41	8	5	7114
1182	1	41	8	4	18132
1183	1	41	8	1	13256
1184	1	45	8	6	122995
1185	1	45	8	5	41904
1186	1	45	8	5	27354
1187	1	45	8	6	115518
1188	1	45	8	4	174460
1189	1	45	8	1	392004
1190	1	46	8	6	52799
1191	1	46	8	5	37778
1192	1	46	8	5	31453
1193	1	46	8	6	18189
1194	1	46	8	4	290845
1195	1	46	8	1	345908
1196	1	47	8	6	56627
1197	1	47	8	5	46555
1198	1	47	8	5	16062
1199	1	47	8	6	71848
1200	1	47	8	4	139157
1201	1	47	8	1	77861
1202	1	48	8	5	42291
1203	1	48	8	6	60598
1204	1	48	8	5	95208
1205	1	48	8	1	321563
1206	1	48	8	1	92622
1207	1	49	8	5	22937
1208	1	49	8	6	73890
1209	1	49	8	1	36009
1210	1	50	8	5	2924
1211	1	50	8	6	20498
1212	1	50	8	1	25473
1213	1	51	8	5	103111
1214	1	51	8	4	2196
1215	1	51	8	1	168993
1216	1	51	8	4	226
1217	1	51	8	1	186370
1218	1	52	8	5	5903
1219	1	52	8	6	14816
1220	1	52	8	1	98525
1221	1	53	8	5	34385
1222	1	53	8	6	11813
1223	1	53	8	1	387128
1224	1	59	8	6	101287
1225	1	59	8	5	13087
1226	1	59	8	5	38312
1227	1	59	8	6	68111
1228	1	59	8	4	181331
1229	1	59	8	1	87285
1230	1	60	8	6	136626
1231	1	60	8	5	21457
1232	1	60	8	5	33225
1233	1	60	8	6	17342
1234	1	60	8	4	266967
1235	1	60	8	1	215204
1236	1	1	9	5	126199
1237	1	1	9	4	3665
1238	1	1	9	1	128142
1239	1	1	9	4	76667
1240	1	1	9	1	162941
1241	1	3	9	4	89038
1242	1	3	9	1	117964
1243	1	4	9	5	145858
1244	1	4	9	4	7985
1245	1	4	9	1	171105
1246	1	4	9	4	26300
1247	1	4	9	1	198416
1248	1	5	9	4	74361
1249	1	5	9	1	124640
1250	1	6	9	5	148459
1251	1	6	9	4	39593
1252	1	6	9	1	98868
1253	1	6	9	4	8568
1254	1	6	9	1	199686
1255	1	7	9	5	147880
1256	1	7	9	4	99674
1257	1	7	9	1	91912
1258	1	7	9	4	21110
1259	1	7	9	1	81555
1260	1	8	9	5	229460
1261	1	8	9	4	66381
1262	1	8	9	1	164523
1263	1	8	9	4	71530
1264	1	8	9	1	91370
1265	1	9	9	5	43280
1266	1	9	9	6	2979
1267	1	9	9	1	123447
1268	1	13	9	6	21938
1269	1	13	9	5	10113
1270	1	13	9	6	48048
1271	1	13	9	5	30829
1272	1	13	9	4	63966
1273	1	13	9	1	73854
1274	1	14	9	6	70043
1275	1	14	9	5	40883
1276	1	14	9	6	76028
1277	1	14	9	5	11122
1278	1	14	9	4	23825
1279	1	14	9	1	45727
1280	1	15	9	6	67181
1281	1	15	9	5	7241
1282	1	15	9	6	67971
1283	1	15	9	5	33733
1284	1	15	9	4	45660
1285	1	15	9	1	67076
1286	1	16	9	5	49619
1287	1	16	9	6	50370
1288	1	16	9	1	40006
1289	1	17	9	6	147419
1290	1	17	9	5	15808
1291	1	17	9	5	46352
1292	1	17	9	6	98626
1293	1	17	9	4	102572
1294	1	17	9	1	65415
1295	1	18	9	5	75397
1296	1	19	9	6	96670
1297	1	19	9	5	30303
1298	1	19	9	5	48262
1299	1	19	9	6	33035
1300	1	19	9	4	244323
1301	1	19	9	1	403827
1302	1	20	9	5	19564
1303	1	20	9	6	11553
1304	1	20	9	5	96606
1305	1	20	9	1	341614
1306	1	20	9	1	80448
1307	1	21	9	5	47637
1308	1	21	9	6	10079
1309	1	21	9	1	11040
1310	1	22	9	6	16053
1311	1	22	9	5	34472
1312	1	22	9	6	34078
1313	1	22	9	5	54192
1314	1	22	9	4	60897
1315	1	22	9	1	86373
1316	1	23	9	6	85640
1317	1	23	9	5	32492
1318	1	23	9	6	98767
1319	1	23	9	5	40139
1320	1	23	9	4	48066
1321	1	23	9	1	78049
1322	1	24	9	5	16544
1323	1	24	9	6	48167
1324	1	24	9	1	87881
1325	1	25	9	5	43818
1326	1	25	9	6	40835
1327	1	25	9	5	79633
1328	1	25	9	1	390106
1329	1	25	9	1	86989
1330	1	28	9	4	27308
1331	1	28	9	1	165632
1332	1	29	9	4	69432
1333	1	29	9	1	130827
1334	1	30	9	1	67805
1335	1	31	9	4	83376
1336	1	31	9	6	68402
1337	1	36	9	6	142698
1338	1	36	9	5	10018
1339	1	36	9	5	39189
1340	1	36	9	6	65582
1341	1	36	9	4	135132
1342	1	36	9	1	379841
1343	1	37	9	6	147820
1344	1	37	9	5	23548
1345	1	37	9	5	13864
1346	1	37	9	6	25628
1347	1	37	9	4	280311
1348	1	37	9	1	148661
1349	1	38	9	6	133217
1350	1	38	9	5	14008
1351	1	38	9	5	25597
1352	1	38	9	6	85791
1353	1	38	9	4	187511
1354	1	38	9	1	213217
1355	1	39	9	6	12864
1356	1	39	9	5	12113
1357	1	39	9	6	69751
1358	1	39	9	5	48919
1359	1	39	9	4	37453
1360	1	39	9	1	50273
1361	1	40	9	4	59332
1362	1	40	9	6	64147
1363	1	40	9	4	124318
1364	1	40	9	6	141931
1365	1	41	9	5	29394
1366	1	41	9	6	52800
1367	1	41	9	5	94210
1368	1	41	9	1	338950
1369	1	41	9	1	77422
1370	1	42	9	4	102807
1371	1	42	9	6	63016
1372	1	44	9	4	121350
1373	1	44	9	6	66431
1374	1	44	9	4	119482
1375	1	44	9	6	93243
1376	1	45	9	6	59275
1377	1	45	9	5	31740
1378	1	45	9	5	10906
1379	1	45	9	6	105255
1380	1	45	9	4	131998
1381	1	45	9	1	305575
1382	1	46	9	1	112841
1383	1	48	9	6	77553
1384	1	48	9	5	33032
1385	1	48	9	6	10076
1386	1	48	9	5	4569
1387	1	48	9	4	24945
1388	1	48	9	1	16236
1389	1	49	9	5	44291
1390	1	49	9	6	25792
1391	1	49	9	5	89208
1392	1	49	9	1	226500
1393	1	49	9	1	54358
1394	1	50	9	5	59198
1395	1	51	9	5	13682
1396	1	51	9	6	28572
1397	1	51	9	1	79157
1398	1	52	9	5	36003
1399	1	52	9	6	8933
1400	1	52	9	1	305410
1401	1	53	9	6	79823
1402	1	53	9	5	31817
1403	1	53	9	5	40587
1404	1	53	9	6	76427
1405	1	53	9	4	183810
1406	1	53	9	1	242378
1407	1	55	9	5	282881
1408	1	55	9	4	94559
1409	1	55	9	1	94981
1410	1	55	9	4	74602
1411	1	55	9	1	195122
1412	1	57	9	5	83531
1413	1	59	9	6	118094
1414	1	59	9	5	60886
1415	1	59	9	5	17180
1416	1	59	9	6	140123
1417	1	59	9	4	117737
1418	1	59	9	1	438338
1419	1	60	9	6	118905
1420	1	60	9	5	37145
1421	1	60	9	5	47380
1422	1	60	9	6	139855
1423	1	60	9	4	193957
1424	1	60	9	1	147948
1425	1	1	10	5	245385
1426	1	1	10	4	64118
1427	1	1	10	1	183776
1428	1	1	10	4	83615
1429	1	1	10	1	105062
1430	1	2	10	5	276897
1431	1	2	10	4	48247
1432	1	2	10	1	75604
1433	1	2	10	4	87899
1434	1	2	10	1	191845
1435	1	3	10	5	179635
1436	1	3	10	4	31936
1437	1	3	10	1	73231
1438	1	3	10	4	93440
1439	1	3	10	1	140879
1440	1	4	10	5	205236
1441	1	4	10	4	79969
1442	1	4	10	1	177278
1443	1	4	10	4	73939
1444	1	4	10	1	153278
1445	1	5	10	5	276709
1446	1	5	10	4	45313
1447	1	5	10	1	199063
1448	1	5	10	4	15610
1449	1	5	10	1	156007
1450	1	6	10	5	243079
1451	1	6	10	4	2614
1452	1	6	10	1	111810
1453	1	6	10	4	62446
1454	1	6	10	1	139403
1455	1	7	10	5	226235
1456	1	7	10	4	21226
1457	1	7	10	1	181679
1458	1	7	10	4	63660
1459	1	7	10	1	122847
1460	1	8	10	4	134026
1461	1	8	10	6	100167
1462	1	8	10	4	76439
1463	1	8	10	6	100529
1464	1	9	10	5	35959
1465	1	9	10	6	109073
1466	1	9	10	1	80907
1467	1	10	10	6	110938
1468	1	10	10	5	3186
1469	1	10	10	5	32429
1470	1	10	10	6	115013
1471	1	10	10	4	222468
1472	1	10	10	1	247337
1473	1	17	10	6	53634
1474	1	17	10	5	40526
1475	1	17	10	6	48023
1476	1	17	10	5	13318
1477	1	17	10	4	12458
1478	1	17	10	1	21745
1479	1	18	10	6	75651
1480	1	18	10	5	15304
1481	1	18	10	5	17878
1482	1	18	10	6	122056
1483	1	18	10	4	237149
1484	1	18	10	1	489861
1485	1	19	10	6	76367
1486	1	19	10	5	3531
1487	1	19	10	5	16882
1488	1	19	10	6	15087
1489	1	19	10	4	227846
1490	1	19	10	1	77589
1491	1	21	10	1	245130
1492	1	23	10	1	71434
1493	1	24	10	5	16614
1494	1	24	10	6	62410
1495	1	24	10	1	94558
1496	1	25	10	6	72552
1497	1	25	10	5	49474
1498	1	25	10	6	55211
1499	1	25	10	5	69949
1500	1	25	10	4	58036
1501	1	25	10	1	7905
1502	1	26	10	5	49188
1503	1	26	10	6	54081
1504	1	26	10	1	81433
1505	1	32	10	4	92762
1506	1	32	10	6	63360
1507	1	32	10	4	108918
1508	1	32	10	6	135975
1509	1	36	10	6	148795
1510	1	36	10	5	46701
1511	1	36	10	5	13886
1512	1	36	10	6	69342
1513	1	36	10	4	159499
1514	1	36	10	1	463757
1515	1	37	10	6	53584
1516	1	37	10	5	50239
1517	1	37	10	5	3132
1518	1	37	10	6	120605
1519	1	37	10	4	289109
1520	1	37	10	1	209010
1521	1	38	10	6	133196
1522	1	38	10	5	3272
1523	1	38	10	5	20089
1524	1	38	10	6	12005
1525	1	38	10	4	188815
1526	1	38	10	1	128740
1527	1	39	10	5	232796
1528	1	39	10	4	90659
1529	1	39	10	1	91747
1530	1	39	10	4	54833
1531	1	39	10	1	168513
1532	1	40	10	5	46901
1533	1	40	10	6	12866
1534	1	40	10	5	86395
1535	1	40	10	1	388498
1536	1	40	10	1	60092
1537	1	41	10	5	11161
1538	1	41	10	6	76888
1539	1	41	10	5	98199
1540	1	41	10	1	417644
1541	1	41	10	1	82451
1542	1	42	10	5	45939
1543	1	42	10	6	54561
1544	1	42	10	5	43508
1545	1	42	10	1	411907
1546	1	42	10	1	19460
1547	1	43	10	4	95815
1548	1	43	10	6	62828
1549	1	43	10	4	87239
1550	1	43	10	6	118217
1551	1	44	10	4	137042
1552	1	44	10	6	69910
1553	1	44	10	4	135525
1554	1	44	10	6	94930
1555	1	45	10	4	108301
1556	1	45	10	6	106251
1557	1	46	10	6	79469
1558	1	46	10	5	9821
1559	1	46	10	5	47044
1560	1	46	10	6	149832
1561	1	46	10	4	204172
1562	1	46	10	1	131143
1563	1	47	10	6	35079
1564	1	47	10	5	23606
1565	1	47	10	6	60908
1566	1	47	10	5	7965
1567	1	47	10	4	93610
1568	1	47	10	1	63630
1569	1	48	10	5	10283
1570	1	48	10	6	88125
1571	1	48	10	5	60272
1572	1	48	10	1	242502
1573	1	48	10	1	36621
1574	1	49	10	5	27545
1575	1	49	10	6	78851
1576	1	49	10	1	114364
1577	1	50	10	5	38150
1578	1	50	10	6	20027
1579	1	50	10	5	56345
1580	1	50	10	1	297428
1581	1	50	10	1	40706
1582	1	51	10	6	41684
1583	1	51	10	5	3416
1584	1	51	10	6	87502
1585	1	51	10	5	32200
1586	1	51	10	4	13240
1587	1	51	10	1	98129
1588	1	52	10	5	14503
1589	1	52	10	6	52303
1590	1	52	10	5	81909
1591	1	52	10	1	206276
1592	1	52	10	1	62067
1593	1	53	10	1	78621
1594	1	56	10	5	206503
1595	1	56	10	4	28269
1596	1	56	10	1	73872
1597	1	56	10	4	55201
1598	1	56	10	1	162248
1599	1	57	10	5	254593
1600	1	57	10	4	20626
1601	1	57	10	1	73702
1602	1	57	10	4	77910
1603	1	57	10	1	164024
1604	1	59	10	6	131851
1605	1	59	10	5	58166
1606	1	59	10	5	21547
1607	1	59	10	6	12540
1608	1	59	10	4	257633
1609	1	59	10	1	376254
1610	1	60	10	5	39830
1611	1	60	10	6	48932
1612	1	60	10	1	326039
1613	1	2	11	5	116922
1614	1	2	11	4	56190
1615	1	2	11	1	80064
1616	1	2	11	4	5726
1617	1	2	11	1	97334
1618	1	5	11	5	146118
1619	1	5	11	4	44418
1620	1	5	11	1	127140
1621	1	5	11	4	54900
1622	1	5	11	1	126791
1623	1	6	11	1	63443
1624	1	7	11	5	287075
1625	1	7	11	4	61923
1626	1	7	11	1	172883
1627	1	7	11	4	38358
1628	1	7	11	1	99174
1629	1	8	11	4	18443
1630	1	8	11	1	143186
1631	1	9	11	6	123274
1632	1	9	11	5	60008
1633	1	9	11	5	17277
1634	1	9	11	6	39269
1635	1	9	11	4	111573
1636	1	9	11	1	294449
1637	1	10	11	6	80317
1638	1	10	11	5	52229
1639	1	10	11	5	20979
1640	1	10	11	6	80383
1641	1	10	11	4	164531
1642	1	10	11	1	429047
1643	1	11	11	6	100745
1644	1	11	11	5	53648
1645	1	11	11	5	10839
1646	1	11	11	6	48013
1647	1	11	11	4	100528
1648	1	11	11	1	243174
1649	1	13	11	5	282046
1650	1	13	11	4	71004
1651	1	13	11	1	147601
1652	1	13	11	4	55565
1653	1	13	11	1	146750
1654	1	14	11	4	56609
1655	1	14	11	1	177896
1656	1	15	11	5	22428
1657	1	15	11	6	38478
1658	1	15	11	1	86806
1659	1	18	11	5	43721
1660	1	18	11	6	48379
1661	1	18	11	1	553660
1662	1	19	11	6	118061
1663	1	19	11	5	39715
1664	1	19	11	5	17425
1665	1	19	11	6	88980
1666	1	19	11	4	222268
1667	1	19	11	1	466582
1668	1	20	11	5	7043
1669	1	20	11	6	26724
1670	1	20	11	5	74703
1671	1	20	11	1	332797
1672	1	20	11	1	29300
1673	1	22	11	1	129685
1674	1	23	11	1	346865
1675	1	24	11	5	41573
1676	1	24	11	6	67398
1677	1	24	11	5	91079
1678	1	24	11	1	438543
1679	1	24	11	1	61302
1680	1	25	11	5	6555
1681	1	25	11	6	79978
1682	1	25	11	5	116802
1683	1	25	11	1	432314
1684	1	25	11	1	70214
1685	1	26	11	5	49470
1686	1	26	11	6	7826
1687	1	26	11	1	87257
1688	1	27	11	5	1711
1689	1	27	11	6	87491
1690	1	27	11	1	72180
1691	1	29	11	5	22441
1692	1	29	11	6	84002
1693	1	29	11	5	41857
1694	1	29	11	1	460794
1695	1	29	11	1	13476
1696	1	30	11	5	10729
1697	1	30	11	6	30808
1698	1	30	11	1	67102
1699	1	31	11	6	72788
1700	1	31	11	5	6384
1701	1	31	11	6	58055
1702	1	31	11	5	60769
1703	1	31	11	4	26391
1704	1	31	11	1	18380
1705	1	32	11	5	2779
1706	1	32	11	6	15660
1707	1	32	11	1	96074
1708	1	34	11	4	97529
1709	1	34	11	1	165941
1710	1	38	11	6	99396
1711	1	38	11	5	51285
1712	1	38	11	5	12087
1713	1	38	11	6	89458
1714	1	38	11	4	103905
1715	1	38	11	1	118049
1716	1	39	11	5	242352
1717	1	39	11	4	88964
1718	1	39	11	1	147039
1719	1	39	11	4	70702
1720	1	39	11	1	91720
1721	1	40	11	6	34622
1722	1	40	11	5	27486
1723	1	40	11	6	67951
1724	1	40	11	5	65848
1725	1	40	11	4	73001
1726	1	40	11	1	23863
1727	1	41	11	5	36324
1728	1	41	11	6	96884
1729	1	41	11	1	63793
1730	1	42	11	6	49363
1731	1	42	11	5	17618
1732	1	42	11	6	26680
1733	1	42	11	5	5634
1734	1	42	11	4	45347
1735	1	42	11	1	81242
1736	1	43	11	5	85737
1737	1	44	11	4	146514
1738	1	44	11	6	114368
1739	1	45	11	4	130135
1740	1	45	11	6	75766
1741	1	45	11	4	58243
1742	1	45	11	6	116616
1743	1	46	11	5	20910
1744	1	46	11	6	36906
1745	1	46	11	5	112524
1746	1	46	11	1	244765
1747	1	46	11	1	12907
1748	1	47	11	6	79390
1749	1	47	11	5	3688
1750	1	47	11	5	35148
1751	1	47	11	6	86239
1752	1	47	11	4	144926
1753	1	47	11	1	157950
1754	1	49	11	5	17443
1755	1	49	11	6	95242
1756	1	49	11	5	43626
1757	1	49	11	1	480886
1758	1	49	11	1	31257
1759	1	50	11	5	30441
1760	1	50	11	6	51260
1761	1	50	11	1	35455
1762	1	51	11	5	30808
1763	1	51	11	6	27343
1764	1	51	11	1	19141
1765	1	52	11	1	69519
1766	1	53	11	1	385581
1767	1	54	11	1	394292
1768	1	55	11	5	194451
1769	1	55	11	4	47497
1770	1	55	11	1	182186
1771	1	55	11	4	1927
1772	1	55	11	1	88195
1773	1	56	11	5	282174
1774	1	56	11	4	5622
1775	1	56	11	1	111127
1776	1	56	11	4	49294
1777	1	56	11	1	128579
1778	1	57	11	4	11715
1779	1	57	11	1	83319
1780	1	60	11	6	90012
1781	1	60	11	5	67066
1782	1	60	11	5	39278
1783	1	60	11	6	82322
1784	1	60	11	4	135245
1785	1	60	11	1	235339
1786	1	1	12	4	23978
1787	1	1	12	1	123563
1788	1	2	12	6	81598
1789	1	2	12	5	4786
1790	1	2	12	6	98614
1791	1	2	12	5	9475
1792	1	2	12	4	77826
1793	1	2	12	1	79178
1794	1	4	12	5	143249
1795	1	4	12	4	79355
1796	1	4	12	1	115220
1797	1	4	12	4	93868
1798	1	4	12	1	148594
1799	1	5	12	4	76175
1800	1	5	12	1	135130
1801	1	6	12	4	132854
1802	1	6	12	6	79722
1803	1	6	12	4	136415
1804	1	6	12	6	75863
1805	1	7	12	5	43999
1806	1	7	12	6	88052
1807	1	7	12	1	403372
1808	1	8	12	6	81440
1809	1	8	12	5	52005
1810	1	8	12	5	6754
1811	1	8	12	6	62617
1812	1	8	12	4	219841
1813	1	8	12	1	372745
1814	1	9	12	6	121446
1815	1	9	12	5	28824
1816	1	9	12	5	34341
1817	1	9	12	6	46921
1818	1	9	12	4	198924
1819	1	9	12	1	300498
1820	1	10	12	6	106522
1821	1	10	12	5	52520
1822	1	10	12	5	34045
1823	1	10	12	6	130067
1824	1	10	12	4	160185
1825	1	10	12	1	368734
1826	1	11	12	4	16045
1827	1	11	12	1	185683
1828	1	12	12	4	96678
1829	1	12	12	1	145726
1830	1	13	12	5	118914
1831	1	13	12	4	87892
1832	1	13	12	1	119650
1833	1	13	12	4	34238
1834	1	13	12	1	107905
1835	1	14	12	5	41276
1836	1	15	12	5	32223
1837	1	15	12	6	31423
1838	1	15	12	5	41765
1839	1	15	12	1	441524
1840	1	15	12	1	49155
1841	1	16	12	6	56225
1842	1	16	12	5	2850
1843	1	16	12	6	14762
1844	1	16	12	5	69882
1845	1	16	12	4	92483
1846	1	16	12	1	35933
1847	1	18	12	6	143685
1848	1	18	12	5	23597
1849	1	18	12	5	38433
1850	1	18	12	6	20332
1851	1	18	12	4	183928
1852	1	18	12	1	143394
1853	1	19	12	5	13230
1854	1	19	12	6	20488
1855	1	19	12	1	114106
1856	1	20	12	6	72748
1857	1	20	12	5	1188
1858	1	20	12	5	19210
1859	1	20	12	6	110903
1860	1	20	12	4	115980
1861	1	20	12	1	234917
1862	1	21	12	6	58505
1863	1	21	12	5	25983
1864	1	21	12	6	94772
1865	1	21	12	5	67375
1866	1	21	12	4	62630
1867	1	21	12	1	77460
1868	1	22	12	1	378057
1869	1	23	12	1	274663
1870	1	24	12	4	120860
1871	1	24	12	6	124759
1872	1	25	12	5	9336
1873	1	25	12	6	95010
1874	1	25	12	1	99630
1875	1	26	12	4	71346
1876	1	26	12	1	95224
1877	1	27	12	6	18216
1878	1	27	12	5	16514
1879	1	27	12	6	94647
1880	1	27	12	5	35844
1881	1	27	12	4	69189
1882	1	27	12	1	66350
1883	1	28	12	5	13576
1884	1	28	12	6	22075
1885	1	28	12	1	50336
1886	1	29	12	5	10231
1887	1	30	12	5	29716
1888	1	30	12	6	28562
1889	1	30	12	1	14498
1890	1	31	12	6	84191
1891	1	31	12	5	38812
1892	1	31	12	6	75646
1893	1	31	12	5	55763
1894	1	31	12	4	30386
1895	1	31	12	1	31081
1896	1	32	12	5	2637
1897	1	32	12	6	92971
1898	1	32	12	5	98057
1899	1	32	12	1	310155
1900	1	32	12	1	33023
1901	1	33	12	5	47416
1902	1	33	12	6	75650
1903	1	33	12	5	40723
1904	1	33	12	1	470018
1905	1	33	12	1	54989
1906	1	34	12	6	95577
1907	1	34	12	5	46667
1908	1	34	12	6	8602
1909	1	34	12	5	18058
1910	1	34	12	4	98375
1911	1	34	12	1	44369
1912	1	35	12	5	38106
1913	1	35	12	6	59177
1914	1	35	12	5	44410
1915	1	35	12	1	215453
1916	1	35	12	1	68692
1917	1	36	12	5	30532
1918	1	36	12	6	36276
1919	1	36	12	1	82791
1920	1	39	12	6	68627
1921	1	39	12	5	25911
1922	1	39	12	6	42179
1923	1	39	12	5	61517
1924	1	39	12	4	85316
1925	1	39	12	1	15668
1926	1	40	12	6	21342
1927	1	40	12	5	37464
1928	1	40	12	6	13158
1929	1	40	12	5	53167
1930	1	40	12	4	89576
1931	1	40	12	1	35022
1932	1	41	12	1	178463
1933	1	42	12	5	43359
1934	1	42	12	6	34854
1935	1	42	12	5	109274
1936	1	42	12	1	307118
1937	1	42	12	1	72486
1938	1	43	12	5	230339
1939	1	43	12	4	43188
1940	1	43	12	1	155767
1941	1	43	12	4	49482
1942	1	43	12	1	86165
1943	1	47	12	6	9417
1944	1	47	12	5	20324
1945	1	47	12	6	76633
1946	1	47	12	5	54289
1947	1	47	12	4	92916
1948	1	47	12	1	30921
1949	1	48	12	5	13847
1950	1	48	12	6	59371
1951	1	48	12	5	115920
1952	1	48	12	1	397302
1953	1	48	12	1	23853
1954	1	49	12	6	49690
1955	1	49	12	5	29212
1956	1	49	12	6	59099
1957	1	49	12	5	65303
1958	1	49	12	4	27355
1959	1	49	12	1	49174
1960	1	50	12	5	14327
1961	1	50	12	6	72525
1962	1	50	12	1	59421
1963	1	51	12	6	37957
1964	1	51	12	5	28379
1965	1	51	12	6	24998
1966	1	51	12	5	46018
1967	1	51	12	4	17940
1968	1	51	12	1	70761
1969	1	52	12	5	34911
1970	1	52	12	6	95756
1971	1	52	12	1	9944
1972	1	54	12	1	332557
1973	1	55	12	5	155898
1974	1	55	12	4	2466
1975	1	55	12	1	86371
1976	1	55	12	4	28432
1977	1	55	12	1	78220
1978	1	56	12	5	190786
1979	1	56	12	4	78315
1980	1	56	12	1	120243
1981	1	56	12	4	29844
1982	1	56	12	1	127554
1983	1	57	12	5	48665
1984	1	58	12	5	234652
1985	1	58	12	4	90296
1986	1	58	12	1	140396
1987	1	58	12	4	13471
1988	1	58	12	1	168286
1989	1	59	12	6	115533
1990	1	59	12	5	29051
1991	1	59	12	5	36907
1992	1	59	12	6	65324
1993	1	59	12	4	179367
1994	1	59	12	1	191629
1995	1	60	12	4	124211
1996	1	60	12	6	68724
1997	1	60	12	4	144481
1998	1	60	12	6	112539
1999	1	1	13	5	5796
2000	1	1	13	6	75696
2001	1	1	13	5	86078
2002	1	1	13	1	330755
2003	1	1	13	1	85468
2004	1	2	13	5	22069
2005	1	2	13	6	39112
2006	1	2	13	1	54409
2007	1	3	13	6	64748
2008	1	3	13	5	26910
2009	1	3	13	6	19119
2010	1	3	13	5	61347
2011	1	3	13	4	13961
2012	1	3	13	1	77176
2013	1	4	13	4	10015
2014	1	4	13	1	70754
2015	1	5	13	5	232899
2016	1	5	13	4	22554
2017	1	5	13	1	101583
2018	1	5	13	4	94012
2019	1	5	13	1	143123
2020	1	6	13	5	294238
2021	1	6	13	4	88468
2022	1	6	13	1	141965
2023	1	6	13	4	53496
2024	1	6	13	1	130374
2025	1	7	13	5	42835
2026	1	7	13	6	97142
2027	1	7	13	1	497878
2028	1	8	13	5	19444
2029	1	8	13	6	131097
2030	1	8	13	1	210112
2031	1	9	13	6	82744
2032	1	9	13	5	3123
2033	1	9	13	5	5385
2034	1	9	13	6	119901
2035	1	9	13	4	277741
2036	1	9	13	1	473163
2037	1	10	13	6	56935
2038	1	10	13	5	36177
2039	1	10	13	5	9591
2040	1	10	13	6	116115
2041	1	10	13	4	221616
2042	1	10	13	1	294758
2043	1	11	13	4	86321
2044	1	11	13	6	101079
2045	1	11	13	4	82688
2046	1	11	13	6	142637
2047	1	12	13	4	63504
2048	1	12	13	1	166116
2049	1	13	13	5	129325
2050	1	13	13	4	66290
2051	1	13	13	1	96560
2052	1	13	13	4	62043
2053	1	13	13	1	79727
2054	1	14	13	5	145755
2055	1	14	13	4	32999
2056	1	14	13	1	182003
2057	1	14	13	4	81091
2058	1	14	13	1	156164
2059	1	15	13	5	27772
2060	1	15	13	6	27241
2061	1	15	13	5	105173
2062	1	15	13	1	431160
2063	1	15	13	1	68148
2064	1	16	13	6	48324
2065	1	16	13	5	5931
2066	1	16	13	6	86547
2067	1	16	13	5	10513
2068	1	16	13	4	47571
2069	1	16	13	1	19390
2070	1	21	13	5	24524
2071	1	21	13	6	98071
2072	1	21	13	1	74618
2073	1	22	13	5	38026
2074	1	22	13	6	1975
2075	1	22	13	5	57781
2076	1	22	13	1	445132
2077	1	22	13	1	55381
2078	1	23	13	1	64671
2079	1	24	13	1	284081
2080	1	25	13	5	2307
2081	1	25	13	6	43801
2082	1	25	13	5	69937
2083	1	25	13	1	468063
2084	1	25	13	1	99632
2085	1	26	13	6	48063
2086	1	26	13	5	24345
2087	1	26	13	6	83004
2088	1	26	13	5	1466
2089	1	26	13	4	73597
2090	1	26	13	1	65569
2091	1	28	13	5	25290
2092	1	28	13	6	45879
2093	1	28	13	1	60168
2094	1	29	13	1	236672
2095	1	30	13	6	38274
2096	1	30	13	5	24884
2097	1	30	13	6	22297
2098	1	30	13	5	68107
2099	1	30	13	4	44335
2100	1	30	13	1	53216
2101	1	31	13	5	2176
2102	1	31	13	6	51452
2103	1	31	13	1	22256
2104	1	32	13	5	45967
2105	1	32	13	6	15478
2106	1	32	13	5	117003
2107	1	32	13	1	282063
2108	1	32	13	1	19247
2109	1	33	13	5	1731
2110	1	33	13	6	44042
2111	1	33	13	1	15833
2112	1	34	13	5	20746
2113	1	34	13	6	95749
2114	1	34	13	1	9493
2115	1	35	13	5	41447
2116	1	35	13	6	17237
2117	1	35	13	1	47588
2118	1	36	13	5	30759
2119	1	36	13	6	93154
2120	1	36	13	1	46171
2121	1	37	13	6	78990
2122	1	37	13	5	35773
2123	1	37	13	6	75089
2124	1	37	13	5	15127
2125	1	37	13	4	35202
2126	1	37	13	1	12466
2127	1	39	13	5	6203
2128	1	39	13	6	24620
2129	1	39	13	1	46408
2130	1	40	13	5	5600
2131	1	40	13	6	42382
2132	1	40	13	1	96780
2133	1	41	13	5	24766
2134	1	41	13	6	94267
2135	1	41	13	5	88375
2136	1	41	13	1	493300
2137	1	41	13	1	12990
2138	1	42	13	4	123053
2139	1	42	13	6	84575
2140	1	42	13	4	129853
2141	1	42	13	6	134227
2142	1	43	13	5	17243
2143	1	43	13	6	47755
2144	1	43	13	5	86672
2145	1	43	13	1	498371
2146	1	43	13	1	27591
2147	1	44	13	5	44280
2148	1	44	13	6	32394
2149	1	44	13	5	51510
2150	1	44	13	1	325435
2151	1	44	13	1	24849
2152	1	45	13	6	11329
2153	1	45	13	5	16893
2154	1	45	13	6	11738
2155	1	45	13	5	63957
2156	1	45	13	4	71657
2157	1	45	13	1	67130
2158	1	46	13	5	5093
2159	1	46	13	6	16081
2160	1	46	13	1	8822
2161	1	47	13	5	21601
2162	1	47	13	6	78125
2163	1	47	13	5	68313
2164	1	47	13	1	439373
2165	1	47	13	1	71596
2166	1	48	13	6	37523
2167	1	48	13	5	28071
2168	1	48	13	6	2409
2169	1	48	13	5	36859
2170	1	48	13	4	50652
2171	1	48	13	1	98706
2172	1	49	13	5	39694
2173	1	49	13	6	26053
2174	1	49	13	1	42059
2175	1	50	13	5	25407
2176	1	50	13	6	51444
2177	1	50	13	5	87149
2178	1	50	13	1	497640
2179	1	50	13	1	14316
2180	1	51	13	6	75316
2181	1	51	13	5	38766
2182	1	51	13	6	57199
2183	1	51	13	5	41064
2184	1	51	13	4	31982
2185	1	51	13	1	85492
2186	1	52	13	6	48749
2187	1	52	13	5	24877
2188	1	52	13	6	83314
2189	1	52	13	5	25104
2190	1	52	13	4	61146
2191	1	52	13	1	76639
2192	1	53	13	5	33481
2193	1	53	13	6	78071
2194	1	53	13	5	108177
2195	1	53	13	1	254256
2196	1	53	13	1	60553
2197	1	54	13	5	45554
2198	1	54	13	6	36441
2199	1	54	13	5	67279
2200	1	54	13	1	362634
2201	1	54	13	1	80345
2202	1	55	13	4	59838
2203	1	55	13	1	162677
2204	1	56	13	5	1841
2205	1	56	13	6	111120
2206	1	56	13	1	427424
2207	1	57	13	5	137865
2208	1	57	13	4	31433
2209	1	57	13	1	153607
2210	1	57	13	4	33289
2211	1	57	13	1	88318
2212	1	58	13	5	211065
2213	1	58	13	4	26202
2214	1	58	13	1	187121
2215	1	58	13	4	75986
2216	1	58	13	1	193774
2217	1	59	13	4	7438
2218	1	59	13	1	72785
2219	1	60	13	6	96230
2220	1	60	13	5	68489
2221	1	60	13	5	33924
2222	1	60	13	6	133669
2223	1	60	13	4	285291
2224	1	60	13	1	530255
2225	1	1	14	6	51120
2226	1	1	14	5	47631
2227	1	1	14	6	71773
2228	1	1	14	5	2559
2229	1	1	14	4	26084
2230	1	1	14	1	90306
2231	1	2	14	6	50560
2232	1	2	14	5	17627
2233	1	2	14	6	82433
2234	1	2	14	5	20214
2235	1	2	14	4	50870
2236	1	2	14	1	54915
2237	1	3	14	5	28780
2238	1	3	14	6	22073
2239	1	3	14	5	46551
2240	1	3	14	1	263138
2241	1	3	14	1	74281
2242	1	4	14	6	4036
2243	1	4	14	5	42231
2244	1	4	14	6	11155
2245	1	4	14	5	22667
2246	1	4	14	4	28152
2247	1	4	14	1	28174
2248	1	5	14	4	40422
2249	1	5	14	1	72124
2250	1	6	14	5	180619
2251	1	6	14	4	53660
2252	1	6	14	1	179378
2253	1	6	14	4	25825
2254	1	6	14	1	138590
2255	1	7	14	6	116333
2256	1	7	14	5	29468
2257	1	7	14	5	8210
2258	1	7	14	6	119711
2259	1	7	14	4	190924
2260	1	7	14	1	102446
2261	1	8	14	5	12206
2262	1	8	14	6	77032
2263	1	8	14	1	500912
2264	1	9	14	5	15933
2265	1	9	14	6	67507
2266	1	9	14	1	566298
2267	1	13	14	4	81155
2268	1	13	14	1	79649
2269	1	14	14	5	112588
2270	1	14	14	4	10449
2271	1	14	14	1	119073
2272	1	14	14	4	91002
2273	1	14	14	1	150986
2274	1	15	14	6	59089
2275	1	15	14	5	33842
2276	1	15	14	6	33977
2277	1	15	14	5	62269
2278	1	15	14	4	52242
2279	1	15	14	1	99618
2280	1	16	14	5	17984
2281	1	16	14	6	27125
2282	1	16	14	5	74993
2283	1	16	14	1	427248
2284	1	16	14	1	47612
2285	1	17	14	5	63412
2286	1	18	14	5	22470
2287	1	20	14	6	72507
2288	1	20	14	5	15129
2289	1	20	14	6	23583
2290	1	20	14	5	2159
2291	1	20	14	4	8855
2292	1	20	14	1	17751
2293	1	21	14	5	28297
2294	1	21	14	6	27765
2295	1	21	14	1	6624
2296	1	22	14	1	333196
2297	1	23	14	1	155882
2298	1	24	14	1	240250
2299	1	25	14	5	25034
2300	1	25	14	6	28990
2301	1	25	14	5	52530
2302	1	25	14	1	246106
2303	1	25	14	1	64216
2304	1	26	14	5	26739
2305	1	26	14	6	29175
2306	1	26	14	1	59292
2307	1	29	14	5	6988
2308	1	29	14	6	61578
2309	1	29	14	1	29028
2310	1	30	14	5	32596
2311	1	31	14	6	77909
2312	1	31	14	5	34681
2313	1	31	14	6	71669
2314	1	31	14	5	26466
2315	1	31	14	4	17661
2316	1	31	14	1	86921
2317	1	32	14	5	74028
2318	1	33	14	5	2258
2319	1	33	14	6	55329
2320	1	33	14	5	106970
2321	1	33	14	1	306225
2322	1	33	14	1	84192
2323	1	34	14	5	5039
2324	1	35	14	1	214807
2325	1	36	14	6	34019
2326	1	36	14	5	6623
2327	1	36	14	6	59836
2328	1	36	14	5	12042
2329	1	36	14	4	31237
2330	1	36	14	1	13772
2331	1	37	14	6	44555
2332	1	37	14	5	48107
2333	1	37	14	6	14984
2334	1	37	14	5	14718
2335	1	37	14	4	47598
2336	1	37	14	1	53393
2337	1	39	14	6	37884
2338	1	39	14	5	33174
2339	1	39	14	6	88813
2340	1	39	14	5	9239
2341	1	39	14	4	26186
2342	1	39	14	1	17518
2343	1	40	14	6	36510
2344	1	40	14	5	37168
2345	1	40	14	6	10987
2346	1	40	14	5	17431
2347	1	40	14	4	20267
2348	1	40	14	1	58585
2349	1	41	14	5	27490
2350	1	41	14	6	36006
2351	1	41	14	1	3694
2352	1	42	14	5	20724
2353	1	42	14	6	73071
2354	1	42	14	1	63729
2355	1	43	14	5	37163
2356	1	43	14	6	51673
2357	1	43	14	5	69772
2358	1	43	14	1	423572
2359	1	43	14	1	43896
2360	1	44	14	5	27684
2361	1	44	14	6	86833
2362	1	44	14	1	62661
2363	1	45	14	6	66331
2364	1	45	14	5	32053
2365	1	45	14	6	7428
2366	1	45	14	5	59166
2367	1	45	14	4	55696
2368	1	45	14	1	84344
2369	1	46	14	5	16476
2370	1	46	14	6	88721
2371	1	46	14	5	86135
2372	1	46	14	1	435160
2373	1	46	14	1	60782
2374	1	47	14	5	12227
2375	1	47	14	6	47932
2376	1	47	14	5	74497
2377	1	47	14	1	468740
2378	1	47	14	1	54988
2379	1	48	14	5	39478
2380	1	48	14	6	97697
2381	1	48	14	1	2472
2382	1	49	14	5	7800
2383	1	49	14	6	59286
2384	1	49	14	1	7150
2385	1	50	14	5	34430
2386	1	50	14	6	40127
2387	1	50	14	5	41673
2388	1	50	14	1	471780
2389	1	50	14	1	22698
2390	1	51	14	5	33655
2391	1	51	14	6	52099
2392	1	51	14	5	59480
2393	1	51	14	1	446183
2394	1	51	14	1	66009
2395	1	52	14	5	29272
2396	1	52	14	6	96543
2397	1	52	14	5	85712
2398	1	52	14	1	229674
2399	1	52	14	1	43157
2400	1	53	14	5	10536
2401	1	53	14	6	81377
2402	1	53	14	5	83764
2403	1	53	14	1	364809
2404	1	53	14	1	14864
2405	1	54	14	5	183661
2406	1	54	14	4	52263
2407	1	54	14	1	126656
2408	1	54	14	4	68413
2409	1	54	14	1	174608
2410	1	55	14	5	193140
2411	1	55	14	4	70476
2412	1	55	14	1	154672
2413	1	55	14	4	27373
2414	1	55	14	1	198192
2415	1	56	14	4	21995
2416	1	56	14	1	151877
2417	1	57	14	5	42552
2418	1	57	14	6	105486
2419	1	57	14	1	467514
2420	1	58	14	4	27021
2421	1	58	14	1	154882
2422	1	59	14	5	216883
2423	1	59	14	4	30078
2424	1	59	14	1	80084
2425	1	59	14	4	28875
2426	1	59	14	1	174505
2427	1	60	14	5	11335
2428	1	60	14	6	26525
2429	1	60	14	5	54731
2430	1	60	14	1	421213
2431	1	60	14	1	45895
2432	1	1	15	6	41660
2433	1	1	15	5	41367
2434	1	1	15	6	16903
2435	1	1	15	5	53506
2436	1	1	15	4	50003
2437	1	1	15	1	7806
2438	1	2	15	5	17886
2439	1	2	15	6	1050
2440	1	2	15	5	76470
2441	1	2	15	1	244258
2442	1	2	15	1	90069
2443	1	3	15	6	92070
2444	1	3	15	5	26251
2445	1	3	15	6	76941
2446	1	3	15	5	42009
2447	1	3	15	4	75337
2448	1	3	15	1	98983
2449	1	4	15	6	53407
2450	1	4	15	5	28505
2451	1	4	15	6	10383
2452	1	4	15	5	54971
2453	1	4	15	4	66385
2454	1	4	15	1	34446
2455	1	7	15	6	128142
2456	1	7	15	5	54189
2457	1	7	15	5	10845
2458	1	7	15	6	137280
2459	1	7	15	4	138304
2460	1	7	15	1	268177
2461	1	8	15	6	91310
2462	1	8	15	5	28281
2463	1	8	15	5	17069
2464	1	8	15	6	97722
2465	1	8	15	4	158014
2466	1	8	15	1	583289
2467	1	9	15	6	135793
2468	1	9	15	5	40197
2469	1	9	15	5	49637
2470	1	9	15	6	125862
2471	1	9	15	4	164384
2472	1	9	15	1	174434
2473	1	11	15	5	10070
2474	1	11	15	6	20311
2475	1	11	15	1	71639
2476	1	13	15	4	80531
2477	1	13	15	1	88975
2478	1	14	15	5	114516
2479	1	14	15	4	89155
2480	1	14	15	1	156834
2481	1	14	15	4	27043
2482	1	14	15	1	160710
2483	1	15	15	5	12353
2484	1	15	15	6	65530
2485	1	15	15	1	95211
2486	1	16	15	5	47181
2487	1	16	15	6	64787
2488	1	16	15	5	56280
2489	1	16	15	1	474627
2490	1	16	15	1	97840
2491	1	18	15	5	13693
2492	1	21	15	6	1270
2493	1	21	15	5	40963
2494	1	21	15	6	63404
2495	1	21	15	5	7773
2496	1	21	15	4	93605
2497	1	21	15	1	73326
2498	1	22	15	6	69999
2499	1	22	15	5	35976
2500	1	22	15	6	32534
2501	1	22	15	5	54332
2502	1	22	15	4	20385
2503	1	22	15	1	95310
2504	1	23	15	1	194367
2505	1	24	15	1	242355
2506	1	25	15	5	44079
2507	1	25	15	6	9236
2508	1	25	15	1	37394
2509	1	26	15	5	22012
2510	1	26	15	6	66150
2511	1	26	15	1	18903
2512	1	35	15	6	45013
2513	1	35	15	5	15325
2514	1	35	15	6	91863
2515	1	35	15	5	69643
2516	1	35	15	4	99998
2517	1	35	15	1	9689
2518	1	36	15	5	13468
2519	1	36	15	6	56290
2520	1	36	15	1	28341
2521	1	37	15	5	16994
2522	1	38	15	6	96034
2523	1	38	15	5	31722
2524	1	38	15	6	97920
2525	1	38	15	5	48006
2526	1	38	15	4	32451
2527	1	38	15	1	80506
2528	1	39	15	6	26994
2529	1	39	15	5	20331
2530	1	39	15	6	48568
2531	1	39	15	5	36066
2532	1	39	15	4	45019
2533	1	39	15	1	5519
2534	1	40	15	5	29786
2535	1	40	15	6	23450
2536	1	40	15	5	73287
2537	1	40	15	1	415084
2538	1	40	15	1	32119
2539	1	41	15	5	11455
2540	1	41	15	6	78836
2541	1	41	15	5	59495
2542	1	41	15	1	209083
2543	1	41	15	1	62850
2544	1	42	15	5	8818
2545	1	42	15	6	6418
2546	1	42	15	1	35219
2547	1	43	15	5	33350
2548	1	43	15	6	50551
2549	1	43	15	1	29555
2550	1	44	15	6	16654
2551	1	44	15	5	35239
2552	1	44	15	6	42891
2553	1	44	15	5	6458
2554	1	44	15	4	66865
2555	1	44	15	1	14767
2556	1	45	15	5	270159
2557	1	45	15	4	34853
2558	1	45	15	1	91555
2559	1	45	15	4	49908
2560	1	45	15	1	176799
2561	1	46	15	6	38416
2562	1	46	15	5	44911
2563	1	46	15	6	79048
2564	1	46	15	5	9297
2565	1	46	15	4	14553
2566	1	46	15	1	31605
2567	1	47	15	5	4990
2568	1	47	15	6	50008
2569	1	47	15	1	86992
2570	1	48	15	1	81092
2571	1	49	15	5	3926
2572	1	49	15	6	71603
2573	1	49	15	5	114610
2574	1	49	15	1	277617
2575	1	49	15	1	84338
2576	1	52	15	4	149369
2577	1	52	15	6	84927
2578	1	52	15	4	63727
2579	1	52	15	6	59091
2580	1	53	15	5	23334
2581	1	53	15	6	97297
2582	1	53	15	5	118086
2583	1	53	15	1	253425
2584	1	53	15	1	80576
2585	1	54	15	5	40511
2586	1	54	15	6	50587
2587	1	54	15	5	52617
2588	1	54	15	1	330807
2589	1	54	15	1	41370
2590	1	55	15	4	48593
2591	1	55	15	1	102972
2592	1	56	15	4	53364
2593	1	56	15	1	80780
2594	1	57	15	5	20937
2595	1	57	15	6	96008
2596	1	57	15	5	57245
2597	1	57	15	1	453674
2598	1	57	15	1	91517
2599	1	58	15	5	288862
2600	1	58	15	4	22368
2601	1	58	15	1	133062
2602	1	58	15	4	52194
2603	1	58	15	1	190080
2604	1	59	15	5	139041
2605	1	59	15	4	52613
2606	1	59	15	1	179487
2607	1	59	15	4	9477
2608	1	59	15	1	164269
2609	1	60	15	5	255606
2610	1	60	15	4	98002
2611	1	60	15	1	75128
2612	1	60	15	4	51548
2613	1	60	15	1	79604
2614	1	1	16	6	19893
2615	1	1	16	5	1424
2616	1	1	16	6	40822
2617	1	1	16	5	46856
2618	1	1	16	4	6919
2619	1	1	16	1	27131
2620	1	3	16	5	26004
2621	1	3	16	6	11057
2622	1	3	16	1	44900
2623	1	4	16	6	97337
2624	1	4	16	5	9589
2625	1	4	16	5	38219
2626	1	4	16	6	29368
2627	1	4	16	4	124089
2628	1	4	16	1	137958
2629	1	5	16	5	22105
2630	1	5	16	6	5794
2631	1	5	16	1	78089
2632	1	6	16	6	30921
2633	1	6	16	5	13559
2634	1	6	16	6	8472
2635	1	6	16	5	22027
2636	1	6	16	4	17989
2637	1	6	16	1	52424
2638	1	7	16	4	73368
2639	1	7	16	6	82737
2640	1	7	16	4	123717
2641	1	7	16	6	82525
2642	1	8	16	6	63380
2643	1	8	16	5	27359
2644	1	8	16	5	8006
2645	1	8	16	6	53672
2646	1	8	16	4	214423
2647	1	8	16	1	261878
2648	1	9	16	6	117507
2649	1	9	16	5	14701
2650	1	9	16	5	43035
2651	1	9	16	6	16172
2652	1	9	16	4	220754
2653	1	9	16	1	387162
2654	1	12	16	6	35690
2655	1	12	16	5	3591
2656	1	12	16	6	93344
2657	1	12	16	5	69810
2658	1	12	16	4	20575
2659	1	12	16	1	28850
2660	1	13	16	1	163962
2661	1	14	16	4	33565
2662	1	14	16	1	191903
2663	1	15	16	5	8777
2664	1	15	16	6	38262
2665	1	15	16	1	10740
2666	1	16	16	5	17465
2667	1	16	16	6	99492
2668	1	16	16	5	47810
2669	1	16	16	1	488803
2670	1	16	16	1	85026
2671	1	18	16	5	6485
2672	1	19	16	5	28419
2673	1	24	16	5	138288
2674	1	24	16	4	86607
2675	1	24	16	1	145760
2676	1	24	16	4	45100
2677	1	24	16	1	166618
2678	1	25	16	5	30772
2679	1	25	16	6	49846
2680	1	25	16	1	22181
2681	1	26	16	6	50218
2682	1	26	16	5	20881
2683	1	26	16	6	67131
2684	1	26	16	5	7916
2685	1	26	16	4	68573
2686	1	26	16	1	83580
2687	1	28	16	1	333913
2688	1	29	16	1	268409
2689	1	31	16	5	49081
2690	1	31	16	6	65429
2691	1	31	16	1	35442
2692	1	34	16	6	37238
2693	1	34	16	5	42389
2694	1	34	16	6	76589
2695	1	34	16	5	1756
2696	1	34	16	4	59292
2697	1	34	16	1	93566
2698	1	35	16	6	83403
2699	1	35	16	5	16645
2700	1	35	16	6	21265
2701	1	35	16	5	18423
2702	1	35	16	4	40784
2703	1	35	16	1	48686
2704	1	36	16	6	75527
2705	1	36	16	5	28182
2706	1	36	16	6	49472
2707	1	36	16	5	62328
2708	1	36	16	4	34182
2709	1	36	16	1	8828
2710	1	37	16	5	1362
2711	1	37	16	6	80865
2712	1	37	16	5	98523
2713	1	37	16	1	408433
2714	1	37	16	1	50894
2715	1	39	16	6	90531
2716	1	39	16	5	6478
2717	1	39	16	6	56947
2718	1	39	16	5	69953
2719	1	39	16	4	82320
2720	1	39	16	1	18174
2721	1	40	16	5	29642
2722	1	40	16	6	9450
2723	1	40	16	5	106995
2724	1	40	16	1	212150
2725	1	40	16	1	71009
2726	1	41	16	5	15498
2727	1	41	16	6	91751
2728	1	41	16	5	119260
2729	1	41	16	1	408577
2730	1	41	16	1	64809
2731	1	42	16	4	145782
2732	1	42	16	6	124210
2733	1	42	16	4	138886
2734	1	42	16	6	84620
2735	1	43	16	5	12634
2736	1	43	16	6	84265
2737	1	43	16	5	68217
2738	1	43	16	1	498102
2739	1	43	16	1	80138
2740	1	44	16	5	39741
2741	1	44	16	6	90690
2742	1	44	16	1	3077
2743	1	45	16	5	42158
2744	1	46	16	5	9453
2745	1	47	16	5	14557
2746	1	47	16	6	21265
2747	1	47	16	1	22008
2748	1	49	16	5	22173
2749	1	49	16	6	93173
2750	1	49	16	5	79760
2751	1	49	16	1	217505
2752	1	49	16	1	38146
2753	1	55	16	5	292420
2754	1	55	16	4	68456
2755	1	55	16	1	189188
2756	1	55	16	4	38595
2757	1	55	16	1	155103
2758	1	56	16	4	92526
2759	1	56	16	1	184069
2760	1	57	16	5	115925
2761	1	57	16	4	45633
2762	1	57	16	1	90779
2763	1	57	16	4	83680
2764	1	57	16	1	113928
2765	1	58	16	5	150996
2766	1	58	16	4	56780
2767	1	58	16	1	184794
2768	1	58	16	4	82020
2769	1	58	16	1	189463
2770	1	59	16	4	85281
2771	1	59	16	1	75303
2772	1	60	16	5	275865
2773	1	60	16	4	18961
2774	1	60	16	1	126584
2775	1	60	16	4	67540
2776	1	60	16	1	132620
2777	1	1	17	6	59403
2778	1	1	17	5	3505
2779	1	1	17	6	72544
2780	1	1	17	5	20235
2781	1	1	17	4	85178
2782	1	1	17	1	68439
2783	1	2	17	5	108734
2784	1	2	17	4	78246
2785	1	2	17	1	98717
2786	1	2	17	4	14043
2787	1	2	17	1	136064
2788	1	3	17	6	73303
2789	1	3	17	5	18676
2790	1	3	17	6	58210
2791	1	3	17	5	45027
2792	1	3	17	4	82322
2793	1	3	17	1	87036
2794	1	4	17	5	22794
2795	1	4	17	6	17077
2796	1	4	17	1	83641
2797	1	5	17	6	46207
2798	1	5	17	5	9911
2799	1	5	17	6	38440
2800	1	5	17	5	11930
2801	1	5	17	4	71233
2802	1	5	17	1	73226
2803	1	6	17	5	24039
2804	1	6	17	6	45584
2805	1	6	17	1	84007
2806	1	7	17	6	11257
2807	1	7	17	5	37992
2808	1	7	17	6	86055
2809	1	7	17	5	27169
2810	1	7	17	4	24333
2811	1	7	17	1	53853
2812	1	8	17	5	19065
2813	1	8	17	6	56547
2814	1	8	17	1	529353
2815	1	9	17	6	62848
2816	1	9	17	5	53840
2817	1	9	17	5	25841
2818	1	9	17	6	83601
2819	1	9	17	4	298344
2820	1	9	17	1	429641
2821	1	12	17	5	44891
2822	1	12	17	6	11496
2823	1	12	17	1	18761
2824	1	13	17	5	28250
2825	1	13	17	6	74980
2826	1	13	17	1	7881
2827	1	14	17	6	69588
2828	1	14	17	5	2124
2829	1	14	17	6	87276
2830	1	14	17	5	10031
2831	1	14	17	4	16602
2832	1	14	17	1	5576
2833	1	15	17	5	7090
2834	1	16	17	6	29681
2835	1	16	17	5	39560
2836	1	16	17	6	73255
2837	1	16	17	5	31486
2838	1	16	17	4	25540
2839	1	16	17	1	51972
2840	1	18	17	5	67310
2841	1	19	17	5	13155
2842	1	21	17	5	64880
2843	1	23	17	5	210251
2844	1	23	17	4	36320
2845	1	23	17	1	125331
2846	1	23	17	4	4534
2847	1	23	17	1	117016
2848	1	24	17	4	84564
2849	1	24	17	1	178860
2850	1	25	17	5	39971
2851	1	25	17	6	92257
2852	1	25	17	5	73619
2853	1	25	17	1	236305
2854	1	25	17	1	5836
2855	1	26	17	5	45188
2856	1	26	17	6	35893
2857	1	26	17	1	49080
2858	1	30	17	5	41189
2859	1	30	17	6	4957
2860	1	30	17	1	59580
2861	1	31	17	1	118348
2862	1	32	17	5	5917
2863	1	32	17	6	89960
2864	1	32	17	5	115904
2865	1	32	17	1	401795
2866	1	32	17	1	67816
2867	1	35	17	5	48739
2868	1	35	17	6	58312
2869	1	35	17	5	60122
2870	1	35	17	1	365748
2871	1	35	17	1	94063
2872	1	36	17	5	5328
2873	1	36	17	6	43783
2874	1	36	17	5	101362
2875	1	36	17	1	483818
2876	1	36	17	1	10017
2877	1	37	17	5	8715
2878	1	37	17	6	55086
2879	1	37	17	1	11690
2880	1	38	17	5	47484
2881	1	38	17	6	20114
2882	1	38	17	1	24484
2883	1	39	17	5	46713
2884	1	39	17	6	37940
2885	1	39	17	1	42174
2886	1	40	17	6	1831
2887	1	40	17	5	8124
2888	1	40	17	6	80250
2889	1	40	17	5	15894
2890	1	40	17	4	27684
2891	1	40	17	1	98189
2892	1	41	17	5	5170
2893	1	41	17	6	62306
2894	1	41	17	5	42791
2895	1	41	17	1	499981
2896	1	41	17	1	77554
2897	1	43	17	5	49147
2898	1	43	17	6	18059
2899	1	43	17	1	77433
2900	1	44	17	5	7540
2901	1	44	17	6	14971
2902	1	44	17	5	67587
2903	1	44	17	1	240249
2904	1	44	17	1	85714
2905	1	45	17	1	176638
2906	1	46	17	5	55426
2907	1	47	17	5	6356
2908	1	48	17	5	40055
2909	1	48	17	6	43390
2910	1	48	17	1	70173
2911	1	49	17	5	34145
2912	1	49	17	6	68401
2913	1	49	17	5	119054
2914	1	49	17	1	319145
2915	1	49	17	1	88007
2916	1	50	17	6	26495
2917	1	50	17	5	45251
2918	1	50	17	6	83859
2919	1	50	17	5	50471
2920	1	50	17	4	29411
2921	1	50	17	1	88358
2922	1	52	17	5	40656
2923	1	52	17	6	9058
2924	1	52	17	5	46391
2925	1	52	17	1	486951
2926	1	52	17	1	84032
2927	1	53	17	4	83668
2928	1	53	17	6	60102
2929	1	53	17	4	81296
2930	1	53	17	6	82177
2931	1	54	17	5	257585
2932	1	54	17	4	87563
2933	1	54	17	1	108654
2934	1	54	17	4	78959
2935	1	54	17	1	123351
2936	1	55	17	4	87148
2937	1	55	17	1	139825
2938	1	56	17	5	234984
2939	1	56	17	4	79842
2940	1	56	17	1	165717
2941	1	56	17	4	41143
2942	1	56	17	1	113644
2943	1	57	17	5	252275
2944	1	57	17	4	2506
2945	1	57	17	1	113415
2946	1	57	17	4	91750
2947	1	57	17	1	128357
2948	1	58	17	4	48399
2949	1	58	17	1	167273
2950	1	60	17	5	270841
2951	1	60	17	4	91600
2952	1	60	17	1	88453
2953	1	60	17	4	58193
2954	1	60	17	1	121490
2955	1	1	18	5	18463
2956	1	1	18	6	40001
2957	1	1	18	5	71504
2958	1	1	18	1	282743
2959	1	1	18	1	26697
2960	1	2	18	5	225530
2961	1	2	18	4	58029
2962	1	2	18	1	91014
2963	1	2	18	4	72631
2964	1	2	18	1	110968
2965	1	3	18	5	251605
2966	1	3	18	4	28220
2967	1	3	18	1	95481
2968	1	3	18	4	74439
2969	1	3	18	1	167892
2970	1	4	18	5	14395
2971	1	4	18	6	17378
2972	1	4	18	1	419831
2973	1	5	18	5	34827
2974	1	5	18	6	39580
2975	1	5	18	1	96113
2976	1	6	18	5	33064
2977	1	6	18	6	75887
2978	1	6	18	5	57703
2979	1	6	18	1	394356
2980	1	6	18	1	53493
2981	1	7	18	5	19648
2982	1	7	18	6	15590
2983	1	7	18	5	48909
2984	1	7	18	1	343815
2985	1	7	18	1	85187
2986	1	8	18	5	24172
2987	1	8	18	6	46644
2988	1	8	18	5	54565
2989	1	8	18	1	233615
2990	1	8	18	1	59312
2991	1	9	18	5	29413
2992	1	9	18	6	19930
2993	1	9	18	1	203876
2994	1	11	18	5	44843
2995	1	11	18	6	91350
2996	1	11	18	1	63908
2997	1	12	18	6	51294
2998	1	12	18	5	49217
2999	1	12	18	6	86977
3000	1	12	18	5	29904
3001	1	12	18	4	78989
3002	1	12	18	1	7972
3003	1	13	18	5	42283
3004	1	13	18	6	55654
3005	1	13	18	5	60486
3006	1	13	18	1	465404
3007	1	13	18	1	7293
3008	1	14	18	5	42671
3009	1	14	18	6	81510
3010	1	14	18	1	77212
3011	1	15	18	5	30346
3012	1	15	18	6	86133
3013	1	15	18	5	84326
3014	1	15	18	1	276490
3015	1	15	18	1	95393
3016	1	16	18	5	8316
3017	1	17	18	5	21494
3018	1	18	18	5	96199
3019	1	19	18	4	121628
3020	1	19	18	6	119971
3021	1	19	18	4	113118
3022	1	19	18	6	66319
3023	1	22	18	5	113063
3024	1	22	18	4	42112
3025	1	22	18	1	71851
3026	1	22	18	4	93550
3027	1	22	18	1	127737
3028	1	23	18	4	85294
3029	1	23	18	6	82468
3030	1	23	18	4	91893
3031	1	23	18	6	75183
3032	1	24	18	5	44427
3033	1	25	18	5	37065
3034	1	25	18	6	98414
3035	1	25	18	1	19872
3036	1	26	18	5	28505
3037	1	26	18	6	81661
3038	1	26	18	1	55253
3039	1	27	18	6	87767
3040	1	27	18	5	34462
3041	1	27	18	5	39674
3042	1	27	18	6	108798
3043	1	27	18	4	115070
3044	1	27	18	1	287841
3045	1	28	18	6	117447
3046	1	28	18	5	11971
3047	1	28	18	5	41818
3048	1	28	18	6	31929
3049	1	28	18	4	242057
3050	1	28	18	1	249324
3051	1	31	18	5	28375
3052	1	31	18	6	27763
3053	1	31	18	5	81272
3054	1	31	18	1	229877
3055	1	31	18	1	63680
3056	1	32	18	5	24371
3057	1	32	18	6	36883
3058	1	32	18	5	108864
3059	1	32	18	1	200523
3060	1	32	18	1	80664
3061	1	35	18	5	7276
3062	1	35	18	6	85377
3063	1	35	18	1	58672
3064	1	36	18	6	11315
3065	1	36	18	5	40721
3066	1	36	18	6	92057
3067	1	36	18	5	4864
3068	1	36	18	4	6764
3069	1	36	18	1	44016
3070	1	37	18	5	35196
3071	1	37	18	6	32684
3072	1	37	18	5	43184
3073	1	37	18	1	424638
3074	1	37	18	1	69389
3075	1	38	18	5	39942
3076	1	38	18	6	25481
3077	1	38	18	1	54438
3078	1	39	18	6	25970
3079	1	39	18	5	41866
3080	1	39	18	6	79725
3081	1	39	18	5	66188
3082	1	39	18	4	77197
3083	1	39	18	1	79829
3084	1	41	18	6	4124
3085	1	41	18	5	22675
3086	1	41	18	6	55445
3087	1	41	18	5	68200
3088	1	41	18	4	13380
3089	1	41	18	1	29368
3090	1	42	18	5	13177
3091	1	42	18	6	48990
3092	1	42	18	5	108413
3093	1	42	18	1	285457
3094	1	42	18	1	66551
3095	1	43	18	6	38534
3096	1	43	18	5	6367
3097	1	43	18	6	15758
3098	1	43	18	5	28790
3099	1	43	18	4	86854
3100	1	43	18	1	5439
3101	1	44	18	6	49711
3102	1	44	18	5	31061
3103	1	44	18	6	26608
3104	1	44	18	5	16034
3105	1	44	18	4	79423
3106	1	44	18	1	75040
3107	1	45	18	5	28604
3108	1	45	18	6	24432
3109	1	45	18	1	51058
3110	1	46	18	5	80134
3111	1	47	18	5	56485
3112	1	48	18	5	44436
3113	1	48	18	6	60014
3114	1	48	18	1	67579
3115	1	52	18	1	342122
3116	1	54	18	5	137470
3117	1	54	18	4	11448
3118	1	54	18	1	121009
3119	1	54	18	4	74264
3120	1	54	18	1	183963
3121	1	55	18	4	4160
3122	1	55	18	1	108938
3123	1	56	18	4	42718
3124	1	56	18	1	70627
3125	1	57	18	5	297694
3126	1	57	18	4	205
3127	1	57	18	1	150557
3128	1	57	18	4	93832
3129	1	57	18	1	113584
3130	1	58	18	5	232017
3131	1	58	18	4	49639
3132	1	58	18	1	79358
3133	1	58	18	4	86190
3134	1	58	18	1	144340
3135	1	1	19	5	42321
3136	1	1	19	6	92470
3137	1	1	19	5	83685
3138	1	1	19	1	240001
3139	1	1	19	1	50442
3140	1	3	19	4	47647
3141	1	3	19	1	130417
3142	1	4	19	5	133030
3143	1	4	19	4	34443
3144	1	4	19	1	192202
3145	1	4	19	4	77042
3146	1	4	19	1	73688
3147	1	5	19	5	16295
3148	1	5	19	6	58377
3149	1	5	19	5	82731
3150	1	5	19	1	387417
3151	1	5	19	1	88330
3152	1	6	19	5	39940
3153	1	6	19	6	62275
3154	1	6	19	5	52168
3155	1	6	19	1	227439
3156	1	6	19	1	70091
3157	1	7	19	5	5196
3158	1	7	19	6	99855
3159	1	7	19	5	74567
3160	1	7	19	1	441336
3161	1	7	19	1	67924
3162	1	8	19	6	29305
3163	1	8	19	5	17578
3164	1	8	19	6	77025
3165	1	8	19	5	4542
3166	1	8	19	4	47581
3167	1	8	19	1	77042
3168	1	9	19	5	29172
3169	1	9	19	6	73929
3170	1	9	19	5	117804
3171	1	9	19	1	436809
3172	1	9	19	1	16968
3173	1	10	19	5	18578
3174	1	10	19	6	61918
3175	1	10	19	5	70764
3176	1	10	19	1	355195
3177	1	10	19	1	94959
3178	1	11	19	6	27699
3179	1	11	19	5	30289
3180	1	11	19	6	2713
3181	1	11	19	5	29441
3182	1	11	19	4	6826
3183	1	11	19	1	31678
3184	1	12	19	6	84025
3185	1	12	19	5	30854
3186	1	12	19	6	42614
3187	1	12	19	5	41751
3188	1	12	19	4	57727
3189	1	12	19	1	92776
3190	1	13	19	5	19959
3191	1	13	19	6	50696
3192	1	13	19	5	88581
3193	1	13	19	1	240739
3194	1	13	19	1	20016
3195	1	14	19	5	43453
3196	1	14	19	6	74640
3197	1	14	19	5	67942
3198	1	14	19	1	356586
3199	1	14	19	1	36971
3200	1	15	19	6	70648
3201	1	15	19	5	16130
3202	1	15	19	6	37498
3203	1	15	19	5	46202
3204	1	15	19	4	33278
3205	1	15	19	1	26291
3206	1	16	19	5	7471
3207	1	16	19	6	85300
3208	1	16	19	5	40458
3209	1	16	19	1	272010
3210	1	16	19	1	12014
3211	1	17	19	5	14902
3212	1	18	19	5	89715
3213	1	19	19	5	10261
3214	1	21	19	4	76756
3215	1	21	19	1	89043
3216	1	22	19	5	156891
3217	1	22	19	4	33512
3218	1	22	19	1	153449
3219	1	22	19	4	78188
3220	1	22	19	1	126889
3221	1	23	19	5	258666
3222	1	23	19	4	83444
3223	1	23	19	1	101102
3224	1	23	19	4	48685
3225	1	23	19	1	173506
3226	1	24	19	5	38466
3227	1	24	19	6	20272
3228	1	24	19	1	92720
3229	1	25	19	5	34407
3230	1	25	19	6	40896
3231	1	25	19	1	36193
3232	1	26	19	5	45310
3233	1	26	19	6	76900
3234	1	26	19	1	76428
3235	1	27	19	5	28380
3236	1	27	19	6	33519
3237	1	27	19	1	97153
3238	1	28	19	6	109367
3239	1	28	19	5	22497
3240	1	28	19	5	49223
3241	1	28	19	6	11014
3242	1	28	19	4	262365
3243	1	28	19	1	392476
3244	1	29	19	6	68142
3245	1	29	19	5	48375
3246	1	29	19	5	40638
3247	1	29	19	6	101347
3248	1	29	19	4	230068
3249	1	29	19	1	384609
3250	1	30	19	5	36228
3251	1	30	19	6	133754
3252	1	30	19	1	561289
3253	1	31	19	5	29850
3254	1	31	19	6	47107
3255	1	31	19	1	20656
3256	1	32	19	5	51265
3257	1	33	19	6	81550
3258	1	33	19	5	2988
3259	1	33	19	6	43751
3260	1	33	19	5	63440
3261	1	33	19	4	36722
3262	1	33	19	1	60690
3263	1	34	19	5	47244
3264	1	34	19	6	15609
3265	1	34	19	5	106556
3266	1	34	19	1	219634
3267	1	34	19	1	66392
3268	1	35	19	5	2835
3269	1	35	19	6	61086
3270	1	35	19	5	49488
3271	1	35	19	1	356829
3272	1	35	19	1	62141
3273	1	36	19	6	34444
3274	1	36	19	5	17986
3275	1	36	19	6	78879
3276	1	36	19	5	22056
3277	1	36	19	4	14307
3278	1	36	19	1	45618
3279	1	37	19	6	7011
3280	1	37	19	5	18245
3281	1	37	19	6	10638
3282	1	37	19	5	28520
3283	1	37	19	4	6410
3284	1	37	19	1	87637
3285	1	39	19	5	42451
3286	1	39	19	6	52660
3287	1	39	19	1	79763
3288	1	41	19	5	28047
3289	1	41	19	6	90713
3290	1	41	19	1	19822
3291	1	42	19	5	37087
3292	1	42	19	6	41407
3293	1	42	19	1	64092
3294	1	43	19	5	21242
3295	1	43	19	6	62280
3296	1	43	19	5	90601
3297	1	43	19	1	293868
3298	1	43	19	1	40792
3299	1	44	19	5	32896
3300	1	44	19	6	6510
3301	1	44	19	5	48413
3302	1	44	19	1	276424
3303	1	44	19	1	19378
3304	1	45	19	5	29497
3305	1	45	19	6	69561
3306	1	45	19	1	84348
3307	1	46	19	5	45838
3308	1	46	19	6	41919
3309	1	46	19	5	47865
3310	1	46	19	1	387813
3311	1	46	19	1	31663
3312	1	48	19	6	47527
3313	1	48	19	5	9277
3314	1	48	19	6	90736
3315	1	48	19	5	20746
3316	1	48	19	4	94350
3317	1	48	19	1	94073
3318	1	49	19	5	32488
3319	1	49	19	6	19139
3320	1	49	19	1	31175
3321	1	51	19	1	133856
3322	1	52	19	5	33085
3323	1	52	19	6	20588
3324	1	52	19	1	530182
3325	1	53	19	6	111738
3326	1	53	19	5	39840
3327	1	53	19	5	21796
3328	1	53	19	6	25303
3329	1	53	19	4	263395
3330	1	53	19	1	433056
3331	1	54	19	5	130975
3332	1	54	19	4	24098
3333	1	54	19	1	82984
3334	1	54	19	4	56495
3335	1	54	19	1	150942
3336	1	55	19	5	137230
3337	1	55	19	4	44939
3338	1	55	19	1	147885
3339	1	55	19	4	95660
3340	1	55	19	1	198607
3341	1	56	19	5	128934
3342	1	56	19	4	72059
3343	1	56	19	1	126107
3344	1	56	19	4	4928
3345	1	56	19	1	86456
3346	1	57	19	5	185289
3347	1	57	19	4	23661
3348	1	57	19	1	118282
3349	1	57	19	4	21083
3350	1	57	19	1	113854
3351	1	58	19	5	265132
3352	1	58	19	4	43719
3353	1	58	19	1	129646
3354	1	58	19	4	59159
3355	1	58	19	1	155571
3356	1	1	20	5	37904
3357	1	1	20	6	77716
3358	1	1	20	1	77464
3359	1	2	20	5	15800
3360	1	2	20	6	73909
3361	1	2	20	5	62121
3362	1	2	20	1	477178
3363	1	2	20	1	66202
3364	1	3	20	5	257589
3365	1	3	20	4	33680
3366	1	3	20	1	98256
3367	1	3	20	4	6323
3368	1	3	20	1	156851
3369	1	4	20	1	121051
3370	1	5	20	5	37383
3371	1	5	20	6	81386
3372	1	5	20	5	88859
3373	1	5	20	1	373306
3374	1	5	20	1	57221
3375	1	7	20	6	64150
3376	1	7	20	5	36662
3377	1	7	20	6	61396
3378	1	7	20	5	40589
3379	1	7	20	4	83457
3380	1	7	20	1	37147
3381	1	8	20	5	43812
3382	1	8	20	6	21029
3383	1	8	20	5	98282
3384	1	8	20	1	321864
3385	1	8	20	1	7934
3386	1	9	20	5	45621
3387	1	9	20	6	39901
3388	1	9	20	5	74547
3389	1	9	20	1	408076
3390	1	9	20	1	97059
3391	1	10	20	5	48272
3392	1	10	20	6	38677
3393	1	10	20	1	85921
3394	1	11	20	5	17122
3395	1	12	20	1	201274
3396	1	13	20	6	26525
3397	1	13	20	5	48185
3398	1	13	20	6	34121
3399	1	13	20	5	41561
3400	1	13	20	4	71576
3401	1	13	20	1	87251
3402	1	14	20	4	57646
3403	1	14	20	1	157019
3404	1	15	20	5	35634
3405	1	15	20	6	58406
3406	1	15	20	1	3707
3407	1	16	20	5	17055
3408	1	16	20	6	32304
3409	1	16	20	5	51045
3410	1	16	20	1	453874
3411	1	16	20	1	67918
3412	1	17	20	5	47786
3413	1	17	20	6	84782
3414	1	17	20	5	115505
3415	1	17	20	1	378415
3416	1	17	20	1	3076
3417	1	18	20	5	97761
3418	1	19	20	5	47380
3419	1	22	20	4	97458
3420	1	22	20	1	188400
3421	1	23	20	4	7003
3422	1	23	20	1	145248
3423	1	24	20	5	35615
3424	1	24	20	6	27602
3425	1	24	20	1	59933
3426	1	25	20	5	43185
3427	1	25	20	6	4163
3428	1	25	20	5	42432
3429	1	25	20	1	225677
3430	1	25	20	1	51530
3431	1	26	20	5	48477
3432	1	26	20	6	51454
3433	1	26	20	1	60039
3434	1	27	20	5	41350
3435	1	27	20	6	23442
3436	1	27	20	5	94507
3437	1	27	20	1	269250
3438	1	27	20	1	31183
3439	1	28	20	6	53743
3440	1	28	20	5	24954
3441	1	28	20	6	10749
3442	1	28	20	5	56292
3443	1	28	20	4	45064
3444	1	28	20	1	75830
3445	1	34	20	6	48674
3446	1	34	20	5	27664
3447	1	34	20	6	93008
3448	1	34	20	5	45362
3449	1	34	20	4	82469
3450	1	34	20	1	4239
3451	1	35	20	5	25316
3452	1	35	20	6	40607
3453	1	35	20	1	50218
3454	1	36	20	1	399980
3455	1	37	20	5	17767
3456	1	37	20	6	73941
3457	1	37	20	1	90208
3458	1	38	20	6	26856
3459	1	38	20	5	4942
3460	1	38	20	6	8334
3461	1	38	20	5	8796
3462	1	38	20	4	49829
3463	1	38	20	1	3400
3464	1	39	20	5	28272
3465	1	39	20	6	54809
3466	1	39	20	1	59003
3467	1	41	20	5	24788
3468	1	41	20	6	41204
3469	1	41	20	1	55375
3470	1	42	20	1	357925
3471	1	43	20	5	23443
3472	1	43	20	6	68130
3473	1	43	20	1	45571
3474	1	44	20	6	91462
3475	1	44	20	5	44067
3476	1	44	20	6	87330
3477	1	44	20	5	21084
3478	1	44	20	4	71118
3479	1	44	20	1	30004
3480	1	45	20	5	7774
3481	1	45	20	6	77814
3482	1	45	20	5	115726
3483	1	45	20	1	498427
3484	1	45	20	1	52121
3485	1	46	20	5	48584
3486	1	46	20	6	51186
3487	1	46	20	1	40980
3488	1	47	20	5	3659
3489	1	47	20	6	66870
3490	1	47	20	1	3547
3491	1	48	20	5	26365
3492	1	48	20	6	77598
3493	1	48	20	1	39552
3494	1	49	20	6	55992
3495	1	49	20	5	28738
3496	1	49	20	6	1012
3497	1	49	20	5	60788
3498	1	49	20	4	12259
3499	1	49	20	1	94252
3500	1	52	20	6	76283
3501	1	52	20	5	56894
3502	1	52	20	5	30611
3503	1	52	20	6	125287
3504	1	52	20	4	223555
3505	1	52	20	1	94330
3506	1	53	20	5	279340
3507	1	53	20	4	67751
3508	1	53	20	1	170805
3509	1	53	20	4	78327
3510	1	53	20	1	126692
3511	1	55	20	5	282593
3512	1	55	20	4	55244
3513	1	55	20	1	73957
3514	1	55	20	4	87393
3515	1	55	20	1	142579
3516	1	56	20	1	227739
3517	1	57	20	5	270472
3518	1	57	20	4	1977
3519	1	57	20	1	75940
3520	1	57	20	4	22359
3521	1	57	20	1	163696
3522	1	60	20	1	114468
3523	1	1	21	6	46442
3524	1	1	21	5	14668
3525	1	1	21	6	81416
3526	1	1	21	5	17750
3527	1	1	21	4	51596
3528	1	1	21	1	85556
3529	1	2	21	5	23247
3530	1	2	21	6	16196
3531	1	2	21	5	105193
3532	1	2	21	1	430011
3533	1	2	21	1	41881
3534	1	3	21	6	11606
3535	1	3	21	5	16925
3536	1	3	21	6	41027
3537	1	3	21	5	20875
3538	1	3	21	4	10542
3539	1	3	21	1	68806
3540	1	4	21	6	54939
3541	1	4	21	5	38207
3542	1	4	21	6	76920
3543	1	4	21	5	43671
3544	1	4	21	4	93319
3545	1	4	21	1	46205
3546	1	7	21	5	36716
3547	1	7	21	6	40669
3548	1	7	21	5	95464
3549	1	7	21	1	430703
3550	1	7	21	1	67467
3551	1	8	21	6	99306
3552	1	8	21	5	1775
3553	1	8	21	6	19947
3554	1	8	21	5	14018
3555	1	8	21	4	3738
3556	1	8	21	1	86625
3557	1	9	21	6	14038
3558	1	9	21	5	14722
3559	1	9	21	6	38177
3560	1	9	21	5	69980
3561	1	9	21	4	51051
3562	1	9	21	1	13107
3563	1	10	21	5	28945
3564	1	10	21	6	6215
3565	1	10	21	5	76242
3566	1	10	21	1	321070
3567	1	10	21	1	9869
3568	1	11	21	5	1760
3569	1	11	21	6	63390
3570	1	11	21	5	78529
3571	1	11	21	1	264464
3572	1	11	21	1	52008
3573	1	12	21	5	12838
3574	1	12	21	6	38180
3575	1	12	21	5	49202
3576	1	12	21	1	321510
3577	1	12	21	1	76400
3578	1	13	21	6	3136
3579	1	13	21	5	30772
3580	1	13	21	6	81312
3581	1	13	21	5	23001
3582	1	13	21	4	6588
3583	1	13	21	1	72270
3584	1	14	21	5	44594
3585	1	14	21	6	52894
3586	1	14	21	1	19697
3587	1	16	21	5	24049
3588	1	16	21	6	31238
3589	1	16	21	1	97522
3590	1	17	21	5	48454
3591	1	18	21	5	48268
3592	1	19	21	5	83488
3593	1	21	21	5	182285
3594	1	21	21	4	9401
3595	1	21	21	1	107452
3596	1	21	21	4	91472
3597	1	21	21	1	178969
3598	1	22	21	4	12822
3599	1	22	21	1	114767
3600	1	23	21	5	294434
3601	1	23	21	4	58580
3602	1	23	21	1	181762
3603	1	23	21	4	9803
3604	1	23	21	1	107805
3605	1	24	21	5	35906
3606	1	24	21	6	36696
3607	1	24	21	5	114304
3608	1	24	21	1	461171
3609	1	24	21	1	53480
3610	1	27	21	5	7909
3611	1	27	21	6	74202
3612	1	27	21	5	61665
3613	1	27	21	1	233557
3614	1	27	21	1	86684
3615	1	28	21	6	72822
3616	1	28	21	5	1761
3617	1	28	21	6	3478
3618	1	28	21	5	22538
3619	1	28	21	4	97875
3620	1	28	21	1	47797
3621	1	29	21	5	13032
3622	1	29	21	6	54584
3623	1	29	21	1	24450
3624	1	30	21	5	4036
3625	1	30	21	6	26676
3626	1	30	21	1	89475
3627	1	32	21	5	262457
3628	1	32	21	4	89763
3629	1	32	21	1	77555
3630	1	32	21	4	63999
3631	1	32	21	1	116971
3632	1	33	21	5	12573
3633	1	33	21	6	24140
3634	1	33	21	1	36002
3635	1	34	21	6	51683
3636	1	34	21	5	14038
3637	1	34	21	6	4021
3638	1	34	21	5	29314
3639	1	34	21	4	71854
3640	1	34	21	1	49864
3641	1	35	21	1	215590
3642	1	36	21	5	5686
3643	1	36	21	6	93529
3644	1	36	21	1	86367
3645	1	37	21	5	21296
3646	1	37	21	6	48574
3647	1	37	21	5	49659
3648	1	37	21	1	280879
3649	1	37	21	1	87917
3650	1	38	21	6	94240
3651	1	38	21	5	11787
3652	1	38	21	6	43452
3653	1	38	21	5	1179
3654	1	38	21	4	82562
3655	1	38	21	1	2127
3656	1	39	21	5	20588
3657	1	39	21	6	32904
3658	1	39	21	5	103561
3659	1	39	21	1	365143
3660	1	39	21	1	84810
3661	1	42	21	5	20461
3662	1	42	21	6	39856
3663	1	42	21	5	57342
3664	1	42	21	1	334509
3665	1	42	21	1	40294
3666	1	43	21	6	93497
3667	1	43	21	5	35932
3668	1	43	21	6	49017
3669	1	43	21	5	65942
3670	1	43	21	4	58879
3671	1	43	21	1	78898
3672	1	45	21	5	17953
3673	1	45	21	6	30796
3674	1	45	21	5	47346
3675	1	45	21	1	209048
3676	1	45	21	1	12990
3677	1	49	21	5	8142
3678	1	49	21	6	46155
3679	1	49	21	1	44174
3680	1	51	21	5	41806
3681	1	51	21	6	61126
3682	1	51	21	1	322088
3683	1	52	21	6	107457
3684	1	52	21	5	46796
3685	1	52	21	5	36114
3686	1	52	21	6	138528
3687	1	52	21	4	287449
3688	1	52	21	1	201478
3689	1	53	21	5	33265
3690	1	53	21	6	142658
3691	1	53	21	1	174524
3692	1	55	21	4	62472
3693	1	55	21	1	199024
3694	1	56	21	4	19114
3695	1	56	21	1	192547
3696	1	57	21	6	143820
3697	1	57	21	5	66501
3698	1	57	21	5	44614
3699	1	57	21	6	61136
3700	1	57	21	4	267538
3701	1	57	21	1	593846
3702	1	58	21	6	57703
3703	1	58	21	5	12749
3704	1	58	21	5	49195
3705	1	58	21	6	56958
3706	1	58	21	4	275426
3707	1	58	21	1	93554
3708	1	59	21	5	3247
3709	1	59	21	6	40806
3710	1	59	21	1	318870
3711	1	60	21	6	105497
3712	1	60	21	5	9663
3713	1	60	21	5	19273
3714	1	60	21	6	125431
3715	1	60	21	4	252705
3716	1	60	21	1	501100
3717	1	1	22	5	25502
3718	1	1	22	6	98136
3719	1	1	22	1	66962
3720	1	2	22	5	16563
3721	1	2	22	6	45033
3722	1	2	22	5	112890
3723	1	2	22	1	203808
3724	1	2	22	1	50486
3725	1	3	22	5	9219
3726	1	3	22	6	4940
3727	1	3	22	1	85141
3728	1	4	22	6	13850
3729	1	4	22	5	17897
3730	1	4	22	6	93219
3731	1	4	22	5	30939
3732	1	4	22	4	77546
3733	1	4	22	1	83575
3734	1	5	22	6	96705
3735	1	5	22	5	6145
3736	1	5	22	6	51883
3737	1	5	22	5	31678
3738	1	5	22	4	65626
3739	1	5	22	1	50806
3740	1	6	22	6	93848
3741	1	6	22	5	29357
3742	1	6	22	6	16377
3743	1	6	22	5	63662
3744	1	6	22	4	61454
3745	1	6	22	1	55770
3746	1	7	22	5	32813
3747	1	7	22	6	56297
3748	1	7	22	5	105198
3749	1	7	22	1	287373
3750	1	7	22	1	76494
3751	1	8	22	1	122835
3752	1	9	22	5	21186
3753	1	9	22	6	64367
3754	1	9	22	5	77348
3755	1	9	22	1	423908
3756	1	9	22	1	74348
3757	1	10	22	5	7362
3758	1	11	22	6	47992
3759	1	11	22	5	41024
3760	1	11	22	6	52347
3761	1	11	22	5	63914
3762	1	11	22	4	3183
3763	1	11	22	1	77323
3764	1	12	22	5	17945
3765	1	12	22	6	12441
3766	1	12	22	5	52961
3767	1	12	22	1	319925
3768	1	12	22	1	87374
3769	1	13	22	6	32007
3770	1	13	22	5	3207
3771	1	13	22	6	40780
3772	1	13	22	5	37729
3773	1	13	22	4	59939
3774	1	13	22	1	96081
3775	1	17	22	1	91914
3776	1	18	22	5	10833
3777	1	19	22	5	67378
3778	1	20	22	5	54264
3779	1	21	22	5	257203
3780	1	21	22	4	37404
3781	1	21	22	1	131970
3782	1	21	22	4	35254
3783	1	21	22	1	129664
3784	1	22	22	6	147637
3785	1	22	22	5	25021
3786	1	22	22	5	24703
3787	1	22	22	6	141358
3788	1	22	22	4	262300
3789	1	22	22	1	563170
3790	1	23	22	4	38134
3791	1	23	22	1	160699
3792	1	24	22	5	170191
3793	1	24	22	4	87949
3794	1	24	22	1	154810
3795	1	24	22	4	271
3796	1	24	22	1	137915
3797	1	25	22	5	24435
3798	1	25	22	6	85593
3799	1	25	22	1	1822
3800	1	28	22	6	80669
3801	1	28	22	5	41863
3802	1	28	22	5	1644
3803	1	28	22	6	53788
3804	1	28	22	4	219936
3805	1	28	22	1	457609
3806	1	29	22	5	10356
3807	1	29	22	6	64202
3808	1	29	22	5	88949
3809	1	29	22	1	475518
3810	1	29	22	1	44636
3811	1	30	22	6	22224
3812	1	30	22	5	44231
3813	1	30	22	6	21259
3814	1	30	22	5	62486
3815	1	30	22	4	47262
3816	1	30	22	1	84667
3817	1	31	22	5	19016
3818	1	31	22	6	4745
3819	1	31	22	5	83912
3820	1	31	22	1	314969
3821	1	31	22	1	95828
3822	1	32	22	5	42841
3823	1	32	22	6	93322
3824	1	32	22	1	16063
3825	1	33	22	5	28164
3826	1	33	22	6	91516
3827	1	33	22	5	92680
3828	1	33	22	1	393121
3829	1	33	22	1	72853
3830	1	34	22	1	373932
3831	1	36	22	6	97234
3832	1	36	22	5	45556
3833	1	36	22	6	35800
3834	1	36	22	5	37677
3835	1	36	22	4	51153
3836	1	36	22	1	88901
3837	1	37	22	4	58799
3838	1	37	22	6	111335
3839	1	37	22	4	139810
3840	1	37	22	6	88442
3841	1	38	22	5	61456
3842	1	39	22	5	4065
3843	1	39	22	6	89021
3844	1	39	22	5	75202
3845	1	39	22	1	263202
3846	1	39	22	1	84859
3847	1	40	22	1	282495
3848	1	41	22	5	10987
3849	1	41	22	6	39288
3850	1	41	22	5	62115
3851	1	41	22	1	203576
3852	1	41	22	1	10794
3853	1	42	22	5	12010
3854	1	42	22	6	12426
3855	1	42	22	5	115432
3856	1	42	22	1	458941
3857	1	42	22	1	41263
3858	1	43	22	5	10187
3859	1	43	22	6	95538
3860	1	43	22	5	58423
3861	1	43	22	1	250167
3862	1	43	22	1	40916
3863	1	44	22	5	25743
3864	1	44	22	6	67161
3865	1	44	22	5	91430
3866	1	44	22	1	305756
3867	1	44	22	1	98274
3868	1	45	22	5	33427
3869	1	45	22	6	66096
3870	1	45	22	5	110695
3871	1	45	22	1	410356
3872	1	45	22	1	18152
3873	1	47	22	6	65078
3874	1	47	22	5	55387
3875	1	47	22	5	48030
3876	1	47	22	6	8067
3877	1	47	22	4	104729
3878	1	47	22	1	136813
3879	1	50	22	6	97214
3880	1	50	22	5	42541
3881	1	50	22	6	34304
3882	1	50	22	5	42217
3883	1	50	22	4	12575
3884	1	50	22	1	10680
3885	1	51	22	5	248256
3886	1	51	22	4	63155
3887	1	51	22	1	130290
3888	1	51	22	4	20560
3889	1	51	22	1	101186
3890	1	52	22	5	50600
3891	1	53	22	6	51406
3892	1	53	22	5	13348
3893	1	53	22	5	44365
3894	1	53	22	6	60705
3895	1	53	22	4	219602
3896	1	53	22	1	267299
3897	1	56	22	4	14178
3898	1	56	22	1	175409
3899	1	57	22	6	142772
3900	1	57	22	5	17625
3901	1	57	22	5	5974
3902	1	57	22	6	64880
3903	1	57	22	4	291465
3904	1	57	22	1	232026
3905	1	58	22	5	268462
3906	1	58	22	4	80446
3907	1	58	22	1	144832
3908	1	58	22	4	73067
3909	1	58	22	1	113456
3910	1	59	22	5	1263
3911	1	59	22	6	63088
3912	1	59	22	1	198917
3913	1	60	22	6	107074
3914	1	60	22	5	47469
3915	1	60	22	5	20777
3916	1	60	22	6	51572
3917	1	60	22	4	110888
3918	1	60	22	1	256501
3919	1	1	23	5	18994
3920	1	1	23	6	76659
3921	1	1	23	5	98977
3922	1	1	23	1	469786
3923	1	1	23	1	99142
3924	1	3	23	5	46585
3925	1	3	23	6	43153
3926	1	3	23	5	112218
3927	1	3	23	1	287287
3928	1	3	23	1	31761
3929	1	4	23	5	28234
3930	1	4	23	6	38994
3931	1	4	23	1	90799
3932	1	5	23	6	62230
3933	1	5	23	5	45421
3934	1	5	23	6	4686
3935	1	5	23	5	64392
3936	1	5	23	4	54540
3937	1	5	23	1	25383
3938	1	6	23	6	7680
3939	1	6	23	5	41757
3940	1	6	23	6	96143
3941	1	6	23	5	57884
3942	1	6	23	4	59935
3943	1	6	23	1	75104
3944	1	7	23	5	41957
3945	1	7	23	6	68413
3946	1	7	23	5	90097
3947	1	7	23	1	382756
3948	1	7	23	1	61499
3949	1	8	23	4	81910
3950	1	8	23	6	50425
3951	1	9	23	5	18095
3952	1	9	23	6	8930
3953	1	9	23	1	20493
3954	1	10	23	6	61868
3955	1	10	23	5	12784
3956	1	10	23	6	52611
3957	1	10	23	5	25020
3958	1	10	23	4	60014
3959	1	10	23	1	46315
3960	1	11	23	5	33520
3961	1	11	23	6	73863
3962	1	11	23	5	109761
3963	1	11	23	1	215229
3964	1	11	23	1	31457
3965	1	12	23	5	2421
3966	1	12	23	6	38899
3967	1	12	23	1	63834
3968	1	13	23	5	11624
3969	1	13	23	6	26597
3970	1	13	23	5	45155
3971	1	13	23	1	223497
3972	1	13	23	1	42900
3973	1	14	23	6	42275
3974	1	14	23	5	46663
3975	1	14	23	6	84532
3976	1	14	23	5	55659
3977	1	14	23	4	92541
3978	1	14	23	1	27590
3979	1	16	23	1	326232
3980	1	17	23	1	334647
3981	1	18	23	5	85475
3982	1	19	23	5	40519
3983	1	19	23	6	28586
3984	1	19	23	1	41550
3985	1	20	23	5	19968
3986	1	21	23	5	6777
3987	1	22	23	5	100351
3988	1	22	23	4	10196
3989	1	22	23	1	97325
3990	1	22	23	4	88535
3991	1	22	23	1	140187
3992	1	23	23	5	114744
3993	1	23	23	4	69467
3994	1	23	23	1	75782
3995	1	23	23	4	52672
3996	1	23	23	1	158188
3997	1	24	23	5	212274
3998	1	24	23	4	26866
3999	1	24	23	1	111938
4000	1	24	23	4	50794
4001	1	24	23	1	101400
4002	1	25	23	5	126355
4003	1	25	23	4	65415
4004	1	25	23	1	85930
4005	1	25	23	4	58057
4006	1	25	23	1	121769
4007	1	26	23	5	40300
4008	1	26	23	6	94666
4009	1	26	23	5	119847
4010	1	26	23	1	317964
4011	1	26	23	1	71909
4012	1	30	23	4	99111
4013	1	30	23	6	147126
4014	1	30	23	4	102623
4015	1	30	23	6	83594
4016	1	31	23	5	33138
4017	1	31	23	6	24406
4018	1	31	23	5	65318
4019	1	31	23	1	491224
4020	1	31	23	1	9476
4021	1	34	23	6	60203
4022	1	34	23	5	11517
4023	1	34	23	6	7394
4024	1	34	23	5	4461
4025	1	34	23	4	94063
4026	1	34	23	1	40749
4027	1	35	23	5	48509
4028	1	35	23	6	34718
4029	1	35	23	1	56146
4030	1	36	23	6	54263
4031	1	36	23	5	49401
4032	1	36	23	6	60844
4033	1	36	23	5	6021
4034	1	36	23	4	23914
4035	1	36	23	1	80363
4036	1	37	23	5	33054
4037	1	37	23	6	28412
4038	1	37	23	1	34162
4039	1	38	23	5	42223
4040	1	38	23	6	34218
4041	1	38	23	5	43695
4042	1	38	23	1	290772
4043	1	38	23	1	33122
4044	1	39	23	6	68016
4045	1	39	23	5	40886
4046	1	39	23	6	24363
4047	1	39	23	5	7697
4048	1	39	23	4	55673
4049	1	39	23	1	47727
4050	1	40	23	5	13774
4051	1	40	23	6	52996
4052	1	40	23	5	114029
4053	1	40	23	1	472936
4054	1	40	23	1	57634
4055	1	41	23	5	46950
4056	1	42	23	6	10126
4057	1	42	23	5	21093
4058	1	42	23	6	45101
4059	1	42	23	5	50286
4060	1	42	23	4	73529
4061	1	42	23	1	78391
4062	1	43	23	5	15080
4063	1	43	23	6	73198
4064	1	43	23	5	111472
4065	1	43	23	1	387864
4066	1	43	23	1	94429
4067	1	44	23	5	16880
4068	1	44	23	6	25611
4069	1	44	23	5	49285
4070	1	44	23	1	214059
4071	1	44	23	1	26302
4072	1	45	23	5	21565
4073	1	45	23	6	55475
4074	1	45	23	5	103083
4075	1	45	23	1	453831
4076	1	45	23	1	27732
4077	1	47	23	5	34457
4078	1	47	23	6	69992
4079	1	47	23	1	422772
4080	1	49	23	6	52934
4081	1	49	23	5	39516
4082	1	49	23	6	2665
4083	1	49	23	5	22436
4084	1	49	23	4	9073
4085	1	49	23	1	94379
4086	1	50	23	5	43821
4087	1	50	23	6	66368
4088	1	50	23	5	40003
4089	1	50	23	1	331929
4090	1	50	23	1	84066
4091	1	51	23	5	37822
4092	1	51	23	6	52754
4093	1	51	23	1	5170
4094	1	52	23	5	18530
4095	1	52	23	6	9889
4096	1	52	23	5	50335
4097	1	52	23	1	220796
4098	1	52	23	1	6931
4099	1	53	23	6	13368
4100	1	53	23	5	33574
4101	1	53	23	6	43796
4102	1	53	23	5	4771
4103	1	53	23	4	59002
4104	1	53	23	1	85921
4105	1	54	23	6	32765
4106	1	54	23	5	16212
4107	1	54	23	6	5099
4108	1	54	23	5	37974
4109	1	54	23	4	87671
4110	1	54	23	1	78968
4111	1	58	23	5	37882
4112	1	58	23	6	119484
4113	1	58	23	1	138408
4114	1	59	23	6	63579
4115	1	59	23	5	1081
4116	1	59	23	5	29085
4117	1	59	23	6	12301
4118	1	59	23	4	234847
4119	1	59	23	1	581174
4120	1	60	23	6	109473
4121	1	60	23	5	23021
4122	1	60	23	5	46680
4123	1	60	23	6	47501
4124	1	60	23	4	241190
4125	1	60	23	1	583015
4126	1	1	24	1	304897
4127	1	2	24	5	12962
4128	1	2	24	6	19994
4129	1	2	24	5	81439
4130	1	2	24	1	436434
4131	1	2	24	1	28939
4132	1	3	24	6	89017
4133	1	3	24	5	44501
4134	1	3	24	6	54416
4135	1	3	24	5	3326
4136	1	3	24	4	93832
4137	1	3	24	1	77831
4138	1	4	24	5	6692
4139	1	4	24	6	71943
4140	1	4	24	5	69516
4141	1	4	24	1	214063
4142	1	4	24	1	25901
4143	1	5	24	5	16955
4144	1	5	24	6	45042
4145	1	5	24	5	107178
4146	1	5	24	1	222370
4147	1	5	24	1	74178
4148	1	6	24	5	10167
4149	1	6	24	6	4307
4150	1	6	24	1	34647
4151	1	7	24	6	70271
4152	1	7	24	5	14256
4153	1	7	24	6	59277
4154	1	7	24	5	28942
4155	1	7	24	4	95945
4156	1	7	24	1	27309
4157	1	8	24	5	10475
4158	1	8	24	6	96064
4159	1	8	24	1	91830
4160	1	9	24	6	2381
4161	1	9	24	5	40483
4162	1	9	24	6	11019
4163	1	9	24	5	64234
4164	1	9	24	4	86900
4165	1	9	24	1	54493
4166	1	10	24	5	31063
4167	1	10	24	6	38500
4168	1	10	24	5	84892
4169	1	10	24	1	459031
4170	1	10	24	1	67654
4171	1	11	24	5	24966
4172	1	11	24	6	91422
4173	1	11	24	5	43825
4174	1	11	24	1	381707
4175	1	11	24	1	35954
4176	1	12	24	5	28891
4177	1	12	24	6	68261
4178	1	12	24	1	69707
4179	1	14	24	5	11956
4180	1	14	24	6	65262
4181	1	14	24	5	66393
4182	1	14	24	1	345153
4183	1	14	24	1	19946
4184	1	16	24	1	224571
4185	1	18	24	6	5282
4186	1	18	24	5	13429
4187	1	18	24	6	21221
4188	1	18	24	5	20214
4189	1	18	24	4	97227
4190	1	18	24	1	26606
4191	1	19	24	5	27207
4192	1	19	24	6	10506
4193	1	19	24	5	71589
4194	1	19	24	1	499167
4195	1	19	24	1	80715
4196	1	21	24	5	3610
4197	1	22	24	5	143373
4198	1	22	24	4	2902
4199	1	22	24	1	83901
4200	1	22	24	4	36613
4201	1	22	24	1	113063
4202	1	24	24	4	4658
4203	1	24	24	1	119468
4204	1	25	24	4	36441
4205	1	25	24	1	121983
4206	1	26	24	6	77670
4207	1	26	24	5	39398
4208	1	26	24	5	41256
4209	1	26	24	6	114978
4210	1	26	24	4	147508
4211	1	26	24	1	270103
4212	1	27	24	5	49387
4213	1	27	24	6	33222
4214	1	27	24	5	75643
4215	1	27	24	1	481483
4216	1	27	24	1	65036
4217	1	30	24	1	300812
4218	1	31	24	6	5643
4219	1	31	24	5	13986
4220	1	31	24	6	83002
4221	1	31	24	5	22873
4222	1	31	24	4	85505
4223	1	31	24	1	49795
4224	1	33	24	5	23764
4225	1	33	24	6	87130
4226	1	33	24	1	49756
4227	1	34	24	5	206751
4228	1	34	24	4	47483
4229	1	34	24	1	138334
4230	1	34	24	4	71964
4231	1	34	24	1	182175
4232	1	35	24	5	45209
4233	1	35	24	6	43006
4234	1	35	24	1	66950
4235	1	36	24	5	49715
4236	1	36	24	6	68140
4237	1	36	24	1	43028
4238	1	37	24	4	96903
4239	1	37	24	6	109139
4240	1	37	24	4	110432
4241	1	37	24	6	140863
4242	1	38	24	5	46249
4243	1	38	24	6	59420
4244	1	38	24	5	57137
4245	1	38	24	1	441266
4246	1	38	24	1	98849
4247	1	39	24	5	5455
4248	1	39	24	6	95859
4249	1	39	24	1	10624
4250	1	40	24	4	101821
4251	1	40	24	6	110534
4252	1	41	24	5	7131
4253	1	41	24	6	77367
4254	1	41	24	1	27670
4255	1	42	24	5	21313
4256	1	42	24	6	53011
4257	1	42	24	1	1439
4258	1	43	24	5	1306
4259	1	43	24	6	88186
4260	1	43	24	1	52201
4261	1	44	24	5	45208
4262	1	44	24	6	93700
4263	1	44	24	1	20311
4264	1	45	24	4	75557
4265	1	45	24	6	146333
4266	1	47	24	6	145177
4267	1	47	24	5	31112
4268	1	47	24	5	8177
4269	1	47	24	6	31202
4270	1	47	24	4	123564
4271	1	47	24	1	239534
4272	1	48	24	5	42101
4273	1	48	24	6	60049
4274	1	48	24	1	528342
4275	1	49	24	5	32080
4276	1	49	24	6	82540
4277	1	49	24	1	22453
4278	1	50	24	5	5160
4279	1	50	24	6	63826
4280	1	50	24	5	118667
4281	1	50	24	1	304251
4282	1	50	24	1	71894
4283	1	51	24	6	15047
4284	1	51	24	5	16413
4285	1	51	24	6	19212
4286	1	51	24	5	26356
4287	1	51	24	4	21424
4288	1	51	24	1	50819
4289	1	53	24	1	129153
4290	1	54	24	6	89696
4291	1	54	24	5	13154
4292	1	54	24	6	67369
4293	1	54	24	5	26156
4294	1	54	24	4	24479
4295	1	54	24	1	83290
4296	1	56	24	4	122878
4297	1	56	24	6	140914
4298	1	56	24	4	148129
4299	1	56	24	6	89745
4300	1	57	24	6	126638
4301	1	57	24	5	5950
4302	1	57	24	5	2846
4303	1	57	24	6	96434
4304	1	57	24	4	179368
4305	1	57	24	1	464356
4306	1	58	24	5	20567
4307	1	58	24	6	133428
4308	1	58	24	1	236702
4309	1	59	24	5	7107
4310	1	59	24	6	52988
4311	1	59	24	1	392966
4312	1	1	25	5	1126
4313	1	1	25	6	28620
4314	1	1	25	1	61140
4315	1	2	25	5	31559
4316	1	2	25	6	61563
4317	1	2	25	5	47787
4318	1	2	25	1	256727
4319	1	2	25	1	58527
4320	1	3	25	6	58764
4321	1	3	25	5	21770
4322	1	3	25	6	8687
4323	1	3	25	5	59442
4324	1	3	25	4	96486
4325	1	3	25	1	12309
4326	1	4	25	4	66159
4327	1	4	25	6	53656
4328	1	4	25	4	77958
4329	1	4	25	6	74826
4330	1	5	25	6	27355
4331	1	5	25	5	49781
4332	1	5	25	6	31375
4333	1	5	25	5	33664
4334	1	5	25	4	66759
4335	1	5	25	1	54925
4336	1	6	25	5	39458
4337	1	6	25	6	39287
4338	1	6	25	1	27855
4339	1	7	25	6	91100
4340	1	7	25	5	11572
4341	1	7	25	6	74612
4342	1	7	25	5	21305
4343	1	7	25	4	92436
4344	1	7	25	1	38382
4345	1	8	25	5	45049
4346	1	8	25	6	60935
4347	1	8	25	5	57157
4348	1	8	25	1	339874
4349	1	8	25	1	96347
4350	1	10	25	5	40031
4351	1	10	25	6	50046
4352	1	10	25	1	75465
4353	1	11	25	6	86720
4354	1	11	25	5	10047
4355	1	11	25	6	65075
4356	1	11	25	5	56970
4357	1	11	25	4	10062
4358	1	11	25	1	53599
4359	1	12	25	5	9559
4360	1	12	25	6	62031
4361	1	12	25	1	2282
4362	1	15	25	5	7923
4363	1	15	25	6	77145
4364	1	15	25	5	107747
4365	1	15	25	1	237508
4366	1	15	25	1	95605
4367	1	16	25	5	35368
4368	1	17	25	5	262823
4369	1	17	25	4	50410
4370	1	17	25	1	149306
4371	1	17	25	4	62086
4372	1	17	25	1	195150
4373	1	18	25	6	34145
4374	1	18	25	5	11656
4375	1	18	25	6	55491
4376	1	18	25	5	7040
4377	1	18	25	4	46617
4378	1	18	25	1	80049
4379	1	19	25	5	40498
4380	1	19	25	6	22546
4381	1	19	25	1	40635
4382	1	21	25	4	62896
4383	1	21	25	1	105431
4384	1	22	25	4	49563
4385	1	22	25	1	189020
4386	1	25	25	4	1431
4387	1	25	25	1	137344
4388	1	26	25	5	169912
4389	1	26	25	4	7604
4390	1	26	25	1	197398
4391	1	26	25	4	74683
4392	1	26	25	1	173201
4393	1	27	25	6	15689
4394	1	27	25	5	8167
4395	1	27	25	6	22197
4396	1	27	25	5	43808
4397	1	27	25	4	70826
4398	1	27	25	1	92652
4399	1	29	25	1	96554
4400	1	30	25	1	363261
4401	1	32	25	5	39160
4402	1	32	25	6	104244
4403	1	32	25	1	339140
4404	1	33	25	5	44504
4405	1	33	25	6	88128
4406	1	33	25	5	73355
4407	1	33	25	1	293888
4408	1	33	25	1	17736
4409	1	34	25	6	95018
4410	1	34	25	5	22452
4411	1	34	25	6	3688
4412	1	34	25	5	6320
4413	1	34	25	4	96868
4414	1	34	25	1	54477
4415	1	35	25	5	35445
4416	1	35	25	6	98631
4417	1	35	25	5	49715
4418	1	35	25	1	231768
4419	1	35	25	1	18258
4420	1	36	25	5	39414
4421	1	36	25	6	18416
4422	1	36	25	5	74698
4423	1	36	25	1	411813
4424	1	36	25	1	4473
4425	1	38	25	5	26859
4426	1	38	25	6	83226
4427	1	38	25	5	74038
4428	1	38	25	1	263422
4429	1	38	25	1	97581
4430	1	39	25	5	209218
4431	1	39	25	4	35726
4432	1	39	25	1	153517
4433	1	39	25	4	50298
4434	1	39	25	1	123502
4435	1	40	25	4	104381
4436	1	40	25	6	82426
4437	1	40	25	4	71409
4438	1	40	25	6	56440
4439	1	41	25	6	18677
4440	1	41	25	5	25831
4441	1	41	25	6	97721
4442	1	41	25	5	12928
4443	1	41	25	4	77644
4444	1	41	25	1	58179
4445	1	42	25	5	32678
4446	1	42	25	6	81675
4447	1	42	25	1	33604
4448	1	43	25	5	24729
4449	1	43	25	6	17233
4450	1	43	25	5	51866
4451	1	43	25	1	254437
4452	1	43	25	1	4703
4453	1	44	25	6	81525
4454	1	44	25	5	25933
4455	1	44	25	6	72943
4456	1	44	25	5	6868
4457	1	44	25	4	35713
4458	1	44	25	1	71046
4459	1	45	25	5	17470
4460	1	45	25	6	84915
4461	1	45	25	5	88368
4462	1	45	25	1	309258
4463	1	45	25	1	39168
4464	1	46	25	5	37552
4465	1	46	25	6	92170
4466	1	46	25	1	22769
4467	1	47	25	5	6672
4468	1	47	25	6	94687
4469	1	47	25	1	85310
4470	1	49	25	6	70697
4471	1	49	25	5	1023
4472	1	49	25	5	8484
4473	1	49	25	6	94996
4474	1	49	25	4	185766
4475	1	49	25	1	280863
4476	1	50	25	6	99901
4477	1	50	25	5	29880
4478	1	50	25	6	14503
4479	1	50	25	5	16210
4480	1	50	25	4	66558
4481	1	50	25	1	66719
4482	1	51	25	6	22843
4483	1	51	25	5	10331
4484	1	51	25	6	67980
4485	1	51	25	5	16701
4486	1	51	25	4	21279
4487	1	51	25	1	27005
4488	1	52	25	4	114535
4489	1	52	25	6	64324
4490	1	52	25	4	69663
4491	1	52	25	6	97327
4492	1	53	25	6	66348
4493	1	53	25	5	48286
4494	1	53	25	6	26407
4495	1	53	25	5	12148
4496	1	53	25	4	30971
4497	1	53	25	1	97933
4498	1	54	25	6	24341
4499	1	54	25	5	42330
4500	1	54	25	6	68202
4501	1	54	25	5	4390
4502	1	54	25	4	44593
4503	1	54	25	1	61744
4504	1	58	25	6	64853
4505	1	58	25	5	52390
4506	1	58	25	5	33006
4507	1	58	25	6	147645
4508	1	58	25	4	172641
4509	1	58	25	1	341315
4510	1	59	25	6	53892
4511	1	59	25	5	25979
4512	1	59	25	5	26645
4513	1	59	25	6	57480
4514	1	59	25	4	207577
4515	1	59	25	1	412081
4516	1	60	25	5	3641
4517	1	60	25	6	141981
4518	1	60	25	1	256646
4519	1	1	26	6	45663
4520	1	1	26	5	43304
4521	1	1	26	6	74762
4522	1	1	26	5	20137
4523	1	1	26	4	58585
4524	1	1	26	1	13447
4525	1	2	26	5	243487
4526	1	2	26	4	9236
4527	1	2	26	1	172753
4528	1	2	26	4	96854
4529	1	2	26	1	144526
4530	1	3	26	5	11230
4531	1	3	26	6	17363
4532	1	3	26	1	9046
4533	1	4	26	6	7159
4534	1	4	26	5	25007
4535	1	4	26	6	7893
4536	1	4	26	5	63538
4537	1	4	26	4	60824
4538	1	4	26	1	10252
4539	1	5	26	6	84312
4540	1	5	26	5	17471
4541	1	5	26	6	38562
4542	1	5	26	5	20494
4543	1	5	26	4	76964
4544	1	5	26	1	57868
4545	1	6	26	5	30293
4546	1	6	26	6	1151
4547	1	6	26	5	76318
4548	1	6	26	1	385920
4549	1	6	26	1	13102
4550	1	7	26	5	47464
4551	1	7	26	6	69208
4552	1	7	26	1	7752
4553	1	8	26	5	33085
4554	1	8	26	6	40167
4555	1	8	26	5	59150
4556	1	8	26	1	472654
4557	1	8	26	1	78715
4558	1	9	26	6	3562
4559	1	9	26	5	43639
4560	1	9	26	6	54803
4561	1	9	26	5	13709
4562	1	9	26	4	52264
4563	1	9	26	1	46178
4564	1	10	26	5	19688
4565	1	10	26	6	3430
4566	1	10	26	1	1921
4567	1	11	26	5	34538
4568	1	11	26	6	27106
4569	1	11	26	5	77675
4570	1	11	26	1	250081
4571	1	11	26	1	9169
4572	1	12	26	6	26369
4573	1	12	26	5	47410
4574	1	12	26	6	88352
4575	1	12	26	5	12490
4576	1	12	26	4	73202
4577	1	12	26	1	48245
4578	1	13	26	5	20328
4579	1	13	26	6	17589
4580	1	13	26	1	57884
4581	1	14	26	5	32166
4582	1	14	26	6	83622
4583	1	14	26	5	114373
4584	1	14	26	1	341862
4585	1	14	26	1	99458
4586	1	15	26	6	91153
4587	1	15	26	5	41471
4588	1	15	26	6	39829
4589	1	15	26	5	52574
4590	1	15	26	4	36020
4591	1	15	26	1	15595
4592	1	16	26	6	94493
4593	1	16	26	5	23104
4594	1	16	26	6	40363
4595	1	16	26	5	48590
4596	1	16	26	4	62120
4597	1	16	26	1	17572
4598	1	17	26	5	22959
4599	1	17	26	6	74566
4600	1	17	26	1	17874
4601	1	19	26	6	93401
4602	1	19	26	5	41866
4603	1	19	26	6	77086
4604	1	19	26	5	30224
4605	1	19	26	4	56647
4606	1	19	26	1	87347
4607	1	21	26	4	31106
4608	1	21	26	1	196391
4609	1	22	26	5	179644
4610	1	22	26	4	56898
4611	1	22	26	1	187853
4612	1	22	26	4	66207
4613	1	22	26	1	103500
4614	1	24	26	5	269573
4615	1	24	26	4	66311
4616	1	24	26	1	154440
4617	1	24	26	4	25903
4618	1	24	26	1	161176
4619	1	25	26	4	72177
4620	1	25	26	6	82539
4621	1	25	26	4	99316
4622	1	25	26	6	107208
4623	1	26	26	5	139819
4624	1	26	26	4	77367
4625	1	26	26	1	90438
4626	1	26	26	4	14549
4627	1	26	26	1	119338
4628	1	27	26	5	273576
4629	1	27	26	4	32966
4630	1	27	26	1	129733
4631	1	27	26	4	36962
4632	1	27	26	1	110654
4633	1	28	26	5	22519
4634	1	28	26	6	56771
4635	1	28	26	5	77871
4636	1	28	26	1	214148
4637	1	28	26	1	12228
4638	1	29	26	1	233067
4639	1	30	26	1	311562
4640	1	31	26	1	106991
4641	1	32	26	6	30859
4642	1	32	26	5	24124
4643	1	32	26	6	43761
4644	1	32	26	5	22038
4645	1	32	26	4	50524
4646	1	32	26	1	45753
4647	1	34	26	6	10200
4648	1	34	26	5	8582
4649	1	34	26	6	44401
4650	1	34	26	5	67525
4651	1	34	26	4	17160
4652	1	34	26	1	68042
4653	1	35	26	6	44079
4654	1	35	26	5	27668
4655	1	35	26	6	38129
4656	1	35	26	5	1767
4657	1	35	26	4	29534
4658	1	35	26	1	59397
4659	1	36	26	6	77916
4660	1	36	26	5	12031
4661	1	36	26	6	63402
4662	1	36	26	5	43676
4663	1	36	26	4	59466
4664	1	36	26	1	16303
4665	1	39	26	5	34845
4666	1	39	26	6	81254
4667	1	39	26	5	111676
4668	1	39	26	1	469279
4669	1	39	26	1	38402
4670	1	40	26	5	47601
4671	1	40	26	6	42081
4672	1	40	26	5	111860
4673	1	40	26	1	480469
4674	1	40	26	1	61418
4675	1	41	26	6	71383
4676	1	41	26	5	47872
4677	1	41	26	6	73609
4678	1	41	26	5	65137
4679	1	41	26	4	29601
4680	1	41	26	1	84220
4681	1	42	26	5	11900
4682	1	42	26	6	92059
4683	1	42	26	5	72237
4684	1	42	26	1	288466
4685	1	42	26	1	93046
4686	1	43	26	5	14818
4687	1	43	26	6	62753
4688	1	43	26	1	36425
4689	1	44	26	4	123249
4690	1	44	26	6	82056
4691	1	45	26	5	26846
4692	1	45	26	6	98764
4693	1	45	26	1	25285
4694	1	46	26	4	76754
4695	1	46	26	6	124017
4696	1	47	26	5	10629
4697	1	47	26	6	41453
4698	1	47	26	1	66814
4699	1	50	26	5	22923
4700	1	50	26	6	71186
4701	1	50	26	1	35675
4702	1	51	26	5	23227
4703	1	51	26	6	35612
4704	1	51	26	1	90980
4705	1	52	26	5	40026
4706	1	52	26	6	8706
4707	1	52	26	1	54454
4708	1	53	26	5	24868
4709	1	53	26	6	30576
4710	1	53	26	5	90350
4711	1	53	26	1	313146
4712	1	53	26	1	6113
4713	1	54	26	5	23569
4714	1	54	26	6	40686
4715	1	54	26	5	98524
4716	1	54	26	1	497470
4717	1	54	26	1	70930
4718	1	55	26	6	96798
4719	1	55	26	5	9382
4720	1	55	26	5	35032
4721	1	55	26	6	120509
4722	1	55	26	4	296743
4723	1	55	26	1	571193
4724	1	56	26	6	90916
4725	1	56	26	5	19168
4726	1	56	26	5	17094
4727	1	56	26	6	74999
4728	1	56	26	4	241124
4729	1	56	26	1	570513
4730	1	58	26	6	117585
4731	1	58	26	5	47720
4732	1	58	26	5	8906
4733	1	58	26	6	42124
4734	1	58	26	4	278369
4735	1	58	26	1	349804
4736	1	59	26	5	37140
4737	1	59	26	6	45274
4738	1	59	26	1	587117
4739	1	60	26	6	117575
4740	1	60	26	5	26924
4741	1	60	26	5	13431
4742	1	60	26	6	39112
4743	1	60	26	4	155845
4744	1	60	26	1	546366
4745	1	1	27	5	44948
4746	1	1	27	6	25016
4747	1	1	27	5	41410
4748	1	1	27	1	251388
4749	1	1	27	1	85323
4750	1	2	27	5	8281
4751	1	2	27	6	32710
4752	1	2	27	5	59503
4753	1	2	27	1	426386
4754	1	2	27	1	87340
4755	1	3	27	5	13104
4756	1	3	27	6	24234
4757	1	3	27	1	36441
4758	1	4	27	5	32533
4759	1	4	27	6	53707
4760	1	4	27	5	64441
4761	1	4	27	1	450956
4762	1	4	27	1	10207
4763	1	5	27	5	40065
4764	1	5	27	6	90809
4765	1	5	27	1	64413
4766	1	6	27	6	16249
4767	1	6	27	5	26806
4768	1	6	27	6	43005
4769	1	6	27	5	68996
4770	1	6	27	4	38619
4771	1	6	27	1	81820
4772	1	8	27	5	7185
4773	1	8	27	6	60215
4774	1	8	27	5	90051
4775	1	8	27	1	432565
4776	1	8	27	1	95151
4777	1	9	27	5	30470
4778	1	9	27	6	55646
4779	1	9	27	5	54777
4780	1	9	27	1	335023
4781	1	9	27	1	97270
4782	1	10	27	5	31040
4783	1	10	27	6	46470
4784	1	10	27	5	60108
4785	1	10	27	1	231040
4786	1	10	27	1	11357
4787	1	11	27	6	3973
4788	1	11	27	5	13529
4789	1	11	27	6	53432
4790	1	11	27	5	39338
4791	1	11	27	4	58923
4792	1	11	27	1	38681
4793	1	12	27	6	59234
4794	1	12	27	5	14756
4795	1	12	27	5	35401
4796	1	12	27	6	22332
4797	1	12	27	4	167607
4798	1	12	27	1	277855
4799	1	13	27	6	83073
4800	1	13	27	5	39507
4801	1	13	27	6	65864
4802	1	13	27	5	58077
4803	1	13	27	4	20514
4804	1	13	27	1	5192
4805	1	14	27	5	7497
4806	1	14	27	6	45836
4807	1	14	27	5	93684
4808	1	14	27	1	465792
4809	1	14	27	1	23541
4810	1	15	27	5	24848
4811	1	15	27	6	84564
4812	1	15	27	1	54568
4813	1	16	27	6	50271
4814	1	16	27	5	30089
4815	1	16	27	6	95263
4816	1	16	27	5	63543
4817	1	16	27	4	88295
4818	1	16	27	1	31047
4819	1	17	27	5	37636
4820	1	17	27	6	96102
4821	1	17	27	5	85004
4822	1	17	27	1	459630
4823	1	17	27	1	34186
4824	1	18	27	5	28158
4825	1	18	27	6	31752
4826	1	18	27	1	61712
4827	1	19	27	5	37147
4828	1	19	27	6	60126
4829	1	19	27	1	420058
4830	1	20	27	5	46066
4831	1	20	27	6	50999
4832	1	20	27	5	57005
4833	1	20	27	1	428629
4834	1	20	27	1	39949
4835	1	21	27	5	261127
4836	1	21	27	4	1186
4837	1	21	27	1	156920
4838	1	21	27	4	60275
4839	1	21	27	1	145812
4840	1	22	27	4	30605
4841	1	22	27	1	123169
4842	1	23	27	5	289749
4843	1	23	27	4	41441
4844	1	23	27	1	129234
4845	1	23	27	4	21180
4846	1	23	27	1	99498
4847	1	24	27	4	36368
4848	1	24	27	1	157031
4849	1	25	27	4	17115
4850	1	25	27	1	184507
4851	1	28	27	5	7792
4852	1	28	27	6	71042
4853	1	28	27	1	48972
4854	1	29	27	5	9725
4855	1	29	27	6	87378
4856	1	29	27	5	58726
4857	1	29	27	1	291021
4858	1	29	27	1	81707
4859	1	31	27	1	251417
4860	1	32	27	5	19982
4861	1	33	27	5	6058
4862	1	33	27	6	38146
4863	1	33	27	1	1158
4864	1	34	27	5	38580
4865	1	34	27	6	92246
4866	1	34	27	5	79017
4867	1	34	27	1	482766
4868	1	34	27	1	81403
4869	1	35	27	6	2780
4870	1	35	27	5	29262
4871	1	35	27	6	96669
4872	1	35	27	5	23628
4873	1	35	27	4	90380
4874	1	35	27	1	96195
4875	1	36	27	5	48427
4876	1	36	27	6	55960
4877	1	36	27	1	18969
4878	1	38	27	6	35166
4879	1	38	27	5	7289
4880	1	38	27	6	92203
4881	1	38	27	5	48694
4882	1	38	27	4	55907
4883	1	38	27	1	91799
4884	1	39	27	5	8185
4885	1	39	27	6	19186
4886	1	39	27	5	101906
4887	1	39	27	1	489218
4888	1	39	27	1	75901
4889	1	40	27	5	38561
4890	1	40	27	6	64885
4891	1	40	27	5	60206
4892	1	40	27	1	497589
4893	1	40	27	1	36591
4894	1	42	27	6	41664
4895	1	42	27	5	36564
4896	1	42	27	6	41496
4897	1	42	27	5	41487
4898	1	42	27	4	56621
4899	1	42	27	1	25742
4900	1	44	27	5	3025
4901	1	44	27	6	42637
4902	1	44	27	5	82324
4903	1	44	27	1	223216
4904	1	44	27	1	64299
4905	1	45	27	5	39616
4906	1	45	27	6	97729
4907	1	45	27	1	87392
4908	1	46	27	5	28141
4909	1	46	27	6	94926
4910	1	46	27	1	34220
4911	1	47	27	6	55587
4912	1	47	27	5	15714
4913	1	47	27	6	85937
4914	1	47	27	5	54405
4915	1	47	27	4	37775
4916	1	47	27	1	78215
4917	1	48	27	5	12923
4918	1	48	27	6	120377
4919	1	48	27	1	510482
4920	1	49	27	6	82447
4921	1	49	27	5	5075
4922	1	49	27	6	61777
4923	1	49	27	5	58573
4924	1	49	27	4	27405
4925	1	49	27	1	28464
4926	1	50	27	5	23886
4927	1	50	27	6	91048
4928	1	50	27	5	94402
4929	1	50	27	1	456215
4930	1	50	27	1	79837
4931	1	51	27	6	74084
4932	1	51	27	5	26776
4933	1	51	27	5	31737
4934	1	51	27	6	115138
4935	1	51	27	4	240040
4936	1	51	27	1	97285
4937	1	53	27	6	24469
4938	1	53	27	5	42876
4939	1	53	27	6	47463
4940	1	53	27	5	53666
4941	1	53	27	4	64858
4942	1	53	27	1	93603
4943	1	54	27	6	14570
4944	1	54	27	5	45693
4945	1	54	27	6	82288
4946	1	54	27	5	21866
4947	1	54	27	4	46759
4948	1	54	27	1	36592
4949	1	55	27	1	197120
4950	1	56	27	5	245078
4951	1	56	27	4	61392
4952	1	56	27	1	76276
4953	1	56	27	4	85661
4954	1	56	27	1	182988
4955	1	57	27	5	262192
4956	1	57	27	4	64560
4957	1	57	27	1	181061
4958	1	57	27	4	43185
4959	1	57	27	1	165975
4960	1	58	27	6	120251
4961	1	58	27	5	60245
4962	1	58	27	5	31875
4963	1	58	27	6	15774
4964	1	58	27	4	126570
4965	1	58	27	1	436960
4966	1	59	27	5	12614
4967	1	60	27	6	103213
4968	1	60	27	5	65047
4969	1	60	27	5	3507
4970	1	60	27	6	119707
4971	1	60	27	4	136884
4972	1	60	27	1	150829
4973	1	1	28	6	73589
4974	1	1	28	5	36839
4975	1	1	28	5	29806
4976	1	1	28	6	82032
4977	1	1	28	4	187072
4978	1	1	28	1	564606
4979	1	2	28	5	46864
4980	1	2	28	6	16679
4981	1	2	28	1	98517
4982	1	3	28	5	23621
4983	1	3	28	6	31055
4984	1	3	28	1	1030
4985	1	4	28	5	44353
4986	1	4	28	6	31260
4987	1	4	28	5	80733
4988	1	4	28	1	297885
4989	1	4	28	1	70173
4990	1	5	28	5	26833
4991	1	5	28	6	4897
4992	1	5	28	1	1094
4993	1	6	28	5	35835
4994	1	6	28	6	95264
4995	1	6	28	5	94028
4996	1	6	28	1	392384
4997	1	6	28	1	83143
4998	1	12	28	5	80786
4999	1	13	28	5	46992
5000	1	13	28	6	26043
5001	1	13	28	5	107795
5002	1	13	28	1	380326
5003	1	13	28	1	23464
5004	1	14	28	6	51678
5005	1	14	28	5	30751
5006	1	14	28	6	87942
5007	1	14	28	5	31624
5008	1	14	28	4	85543
5009	1	14	28	1	72161
5010	1	15	28	5	44452
5011	1	15	28	6	13338
5012	1	15	28	1	98105
5013	1	16	28	5	41707
5014	1	16	28	6	12026
5015	1	16	28	1	46253
5016	1	17	28	5	30701
5017	1	17	28	6	86658
5018	1	17	28	5	111078
5019	1	17	28	1	325795
5020	1	17	28	1	73110
5021	1	18	28	5	5787
5022	1	18	28	6	23085
5023	1	18	28	5	67908
5024	1	18	28	1	342335
5025	1	18	28	1	89806
5026	1	19	28	6	43051
5027	1	19	28	5	29344
5028	1	19	28	6	17982
5029	1	19	28	5	53813
5030	1	19	28	4	54547
5031	1	19	28	1	82559
5032	1	20	28	5	30612
5033	1	20	28	6	32499
5034	1	20	28	1	75546
5035	1	21	28	5	43684
5036	1	21	28	6	71978
5037	1	21	28	1	64295
5038	1	22	28	5	158960
5039	1	22	28	4	9811
5040	1	22	28	1	118595
5041	1	22	28	4	7897
5042	1	22	28	1	141738
5043	1	23	28	5	191829
5044	1	23	28	4	68981
5045	1	23	28	1	195097
5046	1	23	28	4	12386
5047	1	23	28	1	180984
5048	1	24	28	6	20980
5049	1	24	28	5	32358
5050	1	24	28	6	20920
5051	1	24	28	5	15612
5052	1	24	28	4	97885
5053	1	24	28	1	37931
5054	1	25	28	4	39316
5055	1	25	28	1	186579
5056	1	26	28	5	295999
5057	1	26	28	4	2096
5058	1	26	28	1	107858
5059	1	26	28	4	85451
5060	1	26	28	1	189215
5061	1	30	28	5	36475
5062	1	30	28	6	86635
5063	1	30	28	5	100399
5064	1	30	28	1	470120
5065	1	30	28	1	35045
5066	1	31	28	6	30490
5067	1	31	28	5	8770
5068	1	31	28	6	54397
5069	1	31	28	5	22910
5070	1	31	28	4	18900
5071	1	31	28	1	33502
5072	1	32	28	6	39561
5073	1	32	28	5	44686
5074	1	32	28	6	85367
5075	1	32	28	5	57517
5076	1	32	28	4	64739
5077	1	32	28	1	67609
5078	1	33	28	6	70693
5079	1	33	28	5	24909
5080	1	33	28	6	42546
5081	1	33	28	5	9410
5082	1	33	28	4	74835
5083	1	33	28	1	47321
5084	1	34	28	6	29275
5085	1	34	28	5	10910
5086	1	34	28	6	96481
5087	1	34	28	5	60027
5088	1	34	28	4	13776
5089	1	34	28	1	70243
5090	1	36	28	6	24533
5091	1	36	28	5	10956
5092	1	36	28	6	94511
5093	1	36	28	5	5576
5094	1	36	28	4	23038
5095	1	36	28	1	8299
5096	1	37	28	5	1759
5097	1	37	28	6	25221
5098	1	37	28	5	89185
5099	1	37	28	1	212797
5100	1	37	28	1	71720
5101	1	38	28	6	3123
5102	1	38	28	5	23242
5103	1	38	28	6	83997
5104	1	38	28	5	30156
5105	1	38	28	4	19677
5106	1	38	28	1	72936
5107	1	39	28	6	89100
5108	1	39	28	5	33885
5109	1	39	28	6	96630
5110	1	39	28	5	39734
5111	1	39	28	4	40185
5112	1	39	28	1	93329
5113	1	40	28	5	15974
5114	1	40	28	6	33331
5115	1	40	28	5	104687
5116	1	40	28	1	274624
5117	1	40	28	1	72611
5118	1	41	28	5	29899
5119	1	41	28	6	95096
5120	1	41	28	5	103980
5121	1	41	28	1	414964
5122	1	41	28	1	66017
5123	1	42	28	5	8890
5124	1	42	28	6	17038
5125	1	42	28	1	22337
5126	1	44	28	5	21947
5127	1	44	28	6	79523
5128	1	44	28	1	92150
5129	1	45	28	6	94485
5130	1	45	28	5	21796
5131	1	45	28	6	38510
5132	1	45	28	5	69002
5133	1	45	28	4	34450
5134	1	45	28	1	92225
5135	1	46	28	5	7276
5136	1	46	28	6	42676
5137	1	46	28	1	79419
5138	1	47	28	6	22191
5139	1	47	28	5	39066
5140	1	47	28	6	17490
5141	1	47	28	5	37038
5142	1	47	28	4	68229
5143	1	47	28	1	82079
5144	1	48	28	5	121361
5145	1	48	28	4	85993
5146	1	48	28	1	88968
5147	1	48	28	4	38403
5148	1	48	28	1	71991
5149	1	49	28	5	20539
5150	1	49	28	6	98341
5151	1	49	28	1	17935
5152	1	50	28	5	255449
5153	1	50	28	4	79681
5154	1	50	28	1	189939
5155	1	50	28	4	7355
5156	1	50	28	1	148921
5157	1	51	28	5	25253
5158	1	51	28	6	56582
5159	1	51	28	5	79819
5160	1	51	28	1	493662
5161	1	51	28	1	33902
5162	1	53	28	5	39084
5163	1	53	28	6	119858
5164	1	53	28	1	278617
5165	1	54	28	6	45441
5166	1	54	28	5	9500
5167	1	54	28	6	12254
5168	1	54	28	5	58037
5169	1	54	28	4	4751
5170	1	54	28	1	84397
5171	1	55	28	6	91987
5172	1	55	28	5	22226
5173	1	55	28	6	1207
5174	1	55	28	5	7968
5175	1	55	28	4	42843
5176	1	55	28	1	17550
5177	1	56	28	4	33614
5178	1	56	28	1	189858
5179	1	57	28	5	254728
5180	1	57	28	4	9518
5181	1	57	28	1	111516
5182	1	57	28	4	3132
5183	1	57	28	1	113424
5184	1	58	28	5	254008
5185	1	58	28	4	27877
5186	1	58	28	1	170358
5187	1	58	28	4	19448
5188	1	58	28	1	114923
5189	1	59	28	5	41441
5190	1	59	28	6	17655
5191	1	59	28	1	99568
5192	1	60	28	5	22402
5193	1	60	28	6	111626
5194	1	60	28	1	505700
5195	1	1	29	5	43850
5196	1	1	29	6	18484
5197	1	1	29	1	79968
5198	1	2	29	6	29060
5199	1	2	29	5	10629
5200	1	2	29	6	23243
5201	1	2	29	5	53317
5202	1	2	29	4	77179
5203	1	2	29	1	76913
5204	1	4	29	5	30338
5205	1	4	29	6	3618
5206	1	4	29	1	64151
5207	1	5	29	5	14276
5208	1	5	29	6	83926
5209	1	5	29	1	34556
5210	1	6	29	5	31005
5211	1	6	29	6	12666
5212	1	6	29	1	41260
5213	1	7	29	6	12243
5214	1	7	29	5	35933
5215	1	7	29	6	86693
5216	1	7	29	5	13085
5217	1	7	29	4	32130
5218	1	7	29	1	12051
5219	1	8	29	5	49733
5220	1	8	29	6	52664
5221	1	8	29	1	53346
5222	1	10	29	5	29049
5223	1	10	29	6	80956
5224	1	10	29	1	560927
5225	1	11	29	6	106544
5226	1	11	29	5	69653
5227	1	11	29	5	39456
5228	1	11	29	6	35568
5229	1	11	29	4	290654
5230	1	11	29	1	384755
5231	1	12	29	5	27110
5232	1	12	29	6	76577
5233	1	12	29	1	38382
5234	1	13	29	5	3276
5235	1	13	29	6	61925
5236	1	13	29	1	76110
5237	1	14	29	5	19602
5238	1	14	29	6	94922
5239	1	14	29	5	69908
5240	1	14	29	1	278268
5241	1	14	29	1	88833
5242	1	15	29	5	17579
5243	1	15	29	6	79996
5244	1	15	29	5	51724
5245	1	15	29	1	365011
5246	1	15	29	1	17362
5247	1	16	29	5	32390
5248	1	16	29	6	9433
5249	1	16	29	1	54712
5250	1	17	29	6	69925
5251	1	17	29	5	10387
5252	1	17	29	6	40437
5253	1	17	29	5	16358
5254	1	17	29	4	51448
5255	1	17	29	1	52829
5256	1	19	29	5	24575
5257	1	20	29	6	65025
5258	1	20	29	5	35442
5259	1	20	29	6	24384
5260	1	20	29	5	55860
5261	1	20	29	4	34360
5262	1	20	29	1	21169
5263	1	22	29	4	35759
5264	1	22	29	1	199237
5265	1	23	29	5	281237
5266	1	23	29	4	50688
5267	1	23	29	1	135816
5268	1	23	29	4	16900
5269	1	23	29	1	76478
5270	1	24	29	1	394250
5271	1	25	29	5	209422
5272	1	25	29	4	33529
5273	1	25	29	1	90349
5274	1	25	29	4	20724
5275	1	25	29	1	145633
5276	1	26	29	5	122555
5277	1	26	29	4	30384
5278	1	26	29	1	173294
5279	1	26	29	4	6153
5280	1	26	29	1	115985
5281	1	27	29	5	196192
5282	1	27	29	4	62200
5283	1	27	29	1	115819
5284	1	27	29	4	67217
5285	1	27	29	1	184015
5286	1	28	29	5	299571
5287	1	28	29	4	36865
5288	1	28	29	1	113194
5289	1	28	29	4	13837
5290	1	28	29	1	79093
5291	1	32	29	5	20407
5292	1	32	29	6	68947
5293	1	32	29	1	22685
5294	1	33	29	5	36390
5295	1	33	29	6	55079
5296	1	33	29	5	42905
5297	1	33	29	1	357623
5298	1	33	29	1	30337
5299	1	34	29	5	27897
5300	1	34	29	6	88174
5301	1	34	29	5	49826
5302	1	34	29	1	441399
5303	1	34	29	1	98308
5304	1	35	29	5	16176
5305	1	35	29	6	41139
5306	1	35	29	1	15338
5307	1	36	29	6	34097
5308	1	36	29	5	6566
5309	1	36	29	6	16737
5310	1	36	29	5	19045
5311	1	36	29	4	75673
5312	1	36	29	1	49606
5313	1	37	29	5	2479
5314	1	37	29	6	46177
5315	1	37	29	1	65656
5316	1	38	29	5	29207
5317	1	38	29	6	65352
5318	1	38	29	5	45981
5319	1	38	29	1	221887
5320	1	38	29	1	47740
5321	1	40	29	5	13176
5322	1	40	29	6	66446
5323	1	40	29	5	44688
5324	1	40	29	1	280163
5325	1	40	29	1	5090
5326	1	41	29	5	21135
5327	1	41	29	6	24625
5328	1	41	29	5	98437
5329	1	41	29	1	295782
5330	1	41	29	1	17684
5331	1	42	29	5	18653
5332	1	42	29	6	60023
5333	1	42	29	1	51084
5334	1	43	29	5	38803
5335	1	43	29	6	44929
5336	1	43	29	5	68212
5337	1	43	29	1	387375
5338	1	43	29	1	49425
5339	1	44	29	5	33069
5340	1	44	29	6	54472
5341	1	44	29	5	40951
5342	1	44	29	1	463785
5343	1	44	29	1	64658
5344	1	45	29	6	91282
5345	1	45	29	5	24234
5346	1	45	29	6	16088
5347	1	45	29	5	43800
5348	1	45	29	4	39123
5349	1	45	29	1	8856
5350	1	47	29	5	21192
5351	1	47	29	6	63719
5352	1	47	29	5	52991
5353	1	47	29	1	344953
5354	1	47	29	1	76087
5355	1	48	29	5	10008
5356	1	50	29	5	1982
5357	1	50	29	6	15327
5358	1	50	29	5	55287
5359	1	50	29	1	444569
5360	1	50	29	1	80058
5361	1	51	29	4	145171
5362	1	51	29	6	83848
5363	1	51	29	4	120108
5364	1	51	29	6	133289
5365	1	52	29	5	5568
5366	1	52	29	6	97799
5367	1	52	29	5	118676
5368	1	52	29	1	219535
5369	1	52	29	1	37086
5370	1	53	29	5	36282
5371	1	53	29	6	43466
5372	1	53	29	1	34130
5373	1	55	29	6	14414
5374	1	55	29	5	49318
5375	1	55	29	6	43654
5376	1	55	29	5	35201
5377	1	55	29	4	15370
5378	1	55	29	1	40954
5379	1	56	29	5	36103
5380	1	56	29	6	86595
5381	1	56	29	1	30441
5382	1	57	29	5	145715
5383	1	57	29	4	32882
5384	1	57	29	1	128170
5385	1	57	29	4	80819
5386	1	57	29	1	89269
5387	1	58	29	5	143189
5388	1	58	29	4	38377
5389	1	58	29	1	162608
5390	1	58	29	4	26421
5391	1	58	29	1	74767
5392	1	59	29	6	66155
5393	1	59	29	5	32858
5394	1	59	29	6	8494
5395	1	59	29	5	66367
5396	1	59	29	4	97152
5397	1	59	29	1	33672
5398	1	60	29	6	89852
5399	1	60	29	5	57405
5400	1	60	29	5	49937
5401	1	60	29	6	65127
5402	1	60	29	4	178223
5403	1	60	29	1	368382
5404	1	4	30	4	97810
5405	1	4	30	6	112772
5406	1	4	30	4	135116
5407	1	4	30	6	122178
5408	1	5	30	6	53762
5409	1	5	30	5	43944
5410	1	5	30	6	74274
5411	1	5	30	5	5106
5412	1	5	30	4	88677
5413	1	5	30	1	33468
5414	1	6	30	5	27892
5415	1	6	30	6	84373
5416	1	6	30	1	31342
5417	1	7	30	5	3677
5418	1	7	30	6	61478
5419	1	7	30	1	79373
5420	1	8	30	5	11814
5421	1	8	30	6	39502
5422	1	8	30	5	52919
5423	1	8	30	1	305763
5424	1	8	30	1	15649
5425	1	9	30	6	1622
5426	1	9	30	5	8113
5427	1	9	30	6	93203
5428	1	9	30	5	3480
5429	1	9	30	4	87784
5430	1	9	30	1	41567
5431	1	10	30	6	143115
5432	1	10	30	5	53801
5433	1	10	30	5	36598
5434	1	10	30	6	22177
5435	1	10	30	4	245006
5436	1	10	30	1	558402
5437	1	11	30	5	7333
5438	1	11	30	6	68144
5439	1	11	30	1	517141
5440	1	12	30	5	19872
5441	1	12	30	6	32204
5442	1	12	30	1	43641
5443	1	13	30	6	41556
5444	1	13	30	5	27292
5445	1	13	30	6	58114
5446	1	13	30	5	22147
5447	1	13	30	4	49846
5448	1	13	30	1	87227
5449	1	14	30	6	19996
5450	1	14	30	5	46173
5451	1	14	30	6	84309
5452	1	14	30	5	60521
5453	1	14	30	4	30390
5454	1	14	30	1	32757
5455	1	15	30	5	42139
5456	1	15	30	6	23382
5457	1	15	30	1	79522
5458	1	16	30	5	13591
5459	1	16	30	6	94184
5460	1	16	30	1	30678
5461	1	17	30	4	123853
5462	1	17	30	6	83610
5463	1	17	30	4	77934
5464	1	17	30	6	95484
5465	1	23	30	5	141205
5466	1	23	30	4	36154
5467	1	23	30	1	73234
5468	1	23	30	4	93181
5469	1	23	30	1	111375
5470	1	24	30	5	135130
5471	1	24	30	4	19569
5472	1	24	30	1	130554
5473	1	24	30	4	57124
5474	1	24	30	1	125803
5475	1	25	30	4	60290
5476	1	25	30	1	173357
5477	1	26	30	5	122022
5478	1	26	30	4	29910
5479	1	26	30	1	149060
5480	1	26	30	4	7590
5481	1	26	30	1	125658
5482	1	27	30	1	274824
5483	1	28	30	4	97186
5484	1	28	30	1	99636
5485	1	30	30	5	26113
5486	1	31	30	6	95638
5487	1	31	30	5	34049
5488	1	31	30	6	62857
5489	1	31	30	5	39406
5490	1	31	30	4	43351
5491	1	31	30	1	23975
5492	1	32	30	5	30885
5493	1	32	30	6	80574
5494	1	32	30	5	84118
5495	1	32	30	1	411388
5496	1	32	30	1	58254
5497	1	33	30	5	3599
5498	1	33	30	6	50241
5499	1	33	30	1	80813
5500	1	34	30	6	20398
5501	1	34	30	5	24794
5502	1	34	30	6	71290
5503	1	34	30	5	11126
5504	1	34	30	4	77866
5505	1	34	30	1	33817
5506	1	35	30	5	16046
5507	1	35	30	6	39011
5508	1	35	30	5	105048
5509	1	35	30	1	227441
5510	1	35	30	1	72444
5511	1	36	30	5	34897
5512	1	36	30	6	20570
5513	1	36	30	1	59326
5514	1	37	30	5	102590
5515	1	37	30	4	31057
5516	1	37	30	1	170044
5517	1	37	30	4	90684
5518	1	37	30	1	110360
5519	1	38	30	5	19228
5520	1	38	30	6	36206
5521	1	38	30	5	69657
5522	1	38	30	1	218388
5523	1	38	30	1	52383
5524	1	39	30	6	57347
5525	1	39	30	5	35336
5526	1	39	30	6	18786
5527	1	39	30	5	30364
5528	1	39	30	4	41446
5529	1	39	30	1	41058
5530	1	40	30	6	60233
5531	1	40	30	5	27629
5532	1	40	30	6	34862
5533	1	40	30	5	55296
5534	1	40	30	4	23360
5535	1	40	30	1	18943
5536	1	41	30	5	37061
5537	1	41	30	6	66444
5538	1	41	30	1	10477
5539	1	42	30	5	36462
5540	1	42	30	6	81524
5541	1	42	30	5	49794
5542	1	42	30	1	415778
5543	1	42	30	1	89199
5544	1	43	30	5	42010
5545	1	43	30	6	39035
5546	1	43	30	5	96071
5547	1	43	30	1	359287
5548	1	43	30	1	91805
5549	1	44	30	6	75527
5550	1	44	30	5	45519
5551	1	44	30	6	4148
5552	1	44	30	5	13843
5553	1	44	30	4	44110
5554	1	44	30	1	49811
5555	1	45	30	6	14466
5556	1	45	30	5	17482
5557	1	45	30	6	56550
5558	1	45	30	5	61094
5559	1	45	30	4	29934
5560	1	45	30	1	74394
5561	1	46	30	6	59231
5562	1	46	30	5	17093
5563	1	46	30	6	16753
5564	1	46	30	5	41269
5565	1	46	30	4	12676
5566	1	46	30	1	11785
5567	1	47	30	6	45210
5568	1	47	30	5	17296
5569	1	47	30	6	58080
5570	1	47	30	5	68887
5571	1	47	30	4	31696
5572	1	47	30	1	64110
5573	1	48	30	5	35184
5574	1	48	30	6	10534
5575	1	48	30	1	13485
5576	1	49	30	5	12321
5577	1	49	30	6	21578
5578	1	49	30	5	77674
5579	1	49	30	1	255005
5580	1	49	30	1	15498
5581	1	50	30	5	2404
5582	1	50	30	6	61564
5583	1	50	30	1	27384
5584	1	51	30	5	34464
5585	1	51	30	6	52026
5586	1	51	30	5	61587
5587	1	51	30	1	477545
5588	1	51	30	1	35125
5589	1	52	30	6	98329
5590	1	52	30	5	14687
5591	1	52	30	6	13629
5592	1	52	30	5	25368
5593	1	52	30	4	89913
5594	1	52	30	1	36176
5595	1	53	30	5	13054
5596	1	53	30	6	7375
5597	1	53	30	5	117508
5598	1	53	30	1	468542
5599	1	53	30	1	83644
5600	1	54	30	5	47111
5601	1	54	30	6	16195
5602	1	54	30	5	96471
5603	1	54	30	1	415562
5604	1	54	30	1	86771
5605	1	55	30	5	27896
5606	1	55	30	6	44964
5607	1	55	30	1	30327
5608	1	56	30	5	37207
5609	1	56	30	6	89792
5610	1	56	30	5	49853
5611	1	56	30	1	341910
5612	1	56	30	1	27134
5613	1	57	30	6	89471
5614	1	57	30	5	25497
5615	1	57	30	6	50081
5616	1	57	30	5	29121
5617	1	57	30	4	27182
5618	1	57	30	1	19066
5619	1	58	30	6	43662
5620	1	58	30	5	28835
5621	1	58	30	6	30604
5622	1	58	30	5	62900
5623	1	58	30	4	76241
5624	1	58	30	1	41783
5625	1	59	30	5	48343
5626	1	59	30	6	7437
5627	1	59	30	1	90411
5628	1	60	30	5	270374
5629	1	60	30	4	82737
5630	1	60	30	1	140871
5631	1	60	30	4	84037
5632	1	60	30	1	155269
5633	1	3	31	5	226123
5634	1	3	31	4	70147
5635	1	3	31	1	178352
5636	1	3	31	4	86679
5637	1	3	31	1	93059
5638	1	4	31	6	81186
5639	1	4	31	5	33121
5640	1	4	31	6	99951
5641	1	4	31	5	16273
5642	1	4	31	4	16819
5643	1	4	31	1	3385
5644	1	5	31	5	22117
5645	1	5	31	6	61867
5646	1	5	31	1	35324
5647	1	6	31	5	39527
5648	1	6	31	6	58622
5649	1	6	31	5	102693
5650	1	6	31	1	237575
5651	1	6	31	1	55538
5652	1	7	31	5	48319
5653	1	7	31	6	52984
5654	1	7	31	1	29713
5655	1	8	31	5	36673
5656	1	8	31	6	19145
5657	1	8	31	5	59031
5658	1	8	31	1	361614
5659	1	8	31	1	2174
5660	1	9	31	5	18080
5661	1	9	31	6	15768
5662	1	9	31	1	78542
5663	1	10	31	5	17581
5664	1	10	31	6	59459
5665	1	10	31	1	80489
5666	1	11	31	5	35494
5667	1	11	31	6	61819
5668	1	11	31	5	50068
5669	1	11	31	1	238447
5670	1	11	31	1	63751
5671	1	14	31	5	26925
5672	1	14	31	6	18739
5673	1	14	31	5	75873
5674	1	14	31	1	244433
5675	1	14	31	1	22267
5676	1	15	31	6	56298
5677	1	15	31	5	4915
5678	1	15	31	6	7888
5679	1	15	31	5	16506
5680	1	15	31	4	75897
5681	1	15	31	1	56179
5682	1	16	31	5	38693
5683	1	16	31	6	20134
5684	1	16	31	5	110626
5685	1	16	31	1	255959
5686	1	16	31	1	93111
5687	1	23	31	5	255726
5688	1	23	31	4	96153
5689	1	23	31	1	130039
5690	1	23	31	4	29943
5691	1	23	31	1	117364
5692	1	24	31	5	133449
5693	1	24	31	4	28657
5694	1	24	31	1	110554
5695	1	24	31	4	49161
5696	1	24	31	1	122597
5697	1	25	31	5	43678
5698	1	26	31	5	263204
5699	1	26	31	4	50343
5700	1	26	31	1	109566
5701	1	26	31	4	52902
5702	1	26	31	1	187900
5703	1	27	31	5	178964
5704	1	27	31	4	21798
5705	1	27	31	1	116170
5706	1	27	31	4	8185
5707	1	27	31	1	180953
5708	1	28	31	4	9063
5709	1	28	31	1	161097
5710	1	31	31	5	44418
5711	1	31	31	6	74183
5712	1	31	31	5	57487
5713	1	31	31	1	283451
5714	1	31	31	1	54190
5715	1	32	31	5	7730
5716	1	32	31	6	98417
5717	1	32	31	1	58085
5718	1	33	31	5	22404
5719	1	33	31	6	15038
5720	1	33	31	5	40892
5721	1	33	31	1	305463
5722	1	33	31	1	29900
5723	1	34	31	1	163783
5724	1	35	31	5	33222
5725	1	35	31	6	14031
5726	1	35	31	1	65372
5727	1	36	31	6	53415
5728	1	36	31	5	1869
5729	1	36	31	6	2384
5730	1	36	31	5	9336
5731	1	36	31	4	78133
5732	1	36	31	1	34848
5733	1	37	31	5	33818
5734	1	37	31	6	85644
5735	1	37	31	5	77021
5736	1	37	31	1	396190
5737	1	37	31	1	55135
5738	1	38	31	5	14936
5739	1	38	31	6	8343
5740	1	38	31	5	92182
5741	1	38	31	1	386295
5742	1	38	31	1	96270
5743	1	39	31	1	353096
5744	1	40	31	5	13362
5745	1	40	31	6	67455
5746	1	40	31	5	92967
5747	1	40	31	1	445339
5748	1	40	31	1	10739
5749	1	41	31	6	18923
5750	1	41	31	5	24207
5751	1	41	31	6	71723
5752	1	41	31	5	41720
5753	1	41	31	4	16616
5754	1	41	31	1	23897
5755	1	42	31	5	6213
5756	1	42	31	6	80602
5757	1	42	31	1	2934
5758	1	43	31	6	74846
5759	1	43	31	5	46226
5760	1	43	31	6	62684
5761	1	43	31	5	16586
5762	1	43	31	4	74579
5763	1	43	31	1	75006
5764	1	44	31	6	126928
5765	1	44	31	5	18499
5766	1	44	31	5	33024
5767	1	44	31	6	95194
5768	1	44	31	4	161564
5769	1	44	31	1	487779
5770	1	45	31	5	36562
5771	1	45	31	6	14556
5772	1	45	31	5	109133
5773	1	45	31	1	381277
5774	1	45	31	1	76367
5775	1	46	31	1	102231
5776	1	47	31	5	50245
5777	1	49	31	5	16031
5778	1	49	31	6	51564
5779	1	49	31	1	65237
5780	1	50	31	5	42324
5781	1	50	31	6	44327
5782	1	50	31	5	64436
5783	1	50	31	1	280391
5784	1	50	31	1	86434
5785	1	51	31	4	47011
5786	1	51	31	1	131257
5787	1	53	31	6	77626
5788	1	53	31	5	28608
5789	1	53	31	6	52052
5790	1	53	31	5	53780
5791	1	53	31	4	51547
5792	1	53	31	1	82303
5793	1	54	31	5	4780
5794	1	54	31	6	79201
5795	1	54	31	1	9590
5796	1	55	31	5	7656
5797	1	55	31	6	74323
5798	1	55	31	5	41747
5799	1	55	31	1	247258
5800	1	55	31	1	49362
5801	1	56	31	5	4334
5802	1	56	31	6	39801
5803	1	56	31	1	99458
5804	1	57	31	5	42806
5805	1	57	31	6	84765
5806	1	57	31	5	40062
5807	1	57	31	1	471727
5808	1	57	31	1	25283
5809	1	58	31	5	16516
5810	1	58	31	6	89943
5811	1	58	31	1	40313
5812	1	59	31	6	54340
5813	1	59	31	5	34105
5814	1	59	31	6	84265
5815	1	59	31	5	22907
5816	1	59	31	4	50159
5817	1	59	31	1	14765
5818	1	60	31	5	11547
5819	1	60	31	6	91971
5820	1	60	31	1	32705
5821	1	2	32	5	96698
5822	1	4	32	6	78623
5823	1	4	32	5	18759
5824	1	4	32	6	62575
5825	1	4	32	5	64148
5826	1	4	32	4	77965
5827	1	4	32	1	54544
5828	1	5	32	5	47517
5829	1	5	32	6	43997
5830	1	5	32	5	101566
5831	1	5	32	1	467124
5832	1	5	32	1	10846
5833	1	6	32	5	21036
5834	1	6	32	6	57801
5835	1	6	32	5	94043
5836	1	6	32	1	487802
5837	1	6	32	1	73316
5838	1	7	32	5	44481
5839	1	7	32	6	37527
5840	1	7	32	1	65260
5841	1	8	32	5	1463
5842	1	8	32	6	10319
5843	1	8	32	5	68461
5844	1	8	32	1	201200
5845	1	8	32	1	47031
5846	1	9	32	5	8930
5847	1	9	32	6	30894
5848	1	9	32	1	58658
5849	1	10	32	6	83703
5850	1	10	32	5	16085
5851	1	10	32	6	97656
5852	1	10	32	5	19045
5853	1	10	32	4	15628
5854	1	10	32	1	64410
5855	1	11	32	5	12911
5856	1	11	32	6	56213
5857	1	11	32	5	101340
5858	1	11	32	1	212427
5859	1	11	32	1	50678
5860	1	13	32	5	81441
5861	1	14	32	5	45941
5862	1	14	32	6	28042
5863	1	14	32	1	73968
5864	1	15	32	6	29683
5865	1	15	32	5	15718
5866	1	15	32	6	21100
5867	1	15	32	5	65481
5868	1	15	32	4	55407
5869	1	15	32	1	43381
5870	1	16	32	5	8575
5871	1	16	32	6	75688
5872	1	16	32	5	42674
5873	1	16	32	1	348755
5874	1	16	32	1	31434
5875	1	25	32	5	172603
5876	1	25	32	4	25737
5877	1	25	32	1	136282
5878	1	25	32	4	22540
5879	1	25	32	1	141255
5880	1	27	32	4	62125
5881	1	27	32	1	181015
5882	1	28	32	5	214555
5883	1	28	32	4	20011
5884	1	28	32	1	197931
5885	1	28	32	4	55646
5886	1	28	32	1	86495
5887	1	29	32	5	188965
5888	1	29	32	4	98992
5889	1	29	32	1	73003
5890	1	29	32	4	89421
5891	1	29	32	1	76144
5892	1	31	32	5	37002
5893	1	31	32	6	53856
5894	1	31	32	5	78688
5895	1	31	32	1	204655
5896	1	31	32	1	12243
5897	1	32	32	5	16519
5898	1	32	32	6	37551
5899	1	32	32	5	118671
5900	1	32	32	1	279215
5901	1	32	32	1	42407
5902	1	33	32	5	37571
5903	1	33	32	6	27036
5904	1	33	32	5	68111
5905	1	33	32	1	375119
5906	1	33	32	1	90225
5907	1	34	32	6	51022
5908	1	34	32	5	1018
5909	1	34	32	6	62668
5910	1	34	32	5	46363
5911	1	34	32	4	1819
5912	1	34	32	1	84075
5913	1	35	32	6	84502
5914	1	35	32	5	39284
5915	1	35	32	6	23465
5916	1	35	32	5	16543
5917	1	35	32	4	18562
5918	1	35	32	1	25621
5919	1	36	32	5	261096
5920	1	36	32	4	87363
5921	1	36	32	1	101531
5922	1	36	32	4	41836
5923	1	36	32	1	172863
5924	1	37	32	5	11082
5925	1	37	32	6	47149
5926	1	37	32	5	119815
5927	1	37	32	1	335747
5928	1	37	32	1	27540
5929	1	38	32	1	86217
5930	1	45	32	6	15583
5931	1	45	32	5	34833
5932	1	45	32	6	32842
5933	1	45	32	5	16239
5934	1	45	32	4	51941
5935	1	45	32	1	79407
5936	1	46	32	6	79915
5937	1	46	32	5	47313
5938	1	46	32	5	10570
5939	1	46	32	6	131262
5940	1	46	32	4	219690
5941	1	46	32	1	383519
5942	1	47	32	6	140222
5943	1	47	32	5	16033
5944	1	47	32	5	17879
5945	1	47	32	6	13687
5946	1	47	32	4	258939
5947	1	47	32	1	348525
5948	1	50	32	5	33711
5949	1	50	32	6	42643
5950	1	50	32	1	65681
5951	1	51	32	6	89562
5952	1	51	32	5	46082
5953	1	51	32	6	47087
5954	1	51	32	5	14631
5955	1	51	32	4	23233
5956	1	51	32	1	37849
5957	1	52	32	6	23833
5958	1	52	32	5	27769
5959	1	52	32	6	12650
5960	1	52	32	5	60332
5961	1	52	32	4	82747
5962	1	52	32	1	34646
5963	1	53	32	5	29922
5964	1	53	32	6	65711
5965	1	53	32	1	97060
5966	1	54	32	5	27435
5967	1	54	32	6	23733
5968	1	54	32	5	95438
5969	1	54	32	1	336505
5970	1	54	32	1	80869
5971	1	55	32	6	105828
5972	1	55	32	5	56098
5973	1	55	32	5	32875
5974	1	55	32	6	1624
5975	1	55	32	4	218163
5976	1	55	32	1	110932
5977	1	56	32	5	26913
5978	1	57	32	5	31275
5979	1	58	32	5	36000
5980	1	58	32	6	79586
5981	1	58	32	5	61956
5982	1	58	32	1	370183
5983	1	58	32	1	22595
5984	1	1	33	5	84270
5985	1	2	33	5	38814
5986	1	5	33	4	132427
5987	1	5	33	6	104486
5988	1	6	33	5	37287
5989	1	6	33	6	4288
5990	1	6	33	1	53661
5991	1	13	33	5	139004
5992	1	13	33	4	35895
5993	1	13	33	1	161298
5994	1	13	33	4	71663
5995	1	13	33	1	114692
5996	1	15	33	6	82527
5997	1	15	33	5	23696
5998	1	15	33	6	14726
5999	1	15	33	5	9512
6000	1	15	33	4	5586
6001	1	15	33	1	87995
6002	1	16	33	5	4771
6003	1	16	33	6	24042
6004	1	16	33	1	19242
6005	1	17	33	5	41709
6006	1	17	33	6	24786
6007	1	17	33	1	14375
6008	1	25	33	5	247665
6009	1	25	33	4	84337
6010	1	25	33	1	149241
6011	1	25	33	4	45360
6012	1	25	33	1	152742
6013	1	26	33	5	33127
6014	1	26	33	6	1348
6015	1	26	33	1	257213
6016	1	27	33	5	214052
6017	1	27	33	4	30094
6018	1	27	33	1	126344
6019	1	27	33	4	30558
6020	1	27	33	1	94346
6021	1	28	33	5	135897
6022	1	28	33	4	9844
6023	1	28	33	1	121310
6024	1	28	33	4	30815
6025	1	28	33	1	95529
6026	1	29	33	5	218731
6027	1	29	33	4	13664
6028	1	29	33	1	157242
6029	1	29	33	4	65211
6030	1	29	33	1	181989
6031	1	30	33	5	260574
6032	1	30	33	4	84246
6033	1	30	33	1	151984
6034	1	30	33	4	27320
6035	1	30	33	1	199029
6036	1	31	33	6	69048
6037	1	31	33	5	39736
6038	1	31	33	6	3185
6039	1	31	33	5	35766
6040	1	31	33	4	8818
6041	1	31	33	1	90891
6042	1	32	33	5	29957
6043	1	32	33	6	91908
6044	1	32	33	1	3533
6045	1	35	33	6	76037
6046	1	35	33	5	5744
6047	1	35	33	6	23584
6048	1	35	33	5	8610
6049	1	35	33	4	24792
6050	1	35	33	1	17667
6051	1	36	33	6	2889
6052	1	36	33	5	28954
6053	1	36	33	6	80811
6054	1	36	33	5	44563
6055	1	36	33	4	27966
6056	1	36	33	1	13402
6057	1	37	33	5	33535
6058	1	37	33	6	88411
6059	1	37	33	5	103801
6060	1	37	33	1	347995
6061	1	37	33	1	44344
6062	1	38	33	5	2976
6063	1	38	33	6	26150
6064	1	38	33	5	111613
6065	1	38	33	1	349033
6066	1	38	33	1	6857
6067	1	40	33	1	318142
6068	1	41	33	1	124549
6069	1	42	33	1	333070
6070	1	44	33	5	41097
6071	1	44	33	6	93416
6072	1	44	33	1	48718
6073	1	45	33	4	133297
6074	1	45	33	6	146584
6075	1	45	33	4	149964
6076	1	45	33	6	144384
6077	1	46	33	6	112101
6078	1	46	33	5	3158
6079	1	46	33	5	19380
6080	1	46	33	6	149826
6081	1	46	33	4	154076
6082	1	46	33	1	471778
6083	1	47	33	5	14319
6084	1	47	33	6	105169
6085	1	47	33	1	128710
6086	1	50	33	5	3821
6087	1	50	33	6	88576
6088	1	50	33	1	70094
6089	1	51	33	5	35779
6090	1	51	33	6	41772
6091	1	51	33	1	16469
6092	1	52	33	5	14811
6093	1	52	33	6	73959
6094	1	52	33	5	70025
6095	1	52	33	1	222873
6096	1	52	33	1	8098
6097	1	53	33	5	21617
6098	1	53	33	6	22518
6099	1	53	33	5	65457
6100	1	53	33	1	220131
6101	1	53	33	1	61797
6102	1	55	33	5	39895
6103	1	55	33	6	95788
6104	1	55	33	5	103212
6105	1	55	33	1	286775
6106	1	55	33	1	90403
6107	1	57	33	5	92977
6108	1	58	33	5	44026
6109	1	59	33	5	26836
6110	1	59	33	6	5854
6111	1	59	33	5	88796
6112	1	59	33	1	492096
6113	1	59	33	1	6927
6114	1	60	33	6	19762
6115	1	60	33	5	29798
6116	1	60	33	6	65554
6117	1	60	33	5	10259
6118	1	60	33	4	4027
6119	1	60	33	1	77431
6120	1	1	34	5	96465
6121	1	2	34	5	9047
6122	1	4	34	4	74841
6123	1	4	34	6	132569
6124	1	4	34	4	77689
6125	1	4	34	6	130543
6126	1	5	34	4	75826
6127	1	5	34	6	139299
6128	1	5	34	4	63289
6129	1	5	34	6	140718
6130	1	6	34	4	133435
6131	1	6	34	6	61846
6132	1	7	34	5	35415
6133	1	7	34	6	79141
6134	1	7	34	5	115261
6135	1	7	34	1	250298
6136	1	7	34	1	39183
6137	1	8	34	6	27046
6138	1	8	34	5	36857
6139	1	8	34	6	50348
6140	1	8	34	5	37686
6141	1	8	34	4	79559
6142	1	8	34	1	49238
6143	1	9	34	5	44048
6144	1	9	34	6	47444
6145	1	9	34	5	94894
6146	1	9	34	1	301169
6147	1	9	34	1	98212
6148	1	15	34	6	21402
6149	1	15	34	5	32874
6150	1	15	34	6	90867
6151	1	15	34	5	16104
6152	1	15	34	4	66788
6153	1	15	34	1	90014
6154	1	16	34	6	31231
6155	1	16	34	5	18200
6156	1	16	34	6	65457
6157	1	16	34	5	33228
6158	1	16	34	4	73117
6159	1	16	34	1	19676
6160	1	17	34	5	49975
6161	1	17	34	6	64922
6162	1	17	34	5	83371
6163	1	17	34	1	301805
6164	1	17	34	1	6533
6165	1	22	34	5	108611
6166	1	22	34	4	64061
6167	1	22	34	1	188873
6168	1	22	34	4	46554
6169	1	22	34	1	106878
6170	1	27	34	5	198597
6171	1	27	34	4	68006
6172	1	27	34	1	172989
6173	1	27	34	4	66456
6174	1	27	34	1	98762
6175	1	28	34	5	261980
6176	1	28	34	4	94886
6177	1	28	34	1	125587
6178	1	28	34	4	44984
6179	1	28	34	1	169604
6180	1	29	34	5	112804
6181	1	29	34	4	90151
6182	1	29	34	1	127965
6183	1	29	34	4	28896
6184	1	29	34	1	125604
6185	1	30	34	5	165599
6186	1	30	34	4	90351
6187	1	30	34	1	82636
6188	1	30	34	4	71805
6189	1	30	34	1	153218
6190	1	31	34	5	36437
6191	1	31	34	6	66681
6192	1	31	34	1	18571
6193	1	32	34	5	5324
6194	1	32	34	6	10224
6195	1	32	34	1	4798
6196	1	34	34	5	34835
6197	1	34	34	6	71642
6198	1	34	34	1	49146
6199	1	35	34	5	2587
6200	1	35	34	6	74021
6201	1	35	34	5	75341
6202	1	35	34	1	385948
6203	1	35	34	1	47495
6204	1	36	34	5	21162
6205	1	36	34	6	15059
6206	1	36	34	1	16208
6207	1	37	34	5	46522
6208	1	37	34	6	82184
6209	1	37	34	5	42610
6210	1	37	34	1	253736
6211	1	37	34	1	12827
6212	1	38	34	1	393712
6213	1	39	34	1	182953
6214	1	40	34	1	253715
6215	1	41	34	1	151400
6216	1	42	34	5	8642
6217	1	45	34	6	71966
6218	1	45	34	5	47561
6219	1	45	34	6	68832
6220	1	45	34	5	38427
6221	1	45	34	4	15698
6222	1	45	34	1	85452
6223	1	46	34	6	55758
6224	1	46	34	5	54589
6225	1	46	34	5	12216
6226	1	46	34	6	132834
6227	1	46	34	4	287562
6228	1	46	34	1	377576
6229	1	47	34	5	33474
6230	1	47	34	6	28989
6231	1	47	34	1	491167
6232	1	49	34	5	35923
6233	1	49	34	6	22403
6234	1	49	34	5	60476
6235	1	49	34	1	376042
6236	1	49	34	1	42427
6237	1	50	34	5	28595
6238	1	50	34	6	30924
6239	1	50	34	1	80806
6240	1	51	34	6	1785
6241	1	51	34	5	46766
6242	1	51	34	6	64820
6243	1	51	34	5	65737
6244	1	51	34	4	84689
6245	1	51	34	1	13004
6246	1	52	34	5	33321
6247	1	52	34	6	64314
6248	1	52	34	1	76199
6249	1	53	34	5	8127
6250	1	53	34	6	26674
6251	1	53	34	5	100348
6252	1	53	34	1	326849
6253	1	53	34	1	72718
6254	1	54	34	5	38207
6255	1	54	34	6	16397
6256	1	54	34	5	66038
6257	1	54	34	1	483248
6258	1	54	34	1	61320
6259	1	55	34	5	7142
6260	1	55	34	6	49307
6261	1	55	34	5	60050
6262	1	55	34	1	290204
6263	1	55	34	1	13466
6264	1	56	34	5	7690
6265	1	56	34	6	65962
6266	1	56	34	5	51292
6267	1	56	34	1	272249
6268	1	56	34	1	52395
6269	1	57	34	4	59822
6270	1	57	34	6	109440
6271	1	58	34	5	40826
6272	1	59	34	6	24636
6273	1	59	34	5	1068
6274	1	59	34	6	56874
6275	1	59	34	5	69015
6276	1	59	34	4	93161
6277	1	59	34	1	35163
6278	1	60	34	5	9781
6279	1	60	34	6	49797
6280	1	60	34	1	50188
6281	1	1	35	5	49807
6282	1	2	35	5	32737
6283	1	4	35	4	140302
6284	1	4	35	6	88918
6285	1	4	35	4	81230
6286	1	4	35	6	119920
6287	1	5	35	4	141547
6288	1	5	35	6	122250
6289	1	5	35	4	112632
6290	1	5	35	6	107531
6291	1	7	35	5	32629
6292	1	7	35	6	34111
6293	1	7	35	1	71864
6294	1	15	35	6	57546
6295	1	15	35	5	37145
6296	1	15	35	6	8987
6297	1	15	35	5	49043
6298	1	15	35	4	43536
6299	1	15	35	1	83908
6300	1	16	35	6	41681
6301	1	16	35	5	34364
6302	1	16	35	6	31189
6303	1	16	35	5	11485
6304	1	16	35	4	58175
6305	1	16	35	1	93079
6306	1	28	35	4	76278
6307	1	28	35	1	192176
6308	1	29	35	5	47208
6309	1	29	35	6	40522
6310	1	29	35	1	397296
6311	1	30	35	4	19534
6312	1	30	35	1	154579
6313	1	31	35	5	14584
6314	1	31	35	6	12868
6315	1	31	35	5	100236
6316	1	31	35	1	227096
6317	1	31	35	1	34208
6318	1	32	35	6	36375
6319	1	32	35	5	11918
6320	1	32	35	6	37432
6321	1	32	35	5	44570
6322	1	32	35	4	96103
6323	1	32	35	1	84296
6324	1	35	35	5	38648
6325	1	35	35	6	17374
6326	1	35	35	5	48451
6327	1	35	35	1	444159
6328	1	35	35	1	78696
6329	1	36	35	5	43409
6330	1	36	35	6	31686
6331	1	36	35	5	88154
6332	1	36	35	1	313829
6333	1	36	35	1	62006
6334	1	37	35	5	42684
6335	1	37	35	6	23189
6336	1	37	35	1	74015
6337	1	38	35	6	66490
6338	1	38	35	5	38636
6339	1	38	35	6	84402
6340	1	38	35	5	37388
6341	1	38	35	4	70873
6342	1	38	35	1	33356
6343	1	39	35	4	149402
6344	1	39	35	6	90994
6345	1	39	35	4	133698
6346	1	39	35	6	136866
6347	1	40	35	1	200873
6348	1	41	35	1	210421
6349	1	42	35	1	349332
6350	1	43	35	4	97076
6351	1	43	35	6	145013
6352	1	45	35	5	122809
6353	1	45	35	4	59256
6354	1	45	35	1	102792
6355	1	45	35	4	34835
6356	1	45	35	1	182534
6357	1	46	35	6	76358
6358	1	46	35	5	2985
6359	1	46	35	5	8924
6360	1	46	35	6	90697
6361	1	46	35	4	233626
6362	1	46	35	1	200629
6363	1	47	35	6	147269
6364	1	47	35	5	29111
6365	1	47	35	5	43944
6366	1	47	35	6	7352
6367	1	47	35	4	224377
6368	1	47	35	1	143968
6369	1	50	35	6	66966
6370	1	50	35	5	16433
6371	1	50	35	6	5463
6372	1	50	35	5	2492
6373	1	50	35	4	21645
6374	1	50	35	1	60352
6375	1	51	35	5	13278
6376	1	51	35	6	100679
6377	1	51	35	1	457507
6378	1	52	35	5	8984
6379	1	52	35	6	25545
6380	1	52	35	5	105277
6381	1	52	35	1	333901
6382	1	52	35	1	98139
6383	1	53	35	5	12099
6384	1	53	35	6	81010
6385	1	53	35	5	73037
6386	1	53	35	1	326244
6387	1	53	35	1	17334
6388	1	54	35	5	16671
6389	1	54	35	6	50722
6390	1	54	35	5	68298
6391	1	54	35	1	430796
6392	1	54	35	1	59577
6393	1	55	35	5	7818
6394	1	55	35	6	83205
6395	1	55	35	5	61643
6396	1	55	35	1	257889
6397	1	55	35	1	78948
6398	1	56	35	5	40732
6399	1	56	35	6	46270
6400	1	56	35	5	99131
6401	1	56	35	1	291419
6402	1	56	35	1	23786
6403	1	57	35	6	85679
6404	1	57	35	5	30905
6405	1	57	35	6	42537
6406	1	57	35	5	12007
6407	1	57	35	4	73716
6408	1	57	35	1	9741
6409	1	58	35	6	81762
6410	1	58	35	5	29057
6411	1	58	35	6	73286
6412	1	58	35	5	16802
6413	1	58	35	4	94470
6414	1	58	35	1	25136
6415	1	59	35	6	120308
6416	1	59	35	5	11660
6417	1	59	35	5	48887
6418	1	59	35	6	80622
6419	1	59	35	4	238043
6420	1	59	35	1	338553
6421	1	60	35	5	45725
6422	1	60	35	6	47730
6423	1	60	35	1	32138
6424	1	1	36	4	149363
6425	1	1	36	6	63165
6426	1	1	36	4	148012
6427	1	1	36	6	57801
6428	1	2	36	5	48835
6429	1	4	36	4	72898
6430	1	4	36	6	116309
6431	1	5	36	4	135691
6432	1	5	36	6	139759
6433	1	5	36	4	55723
6434	1	5	36	6	78680
6435	1	6	36	4	66382
6436	1	6	36	6	136565
6437	1	6	36	4	56021
6438	1	6	36	6	79314
6439	1	7	36	6	50716
6440	1	7	36	5	21929
6441	1	7	36	6	62496
6442	1	7	36	5	58712
6443	1	7	36	4	44900
6444	1	7	36	1	8832
6445	1	15	36	5	12548
6446	1	15	36	6	4575
6447	1	15	36	5	118667
6448	1	15	36	1	441090
6449	1	15	36	1	56237
6450	1	17	36	6	62887
6451	1	17	36	5	34635
6452	1	17	36	6	39174
6453	1	17	36	5	47791
6454	1	17	36	4	74397
6455	1	17	36	1	62301
6456	1	28	36	6	126848
6457	1	28	36	5	42205
6458	1	28	36	5	6636
6459	1	28	36	6	1939
6460	1	28	36	4	221165
6461	1	28	36	1	219543
6462	1	30	36	5	188815
6463	1	30	36	4	27384
6464	1	30	36	1	71723
6465	1	30	36	4	48628
6466	1	30	36	1	141735
6467	1	31	36	5	41552
6468	1	31	36	6	90429
6469	1	31	36	5	105327
6470	1	31	36	1	242042
6471	1	31	36	1	12570
6472	1	32	36	5	32846
6473	1	32	36	6	57150
6474	1	32	36	1	255646
6475	1	33	36	5	12019
6476	1	33	36	6	13439
6477	1	33	36	1	3607
6478	1	34	36	6	59753
6479	1	34	36	5	48555
6480	1	34	36	6	11654
6481	1	34	36	5	35199
6482	1	34	36	4	85330
6483	1	34	36	1	41151
6484	1	39	36	4	10799
6485	1	39	36	1	187510
6486	1	40	36	1	111111
6487	1	41	36	1	348846
6488	1	43	36	4	106476
6489	1	43	36	6	75135
6490	1	44	36	4	53931
6491	1	44	36	6	113513
6492	1	44	36	4	119403
6493	1	44	36	6	55109
6494	1	45	36	5	12649
6495	1	45	36	6	11247
6496	1	45	36	1	61561
6497	1	46	36	5	30754
6498	1	46	36	6	84052
6499	1	46	36	1	60948
6500	1	47	36	5	13312
6501	1	47	36	6	88182
6502	1	47	36	1	323926
6503	1	48	36	4	67231
6504	1	48	36	6	98366
6505	1	48	36	4	99784
6506	1	48	36	6	75089
6507	1	52	36	6	76548
6508	1	52	36	5	9256
6509	1	52	36	6	98597
6510	1	52	36	5	7165
6511	1	52	36	4	27818
6512	1	52	36	1	16852
6513	1	53	36	6	91909
6514	1	53	36	5	47924
6515	1	53	36	6	67303
6516	1	53	36	5	56079
6517	1	53	36	4	81992
6518	1	53	36	1	4193
6519	1	55	36	5	28064
6520	1	55	36	6	35670
6521	1	55	36	1	74113
6522	1	56	36	6	17707
6523	1	56	36	5	26625
6524	1	56	36	6	5937
6525	1	56	36	5	66863
6526	1	56	36	4	13057
6527	1	56	36	1	35244
6528	1	57	36	5	44537
6529	1	57	36	6	39171
6530	1	57	36	1	11719
6531	1	58	36	5	3458
6532	1	58	36	6	29804
6533	1	58	36	1	86414
6534	1	59	36	1	314418
6535	1	60	36	5	16980
6536	1	60	36	6	89889
6537	1	60	36	5	110661
6538	1	60	36	1	321811
6539	1	60	36	1	89234
6540	1	2	37	5	23960
6541	1	3	37	5	88261
6542	1	4	37	4	87205
6543	1	4	37	6	139117
6544	1	4	37	4	55496
6545	1	4	37	6	144036
6546	1	5	37	4	110901
6547	1	5	37	6	86139
6548	1	5	37	4	131054
6549	1	5	37	6	138459
6550	1	6	37	6	92322
6551	1	6	37	5	54052
6552	1	6	37	5	28855
6553	1	6	37	6	49581
6554	1	6	37	4	127023
6555	1	6	37	1	76397
6556	1	7	37	5	30796
6557	1	7	37	6	91328
6558	1	7	37	5	110579
6559	1	7	37	1	231065
6560	1	7	37	1	65960
6561	1	10	37	5	187056
6562	1	10	37	4	18987
6563	1	10	37	1	117001
6564	1	10	37	4	18384
6565	1	10	37	1	148386
6566	1	16	37	5	24678
6567	1	16	37	6	55918
6568	1	16	37	1	88237
6569	1	17	37	1	312160
6570	1	29	37	5	223820
6571	1	29	37	4	90233
6572	1	29	37	1	70973
6573	1	29	37	4	35089
6574	1	29	37	1	96782
6575	1	30	37	6	102408
6576	1	30	37	5	33932
6577	1	30	37	5	16688
6578	1	30	37	6	71236
6579	1	30	37	4	163298
6580	1	30	37	1	308145
6581	1	31	37	5	40355
6582	1	31	37	6	73706
6583	1	31	37	1	184911
6584	1	32	37	5	34318
6585	1	32	37	6	2479
6586	1	32	37	5	50912
6587	1	32	37	1	213838
6588	1	32	37	1	16917
6589	1	33	37	5	45893
6590	1	33	37	6	23091
6591	1	33	37	1	41167
6592	1	34	37	5	43161
6593	1	34	37	6	70917
6594	1	34	37	1	12478
6595	1	35	37	4	128849
6596	1	35	37	6	92772
6597	1	36	37	4	97128
6598	1	36	37	6	135106
6599	1	36	37	4	89065
6600	1	36	37	6	65287
6601	1	37	37	5	7354
6602	1	38	37	5	198149
6603	1	38	37	4	57900
6604	1	38	37	1	73306
6605	1	38	37	4	36783
6606	1	38	37	1	90853
6607	1	39	37	4	65099
6608	1	39	37	1	192514
6609	1	40	37	5	138227
6610	1	40	37	4	34615
6611	1	40	37	1	156903
6612	1	40	37	4	58756
6613	1	40	37	1	142218
6614	1	41	37	1	247952
6615	1	42	37	1	66152
6616	1	43	37	4	74399
6617	1	43	37	6	103108
6618	1	44	37	1	241184
6619	1	45	37	5	40619
6620	1	45	37	6	19374
6621	1	45	37	1	285354
6622	1	46	37	6	142808
6623	1	46	37	5	5127
6624	1	46	37	5	34563
6625	1	46	37	6	41934
6626	1	46	37	4	188900
6627	1	46	37	1	451687
6628	1	47	37	5	9730
6629	1	47	37	6	45442
6630	1	47	37	1	489592
6631	1	48	37	5	12676
6632	1	48	37	6	17248
6633	1	48	37	1	145204
6634	1	49	37	5	47959
6635	1	49	37	6	107977
6636	1	49	37	1	363782
6637	1	51	37	5	137788
6638	1	51	37	4	29857
6639	1	51	37	1	94034
6640	1	51	37	4	53112
6641	1	51	37	1	97810
6642	1	52	37	6	84411
6643	1	52	37	5	34864
6644	1	52	37	6	3001
6645	1	52	37	5	35532
6646	1	52	37	4	18813
6647	1	52	37	1	37979
6648	1	53	37	5	47799
6649	1	53	37	6	84084
6650	1	53	37	1	51011
6651	1	58	37	5	16435
6652	1	58	37	6	91599
6653	1	58	37	5	68836
6654	1	58	37	1	395968
6655	1	58	37	1	4484
6656	1	59	37	5	10805
6657	1	59	37	6	96306
6658	1	59	37	5	76453
6659	1	59	37	1	290250
6660	1	59	37	1	88452
6661	1	60	37	5	37510
6662	1	60	37	6	74349
6663	1	60	37	5	94054
6664	1	60	37	1	345586
6665	1	60	37	1	8278
6666	1	1	38	5	7316
6667	1	2	38	5	30307
6668	1	3	38	5	66106
6669	1	4	38	5	15235
6670	1	5	38	4	85506
6671	1	5	38	6	123260
6672	1	6	38	4	63728
6673	1	6	38	6	128675
6674	1	7	38	5	73643
6675	1	18	38	6	87557
6676	1	18	38	5	43097
6677	1	18	38	6	3658
6678	1	18	38	5	20483
6679	1	18	38	4	82908
6680	1	18	38	1	83827
6681	1	29	38	6	119437
6682	1	29	38	5	66686
6683	1	29	38	5	16527
6684	1	29	38	6	13066
6685	1	29	38	4	142055
6686	1	29	38	1	240051
6687	1	30	38	6	106398
6688	1	30	38	5	40012
6689	1	30	38	5	5838
6690	1	30	38	6	33362
6691	1	30	38	4	101861
6692	1	30	38	1	369692
6693	1	31	38	4	72893
6694	1	31	38	6	120251
6695	1	32	38	5	10185
6696	1	32	38	6	79376
6697	1	32	38	5	43153
6698	1	32	38	1	240192
6699	1	32	38	1	71781
6700	1	34	38	5	10208
6701	1	34	38	6	61650
6702	1	34	38	1	64842
6703	1	35	38	5	28427
6704	1	35	38	6	50383
6705	1	35	38	5	114717
6706	1	35	38	1	278829
6707	1	35	38	1	8924
6708	1	36	38	4	60655
6709	1	36	38	6	103518
6710	1	37	38	5	1578
6711	1	38	38	4	46466
6712	1	38	38	1	115233
6713	1	39	38	5	117424
6714	1	39	38	4	67143
6715	1	39	38	1	105046
6716	1	39	38	4	24801
6717	1	39	38	1	147927
6718	1	40	38	5	274429
6719	1	40	38	4	21661
6720	1	40	38	1	86199
6721	1	40	38	4	48018
6722	1	40	38	1	74305
6723	1	41	38	1	318212
6724	1	42	38	1	109234
6725	1	43	38	6	99339
6726	1	43	38	5	18323
6727	1	43	38	5	49074
6728	1	43	38	6	37289
6729	1	43	38	4	286039
6730	1	43	38	1	342344
6731	1	45	38	6	144997
6732	1	45	38	5	19914
6733	1	45	38	5	42320
6734	1	45	38	6	23538
6735	1	45	38	4	107260
6736	1	45	38	1	271286
6737	1	46	38	6	82941
6738	1	46	38	5	37894
6739	1	46	38	5	49078
6740	1	46	38	6	58218
6741	1	46	38	4	286185
6742	1	46	38	1	397719
6743	1	47	38	6	101214
6744	1	47	38	5	54927
6745	1	47	38	5	47204
6746	1	47	38	6	55249
6747	1	47	38	4	279007
6748	1	47	38	1	536039
6749	1	48	38	6	119311
6750	1	48	38	5	27677
6751	1	48	38	5	35334
6752	1	48	38	6	68221
6753	1	48	38	4	226212
6754	1	48	38	1	308360
6755	1	49	38	6	81551
6756	1	49	38	5	16590
6757	1	49	38	5	8486
6758	1	49	38	6	69722
6759	1	49	38	4	276416
6760	1	49	38	1	79959
6761	1	52	38	5	48827
6762	1	52	38	6	87044
6763	1	52	38	1	94239
6764	1	53	38	6	94755
6765	1	53	38	5	30148
6766	1	53	38	6	68228
6767	1	53	38	5	5930
6768	1	53	38	4	71636
6769	1	53	38	1	90090
6770	1	55	38	5	46567
6771	1	55	38	6	18144
6772	1	55	38	5	117997
6773	1	55	38	1	456464
6774	1	55	38	1	9781
6775	1	56	38	5	36540
6776	1	56	38	6	65969
6777	1	56	38	5	51112
6778	1	56	38	1	341520
6779	1	56	38	1	46536
6780	1	58	38	5	28396
6781	1	58	38	6	55454
6782	1	58	38	5	90090
6783	1	58	38	1	300409
6784	1	58	38	1	80922
6785	1	59	38	5	2739
6786	1	59	38	6	68668
6787	1	59	38	1	51092
6788	1	60	38	5	60154
6789	1	1	39	5	15846
6790	1	2	39	5	53409
6791	1	3	39	5	13129
6792	1	4	39	5	2174
6793	1	5	39	5	77188
6794	1	6	39	5	81184
6795	1	18	39	5	32448
6796	1	18	39	6	39000
6797	1	18	39	5	65553
6798	1	18	39	1	388607
6799	1	18	39	1	81310
6800	1	19	39	5	36600
6801	1	19	39	6	86941
6802	1	19	39	5	62713
6803	1	19	39	1	381091
6804	1	19	39	1	87402
6805	1	29	39	6	82270
6806	1	29	39	5	66819
6807	1	29	39	5	43934
6808	1	29	39	6	66069
6809	1	29	39	4	298471
6810	1	29	39	1	131568
6811	1	30	39	5	16142
6812	1	30	39	6	59702
6813	1	30	39	1	528422
6814	1	31	39	6	102415
6815	1	31	39	5	33637
6816	1	31	39	5	47063
6817	1	31	39	6	5991
6818	1	31	39	4	148195
6819	1	31	39	1	223261
6820	1	32	39	5	4607
6821	1	32	39	6	43702
6822	1	32	39	1	37442
6823	1	34	39	5	15538
6824	1	34	39	6	43016
6825	1	34	39	1	66830
6826	1	35	39	5	37778
6827	1	35	39	6	46368
6828	1	35	39	1	41358
6829	1	36	39	6	50489
6830	1	36	39	5	46410
6831	1	36	39	6	22933
6832	1	36	39	5	44790
6833	1	36	39	4	89239
6834	1	36	39	1	69682
6835	1	37	39	5	27703
6836	1	37	39	6	55712
6837	1	37	39	5	73711
6838	1	37	39	1	338488
6839	1	37	39	1	11829
6840	1	38	39	5	289470
6841	1	38	39	4	12757
6842	1	38	39	1	181462
6843	1	38	39	4	61760
6844	1	38	39	1	126592
6845	1	39	39	4	59970
6846	1	39	39	1	76888
6847	1	40	39	5	214342
6848	1	40	39	4	10044
6849	1	40	39	1	123872
6850	1	40	39	4	17627
6851	1	40	39	1	111242
6852	1	41	39	5	8284
6853	1	41	39	6	74592
6854	1	41	39	5	82576
6855	1	41	39	1	332026
6856	1	41	39	1	62039
6857	1	42	39	6	49795
6858	1	42	39	5	33555
6859	1	42	39	6	27778
6860	1	42	39	5	54565
6861	1	42	39	4	99199
6862	1	42	39	1	18266
6863	1	43	39	5	42840
6864	1	43	39	6	81727
6865	1	43	39	5	41053
6866	1	43	39	1	463750
6867	1	43	39	1	43078
6868	1	44	39	5	33709
6869	1	44	39	6	59489
6870	1	44	39	1	563018
6871	1	45	39	5	32634
6872	1	45	39	6	126972
6873	1	45	39	1	91696
6874	1	46	39	6	55560
6875	1	46	39	5	65066
6876	1	46	39	5	19326
6877	1	46	39	6	108914
6878	1	46	39	4	224529
6879	1	46	39	1	124952
6880	1	47	39	5	33975
6881	1	47	39	6	40841
6882	1	47	39	1	262144
6883	1	48	39	5	275519
6884	1	48	39	4	91868
6885	1	48	39	1	93938
6886	1	48	39	4	38253
6887	1	48	39	1	183048
6888	1	49	39	6	86880
6889	1	49	39	5	21735
6890	1	49	39	5	2538
6891	1	49	39	6	143125
6892	1	49	39	4	247132
6893	1	49	39	1	193195
6894	1	50	39	5	33804
6895	1	50	39	6	122709
6896	1	50	39	1	272743
6897	1	57	39	6	17594
6898	1	57	39	5	25024
6899	1	57	39	6	24287
6900	1	57	39	5	10565
6901	1	57	39	4	49078
6902	1	57	39	1	6322
6903	1	58	39	5	11870
6904	1	58	39	6	49752
6905	1	58	39	5	79524
6906	1	58	39	1	456693
6907	1	58	39	1	80382
6908	1	59	39	5	43142
6909	1	59	39	6	44256
6910	1	59	39	1	49723
6911	1	60	39	5	36128
6912	1	60	39	6	62757
6913	1	60	39	1	70119
6914	1	1	40	5	28859
6915	1	1	40	6	93555
6916	1	1	40	1	51493
6917	1	2	40	1	197186
6918	1	3	40	5	97881
6919	1	4	40	5	73760
6920	1	18	40	5	31132
6921	1	18	40	6	99488
6922	1	18	40	1	7397
6923	1	30	40	6	86321
6924	1	30	40	5	25598
6925	1	30	40	5	32095
6926	1	30	40	6	10661
6927	1	30	40	4	153410
6928	1	30	40	1	309961
6929	1	31	40	6	58202
6930	1	31	40	5	45045
6931	1	31	40	5	22582
6932	1	31	40	6	92584
6933	1	31	40	4	227914
6934	1	31	40	1	464231
6935	1	33	40	5	42594
6936	1	33	40	6	24016
6937	1	33	40	1	57812
6938	1	34	40	5	20333
6939	1	34	40	6	99582
6940	1	34	40	1	18640
6941	1	35	40	6	7449
6942	1	35	40	5	40345
6943	1	35	40	6	90188
6944	1	35	40	5	11719
6945	1	35	40	4	16708
6946	1	35	40	1	26987
6947	1	36	40	5	34562
6948	1	36	40	6	97142
6949	1	36	40	1	53940
6950	1	37	40	6	81991
6951	1	37	40	5	17352
6952	1	37	40	6	18572
6953	1	37	40	5	29153
6954	1	37	40	4	55639
6955	1	37	40	1	72324
6956	1	38	40	6	26075
6957	1	38	40	5	9720
6958	1	38	40	6	6465
6959	1	38	40	5	60002
6960	1	38	40	4	50755
6961	1	38	40	1	78227
6962	1	39	40	5	140412
6963	1	39	40	4	41276
6964	1	39	40	1	128631
6965	1	39	40	4	74463
6966	1	39	40	1	141419
6967	1	40	40	5	137305
6968	1	40	40	4	2065
6969	1	40	40	1	152802
6970	1	40	40	4	44433
6971	1	40	40	1	99232
6972	1	41	40	5	24027
6973	1	41	40	6	71220
6974	1	41	40	5	99058
6975	1	41	40	1	259619
6976	1	41	40	1	54303
6977	1	42	40	6	65812
6978	1	42	40	5	16797
6979	1	42	40	6	3185
6980	1	42	40	5	63091
6981	1	42	40	4	51654
6982	1	42	40	1	49627
6983	1	43	40	6	64729
6984	1	43	40	5	29626
6985	1	43	40	5	3711
6986	1	43	40	6	109468
6987	1	43	40	4	253282
6988	1	43	40	1	181726
6989	1	44	40	6	80692
6990	1	44	40	5	13453
6991	1	44	40	5	16050
6992	1	44	40	6	35249
6993	1	44	40	4	267698
6994	1	44	40	1	225371
6995	1	45	40	6	108555
6996	1	45	40	5	39208
6997	1	45	40	5	4313
6998	1	45	40	6	106636
6999	1	45	40	4	255631
7000	1	45	40	1	518683
7001	1	46	40	6	128025
7002	1	46	40	5	21475
7003	1	46	40	5	1500
7004	1	46	40	6	80451
7005	1	46	40	4	119675
7006	1	46	40	1	355318
7007	1	47	40	6	87116
7008	1	47	40	5	36206
7009	1	47	40	6	38575
7010	1	47	40	5	30162
7011	1	47	40	4	78841
7012	1	47	40	1	91242
7013	1	48	40	5	23240
7014	1	48	40	6	145072
7015	1	48	40	1	590020
7016	1	50	40	5	6751
7017	1	54	40	4	136289
7018	1	54	40	6	69888
7019	1	54	40	4	139814
7020	1	54	40	6	132943
7021	1	56	40	1	322381
7022	1	57	40	6	58390
7023	1	57	40	5	49165
7024	1	57	40	6	31481
7025	1	57	40	5	6359
7026	1	57	40	4	14897
7027	1	57	40	1	16284
7028	1	58	40	6	57574
7029	1	58	40	5	39214
7030	1	58	40	6	87435
7031	1	58	40	5	5960
7032	1	58	40	4	93963
7033	1	58	40	1	15163
7034	1	59	40	5	40176
7035	1	59	40	6	94700
7036	1	59	40	5	96567
7037	1	59	40	1	217651
7038	1	59	40	1	96927
7039	1	1	41	5	27153
7040	1	1	41	6	2035
7041	1	1	41	5	117468
7042	1	1	41	1	371594
7043	1	1	41	1	37340
7044	1	2	41	5	44860
7045	1	2	41	6	5650
7046	1	2	41	5	85080
7047	1	2	41	1	285633
7048	1	2	41	1	10122
7049	1	3	41	5	249699
7050	1	3	41	4	91407
7051	1	3	41	1	127503
7052	1	3	41	4	5055
7053	1	3	41	1	177432
7054	1	4	41	5	93138
7055	1	14	41	5	40151
7056	1	14	41	6	82898
7057	1	14	41	5	61877
7058	1	14	41	1	204518
7059	1	14	41	1	99890
7060	1	30	41	6	83943
7061	1	30	41	5	43022
7062	1	30	41	5	15809
7063	1	30	41	6	98280
7064	1	30	41	4	130083
7065	1	30	41	1	450255
7066	1	31	41	6	141773
7067	1	31	41	5	62144
7068	1	31	41	5	40186
7069	1	31	41	6	45125
7070	1	31	41	4	144145
7071	1	31	41	1	126482
7072	1	32	41	5	3693
7073	1	32	41	6	139268
7074	1	32	41	1	298593
7075	1	35	41	6	76131
7076	1	35	41	5	32238
7077	1	35	41	6	84453
7078	1	35	41	5	60116
7079	1	35	41	4	38750
7080	1	35	41	1	93175
7081	1	36	41	1	115028
7082	1	37	41	5	37582
7083	1	37	41	6	25763
7084	1	37	41	1	4159
7085	1	38	41	6	26800
7086	1	38	41	5	12667
7087	1	38	41	6	12584
7088	1	38	41	5	45372
7089	1	38	41	4	29462
7090	1	38	41	1	82781
7091	1	39	41	5	33141
7092	1	39	41	6	51972
7093	1	39	41	1	71396
7094	1	40	41	5	21006
7095	1	41	41	4	114965
7096	1	41	41	6	98281
7097	1	42	41	5	12096
7098	1	42	41	6	74339
7099	1	42	41	1	98526
7100	1	43	41	5	44637
7101	1	43	41	6	14137
7102	1	43	41	5	55411
7103	1	43	41	1	316051
7104	1	43	41	1	94671
7105	1	44	41	5	5172
7106	1	44	41	6	47259
7107	1	44	41	1	363733
7108	1	45	41	6	62135
7109	1	45	41	5	18918
7110	1	45	41	5	37027
7111	1	45	41	6	75495
7112	1	45	41	4	261124
7113	1	45	41	1	490747
7114	1	46	41	6	91321
7115	1	46	41	5	20026
7116	1	46	41	5	38447
7117	1	46	41	6	33306
7118	1	46	41	4	127721
7119	1	46	41	1	379141
7120	1	47	41	5	18918
7121	1	47	41	6	144040
7122	1	47	41	1	208740
7123	1	48	41	6	109809
7124	1	48	41	5	2133
7125	1	48	41	5	39738
7126	1	48	41	6	133807
7127	1	48	41	4	251843
7128	1	48	41	1	329307
7129	1	49	41	5	15421
7130	1	49	41	6	22247
7131	1	49	41	5	116059
7132	1	49	41	1	223436
7133	1	49	41	1	14532
7134	1	50	41	1	178549
7135	1	54	41	4	57534
7136	1	54	41	6	134641
7137	1	54	41	4	136081
7138	1	54	41	6	115046
7139	1	56	41	5	26620
7140	1	56	41	6	47364
7141	1	56	41	1	86246
7142	1	57	41	5	260804
7143	1	57	41	4	51684
7144	1	57	41	1	147044
7145	1	57	41	4	30070
7146	1	57	41	1	195818
7147	1	58	41	6	2118
7148	1	58	41	5	3498
7149	1	58	41	6	45486
7150	1	58	41	5	3965
7151	1	58	41	4	59127
7152	1	58	41	1	37057
7153	1	59	41	6	51927
7154	1	59	41	5	34296
7155	1	59	41	6	22154
7156	1	59	41	5	39715
7157	1	59	41	4	94602
7158	1	59	41	1	35355
7159	1	60	41	5	34154
7160	1	60	41	6	26724
7161	1	60	41	5	107548
7162	1	60	41	1	228382
7163	1	60	41	1	70146
7164	1	1	42	5	18899
7165	1	1	42	6	32205
7166	1	1	42	5	89846
7167	1	1	42	1	432622
7168	1	1	42	1	47705
7169	1	2	42	6	79026
7170	1	2	42	5	34247
7171	1	2	42	6	44071
7172	1	2	42	5	22835
7173	1	2	42	4	5558
7174	1	2	42	1	36355
7175	1	3	42	4	132611
7176	1	3	42	6	127082
7177	1	3	42	4	139357
7178	1	3	42	6	65486
7179	1	20	42	5	106513
7180	1	20	42	4	87394
7181	1	20	42	1	118611
7182	1	20	42	4	3679
7183	1	20	42	1	138646
7184	1	31	42	6	104001
7185	1	31	42	5	30937
7186	1	31	42	5	48405
7187	1	31	42	6	147564
7188	1	31	42	4	223946
7189	1	31	42	1	313687
7190	1	32	42	6	86046
7191	1	32	42	5	42132
7192	1	32	42	5	3031
7193	1	32	42	6	132224
7194	1	32	42	4	164172
7195	1	32	42	1	439698
7196	1	33	42	5	22954
7197	1	34	42	5	35888
7198	1	34	42	6	38319
7199	1	34	42	5	91166
7200	1	34	42	1	307003
7201	1	34	42	1	60320
7202	1	36	42	6	56717
7203	1	36	42	5	13323
7204	1	36	42	6	13025
7205	1	36	42	5	6846
7206	1	36	42	4	19322
7207	1	36	42	1	39728
7208	1	37	42	5	18819
7209	1	37	42	6	98433
7210	1	37	42	1	57943
7211	1	38	42	6	26903
7212	1	38	42	5	48418
7213	1	38	42	6	15238
7214	1	38	42	5	68123
7215	1	38	42	4	32349
7216	1	38	42	1	3525
7217	1	39	42	5	9133
7218	1	39	42	6	48191
7219	1	39	42	1	36429
7220	1	40	42	4	135667
7221	1	40	42	6	118797
7222	1	41	42	4	95370
7223	1	41	42	6	85511
7224	1	41	42	4	70600
7225	1	41	42	6	53620
7226	1	44	42	5	13278
7227	1	44	42	6	54280
7228	1	44	42	1	179809
7229	1	45	42	6	120679
7230	1	45	42	5	52907
7231	1	45	42	5	7027
7232	1	45	42	6	40265
7233	1	45	42	4	262416
7234	1	45	42	1	162874
7235	1	46	42	5	34129
7236	1	46	42	6	148823
7237	1	46	42	1	255037
7238	1	47	42	5	36345
7239	1	47	42	6	120412
7240	1	47	42	1	178534
7241	1	48	42	6	127624
7242	1	48	42	5	1806
7243	1	48	42	5	34627
7244	1	48	42	6	80350
7245	1	48	42	4	261258
7246	1	48	42	1	397724
7247	1	49	42	6	52782
7248	1	49	42	5	4450
7249	1	49	42	5	23908
7250	1	49	42	6	134029
7251	1	49	42	4	161124
7252	1	49	42	1	394362
7253	1	50	42	6	9653
7254	1	50	42	5	31672
7255	1	50	42	6	85947
7256	1	50	42	5	20321
7257	1	50	42	4	86144
7258	1	50	42	1	73457
7259	1	53	42	5	70008
7260	1	54	42	5	9723
7261	1	55	42	6	91366
7262	1	55	42	5	9788
7263	1	55	42	5	35784
7264	1	55	42	6	64861
7265	1	55	42	4	284273
7266	1	55	42	1	505030
7267	1	56	42	5	45058
7268	1	56	42	6	55321
7269	1	56	42	1	44349
7270	1	57	42	6	97364
7271	1	57	42	5	49221
7272	1	57	42	6	85518
7273	1	57	42	5	33782
7274	1	57	42	4	99203
7275	1	57	42	1	70573
7276	1	58	42	6	44722
7277	1	58	42	5	18307
7278	1	58	42	6	50804
7279	1	58	42	5	11518
7280	1	58	42	4	81666
7281	1	58	42	1	48422
7282	1	59	42	5	2531
7283	1	59	42	6	22332
7284	1	59	42	5	52886
7285	1	59	42	1	495622
7286	1	59	42	1	40140
7287	1	1	43	6	6275
7288	1	1	43	5	23106
7289	1	1	43	6	38697
7290	1	1	43	5	30495
7291	1	1	43	4	32981
7292	1	1	43	1	75300
7293	1	2	43	5	25755
7294	1	2	43	6	35786
7295	1	2	43	5	110219
7296	1	2	43	1	271967
7297	1	2	43	1	92751
7298	1	3	43	6	76230
7299	1	3	43	5	10761
7300	1	3	43	6	4224
7301	1	3	43	5	39846
7302	1	3	43	4	19383
7303	1	3	43	1	94368
7304	1	4	43	5	33149
7305	1	4	43	6	16783
7306	1	4	43	1	98932
7307	1	34	43	6	76657
7308	1	34	43	5	36298
7309	1	34	43	6	53139
7310	1	34	43	5	35662
7311	1	34	43	4	44898
7312	1	34	43	1	69597
7313	1	35	43	5	15386
7314	1	35	43	6	71216
7315	1	35	43	5	70584
7316	1	35	43	1	468924
7317	1	35	43	1	3065
7318	1	38	43	5	28418
7319	1	38	43	6	94586
7320	1	38	43	5	58456
7321	1	38	43	1	378098
7322	1	38	43	1	54823
7323	1	39	43	4	117060
7324	1	39	43	6	114673
7325	1	39	43	4	61321
7326	1	39	43	6	107884
7327	1	40	43	4	124864
7328	1	40	43	6	84235
7329	1	41	43	4	132060
7330	1	41	43	6	119918
7331	1	44	43	5	37564
7332	1	44	43	6	37966
7333	1	44	43	1	351959
7334	1	45	43	6	100180
7335	1	45	43	5	41342
7336	1	45	43	5	10978
7337	1	45	43	6	143095
7338	1	45	43	4	272258
7339	1	45	43	1	162574
7340	1	46	43	5	31412
7341	1	46	43	6	82630
7342	1	46	43	1	588047
7343	1	47	43	5	47880
7344	1	47	43	6	8740
7345	1	47	43	1	116892
7346	1	48	43	1	117249
7347	1	49	43	6	130437
7348	1	49	43	5	37524
7349	1	49	43	5	40850
7350	1	49	43	6	47357
7351	1	49	43	4	118118
7352	1	49	43	1	465665
7353	1	50	43	6	90716
7354	1	50	43	5	54443
7355	1	50	43	5	10660
7356	1	50	43	6	114620
7357	1	50	43	4	239875
7358	1	50	43	1	423502
7359	1	51	43	5	32254
7360	1	51	43	6	51172
7361	1	51	43	1	86429
7362	1	52	43	5	5488
7363	1	52	43	6	55386
7364	1	52	43	1	40591
7365	1	53	43	5	95099
7366	1	54	43	5	76438
7367	1	55	43	5	7411
7368	1	56	43	5	39137
7369	1	56	43	6	43037
7370	1	56	43	1	86448
7371	1	57	43	5	23693
7372	1	57	43	6	39660
7373	1	57	43	1	58797
7374	1	58	43	5	263853
7375	1	58	43	4	30979
7376	1	58	43	1	87851
7377	1	58	43	4	88085
7378	1	58	43	1	94112
7379	1	59	43	5	42292
7380	1	59	43	6	9246
7381	1	59	43	1	54796
7382	1	60	43	5	46093
7383	1	60	43	6	62823
7384	1	60	43	5	83585
7385	1	60	43	1	454272
7386	1	60	43	1	86651
7387	1	1	44	4	54378
7388	1	1	44	6	125075
7389	1	1	44	4	70024
7390	1	1	44	6	140654
7391	1	26	44	6	43574
7392	1	26	44	5	23322
7393	1	26	44	6	95548
7394	1	26	44	5	59531
7395	1	26	44	4	81414
7396	1	26	44	1	70993
7397	1	34	44	6	57639
7398	1	34	44	5	15465
7399	1	34	44	6	84264
7400	1	34	44	5	18046
7401	1	34	44	4	56659
7402	1	34	44	1	46643
7403	1	35	44	5	43457
7404	1	35	44	6	52541
7405	1	35	44	5	118469
7406	1	35	44	1	378788
7407	1	35	44	1	95948
7408	1	36	44	5	40377
7409	1	36	44	6	77990
7410	1	36	44	1	45502
7411	1	41	44	4	80687
7412	1	41	44	6	53151
7413	1	41	44	4	64623
7414	1	41	44	6	117825
7415	1	42	44	4	135535
7416	1	42	44	6	149379
7417	1	42	44	4	63860
7418	1	42	44	6	61117
7419	1	43	44	6	92024
7420	1	43	44	5	7821
7421	1	43	44	5	26008
7422	1	43	44	6	19063
7423	1	43	44	4	114863
7424	1	43	44	1	462229
7425	1	44	44	5	82271
7426	1	45	44	6	63709
7427	1	45	44	5	6341
7428	1	45	44	5	36980
7429	1	45	44	6	32199
7430	1	45	44	4	297939
7431	1	45	44	1	266097
7432	1	48	44	5	124568
7433	1	48	44	4	39968
7434	1	48	44	1	189724
7435	1	48	44	4	60791
7436	1	48	44	1	150805
7437	1	49	44	5	35881
7438	1	49	44	6	138537
7439	1	49	44	1	281227
7440	1	50	44	5	37634
7441	1	50	44	6	102652
7442	1	50	44	1	594323
7443	1	51	44	5	15445
7444	1	51	44	6	48664
7445	1	51	44	1	91450
7446	1	52	44	6	31741
7447	1	52	44	5	19391
7448	1	52	44	6	69224
7449	1	52	44	5	40044
7450	1	52	44	4	49625
7451	1	52	44	1	97259
7452	1	53	44	6	26034
7453	1	53	44	5	35007
7454	1	53	44	6	59937
7455	1	53	44	5	64801
7456	1	53	44	4	72617
7457	1	53	44	1	49911
7458	1	54	44	5	82381
7459	1	55	44	5	81192
7460	1	56	44	6	53418
7461	1	56	44	5	26356
7462	1	56	44	6	2256
7463	1	56	44	5	43246
7464	1	56	44	4	49773
7465	1	56	44	1	70148
7466	1	57	44	5	95069
7467	1	58	44	5	14830
7468	1	58	44	6	25976
7469	1	58	44	1	44813
7470	1	59	44	6	84585
7471	1	59	44	5	35482
7472	1	59	44	6	78065
7473	1	59	44	5	41988
7474	1	59	44	4	11030
7475	1	59	44	1	55386
7476	1	60	44	6	74048
7477	1	60	44	5	5423
7478	1	60	44	6	35592
7479	1	60	44	5	58123
7480	1	60	44	4	16305
7481	1	60	44	1	25577
7482	1	1	45	4	134446
7483	1	1	45	6	97830
7484	1	2	45	4	84575
7485	1	2	45	6	105384
7486	1	36	45	5	93838
7487	1	37	45	5	32900
7488	1	37	45	6	49690
7489	1	37	45	5	58654
7490	1	37	45	1	261092
7491	1	37	45	1	32415
7492	1	41	45	4	59148
7493	1	41	45	6	72744
7494	1	43	45	6	86467
7495	1	43	45	5	50056
7496	1	43	45	5	10337
7497	1	43	45	6	9214
7498	1	43	45	4	168325
7499	1	43	45	1	474387
7500	1	44	45	5	1193
7501	1	44	45	6	62497
7502	1	44	45	1	313198
7503	1	45	45	6	144586
7504	1	45	45	5	9834
7505	1	45	45	5	25696
7506	1	45	45	6	6587
7507	1	45	45	4	128026
7508	1	45	45	1	131437
7509	1	46	45	6	46076
7510	1	46	45	5	44722
7511	1	46	45	6	82232
7512	1	46	45	5	50911
7513	1	46	45	4	23985
7514	1	46	45	1	44288
7515	1	47	45	6	1733
7516	1	47	45	5	15346
7517	1	47	45	6	34950
7518	1	47	45	5	5861
7519	1	47	45	4	95303
7520	1	47	45	1	37374
7521	1	48	45	5	46199
7522	1	49	45	6	97520
7523	1	49	45	5	61244
7524	1	49	45	5	30325
7525	1	49	45	6	92700
7526	1	49	45	4	154657
7527	1	49	45	1	549151
7528	1	50	45	5	4019
7529	1	50	45	6	21006
7530	1	50	45	1	395863
7531	1	51	45	5	47510
7532	1	51	45	6	41586
7533	1	51	45	5	63171
7534	1	51	45	1	482063
7535	1	51	45	1	61682
7536	1	52	45	1	124926
7537	1	53	45	6	41139
7538	1	53	45	5	19873
7539	1	53	45	6	54072
7540	1	53	45	5	36331
7541	1	53	45	4	9924
7542	1	53	45	1	47766
7543	1	54	45	6	79681
7544	1	54	45	5	17492
7545	1	54	45	6	29092
7546	1	54	45	5	38365
7547	1	54	45	4	90996
7548	1	54	45	1	11396
7549	1	55	45	5	43654
7550	1	55	45	6	67915
7551	1	55	45	5	88670
7552	1	55	45	1	237764
7553	1	55	45	1	58179
7554	1	56	45	5	36709
7555	1	56	45	6	49820
7556	1	56	45	1	54161
7557	1	58	45	5	15722
7558	1	58	45	6	70974
7559	1	58	45	1	31497
7560	1	59	45	5	41467
7561	1	59	45	6	91662
7562	1	59	45	1	39371
7563	1	60	45	6	52616
7564	1	60	45	5	10438
7565	1	60	45	6	78397
7566	1	60	45	5	65160
7567	1	60	45	4	96263
7568	1	60	45	1	87433
7569	1	1	46	4	80370
7570	1	1	46	6	120809
7571	1	1	46	4	69305
7572	1	1	46	6	125559
7573	1	36	46	6	15263
7574	1	36	46	5	4478
7575	1	36	46	6	13458
7576	1	36	46	5	53721
7577	1	36	46	4	87352
7578	1	36	46	1	69206
7579	1	37	46	5	25430
7580	1	37	46	6	44553
7581	1	37	46	5	62559
7582	1	37	46	1	238455
7583	1	37	46	1	4357
7584	1	38	46	6	82707
7585	1	38	46	5	1614
7586	1	38	46	6	66353
7587	1	38	46	5	18181
7588	1	38	46	4	29206
7589	1	38	46	1	55073
7590	1	41	46	4	121641
7591	1	41	46	6	107435
7592	1	41	46	4	127853
7593	1	41	46	6	118846
7594	1	45	46	6	106941
7595	1	45	46	5	40144
7596	1	45	46	5	40593
7597	1	45	46	6	69300
7598	1	45	46	4	176020
7599	1	45	46	1	389944
7600	1	46	46	6	14418
7601	1	46	46	5	26858
7602	1	46	46	6	21174
7603	1	46	46	5	34603
7604	1	46	46	4	23327
7605	1	46	46	1	48526
7606	1	47	46	4	113902
7607	1	47	46	6	93682
7608	1	50	46	5	40647
7609	1	51	46	5	70802
7610	1	52	46	6	76390
7611	1	52	46	5	38421
7612	1	52	46	6	68302
7613	1	52	46	5	42943
7614	1	52	46	4	24196
7615	1	52	46	1	51848
7616	1	53	46	5	8828
7617	1	53	46	6	34543
7618	1	53	46	5	44623
7619	1	53	46	1	307115
7620	1	53	46	1	27562
7621	1	54	46	5	21390
7622	1	54	46	6	73700
7623	1	54	46	5	79882
7624	1	54	46	1	298404
7625	1	54	46	1	41283
7626	1	55	46	5	43564
7627	1	55	46	6	60850
7628	1	55	46	5	56745
7629	1	55	46	1	470644
7630	1	55	46	1	93390
7631	1	56	46	5	13936
7632	1	56	46	6	61501
7633	1	56	46	1	16319
7634	1	57	46	1	398433
7635	1	58	46	5	30934
7636	1	58	46	6	87184
7637	1	58	46	1	31600
7638	1	59	46	6	47024
7639	1	59	46	5	31865
7640	1	59	46	6	11733
7641	1	59	46	5	61025
7642	1	59	46	4	31653
7643	1	59	46	1	6740
7644	1	1	47	4	141741
7645	1	1	47	6	123008
7646	1	13	47	1	306372
7647	1	29	47	1	295728
7648	1	37	47	5	37167
7649	1	37	47	6	70540
7650	1	37	47	1	24907
7651	1	38	47	5	24096
7652	1	38	47	6	76335
7653	1	38	47	1	26360
7654	1	41	47	4	90458
7655	1	41	47	6	55708
7656	1	41	47	4	66406
7657	1	41	47	6	115833
7658	1	43	47	5	22428
7659	1	45	47	5	10768
7660	1	45	47	6	82385
7661	1	45	47	5	70750
7662	1	45	47	1	271221
7663	1	45	47	1	28450
7664	1	46	47	5	258034
7665	1	46	47	4	55857
7666	1	46	47	1	115540
7667	1	46	47	4	81591
7668	1	46	47	1	199340
7669	1	47	47	6	91680
7670	1	47	47	5	22602
7671	1	47	47	6	46905
7672	1	47	47	5	57013
7673	1	47	47	4	78612
7674	1	47	47	1	26830
7675	1	48	47	5	36594
7676	1	48	47	6	39699
7677	1	48	47	5	107974
7678	1	48	47	1	434555
7679	1	48	47	1	44902
7680	1	51	47	5	65787
7681	1	52	47	6	92581
7682	1	52	47	5	15936
7683	1	52	47	6	25027
7684	1	52	47	5	39811
7685	1	52	47	4	45064
7686	1	52	47	1	16994
7687	1	53	47	6	125505
7688	1	53	47	5	22820
7689	1	53	47	5	20188
7690	1	53	47	6	55844
7691	1	53	47	4	157195
7692	1	53	47	1	68875
7693	1	54	47	6	31559
7694	1	54	47	5	33209
7695	1	54	47	6	48622
7696	1	54	47	5	59618
7697	1	54	47	4	73571
7698	1	54	47	1	53115
7699	1	55	47	5	14543
7700	1	55	47	6	68803
7701	1	55	47	5	76744
7702	1	55	47	1	229786
7703	1	55	47	1	53904
7704	1	56	47	5	20615
7705	1	56	47	6	57549
7706	1	56	47	1	98493
7707	1	57	47	5	41896
7708	1	57	47	6	70599
7709	1	57	47	1	47767
7710	1	59	47	6	64031
7711	1	59	47	5	47084
7712	1	59	47	6	97786
7713	1	59	47	5	68950
7714	1	59	47	4	11682
7715	1	59	47	1	56670
7716	1	1	48	4	90050
7717	1	1	48	6	92918
7718	1	42	48	5	56410
7719	1	43	48	5	93782
7720	1	46	48	5	2786
7721	1	46	48	6	20874
7722	1	46	48	5	99296
7723	1	46	48	1	433445
7724	1	46	48	1	2120
7725	1	47	48	5	1860
7726	1	47	48	6	30862
7727	1	47	48	5	97131
7728	1	47	48	1	217273
7729	1	47	48	1	8239
7730	1	48	48	5	29964
7731	1	48	48	6	43236
7732	1	48	48	1	95627
7733	1	49	48	6	123124
7734	1	49	48	5	3568
7735	1	49	48	5	13547
7736	1	49	48	6	54777
7737	1	49	48	4	107646
7738	1	49	48	1	489185
7739	1	50	48	6	126265
7740	1	50	48	5	19657
7741	1	50	48	5	6434
7742	1	50	48	6	140068
7743	1	50	48	4	109640
7744	1	50	48	1	441706
7745	1	51	48	6	22623
7746	1	51	48	5	21282
7747	1	51	48	6	47169
7748	1	51	48	5	30871
7749	1	51	48	4	10140
7750	1	51	48	1	34017
7751	1	52	48	5	37137
7752	1	52	48	6	79955
7753	1	52	48	5	116312
7754	1	52	48	1	449390
7755	1	52	48	1	38039
7756	1	53	48	5	33160
7757	1	53	48	6	57380
7758	1	53	48	1	6465
7759	1	54	48	5	9366
7760	1	54	48	6	61639
7761	1	54	48	1	67890
7762	1	55	48	6	23168
7763	1	55	48	5	44511
7764	1	55	48	6	11777
7765	1	55	48	5	5124
7766	1	55	48	4	58417
7767	1	55	48	1	29303
7768	1	56	48	5	9781
7769	1	56	48	6	88846
7770	1	56	48	5	81469
7771	1	56	48	1	217034
7772	1	56	48	1	83709
7773	1	57	48	5	14166
7774	1	57	48	6	2806
7775	1	57	48	1	8075
7776	1	60	48	6	20863
7777	1	60	48	5	44512
7778	1	60	48	6	82866
7779	1	60	48	5	42374
7780	1	60	48	4	89125
7781	1	60	48	1	21224
7782	1	1	49	4	106538
7783	1	1	49	6	75248
7784	1	1	49	4	106774
7785	1	1	49	6	124591
7786	1	2	49	4	64444
7787	1	2	49	6	118905
7788	1	2	49	4	119009
7789	1	2	49	6	136107
7790	1	43	49	5	49176
7791	1	45	49	5	3750
7792	1	45	49	6	32845
7793	1	45	49	1	20013
7794	1	46	49	6	5723
7795	1	46	49	5	36403
7796	1	46	49	6	72570
7797	1	46	49	5	22012
7798	1	46	49	4	56127
7799	1	46	49	1	41011
7800	1	47	49	5	15200
7801	1	47	49	6	74428
7802	1	47	49	5	70693
7803	1	47	49	1	205031
7804	1	47	49	1	91900
7805	1	48	49	5	48604
7806	1	48	49	6	84412
7807	1	48	49	1	82757
7808	1	49	49	5	28841
7809	1	49	49	6	19001
7810	1	49	49	5	80441
7811	1	49	49	1	237882
7812	1	49	49	1	72702
7813	1	50	49	6	66964
7814	1	50	49	5	43304
7815	1	50	49	6	16848
7816	1	50	49	5	49947
7817	1	50	49	4	81040
7818	1	50	49	1	19182
7819	1	51	49	6	19243
7820	1	51	49	5	42477
7821	1	51	49	6	14751
7822	1	51	49	5	17318
7823	1	51	49	4	57560
7824	1	51	49	1	74831
7825	1	52	49	5	6746
7826	1	52	49	6	9894
7827	1	52	49	1	64979
7828	1	53	49	5	18153
7829	1	53	49	6	46180
7830	1	53	49	5	53566
7831	1	53	49	1	435512
7832	1	53	49	1	29858
7833	1	54	49	5	17601
7834	1	54	49	6	84931
7835	1	54	49	1	84139
7836	1	55	49	5	44912
7837	1	55	49	6	58057
7838	1	55	49	1	62121
7839	1	56	49	5	40746
7840	1	56	49	6	19926
7841	1	56	49	1	44734
7842	1	57	49	5	21078
7843	1	57	49	6	38498
7844	1	57	49	5	95921
7845	1	57	49	1	448512
7846	1	57	49	1	25943
7847	1	59	49	6	131740
7848	1	59	49	5	40923
7849	1	59	49	5	16562
7850	1	59	49	6	118099
7851	1	59	49	4	184620
7852	1	59	49	1	406199
7853	1	60	49	6	74989
7854	1	60	49	5	48725
7855	1	60	49	6	73264
7856	1	60	49	5	6259
7857	1	60	49	4	65609
7858	1	60	49	1	53966
7859	1	1	50	4	88775
7860	1	1	50	6	141787
7861	1	1	50	4	85485
7862	1	1	50	6	121718
7863	1	19	50	5	36108
7864	1	19	50	6	51779
7865	1	19	50	1	46481
7866	1	43	50	5	14230
7867	1	50	50	6	28553
7868	1	50	50	5	32748
7869	1	50	50	6	90522
7870	1	50	50	5	61188
7871	1	50	50	4	16074
7872	1	50	50	1	15464
7873	1	51	50	5	17007
7874	1	51	50	6	19972
7875	1	51	50	5	102058
7876	1	51	50	1	237247
7877	1	51	50	1	34932
7878	1	52	50	5	37472
7879	1	52	50	6	76695
7880	1	52	50	1	8467
7881	1	53	50	5	1685
7882	1	53	50	6	70093
7883	1	53	50	1	37036
7884	1	54	50	4	95832
7885	1	54	50	6	96540
7886	1	55	50	6	23518
7887	1	55	50	5	26349
7888	1	55	50	6	40133
7889	1	55	50	5	18686
7890	1	55	50	4	18086
7891	1	55	50	1	50853
7892	1	57	50	5	42244
7893	1	57	50	6	97019
7894	1	57	50	5	111945
7895	1	57	50	1	351590
7896	1	57	50	1	82789
7897	1	59	50	1	265634
7898	1	1	51	4	96719
7899	1	1	51	6	77192
7900	1	1	51	4	130211
7901	1	1	51	6	131289
7902	1	2	51	4	69757
7903	1	2	51	6	149612
7904	1	14	51	6	16328
7905	1	14	51	5	5487
7906	1	14	51	6	37804
7907	1	14	51	5	57043
7908	1	14	51	4	63579
7909	1	14	51	1	10802
7910	1	25	51	5	223742
7911	1	25	51	4	90877
7912	1	25	51	1	110783
7913	1	25	51	4	37311
7914	1	25	51	1	74341
7915	1	50	51	6	37878
7916	1	50	51	5	9926
7917	1	50	51	6	54478
7918	1	50	51	5	38092
7919	1	50	51	4	71840
7920	1	50	51	1	18246
7921	1	51	51	5	32454
7922	1	52	51	1	189383
7923	1	53	51	5	35658
7924	1	53	51	6	55331
7925	1	53	51	5	51927
7926	1	53	51	1	411072
7927	1	53	51	1	72060
7928	1	54	51	6	3250
7929	1	54	51	5	2799
7930	1	54	51	6	18100
7931	1	54	51	5	60749
7932	1	54	51	4	10870
7933	1	54	51	1	92941
7934	1	55	51	5	2289
7935	1	55	51	6	28832
7936	1	55	51	1	98263
7937	1	56	51	5	4995
7938	1	56	51	6	21533
7939	1	56	51	1	95466
7940	1	57	51	5	38941
7941	1	57	51	6	82256
7942	1	57	51	1	56297
7943	1	58	51	6	136787
7944	1	58	51	5	22330
7945	1	58	51	5	12984
7946	1	58	51	6	56901
7947	1	58	51	4	101414
7948	1	58	51	1	553516
7949	1	59	51	6	138252
7950	1	59	51	5	67155
7951	1	59	51	5	11455
7952	1	59	51	6	7124
7953	1	59	51	4	277190
7954	1	59	51	1	456205
7955	1	1	52	5	245184
7956	1	1	52	4	80493
7957	1	1	52	1	184774
7958	1	1	52	4	83052
7959	1	1	52	1	114044
7960	1	17	52	5	42345
7961	1	17	52	6	84587
7962	1	17	52	1	4704
7963	1	23	52	6	51531
7964	1	23	52	5	11841
7965	1	23	52	5	23718
7966	1	23	52	6	104328
7967	1	23	52	4	176184
7968	1	23	52	1	203031
7969	1	24	52	6	112968
7970	1	24	52	5	50859
7971	1	24	52	5	10644
7972	1	24	52	6	70642
7973	1	24	52	4	129841
7974	1	24	52	1	449228
7975	1	25	52	5	10505
7976	1	25	52	6	30124
7977	1	25	52	1	156124
7978	1	26	52	5	11816
7979	1	26	52	6	132515
7980	1	26	52	1	139589
7981	1	50	52	6	17113
7982	1	50	52	5	31722
7983	1	50	52	6	46877
7984	1	50	52	5	2598
7985	1	50	52	4	61077
7986	1	50	52	1	99431
7987	1	51	52	6	63390
7988	1	51	52	5	19518
7989	1	51	52	6	77115
7990	1	51	52	5	39340
7991	1	51	52	4	72318
7992	1	51	52	1	95344
7993	1	53	52	5	13652
7994	1	53	52	6	63065
7995	1	53	52	1	27269
7996	1	56	52	6	97248
7997	1	56	52	5	21832
7998	1	56	52	5	12165
7999	1	56	52	6	144370
8000	1	56	52	4	169759
8001	1	56	52	1	465906
8002	1	57	52	6	73876
8003	1	57	52	5	2056
8004	1	57	52	5	41765
8005	1	57	52	6	70000
8006	1	57	52	4	112838
8007	1	57	52	1	531379
8008	1	58	52	6	134885
8009	1	58	52	5	15685
8010	1	58	52	5	16126
8011	1	58	52	6	86897
8012	1	58	52	4	135761
8013	1	58	52	1	528756
8014	1	59	52	6	53956
8015	1	59	52	5	55214
8016	1	59	52	5	36103
8017	1	59	52	6	51333
8018	1	59	52	4	131366
8019	1	59	52	1	320091
8020	1	1	53	5	160398
8021	1	1	53	4	51013
8022	1	1	53	1	179635
8023	1	1	53	4	31534
8024	1	1	53	1	108638
8025	1	24	53	5	47131
8026	1	24	53	6	71942
8027	1	24	53	1	401070
8028	1	25	53	5	255646
8029	1	25	53	4	37853
8030	1	25	53	1	91436
8031	1	25	53	4	20613
8032	1	25	53	1	128792
8033	1	26	53	5	36398
8034	1	26	53	6	16816
8035	1	26	53	1	390154
8036	1	27	53	4	46735
8037	1	27	53	1	155811
8038	1	28	53	1	296118
8039	1	51	53	5	31018
8040	1	51	53	6	113955
8041	1	51	53	1	145852
8042	1	52	53	5	1563
8043	1	52	53	6	10444
8044	1	52	53	1	4024
8045	1	53	53	5	37311
8046	1	53	53	6	79819
8047	1	53	53	5	68045
8048	1	53	53	1	408463
8049	1	53	53	1	74675
8050	1	55	53	6	122385
8051	1	55	53	5	32165
8052	1	55	53	5	20287
8053	1	55	53	6	17487
8054	1	55	53	4	268342
8055	1	55	53	1	68529
8056	1	56	53	5	12505
8057	1	56	53	6	55812
8058	1	56	53	1	236910
8059	1	57	53	6	70549
8060	1	57	53	5	17578
8061	1	57	53	5	36710
8062	1	57	53	6	14832
8063	1	57	53	4	133729
8064	1	57	53	1	194139
8065	1	58	53	5	14331
8066	1	58	53	6	17355
8067	1	58	53	1	515252
8068	1	59	53	5	41119
8069	1	59	53	6	88073
8070	1	59	53	1	480259
8071	1	60	53	6	56118
8072	1	60	53	5	5262
8073	1	60	53	5	16393
8074	1	60	53	6	149982
8075	1	60	53	4	292159
8076	1	60	53	1	410987
8077	1	1	54	5	119028
8078	1	1	54	4	79823
8079	1	1	54	1	72998
8080	1	1	54	4	12175
8081	1	1	54	1	170340
8082	1	4	54	5	188118
8083	1	4	54	4	55435
8084	1	4	54	1	84996
8085	1	4	54	4	31631
8086	1	4	54	1	151740
8087	1	24	54	6	65096
8088	1	24	54	5	27793
8089	1	24	54	5	23862
8090	1	24	54	6	20320
8091	1	24	54	4	282317
8092	1	24	54	1	174944
8093	1	25	54	6	130748
8094	1	25	54	5	22895
8095	1	25	54	5	8033
8096	1	25	54	6	61429
8097	1	25	54	4	186192
8098	1	25	54	1	130607
8099	1	26	54	6	58498
8100	1	26	54	5	23375
8101	1	26	54	5	25667
8102	1	26	54	6	12850
8103	1	26	54	4	200346
8104	1	26	54	1	362445
8105	1	27	54	6	110238
8106	1	27	54	5	18077
8107	1	27	54	5	15505
8108	1	27	54	6	88775
8109	1	27	54	4	105247
8110	1	27	54	1	563296
8111	1	28	54	5	13530
8112	1	28	54	6	57534
8113	1	28	54	1	467303
8114	1	29	54	6	118593
8115	1	29	54	5	61412
8116	1	29	54	5	4420
8117	1	29	54	6	7917
8118	1	29	54	4	186581
8119	1	29	54	1	194911
8120	1	39	54	4	68188
8121	1	39	54	1	138220
8122	1	47	54	5	245672
8123	1	47	54	4	6399
8124	1	47	54	1	93851
8125	1	47	54	4	89150
8126	1	47	54	1	198064
8127	1	52	54	4	18480
8128	1	52	54	1	197410
8129	1	53	54	6	68431
8130	1	53	54	5	13421
8131	1	53	54	6	16647
8132	1	53	54	5	1923
8133	1	53	54	4	3744
8134	1	53	54	1	77304
8135	1	56	54	6	144102
8136	1	56	54	5	4380
8137	1	56	54	5	2915
8138	1	56	54	6	91290
8139	1	56	54	4	289849
8140	1	56	54	1	564697
8141	1	57	54	6	134781
8142	1	57	54	5	55589
8143	1	57	54	5	41834
8144	1	57	54	6	100838
8145	1	57	54	4	141317
8146	1	57	54	1	320831
8147	1	58	54	5	44495
8148	1	58	54	6	79740
8149	1	58	54	1	413025
8150	1	59	54	5	19990
8151	1	59	54	6	117035
8152	1	59	54	1	589089
8153	1	60	54	6	122886
8154	1	60	54	5	10274
8155	1	60	54	5	23405
8156	1	60	54	6	28211
8157	1	60	54	4	239789
8158	1	60	54	1	376761
8159	1	6	55	4	80107
8160	1	6	55	6	132710
8161	1	25	55	6	83566
8162	1	25	55	5	67434
8163	1	25	55	5	22429
8164	1	25	55	6	44248
8165	1	25	55	4	135482
8166	1	25	55	1	322782
8167	1	26	55	5	29986
8168	1	26	55	6	71456
8169	1	26	55	1	354253
8170	1	27	55	4	67298
8171	1	27	55	6	51297
8172	1	38	55	4	7083
8173	1	38	55	1	97423
8174	1	42	55	1	337525
8175	1	53	55	5	40797
8176	1	53	55	6	89590
8177	1	53	55	1	35710
8178	1	54	55	5	13681
8179	1	54	55	6	32648
8180	1	54	55	1	13541
8181	1	56	55	6	52622
8182	1	56	55	5	41407
8183	1	56	55	5	16694
8184	1	56	55	6	128110
8185	1	56	55	4	204807
8186	1	56	55	1	240654
8187	1	57	55	6	92135
8188	1	57	55	5	62759
8189	1	57	55	5	49501
8190	1	57	55	6	57533
8191	1	57	55	4	275681
8192	1	57	55	1	277188
8193	1	58	55	6	120608
8194	1	58	55	5	34027
8195	1	58	55	5	38922
8196	1	58	55	6	129627
8197	1	58	55	4	227967
8198	1	58	55	1	576701
8199	1	59	55	5	2831
8200	1	59	55	6	53402
8201	1	59	55	1	498184
8202	1	60	55	5	249127
8203	1	60	55	4	57667
8204	1	60	55	1	80234
8205	1	60	55	4	21064
8206	1	60	55	1	194214
8207	1	25	56	4	68460
8208	1	25	56	6	50455
8209	1	25	56	4	126819
8210	1	25	56	6	62511
8211	1	26	56	6	84340
8212	1	26	56	5	58360
8213	1	26	56	5	5063
8214	1	26	56	6	85590
8215	1	26	56	4	182386
8216	1	26	56	1	267146
8217	1	27	56	5	26378
8218	1	27	56	6	95522
8219	1	27	56	1	102437
8220	1	29	56	6	133170
8221	1	29	56	5	43031
8222	1	29	56	5	19911
8223	1	29	56	6	109496
8224	1	29	56	4	175383
8225	1	29	56	1	430308
8226	1	53	56	6	16484
8227	1	53	56	5	48875
8228	1	53	56	6	55249
8229	1	53	56	5	10760
8230	1	53	56	4	81524
8231	1	53	56	1	51188
8232	1	54	56	6	39795
8233	1	54	56	5	16044
8234	1	54	56	6	37873
8235	1	54	56	5	62218
8236	1	54	56	4	11831
8237	1	54	56	1	55736
8238	1	55	56	5	22312
8239	1	55	56	6	81906
8240	1	55	56	1	37533
8241	1	56	56	5	5297
8242	1	56	56	6	129965
8243	1	56	56	1	503121
8244	1	57	56	5	8588
8245	1	57	56	6	139795
8246	1	57	56	1	587221
8247	1	60	56	6	78203
8248	1	60	56	5	62751
8249	1	60	56	5	39143
8250	1	60	56	6	135484
8251	1	60	56	4	286764
8252	1	60	56	1	422601
8253	1	26	57	6	60982
8254	1	26	57	5	52136
8255	1	26	57	5	41381
8256	1	26	57	6	96810
8257	1	26	57	4	160603
8258	1	26	57	1	396883
8259	1	27	57	4	83308
8260	1	27	57	6	54616
8261	1	27	57	4	66837
8262	1	27	57	6	127648
8263	1	54	57	5	2231
8264	1	54	57	6	10530
8265	1	54	57	1	88315
8266	1	55	57	5	20852
8267	1	55	57	6	5788
8268	1	55	57	5	84058
8269	1	55	57	1	400320
8270	1	55	57	1	89077
8271	1	56	57	5	2707
8272	1	56	57	6	58935
8273	1	56	57	1	67705
8274	1	57	57	6	70954
8275	1	57	57	5	3432
8276	1	57	57	5	43601
8277	1	57	57	6	74141
8278	1	57	57	4	174287
8279	1	57	57	1	457821
8280	1	59	57	6	72004
8281	1	59	57	5	24744
8282	1	59	57	5	30305
8283	1	59	57	6	87777
8284	1	59	57	4	175370
8285	1	59	57	1	539908
8286	1	60	57	6	101078
8287	1	60	57	5	30185
8288	1	60	57	5	10048
8289	1	60	57	6	1574
8290	1	60	57	4	271984
8291	1	60	57	1	407316
8292	1	1	58	5	77535
8293	1	15	58	4	96555
8294	1	15	58	6	107550
8295	1	15	58	4	94119
8296	1	15	58	6	142067
8297	1	17	58	6	56303
8298	1	17	58	5	41483
8299	1	17	58	6	29462
8300	1	17	58	5	63300
8301	1	17	58	4	66723
8302	1	17	58	1	88578
8303	1	40	58	4	93345
8304	1	40	58	6	58132
8305	1	40	58	4	145397
8306	1	40	58	6	64390
8307	1	54	58	5	4677
8308	1	54	58	6	70590
8309	1	54	58	1	7808
8310	1	55	58	5	8613
8311	1	55	58	6	12635
8312	1	55	58	5	87458
8313	1	55	58	1	478660
8314	1	55	58	1	22607
8315	1	56	58	6	92519
8316	1	56	58	5	39767
8317	1	56	58	6	26687
8318	1	56	58	5	61999
8319	1	56	58	4	17505
8320	1	56	58	1	91847
8321	1	57	58	5	1253
8322	1	57	58	6	79583
8323	1	57	58	1	17366
8324	1	11	59	6	66100
8325	1	11	59	5	24188
8326	1	11	59	5	32053
8327	1	11	59	6	92952
8328	1	11	59	4	298192
8329	1	11	59	1	362586
8330	1	28	59	5	29234
8331	1	28	59	6	85154
8332	1	28	59	1	15207
8333	1	49	59	5	91289
8334	1	54	59	6	19957
8335	1	54	59	5	46476
8336	1	54	59	6	68647
8337	1	54	59	5	37568
8338	1	54	59	4	74533
8339	1	54	59	1	2764
8340	1	55	59	5	4123
8341	1	55	59	6	53940
8342	1	55	59	1	34995
8343	1	56	59	5	39645
8344	1	56	59	6	56694
8345	1	56	59	1	26453
8346	1	57	59	5	20602
8347	1	57	59	6	14555
8348	1	57	59	5	81031
8349	1	57	59	1	248951
8350	1	57	59	1	81334
8351	1	58	59	4	117437
8352	1	58	59	6	93746
8353	1	58	59	4	77967
8354	1	58	59	6	76656
8355	1	59	59	4	147803
8356	1	59	59	6	50925
8357	1	4	60	5	32589
8358	1	4	60	6	107782
8359	1	4	60	1	428092
8360	1	27	60	5	45060
8361	1	27	60	6	39798
8362	1	27	60	1	9002
8363	1	28	60	5	6732
8364	1	28	60	6	2767
8365	1	28	60	1	4569
8366	1	31	60	5	8230
8367	1	31	60	6	62209
8368	1	31	60	1	573847
8369	1	57	60	5	22873
8370	1	57	60	6	33058
8371	1	57	60	5	40369
8372	1	57	60	1	272517
8373	1	57	60	1	13878
8374	1	59	60	5	98471
\.


--
-- TOC entry 5561 (class 0 OID 271592)
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
-- TOC entry 5541 (class 0 OID 22822)
-- Dependencies: 300
-- Data for Name: maps; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.maps (id, name) FROM stdin;
1	NowaMapa
\.


--
-- TOC entry 5543 (class 0 OID 22828)
-- Dependencies: 302
-- Data for Name: region_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.region_types (id, name) FROM stdin;
2	River
3	Sea
1	Province
\.


--
-- TOC entry 5490 (class 0 OID 22621)
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
-- TOC entry 5634 (class 0 OID 0)
-- Dependencies: 250
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.abilities_id_seq', 2, true);


--
-- TOC entry 5635 (class 0 OID 0)
-- Dependencies: 253
-- Name: player_abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_abilities_id_seq', 8, true);


--
-- TOC entry 5636 (class 0 OID 0)
-- Dependencies: 255
-- Name: player_skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_skills_id_seq', 12, true);


--
-- TOC entry 5637 (class 0 OID 0)
-- Dependencies: 257
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_stats_id_seq', 36, true);


--
-- TOC entry 5638 (class 0 OID 0)
-- Dependencies: 258
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.roles_id_seq', 1, false);


--
-- TOC entry 5639 (class 0 OID 0)
-- Dependencies: 259
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.skills_id_seq', 3, true);


--
-- TOC entry 5640 (class 0 OID 0)
-- Dependencies: 260
-- Name: stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.stats_id_seq', 9, true);


--
-- TOC entry 5641 (class 0 OID 0)
-- Dependencies: 262
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.accounts_id_seq', 1, false);


--
-- TOC entry 5642 (class 0 OID 0)
-- Dependencies: 264
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.sessions_id_seq', 1, false);


--
-- TOC entry 5643 (class 0 OID 0)
-- Dependencies: 266
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_id_seq', 4, true);


--
-- TOC entry 5644 (class 0 OID 0)
-- Dependencies: 269
-- Name: building_types_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.building_types_id_seq', 1, false);


--
-- TOC entry 5645 (class 0 OID 0)
-- Dependencies: 270
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.buildings_id_seq', 1, false);


--
-- TOC entry 5646 (class 0 OID 0)
-- Dependencies: 271
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: cities; Owner: postgres
--

SELECT pg_catalog.setval('cities.cities_id_seq', 1, false);


--
-- TOC entry 5647 (class 0 OID 0)
-- Dependencies: 274
-- Name: district_types_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.district_types_id_seq', 1, false);


--
-- TOC entry 5648 (class 0 OID 0)
-- Dependencies: 275
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.districts_id_seq', 1, false);


--
-- TOC entry 5649 (class 0 OID 0)
-- Dependencies: 277
-- Name: inventory_container_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_container_types_id_seq', 4, true);


--
-- TOC entry 5650 (class 0 OID 0)
-- Dependencies: 279
-- Name: inventory_containers_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_containers_id_seq', 8, true);


--
-- TOC entry 5651 (class 0 OID 0)
-- Dependencies: 281
-- Name: inventory_slot_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slot_types_id_seq', 14, true);


--
-- TOC entry 5652 (class 0 OID 0)
-- Dependencies: 283
-- Name: inventory_slots_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slots_id_seq', 88, true);


--
-- TOC entry 5653 (class 0 OID 0)
-- Dependencies: 284
-- Name: item_stats_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_stats_id_seq', 1, false);


--
-- TOC entry 5654 (class 0 OID 0)
-- Dependencies: 286
-- Name: item_types_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_types_id_seq', 10, true);


--
-- TOC entry 5655 (class 0 OID 0)
-- Dependencies: 287
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.items_id_seq', 6, true);


--
-- TOC entry 5656 (class 0 OID 0)
-- Dependencies: 290
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.players_id_seq', 4, true);


--
-- TOC entry 5657 (class 0 OID 0)
-- Dependencies: 315
-- Name: squads_id_seq; Type: SEQUENCE SET; Schema: squad; Owner: postgres
--

SELECT pg_catalog.setval('squad.squads_id_seq', 1, false);


--
-- TOC entry 5658 (class 0 OID 0)
-- Dependencies: 292
-- Name: status_types_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.status_types_id_seq', 1, false);


--
-- TOC entry 5659 (class 0 OID 0)
-- Dependencies: 294
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.tasks_id_seq', 20, true);


--
-- TOC entry 5660 (class 0 OID 0)
-- Dependencies: 295
-- Name: landscape_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.landscape_types_id_seq', 1, false);


--
-- TOC entry 5661 (class 0 OID 0)
-- Dependencies: 297
-- Name: map_regions_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_regions_id_seq', 343, true);


--
-- TOC entry 5662 (class 0 OID 0)
-- Dependencies: 318
-- Name: map_tiles_resources_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_tiles_resources_id_seq', 8374, true);


--
-- TOC entry 5663 (class 0 OID 0)
-- Dependencies: 321
-- Name: map_tiles_resources_spawn_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_tiles_resources_spawn_id_seq', 30, true);


--
-- TOC entry 5664 (class 0 OID 0)
-- Dependencies: 301
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.maps_id_seq', 1, true);


--
-- TOC entry 5665 (class 0 OID 0)
-- Dependencies: 303
-- Name: region_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.region_types_id_seq', 3, true);


--
-- TOC entry 5666 (class 0 OID 0)
-- Dependencies: 304
-- Name: terrain_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.terrain_types_id_seq', 3, true);


--
-- TOC entry 5149 (class 2606 OID 22844)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5184 (class 2606 OID 22846)
-- Name: ability_skill_requirements ability_skill_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_pkey PRIMARY KEY (ability_id, skill_id);


--
-- TOC entry 5186 (class 2606 OID 22848)
-- Name: ability_stat_requirements ability_stat_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_pkey PRIMARY KEY (ability_id, stat_id);


--
-- TOC entry 5151 (class 2606 OID 22850)
-- Name: player_abilities player_abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5188 (class 2606 OID 22852)
-- Name: player_skills player_skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5190 (class 2606 OID 22854)
-- Name: player_stats player_stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5153 (class 2606 OID 22856)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5155 (class 2606 OID 22858)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5157 (class 2606 OID 22860)
-- Name: stats stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5192 (class 2606 OID 22862)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 5194 (class 2606 OID 22864)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5196 (class 2606 OID 22866)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5198 (class 2606 OID 22868)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5200 (class 2606 OID 22870)
-- Name: verification_token verification_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.verification_token
    ADD CONSTRAINT verification_token_pkey PRIMARY KEY (identifier, token);


--
-- TOC entry 5202 (class 2606 OID 22872)
-- Name: building_roles building_owners_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_owners_pkey PRIMARY KEY (building_id, player_id, role_id);


--
-- TOC entry 5159 (class 2606 OID 22874)
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5161 (class 2606 OID 22876)
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- TOC entry 5163 (class 2606 OID 22878)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 5204 (class 2606 OID 22880)
-- Name: city_roles city_owners_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_roles
    ADD CONSTRAINT city_owners_pkey PRIMARY KEY (city_id, player_id, role_id);


--
-- TOC entry 5166 (class 2606 OID 22882)
-- Name: city_tiles city_tiles_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_tiles
    ADD CONSTRAINT city_tiles_pkey PRIMARY KEY (city_id, x, y);


--
-- TOC entry 5206 (class 2606 OID 22884)
-- Name: district_roles district_owners_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_owners_pkey PRIMARY KEY (district_id, player_id, role_id);


--
-- TOC entry 5168 (class 2606 OID 22886)
-- Name: district_types district_types_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_types
    ADD CONSTRAINT district_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5170 (class 2606 OID 22888)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 5241 (class 2606 OID 288321)
-- Name: inventory_container_player_access inventory_container_player_access_unique; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_player_access
    ADD CONSTRAINT inventory_container_player_access_unique UNIQUE (inventory_container_id, player_id);


--
-- TOC entry 5208 (class 2606 OID 22890)
-- Name: inventory_container_types inventory_container_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_types
    ADD CONSTRAINT inventory_container_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5210 (class 2606 OID 22892)
-- Name: inventory_containers inventory_containers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_pkey PRIMARY KEY (id);


--
-- TOC entry 5172 (class 2606 OID 22894)
-- Name: inventory_slot_types inventory_slot_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_types
    ADD CONSTRAINT inventory_slot_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5212 (class 2606 OID 22896)
-- Name: inventory_slots inventory_slots_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 5174 (class 2606 OID 22898)
-- Name: item_stats item_stats_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5214 (class 2606 OID 22900)
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5176 (class 2606 OID 22902)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 5235 (class 2606 OID 25562)
-- Name: known_map_tiles known_map_tiles_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_pk PRIMARY KEY (player_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5247 (class 2606 OID 25558)
-- Name: known_players_abilities known_players_abilities_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5239 (class 2606 OID 25556)
-- Name: known_players_containers known_players_containers_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_pk PRIMARY KEY (player_id, container_id);


--
-- TOC entry 5216 (class 2606 OID 25554)
-- Name: known_players_positions known_players_positions_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5237 (class 2606 OID 25552)
-- Name: known_players_profiles known_players_profiles_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5245 (class 2606 OID 25550)
-- Name: known_players_skills known_players_skills_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5243 (class 2606 OID 25548)
-- Name: known_players_stats known_players_stats_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5219 (class 2606 OID 22904)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 5249 (class 2606 OID 25573)
-- Name: squad_players squad_players_pkey; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_pkey PRIMARY KEY (squad_id, player_id);


--
-- TOC entry 5251 (class 2606 OID 25580)
-- Name: squads squads_pk; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squads
    ADD CONSTRAINT squads_pk PRIMARY KEY (id);


--
-- TOC entry 5221 (class 2606 OID 22906)
-- Name: status_types status_types_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types
    ADD CONSTRAINT status_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5223 (class 2606 OID 22908)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 5178 (class 2606 OID 22910)
-- Name: landscape_types landscape_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.landscape_types
    ADD CONSTRAINT landscape_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5225 (class 2606 OID 22912)
-- Name: map_regions map_regions_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_regions
    ADD CONSTRAINT map_regions_pkey PRIMARY KEY (id);


--
-- TOC entry 5227 (class 2606 OID 25566)
-- Name: map_tiles_map_regions map_tiles_map_regions_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_pk PRIMARY KEY (region_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5180 (class 2606 OID 22914)
-- Name: map_tiles map_tiles_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_pkey PRIMARY KEY (map_id, x, y);


--
-- TOC entry 5229 (class 2606 OID 25564)
-- Name: map_tiles_players_positions map_tiles_players_positions_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_pk PRIMARY KEY (player_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5253 (class 2606 OID 25642)
-- Name: map_tiles_resources map_tiles_resources_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_pk PRIMARY KEY (id);


--
-- TOC entry 5255 (class 2606 OID 271606)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_pkey PRIMARY KEY (id);


--
-- TOC entry 5257 (class 2606 OID 271608)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_terrain_type_id_landscape_type_id_key; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_terrain_type_id_landscape_type_id_key UNIQUE (terrain_type_id, landscape_type_id, item_id);


--
-- TOC entry 5231 (class 2606 OID 22918)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- TOC entry 5233 (class 2606 OID 22920)
-- Name: region_types region_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.region_types
    ADD CONSTRAINT region_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5182 (class 2606 OID 22922)
-- Name: terrain_types terrain_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.terrain_types
    ADD CONSTRAINT terrain_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5164 (class 1259 OID 22923)
-- Name: unique_city_position; Type: INDEX; Schema: cities; Owner: postgres
--

CREATE UNIQUE INDEX unique_city_position ON cities.cities USING btree (map_tile_x, map_tile_y);


--
-- TOC entry 5217 (class 1259 OID 22924)
-- Name: one_active_player_per_user; Type: INDEX; Schema: players; Owner: postgres
--

CREATE UNIQUE INDEX one_active_player_per_user ON players.players USING btree (user_id) WHERE (is_active = true);


--
-- TOC entry 5274 (class 2606 OID 22925)
-- Name: ability_skill_requirements ability_skill_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5275 (class 2606 OID 22930)
-- Name: ability_skill_requirements ability_skill_requirements_skill_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5276 (class 2606 OID 22935)
-- Name: ability_stat_requirements ability_stat_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5277 (class 2606 OID 22940)
-- Name: ability_stat_requirements ability_stat_requirements_stat_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_stat_id_fkey FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5258 (class 2606 OID 22945)
-- Name: player_abilities player_abilities_abilities_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_abilities_fk FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5259 (class 2606 OID 22950)
-- Name: player_abilities player_abilities_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5278 (class 2606 OID 22955)
-- Name: player_skills player_skills_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5279 (class 2606 OID 22960)
-- Name: player_skills player_skills_skills_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_skills_fk FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5280 (class 2606 OID 22965)
-- Name: player_stats player_stats_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5281 (class 2606 OID 22970)
-- Name: player_stats player_stats_stats_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5282 (class 2606 OID 22975)
-- Name: accounts accounts_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_users_fk FOREIGN KEY ("userId") REFERENCES auth.users(id);


--
-- TOC entry 5283 (class 2606 OID 22980)
-- Name: sessions sessions_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_users_fk FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- TOC entry 5284 (class 2606 OID 22985)
-- Name: building_roles building_roles_buildings_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_buildings_fk FOREIGN KEY (building_id) REFERENCES buildings.buildings(id);


--
-- TOC entry 5285 (class 2606 OID 22990)
-- Name: building_roles building_roles_players_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5286 (class 2606 OID 22995)
-- Name: building_roles building_roles_roles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5260 (class 2606 OID 23000)
-- Name: buildings buildings_building_types_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_building_types_fk FOREIGN KEY (building_type_id) REFERENCES buildings.building_types(id);


--
-- TOC entry 5261 (class 2606 OID 23005)
-- Name: buildings buildings_cities_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_cities_fk FOREIGN KEY (city_id) REFERENCES cities.cities(id);


--
-- TOC entry 5262 (class 2606 OID 23010)
-- Name: buildings buildings_city_tiles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_city_tiles_fk FOREIGN KEY (city_id, city_tile_x, city_tile_y) REFERENCES cities.city_tiles(city_id, x, y);


--
-- TOC entry 5263 (class 2606 OID 23015)
-- Name: cities cities_map_tiles_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5264 (class 2606 OID 23020)
-- Name: cities cities_maps_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5287 (class 2606 OID 23025)
-- Name: district_roles district_roles_districts_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_districts_fk FOREIGN KEY (district_id) REFERENCES districts.districts(id);


--
-- TOC entry 5288 (class 2606 OID 23030)
-- Name: district_roles district_roles_players_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5289 (class 2606 OID 23035)
-- Name: district_roles district_roles_roles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5265 (class 2606 OID 23040)
-- Name: districts districts_district_types_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_district_types_fk FOREIGN KEY (district_type_id) REFERENCES districts.district_types(id);


--
-- TOC entry 5266 (class 2606 OID 23045)
-- Name: districts districts_map_tiles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5267 (class 2606 OID 23050)
-- Name: districts districts_maps_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5290 (class 2606 OID 23055)
-- Name: inventory_containers inventory_containers_inventory_container_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_inventory_container_types_fk FOREIGN KEY (inventory_container_type_id) REFERENCES inventory.inventory_container_types(id);


--
-- TOC entry 5291 (class 2606 OID 23060)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5292 (class 2606 OID 23065)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_item_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5293 (class 2606 OID 23070)
-- Name: inventory_slots inventory_slots_inventory_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5294 (class 2606 OID 23075)
-- Name: inventory_slots inventory_slots_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5295 (class 2606 OID 23080)
-- Name: inventory_slots inventory_slots_items_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5268 (class 2606 OID 23085)
-- Name: item_stats item_stats_items_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5269 (class 2606 OID 23090)
-- Name: item_stats item_stats_stats_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5270 (class 2606 OID 23095)
-- Name: items items_item_types_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5304 (class 2606 OID 23184)
-- Name: known_map_tiles known_map_tiles_map_tiles_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5305 (class 2606 OID 23179)
-- Name: known_map_tiles known_map_tiles_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5320 (class 2606 OID 25663)
-- Name: known_map_tiles_resources known_map_tiles_resources_map_tiles_resources_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles_resources
    ADD CONSTRAINT known_map_tiles_resources_map_tiles_resources_fk FOREIGN KEY (map_tiles_resource_id) REFERENCES world.map_tiles_resources(id);


--
-- TOC entry 5321 (class 2606 OID 25658)
-- Name: known_map_tiles_resources known_map_tiles_resources_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles_resources
    ADD CONSTRAINT known_map_tiles_resources_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5314 (class 2606 OID 25535)
-- Name: known_players_abilities known_players_abilities_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5315 (class 2606 OID 25540)
-- Name: known_players_abilities known_players_abilities_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5308 (class 2606 OID 25470)
-- Name: known_players_containers known_players_containers_inventory_containers_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_inventory_containers_fk FOREIGN KEY (container_id) REFERENCES inventory.inventory_containers(id);


--
-- TOC entry 5309 (class 2606 OID 25465)
-- Name: known_players_containers known_players_containers_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5296 (class 2606 OID 23100)
-- Name: known_players_positions known_players_positions_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5297 (class 2606 OID 23105)
-- Name: known_players_positions known_players_positions_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5306 (class 2606 OID 25450)
-- Name: known_players_profiles known_players_profiles_other_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_other_players_fk FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5307 (class 2606 OID 25445)
-- Name: known_players_profiles known_players_profiles_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5312 (class 2606 OID 25519)
-- Name: known_players_skills known_players_skills_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5313 (class 2606 OID 25524)
-- Name: known_players_skills known_players_skills_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5310 (class 2606 OID 25508)
-- Name: known_players_stats known_players_stats_player_stats_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_player_stats_fk FOREIGN KEY (other_player_id) REFERENCES attributes.player_stats(id);


--
-- TOC entry 5311 (class 2606 OID 25497)
-- Name: known_players_stats known_players_stats_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5316 (class 2606 OID 25586)
-- Name: squad_players squad_players_players_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5317 (class 2606 OID 25581)
-- Name: squad_players squad_players_squads_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_squads_fk FOREIGN KEY (squad_id) REFERENCES squad.squads(id);


--
-- TOC entry 5271 (class 2606 OID 23110)
-- Name: map_tiles map_tiles_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5298 (class 2606 OID 23115)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_regions_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_regions_fk FOREIGN KEY (region_id) REFERENCES world.map_regions(id);


--
-- TOC entry 5299 (class 2606 OID 23120)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5300 (class 2606 OID 23125)
-- Name: map_tiles_map_regions map_tiles_map_regions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5272 (class 2606 OID 23130)
-- Name: map_tiles map_tiles_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5301 (class 2606 OID 23135)
-- Name: map_tiles_players_positions map_tiles_players_positions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5302 (class 2606 OID 23140)
-- Name: map_tiles_players_positions map_tiles_players_positions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5303 (class 2606 OID 23145)
-- Name: map_tiles_players_positions map_tiles_players_positions_players_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5318 (class 2606 OID 25648)
-- Name: map_tiles_resources map_tiles_resources_items_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5319 (class 2606 OID 25643)
-- Name: map_tiles_resources map_tiles_resources_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5322 (class 2606 OID 271619)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_items_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5323 (class 2606 OID 271614)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5324 (class 2606 OID 271609)
-- Name: map_tiles_resources_spawn map_tiles_resources_spawn_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources_spawn
    ADD CONSTRAINT map_tiles_resources_spawn_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


--
-- TOC entry 5273 (class 2606 OID 23150)
-- Name: map_tiles map_tiles_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


-- Completed on 2026-04-01 00:33:46

--
-- PostgreSQL database dump complete
--

\unrestrict XAI5NawaLQdjFW7pzfvdsTY08TLwpCFb21YPx6IT55WDZ6EWppj2T8m6PfzaE8Q

