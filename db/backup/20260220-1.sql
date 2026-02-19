--
-- PostgreSQL database dump
--

\restrict YBmaD7KMiwnxQqmoKSp7H8a9DkzQeSzRwTeJQNn4gjKXXOM43JkhQdY2p3JhgXE

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-02-20 00:31:13

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
-- TOC entry 369 (class 1255 OID 22428)
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
-- TOC entry 376 (class 1255 OID 22429)
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
-- TOC entry 312 (class 1255 OID 22430)
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
-- TOC entry 338 (class 1255 OID 22431)
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

            IF assigned[cur_x][cur_y] THEN
                CONTINUE;
            END IF;

            ------------------------------------------
            -- nowy region
            ------------------------------------------
            INSERT INTO world.map_regions(name)
            VALUES ('region')
            RETURNING id INTO region_id;

            region_size_target := floor(random() * 5) + 4; -- 4..8
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
-- TOC entry 351 (class 1255 OID 22432)
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
VALUES(p_player_id, 1, 3, 3);

INSERT INTO knowledge.known_map_tiles
(player_id, map_id, map_tile_x, map_tile_y)
VALUES(p_player_id, 1, 3, 3);

INSERT INTO knowledge.known_players_positions
(player_id, other_player_id)
SELECT
p_player_id
,id
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
-- TOC entry 396 (class 1255 OID 22433)
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
-- TOC entry 339 (class 1255 OID 22434)
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
	

CALL "admin".map_insert();
CALL "admin".new_player(1, 'Ciabat', 'Ciabatos');

    RAISE NOTICE 'All have been truncated and reset';
END;
$$;


ALTER PROCEDURE admin.reset_all() OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 22435)
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
-- TOC entry 232 (class 1259 OID 22436)
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
-- TOC entry 377 (class 1255 OID 22444)
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
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 377
-- Name: FUNCTION get_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities() IS 'automatic_get_api';


--
-- TOC entry 307 (class 1255 OID 22445)
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
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 307
-- Name: FUNCTION get_abilities_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 233 (class 1259 OID 22446)
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
-- TOC entry 335 (class 1255 OID 22453)
-- Name: get_player_abilities(); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_player_abilities() RETURNS SETOF attributes.player_abilities
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.player_abilities;
      END;
      $$;


ALTER FUNCTION attributes.get_player_abilities() OWNER TO postgres;

--
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION get_player_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities() IS 'automatic_get_api';


--
-- TOC entry 311 (class 1255 OID 22454)
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
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 311
-- Name: FUNCTION get_player_abilities(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities(p_player_id integer) IS 'get_api';


--
-- TOC entry 393 (class 1255 OID 22455)
-- Name: get_player_abilities_by_key(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.get_player_abilities_by_key(p_player_id integer) RETURNS SETOF attributes.player_abilities
    LANGUAGE plpgsql
    AS $$
      BEGIN
      -- GENERATED CODE - DO NOT EDIT MANUALLY - getTable.js
          RETURN QUERY
          SELECT * FROM attributes.player_abilities
          WHERE "player_id" = p_player_id;
      END;
      $$;


ALTER FUNCTION attributes.get_player_abilities_by_key(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 393
-- Name: FUNCTION get_player_abilities_by_key(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities_by_key(p_player_id integer) IS 'automatic_get_api';


--
-- TOC entry 383 (class 1255 OID 22456)
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
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 383
-- Name: FUNCTION get_player_skills(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_skills(p_player_id integer) IS 'get_api';


--
-- TOC entry 318 (class 1255 OID 22457)
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
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 318
-- Name: FUNCTION get_player_stats(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_stats(p_player_id integer) IS 'get_api';


--
-- TOC entry 234 (class 1259 OID 22458)
-- Name: roles; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.roles (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE attributes.roles OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 22462)
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
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 315
-- Name: FUNCTION get_roles(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles() IS 'automatic_get_api';


--
-- TOC entry 345 (class 1255 OID 22463)
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
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 345
-- Name: FUNCTION get_roles_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 235 (class 1259 OID 22464)
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
-- TOC entry 327 (class 1255 OID 22472)
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
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION get_skills(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills() IS 'automatic_get_api';


--
-- TOC entry 309 (class 1255 OID 22473)
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
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 309
-- Name: FUNCTION get_skills_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 236 (class 1259 OID 22474)
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
-- TOC entry 328 (class 1255 OID 22482)
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
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION get_stats(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats() IS 'automatic_get_api';


--
-- TOC entry 363 (class 1255 OID 22483)
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
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 363
-- Name: FUNCTION get_stats_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 326 (class 1255 OID 22484)
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
-- TOC entry 372 (class 1255 OID 22485)
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
-- TOC entry 337 (class 1255 OID 22486)
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
-- TOC entry 237 (class 1259 OID 22487)
-- Name: building_types; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    image_url character varying(255)
);


ALTER TABLE buildings.building_types OWNER TO postgres;

--
-- TOC entry 347 (class 1255 OID 22492)
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
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION get_building_types(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types() IS 'automatic_get_api';


--
-- TOC entry 329 (class 1255 OID 22493)
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
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION get_building_types_by_key(p_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 238 (class 1259 OID 22494)
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
-- TOC entry 374 (class 1255 OID 22503)
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
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 374
-- Name: FUNCTION get_buildings(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings() IS 'automatic_get_api';


--
-- TOC entry 308 (class 1255 OID 22504)
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
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 308
-- Name: FUNCTION get_buildings_by_key(p_city_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 239 (class 1259 OID 22505)
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
-- TOC entry 354 (class 1255 OID 22514)
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
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 354
-- Name: FUNCTION get_cities(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities() IS 'automatic_get_api';


--
-- TOC entry 384 (class 1255 OID 22515)
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
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 384
-- Name: FUNCTION get_cities_by_key(p_map_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 240 (class 1259 OID 22516)
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
-- TOC entry 398 (class 1255 OID 22524)
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
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 398
-- Name: FUNCTION get_city_tiles(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles() IS 'automatic_get_api';


--
-- TOC entry 379 (class 1255 OID 22525)
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
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 379
-- Name: FUNCTION get_city_tiles_by_key(p_city_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 360 (class 1255 OID 22526)
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
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 360
-- Name: FUNCTION get_player_city(p_player_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_player_city(p_player_id integer) IS 'get_api';


--
-- TOC entry 241 (class 1259 OID 22527)
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
-- TOC entry 324 (class 1255 OID 22533)
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
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION get_district_types(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types() IS 'automatic_get_api';


--
-- TOC entry 371 (class 1255 OID 22534)
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
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 371
-- Name: FUNCTION get_district_types_by_key(p_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 242 (class 1259 OID 22535)
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
-- TOC entry 330 (class 1255 OID 22543)
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
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION get_districts(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts() IS 'automatic_get_api';


--
-- TOC entry 349 (class 1255 OID 22544)
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
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 349
-- Name: FUNCTION get_districts_by_key(p_map_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 359 (class 1255 OID 22545)
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
-- TOC entry 364 (class 1255 OID 22546)
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
-- TOC entry 390 (class 1255 OID 22547)
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
-- TOC entry 336 (class 1255 OID 22548)
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
-- TOC entry 357 (class 1255 OID 22549)
-- Name: check_inventory_container_ownership(integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.check_inventory_container_ownership(p_player_id integer, p_inventory_container_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.inventory_containers WHERE id = p_inventory_container_id AND owner_id = p_player_id) THEN
        PERFORM util.raise_error('You are no owner of inventory container');
    END IF;
END;
$$;


ALTER FUNCTION inventory.check_inventory_container_ownership(p_player_id integer, p_inventory_container_id integer) OWNER TO postgres;

--
-- TOC entry 381 (class 1255 OID 22550)
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
-- TOC entry 322 (class 1255 OID 22551)
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
-- TOC entry 386 (class 1255 OID 22552)
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
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 386
-- Name: FUNCTION do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 375 (class 1255 OID 22553)
-- Name: do_move_or_swap_item(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$

BEGIN
	PERFORM inventory.check_inventory_container_ownership(p_player_id, p_from_inventory_container_id);
	PERFORM inventory.check_inventory_container_ownership(p_player_id, p_to_inventory_container_id);
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
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 375
-- Name: FUNCTION do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) IS 'action_api';


--
-- TOC entry 378 (class 1255 OID 22554)
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
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 378
-- Name: FUNCTION get_building_inventory(p_building_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_building_inventory(p_building_id integer) IS 'get_api';


--
-- TOC entry 342 (class 1255 OID 22555)
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
-- TOC entry 341 (class 1255 OID 22556)
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
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 341
-- Name: FUNCTION get_district_inventory(p_district_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_district_inventory(p_district_id integer) IS 'get_api';


--
-- TOC entry 243 (class 1259 OID 22557)
-- Name: inventory_slot_types; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slot_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE inventory.inventory_slot_types OWNER TO postgres;

--
-- TOC entry 368 (class 1255 OID 22561)
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
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 368
-- Name: FUNCTION get_inventory_slot_types(); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types() IS 'automatic_get_api';


--
-- TOC entry 317 (class 1255 OID 22562)
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
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 317
-- Name: FUNCTION get_inventory_slot_types_by_key(p_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 352 (class 1255 OID 22563)
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
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 352
-- Name: FUNCTION get_player_gear_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_gear_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 332 (class 1255 OID 22564)
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
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION get_player_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 365 (class 1255 OID 22565)
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
-- TOC entry 333 (class 1255 OID 22566)
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
-- TOC entry 325 (class 1255 OID 22567)
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
-- TOC entry 244 (class 1259 OID 22568)
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
-- TOC entry 388 (class 1255 OID 22575)
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
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 388
-- Name: FUNCTION get_item_stats(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats() IS 'automatic_get_api';


--
-- TOC entry 314 (class 1255 OID 22576)
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
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 314
-- Name: FUNCTION get_item_stats_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 245 (class 1259 OID 22577)
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
-- TOC entry 387 (class 1255 OID 22587)
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
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 387
-- Name: FUNCTION get_items(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items() IS 'automatic_get_api';


--
-- TOC entry 334 (class 1255 OID 22588)
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
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION get_items_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 319 (class 1255 OID 22589)
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
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 319
-- Name: FUNCTION do_switch_active_player(p_player_id integer, p_switch_to_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) IS 'action_api';


--
-- TOC entry 389 (class 1255 OID 22590)
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
-- TOC entry 385 (class 1255 OID 22591)
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
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 385
-- Name: FUNCTION get_active_player_profile(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_profile(p_player_id integer) IS 'get_api';


--
-- TOC entry 331 (class 1255 OID 22592)
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
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION get_active_player_switch_profiles(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_switch_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 350 (class 1255 OID 22593)
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
-- TOC entry 394 (class 1255 OID 22594)
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
-- TOC entry 344 (class 1255 OID 22595)
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
-- TOC entry 399 (class 1255 OID 22596)
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
-- TOC entry 346 (class 1255 OID 22597)
-- Name: do_player_movement(integer, jsonb); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    tile jsonb;
    scheduled_time timestamp;    
BEGIN
    PERFORM tasks.cancel_task(p_player_id, 'world.player_movement');

    FOR tile IN 
        SELECT * FROM jsonb_array_elements(p_path)
    LOOP
        scheduled_time := NOW() + ((tile->>'totalMoveCost')::integer * interval '1 minute');
        PERFORM tasks.insert_task(p_player_id, scheduled_time , 'world.player_movement', tile);
    END LOOP;

    RETURN QUERY SELECT true, 'Movement actions assigned';
END;
$$;


ALTER FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) OWNER TO postgres;

--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 346
-- Name: FUNCTION do_player_movement(p_player_id integer, p_path jsonb); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) IS 'action_api';


--
-- TOC entry 367 (class 1255 OID 23168)
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
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 367
-- Name: FUNCTION get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer) IS 'get_api';


--
-- TOC entry 320 (class 1255 OID 23190)
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
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION get_known_map_tiles(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_map_tiles(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 373 (class 1255 OID 23169)
-- Name: get_known_players_positions(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) RETURNS TABLE(other_player_id uuid, x integer, y integer, image_map character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
             SELECT  T2.masked_id AS other_player_id 
                     ,T1.map_tile_x AS X 
                     ,T1.map_tile_y AS Y
                     ,t2.image_map AS image_map
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            JOIN knowledge.known_players_positions T3 ON T3.other_player_id = T2.id
            WHERE T1.map_id = p_map_id
             AND T3.player_id = p_player_id;
      END;
      $$;


ALTER FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 373
-- Name: FUNCTION get_known_players_positions(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 246 (class 1259 OID 22599)
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
-- TOC entry 391 (class 1255 OID 22605)
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
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 391
-- Name: FUNCTION get_landscape_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types() IS 'automatic_get_api';


--
-- TOC entry 321 (class 1255 OID 22606)
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
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION get_landscape_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 247 (class 1259 OID 22607)
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
-- TOC entry 392 (class 1255 OID 22615)
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
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 392
-- Name: FUNCTION get_map_tiles(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles() IS 'automatic_get_api';


--
-- TOC entry 400 (class 1255 OID 22616)
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
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 400
-- Name: FUNCTION get_map_tiles_by_key(p_map_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 370 (class 1255 OID 22617)
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
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 370
-- Name: FUNCTION get_player_map(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_map(p_player_id integer) IS 'get_api';


--
-- TOC entry 316 (class 1255 OID 23195)
-- Name: get_player_movement(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_movement(p_player_id integer) RETURNS TABLE("order" integer, move_cost integer, x integer, y integer, total_move_cost integer)
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
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 316
-- Name: FUNCTION get_player_movement(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_movement(p_player_id integer) IS 'get_api';


--
-- TOC entry 356 (class 1255 OID 22619)
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
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 356
-- Name: FUNCTION get_player_position(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 323 (class 1255 OID 23170)
-- Name: get_players_on_the_same_tile(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_players_on_the_same_tile(p_map_id integer, p_player_id integer) RETURNS TABLE(other_player_id uuid, name character varying, second_name character varying, nickname character varying, image_map character varying, image_portrait character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN

RETURN QUERY          
WITH active_player_pos AS (
    SELECT map_tile_x, map_tile_y
    FROM world.map_tiles_players_positions
    WHERE map_id = p_map_id
      AND player_id = p_player_id
)
SELECT      p.masked_id AS other_player_id,
            p.name,
            p.second_name,
            p.nickname,
            p.image_map,
            p.image_portrait
FROM world.map_tiles_players_positions mp
JOIN players.players p ON mp.player_id = p.id
JOIN active_player_pos ap ON mp.map_tile_x = ap.map_tile_x
                         AND mp.map_tile_y = ap.map_tile_y
WHERE mp.map_id = p_map_id
  AND mp.player_id <> p_player_id;

END;
$$;


ALTER FUNCTION world.get_players_on_the_same_tile(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION get_players_on_the_same_tile(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_players_on_the_same_tile(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 248 (class 1259 OID 22621)
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
-- TOC entry 361 (class 1255 OID 22627)
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
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 361
-- Name: FUNCTION get_terrain_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types() IS 'automatic_get_api';


--
-- TOC entry 310 (class 1255 OID 22628)
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
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 310
-- Name: FUNCTION get_terrain_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 355 (class 1255 OID 22629)
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
               (method_parameters->>'y')::int AS y
        FROM tasks.tasks
        WHERE method_name = 'world.player_movement'
          AND status IN (1, 2)
          AND scheduled_at <= now()
        ORDER BY
            player_id,
            (method_parameters->>'totalMoveCost')::int DESC
    ) T1
    WHERE mp.player_id = T1.player_id;
    
    

    UPDATE tasks.tasks
    SET status = 3
    WHERE method_name = 'world.player_movement'
      AND status IN (1, 2)
      AND scheduled_at <= now();
    
    
END;
$$;


ALTER PROCEDURE world.player_movement() OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 22630)
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
-- TOC entry 250 (class 1259 OID 22631)
-- Name: ability_skill_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_skill_requirements (
    ability_id integer NOT NULL,
    skill_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_skill_requirements OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 22638)
-- Name: ability_stat_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_stat_requirements (
    ability_id integer NOT NULL,
    stat_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_stat_requirements OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 22645)
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
-- TOC entry 253 (class 1259 OID 22646)
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
-- TOC entry 254 (class 1259 OID 22653)
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
-- TOC entry 255 (class 1259 OID 22654)
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
-- TOC entry 256 (class 1259 OID 22661)
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
-- TOC entry 257 (class 1259 OID 22662)
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
-- TOC entry 258 (class 1259 OID 22663)
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
-- TOC entry 259 (class 1259 OID 22664)
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
-- TOC entry 260 (class 1259 OID 22665)
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
-- TOC entry 261 (class 1259 OID 22675)
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
-- TOC entry 262 (class 1259 OID 22676)
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
-- TOC entry 263 (class 1259 OID 22683)
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
-- TOC entry 264 (class 1259 OID 22684)
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
-- TOC entry 265 (class 1259 OID 22690)
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
-- TOC entry 266 (class 1259 OID 22691)
-- Name: verification_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.verification_token (
    identifier text NOT NULL,
    expires timestamp with time zone NOT NULL,
    token text NOT NULL
);


ALTER TABLE auth.verification_token OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 22699)
-- Name: building_roles; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_roles (
    building_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE buildings.building_roles OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 22705)
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
-- TOC entry 269 (class 1259 OID 22706)
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
-- TOC entry 270 (class 1259 OID 22707)
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
-- TOC entry 271 (class 1259 OID 22708)
-- Name: city_roles; Type: TABLE; Schema: cities; Owner: postgres
--

CREATE TABLE cities.city_roles (
    city_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE cities.city_roles OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 22714)
-- Name: district_roles; Type: TABLE; Schema: districts; Owner: postgres
--

CREATE TABLE districts.district_roles (
    district_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE districts.district_roles OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 22720)
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
-- TOC entry 274 (class 1259 OID 22721)
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
-- TOC entry 275 (class 1259 OID 22722)
-- Name: inventory_container_types; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_container_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE inventory.inventory_container_types OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 22726)
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
-- TOC entry 277 (class 1259 OID 22727)
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
-- TOC entry 278 (class 1259 OID 22736)
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
-- TOC entry 279 (class 1259 OID 22737)
-- Name: inventory_slot_type_item_type; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slot_type_item_type (
    inventory_slot_type_id integer NOT NULL,
    item_type_id integer NOT NULL
);


ALTER TABLE inventory.inventory_slot_type_item_type OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 22742)
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
-- TOC entry 281 (class 1259 OID 22743)
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
-- TOC entry 282 (class 1259 OID 22750)
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
-- TOC entry 283 (class 1259 OID 22751)
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
-- TOC entry 284 (class 1259 OID 22752)
-- Name: item_types; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.item_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE items.item_types OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 22756)
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
-- TOC entry 286 (class 1259 OID 22757)
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
-- TOC entry 306 (class 1259 OID 23161)
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
-- TOC entry 287 (class 1259 OID 22758)
-- Name: known_players_positions; Type: TABLE; Schema: knowledge; Owner: postgres
--

CREATE TABLE knowledge.known_players_positions (
    player_id integer CONSTRAINT known_players_positions_observer_player_id_not_null NOT NULL,
    other_player_id integer CONSTRAINT known_players_positions_observed_player_id_not_null NOT NULL
);


ALTER TABLE knowledge.known_players_positions OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 22763)
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
-- TOC entry 289 (class 1259 OID 22779)
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
-- TOC entry 290 (class 1259 OID 22780)
-- Name: status_types; Type: TABLE; Schema: tasks; Owner: postgres
--

CREATE TABLE tasks.status_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE tasks.status_types OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 22785)
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
-- TOC entry 292 (class 1259 OID 22786)
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
-- TOC entry 293 (class 1259 OID 22796)
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
-- TOC entry 294 (class 1259 OID 22797)
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
-- TOC entry 295 (class 1259 OID 22798)
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
-- TOC entry 296 (class 1259 OID 22807)
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
-- TOC entry 297 (class 1259 OID 22808)
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
-- TOC entry 298 (class 1259 OID 22815)
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
-- TOC entry 299 (class 1259 OID 22822)
-- Name: maps; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.maps (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE world.maps OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 22827)
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
-- TOC entry 301 (class 1259 OID 22828)
-- Name: region_types; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.region_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE world.region_types OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 22833)
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
-- TOC entry 303 (class 1259 OID 22834)
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
-- TOC entry 304 (class 1259 OID 22835)
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
-- TOC entry 305 (class 1259 OID 22839)
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
-- TOC entry 5353 (class 0 OID 22436)
-- Dependencies: 232
-- Data for Name: abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.abilities (id, name, description, image) FROM stdin;
2	Explore	Explore new land's	Eye
1	Colonize	Settle Nomad's	Tent
\.


--
-- TOC entry 5371 (class 0 OID 22631)
-- Dependencies: 250
-- Data for Name: ability_skill_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_skill_requirements (ability_id, skill_id, min_value) FROM stdin;
1	1	1
2	2	1
\.


--
-- TOC entry 5372 (class 0 OID 22638)
-- Dependencies: 251
-- Data for Name: ability_stat_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_stat_requirements (ability_id, stat_id, min_value) FROM stdin;
\.


--
-- TOC entry 5354 (class 0 OID 22446)
-- Dependencies: 233
-- Data for Name: player_abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_abilities (id, player_id, ability_id, value) FROM stdin;
1	1	1	1
2	1	2	1
3	2	1	1
4	2	2	1
5	3	1	1
6	3	2	1
\.


--
-- TOC entry 5374 (class 0 OID 22646)
-- Dependencies: 253
-- Data for Name: player_skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_skills (id, player_id, skill_id, value) FROM stdin;
1	1	1	7
2	1	2	9
3	1	3	7
4	2	1	10
5	2	2	7
6	2	3	5
7	3	1	8
8	3	2	2
9	3	3	4
\.


--
-- TOC entry 5376 (class 0 OID 22654)
-- Dependencies: 255
-- Data for Name: player_stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_stats (id, player_id, stat_id, value) FROM stdin;
1	1	1	5
2	1	3	9
3	1	4	4
4	1	5	4
5	1	6	9
6	1	7	6
7	1	2	8
8	2	1	7
9	2	3	3
10	2	4	2
11	2	5	4
12	2	6	3
13	2	7	1
14	2	2	1
15	3	1	1
16	3	3	2
17	3	4	8
18	3	5	3
19	3	6	6
20	3	7	2
21	3	2	10
\.


--
-- TOC entry 5355 (class 0 OID 22458)
-- Dependencies: 234
-- Data for Name: roles; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.roles (id, name) FROM stdin;
1	Owner
\.


--
-- TOC entry 5356 (class 0 OID 22464)
-- Dependencies: 235
-- Data for Name: skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.skills (id, name, description, image) FROM stdin;
1	Colonization	Settle new world's !	Tent
2	Survival	Navigate wilderness and find resources stay alive	TreePine
3	Trade	How cheap can you buy ?	HandCoinsIcon
\.


--
-- TOC entry 5357 (class 0 OID 22474)
-- Dependencies: 236
-- Data for Name: stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.stats (id, name, description, image) FROM stdin;
1	Health	Your character's life force	Heart
3	Strength	Strength represents a creature's ability to exert physical force	HandFist
4	Dexterity	Dexterity represents a creature's agility and reflexes	Rabbit
5	Intelligence	Intelligence represents a creature's recall, as well as their ability to reason and think quickly	Brain
6	Wisdom	Wisdom represents a creature's awareness of their surroundings and their intuition	BookOpenText
7	Charisma	Charisma represents a creature's ability to exert their will when interacting with others	Speech
2	Stamina	Energy for physical actions	Activity
\.


--
-- TOC entry 5381 (class 0 OID 22665)
-- Dependencies: 260
-- Data for Name: accounts; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.accounts (id, "userId", type, provider, "providerAccountId", refresh_token, access_token, expires_at, id_token, scope, session_state, token_type) FROM stdin;
\.


--
-- TOC entry 5383 (class 0 OID 22676)
-- Dependencies: 262
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.sessions (id, "userId", expires, "sessionToken") FROM stdin;
\.


--
-- TOC entry 5385 (class 0 OID 22684)
-- Dependencies: 264
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.users (id, name, email, "emailVerified", image, password) FROM stdin;
1	ciabat	pszabat001@gmail.com	\N	\N	$2b$10$4IQKRdaQ8l29u9KEdy6G6esjYGPJe9rQsWlAqPSe0OgbzyjsV6rCW
\.


--
-- TOC entry 5387 (class 0 OID 22691)
-- Dependencies: 266
-- Data for Name: verification_token; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.verification_token (identifier, expires, token) FROM stdin;
\.


--
-- TOC entry 5388 (class 0 OID 22699)
-- Dependencies: 267
-- Data for Name: building_roles; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_roles (building_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5358 (class 0 OID 22487)
-- Dependencies: 237
-- Data for Name: building_types; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_types (id, name, image_url) FROM stdin;
1	Townhall	Townhall.png
2	Marketplace	Marketplace.png
3	Shacks	Shacks.png
4	Logistics	Logistics.png
\.


--
-- TOC entry 5359 (class 0 OID 22494)
-- Dependencies: 238
-- Data for Name: buildings; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.buildings (id, city_id, city_tile_x, city_tile_y, building_type_id, name) FROM stdin;
\.


--
-- TOC entry 5360 (class 0 OID 22505)
-- Dependencies: 239
-- Data for Name: cities; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.cities (id, map_id, map_tile_x, map_tile_y, name, move_cost, image_url) FROM stdin;
\.


--
-- TOC entry 5392 (class 0 OID 22708)
-- Dependencies: 271
-- Data for Name: city_roles; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.city_roles (city_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5361 (class 0 OID 22516)
-- Dependencies: 240
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
-- TOC entry 5393 (class 0 OID 22714)
-- Dependencies: 272
-- Data for Name: district_roles; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_roles (district_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5362 (class 0 OID 22527)
-- Dependencies: 241
-- Data for Name: district_types; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_types (id, name, move_cost, image_url) FROM stdin;
1	Farmland	1	full_farmland.png
\.


--
-- TOC entry 5363 (class 0 OID 22535)
-- Dependencies: 242
-- Data for Name: districts; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.districts (id, map_id, map_tile_x, map_tile_y, district_type_id, name) FROM stdin;
\.


--
-- TOC entry 5396 (class 0 OID 22722)
-- Dependencies: 275
-- Data for Name: inventory_container_types; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_container_types (id, name) FROM stdin;
1	Player
2	PlayerGear
3	Building
4	District
\.


--
-- TOC entry 5398 (class 0 OID 22727)
-- Dependencies: 277
-- Data for Name: inventory_containers; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_containers (id, inventory_size, inventory_container_type_id, owner_id) FROM stdin;
1	9	1	1
2	13	2	1
3	9	1	2
4	13	2	2
5	9	1	3
6	13	2	3
\.


--
-- TOC entry 5400 (class 0 OID 22737)
-- Dependencies: 279
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
-- TOC entry 5364 (class 0 OID 22557)
-- Dependencies: 243
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
-- TOC entry 5402 (class 0 OID 22743)
-- Dependencies: 281
-- Data for Name: inventory_slots; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slots (id, inventory_container_id, item_id, quantity, inventory_slot_type_id) FROM stdin;
1	1	\N	\N	1
2	1	\N	\N	1
3	1	\N	\N	1
4	1	\N	\N	1
5	1	\N	\N	1
6	1	\N	\N	1
7	1	\N	\N	1
8	1	\N	\N	1
9	1	\N	\N	1
10	2	\N	\N	2
11	2	\N	\N	3
12	2	\N	\N	4
13	2	\N	\N	5
14	2	\N	\N	6
15	2	\N	\N	7
16	2	\N	\N	8
17	2	\N	\N	9
18	2	\N	\N	10
19	2	\N	\N	11
20	2	\N	\N	12
21	2	\N	\N	13
22	2	\N	\N	14
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
\.


--
-- TOC entry 5365 (class 0 OID 22568)
-- Dependencies: 244
-- Data for Name: item_stats; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_stats (id, item_id, stat_id, value) FROM stdin;
\.


--
-- TOC entry 5405 (class 0 OID 22752)
-- Dependencies: 284
-- Data for Name: item_types; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_types (id, name) FROM stdin;
1	Any
2	Helmet
3	Trinket
4	Armor
5	Weapon
6	Shield
7	Belt
8	Boots
9	Ring
10	Glove
\.


--
-- TOC entry 5366 (class 0 OID 22577)
-- Dependencies: 245
-- Data for Name: items; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.items (id, name, description, image, item_type_id) FROM stdin;
1	Food	\N	Herbalism	1
2	Sword	\N	Sword	5
3	Helmet	\N	default.png	2
\.


--
-- TOC entry 5425 (class 0 OID 23161)
-- Dependencies: 306
-- Data for Name: known_map_tiles; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_map_tiles (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
1	1	33	33
1	1	33	34
1	1	33	35
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
1	1	1	2
1	1	2	2
1	1	3	2
1	1	4	2
1	1	5	2
1	1	6	2
1	1	7	2
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
1	1	1	3
1	1	2	3
1	1	3	3
1	1	4	3
1	1	5	3
1	1	6	3
1	1	7	3
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
1	1	1	4
1	1	2	4
1	1	3	4
1	1	4	4
1	1	5	4
1	1	6	4
1	1	7	4
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
1	1	1	5
1	1	2	5
1	1	3	5
1	1	4	5
1	1	5	5
1	1	6	5
1	1	7	5
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
1	1	1	6
1	1	2	6
1	1	3	6
1	1	4	6
1	1	5	6
1	1	6	6
1	1	7	6
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
1	1	1	7
1	1	2	7
1	1	3	7
1	1	4	7
1	1	5	7
1	1	6	7
1	1	7	7
2	1	40	3
2	1	41	3
2	1	42	3
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
\.


--
-- TOC entry 5408 (class 0 OID 22758)
-- Dependencies: 287
-- Data for Name: known_players_positions; Type: TABLE DATA; Schema: knowledge; Owner: postgres
--

COPY knowledge.known_players_positions (player_id, other_player_id) FROM stdin;
1	2
\.


--
-- TOC entry 5409 (class 0 OID 22763)
-- Dependencies: 288
-- Data for Name: players; Type: TABLE DATA; Schema: players; Owner: postgres
--

COPY players.players (id, user_id, name, image_map, image_portrait, is_active, second_name, nickname, masked_id) FROM stdin;
3	1	Pawlak	default.png	default.png	f	Dad	\N	2aaeddd1-95e7-4d45-a9a8-241dd2edd8ba
2	1	Pawlak	default.png	default.png	f	Odeon	\N	225b7dc2-d925-4d52-bcfb-255167ed40e1
1	1	Ciabat	default.png	default.png	t	Ciabatos	\N	b867b072-10d4-49b0-8919-ce01a6a55ee0
\.


--
-- TOC entry 5411 (class 0 OID 22780)
-- Dependencies: 290
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
-- TOC entry 5413 (class 0 OID 22786)
-- Dependencies: 292
-- Data for Name: tasks; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

COPY tasks.tasks (id, player_id, status, created_at, scheduled_at, last_executed_at, error, method_name, method_parameters) FROM stdin;
177	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:32:09.44881	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
178	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:44:09.44881	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
179	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:45:09.44881	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
180	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:51:09.44881	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
181	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:52:09.44881	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
182	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:53:09.44881	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
183	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:54:09.44881	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
184	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:55:09.44881	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
185	1	5	2026-02-18 14:32:09.44881	2026-02-18 14:58:09.44881	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
186	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:01:09.44881	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
187	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:02:09.44881	\N	\N	world.player_movement	{"x": 13, "y": 7, "moveCost": 1, "totalMoveCost": 30}
188	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:03:09.44881	\N	\N	world.player_movement	{"x": 13, "y": 8, "moveCost": 1, "totalMoveCost": 31}
189	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:04:09.44881	\N	\N	world.player_movement	{"x": 14, "y": 9, "moveCost": 3, "totalMoveCost": 32}
190	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:07:09.44881	\N	\N	world.player_movement	{"x": 15, "y": 10, "moveCost": 1, "totalMoveCost": 35}
191	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:08:09.44881	\N	\N	world.player_movement	{"x": 16, "y": 11, "moveCost": 1, "totalMoveCost": 36}
192	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:09:09.44881	\N	\N	world.player_movement	{"x": 17, "y": 12, "moveCost": 3, "totalMoveCost": 37}
193	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:12:09.44881	\N	\N	world.player_movement	{"x": 18, "y": 13, "moveCost": 1, "totalMoveCost": 40}
194	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:13:09.44881	\N	\N	world.player_movement	{"x": 19, "y": 14, "moveCost": 1, "totalMoveCost": 41}
195	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:14:09.44881	\N	\N	world.player_movement	{"x": 19, "y": 15, "moveCost": 1, "totalMoveCost": 42}
196	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:15:09.44881	\N	\N	world.player_movement	{"x": 18, "y": 16, "moveCost": 3, "totalMoveCost": 43}
197	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:18:09.44881	\N	\N	world.player_movement	{"x": 17, "y": 17, "moveCost": 1, "totalMoveCost": 46}
198	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:19:09.44881	\N	\N	world.player_movement	{"x": 16, "y": 17, "moveCost": 1, "totalMoveCost": 47}
199	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:20:09.44881	\N	\N	world.player_movement	{"x": 15, "y": 18, "moveCost": 3, "totalMoveCost": 48}
200	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:23:09.44881	\N	\N	world.player_movement	{"x": 14, "y": 19, "moveCost": 1, "totalMoveCost": 51}
201	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:24:09.44881	\N	\N	world.player_movement	{"x": 13, "y": 20, "moveCost": 3, "totalMoveCost": 52}
202	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:27:09.44881	\N	\N	world.player_movement	{"x": 12, "y": 21, "moveCost": 3, "totalMoveCost": 55}
203	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:30:09.44881	\N	\N	world.player_movement	{"x": 12, "y": 22, "moveCost": 1, "totalMoveCost": 58}
204	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:31:09.44881	\N	\N	world.player_movement	{"x": 11, "y": 23, "moveCost": 3, "totalMoveCost": 59}
205	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:34:09.44881	\N	\N	world.player_movement	{"x": 11, "y": 24, "moveCost": 3, "totalMoveCost": 62}
206	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:37:09.44881	\N	\N	world.player_movement	{"x": 11, "y": 25, "moveCost": 1, "totalMoveCost": 65}
207	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:38:09.44881	\N	\N	world.player_movement	{"x": 11, "y": 26, "moveCost": 1, "totalMoveCost": 66}
208	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:39:09.44881	\N	\N	world.player_movement	{"x": 12, "y": 27, "moveCost": 1, "totalMoveCost": 67}
209	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:40:09.44881	\N	\N	world.player_movement	{"x": 13, "y": 28, "moveCost": 1, "totalMoveCost": 68}
210	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:41:09.44881	\N	\N	world.player_movement	{"x": 14, "y": 29, "moveCost": 1, "totalMoveCost": 69}
211	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:42:09.44881	\N	\N	world.player_movement	{"x": 15, "y": 30, "moveCost": 1, "totalMoveCost": 70}
1	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:29:10.658838	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
2	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:41:10.658838	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
3	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:42:10.658838	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
4	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:48:10.658838	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
5	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:49:10.658838	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
6	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:50:10.658838	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
7	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:51:10.658838	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
8	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:52:10.658838	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
9	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:55:10.658838	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
10	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:58:10.658838	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
11	1	5	2026-02-18 14:29:10.658838	2026-02-18 14:59:10.658838	\N	\N	world.player_movement	{"x": 13, "y": 4, "moveCost": 1, "totalMoveCost": 30}
12	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:00:10.658838	\N	\N	world.player_movement	{"x": 14, "y": 3, "moveCost": 3, "totalMoveCost": 31}
13	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:03:10.658838	\N	\N	world.player_movement	{"x": 15, "y": 2, "moveCost": 1, "totalMoveCost": 34}
14	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:04:10.658838	\N	\N	world.player_movement	{"x": 16, "y": 3, "moveCost": 1, "totalMoveCost": 35}
15	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:05:10.658838	\N	\N	world.player_movement	{"x": 17, "y": 2, "moveCost": 1, "totalMoveCost": 36}
16	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:06:10.658838	\N	\N	world.player_movement	{"x": 18, "y": 3, "moveCost": 1, "totalMoveCost": 37}
17	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:07:10.658838	\N	\N	world.player_movement	{"x": 19, "y": 4, "moveCost": 1, "totalMoveCost": 38}
18	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:08:10.658838	\N	\N	world.player_movement	{"x": 20, "y": 5, "moveCost": 1, "totalMoveCost": 39}
19	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:09:10.658838	\N	\N	world.player_movement	{"x": 21, "y": 5, "moveCost": 1, "totalMoveCost": 40}
20	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:10:10.658838	\N	\N	world.player_movement	{"x": 22, "y": 5, "moveCost": 1, "totalMoveCost": 41}
21	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:11:10.658838	\N	\N	world.player_movement	{"x": 23, "y": 4, "moveCost": 1, "totalMoveCost": 42}
22	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:12:10.658838	\N	\N	world.player_movement	{"x": 24, "y": 5, "moveCost": 3, "totalMoveCost": 43}
23	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:15:10.658838	\N	\N	world.player_movement	{"x": 25, "y": 6, "moveCost": 3, "totalMoveCost": 46}
24	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:18:10.658838	\N	\N	world.player_movement	{"x": 26, "y": 7, "moveCost": 1, "totalMoveCost": 49}
25	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:19:10.658838	\N	\N	world.player_movement	{"x": 26, "y": 8, "moveCost": 1, "totalMoveCost": 50}
26	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:20:10.658838	\N	\N	world.player_movement	{"x": 27, "y": 9, "moveCost": 3, "totalMoveCost": 51}
27	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:23:10.658838	\N	\N	world.player_movement	{"x": 28, "y": 9, "moveCost": 1, "totalMoveCost": 54}
28	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:24:10.658838	\N	\N	world.player_movement	{"x": 29, "y": 10, "moveCost": 1, "totalMoveCost": 55}
29	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:25:10.658838	\N	\N	world.player_movement	{"x": 30, "y": 9, "moveCost": 1, "totalMoveCost": 56}
30	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:26:10.658838	\N	\N	world.player_movement	{"x": 31, "y": 9, "moveCost": 1, "totalMoveCost": 57}
31	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:27:10.658838	\N	\N	world.player_movement	{"x": 32, "y": 10, "moveCost": 1, "totalMoveCost": 58}
32	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:28:10.658838	\N	\N	world.player_movement	{"x": 33, "y": 11, "moveCost": 3, "totalMoveCost": 59}
33	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:31:10.658838	\N	\N	world.player_movement	{"x": 34, "y": 12, "moveCost": 1, "totalMoveCost": 62}
34	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:32:10.658838	\N	\N	world.player_movement	{"x": 35, "y": 13, "moveCost": 3, "totalMoveCost": 63}
35	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:35:10.658838	\N	\N	world.player_movement	{"x": 36, "y": 14, "moveCost": 1, "totalMoveCost": 66}
36	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:36:10.658838	\N	\N	world.player_movement	{"x": 37, "y": 15, "moveCost": 3, "totalMoveCost": 67}
37	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:39:10.658838	\N	\N	world.player_movement	{"x": 38, "y": 16, "moveCost": 3, "totalMoveCost": 70}
38	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:42:10.658838	\N	\N	world.player_movement	{"x": 39, "y": 17, "moveCost": 3, "totalMoveCost": 73}
39	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:45:10.658838	\N	\N	world.player_movement	{"x": 40, "y": 18, "moveCost": 3, "totalMoveCost": 76}
40	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:48:10.658838	\N	\N	world.player_movement	{"x": 41, "y": 19, "moveCost": 1, "totalMoveCost": 79}
41	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:49:10.658838	\N	\N	world.player_movement	{"x": 42, "y": 20, "moveCost": 3, "totalMoveCost": 80}
42	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:52:10.658838	\N	\N	world.player_movement	{"x": 43, "y": 20, "moveCost": 3, "totalMoveCost": 83}
43	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:55:10.658838	\N	\N	world.player_movement	{"x": 44, "y": 20, "moveCost": 3, "totalMoveCost": 86}
44	1	5	2026-02-18 14:29:10.658838	2026-02-18 15:58:10.658838	\N	\N	world.player_movement	{"x": 45, "y": 19, "moveCost": 6, "totalMoveCost": 89}
45	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:04:10.658838	\N	\N	world.player_movement	{"x": 46, "y": 18, "moveCost": 1, "totalMoveCost": 95}
46	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:05:10.658838	\N	\N	world.player_movement	{"x": 47, "y": 18, "moveCost": 6, "totalMoveCost": 96}
47	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:11:10.658838	\N	\N	world.player_movement	{"x": 48, "y": 17, "moveCost": 1, "totalMoveCost": 102}
48	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:12:10.658838	\N	\N	world.player_movement	{"x": 49, "y": 18, "moveCost": 1, "totalMoveCost": 103}
49	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:13:10.658838	\N	\N	world.player_movement	{"x": 50, "y": 17, "moveCost": 1, "totalMoveCost": 104}
50	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:14:10.658838	\N	\N	world.player_movement	{"x": 51, "y": 18, "moveCost": 3, "totalMoveCost": 105}
51	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:17:10.658838	\N	\N	world.player_movement	{"x": 52, "y": 19, "moveCost": 1, "totalMoveCost": 108}
52	1	5	2026-02-18 14:29:10.658838	2026-02-18 16:18:10.658838	\N	\N	world.player_movement	{"x": 52, "y": 20, "moveCost": 1, "totalMoveCost": 109}
429	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:15:46.252811	\N	\N	world.player_movement	{"x": 20, "y": 5, "moveCost": 1, "totalMoveCost": 39}
430	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:16:46.252811	\N	\N	world.player_movement	{"x": 21, "y": 5, "moveCost": 1, "totalMoveCost": 40}
431	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:17:46.252811	\N	\N	world.player_movement	{"x": 22, "y": 5, "moveCost": 1, "totalMoveCost": 41}
432	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:18:46.252811	\N	\N	world.player_movement	{"x": 23, "y": 4, "moveCost": 1, "totalMoveCost": 42}
433	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:19:46.252811	\N	\N	world.player_movement	{"x": 24, "y": 5, "moveCost": 3, "totalMoveCost": 43}
434	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:22:46.252811	\N	\N	world.player_movement	{"x": 25, "y": 6, "moveCost": 3, "totalMoveCost": 46}
435	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:25:46.252811	\N	\N	world.player_movement	{"x": 26, "y": 7, "moveCost": 1, "totalMoveCost": 49}
412	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:36:46.252811	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
413	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:48:46.252811	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
414	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:49:46.252811	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
415	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:55:46.252811	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
416	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:56:46.252811	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
417	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:57:46.252811	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
418	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:58:46.252811	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
419	1	5	2026-02-18 14:36:46.252811	2026-02-18 14:59:46.252811	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
420	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:02:46.252811	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
421	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:05:46.252811	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
422	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:06:46.252811	\N	\N	world.player_movement	{"x": 13, "y": 4, "moveCost": 1, "totalMoveCost": 30}
423	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:07:46.252811	\N	\N	world.player_movement	{"x": 14, "y": 3, "moveCost": 3, "totalMoveCost": 31}
53	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:31:32.129012	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
54	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:43:32.129012	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
55	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:44:32.129012	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
56	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:50:32.129012	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
57	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:51:32.129012	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
58	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:52:32.129012	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
59	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:53:32.129012	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
60	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:54:32.129012	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
61	1	5	2026-02-18 14:31:32.129012	2026-02-18 14:57:32.129012	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
62	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:00:32.129012	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
63	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:01:32.129012	\N	\N	world.player_movement	{"x": 13, "y": 7, "moveCost": 1, "totalMoveCost": 30}
64	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:02:32.129012	\N	\N	world.player_movement	{"x": 13, "y": 8, "moveCost": 1, "totalMoveCost": 31}
65	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:03:32.129012	\N	\N	world.player_movement	{"x": 14, "y": 9, "moveCost": 3, "totalMoveCost": 32}
66	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:06:32.129012	\N	\N	world.player_movement	{"x": 15, "y": 10, "moveCost": 1, "totalMoveCost": 35}
67	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:07:32.129012	\N	\N	world.player_movement	{"x": 16, "y": 11, "moveCost": 1, "totalMoveCost": 36}
68	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:08:32.129012	\N	\N	world.player_movement	{"x": 17, "y": 12, "moveCost": 3, "totalMoveCost": 37}
69	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:11:32.129012	\N	\N	world.player_movement	{"x": 18, "y": 13, "moveCost": 1, "totalMoveCost": 40}
70	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:12:32.129012	\N	\N	world.player_movement	{"x": 19, "y": 14, "moveCost": 1, "totalMoveCost": 41}
71	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:13:32.129012	\N	\N	world.player_movement	{"x": 19, "y": 15, "moveCost": 1, "totalMoveCost": 42}
72	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:14:32.129012	\N	\N	world.player_movement	{"x": 18, "y": 16, "moveCost": 3, "totalMoveCost": 43}
73	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:17:32.129012	\N	\N	world.player_movement	{"x": 17, "y": 17, "moveCost": 1, "totalMoveCost": 46}
74	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:18:32.129012	\N	\N	world.player_movement	{"x": 16, "y": 17, "moveCost": 1, "totalMoveCost": 47}
75	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:19:32.129012	\N	\N	world.player_movement	{"x": 15, "y": 18, "moveCost": 3, "totalMoveCost": 48}
76	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:22:32.129012	\N	\N	world.player_movement	{"x": 14, "y": 19, "moveCost": 1, "totalMoveCost": 51}
77	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:23:32.129012	\N	\N	world.player_movement	{"x": 13, "y": 20, "moveCost": 3, "totalMoveCost": 52}
78	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:26:32.129012	\N	\N	world.player_movement	{"x": 12, "y": 21, "moveCost": 3, "totalMoveCost": 55}
79	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:29:32.129012	\N	\N	world.player_movement	{"x": 12, "y": 22, "moveCost": 1, "totalMoveCost": 58}
80	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:30:32.129012	\N	\N	world.player_movement	{"x": 11, "y": 23, "moveCost": 3, "totalMoveCost": 59}
218	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:34:54.917933	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
219	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:46:54.917933	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
220	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:47:54.917933	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
81	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:33:32.129012	\N	\N	world.player_movement	{"x": 11, "y": 24, "moveCost": 3, "totalMoveCost": 62}
82	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:36:32.129012	\N	\N	world.player_movement	{"x": 11, "y": 25, "moveCost": 1, "totalMoveCost": 65}
83	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:37:32.129012	\N	\N	world.player_movement	{"x": 10, "y": 26, "moveCost": 1, "totalMoveCost": 66}
84	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:38:32.129012	\N	\N	world.player_movement	{"x": 9, "y": 25, "moveCost": 1, "totalMoveCost": 67}
85	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:39:32.129012	\N	\N	world.player_movement	{"x": 8, "y": 25, "moveCost": 3, "totalMoveCost": 68}
86	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:42:32.129012	\N	\N	world.player_movement	{"x": 7, "y": 26, "moveCost": 3, "totalMoveCost": 71}
87	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:45:32.129012	\N	\N	world.player_movement	{"x": 7, "y": 27, "moveCost": 3, "totalMoveCost": 74}
88	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:48:32.129012	\N	\N	world.player_movement	{"x": 8, "y": 28, "moveCost": 1, "totalMoveCost": 77}
89	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:49:32.129012	\N	\N	world.player_movement	{"x": 7, "y": 29, "moveCost": 1, "totalMoveCost": 78}
90	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:50:32.129012	\N	\N	world.player_movement	{"x": 8, "y": 30, "moveCost": 1, "totalMoveCost": 79}
91	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:51:32.129012	\N	\N	world.player_movement	{"x": 7, "y": 31, "moveCost": 5, "totalMoveCost": 80}
92	1	5	2026-02-18 14:31:32.129012	2026-02-18 15:56:32.129012	\N	\N	world.player_movement	{"x": 6, "y": 32, "moveCost": 5, "totalMoveCost": 85}
221	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:53:54.917933	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
222	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:54:54.917933	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
223	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:55:54.917933	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
224	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:56:54.917933	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
225	1	5	2026-02-18 14:34:54.917933	2026-02-18 14:57:54.917933	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
226	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:00:54.917933	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
227	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:03:54.917933	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
228	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:04:54.917933	\N	\N	world.player_movement	{"x": 13, "y": 4, "moveCost": 1, "totalMoveCost": 30}
229	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:05:54.917933	\N	\N	world.player_movement	{"x": 14, "y": 3, "moveCost": 3, "totalMoveCost": 31}
230	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:08:54.917933	\N	\N	world.player_movement	{"x": 15, "y": 2, "moveCost": 1, "totalMoveCost": 34}
231	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:09:54.917933	\N	\N	world.player_movement	{"x": 16, "y": 3, "moveCost": 1, "totalMoveCost": 35}
232	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:10:54.917933	\N	\N	world.player_movement	{"x": 17, "y": 2, "moveCost": 1, "totalMoveCost": 36}
233	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:11:54.917933	\N	\N	world.player_movement	{"x": 18, "y": 3, "moveCost": 1, "totalMoveCost": 37}
234	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:12:54.917933	\N	\N	world.player_movement	{"x": 19, "y": 4, "moveCost": 1, "totalMoveCost": 38}
235	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:13:54.917933	\N	\N	world.player_movement	{"x": 20, "y": 4, "moveCost": 1, "totalMoveCost": 39}
236	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:14:54.917933	\N	\N	world.player_movement	{"x": 21, "y": 5, "moveCost": 1, "totalMoveCost": 40}
237	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:15:54.917933	\N	\N	world.player_movement	{"x": 22, "y": 4, "moveCost": 1, "totalMoveCost": 41}
238	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:16:54.917933	\N	\N	world.player_movement	{"x": 23, "y": 4, "moveCost": 1, "totalMoveCost": 42}
239	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:17:54.917933	\N	\N	world.player_movement	{"x": 24, "y": 4, "moveCost": 3, "totalMoveCost": 43}
240	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:20:54.917933	\N	\N	world.player_movement	{"x": 25, "y": 5, "moveCost": 3, "totalMoveCost": 46}
241	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:23:54.917933	\N	\N	world.player_movement	{"x": 26, "y": 4, "moveCost": 1, "totalMoveCost": 49}
242	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:24:54.917933	\N	\N	world.player_movement	{"x": 27, "y": 5, "moveCost": 1, "totalMoveCost": 50}
243	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:25:54.917933	\N	\N	world.player_movement	{"x": 28, "y": 5, "moveCost": 1, "totalMoveCost": 51}
244	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:26:54.917933	\N	\N	world.player_movement	{"x": 29, "y": 6, "moveCost": 3, "totalMoveCost": 52}
245	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:29:54.917933	\N	\N	world.player_movement	{"x": 30, "y": 7, "moveCost": 1, "totalMoveCost": 55}
246	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:30:54.917933	\N	\N	world.player_movement	{"x": 31, "y": 8, "moveCost": 1, "totalMoveCost": 56}
247	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:31:54.917933	\N	\N	world.player_movement	{"x": 31, "y": 9, "moveCost": 1, "totalMoveCost": 57}
248	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:32:54.917933	\N	\N	world.player_movement	{"x": 32, "y": 10, "moveCost": 1, "totalMoveCost": 58}
249	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:33:54.917933	\N	\N	world.player_movement	{"x": 33, "y": 11, "moveCost": 3, "totalMoveCost": 59}
250	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:36:54.917933	\N	\N	world.player_movement	{"x": 34, "y": 12, "moveCost": 1, "totalMoveCost": 62}
251	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:37:54.917933	\N	\N	world.player_movement	{"x": 35, "y": 13, "moveCost": 3, "totalMoveCost": 63}
252	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:40:54.917933	\N	\N	world.player_movement	{"x": 36, "y": 12, "moveCost": 5, "totalMoveCost": 66}
253	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:45:54.917933	\N	\N	world.player_movement	{"x": 37, "y": 12, "moveCost": 3, "totalMoveCost": 71}
254	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:48:54.917933	\N	\N	world.player_movement	{"x": 38, "y": 11, "moveCost": 1, "totalMoveCost": 74}
255	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:49:54.917933	\N	\N	world.player_movement	{"x": 39, "y": 11, "moveCost": 3, "totalMoveCost": 75}
256	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:52:54.917933	\N	\N	world.player_movement	{"x": 40, "y": 12, "moveCost": 1, "totalMoveCost": 78}
257	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:53:54.917933	\N	\N	world.player_movement	{"x": 41, "y": 12, "moveCost": 1, "totalMoveCost": 79}
258	1	5	2026-02-18 14:34:54.917933	2026-02-18 15:54:54.917933	\N	\N	world.player_movement	{"x": 42, "y": 11, "moveCost": 6, "totalMoveCost": 80}
259	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:00:54.917933	\N	\N	world.player_movement	{"x": 43, "y": 10, "moveCost": 6, "totalMoveCost": 86}
260	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:06:54.917933	\N	\N	world.player_movement	{"x": 44, "y": 9, "moveCost": 3, "totalMoveCost": 92}
261	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:09:54.917933	\N	\N	world.player_movement	{"x": 45, "y": 8, "moveCost": 1, "totalMoveCost": 95}
262	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:10:54.917933	\N	\N	world.player_movement	{"x": 46, "y": 9, "moveCost": 1, "totalMoveCost": 96}
263	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:11:54.917933	\N	\N	world.player_movement	{"x": 47, "y": 8, "moveCost": 3, "totalMoveCost": 97}
264	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:14:54.917933	\N	\N	world.player_movement	{"x": 48, "y": 8, "moveCost": 1, "totalMoveCost": 100}
93	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:31:57.813288	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
94	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:43:57.813288	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
95	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:44:57.813288	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
96	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:50:57.813288	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
97	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:51:57.813288	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
98	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:52:57.813288	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
99	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:53:57.813288	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
100	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:54:57.813288	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
101	1	5	2026-02-18 14:31:57.813288	2026-02-18 14:57:57.813288	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
102	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:00:57.813288	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
103	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:01:57.813288	\N	\N	world.player_movement	{"x": 13, "y": 7, "moveCost": 1, "totalMoveCost": 30}
104	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:02:57.813288	\N	\N	world.player_movement	{"x": 13, "y": 8, "moveCost": 1, "totalMoveCost": 31}
105	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:03:57.813288	\N	\N	world.player_movement	{"x": 14, "y": 9, "moveCost": 3, "totalMoveCost": 32}
106	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:06:57.813288	\N	\N	world.player_movement	{"x": 15, "y": 10, "moveCost": 1, "totalMoveCost": 35}
107	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:07:57.813288	\N	\N	world.player_movement	{"x": 16, "y": 11, "moveCost": 1, "totalMoveCost": 36}
108	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:08:57.813288	\N	\N	world.player_movement	{"x": 17, "y": 12, "moveCost": 3, "totalMoveCost": 37}
109	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:11:57.813288	\N	\N	world.player_movement	{"x": 18, "y": 13, "moveCost": 1, "totalMoveCost": 40}
110	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:12:57.813288	\N	\N	world.player_movement	{"x": 19, "y": 14, "moveCost": 1, "totalMoveCost": 41}
111	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:13:57.813288	\N	\N	world.player_movement	{"x": 19, "y": 15, "moveCost": 1, "totalMoveCost": 42}
112	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:14:57.813288	\N	\N	world.player_movement	{"x": 18, "y": 16, "moveCost": 3, "totalMoveCost": 43}
113	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:17:57.813288	\N	\N	world.player_movement	{"x": 17, "y": 17, "moveCost": 1, "totalMoveCost": 46}
114	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:18:57.813288	\N	\N	world.player_movement	{"x": 16, "y": 17, "moveCost": 1, "totalMoveCost": 47}
115	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:19:57.813288	\N	\N	world.player_movement	{"x": 15, "y": 18, "moveCost": 3, "totalMoveCost": 48}
116	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:22:57.813288	\N	\N	world.player_movement	{"x": 14, "y": 19, "moveCost": 1, "totalMoveCost": 51}
117	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:23:57.813288	\N	\N	world.player_movement	{"x": 13, "y": 20, "moveCost": 3, "totalMoveCost": 52}
118	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:26:57.813288	\N	\N	world.player_movement	{"x": 12, "y": 21, "moveCost": 3, "totalMoveCost": 55}
119	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:29:57.813288	\N	\N	world.player_movement	{"x": 12, "y": 22, "moveCost": 1, "totalMoveCost": 58}
120	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:30:57.813288	\N	\N	world.player_movement	{"x": 11, "y": 23, "moveCost": 3, "totalMoveCost": 59}
121	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:33:57.813288	\N	\N	world.player_movement	{"x": 11, "y": 24, "moveCost": 3, "totalMoveCost": 62}
122	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:36:57.813288	\N	\N	world.player_movement	{"x": 11, "y": 25, "moveCost": 1, "totalMoveCost": 65}
123	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:37:57.813288	\N	\N	world.player_movement	{"x": 10, "y": 26, "moveCost": 1, "totalMoveCost": 66}
124	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:38:57.813288	\N	\N	world.player_movement	{"x": 9, "y": 25, "moveCost": 1, "totalMoveCost": 67}
125	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:39:57.813288	\N	\N	world.player_movement	{"x": 8, "y": 24, "moveCost": 1, "totalMoveCost": 68}
126	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:40:57.813288	\N	\N	world.player_movement	{"x": 7, "y": 25, "moveCost": 3, "totalMoveCost": 69}
127	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:43:57.813288	\N	\N	world.player_movement	{"x": 6, "y": 25, "moveCost": 3, "totalMoveCost": 72}
128	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:46:57.813288	\N	\N	world.player_movement	{"x": 5, "y": 26, "moveCost": 1, "totalMoveCost": 75}
129	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:47:57.813288	\N	\N	world.player_movement	{"x": 4, "y": 27, "moveCost": 3, "totalMoveCost": 76}
130	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:50:57.813288	\N	\N	world.player_movement	{"x": 3, "y": 28, "moveCost": 1, "totalMoveCost": 79}
131	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:51:57.813288	\N	\N	world.player_movement	{"x": 2, "y": 29, "moveCost": 1, "totalMoveCost": 80}
132	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:52:57.813288	\N	\N	world.player_movement	{"x": 3, "y": 30, "moveCost": 3, "totalMoveCost": 81}
133	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:55:57.813288	\N	\N	world.player_movement	{"x": 3, "y": 31, "moveCost": 1, "totalMoveCost": 84}
134	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:56:57.813288	\N	\N	world.player_movement	{"x": 3, "y": 32, "moveCost": 1, "totalMoveCost": 85}
135	1	5	2026-02-18 14:31:57.813288	2026-02-18 15:57:57.813288	\N	\N	world.player_movement	{"x": 4, "y": 33, "moveCost": 3, "totalMoveCost": 86}
136	1	5	2026-02-18 14:31:57.813288	2026-02-18 16:00:57.813288	\N	\N	world.player_movement	{"x": 5, "y": 34, "moveCost": 5, "totalMoveCost": 89}
265	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:15:54.917933	\N	\N	world.player_movement	{"x": 49, "y": 7, "moveCost": 1, "totalMoveCost": 101}
266	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:16:54.917933	\N	\N	world.player_movement	{"x": 49, "y": 6, "moveCost": 1, "totalMoveCost": 102}
267	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:17:54.917933	\N	\N	world.player_movement	{"x": 50, "y": 5, "moveCost": 1, "totalMoveCost": 103}
268	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:18:54.917933	\N	\N	world.player_movement	{"x": 49, "y": 4, "moveCost": 1, "totalMoveCost": 104}
269	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:19:54.917933	\N	\N	world.player_movement	{"x": 50, "y": 3, "moveCost": 4, "totalMoveCost": 105}
270	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:23:54.917933	\N	\N	world.player_movement	{"x": 51, "y": 2, "moveCost": 4, "totalMoveCost": 109}
271	1	5	2026-02-18 14:34:54.917933	2026-02-18 16:27:54.917933	\N	\N	world.player_movement	{"x": 51, "y": 1, "moveCost": 4, "totalMoveCost": 113}
272	1	5	2026-02-18 14:35:13.081081	2026-02-18 14:35:13.081081	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
424	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:10:46.252811	\N	\N	world.player_movement	{"x": 15, "y": 2, "moveCost": 1, "totalMoveCost": 34}
425	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:11:46.252811	\N	\N	world.player_movement	{"x": 16, "y": 3, "moveCost": 1, "totalMoveCost": 35}
315	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:07:17.799377	\N	\N	world.player_movement	{"x": 44, "y": 9, "moveCost": 3, "totalMoveCost": 92}
316	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:10:17.799377	\N	\N	world.player_movement	{"x": 45, "y": 8, "moveCost": 1, "totalMoveCost": 95}
317	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:11:17.799377	\N	\N	world.player_movement	{"x": 46, "y": 9, "moveCost": 1, "totalMoveCost": 96}
318	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:12:17.799377	\N	\N	world.player_movement	{"x": 47, "y": 8, "moveCost": 3, "totalMoveCost": 97}
319	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:15:17.799377	\N	\N	world.player_movement	{"x": 48, "y": 8, "moveCost": 1, "totalMoveCost": 100}
320	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:16:17.799377	\N	\N	world.player_movement	{"x": 49, "y": 7, "moveCost": 1, "totalMoveCost": 101}
321	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:17:17.799377	\N	\N	world.player_movement	{"x": 50, "y": 8, "moveCost": 1, "totalMoveCost": 102}
322	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:18:17.799377	\N	\N	world.player_movement	{"x": 51, "y": 7, "moveCost": 1, "totalMoveCost": 103}
323	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:19:17.799377	\N	\N	world.player_movement	{"x": 52, "y": 6, "moveCost": 1, "totalMoveCost": 104}
426	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:12:46.252811	\N	\N	world.player_movement	{"x": 17, "y": 2, "moveCost": 1, "totalMoveCost": 36}
427	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:13:46.252811	\N	\N	world.player_movement	{"x": 18, "y": 3, "moveCost": 1, "totalMoveCost": 37}
428	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:14:46.252811	\N	\N	world.player_movement	{"x": 19, "y": 4, "moveCost": 1, "totalMoveCost": 38}
436	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:26:46.252811	\N	\N	world.player_movement	{"x": 26, "y": 8, "moveCost": 1, "totalMoveCost": 50}
437	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:27:46.252811	\N	\N	world.player_movement	{"x": 27, "y": 9, "moveCost": 3, "totalMoveCost": 51}
438	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:30:46.252811	\N	\N	world.player_movement	{"x": 28, "y": 9, "moveCost": 1, "totalMoveCost": 54}
439	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:31:46.252811	\N	\N	world.player_movement	{"x": 29, "y": 10, "moveCost": 1, "totalMoveCost": 55}
440	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:32:46.252811	\N	\N	world.player_movement	{"x": 30, "y": 9, "moveCost": 1, "totalMoveCost": 56}
441	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:33:46.252811	\N	\N	world.player_movement	{"x": 31, "y": 9, "moveCost": 1, "totalMoveCost": 57}
442	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:34:46.252811	\N	\N	world.player_movement	{"x": 32, "y": 10, "moveCost": 1, "totalMoveCost": 58}
443	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:35:46.252811	\N	\N	world.player_movement	{"x": 33, "y": 11, "moveCost": 3, "totalMoveCost": 59}
444	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:38:46.252811	\N	\N	world.player_movement	{"x": 34, "y": 12, "moveCost": 1, "totalMoveCost": 62}
445	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:39:46.252811	\N	\N	world.player_movement	{"x": 35, "y": 13, "moveCost": 3, "totalMoveCost": 63}
446	1	5	2026-02-18 14:36:46.252811	2026-02-18 15:42:46.252811	\N	\N	world.player_movement	{"x": 35, "y": 14, "moveCost": 1, "totalMoveCost": 66}
137	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:32:06.027509	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
138	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:44:06.027509	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
139	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:45:06.027509	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
140	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:51:06.027509	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
141	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:52:06.027509	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
142	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:53:06.027509	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
143	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:54:06.027509	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
144	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:55:06.027509	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
145	1	5	2026-02-18 14:32:06.027509	2026-02-18 14:58:06.027509	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
146	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:01:06.027509	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
147	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:02:06.027509	\N	\N	world.player_movement	{"x": 13, "y": 7, "moveCost": 1, "totalMoveCost": 30}
148	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:03:06.027509	\N	\N	world.player_movement	{"x": 13, "y": 8, "moveCost": 1, "totalMoveCost": 31}
149	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:04:06.027509	\N	\N	world.player_movement	{"x": 14, "y": 9, "moveCost": 3, "totalMoveCost": 32}
150	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:07:06.027509	\N	\N	world.player_movement	{"x": 15, "y": 10, "moveCost": 1, "totalMoveCost": 35}
151	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:08:06.027509	\N	\N	world.player_movement	{"x": 16, "y": 11, "moveCost": 1, "totalMoveCost": 36}
152	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:09:06.027509	\N	\N	world.player_movement	{"x": 17, "y": 12, "moveCost": 3, "totalMoveCost": 37}
153	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:12:06.027509	\N	\N	world.player_movement	{"x": 18, "y": 13, "moveCost": 1, "totalMoveCost": 40}
154	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:13:06.027509	\N	\N	world.player_movement	{"x": 19, "y": 14, "moveCost": 1, "totalMoveCost": 41}
155	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:14:06.027509	\N	\N	world.player_movement	{"x": 19, "y": 15, "moveCost": 1, "totalMoveCost": 42}
156	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:15:06.027509	\N	\N	world.player_movement	{"x": 18, "y": 16, "moveCost": 3, "totalMoveCost": 43}
157	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:18:06.027509	\N	\N	world.player_movement	{"x": 17, "y": 17, "moveCost": 1, "totalMoveCost": 46}
158	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:19:06.027509	\N	\N	world.player_movement	{"x": 16, "y": 17, "moveCost": 1, "totalMoveCost": 47}
159	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:20:06.027509	\N	\N	world.player_movement	{"x": 15, "y": 18, "moveCost": 3, "totalMoveCost": 48}
160	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:23:06.027509	\N	\N	world.player_movement	{"x": 14, "y": 19, "moveCost": 1, "totalMoveCost": 51}
161	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:24:06.027509	\N	\N	world.player_movement	{"x": 13, "y": 20, "moveCost": 3, "totalMoveCost": 52}
162	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:27:06.027509	\N	\N	world.player_movement	{"x": 12, "y": 21, "moveCost": 3, "totalMoveCost": 55}
163	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:30:06.027509	\N	\N	world.player_movement	{"x": 12, "y": 22, "moveCost": 1, "totalMoveCost": 58}
164	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:31:06.027509	\N	\N	world.player_movement	{"x": 11, "y": 23, "moveCost": 3, "totalMoveCost": 59}
165	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:34:06.027509	\N	\N	world.player_movement	{"x": 11, "y": 24, "moveCost": 3, "totalMoveCost": 62}
166	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:37:06.027509	\N	\N	world.player_movement	{"x": 11, "y": 25, "moveCost": 1, "totalMoveCost": 65}
167	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:38:06.027509	\N	\N	world.player_movement	{"x": 11, "y": 26, "moveCost": 1, "totalMoveCost": 66}
168	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:39:06.027509	\N	\N	world.player_movement	{"x": 12, "y": 27, "moveCost": 1, "totalMoveCost": 67}
169	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:40:06.027509	\N	\N	world.player_movement	{"x": 13, "y": 28, "moveCost": 1, "totalMoveCost": 68}
170	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:41:06.027509	\N	\N	world.player_movement	{"x": 14, "y": 29, "moveCost": 1, "totalMoveCost": 69}
171	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:42:06.027509	\N	\N	world.player_movement	{"x": 15, "y": 30, "moveCost": 1, "totalMoveCost": 70}
172	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:43:06.027509	\N	\N	world.player_movement	{"x": 14, "y": 31, "moveCost": 1, "totalMoveCost": 71}
173	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:44:06.027509	\N	\N	world.player_movement	{"x": 14, "y": 32, "moveCost": 3, "totalMoveCost": 72}
174	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:47:06.027509	\N	\N	world.player_movement	{"x": 13, "y": 33, "moveCost": 1, "totalMoveCost": 75}
175	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:48:06.027509	\N	\N	world.player_movement	{"x": 12, "y": 34, "moveCost": 1, "totalMoveCost": 76}
176	1	5	2026-02-18 14:32:06.027509	2026-02-18 15:49:06.027509	\N	\N	world.player_movement	{"x": 11, "y": 34, "moveCost": 6, "totalMoveCost": 77}
212	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:43:09.44881	\N	\N	world.player_movement	{"x": 14, "y": 31, "moveCost": 1, "totalMoveCost": 71}
213	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:44:09.44881	\N	\N	world.player_movement	{"x": 14, "y": 32, "moveCost": 3, "totalMoveCost": 72}
214	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:47:09.44881	\N	\N	world.player_movement	{"x": 13, "y": 33, "moveCost": 1, "totalMoveCost": 75}
215	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:48:09.44881	\N	\N	world.player_movement	{"x": 12, "y": 34, "moveCost": 1, "totalMoveCost": 76}
216	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:49:09.44881	\N	\N	world.player_movement	{"x": 11, "y": 34, "moveCost": 6, "totalMoveCost": 77}
217	1	5	2026-02-18 14:32:09.44881	2026-02-18 15:55:09.44881	\N	\N	world.player_movement	{"x": 10, "y": 33, "moveCost": 6, "totalMoveCost": 83}
284	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:06:17.799377	\N	\N	world.player_movement	{"x": 14, "y": 3, "moveCost": 3, "totalMoveCost": 31}
285	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:09:17.799377	\N	\N	world.player_movement	{"x": 15, "y": 2, "moveCost": 1, "totalMoveCost": 34}
286	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:10:17.799377	\N	\N	world.player_movement	{"x": 16, "y": 3, "moveCost": 1, "totalMoveCost": 35}
287	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:11:17.799377	\N	\N	world.player_movement	{"x": 17, "y": 2, "moveCost": 1, "totalMoveCost": 36}
288	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:12:17.799377	\N	\N	world.player_movement	{"x": 18, "y": 3, "moveCost": 1, "totalMoveCost": 37}
289	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:13:17.799377	\N	\N	world.player_movement	{"x": 19, "y": 4, "moveCost": 1, "totalMoveCost": 38}
324	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:20:17.799377	\N	\N	world.player_movement	{"x": 53, "y": 6, "moveCost": 3, "totalMoveCost": 105}
325	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:23:17.799377	\N	\N	world.player_movement	{"x": 54, "y": 5, "moveCost": 1, "totalMoveCost": 108}
273	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:35:17.799377	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
274	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:47:17.799377	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
275	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:48:17.799377	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
276	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:54:17.799377	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
277	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:55:17.799377	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
278	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:56:17.799377	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
279	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:57:17.799377	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
280	1	5	2026-02-18 14:35:17.799377	2026-02-18 14:58:17.799377	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
281	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:01:17.799377	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
282	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:04:17.799377	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
283	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:05:17.799377	\N	\N	world.player_movement	{"x": 13, "y": 4, "moveCost": 1, "totalMoveCost": 30}
290	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:14:17.799377	\N	\N	world.player_movement	{"x": 20, "y": 5, "moveCost": 1, "totalMoveCost": 39}
291	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:15:17.799377	\N	\N	world.player_movement	{"x": 21, "y": 5, "moveCost": 1, "totalMoveCost": 40}
292	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:16:17.799377	\N	\N	world.player_movement	{"x": 22, "y": 5, "moveCost": 1, "totalMoveCost": 41}
293	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:17:17.799377	\N	\N	world.player_movement	{"x": 23, "y": 4, "moveCost": 1, "totalMoveCost": 42}
294	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:18:17.799377	\N	\N	world.player_movement	{"x": 24, "y": 5, "moveCost": 3, "totalMoveCost": 43}
295	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:21:17.799377	\N	\N	world.player_movement	{"x": 25, "y": 5, "moveCost": 3, "totalMoveCost": 46}
296	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:24:17.799377	\N	\N	world.player_movement	{"x": 26, "y": 5, "moveCost": 1, "totalMoveCost": 49}
297	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:25:17.799377	\N	\N	world.player_movement	{"x": 27, "y": 5, "moveCost": 1, "totalMoveCost": 50}
298	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:26:17.799377	\N	\N	world.player_movement	{"x": 28, "y": 5, "moveCost": 1, "totalMoveCost": 51}
299	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:27:17.799377	\N	\N	world.player_movement	{"x": 29, "y": 6, "moveCost": 3, "totalMoveCost": 52}
300	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:30:17.799377	\N	\N	world.player_movement	{"x": 30, "y": 7, "moveCost": 1, "totalMoveCost": 55}
301	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:31:17.799377	\N	\N	world.player_movement	{"x": 31, "y": 8, "moveCost": 1, "totalMoveCost": 56}
302	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:32:17.799377	\N	\N	world.player_movement	{"x": 31, "y": 9, "moveCost": 1, "totalMoveCost": 57}
303	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:33:17.799377	\N	\N	world.player_movement	{"x": 32, "y": 10, "moveCost": 1, "totalMoveCost": 58}
304	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:34:17.799377	\N	\N	world.player_movement	{"x": 33, "y": 11, "moveCost": 3, "totalMoveCost": 59}
305	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:37:17.799377	\N	\N	world.player_movement	{"x": 34, "y": 12, "moveCost": 1, "totalMoveCost": 62}
306	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:38:17.799377	\N	\N	world.player_movement	{"x": 35, "y": 13, "moveCost": 3, "totalMoveCost": 63}
307	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:41:17.799377	\N	\N	world.player_movement	{"x": 36, "y": 12, "moveCost": 5, "totalMoveCost": 66}
308	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:46:17.799377	\N	\N	world.player_movement	{"x": 37, "y": 12, "moveCost": 3, "totalMoveCost": 71}
309	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:49:17.799377	\N	\N	world.player_movement	{"x": 38, "y": 11, "moveCost": 1, "totalMoveCost": 74}
310	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:50:17.799377	\N	\N	world.player_movement	{"x": 39, "y": 11, "moveCost": 3, "totalMoveCost": 75}
311	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:53:17.799377	\N	\N	world.player_movement	{"x": 40, "y": 12, "moveCost": 1, "totalMoveCost": 78}
312	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:54:17.799377	\N	\N	world.player_movement	{"x": 41, "y": 12, "moveCost": 1, "totalMoveCost": 79}
313	1	5	2026-02-18 14:35:17.799377	2026-02-18 15:55:17.799377	\N	\N	world.player_movement	{"x": 42, "y": 11, "moveCost": 6, "totalMoveCost": 80}
314	1	5	2026-02-18 14:35:17.799377	2026-02-18 16:01:17.799377	\N	\N	world.player_movement	{"x": 43, "y": 10, "moveCost": 6, "totalMoveCost": 86}
326	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:35:33.880506	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
327	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:47:33.880506	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
328	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:48:33.880506	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
329	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:54:33.880506	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
330	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:55:33.880506	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
331	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:56:33.880506	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
332	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:57:33.880506	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
333	1	5	2026-02-18 14:35:33.880506	2026-02-18 14:58:33.880506	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
334	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:01:33.880506	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
335	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:04:33.880506	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
336	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:05:33.880506	\N	\N	world.player_movement	{"x": 13, "y": 4, "moveCost": 1, "totalMoveCost": 30}
337	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:06:33.880506	\N	\N	world.player_movement	{"x": 14, "y": 3, "moveCost": 3, "totalMoveCost": 31}
338	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:09:33.880506	\N	\N	world.player_movement	{"x": 15, "y": 2, "moveCost": 1, "totalMoveCost": 34}
339	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:10:33.880506	\N	\N	world.player_movement	{"x": 16, "y": 3, "moveCost": 1, "totalMoveCost": 35}
340	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:11:33.880506	\N	\N	world.player_movement	{"x": 17, "y": 2, "moveCost": 1, "totalMoveCost": 36}
341	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:12:33.880506	\N	\N	world.player_movement	{"x": 18, "y": 3, "moveCost": 1, "totalMoveCost": 37}
342	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:13:33.880506	\N	\N	world.player_movement	{"x": 19, "y": 4, "moveCost": 1, "totalMoveCost": 38}
343	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:14:33.880506	\N	\N	world.player_movement	{"x": 20, "y": 4, "moveCost": 1, "totalMoveCost": 39}
344	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:15:33.880506	\N	\N	world.player_movement	{"x": 21, "y": 5, "moveCost": 1, "totalMoveCost": 40}
345	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:16:33.880506	\N	\N	world.player_movement	{"x": 22, "y": 4, "moveCost": 1, "totalMoveCost": 41}
346	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:17:33.880506	\N	\N	world.player_movement	{"x": 23, "y": 4, "moveCost": 1, "totalMoveCost": 42}
347	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:18:33.880506	\N	\N	world.player_movement	{"x": 24, "y": 4, "moveCost": 3, "totalMoveCost": 43}
348	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:21:33.880506	\N	\N	world.player_movement	{"x": 25, "y": 5, "moveCost": 3, "totalMoveCost": 46}
349	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:24:33.880506	\N	\N	world.player_movement	{"x": 26, "y": 4, "moveCost": 1, "totalMoveCost": 49}
350	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:25:33.880506	\N	\N	world.player_movement	{"x": 27, "y": 5, "moveCost": 1, "totalMoveCost": 50}
351	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:26:33.880506	\N	\N	world.player_movement	{"x": 28, "y": 5, "moveCost": 1, "totalMoveCost": 51}
352	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:27:33.880506	\N	\N	world.player_movement	{"x": 29, "y": 6, "moveCost": 3, "totalMoveCost": 52}
353	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:30:33.880506	\N	\N	world.player_movement	{"x": 30, "y": 7, "moveCost": 1, "totalMoveCost": 55}
354	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:31:33.880506	\N	\N	world.player_movement	{"x": 31, "y": 8, "moveCost": 1, "totalMoveCost": 56}
355	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:32:33.880506	\N	\N	world.player_movement	{"x": 31, "y": 9, "moveCost": 1, "totalMoveCost": 57}
356	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:33:33.880506	\N	\N	world.player_movement	{"x": 32, "y": 10, "moveCost": 1, "totalMoveCost": 58}
357	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:34:33.880506	\N	\N	world.player_movement	{"x": 33, "y": 11, "moveCost": 3, "totalMoveCost": 59}
358	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:37:33.880506	\N	\N	world.player_movement	{"x": 34, "y": 12, "moveCost": 1, "totalMoveCost": 62}
359	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:38:33.880506	\N	\N	world.player_movement	{"x": 35, "y": 13, "moveCost": 3, "totalMoveCost": 63}
360	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:41:33.880506	\N	\N	world.player_movement	{"x": 36, "y": 12, "moveCost": 5, "totalMoveCost": 66}
361	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:46:33.880506	\N	\N	world.player_movement	{"x": 37, "y": 12, "moveCost": 3, "totalMoveCost": 71}
362	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:49:33.880506	\N	\N	world.player_movement	{"x": 38, "y": 11, "moveCost": 1, "totalMoveCost": 74}
363	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:50:33.880506	\N	\N	world.player_movement	{"x": 38, "y": 10, "moveCost": 1, "totalMoveCost": 75}
364	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:51:33.880506	\N	\N	world.player_movement	{"x": 39, "y": 9, "moveCost": 3, "totalMoveCost": 76}
365	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:54:33.880506	\N	\N	world.player_movement	{"x": 39, "y": 8, "moveCost": 3, "totalMoveCost": 79}
366	1	5	2026-02-18 14:35:33.880506	2026-02-18 15:57:33.880506	\N	\N	world.player_movement	{"x": 40, "y": 7, "moveCost": 6, "totalMoveCost": 82}
367	1	5	2026-02-18 14:35:33.880506	2026-02-18 16:03:33.880506	\N	\N	world.player_movement	{"x": 41, "y": 7, "moveCost": 6, "totalMoveCost": 88}
368	1	5	2026-02-18 14:35:33.880506	2026-02-18 16:09:33.880506	\N	\N	world.player_movement	{"x": 42, "y": 7, "moveCost": 1, "totalMoveCost": 94}
369	1	5	2026-02-18 14:35:33.880506	2026-02-18 16:10:33.880506	\N	\N	world.player_movement	{"x": 43, "y": 6, "moveCost": 3, "totalMoveCost": 95}
370	1	5	2026-02-18 14:35:33.880506	2026-02-18 16:13:33.880506	\N	\N	world.player_movement	{"x": 44, "y": 5, "moveCost": 3, "totalMoveCost": 98}
371	1	5	2026-02-18 14:35:33.880506	2026-02-18 16:16:33.880506	\N	\N	world.player_movement	{"x": 45, "y": 4, "moveCost": 1, "totalMoveCost": 101}
372	1	5	2026-02-18 14:35:33.880506	2026-02-18 16:17:33.880506	\N	\N	world.player_movement	{"x": 45, "y": 3, "moveCost": 3, "totalMoveCost": 102}
373	1	5	2026-02-18 14:35:33.880506	2026-02-18 16:20:33.880506	\N	\N	world.player_movement	{"x": 46, "y": 2, "moveCost": 1, "totalMoveCost": 105}
374	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:36:22.411663	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
375	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:48:22.411663	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
376	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:49:22.411663	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
377	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:55:22.411663	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
378	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:56:22.411663	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
379	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:57:22.411663	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
380	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:58:22.411663	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
381	1	5	2026-02-18 14:36:22.411663	2026-02-18 14:59:22.411663	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
382	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:02:22.411663	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
383	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:05:22.411663	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
384	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:06:22.411663	\N	\N	world.player_movement	{"x": 13, "y": 7, "moveCost": 1, "totalMoveCost": 30}
385	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:07:22.411663	\N	\N	world.player_movement	{"x": 14, "y": 8, "moveCost": 3, "totalMoveCost": 31}
386	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:10:22.411663	\N	\N	world.player_movement	{"x": 15, "y": 7, "moveCost": 1, "totalMoveCost": 34}
387	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:11:22.411663	\N	\N	world.player_movement	{"x": 16, "y": 8, "moveCost": 1, "totalMoveCost": 35}
388	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:12:22.411663	\N	\N	world.player_movement	{"x": 17, "y": 9, "moveCost": 3, "totalMoveCost": 36}
389	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:15:22.411663	\N	\N	world.player_movement	{"x": 18, "y": 10, "moveCost": 1, "totalMoveCost": 39}
390	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:16:22.411663	\N	\N	world.player_movement	{"x": 19, "y": 11, "moveCost": 3, "totalMoveCost": 40}
391	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:19:22.411663	\N	\N	world.player_movement	{"x": 20, "y": 12, "moveCost": 1, "totalMoveCost": 43}
392	1	5	2026-02-18 14:36:22.411663	2026-02-18 15:20:22.411663	\N	\N	world.player_movement	{"x": 21, "y": 12, "moveCost": 1, "totalMoveCost": 44}
393	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:36:24.29375	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
394	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:48:24.29375	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
395	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:49:24.29375	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
396	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:55:24.29375	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
397	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:56:24.29375	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
398	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:57:24.29375	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
399	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:58:24.29375	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
400	1	5	2026-02-18 14:36:24.29375	2026-02-18 14:59:24.29375	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
401	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:02:24.29375	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
402	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:05:24.29375	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
403	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:06:24.29375	\N	\N	world.player_movement	{"x": 13, "y": 7, "moveCost": 1, "totalMoveCost": 30}
404	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:07:24.29375	\N	\N	world.player_movement	{"x": 14, "y": 8, "moveCost": 3, "totalMoveCost": 31}
405	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:10:24.29375	\N	\N	world.player_movement	{"x": 15, "y": 7, "moveCost": 1, "totalMoveCost": 34}
406	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:11:24.29375	\N	\N	world.player_movement	{"x": 16, "y": 8, "moveCost": 1, "totalMoveCost": 35}
407	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:12:24.29375	\N	\N	world.player_movement	{"x": 17, "y": 9, "moveCost": 3, "totalMoveCost": 36}
408	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:15:24.29375	\N	\N	world.player_movement	{"x": 18, "y": 10, "moveCost": 1, "totalMoveCost": 39}
409	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:16:24.29375	\N	\N	world.player_movement	{"x": 19, "y": 11, "moveCost": 3, "totalMoveCost": 40}
410	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:19:24.29375	\N	\N	world.player_movement	{"x": 20, "y": 12, "moveCost": 1, "totalMoveCost": 43}
411	1	5	2026-02-18 14:36:24.29375	2026-02-18 15:20:24.29375	\N	\N	world.player_movement	{"x": 21, "y": 12, "moveCost": 1, "totalMoveCost": 44}
482	3	1	2026-02-18 21:41:19.302341	2026-02-18 21:41:19.302341	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
483	3	1	2026-02-18 21:41:19.302341	2026-02-18 21:53:19.302341	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
484	3	1	2026-02-18 21:41:19.302341	2026-02-18 21:54:19.302341	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
485	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:00:19.302341	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
486	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:01:19.302341	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
487	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:02:19.302341	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
488	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:03:19.302341	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
489	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:04:19.302341	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
490	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:07:19.302341	\N	\N	world.player_movement	{"x": 10, "y": 5, "moveCost": 3, "totalMoveCost": 26}
491	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:10:19.302341	\N	\N	world.player_movement	{"x": 9, "y": 6, "moveCost": 3, "totalMoveCost": 29}
492	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:13:19.302341	\N	\N	world.player_movement	{"x": 8, "y": 6, "moveCost": 4, "totalMoveCost": 32}
493	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:17:19.302341	\N	\N	world.player_movement	{"x": 7, "y": 7, "moveCost": 11, "totalMoveCost": 36}
494	3	1	2026-02-18 21:41:19.302341	2026-02-18 22:28:19.302341	\N	\N	world.player_movement	{"x": 7, "y": 8, "moveCost": 6, "totalMoveCost": 47}
498	1	5	2026-02-18 21:42:50.19722	2026-02-18 22:01:50.19722	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
499	1	5	2026-02-18 21:42:50.19722	2026-02-18 22:02:50.19722	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
500	1	5	2026-02-19 20:54:51.405923	2026-02-19 20:54:51.405923	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
501	1	5	2026-02-19 20:54:51.405923	2026-02-19 21:06:51.405923	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
502	1	5	2026-02-19 20:54:51.405923	2026-02-19 21:07:51.405923	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
503	1	5	2026-02-19 20:54:51.405923	2026-02-19 21:13:51.405923	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
504	1	5	2026-02-19 20:54:51.405923	2026-02-19 21:14:51.405923	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
505	1	5	2026-02-19 20:54:51.405923	2026-02-19 21:15:51.405923	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
506	1	5	2026-02-19 20:54:51.405923	2026-02-19 21:16:51.405923	\N	\N	world.player_movement	{"x": 9, "y": 1, "moveCost": 1, "totalMoveCost": 22}
652	1	5	2026-02-19 22:44:58.140642	2026-02-19 22:44:58.140642	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
653	1	5	2026-02-19 22:44:58.140642	2026-02-19 22:56:58.140642	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
654	1	5	2026-02-19 22:44:58.140642	2026-02-19 22:57:58.140642	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
655	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:03:58.140642	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
656	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:04:58.140642	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
657	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:05:58.140642	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
658	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:06:58.140642	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
659	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:07:58.140642	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
660	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:10:58.140642	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
691	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:16:33.709538	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
692	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:28:33.709538	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
693	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:29:33.709538	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
694	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:35:33.709538	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
695	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:36:33.709538	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
696	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:37:33.709538	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
697	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:37:33.709538	\N	\N	world.player_movement	{"x": 9, "y": 6, "moveCost": 3, "totalMoveCost": 21}
698	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:40:33.709538	\N	\N	world.player_movement	{"x": 10, "y": 7, "moveCost": 3, "totalMoveCost": 24}
699	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:43:33.709538	\N	\N	world.player_movement	{"x": 11, "y": 8, "moveCost": 3, "totalMoveCost": 27}
700	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:46:33.709538	\N	\N	world.player_movement	{"x": 12, "y": 8, "moveCost": 3, "totalMoveCost": 30}
701	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:49:33.709538	\N	\N	world.player_movement	{"x": 13, "y": 8, "moveCost": 1, "totalMoveCost": 33}
702	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:50:33.709538	\N	\N	world.player_movement	{"x": 14, "y": 8, "moveCost": 3, "totalMoveCost": 34}
447	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:36:49.885778	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
448	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:48:49.885778	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
449	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:49:49.885778	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
450	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:55:49.885778	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
451	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:56:49.885778	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
452	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:57:49.885778	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
453	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:58:49.885778	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
454	1	5	2026-02-18 14:36:49.885778	2026-02-18 14:59:49.885778	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
455	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:02:49.885778	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
456	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:05:49.885778	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
457	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:06:49.885778	\N	\N	world.player_movement	{"x": 13, "y": 4, "moveCost": 1, "totalMoveCost": 30}
458	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:07:49.885778	\N	\N	world.player_movement	{"x": 14, "y": 3, "moveCost": 3, "totalMoveCost": 31}
459	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:10:49.885778	\N	\N	world.player_movement	{"x": 15, "y": 2, "moveCost": 1, "totalMoveCost": 34}
460	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:11:49.885778	\N	\N	world.player_movement	{"x": 16, "y": 3, "moveCost": 1, "totalMoveCost": 35}
461	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:12:49.885778	\N	\N	world.player_movement	{"x": 17, "y": 2, "moveCost": 1, "totalMoveCost": 36}
462	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:13:49.885778	\N	\N	world.player_movement	{"x": 18, "y": 3, "moveCost": 1, "totalMoveCost": 37}
463	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:14:49.885778	\N	\N	world.player_movement	{"x": 19, "y": 4, "moveCost": 1, "totalMoveCost": 38}
464	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:15:49.885778	\N	\N	world.player_movement	{"x": 20, "y": 5, "moveCost": 1, "totalMoveCost": 39}
465	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:16:49.885778	\N	\N	world.player_movement	{"x": 21, "y": 5, "moveCost": 1, "totalMoveCost": 40}
466	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:17:49.885778	\N	\N	world.player_movement	{"x": 22, "y": 5, "moveCost": 1, "totalMoveCost": 41}
467	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:18:49.885778	\N	\N	world.player_movement	{"x": 23, "y": 4, "moveCost": 1, "totalMoveCost": 42}
468	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:19:49.885778	\N	\N	world.player_movement	{"x": 24, "y": 5, "moveCost": 3, "totalMoveCost": 43}
469	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:22:49.885778	\N	\N	world.player_movement	{"x": 25, "y": 6, "moveCost": 3, "totalMoveCost": 46}
470	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:25:49.885778	\N	\N	world.player_movement	{"x": 26, "y": 7, "moveCost": 1, "totalMoveCost": 49}
471	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:26:49.885778	\N	\N	world.player_movement	{"x": 26, "y": 8, "moveCost": 1, "totalMoveCost": 50}
472	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:27:49.885778	\N	\N	world.player_movement	{"x": 27, "y": 9, "moveCost": 3, "totalMoveCost": 51}
473	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:30:49.885778	\N	\N	world.player_movement	{"x": 28, "y": 9, "moveCost": 1, "totalMoveCost": 54}
474	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:31:49.885778	\N	\N	world.player_movement	{"x": 29, "y": 10, "moveCost": 1, "totalMoveCost": 55}
475	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:32:49.885778	\N	\N	world.player_movement	{"x": 30, "y": 9, "moveCost": 1, "totalMoveCost": 56}
476	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:33:49.885778	\N	\N	world.player_movement	{"x": 31, "y": 9, "moveCost": 1, "totalMoveCost": 57}
477	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:34:49.885778	\N	\N	world.player_movement	{"x": 32, "y": 10, "moveCost": 1, "totalMoveCost": 58}
478	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:35:49.885778	\N	\N	world.player_movement	{"x": 33, "y": 11, "moveCost": 3, "totalMoveCost": 59}
479	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:38:49.885778	\N	\N	world.player_movement	{"x": 34, "y": 12, "moveCost": 1, "totalMoveCost": 62}
480	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:39:49.885778	\N	\N	world.player_movement	{"x": 35, "y": 13, "moveCost": 3, "totalMoveCost": 63}
481	1	5	2026-02-18 14:36:49.885778	2026-02-18 15:42:49.885778	\N	\N	world.player_movement	{"x": 35, "y": 14, "moveCost": 1, "totalMoveCost": 66}
495	1	5	2026-02-18 21:42:50.19722	2026-02-18 21:42:50.19722	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
496	1	5	2026-02-18 21:42:50.19722	2026-02-18 21:54:50.19722	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
497	1	5	2026-02-18 21:42:50.19722	2026-02-18 21:55:50.19722	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
507	1	5	2026-02-19 21:13:03.952889	2026-02-19 21:13:03.952889	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
508	1	5	2026-02-19 21:13:03.952889	2026-02-19 21:25:03.952889	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
509	1	5	2026-02-19 21:13:03.952889	2026-02-19 21:26:03.952889	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
510	1	5	2026-02-19 21:13:03.952889	2026-02-19 21:32:03.952889	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
511	1	5	2026-02-19 21:13:03.952889	2026-02-19 21:33:03.952889	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
512	1	5	2026-02-19 21:13:03.952889	2026-02-19 21:34:03.952889	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
513	1	5	2026-02-19 21:13:03.952889	2026-02-19 21:35:03.952889	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
514	1	5	2026-02-19 21:13:22.247235	2026-02-19 21:13:22.247235	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
515	1	5	2026-02-19 21:13:22.247235	2026-02-19 21:25:22.247235	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
516	1	5	2026-02-19 21:13:22.247235	2026-02-19 21:26:22.247235	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
517	1	5	2026-02-19 21:13:22.247235	2026-02-19 21:32:22.247235	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
518	1	5	2026-02-19 21:13:22.247235	2026-02-19 21:33:22.247235	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
519	1	5	2026-02-19 21:13:22.247235	2026-02-19 21:34:22.247235	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
520	1	5	2026-02-19 21:13:22.247235	2026-02-19 21:35:22.247235	\N	\N	world.player_movement	{"x": 9, "y": 1, "moveCost": 1, "totalMoveCost": 22}
521	1	5	2026-02-19 21:13:47.314899	2026-02-19 21:13:47.314899	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
522	1	5	2026-02-19 21:13:47.314899	2026-02-19 21:25:47.314899	\N	\N	world.player_movement	{"x": 2, "y": 2, "moveCost": 6, "totalMoveCost": 12}
523	1	5	2026-02-19 21:13:52.940779	2026-02-19 21:13:52.940779	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
524	1	5	2026-02-19 21:13:52.940779	2026-02-19 21:25:52.940779	\N	\N	world.player_movement	{"x": 2, "y": 2, "moveCost": 6, "totalMoveCost": 12}
525	1	5	2026-02-19 21:13:54.007595	2026-02-19 21:13:54.007595	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
526	1	5	2026-02-19 21:13:54.007595	2026-02-19 21:25:54.007595	\N	\N	world.player_movement	{"x": 2, "y": 2, "moveCost": 6, "totalMoveCost": 12}
527	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:13:57.987429	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
528	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:25:57.987429	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
529	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:26:57.987429	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
530	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:32:57.987429	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
531	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:33:57.987429	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
532	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:34:57.987429	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
533	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:35:57.987429	\N	\N	world.player_movement	{"x": 9, "y": 2, "moveCost": 1, "totalMoveCost": 22}
534	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:36:57.987429	\N	\N	world.player_movement	{"x": 10, "y": 3, "moveCost": 1, "totalMoveCost": 23}
535	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:37:57.987429	\N	\N	world.player_movement	{"x": 11, "y": 2, "moveCost": 6, "totalMoveCost": 24}
536	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:43:57.987429	\N	\N	world.player_movement	{"x": 12, "y": 1, "moveCost": 6, "totalMoveCost": 30}
537	1	5	2026-02-19 21:13:57.987429	2026-02-19 21:49:57.987429	\N	\N	world.player_movement	{"x": 13, "y": 1, "moveCost": 1, "totalMoveCost": 36}
661	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:13:58.140642	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
662	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:14:58.140642	\N	\N	world.player_movement	{"x": 13, "y": 6, "moveCost": 1, "totalMoveCost": 30}
663	1	5	2026-02-19 22:44:58.140642	2026-02-19 23:15:58.140642	\N	\N	world.player_movement	{"x": 14, "y": 6, "moveCost": 3, "totalMoveCost": 31}
664	1	5	2026-02-19 22:48:59.134508	2026-02-19 22:48:59.134508	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
665	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:00:59.134508	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
666	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:01:59.134508	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
667	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:07:59.134508	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
668	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:08:59.134508	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
669	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:09:59.134508	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
670	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:10:59.134508	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
671	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:11:59.134508	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
672	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:14:59.134508	\N	\N	world.player_movement	{"x": 10, "y": 5, "moveCost": 3, "totalMoveCost": 26}
673	1	5	2026-02-19 22:48:59.134508	2026-02-19 23:17:59.134508	\N	\N	world.player_movement	{"x": 9, "y": 6, "moveCost": 3, "totalMoveCost": 29}
705	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:16:46.553405	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
706	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:28:46.553405	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
707	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:29:46.553405	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
708	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:35:46.553405	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
709	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:36:46.553405	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
710	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:37:46.553405	\N	\N	world.player_movement	{"x": 8, "y": 4, "moveCost": 6, "totalMoveCost": 21}
738	1	5	2026-02-19 23:36:24.367161	2026-02-19 23:36:24.367161	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
739	1	5	2026-02-19 23:36:24.367161	2026-02-19 23:48:24.367161	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
740	1	5	2026-02-19 23:36:24.367161	2026-02-19 23:49:24.367161	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
741	1	5	2026-02-19 23:36:24.367161	2026-02-19 23:55:24.367161	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
742	1	5	2026-02-19 23:36:24.367161	2026-02-19 23:56:24.367161	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
761	1	5	2026-02-19 23:52:15.22585	2026-02-20 00:12:15.22585	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
762	1	5	2026-02-19 23:52:15.22585	2026-02-20 00:13:15.22585	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
763	1	5	2026-02-19 23:52:15.22585	2026-02-20 00:13:15.22585	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 99999, "totalMoveCost": 21}
764	1	5	2026-02-20 00:11:43.637916	2026-02-20 00:11:43.637916	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
765	1	5	2026-02-20 00:11:43.637916	2026-02-20 00:23:43.637916	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
766	1	5	2026-02-20 00:11:43.637916	2026-02-20 00:24:43.637916	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
767	1	5	2026-02-20 00:11:43.637916	2026-02-20 00:30:43.637916	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
768	1	5	2026-02-20 00:11:43.637916	2026-02-20 00:31:43.637916	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
779	1	5	2026-02-20 00:13:06.749829	2026-02-20 00:25:06.749829	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
538	1	5	2026-02-19 21:20:56.488666	2026-02-19 21:20:56.488666	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
539	1	5	2026-02-19 21:20:56.488666	2026-02-19 21:32:56.488666	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
540	1	5	2026-02-19 21:20:56.488666	2026-02-19 21:33:56.488666	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
541	1	5	2026-02-19 21:20:56.488666	2026-02-19 21:39:56.488666	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
542	1	5	2026-02-19 21:20:56.488666	2026-02-19 21:40:56.488666	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
543	1	5	2026-02-19 21:20:56.488666	2026-02-19 21:41:56.488666	\N	\N	world.player_movement	{"x": 8, "y": 3, "moveCost": 99999, "totalMoveCost": 21}
544	1	5	2026-02-19 21:20:56.488666	2026-04-30 09:20:56.488666	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 99999, "totalMoveCost": 100020}
545	1	5	2026-02-19 21:20:56.488666	2026-07-08 19:59:56.488666	\N	\N	world.player_movement	{"x": 10, "y": 3, "moveCost": 99999, "totalMoveCost": 200019}
546	1	5	2026-02-19 21:20:57.938555	2026-02-19 21:20:57.938555	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
547	1	5	2026-02-19 21:20:57.938555	2026-02-19 21:32:57.938555	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
548	1	5	2026-02-19 21:20:57.938555	2026-02-19 21:33:57.938555	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
549	1	5	2026-02-19 21:20:57.938555	2026-02-19 21:39:57.938555	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
550	1	5	2026-02-19 21:20:57.938555	2026-02-19 21:40:57.938555	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
551	1	5	2026-02-19 21:20:57.938555	2026-02-19 21:41:57.938555	\N	\N	world.player_movement	{"x": 8, "y": 3, "moveCost": 99999, "totalMoveCost": 21}
552	1	5	2026-02-19 21:20:57.938555	2026-04-30 09:20:57.938555	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 99999, "totalMoveCost": 100020}
553	1	5	2026-02-19 21:20:57.938555	2026-07-08 19:59:57.938555	\N	\N	world.player_movement	{"x": 10, "y": 3, "moveCost": 99999, "totalMoveCost": 200019}
674	1	5	2026-02-19 22:52:18.669755	2026-02-19 22:52:18.669755	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
675	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:04:18.669755	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
676	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:05:18.669755	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
677	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:11:18.669755	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
678	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:12:18.669755	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
679	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:13:18.669755	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
680	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:14:18.669755	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
681	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:15:18.669755	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
682	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:18:18.669755	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
683	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:21:18.669755	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
684	1	5	2026-02-19 22:52:18.669755	2026-02-19 23:22:18.669755	\N	\N	world.player_movement	{"x": 13, "y": 5, "moveCost": 3, "totalMoveCost": 30}
711	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:43:46.553405	\N	\N	world.player_movement	{"x": 9, "y": 4, "moveCost": 6, "totalMoveCost": 27}
712	1	5	2026-02-19 23:16:46.553405	2026-02-19 23:49:46.553405	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 33}
713	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:24:39.438029	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
714	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:36:39.438029	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
743	1	5	2026-02-19 23:44:35.78652	2026-02-19 23:44:35.78652	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
744	1	5	2026-02-19 23:44:35.78652	2026-02-19 23:56:35.78652	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
745	1	5	2026-02-19 23:44:35.78652	2026-02-19 23:57:35.78652	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
746	1	5	2026-02-19 23:44:35.78652	2026-02-20 00:03:35.78652	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
769	1	5	2026-02-20 00:11:43.637916	2026-02-20 00:32:43.637916	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
770	1	5	2026-02-20 00:11:43.637916	2026-02-20 00:32:43.637916	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 21}
554	1	5	2026-02-19 21:23:10.856518	2026-02-19 21:23:10.856518	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
555	1	5	2026-02-19 21:23:10.856518	2026-02-19 21:35:10.856518	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
556	1	5	2026-02-19 21:23:10.856518	2026-02-19 21:36:10.856518	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
557	1	5	2026-02-19 21:23:10.856518	2026-02-19 21:42:10.856518	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
558	1	5	2026-02-19 21:23:10.856518	2026-02-19 21:43:10.856518	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
559	1	5	2026-02-19 21:23:10.856518	2026-02-19 21:44:10.856518	\N	\N	world.player_movement	{"x": 8, "y": 4, "moveCost": 99999, "totalMoveCost": 21}
560	1	5	2026-02-19 21:23:10.856518	2026-04-30 09:23:10.856518	\N	\N	world.player_movement	{"x": 9, "y": 4, "moveCost": 99999, "totalMoveCost": 100020}
561	1	5	2026-02-19 21:23:10.856518	2026-07-08 20:02:10.856518	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 99999, "totalMoveCost": 200019}
562	1	5	2026-02-19 21:23:10.856518	2026-09-16 06:41:10.856518	\N	\N	world.player_movement	{"x": 11, "y": 4, "moveCost": 99999, "totalMoveCost": 300018}
563	1	5	2026-02-19 21:23:10.856518	2026-11-24 16:20:10.856518	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 99999, "totalMoveCost": 400017}
564	1	5	2026-02-19 21:23:13.558976	2026-02-19 21:23:13.558976	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
565	1	5	2026-02-19 21:23:13.558976	2026-02-19 21:35:13.558976	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
566	1	5	2026-02-19 21:23:13.558976	2026-02-19 21:36:13.558976	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
567	1	5	2026-02-19 21:23:13.558976	2026-02-19 21:42:13.558976	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
568	1	5	2026-02-19 21:23:13.558976	2026-02-19 21:43:13.558976	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
569	1	5	2026-02-19 21:23:13.558976	2026-02-19 21:44:13.558976	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 99999, "totalMoveCost": 21}
570	1	5	2026-02-19 21:23:13.558976	2026-04-30 09:23:13.558976	\N	\N	world.player_movement	{"x": 9, "y": 5, "moveCost": 99999, "totalMoveCost": 100020}
571	1	5	2026-02-19 21:23:13.558976	2026-07-08 20:02:13.558976	\N	\N	world.player_movement	{"x": 10, "y": 5, "moveCost": 99999, "totalMoveCost": 200019}
572	1	5	2026-02-19 21:23:13.558976	2026-09-16 06:41:13.558976	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 99999, "totalMoveCost": 300018}
573	1	5	2026-02-19 21:23:13.558976	2026-11-24 16:20:13.558976	\N	\N	world.player_movement	{"x": 12, "y": 5, "moveCost": 99999, "totalMoveCost": 400017}
574	1	5	2026-02-19 21:23:13.558976	2027-02-02 02:59:13.558976	\N	\N	world.player_movement	{"x": 13, "y": 5, "moveCost": 99999, "totalMoveCost": 500016}
575	1	5	2026-02-19 21:23:13.558976	2027-04-12 14:38:13.558976	\N	\N	world.player_movement	{"x": 14, "y": 5, "moveCost": 99999, "totalMoveCost": 600015}
576	1	5	2026-02-19 21:23:13.558976	2027-06-21 01:17:13.558976	\N	\N	world.player_movement	{"x": 15, "y": 5, "moveCost": 99999, "totalMoveCost": 700014}
577	1	5	2026-02-19 21:23:13.558976	2027-08-29 11:56:13.558976	\N	\N	world.player_movement	{"x": 16, "y": 5, "moveCost": 99999, "totalMoveCost": 800013}
578	1	5	2026-02-19 21:23:13.558976	2027-11-06 21:35:13.558976	\N	\N	world.player_movement	{"x": 17, "y": 5, "moveCost": 99999, "totalMoveCost": 900012}
579	1	5	2026-02-19 21:23:13.558976	2028-01-15 08:14:13.558976	\N	\N	world.player_movement	{"x": 18, "y": 5, "moveCost": 99999, "totalMoveCost": 1000011}
580	1	5	2026-02-19 21:23:13.558976	2028-03-24 18:53:13.558976	\N	\N	world.player_movement	{"x": 19, "y": 5, "moveCost": 99999, "totalMoveCost": 1100010}
581	1	5	2026-02-19 21:23:17.96396	2026-02-19 21:23:17.96396	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
582	1	5	2026-02-19 21:23:17.96396	2026-02-19 21:35:17.96396	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
583	1	5	2026-02-19 21:23:17.96396	2026-02-19 21:36:17.96396	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
584	1	5	2026-02-19 21:23:17.96396	2026-02-19 21:42:17.96396	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
585	1	5	2026-02-19 21:23:17.96396	2026-02-19 21:43:17.96396	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
586	1	5	2026-02-19 21:23:17.96396	2026-02-19 21:44:17.96396	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 99999, "totalMoveCost": 21}
587	1	5	2026-02-19 21:23:17.96396	2026-04-30 09:23:17.96396	\N	\N	world.player_movement	{"x": 9, "y": 2, "moveCost": 99999, "totalMoveCost": 100020}
588	1	5	2026-02-19 21:23:17.96396	2026-07-08 20:02:17.96396	\N	\N	world.player_movement	{"x": 10, "y": 2, "moveCost": 99999, "totalMoveCost": 200019}
589	1	5	2026-02-19 21:23:17.96396	2026-09-16 06:41:17.96396	\N	\N	world.player_movement	{"x": 11, "y": 2, "moveCost": 99999, "totalMoveCost": 300018}
590	1	5	2026-02-19 21:23:17.96396	2026-11-24 16:20:17.96396	\N	\N	world.player_movement	{"x": 12, "y": 2, "moveCost": 99999, "totalMoveCost": 400017}
685	1	5	2026-02-19 22:52:45.225646	2026-02-19 22:52:45.225646	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
715	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:37:39.438029	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
716	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:43:39.438029	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
717	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:44:39.438029	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
718	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:45:39.438029	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
719	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:45:39.438029	\N	\N	world.player_movement	{"x": 9, "y": 5, "moveCost": 6, "totalMoveCost": 21}
720	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:51:39.438029	\N	\N	world.player_movement	{"x": 10, "y": 5, "moveCost": 3, "totalMoveCost": 27}
721	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:54:39.438029	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 30}
722	1	5	2026-02-19 23:24:39.438029	2026-02-19 23:57:39.438029	\N	\N	world.player_movement	{"x": 12, "y": 5, "moveCost": 6, "totalMoveCost": 33}
591	1	5	2026-02-19 21:24:57.651165	2026-02-19 21:24:57.651165	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
592	1	5	2026-02-19 21:24:57.651165	2026-02-19 21:36:57.651165	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
593	1	5	2026-02-19 21:24:57.651165	2026-02-19 21:37:57.651165	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
594	1	5	2026-02-19 21:24:57.651165	2026-02-19 21:43:57.651165	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
595	1	5	2026-02-19 21:24:57.651165	2026-02-19 21:44:57.651165	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
596	1	5	2026-02-19 21:24:57.651165	2026-02-19 21:45:57.651165	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 99999, "totalMoveCost": 21}
686	1	5	2026-02-19 23:10:57.361585	2026-02-19 23:10:57.361585	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
687	1	5	2026-02-19 23:10:57.361585	2026-02-19 23:22:57.361585	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
688	1	5	2026-02-19 23:10:57.361585	2026-02-19 23:23:57.361585	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
689	1	5	2026-02-19 23:10:57.361585	2026-02-19 23:29:57.361585	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
690	1	5	2026-02-19 23:10:57.361585	2026-02-19 23:30:57.361585	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
723	1	5	2026-02-19 23:24:39.438029	2026-02-20 00:03:39.438029	\N	\N	world.player_movement	{"x": 13, "y": 5, "moveCost": 3, "totalMoveCost": 39}
724	1	5	2026-02-19 23:25:55.949482	2026-02-19 23:25:55.949482	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
725	1	5	2026-02-19 23:25:57.011974	2026-02-19 23:25:57.011974	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
747	1	5	2026-02-19 23:44:35.78652	2026-02-20 00:04:35.78652	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
748	1	5	2026-02-19 23:44:35.78652	2026-02-20 00:05:35.78652	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 99999, "totalMoveCost": 21}
749	1	5	2026-02-19 23:44:35.78652	2026-04-30 11:44:35.78652	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 100020}
732	1	5	2026-02-19 23:25:59.045728	2026-02-19 23:26:59.045	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 21}
731	1	5	2026-02-19 23:25:59.045728	2026-02-19 23:26:59.045	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
730	1	5	2026-02-19 23:25:59.045728	2026-02-19 23:25:59.045	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
729	1	5	2026-02-19 23:25:59.045728	2026-02-19 23:24:59.045	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
728	1	5	2026-02-19 23:25:59.045728	2026-02-19 23:28:59.045	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
727	1	5	2026-02-19 23:25:59.045728	2026-02-19 23:27:59.045	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
726	1	5	2026-02-19 23:25:59.045728	2026-02-19 23:25:59.045	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
750	1	5	2026-02-19 23:49:48.805356	2026-02-19 23:49:48.805356	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
751	1	5	2026-02-19 23:49:48.805356	2026-02-20 00:01:48.805356	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
752	1	5	2026-02-19 23:49:48.805356	2026-02-20 00:02:48.805356	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
753	1	5	2026-02-19 23:49:48.805356	2026-02-20 00:08:48.805356	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
754	1	5	2026-02-19 23:49:48.805356	2026-02-20 00:09:48.805356	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
755	1	5	2026-02-19 23:49:48.805356	2026-02-20 00:10:48.805356	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
756	1	5	2026-02-19 23:49:48.805356	2026-02-20 00:10:48.805356	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 21}
776	1	5	2026-02-20 00:12:24.144212	2026-02-20 00:33:24.144212	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
777	1	5	2026-02-20 00:12:24.144212	2026-02-20 00:33:24.144212	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 9999999, "totalMoveCost": 21}
780	1	5	2026-02-20 00:13:06.749829	2026-02-20 00:26:06.749829	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
781	1	5	2026-02-20 00:13:06.749829	2026-02-20 00:32:06.749829	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
782	1	5	2026-02-20 00:13:06.749829	2026-02-20 00:33:06.749829	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
783	1	5	2026-02-20 00:13:06.749829	2026-02-20 00:34:06.749829	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 9999999, "totalMoveCost": 21}
784	1	5	2026-02-20 00:13:06.749829	2045-02-24 11:13:06.749829	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 9999999, "totalMoveCost": 10000020}
778	1	5	2026-02-20 00:13:06.749829	2026-02-20 00:13:06.749829	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
597	1	5	2026-02-19 21:24:57.651165	2026-04-30 09:24:57.651165	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 100020}
598	1	5	2026-02-19 21:24:57.651165	2026-04-30 09:30:57.651165	\N	\N	world.player_movement	{"x": 7, "y": 7, "moveCost": 11, "totalMoveCost": 100026}
599	1	5	2026-02-19 21:24:57.651165	2026-04-30 09:41:57.651165	\N	\N	world.player_movement	{"x": 8, "y": 8, "moveCost": 99999, "totalMoveCost": 100037}
600	1	5	2026-02-19 21:24:57.651165	2026-07-08 20:20:57.651165	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 99999, "totalMoveCost": 200036}
601	1	5	2026-02-19 21:24:57.651165	2026-09-16 06:59:57.651165	\N	\N	world.player_movement	{"x": 10, "y": 10, "moveCost": 99999, "totalMoveCost": 300035}
602	1	5	2026-02-19 21:24:57.651165	2026-11-24 16:38:57.651165	\N	\N	world.player_movement	{"x": 11, "y": 11, "moveCost": 99999, "totalMoveCost": 400034}
603	1	5	2026-02-19 21:24:57.651165	2027-02-02 03:17:57.651165	\N	\N	world.player_movement	{"x": 12, "y": 12, "moveCost": 99999, "totalMoveCost": 500033}
604	1	5	2026-02-19 21:24:57.651165	2027-04-12 14:56:57.651165	\N	\N	world.player_movement	{"x": 13, "y": 13, "moveCost": 99999, "totalMoveCost": 600032}
605	1	5	2026-02-19 21:24:57.651165	2027-06-21 01:35:57.651165	\N	\N	world.player_movement	{"x": 14, "y": 14, "moveCost": 99999, "totalMoveCost": 700031}
606	1	5	2026-02-19 21:24:57.651165	2027-08-29 12:14:57.651165	\N	\N	world.player_movement	{"x": 15, "y": 15, "moveCost": 99999, "totalMoveCost": 800030}
607	1	5	2026-02-19 21:24:57.651165	2027-11-06 21:53:57.651165	\N	\N	world.player_movement	{"x": 16, "y": 16, "moveCost": 99999, "totalMoveCost": 900029}
608	1	5	2026-02-19 21:24:57.651165	2028-01-15 08:32:57.651165	\N	\N	world.player_movement	{"x": 17, "y": 17, "moveCost": 99999, "totalMoveCost": 1000028}
609	1	5	2026-02-19 21:24:57.651165	2028-03-24 19:11:57.651165	\N	\N	world.player_movement	{"x": 18, "y": 18, "moveCost": 99999, "totalMoveCost": 1100027}
610	1	5	2026-02-19 21:24:57.651165	2028-06-02 06:50:57.651165	\N	\N	world.player_movement	{"x": 19, "y": 19, "moveCost": 99999, "totalMoveCost": 1200026}
611	1	5	2026-02-19 21:24:57.651165	2028-08-10 17:29:57.651165	\N	\N	world.player_movement	{"x": 20, "y": 20, "moveCost": 99999, "totalMoveCost": 1300025}
612	1	5	2026-02-19 21:24:57.651165	2028-10-19 04:08:57.651165	\N	\N	world.player_movement	{"x": 21, "y": 21, "moveCost": 99999, "totalMoveCost": 1400024}
613	1	5	2026-02-19 21:24:57.651165	2028-12-27 13:47:57.651165	\N	\N	world.player_movement	{"x": 22, "y": 22, "moveCost": 99999, "totalMoveCost": 1500023}
614	1	5	2026-02-19 21:24:57.651165	2029-03-07 00:26:57.651165	\N	\N	world.player_movement	{"x": 23, "y": 23, "moveCost": 99999, "totalMoveCost": 1600022}
615	1	5	2026-02-19 21:24:57.651165	2029-05-15 12:05:57.651165	\N	\N	world.player_movement	{"x": 24, "y": 24, "moveCost": 99999, "totalMoveCost": 1700021}
616	1	5	2026-02-19 21:24:57.651165	2029-07-23 22:44:57.651165	\N	\N	world.player_movement	{"x": 25, "y": 25, "moveCost": 99999, "totalMoveCost": 1800020}
617	1	5	2026-02-19 21:24:57.651165	2029-10-01 09:23:57.651165	\N	\N	world.player_movement	{"x": 26, "y": 26, "moveCost": 99999, "totalMoveCost": 1900019}
618	1	5	2026-02-19 21:24:57.651165	2029-12-09 19:02:57.651165	\N	\N	world.player_movement	{"x": 27, "y": 27, "moveCost": 99999, "totalMoveCost": 2000018}
619	1	5	2026-02-19 21:24:57.651165	2030-02-17 05:41:57.651165	\N	\N	world.player_movement	{"x": 28, "y": 28, "moveCost": 99999, "totalMoveCost": 2100017}
620	1	5	2026-02-19 21:24:57.651165	2030-04-27 17:20:57.651165	\N	\N	world.player_movement	{"x": 29, "y": 29, "moveCost": 99999, "totalMoveCost": 2200016}
621	1	5	2026-02-19 21:24:57.651165	2030-07-06 03:59:57.651165	\N	\N	world.player_movement	{"x": 30, "y": 30, "moveCost": 99999, "totalMoveCost": 2300015}
622	1	5	2026-02-19 21:24:57.651165	2030-09-13 14:38:57.651165	\N	\N	world.player_movement	{"x": 31, "y": 31, "moveCost": 99999, "totalMoveCost": 2400014}
623	1	5	2026-02-19 21:24:57.651165	2030-11-22 00:17:57.651165	\N	\N	world.player_movement	{"x": 32, "y": 32, "moveCost": 99999, "totalMoveCost": 2500013}
624	1	5	2026-02-19 21:24:57.651165	2031-01-30 10:56:57.651165	\N	\N	world.player_movement	{"x": 33, "y": 33, "moveCost": 3, "totalMoveCost": 2600012}
625	1	5	2026-02-19 21:24:57.651165	2031-01-30 10:59:57.651165	\N	\N	world.player_movement	{"x": 33, "y": 34, "moveCost": 3, "totalMoveCost": 2600015}
626	1	5	2026-02-19 21:24:57.651165	2031-01-30 11:02:57.651165	\N	\N	world.player_movement	{"x": 33, "y": 35, "moveCost": 4, "totalMoveCost": 2600018}
627	1	5	2026-02-19 22:42:06.991186	2026-02-19 22:42:06.991186	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
628	1	5	2026-02-19 22:42:06.991186	2026-02-19 22:54:06.991186	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
629	1	5	2026-02-19 22:42:06.991186	2026-02-19 22:55:06.991186	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
630	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:01:06.991186	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
631	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:02:06.991186	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
632	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:03:06.991186	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
633	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:04:06.991186	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
634	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:05:06.991186	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
635	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:08:06.991186	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
636	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:11:06.991186	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 29}
637	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:12:06.991186	\N	\N	world.player_movement	{"x": 11, "y": 7, "moveCost": 1, "totalMoveCost": 30}
638	1	5	2026-02-19 22:42:06.991186	2026-02-19 23:13:06.991186	\N	\N	world.player_movement	{"x": 10, "y": 7, "moveCost": 3, "totalMoveCost": 31}
639	1	5	2026-02-19 22:42:39.929641	2026-02-19 22:42:39.929641	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
640	1	5	2026-02-19 22:42:39.929641	2026-02-19 22:54:39.929641	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
641	1	5	2026-02-19 22:42:39.929641	2026-02-19 22:55:39.929641	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
642	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:01:39.929641	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
643	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:02:39.929641	\N	\N	world.player_movement	{"x": 7, "y": 3, "moveCost": 1, "totalMoveCost": 20}
644	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:03:39.929641	\N	\N	world.player_movement	{"x": 8, "y": 2, "moveCost": 1, "totalMoveCost": 21}
645	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:04:39.929641	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 1, "totalMoveCost": 22}
646	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:05:39.929641	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 3, "totalMoveCost": 23}
647	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:08:39.929641	\N	\N	world.player_movement	{"x": 11, "y": 5, "moveCost": 3, "totalMoveCost": 26}
648	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:11:39.929641	\N	\N	world.player_movement	{"x": 12, "y": 4, "moveCost": 1, "totalMoveCost": 29}
649	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:12:39.929641	\N	\N	world.player_movement	{"x": 13, "y": 4, "moveCost": 1, "totalMoveCost": 30}
650	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:13:39.929641	\N	\N	world.player_movement	{"x": 14, "y": 4, "moveCost": 3, "totalMoveCost": 31}
651	1	5	2026-02-19 22:42:39.929641	2026-02-19 23:16:39.929641	\N	\N	world.player_movement	{"x": 15, "y": 4, "moveCost": 5, "totalMoveCost": 34}
703	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:53:33.709538	\N	\N	world.player_movement	{"x": 15, "y": 8, "moveCost": 3, "totalMoveCost": 37}
704	1	5	2026-02-19 23:16:33.709538	2026-02-19 23:56:33.709538	\N	\N	world.player_movement	{"x": 16, "y": 8, "moveCost": 1, "totalMoveCost": 40}
733	1	5	2026-02-19 23:36:00.704887	2026-02-19 23:36:00.704887	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
734	1	5	2026-02-19 23:36:00.704887	2026-02-19 23:48:00.704887	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
735	1	5	2026-02-19 23:36:00.704887	2026-02-19 23:49:00.704887	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
736	1	5	2026-02-19 23:36:00.704887	2026-02-19 23:55:00.704887	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
737	1	5	2026-02-19 23:36:00.704887	2026-02-19 23:56:00.704887	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
757	1	5	2026-02-19 23:52:15.22585	2026-02-19 23:52:15.22585	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
758	1	5	2026-02-19 23:52:15.22585	2026-02-20 00:04:15.22585	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
759	1	5	2026-02-19 23:52:15.22585	2026-02-20 00:05:15.22585	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
760	1	5	2026-02-19 23:52:15.22585	2026-02-20 00:11:15.22585	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
771	1	5	2026-02-20 00:12:24.144212	2026-02-20 00:12:24.144212	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
772	1	5	2026-02-20 00:12:24.144212	2026-02-20 00:24:24.144212	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
773	1	5	2026-02-20 00:12:24.144212	2026-02-20 00:25:24.144212	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
774	1	5	2026-02-20 00:12:24.144212	2026-02-20 00:31:24.144212	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
775	1	5	2026-02-20 00:12:24.144212	2026-02-20 00:32:24.144212	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
785	1	5	2026-02-20 00:19:28.425288	2026-02-20 00:19:28.425288	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
786	1	5	2026-02-20 00:19:28.425288	2026-02-20 00:31:28.425288	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
787	1	5	2026-02-20 00:19:28.425288	2026-02-20 00:32:28.425288	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
788	1	5	2026-02-20 00:19:28.425288	2026-02-20 00:38:28.425288	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
789	1	5	2026-02-20 00:19:28.425288	2026-02-20 00:39:28.425288	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
790	1	5	2026-02-20 00:19:28.425288	2026-02-20 00:40:28.425288	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
791	1	5	2026-02-20 00:19:28.425288	2026-02-20 00:40:28.425288	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 21}
792	1	5	2026-02-20 00:19:42.947957	2026-02-20 00:19:42.947957	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
793	1	5	2026-02-20 00:19:42.947957	2026-02-20 00:31:42.947957	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
794	1	5	2026-02-20 00:19:42.947957	2026-02-20 00:32:42.947957	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
795	1	5	2026-02-20 00:19:42.947957	2026-02-20 00:38:42.947957	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
796	1	5	2026-02-20 00:19:42.947957	2026-02-20 00:39:42.947957	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
797	1	5	2026-02-20 00:19:42.947957	2026-02-20 00:40:42.947957	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
798	1	5	2026-02-20 00:19:42.947957	2026-02-20 00:40:42.947957	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 21}
799	1	5	2026-02-20 00:19:47.926465	2026-02-20 00:19:47.926465	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
800	1	5	2026-02-20 00:19:47.926465	2026-02-20 00:31:47.926465	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
801	1	5	2026-02-20 00:19:47.926465	2026-02-20 00:32:47.926465	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
802	1	5	2026-02-20 00:19:47.926465	2026-02-20 00:38:47.926465	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
803	1	5	2026-02-20 00:19:47.926465	2026-02-20 00:39:47.926465	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
804	1	5	2026-02-20 00:19:47.926465	2026-02-20 00:40:47.926465	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
805	1	5	2026-02-20 00:19:47.926465	2026-02-20 00:40:47.926465	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 21}
806	1	5	2026-02-20 00:22:33.233124	2026-02-20 00:22:33.233124	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 12, "totalMoveCost": 0}
807	1	5	2026-02-20 00:22:33.233124	2026-02-20 00:34:33.233124	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 1, "totalMoveCost": 12}
808	1	5	2026-02-20 00:22:33.233124	2026-02-20 00:35:33.233124	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 6, "totalMoveCost": 13}
809	1	5	2026-02-20 00:22:33.233124	2026-02-20 00:41:33.233124	\N	\N	world.player_movement	{"x": 6, "y": 4, "moveCost": 1, "totalMoveCost": 19}
810	1	5	2026-02-20 00:22:33.233124	2026-02-20 00:42:33.233124	\N	\N	world.player_movement	{"x": 7, "y": 4, "moveCost": 1, "totalMoveCost": 20}
811	1	5	2026-02-20 00:22:33.233124	2026-02-20 00:43:33.233124	\N	\N	world.player_movement	{"x": 8, "y": 5, "moveCost": 0, "totalMoveCost": 21}
812	1	5	2026-02-20 00:22:33.233124	2026-02-20 00:43:33.233124	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 6, "totalMoveCost": 21}
813	1	1	2026-02-20 00:24:47.444381	2026-02-20 00:24:47.444381	\N	\N	world.player_movement	{"x": 3, "y": 3, "order": 1, "moveCost": 12, "totalMoveCost": 0}
819	1	1	2026-02-20 00:24:47.444381	2026-02-20 00:25:47.444	\N	\N	world.player_movement	{"x": 7, "y": 6, "order": 7, "moveCost": 6, "totalMoveCost": 21}
818	1	1	2026-02-20 00:24:47.444381	2026-02-20 00:25:47.444	\N	\N	world.player_movement	{"x": 8, "y": 5, "order": 6, "moveCost": 0, "totalMoveCost": 21}
817	1	1	2026-02-20 00:24:47.444381	2026-02-20 00:24:47.444	\N	\N	world.player_movement	{"x": 7, "y": 4, "order": 5, "moveCost": 1, "totalMoveCost": 20}
816	1	1	2026-02-20 00:24:47.444381	2026-02-20 00:23:47.444	\N	\N	world.player_movement	{"x": 6, "y": 4, "order": 4, "moveCost": 1, "totalMoveCost": 19}
815	1	1	2026-02-20 00:24:47.444381	2026-02-20 00:27:47.444	\N	\N	world.player_movement	{"x": 5, "y": 3, "order": 3, "moveCost": 6, "totalMoveCost": 13}
814	1	1	2026-02-20 00:24:47.444381	2026-02-20 00:26:47.444	\N	\N	world.player_movement	{"x": 4, "y": 2, "order": 2, "moveCost": 1, "totalMoveCost": 12}
\.


--
-- TOC entry 5367 (class 0 OID 22599)
-- Dependencies: 246
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
-- TOC entry 5416 (class 0 OID 22798)
-- Dependencies: 295
-- Data for Name: map_regions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_regions (id, name, region_type_id, image_outline, image_fill) FROM stdin;
1	region	1	\N	\N
2	region	1	\N	\N
3	region	1	\N	\N
4	region	1	\N	\N
5	region	1	\N	\N
6	region	1	\N	\N
7	region	1	\N	\N
8	region	1	\N	\N
9	region	1	\N	\N
10	region	1	\N	\N
11	region	1	\N	\N
12	region	1	\N	\N
13	region	1	\N	\N
14	region	1	\N	\N
15	region	1	\N	\N
16	region	1	\N	\N
17	region	1	\N	\N
18	region	1	\N	\N
19	region	1	\N	\N
20	region	1	\N	\N
21	region	1	\N	\N
22	region	1	\N	\N
23	region	1	\N	\N
24	region	1	\N	\N
25	region	1	\N	\N
26	region	1	\N	\N
27	region	1	\N	\N
28	region	1	\N	\N
29	region	1	\N	\N
30	region	1	\N	\N
31	region	1	\N	\N
32	region	1	\N	\N
33	region	1	\N	\N
34	region	1	\N	\N
35	region	1	\N	\N
36	region	1	\N	\N
37	region	1	\N	\N
38	region	1	\N	\N
39	region	1	\N	\N
40	region	1	\N	\N
41	region	1	\N	\N
42	region	1	\N	\N
43	region	1	\N	\N
44	region	1	\N	\N
45	region	1	\N	\N
46	region	1	\N	\N
47	region	1	\N	\N
48	region	1	\N	\N
49	region	1	\N	\N
50	region	1	\N	\N
51	region	1	\N	\N
52	region	1	\N	\N
53	region	1	\N	\N
54	region	1	\N	\N
55	region	1	\N	\N
56	region	1	\N	\N
57	region	1	\N	\N
58	region	1	\N	\N
59	region	1	\N	\N
60	region	1	\N	\N
61	region	1	\N	\N
62	region	1	\N	\N
63	region	1	\N	\N
64	region	1	\N	\N
65	region	1	\N	\N
66	region	1	\N	\N
67	region	1	\N	\N
68	region	1	\N	\N
69	region	1	\N	\N
70	region	1	\N	\N
71	region	1	\N	\N
72	region	1	\N	\N
73	region	1	\N	\N
74	region	1	\N	\N
75	region	1	\N	\N
76	region	1	\N	\N
77	region	1	\N	\N
78	region	1	\N	\N
79	region	1	\N	\N
80	region	1	\N	\N
81	region	1	\N	\N
82	region	1	\N	\N
83	region	1	\N	\N
84	region	1	\N	\N
85	region	1	\N	\N
86	region	1	\N	\N
87	region	1	\N	\N
88	region	1	\N	\N
89	region	1	\N	\N
90	region	1	\N	\N
91	region	1	\N	\N
92	region	1	\N	\N
93	region	1	\N	\N
94	region	1	\N	\N
95	region	1	\N	\N
96	region	1	\N	\N
97	region	1	\N	\N
98	region	1	\N	\N
99	region	1	\N	\N
100	region	1	\N	\N
101	region	1	\N	\N
102	region	1	\N	\N
103	region	1	\N	\N
104	region	1	\N	\N
105	region	1	\N	\N
106	region	1	\N	\N
107	region	1	\N	\N
108	region	1	\N	\N
109	region	1	\N	\N
110	region	1	\N	\N
111	region	1	\N	\N
112	region	1	\N	\N
113	region	1	\N	\N
114	region	1	\N	\N
115	region	1	\N	\N
116	region	1	\N	\N
117	region	1	\N	\N
118	region	1	\N	\N
119	region	1	\N	\N
120	region	1	\N	\N
121	region	1	\N	\N
122	region	1	\N	\N
123	region	1	\N	\N
124	region	1	\N	\N
125	region	1	\N	\N
126	region	1	\N	\N
127	region	1	\N	\N
128	region	1	\N	\N
129	region	1	\N	\N
130	region	1	\N	\N
131	region	1	\N	\N
132	region	1	\N	\N
133	region	1	\N	\N
134	region	1	\N	\N
135	region	1	\N	\N
136	region	1	\N	\N
137	region	1	\N	\N
138	region	1	\N	\N
139	region	1	\N	\N
140	region	1	\N	\N
141	region	1	\N	\N
142	region	1	\N	\N
143	region	1	\N	\N
144	region	1	\N	\N
145	region	1	\N	\N
146	region	1	\N	\N
147	region	1	\N	\N
148	region	1	\N	\N
149	region	1	\N	\N
150	region	1	\N	\N
151	region	1	\N	\N
152	region	1	\N	\N
153	region	1	\N	\N
154	region	1	\N	\N
155	region	1	\N	\N
156	region	1	\N	\N
157	region	1	\N	\N
158	region	1	\N	\N
159	region	1	\N	\N
160	region	1	\N	\N
161	region	1	\N	\N
162	region	1	\N	\N
163	region	1	\N	\N
164	region	1	\N	\N
165	region	1	\N	\N
166	region	1	\N	\N
167	region	1	\N	\N
168	region	1	\N	\N
169	region	1	\N	\N
170	region	1	\N	\N
171	region	1	\N	\N
172	region	1	\N	\N
173	region	1	\N	\N
174	region	1	\N	\N
175	region	1	\N	\N
176	region	1	\N	\N
177	region	1	\N	\N
178	region	1	\N	\N
179	region	1	\N	\N
180	region	1	\N	\N
181	region	1	\N	\N
182	region	1	\N	\N
183	region	1	\N	\N
184	region	1	\N	\N
185	region	1	\N	\N
186	region	1	\N	\N
187	region	1	\N	\N
188	region	1	\N	\N
189	region	1	\N	\N
190	region	1	\N	\N
191	region	1	\N	\N
192	region	1	\N	\N
193	region	1	\N	\N
194	region	1	\N	\N
195	region	1	\N	\N
196	region	1	\N	\N
197	region	1	\N	\N
198	region	1	\N	\N
199	region	1	\N	\N
200	region	1	\N	\N
201	region	1	\N	\N
202	region	1	\N	\N
203	region	1	\N	\N
204	region	1	\N	\N
205	region	1	\N	\N
206	region	1	\N	\N
207	region	1	\N	\N
208	region	1	\N	\N
209	region	1	\N	\N
210	region	1	\N	\N
211	region	1	\N	\N
212	region	1	\N	\N
213	region	1	\N	\N
214	region	1	\N	\N
215	region	1	\N	\N
216	region	1	\N	\N
217	region	1	\N	\N
218	region	1	\N	\N
219	region	1	\N	\N
220	region	1	\N	\N
221	region	1	\N	\N
222	region	1	\N	\N
223	region	1	\N	\N
224	region	1	\N	\N
225	region	1	\N	\N
226	region	1	\N	\N
227	region	1	\N	\N
228	region	1	\N	\N
229	region	1	\N	\N
230	region	1	\N	\N
231	region	1	\N	\N
232	region	1	\N	\N
233	region	1	\N	\N
234	region	1	\N	\N
235	region	1	\N	\N
236	region	1	\N	\N
237	region	1	\N	\N
238	region	1	\N	\N
239	region	1	\N	\N
240	region	1	\N	\N
241	region	1	\N	\N
242	region	1	\N	\N
243	region	1	\N	\N
244	region	1	\N	\N
245	region	1	\N	\N
246	region	1	\N	\N
247	region	1	\N	\N
248	region	1	\N	\N
249	region	1	\N	\N
250	region	1	\N	\N
251	region	1	\N	\N
252	region	1	\N	\N
253	region	1	\N	\N
254	region	1	\N	\N
255	region	1	\N	\N
256	region	1	\N	\N
257	region	1	\N	\N
258	region	1	\N	\N
259	region	1	\N	\N
260	region	1	\N	\N
261	region	1	\N	\N
262	region	1	\N	\N
263	region	1	\N	\N
264	region	1	\N	\N
265	region	1	\N	\N
266	region	1	\N	\N
267	region	1	\N	\N
268	region	1	\N	\N
269	region	1	\N	\N
270	region	1	\N	\N
271	region	1	\N	\N
272	region	1	\N	\N
273	region	1	\N	\N
274	region	1	\N	\N
275	region	1	\N	\N
276	region	1	\N	\N
277	region	1	\N	\N
278	region	1	\N	\N
279	region	1	\N	\N
280	region	1	\N	\N
281	region	1	\N	\N
282	region	1	\N	\N
283	region	1	\N	\N
284	region	1	\N	\N
285	region	1	\N	\N
286	region	1	\N	\N
287	region	1	\N	\N
288	region	1	\N	\N
289	region	1	\N	\N
290	region	1	\N	\N
291	region	1	\N	\N
292	region	1	\N	\N
293	region	1	\N	\N
294	region	1	\N	\N
295	region	1	\N	\N
296	region	1	\N	\N
297	region	1	\N	\N
298	region	1	\N	\N
299	region	1	\N	\N
300	region	1	\N	\N
301	region	1	\N	\N
302	region	1	\N	\N
303	region	1	\N	\N
304	region	1	\N	\N
305	region	1	\N	\N
306	region	1	\N	\N
307	region	1	\N	\N
308	region	1	\N	\N
309	region	1	\N	\N
310	region	1	\N	\N
311	region	1	\N	\N
312	region	1	\N	\N
313	region	1	\N	\N
314	region	1	\N	\N
315	region	1	\N	\N
316	region	1	\N	\N
317	region	1	\N	\N
318	region	1	\N	\N
319	region	1	\N	\N
320	region	1	\N	\N
321	region	1	\N	\N
322	region	1	\N	\N
323	region	1	\N	\N
324	region	1	\N	\N
325	region	1	\N	\N
326	region	1	\N	\N
327	region	1	\N	\N
328	region	1	\N	\N
329	region	1	\N	\N
330	region	1	\N	\N
331	region	1	\N	\N
332	region	1	\N	\N
333	region	1	\N	\N
334	region	1	\N	\N
335	region	1	\N	\N
336	region	1	\N	\N
337	region	1	\N	\N
338	region	1	\N	\N
339	region	1	\N	\N
340	region	1	\N	\N
341	region	1	\N	\N
342	region	1	\N	\N
343	region	1	\N	\N
344	region	1	\N	\N
345	region	1	\N	\N
346	region	1	\N	\N
347	region	1	\N	\N
348	region	1	\N	\N
349	region	1	\N	\N
350	region	1	\N	\N
351	region	1	\N	\N
352	region	1	\N	\N
353	region	1	\N	\N
354	region	1	\N	\N
355	region	1	\N	\N
356	region	1	\N	\N
357	region	1	\N	\N
358	region	1	\N	\N
359	region	1	\N	\N
360	region	1	\N	\N
361	region	1	\N	\N
362	region	1	\N	\N
363	region	1	\N	\N
364	region	1	\N	\N
365	region	1	\N	\N
366	region	1	\N	\N
367	region	1	\N	\N
368	region	1	\N	\N
369	region	1	\N	\N
370	region	1	\N	\N
371	region	1	\N	\N
372	region	1	\N	\N
373	region	1	\N	\N
374	region	1	\N	\N
375	region	1	\N	\N
376	region	1	\N	\N
377	region	1	\N	\N
378	region	1	\N	\N
379	region	1	\N	\N
380	region	1	\N	\N
381	region	1	\N	\N
382	region	1	\N	\N
383	region	1	\N	\N
384	region	1	\N	\N
385	region	1	\N	\N
386	region	1	\N	\N
387	region	1	\N	\N
388	region	1	\N	\N
389	region	1	\N	\N
390	region	1	\N	\N
391	region	1	\N	\N
392	region	1	\N	\N
393	region	1	\N	\N
394	region	1	\N	\N
395	region	1	\N	\N
396	region	1	\N	\N
397	region	1	\N	\N
398	region	1	\N	\N
399	region	1	\N	\N
400	region	1	\N	\N
401	region	1	\N	\N
402	region	1	\N	\N
403	region	1	\N	\N
404	region	1	\N	\N
405	region	1	\N	\N
406	region	1	\N	\N
407	region	1	\N	\N
408	region	1	\N	\N
409	region	1	\N	\N
410	region	1	\N	\N
411	region	1	\N	\N
412	region	1	\N	\N
413	region	1	\N	\N
414	region	1	\N	\N
415	region	1	\N	\N
416	region	1	\N	\N
417	region	1	\N	\N
418	region	1	\N	\N
419	region	1	\N	\N
420	region	1	\N	\N
421	region	1	\N	\N
422	region	1	\N	\N
423	region	1	\N	\N
424	region	1	\N	\N
425	region	1	\N	\N
426	region	1	\N	\N
427	region	1	\N	\N
428	region	1	\N	\N
429	region	1	\N	\N
430	region	1	\N	\N
431	region	1	\N	\N
432	region	1	\N	\N
433	region	1	\N	\N
434	region	1	\N	\N
435	region	1	\N	\N
436	region	1	\N	\N
437	region	1	\N	\N
438	region	1	\N	\N
439	region	1	\N	\N
440	region	1	\N	\N
441	region	1	\N	\N
442	region	1	\N	\N
443	region	1	\N	\N
444	region	1	\N	\N
445	region	1	\N	\N
446	region	1	\N	\N
447	region	1	\N	\N
448	region	1	\N	\N
449	region	1	\N	\N
450	region	1	\N	\N
451	region	1	\N	\N
452	region	1	\N	\N
453	region	1	\N	\N
454	region	1	\N	\N
455	region	1	\N	\N
456	region	1	\N	\N
457	region	1	\N	\N
458	region	1	\N	\N
459	region	1	\N	\N
460	region	1	\N	\N
461	region	1	\N	\N
462	region	1	\N	\N
463	region	1	\N	\N
464	region	1	\N	\N
465	region	1	\N	\N
466	region	1	\N	\N
467	region	1	\N	\N
468	region	1	\N	\N
469	region	1	\N	\N
470	region	1	\N	\N
471	region	1	\N	\N
472	region	1	\N	\N
473	region	1	\N	\N
474	region	1	\N	\N
475	region	1	\N	\N
476	region	1	\N	\N
477	region	1	\N	\N
478	region	1	\N	\N
479	region	1	\N	\N
480	region	1	\N	\N
481	region	1	\N	\N
482	region	1	\N	\N
483	region	1	\N	\N
484	region	1	\N	\N
485	region	1	\N	\N
486	region	1	\N	\N
487	region	1	\N	\N
488	region	1	\N	\N
489	region	1	\N	\N
490	region	1	\N	\N
491	region	1	\N	\N
492	region	1	\N	\N
493	region	1	\N	\N
494	region	1	\N	\N
495	region	1	\N	\N
496	region	1	\N	\N
497	region	1	\N	\N
498	region	1	\N	\N
499	region	1	\N	\N
500	region	1	\N	\N
501	region	1	\N	\N
502	region	1	\N	\N
503	region	1	\N	\N
504	region	1	\N	\N
505	region	1	\N	\N
506	region	1	\N	\N
507	region	1	\N	\N
508	region	1	\N	\N
509	region	1	\N	\N
510	region	1	\N	\N
511	region	1	\N	\N
512	region	1	\N	\N
513	region	1	\N	\N
514	region	1	\N	\N
515	region	1	\N	\N
516	region	1	\N	\N
517	region	1	\N	\N
518	region	1	\N	\N
519	region	1	\N	\N
520	region	1	\N	\N
521	region	1	\N	\N
522	region	1	\N	\N
523	region	1	\N	\N
524	region	1	\N	\N
525	region	1	\N	\N
526	region	1	\N	\N
527	region	1	\N	\N
528	region	1	\N	\N
529	region	1	\N	\N
530	region	1	\N	\N
531	region	1	\N	\N
532	region	1	\N	\N
533	region	1	\N	\N
534	region	1	\N	\N
535	region	1	\N	\N
536	region	1	\N	\N
537	region	1	\N	\N
538	region	1	\N	\N
539	region	1	\N	\N
540	region	1	\N	\N
541	region	1	\N	\N
542	region	1	\N	\N
543	region	1	\N	\N
544	region	1	\N	\N
545	region	1	\N	\N
546	region	1	\N	\N
547	region	1	\N	\N
548	region	1	\N	\N
549	region	1	\N	\N
550	region	1	\N	\N
551	region	1	\N	\N
552	region	1	\N	\N
553	region	1	\N	\N
554	region	1	\N	\N
555	region	1	\N	\N
556	region	1	\N	\N
557	region	1	\N	\N
558	region	1	\N	\N
559	region	1	\N	\N
560	region	1	\N	\N
561	region	1	\N	\N
562	region	1	\N	\N
563	region	1	\N	\N
564	region	1	\N	\N
565	region	1	\N	\N
566	region	1	\N	\N
567	region	1	\N	\N
568	region	1	\N	\N
569	region	1	\N	\N
570	region	1	\N	\N
571	region	1	\N	\N
572	region	1	\N	\N
573	region	1	\N	\N
574	region	1	\N	\N
575	region	1	\N	\N
576	region	1	\N	\N
577	region	1	\N	\N
578	region	1	\N	\N
579	region	1	\N	\N
580	region	1	\N	\N
581	region	1	\N	\N
582	region	1	\N	\N
583	region	1	\N	\N
584	region	1	\N	\N
585	region	1	\N	\N
586	region	1	\N	\N
587	region	1	\N	\N
588	region	1	\N	\N
589	region	1	\N	\N
590	region	1	\N	\N
591	region	1	\N	\N
592	region	1	\N	\N
593	region	1	\N	\N
594	region	1	\N	\N
595	region	1	\N	\N
596	region	1	\N	\N
597	region	1	\N	\N
598	region	1	\N	\N
599	region	1	\N	\N
600	region	1	\N	\N
601	region	1	\N	\N
602	region	1	\N	\N
603	region	1	\N	\N
604	region	1	\N	\N
605	region	1	\N	\N
606	region	1	\N	\N
607	region	1	\N	\N
608	region	1	\N	\N
609	region	1	\N	\N
610	region	1	\N	\N
611	region	1	\N	\N
612	region	1	\N	\N
613	region	1	\N	\N
614	region	1	\N	\N
615	region	1	\N	\N
616	region	1	\N	\N
617	region	1	\N	\N
618	region	1	\N	\N
619	region	1	\N	\N
\.


--
-- TOC entry 5368 (class 0 OID 22607)
-- Dependencies: 247
-- Data for Name: map_tiles; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles (map_id, x, y, terrain_type_id, landscape_type_id) FROM stdin;
1	1	1	5	\N
1	2	1	5	8
1	3	1	5	8
1	4	1	3	2
1	5	1	3	2
1	6	1	3	2
1	7	1	3	3
1	8	1	3	2
1	9	1	3	\N
1	10	1	3	2
1	11	1	3	3
1	12	1	3	2
1	13	1	3	\N
1	14	1	3	2
1	15	1	3	\N
1	16	1	3	2
1	17	1	3	3
1	18	1	3	3
1	19	1	3	3
1	20	1	3	2
1	21	1	3	2
1	22	1	3	\N
1	23	1	3	2
1	24	1	3	3
1	25	1	3	\N
1	26	1	3	\N
1	27	1	3	2
1	28	1	3	3
1	29	1	3	3
1	30	1	3	\N
1	31	1	3	\N
1	32	1	3	3
1	33	1	3	\N
1	34	1	9	\N
1	35	1	9	\N
1	36	1	9	\N
1	37	1	5	8
1	38	1	5	6
1	39	1	5	6
1	40	1	5	6
1	41	1	6	\N
1	42	1	6	\N
1	43	1	6	\N
1	44	1	6	\N
1	45	1	6	\N
1	46	1	1	1
1	47	1	7	\N
1	48	1	7	\N
1	49	1	7	\N
1	50	1	7	\N
1	51	1	7	\N
1	52	1	7	\N
1	53	1	7	\N
1	54	1	7	\N
1	55	1	7	\N
1	56	1	7	\N
1	57	1	7	\N
1	58	1	7	\N
1	59	1	7	\N
1	60	1	7	\N
1	1	2	5	8
1	2	2	5	\N
1	3	2	5	8
1	4	2	3	\N
1	5	2	3	3
1	6	2	6	\N
1	7	2	3	2
1	8	2	3	\N
1	9	2	3	\N
1	10	2	3	2
1	11	2	3	2
1	12	2	9	\N
1	13	2	3	3
1	14	2	1	9
1	15	2	3	\N
1	16	2	3	2
1	17	2	2	\N
1	18	2	3	\N
1	19	2	3	\N
1	20	2	3	3
1	21	2	3	3
1	22	2	3	2
1	23	2	3	3
1	24	2	3	2
1	25	2	3	2
1	26	2	2	\N
1	27	2	3	\N
1	28	2	3	2
1	29	2	3	2
1	30	2	3	3
1	31	2	3	\N
1	32	2	3	3
1	33	2	3	2
1	34	2	3	2
1	35	2	9	\N
1	36	2	2	1
1	37	2	5	6
1	38	2	5	8
1	39	2	5	6
1	40	2	5	\N
1	41	2	5	8
1	42	2	6	\N
1	43	2	6	\N
1	44	2	1	\N
1	45	2	9	\N
1	46	2	1	\N
1	47	2	1	1
1	48	2	7	\N
1	49	2	7	\N
1	50	2	6	\N
1	51	2	7	\N
1	52	2	4	7
1	53	2	5	6
1	54	2	9	\N
1	55	2	7	\N
1	56	2	3	\N
1	57	2	1	9
1	58	2	7	\N
1	59	2	7	\N
1	60	2	7	\N
1	1	3	5	8
1	2	3	5	8
1	3	3	5	8
1	4	3	3	2
1	5	3	3	3
1	6	3	3	3
1	7	3	3	\N
1	8	3	3	3
1	9	3	3	\N
1	10	3	3	\N
1	11	3	3	3
1	12	3	9	\N
1	13	3	1	1
1	14	3	1	9
1	15	3	7	\N
1	16	3	3	\N
1	17	3	7	\N
1	18	3	1	\N
1	19	3	3	3
1	20	3	3	2
1	21	3	3	2
1	22	3	2	1
1	23	3	3	3
1	24	3	3	2
1	25	3	7	\N
1	26	3	3	2
1	27	3	3	2
1	28	3	4	7
1	29	3	3	\N
1	30	3	6	\N
1	31	3	2	1
1	32	3	6	\N
1	33	3	3	2
1	34	3	3	3
1	35	3	9	\N
1	36	3	7	\N
1	37	3	5	8
1	38	3	5	8
1	39	3	5	8
1	40	3	5	8
1	41	3	2	1
1	42	3	1	1
1	43	3	1	1
1	44	3	1	9
1	45	3	1	1
1	46	3	5	\N
1	47	3	1	9
1	48	3	1	\N
1	49	3	7	\N
1	50	3	7	\N
1	51	3	7	\N
1	52	3	7	\N
1	53	3	1	1
1	54	3	9	\N
1	55	3	4	7
1	56	3	1	1
1	57	3	9	\N
1	58	3	9	\N
1	59	3	9	\N
1	60	3	9	\N
1	1	4	5	6
1	2	4	5	8
1	3	4	7	\N
1	4	4	1	1
1	5	4	3	3
1	6	4	3	\N
1	7	4	3	\N
1	8	4	3	2
1	9	4	3	3
1	10	4	1	9
1	11	4	3	2
1	12	4	3	\N
1	13	4	2	\N
1	14	4	1	1
1	15	4	6	\N
1	16	4	7	\N
1	17	4	7	\N
1	18	4	7	\N
1	19	4	3	\N
1	20	4	3	\N
1	21	4	3	2
1	22	4	3	\N
1	23	4	2	\N
1	24	4	2	1
1	25	4	3	2
1	26	4	3	\N
1	27	4	3	2
1	28	4	3	2
1	29	4	3	2
1	30	4	3	2
1	31	4	5	6
1	32	4	5	8
1	33	4	7	\N
1	34	4	3	\N
1	35	4	9	\N
1	36	4	4	7
1	37	4	5	\N
1	38	4	5	6
1	39	4	9	\N
1	40	4	5	6
1	41	4	5	6
1	42	4	1	\N
1	43	4	1	1
1	44	4	1	9
1	45	4	1	\N
1	46	4	9	\N
1	47	4	1	9
1	48	4	1	1
1	49	4	1	\N
1	50	4	7	\N
1	51	4	5	6
1	52	4	7	\N
1	53	4	7	\N
1	54	4	1	9
1	55	4	1	9
1	56	4	1	9
1	57	4	9	\N
1	58	4	4	7
1	59	4	4	\N
1	60	4	4	7
1	1	5	5	8
1	2	5	5	6
1	3	5	5	8
1	4	5	9	\N
1	5	5	9	\N
1	6	5	9	\N
1	7	5	9	\N
1	8	5	9	\N
1	9	5	3	2
1	10	5	1	9
1	11	5	1	1
1	12	5	3	2
1	13	5	1	1
1	14	5	1	9
1	15	5	1	1
1	16	5	7	\N
1	17	5	7	\N
1	18	5	7	\N
1	19	5	3	3
1	20	5	3	\N
1	21	5	3	\N
1	22	5	3	\N
1	23	5	7	\N
1	24	5	2	1
1	25	5	2	1
1	26	5	3	\N
1	27	5	1	\N
1	28	5	3	\N
1	29	5	6	\N
1	30	5	3	2
1	31	5	3	3
1	32	5	5	\N
1	33	5	3	3
1	34	5	3	2
1	35	5	9	\N
1	36	5	4	\N
1	37	5	4	7
1	38	5	5	8
1	39	5	9	\N
1	40	5	5	6
1	41	5	5	8
1	42	5	1	1
1	43	5	1	1
1	44	5	1	9
1	45	5	1	9
1	46	5	9	\N
1	47	5	1	1
1	48	5	1	\N
1	49	5	1	9
1	50	5	1	\N
1	51	5	7	\N
1	52	5	7	\N
1	53	5	7	\N
1	54	5	1	\N
1	55	5	9	\N
1	56	5	9	\N
1	57	5	1	1
1	58	5	3	\N
1	59	5	6	\N
1	60	5	4	7
1	1	6	5	6
1	2	6	5	\N
1	3	6	4	\N
1	4	6	9	\N
1	5	6	2	1
1	6	6	9	\N
1	7	6	4	\N
1	8	6	7	\N
1	9	6	1	9
1	10	6	6	\N
1	11	6	1	1
1	12	6	1	\N
1	13	6	1	\N
1	14	6	1	1
1	15	6	1	9
1	16	6	1	\N
1	17	6	7	\N
1	18	6	7	\N
1	19	6	5	6
1	20	6	3	2
1	21	6	3	3
1	22	6	3	2
1	23	6	7	\N
1	24	6	2	1
1	25	6	2	1
1	26	6	6	\N
1	27	6	9	\N
1	28	6	9	\N
1	29	6	2	1
1	30	6	3	2
1	31	6	3	\N
1	32	6	3	\N
1	33	6	3	3
1	34	6	3	3
1	35	6	3	2
1	36	6	4	\N
1	37	6	4	7
1	38	6	4	7
1	39	6	5	\N
1	40	6	5	\N
1	41	6	5	8
1	42	6	1	9
1	43	6	1	9
1	44	6	1	9
1	45	6	1	\N
1	46	6	1	9
1	47	6	1	\N
1	48	6	7	\N
1	49	6	1	\N
1	50	6	1	1
1	51	6	1	\N
1	52	6	2	\N
1	53	6	1	1
1	54	6	1	9
1	55	6	9	\N
1	56	6	1	1
1	57	6	1	\N
1	58	6	1	9
1	59	6	1	9
1	60	6	2	1
1	1	7	5	6
1	2	7	5	8
1	3	7	2	1
1	4	7	3	3
1	5	7	5	6
1	6	7	9	\N
1	7	7	4	7
1	8	7	9	\N
1	9	7	9	\N
1	10	7	1	9
1	11	7	1	\N
1	12	7	5	6
1	13	7	1	\N
1	14	7	1	1
1	15	7	1	\N
1	16	7	1	9
1	17	7	1	\N
1	18	7	7	\N
1	19	7	7	\N
1	20	7	3	3
1	21	7	3	2
1	22	7	4	\N
1	23	7	2	\N
1	24	7	2	1
1	25	7	4	7
1	26	7	2	\N
1	27	7	9	\N
1	28	7	7	\N
1	29	7	2	1
1	30	7	2	\N
1	31	7	7	\N
1	32	7	3	3
1	33	7	4	7
1	34	7	6	\N
1	35	7	3	3
1	36	7	3	2
1	37	7	4	7
1	38	7	3	2
1	39	7	5	6
1	40	7	5	\N
1	41	7	5	\N
1	42	7	1	\N
1	43	7	6	\N
1	44	7	1	9
1	45	7	1	1
1	46	7	5	8
1	47	7	1	1
1	48	7	1	9
1	49	7	1	\N
1	50	7	1	1
1	51	7	1	\N
1	52	7	1	\N
1	53	7	1	\N
1	54	7	1	\N
1	55	7	9	\N
1	56	7	1	1
1	57	7	1	1
1	58	7	1	1
1	59	7	6	\N
1	60	7	1	9
1	1	8	5	8
1	2	8	5	\N
1	3	8	5	8
1	4	8	5	6
1	5	8	5	\N
1	6	8	5	8
1	7	8	4	\N
1	8	8	9	\N
1	9	8	1	\N
1	10	8	1	1
1	11	8	1	1
1	12	8	1	1
1	13	8	1	\N
1	14	8	1	1
1	15	8	1	1
1	16	8	1	\N
1	17	8	1	9
1	18	8	1	1
1	19	8	7	\N
1	20	8	3	3
1	21	8	3	\N
1	22	8	6	\N
1	23	8	2	1
1	24	8	2	1
1	25	8	9	\N
1	26	8	2	\N
1	27	8	9	\N
1	28	8	2	\N
1	29	8	5	\N
1	30	8	2	1
1	31	8	3	\N
1	32	8	6	\N
1	33	8	6	\N
1	34	8	6	\N
1	35	8	5	6
1	36	8	3	\N
1	37	8	9	\N
1	38	8	3	2
1	39	8	1	9
1	40	8	9	\N
1	41	8	5	\N
1	42	8	5	\N
1	43	8	1	9
1	44	8	1	\N
1	45	8	1	\N
1	46	8	1	1
1	47	8	1	9
1	48	8	1	\N
1	49	8	1	9
1	50	8	1	\N
1	51	8	1	1
1	52	8	9	\N
1	53	8	9	\N
1	54	8	9	\N
1	55	8	9	\N
1	56	8	9	\N
1	57	8	1	\N
1	58	8	1	\N
1	59	8	1	9
1	60	8	1	9
1	1	9	7	\N
1	2	9	5	\N
1	3	9	5	8
1	4	9	5	8
1	5	9	5	8
1	6	9	5	8
1	7	9	1	1
1	8	9	9	\N
1	9	9	9	\N
1	10	9	9	\N
1	11	9	1	9
1	12	9	1	9
1	13	9	1	1
1	14	9	1	1
1	15	9	1	1
1	16	9	1	9
1	17	9	1	1
1	18	9	1	9
1	19	9	1	9
1	20	9	3	\N
1	21	9	3	2
1	22	9	3	2
1	23	9	2	1
1	24	9	2	\N
1	25	9	2	\N
1	26	9	2	1
1	27	9	2	1
1	28	9	2	\N
1	29	9	2	\N
1	30	9	2	\N
1	31	9	2	\N
1	32	9	6	\N
1	33	9	6	\N
1	34	9	6	\N
1	35	9	6	\N
1	36	9	3	3
1	37	9	9	\N
1	38	9	1	9
1	39	9	1	1
1	40	9	9	\N
1	41	9	9	\N
1	42	9	5	\N
1	43	9	3	3
1	44	9	1	9
1	45	9	1	1
1	46	9	1	\N
1	47	9	5	6
1	48	9	1	\N
1	49	9	3	\N
1	50	9	1	9
1	51	9	1	1
1	52	9	1	9
1	53	9	4	\N
1	54	9	4	7
1	55	9	9	\N
1	56	9	1	9
1	57	9	1	1
1	58	9	1	9
1	59	9	9	\N
1	60	9	1	1
1	1	10	5	\N
1	2	10	5	\N
1	3	10	5	\N
1	4	10	5	8
1	5	10	5	8
1	6	10	7	\N
1	7	10	1	\N
1	8	10	9	\N
1	9	10	1	1
1	10	10	9	\N
1	11	10	1	\N
1	12	10	1	\N
1	13	10	7	\N
1	14	10	1	1
1	15	10	1	\N
1	16	10	9	\N
1	17	10	1	9
1	18	10	1	\N
1	19	10	1	9
1	20	10	7	\N
1	21	10	3	\N
1	22	10	3	3
1	23	10	4	7
1	24	10	2	1
1	25	10	2	\N
1	26	10	9	\N
1	27	10	2	\N
1	28	10	4	7
1	29	10	2	\N
1	30	10	2	1
1	31	10	2	1
1	32	10	2	\N
1	33	10	6	\N
1	34	10	6	\N
1	35	10	6	\N
1	36	10	6	\N
1	37	10	9	\N
1	38	10	1	\N
1	39	10	1	1
1	40	10	9	\N
1	41	10	5	8
1	42	10	5	6
1	43	10	5	\N
1	44	10	1	9
1	45	10	7	\N
1	46	10	4	7
1	47	10	6	\N
1	48	10	1	9
1	49	10	1	9
1	50	10	1	9
1	51	10	3	\N
1	52	10	1	\N
1	53	10	5	8
1	54	10	4	7
1	55	10	9	\N
1	56	10	1	\N
1	57	10	6	\N
1	58	10	1	\N
1	59	10	9	\N
1	60	10	1	1
1	1	11	1	1
1	2	11	5	6
1	3	11	5	\N
1	4	11	5	6
1	5	11	5	8
1	6	11	5	\N
1	7	11	1	1
1	8	11	1	\N
1	9	11	1	1
1	10	11	9	\N
1	11	11	9	\N
1	12	11	9	\N
1	13	11	9	\N
1	14	11	9	\N
1	15	11	9	\N
1	16	11	1	\N
1	17	11	1	9
1	18	11	1	9
1	19	11	1	1
1	20	11	1	9
1	21	11	3	\N
1	22	11	3	2
1	23	11	4	7
1	24	11	2	1
1	25	11	2	1
1	26	11	2	1
1	27	11	2	1
1	28	11	2	1
1	29	11	2	1
1	30	11	2	1
1	31	11	2	\N
1	32	11	2	1
1	33	11	2	1
1	34	11	6	\N
1	35	11	6	\N
1	36	11	5	\N
1	37	11	9	\N
1	38	11	1	\N
1	39	11	1	1
1	40	11	1	9
1	41	11	5	\N
1	42	11	5	\N
1	43	11	5	\N
1	44	11	5	\N
1	45	11	3	\N
1	46	11	3	\N
1	47	11	1	1
1	48	11	1	\N
1	49	11	1	9
1	50	11	1	1
1	51	11	1	9
1	52	11	1	\N
1	53	11	1	9
1	54	11	7	\N
1	55	11	9	\N
1	56	11	9	\N
1	57	11	1	9
1	58	11	1	\N
1	59	11	1	9
1	60	11	1	\N
1	1	12	1	9
1	2	12	1	1
1	3	12	5	6
1	4	12	5	\N
1	5	12	7	\N
1	6	12	5	\N
1	7	12	7	\N
1	8	12	9	\N
1	9	12	9	\N
1	10	12	1	1
1	11	12	9	\N
1	12	12	6	\N
1	13	12	9	\N
1	14	12	3	2
1	15	12	9	\N
1	16	12	1	\N
1	17	12	1	1
1	18	12	3	2
1	19	12	4	\N
1	20	12	1	\N
1	21	12	1	\N
1	22	12	3	3
1	23	12	3	3
1	24	12	2	\N
1	25	12	2	1
1	26	12	2	\N
1	27	12	9	\N
1	28	12	9	\N
1	29	12	2	1
1	30	12	3	2
1	31	12	2	1
1	32	12	2	1
1	33	12	2	\N
1	34	12	2	\N
1	35	12	6	\N
1	36	12	6	\N
1	37	12	1	1
1	38	12	3	3
1	39	12	1	1
1	40	12	1	\N
1	41	12	1	\N
1	42	12	5	\N
1	43	12	5	\N
1	44	12	2	\N
1	45	12	3	3
1	46	12	3	3
1	47	12	7	\N
1	48	12	1	1
1	49	12	1	9
1	50	12	1	\N
1	51	12	9	\N
1	52	12	9	\N
1	53	12	9	\N
1	54	12	9	\N
1	55	12	1	1
1	56	12	9	\N
1	57	12	1	1
1	58	12	1	\N
1	59	12	1	1
1	60	12	1	9
1	1	13	1	9
1	2	13	9	\N
1	3	13	5	8
1	4	13	5	\N
1	5	13	5	6
1	6	13	5	6
1	7	13	5	8
1	8	13	5	8
1	9	13	9	\N
1	10	13	9	\N
1	11	13	1	\N
1	12	13	1	9
1	13	13	9	\N
1	14	13	9	\N
1	15	13	1	1
1	16	13	1	9
1	17	13	1	9
1	18	13	1	\N
1	19	13	5	6
1	20	13	1	9
1	21	13	1	\N
1	22	13	1	1
1	23	13	2	\N
1	24	13	2	1
1	25	13	4	7
1	26	13	2	1
1	27	13	9	\N
1	28	13	2	1
1	29	13	2	\N
1	30	13	4	\N
1	31	13	2	1
1	32	13	2	1
1	33	13	2	1
1	34	13	2	1
1	35	13	2	1
1	36	13	6	\N
1	37	13	6	\N
1	38	13	5	6
1	39	13	6	\N
1	40	13	9	\N
1	41	13	9	\N
1	42	13	9	\N
1	43	13	5	\N
1	44	13	5	6
1	45	13	3	2
1	46	13	3	2
1	47	13	3	3
1	48	13	1	1
1	49	13	1	1
1	50	13	1	\N
1	51	13	1	9
1	52	13	9	\N
1	53	13	3	2
1	54	13	1	\N
1	55	13	1	1
1	56	13	1	1
1	57	13	4	\N
1	58	13	1	1
1	59	13	1	\N
1	60	13	1	\N
1	1	14	1	1
1	2	14	1	9
1	3	14	5	\N
1	4	14	1	\N
1	5	14	5	\N
1	6	14	5	6
1	7	14	9	\N
1	8	14	5	8
1	9	14	5	8
1	10	14	9	\N
1	11	14	3	2
1	12	14	2	1
1	13	14	9	\N
1	14	14	6	\N
1	15	14	1	9
1	16	14	4	7
1	17	14	1	1
1	18	14	1	1
1	19	14	1	\N
1	20	14	1	9
1	21	14	1	9
1	22	14	1	1
1	23	14	6	\N
1	24	14	6	\N
1	25	14	2	1
1	26	14	2	1
1	27	14	2	\N
1	28	14	2	\N
1	29	14	7	\N
1	30	14	2	1
1	31	14	2	1
1	32	14	4	7
1	33	14	2	1
1	34	14	2	1
1	35	14	2	\N
1	36	14	2	\N
1	37	14	6	\N
1	38	14	9	\N
1	39	14	9	\N
1	40	14	6	\N
1	41	14	4	7
1	42	14	4	7
1	43	14	5	6
1	44	14	5	8
1	45	14	3	3
1	46	14	3	\N
1	47	14	5	8
1	48	14	1	\N
1	49	14	5	\N
1	50	14	1	\N
1	51	14	1	\N
1	52	14	9	\N
1	53	14	9	\N
1	54	14	9	\N
1	55	14	1	\N
1	56	14	1	9
1	57	14	9	\N
1	58	14	1	9
1	59	14	1	\N
1	60	14	1	9
1	1	15	1	1
1	2	15	1	1
1	3	15	7	\N
1	4	15	5	\N
1	5	15	6	\N
1	6	15	5	8
1	7	15	9	\N
1	8	15	5	8
1	9	15	5	\N
1	10	15	5	6
1	11	15	2	\N
1	12	15	2	1
1	13	15	9	\N
1	14	15	5	6
1	15	15	1	1
1	16	15	6	\N
1	17	15	1	1
1	18	15	1	1
1	19	15	1	\N
1	20	15	1	1
1	21	15	2	1
1	22	15	7	\N
1	23	15	6	\N
1	24	15	6	\N
1	25	15	2	\N
1	26	15	2	1
1	27	15	2	1
1	28	15	2	1
1	29	15	2	\N
1	30	15	2	1
1	31	15	2	1
1	32	15	2	1
1	33	15	2	\N
1	34	15	2	\N
1	35	15	2	1
1	36	15	7	\N
1	37	15	2	1
1	38	15	9	\N
1	39	15	6	\N
1	40	15	6	\N
1	41	15	4	7
1	42	15	4	7
1	43	15	4	7
1	44	15	5	6
1	45	15	3	2
1	46	15	3	3
1	47	15	3	2
1	48	15	5	6
1	49	15	1	9
1	50	15	1	\N
1	51	15	1	\N
1	52	15	1	9
1	53	15	4	7
1	54	15	1	1
1	55	15	1	9
1	56	15	1	\N
1	57	15	1	\N
1	58	15	1	9
1	59	15	1	9
1	60	15	1	\N
1	1	16	3	3
1	2	16	1	\N
1	3	16	6	\N
1	4	16	9	\N
1	5	16	5	6
1	6	16	3	2
1	7	16	9	\N
1	8	16	5	6
1	9	16	5	\N
1	10	16	5	8
1	11	16	6	\N
1	12	16	2	1
1	13	16	9	\N
1	14	16	1	1
1	15	16	1	1
1	16	16	1	1
1	17	16	1	9
1	18	16	1	1
1	19	16	1	1
1	20	16	7	\N
1	21	16	7	\N
1	22	16	7	\N
1	23	16	6	\N
1	24	16	7	\N
1	25	16	2	1
1	26	16	2	1
1	27	16	2	1
1	28	16	2	\N
1	29	16	2	\N
1	30	16	2	1
1	31	16	2	1
1	32	16	5	8
1	33	16	6	\N
1	34	16	2	1
1	35	16	2	1
1	36	16	7	\N
1	37	16	7	\N
1	38	16	2	1
1	39	16	6	\N
1	40	16	6	\N
1	41	16	4	7
1	42	16	4	\N
1	43	16	4	7
1	44	16	4	\N
1	45	16	3	2
1	46	16	3	\N
1	47	16	4	\N
1	48	16	1	1
1	49	16	1	1
1	50	16	5	6
1	51	16	1	9
1	52	16	1	\N
1	53	16	1	9
1	54	16	1	9
1	55	16	1	1
1	56	16	1	\N
1	57	16	1	1
1	58	16	1	\N
1	59	16	1	\N
1	60	16	1	9
1	1	17	1	9
1	2	17	1	9
1	3	17	1	1
1	4	17	9	\N
1	5	17	9	\N
1	6	17	3	\N
1	7	17	3	3
1	8	17	5	6
1	9	17	5	6
1	10	17	5	6
1	11	17	3	2
1	12	17	2	\N
1	13	17	2	1
1	14	17	5	8
1	15	17	1	1
1	16	17	1	\N
1	17	17	1	\N
1	18	17	1	\N
1	19	17	1	1
1	20	17	1	\N
1	21	17	3	2
1	22	17	7	\N
1	23	17	4	7
1	24	17	4	\N
1	25	17	2	1
1	26	17	2	1
1	27	17	2	\N
1	28	17	2	\N
1	29	17	2	1
1	30	17	2	1
1	31	17	2	1
1	32	17	2	1
1	33	17	9	\N
1	34	17	9	\N
1	35	17	9	\N
1	36	17	9	\N
1	37	17	9	\N
1	38	17	2	1
1	39	17	2	1
1	40	17	6	\N
1	41	17	4	\N
1	42	17	9	\N
1	43	17	9	\N
1	44	17	9	\N
1	45	17	3	2
1	46	17	3	3
1	47	17	3	2
1	48	17	1	\N
1	49	17	1	9
1	50	17	1	\N
1	51	17	1	1
1	52	17	1	\N
1	53	17	1	\N
1	54	17	1	\N
1	55	17	1	1
1	56	17	1	9
1	57	17	1	\N
1	58	17	1	9
1	59	17	1	\N
1	60	17	1	9
1	1	18	1	9
1	2	18	1	\N
1	3	18	1	9
1	4	18	5	\N
1	5	18	9	\N
1	6	18	9	\N
1	7	18	5	\N
1	8	18	5	8
1	9	18	5	\N
1	10	18	5	6
1	11	18	5	8
1	12	18	2	1
1	13	18	2	1
1	14	18	6	\N
1	15	18	1	1
1	16	18	9	\N
1	17	18	1	\N
1	18	18	1	\N
1	19	18	5	\N
1	20	18	1	9
1	21	18	1	\N
1	22	18	1	\N
1	23	18	4	7
1	24	18	2	1
1	25	18	2	1
1	26	18	9	\N
1	27	18	2	1
1	28	18	2	1
1	29	18	2	\N
1	30	18	2	1
1	31	18	2	1
1	32	18	2	1
1	33	18	9	\N
1	34	18	3	3
1	35	18	3	3
1	36	18	1	1
1	37	18	9	\N
1	38	18	9	\N
1	39	18	9	\N
1	40	18	2	1
1	41	18	2	1
1	42	18	9	\N
1	43	18	5	\N
1	44	18	9	\N
1	45	18	9	\N
1	46	18	3	\N
1	47	18	3	2
1	48	18	1	1
1	49	18	1	\N
1	50	18	1	9
1	51	18	1	9
1	52	18	1	9
1	53	18	6	\N
1	54	18	1	1
1	55	18	1	1
1	56	18	1	1
1	57	18	1	\N
1	58	18	1	1
1	59	18	1	1
1	60	18	1	\N
1	1	19	1	\N
1	2	19	1	\N
1	3	19	1	\N
1	4	19	1	\N
1	5	19	9	\N
1	6	19	7	\N
1	7	19	5	6
1	8	19	5	8
1	9	19	3	2
1	10	19	5	8
1	11	19	5	8
1	12	19	2	1
1	13	19	2	1
1	14	19	2	\N
1	15	19	1	1
1	16	19	9	\N
1	17	19	1	\N
1	18	19	1	1
1	19	19	1	9
1	20	19	1	\N
1	21	19	2	1
1	22	19	1	1
1	23	19	1	1
1	24	19	2	1
1	25	19	2	1
1	26	19	2	1
1	27	19	2	\N
1	28	19	2	1
1	29	19	2	1
1	30	19	2	\N
1	31	19	3	2
1	32	19	2	1
1	33	19	2	1
1	34	19	7	\N
1	35	19	3	2
1	36	19	3	3
1	37	19	1	9
1	38	19	1	\N
1	39	19	9	\N
1	40	19	2	\N
1	41	19	2	\N
1	42	19	2	1
1	43	19	6	\N
1	44	19	9	\N
1	45	19	3	2
1	46	19	3	2
1	47	19	3	2
1	48	19	1	9
1	49	19	1	\N
1	50	19	1	1
1	51	19	2	1
1	52	19	1	\N
1	53	19	6	\N
1	54	19	7	\N
1	55	19	1	\N
1	56	19	1	1
1	57	19	1	1
1	58	19	1	\N
1	59	19	1	9
1	60	19	2	\N
1	1	20	1	\N
1	2	20	1	9
1	3	20	5	8
1	4	20	1	\N
1	5	20	1	\N
1	6	20	1	\N
1	7	20	5	8
1	8	20	5	8
1	9	20	5	6
1	10	20	5	8
1	11	20	6	\N
1	12	20	2	1
1	13	20	2	1
1	14	20	5	8
1	15	20	5	6
1	16	20	9	\N
1	17	20	9	\N
1	18	20	9	\N
1	19	20	9	\N
1	20	20	9	\N
1	21	20	5	6
1	22	20	1	9
1	23	20	1	\N
1	24	20	1	9
1	25	20	3	2
1	26	20	2	1
1	27	20	6	\N
1	28	20	2	1
1	29	20	2	\N
1	30	20	9	\N
1	31	20	2	1
1	32	20	2	1
1	33	20	7	\N
1	34	20	4	7
1	35	20	6	\N
1	36	20	3	2
1	37	20	1	1
1	38	20	6	\N
1	39	20	1	1
1	40	20	2	1
1	41	20	9	\N
1	42	20	2	1
1	43	20	2	1
1	44	20	2	1
1	45	20	8	\N
1	46	20	3	3
1	47	20	3	2
1	48	20	1	\N
1	49	20	1	1
1	50	20	1	9
1	51	20	1	9
1	52	20	1	\N
1	53	20	5	6
1	54	20	1	\N
1	55	20	1	\N
1	56	20	1	9
1	57	20	1	\N
1	58	20	1	\N
1	59	20	1	1
1	60	20	1	\N
1	1	21	1	\N
1	2	21	1	1
1	3	21	1	1
1	4	21	1	1
1	5	21	1	1
1	6	21	1	1
1	7	21	1	9
1	8	21	5	6
1	9	21	5	\N
1	10	21	6	\N
1	11	21	1	9
1	12	21	2	1
1	13	21	2	1
1	14	21	2	1
1	15	21	5	\N
1	16	21	9	\N
1	17	21	3	2
1	18	21	3	3
1	19	21	9	\N
1	20	21	5	\N
1	21	21	4	7
1	22	21	1	\N
1	23	21	1	1
1	24	21	9	\N
1	25	21	5	\N
1	26	21	2	1
1	27	21	2	1
1	28	21	2	1
1	29	21	2	1
1	30	21	3	\N
1	31	21	2	1
1	32	21	2	\N
1	33	21	9	\N
1	34	21	9	\N
1	35	21	3	3
1	36	21	7	\N
1	37	21	1	\N
1	38	21	9	\N
1	39	21	1	9
1	40	21	1	\N
1	41	21	9	\N
1	42	21	9	\N
1	43	21	2	1
1	44	21	8	\N
1	45	21	8	\N
1	46	21	3	\N
1	47	21	3	3
1	48	21	9	\N
1	49	21	1	\N
1	50	21	1	9
1	51	21	1	9
1	52	21	9	\N
1	53	21	9	\N
1	54	21	9	\N
1	55	21	9	\N
1	56	21	9	\N
1	57	21	9	\N
1	58	21	9	\N
1	59	21	2	1
1	60	21	1	\N
1	1	22	1	1
1	2	22	1	1
1	3	22	1	9
1	4	22	1	1
1	5	22	1	9
1	6	22	1	\N
1	7	22	1	\N
1	8	22	1	9
1	9	22	5	8
1	10	22	5	8
1	11	22	1	9
1	12	22	1	\N
1	13	22	2	\N
1	14	22	3	3
1	15	22	2	1
1	16	22	2	1
1	17	22	3	\N
1	18	22	4	7
1	19	22	9	\N
1	20	22	9	\N
1	21	22	1	1
1	22	22	1	9
1	23	22	4	7
1	24	22	1	9
1	25	22	1	\N
1	26	22	2	1
1	27	22	4	\N
1	28	22	2	1
1	29	22	2	1
1	30	22	2	1
1	31	22	2	\N
1	32	22	2	1
1	33	22	9	\N
1	34	22	3	3
1	35	22	3	2
1	36	22	3	\N
1	37	22	1	1
1	38	22	1	1
1	39	22	1	9
1	40	22	1	\N
1	41	22	9	\N
1	42	22	2	1
1	43	22	2	\N
1	44	22	3	3
1	45	22	8	\N
1	46	22	3	2
1	47	22	3	\N
1	48	22	9	\N
1	49	22	1	\N
1	50	22	1	1
1	51	22	1	\N
1	52	22	1	1
1	53	22	7	\N
1	54	22	9	\N
1	55	22	6	\N
1	56	22	6	\N
1	57	22	6	\N
1	58	22	2	\N
1	59	22	2	1
1	60	22	2	\N
1	1	23	1	\N
1	2	23	1	1
1	3	23	1	1
1	4	23	1	1
1	5	23	1	\N
1	6	23	3	3
1	7	23	1	1
1	8	23	3	\N
1	9	23	5	\N
1	10	23	5	6
1	11	23	1	1
1	12	23	1	9
1	13	23	7	\N
1	14	23	2	1
1	15	23	2	1
1	16	23	2	1
1	17	23	2	1
1	18	23	2	1
1	19	23	2	\N
1	20	23	9	\N
1	21	23	6	\N
1	22	23	1	9
1	23	23	1	9
1	24	23	1	1
1	25	23	1	9
1	26	23	1	1
1	27	23	2	1
1	28	23	2	1
1	29	23	2	1
1	30	23	2	\N
1	31	23	1	\N
1	32	23	2	\N
1	33	23	9	\N
1	34	23	9	\N
1	35	23	9	\N
1	36	23	3	3
1	37	23	9	\N
1	38	23	9	\N
1	39	23	9	\N
1	40	23	9	\N
1	41	23	1	\N
1	42	23	2	1
1	43	23	9	\N
1	44	23	8	\N
1	45	23	3	\N
1	46	23	8	\N
1	47	23	8	\N
1	48	23	8	\N
1	49	23	1	\N
1	50	23	1	9
1	51	23	1	1
1	52	23	1	\N
1	53	23	1	9
1	54	23	9	\N
1	55	23	1	\N
1	56	23	6	\N
1	57	23	6	\N
1	58	23	2	1
1	59	23	2	1
1	60	23	2	1
1	1	24	1	1
1	2	24	2	1
1	3	24	6	\N
1	4	24	1	9
1	5	24	1	9
1	6	24	1	9
1	7	24	4	7
1	8	24	1	\N
1	9	24	5	\N
1	10	24	5	\N
1	11	24	1	9
1	12	24	1	9
1	13	24	1	9
1	14	24	2	1
1	15	24	2	\N
1	16	24	2	\N
1	17	24	2	1
1	18	24	5	6
1	19	24	2	1
1	20	24	2	\N
1	21	24	1	\N
1	22	24	1	9
1	23	24	6	\N
1	24	24	1	9
1	25	24	9	\N
1	26	24	1	9
1	27	24	5	\N
1	28	24	2	1
1	29	24	2	1
1	30	24	2	1
1	31	24	2	1
1	32	24	2	1
1	33	24	2	\N
1	34	24	9	\N
1	35	24	3	2
1	36	24	3	2
1	37	24	3	2
1	38	24	3	\N
1	39	24	9	\N
1	40	24	9	\N
1	41	24	1	9
1	42	24	1	\N
1	43	24	8	\N
1	44	24	3	3
1	45	24	8	\N
1	46	24	8	\N
1	47	24	8	\N
1	48	24	8	\N
1	49	24	1	9
1	50	24	1	1
1	51	24	6	\N
1	52	24	9	\N
1	53	24	9	\N
1	54	24	1	1
1	55	24	1	9
1	56	24	1	1
1	57	24	6	\N
1	58	24	5	6
1	59	24	2	\N
1	60	24	4	\N
1	1	25	1	\N
1	2	25	1	\N
1	3	25	9	\N
1	4	25	1	\N
1	5	25	1	\N
1	6	25	1	1
1	7	25	1	1
1	8	25	1	1
1	9	25	1	\N
1	10	25	9	\N
1	11	25	1	\N
1	12	25	1	9
1	13	25	1	1
1	14	25	6	\N
1	15	25	2	\N
1	16	25	2	1
1	17	25	5	8
1	18	25	2	1
1	19	25	2	1
1	20	25	2	1
1	21	25	1	\N
1	22	25	1	9
1	23	25	1	9
1	24	25	1	9
1	25	25	9	\N
1	26	25	1	\N
1	27	25	9	\N
1	28	25	2	1
1	29	25	2	\N
1	30	25	2	1
1	31	25	9	\N
1	32	25	9	\N
1	33	25	2	1
1	34	25	2	1
1	35	25	3	3
1	36	25	3	\N
1	37	25	3	2
1	38	25	3	2
1	39	25	3	2
1	40	25	9	\N
1	41	25	7	\N
1	42	25	8	\N
1	43	25	1	9
1	44	25	8	\N
1	45	25	8	\N
1	46	25	8	\N
1	47	25	8	\N
1	48	25	8	\N
1	49	25	8	\N
1	50	25	1	\N
1	51	25	1	\N
1	52	25	9	\N
1	53	25	1	\N
1	54	25	3	\N
1	55	25	1	\N
1	56	25	1	1
1	57	25	1	1
1	58	25	1	\N
1	59	25	1	\N
1	60	25	1	\N
1	1	26	1	\N
1	2	26	1	1
1	3	26	9	\N
1	4	26	7	\N
1	5	26	1	\N
1	6	26	5	8
1	7	26	1	9
1	8	26	9	\N
1	9	26	9	\N
1	10	26	1	\N
1	11	26	1	\N
1	12	26	1	1
1	13	26	1	\N
1	14	26	1	9
1	15	26	2	1
1	16	26	2	1
1	17	26	7	\N
1	18	26	2	\N
1	19	26	2	1
1	20	26	2	1
1	21	26	9	\N
1	22	26	9	\N
1	23	26	1	1
1	24	26	1	\N
1	25	26	9	\N
1	26	26	9	\N
1	27	26	1	\N
1	28	26	7	\N
1	29	26	2	1
1	30	26	2	1
1	31	26	9	\N
1	32	26	2	\N
1	33	26	2	\N
1	34	26	1	\N
1	35	26	3	\N
1	36	26	3	2
1	37	26	3	\N
1	38	26	3	\N
1	39	26	3	3
1	40	26	9	\N
1	41	26	8	\N
1	42	26	8	\N
1	43	26	8	\N
1	44	26	8	\N
1	45	26	8	\N
1	46	26	8	\N
1	47	26	8	\N
1	48	26	8	\N
1	49	26	8	\N
1	50	26	8	\N
1	51	26	6	\N
1	52	26	7	\N
1	53	26	1	\N
1	54	26	1	\N
1	55	26	1	9
1	56	26	1	\N
1	57	26	7	\N
1	58	26	1	9
1	59	26	1	9
1	60	26	1	\N
1	1	27	2	1
1	2	27	1	1
1	3	27	1	9
1	4	27	1	1
1	5	27	1	1
1	6	27	9	\N
1	7	27	1	1
1	8	27	1	1
1	9	27	9	\N
1	10	27	1	1
1	11	27	1	1
1	12	27	1	\N
1	13	27	1	1
1	14	27	1	1
1	15	27	1	1
1	16	27	2	1
1	17	27	6	\N
1	18	27	2	1
1	19	27	2	\N
1	20	27	2	\N
1	21	27	2	1
1	22	27	1	9
1	23	27	1	\N
1	24	27	1	\N
1	25	27	9	\N
1	26	27	1	\N
1	27	27	1	1
1	28	27	1	9
1	29	27	2	1
1	30	27	7	\N
1	31	27	2	1
1	32	27	2	1
1	33	27	3	3
1	34	27	3	2
1	35	27	3	\N
1	36	27	3	\N
1	37	27	3	2
1	38	27	3	2
1	39	27	6	\N
1	40	27	9	\N
1	41	27	8	\N
1	42	27	8	\N
1	43	27	8	\N
1	44	27	8	\N
1	45	27	8	\N
1	46	27	8	\N
1	47	27	8	\N
1	48	27	3	\N
1	49	27	8	\N
1	50	27	8	\N
1	51	27	8	\N
1	52	27	8	\N
1	53	27	1	1
1	54	27	9	\N
1	55	27	9	\N
1	56	27	1	1
1	57	27	1	1
1	58	27	3	3
1	59	27	1	1
1	60	27	1	\N
1	1	28	1	1
1	2	28	1	9
1	3	28	1	\N
1	4	28	5	\N
1	5	28	1	\N
1	6	28	9	\N
1	7	28	1	1
1	8	28	1	\N
1	9	28	9	\N
1	10	28	1	1
1	11	28	6	\N
1	12	28	1	9
1	13	28	1	\N
1	14	28	1	1
1	15	28	1	1
1	16	28	1	9
1	17	28	2	\N
1	18	28	2	1
1	19	28	4	\N
1	20	28	5	8
1	21	28	4	7
1	22	28	1	9
1	23	28	1	9
1	24	28	7	\N
1	25	28	9	\N
1	26	28	1	1
1	27	28	1	\N
1	28	28	1	\N
1	29	28	1	\N
1	30	28	2	\N
1	31	28	2	1
1	32	28	2	1
1	33	28	2	\N
1	34	28	3	3
1	35	28	3	2
1	36	28	3	\N
1	37	28	3	2
1	38	28	3	3
1	39	28	6	\N
1	40	28	8	\N
1	41	28	8	\N
1	42	28	8	\N
1	43	28	8	\N
1	44	28	8	\N
1	45	28	8	\N
1	46	28	8	\N
1	47	28	8	\N
1	48	28	3	2
1	49	28	8	\N
1	50	28	8	\N
1	51	28	8	\N
1	52	28	8	\N
1	53	28	8	\N
1	54	28	8	\N
1	55	28	8	\N
1	56	28	1	\N
1	57	28	2	1
1	58	28	2	1
1	59	28	1	1
1	60	28	2	1
1	1	29	1	\N
1	2	29	1	\N
1	3	29	1	1
1	4	29	1	1
1	5	29	1	1
1	6	29	1	9
1	7	29	1	\N
1	8	29	1	\N
1	9	29	9	\N
1	10	29	9	\N
1	11	29	1	\N
1	12	29	1	9
1	13	29	7	\N
1	14	29	1	\N
1	15	29	5	8
1	16	29	7	\N
1	17	29	2	\N
1	18	29	4	7
1	19	29	4	7
1	20	29	2	1
1	21	29	1	9
1	22	29	1	\N
1	23	29	1	\N
1	24	29	1	\N
1	25	29	1	1
1	26	29	1	9
1	27	29	1	9
1	28	29	1	1
1	29	29	1	1
1	30	29	6	\N
1	31	29	2	1
1	32	29	2	\N
1	33	29	2	1
1	34	29	2	\N
1	35	29	3	\N
1	36	29	3	\N
1	37	29	3	2
1	38	29	3	2
1	39	29	6	\N
1	40	29	8	\N
1	41	29	8	\N
1	42	29	8	\N
1	43	29	8	\N
1	44	29	8	\N
1	45	29	8	\N
1	46	29	8	\N
1	47	29	8	\N
1	48	29	8	\N
1	49	29	8	\N
1	50	29	8	\N
1	51	29	8	\N
1	52	29	8	\N
1	53	29	8	\N
1	54	29	8	\N
1	55	29	8	\N
1	56	29	8	\N
1	57	29	2	1
1	58	29	8	\N
1	59	29	2	1
1	60	29	2	1
1	1	30	1	1
1	2	30	3	2
1	3	30	1	9
1	4	30	1	1
1	5	30	6	\N
1	6	30	6	\N
1	7	30	3	3
1	8	30	1	\N
1	9	30	9	\N
1	10	30	9	\N
1	11	30	1	1
1	12	30	1	1
1	13	30	4	\N
1	14	30	1	1
1	15	30	1	\N
1	16	30	3	\N
1	17	30	2	\N
1	18	30	2	\N
1	19	30	2	1
1	20	30	7	\N
1	21	30	1	\N
1	22	30	1	\N
1	23	30	1	9
1	24	30	1	1
1	25	30	1	\N
1	26	30	2	\N
1	27	30	1	\N
1	28	30	1	9
1	29	30	1	\N
1	30	30	1	\N
1	31	30	2	1
1	32	30	2	1
1	33	30	7	\N
1	34	30	2	1
1	35	30	2	1
1	36	30	3	2
1	37	30	3	\N
1	38	30	3	2
1	39	30	3	\N
1	40	30	8	\N
1	41	30	8	\N
1	42	30	8	\N
1	43	30	8	\N
1	44	30	8	\N
1	45	30	8	\N
1	46	30	8	\N
1	47	30	6	\N
1	48	30	6	\N
1	49	30	8	\N
1	50	30	8	\N
1	51	30	8	\N
1	52	30	8	\N
1	53	30	8	\N
1	54	30	8	\N
1	55	30	8	\N
1	56	30	8	\N
1	57	30	8	\N
1	58	30	2	1
1	59	30	2	1
1	60	30	2	\N
1	1	31	1	1
1	2	31	1	\N
1	3	31	1	\N
1	4	31	4	7
1	5	31	6	\N
1	6	31	6	\N
1	7	31	6	\N
1	8	31	1	1
1	9	31	1	9
1	10	31	1	9
1	11	31	1	9
1	12	31	1	\N
1	13	31	1	1
1	14	31	1	\N
1	15	31	1	1
1	16	31	1	\N
1	17	31	2	1
1	18	31	2	\N
1	19	31	2	1
1	20	31	1	1
1	21	31	1	\N
1	22	31	2	\N
1	23	31	6	\N
1	24	31	1	9
1	25	31	1	1
1	26	31	6	\N
1	27	31	1	9
1	28	31	3	2
1	29	31	1	1
1	30	31	1	\N
1	31	31	1	\N
1	32	31	2	\N
1	33	31	2	1
1	34	31	2	1
1	35	31	2	1
1	36	31	5	8
1	37	31	9	\N
1	38	31	9	\N
1	39	31	8	\N
1	40	31	3	2
1	41	31	8	\N
1	42	31	8	\N
1	43	31	8	\N
1	44	31	8	\N
1	45	31	8	\N
1	46	31	8	\N
1	47	31	8	\N
1	48	31	6	\N
1	49	31	8	\N
1	50	31	1	\N
1	51	31	8	\N
1	52	31	8	\N
1	53	31	8	\N
1	54	31	8	\N
1	55	31	8	\N
1	56	31	8	\N
1	57	31	8	\N
1	58	31	8	\N
1	59	31	2	1
1	60	31	2	1
1	1	32	1	9
1	2	32	1	1
1	3	32	1	\N
1	4	32	6	\N
1	5	32	6	\N
1	6	32	6	\N
1	7	32	6	\N
1	8	32	9	\N
1	9	32	9	\N
1	10	32	9	\N
1	11	32	9	\N
1	12	32	9	\N
1	13	32	9	\N
1	14	32	1	9
1	15	32	1	9
1	16	32	4	7
1	17	32	2	1
1	18	32	7	\N
1	19	32	2	\N
1	20	32	1	1
1	21	32	5	6
1	22	32	1	\N
1	23	32	1	1
1	24	32	1	1
1	25	32	1	\N
1	26	32	1	\N
1	27	32	1	\N
1	28	32	1	\N
1	29	32	5	6
1	30	32	1	\N
1	31	32	4	7
1	32	32	2	\N
1	33	32	2	1
1	34	32	2	1
1	35	32	2	1
1	36	32	2	\N
1	37	32	2	\N
1	38	32	8	\N
1	39	32	8	\N
1	40	32	8	\N
1	41	32	8	\N
1	42	32	8	\N
1	43	32	8	\N
1	44	32	8	\N
1	45	32	8	\N
1	46	32	8	\N
1	47	32	8	\N
1	48	32	8	\N
1	49	32	8	\N
1	50	32	8	\N
1	51	32	8	\N
1	52	32	7	\N
1	53	32	8	\N
1	54	32	8	\N
1	55	32	8	\N
1	56	32	8	\N
1	57	32	8	\N
1	58	32	8	\N
1	59	32	8	\N
1	60	32	2	\N
1	1	33	1	\N
1	2	33	3	3
1	3	33	1	\N
1	4	33	1	9
1	5	33	6	\N
1	6	33	6	\N
1	7	33	6	\N
1	8	33	9	\N
1	9	33	9	\N
1	10	33	4	\N
1	11	33	4	7
1	12	33	1	1
1	13	33	1	\N
1	14	33	5	\N
1	15	33	1	\N
1	16	33	1	1
1	17	33	1	9
1	18	33	2	\N
1	19	33	6	\N
1	20	33	1	9
1	21	33	1	9
1	22	33	1	\N
1	23	33	1	9
1	24	33	1	1
1	25	33	3	\N
1	26	33	1	9
1	27	33	1	9
1	28	33	1	\N
1	29	33	1	1
1	30	33	1	9
1	31	33	9	\N
1	32	33	3	\N
1	33	33	2	1
1	34	33	9	\N
1	35	33	9	\N
1	36	33	9	\N
1	37	33	8	\N
1	38	33	8	\N
1	39	33	8	\N
1	40	33	8	\N
1	41	33	8	\N
1	42	33	8	\N
1	43	33	8	\N
1	44	33	8	\N
1	45	33	8	\N
1	46	33	8	\N
1	47	33	8	\N
1	48	33	8	\N
1	49	33	8	\N
1	50	33	8	\N
1	51	33	8	\N
1	52	33	8	\N
1	53	33	8	\N
1	54	33	8	\N
1	55	33	8	\N
1	56	33	8	\N
1	57	33	8	\N
1	58	33	8	\N
1	59	33	8	\N
1	60	33	2	1
1	1	34	1	1
1	2	34	1	1
1	3	34	4	7
1	4	34	3	3
1	5	34	6	\N
1	6	34	6	\N
1	7	34	6	\N
1	8	34	6	\N
1	9	34	4	7
1	10	34	4	7
1	11	34	4	\N
1	12	34	2	\N
1	13	34	6	\N
1	14	34	1	9
1	15	34	4	\N
1	16	34	1	1
1	17	34	4	\N
1	18	34	1	\N
1	19	34	7	\N
1	20	34	1	9
1	21	34	1	1
1	22	34	1	\N
1	23	34	1	1
1	24	34	9	\N
1	25	34	9	\N
1	26	34	1	\N
1	27	34	1	9
1	28	34	1	9
1	29	34	1	\N
1	30	34	1	1
1	31	34	9	\N
1	32	34	2	1
1	33	34	2	1
1	34	34	2	1
1	35	34	2	1
1	36	34	8	\N
1	37	34	8	\N
1	38	34	8	\N
1	39	34	3	\N
1	40	34	8	\N
1	41	34	8	\N
1	42	34	8	\N
1	43	34	8	\N
1	44	34	8	\N
1	45	34	8	\N
1	46	34	8	\N
1	47	34	8	\N
1	48	34	8	\N
1	49	34	4	\N
1	50	34	8	\N
1	51	34	8	\N
1	52	34	8	\N
1	53	34	8	\N
1	54	34	8	\N
1	55	34	8	\N
1	56	34	8	\N
1	57	34	5	8
1	58	34	8	\N
1	59	34	8	\N
1	60	34	8	\N
1	1	35	1	\N
1	2	35	1	\N
1	3	35	1	1
1	4	35	1	\N
1	5	35	6	\N
1	6	35	6	\N
1	7	35	6	\N
1	8	35	9	\N
1	9	35	4	7
1	10	35	4	7
1	11	35	1	\N
1	12	35	1	1
1	13	35	1	1
1	14	35	5	8
1	15	35	1	\N
1	16	35	1	\N
1	17	35	5	8
1	18	35	6	\N
1	19	35	1	1
1	20	35	1	1
1	21	35	1	\N
1	22	35	1	1
1	23	35	1	\N
1	24	35	9	\N
1	25	35	1	\N
1	26	35	1	9
1	27	35	1	1
1	28	35	9	\N
1	29	35	9	\N
1	30	35	9	\N
1	31	35	1	9
1	32	35	2	\N
1	33	35	7	\N
1	34	35	2	\N
1	35	35	2	1
1	36	35	8	\N
1	37	35	8	\N
1	38	35	8	\N
1	39	35	8	\N
1	40	35	3	\N
1	41	35	8	\N
1	42	35	8	\N
1	43	35	8	\N
1	44	35	8	\N
1	45	35	8	\N
1	46	35	8	\N
1	47	35	8	\N
1	48	35	8	\N
1	49	35	8	\N
1	50	35	8	\N
1	51	35	8	\N
1	52	35	8	\N
1	53	35	8	\N
1	54	35	8	\N
1	55	35	8	\N
1	56	35	8	\N
1	57	35	8	\N
1	58	35	8	\N
1	59	35	8	\N
1	60	35	8	\N
1	1	36	1	\N
1	2	36	1	\N
1	3	36	1	1
1	4	36	6	\N
1	5	36	6	\N
1	6	36	6	\N
1	7	36	6	\N
1	8	36	9	\N
1	9	36	9	\N
1	10	36	9	\N
1	11	36	1	\N
1	12	36	1	9
1	13	36	1	1
1	14	36	1	\N
1	15	36	1	9
1	16	36	1	\N
1	17	36	1	1
1	18	36	1	1
1	19	36	9	\N
1	20	36	1	\N
1	21	36	5	6
1	22	36	1	1
1	23	36	1	9
1	24	36	9	\N
1	25	36	9	\N
1	26	36	9	\N
1	27	36	1	9
1	28	36	1	1
1	29	36	1	9
1	30	36	9	\N
1	31	36	9	\N
1	32	36	9	\N
1	33	36	9	\N
1	34	36	2	1
1	35	36	2	1
1	36	36	2	1
1	37	36	8	\N
1	38	36	8	\N
1	39	36	8	\N
1	40	36	4	7
1	41	36	8	\N
1	42	36	3	3
1	43	36	3	3
1	44	36	8	\N
1	45	36	8	\N
1	46	36	8	\N
1	47	36	8	\N
1	48	36	8	\N
1	49	36	8	\N
1	50	36	8	\N
1	51	36	8	\N
1	52	36	8	\N
1	53	36	8	\N
1	54	36	8	\N
1	55	36	8	\N
1	56	36	8	\N
1	57	36	8	\N
1	58	36	8	\N
1	59	36	8	\N
1	60	36	8	\N
1	1	37	1	1
1	2	37	1	9
1	3	37	1	1
1	4	37	1	1
1	5	37	6	\N
1	6	37	8	\N
1	7	37	8	\N
1	8	37	8	\N
1	9	37	8	\N
1	10	37	9	\N
1	11	37	9	\N
1	12	37	1	\N
1	13	37	1	1
1	14	37	1	\N
1	15	37	1	9
1	16	37	1	9
1	17	37	1	1
1	18	37	1	1
1	19	37	1	9
1	20	37	1	9
1	21	37	1	9
1	22	37	1	1
1	23	37	1	\N
1	24	37	1	9
1	25	37	1	9
1	26	37	9	\N
1	27	37	1	9
1	28	37	1	9
1	29	37	1	1
1	30	37	1	\N
1	31	37	1	\N
1	32	37	9	\N
1	33	37	2	1
1	34	37	3	\N
1	35	37	2	1
1	36	37	8	\N
1	37	37	8	\N
1	38	37	8	\N
1	39	37	8	\N
1	40	37	8	\N
1	41	37	8	\N
1	42	37	8	\N
1	43	37	1	1
1	44	37	1	\N
1	45	37	8	\N
1	46	37	8	\N
1	47	37	8	\N
1	48	37	8	\N
1	49	37	8	\N
1	50	37	8	\N
1	51	37	8	\N
1	52	37	8	\N
1	53	37	8	\N
1	54	37	8	\N
1	55	37	8	\N
1	56	37	8	\N
1	57	37	8	\N
1	58	37	8	\N
1	59	37	8	\N
1	60	37	8	\N
1	1	38	1	9
1	2	38	1	1
1	3	38	1	9
1	4	38	1	\N
1	5	38	8	\N
1	6	38	8	\N
1	7	38	8	\N
1	8	38	8	\N
1	9	38	8	\N
1	10	38	8	\N
1	11	38	8	\N
1	12	38	1	9
1	13	38	1	\N
1	14	38	1	1
1	15	38	3	3
1	16	38	1	1
1	17	38	1	9
1	18	38	1	1
1	19	38	1	\N
1	20	38	1	1
1	21	38	1	9
1	22	38	1	9
1	23	38	1	9
1	24	38	1	9
1	25	38	1	\N
1	26	38	1	9
1	27	38	1	9
1	28	38	1	9
1	29	38	6	\N
1	30	38	1	1
1	31	38	1	9
1	32	38	9	\N
1	33	38	2	1
1	34	38	2	1
1	35	38	8	\N
1	36	38	8	\N
1	37	38	5	\N
1	38	38	8	\N
1	39	38	8	\N
1	40	38	8	\N
1	41	38	8	\N
1	42	38	8	\N
1	43	38	1	1
1	44	38	8	\N
1	45	38	8	\N
1	46	38	8	\N
1	47	38	8	\N
1	48	38	8	\N
1	49	38	8	\N
1	50	38	8	\N
1	51	38	8	\N
1	52	38	8	\N
1	53	38	8	\N
1	54	38	8	\N
1	55	38	8	\N
1	56	38	8	\N
1	57	38	8	\N
1	58	38	8	\N
1	59	38	8	\N
1	60	38	8	\N
1	1	39	1	\N
1	2	39	1	1
1	3	39	1	9
1	4	39	1	\N
1	5	39	8	\N
1	6	39	8	\N
1	7	39	4	7
1	8	39	8	\N
1	9	39	8	\N
1	10	39	8	\N
1	11	39	8	\N
1	12	39	1	1
1	13	39	1	\N
1	14	39	1	1
1	15	39	1	9
1	16	39	1	1
1	17	39	1	1
1	18	39	1	9
1	19	39	1	1
1	20	39	1	\N
1	21	39	7	\N
1	22	39	1	\N
1	23	39	1	9
1	24	39	1	9
1	25	39	9	\N
1	26	39	9	\N
1	27	39	9	\N
1	28	39	1	9
1	29	39	1	\N
1	30	39	1	9
1	31	39	3	\N
1	32	39	9	\N
1	33	39	2	1
1	34	39	2	\N
1	35	39	2	1
1	36	39	8	\N
1	37	39	8	\N
1	38	39	8	\N
1	39	39	8	\N
1	40	39	8	\N
1	41	39	8	\N
1	42	39	8	\N
1	43	39	8	\N
1	44	39	8	\N
1	45	39	8	\N
1	46	39	8	\N
1	47	39	8	\N
1	48	39	8	\N
1	49	39	8	\N
1	50	39	8	\N
1	51	39	8	\N
1	52	39	8	\N
1	53	39	8	\N
1	54	39	8	\N
1	55	39	8	\N
1	56	39	8	\N
1	57	39	6	\N
1	58	39	8	\N
1	59	39	8	\N
1	60	39	8	\N
1	1	40	1	9
1	2	40	7	\N
1	3	40	1	\N
1	4	40	8	\N
1	5	40	8	\N
1	6	40	8	\N
1	7	40	8	\N
1	8	40	8	\N
1	9	40	8	\N
1	10	40	8	\N
1	11	40	8	\N
1	12	40	8	\N
1	13	40	1	9
1	14	40	7	\N
1	15	40	9	\N
1	16	40	9	\N
1	17	40	9	\N
1	18	40	5	8
1	19	40	1	\N
1	20	40	4	\N
1	21	40	1	1
1	22	40	5	\N
1	23	40	2	1
1	24	40	1	\N
1	25	40	3	3
1	26	40	9	\N
1	27	40	1	\N
1	28	40	7	\N
1	29	40	1	9
1	30	40	3	\N
1	31	40	3	3
1	32	40	2	1
1	33	40	2	1
1	34	40	2	1
1	35	40	2	\N
1	36	40	2	1
1	37	40	8	\N
1	38	40	8	\N
1	39	40	8	\N
1	40	40	8	\N
1	41	40	8	\N
1	42	40	8	\N
1	43	40	4	\N
1	44	40	8	\N
1	45	40	8	\N
1	46	40	8	\N
1	47	40	8	\N
1	48	40	8	\N
1	49	40	8	\N
1	50	40	8	\N
1	51	40	8	\N
1	52	40	8	\N
1	53	40	3	2
1	54	40	3	2
1	55	40	8	\N
1	56	40	8	\N
1	57	40	8	\N
1	58	40	8	\N
1	59	40	8	\N
1	60	40	8	\N
1	1	41	1	9
1	2	41	1	9
1	3	41	1	\N
1	4	41	8	\N
1	5	41	3	3
1	6	41	8	\N
1	7	41	8	\N
1	8	41	8	\N
1	9	41	8	\N
1	10	41	8	\N
1	11	41	5	6
1	12	41	8	\N
1	13	41	8	\N
1	14	41	1	\N
1	15	41	9	\N
1	16	41	6	\N
1	17	41	5	6
1	18	41	5	6
1	19	41	5	\N
1	20	41	1	\N
1	21	41	1	1
1	22	41	1	9
1	23	41	1	9
1	24	41	1	9
1	25	41	1	9
1	26	41	1	1
1	27	41	3	2
1	28	41	1	9
1	29	41	1	1
1	30	41	1	1
1	31	41	3	\N
1	32	41	2	1
1	33	41	2	1
1	34	41	9	\N
1	35	41	9	\N
1	36	41	8	\N
1	37	41	8	\N
1	38	41	8	\N
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
1	53	41	3	3
1	54	41	3	3
1	55	41	8	\N
1	56	41	8	\N
1	57	41	8	\N
1	58	41	8	\N
1	59	41	8	\N
1	60	41	8	\N
1	1	42	1	1
1	2	42	1	\N
1	3	42	8	\N
1	4	42	1	9
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
1	16	42	5	\N
1	17	42	9	\N
1	18	42	9	\N
1	19	42	9	\N
1	20	42	1	9
1	21	42	6	\N
1	22	42	1	\N
1	23	42	1	1
1	24	42	1	\N
1	25	42	1	1
1	26	42	1	1
1	27	42	1	1
1	28	42	1	9
1	29	42	1	9
1	30	42	1	9
1	31	42	1	1
1	32	42	2	\N
1	33	42	2	1
1	34	42	9	\N
1	35	42	8	\N
1	36	42	8	\N
1	37	42	8	\N
1	38	42	8	\N
1	39	42	8	\N
1	40	42	8	\N
1	41	42	8	\N
1	42	42	8	\N
1	43	42	8	\N
1	44	42	8	\N
1	45	42	8	\N
1	46	42	8	\N
1	47	42	8	\N
1	48	42	8	\N
1	49	42	8	\N
1	50	42	8	\N
1	51	42	8	\N
1	52	42	8	\N
1	53	42	1	1
1	54	42	3	3
1	55	42	2	\N
1	56	42	8	\N
1	57	42	8	\N
1	58	42	8	\N
1	59	42	8	\N
1	60	42	8	\N
1	1	43	9	\N
1	2	43	8	\N
1	3	43	1	1
1	4	43	8	\N
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
1	18	43	9	\N
1	19	43	9	\N
1	20	43	9	\N
1	21	43	9	\N
1	22	43	1	1
1	23	43	1	1
1	24	43	1	9
1	25	43	9	\N
1	26	43	1	\N
1	27	43	1	9
1	28	43	1	9
1	29	43	1	\N
1	30	43	1	\N
1	31	43	1	1
1	32	43	1	\N
1	33	43	2	1
1	34	43	8	\N
1	35	43	8	\N
1	36	43	3	\N
1	37	43	8	\N
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
1	54	43	1	\N
1	55	43	1	1
1	56	43	5	8
1	57	43	8	\N
1	58	43	8	\N
1	59	43	8	\N
1	60	43	8	\N
1	1	44	9	\N
1	2	44	8	\N
1	3	44	8	\N
1	4	44	8	\N
1	5	44	8	\N
1	6	44	8	\N
1	7	44	8	\N
1	8	44	8	\N
1	9	44	6	\N
1	10	44	8	\N
1	11	44	8	\N
1	12	44	8	\N
1	13	44	8	\N
1	14	44	8	\N
1	15	44	8	\N
1	16	44	8	\N
1	17	44	8	\N
1	18	44	8	\N
1	19	44	8	\N
1	20	44	8	\N
1	21	44	8	\N
1	22	44	1	1
1	23	44	1	9
1	24	44	1	\N
1	25	44	9	\N
1	26	44	9	\N
1	27	44	1	\N
1	28	44	1	\N
1	29	44	1	9
1	30	44	1	1
1	31	44	1	9
1	32	44	1	9
1	33	44	1	9
1	34	44	8	\N
1	35	44	8	\N
1	36	44	8	\N
1	37	44	8	\N
1	38	44	8	\N
1	39	44	8	\N
1	40	44	2	\N
1	41	44	8	\N
1	42	44	8	\N
1	43	44	8	\N
1	44	44	8	\N
1	45	44	8	\N
1	46	44	8	\N
1	47	44	8	\N
1	48	44	8	\N
1	49	44	1	9
1	50	44	8	\N
1	51	44	8	\N
1	52	44	8	\N
1	53	44	8	\N
1	54	44	8	\N
1	55	44	8	\N
1	56	44	1	9
1	57	44	1	9
1	58	44	8	\N
1	59	44	8	\N
1	60	44	8	\N
1	1	45	8	\N
1	2	45	8	\N
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
1	23	45	1	1
1	24	45	1	9
1	25	45	1	1
1	26	45	1	\N
1	27	45	1	9
1	28	45	1	\N
1	29	45	1	\N
1	30	45	8	\N
1	31	45	1	1
1	32	45	1	1
1	33	45	1	1
1	34	45	1	\N
1	35	45	8	\N
1	36	45	8	\N
1	37	45	8	\N
1	38	45	8	\N
1	39	45	8	\N
1	40	45	8	\N
1	41	45	8	\N
1	42	45	8	\N
1	43	45	6	\N
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
1	56	45	1	1
1	57	45	8	\N
1	58	45	8	\N
1	59	45	8	\N
1	60	45	8	\N
1	1	46	6	\N
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
1	23	46	1	9
1	24	46	1	\N
1	25	46	7	\N
1	26	46	1	\N
1	27	46	1	\N
1	28	46	1	\N
1	29	46	1	9
1	30	46	1	1
1	31	46	8	\N
1	32	46	1	9
1	33	46	9	\N
1	34	46	8	\N
1	35	46	8	\N
1	36	46	8	\N
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
1	47	46	8	\N
1	48	46	8	\N
1	49	46	8	\N
1	50	46	8	\N
1	51	46	8	\N
1	52	46	6	\N
1	53	46	8	\N
1	54	46	8	\N
1	55	46	8	\N
1	56	46	8	\N
1	57	46	8	\N
1	58	46	8	\N
1	59	46	8	\N
1	60	46	8	\N
1	1	47	6	\N
1	2	47	6	\N
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
1	23	47	1	1
1	24	47	1	9
1	25	47	5	6
1	26	47	1	\N
1	27	47	5	6
1	28	47	1	\N
1	29	47	1	1
1	30	47	3	2
1	31	47	3	3
1	32	47	1	1
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
1	56	47	8	\N
1	57	47	8	\N
1	58	47	1	\N
1	59	47	8	\N
1	60	47	8	\N
1	1	48	6	\N
1	2	48	5	6
1	3	48	5	8
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
1	22	48	1	1
1	23	48	1	1
1	24	48	1	\N
1	25	48	1	9
1	26	48	1	\N
1	27	48	1	1
1	28	48	1	\N
1	29	48	3	3
1	30	48	3	\N
1	31	48	3	\N
1	32	48	4	7
1	33	48	1	1
1	34	48	8	\N
1	35	48	8	\N
1	36	48	8	\N
1	37	48	8	\N
1	38	48	8	\N
1	39	48	8	\N
1	40	48	3	\N
1	41	48	8	\N
1	42	48	8	\N
1	43	48	7	\N
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
1	54	48	8	\N
1	55	48	8	\N
1	56	48	8	\N
1	57	48	8	\N
1	58	48	8	\N
1	59	48	8	\N
1	60	48	8	\N
1	1	49	2	\N
1	2	49	5	8
1	3	49	5	\N
1	4	49	8	\N
1	5	49	8	\N
1	6	49	8	\N
1	7	49	8	\N
1	8	49	8	\N
1	9	49	8	\N
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
1	25	49	1	9
1	26	49	2	1
1	27	49	4	\N
1	28	49	1	9
1	29	49	3	3
1	30	49	3	2
1	31	49	6	\N
1	32	49	1	9
1	33	49	1	1
1	34	49	2	\N
1	35	49	8	\N
1	36	49	8	\N
1	37	49	8	\N
1	38	49	8	\N
1	39	49	8	\N
1	40	49	8	\N
1	41	49	8	\N
1	42	49	8	\N
1	43	49	7	\N
1	44	49	7	\N
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
1	55	49	2	1
1	56	49	8	\N
1	57	49	8	\N
1	58	49	4	7
1	59	49	8	\N
1	60	49	8	\N
1	1	50	2	1
1	2	50	2	1
1	3	50	7	\N
1	4	50	5	6
1	5	50	5	\N
1	6	50	8	\N
1	7	50	8	\N
1	8	50	8	\N
1	9	50	8	\N
1	10	50	8	\N
1	11	50	8	\N
1	12	50	8	\N
1	13	50	8	\N
1	14	50	8	\N
1	15	50	8	\N
1	16	50	8	\N
1	17	50	8	\N
1	18	50	8	\N
1	19	50	8	\N
1	20	50	8	\N
1	21	50	8	\N
1	22	50	8	\N
1	23	50	8	\N
1	24	50	8	\N
1	25	50	1	1
1	26	50	7	\N
1	27	50	1	\N
1	28	50	1	\N
1	29	50	1	\N
1	30	50	3	3
1	31	50	3	2
1	32	50	1	9
1	33	50	2	1
1	34	50	8	\N
1	35	50	8	\N
1	36	50	8	\N
1	37	50	8	\N
1	38	50	8	\N
1	39	50	8	\N
1	40	50	7	\N
1	41	50	8	\N
1	42	50	8	\N
1	43	50	7	\N
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
1	59	50	8	\N
1	60	50	8	\N
1	1	51	2	1
1	2	51	2	1
1	3	51	2	1
1	4	51	1	1
1	5	51	2	1
1	6	51	8	\N
1	7	51	8	\N
1	8	51	8	\N
1	9	51	8	\N
1	10	51	8	\N
1	11	51	1	1
1	12	51	1	\N
1	13	51	8	\N
1	14	51	8	\N
1	15	51	8	\N
1	16	51	8	\N
1	17	51	8	\N
1	18	51	8	\N
1	19	51	8	\N
1	20	51	7	\N
1	21	51	8	\N
1	22	51	8	\N
1	23	51	8	\N
1	24	51	8	\N
1	25	51	2	1
1	26	51	1	1
1	27	51	1	\N
1	28	51	1	\N
1	29	51	1	1
1	30	51	1	1
1	31	51	4	7
1	32	51	1	\N
1	33	51	1	\N
1	34	51	1	9
1	35	51	8	\N
1	36	51	7	\N
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
1	50	51	8	\N
1	51	51	8	\N
1	52	51	8	\N
1	53	51	8	\N
1	54	51	8	\N
1	55	51	8	\N
1	56	51	3	2
1	57	51	8	\N
1	58	51	8	\N
1	59	51	8	\N
1	60	51	8	\N
1	1	52	2	1
1	2	52	6	\N
1	3	52	2	1
1	4	52	2	1
1	5	52	1	1
1	6	52	1	\N
1	7	52	8	\N
1	8	52	8	\N
1	9	52	8	\N
1	10	52	8	\N
1	11	52	8	\N
1	12	52	1	1
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
1	25	52	1	1
1	26	52	1	1
1	27	52	5	\N
1	28	52	9	\N
1	29	52	1	1
1	30	52	7	\N
1	31	52	1	\N
1	32	52	6	\N
1	33	52	1	1
1	34	52	8	\N
1	35	52	1	1
1	36	52	8	\N
1	37	52	7	\N
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
1	1	53	2	\N
1	2	53	2	\N
1	3	53	2	1
1	4	53	2	1
1	5	53	1	\N
1	6	53	1	9
1	7	53	1	1
1	8	53	8	\N
1	9	53	8	\N
1	10	53	8	\N
1	11	53	8	\N
1	12	53	8	\N
1	13	53	8	\N
1	14	53	8	\N
1	15	53	4	7
1	16	53	8	\N
1	17	53	8	\N
1	18	53	8	\N
1	19	53	8	\N
1	20	53	8	\N
1	21	53	8	\N
1	22	53	8	\N
1	23	53	8	\N
1	24	53	8	\N
1	25	53	8	\N
1	26	53	2	\N
1	27	53	1	1
1	28	53	9	\N
1	29	53	9	\N
1	30	53	9	\N
1	31	53	9	\N
1	32	53	1	1
1	33	53	1	9
1	34	53	1	9
1	35	53	1	1
1	36	53	1	1
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
1	51	53	8	\N
1	52	53	8	\N
1	53	53	8	\N
1	54	53	8	\N
1	55	53	8	\N
1	56	53	8	\N
1	57	53	8	\N
1	58	53	8	\N
1	59	53	2	1
1	60	53	8	\N
1	1	54	2	\N
1	2	54	2	\N
1	3	54	4	7
1	4	54	2	\N
1	5	54	1	9
1	6	54	1	\N
1	7	54	3	2
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
1	22	54	3	\N
1	23	54	8	\N
1	24	54	8	\N
1	25	54	8	\N
1	26	54	8	\N
1	27	54	3	\N
1	28	54	3	2
1	29	54	9	\N
1	30	54	2	1
1	31	54	1	1
1	32	54	1	\N
1	33	54	1	\N
1	34	54	1	9
1	35	54	1	9
1	36	54	8	\N
1	37	54	8	\N
1	38	54	8	\N
1	39	54	8	\N
1	40	54	8	\N
1	41	54	8	\N
1	42	54	7	\N
1	43	54	8	\N
1	44	54	8	\N
1	45	54	4	7
1	46	54	8	\N
1	47	54	8	\N
1	48	54	8	\N
1	49	54	8	\N
1	50	54	8	\N
1	51	54	8	\N
1	52	54	8	\N
1	53	54	8	\N
1	54	54	8	\N
1	55	54	8	\N
1	56	54	8	\N
1	57	54	8	\N
1	58	54	8	\N
1	59	54	8	\N
1	60	54	8	\N
1	1	55	2	\N
1	2	55	2	\N
1	3	55	7	\N
1	4	55	1	9
1	5	55	1	9
1	6	55	1	\N
1	7	55	1	1
1	8	55	6	\N
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
1	25	55	8	\N
1	26	55	8	\N
1	27	55	3	3
1	28	55	3	3
1	29	55	9	\N
1	30	55	9	\N
1	31	55	1	\N
1	32	55	1	\N
1	33	55	1	1
1	34	55	8	\N
1	35	55	1	1
1	36	55	2	\N
1	37	55	2	1
1	38	55	8	\N
1	39	55	8	\N
1	40	55	8	\N
1	41	55	7	\N
1	42	55	7	\N
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
1	58	55	8	\N
1	59	55	8	\N
1	60	55	8	\N
1	1	56	2	1
1	2	56	5	6
1	3	56	9	\N
1	4	56	9	\N
1	5	56	9	\N
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
1	27	56	5	6
1	28	56	3	\N
1	29	56	3	3
1	30	56	9	\N
1	31	56	1	1
1	32	56	1	1
1	33	56	2	1
1	34	56	1	9
1	35	56	8	\N
1	36	56	2	\N
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
1	1	57	1	1
1	2	57	1	\N
1	3	57	1	1
1	4	57	6	\N
1	5	57	9	\N
1	6	57	1	1
1	7	57	1	9
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
1	26	57	8	\N
1	27	57	8	\N
1	28	57	8	\N
1	29	57	3	2
1	30	57	9	\N
1	31	57	1	9
1	32	57	1	\N
1	33	57	1	\N
1	34	57	1	1
1	35	57	8	\N
1	36	57	8	\N
1	37	57	8	\N
1	38	57	8	\N
1	39	57	8	\N
1	40	57	8	\N
1	41	57	8	\N
1	42	57	8	\N
1	43	57	2	1
1	44	57	8	\N
1	45	57	4	7
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
1	60	57	8	\N
1	1	58	1	\N
1	2	58	7	\N
1	3	58	1	1
1	4	58	1	\N
1	5	58	1	\N
1	6	58	6	\N
1	7	58	6	\N
1	8	58	8	\N
1	9	58	8	\N
1	10	58	8	\N
1	11	58	7	\N
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
1	33	58	1	1
1	34	58	1	\N
1	35	58	8	\N
1	36	58	8	\N
1	37	58	3	2
1	38	58	8	\N
1	39	58	8	\N
1	40	58	8	\N
1	41	58	8	\N
1	42	58	8	\N
1	43	58	8	\N
1	44	58	2	\N
1	45	58	8	\N
1	46	58	8	\N
1	47	58	8	\N
1	48	58	8	\N
1	49	58	8	\N
1	50	58	7	\N
1	51	58	8	\N
1	52	58	8	\N
1	53	58	8	\N
1	54	58	8	\N
1	55	58	8	\N
1	56	58	8	\N
1	57	58	8	\N
1	58	58	8	\N
1	59	58	8	\N
1	60	58	8	\N
1	1	59	3	2
1	2	59	9	\N
1	3	59	9	\N
1	4	59	9	\N
1	5	59	1	9
1	6	59	1	9
1	7	59	6	\N
1	8	59	6	\N
1	9	59	8	\N
1	10	59	8	\N
1	11	59	8	\N
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
1	28	59	8	\N
1	29	59	8	\N
1	30	59	8	\N
1	31	59	8	\N
1	32	59	8	\N
1	33	59	4	\N
1	34	59	1	\N
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
1	60	59	8	\N
1	1	60	3	\N
1	2	60	3	2
1	3	60	9	\N
1	4	60	9	\N
1	5	60	1	\N
1	6	60	1	9
1	7	60	1	9
1	8	60	6	\N
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
1	37	60	1	9
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
1	57	60	4	\N
1	58	60	8	\N
1	59	60	3	2
1	60	60	8	\N
\.


--
-- TOC entry 5418 (class 0 OID 22808)
-- Dependencies: 297
-- Data for Name: map_tiles_map_regions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_map_regions (region_id, map_id, map_tile_x, map_tile_y) FROM stdin;
1	1	1	1
1	1	2	1
1	1	1	2
1	1	2	2
1	1	1	3
2	1	3	1
2	1	4	1
2	1	3	2
2	1	4	2
2	1	3	3
2	1	5	2
3	1	5	1
3	1	6	1
3	1	7	1
3	1	6	2
3	1	8	1
4	1	9	1
4	1	10	1
4	1	9	2
4	1	10	2
4	1	8	2
5	1	11	1
5	1	12	1
5	1	11	2
5	1	13	1
5	1	12	2
5	1	11	3
5	1	13	2
5	1	12	3
6	1	14	1
6	1	15	1
6	1	14	2
6	1	16	1
6	1	15	2
6	1	14	3
6	1	15	3
7	1	17	1
7	1	18	1
7	1	17	2
7	1	18	2
8	1	19	1
8	1	20	1
8	1	19	2
8	1	21	1
9	1	22	1
9	1	23	1
9	1	22	2
9	1	24	1
9	1	23	2
9	1	21	2
10	1	25	1
10	1	26	1
10	1	25	2
10	1	27	1
11	1	28	1
11	1	29	1
11	1	28	2
11	1	29	2
11	1	27	2
12	1	30	1
12	1	31	1
12	1	30	2
12	1	32	1
12	1	31	2
12	1	30	3
13	1	33	1
13	1	34	1
13	1	33	2
13	1	34	2
13	1	32	2
14	1	35	1
14	1	36	1
14	1	35	2
14	1	36	2
15	1	37	1
15	1	38	1
15	1	37	2
15	1	39	1
15	1	38	2
16	1	40	1
16	1	41	1
16	1	40	2
16	1	42	1
17	1	43	1
17	1	44	1
17	1	43	2
17	1	44	2
18	1	45	1
18	1	46	1
18	1	45	2
18	1	47	1
18	1	46	2
18	1	47	2
18	1	46	3
19	1	48	1
19	1	49	1
19	1	48	2
19	1	49	2
19	1	48	3
19	1	50	1
20	1	51	1
20	1	52	1
20	1	51	2
20	1	53	1
20	1	52	2
20	1	53	2
21	1	54	1
21	1	55	1
21	1	54	2
21	1	56	1
21	1	55	2
21	1	54	3
21	1	55	3
21	1	53	3
22	1	57	1
22	1	58	1
22	1	57	2
22	1	59	1
22	1	58	2
23	1	60	1
23	1	60	2
23	1	59	2
23	1	60	3
23	1	59	3
23	1	58	3
23	1	59	4
24	1	7	2
24	1	7	3
24	1	8	3
24	1	6	3
24	1	7	4
24	1	9	3
24	1	8	4
25	1	16	2
25	1	16	3
25	1	17	3
25	1	16	4
26	1	20	2
26	1	20	3
26	1	21	3
26	1	19	3
27	1	24	2
27	1	24	3
27	1	25	3
27	1	23	3
28	1	26	2
28	1	26	3
28	1	27	3
28	1	26	4
28	1	28	3
29	1	39	2
29	1	39	3
29	1	40	3
29	1	38	3
29	1	39	4
29	1	40	4
30	1	41	2
30	1	42	2
30	1	41	3
30	1	42	3
31	1	50	2
31	1	50	3
31	1	51	3
31	1	49	3
31	1	50	4
31	1	52	3
32	1	56	2
32	1	56	3
32	1	57	3
32	1	56	4
32	1	57	4
32	1	55	4
33	1	2	3
33	1	2	4
33	1	3	4
33	1	1	4
33	1	2	5
33	1	4	4
33	1	3	5
34	1	4	3
34	1	5	3
34	1	5	4
34	1	6	4
34	1	5	5
34	1	6	5
35	1	10	3
35	1	10	4
35	1	11	4
35	1	9	4
35	1	10	5
35	1	11	5
35	1	9	5
36	1	13	3
36	1	13	4
36	1	14	4
36	1	12	4
36	1	13	5
36	1	15	4
36	1	14	5
37	1	18	3
37	1	18	4
37	1	19	4
37	1	17	4
37	1	18	5
38	1	22	3
38	1	22	4
38	1	23	4
38	1	21	4
39	1	29	3
39	1	29	4
39	1	30	4
39	1	28	4
39	1	29	5
40	1	31	3
40	1	32	3
40	1	31	4
40	1	33	3
41	1	34	3
41	1	35	3
41	1	34	4
41	1	36	3
41	1	35	4
41	1	33	4
41	1	34	5
41	1	37	3
42	1	43	3
42	1	44	3
42	1	43	4
42	1	44	4
43	1	45	3
43	1	45	4
43	1	46	4
43	1	45	5
43	1	47	4
43	1	46	5
43	1	48	4
43	1	47	5
44	1	47	3
45	1	20	4
45	1	20	5
45	1	21	5
45	1	19	5
45	1	20	6
45	1	22	5
45	1	21	6
46	1	24	4
46	1	25	4
46	1	24	5
46	1	25	5
46	1	26	5
46	1	25	6
46	1	23	5
47	1	27	4
47	1	27	5
47	1	28	5
47	1	27	6
47	1	28	6
47	1	29	6
48	1	32	4
48	1	32	5
48	1	33	5
48	1	31	5
48	1	32	6
48	1	33	6
49	1	36	4
49	1	37	4
49	1	36	5
49	1	37	5
49	1	35	5
49	1	36	6
49	1	38	5
50	1	38	4
51	1	41	4
51	1	42	4
51	1	41	5
51	1	42	5
51	1	40	5
51	1	41	6
51	1	43	5
52	1	49	4
52	1	49	5
52	1	50	5
52	1	48	5
52	1	49	6
53	1	51	4
53	1	52	4
53	1	51	5
53	1	52	5
53	1	51	6
54	1	53	4
54	1	54	4
54	1	53	5
54	1	54	5
54	1	53	6
54	1	55	5
54	1	54	6
54	1	56	5
55	1	58	4
55	1	58	5
55	1	59	5
55	1	57	5
55	1	58	6
56	1	60	4
56	1	60	5
56	1	60	6
56	1	59	6
57	1	1	5
57	1	1	6
57	1	2	6
57	1	1	7
57	1	2	7
58	1	4	5
58	1	4	6
58	1	5	6
58	1	3	6
58	1	4	7
58	1	6	6
59	1	7	5
59	1	8	5
59	1	7	6
59	1	8	6
59	1	7	7
59	1	8	7
59	1	6	7
59	1	7	8
60	1	12	5
60	1	12	6
60	1	13	6
60	1	11	6
60	1	12	7
60	1	13	7
60	1	11	7
60	1	12	8
61	1	15	5
61	1	16	5
61	1	15	6
61	1	17	5
61	1	16	6
61	1	17	6
61	1	16	7
62	1	30	5
62	1	30	6
62	1	31	6
62	1	30	7
62	1	31	7
63	1	39	5
63	1	39	6
63	1	40	6
63	1	38	6
63	1	39	7
63	1	40	7
63	1	38	7
63	1	39	8
64	1	44	5
64	1	44	6
64	1	45	6
64	1	43	6
64	1	44	7
64	1	45	7
64	1	43	7
64	1	44	8
65	1	9	6
65	1	10	6
65	1	9	7
65	1	10	7
65	1	9	8
65	1	10	8
65	1	8	8
66	1	14	6
66	1	14	7
66	1	15	7
66	1	14	8
66	1	15	8
67	1	18	6
67	1	19	6
67	1	18	7
67	1	19	7
68	1	22	6
68	1	23	6
68	1	22	7
68	1	23	7
68	1	21	7
68	1	22	8
68	1	20	7
69	1	24	6
69	1	24	7
69	1	25	7
69	1	24	8
69	1	26	7
69	1	25	8
70	1	26	6
71	1	34	6
71	1	35	6
71	1	34	7
71	1	35	7
71	1	33	7
72	1	37	6
72	1	37	7
72	1	36	7
72	1	37	8
73	1	42	6
73	1	42	7
73	1	41	7
73	1	42	8
74	1	46	6
74	1	47	6
74	1	46	7
74	1	47	7
74	1	46	8
74	1	47	8
75	1	48	6
75	1	48	7
75	1	49	7
75	1	48	8
75	1	50	7
75	1	49	8
76	1	50	6
77	1	52	6
77	1	52	7
77	1	53	7
77	1	51	7
77	1	52	8
77	1	54	7
77	1	53	8
78	1	55	6
78	1	56	6
78	1	55	7
78	1	57	6
78	1	56	7
78	1	55	8
78	1	57	7
79	1	3	7
79	1	3	8
79	1	4	8
79	1	2	8
79	1	3	9
79	1	5	8
79	1	4	9
79	1	6	8
80	1	5	7
81	1	17	7
81	1	17	8
81	1	18	8
81	1	16	8
81	1	17	9
81	1	18	9
81	1	16	9
81	1	17	10
82	1	27	7
82	1	28	7
82	1	27	8
82	1	28	8
82	1	26	8
82	1	27	9
83	1	29	7
83	1	29	8
83	1	30	8
83	1	29	9
83	1	30	9
83	1	28	9
83	1	29	10
83	1	31	8
84	1	32	7
84	1	32	8
84	1	33	8
84	1	32	9
84	1	33	9
84	1	31	9
84	1	32	10
85	1	58	7
85	1	59	7
85	1	58	8
85	1	59	8
85	1	57	8
85	1	58	9
86	1	60	7
86	1	60	8
86	1	60	9
86	1	59	9
87	1	1	8
87	1	1	9
87	1	2	9
87	1	1	10
87	1	2	10
87	1	1	11
87	1	2	11
87	1	1	12
88	1	11	8
88	1	11	9
88	1	12	9
88	1	10	9
88	1	11	10
89	1	13	8
89	1	13	9
89	1	14	9
89	1	13	10
89	1	14	10
89	1	12	10
89	1	13	11
90	1	19	8
90	1	20	8
90	1	19	9
90	1	20	9
90	1	19	10
90	1	21	8
91	1	23	8
91	1	23	9
91	1	24	9
91	1	22	9
91	1	23	10
91	1	21	9
92	1	34	8
92	1	35	8
92	1	34	9
92	1	35	9
92	1	34	10
92	1	36	8
93	1	38	8
93	1	38	9
93	1	39	9
93	1	37	9
93	1	38	10
94	1	40	8
94	1	41	8
94	1	40	9
94	1	41	9
94	1	40	10
95	1	43	8
95	1	43	9
95	1	44	9
95	1	42	9
95	1	43	10
95	1	42	10
95	1	41	10
96	1	45	8
96	1	45	9
96	1	46	9
96	1	45	10
96	1	47	9
96	1	46	10
96	1	44	10
97	1	50	8
97	1	51	8
97	1	50	9
97	1	51	9
97	1	49	9
97	1	50	10
98	1	54	8
98	1	54	9
98	1	55	9
98	1	53	9
98	1	54	10
98	1	56	9
99	1	56	8
100	1	5	9
100	1	6	9
100	1	5	10
100	1	6	10
100	1	4	10
100	1	5	11
100	1	3	10
100	1	4	11
101	1	7	9
101	1	8	9
101	1	7	10
101	1	8	10
101	1	7	11
101	1	9	9
101	1	8	11
101	1	6	11
102	1	15	9
102	1	15	10
102	1	16	10
102	1	15	11
102	1	16	11
103	1	25	9
103	1	26	9
103	1	25	10
103	1	26	10
103	1	24	10
103	1	25	11
104	1	36	9
104	1	36	10
104	1	37	10
104	1	35	10
104	1	36	11
104	1	37	11
105	1	48	9
105	1	48	10
105	1	49	10
105	1	47	10
105	1	48	11
105	1	49	11
105	1	47	11
106	1	52	9
106	1	52	10
106	1	53	10
106	1	51	10
106	1	52	11
106	1	51	11
107	1	57	9
107	1	57	10
107	1	58	10
107	1	56	10
108	1	9	10
108	1	10	10
108	1	9	11
108	1	10	11
108	1	9	12
108	1	11	11
108	1	10	12
109	1	18	10
109	1	18	11
109	1	19	11
109	1	17	11
110	1	20	10
110	1	21	10
110	1	20	11
110	1	22	10
110	1	21	11
110	1	22	11
110	1	23	11
110	1	22	12
111	1	27	10
111	1	28	10
111	1	27	11
111	1	28	11
111	1	26	11
112	1	30	10
112	1	31	10
112	1	30	11
112	1	31	11
113	1	33	10
113	1	33	11
113	1	34	11
113	1	32	11
113	1	33	12
113	1	35	11
113	1	34	12
114	1	39	10
114	1	39	11
114	1	40	11
114	1	38	11
114	1	39	12
114	1	40	12
115	1	55	10
115	1	55	11
115	1	56	11
115	1	54	11
115	1	55	12
115	1	53	11
116	1	59	10
116	1	60	10
116	1	59	11
116	1	60	11
116	1	60	12
117	1	3	11
117	1	3	12
117	1	4	12
117	1	2	12
117	1	3	13
118	1	12	11
118	1	12	12
118	1	13	12
118	1	11	12
118	1	12	13
118	1	13	13
118	1	11	13
118	1	12	14
119	1	14	11
119	1	14	12
119	1	15	12
119	1	14	13
119	1	16	12
119	1	15	13
120	1	24	11
120	1	24	12
120	1	25	12
120	1	23	12
120	1	24	13
121	1	29	11
121	1	29	12
121	1	30	12
121	1	28	12
121	1	29	13
122	1	41	11
122	1	42	11
122	1	41	12
122	1	42	12
122	1	41	13
122	1	43	11
122	1	43	12
123	1	44	11
123	1	45	11
123	1	44	12
123	1	45	12
123	1	44	13
124	1	46	11
124	1	46	12
124	1	47	12
124	1	46	13
124	1	48	12
124	1	47	13
124	1	45	13
124	1	46	14
125	1	50	11
125	1	50	12
125	1	51	12
125	1	49	12
125	1	50	13
125	1	52	12
125	1	51	13
126	1	57	11
126	1	58	11
126	1	57	12
126	1	58	12
126	1	56	12
126	1	57	13
126	1	59	12
127	1	5	12
127	1	6	12
127	1	5	13
127	1	6	13
127	1	4	13
128	1	7	12
128	1	8	12
128	1	7	13
128	1	8	13
129	1	17	12
129	1	18	12
129	1	17	13
129	1	18	13
129	1	16	13
129	1	17	14
129	1	16	14
130	1	19	12
130	1	20	12
130	1	19	13
130	1	20	13
130	1	19	14
130	1	21	13
130	1	20	14
130	1	21	12
131	1	26	12
131	1	27	12
131	1	26	13
131	1	27	13
131	1	25	13
131	1	26	14
132	1	31	12
132	1	32	12
132	1	31	13
132	1	32	13
132	1	30	13
132	1	31	14
133	1	35	12
133	1	36	12
133	1	35	13
133	1	37	12
133	1	36	13
133	1	34	13
134	1	38	12
134	1	38	13
134	1	39	13
134	1	37	13
135	1	53	12
135	1	54	12
135	1	53	13
135	1	54	13
135	1	55	13
135	1	54	14
136	1	1	13
136	1	2	13
136	1	1	14
136	1	2	14
136	1	1	15
136	1	2	15
136	1	1	16
137	1	9	13
137	1	10	13
137	1	9	14
137	1	10	14
137	1	8	14
137	1	9	15
137	1	11	14
137	1	10	15
138	1	22	13
138	1	23	13
138	1	22	14
138	1	23	14
138	1	21	14
138	1	22	15
138	1	23	15
139	1	28	13
139	1	28	14
139	1	29	14
139	1	27	14
139	1	28	15
140	1	33	13
140	1	33	14
140	1	34	14
140	1	32	14
141	1	40	13
141	1	40	14
141	1	41	14
141	1	39	14
141	1	40	15
142	1	42	13
142	1	43	13
142	1	42	14
142	1	43	14
142	1	42	15
142	1	44	14
142	1	43	15
143	1	48	13
143	1	49	13
143	1	48	14
143	1	49	14
143	1	47	14
143	1	48	15
143	1	47	15
143	1	49	15
144	1	52	13
144	1	52	14
144	1	53	14
144	1	51	14
144	1	52	15
144	1	53	15
144	1	51	15
144	1	52	16
145	1	56	13
145	1	56	14
145	1	57	14
145	1	55	14
145	1	56	15
145	1	55	15
145	1	57	15
146	1	58	13
146	1	59	13
146	1	58	14
146	1	59	14
147	1	60	13
147	1	60	14
147	1	60	15
147	1	59	15
147	1	60	16
147	1	59	16
147	1	60	17
147	1	58	16
148	1	3	14
148	1	4	14
148	1	3	15
148	1	4	15
148	1	3	16
148	1	5	14
148	1	4	16
149	1	6	14
149	1	7	14
149	1	6	15
149	1	7	15
149	1	5	15
149	1	6	16
149	1	8	15
149	1	7	16
150	1	13	14
150	1	14	14
150	1	13	15
150	1	15	14
150	1	14	15
151	1	18	14
151	1	18	15
151	1	19	15
151	1	17	15
151	1	18	16
152	1	24	14
152	1	25	14
152	1	24	15
152	1	25	15
152	1	24	16
152	1	25	16
152	1	23	16
152	1	24	17
153	1	30	14
153	1	30	15
153	1	31	15
153	1	29	15
153	1	30	16
153	1	29	16
153	1	32	15
153	1	31	16
154	1	35	14
154	1	36	14
154	1	35	15
154	1	37	14
155	1	38	14
155	1	38	15
155	1	39	15
155	1	37	15
155	1	38	16
155	1	36	15
155	1	37	16
156	1	45	14
156	1	45	15
156	1	46	15
156	1	44	15
156	1	45	16
156	1	46	16
156	1	44	16
157	1	50	14
157	1	50	15
157	1	50	16
157	1	51	16
158	1	11	15
158	1	12	15
158	1	11	16
158	1	12	16
159	1	15	15
159	1	16	15
159	1	15	16
159	1	16	16
159	1	14	16
160	1	20	15
160	1	21	15
160	1	20	16
160	1	21	16
160	1	19	16
160	1	20	17
161	1	26	15
161	1	27	15
161	1	26	16
161	1	27	16
161	1	26	17
161	1	27	17
161	1	25	17
161	1	26	18
162	1	33	15
162	1	34	15
162	1	33	16
162	1	34	16
163	1	41	15
163	1	41	16
163	1	42	16
163	1	40	16
163	1	41	17
163	1	42	17
163	1	40	17
164	1	54	15
164	1	54	16
164	1	55	16
164	1	53	16
164	1	54	17
164	1	55	17
164	1	53	17
164	1	54	18
165	1	58	15
166	1	2	16
166	1	2	17
166	1	3	17
166	1	1	17
166	1	2	18
166	1	3	18
167	1	5	16
167	1	5	17
167	1	6	17
167	1	4	17
167	1	5	18
167	1	4	18
167	1	4	19
167	1	5	19
168	1	8	16
168	1	9	16
168	1	8	17
168	1	10	16
168	1	9	17
168	1	10	17
168	1	7	17
169	1	13	16
169	1	13	17
169	1	14	17
169	1	12	17
169	1	13	18
169	1	15	17
169	1	14	18
170	1	17	16
170	1	17	17
170	1	18	17
170	1	16	17
170	1	17	18
170	1	19	17
170	1	18	18
170	1	16	18
171	1	22	16
171	1	22	17
171	1	23	17
171	1	21	17
171	1	22	18
171	1	21	18
171	1	23	18
172	1	28	16
172	1	28	17
172	1	29	17
172	1	28	18
172	1	30	17
172	1	29	18
172	1	30	18
172	1	29	19
173	1	32	16
173	1	32	17
173	1	33	17
173	1	31	17
173	1	32	18
174	1	35	16
174	1	36	16
174	1	35	17
174	1	36	17
174	1	34	17
174	1	35	18
174	1	37	17
174	1	36	18
175	1	39	16
175	1	39	17
175	1	38	17
175	1	39	18
176	1	43	16
176	1	43	17
176	1	44	17
176	1	43	18
177	1	47	16
177	1	48	16
177	1	47	17
177	1	48	17
177	1	46	17
178	1	49	16
178	1	49	17
178	1	50	17
178	1	49	18
178	1	50	18
179	1	56	16
179	1	57	16
179	1	56	17
179	1	57	17
180	1	11	17
180	1	11	18
180	1	12	18
180	1	10	18
180	1	11	19
181	1	45	17
181	1	45	18
181	1	46	18
181	1	44	18
181	1	45	19
181	1	47	18
181	1	46	19
181	1	44	19
182	1	51	17
182	1	52	17
182	1	51	18
182	1	52	18
182	1	51	19
182	1	53	18
182	1	52	19
183	1	58	17
183	1	59	17
183	1	58	18
183	1	59	18
183	1	57	18
183	1	58	19
183	1	59	19
184	1	1	18
184	1	1	19
184	1	2	19
184	1	1	20
184	1	2	20
185	1	6	18
185	1	7	18
185	1	6	19
185	1	7	19
186	1	8	18
186	1	9	18
186	1	8	19
186	1	9	19
186	1	8	20
187	1	15	18
187	1	15	19
187	1	16	19
187	1	14	19
187	1	15	20
187	1	17	19
188	1	19	18
188	1	20	18
188	1	19	19
188	1	20	19
188	1	18	19
188	1	19	20
188	1	18	20
188	1	20	20
189	1	24	18
189	1	25	18
189	1	24	19
189	1	25	19
189	1	23	19
189	1	24	20
190	1	27	18
190	1	27	19
190	1	28	19
190	1	26	19
190	1	27	20
190	1	28	20
190	1	29	20
191	1	31	18
191	1	31	19
191	1	32	19
191	1	30	19
191	1	31	20
191	1	33	19
192	1	33	18
192	1	34	18
192	1	34	19
192	1	35	19
192	1	34	20
192	1	36	19
192	1	35	20
193	1	37	18
193	1	38	18
193	1	37	19
193	1	38	19
194	1	40	18
194	1	41	18
194	1	40	19
194	1	42	18
194	1	41	19
194	1	39	19
194	1	40	20
195	1	48	18
195	1	48	19
195	1	49	19
195	1	47	19
195	1	48	20
195	1	50	19
195	1	49	20
195	1	50	20
196	1	55	18
196	1	56	18
196	1	55	19
196	1	56	19
197	1	60	18
197	1	60	19
197	1	60	20
197	1	59	20
197	1	60	21
197	1	59	21
198	1	3	19
198	1	3	20
198	1	4	20
198	1	3	21
198	1	5	20
198	1	4	21
199	1	10	19
199	1	10	20
199	1	11	20
199	1	9	20
199	1	10	21
199	1	11	21
199	1	9	21
200	1	12	19
200	1	13	19
200	1	12	20
200	1	13	20
200	1	14	20
200	1	13	21
200	1	12	21
200	1	14	21
201	1	21	19
201	1	22	19
201	1	21	20
201	1	22	20
202	1	42	19
202	1	43	19
202	1	42	20
202	1	43	20
202	1	41	20
202	1	42	21
203	1	53	19
203	1	54	19
203	1	53	20
203	1	54	20
203	1	52	20
203	1	53	21
203	1	55	20
203	1	54	21
204	1	57	19
204	1	57	20
204	1	58	20
204	1	56	20
204	1	57	21
205	1	6	20
205	1	7	20
205	1	6	21
205	1	7	21
205	1	5	21
205	1	6	22
205	1	8	21
206	1	16	20
206	1	17	20
206	1	16	21
206	1	17	21
206	1	15	21
206	1	16	22
206	1	18	21
206	1	17	22
207	1	23	20
207	1	23	21
207	1	24	21
207	1	22	21
207	1	23	22
207	1	21	21
207	1	22	22
207	1	25	21
208	1	25	20
208	1	26	20
208	1	26	21
208	1	27	21
208	1	26	22
208	1	28	21
208	1	27	22
208	1	28	22
209	1	30	20
209	1	30	21
209	1	31	21
209	1	29	21
209	1	30	22
209	1	31	22
209	1	29	22
209	1	30	23
210	1	32	20
210	1	33	20
210	1	32	21
210	1	33	21
210	1	32	22
210	1	33	22
211	1	36	20
211	1	37	20
211	1	36	21
211	1	37	21
212	1	38	20
212	1	39	20
212	1	38	21
212	1	39	21
212	1	38	22
212	1	40	21
212	1	39	22
212	1	37	22
213	1	44	20
213	1	45	20
213	1	44	21
213	1	46	20
213	1	45	21
214	1	47	20
214	1	47	21
214	1	48	21
214	1	46	21
214	1	47	22
214	1	49	21
215	1	51	20
215	1	51	21
215	1	52	21
215	1	50	21
216	1	1	21
216	1	2	21
216	1	1	22
216	1	2	22
216	1	1	23
216	1	2	23
216	1	1	24
217	1	19	21
217	1	20	21
217	1	19	22
217	1	20	22
217	1	18	22
218	1	34	21
218	1	35	21
218	1	34	22
218	1	35	22
218	1	34	23
218	1	36	22
218	1	35	23
218	1	36	23
219	1	41	21
219	1	41	22
219	1	42	22
219	1	40	22
220	1	43	21
220	1	43	22
220	1	44	22
220	1	43	23
220	1	44	23
220	1	42	23
221	1	55	21
221	1	56	21
221	1	55	22
221	1	56	22
221	1	54	22
222	1	58	21
222	1	58	22
222	1	59	22
222	1	57	22
222	1	58	23
222	1	59	23
222	1	57	23
223	1	3	22
223	1	4	22
223	1	3	23
223	1	5	22
223	1	4	23
223	1	3	24
223	1	4	24
223	1	2	24
224	1	7	22
224	1	8	22
224	1	7	23
224	1	9	22
224	1	8	23
224	1	6	23
225	1	10	22
225	1	11	22
225	1	10	23
225	1	12	22
225	1	11	23
225	1	9	23
225	1	10	24
226	1	13	22
226	1	14	22
226	1	13	23
226	1	15	22
226	1	14	23
226	1	15	23
226	1	12	23
226	1	13	24
227	1	21	22
227	1	21	23
227	1	22	23
227	1	20	23
227	1	21	24
227	1	19	23
228	1	24	22
228	1	25	22
228	1	24	23
228	1	25	23
228	1	26	23
228	1	25	24
228	1	23	23
228	1	24	24
229	1	45	22
229	1	46	22
229	1	45	23
229	1	46	23
229	1	45	24
229	1	47	23
229	1	46	24
230	1	48	22
230	1	49	22
230	1	48	23
230	1	49	23
230	1	48	24
230	1	49	24
230	1	47	24
230	1	48	25
231	1	50	22
231	1	51	22
231	1	50	23
231	1	52	22
231	1	51	23
232	1	53	22
232	1	53	23
232	1	54	23
232	1	52	23
232	1	53	24
232	1	52	24
232	1	55	23
232	1	54	24
233	1	60	22
233	1	60	23
233	1	60	24
233	1	59	24
233	1	60	25
233	1	58	24
233	1	59	25
233	1	60	26
234	1	5	23
234	1	5	24
234	1	6	24
234	1	5	25
235	1	16	23
235	1	17	23
235	1	16	24
235	1	18	23
235	1	17	24
235	1	18	24
236	1	27	23
236	1	28	23
236	1	27	24
236	1	28	24
236	1	26	24
236	1	27	25
236	1	26	25
237	1	29	23
237	1	29	24
237	1	30	24
237	1	29	25
237	1	31	24
237	1	30	25
237	1	31	25
238	1	31	23
238	1	32	23
238	1	33	23
238	1	32	24
238	1	33	24
238	1	32	25
238	1	34	24
239	1	37	23
239	1	38	23
239	1	37	24
239	1	39	23
239	1	38	24
239	1	40	23
239	1	39	24
240	1	41	23
240	1	41	24
240	1	42	24
240	1	40	24
240	1	41	25
240	1	40	25
241	1	56	23
241	1	56	24
241	1	57	24
241	1	55	24
241	1	56	25
241	1	57	25
242	1	7	24
242	1	8	24
242	1	7	25
242	1	9	24
242	1	8	25
243	1	11	24
243	1	12	24
243	1	11	25
243	1	12	25
243	1	10	25
243	1	11	26
244	1	14	24
244	1	15	24
244	1	14	25
244	1	15	25
245	1	19	24
245	1	20	24
245	1	19	25
245	1	20	25
245	1	21	25
246	1	22	24
246	1	23	24
246	1	22	25
246	1	23	25
247	1	35	24
247	1	36	24
247	1	35	25
247	1	36	25
247	1	37	25
247	1	36	26
247	1	34	25
248	1	43	24
248	1	44	24
248	1	43	25
248	1	44	25
249	1	50	24
249	1	51	24
249	1	50	25
249	1	51	25
249	1	52	25
250	1	1	25
250	1	2	25
250	1	1	26
250	1	2	26
250	1	1	27
250	1	2	27
250	1	1	28
251	1	3	25
251	1	4	25
251	1	3	26
251	1	4	26
252	1	6	25
252	1	6	26
252	1	7	26
252	1	5	26
252	1	6	27
253	1	9	25
253	1	9	26
253	1	10	26
253	1	8	26
254	1	13	25
254	1	13	26
254	1	14	26
254	1	12	26
255	1	16	25
255	1	17	25
255	1	16	26
255	1	18	25
255	1	17	26
255	1	18	26
255	1	17	27
256	1	24	25
256	1	25	25
256	1	24	26
256	1	25	26
256	1	23	26
256	1	24	27
256	1	26	26
257	1	28	25
257	1	28	26
257	1	29	26
257	1	27	26
258	1	33	25
258	1	33	26
258	1	34	26
258	1	32	26
258	1	33	27
258	1	34	27
259	1	38	25
259	1	39	25
259	1	38	26
259	1	39	26
259	1	37	26
259	1	38	27
259	1	39	27
260	1	42	25
260	1	42	26
260	1	43	26
260	1	41	26
260	1	42	27
260	1	44	26
260	1	43	27
261	1	45	25
261	1	46	25
261	1	45	26
261	1	46	26
261	1	45	27
261	1	47	26
262	1	47	25
263	1	49	25
263	1	49	26
263	1	50	26
263	1	48	26
263	1	49	27
263	1	48	27
264	1	53	25
264	1	54	25
264	1	53	26
264	1	54	26
264	1	52	26
264	1	53	27
265	1	55	25
265	1	55	26
265	1	56	26
265	1	55	27
265	1	57	26
265	1	56	27
265	1	54	27
266	1	58	25
266	1	58	26
266	1	59	26
266	1	58	27
266	1	59	27
267	1	15	26
267	1	15	27
267	1	16	27
267	1	14	27
267	1	15	28
268	1	19	26
268	1	20	26
268	1	19	27
268	1	20	27
268	1	18	27
268	1	19	28
268	1	21	27
269	1	21	26
269	1	22	26
269	1	22	27
269	1	23	27
269	1	22	28
269	1	23	28
269	1	24	28
269	1	23	29
270	1	30	26
270	1	31	26
270	1	30	27
270	1	31	27
270	1	29	27
270	1	30	28
271	1	35	26
271	1	35	27
271	1	36	27
271	1	35	28
271	1	37	27
271	1	36	28
271	1	34	28
271	1	35	29
272	1	40	26
272	1	40	27
272	1	41	27
272	1	40	28
272	1	41	28
273	1	51	26
273	1	51	27
273	1	52	27
273	1	50	27
273	1	51	28
273	1	52	28
274	1	3	27
274	1	4	27
274	1	3	28
274	1	4	28
274	1	2	28
275	1	5	27
275	1	5	28
275	1	6	28
275	1	5	29
275	1	7	28
276	1	7	27
276	1	8	27
276	1	9	27
276	1	8	28
276	1	10	27
277	1	11	27
277	1	12	27
277	1	11	28
277	1	13	27
277	1	12	28
277	1	13	28
277	1	12	29
278	1	25	27
278	1	26	27
278	1	25	28
278	1	27	27
279	1	28	27
279	1	28	28
279	1	29	28
279	1	27	28
279	1	28	29
279	1	29	29
279	1	27	29
280	1	32	27
280	1	32	28
280	1	33	28
280	1	31	28
280	1	32	29
280	1	33	29
280	1	34	29
281	1	44	27
281	1	44	28
281	1	45	28
281	1	43	28
281	1	44	29
281	1	42	28
281	1	43	29
282	1	46	27
282	1	47	27
282	1	46	28
282	1	47	28
282	1	48	28
282	1	47	29
282	1	46	29
282	1	48	29
283	1	57	27
283	1	57	28
283	1	58	28
283	1	56	28
283	1	57	29
283	1	59	28
283	1	58	29
283	1	60	28
284	1	60	27
285	1	9	28
285	1	10	28
285	1	9	29
285	1	10	29
285	1	11	29
285	1	10	30
286	1	14	28
286	1	14	29
286	1	15	29
286	1	13	29
286	1	14	30
287	1	16	28
287	1	17	28
287	1	16	29
287	1	18	28
288	1	20	28
288	1	21	28
288	1	20	29
288	1	21	29
288	1	19	29
289	1	26	28
289	1	26	29
289	1	25	29
289	1	26	30
289	1	27	30
290	1	37	28
290	1	38	28
290	1	37	29
290	1	38	29
290	1	36	29
290	1	37	30
290	1	39	29
291	1	39	28
292	1	49	28
292	1	50	28
292	1	49	29
292	1	50	29
293	1	53	28
293	1	54	28
293	1	53	29
293	1	55	28
293	1	54	29
293	1	52	29
293	1	53	30
293	1	55	29
294	1	1	29
294	1	2	29
294	1	1	30
294	1	2	30
294	1	1	31
295	1	3	29
295	1	4	29
295	1	3	30
295	1	4	30
295	1	3	31
295	1	4	31
295	1	2	31
295	1	3	32
296	1	6	29
296	1	7	29
296	1	6	30
296	1	7	30
296	1	5	30
296	1	6	31
296	1	8	30
296	1	7	31
297	1	8	29
298	1	17	29
298	1	18	29
298	1	17	30
298	1	18	30
298	1	16	30
298	1	17	31
298	1	18	31
299	1	22	29
299	1	22	30
299	1	23	30
299	1	21	30
299	1	22	31
299	1	23	31
299	1	21	31
300	1	24	29
300	1	24	30
300	1	25	30
300	1	24	31
301	1	30	29
301	1	31	29
301	1	30	30
301	1	31	30
301	1	32	30
301	1	31	31
302	1	40	29
302	1	41	29
302	1	40	30
302	1	42	29
302	1	41	30
302	1	42	30
302	1	39	30
303	1	45	29
303	1	45	30
303	1	46	30
303	1	44	30
303	1	45	31
304	1	51	29
304	1	51	30
304	1	52	30
304	1	50	30
304	1	51	31
304	1	52	31
304	1	50	31
304	1	51	32
305	1	56	29
305	1	56	30
305	1	57	30
305	1	55	30
305	1	56	31
305	1	58	30
306	1	59	29
306	1	60	29
306	1	59	30
306	1	60	30
307	1	9	30
307	1	9	31
307	1	10	31
307	1	8	31
308	1	11	30
308	1	12	30
308	1	11	31
308	1	12	31
309	1	13	30
309	1	13	31
309	1	14	31
309	1	13	32
309	1	15	31
310	1	15	30
311	1	19	30
311	1	20	30
311	1	19	31
311	1	20	31
311	1	20	32
311	1	19	32
311	1	21	32
311	1	20	33
312	1	28	30
312	1	29	30
312	1	28	31
312	1	29	31
312	1	30	31
312	1	29	32
312	1	27	31
312	1	28	32
313	1	33	30
313	1	34	30
313	1	33	31
313	1	34	31
314	1	35	30
314	1	36	30
314	1	35	31
314	1	36	31
314	1	35	32
315	1	38	30
315	1	38	31
315	1	39	31
315	1	37	31
316	1	43	30
316	1	43	31
316	1	44	31
316	1	42	31
317	1	47	30
317	1	48	30
317	1	47	31
317	1	49	30
318	1	54	30
318	1	54	31
318	1	55	31
318	1	53	31
318	1	54	32
318	1	53	32
318	1	55	32
318	1	54	33
319	1	5	31
319	1	5	32
319	1	6	32
319	1	4	32
319	1	5	33
319	1	4	33
320	1	16	31
320	1	16	32
320	1	17	32
320	1	15	32
320	1	16	33
321	1	25	31
321	1	26	31
321	1	25	32
321	1	26	32
321	1	24	32
322	1	32	31
322	1	32	32
322	1	33	32
322	1	31	32
322	1	32	33
322	1	34	32
323	1	40	31
323	1	41	31
323	1	40	32
323	1	41	32
323	1	39	32
323	1	40	33
323	1	42	32
324	1	46	31
324	1	46	32
324	1	47	32
324	1	45	32
324	1	46	33
324	1	44	32
324	1	45	33
324	1	48	32
325	1	48	31
325	1	49	31
325	1	49	32
325	1	50	32
326	1	57	31
326	1	58	31
326	1	57	32
326	1	58	32
326	1	56	32
326	1	57	33
326	1	58	33
327	1	59	31
327	1	60	31
327	1	59	32
327	1	60	32
327	1	59	33
327	1	60	33
327	1	60	34
328	1	1	32
328	1	2	32
328	1	1	33
328	1	2	33
328	1	1	34
328	1	3	33
329	1	7	32
329	1	8	32
329	1	7	33
329	1	9	32
329	1	8	33
329	1	6	33
329	1	7	34
329	1	8	34
330	1	10	32
330	1	11	32
330	1	10	33
330	1	11	33
330	1	9	33
330	1	10	34
330	1	12	32
331	1	14	32
331	1	14	33
331	1	15	33
331	1	13	33
331	1	14	34
331	1	15	34
331	1	12	33
332	1	18	32
332	1	18	33
332	1	19	33
332	1	17	33
333	1	22	32
333	1	23	32
333	1	22	33
333	1	23	33
333	1	21	33
334	1	27	32
334	1	27	33
334	1	28	33
334	1	26	33
334	1	27	34
334	1	28	34
334	1	26	34
334	1	27	35
335	1	30	32
335	1	30	33
335	1	31	33
335	1	29	33
335	1	30	34
335	1	31	34
336	1	36	32
336	1	37	32
336	1	36	33
336	1	38	32
336	1	37	33
336	1	38	33
336	1	37	34
337	1	43	32
337	1	43	33
337	1	44	33
337	1	42	33
338	1	52	32
338	1	52	33
338	1	53	33
338	1	51	33
338	1	52	34
338	1	53	34
339	1	24	33
339	1	25	33
339	1	24	34
339	1	25	34
340	1	33	33
340	1	34	33
340	1	33	34
340	1	35	33
341	1	39	33
341	1	39	34
341	1	40	34
341	1	38	34
341	1	39	35
341	1	41	34
342	1	41	33
343	1	47	33
343	1	48	33
343	1	47	34
343	1	48	34
343	1	46	34
343	1	47	35
343	1	49	33
344	1	50	33
344	1	50	34
344	1	51	34
344	1	49	34
344	1	50	35
344	1	49	35
345	1	55	33
345	1	56	33
345	1	55	34
345	1	56	34
345	1	54	34
345	1	55	35
345	1	56	35
345	1	54	35
346	1	2	34
346	1	3	34
346	1	2	35
346	1	4	34
347	1	5	34
347	1	6	34
347	1	5	35
347	1	6	35
347	1	7	35
347	1	6	36
347	1	4	35
348	1	9	34
348	1	9	35
348	1	10	35
348	1	8	35
348	1	9	36
348	1	8	36
348	1	11	35
349	1	11	34
349	1	12	34
349	1	13	34
349	1	12	35
350	1	16	34
350	1	17	34
350	1	16	35
350	1	18	34
350	1	17	35
350	1	19	34
351	1	20	34
351	1	21	34
351	1	20	35
351	1	22	34
352	1	23	34
352	1	23	35
352	1	24	35
352	1	22	35
352	1	23	36
352	1	24	36
352	1	22	36
353	1	29	34
353	1	29	35
353	1	30	35
353	1	28	35
353	1	29	36
354	1	32	34
354	1	32	35
354	1	33	35
354	1	31	35
354	1	32	36
354	1	31	36
354	1	34	35
355	1	34	34
355	1	35	34
355	1	36	34
355	1	35	35
355	1	36	35
356	1	42	34
356	1	43	34
356	1	42	35
356	1	43	35
356	1	41	35
356	1	42	36
356	1	43	36
356	1	41	36
357	1	44	34
357	1	45	34
357	1	44	35
357	1	45	35
357	1	44	36
357	1	45	36
357	1	44	37
358	1	57	34
358	1	58	34
358	1	57	35
358	1	59	34
359	1	1	35
359	1	1	36
359	1	2	36
359	1	1	37
360	1	3	35
360	1	3	36
360	1	4	36
360	1	3	37
360	1	4	37
360	1	2	37
360	1	3	38
361	1	13	35
361	1	14	35
361	1	13	36
361	1	14	36
361	1	12	36
361	1	13	37
362	1	15	35
362	1	15	36
362	1	16	36
362	1	15	37
362	1	16	37
362	1	14	37
363	1	18	35
363	1	19	35
363	1	18	36
363	1	19	36
363	1	17	36
364	1	21	35
364	1	21	36
364	1	20	36
364	1	21	37
364	1	22	37
364	1	20	37
364	1	21	38
364	1	23	37
365	1	25	35
365	1	26	35
365	1	25	36
365	1	26	36
365	1	25	37
366	1	37	35
366	1	38	35
366	1	37	36
366	1	38	36
366	1	39	36
367	1	40	35
367	1	40	36
367	1	40	37
367	1	41	37
367	1	39	37
367	1	40	38
367	1	41	38
367	1	39	38
368	1	46	35
368	1	46	36
368	1	47	36
368	1	46	37
368	1	47	37
368	1	45	37
368	1	46	38
369	1	48	35
369	1	48	36
369	1	49	36
369	1	48	37
369	1	49	37
369	1	48	38
369	1	50	36
370	1	51	35
370	1	52	35
370	1	51	36
370	1	53	35
371	1	58	35
371	1	59	35
371	1	58	36
371	1	60	35
371	1	59	36
371	1	60	36
371	1	60	37
372	1	5	36
372	1	5	37
372	1	6	37
372	1	5	38
372	1	6	38
373	1	7	36
373	1	7	37
373	1	8	37
373	1	7	38
373	1	9	37
373	1	8	38
373	1	9	38
374	1	10	36
374	1	11	36
374	1	10	37
374	1	11	37
375	1	27	36
375	1	28	36
375	1	27	37
375	1	28	37
375	1	26	37
375	1	27	38
375	1	28	38
375	1	26	38
376	1	30	36
376	1	30	37
376	1	31	37
376	1	29	37
376	1	30	38
376	1	32	37
377	1	33	36
377	1	34	36
377	1	33	37
377	1	35	36
377	1	34	37
377	1	35	37
377	1	34	38
377	1	33	38
378	1	36	36
378	1	36	37
378	1	37	37
378	1	36	38
378	1	38	37
378	1	37	38
378	1	38	38
378	1	37	39
379	1	52	36
379	1	53	36
379	1	52	37
379	1	54	36
379	1	53	37
379	1	54	37
380	1	55	36
380	1	56	36
380	1	55	37
380	1	56	37
380	1	55	38
380	1	56	38
380	1	54	38
380	1	55	39
381	1	57	36
381	1	57	37
381	1	58	37
381	1	57	38
381	1	58	38
382	1	12	37
382	1	12	38
382	1	13	38
382	1	11	38
383	1	17	37
383	1	18	37
383	1	17	38
383	1	19	37
383	1	18	38
384	1	24	37
384	1	24	38
384	1	25	38
384	1	23	38
384	1	24	39
384	1	22	38
384	1	23	39
384	1	22	39
385	1	42	37
385	1	43	37
385	1	42	38
385	1	43	38
385	1	44	38
386	1	50	37
386	1	51	37
386	1	50	38
386	1	51	38
386	1	52	38
386	1	51	39
387	1	59	37
387	1	59	38
387	1	60	38
387	1	59	39
388	1	1	38
388	1	2	38
388	1	1	39
388	1	2	39
389	1	4	38
389	1	4	39
389	1	5	39
389	1	3	39
389	1	4	40
389	1	3	40
390	1	10	38
390	1	10	39
390	1	11	39
390	1	9	39
390	1	10	40
390	1	8	39
390	1	9	40
391	1	14	38
391	1	15	38
391	1	14	39
391	1	15	39
391	1	13	39
392	1	16	38
392	1	16	39
392	1	17	39
392	1	16	40
392	1	17	40
393	1	19	38
393	1	20	38
393	1	19	39
393	1	20	39
394	1	29	38
394	1	29	39
394	1	30	39
394	1	28	39
395	1	31	38
395	1	32	38
395	1	31	39
395	1	32	39
395	1	31	40
395	1	32	40
395	1	30	40
395	1	31	41
396	1	35	38
396	1	35	39
396	1	36	39
396	1	34	39
396	1	35	40
396	1	36	40
396	1	33	39
397	1	45	38
397	1	45	39
397	1	46	39
397	1	44	39
397	1	45	40
398	1	47	38
398	1	47	39
398	1	48	39
398	1	47	40
398	1	48	40
398	1	46	40
399	1	49	38
399	1	49	39
399	1	50	39
399	1	49	40
400	1	53	38
400	1	53	39
400	1	54	39
400	1	52	39
400	1	53	40
400	1	54	40
400	1	52	40
401	1	6	39
401	1	7	39
401	1	6	40
401	1	7	40
401	1	8	40
401	1	7	41
402	1	12	39
402	1	12	40
402	1	13	40
402	1	11	40
403	1	18	39
403	1	18	40
403	1	19	40
403	1	18	41
403	1	19	41
403	1	17	41
403	1	18	42
404	1	21	39
404	1	21	40
404	1	22	40
404	1	20	40
404	1	21	41
405	1	25	39
405	1	26	39
405	1	25	40
405	1	27	39
405	1	26	40
405	1	27	40
406	1	38	39
406	1	39	39
406	1	38	40
406	1	40	39
406	1	39	40
407	1	41	39
407	1	42	39
407	1	41	40
407	1	42	40
407	1	40	40
408	1	43	39
408	1	43	40
408	1	44	40
408	1	43	41
408	1	44	41
408	1	42	41
408	1	43	42
408	1	44	42
409	1	56	39
409	1	57	39
409	1	56	40
409	1	58	39
410	1	60	39
410	1	60	40
410	1	59	40
410	1	60	41
410	1	59	41
411	1	1	40
411	1	2	40
411	1	1	41
411	1	2	41
411	1	1	42
411	1	3	41
411	1	2	42
411	1	1	43
412	1	5	40
412	1	5	41
412	1	6	41
412	1	4	41
412	1	5	42
412	1	4	42
413	1	14	40
413	1	15	40
413	1	14	41
413	1	15	41
413	1	16	41
413	1	15	42
414	1	23	40
414	1	24	40
414	1	23	41
414	1	24	41
414	1	22	41
414	1	23	42
414	1	25	41
414	1	24	42
415	1	28	40
415	1	29	40
415	1	28	41
415	1	29	41
416	1	33	40
416	1	34	40
416	1	33	41
416	1	34	41
416	1	32	41
416	1	33	42
416	1	35	41
416	1	34	42
417	1	37	40
417	1	37	41
417	1	38	41
417	1	36	41
417	1	37	42
417	1	36	42
417	1	35	42
418	1	50	40
418	1	51	40
418	1	50	41
418	1	51	41
418	1	49	41
418	1	50	42
418	1	52	41
419	1	55	40
419	1	55	41
419	1	56	41
419	1	54	41
419	1	55	42
420	1	57	40
420	1	58	40
420	1	57	41
420	1	58	41
420	1	57	42
420	1	58	42
421	1	8	41
421	1	9	41
421	1	8	42
421	1	10	41
421	1	9	42
421	1	11	41
422	1	12	41
422	1	13	41
422	1	12	42
422	1	13	42
422	1	11	42
422	1	12	43
423	1	20	41
423	1	20	42
423	1	21	42
423	1	19	42
423	1	20	43
423	1	19	43
423	1	18	43
424	1	26	41
424	1	27	41
424	1	26	42
424	1	27	42
424	1	25	42
425	1	30	41
425	1	30	42
425	1	31	42
425	1	29	42
426	1	39	41
426	1	40	41
426	1	39	42
426	1	41	41
426	1	40	42
427	1	45	41
427	1	46	41
427	1	45	42
427	1	46	42
427	1	45	43
427	1	47	41
427	1	47	42
428	1	48	41
428	1	48	42
428	1	49	42
428	1	48	43
428	1	49	43
428	1	47	43
429	1	53	41
429	1	53	42
429	1	54	42
429	1	52	42
429	1	53	43
429	1	54	43
429	1	52	43
429	1	53	44
430	1	3	42
430	1	3	43
430	1	4	43
430	1	2	43
430	1	3	44
431	1	6	42
431	1	7	42
431	1	6	43
431	1	7	43
431	1	5	43
431	1	6	44
431	1	7	44
431	1	5	44
432	1	10	42
432	1	10	43
432	1	11	43
432	1	9	43
432	1	10	44
432	1	11	44
432	1	9	44
432	1	10	45
433	1	14	42
433	1	14	43
433	1	15	43
433	1	13	43
433	1	14	44
434	1	16	42
434	1	17	42
434	1	16	43
434	1	17	43
434	1	16	44
434	1	17	44
435	1	22	42
435	1	22	43
435	1	23	43
435	1	21	43
435	1	22	44
436	1	28	42
436	1	28	43
436	1	29	43
436	1	27	43
436	1	28	44
436	1	29	44
437	1	32	42
437	1	32	43
437	1	33	43
437	1	31	43
437	1	32	44
437	1	30	43
437	1	31	44
437	1	34	43
438	1	38	42
438	1	38	43
438	1	39	43
438	1	37	43
438	1	38	44
438	1	40	43
439	1	41	42
439	1	42	42
439	1	41	43
439	1	42	43
439	1	41	44
439	1	42	44
439	1	40	44
440	1	51	42
440	1	51	43
440	1	50	43
440	1	51	44
441	1	56	42
441	1	56	43
441	1	57	43
441	1	55	43
441	1	56	44
441	1	55	44
441	1	54	44
441	1	55	45
442	1	59	42
442	1	60	42
442	1	59	43
442	1	60	43
442	1	58	43
442	1	59	44
442	1	60	44
443	1	8	43
443	1	8	44
443	1	8	45
443	1	9	45
444	1	24	43
444	1	25	43
444	1	24	44
444	1	25	44
444	1	23	44
445	1	26	43
445	1	26	44
445	1	27	44
445	1	26	45
445	1	27	45
445	1	25	45
445	1	26	46
446	1	35	43
446	1	36	43
446	1	35	44
446	1	36	44
446	1	34	44
446	1	35	45
447	1	43	43
447	1	44	43
447	1	43	44
447	1	44	44
448	1	46	43
448	1	46	44
448	1	47	44
448	1	45	44
448	1	46	45
448	1	45	45
448	1	44	45
449	1	1	44
449	1	2	44
449	1	1	45
449	1	2	45
449	1	1	46
449	1	3	45
449	1	2	46
449	1	1	47
450	1	4	44
450	1	4	45
450	1	5	45
450	1	4	46
450	1	6	45
451	1	12	44
451	1	13	44
451	1	12	45
451	1	13	45
451	1	14	45
451	1	13	46
451	1	15	45
451	1	14	46
452	1	15	44
453	1	18	44
453	1	19	44
453	1	18	45
453	1	20	44
453	1	19	45
453	1	21	44
453	1	20	45
453	1	19	46
454	1	30	44
454	1	30	45
454	1	31	45
454	1	29	45
454	1	30	46
454	1	32	45
454	1	31	46
454	1	32	46
455	1	33	44
455	1	33	45
455	1	34	45
455	1	33	46
455	1	34	46
455	1	33	47
455	1	34	47
455	1	32	47
456	1	37	44
456	1	37	45
456	1	38	45
456	1	36	45
457	1	39	44
457	1	39	45
457	1	40	45
457	1	39	46
457	1	40	46
457	1	38	46
458	1	48	44
458	1	49	44
458	1	48	45
458	1	49	45
458	1	47	45
458	1	48	46
458	1	50	45
459	1	50	44
460	1	52	44
460	1	52	45
460	1	53	45
460	1	51	45
460	1	52	46
460	1	53	46
460	1	51	46
460	1	52	47
461	1	57	44
461	1	58	44
461	1	57	45
461	1	58	45
461	1	56	45
461	1	57	46
461	1	59	45
461	1	58	46
462	1	7	45
462	1	7	46
462	1	8	46
462	1	6	46
462	1	7	47
462	1	5	46
463	1	11	45
463	1	11	46
463	1	12	46
463	1	10	46
463	1	11	47
463	1	12	47
464	1	16	45
464	1	17	45
464	1	16	46
464	1	17	46
464	1	18	46
464	1	17	47
464	1	18	47
464	1	15	46
465	1	21	45
465	1	22	45
465	1	21	46
465	1	23	45
466	1	24	45
466	1	24	46
466	1	25	46
466	1	23	46
467	1	28	45
467	1	28	46
467	1	29	46
467	1	27	46
467	1	28	47
467	1	29	47
468	1	41	45
468	1	42	45
468	1	41	46
468	1	43	45
468	1	42	46
468	1	43	46
469	1	54	45
469	1	54	46
469	1	55	46
469	1	54	47
470	1	60	45
470	1	60	46
470	1	59	46
470	1	60	47
470	1	59	47
470	1	60	48
471	1	3	46
471	1	3	47
471	1	4	47
471	1	2	47
472	1	9	46
472	1	9	47
472	1	10	47
472	1	8	47
473	1	20	46
473	1	20	47
473	1	21	47
473	1	19	47
473	1	20	48
473	1	21	48
473	1	19	48
473	1	20	49
474	1	22	46
474	1	22	47
474	1	23	47
474	1	22	48
474	1	24	47
474	1	23	48
474	1	22	49
475	1	35	46
475	1	36	46
475	1	35	47
475	1	37	46
475	1	36	47
475	1	37	47
476	1	44	46
476	1	45	46
476	1	44	47
476	1	46	46
476	1	45	47
477	1	47	46
477	1	47	47
477	1	48	47
477	1	46	47
478	1	49	46
478	1	50	46
478	1	49	47
478	1	50	47
478	1	49	48
478	1	50	48
478	1	48	48
478	1	49	49
479	1	56	46
479	1	56	47
479	1	57	47
479	1	55	47
479	1	56	48
479	1	55	48
479	1	57	48
479	1	56	49
480	1	5	47
480	1	6	47
480	1	5	48
480	1	6	48
480	1	4	48
480	1	5	49
481	1	13	47
481	1	14	47
481	1	13	48
481	1	15	47
481	1	14	48
481	1	15	48
482	1	16	47
482	1	16	48
482	1	17	48
482	1	16	49
482	1	18	48
482	1	17	49
483	1	25	47
483	1	26	47
483	1	25	48
483	1	27	47
483	1	26	48
483	1	27	48
484	1	30	47
484	1	31	47
484	1	30	48
484	1	31	48
484	1	29	48
484	1	30	49
484	1	32	48
485	1	38	47
485	1	39	47
485	1	38	48
485	1	39	48
485	1	37	48
486	1	40	47
486	1	41	47
486	1	40	48
486	1	41	48
486	1	40	49
487	1	42	47
487	1	43	47
487	1	42	48
487	1	43	48
487	1	42	49
487	1	44	48
487	1	43	49
488	1	51	47
488	1	51	48
488	1	52	48
488	1	51	49
489	1	53	47
489	1	53	48
489	1	54	48
489	1	53	49
489	1	54	49
489	1	52	49
489	1	53	50
489	1	54	50
490	1	58	47
490	1	58	48
490	1	59	48
490	1	58	49
490	1	59	49
491	1	1	48
491	1	2	48
491	1	1	49
491	1	2	49
492	1	3	48
492	1	3	49
492	1	4	49
492	1	3	50
493	1	7	48
493	1	8	48
493	1	7	49
493	1	8	49
493	1	6	49
493	1	7	50
494	1	9	48
494	1	10	48
494	1	9	49
494	1	10	49
495	1	11	48
495	1	12	48
495	1	11	49
495	1	12	49
495	1	11	50
495	1	13	49
495	1	12	50
496	1	24	48
496	1	24	49
496	1	25	49
496	1	23	49
496	1	24	50
496	1	25	50
496	1	23	50
497	1	28	48
497	1	28	49
497	1	29	49
497	1	27	49
497	1	28	50
497	1	29	50
497	1	27	50
497	1	28	51
498	1	33	48
498	1	34	48
498	1	33	49
498	1	35	48
498	1	34	49
499	1	36	48
499	1	36	49
499	1	37	49
499	1	35	49
499	1	36	50
500	1	45	48
500	1	46	48
500	1	45	49
500	1	47	48
500	1	46	49
501	1	14	49
501	1	15	49
501	1	14	50
501	1	15	50
501	1	13	50
501	1	14	51
501	1	15	51
502	1	18	49
502	1	19	49
502	1	18	50
502	1	19	50
502	1	17	50
502	1	18	51
502	1	20	50
502	1	19	51
503	1	21	49
503	1	21	50
503	1	22	50
503	1	21	51
503	1	22	51
503	1	20	51
503	1	21	52
503	1	22	52
504	1	26	49
504	1	26	50
504	1	26	51
504	1	27	51
504	1	25	51
505	1	31	49
505	1	32	49
505	1	31	50
505	1	32	50
506	1	38	49
506	1	39	49
506	1	38	50
506	1	39	50
507	1	41	49
507	1	41	50
507	1	42	50
507	1	40	50
507	1	41	51
507	1	43	50
507	1	42	51
507	1	43	51
508	1	44	49
508	1	44	50
508	1	45	50
508	1	44	51
508	1	46	50
509	1	47	49
509	1	48	49
509	1	47	50
509	1	48	50
509	1	47	51
509	1	49	50
510	1	50	49
510	1	50	50
510	1	51	50
510	1	50	51
511	1	55	49
511	1	55	50
511	1	56	50
511	1	55	51
511	1	56	51
511	1	54	51
512	1	57	49
512	1	57	50
512	1	58	50
512	1	57	51
512	1	58	51
513	1	60	49
513	1	60	50
513	1	59	50
513	1	60	51
514	1	1	50
514	1	2	50
514	1	1	51
514	1	2	51
514	1	1	52
514	1	3	51
515	1	4	50
515	1	5	50
515	1	4	51
515	1	5	51
515	1	4	52
515	1	6	50
516	1	8	50
516	1	9	50
516	1	8	51
516	1	10	50
516	1	9	51
517	1	16	50
517	1	16	51
517	1	17	51
517	1	16	52
517	1	17	52
517	1	15	52
518	1	30	50
518	1	30	51
518	1	31	51
518	1	29	51
519	1	33	50
519	1	34	50
519	1	33	51
519	1	34	51
519	1	32	51
519	1	33	52
519	1	32	52
519	1	35	50
520	1	37	50
520	1	37	51
520	1	38	51
520	1	36	51
520	1	37	52
520	1	39	51
521	1	52	50
521	1	52	51
521	1	53	51
521	1	51	51
521	1	52	52
521	1	51	52
522	1	6	51
522	1	7	51
522	1	6	52
522	1	7	52
522	1	8	52
523	1	10	51
523	1	11	51
523	1	10	52
523	1	12	51
524	1	13	51
524	1	13	52
524	1	14	52
524	1	12	52
524	1	13	53
524	1	14	53
524	1	12	53
524	1	13	54
525	1	23	51
525	1	24	51
525	1	23	52
525	1	24	52
525	1	23	53
525	1	24	53
525	1	22	53
525	1	23	54
526	1	35	51
526	1	35	52
526	1	36	52
526	1	34	52
527	1	40	51
527	1	40	52
527	1	41	52
527	1	39	52
527	1	40	53
527	1	42	52
527	1	41	53
528	1	45	51
528	1	46	51
528	1	45	52
528	1	46	52
528	1	44	52
528	1	45	53
528	1	46	53
528	1	44	53
529	1	48	51
529	1	49	51
529	1	48	52
529	1	49	52
529	1	47	52
529	1	48	53
529	1	50	52
530	1	59	51
530	1	59	52
530	1	60	52
530	1	58	52
530	1	59	53
531	1	2	52
531	1	3	52
531	1	2	53
531	1	3	53
531	1	1	53
531	1	2	54
532	1	5	52
532	1	5	53
532	1	6	53
532	1	4	53
532	1	5	54
532	1	4	54
532	1	7	53
533	1	9	52
533	1	9	53
533	1	10	53
533	1	8	53
533	1	9	54
534	1	11	52
534	1	11	53
534	1	11	54
534	1	12	54
534	1	10	54
535	1	18	52
535	1	19	52
535	1	18	53
535	1	20	52
535	1	19	53
535	1	20	53
535	1	19	54
535	1	21	53
536	1	25	52
536	1	26	52
536	1	25	53
536	1	26	53
536	1	25	54
536	1	26	54
536	1	24	54
537	1	27	52
537	1	28	52
537	1	27	53
537	1	29	52
537	1	28	53
537	1	29	53
537	1	28	54
537	1	29	54
538	1	30	52
538	1	31	52
538	1	30	53
538	1	31	53
538	1	30	54
539	1	38	52
539	1	38	53
539	1	39	53
539	1	37	53
539	1	38	54
539	1	39	54
540	1	43	52
540	1	43	53
540	1	42	53
540	1	43	54
540	1	44	54
541	1	53	52
541	1	54	52
541	1	53	53
541	1	55	52
541	1	54	53
542	1	56	52
542	1	57	52
542	1	56	53
542	1	57	53
542	1	55	53
543	1	15	53
543	1	16	53
543	1	15	54
543	1	16	54
543	1	14	54
544	1	17	53
544	1	17	54
544	1	18	54
544	1	17	55
544	1	18	55
545	1	32	53
545	1	33	53
545	1	32	54
545	1	34	53
545	1	33	54
545	1	34	54
545	1	33	55
545	1	31	54
546	1	35	53
546	1	36	53
546	1	35	54
546	1	36	54
547	1	47	53
547	1	47	54
547	1	48	54
547	1	46	54
547	1	47	55
548	1	49	53
548	1	50	53
548	1	49	54
548	1	50	54
548	1	49	55
549	1	51	53
549	1	52	53
549	1	51	54
549	1	52	54
549	1	51	55
549	1	52	55
550	1	58	53
550	1	58	54
550	1	59	54
550	1	57	54
550	1	58	55
550	1	59	55
550	1	57	55
550	1	58	56
551	1	60	53
551	1	60	54
551	1	60	55
551	1	60	56
551	1	59	56
551	1	60	57
551	1	59	57
552	1	1	54
552	1	1	55
552	1	2	55
552	1	1	56
552	1	2	56
552	1	1	57
553	1	3	54
553	1	3	55
553	1	4	55
553	1	3	56
553	1	4	56
554	1	6	54
554	1	7	54
554	1	6	55
554	1	7	55
554	1	5	55
554	1	6	56
554	1	5	56
555	1	8	54
555	1	8	55
555	1	9	55
555	1	8	56
556	1	20	54
556	1	21	54
556	1	20	55
556	1	21	55
556	1	19	55
556	1	20	56
556	1	21	56
556	1	19	56
557	1	22	54
557	1	22	55
557	1	23	55
557	1	22	56
557	1	24	55
557	1	23	56
558	1	27	54
558	1	27	55
558	1	28	55
558	1	26	55
558	1	27	56
558	1	25	55
558	1	26	56
558	1	29	55
559	1	37	54
559	1	37	55
559	1	38	55
559	1	36	55
559	1	37	56
559	1	39	55
559	1	38	56
559	1	36	56
560	1	40	54
560	1	41	54
560	1	40	55
560	1	42	54
561	1	45	54
561	1	45	55
561	1	46	55
561	1	44	55
561	1	45	56
561	1	46	56
561	1	44	56
562	1	53	54
562	1	54	54
562	1	53	55
562	1	54	55
562	1	53	56
563	1	55	54
563	1	56	54
563	1	55	55
563	1	56	55
563	1	56	56
563	1	57	56
563	1	55	56
563	1	56	57
564	1	10	55
564	1	11	55
564	1	10	56
564	1	12	55
564	1	11	56
564	1	12	56
564	1	11	57
564	1	13	56
565	1	13	55
565	1	14	55
565	1	15	55
565	1	14	56
566	1	16	55
566	1	16	56
566	1	17	56
566	1	15	56
567	1	30	55
567	1	31	55
567	1	30	56
567	1	32	55
567	1	31	56
568	1	34	55
568	1	35	55
568	1	34	56
568	1	35	56
569	1	41	55
569	1	42	55
569	1	41	56
569	1	42	56
569	1	40	56
569	1	41	57
570	1	43	55
570	1	43	56
570	1	43	57
570	1	44	57
570	1	42	57
570	1	43	58
570	1	45	57
571	1	48	55
571	1	48	56
571	1	49	56
571	1	47	56
571	1	48	57
571	1	50	56
572	1	50	55
573	1	7	56
573	1	7	57
573	1	8	57
573	1	6	57
573	1	7	58
573	1	5	57
573	1	6	58
573	1	9	57
574	1	9	56
575	1	18	56
575	1	18	57
575	1	19	57
575	1	17	57
575	1	18	58
575	1	19	58
575	1	17	58
576	1	24	56
576	1	25	56
576	1	24	57
576	1	25	57
577	1	28	56
577	1	29	56
577	1	28	57
577	1	29	57
577	1	30	57
577	1	29	58
577	1	27	57
577	1	28	58
578	1	32	56
578	1	33	56
578	1	32	57
578	1	33	57
578	1	31	57
579	1	39	56
579	1	39	57
579	1	40	57
579	1	38	57
579	1	39	58
579	1	37	57
579	1	38	58
580	1	51	56
580	1	52	56
580	1	51	57
580	1	52	57
580	1	50	57
581	1	54	56
581	1	54	57
581	1	55	57
581	1	53	57
581	1	54	58
581	1	55	58
582	1	2	57
582	1	3	57
582	1	2	58
582	1	4	57
582	1	3	58
582	1	1	58
583	1	10	57
583	1	10	58
583	1	11	58
583	1	9	58
583	1	10	59
583	1	12	58
584	1	12	57
584	1	13	57
584	1	14	57
584	1	13	58
584	1	14	58
585	1	15	57
585	1	16	57
585	1	15	58
585	1	16	58
585	1	15	59
585	1	16	59
585	1	14	59
586	1	20	57
586	1	21	57
586	1	20	58
586	1	22	57
586	1	21	58
586	1	22	58
586	1	21	59
587	1	23	57
587	1	23	58
587	1	24	58
587	1	23	59
587	1	24	59
588	1	26	57
588	1	26	58
588	1	27	58
588	1	25	58
589	1	34	57
589	1	35	57
589	1	34	58
589	1	35	58
589	1	33	58
590	1	36	57
590	1	36	58
590	1	37	58
590	1	36	59
590	1	37	59
591	1	46	57
591	1	47	57
591	1	46	58
591	1	47	58
592	1	49	57
592	1	49	58
592	1	50	58
592	1	48	58
593	1	57	57
593	1	58	57
593	1	57	58
593	1	58	58
593	1	56	58
594	1	4	58
594	1	5	58
594	1	4	59
594	1	5	59
594	1	3	59
594	1	4	60
594	1	2	59
595	1	8	58
595	1	8	59
595	1	9	59
595	1	7	59
595	1	8	60
595	1	9	60
595	1	7	60
596	1	30	58
596	1	31	58
596	1	30	59
596	1	31	59
596	1	29	59
596	1	30	60
596	1	32	59
596	1	31	60
597	1	32	58
598	1	40	58
598	1	41	58
598	1	40	59
598	1	42	58
598	1	41	59
598	1	39	59
598	1	40	60
599	1	44	58
599	1	45	58
599	1	44	59
599	1	45	59
599	1	43	59
599	1	44	60
600	1	51	58
600	1	52	58
600	1	51	59
600	1	53	58
600	1	52	59
601	1	59	58
601	1	60	58
601	1	59	59
601	1	60	59
601	1	58	59
601	1	59	60
601	1	60	60
602	1	1	59
602	1	1	60
602	1	2	60
602	1	3	60
603	1	6	59
603	1	6	60
603	1	5	60
604	1	11	59
604	1	12	59
604	1	11	60
604	1	12	60
604	1	10	60
604	1	13	60
604	1	13	59
605	1	17	59
605	1	18	59
605	1	17	60
605	1	19	59
605	1	18	60
605	1	19	60
605	1	16	60
605	1	15	60
606	1	20	59
606	1	20	60
606	1	21	60
606	1	22	60
606	1	23	60
606	1	22	59
606	1	24	60
607	1	25	59
607	1	26	59
607	1	25	60
607	1	27	59
608	1	28	59
608	1	28	60
608	1	29	60
608	1	27	60
608	1	26	60
609	1	33	59
609	1	34	59
609	1	33	60
609	1	35	59
609	1	34	60
610	1	38	59
610	1	38	60
610	1	39	60
610	1	37	60
611	1	42	59
611	1	42	60
611	1	43	60
611	1	41	60
612	1	46	59
612	1	47	59
612	1	46	60
612	1	47	60
613	1	48	59
613	1	49	59
613	1	48	60
613	1	50	59
613	1	49	60
614	1	53	59
614	1	54	59
614	1	53	60
614	1	54	60
614	1	52	60
614	1	51	60
614	1	55	60
614	1	50	60
615	1	55	59
615	1	56	59
615	1	57	59
615	1	56	60
615	1	57	60
615	1	58	60
616	1	14	60
617	1	32	60
618	1	35	60
618	1	36	60
619	1	45	60
\.


--
-- TOC entry 5419 (class 0 OID 22815)
-- Dependencies: 298
-- Data for Name: map_tiles_players_positions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_players_positions (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
1	1	3	3
2	1	4	4
3	1	3	3
\.


--
-- TOC entry 5420 (class 0 OID 22822)
-- Dependencies: 299
-- Data for Name: maps; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.maps (id, name) FROM stdin;
1	NowaMapa
\.


--
-- TOC entry 5422 (class 0 OID 22828)
-- Dependencies: 301
-- Data for Name: region_types; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.region_types (id, name) FROM stdin;
2	River
3	Sea
1	Province
\.


--
-- TOC entry 5369 (class 0 OID 22621)
-- Dependencies: 248
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
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 249
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.abilities_id_seq', 2, true);


--
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 252
-- Name: player_abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_abilities_id_seq', 6, true);


--
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 254
-- Name: player_skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_skills_id_seq', 9, true);


--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 256
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_stats_id_seq', 21, true);


--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 257
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.roles_id_seq', 1, false);


--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 258
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.skills_id_seq', 3, true);


--
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 259
-- Name: stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.stats_id_seq', 7, true);


--
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 261
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.accounts_id_seq', 1, false);


--
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 263
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.sessions_id_seq', 1, false);


--
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 265
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_id_seq', 1, false);


--
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 268
-- Name: building_types_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.building_types_id_seq', 1, false);


--
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 269
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.buildings_id_seq', 1, false);


--
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 270
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: cities; Owner: postgres
--

SELECT pg_catalog.setval('cities.cities_id_seq', 1, false);


--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 273
-- Name: district_types_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.district_types_id_seq', 1, false);


--
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 274
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.districts_id_seq', 1, false);


--
-- TOC entry 5501 (class 0 OID 0)
-- Dependencies: 276
-- Name: inventory_container_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_container_types_id_seq', 4, true);


--
-- TOC entry 5502 (class 0 OID 0)
-- Dependencies: 278
-- Name: inventory_containers_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_containers_id_seq', 6, true);


--
-- TOC entry 5503 (class 0 OID 0)
-- Dependencies: 280
-- Name: inventory_slot_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slot_types_id_seq', 14, true);


--
-- TOC entry 5504 (class 0 OID 0)
-- Dependencies: 282
-- Name: inventory_slots_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slots_id_seq', 66, true);


--
-- TOC entry 5505 (class 0 OID 0)
-- Dependencies: 283
-- Name: item_stats_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_stats_id_seq', 1, false);


--
-- TOC entry 5506 (class 0 OID 0)
-- Dependencies: 285
-- Name: item_types_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_types_id_seq', 10, true);


--
-- TOC entry 5507 (class 0 OID 0)
-- Dependencies: 286
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.items_id_seq', 3, true);


--
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 289
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.players_id_seq', 3, true);


--
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 291
-- Name: status_types_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.status_types_id_seq', 1, false);


--
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 293
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.tasks_id_seq', 819, true);


--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 294
-- Name: landscape_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.landscape_types_id_seq', 1, false);


--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 296
-- Name: map_regions_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.map_regions_id_seq', 619, true);


--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 300
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.maps_id_seq', 1, true);


--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 302
-- Name: region_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.region_types_id_seq', 3, true);


--
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 303
-- Name: terrain_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.terrain_types_id_seq', 3, true);


--
-- TOC entry 5075 (class 2606 OID 22844)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 22846)
-- Name: ability_skill_requirements ability_skill_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_pkey PRIMARY KEY (ability_id, skill_id);


--
-- TOC entry 5112 (class 2606 OID 22848)
-- Name: ability_stat_requirements ability_stat_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_pkey PRIMARY KEY (ability_id, stat_id);


--
-- TOC entry 5077 (class 2606 OID 22850)
-- Name: player_abilities player_abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5114 (class 2606 OID 22852)
-- Name: player_skills player_skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5116 (class 2606 OID 22854)
-- Name: player_stats player_stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5079 (class 2606 OID 22856)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5081 (class 2606 OID 22858)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5083 (class 2606 OID 22860)
-- Name: stats stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5118 (class 2606 OID 22862)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 5120 (class 2606 OID 22864)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5122 (class 2606 OID 22866)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5124 (class 2606 OID 22868)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5126 (class 2606 OID 22870)
-- Name: verification_token verification_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.verification_token
    ADD CONSTRAINT verification_token_pkey PRIMARY KEY (identifier, token);


--
-- TOC entry 5128 (class 2606 OID 22872)
-- Name: building_roles building_owners_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_owners_pkey PRIMARY KEY (building_id, player_id, role_id);


--
-- TOC entry 5085 (class 2606 OID 22874)
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5087 (class 2606 OID 22876)
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- TOC entry 5089 (class 2606 OID 22878)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 5130 (class 2606 OID 22880)
-- Name: city_roles city_owners_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_roles
    ADD CONSTRAINT city_owners_pkey PRIMARY KEY (city_id, player_id, role_id);


--
-- TOC entry 5092 (class 2606 OID 22882)
-- Name: city_tiles city_tiles_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_tiles
    ADD CONSTRAINT city_tiles_pkey PRIMARY KEY (city_id, x, y);


--
-- TOC entry 5132 (class 2606 OID 22884)
-- Name: district_roles district_owners_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_owners_pkey PRIMARY KEY (district_id, player_id, role_id);


--
-- TOC entry 5094 (class 2606 OID 22886)
-- Name: district_types district_types_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_types
    ADD CONSTRAINT district_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5096 (class 2606 OID 22888)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 5134 (class 2606 OID 22890)
-- Name: inventory_container_types inventory_container_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_types
    ADD CONSTRAINT inventory_container_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5136 (class 2606 OID 22892)
-- Name: inventory_containers inventory_containers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 22894)
-- Name: inventory_slot_types inventory_slot_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_types
    ADD CONSTRAINT inventory_slot_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5138 (class 2606 OID 22896)
-- Name: inventory_slots inventory_slots_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 5100 (class 2606 OID 22898)
-- Name: item_stats item_stats_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5140 (class 2606 OID 22900)
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 22902)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 5143 (class 2606 OID 22904)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 5145 (class 2606 OID 22906)
-- Name: status_types status_types_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types
    ADD CONSTRAINT status_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5147 (class 2606 OID 22908)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 5104 (class 2606 OID 22910)
-- Name: landscape_types landscape_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.landscape_types
    ADD CONSTRAINT landscape_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5149 (class 2606 OID 22912)
-- Name: map_regions map_regions_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_regions
    ADD CONSTRAINT map_regions_pkey PRIMARY KEY (id);


--
-- TOC entry 5106 (class 2606 OID 22914)
-- Name: map_tiles map_tiles_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_pkey PRIMARY KEY (map_id, x, y);


--
-- TOC entry 5151 (class 2606 OID 22916)
-- Name: map_tiles_players_positions map_tiles_players_positions_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_pkey PRIMARY KEY (player_id, map_tile_x, map_tile_y);


--
-- TOC entry 5153 (class 2606 OID 22918)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- TOC entry 5155 (class 2606 OID 22920)
-- Name: region_types region_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.region_types
    ADD CONSTRAINT region_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5108 (class 2606 OID 22922)
-- Name: terrain_types terrain_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.terrain_types
    ADD CONSTRAINT terrain_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5090 (class 1259 OID 22923)
-- Name: unique_city_position; Type: INDEX; Schema: cities; Owner: postgres
--

CREATE UNIQUE INDEX unique_city_position ON cities.cities USING btree (map_tile_x, map_tile_y);


--
-- TOC entry 5141 (class 1259 OID 22924)
-- Name: one_active_player_per_user; Type: INDEX; Schema: players; Owner: postgres
--

CREATE UNIQUE INDEX one_active_player_per_user ON players.players USING btree (user_id) WHERE (is_active = true);


--
-- TOC entry 5172 (class 2606 OID 22925)
-- Name: ability_skill_requirements ability_skill_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5173 (class 2606 OID 22930)
-- Name: ability_skill_requirements ability_skill_requirements_skill_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5174 (class 2606 OID 22935)
-- Name: ability_stat_requirements ability_stat_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5175 (class 2606 OID 22940)
-- Name: ability_stat_requirements ability_stat_requirements_stat_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_stat_id_fkey FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5156 (class 2606 OID 22945)
-- Name: player_abilities player_abilities_abilities_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_abilities_fk FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5157 (class 2606 OID 22950)
-- Name: player_abilities player_abilities_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5176 (class 2606 OID 22955)
-- Name: player_skills player_skills_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5177 (class 2606 OID 22960)
-- Name: player_skills player_skills_skills_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_skills_fk FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5178 (class 2606 OID 22965)
-- Name: player_stats player_stats_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5179 (class 2606 OID 22970)
-- Name: player_stats player_stats_stats_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5180 (class 2606 OID 22975)
-- Name: accounts accounts_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_users_fk FOREIGN KEY ("userId") REFERENCES auth.users(id);


--
-- TOC entry 5181 (class 2606 OID 22980)
-- Name: sessions sessions_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_users_fk FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- TOC entry 5182 (class 2606 OID 22985)
-- Name: building_roles building_roles_buildings_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_buildings_fk FOREIGN KEY (building_id) REFERENCES buildings.buildings(id);


--
-- TOC entry 5183 (class 2606 OID 22990)
-- Name: building_roles building_roles_players_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5184 (class 2606 OID 22995)
-- Name: building_roles building_roles_roles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5158 (class 2606 OID 23000)
-- Name: buildings buildings_building_types_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_building_types_fk FOREIGN KEY (building_type_id) REFERENCES buildings.building_types(id);


--
-- TOC entry 5159 (class 2606 OID 23005)
-- Name: buildings buildings_cities_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_cities_fk FOREIGN KEY (city_id) REFERENCES cities.cities(id);


--
-- TOC entry 5160 (class 2606 OID 23010)
-- Name: buildings buildings_city_tiles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_city_tiles_fk FOREIGN KEY (city_id, city_tile_x, city_tile_y) REFERENCES cities.city_tiles(city_id, x, y);


--
-- TOC entry 5161 (class 2606 OID 23015)
-- Name: cities cities_map_tiles_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5162 (class 2606 OID 23020)
-- Name: cities cities_maps_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5185 (class 2606 OID 23025)
-- Name: district_roles district_roles_districts_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_districts_fk FOREIGN KEY (district_id) REFERENCES districts.districts(id);


--
-- TOC entry 5186 (class 2606 OID 23030)
-- Name: district_roles district_roles_players_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5187 (class 2606 OID 23035)
-- Name: district_roles district_roles_roles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5163 (class 2606 OID 23040)
-- Name: districts districts_district_types_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_district_types_fk FOREIGN KEY (district_type_id) REFERENCES districts.district_types(id);


--
-- TOC entry 5164 (class 2606 OID 23045)
-- Name: districts districts_map_tiles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5165 (class 2606 OID 23050)
-- Name: districts districts_maps_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5188 (class 2606 OID 23055)
-- Name: inventory_containers inventory_containers_inventory_container_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_inventory_container_types_fk FOREIGN KEY (inventory_container_type_id) REFERENCES inventory.inventory_container_types(id);


--
-- TOC entry 5189 (class 2606 OID 23060)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5190 (class 2606 OID 23065)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_item_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5191 (class 2606 OID 23070)
-- Name: inventory_slots inventory_slots_inventory_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5192 (class 2606 OID 23075)
-- Name: inventory_slots inventory_slots_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5193 (class 2606 OID 23080)
-- Name: inventory_slots inventory_slots_items_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5166 (class 2606 OID 23085)
-- Name: item_stats item_stats_items_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5167 (class 2606 OID 23090)
-- Name: item_stats item_stats_stats_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5168 (class 2606 OID 23095)
-- Name: items items_item_types_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5202 (class 2606 OID 23184)
-- Name: known_map_tiles known_map_tiles_map_tiles_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5203 (class 2606 OID 23179)
-- Name: known_map_tiles known_map_tiles_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_map_tiles
    ADD CONSTRAINT known_map_tiles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5194 (class 2606 OID 23100)
-- Name: known_players_positions known_players_positions_players_fk; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5195 (class 2606 OID 23105)
-- Name: known_players_positions known_players_positions_players_fk_1; Type: FK CONSTRAINT; Schema: knowledge; Owner: postgres
--

ALTER TABLE ONLY knowledge.known_players_positions
    ADD CONSTRAINT known_players_positions_players_fk_1 FOREIGN KEY (other_player_id) REFERENCES players.players(id);


--
-- TOC entry 5169 (class 2606 OID 23110)
-- Name: map_tiles map_tiles_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5196 (class 2606 OID 23115)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_regions_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_regions_fk FOREIGN KEY (region_id) REFERENCES world.map_regions(id);


--
-- TOC entry 5197 (class 2606 OID 23120)
-- Name: map_tiles_map_regions map_tiles_map_regions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5198 (class 2606 OID 23125)
-- Name: map_tiles_map_regions map_tiles_map_regions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_map_regions
    ADD CONSTRAINT map_tiles_map_regions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5170 (class 2606 OID 23130)
-- Name: map_tiles map_tiles_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5199 (class 2606 OID 23135)
-- Name: map_tiles_players_positions map_tiles_players_positions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5200 (class 2606 OID 23140)
-- Name: map_tiles_players_positions map_tiles_players_positions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5201 (class 2606 OID 23145)
-- Name: map_tiles_players_positions map_tiles_players_positions_players_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5171 (class 2606 OID 23150)
-- Name: map_tiles map_tiles_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


-- Completed on 2026-02-20 00:31:13

--
-- PostgreSQL database dump complete
--

\unrestrict YBmaD7KMiwnxQqmoKSp7H8a9DkzQeSzRwTeJQNn4gjKXXOM43JkhQdY2p3JhgXE

