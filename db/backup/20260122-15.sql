--
-- PostgreSQL database dump
--

\restrict PVFeXO62DDthT61nhlLNQJafg7nAL24RhhGtajGTf0LtulBAych03zgbihA016X

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-02-12 00:28:37

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
-- TOC entry 6 (class 2615 OID 21319)
-- Name: admin; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA admin;


ALTER SCHEMA admin OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 21320)
-- Name: attributes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA attributes;


ALTER SCHEMA attributes OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 21321)
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 21322)
-- Name: buildings; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA buildings;


ALTER SCHEMA buildings OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 21323)
-- Name: cities; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA cities;


ALTER SCHEMA cities OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 21324)
-- Name: districts; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA districts;


ALTER SCHEMA districts OWNER TO postgres;

--
-- TOC entry 12 (class 2615 OID 21325)
-- Name: inventory; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA inventory;


ALTER SCHEMA inventory OWNER TO postgres;

--
-- TOC entry 13 (class 2615 OID 21326)
-- Name: items; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA items;


ALTER SCHEMA items OWNER TO postgres;

--
-- TOC entry 14 (class 2615 OID 21327)
-- Name: knowledge; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA knowledge;


ALTER SCHEMA knowledge OWNER TO postgres;

--
-- TOC entry 15 (class 2615 OID 21328)
-- Name: players; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA players;


ALTER SCHEMA players OWNER TO postgres;

--
-- TOC entry 16 (class 2615 OID 21329)
-- Name: tasks; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tasks;


ALTER SCHEMA tasks OWNER TO postgres;

--
-- TOC entry 17 (class 2615 OID 21330)
-- Name: util; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA util;


ALTER SCHEMA util OWNER TO postgres;

--
-- TOC entry 18 (class 2615 OID 21331)
-- Name: world; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA world;


ALTER SCHEMA world OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 21332)
-- Name: choose_terrain_based_on_neighbors(integer[], integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: admin; Owner: postgres
--

CREATE FUNCTION admin.choose_terrain_based_on_neighbors(terrain_grid integer[], x integer, y integer, width integer, height integer, upper1 integer, lower1 integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION admin.choose_terrain_based_on_neighbors(terrain_grid integer[], x integer, y integer, width integer, height integer, upper1 integer, lower1 integer) OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 21333)
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
-- TOC entry 361 (class 1255 OID 21334)
-- Name: map_delete(); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.map_delete()
    LANGUAGE plpgsql
    AS $$

BEGIN
TRUNCATE TABLE world.maps RESTART IDENTITY CASCADE;

TRUNCATE TABLE world.map_tiles RESTART IDENTITY CASCADE;
   
END;
$$;


ALTER PROCEDURE admin.map_delete() OWNER TO postgres;

--
-- TOC entry 344 (class 1255 OID 21335)
-- Name: map_insert(); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.map_insert()
    LANGUAGE plpgsql
    AS $$
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
               random1 := admin.choose_terrain_based_on_neighbors(terrain_grid, countW, countH, width, height, upper1, lower1);
            END IF;

            --random1 := floor((upper1 - lower1 + 1) * random() + lower1);
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
END;
$$;


ALTER PROCEDURE admin.map_insert() OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 21336)
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
-- TOC entry 321 (class 1255 OID 21337)
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
$$;


ALTER FUNCTION admin.random_landscape_types(terrain_type_id integer) OWNER TO postgres;

--
-- TOC entry 384 (class 1255 OID 21338)
-- Name: reset_all(); Type: PROCEDURE; Schema: admin; Owner: postgres
--

CREATE PROCEDURE admin.reset_all()
    LANGUAGE plpgsql
    AS $$
BEGIN

TRUNCATE TABLE  players.players 					RESTART IDENTITY CASCADE;
TRUNCATE TABLE  world.map_tiles_players_positions RESTART IDENTITY CASCADE;
TRUNCATE TABLE  "attributes".player_stats     	RESTART IDENTITY CASCADE;
TRUNCATE TABLE  "attributes".player_skills     	RESTART IDENTITY CASCADE;
TRUNCATE TABLE  "attributes".player_abilities  	   RESTART IDENTITY CASCADE;
TRUNCATE TABLE  inventory.inventory_containers     RESTART IDENTITY CASCADE;
TRUNCATE TABLE  inventory.inventory_slots           RESTART IDENTITY CASCADE;

TRUNCATE TABLE  tasks.tasks          RESTART IDENTITY CASCADE;
	


    RAISE NOTICE 'All have been truncated and reset';
END;
$$;


ALTER PROCEDURE admin.reset_all() OWNER TO postgres;

--
-- TOC entry 386 (class 1255 OID 21339)
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
-- TOC entry 232 (class 1259 OID 21340)
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
-- TOC entry 374 (class 1255 OID 21348)
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
-- TOC entry 5385 (class 0 OID 0)
-- Dependencies: 374
-- Name: FUNCTION get_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities() IS 'automatic_get_api';


--
-- TOC entry 367 (class 1255 OID 21349)
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
-- TOC entry 5386 (class 0 OID 0)
-- Dependencies: 367
-- Name: FUNCTION get_abilities_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 233 (class 1259 OID 21350)
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
-- TOC entry 370 (class 1255 OID 21357)
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
-- TOC entry 5387 (class 0 OID 0)
-- Dependencies: 370
-- Name: FUNCTION get_player_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities() IS 'automatic_get_api';


--
-- TOC entry 351 (class 1255 OID 21358)
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
-- TOC entry 5388 (class 0 OID 0)
-- Dependencies: 351
-- Name: FUNCTION get_player_abilities(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities(p_player_id integer) IS 'get_api';


--
-- TOC entry 300 (class 1255 OID 21359)
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
-- TOC entry 5389 (class 0 OID 0)
-- Dependencies: 300
-- Name: FUNCTION get_player_abilities_by_key(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities_by_key(p_player_id integer) IS 'automatic_get_api';


--
-- TOC entry 306 (class 1255 OID 21360)
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
-- TOC entry 5390 (class 0 OID 0)
-- Dependencies: 306
-- Name: FUNCTION get_player_skills(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_skills(p_player_id integer) IS 'get_api';


--
-- TOC entry 356 (class 1255 OID 21361)
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
-- TOC entry 5391 (class 0 OID 0)
-- Dependencies: 356
-- Name: FUNCTION get_player_stats(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_stats(p_player_id integer) IS 'get_api';


--
-- TOC entry 234 (class 1259 OID 21362)
-- Name: roles; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.roles (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE attributes.roles OWNER TO postgres;

--
-- TOC entry 336 (class 1255 OID 21366)
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
-- TOC entry 5392 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION get_roles(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles() IS 'automatic_get_api';


--
-- TOC entry 334 (class 1255 OID 21367)
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
-- TOC entry 5393 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION get_roles_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 235 (class 1259 OID 21368)
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
-- TOC entry 348 (class 1255 OID 21376)
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
-- TOC entry 5394 (class 0 OID 0)
-- Dependencies: 348
-- Name: FUNCTION get_skills(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills() IS 'automatic_get_api';


--
-- TOC entry 315 (class 1255 OID 21377)
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
-- TOC entry 5395 (class 0 OID 0)
-- Dependencies: 315
-- Name: FUNCTION get_skills_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 236 (class 1259 OID 21378)
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
-- TOC entry 330 (class 1255 OID 21386)
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
-- TOC entry 5396 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION get_stats(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats() IS 'automatic_get_api';


--
-- TOC entry 347 (class 1255 OID 21387)
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
-- TOC entry 5397 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION get_stats_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 354 (class 1255 OID 21388)
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
-- TOC entry 302 (class 1255 OID 21389)
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
-- TOC entry 317 (class 1255 OID 21390)
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
-- TOC entry 237 (class 1259 OID 21391)
-- Name: building_types; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    image_url character varying(255)
);


ALTER TABLE buildings.building_types OWNER TO postgres;

--
-- TOC entry 319 (class 1255 OID 21396)
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
-- TOC entry 5398 (class 0 OID 0)
-- Dependencies: 319
-- Name: FUNCTION get_building_types(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types() IS 'automatic_get_api';


--
-- TOC entry 380 (class 1255 OID 21397)
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
-- TOC entry 5399 (class 0 OID 0)
-- Dependencies: 380
-- Name: FUNCTION get_building_types_by_key(p_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 238 (class 1259 OID 21398)
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
-- TOC entry 333 (class 1255 OID 21407)
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
-- TOC entry 5400 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION get_buildings(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings() IS 'automatic_get_api';


--
-- TOC entry 371 (class 1255 OID 21408)
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
-- TOC entry 5401 (class 0 OID 0)
-- Dependencies: 371
-- Name: FUNCTION get_buildings_by_key(p_city_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 239 (class 1259 OID 21409)
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
-- TOC entry 316 (class 1255 OID 21418)
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
-- TOC entry 5402 (class 0 OID 0)
-- Dependencies: 316
-- Name: FUNCTION get_cities(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities() IS 'automatic_get_api';


--
-- TOC entry 369 (class 1255 OID 21419)
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
-- TOC entry 5403 (class 0 OID 0)
-- Dependencies: 369
-- Name: FUNCTION get_cities_by_key(p_map_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 240 (class 1259 OID 21420)
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
-- TOC entry 329 (class 1255 OID 21428)
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
-- TOC entry 5404 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION get_city_tiles(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles() IS 'automatic_get_api';


--
-- TOC entry 382 (class 1255 OID 21429)
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
-- TOC entry 5405 (class 0 OID 0)
-- Dependencies: 382
-- Name: FUNCTION get_city_tiles_by_key(p_city_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 360 (class 1255 OID 21430)
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
-- TOC entry 5406 (class 0 OID 0)
-- Dependencies: 360
-- Name: FUNCTION get_player_city(p_player_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_player_city(p_player_id integer) IS 'get_api';


--
-- TOC entry 241 (class 1259 OID 21431)
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
-- TOC entry 385 (class 1255 OID 21437)
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
-- TOC entry 5407 (class 0 OID 0)
-- Dependencies: 385
-- Name: FUNCTION get_district_types(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types() IS 'automatic_get_api';


--
-- TOC entry 301 (class 1255 OID 21438)
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
-- TOC entry 5408 (class 0 OID 0)
-- Dependencies: 301
-- Name: FUNCTION get_district_types_by_key(p_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 242 (class 1259 OID 21439)
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
-- TOC entry 305 (class 1255 OID 21447)
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
-- TOC entry 5409 (class 0 OID 0)
-- Dependencies: 305
-- Name: FUNCTION get_districts(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts() IS 'automatic_get_api';


--
-- TOC entry 358 (class 1255 OID 21448)
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
-- TOC entry 5410 (class 0 OID 0)
-- Dependencies: 358
-- Name: FUNCTION get_districts_by_key(p_map_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 331 (class 1255 OID 21449)
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
-- TOC entry 346 (class 1255 OID 21450)
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
-- TOC entry 350 (class 1255 OID 21451)
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
-- TOC entry 378 (class 1255 OID 21452)
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
-- TOC entry 377 (class 1255 OID 21453)
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
-- TOC entry 349 (class 1255 OID 21454)
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
-- TOC entry 355 (class 1255 OID 21455)
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
-- TOC entry 312 (class 1255 OID 21456)
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
-- TOC entry 5411 (class 0 OID 0)
-- Dependencies: 312
-- Name: FUNCTION do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 327 (class 1255 OID 21457)
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
-- TOC entry 5412 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer) IS 'action_api';


--
-- TOC entry 387 (class 1255 OID 21458)
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
-- TOC entry 5413 (class 0 OID 0)
-- Dependencies: 387
-- Name: FUNCTION get_building_inventory(p_building_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_building_inventory(p_building_id integer) IS 'get_api';


--
-- TOC entry 309 (class 1255 OID 21459)
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
-- TOC entry 314 (class 1255 OID 21460)
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
-- TOC entry 5414 (class 0 OID 0)
-- Dependencies: 314
-- Name: FUNCTION get_district_inventory(p_district_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_district_inventory(p_district_id integer) IS 'get_api';


--
-- TOC entry 243 (class 1259 OID 21461)
-- Name: inventory_slot_types; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slot_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE inventory.inventory_slot_types OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 21465)
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
-- TOC entry 5415 (class 0 OID 0)
-- Dependencies: 310
-- Name: FUNCTION get_inventory_slot_types(); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types() IS 'automatic_get_api';


--
-- TOC entry 388 (class 1255 OID 21466)
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
-- TOC entry 5416 (class 0 OID 0)
-- Dependencies: 388
-- Name: FUNCTION get_inventory_slot_types_by_key(p_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_inventory_slot_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 376 (class 1255 OID 21467)
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
-- TOC entry 5417 (class 0 OID 0)
-- Dependencies: 376
-- Name: FUNCTION get_player_gear_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_gear_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 375 (class 1255 OID 21468)
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
-- TOC entry 5418 (class 0 OID 0)
-- Dependencies: 375
-- Name: FUNCTION get_player_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 362 (class 1255 OID 21469)
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
-- TOC entry 373 (class 1255 OID 21470)
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
-- TOC entry 318 (class 1255 OID 21471)
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
-- TOC entry 244 (class 1259 OID 21472)
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
-- TOC entry 335 (class 1255 OID 21479)
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
-- TOC entry 5419 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION get_item_stats(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats() IS 'automatic_get_api';


--
-- TOC entry 352 (class 1255 OID 21480)
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
-- TOC entry 5420 (class 0 OID 0)
-- Dependencies: 352
-- Name: FUNCTION get_item_stats_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 245 (class 1259 OID 21481)
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
-- TOC entry 381 (class 1255 OID 21491)
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
-- TOC entry 5421 (class 0 OID 0)
-- Dependencies: 381
-- Name: FUNCTION get_items(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items() IS 'automatic_get_api';


--
-- TOC entry 363 (class 1255 OID 21492)
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
-- TOC entry 5422 (class 0 OID 0)
-- Dependencies: 363
-- Name: FUNCTION get_items_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 320 (class 1255 OID 21493)
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
-- TOC entry 5423 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION do_switch_active_player(p_player_id integer, p_switch_to_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) IS 'action_api';


--
-- TOC entry 325 (class 1255 OID 21494)
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
-- TOC entry 313 (class 1255 OID 21495)
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
-- TOC entry 5424 (class 0 OID 0)
-- Dependencies: 313
-- Name: FUNCTION get_active_player_profile(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_profile(p_player_id integer) IS 'get_api';


--
-- TOC entry 368 (class 1255 OID 21496)
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
-- TOC entry 5425 (class 0 OID 0)
-- Dependencies: 368
-- Name: FUNCTION get_active_player_switch_profiles(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_switch_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 311 (class 1255 OID 21497)
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
-- TOC entry 372 (class 1255 OID 21498)
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
-- TOC entry 342 (class 1255 OID 21999)
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
-- TOC entry 337 (class 1255 OID 21500)
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
-- TOC entry 323 (class 1255 OID 21501)
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
-- TOC entry 5426 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION do_player_movement(p_player_id integer, p_path jsonb); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) IS 'action_api';


--
-- TOC entry 246 (class 1259 OID 21502)
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
-- TOC entry 324 (class 1255 OID 21508)
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
-- TOC entry 5427 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION get_landscape_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types() IS 'automatic_get_api';


--
-- TOC entry 359 (class 1255 OID 21509)
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
-- TOC entry 5428 (class 0 OID 0)
-- Dependencies: 359
-- Name: FUNCTION get_landscape_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 247 (class 1259 OID 21510)
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
-- TOC entry 339 (class 1255 OID 21518)
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
-- TOC entry 5429 (class 0 OID 0)
-- Dependencies: 339
-- Name: FUNCTION get_map_tiles(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles() IS 'automatic_get_api';


--
-- TOC entry 389 (class 1255 OID 21519)
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
-- TOC entry 5430 (class 0 OID 0)
-- Dependencies: 389
-- Name: FUNCTION get_map_tiles_by_key(p_map_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 353 (class 1255 OID 21520)
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
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 353
-- Name: FUNCTION get_player_map(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_map(p_player_id integer) IS 'get_api';


--
-- TOC entry 341 (class 1255 OID 22007)
-- Name: get_player_movement(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_movement(p_player_id integer) RETURNS TABLE(move_cost integer, x integer, y integer, total_move_cost integer)
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
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 341
-- Name: FUNCTION get_player_movement(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_movement(p_player_id integer) IS 'get_api';


--
-- TOC entry 338 (class 1255 OID 21522)
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
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 338
-- Name: FUNCTION get_player_position(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 248 (class 1259 OID 21523)
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
-- TOC entry 304 (class 1255 OID 21529)
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
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 304
-- Name: FUNCTION get_terrain_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types() IS 'automatic_get_api';


--
-- TOC entry 357 (class 1255 OID 21530)
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
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 357
-- Name: FUNCTION get_terrain_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 328 (class 1255 OID 22232)
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
-- TOC entry 249 (class 1259 OID 21531)
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
-- TOC entry 250 (class 1259 OID 21532)
-- Name: ability_skill_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_skill_requirements (
    ability_id integer NOT NULL,
    skill_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_skill_requirements OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 21539)
-- Name: ability_stat_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_stat_requirements (
    ability_id integer NOT NULL,
    stat_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_stat_requirements OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 21546)
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
-- TOC entry 253 (class 1259 OID 21547)
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
-- TOC entry 254 (class 1259 OID 21554)
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
-- TOC entry 255 (class 1259 OID 21555)
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
-- TOC entry 256 (class 1259 OID 21562)
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
-- TOC entry 257 (class 1259 OID 21563)
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
-- TOC entry 258 (class 1259 OID 21564)
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
-- TOC entry 259 (class 1259 OID 21565)
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
-- TOC entry 260 (class 1259 OID 21566)
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
-- TOC entry 261 (class 1259 OID 21576)
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
-- TOC entry 262 (class 1259 OID 21577)
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
-- TOC entry 263 (class 1259 OID 21584)
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
-- TOC entry 264 (class 1259 OID 21585)
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
-- TOC entry 265 (class 1259 OID 21591)
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
-- TOC entry 266 (class 1259 OID 21592)
-- Name: verification_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.verification_token (
    identifier text NOT NULL,
    expires timestamp with time zone NOT NULL,
    token text NOT NULL
);


ALTER TABLE auth.verification_token OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 21600)
-- Name: building_roles; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_roles (
    building_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE buildings.building_roles OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 21606)
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
-- TOC entry 269 (class 1259 OID 21607)
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
-- TOC entry 270 (class 1259 OID 21608)
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
-- TOC entry 271 (class 1259 OID 21609)
-- Name: city_roles; Type: TABLE; Schema: cities; Owner: postgres
--

CREATE TABLE cities.city_roles (
    city_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE cities.city_roles OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 21615)
-- Name: district_roles; Type: TABLE; Schema: districts; Owner: postgres
--

CREATE TABLE districts.district_roles (
    district_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE districts.district_roles OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 21621)
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
-- TOC entry 274 (class 1259 OID 21622)
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
-- TOC entry 275 (class 1259 OID 21623)
-- Name: inventory_container_types; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_container_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE inventory.inventory_container_types OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 21627)
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
-- TOC entry 277 (class 1259 OID 21628)
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
-- TOC entry 278 (class 1259 OID 21637)
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
-- TOC entry 279 (class 1259 OID 21638)
-- Name: inventory_slot_type_item_type; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slot_type_item_type (
    inventory_slot_type_id integer NOT NULL,
    item_type_id integer NOT NULL
);


ALTER TABLE inventory.inventory_slot_type_item_type OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 21643)
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
-- TOC entry 281 (class 1259 OID 21644)
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
-- TOC entry 282 (class 1259 OID 21651)
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
-- TOC entry 283 (class 1259 OID 21652)
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
-- TOC entry 284 (class 1259 OID 21653)
-- Name: item_types; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.item_types (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE items.item_types OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 21657)
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
-- TOC entry 286 (class 1259 OID 21658)
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
-- TOC entry 287 (class 1259 OID 21659)
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
    nickname character varying(255)
);


ALTER TABLE players.players OWNER TO postgres;

--
-- TOC entry 288 (class 1259 OID 21674)
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
-- TOC entry 289 (class 1259 OID 21675)
-- Name: status_types; Type: TABLE; Schema: tasks; Owner: postgres
--

CREATE TABLE tasks.status_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE tasks.status_types OWNER TO postgres;

--
-- TOC entry 290 (class 1259 OID 21680)
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
-- TOC entry 291 (class 1259 OID 21681)
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
-- TOC entry 292 (class 1259 OID 21691)
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
-- TOC entry 293 (class 1259 OID 21692)
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
-- TOC entry 294 (class 1259 OID 21693)
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
-- TOC entry 295 (class 1259 OID 21700)
-- Name: maps; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.maps (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE world.maps OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 21705)
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
-- TOC entry 297 (class 1259 OID 21706)
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
-- TOC entry 298 (class 1259 OID 21707)
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
-- TOC entry 299 (class 1259 OID 21711)
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
-- TOC entry 5314 (class 0 OID 21340)
-- Dependencies: 232
-- Data for Name: abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.abilities (id, name, description, image) FROM stdin;
2	Explore	Explore new land's	Eye
1	Colonize	Settle Nomad's	Tent
\.


--
-- TOC entry 5332 (class 0 OID 21532)
-- Dependencies: 250
-- Data for Name: ability_skill_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_skill_requirements (ability_id, skill_id, min_value) FROM stdin;
1	1	1
2	2	1
\.


--
-- TOC entry 5333 (class 0 OID 21539)
-- Dependencies: 251
-- Data for Name: ability_stat_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_stat_requirements (ability_id, stat_id, min_value) FROM stdin;
\.


--
-- TOC entry 5315 (class 0 OID 21350)
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
7	4	1	1
8	4	2	1
9	5	1	1
10	5	2	1
\.


--
-- TOC entry 5335 (class 0 OID 21547)
-- Dependencies: 253
-- Data for Name: player_skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_skills (id, player_id, skill_id, value) FROM stdin;
1	1	1	10
2	1	2	2
3	1	3	3
4	2	1	4
5	2	2	2
6	2	3	4
7	3	1	4
8	3	2	5
9	3	3	6
10	4	1	4
11	4	2	9
12	4	3	3
13	5	1	8
14	5	2	8
15	5	3	5
\.


--
-- TOC entry 5337 (class 0 OID 21555)
-- Dependencies: 255
-- Data for Name: player_stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_stats (id, player_id, stat_id, value) FROM stdin;
1	1	1	5
2	1	3	5
3	1	4	10
4	1	5	5
5	1	6	8
6	1	7	4
7	1	2	2
8	2	1	5
9	2	3	1
10	2	4	3
11	2	5	8
12	2	6	9
13	2	7	3
14	2	2	1
15	3	1	1
16	3	3	2
17	3	4	3
18	3	5	2
19	3	6	5
20	3	7	2
21	3	2	4
22	4	1	5
23	4	3	4
24	4	4	3
25	4	5	1
26	4	6	2
27	4	7	6
28	4	2	1
29	5	1	10
30	5	3	7
31	5	4	5
32	5	5	7
33	5	6	5
34	5	7	4
35	5	2	6
\.


--
-- TOC entry 5316 (class 0 OID 21362)
-- Dependencies: 234
-- Data for Name: roles; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.roles (id, name) FROM stdin;
1	Owner
\.


--
-- TOC entry 5317 (class 0 OID 21368)
-- Dependencies: 235
-- Data for Name: skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.skills (id, name, description, image) FROM stdin;
1	Colonization	Settle new world's !	Tent
2	Survival	Navigate wilderness and find resources stay alive	TreePine
3	Trade	How cheap can you buy ?	HandCoinsIcon
\.


--
-- TOC entry 5318 (class 0 OID 21378)
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
-- TOC entry 5342 (class 0 OID 21566)
-- Dependencies: 260
-- Data for Name: accounts; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.accounts (id, "userId", type, provider, "providerAccountId", refresh_token, access_token, expires_at, id_token, scope, session_state, token_type) FROM stdin;
\.


--
-- TOC entry 5344 (class 0 OID 21577)
-- Dependencies: 262
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.sessions (id, "userId", expires, "sessionToken") FROM stdin;
\.


--
-- TOC entry 5346 (class 0 OID 21585)
-- Dependencies: 264
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.users (id, name, email, "emailVerified", image, password) FROM stdin;
1	ciabat	pszabat001@gmail.com	\N	\N	$2b$10$4IQKRdaQ8l29u9KEdy6G6esjYGPJe9rQsWlAqPSe0OgbzyjsV6rCW
\.


--
-- TOC entry 5348 (class 0 OID 21592)
-- Dependencies: 266
-- Data for Name: verification_token; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.verification_token (identifier, expires, token) FROM stdin;
\.


--
-- TOC entry 5349 (class 0 OID 21600)
-- Dependencies: 267
-- Data for Name: building_roles; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_roles (building_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5319 (class 0 OID 21391)
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
-- TOC entry 5320 (class 0 OID 21398)
-- Dependencies: 238
-- Data for Name: buildings; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.buildings (id, city_id, city_tile_x, city_tile_y, building_type_id, name) FROM stdin;
1	2	5	5	1	First
2	2	5	6	2	Second
5	2	5	4	3	Third
3	2	6	5	3	Third
4	2	4	5	3	Third
6	2	4	4	3	Third
7	2	6	4	3	Third
8	2	6	6	4	Third
\.


--
-- TOC entry 5321 (class 0 OID 21409)
-- Dependencies: 239
-- Data for Name: cities; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.cities (id, map_id, map_tile_x, map_tile_y, name, move_cost, image_url) FROM stdin;
2	1	4	3	Nashkel	1	City_1.png
\.


--
-- TOC entry 5353 (class 0 OID 21609)
-- Dependencies: 271
-- Data for Name: city_roles; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.city_roles (city_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5322 (class 0 OID 21420)
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
-- TOC entry 5354 (class 0 OID 21615)
-- Dependencies: 272
-- Data for Name: district_roles; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_roles (district_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5323 (class 0 OID 21431)
-- Dependencies: 241
-- Data for Name: district_types; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_types (id, name, move_cost, image_url) FROM stdin;
1	Farmland	1	full_farmland.png
\.


--
-- TOC entry 5324 (class 0 OID 21439)
-- Dependencies: 242
-- Data for Name: districts; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.districts (id, map_id, map_tile_x, map_tile_y, district_type_id, name) FROM stdin;
1	1	4	4	1	Green Hills
\.


--
-- TOC entry 5357 (class 0 OID 21623)
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
-- TOC entry 5359 (class 0 OID 21628)
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
7	9	1	4
8	13	2	4
9	9	1	5
10	13	2	5
\.


--
-- TOC entry 5361 (class 0 OID 21638)
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
-- TOC entry 5325 (class 0 OID 21461)
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
-- TOC entry 5363 (class 0 OID 21644)
-- Dependencies: 281
-- Data for Name: inventory_slots; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slots (id, inventory_container_id, item_id, quantity, inventory_slot_type_id) FROM stdin;
6	1	\N	\N	1
8	1	\N	\N	1
9	1	\N	\N	1
12	2	\N	\N	4
16	2	\N	\N	8
17	2	\N	\N	9
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
1	1	1	1	1
10	2	\N	\N	2
2	1	\N	\N	1
3	1	\N	\N	1
4	1	\N	\N	1
7	1	\N	\N	1
22	2	\N	\N	14
11	2	\N	\N	3
15	2	\N	\N	7
20	2	\N	\N	12
14	2	\N	\N	6
21	2	\N	\N	13
13	2	\N	\N	5
5	1	\N	\N	1
18	2	\N	\N	10
\.


--
-- TOC entry 5326 (class 0 OID 21472)
-- Dependencies: 244
-- Data for Name: item_stats; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_stats (id, item_id, stat_id, value) FROM stdin;
\.


--
-- TOC entry 5366 (class 0 OID 21653)
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
-- TOC entry 5327 (class 0 OID 21481)
-- Dependencies: 245
-- Data for Name: items; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.items (id, name, description, image, item_type_id) FROM stdin;
1	Food	\N	Herbalism	1
2	Sword	\N	Sword	5
3	Helmet	\N	default.png	2
\.


--
-- TOC entry 5369 (class 0 OID 21659)
-- Dependencies: 287
-- Data for Name: players; Type: TABLE DATA; Schema: players; Owner: postgres
--

COPY players.players (id, user_id, name, image_map, image_portrait, is_active, second_name, nickname) FROM stdin;
2	1	Pawel	default.png	default.png	f	Ciabat	\N
3	1	Pawluniu	default.png	default.png	f	Pigeon	\N
4	1	Pawluniu	default.png	default.png	f	Pigeon	\N
5	1	Piotruniu	default.png	default.png	f	Pigeon	\N
1	1	Peter	default.png	default.png	t	Ciabat	\N
\.


--
-- TOC entry 5371 (class 0 OID 21675)
-- Dependencies: 289
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
-- TOC entry 5373 (class 0 OID 21681)
-- Dependencies: 291
-- Data for Name: tasks; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

COPY tasks.tasks (id, player_id, status, created_at, scheduled_at, last_executed_at, error, method_name, method_parameters) FROM stdin;
1	1	5	2026-02-09 20:49:16.436508	2026-02-09 20:52:16.436508	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 3}
2	1	5	2026-02-09 20:49:16.436508	2026-02-09 20:53:16.436508	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 1, "totalMoveCost": 4}
3	1	5	2026-02-09 20:49:16.436508	2026-02-09 20:54:16.436508	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 5}
4	1	5	2026-02-09 20:49:16.436508	2026-02-09 20:55:16.436508	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 6}
5	1	5	2026-02-09 20:49:16.436508	2026-02-09 20:58:16.436508	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 9}
6	1	5	2026-02-09 20:49:16.436508	2026-02-09 20:59:16.436508	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 10}
7	1	5	2026-02-09 20:49:16.436508	2026-02-09 21:00:16.436508	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 11}
8	1	5	2026-02-09 20:49:16.436508	2026-02-09 21:01:16.436508	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 12}
9	1	5	2026-02-09 20:49:16.436508	2026-02-09 21:02:16.436508	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 13}
10	1	5	2026-02-09 20:49:16.436508	2026-02-09 21:03:16.436508	\N	\N	world.player_movement	{"x": 10, "y": 8, "moveCost": 1, "totalMoveCost": 14}
11	1	5	2026-02-09 20:49:16.436508	2026-02-09 21:04:16.436508	\N	\N	world.player_movement	{"x": 10, "y": 7, "moveCost": 1, "totalMoveCost": 15}
129	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:38:37.010592	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 6}
12	1	5	2026-02-09 20:53:06.779883	2026-02-09 20:53:06.779883	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
13	1	5	2026-02-09 20:53:06.779883	2026-02-09 20:56:06.779883	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 1, "totalMoveCost": 3}
14	1	5	2026-02-09 20:53:06.779883	2026-02-09 20:57:06.779883	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 4}
15	1	5	2026-02-09 20:53:06.779883	2026-02-09 20:58:06.779883	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 5}
16	1	5	2026-02-09 20:53:06.779883	2026-02-09 20:59:06.779883	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 6}
17	1	5	2026-02-09 20:53:06.779883	2026-02-09 21:02:06.779883	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 9}
18	1	5	2026-02-09 20:53:06.779883	2026-02-09 21:03:06.779883	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 10}
19	1	5	2026-02-09 20:53:06.779883	2026-02-09 21:04:06.779883	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 11}
20	1	5	2026-02-09 20:53:06.779883	2026-02-09 21:05:06.779883	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 12}
21	1	5	2026-02-09 20:53:06.779883	2026-02-09 21:06:06.779883	\N	\N	world.player_movement	{"x": 10, "y": 8, "moveCost": 1, "totalMoveCost": 13}
130	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:39:37.010592	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 7}
131	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:42:37.010592	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 10}
132	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:43:37.010592	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 11}
133	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:44:37.010592	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 12}
134	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:45:37.010592	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 13}
135	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:46:37.010592	\N	\N	world.player_movement	{"x": 10, "y": 10, "moveCost": 3, "totalMoveCost": 14}
136	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:49:37.010592	\N	\N	world.player_movement	{"x": 11, "y": 11, "moveCost": 3, "totalMoveCost": 17}
137	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:52:37.010592	\N	\N	world.player_movement	{"x": 12, "y": 12, "moveCost": 1, "totalMoveCost": 20}
138	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:53:37.010592	\N	\N	world.player_movement	{"x": 13, "y": 12, "moveCost": 1, "totalMoveCost": 21}
139	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:54:37.010592	\N	\N	world.player_movement	{"x": 14, "y": 13, "moveCost": 1, "totalMoveCost": 22}
140	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:55:37.010592	\N	\N	world.player_movement	{"x": 15, "y": 12, "moveCost": 1, "totalMoveCost": 23}
141	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:56:37.010592	\N	\N	world.player_movement	{"x": 16, "y": 11, "moveCost": 1, "totalMoveCost": 24}
142	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:57:37.010592	\N	\N	world.player_movement	{"x": 17, "y": 11, "moveCost": 1, "totalMoveCost": 25}
143	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:58:37.010592	\N	\N	world.player_movement	{"x": 18, "y": 12, "moveCost": 1, "totalMoveCost": 26}
144	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:59:37.010592	\N	\N	world.player_movement	{"x": 19, "y": 12, "moveCost": 3, "totalMoveCost": 27}
145	1	3	2026-02-09 22:32:37.010592	2026-02-09 23:02:37.010592	\N	\N	world.player_movement	{"x": 20, "y": 11, "moveCost": 1, "totalMoveCost": 30}
146	1	3	2026-02-09 22:32:37.010592	2026-02-09 23:03:37.010592	\N	\N	world.player_movement	{"x": 21, "y": 10, "moveCost": 1, "totalMoveCost": 31}
147	1	3	2026-02-09 22:32:37.010592	2026-02-09 23:04:37.010592	\N	\N	world.player_movement	{"x": 22, "y": 11, "moveCost": 1, "totalMoveCost": 32}
148	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:41:27.244905	\N	\N	world.player_movement	{"x": 22, "y": 11, "moveCost": 1, "totalMoveCost": 0}
149	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:42:27.244905	\N	\N	world.player_movement	{"x": 21, "y": 10, "moveCost": 1, "totalMoveCost": 1}
150	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:43:27.244905	\N	\N	world.player_movement	{"x": 20, "y": 11, "moveCost": 1, "totalMoveCost": 2}
22	1	5	2026-02-09 20:53:06.779883	2026-02-09 21:07:06.779883	\N	\N	world.player_movement	{"x": 10, "y": 7, "moveCost": 1, "totalMoveCost": 14}
23	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:02:54.074743	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
24	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:05:54.074743	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 1, "totalMoveCost": 3}
25	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:06:54.074743	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 4}
26	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:07:54.074743	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 5}
27	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:08:54.074743	\N	\N	world.player_movement	{"x": 6, "y": 6, "moveCost": 1, "totalMoveCost": 6}
28	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:09:54.074743	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 3, "totalMoveCost": 7}
29	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:12:54.074743	\N	\N	world.player_movement	{"x": 8, "y": 6, "moveCost": 3, "totalMoveCost": 10}
30	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:15:54.074743	\N	\N	world.player_movement	{"x": 9, "y": 5, "moveCost": 1, "totalMoveCost": 13}
31	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:16:54.074743	\N	\N	world.player_movement	{"x": 10, "y": 5, "moveCost": 1, "totalMoveCost": 14}
32	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:17:54.074743	\N	\N	world.player_movement	{"x": 11, "y": 6, "moveCost": 3, "totalMoveCost": 15}
33	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:20:54.074743	\N	\N	world.player_movement	{"x": 12, "y": 6, "moveCost": 1, "totalMoveCost": 18}
34	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:21:54.074743	\N	\N	world.player_movement	{"x": 13, "y": 5, "moveCost": 6, "totalMoveCost": 19}
35	1	5	2026-02-09 21:02:54.074743	2026-02-09 21:27:54.074743	\N	\N	world.player_movement	{"x": 14, "y": 4, "moveCost": 1, "totalMoveCost": 25}
36	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:05:52.714292	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
37	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:08:52.714292	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 1, "totalMoveCost": 3}
38	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:09:52.714292	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 4}
39	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:10:52.714292	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 5}
40	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:11:52.714292	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 6}
41	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:14:52.714292	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 9}
160	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:57:27.244905	\N	\N	world.player_movement	{"x": 10, "y": 10, "moveCost": 3, "totalMoveCost": 16}
161	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:00:27.244905	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 19}
162	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:01:27.244905	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 20}
163	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:02:27.244905	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 21}
164	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:03:27.244905	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 22}
165	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:04:27.244905	\N	\N	world.player_movement	{"x": 5, "y": 7, "moveCost": 3, "totalMoveCost": 23}
166	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:07:27.244905	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 26}
167	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:08:27.244905	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 27}
168	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:09:27.244905	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 28}
169	1	3	2026-02-09 23:41:27.244905	2026-02-10 00:11:27.244905	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 9, "totalMoveCost": 30}
42	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:15:52.714292	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 10}
43	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:16:52.714292	\N	\N	world.player_movement	{"x": 7, "y": 10, "moveCost": 1, "totalMoveCost": 11}
44	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:17:52.714292	\N	\N	world.player_movement	{"x": 7, "y": 11, "moveCost": 1, "totalMoveCost": 12}
45	1	5	2026-02-09 21:05:52.714292	2026-02-09 21:18:52.714292	\N	\N	world.player_movement	{"x": 8, "y": 12, "moveCost": 1, "totalMoveCost": 13}
46	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:05:56.303296	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
47	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:08:56.303296	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 1, "totalMoveCost": 3}
48	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:09:56.303296	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 4}
49	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:10:56.303296	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 5}
50	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:11:56.303296	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 6}
51	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:14:56.303296	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 9}
52	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:15:56.303296	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 10}
53	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:16:56.303296	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 11}
54	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:17:56.303296	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 12}
55	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:18:56.303296	\N	\N	world.player_movement	{"x": 10, "y": 8, "moveCost": 1, "totalMoveCost": 13}
56	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:19:56.303296	\N	\N	world.player_movement	{"x": 11, "y": 8, "moveCost": 1, "totalMoveCost": 14}
57	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:20:56.303296	\N	\N	world.player_movement	{"x": 12, "y": 7, "moveCost": 1, "totalMoveCost": 15}
58	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:21:56.303296	\N	\N	world.player_movement	{"x": 13, "y": 6, "moveCost": 1, "totalMoveCost": 16}
59	1	5	2026-02-09 21:05:56.303296	2026-02-09 21:22:56.303296	\N	\N	world.player_movement	{"x": 14, "y": 6, "moveCost": 6, "totalMoveCost": 17}
60	1	5	2026-02-09 21:27:19.697277	2026-02-09 21:27:19.697277	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
61	1	5	2026-02-09 21:27:19.697277	2026-02-09 21:30:19.697277	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 3}
62	1	5	2026-02-09 21:27:19.697277	2026-02-09 21:32:19.697277	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 5}
63	1	5	2026-02-09 21:27:19.697277	2026-02-09 21:33:19.697277	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 6}
64	1	5	2026-02-09 21:27:19.697277	2026-02-09 21:34:19.697277	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 7}
179	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:56:31.250709	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 15}
180	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:57:31.250709	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 16}
181	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:58:31.250709	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 17}
182	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:59:31.250709	\N	\N	world.player_movement	{"x": 5, "y": 7, "moveCost": 3, "totalMoveCost": 18}
183	2	3	2026-02-09 23:41:31.250709	2026-02-10 00:02:31.250709	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 21}
184	2	3	2026-02-09 23:41:31.250709	2026-02-10 00:03:31.250709	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 22}
185	2	3	2026-02-09 23:41:31.250709	2026-02-10 00:04:31.250709	\N	\N	world.player_movement	{"x": 5, "y": 4, "moveCost": 3, "totalMoveCost": 23}
65	1	5	2026-02-09 21:27:19.697277	2026-02-09 21:37:19.697277	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 10}
91	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:32:18.088061	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
92	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:35:18.088061	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 3}
93	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:37:18.088061	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 5}
94	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:38:18.088061	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 6}
95	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:39:18.088061	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 7}
96	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:42:18.088061	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 10}
97	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:43:18.088061	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 11}
98	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:44:18.088061	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 12}
99	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:45:18.088061	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 13}
100	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:46:18.088061	\N	\N	world.player_movement	{"x": 10, "y": 8, "moveCost": 1, "totalMoveCost": 14}
101	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:47:18.088061	\N	\N	world.player_movement	{"x": 11, "y": 8, "moveCost": 1, "totalMoveCost": 15}
102	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:48:18.088061	\N	\N	world.player_movement	{"x": 12, "y": 7, "moveCost": 1, "totalMoveCost": 16}
103	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:49:18.088061	\N	\N	world.player_movement	{"x": 13, "y": 8, "moveCost": 3, "totalMoveCost": 17}
104	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:52:18.088061	\N	\N	world.player_movement	{"x": 14, "y": 8, "moveCost": 3, "totalMoveCost": 20}
105	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:55:18.088061	\N	\N	world.player_movement	{"x": 15, "y": 7, "moveCost": 1, "totalMoveCost": 23}
106	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:56:18.088061	\N	\N	world.player_movement	{"x": 16, "y": 8, "moveCost": 1, "totalMoveCost": 24}
107	2	3	2026-02-09 22:32:18.088061	2026-02-09 22:57:18.088061	\N	\N	world.player_movement	{"x": 16, "y": 9, "moveCost": 3, "totalMoveCost": 25}
151	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:44:27.244905	\N	\N	world.player_movement	{"x": 19, "y": 12, "moveCost": 3, "totalMoveCost": 3}
152	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:47:27.244905	\N	\N	world.player_movement	{"x": 18, "y": 12, "moveCost": 1, "totalMoveCost": 6}
153	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:48:27.244905	\N	\N	world.player_movement	{"x": 17, "y": 11, "moveCost": 1, "totalMoveCost": 7}
154	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:49:27.244905	\N	\N	world.player_movement	{"x": 16, "y": 11, "moveCost": 1, "totalMoveCost": 8}
155	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:50:27.244905	\N	\N	world.player_movement	{"x": 15, "y": 12, "moveCost": 1, "totalMoveCost": 9}
156	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:51:27.244905	\N	\N	world.player_movement	{"x": 14, "y": 13, "moveCost": 1, "totalMoveCost": 10}
191	5	3	2026-02-09 23:41:42.522128	2026-02-09 23:44:42.522128	\N	\N	world.player_movement	{"x": 2, "y": 2, "moveCost": 4, "totalMoveCost": 3}
192	5	3	2026-02-09 23:41:42.522128	2026-02-09 23:48:42.522128	\N	\N	world.player_movement	{"x": 1, "y": 1, "moveCost": 6, "totalMoveCost": 7}
66	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:32:12.431068	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
67	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:35:12.431068	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 3}
68	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:37:12.431068	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 5}
69	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:38:12.431068	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 6}
70	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:39:12.431068	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 7}
71	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:42:12.431068	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 10}
72	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:43:12.431068	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 11}
73	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:44:12.431068	\N	\N	world.player_movement	{"x": 7, "y": 10, "moveCost": 1, "totalMoveCost": 12}
74	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:45:12.431068	\N	\N	world.player_movement	{"x": 7, "y": 11, "moveCost": 1, "totalMoveCost": 13}
75	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:46:12.431068	\N	\N	world.player_movement	{"x": 8, "y": 12, "moveCost": 1, "totalMoveCost": 14}
76	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:47:12.431068	\N	\N	world.player_movement	{"x": 8, "y": 13, "moveCost": 1, "totalMoveCost": 15}
77	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:48:12.431068	\N	\N	world.player_movement	{"x": 9, "y": 14, "moveCost": 3, "totalMoveCost": 16}
78	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:51:12.431068	\N	\N	world.player_movement	{"x": 10, "y": 15, "moveCost": 3, "totalMoveCost": 19}
79	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:54:12.431068	\N	\N	world.player_movement	{"x": 11, "y": 16, "moveCost": 1, "totalMoveCost": 22}
80	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:55:12.431068	\N	\N	world.player_movement	{"x": 12, "y": 17, "moveCost": 3, "totalMoveCost": 23}
81	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:58:12.431068	\N	\N	world.player_movement	{"x": 13, "y": 18, "moveCost": 1, "totalMoveCost": 26}
82	1	5	2026-02-09 22:32:12.431068	2026-02-09 22:59:12.431068	\N	\N	world.player_movement	{"x": 14, "y": 19, "moveCost": 1, "totalMoveCost": 27}
83	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:00:12.431068	\N	\N	world.player_movement	{"x": 15, "y": 18, "moveCost": 1, "totalMoveCost": 28}
84	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:01:12.431068	\N	\N	world.player_movement	{"x": 16, "y": 18, "moveCost": 1, "totalMoveCost": 29}
85	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:02:12.431068	\N	\N	world.player_movement	{"x": 17, "y": 19, "moveCost": 1, "totalMoveCost": 30}
86	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:03:12.431068	\N	\N	world.player_movement	{"x": 17, "y": 20, "moveCost": 3, "totalMoveCost": 31}
87	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:06:12.431068	\N	\N	world.player_movement	{"x": 18, "y": 21, "moveCost": 1, "totalMoveCost": 34}
88	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:07:12.431068	\N	\N	world.player_movement	{"x": 19, "y": 22, "moveCost": 1, "totalMoveCost": 35}
89	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:08:12.431068	\N	\N	world.player_movement	{"x": 20, "y": 23, "moveCost": 1, "totalMoveCost": 36}
90	1	5	2026-02-09 22:32:12.431068	2026-02-09 23:09:12.431068	\N	\N	world.player_movement	{"x": 21, "y": 23, "moveCost": 5, "totalMoveCost": 37}
193	4	5	2026-02-09 23:41:50.168055	2026-02-09 23:41:50.168055	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
194	4	5	2026-02-09 23:41:50.168055	2026-02-09 23:44:50.168055	\N	\N	world.player_movement	{"x": 4, "y": 2, "moveCost": 6, "totalMoveCost": 3}
195	4	5	2026-02-09 23:41:50.168055	2026-02-09 23:50:50.168055	\N	\N	world.player_movement	{"x": 5, "y": 1, "moveCost": 12, "totalMoveCost": 9}
157	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:52:27.244905	\N	\N	world.player_movement	{"x": 13, "y": 12, "moveCost": 1, "totalMoveCost": 11}
158	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:53:27.244905	\N	\N	world.player_movement	{"x": 12, "y": 12, "moveCost": 1, "totalMoveCost": 12}
159	1	3	2026-02-09 23:41:27.244905	2026-02-09 23:54:27.244905	\N	\N	world.player_movement	{"x": 11, "y": 11, "moveCost": 3, "totalMoveCost": 13}
190	5	3	2026-02-09 23:41:42.522128	2026-02-09 23:41:42.522128	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
170	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:41:31.250709	\N	\N	world.player_movement	{"x": 16, "y": 9, "moveCost": 3, "totalMoveCost": 0}
171	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:44:31.250709	\N	\N	world.player_movement	{"x": 16, "y": 8, "moveCost": 1, "totalMoveCost": 3}
172	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:45:31.250709	\N	\N	world.player_movement	{"x": 15, "y": 7, "moveCost": 1, "totalMoveCost": 4}
173	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:46:31.250709	\N	\N	world.player_movement	{"x": 14, "y": 8, "moveCost": 3, "totalMoveCost": 5}
174	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:49:31.250709	\N	\N	world.player_movement	{"x": 13, "y": 7, "moveCost": 3, "totalMoveCost": 8}
175	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:52:31.250709	\N	\N	world.player_movement	{"x": 12, "y": 7, "moveCost": 1, "totalMoveCost": 11}
176	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:53:31.250709	\N	\N	world.player_movement	{"x": 11, "y": 8, "moveCost": 1, "totalMoveCost": 12}
177	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:54:31.250709	\N	\N	world.player_movement	{"x": 10, "y": 8, "moveCost": 1, "totalMoveCost": 13}
108	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:32:24.216228	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
109	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:35:24.216228	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 3}
110	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:37:24.216228	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 5}
111	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:38:24.216228	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 6}
112	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:39:24.216228	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 7}
113	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:42:24.216228	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 10}
114	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:43:24.216228	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 11}
115	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:44:24.216228	\N	\N	world.player_movement	{"x": 7, "y": 10, "moveCost": 1, "totalMoveCost": 12}
116	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:45:24.216228	\N	\N	world.player_movement	{"x": 7, "y": 11, "moveCost": 1, "totalMoveCost": 13}
117	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:46:24.216228	\N	\N	world.player_movement	{"x": 8, "y": 12, "moveCost": 1, "totalMoveCost": 14}
118	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:47:24.216228	\N	\N	world.player_movement	{"x": 8, "y": 13, "moveCost": 1, "totalMoveCost": 15}
119	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:48:24.216228	\N	\N	world.player_movement	{"x": 9, "y": 14, "moveCost": 3, "totalMoveCost": 16}
120	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:51:24.216228	\N	\N	world.player_movement	{"x": 10, "y": 15, "moveCost": 3, "totalMoveCost": 19}
121	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:54:24.216228	\N	\N	world.player_movement	{"x": 11, "y": 16, "moveCost": 1, "totalMoveCost": 22}
122	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:55:24.216228	\N	\N	world.player_movement	{"x": 12, "y": 17, "moveCost": 3, "totalMoveCost": 23}
123	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:58:24.216228	\N	\N	world.player_movement	{"x": 13, "y": 18, "moveCost": 1, "totalMoveCost": 26}
124	1	5	2026-02-09 22:32:24.216228	2026-02-09 22:59:24.216228	\N	\N	world.player_movement	{"x": 14, "y": 17, "moveCost": 1, "totalMoveCost": 27}
125	1	5	2026-02-09 22:32:24.216228	2026-02-09 23:00:24.216228	\N	\N	world.player_movement	{"x": 15, "y": 18, "moveCost": 1, "totalMoveCost": 28}
126	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:32:37.010592	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
127	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:35:37.010592	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 3}
128	1	3	2026-02-09 22:32:37.010592	2026-02-09 22:37:37.010592	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 5}
178	2	3	2026-02-09 23:41:31.250709	2026-02-09 23:55:31.250709	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 14}
186	3	3	2026-02-09 23:41:36.330802	2026-02-09 23:41:36.330802	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
187	3	3	2026-02-09 23:41:36.330802	2026-02-09 23:44:36.330802	\N	\N	world.player_movement	{"x": 4, "y": 3, "moveCost": 2, "totalMoveCost": 3}
188	3	3	2026-02-09 23:41:36.330802	2026-02-09 23:46:36.330802	\N	\N	world.player_movement	{"x": 5, "y": 4, "moveCost": 3, "totalMoveCost": 5}
189	3	3	2026-02-09 23:41:36.330802	2026-02-09 23:49:36.330802	\N	\N	world.player_movement	{"x": 6, "y": 3, "moveCost": 11, "totalMoveCost": 8}
196	4	3	2026-02-09 23:42:07.202407	2026-02-09 23:42:07.202407	\N	\N	world.player_movement	{"x": 3, "y": 3, "moveCost": 3, "totalMoveCost": 0}
197	4	3	2026-02-09 23:42:07.202407	2026-02-09 23:45:07.202407	\N	\N	world.player_movement	{"x": 4, "y": 3, "moveCost": 2, "totalMoveCost": 3}
198	4	3	2026-02-09 23:42:07.202407	2026-02-09 23:47:07.202407	\N	\N	world.player_movement	{"x": 5, "y": 2, "moveCost": 9, "totalMoveCost": 5}
199	4	3	2026-02-09 23:42:07.202407	2026-02-09 23:56:07.202407	\N	\N	world.player_movement	{"x": 6, "y": 1, "moveCost": 6, "totalMoveCost": 14}
200	4	3	2026-02-09 23:42:07.202407	2026-02-10 00:02:07.202407	\N	\N	world.player_movement	{"x": 7, "y": 1, "moveCost": 7, "totalMoveCost": 20}
201	1	3	2026-02-10 00:13:23.493752	2026-02-10 00:13:23.493752	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 9, "totalMoveCost": 0}
202	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:22:23.493752	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 9}
203	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:24:23.493752	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 11}
204	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:25:23.493752	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 12}
205	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:26:23.493752	\N	\N	world.player_movement	{"x": 6, "y": 6, "moveCost": 1, "totalMoveCost": 13}
212	4	1	2026-02-10 00:17:34.623298	2026-02-10 00:24:34.623298	\N	\N	world.player_movement	{"x": 6, "y": 2, "moveCost": 6, "totalMoveCost": 7}
213	4	1	2026-02-10 00:17:34.623298	2026-02-10 00:30:34.623298	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 9, "totalMoveCost": 13}
214	4	1	2026-02-10 00:17:34.623298	2026-02-10 00:39:34.623298	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 22}
215	4	1	2026-02-10 00:17:34.623298	2026-02-10 00:41:34.623298	\N	\N	world.player_movement	{"x": 3, "y": 5, "moveCost": 6, "totalMoveCost": 24}
211	4	3	2026-02-10 00:17:34.623298	2026-02-10 00:17:34.623298	\N	\N	world.player_movement	{"x": 7, "y": 1, "moveCost": 7, "totalMoveCost": 0}
206	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:27:23.493752	\N	\N	world.player_movement	{"x": 7, "y": 6, "moveCost": 3, "totalMoveCost": 14}
207	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:30:23.493752	\N	\N	world.player_movement	{"x": 8, "y": 6, "moveCost": 3, "totalMoveCost": 17}
208	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:33:23.493752	\N	\N	world.player_movement	{"x": 9, "y": 5, "moveCost": 1, "totalMoveCost": 20}
209	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:34:23.493752	\N	\N	world.player_movement	{"x": 10, "y": 4, "moveCost": 4, "totalMoveCost": 21}
210	1	5	2026-02-10 00:13:23.493752	2026-02-10 00:38:23.493752	\N	\N	world.player_movement	{"x": 9, "y": 3, "moveCost": 6, "totalMoveCost": 25}
216	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:19:23.199265	\N	\N	world.player_movement	{"x": 5, "y": 3, "moveCost": 9, "totalMoveCost": 0}
217	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:28:23.199265	\N	\N	world.player_movement	{"x": 4, "y": 4, "moveCost": 2, "totalMoveCost": 9}
218	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:30:23.199265	\N	\N	world.player_movement	{"x": 4, "y": 5, "moveCost": 1, "totalMoveCost": 11}
219	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:31:23.199265	\N	\N	world.player_movement	{"x": 5, "y": 6, "moveCost": 1, "totalMoveCost": 12}
220	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:32:23.199265	\N	\N	world.player_movement	{"x": 6, "y": 7, "moveCost": 3, "totalMoveCost": 13}
221	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:35:23.199265	\N	\N	world.player_movement	{"x": 6, "y": 8, "moveCost": 1, "totalMoveCost": 16}
222	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:36:23.199265	\N	\N	world.player_movement	{"x": 7, "y": 9, "moveCost": 1, "totalMoveCost": 17}
223	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:37:23.199265	\N	\N	world.player_movement	{"x": 8, "y": 9, "moveCost": 1, "totalMoveCost": 18}
224	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:38:23.199265	\N	\N	world.player_movement	{"x": 9, "y": 9, "moveCost": 1, "totalMoveCost": 19}
225	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:39:23.199265	\N	\N	world.player_movement	{"x": 10, "y": 8, "moveCost": 1, "totalMoveCost": 20}
226	1	1	2026-02-11 17:19:23.199265	2026-02-11 17:40:23.199265	\N	\N	world.player_movement	{"x": 10, "y": 7, "moveCost": 1, "totalMoveCost": 21}
\.


--
-- TOC entry 5328 (class 0 OID 21502)
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
-- TOC entry 5329 (class 0 OID 21510)
-- Dependencies: 247
-- Data for Name: map_tiles; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles (map_id, x, y, terrain_type_id, landscape_type_id) FROM stdin;
1	11	1	3	\N
1	13	1	4	\N
1	14	1	4	7
1	15	1	5	\N
1	16	1	5	6
1	17	1	5	8
1	18	1	5	\N
1	19	1	5	8
1	20	1	5	\N
1	21	1	3	2
1	22	1	3	2
1	23	1	3	3
1	24	1	3	2
1	25	1	3	3
1	26	1	3	3
1	27	1	4	7
1	28	1	4	\N
1	29	1	4	\N
1	30	1	4	\N
1	1	2	4	\N
1	2	2	7	\N
1	3	2	1	9
1	4	2	5	\N
1	5	2	5	6
1	6	2	5	\N
1	7	2	6	\N
1	8	2	5	6
1	9	2	5	\N
1	10	2	3	\N
1	11	2	6	\N
1	12	2	3	2
1	13	2	3	3
1	14	2	4	7
1	15	2	4	\N
1	16	2	7	\N
1	17	2	7	\N
1	18	2	5	8
1	19	2	5	6
1	20	2	2	1
1	21	2	3	2
1	22	2	3	3
1	23	2	7	\N
1	24	2	3	\N
1	25	2	5	\N
1	26	2	3	\N
1	27	2	2	1
1	28	2	5	8
1	29	2	4	\N
1	30	2	4	7
1	1	3	4	7
1	2	3	1	1
1	3	3	1	9
1	4	3	1	\N
1	5	3	5	6
1	6	3	4	7
1	7	3	5	8
1	8	3	5	8
1	9	3	5	\N
1	10	3	5	6
1	11	3	4	7
1	12	3	3	\N
1	13	3	3	3
1	14	3	3	\N
1	15	3	4	7
1	16	3	4	7
1	17	3	7	\N
1	18	3	5	6
1	19	3	5	8
1	20	3	5	6
1	21	3	3	\N
1	22	3	1	\N
1	23	3	3	3
1	24	3	3	3
1	25	3	3	2
1	26	3	3	\N
1	27	3	3	2
1	28	3	2	1
1	29	3	4	7
1	30	3	4	7
1	1	4	1	9
1	2	4	1	1
1	3	4	6	\N
1	4	4	1	\N
1	5	4	1	9
1	6	4	5	\N
1	7	4	5	8
1	8	4	5	6
1	9	4	5	8
1	10	4	7	\N
1	11	4	3	3
1	12	4	3	2
1	13	4	3	3
1	14	4	3	\N
1	15	4	3	3
1	16	4	3	\N
1	17	4	3	3
1	18	4	5	8
1	19	4	4	7
1	20	4	6	\N
1	21	4	1	1
1	22	4	4	7
1	23	4	3	3
1	24	4	2	1
1	25	4	3	2
1	26	4	3	3
1	27	4	2	\N
1	28	4	2	1
1	29	4	2	\N
1	30	4	4	7
1	1	5	7	\N
1	2	5	1	9
1	3	5	4	\N
1	4	5	1	\N
1	5	5	1	9
1	6	5	1	9
1	7	5	3	2
1	8	5	5	8
1	9	5	2	\N
1	10	5	2	\N
1	11	5	3	3
1	12	5	5	6
1	13	5	3	2
1	14	5	3	3
1	15	5	3	\N
1	16	5	3	2
1	17	5	3	3
1	18	5	3	2
1	19	5	3	\N
1	20	5	5	8
1	21	5	1	1
1	22	5	1	1
1	23	5	1	9
1	24	5	3	3
1	25	5	2	\N
1	26	5	3	\N
1	27	5	2	1
1	28	5	1	\N
1	29	5	2	\N
1	30	5	2	1
1	1	6	1	9
1	2	6	1	1
1	3	6	1	1
1	4	6	1	\N
1	5	6	1	\N
1	6	6	1	\N
1	7	6	1	9
1	8	6	1	1
1	9	6	4	\N
1	10	6	2	1
1	11	6	2	1
1	12	6	2	\N
1	13	6	3	\N
1	14	6	3	3
1	15	6	4	\N
1	16	6	3	3
1	7	1	3	8
1	8	1	3	6
1	3	1	1	9
1	5	1	4	8
1	4	1	4	\N
1	12	1	4	2
1	6	1	4	\N
1	9	1	1	8
1	10	1	1	2
1	17	6	3	3
1	18	6	3	2
1	19	6	3	2
1	20	6	2	1
1	21	6	1	1
1	22	6	1	1
1	23	6	1	1
1	24	6	3	3
1	25	6	3	3
1	26	6	2	1
1	27	6	2	1
1	28	6	2	1
1	29	6	2	\N
1	30	6	2	\N
1	1	7	1	9
1	2	7	5	6
1	3	7	1	9
1	4	7	1	\N
1	5	7	1	1
1	6	7	1	1
1	7	7	4	7
1	8	7	1	1
1	9	7	1	1
1	10	7	2	\N
1	11	7	2	1
1	12	7	2	\N
1	13	7	2	1
1	14	7	3	2
1	15	7	3	\N
1	16	7	3	\N
1	17	7	3	2
1	18	7	4	7
1	19	7	3	2
1	20	7	3	\N
1	21	7	1	1
1	22	7	1	\N
1	23	7	1	1
1	24	7	1	9
1	25	7	3	3
1	26	7	2	1
1	27	7	2	1
1	28	7	2	1
1	29	7	2	\N
1	30	7	2	\N
1	1	8	1	9
1	2	8	1	1
1	3	8	3	2
1	4	8	1	1
1	5	8	1	1
1	6	8	3	\N
1	7	8	1	1
1	8	8	1	9
1	9	8	1	9
1	10	8	1	\N
1	11	8	2	\N
1	12	8	2	1
1	13	8	2	1
1	14	8	2	1
1	15	8	7	\N
1	16	8	3	\N
1	17	8	6	\N
1	18	8	1	1
1	19	8	7	\N
1	20	8	3	2
1	21	8	3	\N
1	22	8	7	\N
1	23	8	1	9
1	24	8	1	\N
1	25	8	1	1
1	26	8	7	\N
1	27	8	2	\N
1	28	8	2	\N
1	29	8	2	\N
1	30	8	2	\N
1	1	9	1	9
1	2	9	1	9
1	3	9	1	1
1	4	9	1	1
1	5	9	1	\N
1	6	9	2	\N
1	7	9	1	\N
1	8	9	1	\N
1	9	9	1	\N
1	10	9	1	1
1	11	9	1	9
1	12	9	2	1
1	13	9	2	1
1	14	9	2	1
1	15	9	2	1
1	16	9	2	1
1	17	9	1	9
1	18	9	3	3
1	19	9	3	3
1	20	9	3	3
1	21	9	3	3
1	22	9	3	\N
1	23	9	1	1
1	24	9	1	\N
1	25	9	1	\N
1	26	9	1	1
1	27	9	2	1
1	28	9	2	\N
1	29	9	2	1
1	30	9	2	1
1	1	10	1	1
1	2	10	1	9
1	3	10	1	1
1	4	10	1	1
1	5	10	7	\N
1	6	10	1	1
1	7	10	3	\N
1	8	10	1	1
1	9	10	1	9
1	10	10	1	9
1	11	10	1	9
1	12	10	1	\N
1	13	10	2	1
1	14	10	2	1
1	15	10	3	3
1	16	10	2	1
1	17	10	2	1
1	18	10	3	3
1	19	10	3	3
1	20	10	6	\N
1	21	10	3	\N
1	22	10	3	\N
1	23	10	5	8
1	24	10	1	1
1	25	10	1	9
1	26	10	4	\N
1	27	10	2	1
1	28	10	7	\N
1	29	10	2	1
1	30	10	3	2
1	1	11	1	1
1	2	11	1	\N
1	3	11	1	9
1	4	11	1	\N
1	5	11	1	9
1	6	11	4	\N
1	7	11	1	\N
1	8	11	1	9
1	9	11	1	9
1	10	11	1	\N
1	11	11	1	1
1	12	11	1	1
1	13	11	1	1
1	14	11	2	1
1	15	11	2	\N
1	16	11	2	\N
1	17	11	2	\N
1	18	11	2	1
1	19	11	3	3
1	20	11	3	\N
1	21	11	2	1
1	22	11	3	\N
1	23	11	3	3
1	24	11	1	9
1	25	11	1	9
1	26	11	1	9
1	27	11	1	9
1	28	11	4	\N
1	29	11	2	1
1	30	11	4	7
1	1	12	2	1
1	2	12	1	1
1	3	12	1	1
1	4	12	1	\N
1	5	12	1	9
1	6	12	1	1
1	7	12	1	9
1	8	12	1	\N
1	9	12	1	\N
1	10	12	1	9
1	11	12	1	9
1	12	12	1	\N
1	13	12	1	\N
1	14	12	1	1
1	15	12	2	\N
1	16	12	2	\N
1	17	12	2	1
1	18	12	2	\N
1	19	12	2	1
1	20	12	2	1
1	21	12	2	1
1	22	12	2	1
1	23	12	3	\N
1	24	12	1	\N
1	25	12	1	9
1	26	12	1	9
1	27	12	1	9
1	28	12	1	\N
1	29	12	4	\N
1	30	12	4	7
1	1	13	1	\N
1	2	13	1	9
1	3	13	1	9
1	4	13	1	1
1	5	13	3	3
1	6	13	1	9
1	7	13	1	1
1	8	13	1	\N
1	9	13	6	\N
1	10	13	1	1
1	11	13	1	9
1	12	13	1	1
1	13	13	5	\N
1	14	13	1	\N
1	15	13	1	1
1	16	13	2	1
1	17	13	2	1
1	18	13	2	1
1	19	13	2	1
1	20	13	2	\N
1	21	13	4	\N
1	22	13	2	\N
1	23	13	6	\N
1	24	13	1	\N
1	25	13	1	\N
1	26	13	1	1
1	27	13	1	9
1	28	13	1	9
1	29	13	1	\N
1	30	13	4	7
1	1	14	1	1
1	2	14	1	9
1	3	14	1	9
1	4	14	1	9
1	5	14	1	9
1	6	14	1	1
1	7	14	1	\N
1	8	14	7	\N
1	9	14	1	9
1	10	14	1	\N
1	11	14	2	1
1	12	14	1	9
1	13	14	1	9
1	14	14	1	1
1	15	14	1	1
1	16	14	1	9
1	17	14	4	7
1	18	14	2	\N
1	19	14	2	1
1	20	14	2	1
1	21	14	2	1
1	22	14	7	\N
1	23	14	1	\N
1	24	14	1	9
1	25	14	1	9
1	26	14	4	7
1	27	14	1	\N
1	28	14	1	1
1	29	14	1	1
1	30	14	1	9
1	1	15	1	9
1	2	15	1	1
1	3	15	1	\N
1	4	15	1	\N
1	5	15	1	1
1	6	15	1	9
1	7	15	1	9
1	8	15	1	\N
1	9	15	5	\N
1	10	15	1	1
1	11	15	7	\N
1	12	15	1	1
1	13	15	1	9
1	14	15	1	\N
1	15	15	1	\N
1	16	15	1	9
1	17	15	1	9
1	18	15	1	\N
1	19	15	7	\N
1	20	15	2	1
1	21	15	2	1
1	22	15	2	1
1	23	15	1	9
1	24	15	1	9
1	25	15	1	9
1	26	15	1	\N
1	27	15	1	9
1	28	15	1	\N
1	29	15	5	6
1	30	15	3	\N
1	1	16	1	\N
1	2	16	1	\N
1	3	16	1	\N
1	4	16	1	\N
1	5	16	1	9
1	6	16	1	1
1	7	16	5	6
1	8	16	1	1
1	9	16	5	\N
1	10	16	7	\N
1	11	16	1	\N
1	12	16	1	1
1	13	16	1	9
1	14	16	1	9
1	15	16	1	9
1	16	16	7	\N
1	17	16	1	1
1	18	16	1	9
1	19	16	1	9
1	20	16	2	\N
1	21	16	2	\N
1	22	16	2	1
1	23	16	1	1
1	24	16	1	9
1	25	16	1	1
1	26	16	1	\N
1	27	16	1	9
1	28	16	1	9
1	29	16	1	\N
1	30	16	1	\N
1	1	17	1	9
1	2	17	6	\N
1	3	17	1	\N
1	4	17	1	\N
1	5	17	1	1
1	6	17	7	\N
1	7	17	5	8
1	8	17	5	8
1	9	17	5	8
1	10	17	5	\N
1	11	17	1	1
1	12	17	1	1
1	13	17	1	\N
1	14	17	1	\N
1	15	17	6	\N
1	16	17	1	\N
1	17	17	3	2
1	18	17	1	\N
1	19	17	1	9
1	20	17	1	1
1	21	17	5	6
1	22	17	3	\N
1	23	17	1	1
1	24	17	1	1
1	25	17	1	1
1	26	17	1	1
1	27	17	1	\N
1	28	17	1	1
1	29	17	1	\N
1	30	17	1	1
1	1	18	1	1
1	2	18	1	\N
1	3	18	1	\N
1	4	18	1	9
1	5	18	1	\N
1	6	18	1	\N
1	7	18	5	8
1	8	18	5	\N
1	9	18	5	6
1	10	18	5	8
1	11	18	1	\N
1	12	18	1	\N
1	13	18	1	\N
1	14	18	1	9
1	15	18	1	\N
1	16	18	1	\N
1	17	18	1	1
1	18	18	1	9
1	19	18	1	9
1	20	18	1	9
1	21	18	1	9
1	22	18	1	1
1	23	18	1	1
1	24	18	1	9
1	25	18	1	9
1	26	18	1	\N
1	27	18	1	1
1	28	18	1	\N
1	29	18	1	9
1	30	18	1	9
1	1	19	1	9
1	2	19	1	1
1	3	19	1	9
1	4	19	1	9
1	5	19	1	\N
1	6	19	1	1
1	7	19	1	1
1	8	19	5	6
1	9	19	5	\N
1	10	19	5	6
1	11	19	1	9
1	12	19	1	\N
1	13	19	1	9
1	14	19	1	\N
1	15	19	7	\N
1	16	19	1	1
1	17	19	1	\N
1	18	19	1	9
1	19	19	1	9
1	20	19	6	\N
1	21	19	1	9
1	22	19	1	9
1	23	19	1	9
1	24	19	7	\N
1	25	19	1	1
1	26	19	1	\N
1	27	19	3	\N
1	28	19	1	\N
1	29	19	1	1
1	30	19	1	\N
1	1	20	1	\N
1	2	20	1	\N
1	3	20	4	\N
1	4	20	1	\N
1	5	20	1	9
1	6	20	1	1
1	7	20	1	9
1	8	20	1	9
1	9	20	5	\N
1	10	20	6	\N
1	11	20	1	\N
1	12	20	1	\N
1	13	20	1	1
1	14	20	1	9
1	15	20	1	\N
1	16	20	1	1
1	17	20	1	1
1	18	20	4	\N
1	19	20	3	2
1	20	20	1	1
1	21	20	1	\N
1	22	20	1	\N
1	23	20	1	1
1	24	20	1	9
1	25	20	1	9
1	26	20	1	1
1	27	20	1	\N
1	28	20	1	1
1	29	20	7	\N
1	30	20	1	1
1	1	21	1	1
1	2	21	1	9
1	3	21	1	9
1	4	21	2	\N
1	5	21	1	9
1	6	21	1	1
1	7	21	1	\N
1	8	21	1	1
1	9	21	1	1
1	10	21	1	9
1	11	21	1	9
1	12	21	1	\N
1	13	21	1	1
1	14	21	1	1
1	15	21	1	\N
1	16	21	5	8
1	17	21	1	9
1	18	21	1	\N
1	19	21	1	\N
1	20	21	1	1
1	21	21	1	\N
1	22	21	1	\N
1	23	21	1	9
1	24	21	1	9
1	25	21	1	\N
1	26	21	4	\N
1	27	21	1	\N
1	28	21	1	\N
1	29	21	1	1
1	30	21	7	\N
1	1	22	1	\N
1	2	22	1	9
1	3	22	1	9
1	4	22	1	\N
1	5	22	1	1
1	6	22	1	9
1	7	22	1	1
1	8	22	1	1
1	9	22	1	\N
1	10	22	3	2
1	11	22	1	1
1	12	22	3	\N
1	13	22	1	1
1	14	22	1	9
1	15	22	1	\N
1	16	22	1	1
1	17	22	1	9
1	18	22	1	\N
1	19	22	1	\N
1	20	22	1	1
1	21	22	3	2
1	22	22	1	1
1	23	22	1	9
1	24	22	1	9
1	25	22	1	9
1	26	22	1	9
1	27	22	3	\N
1	28	22	1	9
1	29	22	1	1
1	30	22	1	9
1	1	23	4	7
1	2	23	3	\N
1	3	23	1	1
1	4	23	1	\N
1	5	23	1	9
1	6	23	1	9
1	7	23	1	1
1	8	23	1	1
1	9	23	1	9
1	10	23	1	9
1	11	23	1	\N
1	12	23	4	\N
1	13	23	1	9
1	14	23	1	\N
1	15	23	1	\N
1	16	23	1	1
1	17	23	1	9
1	18	23	1	9
1	19	23	3	2
1	20	23	1	\N
1	21	23	6	\N
1	22	23	1	1
1	23	23	1	1
1	24	23	1	1
1	25	23	1	1
1	26	23	5	\N
1	27	23	3	3
1	28	23	1	1
1	29	23	5	6
1	30	23	1	9
1	1	24	3	2
1	2	24	3	\N
1	3	24	1	1
1	4	24	1	1
1	5	24	3	2
1	6	24	3	2
1	7	24	1	\N
1	8	24	1	1
1	9	24	1	9
1	10	24	2	\N
1	11	24	1	1
1	12	24	4	7
1	13	24	1	\N
1	14	24	1	9
1	15	24	1	1
1	16	24	1	\N
1	17	24	1	9
1	18	24	1	9
1	19	24	1	9
1	20	24	1	\N
1	21	24	1	\N
1	22	24	3	\N
1	23	24	1	1
1	24	24	1	1
1	25	24	1	1
1	26	24	1	\N
1	27	24	1	1
1	28	24	1	1
1	29	24	1	9
1	30	24	5	6
1	1	25	3	\N
1	2	25	3	2
1	3	25	1	1
1	4	25	3	2
1	5	25	3	2
1	6	25	3	2
1	7	25	1	1
1	8	25	1	\N
1	9	25	1	9
1	10	25	1	9
1	11	25	6	\N
1	12	25	1	9
1	13	25	5	6
1	14	25	1	9
1	15	25	3	3
1	16	25	1	\N
1	17	25	6	\N
1	18	25	1	1
1	19	25	1	9
1	20	25	1	1
1	21	25	1	\N
1	22	25	1	1
1	23	25	1	1
1	24	25	1	9
1	25	25	4	7
1	26	25	1	\N
1	27	25	1	1
1	28	25	1	1
1	29	25	1	1
1	30	25	1	\N
1	1	26	2	1
1	2	26	3	3
1	3	26	4	\N
1	4	26	3	2
1	5	26	3	3
1	6	26	3	2
1	7	26	1	\N
1	8	26	1	\N
1	9	26	1	1
1	10	26	1	\N
1	11	26	4	7
1	12	26	1	1
1	13	26	5	6
1	14	26	3	2
1	15	26	1	9
1	16	26	1	\N
1	17	26	1	9
1	18	26	1	9
1	19	26	1	\N
1	20	26	3	3
1	21	26	1	\N
1	22	26	3	2
1	23	26	1	9
1	24	26	1	1
1	25	26	1	9
1	26	26	1	9
1	27	26	1	1
1	28	26	1	\N
1	29	26	1	\N
1	30	26	2	1
1	1	27	2	1
1	2	27	2	1
1	3	27	3	\N
1	4	27	7	\N
1	5	27	3	\N
1	6	27	3	\N
1	7	27	1	1
1	8	27	1	1
1	9	27	1	1
1	10	27	1	1
1	11	27	1	9
1	12	27	1	\N
1	13	27	1	\N
1	14	27	1	1
1	15	27	1	9
1	16	27	1	\N
1	17	27	1	9
1	18	27	1	\N
1	19	27	1	1
1	20	27	1	9
1	21	27	1	\N
1	22	27	1	1
1	23	27	1	1
1	24	27	1	9
1	25	27	1	9
1	26	27	1	1
1	27	27	1	\N
1	28	27	1	9
1	29	27	1	\N
1	30	27	1	\N
1	1	28	2	\N
1	2	28	3	\N
1	3	28	3	3
1	4	28	3	\N
1	5	28	3	2
1	6	28	3	3
1	7	28	1	1
1	8	28	1	9
1	9	28	1	\N
1	10	28	1	1
1	11	28	1	\N
1	12	28	2	1
1	13	28	1	\N
1	14	28	4	7
1	15	28	1	9
1	16	28	1	1
1	17	28	1	1
1	18	28	5	\N
1	19	28	1	9
1	20	28	5	6
1	21	28	1	1
1	22	28	2	1
1	23	28	1	\N
1	24	28	4	7
1	25	28	1	9
1	26	28	1	1
1	27	28	4	7
1	28	28	1	\N
1	29	28	1	1
1	30	28	1	\N
1	1	29	2	\N
1	2	29	2	1
1	3	29	3	\N
1	4	29	3	3
1	5	29	3	\N
1	6	29	3	2
1	7	29	1	\N
1	8	29	1	1
1	9	29	1	\N
1	10	29	1	1
1	11	29	1	9
1	12	29	1	\N
1	13	29	1	9
1	14	29	1	1
1	15	29	1	1
1	16	29	1	\N
1	17	29	1	1
1	18	29	1	1
1	19	29	1	1
1	20	29	1	1
1	21	29	1	\N
1	22	29	1	1
1	23	29	1	9
1	24	29	1	9
1	25	29	1	\N
1	26	29	1	9
1	27	29	1	1
1	28	29	1	9
1	29	29	1	\N
1	30	29	7	\N
1	1	30	2	1
1	2	30	2	1
1	3	30	2	1
1	4	30	5	6
1	5	30	3	3
1	6	30	3	2
1	7	30	4	7
1	8	30	1	9
1	9	30	1	9
1	10	30	1	1
1	11	30	1	1
1	12	30	1	1
1	13	30	1	1
1	14	30	1	9
1	15	30	3	\N
1	16	30	1	9
1	17	30	1	9
1	18	30	1	\N
1	19	30	6	\N
1	20	30	1	9
1	21	30	1	1
1	22	30	1	\N
1	23	30	1	1
1	24	30	1	9
1	25	30	1	1
1	26	30	1	9
1	27	30	1	9
1	28	30	1	9
1	29	30	1	\N
1	30	30	5	8
1	2	1	3	9
1	1	1	4	\N
\.


--
-- TOC entry 5376 (class 0 OID 21693)
-- Dependencies: 294
-- Data for Name: map_tiles_players_positions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_players_positions (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
3	1	6	3
5	1	1	1
2	1	5	4
1	1	5	3
4	1	7	1
\.


--
-- TOC entry 5377 (class 0 OID 21700)
-- Dependencies: 295
-- Data for Name: maps; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.maps (id, name) FROM stdin;
1	NowaMapa
\.


--
-- TOC entry 5330 (class 0 OID 21523)
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
\.


--
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 249
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.abilities_id_seq', 2, true);


--
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 252
-- Name: player_abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_abilities_id_seq', 10, true);


--
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 254
-- Name: player_skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_skills_id_seq', 15, true);


--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 256
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_stats_id_seq', 35, true);


--
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 257
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.roles_id_seq', 1, false);


--
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 258
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.skills_id_seq', 3, true);


--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 259
-- Name: stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.stats_id_seq', 7, true);


--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 261
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.accounts_id_seq', 1, false);


--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 263
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.sessions_id_seq', 1, false);


--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 265
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_id_seq', 1, false);


--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 268
-- Name: building_types_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.building_types_id_seq', 1, false);


--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 269
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.buildings_id_seq', 1, false);


--
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 270
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: cities; Owner: postgres
--

SELECT pg_catalog.setval('cities.cities_id_seq', 1, false);


--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 273
-- Name: district_types_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.district_types_id_seq', 1, false);


--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 274
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.districts_id_seq', 1, false);


--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 276
-- Name: inventory_container_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_container_types_id_seq', 4, true);


--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 278
-- Name: inventory_containers_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_containers_id_seq', 10, true);


--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 280
-- Name: inventory_slot_types_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slot_types_id_seq', 14, true);


--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 282
-- Name: inventory_slots_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slots_id_seq', 110, true);


--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 283
-- Name: item_stats_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_stats_id_seq', 1, false);


--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 285
-- Name: item_types_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_types_id_seq', 10, true);


--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 286
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.items_id_seq', 3, true);


--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 288
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.players_id_seq', 5, true);


--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 290
-- Name: status_types_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.status_types_id_seq', 1, false);


--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 292
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.tasks_id_seq', 226, true);


--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 293
-- Name: landscape_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.landscape_types_id_seq', 1, false);


--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 296
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.maps_id_seq', 1, false);


--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 297
-- Name: terrain_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.terrain_types_id_seq', 1, false);


--
-- TOC entry 5047 (class 2606 OID 21716)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5082 (class 2606 OID 21718)
-- Name: ability_skill_requirements ability_skill_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_pkey PRIMARY KEY (ability_id, skill_id);


--
-- TOC entry 5084 (class 2606 OID 21720)
-- Name: ability_stat_requirements ability_stat_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_pkey PRIMARY KEY (ability_id, stat_id);


--
-- TOC entry 5049 (class 2606 OID 21722)
-- Name: player_abilities player_abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5086 (class 2606 OID 21724)
-- Name: player_skills player_skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5088 (class 2606 OID 21726)
-- Name: player_stats player_stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5051 (class 2606 OID 21728)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5053 (class 2606 OID 21730)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5055 (class 2606 OID 21732)
-- Name: stats stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5090 (class 2606 OID 21734)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 5092 (class 2606 OID 21736)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5094 (class 2606 OID 21738)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5096 (class 2606 OID 21740)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 21742)
-- Name: verification_token verification_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.verification_token
    ADD CONSTRAINT verification_token_pkey PRIMARY KEY (identifier, token);


--
-- TOC entry 5100 (class 2606 OID 21744)
-- Name: building_roles building_owners_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_owners_pkey PRIMARY KEY (building_id, player_id, role_id);


--
-- TOC entry 5057 (class 2606 OID 21746)
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5059 (class 2606 OID 21748)
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- TOC entry 5061 (class 2606 OID 21750)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 21752)
-- Name: city_roles city_owners_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_roles
    ADD CONSTRAINT city_owners_pkey PRIMARY KEY (city_id, player_id, role_id);


--
-- TOC entry 5064 (class 2606 OID 21754)
-- Name: city_tiles city_tiles_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_tiles
    ADD CONSTRAINT city_tiles_pkey PRIMARY KEY (city_id, x, y);


--
-- TOC entry 5104 (class 2606 OID 21756)
-- Name: district_roles district_owners_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_owners_pkey PRIMARY KEY (district_id, player_id, role_id);


--
-- TOC entry 5066 (class 2606 OID 21758)
-- Name: district_types district_types_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_types
    ADD CONSTRAINT district_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5068 (class 2606 OID 21760)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 5106 (class 2606 OID 21762)
-- Name: inventory_container_types inventory_container_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_types
    ADD CONSTRAINT inventory_container_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5108 (class 2606 OID 21764)
-- Name: inventory_containers inventory_containers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_pkey PRIMARY KEY (id);


--
-- TOC entry 5070 (class 2606 OID 21766)
-- Name: inventory_slot_types inventory_slot_types_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_types
    ADD CONSTRAINT inventory_slot_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 21768)
-- Name: inventory_slots inventory_slots_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 5072 (class 2606 OID 21770)
-- Name: item_stats item_stats_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5112 (class 2606 OID 21772)
-- Name: item_types item_types_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5074 (class 2606 OID 21774)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 5115 (class 2606 OID 21776)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 5117 (class 2606 OID 21778)
-- Name: status_types status_types_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types
    ADD CONSTRAINT status_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5119 (class 2606 OID 21780)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 5076 (class 2606 OID 21782)
-- Name: landscape_types landscape_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.landscape_types
    ADD CONSTRAINT landscape_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5078 (class 2606 OID 21784)
-- Name: map_tiles map_tiles_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_pkey PRIMARY KEY (map_id, x, y);


--
-- TOC entry 5121 (class 2606 OID 21786)
-- Name: map_tiles_players_positions map_tiles_players_positions_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_pkey PRIMARY KEY (player_id, map_tile_x, map_tile_y);


--
-- TOC entry 5123 (class 2606 OID 21788)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- TOC entry 5080 (class 2606 OID 21790)
-- Name: terrain_types terrain_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.terrain_types
    ADD CONSTRAINT terrain_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5062 (class 1259 OID 21791)
-- Name: unique_city_position; Type: INDEX; Schema: cities; Owner: postgres
--

CREATE UNIQUE INDEX unique_city_position ON cities.cities USING btree (map_tile_x, map_tile_y);


--
-- TOC entry 5113 (class 1259 OID 21792)
-- Name: one_active_player_per_user; Type: INDEX; Schema: players; Owner: postgres
--

CREATE UNIQUE INDEX one_active_player_per_user ON players.players USING btree (user_id) WHERE (is_active = true);


--
-- TOC entry 5140 (class 2606 OID 21793)
-- Name: ability_skill_requirements ability_skill_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5141 (class 2606 OID 21798)
-- Name: ability_skill_requirements ability_skill_requirements_skill_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5142 (class 2606 OID 21803)
-- Name: ability_stat_requirements ability_stat_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5143 (class 2606 OID 21808)
-- Name: ability_stat_requirements ability_stat_requirements_stat_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_stat_id_fkey FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5124 (class 2606 OID 21813)
-- Name: player_abilities player_abilities_abilities_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_abilities_fk FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5125 (class 2606 OID 21818)
-- Name: player_abilities player_abilities_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5144 (class 2606 OID 21823)
-- Name: player_skills player_skills_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5145 (class 2606 OID 21828)
-- Name: player_skills player_skills_skills_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_skills_fk FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5146 (class 2606 OID 21833)
-- Name: player_stats player_stats_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5147 (class 2606 OID 21838)
-- Name: player_stats player_stats_stats_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5148 (class 2606 OID 21843)
-- Name: accounts accounts_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_users_fk FOREIGN KEY ("userId") REFERENCES auth.users(id);


--
-- TOC entry 5149 (class 2606 OID 21848)
-- Name: sessions sessions_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_users_fk FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- TOC entry 5150 (class 2606 OID 21853)
-- Name: building_roles building_roles_buildings_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_buildings_fk FOREIGN KEY (building_id) REFERENCES buildings.buildings(id);


--
-- TOC entry 5151 (class 2606 OID 21858)
-- Name: building_roles building_roles_players_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5152 (class 2606 OID 21863)
-- Name: building_roles building_roles_roles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5126 (class 2606 OID 21868)
-- Name: buildings buildings_building_types_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_building_types_fk FOREIGN KEY (building_type_id) REFERENCES buildings.building_types(id);


--
-- TOC entry 5127 (class 2606 OID 21873)
-- Name: buildings buildings_cities_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_cities_fk FOREIGN KEY (city_id) REFERENCES cities.cities(id);


--
-- TOC entry 5128 (class 2606 OID 21878)
-- Name: buildings buildings_city_tiles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_city_tiles_fk FOREIGN KEY (city_id, city_tile_x, city_tile_y) REFERENCES cities.city_tiles(city_id, x, y);


--
-- TOC entry 5129 (class 2606 OID 21883)
-- Name: cities cities_map_tiles_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5130 (class 2606 OID 21888)
-- Name: cities cities_maps_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5153 (class 2606 OID 21893)
-- Name: district_roles district_roles_districts_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_districts_fk FOREIGN KEY (district_id) REFERENCES districts.districts(id);


--
-- TOC entry 5154 (class 2606 OID 21898)
-- Name: district_roles district_roles_players_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5155 (class 2606 OID 21903)
-- Name: district_roles district_roles_roles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5131 (class 2606 OID 21908)
-- Name: districts districts_district_types_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_district_types_fk FOREIGN KEY (district_type_id) REFERENCES districts.district_types(id);


--
-- TOC entry 5132 (class 2606 OID 21913)
-- Name: districts districts_map_tiles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5133 (class 2606 OID 21918)
-- Name: districts districts_maps_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5156 (class 2606 OID 21923)
-- Name: inventory_containers inventory_containers_inventory_container_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_inventory_container_types_fk FOREIGN KEY (inventory_container_type_id) REFERENCES inventory.inventory_container_types(id);


--
-- TOC entry 5157 (class 2606 OID 21928)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5158 (class 2606 OID 21933)
-- Name: inventory_slot_type_item_type inventory_slot_type_item_type_item_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slot_type_item_type
    ADD CONSTRAINT inventory_slot_type_item_type_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5159 (class 2606 OID 21938)
-- Name: inventory_slots inventory_slots_inventory_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5160 (class 2606 OID 21943)
-- Name: inventory_slots inventory_slots_inventory_slot_types_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_slot_types_fk FOREIGN KEY (inventory_slot_type_id) REFERENCES inventory.inventory_slot_types(id);


--
-- TOC entry 5161 (class 2606 OID 21948)
-- Name: inventory_slots inventory_slots_items_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5134 (class 2606 OID 21953)
-- Name: item_stats item_stats_items_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5135 (class 2606 OID 21958)
-- Name: item_stats item_stats_stats_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5136 (class 2606 OID 21963)
-- Name: items items_item_types_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_item_types_fk FOREIGN KEY (item_type_id) REFERENCES items.item_types(id);


--
-- TOC entry 5137 (class 2606 OID 21968)
-- Name: map_tiles map_tiles_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5138 (class 2606 OID 21973)
-- Name: map_tiles map_tiles_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5162 (class 2606 OID 21978)
-- Name: map_tiles_players_positions map_tiles_players_positions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5163 (class 2606 OID 21983)
-- Name: map_tiles_players_positions map_tiles_players_positions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5164 (class 2606 OID 21988)
-- Name: map_tiles_players_positions map_tiles_players_positions_players_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5139 (class 2606 OID 21993)
-- Name: map_tiles map_tiles_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


-- Completed on 2026-02-12 00:28:37

--
-- PostgreSQL database dump complete
--

\unrestrict PVFeXO62DDthT61nhlLNQJafg7nAL24RhhGtajGTf0LtulBAych03zgbihA016X

