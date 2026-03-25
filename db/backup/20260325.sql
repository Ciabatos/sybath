--
-- PostgreSQL database dump
--

\restrict FBebtk7YY25BhKthALtYvKTFI6vrDsxvXnHnKfk2RfkMe2IUmkpYvWrgCBISvBJ

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-03-25 17:06:33

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
-- TOC entry 389 (class 1255 OID 22428)
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
-- TOC entry 399 (class 1255 OID 22429)
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
-- TOC entry 326 (class 1255 OID 22430)
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
-- TOC entry 356 (class 1255 OID 22431)
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

END;
$$;


ALTER PROCEDURE admin.map_insert() OWNER TO postgres;

--
-- TOC entry 370 (class 1255 OID 22432)
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

END;
$$;


ALTER PROCEDURE admin.new_player(IN p_user_id integer, IN p_name character varying, IN p_second_name character varying) OWNER TO postgres;

--
-- TOC entry 421 (class 1255 OID 22433)
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
-- TOC entry 357 (class 1255 OID 22434)
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
TRUNCATE TABLE  tasks.tasks          RESTART IDENTITY CASCADE;
TRUNCATE TABLE	knowledge.known_map_tiles RESTART IDENTITY CASCADE;
TRUNCATE TABLE knowledge.known_players_positions RESTART IDENTITY CASCADE;

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
-- TOC entry 361 (class 1255 OID 22435)
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
-- TOC entry 400 (class 1255 OID 22444)
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
-- TOC entry 5542 (class 0 OID 0)
-- Dependencies: 400
-- Name: FUNCTION get_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities() IS 'automatic_get_api';


--
-- TOC entry 321 (class 1255 OID 22445)
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
-- TOC entry 5543 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION get_abilities_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 416 (class 1255 OID 25614)
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
-- TOC entry 5544 (class 0 OID 0)
-- Dependencies: 416
-- Name: FUNCTION get_other_player_abilities(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_abilities(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 366 (class 1255 OID 25613)
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
-- TOC entry 5545 (class 0 OID 0)
-- Dependencies: 366
-- Name: FUNCTION get_other_player_skills(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_skills(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 396 (class 1255 OID 25612)
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
-- TOC entry 5546 (class 0 OID 0)
-- Dependencies: 396
-- Name: FUNCTION get_other_player_stats(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_other_player_stats(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 325 (class 1255 OID 22454)
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
-- TOC entry 5547 (class 0 OID 0)
-- Dependencies: 325
-- Name: FUNCTION get_player_abilities(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities(p_player_id integer) IS 'get_api';


--
-- TOC entry 406 (class 1255 OID 22456)
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
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 406
-- Name: FUNCTION get_player_skills(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_skills(p_player_id integer) IS 'get_api';


--
-- TOC entry 332 (class 1255 OID 22457)
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
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 332
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
-- TOC entry 329 (class 1255 OID 22462)
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
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION get_roles(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles() IS 'automatic_get_api';


--
-- TOC entry 363 (class 1255 OID 22463)
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
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 363
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
-- TOC entry 343 (class 1255 OID 22472)
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
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION get_skills(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills() IS 'automatic_get_api';


--
-- TOC entry 323 (class 1255 OID 22473)
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
-- TOC entry 5553 (class 0 OID 0)
-- Dependencies: 323
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
-- TOC entry 344 (class 1255 OID 22482)
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
-- TOC entry 5554 (class 0 OID 0)
-- Dependencies: 344
-- Name: FUNCTION get_stats(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats() IS 'automatic_get_api';


--
-- TOC entry 382 (class 1255 OID 22483)
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
-- TOC entry 5555 (class 0 OID 0)
-- Dependencies: 382
-- Name: FUNCTION get_stats_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 342 (class 1255 OID 22484)
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
-- TOC entry 392 (class 1255 OID 22485)
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
-- TOC entry 355 (class 1255 OID 22486)
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
-- TOC entry 365 (class 1255 OID 22492)
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
-- TOC entry 5556 (class 0 OID 0)
-- Dependencies: 365
-- Name: FUNCTION get_building_types(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types() IS 'automatic_get_api';


--
-- TOC entry 345 (class 1255 OID 22493)
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
-- TOC entry 5557 (class 0 OID 0)
-- Dependencies: 345
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
-- TOC entry 393 (class 1255 OID 22503)
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
-- TOC entry 5558 (class 0 OID 0)
-- Dependencies: 393
-- Name: FUNCTION get_buildings(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings() IS 'automatic_get_api';


--
-- TOC entry 322 (class 1255 OID 22504)
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
-- TOC entry 5559 (class 0 OID 0)
-- Dependencies: 322
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
-- TOC entry 372 (class 1255 OID 22514)
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
-- TOC entry 5560 (class 0 OID 0)
-- Dependencies: 372
-- Name: FUNCTION get_cities(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities() IS 'automatic_get_api';


--
-- TOC entry 407 (class 1255 OID 22515)
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
-- TOC entry 5561 (class 0 OID 0)
-- Dependencies: 407
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
-- TOC entry 424 (class 1255 OID 22524)
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
-- TOC entry 5562 (class 0 OID 0)
-- Dependencies: 424
-- Name: FUNCTION get_city_tiles(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles() IS 'automatic_get_api';


--
-- TOC entry 402 (class 1255 OID 22525)
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
-- TOC entry 5563 (class 0 OID 0)
-- Dependencies: 402
-- Name: FUNCTION get_city_tiles_by_key(p_city_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 379 (class 1255 OID 22526)
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
-- TOC entry 5564 (class 0 OID 0)
-- Dependencies: 379
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
-- TOC entry 340 (class 1255 OID 22533)
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
-- TOC entry 5565 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION get_district_types(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types() IS 'automatic_get_api';


--
-- TOC entry 391 (class 1255 OID 22534)
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
-- TOC entry 5566 (class 0 OID 0)
-- Dependencies: 391
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
-- TOC entry 346 (class 1255 OID 22543)
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
-- TOC entry 5567 (class 0 OID 0)
-- Dependencies: 346
-- Name: FUNCTION get_districts(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts() IS 'automatic_get_api';


--
-- TOC entry 368 (class 1255 OID 22544)
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
-- TOC entry 5568 (class 0 OID 0)
-- Dependencies: 368
-- Name: FUNCTION get_districts_by_key(p_map_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 377 (class 1255 OID 22545)
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

    RETURN QUERY SELECT true, 'Container created successfully';


END;
$$;


ALTER FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer) OWNER TO postgres;

--
-- TOC entry 383 (class 1255 OID 22546)
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
-- TOC entry 414 (class 1255 OID 22547)
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
-- TOC entry 349 (class 1255 OID 25491)
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
-- TOC entry 354 (class 1255 OID 22548)
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
-- TOC entry 404 (class 1255 OID 22550)
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
-- TOC entry 339 (class 1255 OID 22551)
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
-- TOC entry 410 (class 1255 OID 22552)
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
-- TOC entry 5569 (class 0 OID 0)
-- Dependencies: 410
-- Name: FUNCTION do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 394 (class 1255 OID 22553)
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
-- TOC entry 5570 (class 0 OID 0)
-- Dependencies: 394
-- Name: FUNCTION do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) IS 'action_api';


--
-- TOC entry 401 (class 1255 OID 22554)
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
-- TOC entry 5571 (class 0 OID 0)
-- Dependencies: 401
-- Name: FUNCTION get_building_inventory(p_building_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_building_inventory(p_building_id integer) IS 'get_api';


--
-- TOC entry 360 (class 1255 OID 22555)
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
-- TOC entry 359 (class 1255 OID 22556)
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
-- TOC entry 5572 (class 0 OID 0)
-- Dependencies: 359
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
-- TOC entry 387 (class 1255 OID 22561)
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
-- TOC entry 5573 (class 0 OID 0)
-- Dependencies: 387
-- Name: FUNCTION get_inventory_slot_types(); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types() IS 'automatic_get_api';


--
-- TOC entry 331 (class 1255 OID 22562)
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
-- TOC entry 5574 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION get_inventory_slot_types_by_key(p_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 350 (class 1255 OID 25611)
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
-- TOC entry 5575 (class 0 OID 0)
-- Dependencies: 350
-- Name: FUNCTION get_other_player_gear_inventory(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_other_player_gear_inventory(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 409 (class 1255 OID 25610)
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
-- TOC entry 5576 (class 0 OID 0)
-- Dependencies: 409
-- Name: FUNCTION get_other_player_inventory(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_other_player_inventory(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 398 (class 1255 OID 25483)
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
-- TOC entry 5577 (class 0 OID 0)
-- Dependencies: 398
-- Name: FUNCTION get_player_gear_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_gear_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 336 (class 1255 OID 25482)
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
-- TOC entry 5578 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION get_player_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 384 (class 1255 OID 22565)
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
-- TOC entry 351 (class 1255 OID 22566)
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
-- TOC entry 341 (class 1255 OID 22567)
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
-- TOC entry 352 (class 1255 OID 25700)
-- Name: do_gather_resources_on_map_tile(integer, jsonb); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.do_gather_resources_on_map_tile(p_player_id integer, parameters jsonb) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    param jsonb;
    base_time timestamp;
    scheduled_time timestamp; 
BEGIN

/* MUTEX */
PERFORM 1
FROM players.players
WHERE id = p_player_id
FOR UPDATE;

    PERFORM tasks.cancel_task(p_player_id, 'items.gather_resources_on_map_tile');

SELECT COALESCE(MAX(t1.scheduled_at), NOW())
INTO base_time
FROM tasks.tasks t1
WHERE t1.player_id = p_player_id
  AND t1.status IN (1, 2);


    FOR param IN 
        SELECT * FROM jsonb_array_elements(parameters)
    LOOP
        scheduled_time := base_time 
                               +  ((param->>'gatherAmount')::int )* interval '1 minute';
        PERFORM tasks.insert_task(p_player_id, scheduled_time , 'items.gather_resources_on_map_tile', param);
    END LOOP;

    RETURN QUERY SELECT true, 'Gather resrources action assigned';
END;
$$;


ALTER FUNCTION items.do_gather_resources_on_map_tile(p_player_id integer, parameters jsonb) OWNER TO postgres;

--
-- TOC entry 5579 (class 0 OID 0)
-- Dependencies: 352
-- Name: FUNCTION do_gather_resources_on_map_tile(p_player_id integer, parameters jsonb); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.do_gather_resources_on_map_tile(p_player_id integer, parameters jsonb) IS 'action_api';


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
-- TOC entry 412 (class 1255 OID 22575)
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
-- TOC entry 5580 (class 0 OID 0)
-- Dependencies: 412
-- Name: FUNCTION get_item_stats(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats() IS 'automatic_get_api';


--
-- TOC entry 328 (class 1255 OID 22576)
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
-- TOC entry 5581 (class 0 OID 0)
-- Dependencies: 328
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
-- TOC entry 411 (class 1255 OID 22587)
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
-- TOC entry 5582 (class 0 OID 0)
-- Dependencies: 411
-- Name: FUNCTION get_items(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items() IS 'automatic_get_api';


--
-- TOC entry 353 (class 1255 OID 22588)
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
-- TOC entry 5583 (class 0 OID 0)
-- Dependencies: 353
-- Name: FUNCTION get_items_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 333 (class 1255 OID 22589)
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
-- TOC entry 5584 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION do_switch_active_player(p_player_id integer, p_switch_to_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) IS 'action_api';


--
-- TOC entry 413 (class 1255 OID 22590)
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
-- TOC entry 408 (class 1255 OID 22591)
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
-- TOC entry 5585 (class 0 OID 0)
-- Dependencies: 408
-- Name: FUNCTION get_active_player_profile(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_profile(p_player_id integer) IS 'get_api';


--
-- TOC entry 347 (class 1255 OID 22592)
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
-- TOC entry 5586 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION get_active_player_switch_profiles(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_switch_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 395 (class 1255 OID 25605)
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
-- TOC entry 5587 (class 0 OID 0)
-- Dependencies: 395
-- Name: FUNCTION get_other_player_profile(p_player_id integer, p_other_player_id text); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_other_player_profile(p_player_id integer, p_other_player_id text) IS 'get_api';


--
-- TOC entry 397 (class 1255 OID 25602)
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
-- TOC entry 369 (class 1255 OID 22593)
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
-- TOC entry 330 (class 1255 OID 25592)
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
-- TOC entry 5588 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION get_active_player_squad(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_active_player_squad(p_player_id integer) IS 'get_api';


--
-- TOC entry 334 (class 1255 OID 25619)
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
-- TOC entry 5589 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION get_active_player_squad_players_profiles(p_player_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_active_player_squad_players_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 338 (class 1255 OID 25620)
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
-- TOC entry 5590 (class 0 OID 0)
-- Dependencies: 338
-- Name: FUNCTION get_other_squad_players_profiles(p_player_id integer, p_squad_id integer); Type: COMMENT; Schema: squad; Owner: postgres
--

COMMENT ON FUNCTION squad.get_other_squad_players_profiles(p_player_id integer, p_squad_id integer) IS 'get_api';


--
-- TOC entry 419 (class 1255 OID 22594)
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
-- TOC entry 362 (class 1255 OID 22595)
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
-- TOC entry 425 (class 1255 OID 22596)
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
-- TOC entry 348 (class 1255 OID 25669)
-- Name: do_map_tile_exploration(integer, jsonb); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.do_map_tile_exploration(p_player_id integer, parameters jsonb) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    param jsonb;
    base_time timestamp;
    scheduled_time timestamp;
BEGIN

/* MUTEX */
PERFORM 1
FROM players.players
WHERE id = p_player_id
FOR UPDATE;

    PERFORM tasks.cancel_task(p_player_id, 'world.map_tile_exploration');

SELECT COALESCE(MAX(t1.scheduled_at), NOW())
INTO base_time
FROM tasks.tasks t1
WHERE t1.player_id = p_player_id
  AND t1.status IN (1, 2);


    FOR param IN 
        SELECT * FROM jsonb_array_elements(parameters)
    LOOP
        scheduled_time := base_time 
                               +  GREATEST((100 * (1 - ((param->>'explorationLevel')::int * 0.1))), 0.1) * interval '1 minute';
        PERFORM tasks.insert_task(p_player_id, scheduled_time , 'world.map_tile_exploration', param);
    END LOOP;

    RETURN QUERY SELECT true, 'Exploration actions assigned';
END;
$$;


ALTER FUNCTION world.do_map_tile_exploration(p_player_id integer, parameters jsonb) OWNER TO postgres;

--
-- TOC entry 5591 (class 0 OID 0)
-- Dependencies: 348
-- Name: FUNCTION do_map_tile_exploration(p_player_id integer, parameters jsonb); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_map_tile_exploration(p_player_id integer, parameters jsonb) IS 'action_api';


--
-- TOC entry 364 (class 1255 OID 22597)
-- Name: do_player_movement(integer, jsonb); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    param jsonb; 
    base_time timestamp;
    scheduled_at timestamp;
BEGIN

/* MUTEX */
PERFORM 1
FROM players.players
WHERE id = p_player_id
FOR UPDATE;

    PERFORM tasks.cancel_task(p_player_id, 'world.player_movement');

SELECT COALESCE(MAX(t1.scheduled_at), NOW())
INTO base_time
FROM tasks.tasks t1
WHERE t1.player_id = p_player_id
  AND t1.status IN (1, 2);

    FOR param IN 
        SELECT * FROM jsonb_array_elements(p_path)
    LOOP
          scheduled_at := base_time
               + ((param->>'totalMoveCost')::int * interval '1 minute');

        PERFORM tasks.insert_task(p_player_id, scheduled_at , 'world.player_movement', param);
    END LOOP;

    RETURN QUERY SELECT true, 'Movement actions assigned';
END;
$$;


ALTER FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) OWNER TO postgres;

--
-- TOC entry 5592 (class 0 OID 0)
-- Dependencies: 364
-- Name: FUNCTION do_player_movement(p_player_id integer, p_path jsonb); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) IS 'action_api';


--
-- TOC entry 386 (class 1255 OID 23168)
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
-- TOC entry 5593 (class 0 OID 0)
-- Dependencies: 386
-- Name: FUNCTION get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer) IS 'get_api';


--
-- TOC entry 335 (class 1255 OID 23190)
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
-- TOC entry 5594 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION get_known_map_tiles(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_tiles(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 418 (class 1255 OID 25668)
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
-- TOC entry 5595 (class 0 OID 0)
-- Dependencies: 418
-- Name: FUNCTION get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_tiles_resources_on_tile(p_map_id integer, p_map_tile_x integer, p_map_tile_y integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 378 (class 1255 OID 25609)
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
-- TOC entry 5596 (class 0 OID 0)
-- Dependencies: 378
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
-- TOC entry 415 (class 1255 OID 22605)
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
-- TOC entry 5597 (class 0 OID 0)
-- Dependencies: 415
-- Name: FUNCTION get_landscape_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types() IS 'automatic_get_api';


--
-- TOC entry 337 (class 1255 OID 22606)
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
-- TOC entry 5598 (class 0 OID 0)
-- Dependencies: 337
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
-- TOC entry 417 (class 1255 OID 22615)
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
-- TOC entry 5599 (class 0 OID 0)
-- Dependencies: 417
-- Name: FUNCTION get_map_tiles(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles() IS 'automatic_get_api';


--
-- TOC entry 426 (class 1255 OID 22616)
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
-- TOC entry 5600 (class 0 OID 0)
-- Dependencies: 426
-- Name: FUNCTION get_map_tiles_by_key(p_map_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 390 (class 1255 OID 22617)
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
-- TOC entry 5601 (class 0 OID 0)
-- Dependencies: 390
-- Name: FUNCTION get_player_map(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_map(p_player_id integer) IS 'get_api';


--
-- TOC entry 423 (class 1255 OID 25672)
-- Name: get_player_movement(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_movement(p_player_id integer) RETURNS TABLE("order" integer, move_cost integer, map_id integer, x integer, y integer, total_move_cost integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM tasks.tasks
        WHERE method_name = 'world.player_movement'
          AND status IN (1, 2)
          AND player_id = p_player_id
    ) THEN

    RETURN QUERY
 
    
             SELECT
                (method_parameters->>'order')::int AS order,
                (method_parameters->>'moveCost')::int AS move_cost,
                (method_parameters->>'mapId')::int AS map_id,
                 (method_parameters->>'x')::int AS x,
                 (method_parameters->>'y')::int AS y,
                 (method_parameters->>'totalMoveCost')::int AS total_move_cost
             FROM tasks.tasks
             WHERE player_id = p_player_id
               AND method_name = 'world.player_movement'
            AND status IN (1, 2);

    END IF;
END;
$$;


ALTER FUNCTION world.get_player_movement(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5602 (class 0 OID 0)
-- Dependencies: 423
-- Name: FUNCTION get_player_movement(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_movement(p_player_id integer) IS 'get_api';


--
-- TOC entry 374 (class 1255 OID 22619)
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
-- TOC entry 5603 (class 0 OID 0)
-- Dependencies: 374
-- Name: FUNCTION get_player_position(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 388 (class 1255 OID 25603)
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
-- TOC entry 5604 (class 0 OID 0)
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
-- TOC entry 380 (class 1255 OID 22627)
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
-- TOC entry 5605 (class 0 OID 0)
-- Dependencies: 380
-- Name: FUNCTION get_terrain_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types() IS 'automatic_get_api';


--
-- TOC entry 324 (class 1255 OID 22628)
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
-- TOC entry 5606 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION get_terrain_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 375 (class 1255 OID 25670)
-- Name: map_tile_exploration(); Type: PROCEDURE; Schema: world; Owner: postgres
--

CREATE PROCEDURE world.map_tile_exploration()
    LANGUAGE plpgsql
    AS $$
BEGIN
    

UPDATE knowledge.known_map_tiles_resources kmtr
    SET
        map_tile_x = T1.x,
        map_tile_y = T1.y

    FROM (
        SELECT DISTINCT ON (player_id)
               player_id,
               (method_parameters->>'x')::int AS x,
               (method_parameters->>'y')::int AS y
        FROM tasks.tasks
        WHERE method_name = 'world.map_tile_exploration'
          AND status IN (1, 2)
          AND scheduled_at <= now()
    ) T1

    WHERE kmtr.player_id = T1.player_id;
    
    

    UPDATE tasks.tasks
    SET status = 3
    WHERE method_name = 'world.map_tile_exploration'
      AND status IN (1, 2)
      AND scheduled_at <= now();
    
    
END;
$$;


ALTER PROCEDURE world.map_tile_exploration() OWNER TO postgres;

--
-- TOC entry 373 (class 1255 OID 22629)
-- Name: player_movement(); Type: PROCEDURE; Schema: world; Owner: postgres
--

CREATE PROCEDURE world.player_movement()
    LANGUAGE plpgsql
    AS $$
BEGIN
    

UPDATE world.map_tiles_players_positions mp
    SET
        map_tile_x = T1.x,
        map_tile_y = T1.y
    FROM (
        SELECT DISTINCT ON (player_id)
               player_id,
               (method_parameters->>'x')::int AS x,
               (method_parameters->>'y')::int AS y,
               (method_parameters->>'mapId')::int AS map_id
        FROM tasks.tasks
        WHERE method_name = 'world.player_movement'
          AND status IN (1, 2)
          AND scheduled_at <= now()
        ORDER BY
            player_id,
            (method_parameters->>'totalMoveCost')::int DESC
    ) T1
    WHERE mp.player_id = T1.player_id
    AND mp.map_id = T1.map_id;
    
    

    UPDATE tasks.tasks
    SET status = 3
    WHERE method_name = 'world.player_movement'
      AND status IN (1, 2)
      AND scheduled_at <= now();
    
    
END;
$$;


ALTER PROCEDURE world.player_movement() OWNER TO postgres;

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
-- TOC entry 5451 (class 0 OID 22436)
-- Dependencies: 233
-- Data for Name: abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.abilities (id, name, description, image) FROM stdin;
2	Explore	Explore new land's	Eye
1	Colonize	Settle Nomad's	Tent
\.


--
-- TOC entry 5469 (class 0 OID 22631)
-- Dependencies: 251
-- Data for Name: ability_skill_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_skill_requirements (ability_id, skill_id, min_value) FROM stdin;
1	1	1
2	2	1
\.


--
-- TOC entry 5470 (class 0 OID 22638)
-- Dependencies: 252
-- Data for Name: ability_stat_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_stat_requirements (ability_id, stat_id, min_value) FROM stdin;
\.


--
-- TOC entry 5452 (class 0 OID 22446)
-- Dependencies: 234
-- Data for Name: player_abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_abilities (id, player_id, ability_id, value) FROM stdin;
1	1	1	1
3	2	1	1
4	2	2	1
5	3	1	1
6	3	2	1
7	4	1	1
8	4	2	1
\.


--
-- TOC entry 5472 (class 0 OID 22646)
-- Dependencies: 254
-- Data for Name: player_skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_skills (id, player_id, skill_id, value) FROM stdin;
1	1	1	1
2	1	2	1
3	1	3	7
4	2	1	8
5	2	2	5
6	2	3	1
7	3	1	2
8	3	2	1
9	3	3	4
10	4	1	2
11	4	2	6
12	4	3	10
\.


--
-- TOC entry 5474 (class 0 OID 22654)
-- Dependencies: 256
-- Data for Name: player_stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_stats (id, player_id, stat_id, value) FROM stdin;
1	1	1	7
2	1	3	4
3	1	4	6
4	1	5	4
5	1	6	5
6	1	7	3
7	1	2	10
8	2	1	8
9	2	3	8
10	2	4	9
11	2	5	6
12	2	6	6
13	2	7	6
14	2	2	3
15	3	1	9
16	3	3	2
17	3	4	8
18	3	5	3
19	3	6	10
20	3	7	5
21	3	2	3
22	4	1	3
23	4	3	8
24	4	4	4
25	4	5	1
26	4	6	8
27	4	7	9
28	4	2	1
\.


--
-- TOC entry 5453 (class 0 OID 22458)
-- Dependencies: 235
-- Data for Name: roles; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.roles (id, name) FROM stdin;
1	Owner
\.


--
-- TOC entry 5454 (class 0 OID 22464)
-- Dependencies: 236
-- Data for Name: skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.skills (id, name, description, image) FROM stdin;
1	Colonization	Settle new world's !	Tent
2	Survival	Navigate wilderness and find resources stay alive	TreePine
3	Trade	How cheap can you buy ?	HandCoinsIcon
\.


--
-- TOC entry 5455 (class 0 OID 22474)
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
-- TOC entry 5479 (class 0 OID 22665)
-- Dependencies: 261
-- Data for Name: accounts; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.accounts (id, "userId", type, provider, "providerAccountId", refresh_token, access_token, expires_at, id_token, scope, session_state, token_type) FROM stdin;
\.


--
-- TOC entry 5481 (class 0 OID 22676)
-- Dependencies: 263
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.sessions (id, "userId", expires, "sessionToken") FROM stdin;
\.


--
-- TOC entry 5483 (class 0 OID 22684)
-- Dependencies: 265
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.users (id, name, email, "emailVerified", image, password) FROM stdin;
1	ciabat	pszabat001@gmail.com	\N	\N	$2b$10$4IQKRdaQ8l29u9KEdy6G6esjYGPJe9rQsWlAqPSe0OgbzyjsV6rCW
3	\N	example@example.com	\N	\N	$2b$10$mA6YTp9nbDRMb2LbiCg0oOS3d0ivwISpT3Fp7JPmGvWkGJ840I9kW
\.


--
-- TOC entry 5485 (class 0 OID 22691)
-- Dependencies: 267
-- Data for Name: verification_token; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.verification_token (identifier, expires, token) FROM stdin;
\.


--
-- TOC entry 5486 (class 0 OID 22699)
-- Dependencies: 268
-- Data for Name: building_roles; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_roles (building_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5456 (class 0 OID 22487)
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
-- TOC entry 5457 (class 0 OID 22494)
-- Dependencies: 239
-- Data for Name: buildings; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.buildings (id, city_id, city_tile_x, city_tile_y, building_type_id, name) FROM stdin;
\.


--
-- TOC entry 5458 (class 0 OID 22505)
-- Dependencies: 240
-- Data for Name: cities; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.cities (id, map_id, map_tile_x, map_tile_y, name, move_cost, image_url) FROM stdin;
\.


--
-- TOC entry 5490 (class 0 OID 22708)
-- Dependencies: 272
-- Data for Name: city_roles; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.city_roles (city_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5459 (class 0 OID 22516)
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
-- TOC entry 5491 (class 0 OID 22714)
-- Dependencies: 273
-- Data for Name: district_roles; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_roles (district_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5460 (class 0 OID 22527)
-- Dependencies: 242
-- Data for Name: district_types; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_types (id, name, move_cost, image_url) FROM stdin;
1	Farmland	1	full_farmland.png
\.


--
-- TOC entry 5461 (class 0 OID 22535)
-- Dependencies: 243
-- Data for Name: districts; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.districts (id, map_id, map_tile_x, map_tile_y, district_type_id, name) FROM stdin;
\.


--
-- TOC entry 5526 (class 0 OID 25486)
-- Dependencies: 310
-- Data for Name: inventory_container_player_access; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_container_player_access (inventory_container_id, player_id) FROM stdin;
1	4
7	4
8	4
2	4
\.


--
-- TOC entry 5494 (class 0 OID 22722)
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
-- TOC entry 5496 (class 0 OID 22727)
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
-- TOC entry 5498 (class 0 OID 22737)
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
-- TOC entry 5462 (class 0 OID 22557)
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
-- TOC entry 5500 (class 0 OID 22743)
-- Dependencies: 282
-- Data for Name: inventory_slots; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slots (id, inventory_container_id, item_id, quantity, inventory_slot_type_id) FROM stdin;
6	1	\N	\N	1
7	1	\N	\N	1
8	1	\N	\N	1
9	1	\N	\N	1
12	2	\N	\N	4
16	2	\N	\N	8
19	2	\N	\N	11
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
82	8	\N	\N	8
85	8	\N	\N	11
67	7	\N	\N	1
2	1	\N	\N	1
21	2	\N	\N	13
20	2	2	1	12
17	2	\N	\N	9
11	2	\N	\N	3
13	2	\N	\N	5
10	2	\N	\N	2
22	2	\N	\N	14
74	7	\N	\N	1
75	7	\N	\N	1
3	1	1	1	1
1	1	\N	\N	1
15	2	\N	\N	7
4	1	\N	\N	1
5	1	\N	\N	1
83	8	\N	\N	9
77	8	\N	\N	3
14	2	\N	\N	6
18	2	\N	\N	10
84	8	\N	\N	10
87	8	\N	\N	13
68	7	\N	\N	1
78	8	\N	\N	4
69	7	\N	\N	1
70	7	\N	\N	1
76	8	\N	\N	2
71	7	\N	\N	1
88	8	\N	\N	14
72	7	\N	\N	1
73	7	\N	\N	1
86	8	\N	\N	12
81	8	\N	\N	7
80	8	\N	\N	6
79	8	\N	\N	5
\.


--
-- TOC entry 5463 (class 0 OID 22568)
-- Dependencies: 245
-- Data for Name: item_stats; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_stats (id, item_id, stat_id, value) FROM stdin;
\.


--
-- TOC entry 5503 (class 0 OID 22752)
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
-- TOC entry 5464 (class 0 OID 22577)
-- Dependencies: 246
-- Data for Name: items; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.items (id, name, description, image, item_type_id) FROM stdin;
1	Food	\N	Herbalism	1
2	Sword	\N	Sword	5
3	Helmet	\N	default.png	2
4	Wood	\N	default.png	1
5	Stone	\N	default.png	1
\.


--
-- TOC entry 5523 (class 0 OID 23161)
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
1	1	16	1
1	1	17	1
1	1	18	1
1	1	19	1
1	1	20	1
1	1	21	1
1	1	22	1
1	1	23	1
1	1	24	1
1	1	25	1
1	1	26	1
1	1	27	1
1	1	28	1
1	1	29	1
1	1	30	1
1	1	31	1
1	1	32	1
1	1	33	1
1	1	34	1
1	1	35	1
1	1	36	1
1	1	37	1
1	1	38	1
1	1	39	1
1	1	40	1
1	1	41	1
1	1	42	1
1	1	43	1
1	1	44	1
1	1	45	1
1	1	46	1
1	1	47	1
1	1	48	1
1	1	49	1
1	1	50	1
1	1	51	1
1	1	52	1
1	1	53	1
1	1	54	1
1	1	55	1
1	1	56	1
1	1	57	1
1	1	58	1
1	1	59	1
1	1	60	1
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
1	1	16	2
1	1	17	2
1	1	18	2
1	1	19	2
1	1	20	2
1	1	21	2
1	1	22	2
1	1	23	2
1	1	24	2
1	1	25	2
1	1	26	2
1	1	27	2
1	1	28	2
1	1	29	2
1	1	30	2
1	1	31	2
1	1	32	2
1	1	33	2
1	1	34	2
1	1	35	2
1	1	36	2
1	1	37	2
1	1	38	2
1	1	39	2
1	1	40	2
1	1	41	2
1	1	42	2
1	1	43	2
1	1	44	2
1	1	45	2
1	1	46	2
1	1	47	2
1	1	48	2
1	1	49	2
1	1	50	2
1	1	51	2
1	1	52	2
1	1	53	2
1	1	54	2
1	1	55	2
1	1	56	2
1	1	57	2
1	1	58	2
1	1	59	2
1	1	60	2
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
1	1	16	3
1	1	17	3
1	1	18	3
1	1	19	3
1	1	20	3
1	1	21	3
1	1	22	3
1	1	23	3
1	1	24	3
1	1	25	3
1	1	26	3
1	1	27	3
1	1	28	3
1	1	29	3
1	1	30	3
1	1	31	3
1	1	32	3
1	1	33	3
1	1	34	3
1	1	35	3
1	1	36	3
1	1	37	3
1	1	38	3
1	1	39	3
1	1	40	3
1	1	41	3
1	1	42	3
1	1	43	3
1	1	44	3
1	1	45	3
1	1	46	3
1	1	47	3
1	1	48	3
1	1	49	3
1	1	50	3
1	1	51	3
1	1	52	3
1	1	53	3
1	1	54	3
1	1	55	3
1	1	56	3
1	1	57	3
1	1	58	3
1	1	59	3
1	1	60	3
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
1	1	16	4
1	1	17	4
1	1	18	4
1	1	19	4
1	1	20	4
1	1	21	4
1	1	22	4
1	1	23	4
1	1	24	4
1	1	25	4
1	1	26	4
1	1	27	4
1	1	28	4
1	1	29	4
1	1	30	4
1	1	31	4
1	1	32	4
1	1	33	4
1	1	34	4
1	1	35	4
1	1	36	4
1	1	37	4
1	1	38	4
1	1	39	4
1	1	40	4
1	1	41	4
1	1	42	4
1	1	43	4
1	1	44	4
1	1	45	4
1	1	46	4
1	1	47	4
1	1	48	4
1	1	49	4
1	1	50	4
1	1	51	4
1	1	52	4
1	1	53	4
1	1	54	4
1	1	55	4
1	1	56	4
1	1	57	4
1	1	58	4
1	1	59	4
1	1	60	4
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
1	1	16	5
1	1	17	5
1	1	18	5
1	1	19	5
1	1	20	5
1	1	21	5
1	1	22	5
1	1	23	5
1	1	24	5
1	1	25	5
1	1	26	5
1	1	27	5
1	1	28	5
1	1	29	5
1	1	30	5
1	1	31	5
1	1	32	5
1	1	33	5
1	1	34	5
1	1	35	5
1	1	36	5
1	1	37	5
1	1	38	5
1	1	39	5
1	1	40	5
1	1	41	5
1	1	42	5
1	1	43	5
1	1	44	5
1	1	45	5
1	1	46	5
1	1	47	5
1	1	48	5
1	1	49	5
1	1	50	5
1	1	51	5
1	1	52	5
1	1	53	5
1	1	54	5
1	1	55	5
1	1	56	5
1	1	57	5
1	1	58	5
1	1	59	5
1	1	60	5
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
1	1	16	6
1	1	17	6
1	1	18	6
1	1	19	6
1	1	20	6
1	1	21	6
1	1	22	6
1	1	23	6
1	1	24	6
1	1	25	6
1	1	26	6
1	1	27	6
1	1	28	6
1	1	29	6
1	1	30	6
1	1	31	6
1	1	32	6
1	1	33	6
1	1	34	6
1	1	35	6
1	1	36	6
1	1	37	6
1	1	38	6
1	1	39	6
1	1	40	6
1	1	41	6
1	1	42	6
1	1	43	6
1	1	44	6
1	1	45	6
1	1	46	6
1	1	47	6
1	1	48	6
1	1	49	6
1	1	50	6
1	1	51	6
1	1	52	6
1	1	53	6
1	1	54	6
1	1	55	6
1	1	56	6
1	1	57	6
1	1	58	6
1	1	59	6
1	1	60	6
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
1	1	16	7
1	1	17	7
1	1	18	7
1	1	19	7
1	1	20	7
1	1	21	7
1	1	22	7
1	1	23	7
1	1	24	7
1	1	25	7
1	1	26	7
1	1	27	7
1	1	28	7
1	1	29	7
1	1	30	7
1	1	31	7
1	1	32	7
1	1	33	7
1	1	34	7
1	1	35	7
1	1	36	7
1	1	37	7
1	1	38	7
1	1	39	7
1	1	40	7
1	1	41	7
1	1	42	7
1	1	43	7
1	1	44	7
1	1	45	7
1	1	46	7
1	1	47	7
1	1	48	7
1	1	49	7
1	1	50	7
1	1	51	7
1	1	52	7
1	1	53	7
1	1	54	7
1	1	55	7
1	1	56	7
1	1	57	7
1	1	58	7
1	1	59	7
1	1	60	7
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
1	1	16	8
1	1	17	8
1	1	18	8
1	1	19	8
1	1	20	8
1	1	21	8
1	1	22	8
1	1	23	8
1	1	24	8
1	1	25	8
1	1	26	8
1	1	27	8
1	1	28	8
1	1	29	8
1	1	30	8
1	1	31	8
1	1	32	8
1	1	33	8
1	1	34	8
1	1	35	8
1	1	36	8
1	1	37	8
1	1	38	8
1	1	39	8
1	1	40	8
1	1	41	8
1	1	42	8
1	1	43	8
1	1	44	8
1	1	45	8
1	1	46	8
1	1	47	8
1	1	48	8
1	1	49	8
1	1	50	8
1	1	51	8
1	1	52	8
1	1	53	8
1	1	54	8
1	1	55	8
1	1	56	8
1	1	57	8
1	1	58	8
1	1	59	8
1	1	60	8
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
1	1	16	9
1	1	17	9
1	1	18	9
1	1	19	9
1	1	20	9
1	1	21	9
1	1	22	9
1	1	23	9
1	1	24	9
1	1	25	9
1	1	26	9
1	1	27	9
1	1	28	9
1	1	29	9
1	1	30	9
1	1	31	9
1	1	32	9
1	1	33	9
1	1	34	9
1	1	35	9
1	1	36	9
1	1	37	9
1	1	38	9
1	1	39	9
1	1	40	9
1	1	41	9
1	1	42	9
1	1	43	9
1	1	44	9
1	1	45	9
1	1	46	9
1	1	47	9
1	1	48	9
1	1	49	9
1	1	50	9
1	1	51	9
1	1	52	9
1	1	53	9
1	1	54	9
1	1	55	9
1	1	56	9
1	1	57	9
1	1	58	9
1	1	59	9
1	1	60	9
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
1	1	16	10
1	1	17	10
1	1	18	10
1	1	19	10
1	1	20	10
1	1	21	10
1	1	22	10
1	1	23	10
1	1	24	10
1	1	25	10
1	1	26	10
1	1	27	10
1	1	28	10
1	1	29	10
1	1	30	10
1	1	31	10
1	1	32	10
1	1	33	10
1	1	34	10
1	1	35	10
1	1	36	10
1	1	37	10
1	1	38	10
1	1	39	10
1	1	40	10
1	1	41	10
1	1	42	10
1	1	43	10
1	1	44	10
1	1	45	10
1	1	46	10
1	1	47	10
1	1	48	10
1	1	49	10
1	1	50	10
1	1	51	10
1	1	52	10
1	1	53	10
1	1	54	10
1	1	55	10
1	1	56	10
1	1	57	10
1	1	58	10
1	1	59	10
1	1	60	10
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
1	1	16	11
1	1	17	11
1	1	18	11
1	1	19	11
1	1	20	11
1	1	21	11
1	1	22	11
1	1	23	11
1	1	24	11
1	1	25	11
1	1	26	11
1	1	27	11
1	1	28	11
1	1	29	11
1	1	30	11
1	1	31	11
1	1	32	11
1	1	33	11
1	1	34	11
1	1	35	11
1	1	36	11
1	1	37	11
1	1	38	11
1	1	39	11
1	1	40	11
1	1	41	11
1	1	42	11
1	1	43	11
1	1	44	11
1	1	45	11
1	1	46	11
1	1	47	11
1	1	48	11
1	1	49	11
1	1	50	11
1	1	51	11
1	1	52	11
1	1	53	11
1	1	54	11
1	1	55	11
1	1	56	11
1	1	57	11
1	1	58	11
1	1	59	11
1	1	60	11
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
1	1	16	12
1	1	17	12
1	1	18	12
1	1	19	12
1	1	20	12
1	1	21	12
1	1	22	12
1	1	23	12
1	1	24	12
1	1	25	12
1	1	26	12
1	1	27	12
1	1	28	12
1	1	29	12
1	1	30	12
1	1	31	12
1	1	32	12
1	1	33	12
1	1	34	12
1	1	35	12
1	1	36	12
1	1	37	12
1	1	38	12
1	1	39	12
1	1	40	12
1	1	41	12
1	1	42	12
1	1	43	12
1	1	44	12
1	1	45	12
1	1	46	12
1	1	47	12
1	1	48	12
1	1	49	12
1	1	50	12
1	1	51	12
1	1	52	12
1	1	53	12
1	1	54	12
1	1	55	12
1	1	56	12
1	1	57	12
1	1	58	12
1	1	59	12
1	1	60	12
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
1	1	16	13
1	1	17	13
1	1	18	13
1	1	19	13
1	1	20	13
1	1	21	13
1	1	22	13
1	1	23	13
1	1	24	13
1	1	25	13
1	1	26	13
1	1	27	13
1	1	28	13
1	1	29	13
1	1	30	13
1	1	31	13
1	1	32	13
1	1	33	13
1	1	34	13
1	1	35	13
1	1	36	13
1	1	37	13
1	1	38	13
1	1	39	13
1	1	40	13
1	1	41	13
1	1	42	13
1	1	43	13
1	1	44	13
1	1	45	13
1	1	46	13
1	1	47	13
1	1	48	13
1	1	49	13
1	1	50	13
1	1	51	13
1	1	52	13
1	1	53	13
1	1	54	13
1	1	55	13
1	1	56	13
1	1	57	13
1	1	58	13
1	1	59	13
1	1	60	13
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
1	1	16	14
1	1	17	14
1	1	18	14
1	1	19	14
1	1	20	14
1	1	21	14
1	1	22	14
1	1	23	14
1	1	24	14
1	1	25	14
1	1	26	14
1	1	27	14
1	1	28	14
1	1	29	14
1	1	30	14
1	1	31	14
1	1	32	14
1	1	33	14
1	1	34	14
1	1	35	14
1	1	36	14
1	1	37	14
1	1	38	14
1	1	39	14
1	1	40	14
1	1	41	14
1	1	42	14
1	1	43	14
1	1	44	14
1	1	45	14
1	1	46	14
1	1	47	14
1	1	48	14
1	1	49	14
1	1	50	14
1	1	51	14
1	1	52	14
1	1	53	14
1	1	54	14
1	1	55	14
1	1	56	14
1	1	57	14
1	1	58	14
1	1	59	14
1	1	60	14
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
1	1	16	15
1	1	17	15
1	1	18	15
1	1	19	15
1	1	20	15
1	1	21	15
1	1	22	15
1	1	23	15
1	1	24	15
1	1	25	15
1	1	26	15
1	1	27	15
1	1	28	15
1	1	29	15
1	1	30	15
1	1	31	15
1	1	32	15
1	1	33	15
1	1	34	15
1	1	35	15
1	1	36	15
1	1	37	15
1	1	38	15
1	1	39	15
1	1	40	15
1	1	41	15
1	1	42	15
1	1	43	15
1	1	44	15
1	1	45	15
1	1	46	15
1	1	47	15
1	1	48	15
1	1	49	15
1	1	50	15
1	1	51	15
1	1	52	15
1	1	53	15
1	1	54	15
1	1	55	15
1	1	56	15
1	1	57	15
1	1	58	15
1	1	59	15
1	1	60	15
1	1	1	16
1	1	2	16
1	1	3	16
1	1	4	16
1	1	5	16
1	1	6	16
1	1	7	16
1	1	8	16
1	1	9	16
1	1	10	16
1	1	11	16
1	1	12	16
1	1	13	16
1	1	14	16
1	1	15	16
1	1	16	16
1	1	17	16
1	1	18	16
1	1	19	16
1	1	20	16
1	1	21	16
1	1	22	16
1	1	23	16
1	1	24	16
1	1	25	16
1	1	26	16
1	1	27	16
1	1	28	16
1	1	29	16
1	1	30	16
1	1	31	16
1	1	32	16
1	1	33	16
1	1	34	16
1	1	35	16
1	1	36	16
1	1	37	16
1	1	38	16
1	1	39	16
1	1	40	16
1	1	41	16
1	1	42	16
1	1	43	16
1	1	44	16
1	1	45	16
1	1	46	16
1	1	47	16
1	1	48	16
1	1	49	16
1	1	50	16
1	1	51	16
1	1	52	16
1	1	53	16
1	1	54	16
1	1	55	16
1	1	56	16
1	1	57	16
1	1	58	16
1	1	59	16
1	1	60	16
1	1	1	17
1	1	2	17
1	1	3	17
1	1	4	17
1	1	5	17
1	1	6	17
1	1	7	17
1	1	8	17
1	1	9	17
1	1	10	17
1	1	11	17
1	1	12	17
1	1	13	17
1	1	14	17
1	1	15	17
1	1	16	17
1	1	17	17
1	1	18	17
1	1	19	17
1	1	20	17
1	1	21	17
1	1	22	17
1	1	23	17
1	1	24	17
1	1	25	17
1	1	26	17
1	1	27	17
1	1	28	17
1	1	29	17
1	1	30	17
1	1	31	17
1	1	32	17
1	1	33	17
1	1	34	17
1	1	35	17
1	1	36	17
1	1	37	17
1	1	38	17
1	1	39	17
1	1	40	17
1	1	41	17
1	1	42	17
1	1	43	17
1	1	44	17
1	1	45	17
1	1	46	17
1	1	47	17
1	1	48	17
1	1	49	17
1	1	50	17
1	1	51	17
1	1	52	17
1	1	53	17
1	1	54	17
1	1	55	17
1	1	56	17
1	1	57	17
1	1	58	17
1	1	59	17
1	1	60	17
1	1	1	18
1	1	2	18
1	1	3	18
1	1	4	18
1	1	5	18
1	1	6	18
1	1	7	18
1	1	8	18
1	1	9	18
1	1	10	18
1	1	11	18
1	1	12	18
1	1	13	18
1	1	14	18
1	1	15	18
1	1	16	18
1	1	17	18
1	1	18	18
1	1	19	18
1	1	20	18
1	1	21	18
1	1	22	18
1	1	23	18
1	1	24	18
1	1	25	18
1	1	26	18
1	1	27	18
1	1	28	18
1	1	29	18
1	1	30	18
1	1	31	18
1	1	32	18
1	1	33	18
1	1	34	18
1	1	35	18
1	1	36	18
1	1	37	18
1	1	38	18
1	1	39	18
1	1	40	18
1	1	41	18
1	1	42	18
1	1	43	18
1	1	44	18
1	1	45	18
1	1	46	18
1	1	47	18
1	1	48	18
1	1	49	18
1	1	50	18
1	1	51	18
1	1	52	18
1	1	53	18
1	1	54	18
1	1	55	18
1	1	56	18
1	1	57	18
1	1	58	18
1	1	59	18
1	1	60	18
1	1	1	19
1	1	2	19
1	1	3	19
1	1	4	19
1	1	5	19
1	1	6	19
1	1	7	19
1	1	8	19
1	1	9	19
1	1	10	19
1	1	11	19
1	1	12	19
1	1	13	19
1	1	14	19
1	1	15	19
1	1	16	19
1	1	17	19
1	1	18	19
1	1	19	19
1	1	20	19
1	1	21	19
1	1	22	19
1	1	23	19
1	1	24	19
1	1	25	19
1	1	26	19
1	1	27	19
1	1	28	19
1	1	29	19
1	1	30	19
1	1	31	19
1	1	32	19
1	1	33	19
1	1	34	19
1	1	35	19
1	1	36	19
1	1	37	19
1	1	38	19
1	1	39	19
1	1	40	19
1	1	41	19
1	1	42	19
1	1	43	19
1	1	44	19
1	1	45	19
1	1	46	19
1	1	47	19
1	1	48	19
1	1	49	19
1	1	50	19
1	1	51	19
1	1	52	19
1	1	53	19
1	1	54	19
1	1	55	19
1	1	56	19
1	1	57	19
1	1	58	19
1	1	59	19
1	1	60	19
1	1	1	20
1	1	2	20
1	1	3	20
1	1	4	20
1	1	5	20
1	1	6	20
1	1	7	20
1	1	8	20
1	1	9	20
1	1	10	20
1	1	11	20
1	1	12	20
1	1	13	20
1	1	14	20
1	1	15	20
1	1	16	20
1	1	17	20
1	1	18	20
1	1	19	20
1	1	20	20
1	1	21	20
1	1	22	20
1	1	23	20
1	1	24	20
1	1	25	20
1	1	26	20
1	1	27	20
1	1	28	20
1	1	29	20
1	1	30	20
1	1	31	20
1	1	32	20
1	1	33	20
1	1	34	20
1	1	35	20
1	1	36	20
1	1	37	20
1	1	38	20
1	1	39	20
1	1	40	20
1	1	41	20
1	1	42	20
1	1	43	20
1	1	44	20
1	1	45	20
1	1	46	20
1	1	47	20
1	1	48	20
1	1	49	20
1	1	50	20
1	1	51	20
1	1	52	20
1	1	53	20
1	1	54	20
1	1	55	20
1	1	56	20
1	1	57	20
1	1	58	20
1	1	59	20
1	1	60	20
1	1	1	21
1	1	2	21
1	1	3	21
1	1	4	21
1	1	5	21
1	1	6	21
1	1	7	21
1	1	8	21
1	1	9	21
1	1	10	21
1	1	11	21
1	1	12	21
1	1	13	21
1	1	14	21
1	1	15	21
1	1	16	21
1	1	17	21
1	1	18	21
1	1	19	21
1	1	20	21
1	1	21	21
1	1	22	21
1	1	23	21
1	1	24	21
1	1	25	21
1	1	26	21
1	1	27	21
1	1	28	21
1	1	29	21
1	1	30	21
1	1	31	21
1	1	32	21
1	1	33	21
1	1	34	21
1	1	35	21
1	1	36	21
1	1	37	21
1	1	38	21
1	1	39	21
1	1	40	21
1	1	41	21
1	1	42	21
1	1	43	21
1	1	44	21
1	1	45	21
1	1	46	21
1	1	47	21
1	1	48	21
1	1	49	21
1	1	50	21
1	1	51	21
1	1	52	21
1	1	53	21
1	1	54	21
1	1	55	21
1	1	56	21
1	1	57	21
1	1	58	21
1	1	59	21
1	1	60	21
1	1	1	22
1	1	2	22
1	1	3	22
1	1	4	22
1	1	5	22
1	1	6	22
1	1	7	22
1	1	8	22
1	1	9	22
1	1	10	22
1	1	11	22
1	1	12	22
1	1	13	22
1	1	14	22
1	1	15	22
1	1	16	22
1	1	17	22
1	1	18	22
1	1	19	22
1	1	20	22
1	1	21	22
1	1	22	22
1	1	23	22
1	1	24	22
1	1	25	22
1	1	26	22
1	1	27	22
1	1	28	22
1	1	29	22
1	1	30	22
1	1	31	22
1	1	32	22
1	1	33	22
1	1	34	22
1	1	35	22
1	1	36	22
1	1	37	22
1	1	38	22
1	1	39	22
1	1	40	22
1	1	41	22
1	1	42	22
1	1	43	22
1	1	44	22
1	1	45	22
1	1	46	22
1	1	47	22
1	1	48	22
1	1	49	22
1	1	50	22
1	1	51	22
1	1	52	22
1	1	53	22
1	1	54	22
1	1	55	22
1	1	56	22
1	1	57	22
1	1	58	22
1	1	59	22
1	1	60	22
1	1	1	23
1	1	2	23
1	1	3	23
1	1	4	23
1	1	5	23
1	1	6	23
1	1	7	23
1	1	8	23
1	1	9	23
1	1	10	23
1	1	11	23
1	1	12	23
1	1	13	23
1	1	14	23
1	1	15	23
1	1	16	23
1	1	17	23
1	1	18	23
1	1	19	23
1	1	20	23
1	1	21	23
1	1	22	23
1	1	23	23
1	1	24	23
1	1	25	23
1	1	26	23
1	1	27	23
1	1	28	23
1	1	29	23
1	1	30	23
1	1	31	23
1	1	32	23
1	1	33	23
1	1	34	23
1	1	35	23
1	1	36	23
1	1	37	23
1	1	38	23
1	1	39	23
1	1	40	23
1	1	41	23
1	1	42	23
1	1	43	23
1	1	44	23
1	1	45	23
1	1	46	23
1	1	47	23
1	1	48	23
1	1	49	23
1	1	50	23
1	1	51	23
1	1	52	23
1	1	53	23
1	1	54	23
1	1	55	23
1	1	56	23
1	1	57	23
1	1	58	23
1	1	59	23
1	1	60	23
1	1	1	24
1	1	2	24
1	1	3	24
1	1	4	24
1	1	5	24
1	1	6	24
1	1	7	24
1	1	8	24
1	1	9	24
1	1	10	24
1	1	11	24
1	1	12	24
1	1	13	24
1	1	14	24
1	1	15	24
1	1	16	24
1	1	17	24
1	1	18	24
1	1	19	24
1	1	20	24
1	1	21	24
1	1	22	24
1	1	23	24
1	1	24	24
1	1	25	24
1	1	26	24
1	1	27	24
1	1	28	24
1	1	29	24
1	1	30	24
1	1	31	24
1	1	32	24
1	1	33	24
1	1	34	24
1	1	35	24
1	1	36	24
1	1	37	24
1	1	38	24
1	1	39	24
1	1	40	24
1	1	41	24
1	1	42	24
1	1	43	24
1	1	44	24
1	1	45	24
1	1	46	24
1	1	47	24
1	1	48	24
1	1	49	24
1	1	50	24
1	1	51	24
1	1	52	24
1	1	53	24
1	1	54	24
1	1	55	24
1	1	56	24
1	1	57	24
1	1	58	24
1	1	59	24
1	1	60	24
1	1	1	25
1	1	2	25
1	1	3	25
1	1	4	25
1	1	5	25
1	1	6	25
1	1	7	25
1	1	8	25
1	1	9	25
1	1	10	25
1	1	11	25
1	1	12	25
1	1	13	25
1	1	14	25
1	1	15	25
1	1	16	25
1	1	17	25
1	1	18	25
1	1	19	25
1	1	20	25
1	1	21	25
1	1	22	25
1	1	23	25
1	1	24	25
1	1	25	25
1	1	26	25
1	1	27	25
1	1	28	25
1	1	29	25
1	1	30	25
1	1	31	25
1	1	32	25
1	1	33	25
1	1	34	25
1	1	35	25
1	1	36	25
1	1	37	25
1	1	38	25
1	1	39	25
1	1	40	25
1	1	41	25
1	1	42	25
1	1	43	25
1	1	44	25
1	1	45	25
1	1	46	25
1	1	47	25
1	1	48	25
1	1	49	25
1	1	50	25
1	1	51	25
1	1	52	25
1	1	53	25
1	1	54	25
1	1	55	25
1	1	56	25
1	1	57	25
1	1	58	25
1	1	59	25
1	1	60	25
1	1	1	26
1	1	2	26
1	1	3	26
1	1	4	26
1	1	5	26
1	1	6	26
1	1	7	26
1	1	8	26
1	1	9	26
1	1	10	26
1	1	11	26
1	1	12	26
1	1	13	26
1	1	14	26
1	1	15	26
1	1	16	26
1	1	17	26
1	1	18	26
1	1	19	26
1	1	20	26
1	1	21	26
1	1	22	26
1	1	23	26
1	1	24	26
1	1	25	26
1	1	26	26
1	1	27	26
1	1	28	26
1	1	29	26
1	1	30	26
1	1	31	26
1	1	32	26
1	1	33	26
1	1	34	26
1	1	35	26
1	1	36	26
1	1	37	26
1	1	38	26
1	1	39	26
1	1	40	26
1	1	41	26
1	1	42	26
1	1	43	26
1	1	44	26
1	1	45	26
1	1	46	26
1	1	47	26
1	1	48	26
1	1	49	26
1	1	50	26
1	1	51	26
1	1	52	26
1	1	53	26
1	1	54	26
1	1	55	26
1	1	56	26
1	1	57	26
1	1	58	26
1	1	59	26
1	1	60	26
1	1	1	27
1	1	2	27
1	1	3	27
1	1	4	27
1	1	5	27
1	1	6	27
1	1	7	27
1	1	8	27
1	1	9	27
1	1	10	27
1	1	11	27
1	1	12	27
1	1	13	27
1	1	14	27
1	1	15	27
1	1	16	27
1	1	17	27
1	1	18	27
1	1	19	27
1	1	20	27
1	1	21	27
1	1	22	27
1	1	23	27
1	1	24	27
1	1	25	27
1	1	26	27
1	1	27	27
1	1	28	27
1	1	29	27
1	1	30	27
1	1	31	27
1	1	32	27
1	1	33	27
1	1	34	27
1	1	35	27
1	1	36	27
1	1	37	27
1	1	38	27
1	1	39	27
1	1	40	27
1	1	41	27
1	1	42	27
1	1	43	27
1	1	44	27
1	1	45	27
1	1	46	27
1	1	47	27
1	1	48	27
1	1	49	27
1	1	50	27
1	1	51	27
1	1	52	27
1	1	53	27
1	1	54	27
1	1	55	27
1	1	56	27
1	1	57	27
1	1	58	27
1	1	59	27
1	1	60	27
1	1	1	28
1	1	2	28
1	1	3	28
1	1	4	28
1	1	5	28
1	1	6	28
1	1	7	28
1	1	8	28
1	1	9	28
1	1	10	28
1	1	11	28
1	1	12	28
1	1	13	28
1	1	14	28
1	1	15	28
1	1	16	28
1	1	17	28
1	1	18	28
1	1	19	28
1	1	20	28
1	1	21	28
1	1	22	28
1	1	23	28
1	1	24	28
1	1	25	28
1	1	26	28
1	1	27	28
1	1	28	28
1	1	29	28
1	1	30	28
1	1	31	28
1	1	32	28
1	1	33	28
1	1	34	28
1	1	35	28
1	1	36	28
1	1	37	28
1	1	38	28
1	1	39	28
1	1	40	28
1	1	41	28
1	1	42	28
1	1	43	28
1	1	44	28
1	1	45	28
1	1	46	28
1	1	47	28
1	1	48	28
1	1	49	28
1	1	50	28
1	1	51	28
1	1	52	28
1	1	53	28
1	1	54	28
1	1	55	28
1	1	56	28
1	1	57	28
1	1	58	28
1	1	59	28
1	1	60	28
1	1	1	29
1	1	2	29
1	1	3	29
1	1	4	29
1	1	5	29
1	1	6	29
1	1	7	29
1	1	8	29
1	1	9	29
1	1	10	29
1	1	11	29
1	1	12	29
1	1	13	29
1	1	14	29
1	1	15	29
1	1	16	29
1	1	17	29
1	1	18	29
1	1	19	29
1	1	20	29
1	1	21	29
1	1	22	29
1	1	23	29
1	1	24	29
1	1	25	29
1	1	26	29
1	1	27	29
1	1	28	29
1	1	29	29
1	1	30	29
1	1	31	29
1	1	32	29
1	1	33	29
1	1	34	29
1	1	35	29
1	1	36	29
1	1	37	29
1	1	38	29
1	1	39	29
1	1	40	29
1	1	41	29
1	1	42	29
1	1	43	29
1	1	44	29
1	1	45	29
1	1	46	29
1	1	47	29
1	1	48	29
1	1	49	29
1	1	50	29
1	1	51	29
1	1	52	29
1	1	53	29
1	1	54	29
1	1	55	29
1	1	56	29
1	1	57	29
1	1	58	29
1	1	59	29
1	1	60	29
1	1	1	30
1	1	2	30
1	1	3	30
1	1	4	30
1	1	5	30
1	1	6	30
1	1	7	30
1	1	8	30
1	1	9	30
1	1	10	30
1	1	11	30
1	1	12	30
1	1	13	30
1	1	14	30
1	1	15	30
1	1	16	30
1	1	17	30
1	1	18	30
1	1	19	30
1	1	20	30
1	1	21	30
1	1	22	30
1	1	23	30
1	1	24	30
1	1	25	30
1	1	26	30
1	1	27	30
1	1	28	30
1	1	29	30
1	1	30	30
1	1	31	30
1	1	32	30
1	1	33	30
1	1	34	30
1	1	35	30
1	1	36	30
1	1	37	30
1	1	38	30
1	1	39	30
1	1	40	30
1	1	41	30
1	1	42	30
1	1	43	30
1	1	44	30
1	1	45	30
1	1	46	30
1	1	47	30
1	1	48	30
1	1	49	30
1	1	50	30
1	1	51	30
1	1	52	30
1	1	53	30
1	1	54	30
1	1	55	30
1	1	56	30
1	1	57	30
1	1	58	30
1	1	59	30
1	1	60	30
1	1	1	31
1	1	2	31
1	1	3	31
1	1	4	31
1	1	5	31
1	1	6	31
1	1	7	31
1	1	8	31
1	1	9	31
1	1	10	31
1	1	11	31
1	1	12	31
1	1	13	31
1	1	14	31
1	1	15	31
1	1	16	31
1	1	17	31
1	1	18	31
1	1	19	31
1	1	20	31
1	1	21	31
1	1	22	31
1	1	23	31
1	1	24	31
1	1	25	31
1	1	26	31
1	1	27	31
1	1	28	31
1	1	29	31
1	1	30	31
1	1	31	31
1	1	32	31
1	1	33	31
1	1	34	31
1	1	35	31
1	1	36	31
1	1	37	31
1	1	38	31
1	1	39	31
1	1	40	31
1	1	41	31
1	1	42	31
1	1	43	31
1	1	44	31
1	1	45	31
1	1	46	31
1	1	47	31
1	1	48	31
1	1	49	31
1	1	50	31
1	1	51	31
1	1	52	31
1	1	53	31
1	1	54	31
1	1	55	31
1	1	56	31
1	1	57	31
1	1	58	31
1	1	59	31
1	1	60	31
1	1	1	32
1	1	2	32
1	1	3	32
1	1	4	32
1	1	5	32
1	1	6	32
1	1	7	32
1	1	8	32
1	1	9	32
1	1	10	32
1	1	11	32
1	1	12	32
1	1	13	32
1	1	14	32
1	1	15	32
1	1	16	32
1	1	17	32
1	1	18	32
1	1	19	32
1	1	20	32
1	1	21	32
1	1	22	32
1	1	23	32
1	1	24	32
1	1	25	32
1	1	26	32
1	1	27	32
1	1	28	32
1	1	29	32
1	1	30	32
1	1	31	32
1	1	32	32
1	1	33	32
1	1	34	32
1	1	35	32
1	1	36	32
1	1	37	32
1	1	38	32
1	1	39	32
1	1	40	32
1	1	41	32
1	1	42	32
1	1	43	32
1	1	44	32
1	1	45	32
1	1	46	32
1	1	47	32
1	1	48	32
1	1	49	32
1	1	50	32
1	1	51	32
1	1	52	32
1	1	53	32
1	1	54	32
1	1	55	32
1	1	56	32
1	1	57	32
1	1	58	32
1	1	59	32
1	1	60	32
1	1	1	33
1	1	2	33
1	1	3	33
1	1	4	33
1	1	5	33
1	1	6	33
1	1	7	33
1	1	8	33
1	1	9	33
1	1	10	33
1	1	11	33
1	1	12	33
1	1	13	33
1	1	14	33
1	1	15	33
1	1	16	33
1	1	17	33
1	1	18	33
1	1	19	33
1	1	20	33
1	1	21	33
1	1	22	33
1	1	23	33
1	1	24	33
1	1	25	33
1	1	26	33
1	1	27	33
1	1	28	33
1	1	29	33
1	1	30	33
1	1	31	33
1	1	32	33
1	1	33	33
1	1	34	33
1	1	35	33
1	1	36	33
1	1	37	33
1	1	38	33
1	1	39	33
1	1	40	33
1	1	41	33
1	1	42	33
1	1	43	33
1	1	44	33
1	1	45	33
1	1	46	33
1	1	47	33
1	1	48	33
1	1	49	33
1	1	50	33
1	1	51	33
1	1	52	33
1	1	53	33
1	1	54	33
1	1	55	33
1	1	56	33
1	1	57	33
1	1	58	33
1	1	59	33
1	1	60	33
1	1	1	34
1	1	2	34
1	1	3	34
1	1	4	34
1	1	5	34
1	1	6	34
1	1	7	34
1	1	8	34
1	1	9	34
1	1	10	34
1	1	11	34
1	1	12	34
1	1	13	34
1	1	14	34
1	1	15	34
1	1	16	34
1	1	17	34
1	1	18	34
1	1	19	34
1	1	20	34
1	1	21	34
1	1	22	34
1	1	23	34
1	1	24	34
1	1	25	34
1	1	26	34
1	1	27	34
1	1	28	34
1	1	29	34
1	1	30	34
1	1	31	34
1	1	32	34
1	1	33	34
1	1	34	34
1	1	35	34
1	1	36	34
1	1	37	34
1	1	38	34
1	1	39	34
1	1	40	34
1	1	41	34
1	1	42	34
1	1	43	34
1	1	44	34
1	1	45	34
1	1	46	34
1	1	47	34
1	1	48	34
1	1	49	34
1	1	50	34
1	1	51	34
1	1	52	34
1	1	53	34
1	1	54	34
1	1	55	34
1	1	56	34
1	1	57	34
1	1	58	34
1	1	59	34
1	1	60	34
1	1	1	35
1	1	2	35
1	1	3	35
1	1	4	35
1	1	5	35
1	1	6	35
1	1	7	35
1	1	8	35
1	1	9	35
1	1	10	35
1	1	11	35
1	1	12	35
1	1	13	35
1	1	14	35
1	1	15	35
1	1	16	35
1	1	17	35
1	1	18	35
1	1	19	35
1	1	20	35
1	1	21	35
1	1	22	35
1	1	23	35
1	1	24	35
1	1	25	35
1	1	26	35
1	1	27	35
1	1	28	35
1	1	29	35
1	1	30	35
1	1	31	35
1	1	32	35
1	1	33	35
1	1	34	35
1	1	35	35
1	1	36	35
1	1	37	35
1	1	38	35
1	1	39	35
1	1	40	35
1	1	41	35
1	1	42	35
1	1	43	35
1	1	44	35
1	1	45	35
1	1	46	35
1	1	47	35
1	1	48	35
1	1	49	35
1	1	50	35
1	1	51	35
1	1	52	35
1	1	53	35
1	1	54	35
1	1	55	35
1	1	56	35
1	1	57	35
1	1	58	35
1	1	59	35
1	1	60	35
1	1	1	36
1	1	2	36
1	1	3	36
1	1	4	36
1	1	5	36
1	1	6	36
1	1	7	36
1	1	8	36
1	1	9	36
1	1	10	36
1	1	11	36
1	1	12	36
1	1	13	36
1	1	14	36
1	1	15	36
1	1	16	36
1	1	17	36
1	1	18	36
1	1	19	36
1	1	20	36
1	1	21	36
1	1	22	36
1	1	23	36
1	1	24	36
1	1	25	36
1	1	26	36
1	1	27	36
1	1	28	36
1	1	29	36
1	1	30	36
1	1	31	36
1	1	32	36
1	1	33	36
1	1	34	36
1	1	35	36
1	1	36	36
1	1	37	36
1	1	38	36
1	1	39	36
1	1	40	36
1	1	41	36
1	1	42	36
1	1	43	36
1	1	44	36
1	1	45	36
1	1	46	36
1	1	47	36
1	1	48	36
1	1	49	36
1	1	50	36
1	1	51	36
1	1	52	36
1	1	53	36
1	1	54	36
1	1	55	36
1	1	56	36
1	1	57	36
1	1	58	36
1	1	59	36
1	1	60	36
1	1	1	37
1	1	2	37
1	1	3	37
1	1	4	37
1	1	5	37
1	1	6	37
1	1	7	37
1	1	8	37
1	1	9	37
1	1	10	37
1	1	11	37
1	1	12	37
1	1	13	37
1	1	14	37
1	1	15	37
1	1	16	37
1	1	17	37
1	1	18	37
1	1	19	37
1	1	20	37
1	1	21	37
1	1	22	37
1	1	23	37
1	1	24	37
1	1	25	37
1	1	26	37
1	1	27	37
1	1	28	37
1	1	29	37
1	1	30	37
1	1	31	37
1	1	32	37
1	1	33	37
1	1	34	37
1	1	35	37
1	1	36	37
1	1	37	37
1	1	38	37
1	1	39	37
1	1	40	37
1	1	41	37
1	1	42	37
1	1	43	37
1	1	44	37
1	1	45	37
1	1	46	37
1	1	47	37
1	1	48	37
1	1	49	37
1	1	50	37
1	1	51	37
1	1	52	37
1	1	53	37
1	1	54	37
1	1	55	37
1	1	56	37
1	1	57	37
1	1	58	37
1	1	59	37
1	1	60	37
1	1	1	38
1	1	2	38
1	1	3	38
1	1	4	38
1	1	5	38
1	1	6	38
1	1	7	38
1	1	8	38
1	1	9	38
1	1	10	38
1	1	11	38
1	1	12	38
1	1	13	38
1	1	14	38
1	1	15	38
1	1	16	38
1	1	17	38
1	1	18	38
1	1	19	38
1	1	20	38
1	1	21	38
1	1	22	38
1	1	23	38
1	1	24	38
1	1	25	38
1	1	26	38
1	1	27	38
1	1	28	38
1	1	29	38
1	1	30	38
1	1	31	38
1	1	32	38
1	1	33	38
1	1	34	38
1	1	35	38
1	1	36	38
1	1	37	38
1	1	38	38
1	1	39	38
1	1	40	38
1	1	41	38
1	1	42	38
1	1	43	38
1	1	44	38
1	1	45	38
1	1	46	38
1	1	47	38
1	1	48	38
1	1	49	38
1	1	50	38
1	1	51	38
1	1	52	38
1	1	53	38
1	1	54	38
1	1	55	38
1	1	56	38
1	1	57	38
1	1	58	38
1	1	59	38
1	1	60	38
1	1	1	39
1	1	2	39
1	1	3	39
1	1	4	39
1	1	5	39
1	1	6	39
1	1	7	39
1	1	8	39
1	1	9	39
1	1	10	39
1	1	11	39
1	1	12	39
1	1	13	39
1	1	14	39
1	1	15	39
1	1	16	39
1	1	17	39
1	1	18	39
1	1	19	39
1	1	20	39
1	1	21	39
1	1	22	39
1	1	23	39
1	1	24	39
1	1	25	39
1	1	26	39
1	1	27	39
1	1	28	39
1	1	29	39
1	1	30	39
1	1	31	39
1	1	32	39
1	1	33	39
1	1	34	39
1	1	35	39
1	1	36	39
1	1	37	39
1	1	38	39
1	1	39	39
1	1	40	39
1	1	41	39
1	1	42	39
1	1	43	39
1	1	44	39
1	1	45	39
1	1	46	39
1	1	47	39
1	1	48	39
1	1	49	39
1	1	50	39
1	1	51	39
1	1	52	39
1	1	53	39
1	1	54	39
1	1	55	39
1	1	56	39
1	1	57	39
1	1	58	39
1	1	59	39
1	1	60	39
1	1	1	40
1	1	2	40
1	1	3	40
1	1	4	40
1	1	5	40
1	1	6	40
1	1	7	40
1	1	8	40
1	1	9	40
1	1	10	40
1	1	11	40
1	1	12	40
1	1	13	40
1	1	14	40
1	1	15	40
1	1	16	40
1	1	17	40
1	1	18	40
1	1	19	40
1	1	20	40
1	1	21	40
1	1	22	40
1	1	23	40
1	1	24	40
1	1	25	40
1	1	26	40
1	1	27	40
1	1	28	40
1	1	29	40
1	1	30	40
1	1	31	40
1	1	32	40
1	1	33	40
1	1	34	40
1	1	35	40
1	1	36	40
1	1	37	40
1	1	38	40
1	1	39	40
1	1	40	40
1	1	41	40
1	1	42	40
1	1	43	40
1	1	44	40
1	1	45	40
1	1	46	40
1	1	47	40
1	1	48	40
1	1	49	40
1	1	50	40
1	1	51	40
1	1	52	40
1	1	53	40
1	1	54	40
1	1	55	40
1	1	56	40
1	1	57	40
1	1	58	40
1	1	59	40
1	1	60	40
1	1	1	41
1	1	2	41
1	1	3	41
1	1	4	41
1	1	5	41
1	1	6	41
1	1	7	41
1	1	8	41
1	1	9	41
1	1	10	41
1	1	11	41
1	1	12	41
1	1	13	41
1	1	14	41
1	1	15	41
1	1	16	41
1	1	17	41
1	1	18	41
1	1	19	41
1	1	20	41
1	1	21	41
1	1	22	41
1	1	23	41
1	1	24	41
1	1	25	41
1	1	26	41
1	1	27	41
1	1	28	41
1	1	29	41
1	1	30	41
1	1	31	41
1	1	32	41
1	1	33	41
1	1	34	41
1	1	35	41
1	1	36	41
1	1	37	41
1	1	38	41
1	1	39	41
1	1	40	41
1	1	41	41
1	1	42	41
1	1	43	41
1	1	44	41
1	1	45	41
1	1	46	41
1	1	47	41
1	1	48	41
1	1	49	41
1	1	50	41
1	1	51	41
1	1	52	41
1	1	53	41
1	1	54	41
1	1	55	41
1	1	56	41
1	1	57	41
1	1	58	41
1	1	59	41
1	1	60	41
1	1	1	42
1	1	2	42
1	1	3	42
1	1	4	42
1	1	5	42
1	1	6	42
1	1	7	42
1	1	8	42
1	1	9	42
1	1	10	42
1	1	11	42
1	1	12	42
1	1	13	42
1	1	14	42
1	1	15	42
1	1	16	42
1	1	17	42
1	1	18	42
1	1	19	42
1	1	20	42
1	1	21	42
1	1	22	42
1	1	23	42
1	1	24	42
1	1	25	42
1	1	26	42
1	1	27	42
1	1	28	42
1	1	29	42
1	1	30	42
1	1	31	42
1	1	32	42
1	1	33	42
1	1	34	42
1	1	35	42
1	1	36	42
1	1	37	42
1	1	38	42
1	1	39	42
1	1	40	42
1	1	41	42
1	1	42	42
1	1	43	42
1	1	44	42
1	1	45	42
1	1	46	42
1	1	47	42
1	1	48	42
1	1	49	42
1	1	50	42
1	1	51	42
1	1	52	42
1	1	53	42
1	1	54	42
1	1	55	42
1	1	56	42
1	1	57	42
1	1	58	42
1	1	59	42
1	1	60	42
1	1	1	43
1	1	2	43
1	1	3	43
1	1	4	43
1	1	5	43
1	1	6	43
1	1	7	43
1	1	8	43
1	1	9	43
1	1	10	43
1	1	11	43
1	1	12	43
1	1	13	43
1	1	14	43
1	1	15	43
1	1	16	43
1	1	17	43
1	1	18	43
1	1	19	43
1	1	20	43
1	1	21	43
1	1	22	43
1	1	23	43
1	1	24	43
1	1	25	43
1	1	26	43
1	1	27	43
1	1	28	43
1	1	29	43
1	1	30	43
1	1	31	43
1	1	32	43
1	1	33	43
1	1	34	43
1	1	35	43
1	1	36	43
1	1	37	43
1	1	38	43
1	1	39	43
1	1	40	43
1	1	41	43
1	1	42	43
1	1	43	43
1	1	44	43
1	1	45	43
1	1	46	43
1	1	47	43
1	1	48	43
1	1	49	43
1	1	50	43
1	1	51	43
1	1	52	43
1	1	53	43
1	1	54	43
1	1	55	43
1	1	56	43
1	1	57	43
1	1	58	43
1	1	59	43
1	1	60	43
1	1	1	44
1	1	2	44
1	1	3	44
1	1	4	44
1	1	5	44
1	1	6	44
1	1	7	44
1	1	8	44
1	1	9	44
1	1	10	44
1	1	11	44
1	1	12	44
1	1	13	44
1	1	14	44
1	1	15	44
1	1	16	44
1	1	17	44
1	1	18	44
1	1	19	44
1	1	20	44
1	1	21	44
1	1	22	44
1	1	23	44
1	1	24	44
1	1	25	44
1	1	26	44
1	1	27	44
1	1	28	44
1	1	29	44
1	1	30	44
1	1	31	44
1	1	32	44
1	1	33	44
1	1	34	44
1	1	35	44
1	1	36	44
1	1	37	44
1	1	38	44
1	1	39	44
1	1	40	44
1	1	41	44
1	1	42	44
1	1	43	44
1	1	44	44
1	1	45	44
1	1	46	44
1	1	47	44
1	1	48	44
1	1	49	44
1	1	50	44
1	1	51	44
1	1	52	44
1	1	53	44
1	1	54	44
1	1	55	44
1	1	56	44
1	1	57	44
1	1	58	44
1	1	59	44
1	1	60	44
1	1	1	45
1	1	2	45
1	1	3	45
1	1	4	45
1	1	5	45
1	1	6	45
1	1	7	45
1	1	8	45
1	1	9	45
1	1	10	45
1	1	11	45
1	1	12	45
1	1	13	45
1	1	14	45
1	1	15	45
1	1	16	45
1	1	17	45
1	1	18	45
1	1	19	45
1	1	20	45
1	1	21	45
1	1	22	45
1	1	23	45
1	1	24	45
1	1	25	45
1	1	26	45
1	1	27	45
1	1	28	45
1	1	29	45
1	1	30	45
1	1	31	45
1	1	32	45
1	1	33	45
1	1	34	45
1	1	35	45
1	1	36	45
1	1	37	45
1	1	38	45
1	1	39	45
1	1	40	45
1	1	41	45
1	1	42	45
1	1	43	45
1	1	44	45
1	1	45	45
1	1	46	45
1	1	47	45
1	1	48	45
1	1	49	45
1	1	50	45
1	1	51	45
1	1	52	45
1	1	53	45
1	1	54	45
1	1	55	45
1	1	56	45
1	1	57	45
1	1	58	45
1	1	59	45
1	1	60	45
1	1	1	46
1	1	2	46
1	1	3	46
1	1	4	46
1	1	5	46
1	1	6	46
1	1	7	46
1	1	8	46
1	1	9	46
1	1	10	46
1	1	11	46
1	1	12	46
1	1	13	46
1	1	14	46
1	1	15	46
1	1	16	46
1	1	17	46
1	1	18	46
1	1	19	46
1	1	20	46
1	1	21	46
1	1	22	46
1	1	23	46
1	1	24	46
1	1	25	46
1	1	26	46
1	1	27	46
1	1	28	46
1	1	29	46
1	1	30	46
1	1	31	46
1	1	32	46
1	1	33	46
1	1	34	46
1	1	35	46
1	1	36	46
1	1	37	46
1	1	38	46
1	1	39	46
1	1	40	46
1	1	41	46
1	1	42	46
1	1	43	46
1	1	44	46
1	1	45	46
1	1	46	46
1	1	47	46
1	1	48	46
1	1	49	46
1	1	50	46
1	1	51	46
1	1	52	46
1	1	53	46
1	1	54	46
1	1	55	46
1	1	56	46
1	1	57	46
1	1	58	46
1	1	59	46
1	1	60	46
1	1	1	47
1	1	2	47
1	1	3	47
1	1	4	47
1	1	5	47
1	1	6	47
1	1	7	47
1	1	8	47
1	1	9	47
1	1	10	47
1	1	11	47
1	1	12	47
1	1	13	47
1	1	14	47
1	1	15	47
1	1	16	47
1	1	17	47
1	1	18	47
1	1	19	47
1	1	20	47
1	1	21	47
1	1	22	47
1	1	23	47
1	1	24	47
1	1	25	47
1	1	26	47
1	1	27	47
1	1	28	47
1	1	29	47
1	1	30	47
1	1	31	47
1	1	32	47
1	1	33	47
1	1	34	47
1	1	35	47
1	1	36	47
1	1	37	47
1	1	38	47
1	1	39	47
1	1	40	47
1	1	41	47
1	1	42	47
1	1	43	47
1	1	44	47
1	1	45	47
1	1	46	47
1	1	47	47
1	1	48	47
1	1	49	47
1	1	50	47
1	1	51	47
1	1	52	47
1	1	53	47
1	1	54	47
1	1	55	47
1	1	56	47
1	1	57	47
1	1	58	47
1	1	59	47
1	1	60	47
1	1	1	48
1	1	2	48
1	1	3	48
1	1	4	48
1	1	5	48
1	1	6	48
1	1	7	48
1	1	8	48
1	1	9	48
1	1	10	48
1	1	11	48
1	1	12	48
1	1	13	48
1	1	14	48
1	1	15	48
1	1	16	48
1	1	17	48
1	1	18	48
1	1	19	48
1	1	20	48
1	1	21	48
1	1	22	48
1	1	23	48
1	1	24	48
1	1	25	48
1	1	26	48
1	1	27	48
1	1	28	48
1	1	29	48
1	1	30	48
1	1	31	48
1	1	32	48
1	1	33	48
1	1	34	48
1	1	35	48
1	1	36	48
1	1	37	48
1	1	38	48
1	1	39	48
1	1	40	48
1	1	41	48
1	1	42	48
1	1	43	48
1	1	44	48
1	1	45	48
1	1	46	48
1	1	47	48
1	1	48	48
1	1	49	48
1	1	50	48
1	1	51	48
1	1	52	48
1	1	53	48
1	1	54	48
1	1	55	48
1	1	56	48
1	1	57	48
1	1	58	48
1	1	59	48
1	1	60	48
1	1	1	49
1	1	2	49
1	1	3	49
1	1	4	49
1	1	5	49
1	1	6	49
1	1	7	49
1	1	8	49
1	1	9	49
1	1	10	49
1	1	11	49
1	1	12	49
1	1	13	49
1	1	14	49
1	1	15	49
1	1	16	49
1	1	17	49
1	1	18	49
1	1	19	49
1	1	20	49
1	1	21	49
1	1	22	49
1	1	23	49
1	1	24	49
1	1	25	49
1	1	26	49
1	1	27	49
1	1	28	49
1	1	29	49
1	1	30	49
1	1	31	49
1	1	32	49
1	1	33	49
1	1	34	49
1	1	35	49
1	1	36	49
1	1	37	49
1	1	38	49
1	1	39	49
1	1	40	49
1	1	41	49
1	1	42	49
1	1	43	49
1	1	44	49
1	1	45	49
1	1	46	49
1	1	47	49
1	1	48	49
1	1	49	49
1	1	50	49
1	1	51	49
1	1	52	49
1	1	53	49
1	1	54	49
1	1	55	49
1	1	56	49
1	1	57	49
1	1	58	49
1	1	59	49
1	1	60	49
1	1	1	50
1	1	2	50
1	1	3	50
1	1	4	50
1	1	5	50
1	1	6	50
1	1	7	50
1	1	8	50
1	1	9	50
1	1	10	50
1	1	11	50
1	1	12	50
1	1	13	50
1	1	14	50
1	1	15	50
1	1	16	50
1	1	17	50
1	1	18	50
1	1	19	50
1	1	20	50
1	1	21	50
1	1	22	50
1	1	23	50
1	1	24	50
1	1	25	50
1	1	26	50
1	1	27	50
1	1	28	50
1	1	29	50
1	1	30	50
1	1	31	50
1	1	32	50
1	1	33	50
1	1	34	50
1	1	35	50
1	1	36	50
1	1	37	50
1	1	38	50
1	1	39	50
1	1	40	50
1	1	41	50
1	1	42	50
1	1	43	50
1	1	44	50
1	1	45	50
1	1	46	50
1	1	47	50
1	1	48	50
1	1	49	50
1	1	50	50
1	1	51	50
1	1	52	50
1	1	53	50
1	1	54	50
1	1	55	50
1	1	56	50
1	1	57	50
1	1	58	50
1	1	59	50
1	1	60	50
1	1	1	51
1	1	2	51
1	1	3	51
1	1	4	51
1	1	5	51
1	1	6	51
1	1	7	51
1	1	8	51
1	1	9	51
1	1	10	51
1	1	11	51
1	1	12	51
1	1	13	51
1	1	14	51
1	1	15	51
1	1	16	51
1	1	17	51
1	1	18	51
1	1	19	51
1	1	20	51
1	1	21	51
1	1	22	51
1	1	23	51
1	1	24	51
1	1	25	51
1	1	26	51
1	1	27	51
1	1	28	51
1	1	29	51
1	1	30	51
1	1	31	51
1	1	32	51
1	1	33	51
1	1	34	51
1	1	35	51
1	1	36	51
1	1	37	51
1	1	38	51
1	1	39	51
1	1	40	51
1	1	41	51
1	1	42	51
1	1	43	51
1	1	44	51
1	1	45	51
1	1	46	51
1	1	47	51
1	1	48	51
1	1	49	51
1	1	50	51
1	1	51	51
1	1	52	51
1	1	53	51
1	1	54	51
1	1	55	51
1	1	56	51
1	1	57	51
1	1	58	51
1	1	59	51
1	1	60	51
1	1	1	52
1	1	2	52
1	1	3	52
1	1	4	52
1	1	5	52
1	1	6	52
1	1	7	52
1	1	8	52
1	1	9	52
1	1	10	52
1	1	11	52
1	1	12	52
1	1	13	52
1	1	14	52
1	1	15	52
1	1	16	52
1	1	17	52
1	1	18	52
1	1	19	52
1	1	20	52
1	1	21	52
1	1	22	52
1	1	23	52
1	1	24	52
1	1	25	52
1	1	26	52
1	1	27	52
1	1	28	52
1	1	29	52
1	1	30	52
1	1	31	52
1	1	32	52
1	1	33	52
1	1	34	52
1	1	35	52
1	1	36	52
1	1	37	52
1	1	38	52
1	1	39	52
1	1	40	52
1	1	41	52
1	1	42	52
1	1	43	52
1	1	44	52
1	1	45	52
1	1	46	52
1	1	47	52
1	1	48	52
1	1	49	52
1	1	50	52
1	1	51	52
1	1	52	52
1	1	53	52
1	1	54	52
1	1	55	52
1	1	56	52
1	1	57	52
1	1	58	52
1	1	59	52
1	1	60	52
1	1	1	53
1	1	2	53
1	1	3	53
1	1	4	53
1	1	5	53
1	1	6	53
1	1	7	53
1	1	8	53
1	1	9	53
1	1	10	53
1	1	11	53
1	1	12	53
1	1	13	53
1	1	14	53
1	1	15	53
1	1	16	53
1	1	17	53
1	1	18	53
1	1	19	53
1	1	20	53
1	1	21	53
1	1	22	53
1	1	23	53
1	1	24	53
1	1	25	53
1	1	26	53
1	1	27	53
1	1	28	53
1	1	29	53
1	1	30	53
1	1	31	53
1	1	32	53
1	1	33	53
1	1	34	53
1	1	35	53
1	1	36	53
1	1	37	53
1	1	38	53
1	1	39	53
1	1	40	53
1	1	41	53
1	1	42	53
1	1	43	53
1	1	44	53
1	1	45	53
1	1	46	53
1	1	47	53
1	1	48	53
1	1	49	53
1	1	50	53
1	1	51	53
1	1	52	53
1	1	53	53
1	1	54	53
1	1	55	53
1	1	56	53
1	1	57	53
1	1	58	53
1	1	59	53
1	1	60	53
1	1	1	54
1	1	2	54
1	1	3	54
1	1	4	54
1	1	5	54
1	1	6	54
1	1	7	54
1	1	8	54
1	1	9	54
1	1	10	54
1	1	11	54
1	1	12	54
1	1	13	54
1	1	14	54
1	1	15	54
1	1	16	54
1	1	17	54
1	1	18	54
1	1	19	54
1	1	20	54
1	1	21	54
1	1	22	54
1	1	23	54
1	1	24	54
1	1	25	54
1	1	26	54
1	1	27	54
1	1	28	54
1	1	29	54
1	1	30	54
1	1	31	54
1	1	32	54
1	1	33	54
1	1	34	54
1	1	35	54
1	1	36	54
1	1	37	54
1	1	38	54
1	1	39	54
1	1	40	54
1	1	41	54
1	1	42	54
1	1	43	54
1	1	44	54
1	1	45	54
1	1	46	54
1	1	47	54
1	1	48	54
1	1	49	54
1	1	50	54
1	1	51	54
1	1	52	54
1	1	53	54
1	1	54	54
1	1	55	54
1	1	56	54
1	1	57	54
1	1	58	54
1	1	59	54
1	1	60	54
1	1	1	55
1	1	2	55
1	1	3	55
1	1	4	55
1	1	5	55
1	1	6	55
1	1	7	55
1	1	8	55
1	1	9	55
1	1	10	55
1	1	11	55
1	1	12	55
1	1	13	55
1	1	14	55
1	1	15	55
1	1	16	55
1	1	17	55
1	1	18	55
1	1	19	55
1	1	20	55
1	1	21	55
1	1	22	55
1	1	23	55
1	1	24	55
1	1	25	55
1	1	26	55
1	1	27	55
1	1	28	55
1	1	29	55
1	1	30	55
1	1	31	55
1	1	32	55
1	1	33	55
1	1	34	55
1	1	35	55
1	1	36	55
1	1	37	55
1	1	38	55
1	1	39	55
1	1	40	55
1	1	41	55
1	1	42	55
1	1	43	55
1	1	44	55
1	1	45	55
1	1	46	55
1	1	47	55
1	1	48	55
1	1	49	55
1	1	50	55
1	1	51	55
1	1	52	55
1	1	53	55
1	1	54	55
1	1	55	55
1	1	56	55
1	1	57	55
1	1	58	55
1	1	59	55
1	1	60	55
1	1	1	56
1	1	2	56
1	1	3	56
1	1	4	56
1	1	5	56
1	1	6	56
1	1	7	56
1	1	8	56
1	1	9	56
1	1	10	56
1	1	11	56
1	1	12	56
1	1	13	56
1	1	14	56
1	1	15	56
1	1	16	56
1	1	17	56
1	1	18	56
1	1	19	56
1	1	20	56
1	1	21	56
1	1	22	56
1	1	23	56
1	1	24	56
1	1	25	56
1	1	26	56
1	1	27	56
1	1	28	56
1	1	29	56
1	1	30	56
1	1	31	56
1	1	32	56
1	1	33	56
1	1	34	56
1	1	35	56
1	1	36	56
1	1	37	56
1	1	38	56
1	1	39	56
1	1	40	56
1	1	41	56
1	1	42	56
1	1	43	56
1	1	44	56
1	1	45	56
1	1	46	56
1	1	47	56
1	1	48	56
1	1	49	56
1	1	50	56
1	1	51	56
1	1	52	56
1	1	53	56
1	1	54	56
1	1	55	56
1	1	56	56
1	1	57	56
1	1	58	56
1	1	59	56
1	1	60	56
1	1	1	57
1	1	2	57
1	1	3	57
1	1	4	57
1	1	5	57
1	1	6	57
1	1	7	57
1	1	8	57
1	1	9	57
1	1	10	57
1	1	11	57
1	1	12	57
1	1	13	57
1	1	14	57
1	1	15	57
1	1	16	57
1	1	17	57
1	1	18	57
1	1	19	57
1	1	20	57
1	1	21	57
1	1	22	57
1	1	23	57
1	1	24	57
1	1	25	57
1	1	26	57
1	1	27	57
1	1	28	57
1	1	29	57
1	1	30	57
1	1	31	57
1	1	32	57
1	1	33	57
1	1	34	57
1	1	35	57
1	1	36	57
1	1	37	57
1	1	38	57
1	1	39	57
1	1	40	57
1	1	41	57
1	1	42	57
1	1	43	57
1	1	44	57
1	1	45	57
1	1	46	57
1	1	47	57
1	1	48	57
1	1	49	57
1	1	50	57
1	1	51	57
1	1	52	57
1	1	53	57
1	1	54	57
1	1	55	57
1	1	56	57
1	1	57	57
1	1	58	57
1	1	59	57
1	1	60	57
1	1	1	58
1	1	2	58
1	1	3	58
1	1	4	58
1	1	5	58
1	1	6	58
1	1	7	58
1	1	8	58
1	1	9	58
1	1	10	58
1	1	11	58
1	1	12	58
1	1	13	58
1	1	14	58
1	1	15	58
1	1	16	58
1	1	17	58
1	1	18	58
1	1	19	58
1	1	20	58
1	1	21	58
1	1	22	58
1	1	23	58
1	1	24	58
1	1	25	58
1	1	26	58
1	1	27	58
1	1	28	58
1	1	29	58
1	1	30	58
1	1	31	58
1	1	32	58
1	1	33	58
1	1	34	58
1	1	35	58
1	1	36	58
1	1	37	58
1	1	38	58
1	1	39	58
1	1	40	58
1	1	41	58
1	1	42	58
1	1	43	58
1	1	44	58
1	1	45	58
1	1	46	58
1	1	47	58
1	1	48	58
1	1	49	58
1	1	50	58
1	1	51	58
1	1	52	58
1	1	53	58
1	1	54	58
1	1	55	58
1	1	56	58
1	1	57	58
1	1	58	58
1	1	59	58
1	1	60	58
1	1	1	59
1	1	2	59
1	1	3	59
1	1	4	59
1	1	5	59
1	1	6	59
1	1	7	59
1	1	8	59
1	1	9	59
1	1	10	59
1	1	11	59
1	1	12	59
1	1	13	59
1	1	14	59
1	1	15	59
1	1	16	59
1	1	17	59
1	1	18	59
1	1	19	59
1	1	20	59
1	1	21	59
1	1	22	59
1	1	23	59
1	1	24	59
1	1	25	59
1	1	26	59
1	1	27	59
1	1	28	59
1	1	29	59
1	1	30	59
1	1	31	59
1	1	32	59
1	1	33	59
1	1	34	59
1	1	35	59
1	1	36	59
1	1	37	59
1	1	38	59
1	1	39	59
1	1	40	59
1	1	41	59
1	1	42	59
1	1	43	59
1	1	44	59
1	1	45	59
1	1	46	59
1	1	47	59
1	1	48	59
1	1	49	59
1	1	50	59
1	1	51	59
1	1	52	59
1	1	53	59
1	1	54	59
1	1	55	59
1	1	56	59
1	1	57	59
1	1	58	59
1	1	59	59
1	1	60	59
1	1	1	60
1	1	2	60
1	1	3	60
1	1	4	60
1	1	5	60
1	1	6	60
1	1	7	60
1	1	8	60
1	1	9	60
1	1	10	60
1	1	11	60
1	1	12	60
1	1	13	60
1	1	14	60
1	1	15	60
1	1	16	60
1	1	17	60
1	1	18	60
1	1	19	60
1	1	20	60
1	1	21	60
1	1	22	60
1	1	23	60
1	1	24	60
1	1	25	60
1	1	26	60
1	1	27	60
1	1	28	60
1	1	29	60
1	1	30	60
1	1	31	60
1	1	32	60
1	1	33	60
1	1	34	60
1	1	35	60
1	1	36	60
1	1	37	60
1	1	38	60
1	1	39	60
1	1	40	60
1	1	41	60
1	1	42	60
1	1	43	60
1	1	44	60
1	1	45	60
1	1	46	60
1	1	47	60
1	1	48	60
1	1	49	60
1	1	50	60
1	1	51	60
1	1	52	60
1	1	53	60
1	1	54	60
1	1	55	60
1	1	56	60
1	1	57	60
1	1	58	60
1	1	59	60
1	1	60	60
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
2	1	16	1
2	1	17	1
2	1	18	1
2	1	19	1
2	1	20	1
2	1	21	1
2	1	22	1
2	1	23	1
2	1	24	1
2	1	25	1
2	1	26	1
2	1	27	1
2	1	28	1
2	1	29	1
2	1	30	1
2	1	31	1
2	1	32	1
2	1	33	1
2	1	34	1
2	1	35	1
2	1	36	1
2	1	37	1
2	1	38	1
2	1	39	1
2	1	40	1
2	1	41	1
2	1	42	1
2	1	43	1
2	1	44	1
2	1	45	1
2	1	46	1
2	1	47	1
2	1	48	1
2	1	49	1
2	1	50	1
2	1	51	1
2	1	52	1
2	1	53	1
2	1	54	1
2	1	55	1
2	1	56	1
2	1	57	1
2	1	58	1
2	1	59	1
2	1	60	1
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
2	1	16	2
2	1	17	2
2	1	18	2
2	1	19	2
2	1	20	2
2	1	21	2
2	1	22	2
2	1	23	2
2	1	24	2
2	1	25	2
2	1	26	2
2	1	27	2
2	1	28	2
2	1	29	2
2	1	30	2
2	1	31	2
2	1	32	2
2	1	33	2
2	1	34	2
2	1	35	2
2	1	36	2
2	1	37	2
2	1	38	2
2	1	39	2
2	1	40	2
2	1	41	2
2	1	42	2
2	1	43	2
2	1	44	2
2	1	45	2
2	1	46	2
2	1	47	2
2	1	48	2
2	1	49	2
2	1	50	2
2	1	51	2
2	1	52	2
2	1	53	2
2	1	54	2
2	1	55	2
2	1	56	2
2	1	57	2
2	1	58	2
2	1	59	2
2	1	60	2
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
2	1	16	3
2	1	17	3
2	1	18	3
2	1	19	3
2	1	20	3
2	1	21	3
2	1	22	3
2	1	23	3
2	1	24	3
2	1	25	3
2	1	26	3
2	1	27	3
2	1	28	3
2	1	29	3
2	1	30	3
2	1	31	3
2	1	32	3
2	1	33	3
2	1	34	3
2	1	35	3
2	1	36	3
2	1	37	3
2	1	38	3
2	1	39	3
2	1	40	3
2	1	41	3
2	1	42	3
2	1	43	3
2	1	44	3
2	1	45	3
2	1	46	3
2	1	47	3
2	1	48	3
2	1	49	3
2	1	50	3
2	1	51	3
2	1	52	3
2	1	53	3
2	1	54	3
2	1	55	3
2	1	56	3
2	1	57	3
2	1	58	3
2	1	59	3
2	1	60	3
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
2	1	16	4
2	1	17	4
2	1	18	4
2	1	19	4
2	1	20	4
2	1	21	4
2	1	22	4
2	1	23	4
2	1	24	4
2	1	25	4
2	1	26	4
2	1	27	4
2	1	28	4
2	1	29	4
2	1	30	4
2	1	31	4
2	1	32	4
2	1	33	4
2	1	34	4
2	1	35	4
2	1	36	4
2	1	37	4
2	1	38	4
2	1	39	4
2	1	40	4
2	1	41	4
2	1	42	4
2	1	43	4
2	1	44	4
2	1	45	4
2	1	46	4
2	1	47	4
2	1	48	4
2	1	49	4
2	1	50	4
2	1	51	4
2	1	52	4
2	1	53	4
2	1	54	4
2	1	55	4
2	1	56	4
2	1	57	4
2	1	58	4
2	1	59	4
2	1	60	4
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
2	1	16	5
2	1	17	5
2	1	18	5
2	1	19	5
2	1	20	5
2	1	21	5
2	1	22	5
2	1	23	5
2	1	24	5
2	1	25	5
2	1	26	5
2	1	27	5
2	1	28	5
2	1	29	5
2	1	30	5
2	1	31	5
2	1	32	5
2	1	33	5
2	1	34	5
2	1	35	5
2	1	36	5
2	1	37	5
2	1	38	5
2	1	39	5
2	1	40	5
2	1	41	5
2	1	42	5
2	1	43	5
2	1	44	5
2	1	45	5
2	1	46	5
2	1	47	5
2	1	48	5
2	1	49	5
2	1	50	5
2	1	51	5
2	1	52	5
2	1	53	5
2	1	54	5
2	1	55	5
2	1	56	5
2	1	57	5
2	1	58	5
2	1	59	5
2	1	60	5
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
2	1	16	6
2	1	17	6
2	1	18	6
2	1	19	6
2	1	20	6
2	1	21	6
2	1	22	6
2	1	23	6
2	1	24	6
2	1	25	6
2	1	26	6
2	1	27	6
2	1	28	6
2	1	29	6
2	1	30	6
2	1	31	6
2	1	32	6
2	1	33	6
2	1	34	6
2	1	35	6
2	1	36	6
2	1	37	6
2	1	38	6
2	1	39	6
2	1	40	6
2	1	41	6
2	1	42	6
2	1	43	6
2	1	44	6
2	1	45	6
2	1	46	6
2	1	47	6
2	1	48	6
2	1	49	6
2	1	50	6
2	1	51	6
2	1	52	6
2	1	53	6
2	1	54	6
2	1	55	6
2	1	56	6
2	1	57	6
2	1	58	6
2	1	59	6
2	1	60	6
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
2	1	16	7
2	1	17	7
2	1	18	7
2	1	19	7
2	1	20	7
2	1	21	7
2	1	22	7
2	1	23	7
2	1	24	7
2	1	25	7
2	1	26	7
2	1	27	7
2	1	28	7
2	1	29	7
2	1	30	7
2	1	31	7
2	1	32	7
2	1	33	7
2	1	34	7
2	1	35	7
2	1	36	7
2	1	37	7
2	1	38	7
2	1	39	7
2	1	40	7
2	1	41	7
2	1	42	7
2	1	43	7
2	1	44	7
2	1	45	7
2	1	46	7
2	1	47	7
2	1	48	7
2	1	49	7
2	1	50	7
2	1	51	7
2	1	52	7
2	1	53	7
2	1	54	7
2	1	55	7
2	1	56	7
2	1	57	7
2	1	58	7
2	1	59	7
2	1	60	7
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
2	1	16	8
2	1	17	8
2	1	18	8
2	1	19	8
2	1	20	8
2	1	21	8
2	1	22	8
2	1	23	8
2	1	24	8
2	1	25	8
2	1	26	8
2	1	27	8
2	1	28	8
2	1	29	8
2	1	30	8
2	1	31	8
2	1	32	8
2	1	33	8
2	1	34	8
2	1	35	8
2	1	36	8
2	1	37	8
2	1	38	8
2	1	39	8
2	1	40	8
2	1	41	8
2	1	42	8
2	1	43	8
2	1	44	8
2	1	45	8
2	1	46	8
2	1	47	8
2	1	48	8
2	1	49	8
2	1	50	8
2	1	51	8
2	1	52	8
2	1	53	8
2	1	54	8
2	1	55	8
2	1	56	8
2	1	57	8
2	1	58	8
2	1	59	8
2	1	60	8
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
2	1	16	9
2	1	17	9
2	1	18	9
2	1	19	9
2	1	20	9
2	1	21	9
2	1	22	9
2	1	23	9
2	1	24	9
2	1	25	9
2	1	26	9
2	1	27	9
2	1	28	9
2	1	29	9
2	1	30	9
2	1	31	9
2	1	32	9
2	1	33	9
2	1	34	9
2	1	35	9
2	1	36	9
2	1	37	9
2	1	38	9
2	1	39	9
2	1	40	9
2	1	41	9
2	1	42	9
2	1	43	9
2	1	44	9
2	1	45	9
2	1	46	9
2	1	47	9
2	1	48	9
2	1	49	9
2	1	50	9
2	1	51	9
2	1	52	9
2	1	53	9
2	1	54	9
2	1	55	9
2	1	56	9
2	1	57	9
2	1	58	9
2	1	59	9
2	1	60	9
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
2	1	16	10
2	1	17	10
2	1	18	10
2	1	19	10
2	1	20	10
2	1	21	10
2	1	22	10
2	1	23	10
2	1	24	10
2	1	25	10
2	1	26	10
2	1	27	10
2	1	28	10
2	1	29	10
2	1	30	10
2	1	31	10
2	1	32	10
2	1	33	10
2	1	34	10
2	1	35	10
2	1	36	10
2	1	37	10
2	1	38	10
2	1	39	10
2	1	40	10
2	1	41	10
2	1	42	10
2	1	43	10
2	1	44	10
2	1	45	10
2	1	46	10
2	1	47	10
2	1	48	10
2	1	49	10
2	1	50	10
2	1	51	10
2	1	52	10
2	1	53	10
2	1	54	10
2	1	55	10
2	1	56	10
2	1	57	10
2	1	58	10
2	1	59	10
2	1	60	10
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
2	1	16	11
2	1	17	11
2	1	18	11
2	1	19	11
2	1	20	11
2	1	21	11
2	1	22	11
2	1	23	11
2	1	24	11
2	1	25	11
2	1	26	11
2	1	27	11
2	1	28	11
2	1	29	11
2	1	30	11
2	1	31	11
2	1	32	11
2	1	33	11
2	1	34	11
2	1	35	11
2	1	36	11
2	1	37	11
2	1	38	11
2	1	39	11
2	1	40	11
2	1	41	11
2	1	42	11
2	1	43	11
2	1	44	11
2	1	45	11
2	1	46	11
2	1	47	11
2	1	48	11
2	1	49	11
2	1	50	11
2	1	51	11
2	1	52	11
2	1	53	11
2	1	54	11
2	1	55	11
2	1	56	11
2	1	57	11
2	1	58	11
2	1	59	11
2	1	60	11
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
2	1	16	12
2	1	17	12
2	1	18	12
2	1	19	12
2	1	20	12
2	1	21	12
2	1	22	12
2	1	23	12
2	1	24	12
2	1	25	12
2	1	26	12
2	1	27	12
2	1	28	12
2	1	29	12
2	1	30	12
2	1	31	12
2	1	32	12
2	1	33	12
2	1	34	12
2	1	35	12
2	1	36	12
2	1	37	12
2	1	38	12
2	1	39	12
2	1	40	12
2	1	41	12
2	1	42	12
2	1	43	12
2	1	44	12
2	1	45	12
2	1	46	12
2	1	47	12
2	1	48	12
2	1	49	12
2	1	50	12
2	1	51	12
2	1	52	12
2	1	53	12
2	1	54	12
2	1	55	12
2	1	56	12
2	1	57	12
2	1	58	12
2	1	59	12
2	1	60	12
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
2	1	16	13
2	1	17	13
2	1	18	13
2	1	19	13
2	1	20	13
2	1	21	13
2	1	22	13
2	1	23	13
2	1	24	13
2	1	25	13
2	1	26	13
2	1	27	13
2	1	28	13
2	1	29	13
2	1	30	13
2	1	31	13
2	1	32	13
2	1	33	13
2	1	34	13
2	1	35	13
2	1	36	13
2	1	37	13
2	1	38	13
2	1	39	13
2	1	40	13
2	1	41	13
2	1	42	13
2	1	43	13
2	1	44	13
2	1	45	13
2	1	46	13
2	1	47	13
2	1	48	13
2	1	49	13
2	1	50	13
2	1	51	13
2	1	52	13
2	1	53	13
2	1	54	13
2	1	55	13
2	1	56	13
2	1	57	13
2	1	58	13
2	1	59	13
2	1	60	13
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
2	1	16	14
2	1	17	14
2	1	18	14
2	1	19	14
2	1	20	14
2	1	21	14
2	1	22	14
2	1	23	14
2	1	24	14
2	1	25	14
2	1	26	14
2	1	27	14
2	1	28	14
2	1	29	14
2	1	30	14
2	1	31	14
2	1	32	14
2	1	33	14
2	1	34	14
2	1	35	14
2	1	36	14
2	1	37	14
2	1	38	14
2	1	39	14
2	1	40	14
2	1	41	14
2	1	42	14
2	1	43	14
2	1	44	14
2	1	45	14
2	1	46	14
2	1	47	14
2	1	48	14
2	1	49	14
2	1	50	14
2	1	51	14
2	1	52	14
2	1	53	14
2	1	54	14
2	1	55	14
2	1	56	14
2	1	57	14
2	1	58	14
2	1	59	14
2	1	60	14
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
2	1	16	15
2	1	17	15
2	1	18	15
2	1	19	15
2	1	20	15
2	1	21	15
2	1	22	15
2	1	23	15
2	1	24	15
2	1	25	15
2	1	26	15
2	1	27	15
2	1	28	15
2	1	29	15
2	1	30	15
2	1	31	15
2	1	32	15
2	1	33	15
2	1	34	15
2	1	35	15
2	1	36	15
2	1	37	15
2	1	38	15
2	1	39	15
2	1	40	15
2	1	41	15
2	1	42	15
2	1	43	15
2	1	44	15
2	1	45	15
2	1	46	15
2	1	47	15
2	1	48	15
2	1	49	15
2	1	50	15
2	1	51	15
2	1	52	15
2	1	53	15
2	1	54	15
2	1	55	15
2	1	56	15
2	1	57	15
2	1	58	15
2	1	59	15
2	1	60	15
2	1	1	16
2	1	2	16
2	1	3	16
2	1	4	16
2	1	5	16
2	1	6	16
2	1	7	16
2	1	8	16
2	1	9	16
2	1	10	16
2	1	11	16
2	1	12	16
2	1	13	16
2	1	14	16
2	1	15	16
2	1	16	16
2	1	17	16
2	1	18	16
2	1	19	16
2	1	20	16
2	1	21	16
2	1	22	16
2	1	23	16
2	1	24	16
2	1	25	16
2	1	26	16
2	1	27	16
2	1	28	16
2	1	29	16
2	1	30	16
2	1	31	16
2	1	32	16
2	1	33	16
2	1	34	16
2	1	35	16
2	1	36	16
2	1	37	16
2	1	38	16
2	1	39	16
2	1	40	16
2	1	41	16
2	1	42	16
2	1	43	16
2	1	44	16
2	1	45	16
2	1	46	16
2	1	47	16
2	1	48	16
2	1	49	16
2	1	50	16
2	1	51	16
2	1	52	16
2	1	53	16
2	1	54	16
2	1	55	16
2	1	56	16
2	1	57	16
2	1	58	16
2	1	59	16
2	1	60	16
2	1	1	17
2	1	2	17
2	1	3	17
2	1	4	17
2	1	5	17
2	1	6	17
2	1	7	17
2	1	8	17
2	1	9	17
2	1	10	17
2	1	11	17
2	1	12	17
2	1	13	17
2	1	14	17
2	1	15	17
2	1	16	17
2	1	17	17
2	1	18	17
2	1	19	17
2	1	20	17
2	1	21	17
2	1	22	17
2	1	23	17
2	1	24	17
2	1	25	17
2	1	26	17
2	1	27	17
2	1	28	17
2	1	29	17
2	1	30	17
2	1	31	17
2	1	32	17
2	1	33	17
2	1	34	17
2	1	35	17
2	1	36	17
2	1	37	17
2	1	38	17
2	1	39	17
2	1	40	17
2	1	41	17
2	1	42	17
2	1	43	17
2	1	44	17
2	1	45	17
2	1	46	17
2	1	47	17
2	1	48	17
2	1	49	17
2	1	50	17
2	1	51	17
2	1	52	17
2	1	53	17
2	1	54	17
2	1	55	17
2	1	56	17
2	1	57	17
2	1	58	17
2	1	59	17
2	1	60	17
2	1	1	18
2	1	2	18
2	1	3	18
2	1	4	18
2	1	5	18
2	1	6	18
2	1	7	18
2	1	8	18
2	1	9	18
2	1	10	18
2	1	11	18
2	1	12	18
2	1	13	18
2	1	14	18
2	1	15	18
2	1	16	18
2	1	17	18
2	1	18	18
2	1	19	18
2	1	20	18
2	1	21	18
2	1	22	18
2	1	23	18
2	1	24	18
2	1	25	18
2	1	26	18
2	1	27	18
2	1	28	18
2	1	29	18
2	1	30	18
2	1	31	18
2	1	32	18
2	1	33	18
2	1	34	18
2	1	35	18
2	1	36	18
2	1	37	18
2	1	38	18
2	1	39	18
2	1	40	18
2	1	41	18
2	1	42	18
2	1	43	18
2	1	44	18
2	1	45	18
2	1	46	18
2	1	47	18
2	1	48	18
2	1	49	18
2	1	50	18
2	1	51	18
2	1	52	18
2	1	53	18
2	1	54	18
2	1	55	18
2	1	56	18
2	1	57	18
2	1	58	18
2	1	59	18
2	1	60	18
2	1	1	19
2	1	2	19
2	1	3	19
2	1	4	19
2	1	5	19
2	1	6	19
2	1	7	19
2	1	8	19
2	1	9	19
2	1	10	19
2	1	11	19
2	1	12	19
2	1	13	19
2	1	14	19
2	1	15	19
2	1	16	19
2	1	17	19
2	1	18	19
2	1	19	19
2	1	20	19
2	1	21	19
2	1	22	19
2	1	23	19
2	1	24	19
2	1	25	19
2	1	26	19
2	1	27	19
2	1	28	19
2	1	29	19
2	1	30	19
2	1	31	19
2	1	32	19
2	1	33	19
2	1	34	19
2	1	35	19
2	1	36	19
2	1	37	19
2	1	38	19
2	1	39	19
2	1	40	19
2	1	41	19
2	1	42	19
2	1	43	19
2	1	44	19
2	1	45	19
2	1	46	19
2	1	47	19
2	1	48	19
2	1	49	19
2	1	50	19
2	1	51	19
2	1	52	19
2	1	53	19
2	1	54	19
2	1	55	19
2	1	56	19
2	1	57	19
2	1	58	19
2	1	59	19
2	1	60	19
2	1	1	20
2	1	2	20
2	1	3	20
2	1	4	20
2	1	5	20
2	1	6	20
2	1	7	20
2	1	8	20
2	1	9	20
2	1	10	20
2	1	11	20
2	1	12	20
2	1	13	20
2	1	14	20
2	1	15	20
2	1	16	20
2	1	17	20
2	1	18	20
2	1	19	20
2	1	20	20
2	1	21	20
2	1	22	20
2	1	23	20
2	1	24	20
2	1	25	20
2	1	26	20
2	1	27	20
2	1	28	20
2	1	29	20
2	1	30	20
2	1	31	20
2	1	32	20
2	1	33	20
2	1	34	20
2	1	35	20
2	1	36	20
2	1	37	20
2	1	38	20
2	1	39	20
2	1	40	20
2	1	41	20
2	1	42	20
2	1	43	20
2	1	44	20
2	1	45	20
2	1	46	20
2	1	47	20
2	1	48	20
2	1	49	20
2	1	50	20
2	1	51	20
2	1	52	20
2	1	53	20
2	1	54	20
2	1	55	20
2	1	56	20
2	1	57	20
2	1	58	20
2	1	59	20
2	1	60	20
2	1	1	21
2	1	2	21
2	1	3	21
2	1	4	21
2	1	5	21
2	1	6	21
2	1	7	21
2	1	8	21
2	1	9	21
2	1	10	21
2	1	11	21
2	1	12	21
2	1	13	21
2	1	14	21
2	1	15	21
2	1	16	21
2	1	17	21
2	1	18	21
2	1	19	21
2	1	20	21
2	1	21	21
2	1	22	21
2	1	23	21
2	1	24	21
2	1	25	21
2	1	26	21
2	1	27	21
2	1	28	21
2	1	29	21
2	1	30	21
2	1	31	21
2	1	32	21
2	1	33	21
2	1	34	21
2	1	35	21
2	1	36	21
2	1	37	21
2	1	38	21
2	1	39	21
2	1	40	21
2	1	41	21
2	1	42	21
2	1	43	21
2	1	44	21
2	1	45	21
2	1	46	21
2	1	47	21
2	1	48	21
2	1	49	21
2	1	50	21
2	1	51	21
2	1	52	21
2	1	53	21
2	1	54	21
2	1	55	21
2	1	56	21
2	1	57	21
2	1	58	21
2	1	59	21
2	1	60	21
2	1	1	22
2	1	2	22
2	1	3	22
2	1	4	22
2	1	5	22
2	1	6	22
2	1	7	22
2	1	8	22
2	1	9	22
2	1	10	22
2	1	11	22
2	1	12	22
2	1	13	22
2	1	14	22
2	1	15	22
2	1	16	22
2	1	17	22
2	1	18	22
2	1	19	22
2	1	20	22
2	1	21	22
2	1	22	22
2	1	23	22
2	1	24	22
2	1	25	22
2	1	26	22
2	1	27	22
2	1	28	22
2	1	29	22
2	1	30	22
2	1	31	22
2	1	32	22
2	1	33	22
2	1	34	22
2	1	35	22
2	1	36	22
2	1	37	22
2	1	38	22
2	1	39	22
2	1	40	22
2	1	41	22
2	1	42	22
2	1	43	22
2	1	44	22
2	1	45	22
2	1	46	22
2	1	47	22
2	1	48	22
2	1	49	22
2	1	50	22
2	1	51	22
2	1	52	22
2	1	53	22
2	1	54	22
2	1	55	22
2	1	56	22
2	1	57	22
2	1	58	22
2	1	59	22
2	1	60	22
2	1	1	23
2	1	2	23
2	1	3	23
2	1	4	23
2	1	5	23
2	1	6	23
2	1	7	23
2	1	8	23
2	1	9	23
2	1	10	23
2	1	11	23
2	1	12	23
2	1	13	23
2	1	14	23
2	1	15	23
2	1	16	23
2	1	17	23
2	1	18	23
2	1	19	23
2	1	20	23
2	1	21	23
2	1	22	23
2	1	23	23
2	1	24	23
2	1	25	23
2	1	26	23
2	1	27	23
2	1	28	23
2	1	29	23
2	1	30	23
2	1	31	23
2	1	32	23
2	1	33	23
2	1	34	23
2	1	35	23
2	1	36	23
2	1	37	23
2	1	38	23
2	1	39	23
2	1	40	23
2	1	41	23
2	1	42	23
2	1	43	23
2	1	44	23
2	1	45	23
2	1	46	23
2	1	47	23
2	1	48	23
2	1	49	23
2	1	50	23
2	1	51	23
2	1	52	23
2	1	53	23
2	1	54	23
2	1	55	23
2	1	56	23
2	1	57	23
2	1	58	23
2	1	59	23
2	1	60	23
2	1	1	24
2	1	2	24
2	1	3	24
2	1	4	24
2	1	5	24
2	1	6	24
2	1	7	24
2	1	8	24
2	1	9	24
2	1	10	24
2	1	11	24
2	1	12	24
2	1	13	24
2	1	14	24
2	1	15	24
2	1	16	24
2	1	17	24
2	1	18	24
2	1	19	24
2	1	20	24
2	1	21	24
2	1	22	24
2	1	23	24
2	1	24	24
2	1	25	24
2	1	26	24
2	1	27	24
2	1	28	24
2	1	29	24
2	1	30	24
2	1	31	24
2	1	32	24
2	1	33	24
2	1	34	24
2	1	35	24
2	1	36	24
2	1	37	24
2	1	38	24
2	1	39	24
2	1	40	24
2	1	41	24
2	1	42	24
2	1	43	24
2	1	44	24
2	1	45	24
2	1	46	24
2	1	47	24
2	1	48	24
2	1	49	24
2	1	50	24
2	1	51	24
2	1	52	24
2	1	53	24
2	1	54	24
2	1	55	24
2	1	56	24
2	1	57	24
2	1	58	24
2	1	59	24
2	1	60	24
2	1	1	25
2	1	2	25
2	1	3	25
2	1	4	25
2	1	5	25
2	1	6	25
2	1	7	25
2	1	8	25
2	1	9	25
2	1	10	25
2	1	11	25
2	1	12	25
2	1	13	25
2	1	14	25
2	1	15	25
2	1	16	25
2	1	17	25
2	1	18	25
2	1	19	25
2	1	20	25
2	1	21	25
2	1	22	25
2	1	23	25
2	1	24	25
2	1	25	25
2	1	26	25
2	1	27	25
2	1	28	25
2	1	29	25
2	1	30	25
2	1	31	25
2	1	32	25
2	1	33	25
2	1	34	25
2	1	35	25
2	1	36	25
2	1	37	25
2	1	38	25
2	1	39	25
2	1	40	25
2	1	41	25
2	1	42	25
2	1	43	25
2	1	44	25
2	1	45	25
2	1	46	25
2	1	47	25
2	1	48	25
2	1	49	25
2	1	50	25
2	1	51	25
2	1	52	25
2	1	53	25
2	1	54	25
2	1	55	25
2	1	56	25
2	1	57	25
2	1	58	25
2	1	59	25
2	1	60	25
2	1	1	26
2	1	2	26
2	1	3	26
2	1	4	26
2	1	5	26
2	1	6	26
2	1	7	26
2	1	8	26
2	1	9	26
2	1	10	26
2	1	11	26
2	1	12	26
2	1	13	26
2	1	14	26
2	1	15	26
2	1	16	26
2	1	17	26
2	1	18	26
2	1	19	26
2	1	20	26
2	1	21	26
2	1	22	26
2	1	23	26
2	1	24	26
2	1	25	26
2	1	26	26
2	1	27	26
2	1	28	26
2	1	29	26
2	1	30	26
2	1	31	26
2	1	32	26
2	1	33	26
2	1	34	26
2	1	35	26
2	1	36	26
2	1	37	26
2	1	38	26
2	1	39	26
2	1	40	26
2	1	41	26
2	1	42	26
2	1	43	26
2	1	44	26
2	1	45	26
2	1	46	26
2	1	47	26
2	1	48	26
2	1	49	26
2	1	50	26
2	1	51	26
2	1	52	26
2	1	53	26
2	1	54	26
2	1	55	26
2	1	56	26
2	1	57	26
2	1	58	26
2	1	59	26
2	1	60	26
2	1	1	27
2	1	2	27
2	1	3	27
2	1	4	27
2	1	5	27
2	1	6	27
2	1	7	27
2	1	8	27
2	1	9	27
2	1	10	27
2	1	11	27
2	1	12	27
2	1	13	27
2	1	14	27
2	1	15	27
2	1	16	27
2	1	17	27
2	1	18	27
2	1	19	27
2	1	20	27
2	1	21	27
2	1	22	27
2	1	23	27
2	1	24	27
2	1	25	27
2	1	26	27
2	1	27	27
2	1	28	27
2	1	29	27
2	1	30	27
2	1	31	27
2	1	32	27
2	1	33	27
2	1	34	27
2	1	35	27
2	1	36	27
2	1	37	27
2	1	38	27
2	1	39	27
2	1	40	27
2	1	41	27
2	1	42	27
2	1	43	27
2	1	44	27
2	1	45	27
2	1	46	27
2	1	47	27
2	1	48	27
2	1	49	27
2	1	50	27
2	1	51	27
2	1	52	27
2	1	53	27
2	1	54	27
2	1	55	27
2	1	56	27
2	1	57	27
2	1	58	27
2	1	59	27
2	1	60	27
2	1	1	28
2	1	2	28
2	1	3	28
2	1	4	28
2	1	5	28
2	1	6	28
2	1	7	28
2	1	8	28
2	1	9	28
2	1	10	28
2	1	11	28
2	1	12	28
2	1	13	28
2	1	14	28
2	1	15	28
2	1	16	28
2	1	17	28
2	1	18	28
2	1	19	28
2	1	20	28
2	1	21	28
2	1	22	28
2	1	23	28
2	1	24	28
2	1	25	28
2	1	26	28
2	1	27	28
2	1	28	28
2	1	29	28
2	1	30	28
2	1	31	28
2	1	32	28
2	1	33	28
2	1	34	28
2	1	35	28
2	1	36	28
2	1	37	28
2	1	38	28
2	1	39	28
2	1	40	28
2	1	41	28
2	1	42	28
2	1	43	28
2	1	44	28
2	1	45	28
2	1	46	28
2	1	47	28
2	1	48	28
2	1	49	28
2	1	50	28
2	1	51	28
2	1	52	28
2	1	53	28
2	1	54	28
2	1	55	28
2	1	56	28
2	1	57	28
2	1	58	28
2	1	59	28
2	1	60	28
2	1	1	29
2	1	2	29
2	1	3	29
2	1	4	29
2	1	5	29
2	1	6	29
2	1	7	29
2	1	8	29
2	1	9	29
2	1	10	29
2	1	11	29
2	1	12	29
2	1	13	29
2	1	14	29
2	1	15	29
2	1	16	29
2	1	17	29
2	1	18	29
2	1	19	29
2	1	20	29
2	1	21	29
2	1	22	29
2	1	23	29
2	1	24	29
2	1	25	29
2	1	26	29
2	1	27	29
2	1	28	29
2	1	29	29
2	1	30	29
2	1	31	29
2	1	32	29
2	1	33	29
2	1	34	29
2	1	35	29
2	1	36	29
2	1	37	29
2	1	38	29
2	1	39	29
2	1	40	29
2	1	41	29
2	1	42	29
2	1	43	29
2	1	44	29
2	1	45	29
2	1	46	29
2	1	47	29
2	1	48	29
2	1	49	29
2	1	50	29
2	1	51	29
2	1	52	29
2	1	53	29
2	1	54	29
2	1	55	29
2	1	56	29
2	1	57	29
2	1	58	29
2	1	59	29
2	1	60	29
2	1	1	30
2	1	2	30
2	1	3	30
2	1	4	30
2	1	5	30
2	1	6	30
2	1	7	30
2	1	8	30
2	1	9	30
2	1	10	30
2	1	11	30
2	1	12	30
2	1	13	30
2	1	14	30
2	1	15	30
2	1	16	30
2	1	17	30
2	1	18	30
2	1	19	30
2	1	20	30
2	1	21	30
2	1	22	30
2	1	23	30
2	1	24	30
2	1	25	30
2	1	26	30
2	1	27	30
2	1	28	30
2	1	29	30
2	1	30	30
2	1	31	30
2	1	32	30
2	1	33	30
2	1	34	30
2	1	35	30
2	1	36	30
2	1	37	30
2	1	38	30
2	1	39	30
2	1	40	30
2	1	41	30
2	1	42	30
2	1	43	30
2	1	44	30
2	1	45	30
2	1	46	30
2	1	47	30
2	1	48	30
2	1	49	30
2	1	50	30
2	1	51	30
2	1	52	30
2	1	53	30
2	1	54	30
2	1	55	30
2	1	56	30
2	1	57	30
2	1	58	30
2	1	59	30
2	1	60	30
2	1	1	31
2	1	2	31
2	1	3	31
2	1	4	31
2	1	5	31
2	1	6	31
2	1	7	31
2	1	8	31
2	1	9	31
2	1	10	31
2	1	11	31
2	1	12	31
2	1	13	31
2	1	14	31
2	1	15	31
2	1	16	31
2	1	17	31
2	1	18	31
2	1	19	31
2	1	20	31
2	1	21	31
2	1	22	31
2	1	23	31
2	1	24	31
2	1	25	31
2	1	26	31
2	1	27	31
2	1	28	31
2	1	29	31
2	1	30	31
2	1	31	31
2	1	32	31
2	1	33	31
2	1	34	31
2	1	35	31
2	1	36	31
2	1	37	31
2	1	38	31
2	1	39	31
2	1	40	31
2	1	41	31
2	1	42	31
2	1	43	31
2	1	44	31
2	1	45	31
2	1	46	31
2	1	47	31
2	1	48	31
2	1	49	31
2	1	50	31
2	1	51	31
2	1	52	31
2	1	53	31
2	1	54	31
2	1	55	31
2	1	56	31
2	1	57	31
2	1	58	31
2	1	59	31
2	1	60	31
2	1	1	32
2	1	2	32
2	1	3	32
2	1	4	32
2	1	5	32
2	1	6	32
2	1	7	32
2	1	8	32
2	1	9	32
2	1	10	32
2	1	11	32
2	1	12	32
2	1	13	32
2	1	14	32
2	1	15	32
2	1	16	32
2	1	17	32
2	1	18	32
2	1	19	32
2	1	20	32
2	1	21	32
2	1	22	32
2	1	23	32
2	1	24	32
2	1	25	32
2	1	26	32
2	1	27	32
2	1	28	32
2	1	29	32
2	1	30	32
2	1	31	32
2	1	32	32
2	1	33	32
2	1	34	32
2	1	35	32
2	1	36	32
2	1	37	32
2	1	38	32
2	1	39	32
2	1	40	32
2	1	41	32
2	1	42	32
2	1	43	32
2	1	44	32
2	1	45	32
2	1	46	32
2	1	47	32
2	1	48	32
2	1	49	32
2	1	50	32
2	1	51	32
2	1	52	32
2	1	53	32
2	1	54	32
2	1	55	32
2	1	56	32
2	1	57	32
2	1	58	32
2	1	59	32
2	1	60	32
2	1	1	33
2	1	2	33
2	1	3	33
2	1	4	33
2	1	5	33
2	1	6	33
2	1	7	33
2	1	8	33
2	1	9	33
2	1	10	33
2	1	11	33
2	1	12	33
2	1	13	33
2	1	14	33
2	1	15	33
2	1	16	33
2	1	17	33
2	1	18	33
2	1	19	33
2	1	20	33
2	1	21	33
2	1	22	33
2	1	23	33
2	1	24	33
2	1	25	33
2	1	26	33
2	1	27	33
2	1	28	33
2	1	29	33
2	1	30	33
2	1	31	33
2	1	32	33
2	1	33	33
2	1	34	33
2	1	35	33
2	1	36	33
2	1	37	33
2	1	38	33
2	1	39	33
2	1	40	33
2	1	41	33
2	1	42	33
2	1	43	33
2	1	44	33
2	1	45	33
2	1	46	33
2	1	47	33
2	1	48	33
2	1	49	33
2	1	50	33
2	1	51	33
2	1	52	33
2	1	53	33
2	1	54	33
2	1	55	33
2	1	56	33
2	1	57	33
2	1	58	33
2	1	59	33
2	1	60	33
2	1	1	34
2	1	2	34
2	1	3	34
2	1	4	34
2	1	5	34
2	1	6	34
2	1	7	34
2	1	8	34
2	1	9	34
2	1	10	34
2	1	11	34
2	1	12	34
2	1	13	34
2	1	14	34
2	1	15	34
2	1	16	34
2	1	17	34
2	1	18	34
2	1	19	34
2	1	20	34
2	1	21	34
2	1	22	34
2	1	23	34
2	1	24	34
2	1	25	34
2	1	26	34
2	1	27	34
2	1	28	34
2	1	29	34
2	1	30	34
2	1	31	34
2	1	32	34
2	1	33	34
2	1	34	34
2	1	35	34
2	1	36	34
2	1	37	34
2	1	38	34
2	1	39	34
2	1	40	34
2	1	41	34
2	1	42	34
2	1	43	34
2	1	44	34
2	1	45	34
2	1	46	34
2	1	47	34
2	1	48	34
2	1	49	34
2	1	50	34
2	1	51	34
2	1	52	34
2	1	53	34
2	1	54	34
2	1	55	34
2	1	56	34
2	1	57	34
2	1	58	34
2	1	59	34
2	1	60	34
2	1	1	35
2	1	2	35
2	1	3	35
2	1	4	35
2	1	5	35
2	1	6	35
2	1	7	35
2	1	8	35
2	1	9	35
2	1	10	35
2	1	11	35
2	1	12	35
2	1	13	35
2	1	14	35
2	1	15	35
2	1	16	35
2	1	17	35
2	1	18	35
2	1	19	35
2	1	20	35
2	1	21	35
2	1	22	35
2	1	23	35
2	1	24	35
2	1	25	35
2	1	26	35
2	1	27	35
2	1	28	35
2	1	29	35
2	1	30	35
2	1	31	35
2	1	32	35
2	1	33	35
2	1	34	35
2	1	35	35
2	1	36	35
2	1	37	35
2	1	38	35
2	1	39	35
2	1	40	35
2	1	41	35
2	1	42	35
2	1	43	35
2	1	44	35
2	1	45	35
2	1	46	35
2	1	47	35
2	1	48	35
2	1	49	35
2	1	50	35
2	1	51	35
2	1	52	35
2	1	53	35
2	1	54	35
2	1	55	35
2	1	56	35
2	1	57	35
2	1	58	35
2	1	59	35
2	1	60	35
2	1	1	36
2	1	2	36
2	1	3	36
2	1	4	36
2	1	5	36
2	1	6	36
2	1	7	36
2	1	8	36
2	1	9	36
2	1	10	36
2	1	11	36
2	1	12	36
2	1	13	36
2	1	14	36
2	1	15	36
2	1	16	36
2	1	17	36
2	1	18	36
2	1	19	36
2	1	20	36
2	1	21	36
2	1	22	36
2	1	23	36
2	1	24	36
2	1	25	36
2	1	26	36
2	1	27	36
2	1	28	36
2	1	29	36
2	1	30	36
2	1	31	36
2	1	32	36
2	1	33	36
2	1	34	36
2	1	35	36
2	1	36	36
2	1	37	36
2	1	38	36
2	1	39	36
2	1	40	36
2	1	41	36
2	1	42	36
2	1	43	36
2	1	44	36
2	1	45	36
2	1	46	36
2	1	47	36
2	1	48	36
2	1	49	36
2	1	50	36
2	1	51	36
2	1	52	36
2	1	53	36
2	1	54	36
2	1	55	36
2	1	56	36
2	1	57	36
2	1	58	36
2	1	59	36
2	1	60	36
2	1	1	37
2	1	2	37
2	1	3	37
2	1	4	37
2	1	5	37
2	1	6	37
2	1	7	37
2	1	8	37
2	1	9	37
2	1	10	37
2	1	11	37
2	1	12	37
2	1	13	37
2	1	14	37
2	1	15	37
2	1	16	37
2	1	17	37
2	1	18	37
2	1	19	37
2	1	20	37
2	1	21	37
2	1	22	37
2	1	23	37
2	1	24	37
2	1	25	37
2	1	26	37
2	1	27	37
2	1	28	37
2	1	29	37
2	1	30	37
2	1	31	37
2	1	32	37
2	1	33	37
2	1	34	37
2	1	35	37
2	1	36	37
2	1	37	37
2	1	38	37
2	1	39	37
2	1	40	37
2	1	41	37
2	1	42	37
2	1	43	37
2	1	44	37
2	1	45	37
2	1	46	37
2	1	47	37
2	1	48	37
2	1	49	37
2	1	50	37
2	1	51	37
2	1	52	37
2	1	53	37
2	1	54	37
2	1	55	37
2	1	56	37
2	1	57	37
2	1	58	37
2	1	59	37
2	1	60	37
2	1	1	38
2	1	2	38
2	1	3	38
2	1	4	38
2	1	5	38
2	1	6	38
2	1	7	38
2	1	8	38
2	1	9	38
2	1	10	38
2	1	11	38
2	1	12	38
2	1	13	38
2	1	14	38
2	1	15	38
2	1	16	38
2	1	17	38
2	1	18	38
2	1	19	38
2	1	20	38
2	1	21	38
2	1	22	38
2	1	23	38
2	1	24	38
2	1	25	38
2	1	26	38
2	1	27	38
2	1	28	38
2	1	29	38
2	1	30	38
2	1	31	38
2	1	32	38
2	1	33	38
2	1	34	38
2	1	35	38
2	1	36	38
2	1	37	38
2	1	38	38
2	1	39	38
2	1	40	38
2	1	41	38
2	1	42	38
2	1	43	38
2	1	44	38
2	1	45	38
2	1	46	38
2	1	47	38
2	1	48	38
2	1	49	38
2	1	50	38
2	1	51	38
2	1	52	38
2	1	53	38
2	1	54	38
2	1	55	38
2	1	56	38
2	1	57	38
2	1	58	38
2	1	59	38
2	1	60	38
2	1	1	39
2	1	2	39
2	1	3	39
2	1	4	39
2	1	5	39
2	1	6	39
2	1	7	39
2	1	8	39
2	1	9	39
2	1	10	39
2	1	11	39
2	1	12	39
2	1	13	39
2	1	14	39
2	1	15	39
2	1	16	39
2	1	17	39
2	1	18	39
2	1	19	39
2	1	20	39
2	1	21	39
2	1	22	39
2	1	23	39
2	1	24	39
2	1	25	39
2	1	26	39
2	1	27	39
2	1	28	39
2	1	29	39
2	1	30	39
2	1	31	39
2	1	32	39
2	1	33	39
2	1	34	39
2	1	35	39
2	1	36	39
2	1	37	39
2	1	38	39
2	1	39	39
2	1	40	39
2	1	41	39
2	1	42	39
2	1	43	39
2	1	44	39
2	1	45	39
2	1	46	39
2	1	47	39
2	1	48	39
2	1	49	39
2	1	50	39
2	1	51	39
2	1	52	39
2	1	53	39
2	1	54	39
2	1	55	39
2	1	56	39
2	1	57	39
2	1	58	39
2	1	59	39
2	1	60	39
2	1	1	40
2	1	2	40
2	1	3	40
2	1	4	40
2	1	5	40
2	1	6	40
2	1	7	40
2	1	8	40
2	1	9	40
2	1	10	40
2	1	11	40
2	1	12	40
2	1	13	40
2	1	14	40
2	1	15	40
2	1	16	40
2	1	17	40
2	1	18	40
2	1	19	40
2	1	20	40
2	1	21	40
2	1	22	40
2	1	23	40
2	1	24	40
2	1	25	40
2	1	26	40
2	1	27	40
2	1	28	40
2	1	29	40
2	1	30	40
2	1	31	40
2	1	32	40
2	1	33	40
2	1	34	40
2	1	35	40
2	1	36	40
2	1	37	40
2	1	38	40
2	1	39	40
2	1	40	40
2	1	41	40
2	1	42	40
2	1	43	40
2	1	44	40
2	1	45	40
2	1	46	40
2	1	47	40
2	1	48	40
2	1	49	40
2	1	50	40
2	1	51	40
2	1	52	40
2	1	53	40
2	1	54	40
2	1	55	40
2	1	56	40
2	1	57	40
2	1	58	40
2	1	59	40
2	1	60	40
2	1	1	41
2	1	2	41
2	1	3	41
2	1	4	41
2	1	5	41
2	1	6	41
2	1	7	41
2	1	8	41
2	1	9	41
2	1	10	41
2	1	11	41
2	1	12	41
2	1	13	41
2	1	14	41
2	1	15	41
2	1	16	41
2	1	17	41
2	1	18	41
2	1	19	41
2	1	20	41
2	1	21	41
2	1	22	41
2	1	23	41
2	1	24	41
2	1	25	41
2	1	26	41
2	1	27	41
2	1	28	41
2	1	29	41
2	1	30	41
2	1	31	41
2	1	32	41
2	1	33	41
2	1	34	41
2	1	35	41
2	1	36	41
2	1	37	41
2	1	38	41
2	1	39	41
2	1	40	41
2	1	41	41
2	1	42	41
2	1	43	41
2	1	44	41
2	1	45	41
2	1	46	41
2	1	47	41
2	1	48	41
2	1	49	41
2	1	50	41
2	1	51	41
2	1	52	41
2	1	53	41
2	1	54	41
2	1	55	41
2	1	56	41
2	1	57	41
2	1	58	41
2	1	59	41
2	1	60	41
2	1	1	42
2	1	2	42
2	1	3	42
2	1	4	42
2	1	5	42
2	1	6	42
2	1	7	42
2	1	8	42
2	1	9	42
2	1	10	42
2	1	11	42
2	1	12	42
2	1	13	42
2	1	14	42
2	1	15	42
2	1	16	42
2	1	17	42
2	1	18	42
2	1	19	42
2	1	20	42
2	1	21	42
2	1	22	42
2	1	23	42
2	1	24	42
2	1	25	42
2	1	26	42
2	1	27	42
2	1	28	42
2	1	29	42
2	1	30	42
2	1	31	42
2	1	32	42
2	1	33	42
2	1	34	42
2	1	35	42
2	1	36	42
2	1	37	42
2	1	38	42
2	1	39	42
2	1	40	42
2	1	41	42
2	1	42	42
2	1	43	42
2	1	44	42
2	1	45	42
2	1	46	42
2	1	47	42
2	1	48	42
2	1	49	42
2	1	50	42
2	1	51	42
2	1	52	42
2	1	53	42
2	1	54	42
2	1	55	42
2	1	56	42
2	1	57	42
2	1	58	42
2	1	59	42
2	1	60	42
2	1	1	43
2	1	2	43
2	1	3	43
2	1	4	43
2	1	5	43
2	1	6	43
2	1	7	43
2	1	8	43
2	1	9	43
2	1	10	43
2	1	11	43
2	1	12	43
2	1	13	43
2	1	14	43
2	1	15	43
2	1	16	43
2	1	17	43
2	1	18	43
2	1	19	43
2	1	20	43
2	1	21	43
2	1	22	43
2	1	23	43
2	1	24	43
2	1	25	43
2	1	26	43
2	1	27	43
2	1	28	43
2	1	29	43
2	1	30	43
2	1	31	43
2	1	32	43
2	1	33	43
2	1	34	43
2	1	35	43
2	1	36	43
2	1	37	43
2	1	38	43
2	1	39	43
2	1	40	43
2	1	41	43
2	1	42	43
2	1	43	43
2	1	44	43
2	1	45	43
2	1	46	43
2	1	47	43
2	1	48	43
2	1	49	43
2	1	50	43
2	1	51	43
2	1	52	43
2	1	53	43
2	1	54	43
2	1	55	43
2	1	56	43
2	1	57	43
2	1	58	43
2	1	59	43
2	1	60	43
2	1	1	44
2	1	2	44
2	1	3	44
2	1	4	44
2	1	5	44
2	1	6	44
2	1	7	44
2	1	8	44
2	1	9	44
2	1	10	44
2	1	11	44
2	1	12	44
2	1	13	44
2	1	14	44
2	1	15	44
2	1	16	44
2	1	17	44
2	1	18	44
2	1	19	44
2	1	20	44
2	1	21	44
2	1	22	44
2	1	23	44
2	1	24	44
2	1	25	44
2	1	26	44
2	1	27	44
2	1	28	44
2	1	29	44
2	1	30	44
2	1	31	44
2	1	32	44
2	1	33	44
2	1	34	44
2	1	35	44
2	1	36	44
2	1	37	44
2	1	38	44
2	1	39	44
2	1	40	44
2	1	41	44
2	1	42	44
2	1	43	44
2	1	44	44
2	1	45	44
2	1	46	44
2	1	47	44
2	1	48	44
2	1	49	44
2	1	50	44
2	1	51	44
2	1	52	44
2	1	53	44
2	1	54	44
2	1	55	44
2	1	56	44
2	1	57	44
2	1	58	44
2	1	59	44
2	1	60	44
2	1	1	45
2	1	2	45
2	1	3	45
2	1	4	45
2	1	5	45
2	1	6	45
2	1	7	45
2	1	8	45
2	1	9	45
2	1	10	45
2	1	11	45
2	1	12	45
2	1	13	45
2	1	14	45
2	1	15	45
2	1	16	45
2	1	17	45
2	1	18	45
2	1	19	45
2	1	20	45
2	1	21	45
2	1	22	45
2	1	23	45
2	1	24	45
2	1	25	45
2	1	26	45
2	1	27	45
2	1	28	45
2	1	29	45
2	1	30	45
2	1	31	45
2	1	32	45
2	1	33	45
2	1	34	45
2	1	35	45
2	1	36	45
2	1	37	45
2	1	38	45
2	1	39	45
2	1	40	45
2	1	41	45
2	1	42	45
2	1	43	45
2	1	44	45
2	1	45	45
2	1	46	45
2	1	47	45
2	1	48	45
2	1	49	45
2	1	50	45
2	1	51	45
2	1	52	45
2	1	53	45
2	1	54	45
2	1	55	45
2	1	56	45
2	1	57	45
2	1	58	45
2	1	59	45
2	1	60	45
2	1	1	46
2	1	2	46
2	1	3	46
2	1	4	46
2	1	5	46
2	1	6	46
2	1	7	46
2	1	8	46
2	1	9	46
2	1	10	46
2	1	11	46
2	1	12	46
2	1	13	46
2	1	14	46
2	1	15	46
2	1	16	46
2	1	17	46
2	1	18	46
2	1	19	46
2	1	20	46
2	1	21	46
2	1	22	46
2	1	23	46
2	1	24	46
2	1	25	46
2	1	26	46
2	1	27	46
2	1	28	46
2	1	29	46
2	1	30	46
2	1	31	46
2	1	32	46
2	1	33	46
2	1	34	46
2	1	35	46
2	1	36	46
2	1	37	46
2	1	38	46
2	1	39	46
2	1	40	46
2	1	41	46
2	1	42	46
2	1	43	46
2	1	44	46
2	1	45	46
2	1	46	46
2	1	47	46
2	1	48	46
2	1	49	46
2	1	50	46
2	1	51	46
2	1	52	46
2	1	53	46
2	1	54	46
2	1	55	46
2	1	56	46
2	1	57	46
2	1	58	46
2	1	59	46
2	1	60	46
2	1	1	47
2	1	2	47
2	1	3	47
2	1	4	47
2	1	5	47
2	1	6	47
2	1	7	47
2	1	8	47
2	1	9	47
2	1	10	47
2	1	11	47
2	1	12	47
2	1	13	47
2	1	14	47
2	1	15	47
2	1	16	47
2	1	17	47
2	1	18	47
2	1	19	47
2	1	20	47
2	1	21	47
2	1	22	47
2	1	23	47
2	1	24	47
2	1	25	47
2	1	26	47
2	1	27	47
2	1	28	47
2	1	29	47
2	1	30	47
2	1	31	47
2	1	32	47
2	1	33	47
2	1	34	47
2	1	35	47
2	1	36	47
2	1	37	47
2	1	38	47
2	1	39	47
2	1	40	47
2	1	41	47
2	1	42	47
2	1	43	47
2	1	44	47
2	1	45	47
2	1	46	47
2	1	47	47
2	1	48	47
2	1	49	47
2	1	50	47
2	1	51	47
2	1	52	47
2	1	53	47
2	1	54	47
2	1	55	47
2	1	56	47
2	1	57	47
2	1	58	47
2	1	59	47
2	1	60	47
2	1	1	48
2	1	2	48
2	1	3	48
2	1	4	48
2	1	5	48
2	1	6	48
2	1	7	48
2	1	8	48
2	1	9	48
2	1	10	48
2	1	11	48
2	1	12	48
2	1	13	48
2	1	14	48
2	1	15	48
2	1	16	48
2	1	17	48
2	1	18	48
2	1	19	48
2	1	20	48
2	1	21	48
2	1	22	48
2	1	23	48
2	1	24	48
2	1	25	48
2	1	26	48
2	1	27	48
2	1	28	48
2	1	29	48
2	1	30	48
2	1	31	48
2	1	32	48
2	1	33	48
2	1	34	48
2	1	35	48
2	1	36	48
2	1	37	48
2	1	38	48
2	1	39	48
2	1	40	48
2	1	41	48
2	1	42	48
2	1	43	48
2	1	44	48
2	1	45	48
2	1	46	48
2	1	47	48
2	1	48	48
2	1	49	48
2	1	50	48
2	1	51	48
2	1	52	48
2	1	53	48
2	1	54	48
2	1	55	48
2	1	56	48
2	1	57	48
2	1	58	48
2	1	59	48
2	1	60	48
2	1	1	49
2	1	2	49
2	1	3	49
2	1	4	49
2	1	5	49
2	1	6	49
2	1	7	49
2	1	8	49
2	1	9	49
2	1	10	49
2	1	11	49
2	1	12	49
2	1	13	49
2	1	14	49
2	1	15	49
2	1	16	49
2	1	17	49
2	1	18	49
2	1	19	49
2	1	20	49
2	1	21	49
2	1	22	49
2	1	23	49
2	1	24	49
2	1	25	49
2	1	26	49
2	1	27	49
2	1	28	49
2	1	29	49
2	1	30	49
2	1	31	49
2	1	32	49
2	1	33	49
2	1	34	49
2	1	35	49
2	1	36	49
2	1	37	49
2	1	38	49
2	1	39	49
2	1	40	49
2	1	41	49
2	1	42	49
2	1	43	49
2	1	44	49
2	1	45	49
2	1	46	49
2	1	47	49
2	1	48	49
2	1	49	49
2	1	50	49
2	1	51	49
2	1	52	49
2	1	53	49
2	1	54	49
2	1	55	49
2	1	56	49
2	1	57	49
2	1	58	49
2	1	59	49
2	1	60	49
2	1	1	50
2	1	2	50
2	1	3	50
2	1	4	50
2	1	5	50
2	1	6	50
2	1	7	50
2	1	8	50
2	1	9	50
2	1	10	50
2	1	11	50
2	1	12	50
2	1	13	50
2	1	14	50
2	1	15	50
2	1	16	50
2	1	17	50
2	1	18	50
2	1	19	50
2	1	20	50
2	1	21	50
2	1	22	50
2	1	23	50
2	1	24	50
2	1	25	50
2	1	26	50
2	1	27	50
2	1	28	50
2	1	29	50
2	1	30	50
2	1	31	50
2	1	32	50
2	1	33	50
2	1	34	50
2	1	35	50
2	1	36	50
2	1	37	50
2	1	38	50
2	1	39	50
2	1	40	50
2	1	41	50
2	1	42	50
2	1	43	50
2	1	44	50
2	1	45	50
2	1	46	50
2	1	47	50
2	1	48	50
2	1	49	50
2	1	50	50
2	1	51	50
2	1	52	50
2	1	53	50
2	1	54	50
2	1	55	50
2	1	56	50
2	1	57	50
2	1	58	50
2	1	59	50
2	1	60	50
2	1	1	51
2	1	2	51
2	1	3	51
2	1	4	51
2	1	5	51
2	1	6	51
2	1	7	51
2	1	8	51
2	1	9	51
2	1	10	51
2	1	11	51
2	1	12	51
2	1	13	51
2	1	14	51
2	1	15	51
2	1	16	51
2	1	17	51
2	1	18	51
2	1	19	51
2	1	20	51
2	1	21	51
2	1	22	51
2	1	23	51
2	1	24	51
2	1	25	51
2	1	26	51
2	1	27	51
2	1	28	51
2	1	29	51
2	1	30	51
2	1	31	51
2	1	32	51
2	1	33	51
2	1	34	51
2	1	35	51
2	1	36	51
2	1	37	51
2	1	38	51
2	1	39	51
2	1	40	51
2	1	41	51
2	1	42	51
2	1	43	51
2	1	44	51
2	1	45	51
2	1	46	51
2	1	47	51
2	1	48	51
2	1	49	51
2	1	50	51
2	1	51	51
2	1	52	51
2	1	53	51
2	1	54	51
2	1	55	51
2	1	56	51
2	1	57	51
2	1	58	51
2	1	59	51
2	1	60	51
2	1	1	52
2	1	2	52
2	1	3	52
2	1	4	52
2	1	5	52
2	1	6	52
2	1	7	52
2	1	8	52
2	1	9	52
2	1	10	52
2	1	11	52
2	1	12	52
2	1	13	52
2	1	14	52
2	1	15	52
2	1	16	52
2	1	17	52
2	1	18	52
2	1	19	52
2	1	20	52
2	1	21	52
2	1	22	52
2	1	23	52
2	1	24	52
2	1	25	52
2	1	26	52
2	1	27	52
2	1	28	52
2	1	29	52
2	1	30	52
2	1	31	52
2	1	32	52
2	1	33	52
2	1	34	52
2	1	35	52
2	1	36	52
2	1	37	52
2	1	38	52
2	1	39	52
2	1	40	52
2	1	41	52
2	1	42	52
2	1	43	52
2	1	44	52
2	1	45	52
2	1	46	52
2	1	47	52
2	1	48	52
2	1	49	52
2	1	50	52
2	1	51	52
2	1	52	52
2	1	53	52
2	1	54	52
2	1	55	52
2	1	56	52
2	1	57	52
2	1	58	52
2	1	59	52
2	1	60	52
2	1	1	53
2	1	2	53
2	1	3	53
2	1	4	53
2	1	5	53
2	1	6	53
2	1	7	53
2	1	8	53
2	1	9	53
2	1	10	53
2	1	11	53
2	1	12	53
2	1	13	53
2	1	14	53
2	1	15	53
2	1	16	53
2	1	17	53
2	1	18	53
2	1	19	53
2	1	20	53
2	1	21	53
2	1	22	53
2	1	23	53
2	1	24	53
2	1	25	53
2	1	26	53
2	1	27	53
2	1	28	53
2	1	29	53
2	1	30	53
2	1	31	53
2	1	32	53
2	1	33	53
2	1	34	53
2	1	35	53
2	1	36	53
2	1	37	53
2	1	38	53
2	1	39	53
2	1	40	53
2	1	41	53
2	1	42	53
2	1	43	53
2	1	44	53
2	1	45	53
2	1	46	53
2	1	47	53
2	1	48	53
2	1	49	53
2	1	50	53
2	1	51	53
2	1	52	53
2	1	53	53
2	1	54	53
2	1	55	53
2	1	56	53
2	1	57	53
2	1	58	53
2	1	59	53
2	1	60	53
2	1	1	54
2	1	2	54
2	1	3	54
2	1	4	54
2	1	5	54
2	1	6	54
2	1	7	54
2	1	8	54
2	1	9	54
2	1	10	54
2	1	11	54
2	1	12	54
2	1	13	54
2	1	14	54
2	1	15	54
2	1	16	54
2	1	17	54
2	1	18	54
2	1	19	54
2	1	20	54
2	1	21	54
2	1	22	54
2	1	23	54
2	1	24	54
2	1	25	54
2	1	26	54
2	1	27	54
2	1	28	54
2	1	29	54
2	1	30	54
2	1	31	54
2	1	32	54
2	1	33	54
2	1	34	54
2	1	35	54
2	1	36	54
2	1	37	54
2	1	38	54
2	1	39	54
2	1	40	54
2	1	41	54
2	1	42	54
2	1	43	54
2	1	44	54
2	1	45	54
2	1	46	54
2	1	47	54
2	1	48	54
2	1	49	54
2	1	50	54
2	1	51	54
2	1	52	54
2	1	53	54
2	1	54	54
2	1	55	54
2	1	56	54
2	1	57	54
2	1	58	54
2	1	59	54
2	1	60	54
2	1	1	55
2	1	2	55
2	1	3	55
2	1	4	55
2	1	5	55
2	1	6	55
2	1	7	55
2	1	8	55
2	1	9	55
2	1	10	55
2	1	11	55
2	1	12	55
2	1	13	55
2	1	14	55
2	1	15	55
2	1	16	55
2	1	17	55
2	1	18	55
2	1	19	55
2	1	20	55
2	1	21	55
2	1	22	55
2	1	23	55
2	1	24	55
2	1	25	55
2	1	26	55
2	1	27	55
2	1	28	55
2	1	29	55
2	1	30	55
2	1	31	55
2	1	32	55
2	1	33	55
2	1	34	55
2	1	35	55
2	1	36	55
2	1	37	55
2	1	38	55
2	1	39	55
2	1	40	55
2	1	41	55
2	1	42	55
2	1	43	55
2	1	44	55
2	1	45	55
2	1	46	55
2	1	47	55
2	1	48	55
2	1	49	55
2	1	50	55
2	1	51	55
2	1	52	55
2	1	53	55
2	1	54	55
2	1	55	55
2	1	56	55
2	1	57	55
2	1	58	55
2	1	59	55
2	1	60	55
2	1	1	56
2	1	2	56
2	1	3	56
2	1	4	56
2	1	5	56
2	1	6	56
2	1	7	56
2	1	8	56
2	1	9	56
2	1	10	56
2	1	11	56
2	1	12	56
2	1	13	56
2	1	14	56
2	1	15	56
2	1	16	56
2	1	17	56
2	1	18	56
2	1	19	56
2	1	20	56
2	1	21	56
2	1	22	56
2	1	23	56
2	1	24	56
2	1	25	56
2	1	26	56
2	1	27	56
2	1	28	56
2	1	29	56
2	1	30	56
2	1	31	56
2	1	32	56
2	1	33	56
2	1	34	56
2	1	35	56
2	1	36	56
2	1	37	56
2	1	38	56
2	1	39	56
2	1	40	56
2	1	41	56
2	1	42	56
2	1	43	56
2	1	44	56
2	1	45	56
2	1	46	56
2	1	47	56
2	1	48	56
2	1	49	56
2	1	50	56
2	1	51	56
2	1	52	56
2	1	53	56
2	1	54	56
2	1	55	56
2	1	56	56
2	1	57	56
2	1	58	56
2	1	59	56
2	1	60	56
2	1	1	57
2	1	2	57
2	1	3	57
2	1	4	57
2	1	5	57
2	1	6	57
2	1	7	57
2	1	8	57
2	1	9	57
2	1	10	57
2	1	11	57
2	1	12	57
2	1	13	57
2	1	14	57
2	1	15	57
2	1	16	57
2	1	17	57
2	1	18	57
2	1	19	57
2	1	20	57
2	1	21	57
2	1	22	57
2	1	23	57
2	1	24	57
2	1	25	57
2	1	26	57
2	1	27	57
2	1	28	57
2	1	29	57
2	1	30	57
2	1	31	57
2	1	32	57
2	1	33	57
2	1	34	57
2	1	35	57
2	1	36	57
2	1	37	57
2	1	38	57
2	1	39	57
2	1	40	57
2	1	41	57
2	1	42	57
2	1	43	57
2	1	44	57
2	1	45	57
2	1	46	57
2	1	47	57
2	1	48	57
2	1	49	57
2	1	50	57
2	1	51	57
2	1	52	57
2	1	53	57
2	1	54	57
2	1	55	57
2	1	56	57
2	1	57	57
2	1	58	57
2	1	59	57
2	1	60	57
2	1	1	58
2	1	2	58
2	1	3	58
2	1	4	58
2	1	5	58
2	1	6	58
2	1	7	58
2	1	8	58
2	1	9	58
2	1	10	58
2	1	11	58
2	1	12	58
2	1	13	58
2	1	14	58
2	1	15	58
2	1	16	58
2	1	17	58
2	1	18	58
2	1	19	58
2	1	20	58
2	1	21	58
2	1	22	58
2	1	23	58
2	1	24	58
2	1	25	58
2	1	26	58
2	1	27	58
2	1	28	58
2	1	29	58
2	1	30	58
2	1	31	58
2	1	32	58
2	1	33	58
2	1	34	58
2	1	35	58
2	1	36	58
2	1	37	58
2	1	38	58
2	1	39	58
2	1	40	58
2	1	41	58
2	1	42	58
2	1	43	58
2	1	44	58
2	1	45	58
2	1	46	58
2	1	47	58
2	1	48	58
2	1	49	58
2	1	50	58
2	1	51	58
2	1	52	58
2	1	53	58
2	1	54	58
2	1	55	58
2	1	56	58
2	1	57	58
2	1	58	58
2	1	59	58
2	1	60	58
2	1	1	59
2	1	2	59
2	1	3	59
2	1	4	59
2	1	5	59
2	1	6	59
2	1	7	59
2	1	8	59
2	1	9	59
2	1	10	59
2	1	11	59
2	1	12	59
2	1	13	59
2	1	14	59
2	1	15	59
2	1	16	59
2	1	17	59
2	1	18	59
2	1	19	59
2	1	20	59
2	1	21	59
2	1	22	59
2	1	23	59
2	1	24	59
2	1	25	59
2	1	26	59
2	1	27	59
2	1	28	59
2	1	29	59
2	1	30	59
2	1	31	59
2	1	32	59
2	1	33	59
2	1	34	59
2	1	35	59
2	1	36	59
2	1	37	59
2	1	38	59
2	1	39	59
2	1	40	59
2	1	41	59
2	1	42	59
2	1	43	59
2	1	44	59
2	1	45	59
2	1	46	59
2	1	47	59
2	1	48	59
2	1	49	59
2	1	50	59
2	1	51	59
2	1	52	59
2	1	53	59
2	1	54	59
2	1	55	59
2	1	56	59
2	1	57	59
2	1	58	59
2	1	59	59
2	1	60	59
2	1	1	60
2	1	2	60
2	1	3	60
2	1	4	60
2	1	5	60
2	1	6	60
2	1	7	60
2	1	8	60
2	1	9	60
2	1	10	60
2	1	11	60
2	1	12	60
2	1	13	60
2	1	14	60
2	1	15	60
2	1	16	60
2	1	17	60
2	1	18	60
2	1	19	60
2	1	20	60
2	1	21	60
2	1	22	60
2	1	23	60
2	1	24	60
2	1	25	60
2	1	26	60
2	1	27	60
2	1	28	60
2	1	29	60
2	1	30	60
2	1	31	60
2	1	32	60
2	1	33	60
2	1	34	60
2	1	35	60
2	1	36	60
2	1	37	60
2	1	38	60
2	1	39	60
2	1	40	60
2	1	41	60
2	1	42	60
2	1	43	60
2	1	44	60
2	1	45	60
2	1	46	60
2	1	47	60
2	1	48	60
2	1	49	60
2	1	50	60
2	1	51	60
2	1	52	60
2	1	53	60
2	1	54	60
2	1	55	60
2	1	56	60
2	1	57	60
2	1	58	60
2	1	59	60
2	1	60	60
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
3	1	16	1
3	1	17	1
3	1	18	1
3	1	19	1
3	1	20	1
3	1	21	1
3	1	22	1
3	1	23	1
3	1	24	1
3	1	25	1
3	1	26	1
3	1	27	1
3	1	28	1
3	1	29	1
3	1	30	1
3	1	31	1
3	1	32	1
3	1	33	1
3	1	34	1
3	1	35	1
3	1	36	1
3	1	37	1
3	1	38	1
3	1	39	1
3	1	40	1
3	1	41	1
3	1	42	1
3	1	43	1
3	1	44	1
3	1	45	1
3	1	46	1
3	1	47	1
3	1	48	1
3	1	49	1
3	1	50	1
3	1	51	1
3	1	52	1
3	1	53	1
3	1	54	1
3	1	55	1
3	1	56	1
3	1	57	1
3	1	58	1
3	1	59	1
3	1	60	1
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
3	1	16	2
3	1	17	2
3	1	18	2
3	1	19	2
3	1	20	2
3	1	21	2
3	1	22	2
3	1	23	2
3	1	24	2
3	1	25	2
3	1	26	2
3	1	27	2
3	1	28	2
3	1	29	2
3	1	30	2
3	1	31	2
3	1	32	2
3	1	33	2
3	1	34	2
3	1	35	2
3	1	36	2
3	1	37	2
3	1	38	2
3	1	39	2
3	1	40	2
3	1	41	2
3	1	42	2
3	1	43	2
3	1	44	2
3	1	45	2
3	1	46	2
3	1	47	2
3	1	48	2
3	1	49	2
3	1	50	2
3	1	51	2
3	1	52	2
3	1	53	2
3	1	54	2
3	1	55	2
3	1	56	2
3	1	57	2
3	1	58	2
3	1	59	2
3	1	60	2
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
3	1	16	3
3	1	17	3
3	1	18	3
3	1	19	3
3	1	20	3
3	1	21	3
3	1	22	3
3	1	23	3
3	1	24	3
3	1	25	3
3	1	26	3
3	1	27	3
3	1	28	3
3	1	29	3
3	1	30	3
3	1	31	3
3	1	32	3
3	1	33	3
3	1	34	3
3	1	35	3
3	1	36	3
3	1	37	3
3	1	38	3
3	1	39	3
3	1	40	3
3	1	41	3
3	1	42	3
3	1	43	3
3	1	44	3
3	1	45	3
3	1	46	3
3	1	47	3
3	1	48	3
3	1	49	3
3	1	50	3
3	1	51	3
3	1	52	3
3	1	53	3
3	1	54	3
3	1	55	3
3	1	56	3
3	1	57	3
3	1	58	3
3	1	59	3
3	1	60	3
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
3	1	16	4
3	1	17	4
3	1	18	4
3	1	19	4
3	1	20	4
3	1	21	4
3	1	22	4
3	1	23	4
3	1	24	4
3	1	25	4
3	1	26	4
3	1	27	4
3	1	28	4
3	1	29	4
3	1	30	4
3	1	31	4
3	1	32	4
3	1	33	4
3	1	34	4
3	1	35	4
3	1	36	4
3	1	37	4
3	1	38	4
3	1	39	4
3	1	40	4
3	1	41	4
3	1	42	4
3	1	43	4
3	1	44	4
3	1	45	4
3	1	46	4
3	1	47	4
3	1	48	4
3	1	49	4
3	1	50	4
3	1	51	4
3	1	52	4
3	1	53	4
3	1	54	4
3	1	55	4
3	1	56	4
3	1	57	4
3	1	58	4
3	1	59	4
3	1	60	4
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
3	1	16	5
3	1	17	5
3	1	18	5
3	1	19	5
3	1	20	5
3	1	21	5
3	1	22	5
3	1	23	5
3	1	24	5
3	1	25	5
3	1	26	5
3	1	27	5
3	1	28	5
3	1	29	5
3	1	30	5
3	1	31	5
3	1	32	5
3	1	33	5
3	1	34	5
3	1	35	5
3	1	36	5
3	1	37	5
3	1	38	5
3	1	39	5
3	1	40	5
3	1	41	5
3	1	42	5
3	1	43	5
3	1	44	5
3	1	45	5
3	1	46	5
3	1	47	5
3	1	48	5
3	1	49	5
3	1	50	5
3	1	51	5
3	1	52	5
3	1	53	5
3	1	54	5
3	1	55	5
3	1	56	5
3	1	57	5
3	1	58	5
3	1	59	5
3	1	60	5
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
3	1	16	6
3	1	17	6
3	1	18	6
3	1	19	6
3	1	20	6
3	1	21	6
3	1	22	6
3	1	23	6
3	1	24	6
3	1	25	6
3	1	26	6
3	1	27	6
3	1	28	6
3	1	29	6
3	1	30	6
3	1	31	6
3	1	32	6
3	1	33	6
3	1	34	6
3	1	35	6
3	1	36	6
3	1	37	6
3	1	38	6
3	1	39	6
3	1	40	6
3	1	41	6
3	1	42	6
3	1	43	6
3	1	44	6
3	1	45	6
3	1	46	6
3	1	47	6
3	1	48	6
3	1	49	6
3	1	50	6
3	1	51	6
3	1	52	6
3	1	53	6
3	1	54	6
3	1	55	6
3	1	56	6
3	1	57	6
3	1	58	6
3	1	59	6
3	1	60	6
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
3	1	16	7
3	1	17	7
3	1	18	7
3	1	19	7
3	1	20	7
3	1	21	7
3	1	22	7
3	1	23	7
3	1	24	7
3	1	25	7
3	1	26	7
3	1	27	7
3	1	28	7
3	1	29	7
3	1	30	7
3	1	31	7
3	1	32	7
3	1	33	7
3	1	34	7
3	1	35	7
3	1	36	7
3	1	37	7
3	1	38	7
3	1	39	7
3	1	40	7
3	1	41	7
3	1	42	7
3	1	43	7
3	1	44	7
3	1	45	7
3	1	46	7
3	1	47	7
3	1	48	7
3	1	49	7
3	1	50	7
3	1	51	7
3	1	52	7
3	1	53	7
3	1	54	7
3	1	55	7
3	1	56	7
3	1	57	7
3	1	58	7
3	1	59	7
3	1	60	7
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
3	1	16	8
3	1	17	8
3	1	18	8
3	1	19	8
3	1	20	8
3	1	21	8
3	1	22	8
3	1	23	8
3	1	24	8
3	1	25	8
3	1	26	8
3	1	27	8
3	1	28	8
3	1	29	8
3	1	30	8
3	1	31	8
3	1	32	8
3	1	33	8
3	1	34	8
3	1	35	8
3	1	36	8
3	1	37	8
3	1	38	8
3	1	39	8
3	1	40	8
3	1	41	8
3	1	42	8
3	1	43	8
3	1	44	8
3	1	45	8
3	1	46	8
3	1	47	8
3	1	48	8
3	1	49	8
3	1	50	8
3	1	51	8
3	1	52	8
3	1	53	8
3	1	54	8
3	1	55	8
3	1	56	8
3	1	57	8
3	1	58	8
3	1	59	8
3	1	60	8
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
3	1	16	9
3	1	17	9
3	1	18	9
3	1	19	9
3	1	20	9
3	1	21	9
3	1	22	9
3	1	23	9
3	1	24	9
3	1	25	9
3	1	26	9
3	1	27	9
3	1	28	9
3	1	29	9
3	1	30	9
3	1	31	9
3	1	32	9
3	1	33	9
3	1	34	9
3	1	35	9
3	1	36	9
3	1	37	9
3	1	38	9
3	1	39	9
3	1	40	9
3	1	41	9
3	1	42	9
3	1	43	9
3	1	44	9
3	1	45	9
3	1	46	9
3	1	47	9
3	1	48	9
3	1	49	9
3	1	50	9
3	1	51	9
3	1	52	9
3	1	53	9
3	1	54	9
3	1	55	9
3	1	56	9
3	1	57	9
3	1	58	9
3	1	59	9
3	1	60	9
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
3	1	16	10
3	1	17	10
3	1	18	10
3	1	19	10
3	1	20	10
3	1	21	10
3	1	22	10
3	1	23	10
3	1	24	10
3	1	25	10
3	1	26	10
3	1	27	10
3	1	28	10
3	1	29	10
3	1	30	10
3	1	31	10
3	1	32	10
3	1	33	10
3	1	34	10
3	1	35	10
3	1	36	10
3	1	37	10
3	1	38	10
3	1	39	10
3	1	40	10
3	1	41	10
3	1	42	10
3	1	43	10
3	1	44	10
3	1	45	10
3	1	46	10
3	1	47	10
3	1	48	10
3	1	49	10
3	1	50	10
3	1	51	10
3	1	52	10
3	1	53	10
3	1	54	10
3	1	55	10
3	1	56	10
3	1	57	10
3	1	58	10
3	1	59	10
3	1	60	10
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
3	1	16	11
3	1	17	11
3	1	18	11
3	1	19	11
3	1	20	11
3	1	21	11
3	1	22	11
3	1	23	11
3	1	24	11
3	1	25	11
3	1	26	11
3	1	27	11
3	1	28	11
3	1	29	11
3	1	30	11
3	1	31	11
3	1	32	11
3	1	33	11
3	1	34	11
3	1	35	11
3	1	36	11
3	1	37	11
3	1	38	11
3	1	39	11
3	1	40	11
3	1	41	11
3	1	42	11
3	1	43	11
3	1	44	11
3	1	45	11
3	1	46	11
3	1	47	11
3	1	48	11
3	1	49	11
3	1	50	11
3	1	51	11
3	1	52	11
3	1	53	11
3	1	54	11
3	1	55	11
3	1	56	11
3	1	57	11
3	1	58	11
3	1	59	11
3	1	60	11
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
3	1	16	12
3	1	17	12
3	1	18	12
3	1	19	12
3	1	20	12
3	1	21	12
3	1	22	12
3	1	23	12
3	1	24	12
3	1	25	12
3	1	26	12
3	1	27	12
3	1	28	12
3	1	29	12
3	1	30	12
3	1	31	12
3	1	32	12
3	1	33	12
3	1	34	12
3	1	35	12
3	1	36	12
3	1	37	12
3	1	38	12
3	1	39	12
3	1	40	12
3	1	41	12
3	1	42	12
3	1	43	12
3	1	44	12
3	1	45	12
3	1	46	12
3	1	47	12
3	1	48	12
3	1	49	12
3	1	50	12
3	1	51	12
3	1	52	12
3	1	53	12
3	1	54	12
3	1	55	12
3	1	56	12
3	1	57	12
3	1	58	12
3	1	59	12
3	1	60	12
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
3	1	16	13
3	1	17	13
3	1	18	13
3	1	19	13
3	1	20	13
3	1	21	13
3	1	22	13
3	1	23	13
3	1	24	13
3	1	25	13
3	1	26	13
3	1	27	13
3	1	28	13
3	1	29	13
3	1	30	13
3	1	31	13
3	1	32	13
3	1	33	13
3	1	34	13
3	1	35	13
3	1	36	13
3	1	37	13
3	1	38	13
3	1	39	13
3	1	40	13
3	1	41	13
3	1	42	13
3	1	43	13
3	1	44	13
3	1	45	13
3	1	46	13
3	1	47	13
3	1	48	13
3	1	49	13
3	1	50	13
3	1	51	13
3	1	52	13
3	1	53	13
3	1	54	13
3	1	55	13
3	1	56	13
3	1	57	13
3	1	58	13
3	1	59	13
3	1	60	13
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
3	1	16	14
3	1	17	14
3	1	18	14
3	1	19	14
3	1	20	14
3	1	21	14
3	1	22	14
3	1	23	14
3	1	24	14
3	1	25	14
3	1	26	14
3	1	27	14
3	1	28	14
3	1	29	14
3	1	30	14
3	1	31	14
3	1	32	14
3	1	33	14
3	1	34	14
3	1	35	14
3	1	36	14
3	1	37	14
3	1	38	14
3	1	39	14
3	1	40	14
3	1	41	14
3	1	42	14
3	1	43	14
3	1	44	14
3	1	45	14
3	1	46	14
3	1	47	14
3	1	48	14
3	1	49	14
3	1	50	14
3	1	51	14
3	1	52	14
3	1	53	14
3	1	54	14
3	1	55	14
3	1	56	14
3	1	57	14
3	1	58	14
3	1	59	14
3	1	60	14
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
3	1	16	15
3	1	17	15
3	1	18	15
3	1	19	15
3	1	20	15
3	1	21	15
3	1	22	15
3	1	23	15
3	1	24	15
3	1	25	15
3	1	26	15
3	1	27	15
3	1	28	15
3	1	29	15
3	1	30	15
3	1	31	15
3	1	32	15
3	1	33	15
3	1	34	15
3	1	35	15
3	1	36	15
3	1	37	15
3	1	38	15
3	1	39	15
3	1	40	15
3	1	41	15
3	1	42	15
3	1	43	15
3	1	44	15
3	1	45	15
3	1	46	15
3	1	47	15
3	1	48	15
3	1	49	15
3	1	50	15
3	1	51	15
3	1	52	15
3	1	53	15
3	1	54	15
3	1	55	15
3	1	56	15
3	1	57	15
3	1	58	15
3	1	59	15
3	1	60	15
3	1	1	16
3	1	2	16
3	1	3	16
3	1	4	16
3	1	5	16
3	1	6	16
3	1	7	16
3	1	8	16
3	1	9	16
3	1	10	16
3	1	11	16
3	1	12	16
3	1	13	16
3	1	14	16
3	1	15	16
3	1	16	16
3	1	17	16
3	1	18	16
3	1	19	16
3	1	20	16
3	1	21	16
3	1	22	16
3	1	23	16
3	1	24	16
3	1	25	16
3	1	26	16
3	1	27	16
3	1	28	16
3	1	29	16
3	1	30	16
3	1	31	16
3	1	32	16
3	1	33	16
3	1	34	16
3	1	35	16
3	1	36	16
3	1	37	16
3	1	38	16
3	1	39	16
3	1	40	16
3	1	41	16
3	1	42	16
3	1	43	16
3	1	44	16
3	1	45	16
3	1	46	16
3	1	47	16
3	1	48	16
3	1	49	16
3	1	50	16
3	1	51	16
3	1	52	16
3	1	53	16
3	1	54	16
3	1	55	16
3	1	56	16
3	1	57	16
3	1	58	16
3	1	59	16
3	1	60	16
3	1	1	17
3	1	2	17
3	1	3	17
3	1	4	17
3	1	5	17
3	1	6	17
3	1	7	17
3	1	8	17
3	1	9	17
3	1	10	17
3	1	11	17
3	1	12	17
3	1	13	17
3	1	14	17
3	1	15	17
3	1	16	17
3	1	17	17
3	1	18	17
3	1	19	17
3	1	20	17
3	1	21	17
3	1	22	17
3	1	23	17
3	1	24	17
3	1	25	17
3	1	26	17
3	1	27	17
3	1	28	17
3	1	29	17
3	1	30	17
3	1	31	17
3	1	32	17
3	1	33	17
3	1	34	17
3	1	35	17
3	1	36	17
3	1	37	17
3	1	38	17
3	1	39	17
3	1	40	17
3	1	41	17
3	1	42	17
3	1	43	17
3	1	44	17
3	1	45	17
3	1	46	17
3	1	47	17
3	1	48	17
3	1	49	17
3	1	50	17
3	1	51	17
3	1	52	17
3	1	53	17
3	1	54	17
3	1	55	17
3	1	56	17
3	1	57	17
3	1	58	17
3	1	59	17
3	1	60	17
3	1	1	18
3	1	2	18
3	1	3	18
3	1	4	18
3	1	5	18
3	1	6	18
3	1	7	18
3	1	8	18
3	1	9	18
3	1	10	18
3	1	11	18
3	1	12	18
3	1	13	18
3	1	14	18
3	1	15	18
3	1	16	18
3	1	17	18
3	1	18	18
3	1	19	18
3	1	20	18
3	1	21	18
3	1	22	18
3	1	23	18
3	1	24	18
3	1	25	18
3	1	26	18
3	1	27	18
3	1	28	18
3	1	29	18
3	1	30	18
3	1	31	18
3	1	32	18
3	1	33	18
3	1	34	18
3	1	35	18
3	1	36	18
3	1	37	18
3	1	38	18
3	1	39	18
3	1	40	18
3	1	41	18
3	1	42	18
3	1	43	18
3	1	44	18
3	1	45	18
3	1	46	18
3	1	47	18
3	1	48	18
3	1	49	18
3	1	50	18
3	1	51	18
3	1	52	18
3	1	53	18
3	1	54	18
3	1	55	18
3	1	56	18
3	1	57	18
3	1	58	18
3	1	59	18
3	1	60	18
3	1	1	19
3	1	2	19
3	1	3	19
3	1	4	19
3	1	5	19
3	1	6	19
3	1	7	19
3	1	8	19
3	1	9	19
3	1	10	19
3	1	11	19
3	1	12	19
3	1	13	19
3	1	14	19
3	1	15	19
3	1	16	19
3	1	17	19
3	1	18	19
3	1	19	19
3	1	20	19
3	1	21	19
3	1	22	19
3	1	23	19
3	1	24	19
3	1	25	19
3	1	26	19
3	1	27	19
3	1	28	19
3	1	29	19
3	1	30	19
3	1	31	19
3	1	32	19
3	1	33	19
3	1	34	19
3	1	35	19
3	1	36	19
3	1	37	19
3	1	38	19
3	1	39	19
3	1	40	19
3	1	41	19
3	1	42	19
3	1	43	19
3	1	44	19
3	1	45	19
3	1	46	19
3	1	47	19
3	1	48	19
3	1	49	19
3	1	50	19
3	1	51	19
3	1	52	19
3	1	53	19
3	1	54	19
3	1	55	19
3	1	56	19
3	1	57	19
3	1	58	19
3	1	59	19
3	1	60	19
3	1	1	20
3	1	2	20
3	1	3	20
3	1	4	20
3	1	5	20
3	1	6	20
3	1	7	20
3	1	8	20
3	1	9	20
3	1	10	20
3	1	11	20
3	1	12	20
3	1	13	20
3	1	14	20
3	1	15	20
3	1	16	20
3	1	17	20
3	1	18	20
3	1	19	20
3	1	20	20
3	1	21	20
3	1	22	20
3	1	23	20
3	1	24	20
3	1	25	20
3	1	26	20
3	1	27	20
3	1	28	20
3	1	29	20
3	1	30	20
3	1	31	20
3	1	32	20
3	1	33	20
3	1	34	20
3	1	35	20
3	1	36	20
3	1	37	20
3	1	38	20
3	1	39	20
3	1	40	20
3	1	41	20
3	1	42	20
3	1	43	20
3	1	44	20
3	1	45	20
3	1	46	20
3	1	47	20
3	1	48	20
3	1	49	20
3	1	50	20
3	1	51	20
3	1	52	20
3	1	53	20
3	1	54	20
3	1	55	20
3	1	56	20
3	1	57	20
3	1	58	20
3	1	59	20
3	1	60	20
3	1	1	21
3	1	2	21
3	1	3	21
3	1	4	21
3	1	5	21
3	1	6	21
3	1	7	21
3	1	8	21
3	1	9	21
3	1	10	21
3	1	11	21
3	1	12	21
3	1	13	21
3	1	14	21
3	1	15	21
3	1	16	21
3	1	17	21
3	1	18	21
3	1	19	21
3	1	20	21
3	1	21	21
3	1	22	21
3	1	23	21
3	1	24	21
3	1	25	21
3	1	26	21
3	1	27	21
3	1	28	21
3	1	29	21
3	1	30	21
3	1	31	21
3	1	32	21
3	1	33	21
3	1	34	21
3	1	35	21
3	1	36	21
3	1	37	21
3	1	38	21
3	1	39	21
3	1	40	21
3	1	41	21
3	1	42	21
3	1	43	21
3	1	44	21
3	1	45	21
3	1	46	21
3	1	47	21
3	1	48	21
3	1	49	21
3	1	50	21
3	1	51	21
3	1	52	21
3	1	53	21
3	1	54	21
3	1	55	21
3	1	56	21
3	1	57	21
3	1	58	21
3	1	59	21
3	1	60	21
3	1	1	22
3	1	2	22
3	1	3	22
3	1	4	22
3	1	5	22
3	1	6	22
3	1	7	22
3	1	8	22
3	1	9	22
3	1	10	22
3	1	11	22
3	1	12	22
3	1	13	22
3	1	14	22
3	1	15	22
3	1	16	22
3	1	17	22
3	1	18	22
3	1	19	22
3	1	20	22
3	1	21	22
3	1	22	22
3	1	23	22
3	1	24	22
3	1	25	22
3	1	26	22
3	1	27	22
3	1	28	22
3	1	29	22
3	1	30	22
3	1	31	22
3	1	32	22
3	1	33	22
3	1	34	22
3	1	35	22
3	1	36	22
3	1	37	22
3	1	38	22
3	1	39	22
3	1	40	22
3	1	41	22
3	1	42	22
3	1	43	22
3	1	44	22
3	1	45	22
3	1	46	22
3	1	47	22
3	1	48	22
3	1	49	22
3	1	50	22
3	1	51	22
3	1	52	22
3	1	53	22
3	1	54	22
3	1	55	22
3	1	56	22
3	1	57	22
3	1	58	22
3	1	59	22
3	1	60	22
3	1	1	23
3	1	2	23
3	1	3	23
3	1	4	23
3	1	5	23
3	1	6	23
3	1	7	23
3	1	8	23
3	1	9	23
3	1	10	23
3	1	11	23
3	1	12	23
3	1	13	23
3	1	14	23
3	1	15	23
3	1	16	23
3	1	17	23
3	1	18	23
3	1	19	23
3	1	20	23
3	1	21	23
3	1	22	23
3	1	23	23
3	1	24	23
3	1	25	23
3	1	26	23
3	1	27	23
3	1	28	23
3	1	29	23
3	1	30	23
3	1	31	23
3	1	32	23
3	1	33	23
3	1	34	23
3	1	35	23
3	1	36	23
3	1	37	23
3	1	38	23
3	1	39	23
3	1	40	23
3	1	41	23
3	1	42	23
3	1	43	23
3	1	44	23
3	1	45	23
3	1	46	23
3	1	47	23
3	1	48	23
3	1	49	23
3	1	50	23
3	1	51	23
3	1	52	23
3	1	53	23
3	1	54	23
3	1	55	23
3	1	56	23
3	1	57	23
3	1	58	23
3	1	59	23
3	1	60	23
3	1	1	24
3	1	2	24
3	1	3	24
3	1	4	24
3	1	5	24
3	1	6	24
3	1	7	24
3	1	8	24
3	1	9	24
3	1	10	24
3	1	11	24
3	1	12	24
3	1	13	24
3	1	14	24
3	1	15	24
3	1	16	24
3	1	17	24
3	1	18	24
3	1	19	24
3	1	20	24
3	1	21	24
3	1	22	24
3	1	23	24
3	1	24	24
3	1	25	24
3	1	26	24
3	1	27	24
3	1	28	24
3	1	29	24
3	1	30	24
3	1	31	24
3	1	32	24
3	1	33	24
3	1	34	24
3	1	35	24
3	1	36	24
3	1	37	24
3	1	38	24
3	1	39	24
3	1	40	24
3	1	41	24
3	1	42	24
3	1	43	24
3	1	44	24
3	1	45	24
3	1	46	24
3	1	47	24
3	1	48	24
3	1	49	24
3	1	50	24
3	1	51	24
3	1	52	24
3	1	53	24
3	1	54	24
3	1	55	24
3	1	56	24
3	1	57	24
3	1	58	24
3	1	59	24
3	1	60	24
3	1	1	25
3	1	2	25
3	1	3	25
3	1	4	25
3	1	5	25
3	1	6	25
3	1	7	25
3	1	8	25
3	1	9	25
3	1	10	25
3	1	11	25
3	1	12	25
3	1	13	25
3	1	14	25
3	1	15	25
3	1	16	25
3	1	17	25
3	1	18	25
3	1	19	25
3	1	20	25
3	1	21	25
3	1	22	25
3	1	23	25
3	1	24	25
3	1	25	25
3	1	26	25
3	1	27	25
3	1	28	25
3	1	29	25
3	1	30	25
3	1	31	25
3	1	32	25
3	1	33	25
3	1	34	25
3	1	35	25
3	1	36	25
3	1	37	25
3	1	38	25
3	1	39	25
3	1	40	25
3	1	41	25
3	1	42	25
3	1	43	25
3	1	44	25
3	1	45	25
3	1	46	25
3	1	47	25
3	1	48	25
3	1	49	25
3	1	50	25
3	1	51	25
3	1	52	25
3	1	53	25
3	1	54	25
3	1	55	25
3	1	56	25
3	1	57	25
3	1	58	25
3	1	59	25
3	1	60	25
3	1	1	26
3	1	2	26
3	1	3	26
3	1	4	26
3	1	5	26
3	1	6	26
3	1	7	26
3	1	8	26
3	1	9	26
3	1	10	26
3	1	11	26
3	1	12	26
3	1	13	26
3	1	14	26
3	1	15	26
3	1	16	26
3	1	17	26
3	1	18	26
3	1	19	26
3	1	20	26
3	1	21	26
3	1	22	26
3	1	23	26
3	1	24	26
3	1	25	26
3	1	26	26
3	1	27	26
3	1	28	26
3	1	29	26
3	1	30	26
3	1	31	26
3	1	32	26
3	1	33	26
3	1	34	26
3	1	35	26
3	1	36	26
3	1	37	26
3	1	38	26
3	1	39	26
3	1	40	26
3	1	41	26
3	1	42	26
3	1	43	26
3	1	44	26
3	1	45	26
3	1	46	26
3	1	47	26
3	1	48	26
3	1	49	26
3	1	50	26
3	1	51	26
3	1	52	26
3	1	53	26
3	1	54	26
3	1	55	26
3	1	56	26
3	1	57	26
3	1	58	26
3	1	59	26
3	1	60	26
3	1	1	27
3	1	2	27
3	1	3	27
3	1	4	27
3	1	5	27
3	1	6	27
3	1	7	27
3	1	8	27
3	1	9	27
3	1	10	27
3	1	11	27
3	1	12	27
3	1	13	27
3	1	14	27
3	1	15	27
3	1	16	27
3	1	17	27
3	1	18	27
3	1	19	27
3	1	20	27
3	1	21	27
3	1	22	27
3	1	23	27
3	1	24	27
3	1	25	27
3	1	26	27
3	1	27	27
3	1	28	27
3	1	29	27
3	1	30	27
3	1	31	27
3	1	32	27
3	1	33	27
3	1	34	27
3	1	35	27
3	1	36	27
3	1	37	27
3	1	38	27
3	1	39	27
3	1	40	27
3	1	41	27
3	1	42	27
3	1	43	27
3	1	44	27
3	1	45	27
3	1	46	27
3	1	47	27
3	1	48	27
3	1	49	27
3	1	50	27
3	1	51	27
3	1	52	27
3	1	53	27
3	1	54	27
3	1	55	27
3	1	56	27
3	1	57	27
3	1	58	27
3	1	59	27
3	1	60	27
3	1	1	28
3	1	2	28
3	1	3	28
3	1	4	28
3	1	5	28
3	1	6	28
3	1	7	28
3	1	8	28
3	1	9	28
3	1	10	28
3	1	11	28
3	1	12	28
3	1	13	28
3	1	14	28
3	1	15	28
3	1	16	28
3	1	17	28
3	1	18	28
3	1	19	28
3	1	20	28
3	1	21	28
3	1	22	28
3	1	23	28
3	1	24	28
3	1	25	28
3	1	26	28
3	1	27	28
3	1	28	28
3	1	29	28
3	1	30	28
3	1	31	28
3	1	32	28
3	1	33	28
3	1	34	28
3	1	35	28
3	1	36	28
3	1	37	28
3	1	38	28
3	1	39	28
3	1	40	28
3	1	41	28
3	1	42	28
3	1	43	28
3	1	44	28
3	1	45	28
3	1	46	28
3	1	47	28
3	1	48	28
3	1	49	28
3	1	50	28
3	1	51	28
3	1	52	28
3	1	53	28
3	1	54	28
3	1	55	28
3	1	56	28
3	1	57	28
3	1	58	28
3	1	59	28
3	1	60	28
3	1	1	29
3	1	2	29
3	1	3	29
3	1	4	29
3	1	5	29
3	1	6	29
3	1	7	29
3	1	8	29
3	1	9	29
3	1	10	29
3	1	11	29
3	1	12	29
3	1	13	29
3	1	14	29
3	1	15	29
3	1	16	29
3	1	17	29
3	1	18	29
3	1	19	29
3	1	20	29
3	1	21	29
3	1	22	29
3	1	23	29
3	1	24	29
3	1	25	29
3	1	26	29
3	1	27	29
3	1	28	29
3	1	29	29
3	1	30	29
3	1	31	29
3	1	32	29
3	1	33	29
3	1	34	29
3	1	35	29
3	1	36	29
3	1	37	29
3	1	38	29
3	1	39	29
3	1	40	29
3	1	41	29
3	1	42	29
3	1	43	29
3	1	44	29
3	1	45	29
3	1	46	29
3	1	47	29
3	1	48	29
3	1	49	29
3	1	50	29
3	1	51	29
3	1	52	29
3	1	53	29
3	1	54	29
3	1	55	29
3	1	56	29
3	1	57	29
3	1	58	29
3	1	59	29
3	1	60	29
3	1	1	30
3	1	2	30
3	1	3	30
3	1	4	30
3	1	5	30
3	1	6	30
3	1	7	30
3	1	8	30
3	1	9	30
3	1	10	30
3	1	11	30
3	1	12	30
3	1	13	30
3	1	14	30
3	1	15	30
3	1	16	30
3	1	17	30
3	1	18	30
3	1	19	30
3	1	20	30
3	1	21	30
3	1	22	30
3	1	23	30
3	1	24	30
3	1	25	30
3	1	26	30
3	1	27	30
3	1	28	30
3	1	29	30
3	1	30	30
3	1	31	30
3	1	32	30
3	1	33	30
3	1	34	30
3	1	35	30
3	1	36	30
3	1	37	30
3	1	38	30
3	1	39	30
3	1	40	30
3	1	41	30
3	1	42	30
3	1	43	30
3	1	44	30
3	1	45	30
3	1	46	30
3	1	47	30
3	1	48	30
3	1	49	30
3	1	50	30
3	1	51	30
3	1	52	30
3	1	53	30
3	1	54	30
3	1	55	30
3	1	56	30
3	1	57	30
3	1	58	30
3	1	59	30
3	1	60	30
3	1	1	31
3	1	2	31
3	1	3	31
3	1	4	31
3	1	5	31
3	1	6	31
3	1	7	31
3	1	8	31
3	1	9	31
3	1	10	31
3	1	11	31
3	1	12	31
3	1	13	31
3	1	14	31
3	1	15	31
3	1	16	31
3	1	17	31
3	1	18	31
3	1	19	31
3	1	20	31
3	1	21	31
3	1	22	31
3	1	23	31
3	1	24	31
3	1	25	31
3	1	26	31
3	1	27	31
3	1	28	31
3	1	29	31
3	1	30	31
3	1	31	31
3	1	32	31
3	1	33	31
3	1	34	31
3	1	35	31
3	1	36	31
3	1	37	31
3	1	38	31
3	1	39	31
3	1	40	31
3	1	41	31
3	1	42	31
3	1	43	31
3	1	44	31
3	1	45	31
3	1	46	31
3	1	47	31
3	1	48	31
3	1	49	31
3	1	50	31
3	1	51	31
3	1	52	31
3	1	53	31
3	1	54	31
3	1	55	31
3	1	56	31
3	1	57	31
3	1	58	31
3	1	59	31
3	1	60	31
3	1	1	32
3	1	2	32
3	1	3	32
3	1	4	32
3	1	5	32
3	1	6	32
3	1	7	32
3	1	8	32
3	1	9	32
3	1	10	32
3	1	11	32
3	1	12	32
3	1	13	32
3	1	14	32
3	1	15	32
3	1	16	32
3	1	17	32
3	1	18	32
3	1	19	32
3	1	20	32
3	1	21	32
3	1	22	32
3	1	23	32
3	1	24	32
3	1	25	32
3	1	26	32
3	1	27	32
3	1	28	32
3	1	29	32
3	1	30	32
3	1	31	32
3	1	32	32
3	1	33	32
3	1	34	32
3	1	35	32
3	1	36	32
3	1	37	32
3	1	38	32
3	1	39	32
3	1	40	32
3	1	41	32
3	1	42	32
3	1	43	32
3	1	44	32
3	1	45	32
3	1	46	32
3	1	47	32
3	1	48	32
3	1	49	32
3	1	50	32
3	1	51	32
3	1	52	32
3	1	53	32
3	1	54	32
3	1	55	32
3	1	56	32
3	1	57	32
3	1	58	32
3	1	59	32
3	1	60	32
3	1	1	33
3	1	2	33
3	1	3	33
3	1	4	33
3	1	5	33
3	1	6	33
3	1	7	33
3	1	8	33
3	1	9	33
3	1	10	33
3	1	11	33
3	1	12	33
3	1	13	33
3	1	14	33
3	1	15	33
3	1	16	33
3	1	17	33
3	1	18	33
3	1	19	33
3	1	20	33
3	1	21	33
3	1	22	33
3	1	23	33
3	1	24	33
3	1	25	33
3	1	26	33
3	1	27	33
3	1	28	33
3	1	29	33
3	1	30	33
3	1	31	33
3	1	32	33
3	1	33	33
3	1	34	33
3	1	35	33
3	1	36	33
3	1	37	33
3	1	38	33
3	1	39	33
3	1	40	33
3	1	41	33
3	1	42	33
3	1	43	33
3	1	44	33
3	1	45	33
3	1	46	33
3	1	47	33
3	1	48	33
3	1	49	33
3	1	50	33
3	1	51	33
3	1	52	33
3	1	53	33
3	1	54	33
3	1	55	33
3	1	56	33
3	1	57	33
3	1	58	33
3	1	59	33
3	1	60	33
3	1	1	34
3	1	2	34
3	1	3	34
3	1	4	34
3	1	5	34
3	1	6	34
3	1	7	34
3	1	8	34
3	1	9	34
3	1	10	34
3	1	11	34
3	1	12	34
3	1	13	34
3	1	14	34
3	1	15	34
3	1	16	34
3	1	17	34
3	1	18	34
3	1	19	34
3	1	20	34
3	1	21	34
3	1	22	34
3	1	23	34
3	1	24	34
3	1	25	34
3	1	26	34
3	1	27	34
3	1	28	34
3	1	29	34
3	1	30	34
3	1	31	34
3	1	32	34
3	1	33	34
3	1	34	34
3	1	35	34
3	1	36	34
3	1	37	34
3	1	38	34
3	1	39	34
3	1	40	34
3	1	41	34
3	1	42	34
3	1	43	34
3	1	44	34
3	1	45	34
3	1	46	34
3	1	47	34
3	1	48	34
3	1	49	34
3	1	50	34
3	1	51	34
3	1	52	34
3	1	53	34
3	1	54	34
3	1	55	34
3	1	56	34
3	1	57	34
3	1	58	34
3	1	59	34
3	1	60	34
3	1	1	35
3	1	2	35
3	1	3	35
3	1	4	35
3	1	5	35
3	1	6	35
3	1	7	35
3	1	8	35
3	1	9	35
3	1	10	35
3	1	11	35
3	1	12	35
3	1	13	35
3	1	14	35
3	1	15	35
3	1	16	35
3	1	17	35
3	1	18	35
3	1	19	35
3	1	20	35
3	1	21	35
3	1	22	35
3	1	23	35
3	1	24	35
3	1	25	35
3	1	26	35
3	1	27	35
3	1	28	35
3	1	29	35
3	1	30	35
3	1	31	35
3	1	32	35
3	1	33	35
3	1	34	35
3	1	35	35
3	1	36	35
3	1	37	35
3	1	38	35
3	1	39	35
3	1	40	35
3	1	41	35
3	1	42	35
3	1	43	35
3	1	44	35
3	1	45	35
3	1	46	35
3	1	47	35
3	1	48	35
3	1	49	35
3	1	50	35
3	1	51	35
3	1	52	35
3	1	53	35
3	1	54	35
3	1	55	35
3	1	56	35
3	1	57	35
3	1	58	35
3	1	59	35
3	1	60	35
3	1	1	36
3	1	2	36
3	1	3	36
3	1	4	36
3	1	5	36
3	1	6	36
3	1	7	36
3	1	8	36
3	1	9	36
3	1	10	36
3	1	11	36
3	1	12	36
3	1	13	36
3	1	14	36
3	1	15	36
3	1	16	36
3	1	17	36
3	1	18	36
3	1	19	36
3	1	20	36
3	1	21	36
3	1	22	36
3	1	23	36
3	1	24	36
3	1	25	36
3	1	26	36
3	1	27	36
3	1	28	36
3	1	29	36
3	1	30	36
3	1	31	36
3	1	32	36
3	1	33	36
3	1	34	36
3	1	35	36
3	1	36	36
3	1	37	36
3	1	38	36
3	1	39	36
3	1	40	36
3	1	41	36
3	1	42	36
3	1	43	36
3	1	44	36
3	1	45	36
3	1	46	36
3	1	47	36
3	1	48	36
3	1	49	36
3	1	50	36
3	1	51	36
3	1	52	36
3	1	53	36
3	1	54	36
3	1	55	36
3	1	56	36
3	1	57	36
3	1	58	36
3	1	59	36
3	1	60	36
3	1	1	37
3	1	2	37
3	1	3	37
3	1	4	37
3	1	5	37
3	1	6	37
3	1	7	37
3	1	8	37
3	1	9	37
3	1	10	37
3	1	11	37
3	1	12	37
3	1	13	37
3	1	14	37
3	1	15	37
3	1	16	37
3	1	17	37
3	1	18	37
3	1	19	37
3	1	20	37
3	1	21	37
3	1	22	37
3	1	23	37
3	1	24	37
3	1	25	37
3	1	26	37
3	1	27	37
3	1	28	37
3	1	29	37
3	1	30	37
3	1	31	37
3	1	32	37
3	1	33	37
3	1	34	37
3	1	35	37
3	1	36	37
3	1	37	37
3	1	38	37
3	1	39	37
3	1	40	37
3	1	41	37
3	1	42	37
3	1	43	37
3	1	44	37
3	1	45	37
3	1	46	37
3	1	47	37
3	1	48	37
3	1	49	37
3	1	50	37
3	1	51	37
3	1	52	37
3	1	53	37
3	1	54	37
3	1	55	37
3	1	56	37
3	1	57	37
3	1	58	37
3	1	59	37
3	1	60	37
3	1	1	38
3	1	2	38
3	1	3	38
3	1	4	38
3	1	5	38
3	1	6	38
3	1	7	38
3	1	8	38
3	1	9	38
3	1	10	38
3	1	11	38
3	1	12	38
3	1	13	38
3	1	14	38
3	1	15	38
3	1	16	38
3	1	17	38
3	1	18	38
3	1	19	38
3	1	20	38
3	1	21	38
3	1	22	38
3	1	23	38
3	1	24	38
3	1	25	38
3	1	26	38
3	1	27	38
3	1	28	38
3	1	29	38
3	1	30	38
3	1	31	38
3	1	32	38
3	1	33	38
3	1	34	38
3	1	35	38
3	1	36	38
3	1	37	38
3	1	38	38
3	1	39	38
3	1	40	38
3	1	41	38
3	1	42	38
3	1	43	38
3	1	44	38
3	1	45	38
3	1	46	38
3	1	47	38
3	1	48	38
3	1	49	38
3	1	50	38
3	1	51	38
3	1	52	38
3	1	53	38
3	1	54	38
3	1	55	38
3	1	56	38
3	1	57	38
3	1	58	38
3	1	59	38
3	1	60	38
3	1	1	39
3	1	2	39
3	1	3	39
3	1	4	39
3	1	5	39
3	1	6	39
3	1	7	39
3	1	8	39
3	1	9	39
3	1	10	39
3	1	11	39
3	1	12	39
3	1	13	39
3	1	14	39
3	1	15	39
3	1	16	39
3	1	17	39
3	1	18	39
3	1	19	39
3	1	20	39
3	1	21	39
3	1	22	39
3	1	23	39
3	1	24	39
3	1	25	39
3	1	26	39
3	1	27	39
3	1	28	39
3	1	29	39
3	1	30	39
3	1	31	39
3	1	32	39
3	1	33	39
3	1	34	39
3	1	35	39
3	1	36	39
3	1	37	39
3	1	38	39
3	1	39	39
3	1	40	39
3	1	41	39
3	1	42	39
3	1	43	39
3	1	44	39
3	1	45	39
3	1	46	39
3	1	47	39
3	1	48	39
3	1	49	39
3	1	50	39
3	1	51	39
3	1	52	39
3	1	53	39
3	1	54	39
3	1	55	39
3	1	56	39
3	1	57	39
3	1	58	39
3	1	59	39
3	1	60	39
3	1	1	40
3	1	2	40
3	1	3	40
3	1	4	40
3	1	5	40
3	1	6	40
3	1	7	40
3	1	8	40
3	1	9	40
3	1	10	40
3	1	11	40
3	1	12	40
3	1	13	40
3	1	14	40
3	1	15	40
3	1	16	40
3	1	17	40
3	1	18	40
3	1	19	40
3	1	20	40
3	1	21	40
3	1	22	40
3	1	23	40
3	1	24	40
3	1	25	40
3	1	26	40
3	1	27	40
3	1	28	40
3	1	29	40
3	1	30	40
3	1	31	40
3	1	32	40
3	1	33	40
3	1	34	40
3	1	35	40
3	1	36	40
3	1	37	40
3	1	38	40
3	1	39	40
3	1	40	40
3	1	41	40
3	1	42	40
3	1	43	40
3	1	44	40
3	1	45	40
3	1	46	40
3	1	47	40
3	1	48	40
3	1	49	40
3	1	50	40
3	1	51	40
3	1	52	40
3	1	53	40
3	1	54	40
3	1	55	40
3	1	56	40
3	1	57	40
3	1	58	40
3	1	59	40
3	1	60	40
3	1	1	41
3	1	2	41
3	1	3	41
3	1	4	41
3	1	5	41
3	1	6	41
3	1	7	41
3	1	8	41
3	1	9	41
3	1	10	41
3	1	11	41
3	1	12	41
3	1	13	41
3	1	14	41
3	1	15	41
3	1	16	41
3	1	17	41
3	1	18	41
3	1	19	41
3	1	20	41
3	1	21	41
3	1	22	41
3	1	23	41
3	1	24	41
3	1	25	41
3	1	26	41
3	1	27	41
3	1	28	41
3	1	29	41
3	1	30	41
3	1	31	41
3	1	32	41
3	1	33	41
3	1	34	41
3	1	35	41
3	1	36	41
3	1	37	41
3	1	38	41
3	1	39	41
3	1	40	41
3	1	41	41
3	1	42	41
3	1	43	41
3	1	44	41
3	1	45	41
3	1	46	41
3	1	47	41
3	1	48	41
3	1	49	41
3	1	50	41
3	1	51	41
3	1	52	41
3	1	53	41
3	1	54	41
3	1	55	41
3	1	56	41
3	1	57	41
3	1	58	41
3	1	59	41
3	1	60	41
3	1	1	42
3	1	2	42
3	1	3	42
3	1	4	42
3	1	5	42
3	1	6	42
3	1	7	42
3	1	8	42
3	1	9	42
3	1	10	42
3	1	11	42
3	1	12	42
3	1	13	42
3	1	14	42
3	1	15	42
3	1	16	42
3	1	17	42
3	1	18	42
3	1	19	42
3	1	20	42
3	1	21	42
3	1	22	42
3	1	23	42
3	1	24	42
3	1	25	42
3	1	26	42
3	1	27	42
3	1	28	42
3	1	29	42
3	1	30	42
3	1	31	42
3	1	32	42
3	1	33	42
3	1	34	42
3	1	35	42
3	1	36	42
3	1	37	42
3	1	38	42
3	1	39	42
3	1	40	42
3	1	41	42
3	1	42	42
3	1	43	42
3	1	44	42
3	1	45	42
3	1	46	42
3	1	47	42
3	1	48	42
3	1	49	42
3	1	50	42
3	1	51	42
3	1	52	42
3	1	53	42
3	1	54	42
3	1	55	42
3	1	56	42
3	1	57	42
3	1	58	42
3	1	59	42
3	1	60	42
3	1	1	43
3	1	2	43
3	1	3	43
3	1	4	43
3	1	5	43
3	1	6	43
3	1	7	43
3	1	8	43
3	1	9	43
3	1	10	43
3	1	11	43
3	1	12	43
3	1	13	43
3	1	14	43
3	1	15	43
3	1	16	43
3	1	17	43
3	1	18	43
3	1	19	43
3	1	20	43
3	1	21	43
3	1	22	43
3	1	23	43
3	1	24	43
3	1	25	43
3	1	26	43
3	1	27	43
3	1	28	43
3	1	29	43
3	1	30	43
3	1	31	43
3	1	32	43
3	1	33	43
3	1	34	43
3	1	35	43
3	1	36	43
3	1	37	43
3	1	38	43
3	1	39	43
3	1	40	43
3	1	41	43
3	1	42	43
3	1	43	43
3	1	44	43
3	1	45	43
3	1	46	43
3	1	47	43
3	1	48	43
3	1	49	43
3	1	50	43
3	1	51	43
3	1	52	43
3	1	53	43
3	1	54	43
3	1	55	43
3	1	56	43
3	1	57	43
3	1	58	43
3	1	59	43
3	1	60	43
3	1	1	44
3	1	2	44
3	1	3	44
3	1	4	44
3	1	5	44
3	1	6	44
3	1	7	44
3	1	8	44
3	1	9	44
3	1	10	44
3	1	11	44
3	1	12	44
3	1	13	44
3	1	14	44
3	1	15	44
3	1	16	44
3	1	17	44
3	1	18	44
3	1	19	44
3	1	20	44
3	1	21	44
3	1	22	44
3	1	23	44
3	1	24	44
3	1	25	44
3	1	26	44
3	1	27	44
3	1	28	44
3	1	29	44
3	1	30	44
3	1	31	44
3	1	32	44
3	1	33	44
3	1	34	44
3	1	35	44
3	1	36	44
3	1	37	44
3	1	38	44
3	1	39	44
3	1	40	44
3	1	41	44
3	1	42	44
3	1	43	44
3	1	44	44
3	1	45	44
3	1	46	44
3	1	47	44
3	1	48	44
3	1	49	44
3	1	50	44
3	1	51	44
3	1	52	44
3	1	53	44
3	1	54	44
3	1	55	44
3	1	56	44
3	1	57	44
3	1	58	44
3	1	59	44
3	1	60	44
3	1	1	45
3	1	2	45
3	1	3	45
3	1	4	45
3	1	5	45
3	1	6	45
3	1	7	45
3	1	8	45
3	1	9	45
3	1	10	45
3	1	11	45
3	1	12	45
3	1	13	45
3	1	14	45
3	1	15	45
3	1	16	45
3	1	17	45
3	1	18	45
3	1	19	45
3	1	20	45
3	1	21	45
3	1	22	45
3	1	23	45
3	1	24	45
3	1	25	45
3	1	26	45
3	1	27	45
3	1	28	45
3	1	29	45
3	1	30	45
3	1	31	45
3	1	32	45
3	1	33	45
3	1	34	45
3	1	35	45
3	1	36	45
3	1	37	45
3	1	38	45
3	1	39	45
3	1	40	45
3	1	41	45
3	1	42	45
3	1	43	45
3	1	44	45
3	1	45	45
3	1	46	45
3	1	47	45
3	1	48	45
3	1	49	45
3	1	50	45
3	1	51	45
3	1	52	45
3	1	53	45
3	1	54	45
3	1	55	45
3	1	56	45
3	1	57	45
3	1	58	45
3	1	59	45
3	1	60	45
3	1	1	46
3	1	2	46
3	1	3	46
3	1	4	46
3	1	5	46
3	1	6	46
3	1	7	46
3	1	8	46
3	1	9	46
3	1	10	46
3	1	11	46
3	1	12	46
3	1	13	46
3	1	14	46
3	1	15	46
3	1	16	46
3	1	17	46
3	1	18	46
3	1	19	46
3	1	20	46
3	1	21	46
3	1	22	46
3	1	23	46
3	1	24	46
3	1	25	46
3	1	26	46
3	1	27	46
3	1	28	46
3	1	29	46
3	1	30	46
3	1	31	46
3	1	32	46
3	1	33	46
3	1	34	46
3	1	35	46
3	1	36	46
3	1	37	46
3	1	38	46
3	1	39	46
3	1	40	46
3	1	41	46
3	1	42	46
3	1	43	46
3	1	44	46
3	1	45	46
3	1	46	46
3	1	47	46
3	1	48	46
3	1	49	46
3	1	50	46
3	1	51	46
3	1	52	46
3	1	53	46
3	1	54	46
3	1	55	46
3	1	56	46
3	1	57	46
3	1	58	46
3	1	59	46
3	1	60	46
3	1	1	47
3	1	2	47
3	1	3	47
3	1	4	47
3	1	5	47
3	1	6	47
3	1	7	47
3	1	8	47
3	1	9	47
3	1	10	47
3	1	11	47
3	1	12	47
3	1	13	47
3	1	14	47
3	1	15	47
3	1	16	47
3	1	17	47
3	1	18	47
3	1	19	47
3	1	20	47
3	1	21	47
3	1	22	47
3	1	23	47
3	1	24	47
3	1	25	47
3	1	26	47
3	1	27	47
3	1	28	47
3	1	29	47
3	1	30	47
3	1	31	47
3	1	32	47
3	1	33	47
3	1	34	47
3	1	35	47
3	1	36	47
3	1	37	47
3	1	38	47
3	1	39	47
3	1	40	47
3	1	41	47
3	1	42	47
3	1	43	47
3	1	44	47
3	1	45	47
3	1	46	47
3	1	47	47
3	1	48	47
3	1	49	47
3	1	50	47
3	1	51	47
3	1	52	47
3	1	53	47
3	1	54	47
3	1	55	47
3	1	56	47
3	1	57	47
3	1	58	47
3	1	59	47
3	1	60	47
3	1	1	48
3	1	2	48
3	1	3	48
3	1	4	48
3	1	5	48
3	1	6	48
3	1	7	48
3	1	8	48
3	1	9	48
3	1	10	48
3	1	11	48
3	1	12	48
3	1	13	48
3	1	14	48
3	1	15	48
3	1	16	48
3	1	17	48
3	1	18	48
3	1	19	48
3	1	20	48
3	1	21	48
3	1	22	48
3	1	23	48
3	1	24	48
3	1	25	48
3	1	26	48
3	1	27	48
3	1	28	48
3	1	29	48
3	1	30	48
3	1	31	48
3	1	32	48
3	1	33	48
3	1	34	48
3	1	35	48
3	1	36	48
3	1	37	48
3	1	38	48
3	1	39	48
3	1	40	48
3	1	41	48
3	1	42	48
3	1	43	48
3	1	44	48
3	1	45	48
3	1	46	48
3	1	47	48
3	1	48	48
3	1	49	48
3	1	50	48
3	1	51	48
3	1	52	48
3	1	53	48
3	1	54	48
3	1	55	48
3	1	56	48
3	1	57	48
3	1	58	48
3	1	59	48
3	1	60	48
3	1	1	49
3	1	2	49
3	1	3	49
3	1	4	49
3	1	5	49
3	1	6	49
3	1	7	49
3	1	8	49
3	1	9	49
3	1	10	49
3	1	11	49
3	1	12	49
3	1	13	49
3	1	14	49
3	1	15	49
3	1	16	49
3	1	17	49
3	1	18	49
3	1	19	49
3	1	20	49
3	1	21	49
3	1	22	49
3	1	23	49
3	1	24	49
3	1	25	49
3	1	26	49
3	1	27	49
3	1	28	49
3	1	29	49
3	1	30	49
3	1	31	49
3	1	32	49
3	1	33	49
3	1	34	49
3	1	35	49
3	1	36	49
3	1	37	49
3	1	38	49
3	1	39	49
3	1	40	49
3	1	41	49
3	1	42	49
3	1	43	49
3	1	44	49
3	1	45	49
3	1	46	49
3	1	47	49
3	1	48	49
3	1	49	49
3	1	50	49
3	1	51	49
3	1	52	49
3	1	53	49
3	1	54	49
3	1	55	49
3	1	56	49
3	1	57	49
3	1	58	49
3	1	59	49
3	1	60	49
3	1	1	50
3	1	2	50
3	1	3	50
3	1	4	50
3	1	5	50
3	1	6	50
3	1	7	50
3	1	8	50
3	1	9	50
3	1	10	50
3	1	11	50
3	1	12	50
3	1	13	50
3	1	14	50
3	1	15	50
3	1	16	50
3	1	17	50
3	1	18	50
3	1	19	50
3	1	20	50
3	1	21	50
3	1	22	50
3	1	23	50
3	1	24	50
3	1	25	50
3	1	26	50
3	1	27	50
3	1	28	50
3	1	29	50
3	1	30	50
3	1	31	50
3	1	32	50
3	1	33	50
3	1	34	50
3	1	35	50
3	1	36	50
3	1	37	50
3	1	38	50
3	1	39	50
3	1	40	50
3	1	41	50
3	1	42	50
3	1	43	50
3	1	44	50
3	1	45	50
3	1	46	50
3	1	47	50
3	1	48	50
3	1	49	50
3	1	50	50
3	1	51	50
3	1	52	50
3	1	53	50
3	1	54	50
3	1	55	50
3	1	56	50
3	1	57	50
3	1	58	50
3	1	59	50
3	1	60	50
3	1	1	51
3	1	2	51
3	1	3	51
3	1	4	51
3	1	5	51
3	1	6	51
3	1	7	51
3	1	8	51
3	1	9	51
3	1	10	51
3	1	11	51
3	1	12	51
3	1	13	51
3	1	14	51
3	1	15	51
3	1	16	51
3	1	17	51
3	1	18	51
3	1	19	51
3	1	20	51
3	1	21	51
3	1	22	51
3	1	23	51
3	1	24	51
3	1	25	51
3	1	26	51
3	1	27	51
3	1	28	51
3	1	29	51
3	1	30	51
3	1	31	51
3	1	32	51
3	1	33	51
3	1	34	51
3	1	35	51
3	1	36	51
3	1	37	51
3	1	38	51
3	1	39	51
3	1	40	51
3	1	41	51
3	1	42	51
3	1	43	51
3	1	44	51
3	1	45	51
3	1	46	51
3	1	47	51
3	1	48	51
3	1	49	51
3	1	50	51
3	1	51	51
3	1	52	51
3	1	53	51
3	1	54	51
3	1	55	51
3	1	56	51
3	1	57	51
3	1	58	51
3	1	59	51
3	1	60	51
3	1	1	52
3	1	2	52
3	1	3	52
3	1	4	52
3	1	5	52
3	1	6	52
3	1	7	52
3	1	8	52
3	1	9	52
3	1	10	52
3	1	11	52
3	1	12	52
3	1	13	52
3	1	14	52
3	1	15	52
3	1	16	52
3	1	17	52
3	1	18	52
3	1	19	52
3	1	20	52
3	1	21	52
3	1	22	52
3	1	23	52
3	1	24	52
3	1	25	52
3	1	26	52
3	1	27	52
3	1	28	52
3	1	29	52
3	1	30	52
3	1	31	52
3	1	32	52
3	1	33	52
3	1	34	52
3	1	35	52
3	1	36	52
3	1	37	52
3	1	38	52
3	1	39	52
3	1	40	52
3	1	41	52
3	1	42	52
3	1	43	52
3	1	44	52
3	1	45	52
3	1	46	52
3	1	47	52
3	1	48	52
3	1	49	52
3	1	50	52
3	1	51	52
3	1	52	52
3	1	53	52
3	1	54	52
3	1	55	52
3	1	56	52
3	1	57	52
3	1	58	52
3	1	59	52
3	1	60	52
3	1	1	53
3	1	2	53
3	1	3	53
3	1	4	53
3	1	5	53
3	1	6	53
3	1	7	53
3	1	8	53
3	1	9	53
3	1	10	53
3	1	11	53
3	1	12	53
3	1	13	53
3	1	14	53
3	1	15	53
3	1	16	53
3	1	17	53
3	1	18	53
3	1	19	53
3	1	20	53
3	1	21	53
3	1	22	53
3	1	23	53
3	1	24	53
3	1	25	53
3	1	26	53
3	1	27	53
3	1	28	53
3	1	29	53
3	1	30	53
3	1	31	53
3	1	32	53
3	1	33	53
3	1	34	53
3	1	35	53
3	1	36	53
3	1	37	53
3	1	38	53
3	1	39	53
3	1	40	53
3	1	41	53
3	1	42	53
3	1	43	53
3	1	44	53
3	1	45	53
3	1	46	53
3	1	47	53
3	1	48	53
3	1	49	53
3	1	50	53
3	1	51	53
3	1	52	53
3	1	53	53
3	1	54	53
3	1	55	53
3	1	56	53
3	1	57	53
3	1	58	53
3	1	59	53
3	1	60	53
3	1	1	54
3	1	2	54
3	1	3	54
3	1	4	54
3	1	5	54
3	1	6	54
3	1	7	54
3	1	8	54
3	1	9	54
3	1	10	54
3	1	11	54
3	1	12	54
3	1	13	54
3	1	14	54
3	1	15	54
3	1	16	54
3	1	17	54
3	1	18	54
3	1	19	54
3	1	20	54
3	1	21	54
3	1	22	54
3	1	23	54
3	1	24	54
3	1	25	54
3	1	26	54
3	1	27	54
3	1	28	54
3	1	29	54
3	1	30	54
3	1	31	54
3	1	32	54
3	1	33	54
3	1	34	54
3	1	35	54
3	1	36	54
3	1	37	54
3	1	38	54
3	1	39	54
3	1	40	54
3	1	41	54
3	1	42	54
3	1	43	54
3	1	44	54
3	1	45	54
3	1	46	54
3	1	47	54
3	1	48	54
3	1	49	54
3	1	50	54
3	1	51	54
3	1	52	54
3	1	53	54
3	1	54	54
3	1	55	54
3	1	56	54
3	1	57	54
3	1	58	54
3	1	59	54
3	1	60	54
3	1	1	55
3	1	2	55
3	1	3	55
3	1	4	55
3	1	5	55
3	1	6	55
3	1	7	55
3	1	8	55
3	1	9	55
3	1	10	55
3	1	11	55
3	1	12	55
3	1	13	55
3	1	14	55
3	1	15	55
3	1	16	55
3	1	17	55
3	1	18	55
3	1	19	55
3	1	20	55
3	1	21	55
3	1	22	55
3	1	23	55
3	1	24	55
3	1	25	55
3	1	26	55
3	1	27	55
3	1	28	55
3	1	29	55
3	1	30	55
3	1	31	55
3	1	32	55
3	1	33	55
3	1	34	55
3	1	35	55
3	1	36	55
3	1	37	55
3	1	38	55
3	1	39	55
3	1	40	55
3	1	41	55
3	1	42	55
3	1	43	55
3	1	44	55
3	1	45	55
3	1	46	55
3	1	47	55
3	1	48	55
3	1	49	55
3	1	50	55
3	1	51	55
3	1	52	55
3	1	53	55
3	1	54	55
3	1	55	55
3	1	56	55
3	1	57	55
3	1	58	55
3	1	59	55
3	1	60	55
3	1	1	56
3	1	2	56
3	1	3	56
3	1	4	56
3	1	5	56
3	1	6	56
3	1	7	56
3	1	8	56
3	1	9	56
3	1	10	56
3	1	11	56
3	1	12	56
3	1	13	56
3	1	14	56
3	1	15	56
3	1	16	56
3	1	17	56
3	1	18	56
3	1	19	56
3	1	20	56
3	1	21	56
3	1	22	56
3	1	23	56
3	1	24	56
3	1	25	56
3	1	26	56
3	1	27	56
3	1	28	56
3	1	29	56
3	1	30	56
3	1	31	56
3	1	32	56
3	1	33	56
3	1	34	56
3	1	35	56
3	1	36	56
3	1	37	56
3	1	38	56
3	1	39	56
3	1	40	56
3	1	41	56
3	1	42	56
3	1	43	56
3	1	44	56
3	1	45	56
3	1	46	56
3	1	47	56
3	1	48	56
3	1	49	56
3	1	50	56
3	1	51	56
3	1	52	56
3	1	53	56
3	1	54	56
3	1	55	56
3	1	56	56
3	1	57	56
3	1	58	56
3	1	59	56
3	1	60	56
3	1	1	57
3	1	2	57
3	1	3	57
3	1	4	57
3	1	5	57
3	1	6	57
3	1	7	57
3	1	8	57
3	1	9	57
3	1	10	57
3	1	11	57
3	1	12	57
3	1	13	57
3	1	14	57
3	1	15	57
3	1	16	57
3	1	17	57
3	1	18	57
3	1	19	57
3	1	20	57
3	1	21	57
3	1	22	57
3	1	23	57
3	1	24	57
3	1	25	57
3	1	26	57
3	1	27	57
3	1	28	57
3	1	29	57
3	1	30	57
3	1	31	57
3	1	32	57
3	1	33	57
3	1	34	57
3	1	35	57
3	1	36	57
3	1	37	57
3	1	38	57
3	1	39	57
3	1	40	57
3	1	41	57
3	1	42	57
3	1	43	57
3	1	44	57
3	1	45	57
3	1	46	57
3	1	47	57
3	1	48	57
3	1	49	57
3	1	50	57
3	1	51	57
3	1	52	57
3	1	53	57
3	1	54	57
3	1	55	57
3	1	56	57
3	1	57	57
3	1	58	57
3	1	59	57
3	1	60	57
3	1	1	58
3	1	2	58
3	1	3	58
3	1	4	58
3	1	5	58
3	1	6	58
3	1	7	58
3	1	8	58
3	1	9	58
3	1	10	58
3	1	11	58
3	1	12	58
3	1	13	58
3	1	14	58
3	1	15	58
3	1	16	58
3	1	17	58
3	1	18	58
3	1	19	58
3	1	20	58
3	1	21	58
3	1	22	58
3	1	23	58
3	1	24	58
3	1	25	58
3	1	26	58
3	1	27	58
3	1	28	58
3	1	29	58
3	1	30	58
3	1	31	58
3	1	32	58
3	1	33	58
3	1	34	58
3	1	35	58
3	1	36	58
3	1	37	58
3	1	38	58
3	1	39	58
3	1	40	58
3	1	41	58
3	1	42	58
3	1	43	58
3	1	44	58
3	1	45	58
3	1	46	58
3	1	47	58
3	1	48	58
3	1	49	58
3	1	50	58
3	1	51	58
3	1	52	58
3	1	53	58
3	1	54	58
3	1	55	58
3	1	56	58
3	1	57	58
3	1	58	58
3	1	59	58
3	1	60	58
3	1	1	59
3	1	2	59
3	1	3	59
3	1	4	59
3	1	5	59
3	1	6	59
3	1	7	59
3	1	8	59
3	1	9	59
3	1	10	59
3	1	11	59
3	1	12	59
3	1	13	59
3	1	14	59
3	1	15	59
3	1	16	59
3	1	17	59
3	1	18	59
3	1	19	59
3	1	20	59
3	1	21	59
3	1	22	59
3	1	23	59
3	1	24	59
3	1	25	59
3	1	26	59
3	1	27	59
3	1	28	59
3	1	29	59
3	1	30	59
3	1	31	59
3	1	32	59
3	1	33	59
3	1	34	59
3	1	35	59
3	1	36	59
3	1	37	59
3	1	38	59
3	1	39	59
3	1	40	59
3	1	41	59
3	1	42	59
3	1	43	59
3	1	44	59
3	1	45	59
3	1	46	59
3	1	47	59
3	1	48	59
3	1	49	59
3	1	50	59
3	1	51	59
3	1	52	59
3	1	53	59
3	1	54	59
3	1	55	59
3	1	56	59
3	1	57	59
3	1	58	59
3	1	59	59
3	1	60	59
3	1	1	60
3	1	2	60
3	1	3	60
3	1	4	60
3	1	5	60
3	1	6	60
3	1	7	60
3	1	8	60
3	1	9	60
3	1	10	60
3	1	11	60
3	1	12	60
3	1	13	60
3	1	14	60
3	1	15	60
3	1	16	60
3	1	17	60
3	1	18	60
3	1	19	60
3	1	20	60
3	1	21	60
3	1	22	60
3	1	23	60
3	1	24	60
3	1	25	60
3	1	26	60
3	1	27	60
3	1	28	60
3	1	29	60
3	1	30	60
3	1	31	60
3	1	32	60
3	1	33	60
3	1	34	60
3	1	35	60
3	1	36	60
3	1	37	60
3	1	38	60
3	1	39	60
3	1	40	60
3	1	41	60
3	1	42	60
3	1	43	60
3	1	44	60
3	1	45	60
3	1	46	60
3	1	47	60
3	1	48	60
3	1	49	60
3	1	50	60
3	1	51	60
3	1	52	60
3	1	53	60
3	1	54	60
3	1	55	60
3	1	56	60
3	1	57	60
3	1	58	60
3	1	59	60
3	1	60	60
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
4	1	16	1
4	1	17	1
4	1	18	1
4	1	19	1
4	1	20	1
4	1	21	1
4	1	22	1
4	1	23	1
4	1	24	1
4	1	25	1
4	1	26	1
4	1	27	1
4	1	28	1
4	1	29	1
4	1	30	1
4	1	31	1
4	1	32	1
4	1	33	1
4	1	34	1
4	1	35	1
4	1	36	1
4	1	37	1
4	1	38	1
4	1	39	1
4	1	40	1
4	1	41	1
4	1	42	1
4	1	43	1
4	1	44	1
4	1	45	1
4	1	46	1
4	1	47	1
4	1	48	1
4	1	49	1
4	1	50	1
4	1	51	1
4	1	52	1
4	1	53	1
4	1	54	1
4	1	55	1
4	1	56	1
4	1	57	1
4	1	58	1
4	1	59	1
4	1	60	1
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
4	1	16	2
4	1	17	2
4	1	18	2
4	1	19	2
4	1	20	2
4	1	21	2
4	1	22	2
4	1	23	2
4	1	24	2
4	1	25	2
4	1	26	2
4	1	27	2
4	1	28	2
4	1	29	2
4	1	30	2
4	1	31	2
4	1	32	2
4	1	33	2
4	1	34	2
4	1	35	2
4	1	36	2
4	1	37	2
4	1	38	2
4	1	39	2
4	1	40	2
4	1	41	2
4	1	42	2
4	1	43	2
4	1	44	2
4	1	45	2
4	1	46	2
4	1	47	2
4	1	48	2
4	1	49	2
4	1	50	2
4	1	51	2
4	1	52	2
4	1	53	2
4	1	54	2
4	1	55	2
4	1	56	2
4	1	57	2
4	1	58	2
4	1	59	2
4	1	60	2
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
4	1	16	3
4	1	17	3
4	1	18	3
4	1	19	3
4	1	20	3
4	1	21	3
4	1	22	3
4	1	23	3
4	1	24	3
4	1	25	3
4	1	26	3
4	1	27	3
4	1	28	3
4	1	29	3
4	1	30	3
4	1	31	3
4	1	32	3
4	1	33	3
4	1	34	3
4	1	35	3
4	1	36	3
4	1	37	3
4	1	38	3
4	1	39	3
4	1	40	3
4	1	41	3
4	1	42	3
4	1	43	3
4	1	44	3
4	1	45	3
4	1	46	3
4	1	47	3
4	1	48	3
4	1	49	3
4	1	50	3
4	1	51	3
4	1	52	3
4	1	53	3
4	1	54	3
4	1	55	3
4	1	56	3
4	1	57	3
4	1	58	3
4	1	59	3
4	1	60	3
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
4	1	16	4
4	1	17	4
4	1	18	4
4	1	19	4
4	1	20	4
4	1	21	4
4	1	22	4
4	1	23	4
4	1	24	4
4	1	25	4
4	1	26	4
4	1	27	4
4	1	28	4
4	1	29	4
4	1	30	4
4	1	31	4
4	1	32	4
4	1	33	4
4	1	34	4
4	1	35	4
4	1	36	4
4	1	37	4
4	1	38	4
4	1	39	4
4	1	40	4
4	1	41	4
4	1	42	4
4	1	43	4
4	1	44	4
4	1	45	4
4	1	46	4
4	1	47	4
4	1	48	4
4	1	49	4
4	1	50	4
4	1	51	4
4	1	52	4
4	1	53	4
4	1	54	4
4	1	55	4
4	1	56	4
4	1	57	4
4	1	58	4
4	1	59	4
4	1	60	4
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
4	1	16	5
4	1	17	5
4	1	18	5
4	1	19	5
4	1	20	5
4	1	21	5
4	1	22	5
4	1	23	5
4	1	24	5
4	1	25	5
4	1	26	5
4	1	27	5
4	1	28	5
4	1	29	5
4	1	30	5
4	1	31	5
4	1	32	5
4	1	33	5
4	1	34	5
4	1	35	5
4	1	36	5
4	1	37	5
4	1	38	5
4	1	39	5
4	1	40	5
4	1	41	5
4	1	42	5
4	1	43	5
4	1	44	5
4	1	45	5
4	1	46	5
4	1	47	5
4	1	48	5
4	1	49	5
4	1	50	5
4	1	51	5
4	1	52	5
4	1	53	5
4	1	54	5
4	1	55	5
4	1	56	5
4	1	57	5
4	1	58	5
4	1	59	5
4	1	60	5
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
4	1	16	6
4	1	17	6
4	1	18	6
4	1	19	6
4	1	20	6
4	1	21	6
4	1	22	6
4	1	23	6
4	1	24	6
4	1	25	6
4	1	26	6
4	1	27	6
4	1	28	6
4	1	29	6
4	1	30	6
4	1	31	6
4	1	32	6
4	1	33	6
4	1	34	6
4	1	35	6
4	1	36	6
4	1	37	6
4	1	38	6
4	1	39	6
4	1	40	6
4	1	41	6
4	1	42	6
4	1	43	6
4	1	44	6
4	1	45	6
4	1	46	6
4	1	47	6
4	1	48	6
4	1	49	6
4	1	50	6
4	1	51	6
4	1	52	6
4	1	53	6
4	1	54	6
4	1	55	6
4	1	56	6
4	1	57	6
4	1	58	6
4	1	59	6
4	1	60	6
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
4	1	16	7
4	1	17	7
4	1	18	7
4	1	19	7
4	1	20	7
4	1	21	7
4	1	22	7
4	1	23	7
4	1	24	7
4	1	25	7
4	1	26	7
4	1	27	7
4	1	28	7
4	1	29	7
4	1	30	7
4	1	31	7
4	1	32	7
4	1	33	7
4	1	34	7
4	1	35	7
4	1	36	7
4	1	37	7
4	1	38	7
4	1	39	7
4	1	40	7
4	1	41	7
4	1	42	7
4	1	43	7
4	1	44	7
4	1	45	7
4	1	46	7
4	1	47	7
4	1	48	7
4	1	49	7
4	1	50	7
4	1	51	7
4	1	52	7
4	1	53	7
4	1	54	7
4	1	55	7
4	1	56	7
4	1	57	7
4	1	58	7
4	1	59	7
4	1	60	7
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
4	1	16	8
4	1	17	8
4	1	18	8
4	1	19	8
4	1	20	8
4	1	21	8
4	1	22	8
4	1	23	8
4	1	24	8
4	1	25	8
4	1	26	8
4	1	27	8
4	1	28	8
4	1	29	8
4	1	30	8
4	1	31	8
4	1	32	8
4	1	33	8
4	1	34	8
4	1	35	8
4	1	36	8
4	1	37	8
4	1	38	8
4	1	39	8
4	1	40	8
4	1	41	8
4	1	42	8
4	1	43	8
4	1	44	8
4	1	45	8
4	1	46	8
4	1	47	8
4	1	48	8
4	1	49	8
4	1	50	8
4	1	51	8
4	1	52	8
4	1	53	8
4	1	54	8
4	1	55	8
4	1	56	8
4	1	57	8
4	1	58	8
4	1	59	8
4	1	60	8
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
4	1	16	9
4	1	17	9
4	1	18	9
4	1	19	9
4	1	20	9
4	1	21	9
4	1	22	9
4	1	23	9
4	1	24	9
4	1	25	9
4	1	26	9
4	1	27	9
4	1	28	9
4	1	29	9
4	1	30	9
4	1	31	9
4	1	32	9
4	1	33	9
4	1	34	9
4	1	35	9
4	1	36	9
4	1	37	9
4	1	38	9
4	1	39	9
4	1	40	9
4	1	41	9
4	1	42	9
4	1	43	9
4	1	44	9
4	1	45	9
4	1	46	9
4	1	47	9
4	1	48	9
4	1	49	9
4	1	50	9
4	1	51	9
4	1	52	9
4	1	53	9
4	1	54	9
4	1	55	9
4	1	56	9
4	1	57	9
4	1	58	9
4	1	59	9
4	1	60	9
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
4	1	16	10
4	1	17	10
4	1	18	10
4	1	19	10
4	1	20	10
4	1	21	10
4	1	22	10
4	1	23	10
4	1	24	10
4	1	25	10
4	1	26	10
4	1	27	10
4	1	28	10
4	1	29	10
4	1	30	10
4	1	31	10
4	1	32	10
4	1	33	10
4	1	34	10
4	1	35	10
4	1	36	10
4	1	37	10
4	1	38	10
4	1	39	10
4	1	40	10
4	1	41	10
4	1	42	10
4	1	43	10
4	1	44	10
4	1	45	10
4	1	46	10
4	1	47	10
4	1	48	10
4	1	49	10
4	1	50	10
4	1	51	10
4	1	52	10
4	1	53	10
4	1	54	10
4	1	55	10
4	1	56	10
4	1	57	10
4	1	58	10
4	1	59	10
4	1	60	10
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
4	1	16	11
4	1	17	11
4	1	18	11
4	1	19	11
4	1	20	11
4	1	21	11
4	1	22	11
4	1	23	11
4	1	24	11
4	1	25	11
4	1	26	11
4	1	27	11
4	1	28	11
4	1	29	11
4	1	30	11
4	1	31	11
4	1	32	11
4	1	33	11
4	1	34	11
4	1	35	11
4	1	36	11
4	1	37	11
4	1	38	11
4	1	39	11
4	1	40	11
4	1	41	11
4	1	42	11
4	1	43	11
4	1	44	11
4	1	45	11
4	1	46	11
4	1	47	11
4	1	48	11
4	1	49	11
4	1	50	11
4	1	51	11
4	1	52	11
4	1	53	11
4	1	54	11
4	1	55	11
4	1	56	11
4	1	57	11
4	1	58	11
4	1	59	11
4	1	60	11
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
4	1	16	12
4	1	17	12
4	1	18	12
4	1	19	12
4	1	20	12
4	1	21	12
4	1	22	12
4	1	23	12
4	1	24	12
4	1	25	12
4	1	26	12
4	1	27	12
4	1	28	12
4	1	29	12
4	1	30	12
4	1	31	12
4	1	32	12
4	1	33	12
4	1	34	12
4	1	35	12
4	1	36	12
4	1	37	12
4	1	38	12
4	1	39	12
4	1	40	12
4	1	41	12
4	1	42	12
4	1	43	12
4	1	44	12
4	1	45	12
4	1	46	12
4	1	47	12
4	1	48	12
4	1	49	12
4	1	50	12
4	1	51	12
4	1	52	12
4	1	53	12
4	1	54	12
4	1	55	12
4	1	56	12
4	1	57	12
4	1	58	12
4	1	59	12
4	1	60	12
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
4	1	16	13
4	1	17	13
4	1	18	13
4	1	19	13
4	1	20	13
4	1	21	13
4	1	22	13
4	1	23	13
4	1	24	13
4	1	25	13
4	1	26	13
4	1	27	13
4	1	28	13
4	1	29	13
4	1	30	13
4	1	31	13
4	1	32	13
4	1	33	13
4	1	34	13
4	1	35	13
4	1	36	13
4	1	37	13
4	1	38	13
4	1	39	13
4	1	40	13
4	1	41	13
4	1	42	13
4	1	43	13
4	1	44	13
4	1	45	13
4	1	46	13
4	1	47	13
4	1	48	13
4	1	49	13
4	1	50	13
4	1	51	13
4	1	52	13
4	1	53	13
4	1	54	13
4	1	55	13
4	1	56	13
4	1	57	13
4	1	58	13
4	1	59	13
4	1	60	13
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
4	1	16	14
4	1	17	14
4	1	18	14
4	1	19	14
4	1	20	14
4	1	21	14
4	1	22	14
4	1	23	14
4	1	24	14
4	1	25	14
4	1	26	14
4	1	27	14
4	1	28	14
4	1	29	14
4	1	30	14
4	1	31	14
4	1	32	14
4	1	33	14
4	1	34	14
4	1	35	14
4	1	36	14
4	1	37	14
4	1	38	14
4	1	39	14
4	1	40	14
4	1	41	14
4	1	42	14
4	1	43	14
4	1	44	14
4	1	45	14
4	1	46	14
4	1	47	14
4	1	48	14
4	1	49	14
4	1	50	14
4	1	51	14
4	1	52	14
4	1	53	14
4	1	54	14
4	1	55	14
4	1	56	14
4	1	57	14
4	1	58	14
4	1	59	14
4	1	60	14
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
4	1	16	15
4	1	17	15
4	1	18	15
4	1	19	15
4	1	20	15
4	1	21	15
4	1	22	15
4	1	23	15
4	1	24	15
4	1	25	15
4	1	26	15
4	1	27	15
4	1	28	15
4	1	29	15
4	1	30	15
4	1	31	15
4	1	32	15
4	1	33	15
4	1	34	15
4	1	35	15
4	1	36	15
4	1	37	15
4	1	38	15
4	1	39	15
4	1	40	15
4	1	41	15
4	1	42	15
4	1	43	15
4	1	44	15
4	1	45	15
4	1	46	15
4	1	47	15
4	1	48	15
4	1	49	15
4	1	50	15
4	1	51	15
4	1	52	15
4	1	53	15
4	1	54	15
4	1	55	15
4	1	56	15
4	1	57	15
4	1	58	15
4	1	59	15
4	1	60	15
4	1	1	16
4	1	2	16
4	1	3	16
4	1	4	16
4	1	5	16
4	1	6	16
4	1	7	16
4	1	8	16
4	1	9	16
4	1	10	16
4	1	11	16
4	1	12	16
4	1	13	16
4	1	14	16
4	1	15	16
4	1	16	16
4	1	17	16
4	1	18	16
4	1	19	16
4	1	20	16
4	1	21	16
4	1	22	16
4	1	23	16
4	1	24	16
4	1	25	16
4	1	26	16
4	1	27	16
4	1	28	16
4	1	29	16
4	1	30	16
4	1	31	16
4	1	32	16
4	1	33	16
4	1	34	16
4	1	35	16
4	1	36	16
4	1	37	16
4	1	38	16
4	1	39	16
4	1	40	16
4	1	41	16
4	1	42	16
4	1	43	16
4	1	44	16
4	1	45	16
4	1	46	16
4	1	47	16
4	1	48	16
4	1	49	16
4	1	50	16
4	1	51	16
4	1	52	16
4	1	53	16
4	1	54	16
4	1	55	16
4	1	56	16
4	1	57	16
4	1	58	16
4	1	59	16
4	1	60	16
4	1	1	17
4	1	2	17
4	1	3	17
4	1	4	17
4	1	5	17
4	1	6	17
4	1	7	17
4	1	8	17
4	1	9	17
4	1	10	17
4	1	11	17
4	1	12	17
4	1	13	17
4	1	14	17
4	1	15	17
4	1	16	17
4	1	17	17
4	1	18	17
4	1	19	17
4	1	20	17
4	1	21	17
4	1	22	17
4	1	23	17
4	1	24	17
4	1	25	17
4	1	26	17
4	1	27	17
4	1	28	17
4	1	29	17
4	1	30	17
4	1	31	17
4	1	32	17
4	1	33	17
4	1	34	17
4	1	35	17
4	1	36	17
4	1	37	17
4	1	38	17
4	1	39	17
4	1	40	17
4	1	41	17
4	1	42	17
4	1	43	17
4	1	44	17
4	1	45	17
4	1	46	17
4	1	47	17
4	1	48	17
4	1	49	17
4	1	50	17
4	1	51	17
4	1	52	17
4	1	53	17
4	1	54	17
4	1	55	17
4	1	56	17
4	1	57	17
4	1	58	17
4	1	59	17
4	1	60	17
4	1	1	18
4	1	2	18
4	1	3	18
4	1	4	18
4	1	5	18
4	1	6	18
4	1	7	18
4	1	8	18
4	1	9	18
4	1	10	18
4	1	11	18
4	1	12	18
4	1	13	18
4	1	14	18
4	1	15	18
4	1	16	18
4	1	17	18
4	1	18	18
4	1	19	18
4	1	20	18
4	1	21	18
4	1	22	18
4	1	23	18
4	1	24	18
4	1	25	18
4	1	26	18
4	1	27	18
4	1	28	18
4	1	29	18
4	1	30	18
4	1	31	18
4	1	32	18
4	1	33	18
4	1	34	18
4	1	35	18
4	1	36	18
4	1	37	18
4	1	38	18
4	1	39	18
4	1	40	18
4	1	41	18
4	1	42	18
4	1	43	18
4	1	44	18
4	1	45	18
4	1	46	18
4	1	47	18
4	1	48	18
4	1	49	18
4	1	50	18
4	1	51	18
4	1	52	18
4	1	53	18
4	1	54	18
4	1	55	18
4	1	56	18
4	1	57	18
4	1	58	18
4	1	59	18
4	1	60	18
4	1	1	19
4	1	2	19
4	1	3	19
4	1	4	19
4	1	5	19
4	1	6	19
4	1	7	19
4	1	8	19
4	1	9	19
4	1	10	19
4	1	11	19
4	1	12	19
4	1	13	19
4	1	14	19
4	1	15	19
4	1	16	19
4	1	17	19
4	1	18	19
4	1	19	19
4	1	20	19
4	1	21	19
4	1	22	19
4	1	23	19
4	1	24	19
4	1	25	19
4	1	26	19
4	1	27	19
4	1	28	19
4	1	29	19
4	1	30	19
4	1	31	19
4	1	32	19
4	1	33	19
4	1	34	19
4	1	35	19
4	1	36	19
4	1	37	19
4	1	38	19
4	1	39	19
4	1	40	19
4	1	41	19
4	1	42	19
4	1	43	19
4	1	44	19
4	1	45	19
4	1	46	19
4	1	47	19
4	1	48	19
4	1	49	19
4	1	50	19
4	1	51	19
4	1	52	19
4	1	53	19
4	1	54	19
4	1	55	19
4	1	56	19
4	1	57	19
4	1	58	19
4	1	59	19
4	1	60	19
4	1	1	20
4	1	2	20
4	1	3	20
4	1	4	20
4	1	5	20
4	1	6	20
4	1	7	20
4	1	8	20
4	1	9	20
4	1	10	20
4	1	11	20
4	1	12	20
4	1	13	20
4	1	14	20
4	1	15	20
4	1	16	20
4	1	17	20
4	1	18	20
4	1	19	20
4	1	20	20
4	1	21	20
4	1	22	20
4	1	23	20
4	1	24	20
4	1	25	20
4	1	26	20
4	1	27	20
4	1	28	20
4	1	29	20
4	1	30	20
4	1	31	20
4	1	32	20
4	1	33	20
4	1	34	20
4	1	35	20
4	1	36	20
4	1	37	20
4	1	38	20
4	1	39	20
4	1	40	20
4	1	41	20
4	1	42	20
4	1	43	20
4	1	44	20
4	1	45	20
4	1	46	20
4	1	47	20
4	1	48	20
4	1	49	20
4	1	50	20
4	1	51	20
4	1	52	20
4	1	53	20
4	1	54	20
4	1	55	20
4	1	56	20
4	1	57	20
4	1	58	20
4	1	59	20
4	1	60	20
4	1	1	21
4	1	2	21
4	1	3	21
4	1	4	21
4	1	5	21
4	1	6	21
4	1	7	21
4	1	8	21
4	1	9	21
4	1	10	21
4	1	11	21
4	1	12	21
4	1	13	21
4	1	14	21
4	1	15	21
4	1	16	21
4	1	17	21
4	1	18	21
4	1	19	21
4	1	20	21
4	1	21	21
4	1	22	21
4	1	23	21
4	1	24	21
4	1	25	21
4	1	26	21
4	1	27	21
4	1	28	21
4	1	29	21
4	1	30	21
4	1	31	21
4	1	32	21
4	1	33	21
4	1	34	21
4	1	35	21
4	1	36	21
4	1	37	21
4	1	38	21
4	1	39	21
4	1	40	21
4	1	41	21
4	1	42	21
4	1	43	21
4	1	44	21
4	1	45	21
4	1	46	21
4	1	47	21
4	1	48	21
4	1	49	21
4	1	50	21
4	1	51	21
4	1	52	21
4	1	53	21
4	1	54	21
4	1	55	21
4	1	56	21
4	1	57	21
4	1	58	21
4	1	59	21
4	1	60	21
4	1	1	22
4	1	2	22
4	1	3	22
4	1	4	22
4	1	5	22
4	1	6	22
4	1	7	22
4	1	8	22
4	1	9	22
4	1	10	22
4	1	11	22
4	1	12	22
4	1	13	22
4	1	14	22
4	1	15	22
4	1	16	22
4	1	17	22
4	1	18	22
4	1	19	22
4	1	20	22
4	1	21	22
4	1	22	22
4	1	23	22
4	1	24	22
4	1	25	22
4	1	26	22
4	1	27	22
4	1	28	22
4	1	29	22
4	1	30	22
4	1	31	22
4	1	32	22
4	1	33	22
4	1	34	22
4	1	35	22
4	1	36	22
4	1	37	22
4	1	38	22
4	1	39	22
4	1	40	22
4	1	41	22
4	1	42	22
4	1	43	22
4	1	44	22
4	1	45	22
4	1	46	22
4	1	47	22
4	1	48	22
4	1	49	22
4	1	50	22
4	1	51	22
4	1	52	22
4	1	53	22
4	1	54	22
4	1	55	22
4	1	56	22
4	1	57	22
4	1	58	22
4	1	59	22
4	1	60	22
4	1	1	23
4	1	2	23
4	1	3	23
4	1	4	23
4	1	5	23
4	1	6	23
4	1	7	23
4	1	8	23
4	1	9	23
4	1	10	23
4	1	11	23
4	1	12	23
4	1	13	23
4	1	14	23
4	1	15	23
4	1	16	23
4	1	17	23
4	1	18	23
4	1	19	23
4	1	20	23
4	1	21	23
4	1	22	23
4	1	23	23
4	1	24	23
4	1	25	23
4	1	26	23
4	1	27	23
4	1	28	23
4	1	29	23
4	1	30	23
4	1	31	23
4	1	32	23
4	1	33	23
4	1	34	23
4	1	35	23
4	1	36	23
4	1	37	23
4	1	38	23
4	1	39	23
4	1	40	23
4	1	41	23
4	1	42	23
4	1	43	23
4	1	44	23
4	1	45	23
4	1	46	23
4	1	47	23
4	1	48	23
4	1	49	23
4	1	50	23
4	1	51	23
4	1	52	23
4	1	53	23
4	1	54	23
4	1	55	23
4	1	56	23
4	1	57	23
4	1	58	23
4	1	59	23
4	1	60	23
4	1	1	24
4	1	2	24
4	1	3	24
4	1	4	24
4	1	5	24
4	1	6	24
4	1	7	24
4	1	8	24
4	1	9	24
4	1	10	24
4	1	11	24
4	1	12	24
4	1	13	24
4	1	14	24
4	1	15	24
4	1	16	24
4	1	17	24
4	1	18	24
4	1	19	24
4	1	20	24
4	1	21	24
4	1	22	24
4	1	23	24
4	1	24	24
4	1	25	24
4	1	26	24
4	1	27	24
4	1	28	24
4	1	29	24
4	1	30	24
4	1	31	24
4	1	32	24
4	1	33	24
4	1	34	24
4	1	35	24
4	1	36	24
4	1	37	24
4	1	38	24
4	1	39	24
4	1	40	24
4	1	41	24
4	1	42	24
4	1	43	24
4	1	44	24
4	1	45	24
4	1	46	24
4	1	47	24
4	1	48	24
4	1	49	24
4	1	50	24
4	1	51	24
4	1	52	24
4	1	53	24
4	1	54	24
4	1	55	24
4	1	56	24
4	1	57	24
4	1	58	24
4	1	59	24
4	1	60	24
4	1	1	25
4	1	2	25
4	1	3	25
4	1	4	25
4	1	5	25
4	1	6	25
4	1	7	25
4	1	8	25
4	1	9	25
4	1	10	25
4	1	11	25
4	1	12	25
4	1	13	25
4	1	14	25
4	1	15	25
4	1	16	25
4	1	17	25
4	1	18	25
4	1	19	25
4	1	20	25
4	1	21	25
4	1	22	25
4	1	23	25
4	1	24	25
4	1	25	25
4	1	26	25
4	1	27	25
4	1	28	25
4	1	29	25
4	1	30	25
4	1	31	25
4	1	32	25
4	1	33	25
4	1	34	25
4	1	35	25
4	1	36	25
4	1	37	25
4	1	38	25
4	1	39	25
4	1	40	25
4	1	41	25
4	1	42	25
4	1	43	25
4	1	44	25
4	1	45	25
4	1	46	25
4	1	47	25
4	1	48	25
4	1	49	25
4	1	50	25
4	1	51	25
4	1	52	25
4	1	53	25
4	1	54	25
4	1	55	25
4	1	56	25
4	1	57	25
4	1	58	25
4	1	59	25
4	1	60	25
4	1	1	26
4	1	2	26
4	1	3	26
4	1	4	26
4	1	5	26
4	1	6	26
4	1	7	26
4	1	8	26
4	1	9	26
4	1	10	26
4	1	11	26
4	1	12	26
4	1	13	26
4	1	14	26
4	1	15	26
4	1	16	26
4	1	17	26
4	1	18	26
4	1	19	26
4	1	20	26
4	1	21	26
4	1	22	26
4	1	23	26
4	1	24	26
4	1	25	26
4	1	26	26
4	1	27	26
4	1	28	26
4	1	29	26
4	1	30	26
4	1	31	26
4	1	32	26
4	1	33	26
4	1	34	26
4	1	35	26
4	1	36	26
4	1	37	26
4	1	38	26
4	1	39	26
4	1	40	26
4	1	41	26
4	1	42	26
4	1	43	26
4	1	44	26
4	1	45	26
4	1	46	26
4	1	47	26
4	1	48	26
4	1	49	26
4	1	50	26
4	1	51	26
4	1	52	26
4	1	53	26
4	1	54	26
4	1	55	26
4	1	56	26
4	1	57	26
4	1	58	26
4	1	59	26
4	1	60	26
4	1	1	27
4	1	2	27
4	1	3	27
4	1	4	27
4	1	5	27
4	1	6	27
4	1	7	27
4	1	8	27
4	1	9	27
4	1	10	27
4	1	11	27
4	1	12	27
4	1	13	27
4	1	14	27
4	1	15	27
4	1	16	27
4	1	17	27
4	1	18	27
4	1	19	27
4	1	20	27
4	1	21	27
4	1	22	27
4	1	23	27
4	1	24	27
4	1	25	27
4	1	26	27
4	1	27	27
4	1	28	27
4	1	29	27
4	1	30	27
4	1	31	27
4	1	32	27
4	1	33	27
4	1	34	27
4	1	35	27
4	1	36	27
4	1	37	27
4	1	38	27
4	1	39	27
4	1	40	27
4	1	41	27
4	1	42	27
4	1	43	27
4	1	44	27
4	1	45	27
4	1	46	27
4	1	47	27
4	1	48	27
4	1	49	27
4	1	50	27
4	1	51	27
4	1	52	27
4	1	53	27
4	1	54	27
4	1	55	27
4	1	56	27
4	1	57	27
4	1	58	27
4	1	59	27
4	1	60	27
4	1	1	28
4	1	2	28
4	1	3	28
4	1	4	28
4	1	5	28
4	1	6	28
4	1	7	28
4	1	8	28
4	1	9	28
4	1	10	28
4	1	11	28
4	1	12	28
4	1	13	28
4	1	14	28
4	1	15	28
4	1	16	28
4	1	17	28
4	1	18	28
4	1	19	28
4	1	20	28
4	1	21	28
4	1	22	28
4	1	23	28
4	1	24	28
4	1	25	28
4	1	26	28
4	1	27	28
4	1	28	28
4	1	29	28
4	1	30	28
4	1	31	28
4	1	32	28
4	1	33	28
4	1	34	28
4	1	35	28
4	1	36	28
4	1	37	28
4	1	38	28
4	1	39	28
4	1	40	28
4	1	41	28
4	1	42	28
4	1	43	28
4	1	44	28
4	1	45	28
4	1	46	28
4	1	47	28
4	1	48	28
4	1	49	28
4	1	50	28
4	1	51	28
4	1	52	28
4	1	53	28
4	1	54	28
4	1	55	28
4	1	56	28
4	1	57	28
4	1	58	28
4	1	59	28
4	1	60	28
4	1	1	29
4	1	2	29
4	1	3	29
4	1	4	29
4	1	5	29
4	1	6	29
4	1	7	29
4	1	8	29
4	1	9	29
4	1	10	29
4	1	11	29
4	1	12	29
4	1	13	29
4	1	14	29
4	1	15	29
4	1	16	29
4	1	17	29
4	1	18	29
4	1	19	29
4	1	20	29
4	1	21	29
4	1	22	29
4	1	23	29
4	1	24	29
4	1	25	29
4	1	26	29
4	1	27	29
4	1	28	29
4	1	29	29
4	1	30	29
4	1	31	29
4	1	32	29
4	1	33	29
4	1	34	29
4	1	35	29
4	1	36	29
4	1	37	29
4	1	38	29
4	1	39	29
4	1	40	29
4	1	41	29
4	1	42	29
4	1	43	29
4	1	44	29
4	1	45	29
4	1	46	29
4	1	47	29
4	1	48	29
4	1	49	29
4	1	50	29
4	1	51	29
4	1	52	29
4	1	53	29
4	1	54	29
4	1	55	29
4	1	56	29
4	1	57	29
4	1	58	29
4	1	59	29
4	1	60	29
4	1	1	30
4	1	2	30
4	1	3	30
4	1	4	30
4	1	5	30
4	1	6	30
4	1	7	30
4	1	8	30
4	1	9	30
4	1	10	30
4	1	11	30
4	1	12	30
4	1	13	30
4	1	14	30
4	1	15	30
4	1	16	30
4	1	17	30
4	1	18	30
4	1	19	30
4	1	20	30
4	1	21	30
4	1	22	30
4	1	23	30
4	1	24	30
4	1	25	30
4	1	26	30
4	1	27	30
4	1	28	30
4	1	29	30
4	1	30	30
4	1	31	30
4	1	32	30
4	1	33	30
4	1	34	30
4	1	35	30
4	1	36	30
4	1	37	30
4	1	38	30
4	1	39	30
4	1	40	30
4	1	41	30
4	1	42	30
4	1	43	30
4	1	44	30
4	1	45	30
4	1	46	30
4	1	47	30
4	1	48	30
4	1	49	30
4	1	50	30
4	1	51	30
4	1	52	30
4	1	53	30
4	1	54	30
4	1	55	30
4	1	56	30
4	1	57	30
4	1	58	30
4	1	59	30
4	1	60	30
4	1	1	31
4	1	2	31
4	1	3	31
4	1	4	31
4	1	5	31
4	1	6	31
4	1	7	31
4	1	8	31
4	1	9	31
4	1	10	31
4	1	11	31
4	1	12	31
4	1	13	31
4	1	14	31
4	1	15	31
4	1	16	31
4	1	17	31
4	1	18	31
4	1	19	31
4	1	20	31
4	1	21	31
4	1	22	31
4	1	23	31
4	1	24	31
4	1	25	31
4	1	26	31
4	1	27	31
4	1	28	31
4	1	29	31
4	1	30	31
4	1	31	31
4	1	32	31
4	1	33	31
4	1	34	31
4	1	35	31
4	1	36	31
4	1	37	31
4	1	38	31
4	1	39	31
4	1	40	31
4	1	41	31
4	1	42	31
4	1	43	31
4	1	44	31
4	1	45	31
4	1	46	31
4	1	47	31
4	1	48	31
4	1	49	31
4	1	50	31
4	1	51	31
4	1	52	31
4	1	53	31
4	1	54	31
4	1	55	31
4	1	56	31
4	1	57	31
4	1	58	31
4	1	59	31
4	1	60	31
4	1	1	32
4	1	2	32
4	1	3	32
4	1	4	32
4	1	5	32
4	1	6	32
4	1	7	32
4	1	8	32
4	1	9	32
4	1	10	32
4	1	11	32
4	1	12	32
4	1	13	32
4	1	14	32
4	1	15	32
4	1	16	32
4	1	17	32
4	1	18	32
4	1	19	32
4	1	20	32
4	1	21	32
4	1	22	32
4	1	23	32
4	1	24	32
4	1	25	32
4	1	26	32
4	1	27	32
4	1	28	32
4	1	29	32
4	1	30	32
4	1	31	32
4	1	32	32
4	1	33	32
4	1	34	32
4	1	35	32
4	1	36	32
4	1	37	32
4	1	38	32
4	1	39	32
4	1	40	32
4	1	41	32
4	1	42	32
4	1	43	32
4	1	44	32
4	1	45	32
4	1	46	32
4	1	47	32
4	1	48	32
4	1	49	32
4	1	50	32
4	1	51	32
4	1	52	32
4	1	53	32
4	1	54	32
4	1	55	32
4	1	56	32
4	1	57	32
4	1	58	32
4	1	59	32
4	1	60	32
4	1	1	33
4	1	2	33
4	1	3	33
4	1	4	33
4	1	5	33
4	1	6	33
4	1	7	33
4	1	8	33
4	1	9	33
4	1	10	33
4	1	11	33
4	1	12	33
4	1	13	33
4	1	14	33
4	1	15	33
4	1	16	33
4	1	17	33
4	1	18	33
4	1	19	33
4	1	20	33
4	1	21	33
4	1	22	33
4	1	23	33
4	1	24	33
4	1	25	33
4	1	26	33
4	1	27	33
4	1	28	33
4	1	29	33
4	1	30	33
4	1	31	33
4	1	32	33
4	1	33	33
4	1	34	33
4	1	35	33
4	1	36	33
4	1	37	33
4	1	38	33
4	1	39	33
4	1	40	33
4	1	41	33
4	1	42	33
4	1	43	33
4	1	44	33
4	1	45	33
4	1	46	33
4	1	47	33
4	1	48	33
4	1	49	33
4	1	50	33
4	1	51	33
4	1	52	33
4	1	53	33
4	1	54	33
4	1	55	33
4	1	56	33
4	1	57	33
4	1	58	33
4	1	59	33
4	1	60	33
4	1	1	34
4	1	2	34
4	1	3	34
4	1	4	34
4	1	5	34
4	1	6	34
4	1	7	34
4	1	8	34
4	1	9	34
4	1	10	34
4	1	11	34
4	1	12	34
4	1	13	34
4	1	14	34
4	1	15	34
4	1	16	34
4	1	17	34
4	1	18	34
4	1	19	34
4	1	20	34
4	1	21	34
4	1	22	34
4	1	23	34
4	1	24	34
4	1	25	34
4	1	26	34
4	1	27	34
4	1	28	34
4	1	29	34
4	1	30	34
4	1	31	34
4	1	32	34
4	1	33	34
4	1	34	34
4	1	35	34
4	1	36	34
4	1	37	34
4	1	38	34
4	1	39	34
4	1	40	34
4	1	41	34
4	1	42	34
4	1	43	34
4	1	44	34
4	1	45	34
4	1	46	34
4	1	47	34
4	1	48	34
4	1	49	34
4	1	50	34
4	1	51	34
4	1	52	34
4	1	53	34
4	1	54	34
4	1	55	34
4	1	56	34
4	1	57	34
4	1	58	34
4	1	59	34
4	1	60	34
4	1	1	35
4	1	2	35
4	1	3	35
4	1	4	35
4	1	5	35
4	1	6	35
4	1	7	35
4	1	8	35
4	1	9	35
4	1	10	35
4	1	11	35
4	1	12	35
4	1	13	35
4	1	14	35
4	1	15	35
4	1	16	35
4	1	17	35
4	1	18	35
4	1	19	35
4	1	20	35
4	1	21	35
4	1	22	35
4	1	23	35
4	1	24	35
4	1	25	35
4	1	26	35
4	1	27	35
4	1	28	35
4	1	29	35
4	1	30	35
4	1	31	35
4	1	32	35
4	1	33	35
4	1	34	35
4	1	35	35
4	1	36	35
4	1	37	35
4	1	38	35
4	1	39	35
4	1	40	35
4	1	41	35
4	1	42	35
4	1	43	35
4	1	44	35
4	1	45	35
4	1	46	35
4	1	47	35
4	1	48	35
4	1	49	35
4	1	50	35
4	1	51	35
4	1	52	35
4	1	53	35
4	1	54	35
4	1	55	35
4	1	56	35
4	1	57	35
4	1	58	35
4	1	59	35
4	1	60	35
4	1	1	36
4	1	2	36
4	1	3	36
4	1	4	36
4	1	5	36
4	1	6	36
4	1	7	36
4	1	8	36
4	1	9	36
4	1	10	36
4	1	11	36
4	1	12	36
4	1	13	36
4	1	14	36
4	1	15	36
4	1	16	36
4	1	17	36
4	1	18	36
4	1	19	36
4	1	20	36
4	1	21	36
4	1	22	36
4	1	23	36
4	1	24	36
4	1	25	36
4	1	26	36
4	1	27	36
4	1	28	36
4	1	29	36
4	1	30	36
4	1	31	36
4	1	32	36
4	1	33	36
4	1	34	36
4	1	35	36
4	1	36	36
4	1	37	36
4	1	38	36
4	1	39	36
4	1	40	36
4	1	41	36
4	1	42	36
4	1	43	36
4	1	44	36
4	1	45	36
4	1	46	36
4	1	47	36
4	1	48	36
4	1	49	36
4	1	50	36
4	1	51	36
4	1	52	36
4	1	53	36
4	1	54	36
4	1	55	36
4	1	56	36
4	1	57	36
4	1	58	36
4	1	59	36
4	1	60	36
4	1	1	37
4	1	2	37
4	1	3	37
4	1	4	37
4	1	5	37
4	1	6	37
4	1	7	37
4	1	8	37
4	1	9	37
4	1	10	37
4	1	11	37
4	1	12	37
4	1	13	37
4	1	14	37
4	1	15	37
4	1	16	37
4	1	17	37
4	1	18	37
4	1	19	37
4	1	20	37
4	1	21	37
4	1	22	37
4	1	23	37
4	1	24	37
4	1	25	37
4	1	26	37
4	1	27	37
4	1	28	37
4	1	29	37
4	1	30	37
4	1	31	37
4	1	32	37
4	1	33	37
4	1	34	37
4	1	35	37
4	1	36	37
4	1	37	37
4	1	38	37
4	1	39	37
4	1	40	37
4	1	41	37
4	1	42	37
4	1	43	37
4	1	44	37
4	1	45	37
4	1	46	37
4	1	47	37
4	1	48	37
4	1	49	37
4	1	50	37
4	1	51	37
4	1	52	37
4	1	53	37
4	1	54	37
4	1	55	37
4	1	56	37
4	1	57	37
4	1	58	37
4	1	59	37
4	1	60	37
4	1	1	38
4	1	2	38
4	1	3	38
4	1	4	38
4	1	5	38
4	1	6	38
4	1	7	38
4	1	8	38
4	1	9	38
4	1	10	38
4	1	11	38
4	1	12	38
4	1	13	38
4	1	14	38
4	1	15	38
4	1	16	38
4	1	17	38
4	1	18	38
4	1	19	38
4	1	20	38
4	1	21	38
4	1	22	38
4	1	23	38
4	1	24	38
4	1	25	38
4	1	26	38
4	1	27	38
4	1	28	38
4	1	29	38
4	1	30	38
4	1	31	38
4	1	32	38
4	1	33	38
4	1	34	38
4	1	35	38
4	1	36	38
4	1	37	38
4	1	38	38
4	1	39	38
4	1	40	38
4	1	41	38
4	1	42	38
4	1	43	38
4	1	44	38
4	1	45	38
4	1	46	38
4	1	47	38
4	1	48	38
4	1	49	38
4	1	50	38
4	1	51	38
4	1	52	38
4	1	53	38
4	1	54	38
4	1	55	38
4	1	56	38
4	1	57	38
4	1	58	38
4	1	59	38
4	1	60	38
4	1	1	39
4	1	2	39
4	1	3	39
4	1	4	39
4	1	5	39
4	1	6	39
4	1	7	39
4	1	8	39
4	1	9	39
4	1	10	39
4	1	11	39
4	1	12	39
4	1	13	39
4	1	14	39
4	1	15	39
4	1	16	39
4	1	17	39
4	1	18	39
4	1	19	39
4	1	20	39
4	1	21	39
4	1	22	39
4	1	23	39
4	1	24	39
4	1	25	39
4	1	26	39
4	1	27	39
4	1	28	39
4	1	29	39
4	1	30	39
4	1	31	39
4	1	32	39
4	1	33	39
4	1	34	39
4	1	35	39
4	1	36	39
4	1	37	39
4	1	38	39
4	1	39	39
4	1	40	39
4	1	41	39
4	1	42	39
4	1	43	39
4	1	44	39
4	1	45	39
4	1	46	39
4	1	47	39
4	1	48	39
4	1	49	39
4	1	50	39
4	1	51	39
4	1	52	39
4	1	53	39
4	1	54	39
4	1	55	39
4	1	56	39
4	1	57	39
4	1	58	39
4	1	59	39
4	1	60	39
4	1	1	40
4	1	2	40
4	1	3	40
4	1	4	40
4	1	5	40
4	1	6	40
4	1	7	40
4	1	8	40
4	1	9	40
4	1	10	40
4	1	11	40
4	1	12	40
4	1	13	40
4	1	14	40
4	1	15	40
4	1	16	40
4	1	17	40
4	1	18	40
4	1	19	40
4	1	20	40
4	1	21	40
4	1	22	40
4	1	23	40
4	1	24	40
4	1	25	40
4	1	26	40
4	1	27	40
4	1	28	40
4	1	29	40
4	1	30	40
4	1	31	40
4	1	32	40
4	1	33	40
4	1	34	40
4	1	35	40
4	1	36	40
4	1	37	40
4	1	38	40
4	1	39	40
4	1	40	40
4	1	41	40
4	1	42	40
4	1	43	40
4	1	44	40
4	1	45	40
4	1	46	40
4	1	47	40
4	1	48	40
4	1	49	40
4	1	50	40
4	1	51	40
4	1	52	40
4	1	53	40
4	1	54	40
4	1	55	40
4	1	56	40
4	1	57	40
4	1	58	40
4	1	59	40
4	1	60	40
4	1	1	41
4	1	2	41
4	1	3	41
4	1	4	41
4	1	5	41
4	1	6	41
4	1	7	41
4	1	8	41
4	1	9	41
4	1	10	41
4	1	11	41
4	1	12	41
4	1	13	41
4	1	14	41
4	1	15	41
4	1	16	41
4	1	17	41
4	1	18	41
4	1	19	41
4	1	20	41
4	1	21	41
4	1	22	41
4	1	23	41
4	1	24	41
4	1	25	41
4	1	26	41
4	1	27	41
4	1	28	41
4	1	29	41
4	1	30	41
4	1	31	41
4	1	32	41
4	1	33	41
4	1	34	41
4	1	35	41
4	1	36	41
4	1	37	41
4	1	38	41
4	1	39	41
4	1	40	41
4	1	41	41
4	1	42	41
4	1	43	41
4	1	44	41
4	1	45	41
4	1	46	41
4	1	47	41
4	1	48	41
4	1	49	41
4	1	50	41
4	1	51	41
4	1	52	41
4	1	53	41
4	1	54	41
4	1	55	41
4	1	56	41
4	1	57	41
4	1	58	41
4	1	59	41
4	1	60	41
4	1	1	42
4	1	2	42
4	1	3	42
4	1	4	42
4	1	5	42
4	1	6	42
4	1	7	42
4	1	8	42
4	1	9	42
4	1	10	42
4	1	11	42
4	1	12	42
4	1	13	42
4	1	14	42
4	1	15	42
4	1	16	42
4	1	17	42
4	1	18	42
4	1	19	42
4	1	20	42
4	1	21	42
4	1	22	42
4	1	23	42
4	1	24	42
4	1	25	42
4	1	26	42
4	1	27	42
4	1	28	42
4	1	29	42
4	1	30	42
4	1	31	42
4	1	32	42
4	1	33	42
4	1	34	42
4	1	35	42
4	1	36	42
4	1	37	42
4	1	38	42
4	1	39	42
4	1	40	42
4	1	41	42
4	1	42	42
4	1	43	42
4	1	44	42
4	1	45	42
4	1	46	42
4	1	47	42
4	1	48	42
4	1	49	42
4	1	50	42
4	1	51	42
4	1	52	42
4	1	53	42
4	1	54	42
4	1	55	42
4	1	56	42
4	1	57	42
4	1	58	42
4	1	59	42
4	1	60	42
4	1	1	43
4	1	2	43
4	1	3	43
4	1	4	43
4	1	5	43
4	1	6	43
4	1	7	43
4	1	8	43
4	1	9	43
4	1	10	43
4	1	11	43
4	1	12	43
4	1	13	43
4	1	14	43
4	1	15	43
4	1	16	43
4	1	17	43
4	1	18	43
4	1	19	43
4	1	20	43
4	1	21	43
4	1	22	43
4	1	23	43
4	1	24	43
4	1	25	43
4	1	26	43
4	1	27	43
4	1	28	43
4	1	29	43
4	1	30	43
4	1	31	43
4	1	32	43
4	1	33	43
4	1	34	43
4	1	35	43
4	1	36	43
4	1	37	43
4	1	38	43
4	1	39	43
4	1	40	43
4	1	41	43
4	1	42	43
4	1	43	43
4	1	44	43
4	1	45	43
4	1	46	43
4	1	47	43
4	1	48	43
4	1	49	43
4	1	50	43
4	1	51	43
4	1	52	43
4	1	53	43
4	1	54	43
4	1	55	43
4	1	56	43
4	1	57	43
4	1	58	43
4	1	59	43
4	1	60	43
4	1	1	44
4	1	2	44
4	1	3	44
4	1	4	44
4	1	5	44
4	1	6	44
4	1	7	44
4	1	8	44
4	1	9	44
4	1	10	44
4	1	11	44
4	1	12	44
4	1	13	44
4	1	14	44
4	1	15	44
4	1	16	44
4	1	17	44
4	1	18	44
4	1	19	44
4	1	20	44
4	1	21	44
4	1	22	44
4	1	23	44
4	1	24	44
4	1	25	44
4	1	26	44
4	1	27	44
4	1	28	44
4	1	29	44
4	1	30	44
4	1	31	44
4	1	32	44
4	1	33	44
4	1	34	44
4	1	35	44
4	1	36	44
4	1	37	44
4	1	38	44
4	1	39	44
4	1	40	44
4	1	41	44
4	1	42	44
4	1	43	44
4	1	44	44
4	1	45	44
4	1	46	44
4	1	47	44
4	1	48	44
4	1	49	44
4	1	50	44
4	1	51	44
4	1	52	44
4	1	53	44
4	1	54	44
4	1	55	44
4	1	56	44
4	1	57	44
4	1	58	44
4	1	59	44
4	1	60	44
4	1	1	45
4	1	2	45
4	1	3	45
4	1	4	45
4	1	5	45
4	1	6	45
4	1	7	45
4	1	8	45
4	1	9	45
4	1	10	45
4	1	11	45
4	1	12	45
4	1	13	45
4	1	14	45
4	1	15	45
4	1	16	45
4	1	17	45
4	1	18	45
4	1	19	45
4	1	20	45
4	1	21	45
4	1	22	45
4	1	23	45
4	1	24	45
4	1	25	45
4	1	26	45
4	1	27	45
4	1	28	45
4	1	29	45
4	1	30	45
4	1	31	45
4	1	32	45
4	1	33	45
4	1	34	45
4	1	35	45
4	1	36	45
4	1	37	45
4	1	38	45
4	1	39	45
4	1	40	45
4	1	41	45
4	1	42	45
4	1	43	45
4	1	44	45
4	1	45	45
4	1	46	45
4	1	47	45
4	1	48	45
4	1	49	45
4	1	50	45
4	1	51	45
4	1	52	45
4	1	53	45
4	1	54	45
4	1	55	45
4	1	56	45
4	1	57	45
4	1	58	45
4	1	59	45
4	1	60	45
4	1	1	46
4	1	2	46
4	1	3	46
4	1	4	46
4	1	5	46
4	1	6	46
4	1	7	46
4	1	8	46
4	1	9	46
4	1	10	46
4	1	11	46
4	1	12	46
4	1	13	46
4	1	14	46
4	1	15	46
4	1	16	46
4	1	17	46
4	1	18	46
4	1	19	46
4	1	20	46
4	1	21	46
4	1	22	46
4	1	23	46
4	1	24	46
4	1	25	46
4	1	26	46
4	1	27	46
4	1	28	46
4	1	29	46
4	1	30	46
4	1	31	46
4	1	32	46
4	1	33	46
4	1	34	46
4	1	35	46
4	1	36	46
4	1	37	46
4	1	38	46
4	1	39	46
4	1	40	46
4	1	41	46
4	1	42	46
4	1	43	46
4	1	44	46
4	1	45	46
4	1	46	46
4	1	47	46
4	1	48	46
4	1	49	46
4	1	50	46
4	1	51	46
4	1	52	46
4	1	53	46
4	1	54	46
4	1	55	46
4	1	56	46
4	1	57	46
4	1	58	46
4	1	59	46
4	1	60	46
4	1	1	47
4	1	2	47
4	1	3	47
4	1	4	47
4	1	5	47
4	1	6	47
4	1	7	47
4	1	8	47
4	1	9	47
4	1	10	47
4	1	11	47
4	1	12	47
4	1	13	47
4	1	14	47
4	1	15	47
4	1	16	47
4	1	17	47
4	1	18	47
4	1	19	47
4	1	20	47
4	1	21	47
4	1	22	47
4	1	23	47
4	1	24	47
4	1	25	47
4	1	26	47
4	1	27	47
4	1	28	47
4	1	29	47
4	1	30	47
4	1	31	47
4	1	32	47
4	1	33	47
4	1	34	47
4	1	35	47
4	1	36	47
4	1	37	47
4	1	38	47
4	1	39	47
4	1	40	47
4	1	41	47
4	1	42	47
4	1	43	47
4	1	44	47
4	1	45	47
4	1	46	47
4	1	47	47
4	1	48	47
4	1	49	47
4	1	50	47
4	1	51	47
4	1	52	47
4	1	53	47
4	1	54	47
4	1	55	47
4	1	56	47
4	1	57	47
4	1	58	47
4	1	59	47
4	1	60	47
4	1	1	48
4	1	2	48
4	1	3	48
4	1	4	48
4	1	5	48
4	1	6	48
4	1	7	48
4	1	8	48
4	1	9	48
4	1	10	48
4	1	11	48
4	1	12	48
4	1	13	48
4	1	14	48
4	1	15	48
4	1	16	48
4	1	17	48
4	1	18	48
4	1	19	48
4	1	20	48
4	1	21	48
4	1	22	48
4	1	23	48
4	1	24	48
4	1	25	48
4	1	26	48
4	1	27	48
4	1	28	48
4	1	29	48
4	1	30	48
4	1	31	48
4	1	32	48
4	1	33	48
4	1	34	48
4	1	35	48
4	1	36	48
4	1	37	48
4	1	38	48
4	1	39	48
4	1	40	48
4	1	41	48
4	1	42	48
4	1	43	48
4	1	44	48
4	1	45	48
4	1	46	48
4	1	47	48
4	1	48	48
4	1	49	48
4	1	50	48
4	1	51	48
4	1	52	48
4	1	53	48
4	1	54	48
4	1	55	48
4	1	56	48
4	1	57	48
4	1	58	48
4	1	59	48
4	1	60	48
4	1	1	49
4	1	2	49
4	1	3	49
4	1	4	49
4	1	5	49
4	1	6	49
4	1	7	49
4	1	8	49
4	1	9	49
4	1	10	49
4	1	11	49
4	1	12	49
4	1	13	49
4	1	14	49
4	1	15	49
4	1	16	49
4	1	17	49
4	1	18	49
4	1	19	49
4	1	20	49
4	1	21	49
4	1	22	49
4	1	23	49
4	1	24	49
4	1	25	49
4	1	26	49
4	1	27	49
4	1	28	49
4	1	29	49
4	1	30	49
4	1	31	49
4	1	32	49
4	1	33	49
4	1	34	49
4	1	35	49
4	1	36	49
4	1	37	49
4	1	38	49
4	1	39	49
4	1	40	49
4	1	41	49
4	1	42	49
4	1	43	49
4	1	44	49
4	1	45	49
4	1	46	49
4	1	47	49
4	1	48	49
4	1	49	49
4	1	50	49
4	1	51	49
4	1	52	49
4	1	53	49
4	1	54	49
4	1	55	49
4	1	56	49
4	1	57	49
4	1	58	49
4	1	59	49
4	1	60	49
4	1	1	50
4	1	2	50
4	1	3	50
4	1	4	50
4	1	5	50
4	1	6	50
4	1	7	50
4	1	8	50
4	1	9	50
4	1	10	50
4	1	11	50
4	1	12	50
4	1	13	50
4	1	14	50
4	1	15	50
4	1	16	50
4	1	17	50
4	1	18	50
4	1	19	50
4	1	20	50
4	1	21	50
4	1	22	50
4	1	23	50
4	1	24	50
4	1	25	50
4	1	26	50
4	1	27	50
4	1	28	50
4	1	29	50
4	1	30	50
4	1	31	50
4	1	32	50
4	1	33	50
4	1	34	50
4	1	35	50
4	1	36	50
4	1	37	50
4	1	38	50
4	1	39	50
4	1	40	50
4	1	41	50
4	1	42	50
4	1	43	50
4	1	44	50
4	1	45	50
4	1	46	50
4	1	47	50
4	1	48	50
4	1	49	50
4	1	50	50
4	1	51	50
4	1	52	50
4	1	53	50
4	1	54	50
4	1	55	50
4	1	56	50
4	1	57	50
4	1	58	50
4	1	59	50
4	1	60	50
4	1	1	51
4	1	2	51
4	1	3	51
4	1	4	51
4	1	5	51
4	1	6	51
4	1	7	51
4	1	8	51
4	1	9	51
4	1	10	51
4	1	11	51
4	1	12	51
4	1	13	51
4	1	14	51
4	1	15	51
4	1	16	51
4	1	17	51
4	1	18	51
4	1	19	51
4	1	20	51
4	1	21	51
4	1	22	51
4	1	23	51
4	1	24	51
4	1	25	51
4	1	26	51
4	1	27	51
4	1	28	51
4	1	29	51
4	1	30	51
4	1	31	51
4	1	32	51
4	1	33	51
4	1	34	51
4	1	35	51
4	1	36	51
4	1	37	51
4	1	38	51
4	1	39	51
4	1	40	51
4	1	41	51
4	1	42	51
4	1	43	51
4	1	44	51
4	1	45	51
4	1	46	51
4	1	47	51
4	1	48	51
4	1	49	51
4	1	50	51
4	1	51	51
4	1	52	51
4	1	53	51
4	1	54	51
4	1	55	51
4	1	56	51
4	1	57	51
4	1	58	51
4	1	59	51
4	1	60	51
4	1	1	52
4	1	2	52
4	1	3	52
4	1	4	52
4	1	5	52
4	1	6	52
4	1	7	52
4	1	8	52
4	1	9	52
4	1	10	52
4	1	11	52
4	1	12	52
4	1	13	52
4	1	14	52
4	1	15	52
4	1	16	52
4	1	17	52
4	1	18	52
4	1	19	52
4	1	20	52
4	1	21	52
4	1	22	52
4	1	23	52
4	1	24	52
4	1	25	52
4	1	26	52
4	1	27	52
4	1	28	52
4	1	29	52
4	1	30	52
4	1	31	52
4	1	32	52
4	1	33	52
4	1	34	52
4	1	35	52
4	1	36	52
4	1	37	52
4	1	38	52
4	1	39	52
4	1	40	52
4	1	41	52
4	1	42	52
4	1	43	52
4	1	44	52
4	1	45	52
4	1	46	52
4	1	47	52
4	1	48	52
4	1	49	52
4	1	50	52
4	1	51	52
4	1	52	52
4	1	53	52
4	1	54	52
4	1	55	52
4	1	56	52
4	1	57	52
4	1	58	52
4	1	59	52
4	1	60	52
4	1	1	53
4	1	2	53
4	1	3	53
4	1	4	53
4	1	5	53
4	1	6	53
4	1	7	53
4	1	8	53
4	1	9	53
4	1	10	53
4	1	11	53
4	1	12	53
4	1	13	53
4	1	14	53
4	1	15	53
4	1	16	53
4	1	17	53
4	1	18	53
4	1	19	53
4	1	20	53
4	1	21	53
4	1	22	53
4	1	23	53
4	1	24	53
4	1	25	53
4	1	26	53
4	1	27	53
4	1	28	53
4	1	29	53
4	1	30	53
4	1	31	53
4	1	32	53
4	1	33	53
4	1	34	53
4	1	35	53
4	1	36	53
4	1	37	53
4	1	38	53
4	1	39	53
4	1	40	53
4	1	41	53
4	1	42	53
4	1	43	53
4	1	44	53
4	1	45	53
4	1	46	53
4	1	47	53
4	1	48	53
4	1	49	53
4	1	50	53
4	1	51	53
4	1	52	53
4	1	53	53
4	1	54	53
4	1	55	53
4	1	56	53
4	1	57	53
4	1	58	53
4	1	59	53
4	1	60	53
4	1	1	54
4	1	2	54
4	1	3	54
4	1	4	54
4	1	5	54
4	1	6	54
4	1	7	54
4	1	8	54
4	1	9	54
4	1	10	54
4	1	11	54
4	1	12	54
4	1	13	54
4	1	14	54
4	1	15	54
4	1	16	54
4	1	17	54
4	1	18	54
4	1	19	54
4	1	20	54
4	1	21	54
4	1	22	54
4	1	23	54
4	1	24	54
4	1	25	54
4	1	26	54
4	1	27	54
4	1	28	54
4	1	29	54
4	1	30	54
4	1	31	54
4	1	32	54
4	1	33	54
4	1	34	54
4	1	35	54
4	1	36	54
4	1	37	54
4	1	38	54
4	1	39	54
4	1	40	54
4	1	41	54
4	1	42	54
4	1	43	54
4	1	44	54
4	1	45	54
4	1	46	54
4	1	47	54
4	1	48	54
4	1	49	54
4	1	50	54
4	1	51	54
4	1	52	54
4	1	53	54
4	1	54	54
4	1	55	54
4	1	56	54
4	1	57	54
4	1	58	54
4	1	59	54
4	1	60	54
4	1	1	55
4	1	2	55
4	1	3	55
4	1	4	55
4	1	5	55
4	1	6	55
4	1	7	55
4	1	8	55
4	1	9	55
4	1	10	55
4	1	11	55
4	1	12	55
4	1	13	55
4	1	14	55
4	1	15	55
4	1	16	55
4	1	17	55
4	1	18	55
4	1	19	55
4	1	20	55
4	1	21	55
4	1	22	55
4	1	23	55
4	1	24	55
4	1	25	55
4	1	26	55
4	1	27	55
4	1	28	55
4	1	29	55
4	1	30	55
4	1	31	55
4	1	32	55
4	1	33	55
4	1	34	55
4	1	35	55
4	1	36	55
4	1	37	55
4	1	38	55
4	1	39	55
4	1	40	55
4	1	41	55
4	1	42	55
4	1	43	55
4	1	44	55
4	1	45	55
4	1	46	55
4	1	47	55
4	1	48	55
4	1	49	55
4	1	50	55
4	1	51	55
4	1	52	55
4	1	53	55
4	1	54	55
4	1	55	55
4	1	56	55
4	1	57	55
4	1	58	55
4	1	59	55
4	1	60	55
4	1	1	56
4	1	2	56
4	1	3	56
4	1	4	56
4	1	5	56
4	1	6	56
4	1	7	56
4	1	8	56
4	1	9	56
4	1	10	56
4	1	11	56
4	1	12	56
4	1	13	56
4	1	14	56
4	1	15	56
4	1	16	56
4	1	17	56
4	1	18	56
4	1	19	56
4	1	20	56
4	1	21	56
4	1	22	56
4	1	23	56
4	1	24	56
4	1	25	56
4	1	26	56
4	1	27	56
4	1	28	56
4	1	29	56
4	1	30	56
4	1	31	56
4	1	32	56
4	1	33	56
4	1	34	56
4	1	35	56
4	1	36	56
4	1	37	56
4	1	38	56
4	1	39	56
4	1	40	56
4	1	41	56
4	1	42	56
4	1	43	56
4	1	44	56
4	1	45	56
4	1	46	56
4	1	47	56
4	1	48	56
4	1	49	56
4	1	50	56
4	1	51	56
4	1	52	56
4	1	53	56
4	1	54	56
4	1	55	56
4	1	56	56
4	1	57	56
4	1	58	56
4	1	59	56
4	1	60	56
4	1	1	57
4	1	2	57
4	1	3	57
4	1	4	57
4	1	5	57
4	1	6	57
4	1	7	57
4	1	8	57
4	1	9	57
4	1	10	57
4	1	11	57
4	1	12	57
4	1	13	57
4	1	14	57
4	1	15	57
4	1	16	57
4	1	17	57
4	1	18	57
4	1	19	57
4	1	20	57
4	1	21	57
4	1	22	57
4	1	23	57
4	1	24	57
4	1	25	57
4	1	26	57
4	1	27	57
4	1	28	57
4	1	29	57
4	1	30	57
4	1	31	57
4	1	32	57
4	1	33	57
4	1	34	57
4	1	35	57
4	1	36	57
4	1	37	57
4	1	38	57
4	1	39	57
4	1	40	57
4	1	41	57
4	1	42	57
4	1	43	57
4	1	44	57
4	1	45	57
4	1	46	57
4	1	47	57
4	1	48	57
4	1	49	57
4	1	50	57
4	1	51	57
4	1	52	57
4	1	53	57
4	1	54	57
4	1	55	57
4	1	56	57
4	1	57	57
4	1	58	57
4	1	59	57
4	1	60	57
4	1	1	58
4	1	2	58
4	1	3	58
4	1	4	58
4	1	5	58
4	1	6	58
4	1	7	58
4	1	8	58
4	1	9	58
4	1	10	58
4	1	11	58
4	1	12	58
4	1	13	58
4	1	14	58
4	1	15	58
4	1	16	58
4	1	17	58
4	1	18	58
4	1	19	58
4	1	20	58
4	1	21	58
4	1	22	58
4	1	23	58
4	1	24	58
4	1	25	58
4	1	26	58
4	1	27	58
4	1	28	58
4	1	29	58
4	1	30	58
4	1	31	58
4	1	32	58
4	1	33	58
4	1	34	58
4	1	35	58
4	1	36	58
4	1	37	58
4	1	38	58
4	1	39	58
4	1	40	58
4	1	41	58
4	1	42	58
4	1	43	58
4	1	44	58
4	1	45	58
4	1	46	58
4	1	47	58
4	1	48	58
4	1	49	58
4	1	50	58
4	1	51	58
4	1	52	58
4	1	53	58
4	1	54	58
4	1	55	58
4	1	56	58
4	1	57	58
4	1	58	58
4	1	59	58
4	1	60	58
4	1	1	59
4	1	2	59
4	1	3	59
4	1	4	59
4	1	5	59
4	1	6	59
4	1	7	59
4	1	8	59
4	1	9	59
4	1	10	59
4	1	11	59
4	1	12	59
4	1	13	59
4	1	14	59
4	1	15	59
4	1	16	59
4	1	17	59
4	1	18	59
4	1	19	59
4	1	20	59
4	1	21	59
4	1	22	59
4	1	23	59
4	1	24	59
4	1	25	59
4	1	26	59
4	1	27	59
4	1	28	59
4	1	29	59
4	1	30	59
4	1	31	59
4	1	32	59
4	1	33	59
4	1	34	59
4	1	35	59
4	1	36	59
4	1	37	59
4	1	38	59
4	1	39	59
4	1	40	59
4	1	41	59
4	1	42	59
4	1	43	59
4	1	44	59
4	1	45	59
4	1	46	59
4	1	47	59
4	1	48	59
4	1	49	59
4	1	50	59
4	1	51	59
4	1	52	59
4	1	53	59
4	1	54	59
4	1	55	59
4	1	56	59
4	1	57	59
4	1	58	59
4	1	59	59
4	1	60	59
4	1	1	60
4	1	2	60
4	1	3	60
4	1	4	60
4	1	5	60
4	1	6	60
4	1	7	60
4	1	8	60
4	1	9	60
4	1	10	60
4	1	11	60
4	1	12	60
4	1	13	60
4	1	14	60
4	1	15	60
4	1	16	60
4	1	17	60
4	1	18	60
4	1	19	60
4	1	20	60
4	1	21	60
4	1	22	60
4	1	23	60
4	1	24	60
4	1	25	60
4	1	26	60
4	1	27	60
4	1	28	60
4	1	29	60
4	1	30	60
4	1	31	60
4	1	32	60
4	1	33	60
4	1	34	60
4	1	35	60
4	1	36	60
4	1	37	60
4	1	38	60
4	1	39	60
4	1	40	60
4	1	41	60
4	1	42	60
4	1	43	60
4	1	44	60
4	1	45	60
4	1	46	60
4	1	47	60
4	1	48	60
4	1	49	60
4	1	50	60
4	1	51	60
4	1	52	60
4	1	53	60
4	1	54	60
4	1	55	60
4	1	56	60
4	1	57	60
4	1	58	60
4	1	59	60
4	1	60	60
\.


--
-- TOC entry 5536 (class 0 OID 25653)
-- Dependencies: 320
-- Data for Name: known_map_tiles_resources; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_map_tiles_resources (player_id, map_tiles_resource_id) FROM stdin;
4	1
4	2
\.


--
-- TOC entry 5529 (class 0 OID 25530)
-- Dependencies: 313
-- Data for Name: known_players_abilities; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_abilities (player_id, other_player_id) FROM stdin;
4	1
\.


--
-- TOC entry 5525 (class 0 OID 25460)
-- Dependencies: 309
-- Data for Name: known_players_containers; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_containers (player_id, container_id) FROM stdin;
4	1
4	2
\.


--
-- TOC entry 5506 (class 0 OID 22758)
-- Dependencies: 288
-- Data for Name: known_players_positions; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_positions (player_id, other_player_id) FROM stdin;
2	1
3	1
3	2
4	1
4	2
4	3
\.


--
-- TOC entry 5524 (class 0 OID 25440)
-- Dependencies: 308
-- Data for Name: known_players_profiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_profiles (player_id, other_player_id) FROM stdin;
4	1
4	2
4	3
\.


--
-- TOC entry 5528 (class 0 OID 25514)
-- Dependencies: 312
-- Data for Name: known_players_skills; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_skills (player_id, other_player_id) FROM stdin;
4	1
\.


--
-- TOC entry 5533 (class 0 OID 25593)
-- Dependencies: 317
-- Data for Name: known_players_squad_profiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_squad_profiles (player_id, squad_id) FROM stdin;
1	1
4	1
\.


--
-- TOC entry 5527 (class 0 OID 25492)
-- Dependencies: 311
-- Data for Name: known_players_stats; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_stats (player_id, other_player_id) FROM stdin;
4	1
\.


--
-- TOC entry 5507 (class 0 OID 22763)
-- Dependencies: 289
-- Data for Name: players; Type: TABLE DATA; Schema: players; Owner: postgres
--

COPY players.players (id, user_id, name, image_map, image_portrait, is_active, second_name, nickname, masked_id) FROM stdin;
4	1	Ziomo	default.png	2.png	f	Fotono	\N	e48a1b44-5673-48a7-9465-c8e92b91322d
3	1	Jachuren	default.png	1.png	f	Koczkodanen	\N	64734827-850c-4144-81ef-04210f1d4918
2	1	Pawlak	default.png	3.png	f	Ciabatos	\N	ef0374e9-457e-4c43-9194-343447dcb08d
1	1	Ciabat	default.png	4.png	t	Ciabatos	\N	360548f1-2fe7-4456-8869-21a12f2052f0
\.


--
-- TOC entry 5530 (class 0 OID 25567)
-- Dependencies: 314
-- Data for Name: squad_players; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squad_players (squad_id, player_id) FROM stdin;
1	1
1	4
\.


--
-- TOC entry 5532 (class 0 OID 25575)
-- Dependencies: 316
-- Data for Name: squads; Type: TABLE DATA; Schema: squad; Owner: postgres
--

COPY squad.squads (id) FROM stdin;
1
\.


--
-- TOC entry 5509 (class 0 OID 22780)
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
-- TOC entry 5511 (class 0 OID 22786)
-- Dependencies: 293
-- Data for Name: tasks; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

COPY tasks.tasks (id, player_id, status, created_at, scheduled_at, last_executed_at, error, method_name, method_parameters) FROM stdin;
1	4	5	2026-02-27 19:26:23.2798	2026-02-27 19:26:23.2798	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
2	4	5	2026-02-27 19:26:23.2798	2026-02-27 19:29:23.2798	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
3	4	5	2026-02-27 19:26:23.2798	2026-02-27 19:32:23.2798	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
4	4	5	2026-02-27 19:26:23.2798	2026-02-27 19:33:23.2798	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 7}
5	4	5	2026-02-27 19:26:23.2798	2026-02-27 19:36:23.2798	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 10}
6	4	5	2026-02-27 19:26:23.2798	2026-02-27 19:37:23.2798	\N	\N	world.player_movement	{"x": 9, "y": 9, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 11}
7	4	5	2026-02-27 19:30:27.813429	2026-02-27 19:30:27.813429	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
8	4	5	2026-02-27 19:30:33.244444	2026-02-27 19:30:33.244444	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
9	4	5	2026-02-27 19:30:33.244444	2026-02-27 19:33:33.244444	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
10	4	5	2026-02-27 19:30:33.244444	2026-02-27 19:36:33.244444	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
11	4	5	2026-02-27 19:30:33.244444	2026-02-27 19:37:33.244444	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 7}
12	4	5	2026-02-27 19:30:33.244444	2026-02-27 19:38:33.244444	\N	\N	world.player_movement	{"x": 8, "y": 5, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 8}
13	4	5	2026-02-27 19:30:36.307688	2026-02-27 19:30:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
15	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
16	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:03:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
17	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:06:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
18	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:07:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 7}
19	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:08:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 8}
20	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:11:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 11}
21	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:12:36.307688	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 7, "moveCost": 6, "totalMoveCost": 12}
14	4	5	2026-02-27 19:30:36.576264	2026-02-27 21:00:36.307688	\N	\N	world.map_tile_exploration	{"x": 4, "y": 6, "explorationLevel": 1}
293	4	5	2026-02-28 23:26:58.006104	2026-02-28 05:01:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
294	4	5	2026-02-28 23:26:58.006104	2026-02-28 05:04:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 6, "mapId": 1, "order": 2, "moveCost": 6, "totalMoveCost": 3}
308	4	5	2026-03-11 21:37:43.005031	2026-02-28 21:59:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
310	4	5	2026-03-13 00:04:44.898846	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
311	4	5	2026-03-13 00:04:44.898846	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
312	4	5	2026-03-13 00:04:44.898846	2026-03-01 04:03:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
313	4	5	2026-03-13 00:04:44.898846	2026-03-01 04:04:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 7}
309	4	5	2026-03-11 21:37:43.08946	2026-03-01 03:57:36.307688	\N	\N	items.gather_resources_on_map_tile	{"x": 4, "y": 6, "gatherAmount": 358, "mapTilesResourceId": 1}
22	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:18:36.307688	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 18}
23	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:19:36.307688	\N	\N	world.player_movement	{"x": 12, "y": 3, "mapId": 1, "order": 9, "moveCost": 1, "totalMoveCost": 19}
24	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:20:36.307688	\N	\N	world.player_movement	{"x": 12, "y": 4, "mapId": 1, "order": 10, "moveCost": 6, "totalMoveCost": 20}
25	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:26:36.307688	\N	\N	world.player_movement	{"x": 13, "y": 5, "mapId": 1, "order": 11, "moveCost": 4, "totalMoveCost": 26}
26	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:30:36.307688	\N	\N	world.player_movement	{"x": 14, "y": 6, "mapId": 1, "order": 12, "moveCost": 4, "totalMoveCost": 30}
27	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:34:36.307688	\N	\N	world.player_movement	{"x": 15, "y": 7, "mapId": 1, "order": 13, "moveCost": 4, "totalMoveCost": 34}
28	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:38:36.307688	\N	\N	world.player_movement	{"x": 16, "y": 8, "mapId": 1, "order": 14, "moveCost": 4, "totalMoveCost": 38}
29	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:42:36.307688	\N	\N	world.player_movement	{"x": 17, "y": 9, "mapId": 1, "order": 15, "moveCost": 4, "totalMoveCost": 42}
30	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:46:36.307688	\N	\N	world.player_movement	{"x": 18, "y": 10, "mapId": 1, "order": 16, "moveCost": 4, "totalMoveCost": 46}
31	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:50:36.307688	\N	\N	world.player_movement	{"x": 19, "y": 11, "mapId": 1, "order": 17, "moveCost": 3, "totalMoveCost": 50}
32	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:53:36.307688	\N	\N	world.player_movement	{"x": 19, "y": 12, "mapId": 1, "order": 18, "moveCost": 3, "totalMoveCost": 53}
33	4	5	2026-02-27 19:31:00.792921	2026-02-27 21:56:36.307688	\N	\N	world.player_movement	{"x": 19, "y": 13, "mapId": 1, "order": 19, "moveCost": 1, "totalMoveCost": 56}
34	4	5	2026-02-27 19:31:58.421371	2026-02-27 21:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
35	4	5	2026-02-27 19:31:58.421371	2026-02-27 21:03:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 5, "mapId": 1, "order": 2, "moveCost": 1, "totalMoveCost": 3}
36	4	5	2026-02-27 19:31:58.421371	2026-02-27 21:04:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 4, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
37	4	5	2026-02-27 19:31:58.421371	2026-02-27 21:05:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 3, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 5}
295	4	5	2026-03-01 18:03:29.171321	2026-02-28 05:01:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
314	4	5	2026-03-13 00:04:44.898846	2026-03-01 04:05:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 5, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 8}
38	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
39	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:03:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
40	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:06:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
41	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:07:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 9, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 7}
315	4	5	2026-03-15 10:17:21.847441	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
316	4	5	2026-03-15 10:17:21.847441	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 5, "mapId": 1, "order": 2, "moveCost": 1, "totalMoveCost": 3}
317	4	5	2026-03-15 10:17:21.847441	2026-03-01 04:01:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 4, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
318	4	5	2026-03-15 10:17:21.847441	2026-03-01 04:02:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 3, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 5}
357	4	1	2026-03-15 14:50:21.62976	2026-03-01 05:30:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
358	4	1	2026-03-15 14:50:21.821406	2026-03-01 14:31:36.307688	\N	\N	items.gather_resources_on_map_tile	{"x": 4, "y": 6, "gatherAmount": 541, "mapTilesResourceId": 1}
401	1	5	2026-03-15 19:06:32.805916	2026-03-15 19:06:32.805916	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
432	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:15:12.85221	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
42	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:10:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 10, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 10}
43	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:11:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 11, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 11}
44	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:14:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 12, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 14}
45	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:17:36.307688	\N	\N	world.player_movement	{"x": 10, "y": 13, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 17}
46	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:18:36.307688	\N	\N	world.player_movement	{"x": 11, "y": 14, "mapId": 1, "order": 9, "moveCost": 1, "totalMoveCost": 18}
47	4	5	2026-02-27 19:32:04.544677	2026-02-27 21:19:36.307688	\N	\N	world.player_movement	{"x": 12, "y": 15, "mapId": 1, "order": 10, "moveCost": 3, "totalMoveCost": 19}
48	4	5	2026-02-27 19:32:38.608639	2026-02-27 21:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
49	4	5	2026-02-27 19:32:38.608639	2026-02-27 21:03:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
50	4	5	2026-02-27 19:32:38.608639	2026-02-27 21:06:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
51	4	5	2026-02-27 19:32:38.608639	2026-02-27 21:07:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 7}
52	4	5	2026-02-27 19:32:38.608639	2026-02-27 21:08:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 5, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 8}
53	4	5	2026-02-27 19:32:38.608639	2026-02-27 21:11:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 11}
54	4	5	2026-02-27 19:32:38.608639	2026-02-27 21:12:36.307688	\N	\N	world.player_movement	{"x": 10, "y": 5, "mapId": 1, "order": 7, "moveCost": 6, "totalMoveCost": 12}
55	4	5	2026-02-27 19:32:43.12335	2026-02-27 21:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
56	4	5	2026-02-27 19:32:43.12335	2026-02-27 21:03:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
57	4	5	2026-02-27 19:32:43.12335	2026-02-27 21:06:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
58	4	5	2026-02-27 19:32:43.12335	2026-02-27 21:07:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 7}
59	4	5	2026-02-27 19:32:43.12335	2026-02-27 21:10:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 10}
60	4	5	2026-02-27 19:32:43.12335	2026-02-27 21:11:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 9, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 11}
61	4	5	2026-02-27 19:32:43.281593	2026-02-27 22:41:36.307688	\N	\N	world.map_tile_exploration	{"x": 9, "y": 9, "explorationLevel": 1}
62	4	5	2026-02-27 19:32:47.585592	2026-02-27 22:41:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
64	4	5	2026-02-27 19:32:49.949405	2026-02-28 00:11:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
65	4	5	2026-02-27 19:32:49.949405	2026-02-28 00:14:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 6, "mapId": 1, "order": 2, "moveCost": 6, "totalMoveCost": 3}
66	4	5	2026-02-27 19:32:53.727356	2026-02-28 00:11:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
67	4	5	2026-02-28 00:29:45.523269	2026-02-28 00:11:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
68	4	5	2026-02-28 00:29:45.523269	2026-02-28 00:14:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
69	4	5	2026-02-28 00:29:45.523269	2026-02-28 00:17:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
63	4	5	2026-02-27 19:32:47.73754	2026-02-28 00:11:36.307688	\N	\N	world.map_tile_exploration	{"x": 4, "y": 6, "explorationLevel": 1}
70	4	5	2026-02-28 00:29:48.497	2026-02-28 00:11:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
71	4	5	2026-02-28 00:29:48.497	2026-02-28 00:14:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
72	4	5	2026-02-28 00:29:48.497	2026-02-28 00:17:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
73	4	5	2026-02-28 00:29:48.58156	2026-02-28 01:47:36.307688	\N	\N	world.map_tile_exploration	{"x": 6, "y": 6, "explorationLevel": 1}
296	4	5	2026-03-01 18:06:05.31422	2026-02-28 05:01:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
74	4	5	2026-02-28 00:36:21.318004	2026-02-28 01:47:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
76	4	5	2026-02-28 16:58:05.793059	2026-02-28 03:17:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
77	4	5	2026-02-28 16:58:05.793059	2026-02-28 03:20:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
78	4	5	2026-02-28 16:58:05.793059	2026-02-28 03:23:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
79	4	5	2026-02-28 16:58:05.793059	2026-02-28 03:24:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 9, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 7}
80	4	5	2026-02-28 16:58:05.793059	2026-02-28 03:27:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 10, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 10}
75	4	5	2026-02-28 00:36:21.562396	2026-02-28 03:17:36.307688	\N	\N	world.map_tile_exploration	{"x": 4, "y": 6, "explorationLevel": 1}
89	3	5	2026-02-28 18:08:19.538494	2026-02-28 18:08:19.538494	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
90	3	5	2026-02-28 18:08:19.538494	2026-02-28 18:09:19.538494	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
91	3	5	2026-02-28 18:08:19.538494	2026-02-28 18:12:19.538494	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 3, "moveCost": 6, "totalMoveCost": 4}
92	3	5	2026-02-28 18:08:19.538494	2026-02-28 18:18:19.538494	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 10}
93	3	5	2026-02-28 18:08:19.538494	2026-02-28 18:19:19.538494	\N	\N	world.player_movement	{"x": 12, "y": 2, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 11}
81	4	5	2026-02-28 16:58:11.215389	2026-02-28 03:17:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
82	4	5	2026-02-28 16:58:11.215389	2026-02-28 03:20:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
83	4	5	2026-02-28 16:58:11.215389	2026-02-28 03:23:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
84	4	5	2026-02-28 16:58:11.215389	2026-02-28 03:24:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 9, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 7}
85	4	5	2026-02-28 16:58:11.215389	2026-02-28 03:27:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 10, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 10}
86	4	5	2026-02-28 16:58:11.215389	2026-02-28 03:28:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 11, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 11}
94	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:08:32.223349	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
95	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:09:32.223349	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
96	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:12:32.223349	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 3, "moveCost": 6, "totalMoveCost": 4}
97	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:18:32.223349	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 10}
87	4	5	2026-02-28 16:58:11.215389	2026-02-28 03:31:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 12, "mapId": 1, "order": 7, "moveCost": 1, "totalMoveCost": 14}
297	4	5	2026-03-01 18:08:24.218897	2026-02-28 05:01:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
320	4	5	2026-03-15 13:42:30.550839	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
321	4	5	2026-03-15 13:42:30.550839	2026-03-01 04:03:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
322	4	5	2026-03-15 13:42:30.550839	2026-03-01 04:04:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 7}
88	4	5	2026-02-28 16:58:11.425504	2026-02-28 05:01:36.307688	\N	\N	world.map_tile_exploration	{"x": 5, "y": 12, "explorationLevel": 1}
359	1	5	2026-03-15 18:48:12.552046	2026-03-15 18:48:12.552046	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
402	1	5	2026-03-15 19:06:32.805916	2026-03-15 19:07:32.805916	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
403	1	5	2026-03-15 19:06:32.805916	2026-03-15 19:10:32.805916	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
404	1	5	2026-03-15 19:06:32.805916	2026-03-15 19:11:32.805916	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
405	1	5	2026-03-15 19:06:32.805916	2026-03-15 19:12:32.805916	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
298	4	5	2026-03-01 18:15:51.77638	2026-02-28 05:01:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
319	4	5	2026-03-15 13:42:30.550839	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
98	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:19:32.223349	\N	\N	world.player_movement	{"x": 12, "y": 3, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 11}
99	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:20:32.223349	\N	\N	world.player_movement	{"x": 12, "y": 4, "mapId": 1, "order": 6, "moveCost": 6, "totalMoveCost": 12}
100	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:26:32.223349	\N	\N	world.player_movement	{"x": 13, "y": 5, "mapId": 1, "order": 7, "moveCost": 4, "totalMoveCost": 18}
101	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:30:32.223349	\N	\N	world.player_movement	{"x": 14, "y": 6, "mapId": 1, "order": 8, "moveCost": 4, "totalMoveCost": 22}
102	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:34:32.223349	\N	\N	world.player_movement	{"x": 15, "y": 7, "mapId": 1, "order": 9, "moveCost": 4, "totalMoveCost": 26}
103	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:38:32.223349	\N	\N	world.player_movement	{"x": 16, "y": 8, "mapId": 1, "order": 10, "moveCost": 4, "totalMoveCost": 30}
104	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:42:32.223349	\N	\N	world.player_movement	{"x": 17, "y": 9, "mapId": 1, "order": 11, "moveCost": 4, "totalMoveCost": 34}
105	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:46:32.223349	\N	\N	world.player_movement	{"x": 18, "y": 10, "mapId": 1, "order": 12, "moveCost": 4, "totalMoveCost": 38}
106	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:50:32.223349	\N	\N	world.player_movement	{"x": 19, "y": 11, "mapId": 1, "order": 13, "moveCost": 3, "totalMoveCost": 42}
107	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:53:32.223349	\N	\N	world.player_movement	{"x": 19, "y": 12, "mapId": 1, "order": 14, "moveCost": 3, "totalMoveCost": 45}
108	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:56:32.223349	\N	\N	world.player_movement	{"x": 19, "y": 13, "mapId": 1, "order": 15, "moveCost": 1, "totalMoveCost": 48}
109	3	5	2026-02-28 18:08:32.223349	2026-02-28 18:57:32.223349	\N	\N	world.player_movement	{"x": 19, "y": 14, "mapId": 1, "order": 16, "moveCost": 3, "totalMoveCost": 49}
110	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:00:32.223349	\N	\N	world.player_movement	{"x": 18, "y": 15, "mapId": 1, "order": 17, "moveCost": 1, "totalMoveCost": 52}
111	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:01:32.223349	\N	\N	world.player_movement	{"x": 19, "y": 16, "mapId": 1, "order": 18, "moveCost": 1, "totalMoveCost": 53}
112	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:02:32.223349	\N	\N	world.player_movement	{"x": 20, "y": 17, "mapId": 1, "order": 19, "moveCost": 3, "totalMoveCost": 54}
113	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:05:32.223349	\N	\N	world.player_movement	{"x": 21, "y": 18, "mapId": 1, "order": 20, "moveCost": 3, "totalMoveCost": 57}
114	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:08:32.223349	\N	\N	world.player_movement	{"x": 22, "y": 19, "mapId": 1, "order": 21, "moveCost": 3, "totalMoveCost": 60}
115	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:11:32.223349	\N	\N	world.player_movement	{"x": 23, "y": 19, "mapId": 1, "order": 22, "moveCost": 1, "totalMoveCost": 63}
323	4	5	2026-03-15 14:46:14.21471	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
324	4	5	2026-03-15 14:46:14.21471	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
325	4	5	2026-03-15 14:46:14.21471	2026-03-01 04:03:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
326	4	5	2026-03-15 14:46:14.21471	2026-03-01 04:04:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 7}
327	4	5	2026-03-15 14:46:14.21471	2026-03-01 04:05:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 6, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 8}
328	4	5	2026-03-15 14:46:14.21471	2026-03-01 04:08:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 7, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 11}
360	1	5	2026-03-15 18:48:12.552046	2026-03-15 18:49:12.552046	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
361	1	5	2026-03-15 18:48:12.552046	2026-03-15 18:52:12.552046	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
362	1	5	2026-03-15 18:48:12.552046	2026-03-15 18:53:12.552046	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
363	1	5	2026-03-15 18:48:12.552046	2026-03-15 18:54:12.552046	\N	\N	world.player_movement	{"x": 5, "y": 5, "mapId": 1, "order": 5, "moveCost": 6, "totalMoveCost": 6}
364	1	5	2026-03-15 18:49:29.539067	2026-03-15 18:49:29.539067	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
116	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:12:32.223349	\N	\N	world.player_movement	{"x": 24, "y": 19, "mapId": 1, "order": 23, "moveCost": 3, "totalMoveCost": 64}
117	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:15:32.223349	\N	\N	world.player_movement	{"x": 25, "y": 19, "mapId": 1, "order": 24, "moveCost": 1, "totalMoveCost": 67}
118	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:16:32.223349	\N	\N	world.player_movement	{"x": 26, "y": 19, "mapId": 1, "order": 25, "moveCost": 1, "totalMoveCost": 68}
119	3	5	2026-02-28 18:08:32.223349	2026-02-28 19:17:32.223349	\N	\N	world.player_movement	{"x": 27, "y": 19, "mapId": 1, "order": 26, "moveCost": 6, "totalMoveCost": 69}
299	4	5	2026-03-01 18:19:53.951437	2026-02-28 05:01:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
329	4	5	2026-03-15 14:47:07.944427	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
330	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
331	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:03:36.307688	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 6}
332	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:04:36.307688	\N	\N	world.player_movement	{"x": 6, "y": 9, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 7}
333	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:07:36.307688	\N	\N	world.player_movement	{"x": 7, "y": 10, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 10}
334	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:08:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 11, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 11}
335	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:11:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 12, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 14}
336	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:14:36.307688	\N	\N	world.player_movement	{"x": 10, "y": 13, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 17}
337	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:15:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 14, "mapId": 1, "order": 9, "moveCost": 1, "totalMoveCost": 18}
365	1	5	2026-03-15 18:49:29.539067	2026-03-15 18:50:29.539067	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
366	1	5	2026-03-15 18:49:29.539067	2026-03-15 18:53:29.539067	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
367	1	5	2026-03-15 18:57:26.79657	2026-03-15 18:57:26.79657	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
368	1	5	2026-03-15 18:57:26.79657	2026-03-15 18:58:26.79657	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
369	1	5	2026-03-15 18:57:26.79657	2026-03-15 19:01:26.79657	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
370	1	5	2026-03-15 18:57:26.79657	2026-03-15 19:02:26.79657	\N	\N	world.player_movement	{"x": 9, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
371	1	5	2026-03-15 18:57:26.79657	2026-03-15 19:03:26.79657	\N	\N	world.player_movement	{"x": 9, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
372	1	5	2026-03-15 18:57:26.79657	2026-03-15 19:06:26.79657	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
373	1	5	2026-03-15 18:57:26.79657	2026-03-15 19:07:26.79657	\N	\N	world.player_movement	{"x": 9, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
406	1	5	2026-03-15 19:07:29.178318	2026-03-15 19:07:29.178318	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
407	1	5	2026-03-15 19:07:29.178318	2026-03-15 19:08:29.178318	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
408	1	5	2026-03-15 19:07:29.178318	2026-03-15 19:11:29.178318	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
409	1	5	2026-03-15 19:07:29.178318	2026-03-15 19:12:29.178318	\N	\N	world.player_movement	{"x": 9, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
410	1	5	2026-03-15 19:07:29.178318	2026-03-15 19:13:29.178318	\N	\N	world.player_movement	{"x": 9, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
411	1	5	2026-03-15 19:07:29.178318	2026-03-15 19:16:29.178318	\N	\N	world.player_movement	{"x": 9, "y": 8, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 9}
412	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:07:51.020872	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
413	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:08:51.020872	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
300	4	5	2026-03-01 18:21:41.348643	2026-02-28 05:01:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
301	4	5	2026-03-01 18:21:41.683329	2026-02-28 08:38:36.307688	\N	\N	items.gather_resources_on_map_tile	{"x": 4, "y": 6, "gatherAmount": 217, "mapTilesResourceId": 1}
338	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:16:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 15, "mapId": 1, "order": 10, "moveCost": 3, "totalMoveCost": 19}
339	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:19:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 16, "mapId": 1, "order": 11, "moveCost": 1, "totalMoveCost": 22}
340	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:20:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 17, "mapId": 1, "order": 12, "moveCost": 3, "totalMoveCost": 23}
341	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:23:36.307688	\N	\N	world.player_movement	{"x": 8, "y": 18, "mapId": 1, "order": 13, "moveCost": 1, "totalMoveCost": 26}
342	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:24:36.307688	\N	\N	world.player_movement	{"x": 9, "y": 19, "mapId": 1, "order": 14, "moveCost": 6, "totalMoveCost": 27}
343	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:30:36.307688	\N	\N	world.player_movement	{"x": 10, "y": 20, "mapId": 1, "order": 15, "moveCost": 1, "totalMoveCost": 33}
120	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:09:21.935875	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
121	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:10:21.935875	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
122	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:13:21.935875	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 3, "moveCost": 6, "totalMoveCost": 4}
123	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:19:21.935875	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 10}
124	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:20:21.935875	\N	\N	world.player_movement	{"x": 12, "y": 3, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 11}
125	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:21:21.935875	\N	\N	world.player_movement	{"x": 12, "y": 4, "mapId": 1, "order": 6, "moveCost": 6, "totalMoveCost": 12}
126	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:27:21.935875	\N	\N	world.player_movement	{"x": 13, "y": 5, "mapId": 1, "order": 7, "moveCost": 4, "totalMoveCost": 18}
127	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:31:21.935875	\N	\N	world.player_movement	{"x": 14, "y": 6, "mapId": 1, "order": 8, "moveCost": 4, "totalMoveCost": 22}
128	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:35:21.935875	\N	\N	world.player_movement	{"x": 15, "y": 7, "mapId": 1, "order": 9, "moveCost": 4, "totalMoveCost": 26}
129	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:39:21.935875	\N	\N	world.player_movement	{"x": 16, "y": 8, "mapId": 1, "order": 10, "moveCost": 4, "totalMoveCost": 30}
130	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:43:21.935875	\N	\N	world.player_movement	{"x": 17, "y": 9, "mapId": 1, "order": 11, "moveCost": 4, "totalMoveCost": 34}
131	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:47:21.935875	\N	\N	world.player_movement	{"x": 18, "y": 10, "mapId": 1, "order": 12, "moveCost": 4, "totalMoveCost": 38}
132	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:51:21.935875	\N	\N	world.player_movement	{"x": 19, "y": 11, "mapId": 1, "order": 13, "moveCost": 3, "totalMoveCost": 42}
133	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:54:21.935875	\N	\N	world.player_movement	{"x": 19, "y": 12, "mapId": 1, "order": 14, "moveCost": 3, "totalMoveCost": 45}
134	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:57:21.935875	\N	\N	world.player_movement	{"x": 19, "y": 13, "mapId": 1, "order": 15, "moveCost": 1, "totalMoveCost": 48}
135	3	5	2026-02-28 18:09:21.935875	2026-02-28 18:58:21.935875	\N	\N	world.player_movement	{"x": 19, "y": 14, "mapId": 1, "order": 16, "moveCost": 3, "totalMoveCost": 49}
136	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:01:21.935875	\N	\N	world.player_movement	{"x": 18, "y": 15, "mapId": 1, "order": 17, "moveCost": 1, "totalMoveCost": 52}
137	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:02:21.935875	\N	\N	world.player_movement	{"x": 19, "y": 16, "mapId": 1, "order": 18, "moveCost": 1, "totalMoveCost": 53}
138	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:03:21.935875	\N	\N	world.player_movement	{"x": 20, "y": 17, "mapId": 1, "order": 19, "moveCost": 3, "totalMoveCost": 54}
139	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:06:21.935875	\N	\N	world.player_movement	{"x": 21, "y": 18, "mapId": 1, "order": 20, "moveCost": 3, "totalMoveCost": 57}
140	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:09:21.935875	\N	\N	world.player_movement	{"x": 22, "y": 19, "mapId": 1, "order": 21, "moveCost": 3, "totalMoveCost": 60}
141	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:12:21.935875	\N	\N	world.player_movement	{"x": 23, "y": 19, "mapId": 1, "order": 22, "moveCost": 1, "totalMoveCost": 63}
142	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:13:21.935875	\N	\N	world.player_movement	{"x": 24, "y": 20, "mapId": 1, "order": 23, "moveCost": 3, "totalMoveCost": 64}
143	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:16:21.935875	\N	\N	world.player_movement	{"x": 25, "y": 21, "mapId": 1, "order": 24, "moveCost": 3, "totalMoveCost": 67}
144	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:19:21.935875	\N	\N	world.player_movement	{"x": 26, "y": 22, "mapId": 1, "order": 25, "moveCost": 3, "totalMoveCost": 70}
145	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:22:21.935875	\N	\N	world.player_movement	{"x": 27, "y": 22, "mapId": 1, "order": 26, "moveCost": 3, "totalMoveCost": 73}
146	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:25:21.935875	\N	\N	world.player_movement	{"x": 28, "y": 23, "mapId": 1, "order": 27, "moveCost": 3, "totalMoveCost": 76}
147	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:28:21.935875	\N	\N	world.player_movement	{"x": 29, "y": 22, "mapId": 1, "order": 28, "moveCost": 1, "totalMoveCost": 79}
148	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:29:21.935875	\N	\N	world.player_movement	{"x": 30, "y": 23, "mapId": 1, "order": 29, "moveCost": 1, "totalMoveCost": 80}
149	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:30:21.935875	\N	\N	world.player_movement	{"x": 31, "y": 24, "mapId": 1, "order": 30, "moveCost": 5, "totalMoveCost": 81}
150	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:35:21.935875	\N	\N	world.player_movement	{"x": 32, "y": 24, "mapId": 1, "order": 31, "moveCost": 1, "totalMoveCost": 86}
151	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:36:21.935875	\N	\N	world.player_movement	{"x": 33, "y": 25, "mapId": 1, "order": 32, "moveCost": 6, "totalMoveCost": 87}
152	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:42:21.935875	\N	\N	world.player_movement	{"x": 34, "y": 26, "mapId": 1, "order": 33, "moveCost": 5, "totalMoveCost": 93}
153	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:47:21.935875	\N	\N	world.player_movement	{"x": 35, "y": 25, "mapId": 1, "order": 34, "moveCost": 1, "totalMoveCost": 98}
154	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:48:21.935875	\N	\N	world.player_movement	{"x": 36, "y": 25, "mapId": 1, "order": 35, "moveCost": 1, "totalMoveCost": 99}
155	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:49:21.935875	\N	\N	world.player_movement	{"x": 37, "y": 26, "mapId": 1, "order": 36, "moveCost": 1, "totalMoveCost": 100}
156	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:50:21.935875	\N	\N	world.player_movement	{"x": 38, "y": 25, "mapId": 1, "order": 37, "moveCost": 3, "totalMoveCost": 101}
157	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:53:21.935875	\N	\N	world.player_movement	{"x": 39, "y": 24, "mapId": 1, "order": 38, "moveCost": 3, "totalMoveCost": 104}
158	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:56:21.935875	\N	\N	world.player_movement	{"x": 40, "y": 23, "mapId": 1, "order": 39, "moveCost": 1, "totalMoveCost": 107}
159	3	5	2026-02-28 18:09:21.935875	2026-02-28 19:57:21.935875	\N	\N	world.player_movement	{"x": 40, "y": 22, "mapId": 1, "order": 40, "moveCost": 1, "totalMoveCost": 108}
302	4	5	2026-03-01 18:22:46.991179	2026-02-28 08:38:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
303	4	5	2026-03-01 18:22:47.131886	2026-02-28 12:15:36.307688	\N	\N	items.gather_resources_on_map_tile	{"x": 4, "y": 6, "gatherAmount": 217, "mapTilesResourceId": 1}
344	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:31:36.307688	\N	\N	world.player_movement	{"x": 11, "y": 21, "mapId": 1, "order": 16, "moveCost": 6, "totalMoveCost": 34}
345	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:37:36.307688	\N	\N	world.player_movement	{"x": 12, "y": 22, "mapId": 1, "order": 17, "moveCost": 1, "totalMoveCost": 40}
346	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:38:36.307688	\N	\N	world.player_movement	{"x": 13, "y": 22, "mapId": 1, "order": 18, "moveCost": 1, "totalMoveCost": 41}
347	4	5	2026-03-15 14:47:07.944427	2026-03-01 04:39:36.307688	\N	\N	world.player_movement	{"x": 14, "y": 21, "mapId": 1, "order": 19, "moveCost": 3, "totalMoveCost": 42}
348	4	5	2026-03-15 14:48:22.44158	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
349	4	5	2026-03-15 14:48:22.44158	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
374	1	5	2026-03-15 18:58:38.689947	2026-03-15 18:58:38.689947	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
375	1	5	2026-03-15 18:58:38.689947	2026-03-15 18:59:38.689947	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
376	1	5	2026-03-15 18:58:38.689947	2026-03-15 19:02:38.689947	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
377	1	5	2026-03-15 18:58:38.689947	2026-03-15 19:03:38.689947	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
304	4	5	2026-03-01 18:24:53.759966	2026-02-28 12:15:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
305	4	5	2026-03-01 18:24:53.836069	2026-02-28 15:52:36.307688	\N	\N	items.gather_resources_on_map_tile	{"x": 4, "y": 6, "gatherAmount": 217, "mapTilesResourceId": 1}
350	4	5	2026-03-15 14:48:55.476293	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
351	4	5	2026-03-15 14:48:55.476293	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
352	4	5	2026-03-15 14:48:58.612025	2026-03-01 03:57:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
353	4	5	2026-03-15 14:48:58.612025	2026-03-01 04:00:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 7, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 3}
378	1	5	2026-03-15 18:58:38.689947	2026-03-15 19:04:38.689947	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
379	1	5	2026-03-15 18:58:38.689947	2026-03-15 19:07:38.689947	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
380	1	5	2026-03-15 18:58:39.683813	2026-03-15 18:58:39.683813	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
381	1	5	2026-03-15 18:58:39.683813	2026-03-15 18:59:39.683813	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
382	1	5	2026-03-15 18:58:39.683813	2026-03-15 19:02:39.683813	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
383	1	5	2026-03-15 18:58:39.683813	2026-03-15 19:03:39.683813	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
384	1	5	2026-03-15 18:58:39.683813	2026-03-15 19:04:39.683813	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
385	1	5	2026-03-15 18:58:39.683813	2026-03-15 19:07:39.683813	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
415	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:12:51.020872	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
416	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:13:51.020872	\N	\N	world.player_movement	{"x": 6, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
417	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:16:51.020872	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
418	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:17:51.020872	\N	\N	world.player_movement	{"x": 6, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
419	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:20:51.020872	\N	\N	world.player_movement	{"x": 7, "y": 10, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 13}
420	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:21:51.020872	\N	\N	world.player_movement	{"x": 6, "y": 11, "mapId": 1, "order": 9, "moveCost": 3, "totalMoveCost": 14}
421	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:24:51.020872	\N	\N	world.player_movement	{"x": 6, "y": 12, "mapId": 1, "order": 10, "moveCost": 1, "totalMoveCost": 17}
433	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:18:12.85221	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
434	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:19:12.85221	\N	\N	world.player_movement	{"x": 4, "y": 9, "mapId": 1, "order": 7, "moveCost": 1, "totalMoveCost": 10}
435	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:20:12.85221	\N	\N	world.player_movement	{"x": 3, "y": 8, "mapId": 1, "order": 8, "moveCost": 6, "totalMoveCost": 11}
428	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:09:12.85221	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
429	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:10:12.85221	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
430	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:13:12.85221	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
306	4	5	2026-03-01 18:26:11.648998	2026-02-28 15:52:36.307688	\N	\N	world.player_movement	{"x": 4, "y": 6, "mapId": 1, "order": 1, "moveCost": 3, "totalMoveCost": 0}
307	4	5	2026-03-01 18:26:11.712793	2026-02-28 21:59:36.307688	\N	\N	items.gather_resources_on_map_tile	{"x": 4, "y": 6, "gatherAmount": 367, "mapTilesResourceId": 2}
354	4	1	2026-03-15 14:48:58.655747	2026-03-01 05:30:36.307688	\N	\N	world.map_tile_exploration	{"x": 4, "y": 7, "explorationLevel": 1}
160	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:09:57.25841	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
161	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:10:57.25841	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
162	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:13:57.25841	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 3, "moveCost": 6, "totalMoveCost": 4}
163	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:19:57.25841	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 10}
164	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:20:57.25841	\N	\N	world.player_movement	{"x": 12, "y": 3, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 11}
165	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:21:57.25841	\N	\N	world.player_movement	{"x": 12, "y": 4, "mapId": 1, "order": 6, "moveCost": 6, "totalMoveCost": 12}
166	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:27:57.25841	\N	\N	world.player_movement	{"x": 13, "y": 5, "mapId": 1, "order": 7, "moveCost": 4, "totalMoveCost": 18}
167	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:31:57.25841	\N	\N	world.player_movement	{"x": 14, "y": 6, "mapId": 1, "order": 8, "moveCost": 4, "totalMoveCost": 22}
168	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:35:57.25841	\N	\N	world.player_movement	{"x": 15, "y": 7, "mapId": 1, "order": 9, "moveCost": 4, "totalMoveCost": 26}
169	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:39:57.25841	\N	\N	world.player_movement	{"x": 16, "y": 8, "mapId": 1, "order": 10, "moveCost": 4, "totalMoveCost": 30}
170	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:43:57.25841	\N	\N	world.player_movement	{"x": 17, "y": 9, "mapId": 1, "order": 11, "moveCost": 4, "totalMoveCost": 34}
171	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:47:57.25841	\N	\N	world.player_movement	{"x": 18, "y": 10, "mapId": 1, "order": 12, "moveCost": 4, "totalMoveCost": 38}
172	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:51:57.25841	\N	\N	world.player_movement	{"x": 19, "y": 11, "mapId": 1, "order": 13, "moveCost": 3, "totalMoveCost": 42}
173	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:54:57.25841	\N	\N	world.player_movement	{"x": 19, "y": 12, "mapId": 1, "order": 14, "moveCost": 3, "totalMoveCost": 45}
174	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:57:57.25841	\N	\N	world.player_movement	{"x": 19, "y": 13, "mapId": 1, "order": 15, "moveCost": 1, "totalMoveCost": 48}
175	3	5	2026-02-28 18:09:57.25841	2026-02-28 18:58:57.25841	\N	\N	world.player_movement	{"x": 19, "y": 14, "mapId": 1, "order": 16, "moveCost": 3, "totalMoveCost": 49}
176	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:01:57.25841	\N	\N	world.player_movement	{"x": 18, "y": 15, "mapId": 1, "order": 17, "moveCost": 1, "totalMoveCost": 52}
177	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:02:57.25841	\N	\N	world.player_movement	{"x": 19, "y": 16, "mapId": 1, "order": 18, "moveCost": 1, "totalMoveCost": 53}
178	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:03:57.25841	\N	\N	world.player_movement	{"x": 20, "y": 17, "mapId": 1, "order": 19, "moveCost": 3, "totalMoveCost": 54}
179	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:06:57.25841	\N	\N	world.player_movement	{"x": 21, "y": 18, "mapId": 1, "order": 20, "moveCost": 3, "totalMoveCost": 57}
180	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:09:57.25841	\N	\N	world.player_movement	{"x": 22, "y": 19, "mapId": 1, "order": 21, "moveCost": 3, "totalMoveCost": 60}
386	1	5	2026-03-15 18:59:24.205393	2026-03-15 18:59:24.205393	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
414	1	5	2026-03-15 19:07:51.020872	2026-03-15 19:11:51.020872	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
422	1	5	2026-03-15 19:08:45.805915	2026-03-15 19:08:45.805915	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
423	1	5	2026-03-15 19:08:45.805915	2026-03-15 19:09:45.805915	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
431	1	5	2026-03-15 19:09:12.85221	2026-03-15 19:14:12.85221	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
181	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:12:57.25841	\N	\N	world.player_movement	{"x": 23, "y": 19, "mapId": 1, "order": 22, "moveCost": 1, "totalMoveCost": 63}
182	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:13:57.25841	\N	\N	world.player_movement	{"x": 24, "y": 20, "mapId": 1, "order": 23, "moveCost": 3, "totalMoveCost": 64}
183	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:16:57.25841	\N	\N	world.player_movement	{"x": 25, "y": 21, "mapId": 1, "order": 24, "moveCost": 3, "totalMoveCost": 67}
184	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:19:57.25841	\N	\N	world.player_movement	{"x": 26, "y": 22, "mapId": 1, "order": 25, "moveCost": 3, "totalMoveCost": 70}
185	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:22:57.25841	\N	\N	world.player_movement	{"x": 27, "y": 23, "mapId": 1, "order": 26, "moveCost": 3, "totalMoveCost": 73}
186	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:25:57.25841	\N	\N	world.player_movement	{"x": 28, "y": 24, "mapId": 1, "order": 27, "moveCost": 1, "totalMoveCost": 76}
187	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:26:57.25841	\N	\N	world.player_movement	{"x": 29, "y": 25, "mapId": 1, "order": 28, "moveCost": 1, "totalMoveCost": 77}
188	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:27:57.25841	\N	\N	world.player_movement	{"x": 30, "y": 26, "mapId": 1, "order": 29, "moveCost": 3, "totalMoveCost": 78}
189	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:30:57.25841	\N	\N	world.player_movement	{"x": 31, "y": 27, "mapId": 1, "order": 30, "moveCost": 3, "totalMoveCost": 81}
190	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:33:57.25841	\N	\N	world.player_movement	{"x": 31, "y": 28, "mapId": 1, "order": 31, "moveCost": 3, "totalMoveCost": 84}
191	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:36:57.25841	\N	\N	world.player_movement	{"x": 32, "y": 29, "mapId": 1, "order": 32, "moveCost": 3, "totalMoveCost": 87}
192	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:39:57.25841	\N	\N	world.player_movement	{"x": 33, "y": 30, "mapId": 1, "order": 33, "moveCost": 3, "totalMoveCost": 90}
193	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:42:57.25841	\N	\N	world.player_movement	{"x": 34, "y": 31, "mapId": 1, "order": 34, "moveCost": 1, "totalMoveCost": 93}
194	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:43:57.25841	\N	\N	world.player_movement	{"x": 35, "y": 32, "mapId": 1, "order": 35, "moveCost": 1, "totalMoveCost": 94}
195	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:44:57.25841	\N	\N	world.player_movement	{"x": 36, "y": 33, "mapId": 1, "order": 36, "moveCost": 3, "totalMoveCost": 95}
196	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:47:57.25841	\N	\N	world.player_movement	{"x": 37, "y": 32, "mapId": 1, "order": 37, "moveCost": 1, "totalMoveCost": 98}
197	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:48:57.25841	\N	\N	world.player_movement	{"x": 38, "y": 32, "mapId": 1, "order": 38, "moveCost": 1, "totalMoveCost": 99}
198	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:49:57.25841	\N	\N	world.player_movement	{"x": 39, "y": 33, "mapId": 1, "order": 39, "moveCost": 1, "totalMoveCost": 100}
199	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:50:57.25841	\N	\N	world.player_movement	{"x": 40, "y": 34, "mapId": 1, "order": 40, "moveCost": 1, "totalMoveCost": 101}
200	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:51:57.25841	\N	\N	world.player_movement	{"x": 40, "y": 35, "mapId": 1, "order": 41, "moveCost": 3, "totalMoveCost": 102}
201	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:54:57.25841	\N	\N	world.player_movement	{"x": 41, "y": 36, "mapId": 1, "order": 42, "moveCost": 1, "totalMoveCost": 105}
202	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:55:57.25841	\N	\N	world.player_movement	{"x": 42, "y": 37, "mapId": 1, "order": 43, "moveCost": 1, "totalMoveCost": 106}
203	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:56:57.25841	\N	\N	world.player_movement	{"x": 43, "y": 38, "mapId": 1, "order": 44, "moveCost": 3, "totalMoveCost": 107}
204	3	5	2026-02-28 18:09:57.25841	2026-02-28 19:59:57.25841	\N	\N	world.player_movement	{"x": 43, "y": 39, "mapId": 1, "order": 45, "moveCost": 1, "totalMoveCost": 110}
205	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:00:57.25841	\N	\N	world.player_movement	{"x": 43, "y": 40, "mapId": 1, "order": 46, "moveCost": 1, "totalMoveCost": 111}
206	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:01:57.25841	\N	\N	world.player_movement	{"x": 44, "y": 41, "mapId": 1, "order": 47, "moveCost": 3, "totalMoveCost": 112}
207	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:04:57.25841	\N	\N	world.player_movement	{"x": 45, "y": 42, "mapId": 1, "order": 48, "moveCost": 1, "totalMoveCost": 115}
208	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:05:57.25841	\N	\N	world.player_movement	{"x": 46, "y": 43, "mapId": 1, "order": 49, "moveCost": 1, "totalMoveCost": 116}
209	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:06:57.25841	\N	\N	world.player_movement	{"x": 47, "y": 44, "mapId": 1, "order": 50, "moveCost": 1, "totalMoveCost": 117}
210	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:07:57.25841	\N	\N	world.player_movement	{"x": 47, "y": 45, "mapId": 1, "order": 51, "moveCost": 1, "totalMoveCost": 118}
211	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:08:57.25841	\N	\N	world.player_movement	{"x": 48, "y": 46, "mapId": 1, "order": 52, "moveCost": 1, "totalMoveCost": 119}
212	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:09:57.25841	\N	\N	world.player_movement	{"x": 49, "y": 47, "mapId": 1, "order": 53, "moveCost": 3, "totalMoveCost": 120}
213	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:12:57.25841	\N	\N	world.player_movement	{"x": 50, "y": 47, "mapId": 1, "order": 54, "moveCost": 1, "totalMoveCost": 123}
214	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:13:57.25841	\N	\N	world.player_movement	{"x": 51, "y": 48, "mapId": 1, "order": 55, "moveCost": 1, "totalMoveCost": 124}
215	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:14:57.25841	\N	\N	world.player_movement	{"x": 52, "y": 49, "mapId": 1, "order": 56, "moveCost": 3, "totalMoveCost": 125}
216	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:17:57.25841	\N	\N	world.player_movement	{"x": 53, "y": 50, "mapId": 1, "order": 57, "moveCost": 1, "totalMoveCost": 128}
217	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:18:57.25841	\N	\N	world.player_movement	{"x": 52, "y": 51, "mapId": 1, "order": 58, "moveCost": 1, "totalMoveCost": 129}
218	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:19:57.25841	\N	\N	world.player_movement	{"x": 53, "y": 52, "mapId": 1, "order": 59, "moveCost": 3, "totalMoveCost": 130}
219	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:22:57.25841	\N	\N	world.player_movement	{"x": 54, "y": 53, "mapId": 1, "order": 60, "moveCost": 1, "totalMoveCost": 133}
220	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:23:57.25841	\N	\N	world.player_movement	{"x": 55, "y": 52, "mapId": 1, "order": 61, "moveCost": 3, "totalMoveCost": 134}
221	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:26:57.25841	\N	\N	world.player_movement	{"x": 56, "y": 52, "mapId": 1, "order": 62, "moveCost": 3, "totalMoveCost": 137}
222	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:29:57.25841	\N	\N	world.player_movement	{"x": 57, "y": 53, "mapId": 1, "order": 63, "moveCost": 1, "totalMoveCost": 140}
223	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:30:57.25841	\N	\N	world.player_movement	{"x": 58, "y": 53, "mapId": 1, "order": 64, "moveCost": 5, "totalMoveCost": 141}
224	3	5	2026-02-28 18:09:57.25841	2026-02-28 20:35:57.25841	\N	\N	world.player_movement	{"x": 59, "y": 52, "mapId": 1, "order": 65, "moveCost": 6, "totalMoveCost": 146}
225	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:10:17.097882	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
226	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:11:17.097882	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
227	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:14:17.097882	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 3, "moveCost": 6, "totalMoveCost": 4}
228	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:20:17.097882	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 10}
229	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:21:17.097882	\N	\N	world.player_movement	{"x": 12, "y": 3, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 11}
230	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:22:17.097882	\N	\N	world.player_movement	{"x": 12, "y": 4, "mapId": 1, "order": 6, "moveCost": 6, "totalMoveCost": 12}
231	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:28:17.097882	\N	\N	world.player_movement	{"x": 13, "y": 5, "mapId": 1, "order": 7, "moveCost": 4, "totalMoveCost": 18}
232	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:32:17.097882	\N	\N	world.player_movement	{"x": 14, "y": 6, "mapId": 1, "order": 8, "moveCost": 4, "totalMoveCost": 22}
233	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:36:17.097882	\N	\N	world.player_movement	{"x": 15, "y": 7, "mapId": 1, "order": 9, "moveCost": 4, "totalMoveCost": 26}
234	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:40:17.097882	\N	\N	world.player_movement	{"x": 16, "y": 8, "mapId": 1, "order": 10, "moveCost": 4, "totalMoveCost": 30}
235	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:44:17.097882	\N	\N	world.player_movement	{"x": 17, "y": 9, "mapId": 1, "order": 11, "moveCost": 4, "totalMoveCost": 34}
236	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:48:17.097882	\N	\N	world.player_movement	{"x": 18, "y": 10, "mapId": 1, "order": 12, "moveCost": 4, "totalMoveCost": 38}
237	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:52:17.097882	\N	\N	world.player_movement	{"x": 19, "y": 11, "mapId": 1, "order": 13, "moveCost": 3, "totalMoveCost": 42}
238	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:55:17.097882	\N	\N	world.player_movement	{"x": 19, "y": 12, "mapId": 1, "order": 14, "moveCost": 3, "totalMoveCost": 45}
239	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:58:17.097882	\N	\N	world.player_movement	{"x": 19, "y": 13, "mapId": 1, "order": 15, "moveCost": 1, "totalMoveCost": 48}
240	3	1	2026-02-28 18:10:17.097882	2026-02-28 18:59:17.097882	\N	\N	world.player_movement	{"x": 19, "y": 14, "mapId": 1, "order": 16, "moveCost": 3, "totalMoveCost": 49}
241	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:02:17.097882	\N	\N	world.player_movement	{"x": 18, "y": 15, "mapId": 1, "order": 17, "moveCost": 1, "totalMoveCost": 52}
242	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:03:17.097882	\N	\N	world.player_movement	{"x": 19, "y": 16, "mapId": 1, "order": 18, "moveCost": 1, "totalMoveCost": 53}
243	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:04:17.097882	\N	\N	world.player_movement	{"x": 20, "y": 17, "mapId": 1, "order": 19, "moveCost": 3, "totalMoveCost": 54}
244	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:07:17.097882	\N	\N	world.player_movement	{"x": 21, "y": 18, "mapId": 1, "order": 20, "moveCost": 3, "totalMoveCost": 57}
245	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:10:17.097882	\N	\N	world.player_movement	{"x": 22, "y": 19, "mapId": 1, "order": 21, "moveCost": 3, "totalMoveCost": 60}
246	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:13:17.097882	\N	\N	world.player_movement	{"x": 23, "y": 19, "mapId": 1, "order": 22, "moveCost": 1, "totalMoveCost": 63}
247	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:14:17.097882	\N	\N	world.player_movement	{"x": 24, "y": 20, "mapId": 1, "order": 23, "moveCost": 3, "totalMoveCost": 64}
248	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:17:17.097882	\N	\N	world.player_movement	{"x": 25, "y": 21, "mapId": 1, "order": 24, "moveCost": 3, "totalMoveCost": 67}
249	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:20:17.097882	\N	\N	world.player_movement	{"x": 26, "y": 22, "mapId": 1, "order": 25, "moveCost": 3, "totalMoveCost": 70}
250	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:23:17.097882	\N	\N	world.player_movement	{"x": 27, "y": 23, "mapId": 1, "order": 26, "moveCost": 3, "totalMoveCost": 73}
251	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:26:17.097882	\N	\N	world.player_movement	{"x": 28, "y": 24, "mapId": 1, "order": 27, "moveCost": 1, "totalMoveCost": 76}
252	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:27:17.097882	\N	\N	world.player_movement	{"x": 29, "y": 25, "mapId": 1, "order": 28, "moveCost": 1, "totalMoveCost": 77}
253	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:28:17.097882	\N	\N	world.player_movement	{"x": 30, "y": 26, "mapId": 1, "order": 29, "moveCost": 3, "totalMoveCost": 78}
254	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:31:17.097882	\N	\N	world.player_movement	{"x": 31, "y": 27, "mapId": 1, "order": 30, "moveCost": 3, "totalMoveCost": 81}
255	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:34:17.097882	\N	\N	world.player_movement	{"x": 31, "y": 28, "mapId": 1, "order": 31, "moveCost": 3, "totalMoveCost": 84}
256	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:37:17.097882	\N	\N	world.player_movement	{"x": 32, "y": 29, "mapId": 1, "order": 32, "moveCost": 3, "totalMoveCost": 87}
257	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:40:17.097882	\N	\N	world.player_movement	{"x": 33, "y": 30, "mapId": 1, "order": 33, "moveCost": 3, "totalMoveCost": 90}
258	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:43:17.097882	\N	\N	world.player_movement	{"x": 34, "y": 31, "mapId": 1, "order": 34, "moveCost": 1, "totalMoveCost": 93}
259	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:44:17.097882	\N	\N	world.player_movement	{"x": 35, "y": 32, "mapId": 1, "order": 35, "moveCost": 1, "totalMoveCost": 94}
260	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:45:17.097882	\N	\N	world.player_movement	{"x": 36, "y": 33, "mapId": 1, "order": 36, "moveCost": 3, "totalMoveCost": 95}
261	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:48:17.097882	\N	\N	world.player_movement	{"x": 37, "y": 32, "mapId": 1, "order": 37, "moveCost": 1, "totalMoveCost": 98}
262	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:49:17.097882	\N	\N	world.player_movement	{"x": 38, "y": 32, "mapId": 1, "order": 38, "moveCost": 1, "totalMoveCost": 99}
263	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:50:17.097882	\N	\N	world.player_movement	{"x": 39, "y": 33, "mapId": 1, "order": 39, "moveCost": 1, "totalMoveCost": 100}
264	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:51:17.097882	\N	\N	world.player_movement	{"x": 40, "y": 34, "mapId": 1, "order": 40, "moveCost": 1, "totalMoveCost": 101}
265	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:52:17.097882	\N	\N	world.player_movement	{"x": 40, "y": 35, "mapId": 1, "order": 41, "moveCost": 3, "totalMoveCost": 102}
266	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:55:17.097882	\N	\N	world.player_movement	{"x": 41, "y": 36, "mapId": 1, "order": 42, "moveCost": 1, "totalMoveCost": 105}
267	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:56:17.097882	\N	\N	world.player_movement	{"x": 42, "y": 37, "mapId": 1, "order": 43, "moveCost": 1, "totalMoveCost": 106}
268	3	1	2026-02-28 18:10:17.097882	2026-02-28 19:57:17.097882	\N	\N	world.player_movement	{"x": 43, "y": 38, "mapId": 1, "order": 44, "moveCost": 3, "totalMoveCost": 107}
269	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:00:17.097882	\N	\N	world.player_movement	{"x": 43, "y": 39, "mapId": 1, "order": 45, "moveCost": 1, "totalMoveCost": 110}
270	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:01:17.097882	\N	\N	world.player_movement	{"x": 43, "y": 40, "mapId": 1, "order": 46, "moveCost": 1, "totalMoveCost": 111}
271	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:02:17.097882	\N	\N	world.player_movement	{"x": 44, "y": 41, "mapId": 1, "order": 47, "moveCost": 3, "totalMoveCost": 112}
272	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:05:17.097882	\N	\N	world.player_movement	{"x": 45, "y": 42, "mapId": 1, "order": 48, "moveCost": 1, "totalMoveCost": 115}
273	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:06:17.097882	\N	\N	world.player_movement	{"x": 46, "y": 43, "mapId": 1, "order": 49, "moveCost": 1, "totalMoveCost": 116}
274	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:07:17.097882	\N	\N	world.player_movement	{"x": 47, "y": 44, "mapId": 1, "order": 50, "moveCost": 1, "totalMoveCost": 117}
275	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:08:17.097882	\N	\N	world.player_movement	{"x": 47, "y": 45, "mapId": 1, "order": 51, "moveCost": 1, "totalMoveCost": 118}
276	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:09:17.097882	\N	\N	world.player_movement	{"x": 48, "y": 46, "mapId": 1, "order": 52, "moveCost": 1, "totalMoveCost": 119}
277	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:10:17.097882	\N	\N	world.player_movement	{"x": 49, "y": 47, "mapId": 1, "order": 53, "moveCost": 3, "totalMoveCost": 120}
278	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:13:17.097882	\N	\N	world.player_movement	{"x": 49, "y": 48, "mapId": 1, "order": 54, "moveCost": 1, "totalMoveCost": 123}
279	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:14:17.097882	\N	\N	world.player_movement	{"x": 49, "y": 49, "mapId": 1, "order": 55, "moveCost": 1, "totalMoveCost": 124}
280	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:15:17.097882	\N	\N	world.player_movement	{"x": 50, "y": 50, "mapId": 1, "order": 56, "moveCost": 3, "totalMoveCost": 125}
281	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:18:17.097882	\N	\N	world.player_movement	{"x": 51, "y": 51, "mapId": 1, "order": 57, "moveCost": 1, "totalMoveCost": 128}
282	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:19:17.097882	\N	\N	world.player_movement	{"x": 50, "y": 52, "mapId": 1, "order": 58, "moveCost": 1, "totalMoveCost": 129}
283	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:20:17.097882	\N	\N	world.player_movement	{"x": 51, "y": 53, "mapId": 1, "order": 59, "moveCost": 1, "totalMoveCost": 130}
284	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:21:17.097882	\N	\N	world.player_movement	{"x": 52, "y": 54, "mapId": 1, "order": 60, "moveCost": 3, "totalMoveCost": 131}
285	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:24:17.097882	\N	\N	world.player_movement	{"x": 53, "y": 55, "mapId": 1, "order": 61, "moveCost": 3, "totalMoveCost": 134}
286	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:27:17.097882	\N	\N	world.player_movement	{"x": 54, "y": 56, "mapId": 1, "order": 62, "moveCost": 1, "totalMoveCost": 137}
287	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:28:17.097882	\N	\N	world.player_movement	{"x": 55, "y": 57, "mapId": 1, "order": 63, "moveCost": 1, "totalMoveCost": 138}
288	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:29:17.097882	\N	\N	world.player_movement	{"x": 56, "y": 58, "mapId": 1, "order": 64, "moveCost": 3, "totalMoveCost": 139}
289	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:32:17.097882	\N	\N	world.player_movement	{"x": 57, "y": 58, "mapId": 1, "order": 65, "moveCost": 1, "totalMoveCost": 142}
290	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:33:17.097882	\N	\N	world.player_movement	{"x": 58, "y": 58, "mapId": 1, "order": 66, "moveCost": 1, "totalMoveCost": 143}
291	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:34:17.097882	\N	\N	world.player_movement	{"x": 59, "y": 59, "mapId": 1, "order": 67, "moveCost": 3, "totalMoveCost": 144}
292	3	1	2026-02-28 18:10:17.097882	2026-02-28 20:37:17.097882	\N	\N	world.player_movement	{"x": 60, "y": 60, "mapId": 1, "order": 68, "moveCost": 1, "totalMoveCost": 147}
355	1	5	2026-03-15 14:49:49.154712	2026-03-15 14:49:49.154712	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
356	1	5	2026-03-15 14:49:49.154712	2026-03-15 14:50:49.154712	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
387	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:00:24.205393	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
388	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:03:24.205393	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
389	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:04:24.205393	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
390	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:05:24.205393	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
391	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:08:24.205393	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
392	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:09:24.205393	\N	\N	world.player_movement	{"x": 8, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
393	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:12:24.205393	\N	\N	world.player_movement	{"x": 7, "y": 10, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 13}
394	1	5	2026-03-15 18:59:24.205393	2026-03-15 19:13:24.205393	\N	\N	world.player_movement	{"x": 8, "y": 11, "mapId": 1, "order": 9, "moveCost": 3, "totalMoveCost": 14}
395	1	5	2026-03-15 19:05:17.220187	2026-03-15 19:05:17.220187	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
396	1	5	2026-03-15 19:05:17.220187	2026-03-15 19:06:17.220187	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
397	1	5	2026-03-15 19:05:17.220187	2026-03-15 19:09:17.220187	\N	\N	world.player_movement	{"x": 7, "y": 3, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
398	1	5	2026-03-15 19:05:17.220187	2026-03-15 19:10:17.220187	\N	\N	world.player_movement	{"x": 6, "y": 4, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 5}
399	1	5	2026-03-15 19:05:17.220187	2026-03-15 19:13:17.220187	\N	\N	world.player_movement	{"x": 5, "y": 4, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 8}
400	1	5	2026-03-15 19:05:17.220187	2026-03-15 19:14:17.220187	\N	\N	world.player_movement	{"x": 4, "y": 4, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 9}
424	1	5	2026-03-15 19:08:45.805915	2026-03-15 19:12:45.805915	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
425	1	5	2026-03-15 19:08:45.805915	2026-03-15 19:13:45.805915	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
426	1	5	2026-03-15 19:08:45.805915	2026-03-15 19:14:45.805915	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
427	1	5	2026-03-15 19:08:45.805915	2026-03-15 19:17:45.805915	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
436	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:09:25.415669	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
437	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:10:25.415669	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
438	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:13:25.415669	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
439	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:14:25.415669	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
440	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:15:25.415669	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
441	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:18:25.415669	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
442	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:19:25.415669	\N	\N	world.player_movement	{"x": 8, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
443	1	5	2026-03-15 19:09:25.415669	2026-03-15 19:22:25.415669	\N	\N	world.player_movement	{"x": 8, "y": 10, "mapId": 1, "order": 8, "moveCost": 3, "totalMoveCost": 13}
444	1	5	2026-03-15 19:10:55.967968	2026-03-15 19:10:55.967968	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
445	1	5	2026-03-15 19:10:55.967968	2026-03-15 19:11:55.967968	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
446	1	5	2026-03-15 19:10:55.967968	2026-03-15 19:14:55.967968	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
447	1	5	2026-03-15 19:10:55.967968	2026-03-15 19:15:55.967968	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
448	1	5	2026-03-15 19:10:55.967968	2026-03-15 19:16:55.967968	\N	\N	world.player_movement	{"x": 5, "y": 6, "mapId": 1, "order": 5, "moveCost": 6, "totalMoveCost": 6}
449	1	5	2026-03-15 19:11:07.243275	2026-03-15 19:11:07.243275	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
450	1	5	2026-03-15 19:11:07.243275	2026-03-15 19:12:07.243275	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
451	1	5	2026-03-15 19:11:07.243275	2026-03-15 19:15:07.243275	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
452	1	5	2026-03-15 19:11:07.243275	2026-03-15 19:16:07.243275	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
453	1	5	2026-03-15 19:11:07.243275	2026-03-15 19:17:07.243275	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
454	1	5	2026-03-15 19:11:07.243275	2026-03-15 19:20:07.243275	\N	\N	world.player_movement	{"x": 4, "y": 8, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 9}
455	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:11:16.778856	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
456	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:12:16.778856	\N	\N	world.player_movement	{"x": 9, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
457	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:15:16.778856	\N	\N	world.player_movement	{"x": 9, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
458	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:16:16.778856	\N	\N	world.player_movement	{"x": 9, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
459	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:17:16.778856	\N	\N	world.player_movement	{"x": 9, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
460	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:20:16.778856	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
461	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:21:16.778856	\N	\N	world.player_movement	{"x": 9, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
462	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:24:16.778856	\N	\N	world.player_movement	{"x": 10, "y": 10, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 13}
463	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:25:16.778856	\N	\N	world.player_movement	{"x": 10, "y": 11, "mapId": 1, "order": 9, "moveCost": 1, "totalMoveCost": 14}
464	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:26:16.778856	\N	\N	world.player_movement	{"x": 10, "y": 12, "mapId": 1, "order": 10, "moveCost": 3, "totalMoveCost": 15}
465	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:29:16.778856	\N	\N	world.player_movement	{"x": 10, "y": 13, "mapId": 1, "order": 11, "moveCost": 1, "totalMoveCost": 18}
466	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:30:16.778856	\N	\N	world.player_movement	{"x": 11, "y": 14, "mapId": 1, "order": 12, "moveCost": 1, "totalMoveCost": 19}
467	1	5	2026-03-15 19:11:16.778856	2026-03-15 19:31:16.778856	\N	\N	world.player_movement	{"x": 12, "y": 15, "mapId": 1, "order": 13, "moveCost": 3, "totalMoveCost": 20}
468	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:32:49.819371	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
469	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:33:49.819371	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
470	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:36:49.819371	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
471	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:37:49.819371	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
472	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:38:49.819371	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
473	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:41:49.819371	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
474	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:42:49.819371	\N	\N	world.player_movement	{"x": 9, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
475	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:45:49.819371	\N	\N	world.player_movement	{"x": 10, "y": 10, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 13}
476	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:46:49.819371	\N	\N	world.player_movement	{"x": 10, "y": 11, "mapId": 1, "order": 9, "moveCost": 1, "totalMoveCost": 14}
477	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:47:49.819371	\N	\N	world.player_movement	{"x": 9, "y": 12, "mapId": 1, "order": 10, "moveCost": 3, "totalMoveCost": 15}
478	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:50:49.819371	\N	\N	world.player_movement	{"x": 8, "y": 13, "mapId": 1, "order": 11, "moveCost": 1, "totalMoveCost": 18}
479	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:51:49.819371	\N	\N	world.player_movement	{"x": 9, "y": 14, "mapId": 1, "order": 12, "moveCost": 1, "totalMoveCost": 19}
480	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:52:49.819371	\N	\N	world.player_movement	{"x": 8, "y": 15, "mapId": 1, "order": 13, "moveCost": 3, "totalMoveCost": 20}
481	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:55:49.819371	\N	\N	world.player_movement	{"x": 7, "y": 16, "mapId": 1, "order": 14, "moveCost": 1, "totalMoveCost": 23}
482	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:56:49.819371	\N	\N	world.player_movement	{"x": 6, "y": 17, "mapId": 1, "order": 15, "moveCost": 1, "totalMoveCost": 24}
483	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:57:49.819371	\N	\N	world.player_movement	{"x": 5, "y": 17, "mapId": 1, "order": 16, "moveCost": 1, "totalMoveCost": 25}
484	1	5	2026-03-15 19:32:49.819371	2026-03-15 19:58:49.819371	\N	\N	world.player_movement	{"x": 4, "y": 18, "mapId": 1, "order": 17, "moveCost": 1, "totalMoveCost": 26}
485	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:32:53.198216	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
486	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:33:53.198216	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
487	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:36:53.198216	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
488	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:37:53.198216	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
489	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:38:53.198216	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
490	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:41:53.198216	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
491	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:42:53.198216	\N	\N	world.player_movement	{"x": 4, "y": 9, "mapId": 1, "order": 7, "moveCost": 1, "totalMoveCost": 10}
492	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:43:53.198216	\N	\N	world.player_movement	{"x": 3, "y": 9, "mapId": 1, "order": 8, "moveCost": 6, "totalMoveCost": 11}
493	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:49:53.198216	\N	\N	world.player_movement	{"x": 2, "y": 9, "mapId": 1, "order": 9, "moveCost": 1, "totalMoveCost": 17}
494	1	5	2026-03-15 19:32:53.198216	2026-03-15 19:50:53.198216	\N	\N	world.player_movement	{"x": 1, "y": 10, "mapId": 1, "order": 10, "moveCost": 3, "totalMoveCost": 18}
495	1	5	2026-03-15 19:33:02.588564	2026-03-15 19:33:02.588564	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
496	1	5	2026-03-15 19:33:02.588564	2026-03-15 19:34:02.588564	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
497	1	5	2026-03-15 19:33:02.588564	2026-03-15 19:37:02.588564	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
498	1	5	2026-03-15 19:33:02.588564	2026-03-15 19:38:02.588564	\N	\N	world.player_movement	{"x": 6, "y": 5, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 5}
499	1	5	2026-03-15 19:33:02.588564	2026-03-15 19:41:02.588564	\N	\N	world.player_movement	{"x": 5, "y": 4, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 8}
500	1	5	2026-03-15 19:33:02.588564	2026-03-15 19:42:02.588564	\N	\N	world.player_movement	{"x": 4, "y": 5, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
501	1	5	2026-03-15 19:33:02.588564	2026-03-15 19:43:02.588564	\N	\N	world.player_movement	{"x": 3, "y": 5, "mapId": 1, "order": 7, "moveCost": 1, "totalMoveCost": 10}
502	1	5	2026-03-15 19:33:40.037939	2026-03-15 19:33:40.037939	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
503	1	5	2026-03-15 19:33:40.037939	2026-03-15 19:34:40.037939	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
504	1	5	2026-03-15 19:33:40.037939	2026-03-15 19:37:40.037939	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
505	1	5	2026-03-15 19:33:40.037939	2026-03-15 19:38:40.037939	\N	\N	world.player_movement	{"x": 7, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
506	1	5	2026-03-15 19:33:40.037939	2026-03-15 19:39:40.037939	\N	\N	world.player_movement	{"x": 7, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
507	1	5	2026-03-15 19:33:40.037939	2026-03-15 19:42:40.037939	\N	\N	world.player_movement	{"x": 8, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
508	1	5	2026-03-15 19:33:40.037939	2026-03-15 19:43:40.037939	\N	\N	world.player_movement	{"x": 7, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
509	1	5	2026-03-15 21:04:42.964293	2026-03-15 21:04:42.964293	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
510	1	5	2026-03-15 21:04:42.964293	2026-03-15 21:05:42.964293	\N	\N	world.player_movement	{"x": 9, "y": 2, "mapId": 1, "order": 2, "moveCost": 5, "totalMoveCost": 1}
511	1	5	2026-03-15 21:04:42.964293	2026-03-15 21:10:42.964293	\N	\N	world.player_movement	{"x": 8, "y": 1, "mapId": 1, "order": 3, "moveCost": 6, "totalMoveCost": 6}
512	1	5	2026-03-15 21:05:13.126228	2026-03-15 21:05:13.126228	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
513	1	5	2026-03-15 21:05:13.126228	2026-03-15 21:06:13.126228	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 2, "moveCost": 6, "totalMoveCost": 1}
514	1	5	2026-03-15 21:05:13.126228	2026-03-15 21:12:13.126228	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 7}
515	1	5	2026-03-15 21:05:13.126228	2026-03-15 21:13:13.126228	\N	\N	world.player_movement	{"x": 12, "y": 3, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 8}
516	1	5	2026-03-15 21:05:13.126228	2026-03-15 21:14:13.126228	\N	\N	world.player_movement	{"x": 12, "y": 4, "mapId": 1, "order": 5, "moveCost": 6, "totalMoveCost": 9}
517	1	5	2026-03-15 21:05:13.126228	2026-03-15 21:20:13.126228	\N	\N	world.player_movement	{"x": 13, "y": 5, "mapId": 1, "order": 6, "moveCost": 4, "totalMoveCost": 15}
518	1	5	2026-03-15 21:05:13.126228	2026-03-15 21:24:13.126228	\N	\N	world.player_movement	{"x": 14, "y": 6, "mapId": 1, "order": 7, "moveCost": 4, "totalMoveCost": 19}
519	1	5	2026-03-22 10:12:19.978781	2026-03-22 10:12:19.978781	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
520	1	5	2026-03-22 10:12:19.978781	2026-03-22 10:13:19.978781	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
521	1	5	2026-03-22 10:12:19.978781	2026-03-22 10:16:19.978781	\N	\N	world.player_movement	{"x": 8, "y": 5, "mapId": 1, "order": 3, "moveCost": 3, "totalMoveCost": 4}
522	1	5	2026-03-22 10:12:25.734292	2026-03-22 10:12:25.734292	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
523	1	5	2026-03-22 10:12:25.734292	2026-03-22 10:13:25.734292	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
524	1	5	2026-03-22 10:12:25.734292	2026-03-22 10:16:25.734292	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
525	1	5	2026-03-22 10:12:25.734292	2026-03-22 10:17:25.734292	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
526	1	5	2026-03-22 10:12:25.734292	2026-03-22 10:18:25.734292	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
527	1	5	2026-03-22 10:12:25.734292	2026-03-22 10:21:25.734292	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
528	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:12:34.063081	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
529	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:13:34.063081	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
530	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:16:34.063081	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
531	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:17:34.063081	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
532	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:18:34.063081	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
533	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:21:34.063081	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
534	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:22:34.063081	\N	\N	world.player_movement	{"x": 6, "y": 9, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 10}
535	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:25:34.063081	\N	\N	world.player_movement	{"x": 7, "y": 10, "mapId": 1, "order": 8, "moveCost": 1, "totalMoveCost": 13}
536	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:26:34.063081	\N	\N	world.player_movement	{"x": 6, "y": 11, "mapId": 1, "order": 9, "moveCost": 3, "totalMoveCost": 14}
537	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:29:34.063081	\N	\N	world.player_movement	{"x": 5, "y": 11, "mapId": 1, "order": 10, "moveCost": 1, "totalMoveCost": 17}
538	1	5	2026-03-22 10:12:34.063081	2026-03-22 10:30:34.063081	\N	\N	world.player_movement	{"x": 4, "y": 11, "mapId": 1, "order": 11, "moveCost": 3, "totalMoveCost": 18}
539	1	5	2026-03-22 10:12:43.5061	2026-03-22 10:12:43.5061	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
540	1	5	2026-03-22 10:12:43.5061	2026-03-22 10:13:43.5061	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
541	1	5	2026-03-22 10:12:43.5061	2026-03-22 10:16:43.5061	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
542	1	5	2026-03-22 10:12:43.5061	2026-03-22 10:17:43.5061	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
543	1	5	2026-03-22 10:12:43.5061	2026-03-22 10:18:43.5061	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
544	1	5	2026-03-22 10:12:43.5061	2026-03-22 10:21:43.5061	\N	\N	world.player_movement	{"x": 5, "y": 8, "mapId": 1, "order": 6, "moveCost": 1, "totalMoveCost": 9}
545	1	5	2026-03-22 10:12:43.5061	2026-03-22 10:22:43.5061	\N	\N	world.player_movement	{"x": 4, "y": 9, "mapId": 1, "order": 7, "moveCost": 1, "totalMoveCost": 10}
546	1	5	2026-03-22 10:12:50.656567	2026-03-22 10:12:50.656567	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
547	1	5	2026-03-22 10:12:50.656567	2026-03-22 10:13:50.656567	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
548	1	5	2026-03-22 10:12:50.656567	2026-03-22 10:16:50.656567	\N	\N	world.player_movement	{"x": 7, "y": 3, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
549	1	5	2026-03-22 10:12:50.656567	2026-03-22 10:17:50.656567	\N	\N	world.player_movement	{"x": 6, "y": 4, "mapId": 1, "order": 4, "moveCost": 3, "totalMoveCost": 5}
550	1	5	2026-03-22 10:12:50.656567	2026-03-22 10:20:50.656567	\N	\N	world.player_movement	{"x": 5, "y": 4, "mapId": 1, "order": 5, "moveCost": 1, "totalMoveCost": 8}
551	1	5	2026-03-22 10:12:50.656567	2026-03-22 10:21:50.656567	\N	\N	world.player_movement	{"x": 4, "y": 4, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 9}
552	1	5	2026-03-22 10:13:00.398488	2026-03-22 10:13:00.398488	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
553	1	5	2026-03-22 10:13:00.398488	2026-03-22 10:14:00.398488	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
554	1	5	2026-03-22 10:13:00.398488	2026-03-22 10:17:00.398488	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
555	1	5	2026-03-22 10:13:00.398488	2026-03-22 10:18:00.398488	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
556	1	5	2026-03-22 10:13:00.398488	2026-03-22 10:19:00.398488	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
557	1	5	2026-03-22 10:13:00.398488	2026-03-22 10:22:00.398488	\N	\N	world.player_movement	{"x": 4, "y": 7, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 9}
558	1	5	2026-03-22 10:13:00.398488	2026-03-22 10:25:00.398488	\N	\N	world.player_movement	{"x": 3, "y": 7, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 12}
559	1	5	2026-03-22 10:22:07.806937	2026-03-22 10:22:07.806937	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
560	1	5	2026-03-22 10:22:07.806937	2026-03-22 10:23:07.806937	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
561	1	5	2026-03-22 10:22:07.806937	2026-03-22 10:26:07.806937	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
562	1	5	2026-03-22 10:22:07.806937	2026-03-22 10:27:07.806937	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
563	1	5	2026-03-22 10:22:07.806937	2026-03-22 10:28:07.806937	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
564	1	5	2026-03-22 10:22:07.806937	2026-03-22 10:31:07.806937	\N	\N	world.player_movement	{"x": 4, "y": 7, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 9}
565	1	5	2026-03-22 10:22:07.806937	2026-03-22 10:34:07.806937	\N	\N	world.player_movement	{"x": 3, "y": 7, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 12}
566	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:26:20.154301	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
567	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:27:20.154301	\N	\N	world.player_movement	{"x": 8, "y": 4, "mapId": 1, "order": 2, "moveCost": 3, "totalMoveCost": 1}
568	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:30:20.154301	\N	\N	world.player_movement	{"x": 7, "y": 5, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 4}
569	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:31:20.154301	\N	\N	world.player_movement	{"x": 6, "y": 6, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 5}
570	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:32:20.154301	\N	\N	world.player_movement	{"x": 5, "y": 7, "mapId": 1, "order": 5, "moveCost": 3, "totalMoveCost": 6}
571	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:35:20.154301	\N	\N	world.player_movement	{"x": 4, "y": 8, "mapId": 1, "order": 6, "moveCost": 3, "totalMoveCost": 9}
572	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:38:20.154301	\N	\N	world.player_movement	{"x": 3, "y": 7, "mapId": 1, "order": 7, "moveCost": 3, "totalMoveCost": 12}
573	1	5	2026-03-22 10:26:20.154301	2026-03-22 10:41:20.154301	\N	\N	world.player_movement	{"x": 2, "y": 8, "mapId": 1, "order": 8, "moveCost": 12, "totalMoveCost": 15}
574	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:18:35.825065	\N	\N	world.player_movement	{"x": 9, "y": 3, "mapId": 1, "order": 1, "moveCost": 1, "totalMoveCost": 0}
575	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:19:35.825065	\N	\N	world.player_movement	{"x": 10, "y": 3, "mapId": 1, "order": 2, "moveCost": 6, "totalMoveCost": 1}
576	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:25:35.825065	\N	\N	world.player_movement	{"x": 11, "y": 2, "mapId": 1, "order": 3, "moveCost": 1, "totalMoveCost": 7}
577	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:26:35.825065	\N	\N	world.player_movement	{"x": 12, "y": 3, "mapId": 1, "order": 4, "moveCost": 1, "totalMoveCost": 8}
578	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:27:35.825065	\N	\N	world.player_movement	{"x": 12, "y": 4, "mapId": 1, "order": 5, "moveCost": 6, "totalMoveCost": 9}
579	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:33:35.825065	\N	\N	world.player_movement	{"x": 13, "y": 5, "mapId": 1, "order": 6, "moveCost": 4, "totalMoveCost": 15}
580	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:37:35.825065	\N	\N	world.player_movement	{"x": 14, "y": 6, "mapId": 1, "order": 7, "moveCost": 4, "totalMoveCost": 19}
581	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:41:35.825065	\N	\N	world.player_movement	{"x": 15, "y": 7, "mapId": 1, "order": 8, "moveCost": 4, "totalMoveCost": 23}
582	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:45:35.825065	\N	\N	world.player_movement	{"x": 16, "y": 8, "mapId": 1, "order": 9, "moveCost": 4, "totalMoveCost": 27}
583	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:49:35.825065	\N	\N	world.player_movement	{"x": 17, "y": 9, "mapId": 1, "order": 10, "moveCost": 4, "totalMoveCost": 31}
584	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:53:35.825065	\N	\N	world.player_movement	{"x": 18, "y": 10, "mapId": 1, "order": 11, "moveCost": 4, "totalMoveCost": 35}
585	1	1	2026-03-23 11:18:35.825065	2026-03-23 11:57:35.825065	\N	\N	world.player_movement	{"x": 19, "y": 11, "mapId": 1, "order": 12, "moveCost": 3, "totalMoveCost": 39}
586	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:00:35.825065	\N	\N	world.player_movement	{"x": 19, "y": 12, "mapId": 1, "order": 13, "moveCost": 3, "totalMoveCost": 42}
587	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:03:35.825065	\N	\N	world.player_movement	{"x": 19, "y": 13, "mapId": 1, "order": 14, "moveCost": 1, "totalMoveCost": 45}
588	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:04:35.825065	\N	\N	world.player_movement	{"x": 19, "y": 14, "mapId": 1, "order": 15, "moveCost": 3, "totalMoveCost": 46}
589	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:07:35.825065	\N	\N	world.player_movement	{"x": 18, "y": 15, "mapId": 1, "order": 16, "moveCost": 1, "totalMoveCost": 49}
590	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:08:35.825065	\N	\N	world.player_movement	{"x": 19, "y": 16, "mapId": 1, "order": 17, "moveCost": 1, "totalMoveCost": 50}
591	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:09:35.825065	\N	\N	world.player_movement	{"x": 20, "y": 17, "mapId": 1, "order": 18, "moveCost": 3, "totalMoveCost": 51}
592	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:12:35.825065	\N	\N	world.player_movement	{"x": 21, "y": 18, "mapId": 1, "order": 19, "moveCost": 3, "totalMoveCost": 54}
593	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:15:35.825065	\N	\N	world.player_movement	{"x": 22, "y": 19, "mapId": 1, "order": 20, "moveCost": 3, "totalMoveCost": 57}
594	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:18:35.825065	\N	\N	world.player_movement	{"x": 23, "y": 19, "mapId": 1, "order": 21, "moveCost": 1, "totalMoveCost": 60}
595	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:19:35.825065	\N	\N	world.player_movement	{"x": 24, "y": 20, "mapId": 1, "order": 22, "moveCost": 3, "totalMoveCost": 61}
596	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:22:35.825065	\N	\N	world.player_movement	{"x": 25, "y": 21, "mapId": 1, "order": 23, "moveCost": 3, "totalMoveCost": 64}
597	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:25:35.825065	\N	\N	world.player_movement	{"x": 26, "y": 22, "mapId": 1, "order": 24, "moveCost": 3, "totalMoveCost": 67}
598	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:28:35.825065	\N	\N	world.player_movement	{"x": 27, "y": 23, "mapId": 1, "order": 25, "moveCost": 3, "totalMoveCost": 70}
599	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:31:35.825065	\N	\N	world.player_movement	{"x": 28, "y": 24, "mapId": 1, "order": 26, "moveCost": 1, "totalMoveCost": 73}
600	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:32:35.825065	\N	\N	world.player_movement	{"x": 29, "y": 25, "mapId": 1, "order": 27, "moveCost": 1, "totalMoveCost": 74}
601	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:33:35.825065	\N	\N	world.player_movement	{"x": 30, "y": 26, "mapId": 1, "order": 28, "moveCost": 3, "totalMoveCost": 75}
602	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:36:35.825065	\N	\N	world.player_movement	{"x": 31, "y": 27, "mapId": 1, "order": 29, "moveCost": 3, "totalMoveCost": 78}
603	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:39:35.825065	\N	\N	world.player_movement	{"x": 31, "y": 28, "mapId": 1, "order": 30, "moveCost": 3, "totalMoveCost": 81}
604	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:42:35.825065	\N	\N	world.player_movement	{"x": 32, "y": 29, "mapId": 1, "order": 31, "moveCost": 3, "totalMoveCost": 84}
605	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:45:35.825065	\N	\N	world.player_movement	{"x": 33, "y": 30, "mapId": 1, "order": 32, "moveCost": 3, "totalMoveCost": 87}
606	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:48:35.825065	\N	\N	world.player_movement	{"x": 34, "y": 31, "mapId": 1, "order": 33, "moveCost": 1, "totalMoveCost": 90}
607	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:49:35.825065	\N	\N	world.player_movement	{"x": 35, "y": 32, "mapId": 1, "order": 34, "moveCost": 1, "totalMoveCost": 91}
608	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:50:35.825065	\N	\N	world.player_movement	{"x": 36, "y": 33, "mapId": 1, "order": 35, "moveCost": 3, "totalMoveCost": 92}
609	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:53:35.825065	\N	\N	world.player_movement	{"x": 37, "y": 32, "mapId": 1, "order": 36, "moveCost": 1, "totalMoveCost": 95}
610	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:54:35.825065	\N	\N	world.player_movement	{"x": 38, "y": 32, "mapId": 1, "order": 37, "moveCost": 1, "totalMoveCost": 96}
611	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:55:35.825065	\N	\N	world.player_movement	{"x": 39, "y": 33, "mapId": 1, "order": 38, "moveCost": 1, "totalMoveCost": 97}
612	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:56:35.825065	\N	\N	world.player_movement	{"x": 40, "y": 34, "mapId": 1, "order": 39, "moveCost": 1, "totalMoveCost": 98}
613	1	1	2026-03-23 11:18:35.825065	2026-03-23 12:57:35.825065	\N	\N	world.player_movement	{"x": 40, "y": 35, "mapId": 1, "order": 40, "moveCost": 3, "totalMoveCost": 99}
614	1	1	2026-03-23 11:18:35.825065	2026-03-23 13:00:35.825065	\N	\N	world.player_movement	{"x": 41, "y": 36, "mapId": 1, "order": 41, "moveCost": 1, "totalMoveCost": 102}
615	1	1	2026-03-23 11:18:35.825065	2026-03-23 13:01:35.825065	\N	\N	world.player_movement	{"x": 42, "y": 37, "mapId": 1, "order": 42, "moveCost": 1, "totalMoveCost": 103}
616	1	1	2026-03-23 11:18:35.825065	2026-03-23 13:02:35.825065	\N	\N	world.player_movement	{"x": 43, "y": 37, "mapId": 1, "order": 43, "moveCost": 1, "totalMoveCost": 104}
617	1	1	2026-03-23 11:18:35.825065	2026-03-23 13:03:35.825065	\N	\N	world.player_movement	{"x": 44, "y": 36, "mapId": 1, "order": 44, "moveCost": 1, "totalMoveCost": 105}
618	1	1	2026-03-23 11:18:35.825065	2026-03-23 13:04:35.825065	\N	\N	world.player_movement	{"x": 45, "y": 37, "mapId": 1, "order": 45, "moveCost": 1, "totalMoveCost": 106}
619	1	1	2026-03-23 11:18:35.825065	2026-03-23 13:05:35.825065	\N	\N	world.player_movement	{"x": 45, "y": 38, "mapId": 1, "order": 46, "moveCost": 3, "totalMoveCost": 107}
\.


--
-- TOC entry 5465 (class 0 OID 22599)
-- Dependencies: 247
-- Data for Name: landscape_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.landscape_types (id, name, move_cost, image_url) FROM stdin;
1	Forest	2	forest.png
2	Mountain	5	mountain.png
3	Volcano	5	volcano.png
6	Jungle	3	jungle.png
7	Dunes	5	dunes.png
8	Swamp	6	swamp.png
5	Forest Savanna	1	forest_savanna.png
4	Volcano Activated	10	volcano_activated.png
9	Hills	2	hills.png
\.


--
-- TOC entry 5514 (class 0 OID 22798)
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
\.


--
-- TOC entry 5466 (class 0 OID 22607)
-- Dependencies: 248
-- Data for Name: map_tiles; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles (map_id, x, y, terrain_type_id, landscape_type_id) FROM stdin;
1	1	1	2	1
1	2	1	2	1
1	3	1	2	1
1	4	1	2	\N
1	5	1	2	\N
1	6	1	9	\N
1	7	1	6	\N
1	8	1	3	2
1	9	1	3	3
1	10	1	3	\N
1	11	1	3	2
1	12	1	5	8
1	13	1	5	6
1	14	1	5	8
1	15	1	5	8
1	16	1	1	1
1	17	1	8	\N
1	18	1	2	1
1	19	1	2	1
1	20	1	2	\N
1	21	1	2	1
1	22	1	2	1
1	23	1	7	\N
1	24	1	7	\N
1	25	1	7	\N
1	26	1	7	\N
1	27	1	7	\N
1	28	1	2	1
1	29	1	5	\N
1	30	1	5	8
1	31	1	9	\N
1	32	1	4	7
1	33	1	4	7
1	34	1	4	\N
1	35	1	4	7
1	36	1	4	\N
1	37	1	4	\N
1	38	1	4	7
1	39	1	4	7
1	40	1	4	7
1	41	1	4	7
1	42	1	4	7
1	43	1	4	7
1	44	1	4	7
1	45	1	4	7
1	46	1	4	7
1	47	1	4	7
1	48	1	4	\N
1	49	1	4	7
1	50	1	4	\N
1	51	1	3	3
1	52	1	5	\N
1	53	1	5	6
1	54	1	9	\N
1	55	1	3	2
1	56	1	3	2
1	57	1	3	2
1	58	1	3	3
1	59	1	3	\N
1	60	1	3	2
1	1	2	2	\N
1	2	2	6	\N
1	3	2	2	1
1	4	2	9	\N
1	5	2	2	1
1	6	2	2	1
1	7	2	2	1
1	8	2	3	2
1	9	2	6	\N
1	10	2	3	2
1	11	2	3	\N
1	12	2	3	\N
1	13	2	5	\N
1	14	2	5	8
1	15	2	5	\N
1	16	2	5	6
1	17	2	1	\N
1	18	2	1	1
1	19	2	2	\N
1	20	2	2	1
1	21	2	2	1
1	22	2	2	1
1	23	2	2	\N
1	24	2	4	7
1	25	2	1	\N
1	26	2	6	\N
1	27	2	7	\N
1	28	2	5	8
1	29	2	5	8
1	30	2	2	1
1	31	2	9	\N
1	32	2	9	\N
1	33	2	4	7
1	34	2	4	\N
1	35	2	4	\N
1	36	2	4	7
1	37	2	4	7
1	38	2	5	8
1	39	2	4	7
1	40	2	5	6
1	41	2	4	7
1	42	2	4	7
1	43	2	6	\N
1	44	2	4	\N
1	45	2	5	\N
1	46	2	4	7
1	47	2	4	\N
1	48	2	4	7
1	49	2	7	\N
1	50	2	4	7
1	51	2	4	7
1	52	2	5	8
1	53	2	5	6
1	54	2	5	\N
1	55	2	3	2
1	56	2	2	1
1	57	2	3	2
1	58	2	3	2
1	59	2	3	2
1	60	2	3	2
1	1	3	2	\N
1	2	3	2	1
1	3	3	2	1
1	4	3	2	\N
1	5	3	2	1
1	6	3	2	1
1	7	3	2	\N
1	8	3	2	1
1	9	3	3	\N
1	10	3	3	2
1	11	3	3	3
1	12	3	3	\N
1	13	3	3	3
1	14	3	1	9
1	15	3	6	\N
1	16	3	5	\N
1	17	3	5	8
1	18	3	1	9
1	19	3	1	9
1	20	3	2	1
1	21	3	2	\N
1	22	3	2	1
1	23	3	2	\N
1	24	3	2	1
1	25	3	1	\N
1	26	3	1	9
1	27	3	9	\N
1	28	3	5	6
1	29	3	5	8
1	30	3	5	8
1	31	3	2	\N
1	32	3	2	1
1	33	3	4	7
1	34	3	3	3
1	35	3	4	7
1	36	3	2	1
1	37	3	4	\N
1	38	3	4	\N
1	39	3	4	\N
1	40	3	4	7
1	41	3	4	7
1	42	3	1	1
1	43	3	4	7
1	44	3	4	7
1	45	3	7	\N
1	46	3	4	7
1	47	3	4	\N
1	48	3	4	7
1	49	3	2	1
1	50	3	4	7
1	51	3	6	\N
1	52	3	4	7
1	53	3	9	\N
1	54	3	5	8
1	55	3	5	8
1	56	3	3	\N
1	57	3	3	2
1	58	3	3	\N
1	59	3	4	7
1	60	3	3	2
1	1	4	2	1
1	2	4	4	7
1	3	4	2	1
1	4	4	2	1
1	5	4	2	\N
1	6	4	2	1
1	7	4	5	\N
1	8	4	2	1
1	9	4	2	1
1	10	4	3	2
1	11	4	9	\N
1	12	4	3	3
1	13	4	9	\N
1	14	4	9	\N
1	15	4	9	\N
1	16	4	9	\N
1	17	4	5	8
1	18	4	1	9
1	19	4	1	9
1	20	4	1	\N
1	21	4	2	\N
1	22	4	2	1
1	23	4	6	\N
1	24	4	2	\N
1	25	4	1	\N
1	26	4	1	\N
1	27	4	1	1
1	28	4	5	8
1	29	4	5	\N
1	30	4	5	\N
1	31	4	5	8
1	32	4	9	\N
1	33	4	9	\N
1	34	4	9	\N
1	35	4	7	\N
1	36	4	9	\N
1	37	4	9	\N
1	38	4	9	\N
1	39	4	9	\N
1	40	4	9	\N
1	41	4	9	\N
1	42	4	9	\N
1	43	4	4	7
1	44	4	3	3
1	45	4	4	7
1	46	4	1	1
1	47	4	4	7
1	48	4	4	7
1	49	4	4	\N
1	50	4	4	7
1	51	4	4	\N
1	52	4	4	7
1	53	4	4	7
1	54	4	5	\N
1	55	4	9	\N
1	56	4	3	3
1	57	4	3	3
1	58	4	2	1
1	59	4	1	\N
1	60	4	1	9
1	1	5	2	1
1	2	5	2	\N
1	3	5	2	\N
1	4	5	2	\N
1	5	5	4	\N
1	6	5	2	1
1	7	5	2	\N
1	8	5	2	1
1	9	5	2	\N
1	10	5	5	\N
1	11	5	9	\N
1	12	5	9	\N
1	13	5	7	\N
1	14	5	7	\N
1	15	5	7	\N
1	16	5	5	\N
1	17	5	7	\N
1	18	5	7	\N
1	19	5	6	\N
1	20	5	1	\N
1	21	5	1	9
1	22	5	2	1
1	23	5	2	1
1	24	5	2	\N
1	25	5	9	\N
1	26	5	1	9
1	27	5	1	1
1	28	5	1	1
1	29	5	5	6
1	30	5	5	6
1	31	5	5	8
1	32	5	9	\N
1	33	5	6	\N
1	34	5	6	\N
1	35	5	6	\N
1	36	5	6	\N
1	37	5	6	\N
1	38	5	9	\N
1	39	5	7	\N
1	40	5	9	\N
1	41	5	9	\N
1	42	5	9	\N
1	43	5	3	\N
1	44	5	3	\N
1	45	5	1	9
1	46	5	1	1
1	47	5	9	\N
1	48	5	4	7
1	49	5	4	7
1	50	5	4	\N
1	51	5	4	\N
1	52	5	9	\N
1	53	5	9	\N
1	54	5	9	\N
1	55	5	3	2
1	56	5	3	3
1	57	5	3	3
1	58	5	3	3
1	59	5	1	1
1	60	5	1	\N
1	1	6	2	1
1	2	6	2	1
1	3	6	2	1
1	4	6	2	1
1	5	6	3	3
1	6	6	2	\N
1	7	6	2	\N
1	8	6	2	1
1	9	6	2	\N
1	10	6	8	\N
1	11	6	8	\N
1	12	6	8	\N
1	13	6	7	\N
1	14	6	7	\N
1	15	6	6	\N
1	16	6	7	\N
1	17	6	7	\N
1	18	6	7	\N
1	19	6	7	\N
1	20	6	6	\N
1	21	6	1	1
1	22	6	1	9
1	23	6	2	1
1	24	6	2	1
1	25	6	2	1
1	26	6	1	\N
1	27	6	6	\N
1	28	6	1	1
1	29	6	1	\N
1	30	6	5	\N
1	31	6	5	\N
1	32	6	9	\N
1	33	6	9	\N
1	34	6	9	\N
1	35	6	6	\N
1	36	6	6	\N
1	37	6	5	\N
1	38	6	5	6
1	39	6	1	\N
1	40	6	9	\N
1	41	6	4	7
1	42	6	5	6
1	43	6	3	3
1	44	6	3	\N
1	45	6	5	\N
1	46	6	1	\N
1	47	6	1	\N
1	48	6	4	7
1	49	6	4	7
1	50	6	4	7
1	51	6	4	7
1	52	6	4	7
1	53	6	4	7
1	54	6	9	\N
1	55	6	9	\N
1	56	6	9	\N
1	57	6	3	2
1	58	6	2	1
1	59	6	1	\N
1	60	6	1	\N
1	1	7	2	1
1	2	7	2	1
1	3	7	2	1
1	4	7	2	1
1	5	7	2	1
1	6	7	2	1
1	7	7	2	1
1	8	7	6	\N
1	9	7	2	1
1	10	7	7	\N
1	11	7	8	\N
1	12	7	8	\N
1	13	7	8	\N
1	14	7	7	\N
1	15	7	7	\N
1	16	7	7	\N
1	17	7	7	\N
1	18	7	7	\N
1	19	7	7	\N
1	20	7	7	\N
1	21	7	1	9
1	22	7	1	9
1	23	7	1	9
1	24	7	2	\N
1	25	7	2	1
1	26	7	2	\N
1	27	7	1	1
1	28	7	1	\N
1	29	7	1	\N
1	30	7	1	1
1	31	7	5	8
1	32	7	9	\N
1	33	7	9	\N
1	34	7	9	\N
1	35	7	6	\N
1	36	7	6	\N
1	37	7	1	1
1	38	7	1	1
1	39	7	1	\N
1	40	7	1	\N
1	41	7	1	1
1	42	7	4	\N
1	43	7	3	\N
1	44	7	3	\N
1	45	7	3	3
1	46	7	1	9
1	47	7	1	9
1	48	7	5	\N
1	49	7	4	7
1	50	7	4	7
1	51	7	4	7
1	52	7	4	7
1	53	7	4	\N
1	54	7	9	\N
1	55	7	3	2
1	56	7	9	\N
1	57	7	9	\N
1	58	7	1	1
1	59	7	1	1
1	60	7	1	\N
1	1	8	2	\N
1	2	8	5	8
1	3	8	3	3
1	4	8	2	1
1	5	8	2	\N
1	6	8	2	1
1	7	8	2	1
1	8	8	2	\N
1	9	8	2	1
1	10	8	2	1
1	11	8	8	\N
1	12	8	8	\N
1	13	8	8	\N
1	14	8	8	\N
1	15	8	8	\N
1	16	8	7	\N
1	17	8	7	\N
1	18	8	2	1
1	19	8	7	\N
1	20	8	7	\N
1	21	8	1	9
1	22	8	1	1
1	23	8	1	\N
1	24	8	1	\N
1	25	8	2	\N
1	26	8	2	1
1	27	8	1	9
1	28	8	1	9
1	29	8	1	1
1	30	8	5	8
1	31	8	5	6
1	32	8	5	6
1	33	8	9	\N
1	34	8	6	\N
1	35	8	6	\N
1	36	8	6	\N
1	37	8	1	9
1	38	8	1	\N
1	39	8	1	9
1	40	8	1	\N
1	41	8	1	\N
1	42	8	1	\N
1	43	8	3	2
1	44	8	4	7
1	45	8	3	3
1	46	8	1	1
1	47	8	1	\N
1	48	8	1	\N
1	49	8	4	7
1	50	8	4	\N
1	51	8	4	7
1	52	8	4	7
1	53	8	4	\N
1	54	8	9	\N
1	55	8	9	\N
1	56	8	3	3
1	57	8	1	1
1	58	8	1	\N
1	59	8	1	9
1	60	8	9	\N
1	1	9	2	1
1	2	9	3	\N
1	3	9	3	2
1	4	9	2	\N
1	5	9	2	\N
1	6	9	2	1
1	7	9	1	1
1	8	9	2	1
1	9	9	2	1
1	10	9	2	1
1	11	9	8	\N
1	12	9	8	\N
1	13	9	8	\N
1	14	9	8	\N
1	15	9	8	\N
1	16	9	8	\N
1	17	9	7	\N
1	18	9	7	\N
1	19	9	9	\N
1	20	9	9	\N
1	21	9	9	\N
1	22	9	9	\N
1	23	9	3	\N
1	24	9	1	\N
1	25	9	1	\N
1	26	9	4	7
1	27	9	1	9
1	28	9	1	9
1	29	9	1	\N
1	30	9	1	1
1	31	9	5	\N
1	32	9	5	\N
1	33	9	9	\N
1	34	9	6	\N
1	35	9	6	\N
1	36	9	6	\N
1	37	9	1	\N
1	38	9	1	\N
1	39	9	1	\N
1	40	9	1	\N
1	41	9	1	\N
1	42	9	1	\N
1	43	9	6	\N
1	44	9	2	\N
1	45	9	1	\N
1	46	9	1	\N
1	47	9	1	9
1	48	9	9	\N
1	49	9	9	\N
1	50	9	9	\N
1	51	9	9	\N
1	52	9	5	6
1	53	9	4	7
1	54	9	9	\N
1	55	9	3	3
1	56	9	3	3
1	57	9	4	7
1	58	9	1	\N
1	59	9	3	\N
1	60	9	9	\N
1	1	10	2	1
1	2	10	6	\N
1	3	10	9	\N
1	4	10	9	\N
1	5	10	9	\N
1	6	10	9	\N
1	7	10	2	\N
1	8	10	2	1
1	9	10	2	1
1	10	10	3	\N
1	11	10	8	\N
1	12	10	8	\N
1	13	10	8	\N
1	14	10	1	\N
1	15	10	8	\N
1	16	10	8	\N
1	17	10	7	\N
1	18	10	7	\N
1	19	10	1	1
1	20	10	9	\N
1	21	10	4	7
1	22	10	3	2
1	23	10	3	3
1	24	10	5	8
1	25	10	1	\N
1	26	10	1	\N
1	27	10	1	9
1	28	10	1	9
1	29	10	9	\N
1	30	10	9	\N
1	31	10	5	\N
1	32	10	5	\N
1	33	10	9	\N
1	34	10	9	\N
1	35	10	6	\N
1	36	10	6	\N
1	37	10	1	\N
1	38	10	1	1
1	39	10	1	9
1	40	10	1	\N
1	41	10	1	\N
1	42	10	5	6
1	43	10	5	6
1	44	10	1	9
1	45	10	1	\N
1	46	10	1	1
1	47	10	1	\N
1	48	10	1	9
1	49	10	9	\N
1	50	10	3	2
1	51	10	9	\N
1	52	10	4	\N
1	53	10	4	7
1	54	10	9	\N
1	55	10	3	2
1	56	10	6	\N
1	57	10	1	1
1	58	10	1	9
1	59	10	1	1
1	60	10	9	\N
1	1	11	2	\N
1	2	11	2	1
1	3	11	9	\N
1	4	11	2	1
1	5	11	2	\N
1	6	11	2	1
1	7	11	2	1
1	8	11	2	1
1	9	11	4	\N
1	10	11	2	\N
1	11	11	8	\N
1	12	11	8	\N
1	13	11	8	\N
1	14	11	8	\N
1	15	11	8	\N
1	16	11	8	\N
1	17	11	8	\N
1	18	11	7	\N
1	19	11	2	1
1	20	11	1	1
1	21	11	1	\N
1	22	11	3	3
1	23	11	4	\N
1	24	11	3	2
1	25	11	1	9
1	26	11	1	9
1	27	11	1	9
1	28	11	1	\N
1	29	11	7	\N
1	30	11	5	6
1	31	11	5	\N
1	32	11	5	6
1	33	11	5	8
1	34	11	9	\N
1	35	11	9	\N
1	36	11	9	\N
1	37	11	9	\N
1	38	11	9	\N
1	39	11	9	\N
1	40	11	9	\N
1	41	11	1	1
1	42	11	1	1
1	43	11	1	9
1	44	11	1	1
1	45	11	7	\N
1	46	11	9	\N
1	47	11	1	9
1	48	11	1	9
1	49	11	9	\N
1	50	11	4	7
1	51	11	3	\N
1	52	11	4	7
1	53	11	2	1
1	54	11	2	1
1	55	11	4	7
1	56	11	1	1
1	57	11	1	\N
1	58	11	1	1
1	59	11	1	9
1	60	11	9	\N
1	1	12	2	1
1	2	12	2	\N
1	3	12	9	\N
1	4	12	2	1
1	5	12	2	\N
1	6	12	2	\N
1	7	12	2	1
1	8	12	2	1
1	9	12	2	1
1	10	12	2	1
1	11	12	8	\N
1	12	12	8	\N
1	13	12	5	6
1	14	12	8	\N
1	15	12	8	\N
1	16	12	8	\N
1	17	12	8	\N
1	18	12	2	1
1	19	12	2	1
1	20	12	3	2
1	21	12	1	9
1	22	12	1	1
1	23	12	3	2
1	24	12	3	2
1	25	12	1	9
1	26	12	9	\N
1	27	12	9	\N
1	28	12	9	\N
1	29	12	9	\N
1	30	12	9	\N
1	31	12	9	\N
1	32	12	9	\N
1	33	12	9	\N
1	34	12	5	\N
1	35	12	1	9
1	36	12	9	\N
1	37	12	7	\N
1	38	12	7	\N
1	39	12	9	\N
1	40	12	3	\N
1	41	12	1	1
1	42	12	1	9
1	43	12	5	\N
1	44	12	1	1
1	45	12	1	9
1	46	12	1	1
1	47	12	1	9
1	48	12	1	\N
1	49	12	1	9
1	50	12	1	1
1	51	12	4	7
1	52	12	4	\N
1	53	12	4	7
1	54	12	2	\N
1	55	12	2	\N
1	56	12	1	9
1	57	12	1	1
1	58	12	1	1
1	59	12	1	1
1	60	12	1	1
1	1	13	3	2
1	2	13	2	1
1	3	13	7	\N
1	4	13	2	1
1	5	13	2	1
1	6	13	2	1
1	7	13	2	1
1	8	13	2	\N
1	9	13	2	1
1	10	13	2	\N
1	11	13	6	\N
1	12	13	8	\N
1	13	13	8	\N
1	14	13	8	\N
1	15	13	8	\N
1	16	13	8	\N
1	17	13	8	\N
1	18	13	2	1
1	19	13	2	\N
1	20	13	2	1
1	21	13	1	1
1	22	13	9	\N
1	23	13	9	\N
1	24	13	3	2
1	25	13	3	2
1	26	13	1	1
1	27	13	9	\N
1	28	13	3	2
1	29	13	5	8
1	30	13	9	\N
1	31	13	9	\N
1	32	13	3	\N
1	33	13	3	\N
1	34	13	3	3
1	35	13	1	1
1	36	13	4	7
1	37	13	7	\N
1	38	13	7	\N
1	39	13	9	\N
1	40	13	9	\N
1	41	13	1	9
1	42	13	8	\N
1	43	13	1	1
1	44	13	1	1
1	45	13	1	9
1	46	13	1	\N
1	47	13	3	3
1	48	13	2	\N
1	49	13	1	1
1	50	13	1	9
1	51	13	1	1
1	52	13	4	7
1	53	13	4	7
1	54	13	2	1
1	55	13	2	1
1	56	13	1	\N
1	57	13	1	1
1	58	13	1	9
1	59	13	3	\N
1	60	13	1	9
1	1	14	5	8
1	2	14	2	1
1	3	14	2	1
1	4	14	2	1
1	5	14	2	1
1	6	14	2	1
1	7	14	2	1
1	8	14	2	1
1	9	14	2	\N
1	10	14	2	1
1	11	14	1	\N
1	12	14	1	\N
1	13	14	8	\N
1	14	14	8	\N
1	15	14	8	\N
1	16	14	8	\N
1	17	14	8	\N
1	18	14	2	1
1	19	14	2	1
1	20	14	2	1
1	21	14	2	1
1	22	14	9	\N
1	23	14	3	3
1	24	14	5	6
1	25	14	3	3
1	26	14	3	3
1	27	14	9	\N
1	28	14	9	\N
1	29	14	9	\N
1	30	14	5	\N
1	31	14	3	2
1	32	14	3	2
1	33	14	3	3
1	34	14	3	\N
1	35	14	3	2
1	36	14	1	9
1	37	14	7	\N
1	38	14	7	\N
1	39	14	9	\N
1	40	14	1	9
1	41	14	1	1
1	42	14	1	\N
1	43	14	1	1
1	44	14	1	1
1	45	14	1	9
1	46	14	1	\N
1	47	14	1	9
1	48	14	7	\N
1	49	14	1	1
1	50	14	7	\N
1	51	14	1	9
1	52	14	2	\N
1	53	14	4	7
1	54	14	1	\N
1	55	14	1	\N
1	56	14	1	1
1	57	14	1	1
1	58	14	1	\N
1	59	14	1	1
1	60	14	1	9
1	1	15	2	1
1	2	15	2	\N
1	3	15	2	1
1	4	15	2	1
1	5	15	2	\N
1	6	15	2	1
1	7	15	2	1
1	8	15	2	1
1	9	15	2	1
1	10	15	2	\N
1	11	15	5	6
1	12	15	1	9
1	13	15	8	\N
1	14	15	8	\N
1	15	15	8	\N
1	16	15	8	\N
1	17	15	8	\N
1	18	15	2	\N
1	19	15	6	\N
1	20	15	2	1
1	21	15	2	1
1	22	15	1	\N
1	23	15	1	\N
1	24	15	3	2
1	25	15	3	\N
1	26	15	3	\N
1	27	15	9	\N
1	28	15	9	\N
1	29	15	5	8
1	30	15	5	\N
1	31	15	3	2
1	32	15	3	2
1	33	15	3	\N
1	34	15	7	\N
1	35	15	9	\N
1	36	15	9	\N
1	37	15	9	\N
1	38	15	9	\N
1	39	15	9	\N
1	40	15	7	\N
1	41	15	6	\N
1	42	15	3	2
1	43	15	1	1
1	44	15	1	\N
1	45	15	1	\N
1	46	15	1	\N
1	47	15	1	\N
1	48	15	1	\N
1	49	15	1	1
1	50	15	1	1
1	51	15	1	1
1	52	15	5	6
1	53	15	9	\N
1	54	15	9	\N
1	55	15	1	9
1	56	15	9	\N
1	57	15	1	\N
1	58	15	1	1
1	59	15	1	1
1	60	15	1	1
1	1	16	2	1
1	2	16	2	\N
1	3	16	2	1
1	4	16	2	\N
1	5	16	2	1
1	6	16	9	\N
1	7	16	2	\N
1	8	16	2	\N
1	9	16	9	\N
1	10	16	9	\N
1	11	16	9	\N
1	12	16	8	\N
1	13	16	8	\N
1	14	16	8	\N
1	15	16	8	\N
1	16	16	8	\N
1	17	16	8	\N
1	18	16	8	\N
1	19	16	2	\N
1	20	16	2	1
1	21	16	2	1
1	22	16	1	1
1	23	16	4	7
1	24	16	3	2
1	25	16	3	3
1	26	16	3	2
1	27	16	9	\N
1	28	16	5	8
1	29	16	5	6
1	30	16	1	9
1	31	16	2	1
1	32	16	3	\N
1	33	16	3	2
1	34	16	3	2
1	35	16	9	\N
1	36	16	6	\N
1	37	16	4	7
1	38	16	4	7
1	39	16	9	\N
1	40	16	6	\N
1	41	16	6	\N
1	42	16	6	\N
1	43	16	1	\N
1	44	16	4	7
1	45	16	1	9
1	46	16	1	1
1	47	16	1	9
1	48	16	1	\N
1	49	16	3	\N
1	50	16	1	1
1	51	16	1	\N
1	52	16	1	1
1	53	16	9	\N
1	54	16	1	\N
1	55	16	1	1
1	56	16	9	\N
1	57	16	1	9
1	58	16	1	9
1	59	16	1	\N
1	60	16	1	1
1	1	17	2	1
1	2	17	2	1
1	3	17	2	1
1	4	17	2	\N
1	5	17	2	\N
1	6	17	2	\N
1	7	17	2	1
1	8	17	2	1
1	9	17	9	\N
1	10	17	9	\N
1	11	17	7	\N
1	12	17	8	\N
1	13	17	8	\N
1	14	17	8	\N
1	15	17	8	\N
1	16	17	8	\N
1	17	17	8	\N
1	18	17	8	\N
1	19	17	8	\N
1	20	17	2	1
1	21	17	2	1
1	22	17	2	1
1	23	17	9	\N
1	24	17	3	3
1	25	17	3	2
1	26	17	3	3
1	27	17	9	\N
1	28	17	9	\N
1	29	17	9	\N
1	30	17	9	\N
1	31	17	9	\N
1	32	17	4	7
1	33	17	3	2
1	34	17	3	\N
1	35	17	9	\N
1	36	17	4	\N
1	37	17	4	7
1	38	17	4	7
1	39	17	9	\N
1	40	17	6	\N
1	41	17	6	\N
1	42	17	4	7
1	43	17	4	7
1	44	17	7	\N
1	45	17	1	9
1	46	17	1	1
1	47	17	1	9
1	48	17	1	\N
1	49	17	1	\N
1	50	17	1	9
1	51	17	1	\N
1	52	17	1	9
1	53	17	9	\N
1	54	17	9	\N
1	55	17	1	\N
1	56	17	1	9
1	57	17	1	1
1	58	17	1	9
1	59	17	1	9
1	60	17	1	9
1	1	18	2	\N
1	2	18	3	3
1	3	18	2	1
1	4	18	2	\N
1	5	18	2	1
1	6	18	2	1
1	7	18	7	\N
1	8	18	3	\N
1	9	18	9	\N
1	10	18	7	\N
1	11	18	8	\N
1	12	18	8	\N
1	13	18	8	\N
1	14	18	8	\N
1	15	18	8	\N
1	16	18	8	\N
1	17	18	8	\N
1	18	18	8	\N
1	19	18	8	\N
1	20	18	8	\N
1	21	18	2	1
1	22	18	2	1
1	23	18	2	1
1	24	18	3	3
1	25	18	3	2
1	26	18	3	\N
1	27	18	3	2
1	28	18	9	\N
1	29	18	1	\N
1	30	18	9	\N
1	31	18	4	\N
1	32	18	5	8
1	33	18	3	3
1	34	18	3	\N
1	35	18	9	\N
1	36	18	4	7
1	37	18	4	\N
1	38	18	4	7
1	39	18	4	7
1	40	18	6	\N
1	41	18	6	\N
1	42	18	4	7
1	43	18	4	\N
1	44	18	4	7
1	45	18	6	\N
1	46	18	1	\N
1	47	18	1	\N
1	48	18	5	\N
1	49	18	1	1
1	50	18	1	9
1	51	18	4	\N
1	52	18	1	1
1	53	18	9	\N
1	54	18	1	1
1	55	18	1	\N
1	56	18	1	1
1	57	18	1	9
1	58	18	1	\N
1	59	18	1	9
1	60	18	1	9
1	1	19	2	\N
1	2	19	2	\N
1	3	19	3	\N
1	4	19	2	1
1	5	19	2	1
1	6	19	3	3
1	7	19	3	2
1	8	19	3	3
1	9	19	3	3
1	10	19	3	\N
1	11	19	3	2
1	12	19	8	\N
1	13	19	8	\N
1	14	19	8	\N
1	15	19	8	\N
1	16	19	8	\N
1	17	19	8	\N
1	18	19	8	\N
1	19	19	8	\N
1	20	19	8	\N
1	21	19	2	\N
1	22	19	2	1
1	23	19	2	\N
1	24	19	2	1
1	25	19	2	\N
1	26	19	3	\N
1	27	19	3	2
1	28	19	9	\N
1	29	19	1	1
1	30	19	9	\N
1	31	19	9	\N
1	32	19	3	2
1	33	19	3	2
1	34	19	3	3
1	35	19	3	\N
1	36	19	4	\N
1	37	19	4	7
1	38	19	2	1
1	39	19	2	1
1	40	19	6	\N
1	41	19	6	\N
1	42	19	4	\N
1	43	19	4	7
1	44	19	4	7
1	45	19	4	7
1	46	19	1	9
1	47	19	1	1
1	48	19	1	9
1	49	19	1	9
1	50	19	1	\N
1	51	19	1	1
1	52	19	1	9
1	53	19	1	\N
1	54	19	1	\N
1	55	19	1	\N
1	56	19	3	3
1	57	19	1	1
1	58	19	1	1
1	59	19	1	\N
1	60	19	1	9
1	1	20	2	\N
1	2	20	2	1
1	3	20	5	6
1	4	20	2	1
1	5	20	2	\N
1	6	20	2	1
1	7	20	3	3
1	8	20	3	2
1	9	20	3	2
1	10	20	3	\N
1	11	20	3	3
1	12	20	3	2
1	13	20	8	\N
1	14	20	8	\N
1	15	20	8	\N
1	16	20	8	\N
1	17	20	8	\N
1	18	20	8	\N
1	19	20	8	\N
1	20	20	8	\N
1	21	20	8	\N
1	22	20	8	\N
1	23	20	8	\N
1	24	20	2	1
1	25	20	2	1
1	26	20	2	1
1	27	20	3	3
1	28	20	3	3
1	29	20	1	9
1	30	20	3	2
1	31	20	3	\N
1	32	20	3	2
1	33	20	3	2
1	34	20	3	\N
1	35	20	1	9
1	36	20	4	7
1	37	20	4	7
1	38	20	4	7
1	39	20	2	\N
1	40	20	2	1
1	41	20	7	\N
1	42	20	4	7
1	43	20	4	7
1	44	20	4	\N
1	45	20	6	\N
1	46	20	6	\N
1	47	20	1	\N
1	48	20	9	\N
1	49	20	1	\N
1	50	20	1	1
1	51	20	9	\N
1	52	20	1	\N
1	53	20	1	1
1	54	20	1	9
1	55	20	1	\N
1	56	20	1	1
1	57	20	1	9
1	58	20	1	1
1	59	20	1	1
1	60	20	1	1
1	1	21	2	\N
1	2	21	2	1
1	3	21	2	1
1	4	21	9	\N
1	5	21	2	1
1	6	21	2	1
1	7	21	2	1
1	8	21	3	2
1	9	21	3	2
1	10	21	7	\N
1	11	21	3	2
1	12	21	3	3
1	13	21	8	\N
1	14	21	2	1
1	15	21	8	\N
1	16	21	8	\N
1	17	21	8	\N
1	18	21	8	\N
1	19	21	7	\N
1	20	21	8	\N
1	21	21	8	\N
1	22	21	8	\N
1	23	21	8	\N
1	24	21	8	\N
1	25	21	2	1
1	26	21	2	1
1	27	21	6	\N
1	28	21	3	2
1	29	21	3	\N
1	30	21	3	\N
1	31	21	6	\N
1	32	21	5	8
1	33	21	3	2
1	34	21	3	3
1	35	21	3	3
1	36	21	4	\N
1	37	21	4	7
1	38	21	4	7
1	39	21	2	1
1	40	21	2	\N
1	41	21	3	\N
1	42	21	9	\N
1	43	21	4	7
1	44	21	4	\N
1	45	21	4	7
1	46	21	6	\N
1	47	21	6	\N
1	48	21	9	\N
1	49	21	9	\N
1	50	21	1	9
1	51	21	1	9
1	52	21	3	2
1	53	21	1	9
1	54	21	1	\N
1	55	21	1	1
1	56	21	1	9
1	57	21	3	3
1	58	21	1	9
1	59	21	1	1
1	60	21	1	1
1	1	22	2	\N
1	2	22	2	1
1	3	22	2	\N
1	4	22	9	\N
1	5	22	9	\N
1	6	22	2	1
1	7	22	9	\N
1	8	22	3	2
1	9	22	3	\N
1	10	22	3	2
1	11	22	2	1
1	12	22	3	\N
1	13	22	3	\N
1	14	22	8	\N
1	15	22	8	\N
1	16	22	8	\N
1	17	22	8	\N
1	18	22	8	\N
1	19	22	8	\N
1	20	22	8	\N
1	21	22	8	\N
1	22	22	8	\N
1	23	22	8	\N
1	24	22	8	\N
1	25	22	2	1
1	26	22	2	1
1	27	22	2	1
1	28	22	3	2
1	29	22	3	\N
1	30	22	3	2
1	31	22	3	3
1	32	22	3	2
1	33	22	3	3
1	34	22	3	3
1	35	22	3	\N
1	36	22	3	\N
1	37	22	4	7
1	38	22	4	7
1	39	22	2	\N
1	40	22	2	\N
1	41	22	2	1
1	42	22	9	\N
1	43	22	9	\N
1	44	22	4	7
1	45	22	4	7
1	46	22	4	\N
1	47	22	6	\N
1	48	22	9	\N
1	49	22	1	\N
1	50	22	1	9
1	51	22	1	9
1	52	22	1	9
1	53	22	9	\N
1	54	22	1	\N
1	55	22	1	\N
1	56	22	1	9
1	57	22	1	9
1	58	22	1	\N
1	59	22	1	9
1	60	22	1	9
1	1	23	5	6
1	2	23	2	1
1	3	23	2	1
1	4	23	2	1
1	5	23	2	\N
1	6	23	2	\N
1	7	23	2	1
1	8	23	3	\N
1	9	23	3	2
1	10	23	3	2
1	11	23	3	3
1	12	23	3	3
1	13	23	8	\N
1	14	23	8	\N
1	15	23	8	\N
1	16	23	8	\N
1	17	23	8	\N
1	18	23	8	\N
1	19	23	8	\N
1	20	23	8	\N
1	21	23	8	\N
1	22	23	8	\N
1	23	23	8	\N
1	24	23	8	\N
1	25	23	2	1
1	26	23	2	1
1	27	23	2	1
1	28	23	2	1
1	29	23	7	\N
1	30	23	3	\N
1	31	23	3	3
1	32	23	7	\N
1	33	23	3	3
1	34	23	9	\N
1	35	23	3	3
1	36	23	3	2
1	37	23	6	\N
1	38	23	4	7
1	39	23	2	1
1	40	23	2	\N
1	41	23	2	\N
1	42	23	2	1
1	43	23	2	1
1	44	23	4	\N
1	45	23	4	7
1	46	23	4	7
1	47	23	4	7
1	48	23	9	\N
1	49	23	9	\N
1	50	23	9	\N
1	51	23	9	\N
1	52	23	9	\N
1	53	23	9	\N
1	54	23	1	1
1	55	23	1	\N
1	56	23	3	\N
1	57	23	1	1
1	58	23	1	9
1	59	23	1	9
1	60	23	1	1
1	1	24	2	1
1	2	24	2	1
1	3	24	2	\N
1	4	24	2	\N
1	5	24	2	1
1	6	24	2	\N
1	7	24	4	7
1	8	24	3	2
1	9	24	3	\N
1	10	24	9	\N
1	11	24	9	\N
1	12	24	9	\N
1	13	24	8	\N
1	14	24	8	\N
1	15	24	8	\N
1	16	24	8	\N
1	17	24	8	\N
1	18	24	8	\N
1	19	24	8	\N
1	20	24	8	\N
1	21	24	8	\N
1	22	24	8	\N
1	23	24	8	\N
1	24	24	8	\N
1	25	24	2	\N
1	26	24	4	\N
1	27	24	2	1
1	28	24	2	\N
1	29	24	2	1
1	30	24	3	3
1	31	24	6	\N
1	32	24	3	\N
1	33	24	3	2
1	34	24	9	\N
1	35	24	3	\N
1	36	24	3	2
1	37	24	3	3
1	38	24	2	1
1	39	24	2	1
1	40	24	2	1
1	41	24	2	1
1	42	24	2	1
1	43	24	2	1
1	44	24	9	\N
1	45	24	4	7
1	46	24	5	\N
1	47	24	4	\N
1	48	24	4	7
1	49	24	4	\N
1	50	24	9	\N
1	51	24	7	\N
1	52	24	9	\N
1	53	24	9	\N
1	54	24	1	\N
1	55	24	1	9
1	56	24	1	9
1	57	24	6	\N
1	58	24	1	9
1	59	24	1	\N
1	60	24	1	9
1	1	25	9	\N
1	2	25	2	1
1	3	25	2	1
1	4	25	3	2
1	5	25	2	\N
1	6	25	2	1
1	7	25	2	1
1	8	25	3	3
1	9	25	3	\N
1	10	25	3	2
1	11	25	9	\N
1	12	25	8	\N
1	13	25	8	\N
1	14	25	8	\N
1	15	25	8	\N
1	16	25	8	\N
1	17	25	8	\N
1	18	25	8	\N
1	19	25	8	\N
1	20	25	8	\N
1	21	25	8	\N
1	22	25	1	1
1	23	25	8	\N
1	24	25	8	\N
1	25	25	8	\N
1	26	25	2	\N
1	27	25	3	2
1	28	25	2	\N
1	29	25	2	\N
1	30	25	2	1
1	31	25	9	\N
1	32	25	9	\N
1	33	25	3	3
1	34	25	3	3
1	35	25	2	\N
1	36	25	3	\N
1	37	25	3	2
1	38	25	2	1
1	39	25	2	1
1	40	25	2	1
1	41	25	2	\N
1	42	25	2	\N
1	43	25	6	\N
1	44	25	5	\N
1	45	25	5	8
1	46	25	4	\N
1	47	25	4	7
1	48	25	4	7
1	49	25	4	\N
1	50	25	4	\N
1	51	25	4	\N
1	52	25	9	\N
1	53	25	1	1
1	54	25	7	\N
1	55	25	1	1
1	56	25	1	9
1	57	25	1	9
1	58	25	1	\N
1	59	25	2	\N
1	60	25	1	\N
1	1	26	9	\N
1	2	26	7	\N
1	3	26	2	1
1	4	26	3	2
1	5	26	2	\N
1	6	26	2	1
1	7	26	2	1
1	8	26	2	1
1	9	26	3	\N
1	10	26	3	3
1	11	26	8	\N
1	12	26	8	\N
1	13	26	8	\N
1	14	26	8	\N
1	15	26	8	\N
1	16	26	8	\N
1	17	26	8	\N
1	18	26	8	\N
1	19	26	8	\N
1	20	26	8	\N
1	21	26	8	\N
1	22	26	8	\N
1	23	26	8	\N
1	24	26	8	\N
1	25	26	8	\N
1	26	26	2	1
1	27	26	2	1
1	28	26	2	1
1	29	26	5	8
1	30	26	2	1
1	31	26	9	\N
1	32	26	3	3
1	33	26	3	3
1	34	26	6	\N
1	35	26	7	\N
1	36	26	3	2
1	37	26	3	\N
1	38	26	6	\N
1	39	26	5	8
1	40	26	2	\N
1	41	26	5	\N
1	42	26	2	1
1	43	26	4	\N
1	44	26	5	8
1	45	26	5	\N
1	46	26	4	7
1	47	26	4	\N
1	48	26	4	7
1	49	26	4	7
1	50	26	4	7
1	51	26	4	7
1	52	26	4	\N
1	53	26	1	1
1	54	26	1	9
1	55	26	7	\N
1	56	26	1	9
1	57	26	2	1
1	58	26	1	9
1	59	26	1	9
1	60	26	1	9
1	1	27	5	8
1	2	27	6	\N
1	3	27	2	1
1	4	27	2	1
1	5	27	2	1
1	6	27	2	\N
1	7	27	2	1
1	8	27	2	1
1	9	27	9	\N
1	10	27	3	3
1	11	27	8	\N
1	12	27	8	\N
1	13	27	8	\N
1	14	27	8	\N
1	15	27	8	\N
1	16	27	8	\N
1	17	27	8	\N
1	18	27	8	\N
1	19	27	8	\N
1	20	27	8	\N
1	21	27	8	\N
1	22	27	8	\N
1	23	27	8	\N
1	24	27	8	\N
1	25	27	8	\N
1	26	27	8	\N
1	27	27	2	\N
1	28	27	2	1
1	29	27	2	1
1	30	27	2	1
1	31	27	2	1
1	32	27	5	8
1	33	27	3	3
1	34	27	3	3
1	35	27	3	3
1	36	27	3	\N
1	37	27	3	\N
1	38	27	3	\N
1	39	27	2	\N
1	40	27	2	1
1	41	27	2	\N
1	42	27	2	1
1	43	27	2	1
1	44	27	5	6
1	45	27	2	\N
1	46	27	4	\N
1	47	27	4	7
1	48	27	4	7
1	49	27	4	7
1	50	27	4	\N
1	51	27	4	\N
1	52	27	4	\N
1	53	27	7	\N
1	54	27	1	\N
1	55	27	1	\N
1	56	27	1	9
1	57	27	1	9
1	58	27	4	7
1	59	27	1	9
1	60	27	1	9
1	1	28	5	\N
1	2	28	5	6
1	3	28	2	\N
1	4	28	2	1
1	5	28	2	1
1	6	28	2	1
1	7	28	2	1
1	8	28	2	1
1	9	28	9	\N
1	10	28	3	2
1	11	28	8	\N
1	12	28	8	\N
1	13	28	8	\N
1	14	28	8	\N
1	15	28	8	\N
1	16	28	8	\N
1	17	28	8	\N
1	18	28	8	\N
1	19	28	8	\N
1	20	28	8	\N
1	21	28	2	\N
1	22	28	8	\N
1	23	28	8	\N
1	24	28	8	\N
1	25	28	8	\N
1	26	28	8	\N
1	27	28	8	\N
1	28	28	2	1
1	29	28	9	\N
1	30	28	9	\N
1	31	28	2	1
1	32	28	5	6
1	33	28	3	2
1	34	28	3	2
1	35	28	3	2
1	36	28	3	2
1	37	28	9	\N
1	38	28	3	2
1	39	28	6	\N
1	40	28	4	7
1	41	28	2	1
1	42	28	2	1
1	43	28	2	\N
1	44	28	2	1
1	45	28	2	1
1	46	28	2	\N
1	47	28	4	7
1	48	28	4	\N
1	49	28	4	7
1	50	28	4	7
1	51	28	6	\N
1	52	28	4	\N
1	53	28	4	7
1	54	28	1	9
1	55	28	3	2
1	56	28	1	9
1	57	28	1	9
1	58	28	1	9
1	59	28	2	1
1	60	28	1	\N
1	1	29	4	\N
1	2	29	7	\N
1	3	29	5	\N
1	4	29	2	1
1	5	29	2	\N
1	6	29	2	\N
1	7	29	2	1
1	8	29	2	1
1	9	29	2	1
1	10	29	1	1
1	11	29	8	\N
1	12	29	8	\N
1	13	29	8	\N
1	14	29	8	\N
1	15	29	7	\N
1	16	29	8	\N
1	17	29	8	\N
1	18	29	8	\N
1	19	29	8	\N
1	20	29	8	\N
1	21	29	8	\N
1	22	29	8	\N
1	23	29	8	\N
1	24	29	8	\N
1	25	29	8	\N
1	26	29	8	\N
1	27	29	2	1
1	28	29	4	7
1	29	29	7	\N
1	30	29	9	\N
1	31	29	2	1
1	32	29	2	1
1	33	29	3	\N
1	34	29	3	3
1	35	29	3	2
1	36	29	3	\N
1	37	29	1	9
1	38	29	3	3
1	39	29	3	\N
1	40	29	2	1
1	41	29	2	1
1	42	29	2	\N
1	43	29	2	1
1	44	29	2	1
1	45	29	7	\N
1	46	29	2	1
1	47	29	2	\N
1	48	29	4	7
1	49	29	4	\N
1	50	29	4	7
1	51	29	4	\N
1	52	29	4	\N
1	53	29	4	7
1	54	29	4	\N
1	55	29	5	\N
1	56	29	1	\N
1	57	29	1	9
1	58	29	1	1
1	59	29	1	9
1	60	29	9	\N
1	1	30	1	\N
1	2	30	1	1
1	3	30	2	1
1	4	30	2	\N
1	5	30	2	1
1	6	30	2	1
1	7	30	2	1
1	8	30	2	1
1	9	30	2	\N
1	10	30	8	\N
1	11	30	8	\N
1	12	30	8	\N
1	13	30	8	\N
1	14	30	8	\N
1	15	30	8	\N
1	16	30	6	\N
1	17	30	8	\N
1	18	30	8	\N
1	19	30	8	\N
1	20	30	8	\N
1	21	30	8	\N
1	22	30	8	\N
1	23	30	8	\N
1	24	30	8	\N
1	25	30	8	\N
1	26	30	8	\N
1	27	30	3	3
1	28	30	2	1
1	29	30	2	1
1	30	30	2	\N
1	31	30	2	1
1	32	30	5	\N
1	33	30	1	1
1	34	30	3	3
1	35	30	3	2
1	36	30	3	3
1	37	30	3	3
1	38	30	3	\N
1	39	30	3	2
1	40	30	2	1
1	41	30	2	1
1	42	30	2	1
1	43	30	2	1
1	44	30	2	\N
1	45	30	2	1
1	46	30	1	\N
1	47	30	2	1
1	48	30	2	1
1	49	30	2	1
1	50	30	4	\N
1	51	30	2	1
1	52	30	4	7
1	53	30	4	7
1	54	30	4	\N
1	55	30	4	7
1	56	30	1	1
1	57	30	9	\N
1	58	30	9	\N
1	59	30	9	\N
1	60	30	1	1
1	1	31	1	\N
1	2	31	1	\N
1	3	31	1	\N
1	4	31	2	1
1	5	31	2	1
1	6	31	3	\N
1	7	31	2	\N
1	8	31	2	1
1	9	31	2	1
1	10	31	8	\N
1	11	31	4	7
1	12	31	8	\N
1	13	31	8	\N
1	14	31	8	\N
1	15	31	8	\N
1	16	31	8	\N
1	17	31	8	\N
1	18	31	8	\N
1	19	31	8	\N
1	20	31	8	\N
1	21	31	8	\N
1	22	31	8	\N
1	23	31	8	\N
1	24	31	8	\N
1	25	31	8	\N
1	26	31	8	\N
1	27	31	2	1
1	28	31	2	1
1	29	31	1	1
1	30	31	2	1
1	31	31	3	\N
1	32	31	2	1
1	33	31	1	9
1	34	31	1	\N
1	35	31	3	\N
1	36	31	3	2
1	37	31	3	2
1	38	31	3	2
1	39	31	3	3
1	40	31	2	1
1	41	31	2	\N
1	42	31	2	1
1	43	31	9	\N
1	44	31	3	2
1	45	31	2	1
1	46	31	2	1
1	47	31	2	\N
1	48	31	2	\N
1	49	31	9	\N
1	50	31	2	1
1	51	31	2	\N
1	52	31	2	1
1	53	31	6	\N
1	54	31	4	7
1	55	31	6	\N
1	56	31	1	\N
1	57	31	1	1
1	58	31	9	\N
1	59	31	1	9
1	60	31	1	\N
1	1	32	5	6
1	2	32	2	1
1	3	32	1	9
1	4	32	4	7
1	5	32	2	1
1	6	32	2	1
1	7	32	2	1
1	8	32	6	\N
1	9	32	2	\N
1	10	32	2	1
1	11	32	8	\N
1	12	32	8	\N
1	13	32	7	\N
1	14	32	8	\N
1	15	32	8	\N
1	16	32	8	\N
1	17	32	8	\N
1	18	32	8	\N
1	19	32	8	\N
1	20	32	8	\N
1	21	32	8	\N
1	22	32	6	\N
1	23	32	8	\N
1	24	32	8	\N
1	25	32	8	\N
1	26	32	8	\N
1	27	32	8	\N
1	28	32	2	\N
1	29	32	9	\N
1	30	32	9	\N
1	31	32	2	1
1	32	32	2	1
1	33	32	1	1
1	34	32	1	\N
1	35	32	1	\N
1	36	32	3	2
1	37	32	3	\N
1	38	32	3	\N
1	39	32	3	3
1	40	32	2	1
1	41	32	2	1
1	42	32	2	\N
1	43	32	2	\N
1	44	32	2	1
1	45	32	4	7
1	46	32	2	\N
1	47	32	2	\N
1	48	32	2	1
1	49	32	2	\N
1	50	32	2	\N
1	51	32	2	1
1	52	32	3	\N
1	53	32	2	1
1	54	32	6	\N
1	55	32	3	\N
1	56	32	9	\N
1	57	32	1	1
1	58	32	1	1
1	59	32	1	1
1	60	32	2	\N
1	1	33	2	1
1	2	33	2	1
1	3	33	2	1
1	4	33	2	1
1	5	33	9	\N
1	6	33	9	\N
1	7	33	9	\N
1	8	33	2	1
1	9	33	9	\N
1	10	33	8	\N
1	11	33	8	\N
1	12	33	8	\N
1	13	33	8	\N
1	14	33	8	\N
1	15	33	8	\N
1	16	33	8	\N
1	17	33	8	\N
1	18	33	2	1
1	19	33	8	\N
1	20	33	8	\N
1	21	33	8	\N
1	22	33	8	\N
1	23	33	8	\N
1	24	33	8	\N
1	25	33	8	\N
1	26	33	8	\N
1	27	33	8	\N
1	28	33	2	1
1	29	33	2	1
1	30	33	9	\N
1	31	33	3	3
1	32	33	2	1
1	33	33	7	\N
1	34	33	1	1
1	35	33	1	1
1	36	33	1	1
1	37	33	3	2
1	38	33	6	\N
1	39	33	3	\N
1	40	33	2	1
1	41	33	2	1
1	42	33	2	\N
1	43	33	2	1
1	44	33	2	1
1	45	33	2	1
1	46	33	2	1
1	47	33	9	\N
1	48	33	2	1
1	49	33	9	\N
1	50	33	2	1
1	51	33	2	\N
1	52	33	2	1
1	53	33	2	1
1	54	33	2	1
1	55	33	2	1
1	56	33	1	\N
1	57	33	1	\N
1	58	33	1	9
1	59	33	1	\N
1	60	33	1	\N
1	1	34	2	1
1	2	34	2	1
1	3	34	2	1
1	4	34	2	1
1	5	34	9	\N
1	6	34	5	6
1	7	34	9	\N
1	8	34	9	\N
1	9	34	8	\N
1	10	34	8	\N
1	11	34	8	\N
1	12	34	8	\N
1	13	34	8	\N
1	14	34	8	\N
1	15	34	8	\N
1	16	34	8	\N
1	17	34	8	\N
1	18	34	8	\N
1	19	34	8	\N
1	20	34	8	\N
1	21	34	8	\N
1	22	34	8	\N
1	23	34	8	\N
1	24	34	8	\N
1	25	34	8	\N
1	26	34	8	\N
1	27	34	8	\N
1	28	34	8	\N
1	29	34	2	1
1	30	34	2	1
1	31	34	5	8
1	32	34	4	7
1	33	34	1	9
1	34	34	1	1
1	35	34	1	\N
1	36	34	1	1
1	37	34	5	6
1	38	34	3	3
1	39	34	7	\N
1	40	34	2	\N
1	41	34	2	1
1	42	34	7	\N
1	43	34	2	\N
1	44	34	2	1
1	45	34	2	1
1	46	34	2	1
1	47	34	2	1
1	48	34	2	1
1	49	34	2	\N
1	50	34	2	1
1	51	34	2	1
1	52	34	2	1
1	53	34	2	1
1	54	34	2	1
1	55	34	7	\N
1	56	34	1	9
1	57	34	1	9
1	58	34	1	\N
1	59	34	7	\N
1	60	34	1	1
1	1	35	2	1
1	2	35	2	1
1	3	35	2	1
1	4	35	2	1
1	5	35	2	1
1	6	35	2	1
1	7	35	2	1
1	8	35	8	\N
1	9	35	8	\N
1	10	35	8	\N
1	11	35	8	\N
1	12	35	8	\N
1	13	35	8	\N
1	14	35	8	\N
1	15	35	8	\N
1	16	35	8	\N
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
1	28	35	8	\N
1	29	35	8	\N
1	30	35	2	\N
1	31	35	2	1
1	32	35	8	\N
1	33	35	1	1
1	34	35	9	\N
1	35	35	9	\N
1	36	35	9	\N
1	37	35	9	\N
1	38	35	3	\N
1	39	35	3	\N
1	40	35	2	1
1	41	35	5	6
1	42	35	2	1
1	43	35	2	1
1	44	35	2	1
1	45	35	1	\N
1	46	35	2	\N
1	47	35	2	1
1	48	35	2	1
1	49	35	2	1
1	50	35	2	\N
1	51	35	9	\N
1	52	35	2	\N
1	53	35	2	1
1	54	35	5	8
1	55	35	1	\N
1	56	35	1	1
1	57	35	1	1
1	58	35	1	\N
1	59	35	9	\N
1	60	35	9	\N
1	1	36	6	\N
1	2	36	2	\N
1	3	36	2	1
1	4	36	2	1
1	5	36	2	1
1	6	36	2	\N
1	7	36	8	\N
1	8	36	8	\N
1	9	36	8	\N
1	10	36	5	\N
1	11	36	8	\N
1	12	36	6	\N
1	13	36	8	\N
1	14	36	8	\N
1	15	36	8	\N
1	16	36	8	\N
1	17	36	8	\N
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
1	28	36	8	\N
1	29	36	1	1
1	30	36	2	\N
1	31	36	2	1
1	32	36	2	1
1	33	36	8	\N
1	34	36	8	\N
1	35	36	8	\N
1	36	36	8	\N
1	37	36	8	\N
1	38	36	3	2
1	39	36	3	3
1	40	36	4	7
1	41	36	2	\N
1	42	36	2	1
1	43	36	2	\N
1	44	36	2	\N
1	45	36	2	1
1	46	36	2	\N
1	47	36	2	\N
1	48	36	2	1
1	49	36	2	1
1	50	36	2	1
1	51	36	9	\N
1	52	36	9	\N
1	53	36	2	1
1	54	36	2	1
1	55	36	2	1
1	56	36	1	\N
1	57	36	1	\N
1	58	36	1	\N
1	59	36	9	\N
1	60	36	4	7
1	1	37	2	1
1	2	37	2	\N
1	3	37	2	1
1	4	37	2	1
1	5	37	2	\N
1	6	37	2	1
1	7	37	2	1
1	8	37	8	\N
1	9	37	8	\N
1	10	37	8	\N
1	11	37	4	\N
1	12	37	8	\N
1	13	37	8	\N
1	14	37	8	\N
1	15	37	8	\N
1	16	37	8	\N
1	17	37	8	\N
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
1	28	37	1	\N
1	29	37	1	9
1	30	37	1	\N
1	31	37	2	\N
1	32	37	8	\N
1	33	37	8	\N
1	34	37	8	\N
1	35	37	8	\N
1	36	37	8	\N
1	37	37	8	\N
1	38	37	3	2
1	39	37	3	\N
1	40	37	3	\N
1	41	37	2	\N
1	42	37	2	\N
1	43	37	2	\N
1	44	37	2	1
1	45	37	2	\N
1	46	37	2	1
1	47	37	2	\N
1	48	37	2	1
1	49	37	2	1
1	50	37	2	1
1	51	37	2	\N
1	52	37	2	1
1	53	37	2	\N
1	54	37	2	1
1	55	37	2	1
1	56	37	3	2
1	57	37	1	\N
1	58	37	5	8
1	59	37	9	\N
1	60	37	9	\N
1	1	38	2	1
1	2	38	2	1
1	3	38	9	\N
1	4	38	9	\N
1	5	38	9	\N
1	6	38	2	1
1	7	38	2	1
1	8	38	2	\N
1	9	38	8	\N
1	10	38	1	1
1	11	38	1	1
1	12	38	1	9
1	13	38	8	\N
1	14	38	8	\N
1	15	38	8	\N
1	16	38	8	\N
1	17	38	8	\N
1	18	38	8	\N
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
1	29	38	1	\N
1	30	38	1	9
1	31	38	8	\N
1	32	38	8	\N
1	33	38	8	\N
1	34	38	8	\N
1	35	38	8	\N
1	36	38	8	\N
1	37	38	8	\N
1	38	38	8	\N
1	39	38	3	3
1	40	38	3	2
1	41	38	2	\N
1	42	38	2	1
1	43	38	2	1
1	44	38	2	1
1	45	38	2	1
1	46	38	1	1
1	47	38	2	1
1	48	38	2	1
1	49	38	2	1
1	50	38	2	\N
1	51	38	7	\N
1	52	38	9	\N
1	53	38	9	\N
1	54	38	9	\N
1	55	38	2	1
1	56	38	2	\N
1	57	38	1	9
1	58	38	1	9
1	59	38	1	1
1	60	38	1	9
1	1	39	2	1
1	2	39	2	1
1	3	39	9	\N
1	4	39	5	6
1	5	39	9	\N
1	6	39	2	1
1	7	39	2	1
1	8	39	2	\N
1	9	39	8	\N
1	10	39	2	\N
1	11	39	1	\N
1	12	39	1	9
1	13	39	8	\N
1	14	39	8	\N
1	15	39	8	\N
1	16	39	8	\N
1	17	39	8	\N
1	18	39	8	\N
1	19	39	8	\N
1	20	39	8	\N
1	21	39	8	\N
1	22	39	8	\N
1	23	39	8	\N
1	24	39	8	\N
1	25	39	8	\N
1	26	39	8	\N
1	27	39	1	1
1	28	39	1	9
1	29	39	8	\N
1	30	39	8	\N
1	31	39	8	\N
1	32	39	8	\N
1	33	39	8	\N
1	34	39	8	\N
1	35	39	8	\N
1	36	39	8	\N
1	37	39	8	\N
1	38	39	8	\N
1	39	39	2	1
1	40	39	2	1
1	41	39	2	1
1	42	39	2	1
1	43	39	2	\N
1	44	39	2	1
1	45	39	2	1
1	46	39	2	1
1	47	39	2	1
1	48	39	2	\N
1	49	39	2	\N
1	50	39	5	\N
1	51	39	2	\N
1	52	39	9	\N
1	53	39	7	\N
1	54	39	9	\N
1	55	39	9	\N
1	56	39	2	1
1	57	39	1	\N
1	58	39	5	\N
1	59	39	1	1
1	60	39	1	9
1	1	40	2	1
1	2	40	2	\N
1	3	40	7	\N
1	4	40	5	\N
1	5	40	9	\N
1	6	40	2	1
1	7	40	2	\N
1	8	40	2	1
1	9	40	2	1
1	10	40	2	\N
1	11	40	1	1
1	12	40	1	9
1	13	40	1	\N
1	14	40	8	\N
1	15	40	8	\N
1	16	40	8	\N
1	17	40	8	\N
1	18	40	8	\N
1	19	40	8	\N
1	20	40	8	\N
1	21	40	8	\N
1	22	40	8	\N
1	23	40	8	\N
1	24	40	8	\N
1	25	40	8	\N
1	26	40	8	\N
1	27	40	8	\N
1	28	40	1	\N
1	29	40	1	1
1	30	40	8	\N
1	31	40	8	\N
1	32	40	8	\N
1	33	40	8	\N
1	34	40	8	\N
1	35	40	8	\N
1	36	40	8	\N
1	37	40	8	\N
1	38	40	8	\N
1	39	40	8	\N
1	40	40	2	1
1	41	40	2	1
1	42	40	2	1
1	43	40	2	\N
1	44	40	2	1
1	45	40	2	1
1	46	40	2	1
1	47	40	2	1
1	48	40	2	1
1	49	40	2	\N
1	50	40	7	\N
1	51	40	2	1
1	52	40	2	1
1	53	40	2	1
1	54	40	2	1
1	55	40	9	\N
1	56	40	9	\N
1	57	40	9	\N
1	58	40	9	\N
1	59	40	1	\N
1	60	40	3	\N
1	1	41	2	1
1	2	41	2	1
1	3	41	2	1
1	4	41	2	1
1	5	41	9	\N
1	6	41	2	1
1	7	41	2	1
1	8	41	2	1
1	9	41	2	1
1	10	41	2	1
1	11	41	1	1
1	12	41	1	\N
1	13	41	1	\N
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
1	26	41	3	2
1	27	41	2	\N
1	28	41	7	\N
1	29	41	1	1
1	30	41	8	\N
1	31	41	8	\N
1	32	41	8	\N
1	33	41	8	\N
1	34	41	8	\N
1	35	41	8	\N
1	36	41	8	\N
1	37	41	8	\N
1	38	41	8	\N
1	39	41	8	\N
1	40	41	8	\N
1	41	41	2	1
1	42	41	2	1
1	43	41	2	1
1	44	41	2	1
1	45	41	1	9
1	46	41	2	1
1	47	41	2	1
1	48	41	2	1
1	49	41	9	\N
1	50	41	2	1
1	51	41	2	\N
1	52	41	1	1
1	53	41	2	1
1	54	41	2	\N
1	55	41	2	1
1	56	41	2	\N
1	57	41	9	\N
1	58	41	1	\N
1	59	41	1	1
1	60	41	1	1
1	1	42	9	\N
1	2	42	2	\N
1	3	42	2	\N
1	4	42	2	\N
1	5	42	2	1
1	6	42	2	\N
1	7	42	2	\N
1	8	42	2	1
1	9	42	2	\N
1	10	42	2	1
1	11	42	1	9
1	12	42	1	1
1	13	42	1	\N
1	14	42	1	1
1	15	42	8	\N
1	16	42	8	\N
1	17	42	6	\N
1	18	42	8	\N
1	19	42	8	\N
1	20	42	8	\N
1	21	42	8	\N
1	22	42	8	\N
1	23	42	8	\N
1	24	42	8	\N
1	25	42	8	\N
1	26	42	2	\N
1	27	42	2	\N
1	28	42	2	\N
1	29	42	5	8
1	30	42	8	\N
1	31	42	8	\N
1	32	42	8	\N
1	33	42	2	1
1	34	42	8	\N
1	35	42	8	\N
1	36	42	8	\N
1	37	42	8	\N
1	38	42	8	\N
1	39	42	8	\N
1	40	42	8	\N
1	41	42	8	\N
1	42	42	2	1
1	43	42	2	1
1	44	42	2	\N
1	45	42	2	\N
1	46	42	2	1
1	47	42	2	1
1	48	42	3	3
1	49	42	9	\N
1	50	42	5	8
1	51	42	1	1
1	52	42	1	\N
1	53	42	1	\N
1	54	42	2	1
1	55	42	2	1
1	56	42	2	1
1	57	42	9	\N
1	58	42	1	9
1	59	42	1	\N
1	60	42	1	9
1	1	43	9	\N
1	2	43	9	\N
1	3	43	9	\N
1	4	43	9	\N
1	5	43	9	\N
1	6	43	9	\N
1	7	43	9	\N
1	8	43	9	\N
1	9	43	2	\N
1	10	43	2	\N
1	11	43	1	\N
1	12	43	1	1
1	13	43	6	\N
1	14	43	8	\N
1	15	43	8	\N
1	16	43	8	\N
1	17	43	8	\N
1	18	43	8	\N
1	19	43	2	1
1	20	43	8	\N
1	21	43	8	\N
1	22	43	8	\N
1	23	43	8	\N
1	24	43	8	\N
1	25	43	8	\N
1	26	43	2	\N
1	27	43	2	\N
1	28	43	2	1
1	29	43	2	1
1	30	43	2	\N
1	31	43	8	\N
1	32	43	8	\N
1	33	43	8	\N
1	34	43	8	\N
1	35	43	8	\N
1	36	43	8	\N
1	37	43	8	\N
1	38	43	8	\N
1	39	43	8	\N
1	40	43	8	\N
1	41	43	8	\N
1	42	43	8	\N
1	43	43	2	1
1	44	43	2	1
1	45	43	2	\N
1	46	43	2	\N
1	47	43	3	2
1	48	43	3	\N
1	49	43	9	\N
1	50	43	6	\N
1	51	43	1	\N
1	52	43	1	9
1	53	43	1	\N
1	54	43	7	\N
1	55	43	2	1
1	56	43	1	9
1	57	43	1	1
1	58	43	1	9
1	59	43	1	9
1	60	43	1	9
1	1	44	9	\N
1	2	44	2	1
1	3	44	2	1
1	4	44	9	\N
1	5	44	1	\N
1	6	44	9	\N
1	7	44	3	3
1	8	44	9	\N
1	9	44	2	\N
1	10	44	2	\N
1	11	44	1	9
1	12	44	1	\N
1	13	44	1	1
1	14	44	8	\N
1	15	44	8	\N
1	16	44	8	\N
1	17	44	8	\N
1	18	44	8	\N
1	19	44	8	\N
1	20	44	5	8
1	21	44	8	\N
1	22	44	8	\N
1	23	44	8	\N
1	24	44	8	\N
1	25	44	8	\N
1	26	44	8	\N
1	27	44	8	\N
1	28	44	2	\N
1	29	44	3	\N
1	30	44	8	\N
1	31	44	8	\N
1	32	44	8	\N
1	33	44	8	\N
1	34	44	8	\N
1	35	44	8	\N
1	36	44	8	\N
1	37	44	8	\N
1	38	44	8	\N
1	39	44	3	3
1	40	44	8	\N
1	41	44	8	\N
1	42	44	8	\N
1	43	44	8	\N
1	44	44	2	\N
1	45	44	7	\N
1	46	44	2	1
1	47	44	2	\N
1	48	44	3	2
1	49	44	9	\N
1	50	44	9	\N
1	51	44	9	\N
1	52	44	1	\N
1	53	44	1	9
1	54	44	7	\N
1	55	44	7	\N
1	56	44	1	1
1	57	44	1	1
1	58	44	1	\N
1	59	44	1	9
1	60	44	3	2
1	1	45	9	\N
1	2	45	9	\N
1	3	45	2	1
1	4	45	9	\N
1	5	45	9	\N
1	6	45	1	9
1	7	45	1	\N
1	8	45	9	\N
1	9	45	9	\N
1	10	45	9	\N
1	11	45	1	9
1	12	45	1	9
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
1	28	45	2	1
1	29	45	2	1
1	30	45	8	\N
1	31	45	8	\N
1	32	45	8	\N
1	33	45	1	1
1	34	45	8	\N
1	35	45	8	\N
1	36	45	8	\N
1	37	45	8	\N
1	38	45	8	\N
1	39	45	8	\N
1	40	45	8	\N
1	41	45	8	\N
1	42	45	8	\N
1	43	45	8	\N
1	44	45	8	\N
1	45	45	8	\N
1	46	45	2	1
1	47	45	2	\N
1	48	45	2	1
1	49	45	2	1
1	50	45	2	1
1	51	45	9	\N
1	52	45	9	\N
1	53	45	9	\N
1	54	45	7	\N
1	55	45	7	\N
1	56	45	1	1
1	57	45	6	\N
1	58	45	6	\N
1	59	45	1	1
1	60	45	1	9
1	1	46	9	\N
1	2	46	2	1
1	3	46	2	\N
1	4	46	2	1
1	5	46	9	\N
1	6	46	1	9
1	7	46	4	\N
1	8	46	1	9
1	9	46	1	9
1	10	46	6	\N
1	11	46	1	1
1	12	46	1	\N
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
1	27	46	8	\N
1	28	46	2	1
1	29	46	2	\N
1	30	46	8	\N
1	31	46	8	\N
1	32	46	8	\N
1	33	46	8	\N
1	34	46	8	\N
1	35	46	8	\N
1	36	46	4	\N
1	37	46	8	\N
1	38	46	8	\N
1	39	46	8	\N
1	40	46	8	\N
1	41	46	8	\N
1	42	46	8	\N
1	43	46	8	\N
1	44	46	8	\N
1	45	46	8	\N
1	46	46	8	\N
1	47	46	2	1
1	48	46	2	\N
1	49	46	2	1
1	50	46	2	\N
1	51	46	9	\N
1	52	46	3	\N
1	53	46	9	\N
1	54	46	7	\N
1	55	46	5	6
1	56	46	9	\N
1	57	46	9	\N
1	58	46	6	\N
1	59	46	1	1
1	60	46	1	\N
1	1	47	2	1
1	2	47	2	\N
1	3	47	3	3
1	4	47	2	\N
1	5	47	9	\N
1	6	47	9	\N
1	7	47	9	\N
1	8	47	9	\N
1	9	47	9	\N
1	10	47	9	\N
1	11	47	9	\N
1	12	47	8	\N
1	13	47	8	\N
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
1	26	47	8	\N
1	27	47	8	\N
1	28	47	2	1
1	29	47	2	\N
1	30	47	8	\N
1	31	47	8	\N
1	32	47	8	\N
1	33	47	8	\N
1	34	47	8	\N
1	35	47	8	\N
1	36	47	8	\N
1	37	47	8	\N
1	38	47	8	\N
1	39	47	8	\N
1	40	47	8	\N
1	41	47	8	\N
1	42	47	8	\N
1	43	47	8	\N
1	44	47	8	\N
1	45	47	8	\N
1	46	47	2	1
1	47	47	2	1
1	48	47	2	1
1	49	47	2	1
1	50	47	2	\N
1	51	47	2	1
1	52	47	2	\N
1	53	47	9	\N
1	54	47	7	\N
1	55	47	7	\N
1	56	47	9	\N
1	57	47	6	\N
1	58	47	4	\N
1	59	47	1	1
1	60	47	1	1
1	1	48	2	1
1	2	48	2	1
1	3	48	2	\N
1	4	48	2	\N
1	5	48	9	\N
1	6	48	6	\N
1	7	48	9	\N
1	8	48	6	\N
1	9	48	9	\N
1	10	48	4	7
1	11	48	8	\N
1	12	48	1	9
1	13	48	8	\N
1	14	48	6	\N
1	15	48	8	\N
1	16	48	8	\N
1	17	48	6	\N
1	18	48	8	\N
1	19	48	8	\N
1	20	48	4	7
1	21	48	8	\N
1	22	48	8	\N
1	23	48	8	\N
1	24	48	8	\N
1	25	48	8	\N
1	26	48	8	\N
1	27	48	8	\N
1	28	48	8	\N
1	29	48	2	1
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
1	40	48	3	\N
1	41	48	8	\N
1	42	48	8	\N
1	43	48	8	\N
1	44	48	8	\N
1	45	48	8	\N
1	46	48	8	\N
1	47	48	8	\N
1	48	48	2	1
1	49	48	2	\N
1	50	48	2	1
1	51	48	2	\N
1	52	48	2	1
1	53	48	9	\N
1	54	48	7	\N
1	55	48	7	\N
1	56	48	5	8
1	57	48	4	\N
1	58	48	4	\N
1	59	48	5	8
1	60	48	1	9
1	1	49	2	\N
1	2	49	2	\N
1	3	49	2	\N
1	4	49	4	\N
1	5	49	2	1
1	6	49	2	1
1	7	49	6	\N
1	8	49	6	\N
1	9	49	9	\N
1	10	49	8	\N
1	11	49	8	\N
1	12	49	8	\N
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
1	34	49	8	\N
1	35	49	8	\N
1	36	49	8	\N
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
1	49	49	2	\N
1	50	49	1	1
1	51	49	2	1
1	52	49	2	1
1	53	49	9	\N
1	54	49	9	\N
1	55	49	7	\N
1	56	49	7	\N
1	57	49	4	7
1	58	49	4	\N
1	59	49	4	7
1	60	49	2	\N
1	1	50	2	1
1	2	50	2	\N
1	3	50	5	6
1	4	50	6	\N
1	5	50	2	1
1	6	50	2	\N
1	7	50	2	1
1	8	50	6	\N
1	9	50	8	\N
1	10	50	8	\N
1	11	50	8	\N
1	12	50	8	\N
1	13	50	8	\N
1	14	50	8	\N
1	15	50	3	\N
1	16	50	8	\N
1	17	50	8	\N
1	18	50	8	\N
1	19	50	8	\N
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
1	36	50	3	3
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
1	49	50	1	1
1	50	50	1	1
1	51	50	6	\N
1	52	50	2	1
1	53	50	2	\N
1	54	50	9	\N
1	55	50	7	\N
1	56	50	9	\N
1	57	50	9	\N
1	58	50	4	\N
1	59	50	4	\N
1	60	50	4	\N
1	1	51	2	1
1	2	51	2	1
1	3	51	2	1
1	4	51	2	1
1	5	51	2	1
1	6	51	2	1
1	7	51	2	\N
1	8	51	8	\N
1	9	51	8	\N
1	10	51	8	\N
1	11	51	8	\N
1	12	51	8	\N
1	13	51	8	\N
1	14	51	8	\N
1	15	51	8	\N
1	16	51	8	\N
1	17	51	8	\N
1	18	51	8	\N
1	19	51	8	\N
1	20	51	8	\N
1	21	51	8	\N
1	22	51	8	\N
1	23	51	8	\N
1	24	51	8	\N
1	25	51	8	\N
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
1	49	51	1	1
1	50	51	1	\N
1	51	51	1	\N
1	52	51	2	\N
1	53	51	2	1
1	54	51	9	\N
1	55	51	7	\N
1	56	51	2	1
1	57	51	2	1
1	58	51	4	\N
1	59	51	4	7
1	60	51	4	\N
1	1	52	3	3
1	2	52	2	1
1	3	52	2	1
1	4	52	2	1
1	5	52	2	\N
1	6	52	2	1
1	7	52	2	1
1	8	52	8	\N
1	9	52	8	\N
1	10	52	3	\N
1	11	52	8	\N
1	12	52	8	\N
1	13	52	8	\N
1	14	52	8	\N
1	15	52	8	\N
1	16	52	8	\N
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
1	31	52	3	2
1	32	52	8	\N
1	33	52	8	\N
1	34	52	8	\N
1	35	52	8	\N
1	36	52	8	\N
1	37	52	8	\N
1	38	52	8	\N
1	39	52	5	8
1	40	52	8	\N
1	41	52	8	\N
1	42	52	8	\N
1	43	52	8	\N
1	44	52	8	\N
1	45	52	8	\N
1	46	52	8	\N
1	47	52	8	\N
1	48	52	8	\N
1	49	52	1	9
1	50	52	1	\N
1	51	52	1	9
1	52	52	1	1
1	53	52	2	1
1	54	52	2	1
1	55	52	2	1
1	56	52	2	1
1	57	52	6	\N
1	58	52	4	\N
1	59	52	4	\N
1	60	52	4	7
1	1	53	2	1
1	2	53	2	1
1	3	53	2	1
1	4	53	6	\N
1	5	53	4	7
1	6	53	1	9
1	7	53	2	\N
1	8	53	5	6
1	9	53	8	\N
1	10	53	8	\N
1	11	53	8	\N
1	12	53	1	\N
1	13	53	8	\N
1	14	53	8	\N
1	15	53	1	1
1	16	53	8	\N
1	17	53	8	\N
1	18	53	8	\N
1	19	53	8	\N
1	20	53	8	\N
1	21	53	8	\N
1	22	53	8	\N
1	23	53	8	\N
1	24	53	4	7
1	25	53	8	\N
1	26	53	8	\N
1	27	53	8	\N
1	28	53	8	\N
1	29	53	8	\N
1	30	53	8	\N
1	31	53	8	\N
1	32	53	8	\N
1	33	53	8	\N
1	34	53	1	9
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
1	50	53	1	9
1	51	53	1	\N
1	52	53	1	1
1	53	53	3	2
1	54	53	2	\N
1	55	53	2	1
1	56	53	2	1
1	57	53	2	\N
1	58	53	6	\N
1	59	53	9	\N
1	60	53	4	7
1	1	54	2	\N
1	2	54	2	1
1	3	54	2	1
1	4	54	2	1
1	5	54	1	1
1	6	54	1	1
1	7	54	1	1
1	8	54	1	\N
1	9	54	8	\N
1	10	54	1	1
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
1	24	54	8	\N
1	25	54	8	\N
1	26	54	8	\N
1	27	54	8	\N
1	28	54	5	8
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
1	47	54	8	\N
1	48	54	8	\N
1	49	54	8	\N
1	50	54	1	1
1	51	54	1	1
1	52	54	1	9
1	53	54	1	9
1	54	54	2	1
1	55	54	7	\N
1	56	54	2	1
1	57	54	2	1
1	58	54	2	1
1	59	54	9	\N
1	60	54	9	\N
1	1	55	2	\N
1	2	55	2	1
1	3	55	9	\N
1	4	55	9	\N
1	5	55	9	\N
1	6	55	1	\N
1	7	55	7	\N
1	8	55	1	1
1	9	55	1	1
1	10	55	8	\N
1	11	55	8	\N
1	12	55	8	\N
1	13	55	8	\N
1	14	55	8	\N
1	15	55	8	\N
1	16	55	8	\N
1	17	55	3	2
1	18	55	8	\N
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
1	51	55	1	\N
1	52	55	6	\N
1	53	55	1	1
1	54	55	1	\N
1	55	55	2	1
1	56	55	2	1
1	57	55	2	1
1	58	55	2	1
1	59	55	2	\N
1	60	55	2	1
1	1	56	2	1
1	2	56	2	1
1	3	56	2	1
1	4	56	9	\N
1	5	56	1	1
1	6	56	1	9
1	7	56	1	1
1	8	56	1	9
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
1	25	56	8	\N
1	26	56	8	\N
1	27	56	8	\N
1	28	56	8	\N
1	29	56	8	\N
1	30	56	1	1
1	31	56	8	\N
1	32	56	8	\N
1	33	56	8	\N
1	34	56	8	\N
1	35	56	8	\N
1	36	56	8	\N
1	37	56	7	\N
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
1	51	56	1	9
1	52	56	1	1
1	53	56	1	9
1	54	56	1	\N
1	55	56	1	9
1	56	56	2	1
1	57	56	7	\N
1	58	56	2	\N
1	59	56	7	\N
1	60	56	2	\N
1	1	57	2	\N
1	2	57	2	\N
1	3	57	2	1
1	4	57	9	\N
1	5	57	7	\N
1	6	57	1	1
1	7	57	4	7
1	8	57	1	9
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
1	46	57	2	1
1	47	57	8	\N
1	48	57	8	\N
1	49	57	8	\N
1	50	57	8	\N
1	51	57	8	\N
1	52	57	8	\N
1	53	57	1	1
1	54	57	1	9
1	55	57	1	\N
1	56	57	3	3
1	57	57	2	1
1	58	57	2	1
1	59	57	2	1
1	60	57	2	1
1	1	58	9	\N
1	2	58	9	\N
1	3	58	2	1
1	4	58	1	9
1	5	58	1	\N
1	6	58	1	1
1	7	58	3	2
1	8	58	1	9
1	9	58	3	3
1	10	58	8	\N
1	11	58	8	\N
1	12	58	8	\N
1	13	58	8	\N
1	14	58	8	\N
1	15	58	8	\N
1	16	58	8	\N
1	17	58	8	\N
1	18	58	8	\N
1	19	58	8	\N
1	20	58	8	\N
1	21	58	8	\N
1	22	58	8	\N
1	23	58	1	\N
1	24	58	8	\N
1	25	58	8	\N
1	26	58	8	\N
1	27	58	4	7
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
1	49	58	6	\N
1	50	58	8	\N
1	51	58	8	\N
1	52	58	8	\N
1	53	58	4	7
1	54	58	1	1
1	55	58	1	1
1	56	58	1	1
1	57	58	2	\N
1	58	58	2	\N
1	59	58	2	1
1	60	58	2	\N
1	1	59	4	\N
1	2	59	2	\N
1	3	59	2	1
1	4	59	1	9
1	5	59	1	1
1	6	59	1	9
1	7	59	1	9
1	8	59	1	9
1	9	59	1	1
1	10	59	6	\N
1	11	59	8	\N
1	12	59	1	1
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
1	25	59	2	\N
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
1	38	59	7	\N
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
1	53	59	1	9
1	54	59	1	\N
1	55	59	1	1
1	56	59	1	\N
1	57	59	1	1
1	58	59	4	7
1	59	59	2	1
1	60	59	2	\N
1	1	60	2	1
1	2	60	2	1
1	3	60	2	1
1	4	60	1	\N
1	5	60	1	\N
1	6	60	1	9
1	7	60	1	\N
1	8	60	1	\N
1	9	60	1	9
1	10	60	1	9
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
1	27	60	8	\N
1	28	60	8	\N
1	29	60	8	\N
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
1	47	60	3	2
1	48	60	8	\N
1	49	60	8	\N
1	50	60	8	\N
1	51	60	8	\N
1	52	60	8	\N
1	53	60	8	\N
1	54	60	1	9
1	55	60	6	\N
1	56	60	1	\N
1	57	60	1	9
1	58	60	1	\N
1	59	60	2	1
1	60	60	3	\N
\.


--
-- TOC entry 5516 (class 0 OID 22808)
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
2	1	5	1
2	1	5	2
2	1	6	2
2	1	5	3
2	1	7	2
2	1	6	3
2	1	4	3
2	1	5	4
2	1	3	3
3	1	7	1
3	1	8	1
3	1	9	1
3	1	8	2
3	1	10	1
3	1	9	2
3	1	10	2
3	1	9	3
4	1	11	1
4	1	12	1
4	1	11	2
4	1	13	1
4	1	12	2
4	1	13	2
4	1	12	3
4	1	11	3
5	1	14	1
5	1	15	1
5	1	14	2
5	1	15	2
5	1	14	3
5	1	16	2
5	1	15	3
5	1	17	2
5	1	16	3
6	1	16	1
7	1	18	1
7	1	19	1
7	1	18	2
7	1	19	2
7	1	18	3
7	1	20	2
7	1	19	3
7	1	21	2
7	1	20	3
7	1	20	1
8	1	21	1
8	1	22	1
8	1	23	1
8	1	22	2
8	1	23	2
8	1	22	3
8	1	24	2
8	1	23	3
8	1	24	3
9	1	24	1
9	1	25	1
9	1	26	1
9	1	25	2
9	1	27	1
9	1	26	2
9	1	28	1
9	1	27	2
9	1	26	3
9	1	28	2
10	1	29	1
10	1	30	1
10	1	29	2
10	1	30	2
10	1	29	3
10	1	30	3
10	1	28	3
10	1	29	4
10	1	28	4
11	1	32	1
11	1	33	1
11	1	34	1
11	1	33	2
11	1	34	2
11	1	33	3
11	1	35	1
11	1	36	1
11	1	35	2
11	1	37	1
12	1	38	1
12	1	39	1
12	1	38	2
12	1	40	1
12	1	39	2
12	1	37	2
12	1	38	3
12	1	36	2
13	1	41	1
13	1	42	1
13	1	41	2
13	1	43	1
13	1	42	2
13	1	44	1
13	1	43	2
13	1	45	1
14	1	46	1
14	1	47	1
14	1	46	2
14	1	48	1
14	1	47	2
14	1	49	1
14	1	48	2
14	1	47	3
15	1	50	1
15	1	51	1
15	1	50	2
15	1	51	2
15	1	49	2
15	1	50	3
15	1	49	3
15	1	48	3
15	1	49	4
16	1	52	1
16	1	53	1
16	1	52	2
16	1	53	2
16	1	52	3
16	1	54	2
16	1	51	3
16	1	52	4
16	1	55	2
17	1	55	1
17	1	56	1
17	1	57	1
17	1	56	2
17	1	58	1
17	1	57	2
17	1	56	3
17	1	57	3
17	1	55	3
17	1	56	4
18	1	59	1
18	1	60	1
18	1	59	2
18	1	60	2
18	1	58	2
18	1	59	3
18	1	60	3
18	1	58	3
18	1	59	4
18	1	58	4
19	1	3	2
20	1	40	2
20	1	40	3
20	1	41	3
20	1	39	3
20	1	42	3
20	1	43	3
20	1	44	3
20	1	43	4
20	1	44	4
20	1	43	5
21	1	44	2
21	1	45	2
21	1	45	3
21	1	46	3
21	1	45	4
21	1	46	4
21	1	45	5
21	1	47	4
22	1	7	3
22	1	8	3
22	1	7	4
22	1	8	4
22	1	9	4
22	1	8	5
22	1	9	5
22	1	7	5
22	1	8	6
22	1	6	4
23	1	10	3
23	1	10	4
23	1	10	5
24	1	13	3
25	1	17	3
25	1	17	4
25	1	18	4
25	1	17	5
25	1	19	4
25	1	18	5
25	1	16	5
25	1	17	6
25	1	20	4
26	1	21	3
26	1	21	4
26	1	22	4
26	1	21	5
26	1	22	5
26	1	20	5
26	1	21	6
26	1	22	6
26	1	20	6
27	1	25	3
27	1	25	4
27	1	26	4
27	1	24	4
27	1	27	4
27	1	26	5
27	1	27	5
27	1	23	4
28	1	31	3
28	1	32	3
28	1	31	4
28	1	30	4
28	1	31	5
28	1	30	5
28	1	31	6
28	1	29	5
28	1	30	6
28	1	31	7
29	1	34	3
29	1	35	3
29	1	36	3
29	1	35	4
29	1	37	3
29	1	35	5
29	1	36	5
29	1	34	5
29	1	35	6
29	1	37	5
30	1	54	3
30	1	54	4
30	1	53	4
31	1	2	4
31	1	3	4
31	1	2	5
31	1	4	4
31	1	3	5
31	1	4	5
31	1	3	6
31	1	4	6
31	1	2	6
32	1	12	4
33	1	48	4
33	1	48	5
33	1	49	5
33	1	48	6
33	1	50	5
33	1	49	6
33	1	50	6
33	1	49	7
33	1	51	5
33	1	50	4
34	1	51	4
35	1	57	4
35	1	57	5
35	1	58	5
35	1	56	5
35	1	57	6
35	1	55	5
35	1	59	5
35	1	58	6
36	1	60	4
36	1	60	5
36	1	60	6
36	1	59	6
36	1	60	7
36	1	59	7
36	1	58	7
36	1	59	8
36	1	58	8
36	1	59	9
37	1	1	5
37	1	1	6
37	1	1	7
37	1	2	7
37	1	1	8
37	1	2	8
37	1	1	9
37	1	3	8
37	1	2	9
38	1	5	5
38	1	6	5
38	1	5	6
38	1	6	6
38	1	5	7
38	1	7	6
38	1	6	7
38	1	7	7
38	1	8	7
38	1	7	8
39	1	13	5
39	1	14	5
39	1	13	6
39	1	14	6
39	1	15	6
39	1	14	7
39	1	15	5
39	1	16	6
39	1	15	7
40	1	19	5
40	1	19	6
40	1	18	6
40	1	19	7
40	1	18	7
40	1	17	7
40	1	18	8
40	1	19	8
40	1	17	8
40	1	18	9
41	1	23	5
41	1	24	5
41	1	23	6
41	1	24	6
41	1	25	6
41	1	24	7
41	1	26	6
41	1	25	7
41	1	27	6
41	1	26	7
42	1	28	5
42	1	28	6
42	1	29	6
42	1	28	7
42	1	29	7
42	1	27	7
42	1	28	8
42	1	30	7
43	1	33	5
44	1	39	5
44	1	39	6
44	1	38	6
44	1	39	7
44	1	37	6
44	1	38	7
44	1	40	7
44	1	39	8
45	1	44	5
45	1	44	6
45	1	45	6
45	1	43	6
45	1	44	7
45	1	46	6
45	1	45	7
45	1	42	6
46	1	46	5
47	1	9	6
47	1	9	7
47	1	10	7
47	1	9	8
47	1	10	8
47	1	8	8
47	1	9	9
47	1	10	9
47	1	8	9
48	1	36	6
48	1	36	7
48	1	37	7
48	1	35	7
48	1	36	8
48	1	37	8
48	1	38	8
48	1	37	9
49	1	41	6
49	1	41	7
49	1	42	7
49	1	41	8
49	1	42	8
49	1	40	8
49	1	41	9
49	1	43	7
49	1	43	8
50	1	47	6
50	1	47	7
50	1	48	7
50	1	46	7
50	1	47	8
50	1	48	8
50	1	49	8
50	1	50	8
50	1	46	8
50	1	47	9
51	1	51	6
51	1	52	6
51	1	51	7
51	1	52	7
51	1	50	7
51	1	51	8
51	1	53	6
51	1	53	7
51	1	52	8
52	1	3	7
52	1	4	7
52	1	4	8
52	1	5	8
52	1	4	9
52	1	5	9
52	1	3	9
52	1	6	8
53	1	16	7
53	1	16	8
54	1	20	7
54	1	21	7
54	1	20	8
54	1	21	8
54	1	22	8
54	1	22	7
54	1	23	8
54	1	23	7
54	1	24	8
55	1	55	7
56	1	25	8
56	1	26	8
56	1	25	9
56	1	27	8
56	1	26	9
56	1	27	9
56	1	26	10
56	1	27	10
56	1	25	10
56	1	26	11
57	1	29	8
57	1	30	8
57	1	29	9
57	1	31	8
57	1	30	9
57	1	31	9
57	1	32	8
57	1	32	9
58	1	34	8
58	1	35	8
58	1	34	9
58	1	35	9
58	1	36	9
58	1	35	10
58	1	36	10
58	1	37	10
59	1	44	8
59	1	45	8
59	1	44	9
59	1	45	9
59	1	43	9
59	1	44	10
59	1	42	9
59	1	43	10
60	1	53	8
60	1	53	9
60	1	52	9
60	1	53	10
60	1	52	10
60	1	53	11
60	1	54	11
60	1	52	11
60	1	53	12
61	1	56	8
61	1	57	8
61	1	56	9
61	1	57	9
61	1	55	9
61	1	56	10
61	1	57	10
61	1	55	10
62	1	6	9
62	1	7	9
62	1	7	10
62	1	8	10
62	1	7	11
62	1	9	10
62	1	8	11
62	1	10	10
62	1	9	11
62	1	10	11
63	1	17	9
63	1	17	10
63	1	18	10
63	1	19	10
63	1	18	11
63	1	19	11
63	1	20	11
63	1	19	12
64	1	23	9
64	1	24	9
64	1	23	10
64	1	24	10
64	1	22	10
64	1	23	11
64	1	24	11
64	1	25	11
64	1	24	12
65	1	28	9
65	1	28	10
65	1	28	11
65	1	29	11
65	1	27	11
65	1	30	11
65	1	31	11
65	1	32	11
65	1	31	10
65	1	33	11
66	1	38	9
66	1	39	9
66	1	38	10
66	1	40	9
66	1	39	10
66	1	40	10
66	1	41	10
66	1	42	10
66	1	41	11
67	1	46	9
67	1	46	10
67	1	47	10
67	1	45	10
67	1	48	10
67	1	47	11
67	1	45	11
67	1	48	11
67	1	48	12
67	1	44	11
68	1	58	9
68	1	58	10
68	1	59	10
68	1	58	11
68	1	59	11
68	1	59	12
68	1	57	11
68	1	58	12
68	1	60	12
69	1	1	10
69	1	2	10
69	1	1	11
69	1	2	11
69	1	2	12
69	1	1	12
69	1	2	13
69	1	1	13
70	1	14	10
71	1	21	10
71	1	21	11
71	1	22	11
71	1	21	12
71	1	22	12
71	1	23	12
71	1	20	12
71	1	21	13
71	1	20	13
72	1	32	10
73	1	50	10
73	1	50	11
73	1	51	11
73	1	50	12
73	1	51	12
73	1	49	12
73	1	50	13
73	1	49	13
74	1	4	11
74	1	5	11
74	1	4	12
74	1	5	12
74	1	4	13
74	1	5	13
74	1	3	13
74	1	4	14
74	1	3	14
74	1	6	13
75	1	6	11
75	1	6	12
75	1	7	12
75	1	8	12
75	1	7	13
75	1	8	13
75	1	7	14
75	1	9	13
75	1	8	14
76	1	42	11
76	1	43	11
76	1	42	12
76	1	43	12
76	1	44	12
76	1	43	13
76	1	45	12
76	1	44	13
76	1	46	12
76	1	45	13
77	1	55	11
77	1	56	11
77	1	55	12
77	1	56	12
77	1	54	12
77	1	55	13
77	1	54	13
77	1	53	13
78	1	9	12
78	1	10	12
78	1	10	13
78	1	11	13
78	1	10	14
78	1	11	14
78	1	12	14
78	1	11	15
79	1	13	12
80	1	18	12
80	1	18	13
80	1	19	13
80	1	18	14
80	1	19	14
80	1	20	14
80	1	19	15
80	1	20	15
80	1	18	15
81	1	25	12
81	1	25	13
81	1	26	13
81	1	24	13
81	1	25	14
81	1	24	14
81	1	26	14
81	1	25	15
81	1	26	15
81	1	23	14
82	1	34	12
82	1	35	12
82	1	34	13
82	1	35	13
82	1	36	13
82	1	35	14
82	1	36	14
82	1	34	14
82	1	33	13
83	1	37	12
83	1	38	12
83	1	37	13
83	1	38	13
83	1	38	14
83	1	37	14
84	1	40	12
84	1	41	12
84	1	41	13
84	1	41	14
84	1	42	14
84	1	40	14
84	1	41	15
84	1	40	15
84	1	40	16
85	1	47	12
85	1	47	13
85	1	48	13
85	1	46	13
85	1	47	14
85	1	46	14
85	1	48	14
85	1	47	15
85	1	48	15
86	1	52	12
86	1	52	13
86	1	51	13
86	1	52	14
86	1	53	14
86	1	51	14
86	1	52	15
86	1	51	15
86	1	52	16
87	1	57	12
87	1	57	13
87	1	58	13
87	1	56	13
87	1	57	14
87	1	59	13
87	1	58	14
87	1	56	14
87	1	57	15
87	1	55	14
88	1	28	13
88	1	29	13
89	1	32	13
89	1	32	14
89	1	33	14
89	1	31	14
89	1	32	15
89	1	30	14
89	1	31	15
89	1	33	15
89	1	30	15
89	1	31	16
90	1	60	13
90	1	60	14
90	1	59	14
90	1	60	15
90	1	59	15
90	1	60	16
90	1	59	16
90	1	60	17
91	1	1	14
91	1	2	14
91	1	1	15
91	1	2	15
91	1	1	16
91	1	3	15
91	1	2	16
91	1	3	16
91	1	2	17
92	1	5	14
92	1	6	14
92	1	5	15
92	1	6	15
92	1	4	15
92	1	5	16
92	1	4	16
92	1	5	17
93	1	9	14
93	1	9	15
93	1	10	15
93	1	8	15
93	1	7	15
93	1	8	16
93	1	7	16
93	1	8	17
94	1	21	14
94	1	21	15
94	1	22	15
94	1	21	16
94	1	23	15
94	1	22	16
94	1	24	15
94	1	23	16
94	1	20	16
95	1	43	14
95	1	44	14
95	1	43	15
95	1	45	14
95	1	44	15
95	1	45	15
95	1	46	15
95	1	45	16
95	1	42	15
95	1	43	16
96	1	49	14
96	1	50	14
96	1	49	15
96	1	50	15
96	1	49	16
96	1	50	16
96	1	48	16
96	1	49	17
97	1	54	14
98	1	12	15
99	1	29	15
99	1	29	16
99	1	30	16
99	1	28	16
100	1	34	15
100	1	34	16
100	1	33	16
100	1	34	17
100	1	32	16
100	1	33	17
100	1	32	17
100	1	33	18
101	1	55	15
101	1	55	16
101	1	54	16
101	1	55	17
101	1	56	17
101	1	55	18
101	1	57	17
101	1	56	18
101	1	57	18
102	1	58	15
102	1	58	16
102	1	57	16
102	1	58	17
102	1	59	17
102	1	58	18
102	1	59	18
102	1	58	19
102	1	60	18
102	1	59	19
103	1	19	16
104	1	24	16
104	1	25	16
104	1	24	17
104	1	25	17
104	1	24	18
104	1	26	17
104	1	25	18
104	1	23	18
105	1	26	16
106	1	36	16
106	1	37	16
106	1	36	17
106	1	38	16
106	1	37	17
106	1	38	17
106	1	37	18
106	1	38	18
106	1	39	18
106	1	38	19
107	1	41	16
107	1	42	16
107	1	41	17
107	1	42	17
107	1	40	17
107	1	41	18
107	1	40	18
107	1	42	18
107	1	41	19
108	1	44	16
108	1	44	17
108	1	45	17
108	1	43	17
108	1	44	18
108	1	45	18
108	1	43	18
108	1	44	19
109	1	46	16
109	1	47	16
109	1	46	17
109	1	47	17
109	1	46	18
109	1	48	17
109	1	47	18
109	1	48	18
109	1	49	18
110	1	51	16
110	1	51	17
110	1	52	17
110	1	50	17
110	1	51	18
110	1	52	18
110	1	52	19
110	1	50	18
111	1	1	17
111	1	1	18
111	1	2	18
111	1	1	19
111	1	3	18
111	1	2	19
111	1	3	19
111	1	2	20
111	1	4	18
112	1	3	17
112	1	4	17
113	1	6	17
113	1	7	17
113	1	6	18
113	1	7	18
113	1	8	18
113	1	7	19
113	1	5	18
113	1	6	19
114	1	11	17
115	1	20	17
115	1	21	17
115	1	22	17
115	1	21	18
115	1	22	18
115	1	21	19
115	1	22	19
115	1	23	19
116	1	10	18
116	1	10	19
116	1	11	19
116	1	9	19
116	1	10	20
116	1	8	19
116	1	9	20
116	1	8	20
116	1	9	21
117	1	26	18
117	1	27	18
117	1	26	19
117	1	27	19
117	1	25	19
117	1	26	20
117	1	27	20
117	1	25	20
118	1	29	18
118	1	29	19
118	1	29	20
118	1	30	20
118	1	28	20
118	1	29	21
118	1	28	21
118	1	31	20
119	1	31	18
119	1	32	18
119	1	32	19
119	1	33	19
119	1	32	20
119	1	33	20
119	1	32	21
119	1	34	20
119	1	33	21
119	1	34	21
120	1	34	18
120	1	34	19
120	1	35	19
120	1	36	19
120	1	35	20
120	1	37	19
120	1	36	20
120	1	36	18
121	1	54	18
121	1	54	19
121	1	55	19
121	1	53	19
121	1	54	20
121	1	56	19
121	1	55	20
121	1	53	20
122	1	4	19
122	1	5	19
122	1	4	20
122	1	5	20
122	1	3	20
122	1	6	20
122	1	5	21
122	1	3	21
123	1	24	19
123	1	24	20
124	1	39	19
124	1	40	19
124	1	39	20
124	1	40	20
124	1	38	20
124	1	39	21
124	1	40	21
124	1	38	21
124	1	39	22
125	1	42	19
125	1	43	19
125	1	42	20
125	1	43	20
125	1	41	20
125	1	44	20
125	1	43	21
125	1	44	21
125	1	45	21
125	1	44	22
126	1	45	19
126	1	46	19
126	1	45	20
126	1	46	20
126	1	47	20
126	1	46	21
126	1	47	19
126	1	47	21
127	1	48	19
127	1	49	19
127	1	50	19
127	1	49	20
127	1	51	19
127	1	50	20
127	1	50	21
127	1	51	21
127	1	50	22
128	1	57	19
128	1	57	20
128	1	58	20
128	1	56	20
128	1	57	21
128	1	56	21
128	1	55	21
128	1	56	22
128	1	54	21
129	1	60	19
129	1	60	20
129	1	59	20
129	1	60	21
129	1	59	21
129	1	60	22
129	1	59	22
129	1	60	23
129	1	58	22
129	1	59	23
130	1	1	20
130	1	1	21
130	1	2	21
130	1	1	22
130	1	2	22
130	1	3	22
130	1	2	23
130	1	3	23
131	1	7	20
131	1	7	21
131	1	8	21
131	1	6	21
131	1	8	22
131	1	6	22
131	1	6	23
131	1	7	23
132	1	11	20
132	1	12	20
132	1	11	21
132	1	12	21
132	1	12	22
132	1	13	22
132	1	11	22
132	1	12	23
132	1	10	21
133	1	37	20
133	1	37	21
133	1	36	21
133	1	37	22
133	1	35	21
133	1	36	22
133	1	35	22
133	1	36	23
134	1	52	20
134	1	52	21
134	1	53	21
134	1	52	22
134	1	51	22
135	1	14	21
136	1	19	21
137	1	25	21
137	1	26	21
137	1	25	22
137	1	26	22
137	1	25	23
137	1	27	21
137	1	26	23
137	1	25	24
137	1	27	22
138	1	30	21
138	1	31	21
138	1	30	22
138	1	31	22
138	1	29	22
138	1	30	23
138	1	31	23
138	1	29	23
138	1	30	24
139	1	41	21
139	1	41	22
139	1	40	22
139	1	41	23
139	1	40	23
139	1	42	23
139	1	41	24
139	1	42	24
140	1	58	21
141	1	9	22
141	1	10	22
141	1	9	23
141	1	10	23
141	1	11	23
141	1	8	23
141	1	9	24
141	1	8	24
141	1	9	25
141	1	7	24
142	1	28	22
142	1	28	23
142	1	27	23
142	1	28	24
142	1	27	24
142	1	29	24
142	1	28	25
142	1	26	24
143	1	32	22
143	1	33	22
143	1	32	23
143	1	34	22
143	1	33	23
143	1	32	24
143	1	33	24
143	1	31	24
144	1	38	22
144	1	38	23
144	1	39	23
144	1	37	23
144	1	38	24
144	1	39	24
144	1	37	24
144	1	38	25
144	1	36	24
144	1	37	25
145	1	45	22
145	1	46	22
145	1	45	23
145	1	47	22
145	1	46	23
145	1	47	23
145	1	46	24
145	1	47	24
145	1	45	24
146	1	49	22
147	1	54	22
147	1	55	22
147	1	54	23
147	1	55	23
147	1	56	23
147	1	55	24
147	1	57	23
147	1	56	24
147	1	54	24
147	1	55	25
148	1	57	22
149	1	1	23
149	1	1	24
149	1	2	24
149	1	3	24
149	1	2	25
149	1	4	24
149	1	3	25
149	1	5	24
149	1	4	25
149	1	4	23
150	1	5	23
151	1	35	23
151	1	35	24
151	1	35	25
151	1	36	25
151	1	34	25
151	1	35	26
151	1	36	26
151	1	33	25
152	1	43	23
152	1	44	23
152	1	43	24
152	1	43	25
152	1	44	25
152	1	42	25
152	1	43	26
152	1	41	25
152	1	42	26
153	1	58	23
153	1	58	24
153	1	59	24
153	1	57	24
153	1	58	25
153	1	60	24
153	1	59	25
153	1	57	25
153	1	58	26
153	1	56	25
154	1	6	24
154	1	6	25
154	1	7	25
154	1	5	25
154	1	6	26
154	1	8	25
154	1	7	26
154	1	8	26
154	1	7	27
154	1	8	27
155	1	40	24
155	1	40	25
155	1	39	25
155	1	40	26
155	1	41	26
155	1	39	26
155	1	40	27
155	1	41	27
155	1	39	27
155	1	40	28
156	1	48	24
156	1	49	24
156	1	48	25
156	1	49	25
156	1	50	25
156	1	49	26
156	1	51	25
156	1	50	26
156	1	51	26
157	1	51	24
158	1	10	25
158	1	10	26
158	1	9	26
158	1	10	27
158	1	10	28
158	1	10	29
158	1	9	29
158	1	8	29
158	1	9	30
159	1	22	25
160	1	26	25
160	1	27	25
160	1	26	26
160	1	27	26
160	1	28	26
160	1	27	27
160	1	29	26
160	1	28	27
160	1	30	26
160	1	29	27
161	1	29	25
161	1	30	25
162	1	45	25
162	1	46	25
162	1	45	26
162	1	46	26
162	1	44	26
162	1	45	27
162	1	44	27
162	1	46	27
162	1	45	28
162	1	47	25
163	1	53	25
163	1	54	25
163	1	53	26
163	1	54	26
163	1	55	26
163	1	54	27
163	1	55	27
163	1	53	27
163	1	54	28
163	1	52	27
164	1	60	25
164	1	60	26
164	1	59	26
164	1	60	27
164	1	59	27
164	1	60	28
164	1	59	28
164	1	58	27
165	1	2	26
165	1	3	26
165	1	2	27
165	1	4	26
165	1	3	27
165	1	1	27
165	1	2	28
165	1	3	28
165	1	1	28
165	1	2	29
166	1	5	26
166	1	5	27
166	1	6	27
166	1	4	27
166	1	5	28
166	1	6	28
166	1	7	28
166	1	6	29
167	1	32	26
167	1	33	26
167	1	32	27
167	1	34	26
167	1	33	27
167	1	31	27
167	1	32	28
167	1	34	27
167	1	30	27
168	1	37	26
168	1	38	26
168	1	37	27
168	1	38	27
168	1	36	27
168	1	35	27
168	1	36	28
168	1	35	28
169	1	47	26
169	1	48	26
169	1	47	27
169	1	48	27
169	1	49	27
169	1	48	28
169	1	49	28
169	1	47	28
170	1	52	26
171	1	56	26
171	1	57	26
171	1	56	27
171	1	57	27
171	1	56	28
171	1	57	28
171	1	55	28
171	1	56	29
172	1	42	27
172	1	43	27
172	1	42	28
172	1	43	28
172	1	41	28
172	1	42	29
172	1	43	29
172	1	41	29
172	1	42	30
172	1	40	29
173	1	50	27
173	1	51	27
173	1	50	28
173	1	51	28
173	1	50	29
173	1	52	28
173	1	51	29
173	1	49	29
173	1	50	30
174	1	4	28
174	1	4	29
174	1	5	29
174	1	3	29
174	1	4	30
174	1	5	30
174	1	3	30
174	1	4	31
175	1	8	28
176	1	21	28
177	1	28	28
177	1	28	29
177	1	29	29
177	1	27	29
177	1	28	30
177	1	27	30
177	1	27	31
177	1	28	31
178	1	31	28
178	1	31	29
178	1	32	29
178	1	31	30
178	1	32	30
178	1	30	30
178	1	31	31
178	1	29	30
178	1	30	31
179	1	33	28
179	1	34	28
179	1	33	29
179	1	34	29
179	1	33	30
179	1	34	30
179	1	33	31
179	1	35	29
179	1	35	30
179	1	34	31
180	1	38	28
180	1	39	28
180	1	38	29
180	1	39	29
180	1	37	29
180	1	38	30
180	1	39	30
180	1	37	30
181	1	44	28
181	1	44	29
181	1	45	29
181	1	44	30
181	1	46	29
181	1	45	30
181	1	43	30
181	1	44	31
181	1	46	30
182	1	46	28
183	1	53	28
183	1	53	29
183	1	54	29
183	1	52	29
183	1	53	30
183	1	52	30
183	1	51	30
183	1	52	31
183	1	51	31
184	1	58	28
184	1	58	29
184	1	59	29
184	1	57	29
185	1	1	29
185	1	1	30
185	1	2	30
185	1	1	31
185	1	2	31
185	1	1	32
185	1	3	31
185	1	2	32
186	1	7	29
186	1	7	30
186	1	8	30
186	1	6	30
186	1	7	31
186	1	6	31
186	1	8	31
186	1	7	32
186	1	8	32
186	1	6	32
187	1	15	29
188	1	36	29
188	1	36	30
188	1	36	31
188	1	37	31
188	1	35	31
188	1	36	32
188	1	37	32
188	1	35	32
188	1	36	33
189	1	47	29
189	1	48	29
189	1	47	30
189	1	48	30
189	1	49	30
189	1	48	31
189	1	47	31
189	1	48	32
189	1	49	32
190	1	55	29
190	1	55	30
190	1	56	30
190	1	54	30
190	1	55	31
190	1	56	31
190	1	54	31
190	1	55	32
190	1	57	31
190	1	53	31
191	1	16	30
192	1	40	30
192	1	41	30
192	1	40	31
192	1	41	31
192	1	42	31
192	1	41	32
192	1	42	32
192	1	39	31
192	1	40	32
192	1	43	32
193	1	60	30
193	1	60	31
193	1	59	31
193	1	60	32
193	1	59	32
193	1	60	33
193	1	59	33
193	1	60	34
193	1	59	34
194	1	5	31
194	1	5	32
194	1	4	32
194	1	3	32
194	1	4	33
194	1	3	33
194	1	4	34
194	1	3	34
194	1	4	35
194	1	5	35
195	1	9	31
195	1	9	32
195	1	10	32
196	1	11	31
197	1	29	31
198	1	32	31
198	1	32	32
198	1	33	32
198	1	31	32
198	1	32	33
198	1	34	32
198	1	33	33
198	1	34	33
198	1	31	33
199	1	38	31
199	1	38	32
199	1	39	32
199	1	38	33
199	1	39	33
199	1	37	33
199	1	38	34
199	1	37	34
199	1	40	33
199	1	39	34
200	1	45	31
200	1	46	31
200	1	45	32
200	1	46	32
200	1	47	32
200	1	46	33
200	1	45	33
200	1	46	34
201	1	50	31
201	1	50	32
201	1	51	32
201	1	50	33
201	1	51	33
201	1	50	34
201	1	52	32
201	1	53	32
201	1	52	33
201	1	51	34
202	1	13	32
203	1	22	32
204	1	28	32
204	1	28	33
204	1	29	33
204	1	29	34
204	1	30	34
204	1	31	34
204	1	30	35
204	1	31	35
204	1	30	36
205	1	44	32
205	1	44	33
205	1	43	33
205	1	44	34
205	1	45	34
205	1	43	34
205	1	44	35
205	1	45	35
206	1	54	32
206	1	54	33
206	1	55	33
206	1	53	33
206	1	54	34
206	1	55	34
206	1	53	34
206	1	54	35
207	1	57	32
207	1	58	32
207	1	57	33
207	1	58	33
207	1	56	33
207	1	57	34
207	1	58	34
207	1	56	34
207	1	57	35
207	1	58	35
208	1	1	33
208	1	2	33
208	1	1	34
208	1	2	34
208	1	1	35
208	1	2	35
208	1	1	36
208	1	2	36
208	1	1	37
209	1	8	33
210	1	18	33
211	1	35	33
211	1	35	34
211	1	36	34
211	1	34	34
211	1	33	34
211	1	32	34
211	1	33	35
212	1	41	33
212	1	42	33
212	1	41	34
212	1	42	34
212	1	40	34
212	1	41	35
212	1	40	35
212	1	42	35
212	1	41	36
212	1	43	35
213	1	48	33
213	1	48	34
213	1	49	34
213	1	47	34
213	1	48	35
213	1	49	35
213	1	50	35
213	1	49	36
213	1	50	36
213	1	48	36
214	1	6	34
214	1	6	35
214	1	7	35
214	1	6	36
214	1	5	36
214	1	6	37
214	1	4	36
214	1	5	37
214	1	3	36
214	1	4	37
215	1	52	34
215	1	52	35
215	1	53	35
215	1	53	36
215	1	54	36
215	1	53	37
215	1	54	37
215	1	52	37
216	1	3	35
217	1	38	35
217	1	39	35
217	1	38	36
217	1	39	36
217	1	38	37
217	1	39	37
217	1	40	37
217	1	39	38
218	1	46	35
218	1	47	35
218	1	46	36
218	1	47	36
218	1	45	36
218	1	46	37
218	1	47	37
218	1	48	37
218	1	47	38
218	1	44	36
219	1	55	35
219	1	56	35
219	1	55	36
219	1	56	36
219	1	57	36
219	1	56	37
219	1	58	36
219	1	57	37
220	1	10	36
221	1	12	36
222	1	29	36
222	1	29	37
222	1	30	37
222	1	28	37
222	1	29	38
222	1	30	38
222	1	31	37
222	1	31	36
222	1	32	36
223	1	40	36
224	1	42	36
224	1	43	36
224	1	42	37
224	1	43	37
224	1	41	37
224	1	42	38
224	1	41	38
224	1	44	37
224	1	43	38
225	1	60	36
226	1	2	37
226	1	3	37
226	1	2	38
226	1	1	38
226	1	2	39
226	1	1	39
226	1	2	40
226	1	3	40
226	1	1	40
226	1	2	41
227	1	7	37
227	1	7	38
227	1	8	38
227	1	6	38
227	1	7	39
227	1	8	39
227	1	6	39
227	1	7	40
227	1	8	40
228	1	11	37
228	1	11	38
228	1	12	38
228	1	10	38
228	1	11	39
228	1	12	39
228	1	12	40
228	1	10	39
228	1	11	40
229	1	45	37
229	1	45	38
229	1	46	38
229	1	44	38
229	1	45	39
229	1	44	39
229	1	43	39
229	1	44	40
229	1	46	39
229	1	42	39
230	1	49	37
230	1	50	37
230	1	49	38
230	1	50	38
230	1	48	38
230	1	49	39
230	1	51	38
230	1	50	39
231	1	51	37
232	1	55	37
232	1	55	38
232	1	56	38
232	1	57	38
232	1	56	39
232	1	58	38
232	1	57	39
232	1	59	38
232	1	58	39
233	1	58	37
234	1	40	38
234	1	40	39
234	1	41	39
234	1	39	39
234	1	40	40
234	1	41	40
234	1	42	40
234	1	41	41
235	1	60	38
235	1	60	39
235	1	59	39
235	1	60	40
235	1	59	40
235	1	60	41
235	1	59	41
235	1	58	41
235	1	59	42
236	1	4	39
236	1	4	40
236	1	4	41
236	1	3	41
236	1	4	42
236	1	5	42
236	1	3	42
236	1	2	42
236	1	6	42
236	1	7	42
237	1	27	39
237	1	28	39
237	1	28	40
237	1	29	40
237	1	28	41
237	1	29	41
237	1	27	41
237	1	28	42
237	1	26	41
237	1	27	42
238	1	47	39
238	1	48	39
238	1	47	40
238	1	48	40
238	1	46	40
238	1	47	41
238	1	45	40
238	1	46	41
238	1	48	41
239	1	51	39
239	1	51	40
239	1	52	40
239	1	50	40
239	1	51	41
239	1	49	40
239	1	50	41
239	1	53	40
239	1	52	41
240	1	53	39
241	1	6	40
241	1	6	41
241	1	7	41
241	1	8	41
241	1	9	41
241	1	8	42
241	1	10	41
241	1	9	42
241	1	9	40
242	1	10	40
243	1	13	40
243	1	13	41
243	1	14	41
243	1	12	41
243	1	13	42
243	1	14	42
243	1	11	41
243	1	12	42
244	1	43	40
244	1	43	41
244	1	44	41
244	1	42	41
244	1	43	42
244	1	45	41
244	1	44	42
244	1	42	42
245	1	54	40
245	1	54	41
245	1	55	41
245	1	53	41
245	1	54	42
245	1	56	41
245	1	55	42
245	1	53	42
245	1	54	43
246	1	1	41
247	1	10	42
247	1	11	42
247	1	10	43
247	1	11	43
247	1	12	43
247	1	11	44
247	1	13	43
247	1	12	44
248	1	17	42
249	1	26	42
249	1	26	43
249	1	27	43
249	1	28	43
249	1	29	43
249	1	28	44
249	1	30	43
249	1	29	44
249	1	29	42
249	1	29	45
250	1	33	42
251	1	45	42
251	1	46	42
251	1	45	43
251	1	47	42
251	1	46	43
251	1	44	43
251	1	45	44
251	1	47	43
251	1	46	44
251	1	48	42
252	1	50	42
252	1	51	42
252	1	50	43
252	1	52	42
252	1	51	43
252	1	52	43
252	1	53	43
252	1	52	44
253	1	56	42
253	1	56	43
253	1	57	43
253	1	55	43
253	1	56	44
253	1	55	44
253	1	57	44
253	1	56	45
254	1	58	42
254	1	58	43
254	1	59	43
254	1	58	44
254	1	60	43
254	1	59	44
254	1	60	44
254	1	59	45
254	1	58	45
254	1	60	42
255	1	9	43
255	1	9	44
255	1	10	44
256	1	19	43
257	1	43	43
258	1	48	43
258	1	48	44
258	1	47	44
258	1	48	45
258	1	49	45
258	1	47	45
258	1	48	46
258	1	49	46
258	1	47	46
258	1	48	47
259	1	2	44
259	1	3	44
259	1	3	45
259	1	3	46
259	1	4	46
259	1	2	46
259	1	3	47
259	1	2	47
260	1	5	44
261	1	7	44
261	1	7	45
261	1	6	45
261	1	7	46
261	1	6	46
261	1	8	46
261	1	9	46
261	1	10	46
262	1	13	44
263	1	20	44
264	1	39	44
265	1	44	44
266	1	53	44
266	1	54	44
266	1	54	45
266	1	55	45
266	1	54	46
266	1	55	46
266	1	54	47
266	1	55	47
266	1	54	48
267	1	11	45
267	1	12	45
267	1	11	46
267	1	12	46
268	1	28	45
268	1	28	46
268	1	29	46
268	1	28	47
268	1	29	47
268	1	29	48
269	1	33	45
270	1	46	45
271	1	50	45
271	1	50	46
271	1	50	47
271	1	51	47
271	1	49	47
271	1	50	48
271	1	52	47
271	1	51	48
271	1	52	48
271	1	51	49
272	1	57	45
273	1	60	45
273	1	60	46
273	1	59	46
273	1	60	47
273	1	59	47
273	1	60	48
273	1	58	46
273	1	58	47
274	1	36	46
275	1	52	46
276	1	1	47
276	1	1	48
276	1	2	48
276	1	1	49
276	1	2	49
276	1	1	50
276	1	3	49
276	1	2	50
276	1	4	49
276	1	3	50
277	1	4	47
277	1	4	48
277	1	3	48
278	1	46	47
278	1	47	47
279	1	57	47
279	1	57	48
279	1	58	48
279	1	56	48
279	1	57	49
279	1	55	48
279	1	56	49
279	1	59	48
279	1	58	49
279	1	59	49
280	1	6	48
280	1	6	49
280	1	7	49
280	1	5	49
280	1	6	50
280	1	8	49
280	1	7	50
280	1	8	50
281	1	8	48
282	1	10	48
283	1	12	48
284	1	14	48
285	1	17	48
286	1	20	48
287	1	40	48
288	1	48	48
288	1	49	48
288	1	49	49
288	1	50	49
288	1	49	50
288	1	50	50
288	1	49	51
288	1	51	50
288	1	50	51
288	1	52	50
289	1	52	49
290	1	55	49
290	1	55	50
290	1	55	51
290	1	56	51
290	1	55	52
290	1	56	52
290	1	54	52
290	1	55	53
291	1	60	49
291	1	60	50
291	1	59	50
291	1	60	51
291	1	58	50
291	1	59	51
291	1	60	52
291	1	59	52
292	1	4	50
292	1	5	50
292	1	4	51
292	1	5	51
292	1	6	51
292	1	5	52
292	1	7	51
292	1	6	52
293	1	15	50
294	1	36	50
295	1	53	50
295	1	53	51
295	1	52	51
295	1	53	52
295	1	51	51
295	1	52	52
295	1	51	52
295	1	53	53
296	1	1	51
296	1	2	51
296	1	1	52
296	1	2	52
296	1	1	53
296	1	3	51
296	1	2	53
296	1	1	54
296	1	3	52
296	1	2	54
297	1	57	51
297	1	58	51
297	1	57	52
297	1	58	52
297	1	57	53
297	1	58	53
297	1	56	53
297	1	57	54
298	1	4	52
298	1	4	53
298	1	5	53
298	1	3	53
298	1	4	54
298	1	6	53
298	1	5	54
298	1	6	54
298	1	7	53
298	1	8	53
299	1	7	52
300	1	10	52
301	1	31	52
302	1	39	52
303	1	49	52
303	1	50	52
303	1	50	53
303	1	51	53
303	1	50	54
303	1	51	54
303	1	52	54
303	1	51	55
304	1	12	53
305	1	15	53
306	1	24	53
307	1	34	53
308	1	52	53
309	1	54	53
309	1	54	54
309	1	55	54
309	1	53	54
309	1	54	55
309	1	56	54
309	1	55	55
309	1	56	55
309	1	57	55
309	1	56	56
310	1	60	53
311	1	3	54
312	1	7	54
312	1	8	54
312	1	7	55
312	1	8	55
312	1	6	55
312	1	7	56
312	1	9	55
312	1	8	56
312	1	8	57
313	1	10	54
314	1	28	54
315	1	58	54
315	1	58	55
315	1	59	55
315	1	58	56
315	1	60	55
315	1	59	56
315	1	57	56
315	1	58	57
315	1	60	56
315	1	57	57
316	1	1	55
316	1	2	55
316	1	1	56
316	1	2	56
316	1	1	57
316	1	3	56
316	1	2	57
316	1	3	57
316	1	3	58
317	1	17	55
318	1	52	55
318	1	53	55
318	1	52	56
318	1	53	56
318	1	51	56
318	1	54	56
318	1	53	57
318	1	55	56
318	1	54	57
318	1	55	57
319	1	5	56
319	1	6	56
319	1	5	57
319	1	6	57
319	1	5	58
319	1	7	57
319	1	6	58
319	1	7	58
319	1	4	58
319	1	5	59
320	1	30	56
321	1	37	56
322	1	46	57
323	1	56	57
323	1	56	58
323	1	57	58
323	1	55	58
323	1	56	59
323	1	58	58
323	1	57	59
323	1	54	58
324	1	59	57
324	1	60	57
324	1	59	58
324	1	60	58
324	1	59	59
324	1	60	59
324	1	58	59
324	1	59	60
325	1	8	58
325	1	9	58
325	1	8	59
325	1	9	59
325	1	10	59
325	1	9	60
325	1	7	59
325	1	8	60
325	1	10	60
325	1	7	60
326	1	23	58
327	1	27	58
328	1	49	58
329	1	53	58
329	1	53	59
329	1	54	59
329	1	55	59
329	1	54	60
329	1	55	60
329	1	56	60
329	1	57	60
329	1	58	60
330	1	1	59
330	1	2	59
330	1	1	60
330	1	2	60
330	1	3	59
330	1	3	60
330	1	4	60
330	1	4	59
331	1	6	59
331	1	6	60
331	1	5	60
332	1	12	59
333	1	25	59
334	1	38	59
335	1	47	60
336	1	60	60
\.


--
-- TOC entry 5517 (class 0 OID 22815)
-- Dependencies: 299
-- Data for Name: map_tiles_players_positions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_players_positions (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
2	1	5	6
4	1	4	6
1	1	9	3
3	1	9	5
\.


--
-- TOC entry 5535 (class 0 OID 25631)
-- Dependencies: 319
-- Data for Name: map_tiles_resources; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_resources (id, map_id, map_tile_x, map_tile_y, item_id, quantity) FROM stdin;
1	1	4	6	4	1000
2	1	4	6	5	2000
\.


--
-- TOC entry 5518 (class 0 OID 22822)
-- Dependencies: 300
-- Data for Name: maps; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.maps (id, name) FROM stdin;
1	NowaMapa
\.


--
-- TOC entry 5520 (class 0 OID 22828)
-- Dependencies: 302
-- Data for Name: region_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.region_types (id, name) FROM stdin;
2	River
3	Sea
1	Province
\.


--
-- TOC entry 5467 (class 0 OID 22621)
-- Dependencies: 249
-- Data for Name: terrain_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.terrain_types (id, name, move_cost, image_url) FROM stdin;
1	Plains	1	plains.png
2	Grasslands	1	grasslands.png
3	Shrubland	1	shrubland.png
4	Desert	6	desert.png
6	Savannah	5	savannah.png
5	Marsh	6	marsh.png
7	Jungle	4	jungle.png
8	Sea	99	sea.png
9	River	99	river.png
\.


--
-- TOC entry 5607 (class 0 OID 0)
-- Dependencies: 250
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.abilities_id_seq', 2, true);


--
-- TOC entry 5608 (class 0 OID 0)
-- Dependencies: 253
-- Name: player_abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_abilities_id_seq', 8, true);


--
-- TOC entry 5609 (class 0 OID 0)
-- Dependencies: 255
-- Name: player_skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_skills_id_seq', 12, true);


--
-- TOC entry 5610 (class 0 OID 0)
-- Dependencies: 257
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_stats_id_seq', 28, true);


--
-- TOC entry 5611 (class 0 OID 0)
-- Dependencies: 258
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.roles_id_seq', 1, false);


--
-- TOC entry 5612 (class 0 OID 0)
-- Dependencies: 259
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.skills_id_seq', 3, true);


--
-- TOC entry 5613 (class 0 OID 0)
-- Dependencies: 260
-- Name: stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.stats_id_seq', 9, true);


--
-- TOC entry 5614 (class 0 OID 0)
-- Dependencies: 262
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.accounts_id_seq', 1, false);


--
-- TOC entry 5615 (class 0 OID 0)
-- Dependencies: 264
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.sessions_id_seq', 1, false);


--
-- TOC entry 5616 (class 0 OID 0)
-- Dependencies: 266
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_id_seq', 4, true);


--
-- TOC entry 5617 (class 0 OID 0)
-- Dependencies: 269
-- Name: building_types_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.building_types_id_seq', 1, false);


--
-- TOC entry 5618 (class 0 OID 0)
-- Dependencies: 270
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.buildings_id_seq', 1, false);


--
-- TOC entry 5619 (class 0 OID 0)
-- Dependencies: 271
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: cities; Owner: postgres
--

SELECT pg_catalog.setval('cities.cities_id_seq', 1, false);


--
-- TOC entry 5620 (class 0 OID 0)
-- Dependencies: 274
-- Name: district_types_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.district_types_id_seq', 1, false);


--
-- TOC entry 5621 (class 0 OID 0)
-- Dependencies: 275
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.districts_id_seq', 1, false);


--
-- TOC entry 5622 (class 0 OID 0)
-- Dependencies: 277
-- Name: inventory_container_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_container_types_id_seq', 4, true);


--
-- TOC entry 5623 (class 0 OID 0)
-- Dependencies: 279
-- Name: inventory_containers_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_containers_id_seq', 8, true);


--
-- TOC entry 5624 (class 0 OID 0)
-- Dependencies: 281
-- Name: inventory_slot_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slot_types_id_seq', 14, true);


--
-- TOC entry 5625 (class 0 OID 0)
-- Dependencies: 283
-- Name: inventory_slots_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slots_id_seq', 88, true);


--
-- TOC entry 5626 (class 0 OID 0)
-- Dependencies: 284
-- Name: item_stats_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_stats_id_seq', 1, false);


--
-- TOC entry 5627 (class 0 OID 0)
-- Dependencies: 286
-- Name: item_types_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_types_id_seq', 10, true);


--
-- TOC entry 5628 (class 0 OID 0)
-- Dependencies: 287
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.items_id_seq', 5, true);


--
-- TOC entry 5629 (class 0 OID 0)
-- Dependencies: 290
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.players_id_seq', 4, true);


--
-- TOC entry 5630 (class 0 OID 0)
-- Dependencies: 315
-- Name: squads_id_seq; Type: SEQUENCE SET; Schema: squad; Owner: postgres
--

SELECT pg_catalog.setval('squad.squads_id_seq', 1, false);


--
-- TOC entry 5631 (class 0 OID 0)
-- Dependencies: 292
-- Name: status_types_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.status_types_id_seq', 1, false);


--
-- TOC entry 5632 (class 0 OID 0)
-- Dependencies: 294
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.tasks_id_seq', 619, true);


--
-- TOC entry 5633 (class 0 OID 0)
-- Dependencies: 295
-- Name: landscape_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.landscape_types_id_seq', 1, false);


--
-- TOC entry 5634 (class 0 OID 0)
-- Dependencies: 297
-- Name: map_regions_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_regions_id_seq', 336, true);


--
-- TOC entry 5635 (class 0 OID 0)
-- Dependencies: 318
-- Name: map_tiles_resources_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_tiles_resources_id_seq', 2, true);


--
-- TOC entry 5636 (class 0 OID 0)
-- Dependencies: 301
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.maps_id_seq', 1, true);


--
-- TOC entry 5637 (class 0 OID 0)
-- Dependencies: 303
-- Name: region_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.region_types_id_seq', 3, true);


--
-- TOC entry 5638 (class 0 OID 0)
-- Dependencies: 304
-- Name: terrain_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.terrain_types_id_seq', 3, true);


--
-- TOC entry 5135 (class 2606 OID 22844)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5170 (class 2606 OID 22846)
-- Name: ability_skill_requirements ability_skill_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_pkey PRIMARY KEY (ability_id, skill_id);


--
-- TOC entry 5172 (class 2606 OID 22848)
-- Name: ability_stat_requirements ability_stat_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_pkey PRIMARY KEY (ability_id, stat_id);


--
-- TOC entry 5137 (class 2606 OID 22850)
-- Name: player_abilities player_abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5174 (class 2606 OID 22852)
-- Name: player_skills player_skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5176 (class 2606 OID 22854)
-- Name: player_stats player_stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5139 (class 2606 OID 22856)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5141 (class 2606 OID 22858)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5143 (class 2606 OID 22860)
-- Name: stats stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5178 (class 2606 OID 22862)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 5180 (class 2606 OID 22864)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5182 (class 2606 OID 22866)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5184 (class 2606 OID 22868)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5186 (class 2606 OID 22870)
-- Name: verification_token verification_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.verification_token
    ADD CONSTRAINT verification_token_pkey PRIMARY KEY (identifier, token);


--
-- TOC entry 5188 (class 2606 OID 22872)
-- Name: building_roles building_owners_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_owners_pkey PRIMARY KEY (building_id, player_id, role_id);


--
-- TOC entry 5145 (class 2606 OID 22874)
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5147 (class 2606 OID 22876)
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- TOC entry 5149 (class 2606 OID 22878)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 5190 (class 2606 OID 22880)
-- Name: city_roles city_owners_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_roles
    ADD CONSTRAINT city_owners_pkey PRIMARY KEY (city_id, player_id, role_id);


--
-- TOC entry 5152 (class 2606 OID 22882)
-- Name: city_tiles city_tiles_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_tiles
    ADD CONSTRAINT city_tiles_pkey PRIMARY KEY (city_id, x, y);


--
-- TOC entry 5192 (class 2606 OID 22884)
-- Name: district_roles district_owners_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_owners_pkey PRIMARY KEY (district_id, player_id, role_id);


--
-- TOC entry 5154 (class 2606 OID 22886)
-- Name: district_types district_types_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_types
    ADD CONSTRAINT district_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5156 (class 2606 OID 22888)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 5194 (class 2606 OID 22890)
-- Name: inventory_container_types inventory_container_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_types
    ADD CONSTRAINT inventory_container_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5196 (class 2606 OID 22892)
-- Name: inventory_containers inventory_containers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_pkey PRIMARY KEY (id);


--
-- TOC entry 5158 (class 2606 OID 22894)
-- Name: inventory_slot_types inventory_slot_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_types
    ADD CONSTRAINT inventory_slot_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5198 (class 2606 OID 22896)
-- Name: inventory_slots inventory_slots_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 5160 (class 2606 OID 22898)
-- Name: item_stats item_stats_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5200 (class 2606 OID 22900)
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5162 (class 2606 OID 22902)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 5221 (class 2606 OID 25562)
-- Name: known_map_tiles known_map_tiles_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_pk PRIMARY KEY (player_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5231 (class 2606 OID 25558)
-- Name: known_players_abilities known_players_abilities_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5225 (class 2606 OID 25556)
-- Name: known_players_containers known_players_containers_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_pk PRIMARY KEY (player_id, container_id);


--
-- TOC entry 5202 (class 2606 OID 25554)
-- Name: known_players_positions known_players_positions_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5223 (class 2606 OID 25552)
-- Name: known_players_profiles known_players_profiles_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5229 (class 2606 OID 25550)
-- Name: known_players_skills known_players_skills_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5227 (class 2606 OID 25548)
-- Name: known_players_stats known_players_stats_pk; Type: CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_pk PRIMARY KEY (player_id, other_player_id);


--
-- TOC entry 5205 (class 2606 OID 22904)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 5233 (class 2606 OID 25573)
-- Name: squad_players squad_players_pkey; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_pkey PRIMARY KEY (squad_id, player_id);


--
-- TOC entry 5235 (class 2606 OID 25580)
-- Name: squads squads_pk; Type: CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squads
    ADD CONSTRAINT squads_pk PRIMARY KEY (id);


--
-- TOC entry 5207 (class 2606 OID 22906)
-- Name: status_types status_types_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types
    ADD CONSTRAINT status_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5209 (class 2606 OID 22908)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 5164 (class 2606 OID 22910)
-- Name: landscape_types landscape_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.landscape_types
    ADD CONSTRAINT landscape_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5211 (class 2606 OID 22912)
-- Name: map_regions map_regions_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_regions
    ADD CONSTRAINT map_regions_pkey PRIMARY KEY (id);


--
-- TOC entry 5213 (class 2606 OID 25566)
-- Name: map_tiles_map_regions map_tiles_map_regions_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_pk PRIMARY KEY (region_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5166 (class 2606 OID 22914)
-- Name: map_tiles map_tiles_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_pkey PRIMARY KEY (map_id, x, y);


--
-- TOC entry 5215 (class 2606 OID 25564)
-- Name: map_tiles_players_positions map_tiles_players_positions_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_pk PRIMARY KEY (player_id, map_id, map_tile_x, map_tile_y);


--
-- TOC entry 5237 (class 2606 OID 25642)
-- Name: map_tiles_resources map_tiles_resources_pk; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_pk PRIMARY KEY (id);


--
-- TOC entry 5217 (class 2606 OID 22918)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- TOC entry 5219 (class 2606 OID 22920)
-- Name: region_types region_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.region_types
    ADD CONSTRAINT region_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5168 (class 2606 OID 22922)
-- Name: terrain_types terrain_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.terrain_types
    ADD CONSTRAINT terrain_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5150 (class 1259 OID 22923)
-- Name: unique_city_position; Type: INDEX; Schema: cities; Owner: postgres
--

CREATE UNIQUE INDEX unique_city_position ON cities.cities USING btree (map_tile_x, map_tile_y);


--
-- TOC entry 5203 (class 1259 OID 22924)
-- Name: one_active_player_per_user; Type: INDEX; Schema: players; Owner: postgres
--

CREATE UNIQUE INDEX one_active_player_per_user ON players.players USING btree (user_id) WHERE (is_active = true);


--
-- TOC entry 5254 (class 2606 OID 22925)
-- Name: ability_skill_requirements ability_skill_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5255 (class 2606 OID 22930)
-- Name: ability_skill_requirements ability_skill_requirements_skill_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5256 (class 2606 OID 22935)
-- Name: ability_stat_requirements ability_stat_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5257 (class 2606 OID 22940)
-- Name: ability_stat_requirements ability_stat_requirements_stat_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_stat_id_fkey FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5238 (class 2606 OID 22945)
-- Name: player_abilities player_abilities_abilities_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_abilities_fk FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5239 (class 2606 OID 22950)
-- Name: player_abilities player_abilities_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5258 (class 2606 OID 22955)
-- Name: player_skills player_skills_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5259 (class 2606 OID 22960)
-- Name: player_skills player_skills_skills_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_skills_fk FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5260 (class 2606 OID 22965)
-- Name: player_stats player_stats_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5261 (class 2606 OID 22970)
-- Name: player_stats player_stats_stats_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5262 (class 2606 OID 22975)
-- Name: accounts accounts_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_users_fk FOREIGN KEY ("userId") REFERENCES auth.users(id);


--
-- TOC entry 5263 (class 2606 OID 22980)
-- Name: sessions sessions_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_users_fk FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- TOC entry 5264 (class 2606 OID 22985)
-- Name: building_roles building_roles_buildings_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_buildings_fk FOREIGN KEY (building_id) REFERENCES buildings.buildings(id);


--
-- TOC entry 5265 (class 2606 OID 22990)
-- Name: building_roles building_roles_players_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5266 (class 2606 OID 22995)
-- Name: building_roles building_roles_roles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5240 (class 2606 OID 23000)
-- Name: buildings buildings_building_types_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_building_types_fk FOREIGN KEY (building_type_id) REFERENCES buildings.building_types(id);


--
-- TOC entry 5241 (class 2606 OID 23005)
-- Name: buildings buildings_cities_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_cities_fk FOREIGN KEY (city_id) REFERENCES cities.cities(id);


--
-- TOC entry 5242 (class 2606 OID 23010)
-- Name: buildings buildings_city_tiles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_city_tiles_fk FOREIGN KEY (city_id, city_tile_x, city_tile_y) REFERENCES cities.city_tiles(city_id, x, y);


--
-- TOC entry 5243 (class 2606 OID 23015)
-- Name: cities cities_map_tiles_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5244 (class 2606 OID 23020)
-- Name: cities cities_maps_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5267 (class 2606 OID 23025)
-- Name: district_roles district_roles_districts_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_districts_fk FOREIGN KEY (district_id) REFERENCES districts.districts(id);


--
-- TOC entry 5268 (class 2606 OID 23030)
-- Name: district_roles district_roles_players_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5269 (class 2606 OID 23035)
-- Name: district_roles district_roles_roles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5245 (class 2606 OID 23040)
-- Name: districts districts_district_types_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_district_types_fk FOREIGN KEY (district_type_id) REFERENCES districts.district_types(id);


--
-- TOC entry 5246 (class 2606 OID 23045)
-- Name: districts districts_map_tiles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5247 (class 2606 OID 23050)
-- Name: districts districts_maps_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5270 (class 2606 OID 23055)
-- Name: inventory_containers inventory_containers_inventory_container_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_inventory_container_types_fk FOREIGN KEY (inventory_container_type_id) REFERENCES inventory.inventory_container_types(id);


--
-- TOC entry 5271 (class 2606 OID 23060)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5272 (class 2606 OID 23065)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_item_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5273 (class 2606 OID 23070)
-- Name: inventory_slots inventory_slots_inventory_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5274 (class 2606 OID 23075)
-- Name: inventory_slots inventory_slots_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5275 (class 2606 OID 23080)
-- Name: inventory_slots inventory_slots_items_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5248 (class 2606 OID 23085)
-- Name: item_stats item_stats_items_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5249 (class 2606 OID 23090)
-- Name: item_stats item_stats_stats_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5250 (class 2606 OID 23095)
-- Name: items items_item_types_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5284 (class 2606 OID 23184)
-- Name: known_map_tiles known_map_tiles_map_tiles_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5285 (class 2606 OID 23179)
-- Name: known_map_tiles known_map_tiles_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5300 (class 2606 OID 25663)
-- Name: known_map_tiles_resources known_map_tiles_resources_map_tiles_resources_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles_resources
    ADD CONSTRAINT known_map_tiles_resources_map_tiles_resources_fk FOREIGN KEY (map_tiles_resource_id) REFERENCES world.map_tiles_resources(id);


--
-- TOC entry 5301 (class 2606 OID 25658)
-- Name: known_map_tiles_resources known_map_tiles_resources_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles_resources
    ADD CONSTRAINT known_map_tiles_resources_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5294 (class 2606 OID 25535)
-- Name: known_players_abilities known_players_abilities_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5295 (class 2606 OID 25540)
-- Name: known_players_abilities known_players_abilities_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_abilities
    ADD CONSTRAINT known_players_abilities_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5288 (class 2606 OID 25470)
-- Name: known_players_containers known_players_containers_inventory_containers_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_inventory_containers_fk FOREIGN KEY (container_id) REFERENCES inventory.inventory_containers(id);


--
-- TOC entry 5289 (class 2606 OID 25465)
-- Name: known_players_containers known_players_containers_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_containers
    ADD CONSTRAINT known_players_containers_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5276 (class 2606 OID 23100)
-- Name: known_players_positions known_players_positions_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5277 (class 2606 OID 23105)
-- Name: known_players_positions known_players_positions_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5286 (class 2606 OID 25450)
-- Name: known_players_profiles known_players_profiles_other_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_other_players_fk FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5287 (class 2606 OID 25445)
-- Name: known_players_profiles known_players_profiles_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_profiles
    ADD CONSTRAINT known_players_profiles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5292 (class 2606 OID 25519)
-- Name: known_players_skills known_players_skills_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5293 (class 2606 OID 25524)
-- Name: known_players_skills known_players_skills_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_skills
    ADD CONSTRAINT known_players_skills_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5290 (class 2606 OID 25508)
-- Name: known_players_stats known_players_stats_player_stats_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_player_stats_fk FOREIGN KEY (other_player_id) REFERENCES attributes.player_stats(id);


--
-- TOC entry 5291 (class 2606 OID 25497)
-- Name: known_players_stats known_players_stats_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_stats
    ADD CONSTRAINT known_players_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5296 (class 2606 OID 25586)
-- Name: squad_players squad_players_players_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5297 (class 2606 OID 25581)
-- Name: squad_players squad_players_squads_fk; Type: FK CONSTRAINT; Schema: squad; Owner: postgres
--

ALTER TABLE ONLY squad.squad_players
    ADD CONSTRAINT squad_players_squads_fk FOREIGN KEY (squad_id) REFERENCES squad.squads(id);


--
-- TOC entry 5251 (class 2606 OID 23110)
-- Name: map_tiles map_tiles_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5278 (class 2606 OID 23115)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_regions_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_regions_fk FOREIGN KEY (region_id) REFERENCES world.map_regions(id);


--
-- TOC entry 5279 (class 2606 OID 23120)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5280 (class 2606 OID 23125)
-- Name: map_tiles_map_regions map_tiles_map_regions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5252 (class 2606 OID 23130)
-- Name: map_tiles map_tiles_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5281 (class 2606 OID 23135)
-- Name: map_tiles_players_positions map_tiles_players_positions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5282 (class 2606 OID 23140)
-- Name: map_tiles_players_positions map_tiles_players_positions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5283 (class 2606 OID 23145)
-- Name: map_tiles_players_positions map_tiles_players_positions_players_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5298 (class 2606 OID 25648)
-- Name: map_tiles_resources map_tiles_resources_items_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5299 (class 2606 OID 25643)
-- Name: map_tiles_resources map_tiles_resources_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_resources
    ADD CONSTRAINT map_tiles_resources_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5253 (class 2606 OID 23150)
-- Name: map_tiles map_tiles_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


-- Completed on 2026-03-25 17:06:33

--
-- PostgreSQL database dump complete
--

\unrestrict FBebtk7YY25BhKthALtYvKTFI6vrDsxvXnHnKfk2RfkMe2IUmkpYvWrgCBISvBJ

