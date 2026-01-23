--
-- PostgreSQL database dump
--

\restrict VSSDwMtKutxR5vhbTY4NueHSB9HZjPkJiwGCNMI3yoKHhhMwEU0uWPQDbwTG5eh

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-01-23 15:39:34

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
-- TOC entry 6 (class 2615 OID 30762)
-- Name: admin; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA admin;


ALTER SCHEMA admin OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 30763)
-- Name: attributes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA attributes;


ALTER SCHEMA attributes OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 30764)
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 30765)
-- Name: buildings; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA buildings;


ALTER SCHEMA buildings OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 30766)
-- Name: cities; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA cities;


ALTER SCHEMA cities OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 30767)
-- Name: districts; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA districts;


ALTER SCHEMA districts OWNER TO postgres;

--
-- TOC entry 12 (class 2615 OID 30768)
-- Name: inventory; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA inventory;


ALTER SCHEMA inventory OWNER TO postgres;

--
-- TOC entry 13 (class 2615 OID 30769)
-- Name: items; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA items;


ALTER SCHEMA items OWNER TO postgres;

--
-- TOC entry 14 (class 2615 OID 30770)
-- Name: players; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA players;


ALTER SCHEMA players OWNER TO postgres;

--
-- TOC entry 15 (class 2615 OID 30771)
-- Name: tasks; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tasks;


ALTER SCHEMA tasks OWNER TO postgres;

--
-- TOC entry 16 (class 2615 OID 30772)
-- Name: utils; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA utils;


ALTER SCHEMA utils OWNER TO postgres;

--
-- TOC entry 17 (class 2615 OID 30773)
-- Name: world; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA world;


ALTER SCHEMA world OWNER TO postgres;

--
-- TOC entry 325 (class 1255 OID 30774)
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
-- TOC entry 318 (class 1255 OID 30775)
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
-- TOC entry 328 (class 1255 OID 30776)
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
-- TOC entry 352 (class 1255 OID 30777)
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
-- TOC entry 359 (class 1255 OID 30778)
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

END;
$$;


ALTER PROCEDURE admin.new_player(IN p_user_id integer, IN p_name character varying, IN p_second_name character varying) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 30779)
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
-- TOC entry 303 (class 1255 OID 30780)
-- Name: add_player_ability(integer, integer, integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.add_player_ability(p_player_id integer, p_ability_id integer, p_value integer) RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO attributes.player_abilities(player_id, ability_id, value)
    VALUES (p_player_id, p_ability_id, p_value);
    RETURN QUERY SELECT 'ok', FORMAT('Added ability %s to player %s', p_ability_id, p_player_id);
EXCEPTION WHEN unique_violation THEN
    RETURN QUERY SELECT 'fail', FORMAT('Player %s already has ability %s', p_player_id, p_ability_id);
END;
$$;


ALTER FUNCTION attributes.add_player_ability(p_player_id integer, p_ability_id integer, p_value integer) OWNER TO postgres;

--
-- TOC entry 342 (class 1255 OID 30781)
-- Name: check_ability_requirements(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.check_ability_requirements(p_player_id integer) RETURNS TABLE(ability_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ar.ability_id
    FROM attributes.ability_requirements ar
    JOIN (
        SELECT 'SKILL' AS requirement_type, skill_id AS requirement_id, value
        FROM attributes.player_skills 
        WHERE player_id = p_player_id

        UNION ALL

        SELECT 'STAT' AS requirement_type, stat_id AS requirement_id, value
        FROM attributes.player_stats
        WHERE player_id = p_player_id
    ) checks
    ON ar.requirement_type = checks.requirement_type
       AND ar.requirement_id = checks.requirement_id
       AND checks.value >= ar.min_value;
END;
$$;


ALTER FUNCTION attributes.check_ability_requirements(p_player_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 231 (class 1259 OID 30782)
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
-- TOC entry 357 (class 1255 OID 30786)
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
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 357
-- Name: FUNCTION get_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities() IS 'automatic_get_api';


--
-- TOC entry 313 (class 1255 OID 30787)
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
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 313
-- Name: FUNCTION get_abilities_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_abilities_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 232 (class 1259 OID 30788)
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
-- TOC entry 345 (class 1255 OID 30795)
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
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 345
-- Name: FUNCTION get_player_abilities(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities() IS 'automatic_get_api';


--
-- TOC entry 344 (class 1255 OID 30796)
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
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 344
-- Name: FUNCTION get_player_abilities(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities(p_player_id integer) IS 'get_api';


--
-- TOC entry 322 (class 1255 OID 30797)
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
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 322
-- Name: FUNCTION get_player_abilities_by_key(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_abilities_by_key(p_player_id integer) IS 'automatic_get_api';


--
-- TOC entry 319 (class 1255 OID 30798)
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
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 319
-- Name: FUNCTION get_player_skills(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_skills(p_player_id integer) IS 'get_api';


--
-- TOC entry 354 (class 1255 OID 30799)
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
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 354
-- Name: FUNCTION get_player_stats(p_player_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_player_stats(p_player_id integer) IS 'get_api';


--
-- TOC entry 233 (class 1259 OID 30800)
-- Name: roles; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.roles (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE attributes.roles OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 30804)
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
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 356
-- Name: FUNCTION get_roles(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles() IS 'automatic_get_api';


--
-- TOC entry 330 (class 1255 OID 30805)
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
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION get_roles_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_roles_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 234 (class 1259 OID 30806)
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
-- TOC entry 314 (class 1255 OID 30810)
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
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 314
-- Name: FUNCTION get_skills(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills() IS 'automatic_get_api';


--
-- TOC entry 369 (class 1255 OID 30811)
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
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 369
-- Name: FUNCTION get_skills_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_skills_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 235 (class 1259 OID 30812)
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
-- TOC entry 338 (class 1255 OID 30820)
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
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 338
-- Name: FUNCTION get_stats(); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats() IS 'automatic_get_api';


--
-- TOC entry 368 (class 1255 OID 30821)
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
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 368
-- Name: FUNCTION get_stats_by_key(p_id integer); Type: COMMENT; Schema: attributes; Owner: postgres
--

COMMENT ON FUNCTION attributes.get_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 300 (class 1255 OID 30822)
-- Name: unlock_player_abilities(integer); Type: FUNCTION; Schema: attributes; Owner: postgres
--

CREATE FUNCTION attributes.unlock_player_abilities(p_player_id integer) RETURNS TABLE(status text, message text, ability_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ability_id INTEGER;
BEGIN

    FOR v_ability_id IN
        SELECT ability_id FROM attributes.check_ability_requirements(p_player_id)
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
-- TOC entry 326 (class 1255 OID 30823)
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
-- TOC entry 236 (class 1259 OID 30824)
-- Name: building_types; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    image_url character varying(255)
);


ALTER TABLE buildings.building_types OWNER TO postgres;

--
-- TOC entry 361 (class 1255 OID 30829)
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
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 361
-- Name: FUNCTION get_building_types(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types() IS 'automatic_get_api';


--
-- TOC entry 339 (class 1255 OID 30830)
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
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 339
-- Name: FUNCTION get_building_types_by_key(p_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_building_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 237 (class 1259 OID 30831)
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
-- TOC entry 298 (class 1255 OID 30840)
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
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 298
-- Name: FUNCTION get_buildings(); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings() IS 'automatic_get_api';


--
-- TOC entry 355 (class 1255 OID 30841)
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
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 355
-- Name: FUNCTION get_buildings_by_key(p_city_id integer); Type: COMMENT; Schema: buildings; Owner: postgres
--

COMMENT ON FUNCTION buildings.get_buildings_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 238 (class 1259 OID 30842)
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
-- TOC entry 358 (class 1255 OID 30851)
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
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 358
-- Name: FUNCTION get_cities(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities() IS 'automatic_get_api';


--
-- TOC entry 305 (class 1255 OID 30852)
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
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 305
-- Name: FUNCTION get_cities_by_key(p_map_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_cities_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 239 (class 1259 OID 30853)
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
-- TOC entry 343 (class 1255 OID 30861)
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
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION get_city_tiles(); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles() IS 'automatic_get_api';


--
-- TOC entry 335 (class 1255 OID 30862)
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
-- TOC entry 5482 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION get_city_tiles_by_key(p_city_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_city_tiles_by_key(p_city_id integer) IS 'automatic_get_api';


--
-- TOC entry 347 (class 1255 OID 30863)
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
-- TOC entry 5483 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION get_player_city(p_player_id integer); Type: COMMENT; Schema: cities; Owner: postgres
--

COMMENT ON FUNCTION cities.get_player_city(p_player_id integer) IS 'get_api';


--
-- TOC entry 240 (class 1259 OID 30864)
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
-- TOC entry 350 (class 1255 OID 30870)
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
-- TOC entry 5484 (class 0 OID 0)
-- Dependencies: 350
-- Name: FUNCTION get_district_types(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types() IS 'automatic_get_api';


--
-- TOC entry 329 (class 1255 OID 30871)
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
-- TOC entry 5485 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION get_district_types_by_key(p_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_district_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 241 (class 1259 OID 30872)
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
-- TOC entry 364 (class 1255 OID 30880)
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
-- TOC entry 5486 (class 0 OID 0)
-- Dependencies: 364
-- Name: FUNCTION get_districts(); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts() IS 'automatic_get_api';


--
-- TOC entry 311 (class 1255 OID 30881)
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
-- TOC entry 5487 (class 0 OID 0)
-- Dependencies: 311
-- Name: FUNCTION get_districts_by_key(p_map_id integer); Type: COMMENT; Schema: districts; Owner: postgres
--

COMMENT ON FUNCTION districts.get_districts_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 310 (class 1255 OID 30882)
-- Name: add_inventory_container(text, integer, integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer DEFAULT 5) RETURNS TABLE(status text, message text, container_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    container_id INT;
BEGIN


IF      p_owner_type != 'player' 
    AND p_owner_type != 'building' 
    AND p_owner_type != 'district'  THEN
        RETURN QUERY SELECT 'fail', 'Invalid owner type', NULL;
        RETURN;
END IF;



    INSERT INTO inventory.inventory_containers (inventory_size)
    VALUES (p_inventory_size)
    RETURNING id INTO container_id;


    IF p_owner_type = 'player' THEN
        INSERT INTO inventory.inventory_container_player (container_id, player_id)
        VALUES (container_id, p_owner_id);
    ELSIF p_owner_type = 'building' THEN
        INSERT INTO inventory.inventory_container_building (container_id, building_id)
        VALUES (container_id, p_owner_id);
    ELSIF p_owner_type = 'district' THEN
        INSERT INTO inventory.inventory_container_district (container_id, district_id)
        VALUES (container_id, p_owner_id);
    END IF;




    FOR x IN 1..p_inventory_size LOOP
            INSERT INTO inventory.inventory_slots (inventory_container_id)
            VALUES (container_id);
        END LOOP;
    RETURN QUERY SELECT 'ok', 'Container created successfully', container_id;


END;
$$;


ALTER FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer) OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 30883)
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
-- TOC entry 367 (class 1255 OID 30884)
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
-- TOC entry 320 (class 1255 OID 30885)
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
-- TOC entry 332 (class 1255 OID 30886)
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
-- TOC entry 5488 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer) IS 'action_api';


--
-- TOC entry 309 (class 1255 OID 30887)
-- Name: get_building_inventory(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_building_inventory(p_building_id integer) RETURNS TABLE(slot_id integer, container_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t2.id AS container_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_container_building t1
    JOIN inventory.inventory_containers t2  ON t1.inventory_container_id = t2.id
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t2.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.building_id = p_building_id
    ORDER BY t3.id ASC;
END;
$$;


ALTER FUNCTION inventory.get_building_inventory(p_building_id integer) OWNER TO postgres;

--
-- TOC entry 5489 (class 0 OID 0)
-- Dependencies: 309
-- Name: FUNCTION get_building_inventory(p_building_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_building_inventory(p_building_id integer) IS 'get_api';


--
-- TOC entry 351 (class 1255 OID 30888)
-- Name: get_district_inventory(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_district_inventory(p_district_id integer) RETURNS TABLE(slot_id integer, container_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t2.id AS container_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_container_district t1
    JOIN inventory.inventory_containers t2  ON t1.inventory_container_id = t2.id
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t2.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.district_id = p_district_id
    ORDER BY t3.id ASC;
END;
$$;


ALTER FUNCTION inventory.get_district_inventory(p_district_id integer) OWNER TO postgres;

--
-- TOC entry 5490 (class 0 OID 0)
-- Dependencies: 351
-- Name: FUNCTION get_district_inventory(p_district_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_district_inventory(p_district_id integer) IS 'get_api';


--
-- TOC entry 316 (class 1255 OID 30889)
-- Name: get_player_inventory(integer); Type: FUNCTION; Schema: inventory; Owner: postgres
--

CREATE FUNCTION inventory.get_player_inventory(p_player_id integer) RETURNS TABLE(slot_id integer, container_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t2.id AS container_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_container_player t1
    JOIN inventory.inventory_containers t2  ON t1.inventory_container_id = t2.id
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t2.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.player_id = p_player_id
    ORDER BY t3.id ASC;
END;
$$;


ALTER FUNCTION inventory.get_player_inventory(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5491 (class 0 OID 0)
-- Dependencies: 316
-- Name: FUNCTION get_player_inventory(p_player_id integer); Type: COMMENT; Schema: inventory; Owner: postgres
--

COMMENT ON FUNCTION inventory.get_player_inventory(p_player_id integer) IS 'get_api';


--
-- TOC entry 301 (class 1255 OID 30890)
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
-- TOC entry 336 (class 1255 OID 30891)
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
-- TOC entry 242 (class 1259 OID 30892)
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
-- TOC entry 312 (class 1255 OID 30899)
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
-- TOC entry 5492 (class 0 OID 0)
-- Dependencies: 312
-- Name: FUNCTION get_item_stats(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats() IS 'automatic_get_api';


--
-- TOC entry 363 (class 1255 OID 30900)
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
-- TOC entry 5493 (class 0 OID 0)
-- Dependencies: 363
-- Name: FUNCTION get_item_stats_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_item_stats_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 243 (class 1259 OID 30901)
-- Name: items; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.items (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE items.items OWNER TO postgres;

--
-- TOC entry 327 (class 1255 OID 30905)
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
-- TOC entry 5494 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION get_items(); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items() IS 'automatic_get_api';


--
-- TOC entry 304 (class 1255 OID 30906)
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
-- TOC entry 5495 (class 0 OID 0)
-- Dependencies: 304
-- Name: FUNCTION get_items_by_key(p_id integer); Type: COMMENT; Schema: items; Owner: postgres
--

COMMENT ON FUNCTION items.get_items_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 349 (class 1255 OID 30907)
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
-- TOC entry 5496 (class 0 OID 0)
-- Dependencies: 349
-- Name: FUNCTION do_switch_active_player(p_player_id integer, p_switch_to_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer) IS 'action_api';


--
-- TOC entry 295 (class 1255 OID 30908)
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
-- TOC entry 317 (class 1255 OID 30909)
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
-- TOC entry 5497 (class 0 OID 0)
-- Dependencies: 317
-- Name: FUNCTION get_active_player_profile(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_profile(p_player_id integer) IS 'get_api';


--
-- TOC entry 346 (class 1255 OID 30910)
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
-- TOC entry 5498 (class 0 OID 0)
-- Dependencies: 346
-- Name: FUNCTION get_active_player_switch_profiles(p_player_id integer); Type: COMMENT; Schema: players; Owner: postgres
--

COMMENT ON FUNCTION players.get_active_player_switch_profiles(p_player_id integer) IS 'get_api';


--
-- TOC entry 373 (class 1255 OID 30911)
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
-- TOC entry 331 (class 1255 OID 30912)
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
-- TOC entry 308 (class 1255 OID 30913)
-- Name: insert_task(integer, character varying, jsonb); Type: FUNCTION; Schema: tasks; Owner: postgres
--

CREATE FUNCTION tasks.insert_task(p_player_id integer, p_method_name character varying, p_parameters jsonb) RETURNS void
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
            NOW() + INTERVAL '5 minutes',
            NULL,
            NULL,
            p_method_name,
            p_parameters

        );

END;

$$;


ALTER FUNCTION tasks.insert_task(p_player_id integer, p_method_name character varying, p_parameters jsonb) OWNER TO postgres;

--
-- TOC entry 337 (class 1255 OID 30914)
-- Name: raise_error(text, text[]); Type: FUNCTION; Schema: utils; Owner: postgres
--

CREATE FUNCTION utils.raise_error(p_message text, VARIADIC p_args text[]) RETURNS void
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


ALTER FUNCTION utils.raise_error(p_message text, VARIADIC p_args text[]) OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 30915)
-- Name: do_player_movement(integer, jsonb); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) RETURNS TABLE(status boolean, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    tile jsonb;
BEGIN
    PERFORM tasks.cancel_task(p_player_id, 'world.player_movement');

    FOR tile IN 
        SELECT * FROM jsonb_array_elements(p_path)
    LOOP
        PERFORM tasks.insert_task(p_player_id, 'world.player_movement', tile);
    END LOOP;

    RETURN QUERY SELECT true, 'Movement actions assigned';
END;
$$;


ALTER FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) OWNER TO postgres;

--
-- TOC entry 5499 (class 0 OID 0)
-- Dependencies: 302
-- Name: FUNCTION do_player_movement(p_player_id integer, p_path jsonb); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.do_player_movement(p_player_id integer, p_path jsonb) IS 'action_api';


--
-- TOC entry 244 (class 1259 OID 30916)
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
-- TOC entry 366 (class 1255 OID 30922)
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
-- TOC entry 5500 (class 0 OID 0)
-- Dependencies: 366
-- Name: FUNCTION get_landscape_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types() IS 'automatic_get_api';


--
-- TOC entry 321 (class 1255 OID 30923)
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
-- TOC entry 5501 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION get_landscape_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_landscape_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 245 (class 1259 OID 30924)
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
-- TOC entry 323 (class 1255 OID 30932)
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
-- TOC entry 5502 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION get_map_tiles(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles() IS 'automatic_get_api';


--
-- TOC entry 372 (class 1255 OID 30933)
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
-- TOC entry 5503 (class 0 OID 0)
-- Dependencies: 372
-- Name: FUNCTION get_map_tiles_by_key(p_map_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_map_tiles_by_key(p_map_id integer) IS 'automatic_get_api';


--
-- TOC entry 334 (class 1255 OID 30934)
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
-- TOC entry 5504 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION get_player_map(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_map(p_player_id integer) IS 'get_api';


--
-- TOC entry 307 (class 1255 OID 30935)
-- Name: get_player_movement(integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_movement(p_player_id integer) RETURNS TABLE(scheduled_at timestamp without time zone, x integer, y integer)
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
                NULL AS scheduled_at,
                map_tile_x AS x,
                map_tile_y AS y
            FROM
                world.map_tiles_players_positions t1
            WHERE player_id = p_player_id
    
      UNION ALL
    
             SELECT
                 scheduled_at,
                 (method_parameters->>'x')::int AS x,
                 (method_parameters->>'y')::int AS y
             FROM tasks.tasks
             WHERE player_id = p_player_id
               AND method_name = 'world.player_movement'
            AND status IN (1, 2)
             ORDER BY scheduled_at ASC NULLS FIRST;

    END IF;
END;
$$;


ALTER FUNCTION world.get_player_movement(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5505 (class 0 OID 0)
-- Dependencies: 307
-- Name: FUNCTION get_player_movement(p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_movement(p_player_id integer) IS 'get_api';


--
-- TOC entry 370 (class 1255 OID 30936)
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
-- TOC entry 5506 (class 0 OID 0)
-- Dependencies: 370
-- Name: FUNCTION get_player_position(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_position(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 296 (class 1255 OID 30937)
-- Name: get_player_vision_players_positions(integer, integer); Type: FUNCTION; Schema: world; Owner: postgres
--

CREATE FUNCTION world.get_player_vision_players_positions(p_map_id integer, p_player_id integer) RETURNS TABLE(x integer, y integer, image_url character varying)
    LANGUAGE plpgsql
    AS $$
      BEGIN
            RETURN QUERY
             SELECT  T1.map_tile_x AS X 
                     ,T1.map_tile_y AS Y
                     ,t2.image_url AS image_url
            FROM world.map_tiles_players_positions T1
            JOIN players.players T2 ON T1.player_id = T2.id
            WHERE T1.map_id = p_map_id
             AND T1.player_id != p_player_id;
      END;
      $$;


ALTER FUNCTION world.get_player_vision_players_positions(p_map_id integer, p_player_id integer) OWNER TO postgres;

--
-- TOC entry 5507 (class 0 OID 0)
-- Dependencies: 296
-- Name: FUNCTION get_player_vision_players_positions(p_map_id integer, p_player_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_player_vision_players_positions(p_map_id integer, p_player_id integer) IS 'get_api';


--
-- TOC entry 246 (class 1259 OID 30938)
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
-- TOC entry 341 (class 1255 OID 30944)
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
-- TOC entry 5508 (class 0 OID 0)
-- Dependencies: 341
-- Name: FUNCTION get_terrain_types(); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types() IS 'automatic_get_api';


--
-- TOC entry 348 (class 1255 OID 30945)
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
-- TOC entry 5509 (class 0 OID 0)
-- Dependencies: 348
-- Name: FUNCTION get_terrain_types_by_key(p_id integer); Type: COMMENT; Schema: world; Owner: postgres
--

COMMENT ON FUNCTION world.get_terrain_types_by_key(p_id integer) IS 'automatic_get_api';


--
-- TOC entry 247 (class 1259 OID 30946)
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
-- TOC entry 248 (class 1259 OID 30947)
-- Name: ability_skill_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_skill_requirements (
    ability_id integer NOT NULL,
    skill_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_skill_requirements OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 30954)
-- Name: ability_stat_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_stat_requirements (
    ability_id integer NOT NULL,
    stat_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL
);


ALTER TABLE attributes.ability_stat_requirements OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 30961)
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
-- TOC entry 251 (class 1259 OID 30962)
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
-- TOC entry 252 (class 1259 OID 30969)
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
-- TOC entry 253 (class 1259 OID 30970)
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
-- TOC entry 254 (class 1259 OID 30977)
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
-- TOC entry 255 (class 1259 OID 30978)
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
-- TOC entry 256 (class 1259 OID 30979)
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
-- TOC entry 257 (class 1259 OID 30980)
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
-- TOC entry 258 (class 1259 OID 30981)
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
-- TOC entry 259 (class 1259 OID 30991)
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
-- TOC entry 260 (class 1259 OID 30992)
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
-- TOC entry 261 (class 1259 OID 30999)
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
-- TOC entry 262 (class 1259 OID 31000)
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
-- TOC entry 263 (class 1259 OID 31006)
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
-- TOC entry 264 (class 1259 OID 31007)
-- Name: verification_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.verification_token (
    identifier text NOT NULL,
    expires timestamp with time zone NOT NULL,
    token text NOT NULL
);


ALTER TABLE auth.verification_token OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 31015)
-- Name: building_roles; Type: TABLE; Schema: buildings; Owner: postgres
--

CREATE TABLE buildings.building_roles (
    building_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE buildings.building_roles OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 31021)
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
-- TOC entry 267 (class 1259 OID 31022)
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
-- TOC entry 268 (class 1259 OID 31023)
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
-- TOC entry 269 (class 1259 OID 31024)
-- Name: city_roles; Type: TABLE; Schema: cities; Owner: postgres
--

CREATE TABLE cities.city_roles (
    city_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE cities.city_roles OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 31030)
-- Name: district_roles; Type: TABLE; Schema: districts; Owner: postgres
--

CREATE TABLE districts.district_roles (
    district_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE districts.district_roles OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 31036)
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
-- TOC entry 272 (class 1259 OID 31037)
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
-- TOC entry 273 (class 1259 OID 31038)
-- Name: inventory_container_building; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_container_building (
    inventory_container_id integer CONSTRAINT inventory_container_building_container_id_not_null NOT NULL,
    building_id integer NOT NULL
);


ALTER TABLE inventory.inventory_container_building OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 31043)
-- Name: inventory_container_district; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_container_district (
    inventory_container_id integer CONSTRAINT inventory_container_district_container_id_not_null NOT NULL,
    district_id integer NOT NULL
);


ALTER TABLE inventory.inventory_container_district OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 31048)
-- Name: inventory_container_player; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_container_player (
    inventory_container_id integer CONSTRAINT inventory_container_player_container_id_not_null NOT NULL,
    player_id integer NOT NULL
);


ALTER TABLE inventory.inventory_container_player OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 31053)
-- Name: inventory_containers; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_containers (
    id integer NOT NULL,
    inventory_size integer NOT NULL,
    CONSTRAINT inventory_containers_inventory_size_check CHECK ((inventory_size > 0))
);


ALTER TABLE inventory.inventory_containers OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 31059)
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
-- TOC entry 278 (class 1259 OID 31060)
-- Name: inventory_slots; Type: TABLE; Schema: inventory; Owner: postgres
--

CREATE TABLE inventory.inventory_slots (
    id integer NOT NULL,
    inventory_container_id integer NOT NULL,
    item_id integer,
    quantity integer,
    CONSTRAINT inventory_slots_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE inventory.inventory_slots OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 31066)
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
-- TOC entry 280 (class 1259 OID 31067)
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
-- TOC entry 281 (class 1259 OID 31068)
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
-- TOC entry 282 (class 1259 OID 31069)
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
-- TOC entry 283 (class 1259 OID 31084)
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
-- TOC entry 284 (class 1259 OID 31085)
-- Name: status_types; Type: TABLE; Schema: tasks; Owner: postgres
--

CREATE TABLE tasks.status_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE tasks.status_types OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 31090)
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
-- TOC entry 286 (class 1259 OID 31091)
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
-- TOC entry 287 (class 1259 OID 31101)
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
-- TOC entry 288 (class 1259 OID 31102)
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
-- TOC entry 289 (class 1259 OID 31103)
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
-- TOC entry 290 (class 1259 OID 31110)
-- Name: maps; Type: TABLE; Schema: world; Owner: postgres
--

CREATE TABLE world.maps (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE world.maps OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 31115)
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
-- TOC entry 292 (class 1259 OID 31116)
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
-- TOC entry 293 (class 1259 OID 31117)
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
-- TOC entry 294 (class 1259 OID 31121)
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
-- TOC entry 5395 (class 0 OID 30782)
-- Dependencies: 231
-- Data for Name: abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.abilities (id, name, description, image) FROM stdin;
2	Explore	Explore new land's	Eye
1	Colonize	Settle Nomad's	Tent
\.


--
-- TOC entry 5412 (class 0 OID 30947)
-- Dependencies: 248
-- Data for Name: ability_skill_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_skill_requirements (ability_id, skill_id, min_value) FROM stdin;
\.


--
-- TOC entry 5413 (class 0 OID 30954)
-- Dependencies: 249
-- Data for Name: ability_stat_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.ability_stat_requirements (ability_id, stat_id, min_value) FROM stdin;
\.


--
-- TOC entry 5396 (class 0 OID 30788)
-- Dependencies: 232
-- Data for Name: player_abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_abilities (id, player_id, ability_id, value) FROM stdin;
1	1	1	1
2	1	2	1
\.


--
-- TOC entry 5415 (class 0 OID 30962)
-- Dependencies: 251
-- Data for Name: player_skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_skills (id, player_id, skill_id, value) FROM stdin;
1	1	1	1
2	1	2	1
3	1	3	2
\.


--
-- TOC entry 5417 (class 0 OID 30970)
-- Dependencies: 253
-- Data for Name: player_stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.player_stats (id, player_id, stat_id, value) FROM stdin;
1	1	1	6
2	1	2	3
3	1	3	2
4	1	4	2
5	1	5	4
6	1	6	3
7	1	7	4
8	2	1	4
9	2	3	8
10	2	4	8
11	2	5	6
12	2	6	7
13	2	7	4
14	2	2	10
\.


--
-- TOC entry 5397 (class 0 OID 30800)
-- Dependencies: 233
-- Data for Name: roles; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.roles (id, name) FROM stdin;
1	Owner
\.


--
-- TOC entry 5398 (class 0 OID 30806)
-- Dependencies: 234
-- Data for Name: skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

COPY attributes.skills (id, name, description, image) FROM stdin;
1	Colonization	Settle new world's !	Tent
2	Survival	Navigate wilderness and find resources stay alive	TreePine
3	Trade	How cheap can you buy ?	HandCoinsIcon
\.


--
-- TOC entry 5399 (class 0 OID 30812)
-- Dependencies: 235
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
-- TOC entry 5422 (class 0 OID 30981)
-- Dependencies: 258
-- Data for Name: accounts; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.accounts (id, "userId", type, provider, "providerAccountId", refresh_token, access_token, expires_at, id_token, scope, session_state, token_type) FROM stdin;
\.


--
-- TOC entry 5424 (class 0 OID 30992)
-- Dependencies: 260
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.sessions (id, "userId", expires, "sessionToken") FROM stdin;
\.


--
-- TOC entry 5426 (class 0 OID 31000)
-- Dependencies: 262
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.users (id, name, email, "emailVerified", image, password) FROM stdin;
1	ciabat	pszabat001@gmail.com	\N	\N	$2b$10$4IQKRdaQ8l29u9KEdy6G6esjYGPJe9rQsWlAqPSe0OgbzyjsV6rCW
\.


--
-- TOC entry 5428 (class 0 OID 31007)
-- Dependencies: 264
-- Data for Name: verification_token; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.verification_token (identifier, expires, token) FROM stdin;
\.


--
-- TOC entry 5429 (class 0 OID 31015)
-- Dependencies: 265
-- Data for Name: building_roles; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_roles (building_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5400 (class 0 OID 30824)
-- Dependencies: 236
-- Data for Name: building_types; Type: TABLE DATA; Schema: buildings; Owner: postgres
--

COPY buildings.building_types (id, name, image_url) FROM stdin;
1	Townhall	Townhall.png
2	Marketplace	Marketplace.png
3	Shacks	Shacks.png
4	Logistics	Logistics.png
\.


--
-- TOC entry 5401 (class 0 OID 30831)
-- Dependencies: 237
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
-- TOC entry 5402 (class 0 OID 30842)
-- Dependencies: 238
-- Data for Name: cities; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.cities (id, map_id, map_tile_x, map_tile_y, name, move_cost, image_url) FROM stdin;
2	1	4	3	Nashkel	1	City_1.png
\.


--
-- TOC entry 5433 (class 0 OID 31024)
-- Dependencies: 269
-- Data for Name: city_roles; Type: TABLE DATA; Schema: cities; Owner: postgres
--

COPY cities.city_roles (city_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5403 (class 0 OID 30853)
-- Dependencies: 239
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
-- TOC entry 5434 (class 0 OID 31030)
-- Dependencies: 270
-- Data for Name: district_roles; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_roles (district_id, player_id, role_id) FROM stdin;
\.


--
-- TOC entry 5404 (class 0 OID 30864)
-- Dependencies: 240
-- Data for Name: district_types; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.district_types (id, name, move_cost, image_url) FROM stdin;
1	Farmland	1	full_farmland.png
\.


--
-- TOC entry 5405 (class 0 OID 30872)
-- Dependencies: 241
-- Data for Name: districts; Type: TABLE DATA; Schema: districts; Owner: postgres
--

COPY districts.districts (id, map_id, map_tile_x, map_tile_y, district_type_id, name) FROM stdin;
1	1	4	4	1	Green Hills
\.


--
-- TOC entry 5437 (class 0 OID 31038)
-- Dependencies: 273
-- Data for Name: inventory_container_building; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_container_building (inventory_container_id, building_id) FROM stdin;
\.


--
-- TOC entry 5438 (class 0 OID 31043)
-- Dependencies: 274
-- Data for Name: inventory_container_district; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_container_district (inventory_container_id, district_id) FROM stdin;
\.


--
-- TOC entry 5439 (class 0 OID 31048)
-- Dependencies: 275
-- Data for Name: inventory_container_player; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_container_player (inventory_container_id, player_id) FROM stdin;
\.


--
-- TOC entry 5440 (class 0 OID 31053)
-- Dependencies: 276
-- Data for Name: inventory_containers; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_containers (id, inventory_size) FROM stdin;
\.


--
-- TOC entry 5442 (class 0 OID 31060)
-- Dependencies: 278
-- Data for Name: inventory_slots; Type: TABLE DATA; Schema: inventory; Owner: postgres
--

COPY inventory.inventory_slots (id, inventory_container_id, item_id, quantity) FROM stdin;
\.


--
-- TOC entry 5406 (class 0 OID 30892)
-- Dependencies: 242
-- Data for Name: item_stats; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.item_stats (id, item_id, stat_id, value) FROM stdin;
\.


--
-- TOC entry 5407 (class 0 OID 30901)
-- Dependencies: 243
-- Data for Name: items; Type: TABLE DATA; Schema: items; Owner: postgres
--

COPY items.items (id, name) FROM stdin;
1	Food
\.


--
-- TOC entry 5446 (class 0 OID 31069)
-- Dependencies: 282
-- Data for Name: players; Type: TABLE DATA; Schema: players; Owner: postgres
--

COPY players.players (id, user_id, name, image_map, image_portrait, is_active, second_name, nickname) FROM stdin;
2	1	Pawluniu	default.png	12.png	f	Pigeon	\N
1	1	Ciabat	default.png	4.png	t	Pigeon	\N
\.


--
-- TOC entry 5448 (class 0 OID 31085)
-- Dependencies: 284
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
-- TOC entry 5450 (class 0 OID 31091)
-- Dependencies: 286
-- Data for Name: tasks; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

COPY tasks.tasks (id, player_id, status, created_at, scheduled_at, last_executed_at, error, method_name, method_parameters) FROM stdin;
2	1	5	2025-06-01 00:53:34.456818	2025-06-01 00:58:34.46	\N	\N	map.movmentAction	{"x": 3, "y": 3, "playerId": 1}
3	1	5	2025-06-01 00:53:34.457512	2025-06-01 00:58:34.46	\N	\N	map.movmentAction	{"x": 4, "y": 4, "playerId": 1}
4	1	5	2025-06-01 01:34:30.884921	2025-06-01 01:39:30.88	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
5	1	5	2025-06-01 01:34:30.886684	2025-06-01 01:39:30.89	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
6	1	5	2025-06-01 01:34:30.887401	2025-06-01 01:39:30.89	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
7	1	5	2025-06-01 01:34:30.888079	2025-06-01 01:39:30.89	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
8	1	5	2025-06-01 01:34:30.888843	2025-06-01 01:39:30.89	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
9	1	5	2025-06-01 01:34:30.889622	2025-06-01 01:39:30.89	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
10	1	5	2025-06-01 01:34:30.89046	2025-06-01 01:39:30.89	\N	\N	map.movmentAction	{"x": 8, "y": 5, "playerId": 1}
11	1	5	2025-06-01 02:01:21.015456	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
12	1	5	2025-06-01 02:01:21.019088	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
13	1	5	2025-06-01 02:01:21.020172	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
14	1	5	2025-06-01 02:01:21.020873	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
15	1	5	2025-06-01 02:01:21.02173	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
16	1	5	2025-06-01 02:01:21.022726	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
17	1	5	2025-06-01 02:01:21.023341	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
18	1	5	2025-06-01 02:01:21.024053	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
19	1	5	2025-06-01 02:01:21.024776	2025-06-01 02:06:21.02	\N	\N	map.movmentAction	{"x": 8, "y": 13, "playerId": 1}
20	1	5	2025-06-01 02:01:21.025677	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 9, "y": 14, "playerId": 1}
21	1	5	2025-06-01 02:01:21.026743	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 10, "y": 15, "playerId": 1}
22	1	5	2025-06-01 02:01:21.02776	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 11, "y": 16, "playerId": 1}
23	1	5	2025-06-01 02:01:21.028559	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 12, "y": 17, "playerId": 1}
24	1	5	2025-06-01 02:01:21.029211	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 13, "y": 18, "playerId": 1}
25	1	5	2025-06-01 02:01:21.02982	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 14, "y": 19, "playerId": 1}
26	1	5	2025-06-01 02:01:21.030425	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 15, "y": 20, "playerId": 1}
27	1	5	2025-06-01 02:01:21.031038	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 16, "y": 20, "playerId": 1}
28	1	5	2025-06-01 02:01:21.03162	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 17, "y": 21, "playerId": 1}
29	1	5	2025-06-01 02:01:21.03247	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 18, "y": 22, "playerId": 1}
30	1	5	2025-06-01 02:01:21.034112	2025-06-01 02:06:21.03	\N	\N	map.movmentAction	{"x": 19, "y": 22, "playerId": 1}
31	1	5	2025-06-01 02:01:21.035319	2025-06-01 02:06:21.04	\N	\N	map.movmentAction	{"x": 20, "y": 23, "playerId": 1}
32	1	5	2025-06-01 02:01:21.036017	2025-06-01 02:06:21.04	\N	\N	map.movmentAction	{"x": 21, "y": 24, "playerId": 1}
33	1	5	2025-06-01 02:01:21.03665	2025-06-01 02:06:21.04	\N	\N	map.movmentAction	{"x": 22, "y": 24, "playerId": 1}
34	1	5	2025-06-03 23:30:10.91695	2025-06-03 23:35:10.92	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
35	1	5	2025-06-03 23:30:10.927372	2025-06-03 23:35:10.93	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
36	1	5	2025-06-03 23:30:10.92852	2025-06-03 23:35:10.93	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
37	1	5	2025-06-03 23:30:10.929375	2025-06-03 23:35:10.93	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
38	1	5	2025-06-03 23:30:10.93114	2025-06-03 23:35:10.93	\N	\N	map.movmentAction	{"x": 6, "y": 5, "playerId": 1}
39	1	5	2025-06-03 23:30:10.932109	2025-06-03 23:35:10.93	\N	\N	map.movmentAction	{"x": 7, "y": 4, "playerId": 1}
40	1	5	2025-06-03 23:33:57.201061	2025-06-03 23:38:57.2	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
41	1	5	2025-06-03 23:33:57.203162	2025-06-03 23:38:57.2	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
42	1	5	2025-06-03 23:33:57.204072	2025-06-03 23:38:57.2	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
43	1	5	2025-06-03 23:33:57.204872	2025-06-03 23:38:57.2	\N	\N	map.movmentAction	{"x": 4, "y": 8, "playerId": 1}
44	1	5	2025-06-03 23:33:57.205956	2025-06-03 23:38:57.21	\N	\N	map.movmentAction	{"x": 4, "y": 9, "playerId": 1}
45	1	5	2025-06-03 23:34:29.666917	2025-06-03 23:39:29.67	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
46	1	5	2025-06-03 23:34:29.670239	2025-06-03 23:39:29.67	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
47	1	5	2025-06-03 23:34:29.674294	2025-06-03 23:39:29.67	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
48	1	5	2025-06-03 23:34:29.676382	2025-06-03 23:39:29.68	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
49	1	5	2025-06-03 23:34:29.678532	2025-06-03 23:39:29.68	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
50	1	5	2025-06-03 23:34:29.681343	2025-06-03 23:39:29.68	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
51	1	5	2025-06-03 23:34:29.683733	2025-06-03 23:39:29.68	\N	\N	map.movmentAction	{"x": 8, "y": 5, "playerId": 1}
52	1	5	2025-06-03 23:34:37.970266	2025-06-03 23:39:37.97	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
53	1	5	2025-06-03 23:34:37.971667	2025-06-03 23:39:37.97	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
54	1	5	2025-06-03 23:34:37.972697	2025-06-03 23:39:37.97	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
55	1	5	2025-06-03 23:34:37.973795	2025-06-03 23:39:37.97	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
56	1	5	2025-06-03 23:34:37.974728	2025-06-03 23:39:37.97	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
57	1	5	2025-06-03 23:34:37.975825	2025-06-03 23:39:37.98	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
58	1	5	2025-06-03 23:34:37.977194	2025-06-03 23:39:37.98	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
59	1	5	2025-06-03 23:34:37.978362	2025-06-03 23:39:37.98	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
60	1	5	2025-06-03 23:34:37.979423	2025-06-03 23:39:37.98	\N	\N	map.movmentAction	{"x": 9, "y": 12, "playerId": 1}
61	1	5	2025-06-03 23:34:37.983815	2025-06-03 23:39:37.98	\N	\N	map.movmentAction	{"x": 10, "y": 11, "playerId": 1}
62	1	5	2025-06-03 23:34:38.000243	2025-06-03 23:39:38	\N	\N	map.movmentAction	{"x": 11, "y": 12, "playerId": 1}
63	1	5	2025-06-03 23:34:38.001896	2025-06-03 23:39:38	\N	\N	map.movmentAction	{"x": 12, "y": 12, "playerId": 1}
64	1	5	2025-06-03 23:34:38.003184	2025-06-03 23:39:38	\N	\N	map.movmentAction	{"x": 13, "y": 12, "playerId": 1}
65	1	5	2025-06-03 23:34:38.004513	2025-06-03 23:39:38	\N	\N	map.movmentAction	{"x": 14, "y": 13, "playerId": 1}
66	1	5	2025-06-03 23:34:38.006	2025-06-03 23:39:38.01	\N	\N	map.movmentAction	{"x": 15, "y": 12, "playerId": 1}
67	1	5	2025-06-03 23:34:38.007541	2025-06-03 23:39:38.01	\N	\N	map.movmentAction	{"x": 16, "y": 12, "playerId": 1}
68	1	5	2025-06-03 23:34:38.009093	2025-06-03 23:39:38.01	\N	\N	map.movmentAction	{"x": 17, "y": 13, "playerId": 1}
69	1	5	2025-06-03 23:34:55.658025	2025-06-03 23:39:55.66	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
70	1	5	2025-06-03 23:34:55.659036	2025-06-03 23:39:55.66	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
71	1	5	2025-06-03 23:34:55.659849	2025-06-03 23:39:55.66	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
72	1	5	2025-06-03 23:34:55.660655	2025-06-03 23:39:55.66	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
73	1	5	2025-06-03 23:34:55.661721	2025-06-03 23:39:55.66	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
74	1	5	2025-06-03 23:34:55.662701	2025-06-03 23:39:55.66	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
75	1	5	2025-06-03 23:34:55.664095	2025-06-03 23:39:55.66	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
76	1	5	2025-06-03 23:34:55.665785	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
77	1	5	2025-06-03 23:34:55.667029	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
78	1	5	2025-06-03 23:34:55.668121	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
79	1	5	2025-06-03 23:34:55.669	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
80	1	5	2025-06-03 23:34:55.670032	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 13, "y": 6, "playerId": 1}
81	1	5	2025-06-03 23:34:55.670849	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 14, "y": 5, "playerId": 1}
82	1	5	2025-06-03 23:34:55.67181	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 15, "y": 5, "playerId": 1}
83	1	5	2025-06-03 23:34:55.672854	2025-06-03 23:39:55.67	\N	\N	map.movmentAction	{"x": 16, "y": 5, "playerId": 1}
84	1	5	2025-06-03 23:35:25.264405	2025-06-03 23:40:25.26	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
85	1	5	2025-06-03 23:35:25.26573	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
86	1	5	2025-06-03 23:35:25.26694	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
87	1	5	2025-06-03 23:35:25.267944	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
88	1	5	2025-06-03 23:35:25.269168	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
89	1	5	2025-06-03 23:35:25.27068	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
90	1	5	2025-06-03 23:35:25.272491	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
91	1	5	2025-06-03 23:35:25.273685	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
92	1	5	2025-06-03 23:35:25.274745	2025-06-03 23:40:25.27	\N	\N	map.movmentAction	{"x": 8, "y": 13, "playerId": 1}
93	1	5	2025-06-03 23:35:25.275811	2025-06-03 23:40:25.28	\N	\N	map.movmentAction	{"x": 9, "y": 14, "playerId": 1}
94	1	5	2025-06-03 23:35:25.276936	2025-06-03 23:40:25.28	\N	\N	map.movmentAction	{"x": 10, "y": 15, "playerId": 1}
95	1	5	2025-06-03 23:35:25.278132	2025-06-03 23:40:25.28	\N	\N	map.movmentAction	{"x": 11, "y": 16, "playerId": 1}
96	1	5	2025-06-03 23:35:25.279382	2025-06-03 23:40:25.28	\N	\N	map.movmentAction	{"x": 11, "y": 17, "playerId": 1}
97	1	5	2025-06-03 23:35:25.280794	2025-06-03 23:40:25.28	\N	\N	map.movmentAction	{"x": 11, "y": 18, "playerId": 1}
98	1	5	2025-06-03 23:35:25.282707	2025-06-03 23:40:25.28	\N	\N	map.movmentAction	{"x": 12, "y": 19, "playerId": 1}
99	1	5	2025-06-03 23:35:25.284214	2025-06-03 23:40:25.28	\N	\N	map.movmentAction	{"x": 11, "y": 20, "playerId": 1}
100	1	5	2025-06-03 23:35:25.285655	2025-06-03 23:40:25.29	\N	\N	map.movmentAction	{"x": 10, "y": 21, "playerId": 1}
101	1	5	2025-06-03 23:35:25.287245	2025-06-03 23:40:25.29	\N	\N	map.movmentAction	{"x": 9, "y": 21, "playerId": 1}
102	1	5	2025-06-03 23:38:48.473185	2025-06-03 23:43:48.47	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
103	1	5	2025-06-03 23:38:48.475395	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
104	1	5	2025-06-03 23:38:48.476284	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
105	1	5	2025-06-03 23:38:48.477077	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
106	1	5	2025-06-03 23:38:48.477798	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
107	1	5	2025-06-03 23:38:48.478524	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
108	1	5	2025-06-03 23:38:48.479264	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
109	1	5	2025-06-03 23:38:48.480132	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
110	1	5	2025-06-03 23:38:48.481007	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 9, "y": 12, "playerId": 1}
111	1	5	2025-06-03 23:38:48.482247	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 10, "y": 11, "playerId": 1}
112	1	5	2025-06-03 23:38:48.482972	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 11, "y": 11, "playerId": 1}
113	1	5	2025-06-03 23:38:48.483671	2025-06-03 23:43:48.48	\N	\N	map.movmentAction	{"x": 12, "y": 11, "playerId": 1}
114	1	5	2025-06-03 23:39:03.350467	2025-06-03 23:44:03.35	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
115	1	5	2025-06-03 23:39:03.35172	2025-06-03 23:44:03.35	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
116	1	5	2025-06-03 23:39:03.352806	2025-06-03 23:44:03.35	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
117	1	5	2025-06-03 23:39:03.353771	2025-06-03 23:44:03.35	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
118	1	5	2025-06-03 23:39:03.354822	2025-06-03 23:44:03.35	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
119	1	5	2025-06-03 23:39:03.355794	2025-06-03 23:44:03.36	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
120	1	5	2025-06-03 23:39:03.356824	2025-06-03 23:44:03.36	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
121	1	5	2025-06-03 23:39:03.35799	2025-06-03 23:44:03.36	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
122	1	5	2025-06-03 23:39:03.359347	2025-06-03 23:44:03.36	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
123	1	5	2025-06-03 23:39:03.36041	2025-06-03 23:44:03.36	\N	\N	map.movmentAction	{"x": 10, "y": 7, "playerId": 1}
124	1	5	2025-06-03 23:40:41.016849	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
125	1	5	2025-06-03 23:40:41.018501	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
126	1	5	2025-06-03 23:40:41.019176	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
127	1	5	2025-06-03 23:40:41.019626	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
128	1	5	2025-06-03 23:40:41.020056	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
129	1	5	2025-06-03 23:40:41.020455	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
130	1	5	2025-06-03 23:40:41.020836	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
131	1	5	2025-06-03 23:40:41.021171	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 6, "y": 12, "playerId": 1}
132	1	5	2025-06-03 23:40:41.021484	2025-06-03 23:45:41.02	\N	\N	map.movmentAction	{"x": 6, "y": 13, "playerId": 1}
133	1	5	2025-06-03 23:41:07.924264	2025-06-03 23:46:07.92	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
134	1	5	2025-06-03 23:41:07.924967	2025-06-03 23:46:07.92	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
135	1	5	2025-06-03 23:41:07.925491	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
136	1	5	2025-06-03 23:41:07.925967	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
137	1	5	2025-06-03 23:41:07.926488	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
138	1	5	2025-06-03 23:41:07.927004	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
139	1	5	2025-06-03 23:41:07.92748	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
140	1	5	2025-06-03 23:41:07.92812	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
141	1	5	2025-06-03 23:41:07.928508	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 8, "y": 13, "playerId": 1}
142	1	5	2025-06-03 23:41:07.928904	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 7, "y": 14, "playerId": 1}
143	1	5	2025-06-03 23:41:07.929286	2025-06-03 23:46:07.93	\N	\N	map.movmentAction	{"x": 8, "y": 15, "playerId": 1}
144	1	5	2025-06-03 23:42:38.035661	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
145	1	5	2025-06-03 23:42:38.037699	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
146	1	5	2025-06-03 23:42:38.038307	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
147	1	5	2025-06-03 23:42:38.038869	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
148	1	5	2025-06-03 23:42:38.039379	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
149	1	5	2025-06-03 23:42:38.04002	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
150	1	5	2025-06-03 23:42:38.040644	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
151	1	5	2025-06-03 23:42:38.041152	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
152	1	5	2025-06-03 23:42:38.041623	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 10, "y": 10, "playerId": 1}
153	1	5	2025-06-03 23:42:38.042042	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 11, "y": 11, "playerId": 1}
154	1	5	2025-06-03 23:42:38.042479	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 12, "y": 12, "playerId": 1}
155	1	5	2025-06-03 23:42:38.042854	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 13, "y": 12, "playerId": 1}
156	1	5	2025-06-03 23:42:38.043377	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 14, "y": 13, "playerId": 1}
157	1	5	2025-06-03 23:42:38.043773	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 15, "y": 12, "playerId": 1}
158	1	5	2025-06-03 23:42:38.044182	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 16, "y": 11, "playerId": 1}
159	1	5	2025-06-03 23:42:38.044581	2025-06-03 23:47:38.04	\N	\N	map.movmentAction	{"x": 17, "y": 11, "playerId": 1}
160	1	5	2025-06-03 23:42:38.045004	2025-06-03 23:47:38.05	\N	\N	map.movmentAction	{"x": 18, "y": 12, "playerId": 1}
161	1	5	2025-06-03 23:42:38.04539	2025-06-03 23:47:38.05	\N	\N	map.movmentAction	{"x": 19, "y": 12, "playerId": 1}
162	1	5	2025-06-03 23:42:38.045891	2025-06-03 23:47:38.05	\N	\N	map.movmentAction	{"x": 20, "y": 11, "playerId": 1}
163	1	5	2025-06-03 23:42:38.046341	2025-06-03 23:47:38.05	\N	\N	map.movmentAction	{"x": 21, "y": 10, "playerId": 1}
164	1	5	2025-06-03 23:42:38.04675	2025-06-03 23:47:38.05	\N	\N	map.movmentAction	{"x": 22, "y": 9, "playerId": 1}
165	1	5	2025-06-03 23:42:38.047143	2025-06-03 23:47:38.05	\N	\N	map.movmentAction	{"x": 21, "y": 8, "playerId": 1}
166	1	5	2025-06-03 23:42:47.681799	2025-06-03 23:47:47.68	\N	\N	map.movmentAction	{"x": 2, "y": 3, "playerId": 1}
167	1	5	2025-06-03 23:42:47.682322	2025-06-03 23:47:47.68	\N	\N	map.movmentAction	{"x": 3, "y": 3, "playerId": 1}
168	1	5	2025-06-03 23:42:47.682706	2025-06-03 23:47:47.68	\N	\N	map.movmentAction	{"x": 4, "y": 3, "playerId": 1}
169	1	5	2025-06-03 23:45:18.543379	2025-06-03 23:50:18.54	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
170	1	5	2025-06-03 23:45:18.545224	2025-06-03 23:50:18.55	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
171	1	5	2025-06-03 23:45:18.545864	2025-06-03 23:50:18.55	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
172	1	5	2025-06-03 23:45:18.546336	2025-06-03 23:50:18.55	\N	\N	map.movmentAction	{"x": 5, "y": 5, "playerId": 1}
173	1	5	2025-06-03 23:45:24.984806	2025-06-03 23:50:24.98	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
174	1	5	2025-06-03 23:45:24.985458	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
175	1	5	2025-06-03 23:45:24.986068	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
176	1	5	2025-06-03 23:45:24.986608	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
177	1	5	2025-06-03 23:45:24.987133	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
178	1	5	2025-06-03 23:45:24.987595	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
179	1	5	2025-06-03 23:45:24.98805	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
180	1	5	2025-06-03 23:45:24.988489	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
181	1	5	2025-06-03 23:45:24.988897	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 10, "y": 10, "playerId": 1}
182	1	5	2025-06-03 23:45:24.989297	2025-06-03 23:50:24.99	\N	\N	map.movmentAction	{"x": 11, "y": 10, "playerId": 1}
183	1	5	2025-06-03 23:46:20.092559	2025-06-03 23:51:20.09	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
184	1	5	2025-06-03 23:46:20.093778	2025-06-03 23:51:20.09	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
185	1	5	2025-06-03 23:46:20.094169	2025-06-03 23:51:20.09	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
186	1	5	2025-06-03 23:46:20.094528	2025-06-03 23:51:20.09	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
187	1	5	2025-06-03 23:46:20.094867	2025-06-03 23:51:20.09	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
188	1	5	2025-06-03 23:46:20.095204	2025-06-03 23:51:20.1	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
189	1	5	2025-06-03 23:46:20.095525	2025-06-03 23:51:20.1	\N	\N	map.movmentAction	{"x": 8, "y": 7, "playerId": 1}
190	1	5	2025-06-03 23:46:26.69606	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
191	1	5	2025-06-03 23:46:26.696701	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
192	1	5	2025-06-03 23:46:26.69726	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
193	1	5	2025-06-03 23:46:26.697873	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
194	1	5	2025-06-03 23:46:26.69832	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
195	1	5	2025-06-03 23:46:26.698812	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
196	1	5	2025-06-03 23:46:26.699259	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
197	1	5	2025-06-03 23:46:26.6997	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
198	1	5	2025-06-03 23:46:26.700253	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
199	1	5	2025-06-03 23:46:26.700658	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
200	1	5	2025-06-03 23:46:26.701059	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
201	1	5	2025-06-03 23:46:26.701459	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 13, "y": 7, "playerId": 1}
202	1	5	2025-06-03 23:46:26.701832	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 14, "y": 8, "playerId": 1}
203	1	5	2025-06-03 23:46:26.702253	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 15, "y": 7, "playerId": 1}
204	1	5	2025-06-03 23:46:26.702757	2025-06-03 23:51:26.7	\N	\N	map.movmentAction	{"x": 16, "y": 6, "playerId": 1}
205	1	5	2025-06-03 23:46:39.148365	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
206	1	5	2025-06-03 23:46:39.14908	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
207	1	5	2025-06-03 23:46:39.149586	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
208	1	5	2025-06-03 23:46:39.150112	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
209	1	5	2025-06-03 23:46:39.150537	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
210	1	5	2025-06-03 23:46:39.150919	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
211	1	5	2025-06-03 23:46:39.151431	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
212	1	5	2025-06-03 23:46:39.151852	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
213	1	5	2025-06-03 23:46:39.152252	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 10, "y": 10, "playerId": 1}
214	1	5	2025-06-03 23:46:39.152626	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 11, "y": 11, "playerId": 1}
215	1	5	2025-06-03 23:46:39.153045	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 12, "y": 12, "playerId": 1}
216	1	5	2025-06-03 23:46:39.153436	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 13, "y": 12, "playerId": 1}
218	1	5	2025-06-03 23:46:39.154245	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 15, "y": 12, "playerId": 1}
219	1	5	2025-06-03 23:46:39.15461	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 16, "y": 11, "playerId": 1}
220	1	5	2025-06-03 23:46:39.15493	2025-06-03 23:51:39.15	\N	\N	map.movmentAction	{"x": 17, "y": 11, "playerId": 1}
221	1	5	2025-06-03 23:46:39.155272	2025-06-03 23:51:39.16	\N	\N	map.movmentAction	{"x": 18, "y": 11, "playerId": 1}
222	1	5	2025-06-03 23:46:39.15562	2025-06-03 23:51:39.16	\N	\N	map.movmentAction	{"x": 19, "y": 10, "playerId": 1}
223	1	5	2025-06-03 23:47:02.6815	2025-06-03 23:52:02.68	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
224	1	5	2025-06-03 23:47:02.682437	2025-06-03 23:52:02.68	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
225	1	5	2025-06-03 23:47:02.684123	2025-06-03 23:52:02.68	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
226	1	5	2025-06-03 23:47:02.684962	2025-06-03 23:52:02.68	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
227	1	5	2025-06-03 23:47:02.685677	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
228	1	5	2025-06-03 23:47:02.686032	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
229	1	5	2025-06-03 23:47:02.68657	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
230	1	5	2025-06-03 23:47:02.686948	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
231	1	5	2025-06-03 23:47:02.687277	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
232	1	5	2025-06-03 23:47:02.687689	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
233	1	5	2025-06-03 23:47:02.688073	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
234	1	5	2025-06-03 23:47:02.688456	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 13, "y": 6, "playerId": 1}
235	1	5	2025-06-03 23:47:02.688812	2025-06-03 23:52:02.69	\N	\N	map.movmentAction	{"x": 14, "y": 6, "playerId": 1}
236	1	5	2025-06-03 23:47:25.795058	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
237	1	5	2025-06-03 23:47:25.797813	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
238	1	5	2025-06-03 23:47:25.799855	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
239	1	5	2025-06-03 23:47:25.800841	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
240	1	5	2025-06-03 23:47:25.80144	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
241	1	5	2025-06-03 23:47:25.801959	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
242	1	5	2025-06-03 23:47:25.802488	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
243	1	5	2025-06-03 23:47:25.804484	2025-06-03 23:52:25.8	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
244	1	5	2025-06-03 23:47:25.805235	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 8, "y": 13, "playerId": 1}
245	1	5	2025-06-03 23:47:25.805853	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 9, "y": 14, "playerId": 1}
246	1	5	2025-06-03 23:47:25.8071	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 10, "y": 15, "playerId": 1}
247	1	5	2025-06-03 23:47:25.80883	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 11, "y": 16, "playerId": 1}
248	1	5	2025-06-03 23:47:25.810035	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 12, "y": 17, "playerId": 1}
249	1	5	2025-06-03 23:47:25.810715	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 13, "y": 18, "playerId": 1}
250	1	5	2025-06-03 23:47:25.811253	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 14, "y": 19, "playerId": 1}
251	1	5	2025-06-03 23:47:25.813019	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 15, "y": 18, "playerId": 1}
252	1	5	2025-06-03 23:47:25.814269	2025-06-03 23:52:25.81	\N	\N	map.movmentAction	{"x": 16, "y": 18, "playerId": 1}
253	1	5	2025-06-03 23:47:25.816822	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 17, "y": 19, "playerId": 1}
254	1	5	2025-06-03 23:47:25.817598	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 17, "y": 20, "playerId": 1}
255	1	5	2025-06-03 23:47:25.818322	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 18, "y": 21, "playerId": 1}
256	1	5	2025-06-03 23:47:25.819876	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 19, "y": 21, "playerId": 1}
257	1	5	2025-06-03 23:47:25.820966	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 20, "y": 21, "playerId": 1}
258	1	5	2025-06-03 23:47:25.821646	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 21, "y": 21, "playerId": 1}
259	1	5	2025-06-03 23:47:25.822181	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 22, "y": 21, "playerId": 1}
260	1	5	2025-06-03 23:47:25.822687	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 23, "y": 21, "playerId": 1}
261	1	5	2025-06-03 23:47:25.823757	2025-06-03 23:52:25.82	\N	\N	map.movmentAction	{"x": 24, "y": 21, "playerId": 1}
262	1	5	2025-06-04 00:07:03.336724	2025-06-04 00:12:03.34	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
263	1	5	2025-06-04 00:07:03.337672	2025-06-04 00:12:03.34	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
264	1	5	2025-06-04 00:07:03.33812	2025-06-04 00:12:03.34	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
265	1	5	2025-06-04 00:07:03.338505	2025-06-04 00:12:03.34	\N	\N	map.movmentAction	{"x": 5, "y": 5, "playerId": 1}
266	1	5	2025-06-04 00:07:12.153128	2025-06-04 00:12:12.15	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
267	1	5	2025-06-04 00:07:12.153753	2025-06-04 00:12:12.15	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
268	1	5	2025-06-04 00:07:12.154307	2025-06-04 00:12:12.15	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
269	1	5	2025-06-04 00:07:12.154721	2025-06-04 00:12:12.15	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
270	1	5	2025-06-04 00:07:12.155099	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
271	1	5	2025-06-04 00:07:12.155471	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
272	1	5	2025-06-04 00:07:12.155892	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
273	1	5	2025-06-04 00:07:12.156275	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
274	1	5	2025-06-04 00:07:12.1567	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
275	1	5	2025-06-04 00:07:12.15703	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
276	1	5	2025-06-04 00:07:12.157389	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
277	1	5	2025-06-04 00:07:12.157784	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 13, "y": 6, "playerId": 1}
278	1	5	2025-06-04 00:07:12.158177	2025-06-04 00:12:12.16	\N	\N	map.movmentAction	{"x": 14, "y": 5, "playerId": 1}
279	1	5	2025-06-04 00:11:13.729942	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
280	1	5	2025-06-04 00:11:13.7312	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
281	1	5	2025-06-04 00:11:13.73178	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
282	1	5	2025-06-04 00:11:13.73229	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
283	1	5	2025-06-04 00:11:13.73279	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
284	1	5	2025-06-04 00:11:13.733276	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
285	1	5	2025-06-04 00:11:13.733742	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
286	1	5	2025-06-04 00:11:13.734191	2025-06-04 00:16:13.73	\N	\N	map.movmentAction	{"x": 6, "y": 12, "playerId": 1}
287	1	5	2025-06-04 00:11:26.500385	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
288	1	5	2025-06-04 00:11:26.501236	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
289	1	5	2025-06-04 00:11:26.50181	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
290	1	5	2025-06-04 00:11:26.502297	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
291	1	5	2025-06-04 00:11:26.502785	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
292	1	5	2025-06-04 00:11:26.503183	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
293	1	5	2025-06-04 00:11:26.503615	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
294	1	5	2025-06-04 00:11:26.504014	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
295	1	5	2025-06-04 00:11:26.504478	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 9, "y": 12, "playerId": 1}
296	1	5	2025-06-04 00:11:26.50491	2025-06-04 00:16:26.5	\N	\N	map.movmentAction	{"x": 10, "y": 11, "playerId": 1}
297	1	5	2025-06-04 00:11:26.505309	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 11, "y": 11, "playerId": 1}
298	1	5	2025-06-04 00:11:26.505737	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 12, "y": 12, "playerId": 1}
299	1	5	2025-06-04 00:11:26.506182	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 13, "y": 12, "playerId": 1}
300	1	5	2025-06-04 00:11:26.506835	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 14, "y": 13, "playerId": 1}
301	1	5	2025-06-04 00:11:26.507358	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 15, "y": 12, "playerId": 1}
302	1	5	2025-06-04 00:11:26.507811	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 16, "y": 11, "playerId": 1}
303	1	5	2025-06-04 00:11:26.508217	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 17, "y": 11, "playerId": 1}
304	1	5	2025-06-04 00:11:26.508607	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 18, "y": 12, "playerId": 1}
305	1	5	2025-06-04 00:11:26.508958	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 19, "y": 12, "playerId": 1}
306	1	5	2025-06-04 00:11:26.509381	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 20, "y": 11, "playerId": 1}
307	1	5	2025-06-04 00:11:26.509763	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 21, "y": 10, "playerId": 1}
308	1	5	2025-06-04 00:11:26.510151	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 22, "y": 11, "playerId": 1}
309	1	5	2025-06-04 00:11:26.510529	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 23, "y": 12, "playerId": 1}
310	1	5	2025-06-04 00:11:26.510879	2025-06-04 00:16:26.51	\N	\N	map.movmentAction	{"x": 24, "y": 11, "playerId": 1}
311	1	5	2025-06-04 00:12:09.796727	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
312	1	5	2025-06-04 00:12:09.797757	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
313	1	5	2025-06-04 00:12:09.798218	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
314	1	5	2025-06-04 00:12:09.798683	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
315	1	5	2025-06-04 00:12:09.799166	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
316	1	5	2025-06-04 00:12:09.799688	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
317	1	5	2025-06-04 00:12:09.80009	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
318	1	5	2025-06-04 00:12:09.800587	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 9, "y": 5, "playerId": 1}
319	1	5	2025-06-04 00:12:09.800952	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 10, "y": 5, "playerId": 1}
320	1	5	2025-06-04 00:12:09.801311	2025-06-04 00:17:09.8	\N	\N	map.movmentAction	{"x": 11, "y": 4, "playerId": 1}
321	1	5	2025-06-04 00:12:38.046177	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
322	1	5	2025-06-04 00:12:38.046756	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
323	1	5	2025-06-04 00:12:38.047212	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
324	1	5	2025-06-04 00:12:38.047574	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
325	1	5	2025-06-04 00:12:38.048034	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
326	1	5	2025-06-04 00:12:38.04841	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
327	1	5	2025-06-04 00:12:38.04891	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
328	1	5	2025-06-04 00:12:38.049277	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
329	1	5	2025-06-04 00:12:38.049652	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
330	1	5	2025-06-04 00:12:38.05006	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
331	1	5	2025-06-04 00:12:38.050422	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
332	1	5	2025-06-04 00:12:38.050916	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 13, "y": 7, "playerId": 1}
333	1	5	2025-06-04 00:12:38.051243	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 14, "y": 8, "playerId": 1}
334	1	5	2025-06-04 00:12:38.05156	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 15, "y": 7, "playerId": 1}
335	1	5	2025-06-04 00:12:38.051909	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 16, "y": 8, "playerId": 1}
336	1	5	2025-06-04 00:12:38.052226	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 17, "y": 9, "playerId": 1}
337	1	5	2025-06-04 00:12:38.052694	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 18, "y": 8, "playerId": 1}
338	1	5	2025-06-04 00:12:38.05303	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 19, "y": 8, "playerId": 1}
339	1	5	2025-06-04 00:12:38.053646	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 20, "y": 7, "playerId": 1}
340	1	5	2025-06-04 00:12:38.054018	2025-06-04 00:17:38.05	\N	\N	map.movmentAction	{"x": 19, "y": 6, "playerId": 1}
341	1	5	2025-06-04 00:22:15.165195	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
342	1	5	2025-06-04 00:22:15.166714	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
343	1	5	2025-06-04 00:22:15.168343	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
344	1	5	2025-06-04 00:22:15.168994	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
345	1	5	2025-06-04 00:22:15.171278	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 5, "y": 9, "playerId": 1}
346	1	5	2025-06-04 00:22:15.171969	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 4, "y": 10, "playerId": 1}
347	1	5	2025-06-04 00:22:15.172549	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 4, "y": 11, "playerId": 1}
348	1	5	2025-06-04 00:22:15.17323	2025-06-04 00:27:15.17	\N	\N	map.movmentAction	{"x": 5, "y": 12, "playerId": 1}
349	1	5	2025-06-04 00:22:24.774003	2025-06-04 00:27:24.77	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
350	1	5	2025-06-04 00:22:24.774654	2025-06-04 00:27:24.77	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
351	1	5	2025-06-04 00:22:24.775152	2025-06-04 00:27:24.78	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
352	1	5	2025-06-04 00:22:24.775562	2025-06-04 00:27:24.78	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
353	1	5	2025-06-04 00:22:24.776079	2025-06-04 00:27:24.78	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
354	1	5	2025-06-04 00:22:24.776545	2025-06-04 00:27:24.78	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
355	1	5	2025-06-04 00:22:24.776902	2025-06-04 00:27:24.78	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
356	1	5	2025-06-04 00:22:24.7773	2025-06-04 00:27:24.78	\N	\N	map.movmentAction	{"x": 9, "y": 5, "playerId": 1}
357	1	5	2025-06-04 00:22:24.777703	2025-06-04 00:27:24.78	\N	\N	map.movmentAction	{"x": 10, "y": 5, "playerId": 1}
358	1	5	2025-06-04 00:22:50.679185	2025-06-04 00:27:50.68	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
359	1	5	2025-06-04 00:22:50.680612	2025-06-04 00:27:50.68	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
360	1	5	2025-06-04 00:22:50.681042	2025-06-04 00:27:50.68	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
361	1	5	2025-06-04 00:22:50.681472	2025-06-04 00:27:50.68	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
362	1	5	2025-06-04 00:22:50.681895	2025-06-04 00:27:50.68	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
363	1	5	2025-06-04 00:22:50.682242	2025-06-04 00:27:50.68	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
364	1	5	2025-06-04 00:22:50.682643	2025-06-04 00:27:50.68	\N	\N	map.movmentAction	{"x": 6, "y": 11, "playerId": 1}
365	1	5	2025-06-04 00:23:22.249503	2025-06-04 00:28:22.25	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
366	1	5	2025-06-04 00:23:22.25194	2025-06-04 00:28:22.25	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
367	1	5	2025-06-04 00:23:22.252551	2025-06-04 00:28:22.25	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
368	1	5	2025-06-04 00:23:22.25328	2025-06-04 00:28:22.25	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
369	1	5	2025-06-04 00:23:22.253826	2025-06-04 00:28:22.25	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
370	1	5	2025-06-04 00:23:22.254379	2025-06-04 00:28:22.25	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
371	1	5	2025-06-04 00:23:22.254933	2025-06-04 00:28:22.25	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
372	1	5	2025-06-04 00:23:22.255499	2025-06-04 00:28:22.26	\N	\N	map.movmentAction	{"x": 9, "y": 5, "playerId": 1}
373	1	5	2025-06-04 00:23:22.256022	2025-06-04 00:28:22.26	\N	\N	map.movmentAction	{"x": 10, "y": 4, "playerId": 1}
374	1	5	2025-06-04 00:23:29.931669	2025-06-04 00:28:29.93	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
375	1	5	2025-06-04 00:23:29.932272	2025-06-04 00:28:29.93	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
376	1	5	2025-06-04 00:23:29.932753	2025-06-04 00:28:29.93	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
377	1	5	2025-06-04 00:23:29.933232	2025-06-04 00:28:29.93	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
378	1	5	2025-06-04 00:23:29.933671	2025-06-04 00:28:29.93	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
379	1	5	2025-06-04 00:23:29.934061	2025-06-04 00:28:29.93	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
380	1	5	2025-06-04 00:23:29.934448	2025-06-04 00:28:29.93	\N	\N	map.movmentAction	{"x": 8, "y": 11, "playerId": 1}
381	1	5	2025-06-04 00:24:47.568208	2025-06-04 00:29:47.57	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
382	1	5	2025-06-04 00:24:47.579851	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
383	1	5	2025-06-04 00:24:47.580649	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
384	1	5	2025-06-04 00:24:47.581209	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
385	1	5	2025-06-04 00:24:47.58168	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
386	1	5	2025-06-04 00:24:47.582097	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
387	1	5	2025-06-04 00:24:47.582556	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
388	1	5	2025-06-04 00:24:47.582994	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
389	1	5	2025-06-04 00:24:47.58343	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
390	1	5	2025-06-04 00:24:47.583877	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
391	1	5	2025-06-04 00:24:47.584283	2025-06-04 00:29:47.58	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
392	1	5	2025-06-04 00:42:26.436848	2025-06-04 00:47:26.44	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
393	1	5	2025-06-04 00:42:26.439124	2025-06-04 00:47:26.44	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
394	1	5	2025-06-04 00:42:26.439664	2025-06-04 00:47:26.44	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
395	1	5	2025-06-04 00:42:26.440109	2025-06-04 00:47:26.44	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
396	1	5	2025-06-04 00:42:26.440511	2025-06-04 00:47:26.44	\N	\N	map.movmentAction	{"x": 6, "y": 5, "playerId": 1}
397	1	5	2025-06-04 00:42:38.948496	2025-06-04 00:47:38.95	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
398	1	5	2025-06-04 00:42:38.95997	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
399	1	5	2025-06-04 00:42:38.960741	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
400	1	5	2025-06-04 00:42:38.961289	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
401	1	5	2025-06-04 00:42:38.961726	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
402	1	5	2025-06-04 00:42:38.962159	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
403	1	5	2025-06-04 00:42:38.962606	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
404	1	5	2025-06-04 00:42:38.963163	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
405	1	5	2025-06-04 00:42:38.963673	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
406	1	5	2025-06-04 00:42:38.964144	2025-06-04 00:47:38.96	\N	\N	map.movmentAction	{"x": 10, "y": 7, "playerId": 1}
407	1	5	2025-06-04 00:44:34.843776	2025-06-04 00:49:34.84	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
408	1	5	2025-06-04 00:44:34.845137	2025-06-04 00:49:34.85	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
409	1	5	2025-06-04 00:44:34.846027	2025-06-04 00:49:34.85	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
410	1	5	2025-06-04 00:44:34.846444	2025-06-04 00:49:34.85	\N	\N	map.movmentAction	{"x": 5, "y": 4, "playerId": 1}
411	1	5	2025-06-04 00:44:34.846838	2025-06-04 00:49:34.85	\N	\N	map.movmentAction	{"x": 6, "y": 4, "playerId": 1}
412	1	5	2025-06-04 00:44:53.136285	2025-06-04 00:49:53.14	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
413	1	5	2025-06-04 00:44:53.138584	2025-06-04 00:49:53.14	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
414	1	5	2025-06-04 00:44:53.139313	2025-06-04 00:49:53.14	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
415	1	5	2025-06-04 00:44:53.147936	2025-06-04 00:49:53.15	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
416	1	5	2025-06-04 00:44:53.150539	2025-06-04 00:49:53.15	\N	\N	map.movmentAction	{"x": 5, "y": 9, "playerId": 1}
417	1	5	2025-06-04 00:44:53.152327	2025-06-04 00:49:53.15	\N	\N	map.movmentAction	{"x": 5, "y": 10, "playerId": 1}
418	1	5	2025-06-04 00:48:16.402433	2025-06-04 00:53:16.4	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
419	1	5	2025-06-04 00:48:16.404059	2025-06-04 00:53:16.4	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
420	1	5	2025-06-04 00:48:16.404513	2025-06-04 00:53:16.4	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
421	1	5	2025-06-04 00:48:16.404953	2025-06-04 00:53:16.4	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
422	1	5	2025-06-04 00:48:16.405438	2025-06-04 00:53:16.41	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
423	1	5	2025-06-04 00:48:16.405865	2025-06-04 00:53:16.41	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
424	1	5	2025-06-04 00:48:16.406303	2025-06-04 00:53:16.41	\N	\N	map.movmentAction	{"x": 8, "y": 7, "playerId": 1}
425	1	5	2025-06-04 00:48:16.406771	2025-06-04 00:53:16.41	\N	\N	map.movmentAction	{"x": 9, "y": 7, "playerId": 1}
426	1	5	2025-06-04 00:48:24.191891	2025-06-04 00:53:24.19	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
427	1	5	2025-06-04 00:48:24.192515	2025-06-04 00:53:24.19	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
428	1	5	2025-06-04 00:48:24.192978	2025-06-04 00:53:24.19	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
429	1	5	2025-06-04 00:48:24.193407	2025-06-04 00:53:24.19	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
430	1	5	2025-06-04 00:48:24.193915	2025-06-04 00:53:24.19	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
431	1	5	2025-06-04 00:48:24.194304	2025-06-04 00:53:24.19	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
432	1	5	2025-06-04 00:48:24.194742	2025-06-04 00:53:24.19	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
433	1	5	2025-06-04 00:48:24.195168	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
434	1	5	2025-06-04 00:48:24.19564	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 8, "y": 13, "playerId": 1}
435	1	5	2025-06-04 00:48:24.196098	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 9, "y": 14, "playerId": 1}
436	1	5	2025-06-04 00:48:24.197492	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 10, "y": 15, "playerId": 1}
437	1	5	2025-06-04 00:48:24.197916	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 11, "y": 16, "playerId": 1}
438	1	5	2025-06-04 00:48:24.198332	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 12, "y": 17, "playerId": 1}
439	1	5	2025-06-04 00:48:24.198865	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 13, "y": 18, "playerId": 1}
440	1	5	2025-06-04 00:48:24.199233	2025-06-04 00:53:24.2	\N	\N	map.movmentAction	{"x": 14, "y": 18, "playerId": 1}
441	1	5	2025-06-04 00:50:26.950597	2025-06-04 00:55:26.95	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
442	1	5	2025-06-04 00:50:26.951941	2025-06-04 00:55:26.95	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
443	1	5	2025-06-04 00:50:26.952444	2025-06-04 00:55:26.95	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
444	1	5	2025-06-04 00:50:26.952864	2025-06-04 00:55:26.95	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
445	1	5	2025-06-04 00:50:26.953404	2025-06-04 00:55:26.95	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
446	1	5	2025-06-04 00:50:26.953776	2025-06-04 00:55:26.95	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
447	1	5	2025-06-04 00:50:26.954142	2025-06-04 00:55:26.95	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
448	1	5	2025-06-04 00:50:32.555237	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
449	1	5	2025-06-04 00:50:32.555792	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
450	1	5	2025-06-04 00:50:32.556318	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
451	1	5	2025-06-04 00:50:32.556849	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
452	1	5	2025-06-04 00:50:32.557294	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
453	1	5	2025-06-04 00:50:32.557742	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
454	1	5	2025-06-04 00:50:32.558207	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
455	1	5	2025-06-04 00:50:32.558648	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
456	1	5	2025-06-04 00:50:32.559056	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 8, "y": 13, "playerId": 1}
457	1	5	2025-06-04 00:50:32.559535	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 9, "y": 14, "playerId": 1}
458	1	5	2025-06-04 00:50:32.559986	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 10, "y": 15, "playerId": 1}
459	1	5	2025-06-04 00:50:32.560364	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 11, "y": 16, "playerId": 1}
460	1	5	2025-06-04 00:50:32.560759	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 12, "y": 17, "playerId": 1}
461	1	5	2025-06-04 00:50:32.561148	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 13, "y": 18, "playerId": 1}
462	1	5	2025-06-04 00:50:32.56168	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 14, "y": 19, "playerId": 1}
463	1	5	2025-06-04 00:50:32.562046	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 15, "y": 18, "playerId": 1}
464	1	5	2025-06-04 00:50:32.56246	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 16, "y": 18, "playerId": 1}
465	1	5	2025-06-04 00:50:32.562861	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 17, "y": 19, "playerId": 1}
466	1	5	2025-06-04 00:50:32.56329	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 17, "y": 20, "playerId": 1}
467	1	5	2025-06-04 00:50:32.563696	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 18, "y": 21, "playerId": 1}
468	1	5	2025-06-04 00:50:32.56409	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 19, "y": 22, "playerId": 1}
469	1	5	2025-06-04 00:50:32.564437	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 20, "y": 23, "playerId": 1}
470	1	5	2025-06-04 00:50:32.564805	2025-06-04 00:55:32.56	\N	\N	map.movmentAction	{"x": 21, "y": 24, "playerId": 1}
471	1	5	2025-06-04 00:50:32.56525	2025-06-04 00:55:32.57	\N	\N	map.movmentAction	{"x": 22, "y": 24, "playerId": 1}
472	1	5	2025-06-04 00:50:32.565619	2025-06-04 00:55:32.57	\N	\N	map.movmentAction	{"x": 23, "y": 25, "playerId": 1}
473	1	5	2025-06-04 00:50:32.565983	2025-06-04 00:55:32.57	\N	\N	map.movmentAction	{"x": 24, "y": 26, "playerId": 1}
474	1	5	2025-06-04 00:50:32.566518	2025-06-04 00:55:32.57	\N	\N	map.movmentAction	{"x": 25, "y": 27, "playerId": 1}
475	1	5	2025-06-04 00:50:32.567064	2025-06-04 00:55:32.57	\N	\N	map.movmentAction	{"x": 26, "y": 27, "playerId": 1}
476	1	5	2025-06-04 00:52:34.826595	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
477	1	5	2025-06-04 00:52:34.828128	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
478	1	5	2025-06-04 00:52:34.828779	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
479	1	5	2025-06-04 00:52:34.829316	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
480	1	5	2025-06-04 00:52:34.829852	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
481	1	5	2025-06-04 00:52:34.830395	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
482	1	5	2025-06-04 00:52:34.830982	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
483	1	5	2025-06-04 00:52:34.83161	2025-06-04 00:57:34.83	\N	\N	map.movmentAction	{"x": 9, "y": 8, "playerId": 1}
484	1	5	2025-06-04 01:00:56.049142	2025-06-04 01:05:56.05	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
485	1	5	2025-06-04 01:00:56.051472	2025-06-04 01:05:56.05	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
486	1	5	2025-06-04 01:00:56.052194	2025-06-04 01:05:56.05	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
487	1	5	2025-06-04 01:00:56.052718	2025-06-04 01:05:56.05	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
488	1	5	2025-06-04 01:00:56.053198	2025-06-04 01:05:56.05	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
489	1	5	2025-06-04 01:00:56.054596	2025-06-04 01:05:56.05	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
490	1	5	2025-06-04 01:00:56.055203	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
491	1	5	2025-06-04 01:00:56.055834	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
492	1	5	2025-06-04 01:00:56.056315	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
493	1	5	2025-06-04 01:00:56.05677	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
494	1	5	2025-06-04 01:00:56.057496	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
495	1	5	2025-06-04 01:00:56.058192	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 13, "y": 8, "playerId": 1}
496	1	5	2025-06-04 01:00:56.058824	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 14, "y": 9, "playerId": 1}
497	1	5	2025-06-04 01:00:56.060088	2025-06-04 01:05:56.06	\N	\N	map.movmentAction	{"x": 15, "y": 9, "playerId": 1}
498	1	5	2025-06-04 01:08:33.840624	2025-06-04 01:13:33.84	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
499	1	5	2025-06-04 01:08:33.842787	2025-06-04 01:13:33.84	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
500	1	5	2025-06-04 01:08:33.843427	2025-06-04 01:13:33.84	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
501	1	5	2025-06-04 01:08:33.843939	2025-06-04 01:13:33.84	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
502	1	5	2025-06-04 01:08:33.844442	2025-06-04 01:13:33.84	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
503	1	5	2025-06-04 01:08:33.844876	2025-06-04 01:13:33.84	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
504	1	5	2025-06-04 01:08:33.845323	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
505	1	5	2025-06-04 01:08:33.84583	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
506	1	5	2025-06-04 01:08:33.846307	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
507	1	5	2025-06-04 01:08:33.846703	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
508	1	5	2025-06-04 01:08:33.847069	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 12, "y": 8, "playerId": 1}
509	1	5	2025-06-04 01:08:33.847438	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 13, "y": 9, "playerId": 1}
510	1	5	2025-06-04 01:08:33.847944	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 14, "y": 10, "playerId": 1}
511	1	5	2025-06-04 01:08:33.848342	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 15, "y": 11, "playerId": 1}
512	1	5	2025-06-04 01:08:33.848724	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 16, "y": 11, "playerId": 1}
513	1	5	2025-06-04 01:08:33.849091	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 17, "y": 11, "playerId": 1}
514	1	5	2025-06-04 01:08:33.849446	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 18, "y": 12, "playerId": 1}
515	1	5	2025-06-04 01:08:33.849828	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 19, "y": 12, "playerId": 1}
516	1	5	2025-06-04 01:08:33.850216	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 20, "y": 11, "playerId": 1}
517	1	5	2025-06-04 01:08:33.850604	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 21, "y": 10, "playerId": 1}
518	1	5	2025-06-04 01:08:33.851047	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 22, "y": 10, "playerId": 1}
519	1	5	2025-06-04 01:08:33.851471	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 23, "y": 9, "playerId": 1}
520	1	5	2025-06-04 01:08:33.851915	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 24, "y": 8, "playerId": 1}
521	1	5	2025-06-04 01:08:33.852306	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 25, "y": 8, "playerId": 1}
522	1	5	2025-06-04 01:08:33.852751	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 26, "y": 7, "playerId": 1}
523	1	5	2025-06-04 01:08:33.853108	2025-06-04 01:13:33.85	\N	\N	map.movmentAction	{"x": 26, "y": 6, "playerId": 1}
524	1	5	2025-06-04 01:12:41.35388	2025-06-04 01:17:41.35	\N	\N	map.movmentAction	{"x": 20, "y": 24, "playerId": 1}
525	1	5	2025-06-04 01:12:41.356111	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 20, "y": 23, "playerId": 1}
526	1	5	2025-06-04 01:12:41.356956	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 19, "y": 22, "playerId": 1}
527	1	5	2025-06-04 01:12:41.357628	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 18, "y": 21, "playerId": 1}
528	1	5	2025-06-04 01:12:41.358383	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 17, "y": 20, "playerId": 1}
529	1	5	2025-06-04 01:12:41.359096	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 17, "y": 19, "playerId": 1}
530	1	5	2025-06-04 01:12:41.359829	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 16, "y": 18, "playerId": 1}
531	1	5	2025-06-04 01:12:41.360498	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 15, "y": 18, "playerId": 1}
532	1	5	2025-06-04 01:12:41.361109	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 14, "y": 19, "playerId": 1}
533	1	5	2025-06-04 01:12:41.361659	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 13, "y": 18, "playerId": 1}
534	1	5	2025-06-04 01:12:41.36222	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 12, "y": 19, "playerId": 1}
535	1	5	2025-06-04 01:12:41.362716	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 11, "y": 20, "playerId": 1}
536	1	5	2025-06-04 01:12:41.363405	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 10, "y": 21, "playerId": 1}
537	1	5	2025-06-04 01:12:41.363837	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 9, "y": 21, "playerId": 1}
538	1	5	2025-06-04 01:12:41.364368	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 8, "y": 20, "playerId": 1}
539	1	5	2025-06-04 01:12:41.364855	2025-06-04 01:17:41.36	\N	\N	map.movmentAction	{"x": 7, "y": 19, "playerId": 1}
540	1	5	2025-06-04 01:12:56.774944	2025-06-04 01:17:56.77	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
541	1	5	2025-06-04 01:12:56.775481	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
542	1	5	2025-06-04 01:12:56.776065	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
543	1	5	2025-06-04 01:12:56.776601	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
544	1	5	2025-06-04 01:12:56.777129	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
545	1	5	2025-06-04 01:12:56.777747	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
546	1	5	2025-06-04 01:12:56.778333	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
547	1	5	2025-06-04 01:12:56.778864	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
548	1	5	2025-06-04 01:12:56.779375	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 10, "y": 10, "playerId": 1}
549	1	5	2025-06-04 01:12:56.779835	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 11, "y": 11, "playerId": 1}
550	1	5	2025-06-04 01:12:56.780349	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 12, "y": 12, "playerId": 1}
551	1	5	2025-06-04 01:12:56.780769	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 13, "y": 12, "playerId": 1}
552	1	5	2025-06-04 01:12:56.781364	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 14, "y": 13, "playerId": 1}
553	1	5	2025-06-04 01:12:56.781739	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 15, "y": 12, "playerId": 1}
554	1	5	2025-06-04 01:12:56.782179	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 16, "y": 11, "playerId": 1}
555	1	5	2025-06-04 01:12:56.782598	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 17, "y": 11, "playerId": 1}
556	1	5	2025-06-04 01:12:56.783023	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 18, "y": 12, "playerId": 1}
557	1	5	2025-06-04 01:12:56.783498	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 19, "y": 12, "playerId": 1}
558	1	5	2025-06-04 01:12:56.78392	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 20, "y": 11, "playerId": 1}
559	1	5	2025-06-04 01:12:56.784349	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 21, "y": 10, "playerId": 1}
560	1	5	2025-06-04 01:12:56.784739	2025-06-04 01:17:56.78	\N	\N	map.movmentAction	{"x": 22, "y": 9, "playerId": 1}
561	1	5	2025-06-04 01:12:56.785184	2025-06-04 01:17:56.79	\N	\N	map.movmentAction	{"x": 23, "y": 9, "playerId": 1}
562	1	5	2025-06-04 01:13:14.67247	2025-06-04 01:18:14.67	\N	\N	map.movmentAction	{"x": 4, "y": 17, "playerId": 1}
563	1	5	2025-06-04 01:13:14.673796	2025-06-04 01:18:14.67	\N	\N	map.movmentAction	{"x": 5, "y": 16, "playerId": 1}
564	1	5	2025-06-04 01:13:14.674438	2025-06-04 01:18:14.67	\N	\N	map.movmentAction	{"x": 6, "y": 15, "playerId": 1}
565	1	5	2025-06-04 01:13:14.674967	2025-06-04 01:18:14.67	\N	\N	map.movmentAction	{"x": 7, "y": 14, "playerId": 1}
566	1	5	2025-06-04 01:13:14.675673	2025-06-04 01:18:14.68	\N	\N	map.movmentAction	{"x": 8, "y": 15, "playerId": 1}
567	1	5	2025-06-04 01:13:14.677264	2025-06-04 01:18:14.68	\N	\N	map.movmentAction	{"x": 9, "y": 14, "playerId": 1}
568	1	5	2025-06-04 01:13:14.677787	2025-06-04 01:18:14.68	\N	\N	map.movmentAction	{"x": 10, "y": 15, "playerId": 1}
569	1	5	2025-06-04 01:15:11.423063	2025-06-04 01:20:11.42	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
570	1	5	2025-06-04 01:15:11.426066	2025-06-04 01:20:11.43	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
571	1	5	2025-06-04 01:15:11.426776	2025-06-04 01:20:11.43	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
572	1	5	2025-06-04 01:15:11.427475	2025-06-04 01:20:11.43	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
573	1	5	2025-06-04 01:15:11.431496	2025-06-04 01:20:11.43	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
574	1	5	2025-06-04 01:15:11.432369	2025-06-04 01:20:11.43	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
575	1	5	2025-06-04 01:15:11.433002	2025-06-04 01:20:11.43	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
576	1	5	2025-06-04 01:15:11.433724	2025-06-04 01:20:11.43	\N	\N	map.movmentAction	{"x": 9, "y": 6, "playerId": 1}
577	1	5	2025-06-04 21:39:13.846131	2025-06-04 21:44:13.85	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
578	1	5	2025-06-04 21:39:13.857492	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
579	1	5	2025-06-04 21:39:13.858386	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
580	1	5	2025-06-04 21:39:13.859205	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
581	1	5	2025-06-04 21:39:13.860159	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
582	1	5	2025-06-04 21:39:13.861296	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
583	1	5	2025-06-04 21:39:13.861797	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
584	1	5	2025-06-04 21:39:13.862191	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
585	1	5	2025-06-04 21:39:13.863024	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 9, "y": 12, "playerId": 1}
586	1	5	2025-06-04 21:39:13.863427	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 10, "y": 11, "playerId": 1}
587	1	5	2025-06-04 21:39:13.863837	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 11, "y": 12, "playerId": 1}
588	1	5	2025-06-04 21:39:13.864183	2025-06-04 21:44:13.86	\N	\N	map.movmentAction	{"x": 12, "y": 13, "playerId": 1}
589	1	5	2025-06-04 21:39:13.865028	2025-06-04 21:44:13.87	\N	\N	map.movmentAction	{"x": 13, "y": 14, "playerId": 1}
590	1	5	2025-06-04 21:39:22.494246	2025-06-04 21:44:22.49	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
591	1	5	2025-06-04 21:39:22.494612	2025-06-04 21:44:22.49	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
592	1	5	2025-06-04 21:39:22.494927	2025-06-04 21:44:22.49	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
593	1	5	2025-06-04 21:39:22.495225	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
594	1	5	2025-06-04 21:39:22.49551	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
595	1	5	2025-06-04 21:39:22.495826	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
596	1	5	2025-06-04 21:39:22.496097	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
597	1	5	2025-06-04 21:39:22.496347	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
598	1	5	2025-06-04 21:39:22.496743	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
599	1	5	2025-06-04 21:39:22.49704	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
600	1	5	2025-06-04 21:39:22.497317	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
601	1	5	2025-06-04 21:39:22.497679	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 13, "y": 6, "playerId": 1}
602	1	5	2025-06-04 21:39:22.498172	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 14, "y": 5, "playerId": 1}
603	1	5	2025-06-04 21:39:22.498494	2025-06-04 21:44:22.5	\N	\N	map.movmentAction	{"x": 15, "y": 4, "playerId": 1}
604	1	5	2025-06-04 21:40:54.122166	2025-06-04 21:45:54.12	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
605	1	5	2025-06-04 21:40:54.123012	2025-06-04 21:45:54.12	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
606	1	5	2025-06-04 21:40:54.123382	2025-06-04 21:45:54.12	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
607	1	5	2025-06-04 21:40:54.123743	2025-06-04 21:45:54.12	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
608	1	5	2025-06-04 21:40:54.124069	2025-06-04 21:45:54.12	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
609	1	5	2025-06-04 21:40:54.124389	2025-06-04 21:45:54.12	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
610	1	5	2025-06-04 21:40:54.124714	2025-06-04 21:45:54.12	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
611	1	5	2025-06-04 21:40:54.12501	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
612	1	5	2025-06-04 21:40:54.125297	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 8, "y": 13, "playerId": 1}
613	1	5	2025-06-04 21:40:54.125588	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 9, "y": 14, "playerId": 1}
614	1	5	2025-06-04 21:40:54.125939	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 10, "y": 15, "playerId": 1}
615	1	5	2025-06-04 21:40:54.126214	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 11, "y": 16, "playerId": 1}
616	1	5	2025-06-04 21:40:54.126483	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 12, "y": 17, "playerId": 1}
617	1	5	2025-06-04 21:40:54.126753	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 13, "y": 18, "playerId": 1}
618	1	5	2025-06-04 21:40:54.127012	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 14, "y": 19, "playerId": 1}
619	1	5	2025-06-04 21:40:54.127262	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 15, "y": 20, "playerId": 1}
620	1	5	2025-06-04 21:40:54.127514	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 15, "y": 21, "playerId": 1}
621	1	5	2025-06-04 21:40:54.127782	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 15, "y": 22, "playerId": 1}
622	1	5	2025-06-04 21:40:54.128045	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 15, "y": 23, "playerId": 1}
623	1	5	2025-06-04 21:40:54.1283	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 16, "y": 24, "playerId": 1}
624	1	5	2025-06-04 21:40:54.128559	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 16, "y": 25, "playerId": 1}
625	1	5	2025-06-04 21:40:54.128821	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 17, "y": 26, "playerId": 1}
626	1	5	2025-06-04 21:40:54.12905	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 18, "y": 27, "playerId": 1}
627	1	5	2025-06-04 21:40:54.129307	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 19, "y": 28, "playerId": 1}
628	1	5	2025-06-04 21:40:54.129567	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 20, "y": 29, "playerId": 1}
629	1	5	2025-06-04 21:40:54.129821	2025-06-04 21:45:54.13	\N	\N	map.movmentAction	{"x": 21, "y": 30, "playerId": 1}
630	1	5	2025-06-04 21:52:52.94149	2025-06-04 21:57:52.94	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
631	1	5	2025-06-04 21:52:52.943306	2025-06-04 21:57:52.94	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
632	1	5	2025-06-04 21:52:52.943674	2025-06-04 21:57:52.94	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
633	1	5	2025-06-04 21:52:52.944016	2025-06-04 21:57:52.94	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
634	1	5	2025-06-04 21:52:52.944356	2025-06-04 21:57:52.94	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
635	1	5	2025-06-04 21:52:52.944684	2025-06-04 21:57:52.94	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
636	1	5	2025-06-04 21:52:59.532935	2025-06-04 21:57:59.53	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
637	1	5	2025-06-04 21:52:59.533317	2025-06-04 21:57:59.53	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
638	1	5	2025-06-04 21:52:59.533679	2025-06-04 21:57:59.53	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
639	1	5	2025-06-04 21:52:59.53399	2025-06-04 21:57:59.53	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
640	1	5	2025-06-04 21:52:59.534304	2025-06-04 21:57:59.53	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
641	1	5	2025-06-04 21:52:59.534665	2025-06-04 21:57:59.53	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
642	1	5	2025-06-04 21:52:59.534974	2025-06-04 21:57:59.53	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
643	1	5	2025-06-04 21:52:59.535291	2025-06-04 21:57:59.54	\N	\N	map.movmentAction	{"x": 6, "y": 12, "playerId": 1}
644	1	5	2025-06-04 21:52:59.53568	2025-06-04 21:57:59.54	\N	\N	map.movmentAction	{"x": 6, "y": 13, "playerId": 1}
645	1	5	2025-06-04 21:53:09.083929	2025-06-04 21:58:09.08	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
646	1	5	2025-06-04 21:53:09.084495	2025-06-04 21:58:09.08	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
647	1	5	2025-06-04 21:53:09.085194	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
648	1	5	2025-06-04 21:53:09.085584	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
649	1	5	2025-06-04 21:53:09.085942	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
650	1	5	2025-06-04 21:53:09.086293	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
651	1	5	2025-06-04 21:53:09.086607	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
652	1	5	2025-06-04 21:53:09.086884	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
653	1	5	2025-06-04 21:53:09.087167	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
654	1	5	2025-06-04 21:53:09.087575	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
655	1	5	2025-06-04 21:53:09.087874	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
656	1	5	2025-06-04 21:53:09.088172	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 13, "y": 6, "playerId": 1}
657	1	5	2025-06-04 21:53:09.088489	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 14, "y": 5, "playerId": 1}
658	1	5	2025-06-04 21:53:09.088811	2025-06-04 21:58:09.09	\N	\N	map.movmentAction	{"x": 15, "y": 4, "playerId": 1}
659	1	5	2025-06-04 21:55:12.143902	2025-06-04 22:00:12.14	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
660	1	5	2025-06-04 21:55:12.144853	2025-06-04 22:00:12.14	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
661	1	5	2025-06-04 21:55:12.145242	2025-06-04 22:00:12.15	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
662	1	5	2025-06-04 21:55:12.146189	2025-06-04 22:00:12.15	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
663	1	5	2025-06-04 21:55:12.146537	2025-06-04 22:00:12.15	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
664	1	5	2025-06-04 21:55:12.146837	2025-06-04 22:00:12.15	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
665	1	5	2025-06-04 21:55:12.147155	2025-06-04 22:00:12.15	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
666	1	5	2025-06-04 21:55:12.147509	2025-06-04 22:00:12.15	\N	\N	map.movmentAction	{"x": 9, "y": 5, "playerId": 1}
667	1	5	2025-06-04 21:55:12.14783	2025-06-04 22:00:12.15	\N	\N	map.movmentAction	{"x": 9, "y": 4, "playerId": 1}
668	1	5	2025-06-04 21:55:26.255963	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
669	1	5	2025-06-04 21:55:26.256462	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
670	1	5	2025-06-04 21:55:26.256853	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
671	1	5	2025-06-04 21:55:26.257267	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
672	1	5	2025-06-04 21:55:26.257633	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
673	1	5	2025-06-04 21:55:26.257966	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
674	1	5	2025-06-04 21:55:26.258292	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
675	1	5	2025-06-04 21:55:26.258666	2025-06-04 22:00:26.26	\N	\N	map.movmentAction	{"x": 7, "y": 12, "playerId": 1}
676	1	5	2025-06-04 21:55:29.978545	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
677	1	5	2025-06-04 21:55:29.979168	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
678	1	5	2025-06-04 21:55:29.979584	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
679	1	5	2025-06-04 21:55:29.979969	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
680	1	5	2025-06-04 21:55:29.980353	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
681	1	5	2025-06-04 21:55:29.980798	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
682	1	5	2025-06-04 21:55:29.981221	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 8, "y": 7, "playerId": 1}
683	1	5	2025-06-04 21:55:29.981651	2025-06-04 22:00:29.98	\N	\N	map.movmentAction	{"x": 9, "y": 7, "playerId": 1}
684	1	5	2025-06-04 22:11:38.788775	2025-06-04 22:16:38.79	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
685	1	5	2025-06-04 22:11:38.791556	2025-06-04 22:16:38.79	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
686	1	5	2025-06-04 22:11:38.792315	2025-06-04 22:16:38.79	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
687	1	5	2025-06-04 22:11:38.793646	2025-06-04 22:16:38.79	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
688	1	5	2025-06-04 22:11:38.794809	2025-06-04 22:16:38.79	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
689	1	5	2025-06-04 22:11:38.795443	2025-06-04 22:16:38.8	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
690	1	5	2025-06-04 22:11:38.795998	2025-06-04 22:16:38.8	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
691	1	5	2025-06-04 22:11:38.796456	2025-06-04 22:16:38.8	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
692	1	5	2025-06-04 22:31:19.851388	2025-06-04 22:36:19.85	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
693	1	5	2025-06-04 22:31:19.853308	2025-06-04 22:36:19.85	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
694	1	5	2025-06-04 22:31:19.853868	2025-06-04 22:36:19.85	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
695	1	5	2025-06-04 22:31:19.854569	2025-06-04 22:36:19.85	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
696	1	5	2025-06-04 22:31:19.85502	2025-06-04 22:36:19.86	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
697	1	5	2025-06-04 22:31:19.855499	2025-06-04 22:36:19.86	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
698	1	5	2025-06-04 22:31:19.856688	2025-06-04 22:36:19.86	\N	\N	map.movmentAction	{"x": 8, "y": 7, "playerId": 1}
699	1	5	2025-06-04 22:31:25.174073	2025-06-04 22:36:25.17	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
700	1	5	2025-06-04 22:31:25.174846	2025-06-04 22:36:25.17	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
701	1	5	2025-06-04 22:31:25.175471	2025-06-04 22:36:25.18	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
702	1	5	2025-06-04 22:31:25.179072	2025-06-04 22:36:25.18	\N	\N	map.movmentAction	{"x": 5, "y": 4, "playerId": 1}
703	1	5	2025-06-04 22:41:22.567506	2025-06-04 22:46:22.57	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
704	1	5	2025-06-04 22:41:22.569373	2025-06-04 22:46:22.57	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
705	1	5	2025-06-04 22:41:22.56986	2025-06-04 22:46:22.57	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
706	1	5	2025-06-04 22:41:22.5703	2025-06-04 22:46:22.57	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
707	1	5	2025-06-04 22:41:22.570783	2025-06-04 22:46:22.57	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
708	1	5	2025-06-04 22:41:22.57121	2025-06-04 22:46:22.57	\N	\N	map.movmentAction	{"x": 7, "y": 7, "playerId": 1}
709	1	5	2025-06-04 22:41:29.991661	2025-06-04 22:46:29.99	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
710	1	5	2025-06-04 22:41:29.994257	2025-06-04 22:46:29.99	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
711	1	5	2025-06-04 22:41:29.994734	2025-06-04 22:46:29.99	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
712	1	5	2025-06-04 22:41:29.995128	2025-06-04 22:46:30	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
713	1	5	2025-06-04 22:41:29.995588	2025-06-04 22:46:30	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
714	1	5	2025-06-04 22:41:29.996032	2025-06-04 22:46:30	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
715	1	5	2025-06-04 22:41:29.996451	2025-06-04 22:46:30	\N	\N	map.movmentAction	{"x": 8, "y": 5, "playerId": 1}
716	1	5	2025-06-04 22:41:45.023105	2025-06-04 22:46:45.02	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
717	1	5	2025-06-04 22:41:45.023944	2025-06-04 22:46:45.02	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
718	1	5	2025-06-04 22:41:45.024472	2025-06-04 22:46:45.02	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
719	1	5	2025-06-04 22:41:45.024946	2025-06-04 22:46:45.02	\N	\N	map.movmentAction	{"x": 5, "y": 4, "playerId": 1}
720	1	5	2025-06-04 22:41:45.025348	2025-06-04 22:46:45.03	\N	\N	map.movmentAction	{"x": 6, "y": 3, "playerId": 1}
721	1	5	2025-06-04 22:41:45.025682	2025-06-04 22:46:45.03	\N	\N	map.movmentAction	{"x": 7, "y": 2, "playerId": 1}
722	1	5	2025-06-04 22:41:45.025997	2025-06-04 22:46:45.03	\N	\N	map.movmentAction	{"x": 8, "y": 2, "playerId": 1}
723	1	5	2025-06-04 22:41:52.794349	2025-06-04 22:46:52.79	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
724	1	5	2025-06-04 22:41:52.795136	2025-06-04 22:46:52.8	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
725	1	5	2025-06-04 22:41:52.795573	2025-06-04 22:46:52.8	\N	\N	map.movmentAction	{"x": 4, "y": 6, "playerId": 1}
726	1	5	2025-06-04 22:41:52.795935	2025-06-04 22:46:52.8	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
727	1	5	2025-06-04 22:41:52.796278	2025-06-04 22:46:52.8	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
728	1	5	2025-06-04 22:41:52.79659	2025-06-04 22:46:52.8	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
729	1	5	2025-06-04 22:41:52.796911	2025-06-04 22:46:52.8	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
730	1	5	2025-06-04 22:41:52.797267	2025-06-04 22:46:52.8	\N	\N	map.movmentAction	{"x": 9, "y": 6, "playerId": 1}
731	1	5	2025-06-04 22:42:02.674923	2025-06-04 22:47:02.67	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
732	1	5	2025-06-04 22:42:02.675556	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
733	1	5	2025-06-04 22:42:02.675947	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
734	1	5	2025-06-04 22:42:02.676389	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 5, "y": 8, "playerId": 1}
735	1	5	2025-06-04 22:42:02.6768	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 6, "y": 9, "playerId": 1}
736	1	5	2025-06-04 22:42:02.677224	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 7, "y": 10, "playerId": 1}
737	1	5	2025-06-04 22:42:02.677613	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 7, "y": 11, "playerId": 1}
738	1	5	2025-06-04 22:42:02.677941	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 8, "y": 12, "playerId": 1}
739	1	5	2025-06-04 22:42:02.678247	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 9, "y": 12, "playerId": 1}
740	1	5	2025-06-04 22:42:02.678574	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 10, "y": 11, "playerId": 1}
741	1	5	2025-06-04 22:42:02.678899	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 11, "y": 12, "playerId": 1}
742	1	5	2025-06-04 22:42:02.679187	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 12, "y": 12, "playerId": 1}
743	1	5	2025-06-04 22:42:02.679501	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 13, "y": 12, "playerId": 1}
744	1	5	2025-06-04 22:42:02.680332	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 14, "y": 13, "playerId": 1}
745	1	5	2025-06-04 22:42:02.680672	2025-06-04 22:47:02.68	\N	\N	map.movmentAction	{"x": 15, "y": 12, "playerId": 1}
746	1	5	2025-06-04 22:42:16.428876	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
747	1	5	2025-06-04 22:42:16.429451	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
748	1	5	2025-06-04 22:42:16.430202	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
749	1	5	2025-06-04 22:42:16.430629	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
750	1	5	2025-06-04 22:42:16.432399	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
751	1	5	2025-06-04 22:42:16.432895	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
752	1	5	2025-06-04 22:42:16.433377	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
753	1	5	2025-06-04 22:42:16.433824	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 9, "y": 5, "playerId": 1}
754	1	5	2025-06-04 22:42:16.434457	2025-06-04 22:47:16.43	\N	\N	map.movmentAction	{"x": 10, "y": 4, "playerId": 1}
755	1	5	2025-06-04 22:42:32.063996	2025-06-04 22:47:32.06	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
756	1	5	2025-06-04 22:42:32.064475	2025-06-04 22:47:32.06	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
757	1	5	2025-06-04 22:42:32.064859	2025-06-04 22:47:32.06	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
758	1	5	2025-06-04 22:42:32.065351	2025-06-04 22:47:32.07	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
759	1	5	2025-06-04 22:42:32.065731	2025-06-04 22:47:32.07	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
760	1	5	2025-06-04 22:42:32.066143	2025-06-04 22:47:32.07	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
761	1	5	2025-06-04 22:42:32.066563	2025-06-04 22:47:32.07	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
762	1	5	2025-06-04 22:42:32.067062	2025-06-04 22:47:32.07	\N	\N	map.movmentAction	{"x": 9, "y": 5, "playerId": 1}
763	1	5	2025-06-04 22:42:32.067404	2025-06-04 22:47:32.07	\N	\N	map.movmentAction	{"x": 10, "y": 4, "playerId": 1}
764	1	5	2025-06-04 22:42:32.067716	2025-06-04 22:47:32.07	\N	\N	map.movmentAction	{"x": 9, "y": 3, "playerId": 1}
765	1	5	2025-06-04 22:42:38.734971	2025-06-04 22:47:38.73	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
766	1	5	2025-06-04 22:42:38.735439	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
767	1	5	2025-06-04 22:42:38.735856	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
768	1	5	2025-06-04 22:42:38.736277	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 5, "y": 7, "playerId": 1}
769	1	5	2025-06-04 22:42:38.736666	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 6, "y": 8, "playerId": 1}
770	1	5	2025-06-04 22:42:38.737099	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 7, "y": 9, "playerId": 1}
771	1	5	2025-06-04 22:42:38.737485	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 8, "y": 9, "playerId": 1}
772	1	5	2025-06-04 22:42:38.737857	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 9, "y": 9, "playerId": 1}
773	1	5	2025-06-04 22:42:38.738219	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 10, "y": 8, "playerId": 1}
774	1	5	2025-06-04 22:42:38.73862	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 11, "y": 8, "playerId": 1}
775	1	5	2025-06-04 22:42:38.738963	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 12, "y": 7, "playerId": 1}
776	1	5	2025-06-04 22:42:38.739426	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 13, "y": 6, "playerId": 1}
777	1	5	2025-06-04 22:42:38.739896	2025-06-04 22:47:38.74	\N	\N	map.movmentAction	{"x": 14, "y": 7, "playerId": 1}
778	1	5	2025-06-04 22:42:46.397978	2025-06-04 22:47:46.4	\N	\N	map.movmentAction	{"x": 2, "y": 3, "playerId": 1}
779	1	5	2025-06-04 22:42:46.398595	2025-06-04 22:47:46.4	\N	\N	map.movmentAction	{"x": 3, "y": 2, "playerId": 1}
780	1	5	2025-06-04 22:42:46.399088	2025-06-04 22:47:46.4	\N	\N	map.movmentAction	{"x": 4, "y": 3, "playerId": 1}
781	1	5	2025-06-04 22:42:46.399652	2025-06-04 22:47:46.4	\N	\N	map.movmentAction	{"x": 5, "y": 2, "playerId": 1}
782	1	5	2025-06-04 22:42:46.40009	2025-06-04 22:47:46.4	\N	\N	map.movmentAction	{"x": 6, "y": 1, "playerId": 1}
783	1	5	2025-06-04 22:42:50.749083	2025-06-04 22:47:50.75	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
784	1	5	2025-06-04 22:42:50.750032	2025-06-04 22:47:50.75	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
785	1	5	2025-06-04 22:42:50.750471	2025-06-04 22:47:50.75	\N	\N	map.movmentAction	{"x": 4, "y": 7, "playerId": 1}
786	1	5	2025-06-04 22:42:50.750886	2025-06-04 22:47:50.75	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
787	1	5	2025-06-04 22:42:50.751254	2025-06-04 22:47:50.75	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
788	1	5	2025-06-04 22:42:50.751584	2025-06-04 22:47:50.75	\N	\N	map.movmentAction	{"x": 7, "y": 7, "playerId": 1}
789	1	5	2025-06-04 22:42:56.149714	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
790	1	5	2025-06-04 22:42:56.150638	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
791	1	5	2025-06-04 22:42:56.151273	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
792	1	5	2025-06-04 22:42:56.151658	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
793	1	5	2025-06-04 22:42:56.152028	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
794	1	5	2025-06-04 22:42:56.152353	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 7, "y": 6, "playerId": 1}
795	1	5	2025-06-04 22:42:56.15267	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 8, "y": 6, "playerId": 1}
796	1	5	2025-06-04 22:42:56.153015	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 9, "y": 5, "playerId": 1}
797	1	5	2025-06-04 22:42:56.153367	2025-06-04 22:47:56.15	\N	\N	map.movmentAction	{"x": 10, "y": 4, "playerId": 1}
798	1	5	2025-06-04 22:43:01.987503	2025-06-04 22:48:01.99	\N	\N	map.movmentAction	{"x": 2, "y": 5, "playerId": 1}
799	1	5	2025-06-04 22:43:01.988638	2025-06-04 22:48:01.99	\N	\N	map.movmentAction	{"x": 3, "y": 6, "playerId": 1}
800	1	5	2025-06-04 22:43:01.989145	2025-06-04 22:48:01.99	\N	\N	map.movmentAction	{"x": 4, "y": 5, "playerId": 1}
801	1	5	2025-06-04 22:43:01.989753	2025-06-04 22:48:01.99	\N	\N	map.movmentAction	{"x": 5, "y": 6, "playerId": 1}
802	1	5	2025-06-04 22:43:01.99034	2025-06-04 22:48:01.99	\N	\N	map.movmentAction	{"x": 6, "y": 6, "playerId": 1}
803	1	5	2025-06-04 22:43:01.990785	2025-06-04 22:48:01.99	\N	\N	map.movmentAction	{"x": 7, "y": 5, "playerId": 1}
804	1	5	2025-06-04 22:43:01.991145	2025-06-04 22:48:01.99	\N	\N	map.movmentAction	{"x": 8, "y": 4, "playerId": 1}
805	1	5	2025-06-04 22:44:14.807143	2025-06-04 22:49:14.81	\N	\N	map.movmentAction	{"x": 2, "y": 4, "playerId": 1}
806	1	5	2025-06-04 22:44:14.808214	2025-06-04 22:49:14.81	\N	\N	map.movmentAction	{"x": 3, "y": 3, "playerId": 1}
807	1	5	2025-06-04 22:44:14.808596	2025-06-04 22:49:14.81	\N	\N	map.movmentAction	{"x": 4, "y": 4, "playerId": 1}
808	1	5	2025-06-04 22:44:20.361584	2025-06-04 22:49:20.36	\N	\N	map.movmentAction	{"x": 2, "y": 3, "playerId": 1}
809	1	5	2025-06-04 22:44:20.362125	2025-06-04 22:49:20.36	\N	\N	map.movmentAction	{"x": 3, "y": 3, "playerId": 1}
810	1	5	2025-06-04 22:44:20.362512	2025-06-04 22:49:20.36	\N	\N	map.movmentAction	{"x": 4, "y": 3, "playerId": 1}
811	1	1	2025-06-04 22:44:37.330353	2025-06-04 22:49:37.33	\N	\N	map.movmentAction	{"x": 2, "y": 3, "playerId": 1}
812	1	1	2025-06-04 22:44:37.330955	2025-06-04 22:49:37.33	\N	\N	map.movmentAction	{"x": 3, "y": 3, "playerId": 1}
813	1	1	2025-06-04 22:44:37.331552	2025-06-04 22:49:37.33	\N	\N	map.movmentAction	{"x": 4, "y": 3, "playerId": 1}
814	1	5	2025-06-05 20:34:30.881779	2025-06-05 20:39:30.88	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
815	1	5	2025-06-05 20:34:30.889127	2025-06-05 20:39:30.89	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
816	1	5	2025-06-05 20:34:30.889519	2025-06-05 20:39:30.89	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
817	1	5	2025-06-05 20:34:30.88983	2025-06-05 20:39:30.89	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
818	1	5	2025-06-05 20:34:30.89081	2025-06-05 20:39:30.89	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
819	1	5	2025-06-05 20:34:30.891207	2025-06-05 20:39:30.89	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
820	1	5	2025-06-05 20:34:35.405884	2025-06-05 20:39:35.41	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
821	1	5	2025-06-05 20:34:35.406345	2025-06-05 20:39:35.41	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
822	1	5	2025-06-05 20:34:35.406649	2025-06-05 20:39:35.41	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
823	1	5	2025-06-05 20:34:35.406924	2025-06-05 20:39:35.41	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
824	1	5	2025-06-05 20:34:35.407216	2025-06-05 20:39:35.41	\N	\N	map.movementAction	{"x": 6, "y": 3, "playerId": 1}
825	1	5	2025-06-05 20:34:35.407528	2025-06-05 20:39:35.41	\N	\N	map.movementAction	{"x": 7, "y": 2, "playerId": 1}
826	1	5	2025-06-05 20:34:35.407898	2025-06-05 20:39:35.41	\N	\N	map.movementAction	{"x": 8, "y": 2, "playerId": 1}
827	1	5	2025-06-05 20:34:50.08206	2025-06-05 20:39:50.08	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
828	1	5	2025-06-05 20:34:50.082842	2025-06-05 20:39:50.08	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
829	1	5	2025-06-05 20:34:50.08366	2025-06-05 20:39:50.08	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
830	1	5	2025-06-05 20:34:50.085842	2025-06-05 20:39:50.09	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
831	1	5	2025-06-05 20:34:50.086679	2025-06-05 20:39:50.09	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
832	1	5	2025-06-05 21:01:06.316345	2025-06-05 21:06:06.32	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
833	1	5	2025-06-05 21:01:06.319454	2025-06-05 21:06:06.32	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
834	1	5	2025-06-05 21:01:06.319829	2025-06-05 21:06:06.32	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
835	1	5	2025-06-05 21:01:06.320143	2025-06-05 21:06:06.32	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
836	1	5	2025-06-05 21:01:06.32046	2025-06-05 21:06:06.32	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
837	1	5	2025-06-05 21:01:06.320804	2025-06-05 21:06:06.32	\N	\N	map.movementAction	{"x": 7, "y": 5, "playerId": 1}
838	1	5	2025-06-05 21:01:06.321115	2025-06-05 21:06:06.32	\N	\N	map.movementAction	{"x": 8, "y": 4, "playerId": 1}
839	1	5	2025-06-18 19:59:56.88923	2025-06-18 20:04:56.89	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
840	1	5	2025-06-18 19:59:56.898429	2025-06-18 20:04:56.9	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
841	1	5	2025-06-18 19:59:56.898877	2025-06-18 20:04:56.9	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
842	1	5	2025-06-18 19:59:56.899215	2025-06-18 20:04:56.9	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
843	1	5	2025-06-18 19:59:56.899558	2025-06-18 20:04:56.9	\N	\N	map.movementAction	{"x": 5, "y": 9, "playerId": 1}
844	1	5	2025-06-18 19:59:56.899867	2025-06-18 20:04:56.9	\N	\N	map.movementAction	{"x": 5, "y": 10, "playerId": 1}
845	1	5	2025-06-18 20:50:35.297888	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
846	1	5	2025-06-18 20:50:35.299606	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
847	1	5	2025-06-18 20:50:35.299991	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
848	1	5	2025-06-18 20:50:35.300312	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
849	1	5	2025-06-18 20:50:35.300623	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
850	1	5	2025-06-18 20:50:35.300912	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
851	1	5	2025-06-18 20:50:35.301193	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 8, "y": 6, "playerId": 1}
852	1	5	2025-06-18 20:50:35.301488	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 9, "y": 5, "playerId": 1}
853	1	5	2025-06-18 20:50:35.301776	2025-06-18 20:55:35.3	\N	\N	map.movementAction	{"x": 10, "y": 5, "playerId": 1}
854	1	5	2025-06-18 23:34:23.750099	2025-06-18 23:39:23.75	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
855	1	5	2025-06-18 23:34:23.756752	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
856	1	5	2025-06-18 23:34:23.757118	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
857	1	5	2025-06-18 23:34:23.757429	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
858	1	5	2025-06-18 23:34:23.757724	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
859	1	5	2025-06-18 23:34:23.758058	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
860	1	5	2025-06-18 23:34:23.758415	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
861	1	5	2025-06-18 23:34:23.75872	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
862	1	5	2025-06-18 23:34:23.759039	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
863	1	5	2025-06-18 23:34:23.75933	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
864	1	5	2025-06-18 23:34:23.759608	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
865	1	5	2025-06-18 23:34:23.759885	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 13, "y": 8, "playerId": 1}
866	1	5	2025-06-18 23:34:23.76029	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 14, "y": 9, "playerId": 1}
867	1	5	2025-06-18 23:34:23.760572	2025-06-18 23:39:23.76	\N	\N	map.movementAction	{"x": 15, "y": 10, "playerId": 1}
868	1	5	2025-06-19 16:21:10.335404	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
869	1	5	2025-06-19 16:21:10.338696	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
870	1	5	2025-06-19 16:21:10.339076	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
871	1	5	2025-06-19 16:21:10.339388	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
872	1	5	2025-06-19 16:21:10.339685	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
873	1	5	2025-06-19 16:21:10.339955	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
874	1	5	2025-06-19 16:21:10.340248	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
875	1	5	2025-06-19 16:21:10.340506	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
876	1	5	2025-06-19 16:21:10.340782	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
877	1	5	2025-06-19 16:21:10.341051	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
878	1	5	2025-06-19 16:21:10.341347	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
879	1	5	2025-06-19 16:21:10.341597	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 13, "y": 6, "playerId": 1}
880	1	5	2025-06-19 16:21:10.341978	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 14, "y": 5, "playerId": 1}
881	1	5	2025-06-19 16:21:10.342257	2025-06-19 16:26:10.34	\N	\N	map.movementAction	{"x": 14, "y": 4, "playerId": 1}
882	1	5	2025-06-19 16:21:17.200231	2025-06-19 16:26:17.2	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
883	1	5	2025-06-19 16:21:17.200596	2025-06-19 16:26:17.2	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
884	1	5	2025-06-19 16:21:17.200862	2025-06-19 16:26:17.2	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
885	1	5	2025-06-19 16:21:17.201109	2025-06-19 16:26:17.2	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
886	1	5	2025-06-19 16:21:17.201348	2025-06-19 16:26:17.2	\N	\N	map.movementAction	{"x": 6, "y": 3, "playerId": 1}
887	1	5	2025-06-19 16:21:17.201592	2025-06-19 16:26:17.2	\N	\N	map.movementAction	{"x": 7, "y": 2, "playerId": 1}
888	1	5	2025-06-19 16:21:17.201827	2025-06-19 16:26:17.2	\N	\N	map.movementAction	{"x": 8, "y": 2, "playerId": 1}
889	1	5	2025-06-19 16:21:24.931507	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
890	1	5	2025-06-19 16:21:24.932292	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
891	1	5	2025-06-19 16:21:24.932705	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
892	1	5	2025-06-19 16:21:24.933036	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
893	1	5	2025-06-19 16:21:24.933846	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
894	1	5	2025-06-19 16:21:24.934178	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
895	1	5	2025-06-19 16:21:24.934556	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
896	1	5	2025-06-19 16:21:24.93493	2025-06-19 16:26:24.93	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
897	1	5	2025-06-19 16:21:24.935209	2025-06-19 16:26:24.94	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
898	1	5	2025-06-19 16:57:06.518717	2025-06-19 17:02:06.52	\N	\N	map.movementAction	{"x": 2, "y": 4, "playerId": 1}
899	1	5	2025-06-19 16:58:34.613206	2025-06-19 17:03:34.61	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
900	1	5	2025-06-19 16:58:34.614377	2025-06-19 17:03:34.61	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
901	1	5	2025-06-19 16:58:34.614758	2025-06-19 17:03:34.61	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
902	1	5	2025-06-19 16:58:34.615077	2025-06-19 17:03:34.62	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
903	1	5	2025-06-19 17:04:55.422468	2025-06-19 17:09:55.42	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
904	1	5	2025-06-19 17:04:55.424235	2025-06-19 17:09:55.42	\N	\N	map.movementAction	{"x": 3, "y": 2, "playerId": 1}
905	1	5	2025-06-19 17:04:55.424729	2025-06-19 17:09:55.42	\N	\N	map.movementAction	{"x": 3, "y": 1, "playerId": 1}
906	1	5	2025-06-19 18:33:41.250735	2025-06-19 18:38:41.25	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
907	1	5	2025-06-19 18:33:41.252559	2025-06-19 18:38:41.25	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
908	1	5	2025-06-19 18:33:41.252989	2025-06-19 18:38:41.25	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
909	1	5	2025-06-19 18:33:41.253345	2025-06-19 18:38:41.25	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
910	1	5	2025-06-19 18:33:41.253682	2025-06-19 18:38:41.25	\N	\N	map.movementAction	{"x": 6, "y": 7, "playerId": 1}
911	1	5	2025-06-19 19:51:57.874528	2025-06-19 19:56:57.87	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
912	1	5	2025-06-19 19:51:57.884792	2025-06-19 19:56:57.88	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
913	1	5	2025-06-19 19:51:57.885411	2025-06-19 19:56:57.89	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
914	1	5	2025-06-19 19:51:57.885856	2025-06-19 19:56:57.89	\N	\N	map.movementAction	{"x": 5, "y": 5, "playerId": 1}
915	1	5	2025-06-19 19:52:05.391833	2025-06-19 19:57:05.39	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
916	1	5	2025-06-19 19:52:05.392562	2025-06-19 19:57:05.39	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
917	1	5	2025-06-19 19:52:05.393045	2025-06-19 19:57:05.39	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
918	1	5	2025-06-19 19:52:05.394543	2025-06-19 19:57:05.39	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
919	1	5	2025-06-19 19:52:05.395137	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
920	1	5	2025-06-19 19:52:05.395639	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
921	1	5	2025-06-19 19:52:05.396007	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
922	1	5	2025-06-19 19:52:05.39638	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
923	1	5	2025-06-19 19:52:05.396813	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
924	1	5	2025-06-19 19:52:05.397136	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
925	1	5	2025-06-19 19:52:05.397474	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
926	1	5	2025-06-19 19:52:05.397794	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 12, "y": 6, "playerId": 1}
927	1	5	2025-06-19 19:52:05.398104	2025-06-19 19:57:05.4	\N	\N	map.movementAction	{"x": 12, "y": 5, "playerId": 1}
928	1	5	2025-06-19 19:58:19.55596	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
929	1	5	2025-06-19 19:58:19.557387	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
930	1	5	2025-06-19 19:58:19.557814	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
931	1	5	2025-06-19 19:58:19.558131	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
932	1	5	2025-06-19 19:58:19.558424	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 5, "y": 9, "playerId": 1}
933	1	5	2025-06-19 19:58:19.558786	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 4, "y": 10, "playerId": 1}
934	1	5	2025-06-19 19:58:19.559074	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 4, "y": 11, "playerId": 1}
935	1	5	2025-06-19 19:58:19.559488	2025-06-19 20:03:19.56	\N	\N	map.movementAction	{"x": 5, "y": 12, "playerId": 1}
936	1	5	2025-06-19 20:11:41.5629	2025-06-19 20:16:41.56	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
937	1	5	2025-06-19 20:11:41.564235	2025-06-19 20:16:41.56	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
938	1	5	2025-06-19 20:11:41.564563	2025-06-19 20:16:41.56	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
939	1	5	2025-06-19 20:11:41.564848	2025-06-19 20:16:41.56	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
940	1	5	2025-06-19 20:11:41.565119	2025-06-19 20:16:41.57	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
941	1	5	2025-06-19 20:11:41.565384	2025-06-19 20:16:41.57	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
942	1	5	2025-06-19 20:11:41.565657	2025-06-19 20:16:41.57	\N	\N	map.movementAction	{"x": 8, "y": 7, "playerId": 1}
943	1	5	2025-06-19 21:06:03.234195	2025-06-19 21:11:03.23	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
944	1	5	2025-06-19 21:06:03.238124	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
945	1	5	2025-06-19 21:06:03.238649	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
946	1	5	2025-06-19 21:06:03.239064	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
947	1	5	2025-06-19 21:06:03.239508	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
948	1	5	2025-06-19 21:06:03.239993	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
949	1	5	2025-06-19 21:06:03.240421	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
950	1	5	2025-06-19 21:06:03.240904	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
951	1	5	2025-06-19 21:06:03.24133	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
952	1	5	2025-06-19 21:06:03.241734	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
953	1	5	2025-06-19 21:06:03.24218	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 11, "y": 12, "playerId": 1}
954	1	5	2025-06-19 21:06:03.242561	2025-06-19 21:11:03.24	\N	\N	map.movementAction	{"x": 12, "y": 12, "playerId": 1}
955	1	5	2025-06-19 21:06:15.731559	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
956	1	5	2025-06-19 21:06:15.732094	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
957	1	5	2025-06-19 21:06:15.73262	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
958	1	5	2025-06-19 21:06:15.733002	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
959	1	5	2025-06-19 21:06:15.733414	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
960	1	5	2025-06-19 21:06:15.73376	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
961	1	5	2025-06-19 21:06:15.734113	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
962	1	5	2025-06-19 21:06:15.734434	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
963	1	5	2025-06-19 21:06:15.734921	2025-06-19 21:11:15.73	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
964	1	5	2025-06-19 21:06:15.735556	2025-06-19 21:11:15.74	\N	\N	map.movementAction	{"x": 11, "y": 9, "playerId": 1}
965	1	5	2025-06-19 21:06:15.736669	2025-06-19 21:11:15.74	\N	\N	map.movementAction	{"x": 12, "y": 10, "playerId": 1}
966	1	5	2025-06-19 21:06:15.737074	2025-06-19 21:11:15.74	\N	\N	map.movementAction	{"x": 13, "y": 11, "playerId": 1}
967	1	5	2025-06-19 21:38:31.800878	2025-06-19 21:43:31.8	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
968	1	5	2025-06-19 21:38:31.802652	2025-06-19 21:43:31.8	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
969	1	5	2025-06-19 21:38:31.803231	2025-06-19 21:43:31.8	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
970	1	5	2025-06-19 21:38:31.803791	2025-06-19 21:43:31.8	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
971	1	5	2025-06-19 21:38:31.804209	2025-06-19 21:43:31.8	\N	\N	map.movementAction	{"x": 6, "y": 4, "playerId": 1}
972	1	5	2025-06-19 21:38:31.804892	2025-06-19 21:43:31.8	\N	\N	map.movementAction	{"x": 7, "y": 3, "playerId": 1}
973	1	5	2025-06-19 21:41:15.204935	2025-06-19 21:46:15.2	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
974	1	5	2025-06-19 21:41:15.209374	2025-06-19 21:46:15.21	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
975	1	5	2025-06-19 21:41:15.210404	2025-06-19 21:46:15.21	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
976	1	5	2025-06-19 21:41:15.21198	2025-06-19 21:46:15.21	\N	\N	map.movementAction	{"x": 3, "y": 8, "playerId": 1}
977	1	5	2025-06-24 19:25:22.278295	2025-06-24 19:30:22.28	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
978	1	5	2025-06-24 19:25:22.291659	2025-06-24 19:30:22.29	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
979	1	5	2025-06-24 19:25:22.292122	2025-06-24 19:30:22.29	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
980	1	5	2025-06-24 19:25:22.292417	2025-06-24 19:30:22.29	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
981	1	5	2025-06-24 19:25:22.292728	2025-06-24 19:30:22.29	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
982	1	5	2025-06-24 19:25:22.293059	2025-06-24 19:30:22.29	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
983	1	5	2025-06-24 19:25:22.293419	2025-06-24 19:30:22.29	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
984	1	5	2025-06-24 19:25:22.293678	2025-06-24 19:30:22.29	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
985	1	5	2025-06-24 19:25:27.914047	2025-06-24 19:30:27.91	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
986	1	5	2025-06-24 19:25:27.914462	2025-06-24 19:30:27.91	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
987	1	5	2025-06-24 19:25:27.914852	2025-06-24 19:30:27.91	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
988	1	5	2025-06-24 19:25:27.915218	2025-06-24 19:30:27.92	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
989	1	5	2025-06-24 19:25:27.915556	2025-06-24 19:30:27.92	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
990	1	5	2025-06-24 19:25:27.915856	2025-06-24 19:30:27.92	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
991	1	5	2025-06-24 19:25:27.91613	2025-06-24 19:30:27.92	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
992	1	5	2025-06-24 19:25:27.916497	2025-06-24 19:30:27.92	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
993	1	5	2025-06-24 19:31:44.056698	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
994	1	5	2025-06-24 19:31:44.058012	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
995	1	5	2025-06-24 19:31:44.058353	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
996	1	5	2025-06-24 19:31:44.058654	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
997	1	5	2025-06-24 19:31:44.058941	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
998	1	5	2025-06-24 19:31:44.05922	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
999	1	5	2025-06-24 19:31:44.059518	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1000	1	5	2025-06-24 19:31:44.05984	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1001	1	5	2025-06-24 19:31:44.060127	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
1002	1	5	2025-06-24 19:31:44.060871	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
1003	1	5	2025-06-24 19:31:44.061127	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 11, "y": 11, "playerId": 1}
1004	1	5	2025-06-24 19:31:44.061415	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 12, "y": 12, "playerId": 1}
1005	1	5	2025-06-24 19:31:44.06168	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 13, "y": 12, "playerId": 1}
1006	1	5	2025-06-24 19:31:44.061926	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 14, "y": 13, "playerId": 1}
1007	1	5	2025-06-24 19:31:44.062161	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 15, "y": 12, "playerId": 1}
1008	1	5	2025-06-24 19:31:44.062389	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 16, "y": 11, "playerId": 1}
1009	1	5	2025-06-24 19:31:44.062628	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 17, "y": 11, "playerId": 1}
1010	1	5	2025-06-24 19:31:44.062892	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 18, "y": 12, "playerId": 1}
1011	1	5	2025-06-24 19:31:44.063133	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 19, "y": 12, "playerId": 1}
1012	1	5	2025-06-24 19:31:44.063368	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 20, "y": 11, "playerId": 1}
1013	1	5	2025-06-24 19:31:44.063605	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 21, "y": 10, "playerId": 1}
1014	1	5	2025-06-24 19:31:44.063838	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 22, "y": 9, "playerId": 1}
1015	1	5	2025-06-24 19:31:44.064071	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 21, "y": 8, "playerId": 1}
1016	1	5	2025-06-24 19:31:44.064297	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 20, "y": 7, "playerId": 1}
1017	1	5	2025-06-24 19:31:44.064537	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 21, "y": 6, "playerId": 1}
1018	1	5	2025-06-24 19:31:44.064768	2025-06-24 19:36:44.06	\N	\N	map.movementAction	{"x": 21, "y": 5, "playerId": 1}
1019	1	5	2025-06-24 19:31:44.065122	2025-06-24 19:36:44.07	\N	\N	map.movementAction	{"x": 21, "y": 4, "playerId": 1}
1020	1	5	2025-06-24 19:31:44.065676	2025-06-24 19:36:44.07	\N	\N	map.movementAction	{"x": 21, "y": 3, "playerId": 1}
1021	1	5	2025-06-24 19:33:35.812078	2025-06-24 19:38:35.81	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1022	1	5	2025-06-24 19:33:35.813286	2025-06-24 19:38:35.81	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1023	1	5	2025-06-24 19:33:35.813663	2025-06-24 19:38:35.81	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1024	1	5	2025-06-24 19:33:35.813973	2025-06-24 19:38:35.81	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1025	1	5	2025-06-24 19:33:35.81429	2025-06-24 19:38:35.81	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1026	1	5	2025-06-24 19:33:35.814575	2025-06-24 19:38:35.81	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1027	1	5	2025-06-24 19:33:35.814843	2025-06-24 19:38:35.81	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1028	1	5	2025-06-24 19:33:35.815089	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1029	1	5	2025-06-24 19:33:35.815334	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
1030	1	5	2025-06-24 19:33:35.815576	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
1031	1	5	2025-06-24 19:33:35.815823	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 11, "y": 11, "playerId": 1}
1032	1	5	2025-06-24 19:33:35.81606	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 12, "y": 12, "playerId": 1}
1033	1	5	2025-06-24 19:33:35.816291	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 13, "y": 12, "playerId": 1}
1034	1	5	2025-06-24 19:33:35.816674	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 14, "y": 13, "playerId": 1}
1035	1	5	2025-06-24 19:33:35.816921	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 15, "y": 12, "playerId": 1}
1036	1	5	2025-06-24 19:33:35.817161	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 16, "y": 11, "playerId": 1}
1037	1	5	2025-06-24 19:33:35.81739	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 17, "y": 11, "playerId": 1}
1038	1	5	2025-06-24 19:33:35.817635	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 18, "y": 12, "playerId": 1}
1039	1	5	2025-06-24 19:33:35.81787	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 19, "y": 12, "playerId": 1}
1040	1	5	2025-06-24 19:33:35.818102	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 20, "y": 11, "playerId": 1}
1041	1	5	2025-06-24 19:33:35.818337	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 21, "y": 10, "playerId": 1}
1042	1	5	2025-06-24 19:33:35.818572	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 22, "y": 9, "playerId": 1}
1043	1	5	2025-06-24 19:33:35.818808	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 23, "y": 8, "playerId": 1}
1044	1	5	2025-06-24 19:33:35.819041	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 24, "y": 8, "playerId": 1}
1045	1	5	2025-06-24 19:33:35.819297	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 25, "y": 9, "playerId": 1}
1046	1	5	2025-06-24 19:33:35.819577	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 26, "y": 9, "playerId": 1}
1047	1	5	2025-06-24 19:33:35.819831	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 27, "y": 8, "playerId": 1}
1048	1	5	2025-06-24 19:33:35.820072	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 28, "y": 8, "playerId": 1}
1049	1	5	2025-06-24 19:33:35.820311	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 29, "y": 7, "playerId": 1}
1050	1	5	2025-06-24 19:33:35.820595	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 30, "y": 6, "playerId": 1}
1051	1	5	2025-06-24 19:33:35.820834	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 29, "y": 5, "playerId": 1}
1052	1	5	2025-06-24 19:33:35.821071	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 29, "y": 4, "playerId": 1}
1053	1	5	2025-06-24 19:33:35.821302	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 28, "y": 3, "playerId": 1}
1054	1	5	2025-06-24 19:33:35.821629	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 29, "y": 2, "playerId": 1}
1055	1	5	2025-06-24 19:33:35.821883	2025-06-24 19:38:35.82	\N	\N	map.movementAction	{"x": 30, "y": 1, "playerId": 1}
1056	1	5	2025-06-28 10:34:22.258114	2025-06-28 10:39:22.26	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1057	1	5	2025-06-28 10:34:22.267383	2025-06-28 10:39:22.27	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1058	1	5	2025-06-28 10:34:22.268045	2025-06-28 10:39:22.27	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1059	1	5	2025-06-28 10:34:22.268514	2025-06-28 10:39:22.27	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1060	1	5	2025-06-28 10:34:22.26894	2025-06-28 10:39:22.27	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1061	1	5	2025-06-28 10:34:22.269288	2025-06-28 10:39:22.27	\N	\N	map.movementAction	{"x": 7, "y": 5, "playerId": 1}
1062	1	5	2025-06-28 10:34:43.368088	2025-06-28 10:39:43.37	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1063	1	5	2025-06-28 10:34:43.368689	2025-06-28 10:39:43.37	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1064	1	5	2025-06-28 10:34:43.369743	2025-06-28 10:39:43.37	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1065	1	5	2025-06-28 10:34:43.370733	2025-06-28 10:39:43.37	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1066	1	5	2025-06-28 10:34:43.371187	2025-06-28 10:39:43.37	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1067	1	5	2025-06-28 10:47:21.222187	2025-06-28 10:52:21.22	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1068	1	5	2025-06-28 10:47:21.227496	2025-06-28 10:52:21.23	\N	\N	map.movementAction	{"x": 3, "y": 3, "playerId": 1}
1069	1	5	2025-06-28 10:47:21.228228	2025-06-28 10:52:21.23	\N	\N	map.movementAction	{"x": 4, "y": 3, "playerId": 1}
1070	1	5	2025-06-28 10:47:36.315872	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1071	1	5	2025-06-28 10:47:36.317532	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1072	1	5	2025-06-28 10:47:36.318564	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1073	1	5	2025-06-28 10:47:36.320001	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1074	1	5	2025-06-28 10:47:36.321657	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1075	1	5	2025-06-28 10:47:36.322386	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1076	1	5	2025-06-28 10:47:36.322815	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1077	1	5	2025-06-28 10:47:36.323263	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1078	1	5	2025-06-28 10:47:36.323919	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
1079	1	5	2025-06-28 10:47:36.324563	2025-06-28 10:52:36.32	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
1080	1	5	2025-06-28 10:47:36.325294	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 11, "y": 12, "playerId": 1}
1081	1	5	2025-06-28 10:47:36.325778	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 12, "y": 12, "playerId": 1}
1082	1	5	2025-06-28 10:47:36.327658	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 13, "y": 12, "playerId": 1}
1083	1	5	2025-06-28 10:47:36.328179	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 14, "y": 13, "playerId": 1}
1084	1	5	2025-06-28 10:47:36.328689	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 15, "y": 12, "playerId": 1}
1085	1	5	2025-06-28 10:47:36.32918	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 16, "y": 12, "playerId": 1}
1086	1	5	2025-06-28 10:47:36.330122	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 17, "y": 11, "playerId": 1}
1087	1	5	2025-06-28 10:47:36.330597	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 18, "y": 12, "playerId": 1}
1088	1	5	2025-06-28 10:47:36.331063	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 19, "y": 13, "playerId": 1}
1089	1	5	2025-06-28 10:47:36.331469	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 20, "y": 13, "playerId": 1}
1090	1	5	2025-06-28 10:47:36.332484	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 21, "y": 14, "playerId": 1}
1091	1	5	2025-06-28 10:47:36.332842	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 22, "y": 13, "playerId": 1}
1092	1	5	2025-06-28 10:47:36.333234	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 23, "y": 14, "playerId": 1}
1093	1	5	2025-06-28 10:47:36.333812	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 24, "y": 13, "playerId": 1}
1094	1	5	2025-06-28 10:47:36.334324	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 25, "y": 14, "playerId": 1}
1095	1	5	2025-06-28 10:47:36.334801	2025-06-28 10:52:36.33	\N	\N	map.movementAction	{"x": 26, "y": 15, "playerId": 1}
1096	1	5	2025-06-28 10:47:36.335232	2025-06-28 10:52:36.34	\N	\N	map.movementAction	{"x": 26, "y": 16, "playerId": 1}
1097	1	5	2025-06-28 10:47:36.335692	2025-06-28 10:52:36.34	\N	\N	map.movementAction	{"x": 27, "y": 17, "playerId": 1}
1098	1	5	2025-06-28 10:47:36.336108	2025-06-28 10:52:36.34	\N	\N	map.movementAction	{"x": 28, "y": 18, "playerId": 1}
1099	1	5	2025-06-28 10:47:36.337332	2025-06-28 10:52:36.34	\N	\N	map.movementAction	{"x": 29, "y": 19, "playerId": 1}
1100	1	5	2025-06-28 10:47:36.337746	2025-06-28 10:52:36.34	\N	\N	map.movementAction	{"x": 30, "y": 19, "playerId": 1}
1101	1	5	2025-06-28 10:49:35.715135	2025-06-28 10:54:35.72	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1102	1	5	2025-06-28 10:49:35.717008	2025-06-28 10:54:35.72	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1103	1	5	2025-06-28 10:49:35.717984	2025-06-28 10:54:35.72	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1104	1	5	2025-06-28 10:49:35.720422	2025-06-28 10:54:35.72	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
1105	1	5	2025-06-28 10:49:35.721132	2025-06-28 10:54:35.72	\N	\N	map.movementAction	{"x": 6, "y": 3, "playerId": 1}
1106	1	5	2025-06-28 10:57:34.997571	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1107	1	5	2025-06-28 10:57:34.999226	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1108	1	5	2025-06-28 10:57:35.000469	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1109	1	5	2025-06-28 10:57:35.000945	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1110	1	5	2025-06-28 10:57:35.00135	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1111	1	5	2025-06-28 10:57:35.001922	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
1112	1	5	2025-06-28 10:57:35.002622	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 8, "y": 6, "playerId": 1}
1113	1	5	2025-06-28 10:57:35.003094	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 9, "y": 5, "playerId": 1}
1114	1	5	2025-06-28 10:57:35.003467	2025-06-28 11:02:35	\N	\N	map.movementAction	{"x": 9, "y": 4, "playerId": 1}
1115	1	5	2025-06-28 10:58:30.659221	2025-06-28 11:03:30.66	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1116	1	5	2025-06-28 10:58:30.660603	2025-06-28 11:03:30.66	\N	\N	map.movementAction	{"x": 2, "y": 6, "playerId": 1}
1117	1	5	2025-06-28 10:58:30.661085	2025-06-28 11:03:30.66	\N	\N	map.movementAction	{"x": 1, "y": 7, "playerId": 1}
1118	1	5	2025-06-28 10:58:30.661547	2025-06-28 11:03:30.66	\N	\N	map.movementAction	{"x": 2, "y": 8, "playerId": 1}
1119	1	5	2025-06-28 12:03:16.9059	2025-06-28 12:08:16.91	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1120	1	5	2025-06-28 12:03:16.907138	2025-06-28 12:08:16.91	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1121	1	5	2025-06-28 12:03:16.910111	2025-06-28 12:08:16.91	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1122	1	5	2025-06-28 12:03:16.9106	2025-06-28 12:08:16.91	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1123	1	5	2025-06-28 12:03:16.911072	2025-06-28 12:08:16.91	\N	\N	map.movementAction	{"x": 6, "y": 7, "playerId": 1}
1124	1	5	2025-06-28 12:07:42.534688	2025-06-28 12:12:42.53	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1125	1	5	2025-06-28 12:07:42.536252	2025-06-28 12:12:42.54	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1126	1	5	2025-06-28 12:07:42.536747	2025-06-28 12:12:42.54	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1127	1	5	2025-06-28 12:07:42.537189	2025-06-28 12:12:42.54	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1128	1	5	2025-06-28 12:07:42.537592	2025-06-28 12:12:42.54	\N	\N	map.movementAction	{"x": 6, "y": 5, "playerId": 1}
1129	1	5	2025-06-28 12:07:42.538096	2025-06-28 12:12:42.54	\N	\N	map.movementAction	{"x": 7, "y": 4, "playerId": 1}
1130	1	5	2025-06-28 12:07:59.598054	2025-06-28 12:12:59.6	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1131	1	5	2025-06-28 12:07:59.598811	2025-06-28 12:12:59.6	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1132	1	5	2025-06-28 12:07:59.599373	2025-06-28 12:12:59.6	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1133	1	5	2025-06-28 12:07:59.600096	2025-06-28 12:12:59.6	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1134	1	5	2025-06-28 12:07:59.600586	2025-06-28 12:12:59.6	\N	\N	map.movementAction	{"x": 6, "y": 5, "playerId": 1}
1135	1	5	2025-06-28 12:07:59.60101	2025-06-28 12:12:59.6	\N	\N	map.movementAction	{"x": 7, "y": 4, "playerId": 1}
1136	1	5	2025-06-28 12:08:08.930022	2025-06-28 12:13:08.93	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1137	1	5	2025-06-28 12:08:08.930609	2025-06-28 12:13:08.93	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1138	1	5	2025-06-28 12:08:08.931041	2025-06-28 12:13:08.93	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1139	1	5	2025-06-28 12:08:08.931462	2025-06-28 12:13:08.93	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1140	1	5	2025-06-28 12:08:08.931843	2025-06-28 12:13:08.93	\N	\N	map.movementAction	{"x": 6, "y": 5, "playerId": 1}
1141	1	5	2025-06-28 12:08:08.932229	2025-06-28 12:13:08.93	\N	\N	map.movementAction	{"x": 7, "y": 4, "playerId": 1}
1142	1	5	2025-06-28 12:32:58.841063	2025-06-28 12:37:58.84	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1143	1	5	2025-06-28 12:32:58.842447	2025-06-28 12:37:58.84	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1144	1	5	2025-06-28 12:32:58.842916	2025-06-28 12:37:58.84	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1145	1	5	2025-06-28 12:32:58.843337	2025-06-28 12:37:58.84	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1146	1	5	2025-06-28 12:32:58.843758	2025-06-28 12:37:58.84	\N	\N	map.movementAction	{"x": 6, "y": 5, "playerId": 1}
1147	1	5	2025-06-28 12:32:58.844157	2025-06-28 12:37:58.84	\N	\N	map.movementAction	{"x": 7, "y": 4, "playerId": 1}
1148	1	5	2025-06-28 12:33:00.297817	2025-06-28 12:38:00.3	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1149	1	5	2025-06-28 12:33:00.298402	2025-06-28 12:38:00.3	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1150	1	5	2025-06-28 12:33:00.298913	2025-06-28 12:38:00.3	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1151	1	5	2025-06-28 12:33:00.299403	2025-06-28 12:38:00.3	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1152	1	5	2025-06-28 12:33:00.299929	2025-06-28 12:38:00.3	\N	\N	map.movementAction	{"x": 6, "y": 5, "playerId": 1}
1153	1	5	2025-06-28 12:33:00.300428	2025-06-28 12:38:00.3	\N	\N	map.movementAction	{"x": 7, "y": 4, "playerId": 1}
1154	1	5	2025-06-28 12:40:09.335295	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
1155	1	5	2025-06-28 12:40:09.336566	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1156	1	5	2025-06-28 12:40:09.337059	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 4, "y": 8, "playerId": 1}
1157	1	5	2025-06-28 12:40:09.337559	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 5, "y": 9, "playerId": 1}
1158	1	5	2025-06-28 12:40:09.338017	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 4, "y": 10, "playerId": 1}
1159	1	5	2025-06-28 12:40:09.338469	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 4, "y": 11, "playerId": 1}
1160	1	5	2025-06-28 12:40:09.338948	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 4, "y": 12, "playerId": 1}
1161	1	5	2025-06-28 12:40:09.33942	2025-06-28 12:45:09.34	\N	\N	map.movementAction	{"x": 4, "y": 13, "playerId": 1}
1162	1	5	2025-06-28 12:40:15.381133	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 4, "y": 12, "playerId": 1}
1163	1	5	2025-06-28 12:40:15.381801	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 4, "y": 11, "playerId": 1}
1164	1	5	2025-06-28 12:40:15.382321	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 4, "y": 10, "playerId": 1}
1165	1	5	2025-06-28 12:40:15.382759	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 5, "y": 9, "playerId": 1}
1166	1	5	2025-06-28 12:40:15.383195	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1167	1	5	2025-06-28 12:40:15.383587	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1168	1	5	2025-06-28 12:40:15.383963	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1169	1	5	2025-06-28 12:40:15.384323	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1170	1	5	2025-06-28 12:40:15.384687	2025-06-28 12:45:15.38	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1171	1	5	2025-06-28 12:40:15.385084	2025-06-28 12:45:15.39	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
1172	1	5	2025-06-28 12:40:15.385429	2025-06-28 12:45:15.39	\N	\N	map.movementAction	{"x": 12, "y": 8, "playerId": 1}
1173	1	5	2025-06-28 12:40:54.968593	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1174	1	5	2025-06-28 12:40:54.969681	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1175	1	5	2025-06-28 12:40:54.970193	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1176	1	5	2025-06-28 12:40:54.970616	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1177	1	5	2025-06-28 12:40:54.971222	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1178	1	5	2025-06-28 12:40:54.971862	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
1179	1	5	2025-06-28 12:40:54.972366	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 8, "y": 6, "playerId": 1}
1180	1	5	2025-06-28 12:40:54.972918	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 9, "y": 5, "playerId": 1}
1181	1	5	2025-06-28 12:40:54.973372	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 10, "y": 5, "playerId": 1}
1182	1	5	2025-06-28 12:40:54.973835	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 11, "y": 4, "playerId": 1}
1183	1	5	2025-06-28 12:40:54.974246	2025-06-28 12:45:54.97	\N	\N	map.movementAction	{"x": 12, "y": 4, "playerId": 1}
1184	1	5	2025-06-28 12:43:16.97265	2025-06-28 12:48:16.97	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1185	1	5	2025-06-28 12:43:16.974398	2025-06-28 12:48:16.97	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1186	1	5	2025-06-28 12:43:16.974971	2025-06-28 12:48:16.97	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
1187	1	5	2025-06-28 12:43:16.975503	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
1188	1	5	2025-06-28 12:43:16.975931	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1189	1	5	2025-06-28 12:43:16.97632	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1190	1	5	2025-06-28 12:43:16.976705	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1191	1	5	2025-06-28 12:43:16.977059	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1192	1	5	2025-06-28 12:43:16.97743	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1193	1	5	2025-06-28 12:43:16.97778	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
1194	1	5	2025-06-28 12:43:16.978109	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
1195	1	5	2025-06-28 12:43:16.97844	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 13, "y": 7, "playerId": 1}
1196	1	5	2025-06-28 12:43:16.978787	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 14, "y": 8, "playerId": 1}
1197	1	5	2025-06-28 12:43:16.979128	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 15, "y": 7, "playerId": 1}
1198	1	5	2025-06-28 12:43:16.97948	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 16, "y": 8, "playerId": 1}
1199	1	5	2025-06-28 12:43:16.979822	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 17, "y": 9, "playerId": 1}
1200	1	5	2025-06-28 12:43:16.98016	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 18, "y": 8, "playerId": 1}
1201	1	5	2025-06-28 12:43:16.980593	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 19, "y": 8, "playerId": 1}
1202	1	5	2025-06-28 12:43:16.980977	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 20, "y": 7, "playerId": 1}
1203	1	5	2025-06-28 12:43:16.981365	2025-06-28 12:48:16.98	\N	\N	map.movementAction	{"x": 19, "y": 6, "playerId": 1}
1204	1	5	2025-06-28 12:46:05.215239	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1205	1	5	2025-06-28 12:46:05.216426	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1206	1	5	2025-06-28 12:46:05.217034	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1207	1	5	2025-06-28 12:46:05.217554	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1208	1	5	2025-06-28 12:46:05.218125	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1209	1	5	2025-06-28 12:46:05.21856	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1210	1	5	2025-06-28 12:46:05.219126	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1211	1	5	2025-06-28 12:46:05.219842	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1212	1	5	2025-06-28 12:46:05.220315	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 8, "y": 13, "playerId": 1}
1213	1	5	2025-06-28 12:46:05.220797	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 9, "y": 14, "playerId": 1}
1214	1	5	2025-06-28 12:46:05.221303	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 10, "y": 15, "playerId": 1}
1215	1	5	2025-06-28 12:46:05.221741	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 11, "y": 16, "playerId": 1}
1216	1	5	2025-06-28 12:46:05.222357	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 11, "y": 17, "playerId": 1}
1217	1	5	2025-06-28 12:46:05.222802	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 11, "y": 18, "playerId": 1}
1218	1	5	2025-06-28 12:46:05.223221	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 12, "y": 19, "playerId": 1}
1219	1	5	2025-06-28 12:46:05.223599	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 11, "y": 20, "playerId": 1}
1220	1	5	2025-06-28 12:46:05.22402	2025-06-28 12:51:05.22	\N	\N	map.movementAction	{"x": 10, "y": 20, "playerId": 1}
1221	1	5	2025-06-28 12:46:16.65822	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1222	1	5	2025-06-28 12:46:16.658871	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1223	1	5	2025-06-28 12:46:16.659343	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1224	1	5	2025-06-28 12:46:16.659755	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1225	1	5	2025-06-28 12:46:16.66015	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1226	1	5	2025-06-28 12:46:16.660546	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1227	1	5	2025-06-28 12:46:16.660921	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1228	1	5	2025-06-28 12:46:16.661293	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1229	1	5	2025-06-28 12:46:16.661761	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
1230	1	5	2025-06-28 12:46:16.662157	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
1231	1	5	2025-06-28 12:46:16.662565	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 11, "y": 12, "playerId": 1}
1232	1	5	2025-06-28 12:46:16.66293	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 12, "y": 12, "playerId": 1}
1233	1	5	2025-06-28 12:46:16.663295	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 13, "y": 12, "playerId": 1}
1234	1	5	2025-06-28 12:46:16.663734	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 14, "y": 13, "playerId": 1}
1235	1	5	2025-06-28 12:46:16.664142	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 15, "y": 12, "playerId": 1}
1236	1	5	2025-06-28 12:46:16.664513	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 16, "y": 12, "playerId": 1}
1237	1	5	2025-06-28 12:46:16.664901	2025-06-28 12:51:16.66	\N	\N	map.movementAction	{"x": 17, "y": 11, "playerId": 1}
1238	1	5	2025-06-28 12:46:16.665311	2025-06-28 12:51:16.67	\N	\N	map.movementAction	{"x": 18, "y": 12, "playerId": 1}
1239	1	5	2025-06-28 12:46:16.66569	2025-06-28 12:51:16.67	\N	\N	map.movementAction	{"x": 19, "y": 12, "playerId": 1}
1240	1	5	2025-06-28 12:46:16.666764	2025-06-28 12:51:16.67	\N	\N	map.movementAction	{"x": 20, "y": 11, "playerId": 1}
1241	1	5	2025-06-28 12:46:16.667135	2025-06-28 12:51:16.67	\N	\N	map.movementAction	{"x": 21, "y": 10, "playerId": 1}
1242	1	5	2025-06-28 12:46:16.667514	2025-06-28 12:51:16.67	\N	\N	map.movementAction	{"x": 22, "y": 11, "playerId": 1}
1243	1	5	2025-06-28 12:46:16.667904	2025-06-28 12:51:16.67	\N	\N	map.movementAction	{"x": 23, "y": 12, "playerId": 1}
1244	1	5	2025-06-28 12:46:16.668292	2025-06-28 12:51:16.67	\N	\N	map.movementAction	{"x": 24, "y": 12, "playerId": 1}
1245	1	5	2025-06-28 12:50:26.989057	2025-06-28 12:55:26.99	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1246	1	5	2025-06-28 12:50:26.990396	2025-06-28 12:55:26.99	\N	\N	map.movementAction	{"x": 3, "y": 3, "playerId": 1}
1247	1	5	2025-06-28 12:50:26.990865	2025-06-28 12:55:26.99	\N	\N	map.movementAction	{"x": 4, "y": 3, "playerId": 1}
1248	1	5	2025-06-28 12:50:26.991331	2025-06-28 12:55:26.99	\N	\N	map.movementAction	{"x": 5, "y": 3, "playerId": 1}
1249	1	5	2025-06-28 13:57:23.804145	2025-06-28 14:02:23.8	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1250	1	5	2025-06-28 13:57:23.807404	2025-06-28 14:02:23.81	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1251	1	5	2025-06-28 13:57:23.808331	2025-06-28 14:02:23.81	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1252	1	5	2025-06-28 13:57:23.809398	2025-06-28 14:02:23.81	\N	\N	map.movementAction	{"x": 4, "y": 8, "playerId": 1}
1253	1	5	2025-06-28 13:57:28.690344	2025-06-28 14:02:28.69	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1254	1	5	2025-06-28 13:57:28.691427	2025-06-28 14:02:28.69	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1255	1	5	2025-06-28 13:57:28.692056	2025-06-28 14:02:28.69	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
1256	1	5	2025-06-28 13:57:28.692848	2025-06-28 14:02:28.69	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1257	1	5	2025-06-28 13:57:28.693372	2025-06-28 14:02:28.69	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1258	1	5	2025-06-30 22:27:42.44253	2025-06-30 22:32:42.44	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1259	1	5	2025-06-30 22:27:42.452903	2025-06-30 22:32:42.45	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1260	1	5	2025-06-30 22:27:42.453515	2025-06-30 22:32:42.45	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1261	1	5	2025-06-30 22:27:42.454016	2025-06-30 22:32:42.45	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1262	1	5	2025-06-30 22:27:42.45451	2025-06-30 22:32:42.45	\N	\N	map.movementAction	{"x": 5, "y": 9, "playerId": 1}
1263	1	5	2025-06-30 23:24:16.436885	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1264	1	5	2025-06-30 23:24:16.439007	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1265	1	5	2025-06-30 23:24:16.439749	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
1266	1	5	2025-06-30 23:24:16.441	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
1267	1	5	2025-06-30 23:24:16.441865	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1268	1	5	2025-06-30 23:24:16.442373	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1269	1	5	2025-06-30 23:24:16.44287	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1270	1	5	2025-06-30 23:24:16.443313	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1271	1	5	2025-06-30 23:24:16.44367	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1272	1	5	2025-06-30 23:24:16.444711	2025-06-30 23:29:16.44	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
1273	1	5	2025-06-30 23:24:16.445116	2025-06-30 23:29:16.45	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
1274	1	5	2025-06-30 23:24:16.445682	2025-06-30 23:29:16.45	\N	\N	map.movementAction	{"x": 13, "y": 6, "playerId": 1}
1275	1	5	2025-06-30 23:24:16.446101	2025-06-30 23:29:16.45	\N	\N	map.movementAction	{"x": 14, "y": 6, "playerId": 1}
1276	1	5	2025-07-01 03:06:24.792785	2025-07-01 03:11:24.79	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1277	1	5	2025-07-01 03:06:24.802364	2025-07-01 03:11:24.8	\N	\N	map.movementAction	{"x": 3, "y": 2, "playerId": 1}
1278	1	5	2025-07-01 03:06:24.803419	2025-07-01 03:11:24.8	\N	\N	map.movementAction	{"x": 4, "y": 3, "playerId": 1}
1279	1	5	2025-07-01 03:06:24.804612	2025-07-01 03:11:24.8	\N	\N	map.movementAction	{"x": 5, "y": 2, "playerId": 1}
1280	1	5	2025-07-01 03:06:24.805394	2025-07-01 03:11:24.81	\N	\N	map.movementAction	{"x": 6, "y": 2, "playerId": 1}
1281	1	5	2025-07-09 23:25:52.04431	2025-07-09 23:30:52.04	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1282	1	5	2025-07-09 23:25:52.056279	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1283	1	5	2025-07-09 23:25:52.056782	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1284	1	5	2025-07-09 23:25:52.057232	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1285	1	5	2025-07-09 23:25:52.057626	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1286	1	5	2025-07-09 23:25:52.057999	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1287	1	5	2025-07-09 23:25:52.058332	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1288	1	5	2025-07-09 23:25:52.058677	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1289	1	5	2025-07-09 23:25:52.059001	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1290	1	5	2025-07-09 23:25:52.059317	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
1291	1	5	2025-07-09 23:25:52.059626	2025-07-09 23:30:52.06	\N	\N	map.movementAction	{"x": 12, "y": 8, "playerId": 1}
1292	1	5	2025-07-09 23:26:16.932124	2025-07-09 23:31:16.93	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1293	1	5	2025-07-09 23:26:16.932831	2025-07-09 23:31:16.93	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1294	1	5	2025-07-09 23:26:16.933315	2025-07-09 23:31:16.93	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1295	1	5	2025-07-09 23:26:16.93375	2025-07-09 23:31:16.93	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1296	1	5	2025-07-09 23:26:16.934231	2025-07-09 23:31:16.93	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1297	1	5	2025-07-09 23:26:16.934652	2025-07-09 23:31:16.93	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
1298	1	5	2025-07-09 23:26:16.935019	2025-07-09 23:31:16.94	\N	\N	map.movementAction	{"x": 8, "y": 6, "playerId": 1}
1299	1	5	2025-07-09 23:26:16.935685	2025-07-09 23:31:16.94	\N	\N	map.movementAction	{"x": 9, "y": 5, "playerId": 1}
1300	1	5	2025-07-09 23:26:27.562326	2025-07-09 23:31:27.56	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1301	1	5	2025-07-09 23:26:27.563039	2025-07-09 23:31:27.56	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1302	1	5	2025-07-09 23:26:27.563573	2025-07-09 23:31:27.56	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1303	1	5	2025-07-09 23:26:27.565211	2025-07-09 23:31:27.57	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
1304	1	5	2025-07-09 23:26:27.565718	2025-07-09 23:31:27.57	\N	\N	map.movementAction	{"x": 6, "y": 4, "playerId": 1}
1305	1	5	2025-07-09 23:26:27.566146	2025-07-09 23:31:27.57	\N	\N	map.movementAction	{"x": 7, "y": 3, "playerId": 1}
1306	1	5	2025-07-10 00:04:34.922457	2025-07-10 00:09:34.92	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1307	1	5	2025-07-10 00:04:34.923929	2025-07-10 00:09:34.92	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1308	1	5	2025-07-10 00:04:34.924386	2025-07-10 00:09:34.92	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1309	1	5	2025-07-10 00:04:34.92555	2025-07-10 00:09:34.93	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1310	1	5	2025-07-10 00:04:34.925982	2025-07-10 00:09:34.93	\N	\N	map.movementAction	{"x": 6, "y": 7, "playerId": 1}
1311	1	5	2025-07-10 00:04:41.196066	2025-07-10 00:09:41.2	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1312	1	5	2025-07-10 00:04:41.196738	2025-07-10 00:09:41.2	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1313	1	5	2025-07-10 00:04:41.197212	2025-07-10 00:09:41.2	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1314	1	5	2025-07-10 00:04:41.197666	2025-07-10 00:09:41.2	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
1315	1	5	2025-07-10 00:04:41.198075	2025-07-10 00:09:41.2	\N	\N	map.movementAction	{"x": 6, "y": 3, "playerId": 1}
1316	1	5	2025-07-10 00:04:41.198464	2025-07-10 00:09:41.2	\N	\N	map.movementAction	{"x": 7, "y": 2, "playerId": 1}
1317	1	5	2025-07-10 00:04:41.198822	2025-07-10 00:09:41.2	\N	\N	map.movementAction	{"x": 8, "y": 2, "playerId": 1}
1318	1	5	2025-07-13 21:48:20.236533	2025-07-13 21:53:20.24	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1319	1	5	2025-07-13 21:48:20.245586	2025-07-13 21:53:20.25	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1320	1	5	2025-07-13 21:48:20.246884	2025-07-13 21:53:20.25	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1321	1	5	2025-07-13 21:48:20.247301	2025-07-13 21:53:20.25	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1322	1	5	2025-07-13 21:48:20.247695	2025-07-13 21:53:20.25	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1323	1	5	2025-07-13 21:48:20.248326	2025-07-13 21:53:20.25	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1324	1	5	2025-07-13 21:48:20.248699	2025-07-13 21:53:20.25	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1325	1	5	2025-07-13 21:48:20.249286	2025-07-13 21:53:20.25	\N	\N	map.movementAction	{"x": 9, "y": 10, "playerId": 1}
1326	1	5	2025-07-13 21:48:33.007306	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1327	1	5	2025-07-13 21:48:33.007931	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1328	1	5	2025-07-13 21:48:33.008438	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
1329	1	5	2025-07-13 21:48:33.008871	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
1330	1	5	2025-07-13 21:48:33.009189	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1331	1	5	2025-07-13 21:48:33.009505	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1332	1	5	2025-07-13 21:48:33.009873	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1333	1	5	2025-07-13 21:48:33.010191	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1334	1	5	2025-07-13 21:48:33.0105	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1335	1	5	2025-07-13 21:48:33.010767	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
1336	1	5	2025-07-13 21:48:33.011014	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
1337	1	5	2025-07-13 21:48:33.011292	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 13, "y": 6, "playerId": 1}
1338	1	5	2025-07-13 21:48:33.011539	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 13, "y": 5, "playerId": 1}
1339	1	5	2025-07-13 21:48:33.01182	2025-07-13 21:53:33.01	\N	\N	map.movementAction	{"x": 13, "y": 4, "playerId": 1}
1340	1	5	2025-07-13 21:56:05.128459	2025-07-13 22:01:05.13	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1341	1	5	2025-07-13 21:56:05.137155	2025-07-13 22:01:05.14	\N	\N	map.movementAction	{"x": 3, "y": 3, "playerId": 1}
1342	1	5	2025-07-13 21:56:05.137943	2025-07-13 22:01:05.14	\N	\N	map.movementAction	{"x": 4, "y": 3, "playerId": 1}
1343	1	5	2025-07-13 21:56:05.13852	2025-07-13 22:01:05.14	\N	\N	map.movementAction	{"x": 5, "y": 3, "playerId": 1}
1344	1	5	2025-07-13 22:04:33.891894	2025-07-13 22:09:33.89	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1345	1	5	2025-07-13 22:04:33.89539	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1346	1	5	2025-07-13 22:04:33.896589	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
1347	1	5	2025-07-13 22:04:33.898158	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
1348	1	5	2025-07-13 22:04:33.898956	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1349	1	5	2025-07-13 22:04:33.899588	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1350	1	5	2025-07-13 22:04:33.900267	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1351	1	5	2025-07-13 22:04:33.901154	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1352	1	5	2025-07-13 22:04:33.901927	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1353	1	5	2025-07-13 22:04:33.902529	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 10, "y": 7, "playerId": 1}
1354	1	5	2025-07-13 22:04:33.903056	2025-07-13 22:09:33.9	\N	\N	map.movementAction	{"x": 11, "y": 6, "playerId": 1}
1355	1	5	2025-07-13 22:04:42.749285	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1356	1	5	2025-07-13 22:04:42.75047	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1357	1	5	2025-07-13 22:04:42.75124	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1358	1	5	2025-07-13 22:04:42.751733	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1359	1	5	2025-07-13 22:04:42.752803	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1360	1	5	2025-07-13 22:04:42.753217	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1361	1	5	2025-07-13 22:04:42.75357	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1362	1	5	2025-07-13 22:04:42.753957	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1363	1	5	2025-07-13 22:04:42.754305	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
1364	1	5	2025-07-13 22:04:42.754652	2025-07-13 22:09:42.75	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
1365	1	5	2025-07-13 22:04:42.755004	2025-07-13 22:09:42.76	\N	\N	map.movementAction	{"x": 11, "y": 12, "playerId": 1}
1366	1	5	2025-07-13 22:04:42.755321	2025-07-13 22:09:42.76	\N	\N	map.movementAction	{"x": 12, "y": 12, "playerId": 1}
1367	1	5	2025-07-13 22:04:42.755636	2025-07-13 22:09:42.76	\N	\N	map.movementAction	{"x": 13, "y": 12, "playerId": 1}
1368	1	5	2025-07-13 22:04:42.756017	2025-07-13 22:09:42.76	\N	\N	map.movementAction	{"x": 14, "y": 13, "playerId": 1}
1369	1	5	2025-07-13 22:08:28.807489	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1370	1	5	2025-07-13 22:08:28.808907	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1371	1	5	2025-07-13 22:08:28.809328	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1372	1	5	2025-07-13 22:08:28.809636	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1373	1	5	2025-07-13 22:08:28.809954	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1374	1	5	2025-07-13 22:08:28.81023	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1375	1	5	2025-07-13 22:08:28.811403	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1376	1	5	2025-07-13 22:08:28.811692	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1377	1	5	2025-07-13 22:08:28.812005	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 8, "y": 13, "playerId": 1}
1378	1	5	2025-07-13 22:08:28.812275	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 9, "y": 14, "playerId": 1}
1379	1	5	2025-07-13 22:08:28.812576	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 10, "y": 15, "playerId": 1}
1380	1	5	2025-07-13 22:08:28.812887	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 11, "y": 16, "playerId": 1}
1381	1	5	2025-07-13 22:08:28.813335	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 12, "y": 17, "playerId": 1}
1382	1	5	2025-07-13 22:08:28.813709	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 13, "y": 18, "playerId": 1}
1383	1	5	2025-07-13 22:08:28.814012	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 14, "y": 19, "playerId": 1}
1384	1	5	2025-07-13 22:08:28.81429	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 15, "y": 20, "playerId": 1}
1385	1	5	2025-07-13 22:08:28.814591	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 15, "y": 21, "playerId": 1}
1386	1	5	2025-07-13 22:08:28.814858	2025-07-13 22:13:28.81	\N	\N	map.movementAction	{"x": 15, "y": 22, "playerId": 1}
1387	1	5	2025-07-13 22:08:28.815444	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 15, "y": 23, "playerId": 1}
1388	1	5	2025-07-13 22:08:28.815714	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 16, "y": 24, "playerId": 1}
1389	1	5	2025-07-13 22:08:28.815972	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 17, "y": 23, "playerId": 1}
1390	1	5	2025-07-13 22:08:28.816249	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 18, "y": 22, "playerId": 1}
1391	1	5	2025-07-13 22:08:28.816504	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 19, "y": 22, "playerId": 1}
1392	1	5	2025-07-13 22:08:28.816766	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 20, "y": 23, "playerId": 1}
1393	1	5	2025-07-13 22:08:28.81702	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 21, "y": 24, "playerId": 1}
1394	1	5	2025-07-13 22:08:28.817268	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 22, "y": 24, "playerId": 1}
1395	1	5	2025-07-13 22:08:28.817538	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 23, "y": 25, "playerId": 1}
1396	1	5	2025-07-13 22:08:28.81781	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 24, "y": 26, "playerId": 1}
1397	1	5	2025-07-13 22:08:28.818067	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 25, "y": 27, "playerId": 1}
1398	1	5	2025-07-13 22:08:28.818339	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 26, "y": 28, "playerId": 1}
1399	1	5	2025-07-13 22:08:28.818612	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 27, "y": 27, "playerId": 1}
1400	1	5	2025-07-13 22:08:28.818979	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 28, "y": 28, "playerId": 1}
1401	1	5	2025-07-13 22:08:28.819236	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 29, "y": 29, "playerId": 1}
1402	1	5	2025-07-13 22:08:28.819488	2025-07-13 22:13:28.82	\N	\N	map.movementAction	{"x": 30, "y": 30, "playerId": 1}
1403	1	5	2025-07-13 22:08:37.836361	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1404	1	5	2025-07-13 22:08:37.836946	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1405	1	5	2025-07-13 22:08:37.837387	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1406	1	5	2025-07-13 22:08:37.837663	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1407	1	5	2025-07-13 22:08:37.837922	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1408	1	5	2025-07-13 22:08:37.838168	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1409	1	5	2025-07-13 22:08:37.838412	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1410	1	5	2025-07-13 22:08:37.838656	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1411	1	5	2025-07-13 22:08:37.838905	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1412	1	5	2025-07-13 22:08:37.839143	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 11, "y": 9, "playerId": 1}
1413	1	5	2025-07-13 22:08:37.839384	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 12, "y": 10, "playerId": 1}
1414	1	5	2025-07-13 22:08:37.839688	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 13, "y": 10, "playerId": 1}
1415	1	5	2025-07-13 22:08:37.840015	2025-07-13 22:13:37.84	\N	\N	map.movementAction	{"x": 14, "y": 10, "playerId": 1}
1416	1	5	2025-07-13 22:10:44.367473	2025-07-13 22:15:44.37	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1417	1	5	2025-07-13 22:10:44.379505	2025-07-13 22:15:44.38	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1418	1	5	2025-07-13 22:10:44.38001	2025-07-13 22:15:44.38	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1419	1	5	2025-07-13 22:10:44.380367	2025-07-13 22:15:44.38	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1420	1	5	2025-07-13 22:10:44.380689	2025-07-13 22:15:44.38	\N	\N	map.movementAction	{"x": 6, "y": 7, "playerId": 1}
1421	1	5	2025-07-13 22:10:49.30677	2025-07-13 22:15:49.31	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
1422	1	5	2025-07-13 22:10:49.307358	2025-07-13 22:15:49.31	\N	\N	map.movementAction	{"x": 8, "y": 6, "playerId": 1}
1423	1	5	2025-07-13 22:10:49.307805	2025-07-13 22:15:49.31	\N	\N	map.movementAction	{"x": 9, "y": 5, "playerId": 1}
1424	1	5	2025-07-13 22:10:49.30835	2025-07-13 22:15:49.31	\N	\N	map.movementAction	{"x": 10, "y": 4, "playerId": 1}
1425	1	5	2025-07-13 22:10:53.394867	2025-07-13 22:15:53.39	\N	\N	map.movementAction	{"x": 10, "y": 5, "playerId": 1}
1426	1	5	2025-07-13 22:10:53.395326	2025-07-13 22:15:53.4	\N	\N	map.movementAction	{"x": 11, "y": 6, "playerId": 1}
1427	1	5	2025-07-13 22:10:53.395663	2025-07-13 22:15:53.4	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
1428	1	5	2025-07-13 22:10:53.396078	2025-07-13 22:15:53.4	\N	\N	map.movementAction	{"x": 13, "y": 8, "playerId": 1}
1429	1	5	2025-07-13 22:10:53.396367	2025-07-13 22:15:53.4	\N	\N	map.movementAction	{"x": 14, "y": 8, "playerId": 1}
1430	1	5	2025-07-13 22:10:53.396635	2025-07-13 22:15:53.4	\N	\N	map.movementAction	{"x": 15, "y": 7, "playerId": 1}
1431	1	5	2025-07-13 22:10:53.397062	2025-07-13 22:15:53.4	\N	\N	map.movementAction	{"x": 16, "y": 8, "playerId": 1}
1432	1	5	2025-07-13 22:10:57.758629	2025-07-13 22:15:57.76	\N	\N	map.movementAction	{"x": 17, "y": 9, "playerId": 1}
1433	1	5	2025-07-13 22:10:57.759043	2025-07-13 22:15:57.76	\N	\N	map.movementAction	{"x": 17, "y": 10, "playerId": 1}
1434	1	5	2025-07-13 22:10:57.759501	2025-07-13 22:15:57.76	\N	\N	map.movementAction	{"x": 17, "y": 11, "playerId": 1}
1435	1	5	2025-07-13 22:10:57.759956	2025-07-13 22:15:57.76	\N	\N	map.movementAction	{"x": 18, "y": 12, "playerId": 1}
1436	1	5	2025-07-13 22:10:57.760433	2025-07-13 22:15:57.76	\N	\N	map.movementAction	{"x": 19, "y": 12, "playerId": 1}
1437	1	5	2025-07-13 22:10:57.760795	2025-07-13 22:15:57.76	\N	\N	map.movementAction	{"x": 20, "y": 11, "playerId": 1}
1438	1	5	2025-07-13 22:10:57.761183	2025-07-13 22:15:57.76	\N	\N	map.movementAction	{"x": 21, "y": 11, "playerId": 1}
1439	1	5	2025-07-13 22:11:01.792618	2025-07-13 22:16:01.79	\N	\N	map.movementAction	{"x": 20, "y": 12, "playerId": 1}
1440	1	5	2025-07-13 22:11:01.793122	2025-07-13 22:16:01.79	\N	\N	map.movementAction	{"x": 19, "y": 13, "playerId": 1}
1441	1	5	2025-07-13 22:11:01.793451	2025-07-13 22:16:01.79	\N	\N	map.movementAction	{"x": 18, "y": 14, "playerId": 1}
1442	1	5	2025-07-13 22:11:01.793735	2025-07-13 22:16:01.79	\N	\N	map.movementAction	{"x": 18, "y": 15, "playerId": 1}
1443	1	5	2025-07-13 22:11:01.794306	2025-07-13 22:16:01.79	\N	\N	map.movementAction	{"x": 17, "y": 16, "playerId": 1}
1444	1	5	2025-07-13 22:11:01.794747	2025-07-13 22:16:01.79	\N	\N	map.movementAction	{"x": 16, "y": 17, "playerId": 1}
1445	1	5	2025-07-13 22:11:01.795128	2025-07-13 22:16:01.8	\N	\N	map.movementAction	{"x": 15, "y": 18, "playerId": 1}
1446	1	5	2025-07-13 22:11:01.795428	2025-07-13 22:16:01.8	\N	\N	map.movementAction	{"x": 14, "y": 19, "playerId": 1}
1447	1	5	2025-07-13 22:11:01.795722	2025-07-13 22:16:01.8	\N	\N	map.movementAction	{"x": 15, "y": 20, "playerId": 1}
1448	1	5	2025-07-13 22:11:06.210406	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 15, "y": 21, "playerId": 1}
1449	1	5	2025-07-13 22:11:06.210814	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 15, "y": 22, "playerId": 1}
1450	1	5	2025-07-13 22:11:06.211183	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 15, "y": 23, "playerId": 1}
1451	1	5	2025-07-13 22:11:06.211499	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 16, "y": 24, "playerId": 1}
1452	1	5	2025-07-13 22:11:06.21176	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 17, "y": 23, "playerId": 1}
1453	1	5	2025-07-13 22:11:06.212053	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 18, "y": 22, "playerId": 1}
1454	1	5	2025-07-13 22:11:06.21234	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 19, "y": 22, "playerId": 1}
1455	1	5	2025-07-13 22:11:06.212637	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 20, "y": 23, "playerId": 1}
1456	1	5	2025-07-13 22:11:06.212897	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 21, "y": 24, "playerId": 1}
1457	1	5	2025-07-13 22:11:06.213164	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 22, "y": 24, "playerId": 1}
1458	1	5	2025-07-13 22:11:06.213419	2025-07-13 22:16:06.21	\N	\N	map.movementAction	{"x": 23, "y": 25, "playerId": 1}
1459	1	5	2025-07-13 22:12:15.595678	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 22, "y": 24, "playerId": 1}
1460	1	5	2025-07-13 22:12:15.597192	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 23, "y": 23, "playerId": 1}
1461	1	5	2025-07-13 22:12:15.597566	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 24, "y": 22, "playerId": 1}
1462	1	5	2025-07-13 22:12:15.597883	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 25, "y": 21, "playerId": 1}
1463	1	5	2025-07-13 22:12:15.598221	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 25, "y": 20, "playerId": 1}
1464	1	5	2025-07-13 22:12:15.598559	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 26, "y": 19, "playerId": 1}
1465	1	5	2025-07-13 22:12:15.598851	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 26, "y": 18, "playerId": 1}
1466	1	5	2025-07-13 22:12:15.599113	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 27, "y": 17, "playerId": 1}
1467	1	5	2025-07-13 22:12:15.599421	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 26, "y": 16, "playerId": 1}
1468	1	5	2025-07-13 22:12:15.599692	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 26, "y": 15, "playerId": 1}
1469	1	5	2025-07-13 22:12:15.599952	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 25, "y": 14, "playerId": 1}
1470	1	5	2025-07-13 22:12:15.600365	2025-07-13 22:17:15.6	\N	\N	map.movementAction	{"x": 24, "y": 13, "playerId": 1}
1471	1	5	2025-07-13 22:12:28.268597	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 23, "y": 12, "playerId": 1}
1472	1	5	2025-07-13 22:12:28.269602	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 22, "y": 11, "playerId": 1}
1473	1	5	2025-07-13 22:12:28.27028	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 21, "y": 10, "playerId": 1}
1474	1	5	2025-07-13 22:12:28.270703	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 20, "y": 11, "playerId": 1}
1475	1	5	2025-07-13 22:12:28.271076	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 19, "y": 12, "playerId": 1}
1476	1	5	2025-07-13 22:12:28.271429	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 18, "y": 12, "playerId": 1}
1477	1	5	2025-07-13 22:12:28.271777	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 17, "y": 11, "playerId": 1}
1478	1	5	2025-07-13 22:12:28.272056	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 16, "y": 10, "playerId": 1}
1479	1	5	2025-07-13 22:12:28.272405	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 15, "y": 9, "playerId": 1}
1480	1	5	2025-07-13 22:12:28.272711	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 16, "y": 8, "playerId": 1}
1481	1	5	2025-07-13 22:12:28.273057	2025-07-13 22:17:28.27	\N	\N	map.movementAction	{"x": 15, "y": 7, "playerId": 1}
1482	1	5	2025-07-13 22:13:12.099051	2025-07-13 22:18:12.1	\N	\N	map.movementAction	{"x": 16, "y": 8, "playerId": 1}
1483	1	5	2025-07-13 22:13:12.1005	2025-07-13 22:18:12.1	\N	\N	map.movementAction	{"x": 17, "y": 9, "playerId": 1}
1484	1	5	2025-07-13 22:13:12.100816	2025-07-13 22:18:12.1	\N	\N	map.movementAction	{"x": 18, "y": 8, "playerId": 1}
1485	1	5	2025-07-13 22:13:12.101176	2025-07-13 22:18:12.1	\N	\N	map.movementAction	{"x": 19, "y": 8, "playerId": 1}
1486	1	5	2025-07-13 22:13:12.101539	2025-07-13 22:18:12.1	\N	\N	map.movementAction	{"x": 20, "y": 8, "playerId": 1}
1487	1	5	2025-07-13 22:18:32.267264	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1488	1	5	2025-07-13 22:18:32.268992	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1489	1	5	2025-07-13 22:18:32.269411	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1490	1	5	2025-07-13 22:18:32.269737	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1491	1	5	2025-07-13 22:18:32.270074	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1492	1	5	2025-07-13 22:18:32.270356	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
1493	1	5	2025-07-13 22:18:32.270644	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 8, "y": 6, "playerId": 1}
1494	1	5	2025-07-13 22:18:32.270914	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 9, "y": 5, "playerId": 1}
1495	1	5	2025-07-13 22:18:32.271209	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 10, "y": 5, "playerId": 1}
1496	1	5	2025-07-13 22:18:32.271471	2025-07-13 22:23:32.27	\N	\N	map.movementAction	{"x": 11, "y": 5, "playerId": 1}
1497	1	5	2025-07-13 22:18:41.010979	2025-07-13 22:23:41.01	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1498	1	5	2025-07-13 22:18:41.01151	2025-07-13 22:23:41.01	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1499	1	5	2025-07-13 22:18:41.011958	2025-07-13 22:23:41.01	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1500	1	5	2025-07-13 22:18:41.012356	2025-07-13 22:23:41.01	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
1501	1	5	2025-07-13 22:18:41.012683	2025-07-13 22:23:41.01	\N	\N	map.movementAction	{"x": 6, "y": 3, "playerId": 1}
1502	1	5	2025-07-13 22:18:41.012997	2025-07-13 22:23:41.01	\N	\N	map.movementAction	{"x": 7, "y": 2, "playerId": 1}
1503	1	5	2025-07-13 22:18:45.021405	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1504	1	5	2025-07-13 22:18:45.021736	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1505	1	5	2025-07-13 22:18:45.021996	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1506	1	5	2025-07-13 22:18:45.022372	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1507	1	5	2025-07-13 22:18:45.022655	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1508	1	5	2025-07-13 22:18:45.02297	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1509	1	5	2025-07-13 22:18:45.023238	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1510	1	5	2025-07-13 22:18:45.023514	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1511	1	5	2025-07-13 22:18:45.023937	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 8, "y": 13, "playerId": 1}
1512	1	5	2025-07-13 22:18:45.024225	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 7, "y": 14, "playerId": 1}
1513	1	5	2025-07-13 22:18:45.024556	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 6, "y": 15, "playerId": 1}
1514	1	5	2025-07-13 22:18:45.024935	2025-07-13 22:23:45.02	\N	\N	map.movementAction	{"x": 5, "y": 16, "playerId": 1}
1515	1	5	2025-07-13 22:18:45.025226	2025-07-13 22:23:45.03	\N	\N	map.movementAction	{"x": 5, "y": 17, "playerId": 1}
1516	1	5	2025-07-13 22:18:49.188968	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1517	1	5	2025-07-13 22:18:49.189433	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1518	1	5	2025-07-13 22:18:49.189793	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1519	1	5	2025-07-13 22:18:49.190193	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 4, "y": 8, "playerId": 1}
1520	1	5	2025-07-13 22:18:49.190545	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 5, "y": 9, "playerId": 1}
1521	1	5	2025-07-13 22:18:49.190831	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 4, "y": 10, "playerId": 1}
1522	1	5	2025-07-13 22:18:49.191095	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 4, "y": 11, "playerId": 1}
1523	1	5	2025-07-13 22:18:49.19135	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 4, "y": 12, "playerId": 1}
1524	1	5	2025-07-13 22:18:49.1916	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 3, "y": 13, "playerId": 1}
1525	1	5	2025-07-13 22:18:49.19189	2025-07-13 22:23:49.19	\N	\N	map.movementAction	{"x": 3, "y": 14, "playerId": 1}
1526	1	5	2025-07-13 22:18:51.535291	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1527	1	5	2025-07-13 22:18:51.535843	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1528	1	5	2025-07-13 22:18:51.5362	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1529	1	5	2025-07-13 22:18:51.536606	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 4, "y": 8, "playerId": 1}
1530	1	5	2025-07-13 22:18:51.536909	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 5, "y": 9, "playerId": 1}
1531	1	5	2025-07-13 22:18:51.537162	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 4, "y": 10, "playerId": 1}
1532	1	5	2025-07-13 22:18:51.537432	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 4, "y": 11, "playerId": 1}
1533	1	5	2025-07-13 22:18:51.53773	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 4, "y": 12, "playerId": 1}
1534	1	5	2025-07-13 22:18:51.538054	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 3, "y": 13, "playerId": 1}
1535	1	5	2025-07-13 22:18:51.538516	2025-07-13 22:23:51.54	\N	\N	map.movementAction	{"x": 3, "y": 14, "playerId": 1}
1536	1	5	2025-07-13 22:18:55.202882	2025-07-13 22:23:55.2	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1537	1	5	2025-07-13 22:18:55.203621	2025-07-13 22:23:55.2	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1538	1	5	2025-07-13 22:18:55.204144	2025-07-13 22:23:55.2	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1539	1	5	2025-07-13 22:18:55.204593	2025-07-13 22:23:55.2	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1540	1	5	2025-07-13 22:18:55.204989	2025-07-13 22:23:55.2	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1541	1	5	2025-07-13 22:18:55.20542	2025-07-13 22:23:55.21	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1542	1	5	2025-07-13 22:18:55.205743	2025-07-13 22:23:55.21	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1543	1	5	2025-07-13 22:18:55.206014	2025-07-13 22:23:55.21	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1544	1	5	2025-07-13 22:18:55.206328	2025-07-13 22:23:55.21	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
1545	1	5	2025-07-13 22:18:55.207562	2025-07-13 22:23:55.21	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
1546	1	5	2025-07-13 22:18:55.208003	2025-07-13 22:23:55.21	\N	\N	map.movementAction	{"x": 11, "y": 11, "playerId": 1}
1547	1	5	2025-07-13 22:19:00.395162	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1548	1	5	2025-07-13 22:19:00.396085	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1549	1	5	2025-07-13 22:19:00.396591	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1550	1	5	2025-07-13 22:19:00.398571	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1551	1	5	2025-07-13 22:19:00.399669	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1552	1	5	2025-07-13 22:19:00.400333	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1553	1	5	2025-07-13 22:19:00.401423	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1554	1	5	2025-07-13 22:19:00.401977	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1555	1	5	2025-07-13 22:19:00.402378	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 8, "y": 13, "playerId": 1}
1556	1	5	2025-07-13 22:19:00.402833	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 7, "y": 14, "playerId": 1}
1557	1	5	2025-07-13 22:19:00.403234	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 8, "y": 15, "playerId": 1}
1558	1	5	2025-07-13 22:19:00.403576	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 8, "y": 16, "playerId": 1}
1559	1	5	2025-07-13 22:19:00.403941	2025-07-13 22:24:00.4	\N	\N	map.movementAction	{"x": 7, "y": 17, "playerId": 1}
1560	1	5	2025-07-14 23:18:52.299327	2025-07-14 23:23:52.3	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1561	1	5	2025-07-14 23:18:52.309084	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1562	1	5	2025-07-14 23:18:52.309542	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1563	1	5	2025-07-14 23:18:52.309888	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1564	1	5	2025-07-14 23:18:52.310185	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1565	1	5	2025-07-14 23:18:52.310488	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1566	1	5	2025-07-14 23:18:52.310821	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 7, "y": 11, "playerId": 1}
1567	1	5	2025-07-14 23:18:52.311119	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 8, "y": 12, "playerId": 1}
1568	1	5	2025-07-14 23:18:52.311409	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 9, "y": 12, "playerId": 1}
1569	1	5	2025-07-14 23:18:52.311694	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 10, "y": 11, "playerId": 1}
1570	1	5	2025-07-14 23:18:52.311971	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 11, "y": 12, "playerId": 1}
1571	1	5	2025-07-14 23:18:52.312243	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 12, "y": 12, "playerId": 1}
1572	1	5	2025-07-14 23:18:52.31251	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 13, "y": 12, "playerId": 1}
1573	1	5	2025-07-14 23:18:52.312776	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 14, "y": 13, "playerId": 1}
1574	1	5	2025-07-14 23:18:52.313106	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 15, "y": 12, "playerId": 1}
1575	1	5	2025-07-14 23:18:52.313513	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 16, "y": 12, "playerId": 1}
1576	1	5	2025-07-14 23:18:52.313846	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 17, "y": 11, "playerId": 1}
1577	1	5	2025-07-14 23:18:52.314141	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 18, "y": 12, "playerId": 1}
1578	1	5	2025-07-14 23:18:52.314427	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 19, "y": 13, "playerId": 1}
1579	1	5	2025-07-14 23:18:52.314782	2025-07-14 23:23:52.31	\N	\N	map.movementAction	{"x": 20, "y": 13, "playerId": 1}
1580	1	5	2025-07-14 23:18:52.315047	2025-07-14 23:23:52.32	\N	\N	map.movementAction	{"x": 21, "y": 14, "playerId": 1}
1581	1	5	2025-07-14 23:18:52.315333	2025-07-14 23:23:52.32	\N	\N	map.movementAction	{"x": 22, "y": 13, "playerId": 1}
1582	1	5	2025-07-14 23:18:52.315606	2025-07-14 23:23:52.32	\N	\N	map.movementAction	{"x": 23, "y": 14, "playerId": 1}
1583	1	5	2025-07-14 23:18:52.315917	2025-07-14 23:23:52.32	\N	\N	map.movementAction	{"x": 24, "y": 13, "playerId": 1}
1584	1	5	2025-07-14 23:18:52.316245	2025-07-14 23:23:52.32	\N	\N	map.movementAction	{"x": 25, "y": 14, "playerId": 1}
1585	1	5	2025-07-14 23:18:52.316566	2025-07-14 23:23:52.32	\N	\N	map.movementAction	{"x": 26, "y": 15, "playerId": 1}
1586	1	5	2025-07-14 23:18:52.317386	2025-07-14 23:23:52.32	\N	\N	map.movementAction	{"x": 27, "y": 15, "playerId": 1}
1587	1	5	2025-07-14 23:22:22.122626	2025-07-14 23:27:22.12	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1588	1	5	2025-07-14 23:22:22.12339	2025-07-14 23:27:22.12	\N	\N	map.movementAction	{"x": 2, "y": 2, "playerId": 1}
1589	1	5	2025-07-14 23:22:22.123817	2025-07-14 23:27:22.12	\N	\N	map.movementAction	{"x": 1, "y": 1, "playerId": 1}
1590	1	5	2025-07-14 23:22:28.622855	2025-07-14 23:27:28.62	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1591	1	5	2025-07-14 23:22:28.623277	2025-07-14 23:27:28.62	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1592	1	5	2025-07-14 23:22:28.623811	2025-07-14 23:27:28.62	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1593	1	5	2025-07-14 23:22:28.624194	2025-07-14 23:27:28.62	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
1594	1	5	2025-07-14 23:22:28.62452	2025-07-14 23:27:28.62	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1595	1	5	2025-07-14 23:22:28.624838	2025-07-14 23:27:28.62	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1596	1	5	2025-07-14 23:22:28.625174	2025-07-14 23:27:28.63	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1597	1	5	2025-07-14 23:22:28.625513	2025-07-14 23:27:28.63	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1598	1	5	2025-07-14 23:22:28.625858	2025-07-14 23:27:28.63	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1599	1	5	2025-07-14 23:22:28.626266	2025-07-14 23:27:28.63	\N	\N	map.movementAction	{"x": 10, "y": 7, "playerId": 1}
1600	1	5	2025-07-14 23:47:16.652942	2025-07-14 23:52:16.65	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1601	1	5	2025-07-14 23:47:16.656965	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1602	1	5	2025-07-14 23:47:16.657424	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1603	1	5	2025-07-14 23:47:16.657812	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1604	1	5	2025-07-14 23:47:16.658128	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1605	1	5	2025-07-14 23:47:16.65842	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 7, "y": 6, "playerId": 1}
1606	1	5	2025-07-14 23:47:16.658717	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 8, "y": 6, "playerId": 1}
1607	1	5	2025-07-14 23:47:16.658976	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 9, "y": 5, "playerId": 1}
1608	1	5	2025-07-14 23:47:16.659276	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 10, "y": 4, "playerId": 1}
1609	1	5	2025-07-14 23:47:16.65954	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 9, "y": 3, "playerId": 1}
1610	1	5	2025-07-14 23:47:16.659822	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 10, "y": 2, "playerId": 1}
1611	1	5	2025-07-14 23:47:16.660079	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 11, "y": 1, "playerId": 1}
1612	1	5	2025-07-14 23:47:16.660573	2025-07-14 23:52:16.66	\N	\N	map.movementAction	{"x": 12, "y": 1, "playerId": 1}
1613	1	5	2025-07-20 23:27:30.92984	2025-07-20 23:32:30.93	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1614	1	5	2025-07-20 23:27:30.937738	2025-07-20 23:32:30.94	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1615	1	5	2025-07-20 23:27:30.938063	2025-07-20 23:32:30.94	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1616	1	5	2025-07-20 23:27:30.938382	2025-07-20 23:32:30.94	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1617	1	5	2025-07-20 23:27:30.938668	2025-07-20 23:32:30.94	\N	\N	map.movementAction	{"x": 6, "y": 9, "playerId": 1}
1618	1	5	2025-07-20 23:27:30.938927	2025-07-20 23:32:30.94	\N	\N	map.movementAction	{"x": 7, "y": 10, "playerId": 1}
1619	1	5	2025-07-20 23:27:30.93918	2025-07-20 23:32:30.94	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1620	1	5	2025-07-20 23:27:30.939466	2025-07-20 23:32:30.94	\N	\N	map.movementAction	{"x": 9, "y": 10, "playerId": 1}
1621	1	5	2025-07-20 23:27:39.936648	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1622	1	5	2025-07-20 23:27:39.93726	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1623	1	5	2025-07-20 23:27:39.93774	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1624	1	5	2025-07-20 23:27:39.938075	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 5, "y": 7, "playerId": 1}
1625	1	5	2025-07-20 23:27:39.938407	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 6, "y": 8, "playerId": 1}
1626	1	5	2025-07-20 23:27:39.938702	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 7, "y": 9, "playerId": 1}
1627	1	5	2025-07-20 23:27:39.939004	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 8, "y": 9, "playerId": 1}
1628	1	5	2025-07-20 23:27:39.93927	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 9, "y": 9, "playerId": 1}
1629	1	5	2025-07-20 23:27:39.940183	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 10, "y": 8, "playerId": 1}
1630	1	5	2025-07-20 23:27:39.940432	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 11, "y": 8, "playerId": 1}
1631	1	5	2025-07-20 23:27:39.940678	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 12, "y": 7, "playerId": 1}
1632	1	5	2025-07-20 23:27:39.940936	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 13, "y": 7, "playerId": 1}
1633	1	5	2025-07-20 23:27:39.941221	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 14, "y": 8, "playerId": 1}
1634	1	5	2025-07-20 23:27:39.941511	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 15, "y": 7, "playerId": 1}
1635	1	5	2025-07-20 23:27:39.941768	2025-07-20 23:32:39.94	\N	\N	map.movementAction	{"x": 16, "y": 7, "playerId": 1}
1636	1	5	2025-07-20 23:31:10.494749	2025-07-20 23:36:10.49	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1637	1	5	2025-07-20 23:31:10.495762	2025-07-20 23:36:10.5	\N	\N	map.movementAction	{"x": 3, "y": 2, "playerId": 1}
1638	1	5	2025-07-20 23:31:10.496072	2025-07-20 23:36:10.5	\N	\N	map.movementAction	{"x": 4, "y": 3, "playerId": 1}
1639	1	5	2025-07-20 23:31:10.496369	2025-07-20 23:36:10.5	\N	\N	map.movementAction	{"x": 5, "y": 2, "playerId": 1}
1640	1	5	2025-07-20 23:31:10.496703	2025-07-20 23:36:10.5	\N	\N	map.movementAction	{"x": 6, "y": 2, "playerId": 1}
1641	1	5	2025-07-20 23:40:12.277423	2025-07-20 23:45:12.28	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1642	1	5	2025-07-20 23:40:12.278798	2025-07-20 23:45:12.28	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1643	1	5	2025-07-20 23:40:12.279106	2025-07-20 23:45:12.28	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1644	1	5	2025-07-20 23:40:12.279393	2025-07-20 23:45:12.28	\N	\N	map.movementAction	{"x": 5, "y": 8, "playerId": 1}
1645	1	5	2025-07-20 23:40:16.953749	2025-07-20 23:45:16.95	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1646	1	5	2025-07-20 23:40:16.954193	2025-07-20 23:45:16.95	\N	\N	map.movementAction	{"x": 3, "y": 2, "playerId": 1}
1647	1	5	2025-07-20 23:40:16.954463	2025-07-20 23:45:16.95	\N	\N	map.movementAction	{"x": 4, "y": 3, "playerId": 1}
1648	1	5	2025-07-20 23:40:16.954684	2025-07-20 23:45:16.95	\N	\N	map.movementAction	{"x": 5, "y": 2, "playerId": 1}
1649	1	5	2025-07-20 23:40:16.954902	2025-07-20 23:45:16.95	\N	\N	map.movementAction	{"x": 6, "y": 1, "playerId": 1}
1650	1	5	2025-07-20 23:40:16.955169	2025-07-20 23:45:16.96	\N	\N	map.movementAction	{"x": 7, "y": 1, "playerId": 1}
1651	1	5	2025-07-27 12:11:41.556241	2025-07-27 12:16:41.56	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1652	1	5	2025-07-27 12:11:41.567958	2025-07-27 12:16:41.57	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1653	1	5	2025-07-27 12:11:41.568405	2025-07-27 12:16:41.57	\N	\N	map.movementAction	{"x": 4, "y": 6, "playerId": 1}
1654	1	5	2025-07-27 12:11:41.5688	2025-07-27 12:16:41.57	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1655	1	5	2025-07-27 12:11:41.569141	2025-07-27 12:16:41.57	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1656	1	5	2025-07-27 12:11:53.348263	2025-07-27 12:16:53.35	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1657	1	5	2025-07-27 12:11:53.348705	2025-07-27 12:16:53.35	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1658	1	5	2025-07-27 12:11:53.349332	2025-07-27 12:16:53.35	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1659	1	5	2025-07-27 12:11:53.349937	2025-07-27 12:16:53.35	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
1660	1	5	2025-07-27 12:11:53.350518	2025-07-27 12:16:53.35	\N	\N	map.movementAction	{"x": 6, "y": 3, "playerId": 1}
1661	1	5	2025-07-27 12:15:52.747379	2025-07-27 12:20:52.75	\N	\N	map.movementAction	{"x": 2, "y": 3, "playerId": 1}
1662	1	5	2025-07-27 12:15:52.748917	2025-07-27 12:20:52.75	\N	\N	map.movementAction	{"x": 3, "y": 2, "playerId": 1}
1663	1	5	2025-07-27 12:15:52.749406	2025-07-27 12:20:52.75	\N	\N	map.movementAction	{"x": 4, "y": 3, "playerId": 1}
1664	1	5	2025-07-27 12:15:52.749704	2025-07-27 12:20:52.75	\N	\N	map.movementAction	{"x": 5, "y": 2, "playerId": 1}
1665	1	5	2025-07-27 12:15:52.749998	2025-07-27 12:20:52.75	\N	\N	map.movementAction	{"x": 6, "y": 1, "playerId": 1}
1666	1	5	2025-07-27 12:15:52.750304	2025-07-27 12:20:52.75	\N	\N	map.movementAction	{"x": 7, "y": 1, "playerId": 1}
1667	1	5	2025-07-27 15:18:06.903676	2025-07-27 15:23:06.9	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1668	1	5	2025-07-27 15:18:06.907835	2025-07-27 15:23:06.91	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1669	1	5	2025-07-27 15:18:06.908207	2025-07-27 15:23:06.91	\N	\N	map.movementAction	{"x": 4, "y": 7, "playerId": 1}
1670	1	5	2025-07-27 15:18:06.908568	2025-07-27 15:23:06.91	\N	\N	map.movementAction	{"x": 5, "y": 6, "playerId": 1}
1671	1	5	2025-07-27 15:18:06.908856	2025-07-27 15:23:06.91	\N	\N	map.movementAction	{"x": 6, "y": 6, "playerId": 1}
1672	1	5	2025-07-27 15:18:06.909163	2025-07-27 15:23:06.91	\N	\N	map.movementAction	{"x": 7, "y": 7, "playerId": 1}
1673	1	1	2025-11-12 21:34:43.067014	2025-11-12 21:39:43.07	\N	\N	map.movementAction	{"x": 2, "y": 5, "playerId": 1}
1674	1	1	2025-11-12 21:34:43.078174	2025-11-12 21:39:43.08	\N	\N	map.movementAction	{"x": 3, "y": 6, "playerId": 1}
1675	1	1	2025-11-12 21:34:43.078517	2025-11-12 21:39:43.08	\N	\N	map.movementAction	{"x": 4, "y": 5, "playerId": 1}
1676	1	1	2025-11-12 21:34:43.0788	2025-11-12 21:39:43.08	\N	\N	map.movementAction	{"x": 5, "y": 4, "playerId": 1}
1677	1	1	2025-11-12 21:34:43.079621	2025-11-12 21:39:43.08	\N	\N	map.movementAction	{"x": 6, "y": 4, "playerId": 1}
1678	1	1	2025-11-12 21:34:43.079932	2025-11-12 21:39:43.08	\N	\N	map.movementAction	{"x": 7, "y": 3, "playerId": 1}
1	1	5	2025-06-01 00:53:34.454705	2025-06-01 00:58:34.45	\N	\N	world.movmentAction	{"x": 2, "y": 4, "playerId": 1}
217	1	5	2025-06-03 23:46:39.153786	2025-06-03 23:51:39.15	\N	\N	world.movmentAction	{"x": 14, "y": 13, "playerId": 1}
\.


--
-- TOC entry 5408 (class 0 OID 30916)
-- Dependencies: 244
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
-- TOC entry 5409 (class 0 OID 30924)
-- Dependencies: 245
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
-- TOC entry 5453 (class 0 OID 31103)
-- Dependencies: 289
-- Data for Name: map_tiles_players_positions; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.map_tiles_players_positions (player_id, map_id, map_tile_x, map_tile_y) FROM stdin;
1	1	3	3
2	1	3	4
\.


--
-- TOC entry 5454 (class 0 OID 31110)
-- Dependencies: 290
-- Data for Name: maps; Type: TABLE DATA; Schema: world; Owner: postgres
--

COPY world.maps (id, name) FROM stdin;
1	NowaMapa
\.


--
-- TOC entry 5410 (class 0 OID 30938)
-- Dependencies: 246
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
-- TOC entry 5510 (class 0 OID 0)
-- Dependencies: 247
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.abilities_id_seq', 2, true);


--
-- TOC entry 5511 (class 0 OID 0)
-- Dependencies: 250
-- Name: player_abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_abilities_id_seq', 2, true);


--
-- TOC entry 5512 (class 0 OID 0)
-- Dependencies: 252
-- Name: player_skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_skills_id_seq', 3, true);


--
-- TOC entry 5513 (class 0 OID 0)
-- Dependencies: 254
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.player_stats_id_seq', 14, true);


--
-- TOC entry 5514 (class 0 OID 0)
-- Dependencies: 255
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.roles_id_seq', 1, false);


--
-- TOC entry 5515 (class 0 OID 0)
-- Dependencies: 256
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.skills_id_seq', 3, true);


--
-- TOC entry 5516 (class 0 OID 0)
-- Dependencies: 257
-- Name: stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.stats_id_seq', 7, true);


--
-- TOC entry 5517 (class 0 OID 0)
-- Dependencies: 259
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.accounts_id_seq', 1, false);


--
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 261
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.sessions_id_seq', 1, false);


--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 263
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_id_seq', 1, false);


--
-- TOC entry 5520 (class 0 OID 0)
-- Dependencies: 266
-- Name: building_types_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.building_types_id_seq', 1, false);


--
-- TOC entry 5521 (class 0 OID 0)
-- Dependencies: 267
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: buildings; Owner: postgres
--

SELECT pg_catalog.setval('buildings.buildings_id_seq', 1, false);


--
-- TOC entry 5522 (class 0 OID 0)
-- Dependencies: 268
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: cities; Owner: postgres
--

SELECT pg_catalog.setval('cities.cities_id_seq', 1, false);


--
-- TOC entry 5523 (class 0 OID 0)
-- Dependencies: 271
-- Name: district_types_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.district_types_id_seq', 1, false);


--
-- TOC entry 5524 (class 0 OID 0)
-- Dependencies: 272
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: districts; Owner: postgres
--

SELECT pg_catalog.setval('districts.districts_id_seq', 1, false);


--
-- TOC entry 5525 (class 0 OID 0)
-- Dependencies: 277
-- Name: inventory_containers_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_containers_id_seq', 1, false);


--
-- TOC entry 5526 (class 0 OID 0)
-- Dependencies: 279
-- Name: inventory_slots_id_seq; Type: SEQUENCE SET; Schema: inventory; Owner: postgres
--

SELECT pg_catalog.setval('inventory.inventory_slots_id_seq', 1, false);


--
-- TOC entry 5527 (class 0 OID 0)
-- Dependencies: 280
-- Name: item_stats_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_stats_id_seq', 1, false);


--
-- TOC entry 5528 (class 0 OID 0)
-- Dependencies: 281
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.items_id_seq', 1, false);


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 283
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.players_id_seq', 2, true);


--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 285
-- Name: status_types_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.status_types_id_seq', 1, false);


--
-- TOC entry 5531 (class 0 OID 0)
-- Dependencies: 287
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.tasks_id_seq', 1, false);


--
-- TOC entry 5532 (class 0 OID 0)
-- Dependencies: 288
-- Name: landscape_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.landscape_types_id_seq', 1, false);


--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 291
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.maps_id_seq', 1, false);


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 292
-- Name: terrain_types_id_seq; Type: SEQUENCE SET; Schema: world; Owner: postgres
--

SELECT pg_catalog.setval('world.terrain_types_id_seq', 1, false);


--
-- TOC entry 5127 (class 2606 OID 31126)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5160 (class 2606 OID 31128)
-- Name: ability_skill_requirements ability_skill_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_pkey PRIMARY KEY (ability_id, skill_id);


--
-- TOC entry 5162 (class 2606 OID 31130)
-- Name: ability_stat_requirements ability_stat_requirements_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_pkey PRIMARY KEY (ability_id, stat_id);


--
-- TOC entry 5129 (class 2606 OID 31132)
-- Name: player_abilities player_abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 5164 (class 2606 OID 31134)
-- Name: player_skills player_skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5166 (class 2606 OID 31136)
-- Name: player_stats player_stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5131 (class 2606 OID 31138)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 5133 (class 2606 OID 31140)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 5135 (class 2606 OID 31142)
-- Name: stats stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5168 (class 2606 OID 31144)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 5170 (class 2606 OID 31146)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5172 (class 2606 OID 31148)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5174 (class 2606 OID 31150)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5176 (class 2606 OID 31152)
-- Name: verification_token verification_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.verification_token
    ADD CONSTRAINT verification_token_pkey PRIMARY KEY (identifier, token);


--
-- TOC entry 5178 (class 2606 OID 31154)
-- Name: building_roles building_owners_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_owners_pkey PRIMARY KEY (building_id, player_id, role_id);


--
-- TOC entry 5137 (class 2606 OID 31156)
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5139 (class 2606 OID 31158)
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- TOC entry 5141 (class 2606 OID 31160)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 5180 (class 2606 OID 31162)
-- Name: city_roles city_owners_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_roles
    ADD CONSTRAINT city_owners_pkey PRIMARY KEY (city_id, player_id, role_id);


--
-- TOC entry 5144 (class 2606 OID 31164)
-- Name: city_tiles city_tiles_pkey; Type: CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.city_tiles
    ADD CONSTRAINT city_tiles_pkey PRIMARY KEY (city_id, x, y);


--
-- TOC entry 5182 (class 2606 OID 31166)
-- Name: district_roles district_owners_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_owners_pkey PRIMARY KEY (district_id, player_id, role_id);


--
-- TOC entry 5146 (class 2606 OID 31168)
-- Name: district_types district_types_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_types
    ADD CONSTRAINT district_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5148 (class 2606 OID 31170)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 5184 (class 2606 OID 31172)
-- Name: inventory_container_building inventory_container_building_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_building
    ADD CONSTRAINT inventory_container_building_pkey PRIMARY KEY (inventory_container_id);


--
-- TOC entry 5186 (class 2606 OID 31174)
-- Name: inventory_container_district inventory_container_district_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_district
    ADD CONSTRAINT inventory_container_district_pkey PRIMARY KEY (inventory_container_id);


--
-- TOC entry 5188 (class 2606 OID 31176)
-- Name: inventory_container_player inventory_container_player_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_player
    ADD CONSTRAINT inventory_container_player_pkey PRIMARY KEY (inventory_container_id);


--
-- TOC entry 5190 (class 2606 OID 31178)
-- Name: inventory_containers inventory_containers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_containers
    ADD CONSTRAINT inventory_containers_pkey PRIMARY KEY (id);


--
-- TOC entry 5192 (class 2606 OID 31180)
-- Name: inventory_slots inventory_slots_pkey; Type: CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 5150 (class 2606 OID 31182)
-- Name: item_stats item_stats_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 5152 (class 2606 OID 31184)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 5195 (class 2606 OID 31186)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 5197 (class 2606 OID 31188)
-- Name: status_types status_types_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types
    ADD CONSTRAINT status_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5199 (class 2606 OID 31190)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 5154 (class 2606 OID 31192)
-- Name: landscape_types landscape_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.landscape_types
    ADD CONSTRAINT landscape_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5156 (class 2606 OID 31194)
-- Name: map_tiles map_tiles_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_pkey PRIMARY KEY (map_id, x, y);


--
-- TOC entry 5201 (class 2606 OID 31196)
-- Name: map_tiles_players_positions map_tiles_players_positions_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_pkey PRIMARY KEY (player_id, map_tile_x, map_tile_y);


--
-- TOC entry 5203 (class 2606 OID 31198)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- TOC entry 5158 (class 2606 OID 31200)
-- Name: terrain_types terrain_types_pkey; Type: CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.terrain_types
    ADD CONSTRAINT terrain_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5142 (class 1259 OID 31201)
-- Name: unique_city_position; Type: INDEX; Schema: cities; Owner: postgres
--

CREATE UNIQUE INDEX unique_city_position ON cities.cities USING btree (map_tile_x, map_tile_y);


--
-- TOC entry 5193 (class 1259 OID 31202)
-- Name: one_active_player_per_user; Type: INDEX; Schema: players; Owner: postgres
--

CREATE UNIQUE INDEX one_active_player_per_user ON players.players USING btree (user_id) WHERE (is_active = true);


--
-- TOC entry 5219 (class 2606 OID 31203)
-- Name: ability_skill_requirements ability_skill_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5220 (class 2606 OID 31208)
-- Name: ability_skill_requirements ability_skill_requirements_skill_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_skill_requirements
    ADD CONSTRAINT ability_skill_requirements_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5221 (class 2606 OID 31213)
-- Name: ability_stat_requirements ability_stat_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5222 (class 2606 OID 31218)
-- Name: ability_stat_requirements ability_stat_requirements_stat_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_stat_requirements
    ADD CONSTRAINT ability_stat_requirements_stat_id_fkey FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5204 (class 2606 OID 31223)
-- Name: player_abilities player_abilities_abilities_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_abilities_fk FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


--
-- TOC entry 5205 (class 2606 OID 31228)
-- Name: player_abilities player_abilities_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_abilities
    ADD CONSTRAINT player_abilities_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5223 (class 2606 OID 31233)
-- Name: player_skills player_skills_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5224 (class 2606 OID 31238)
-- Name: player_skills player_skills_skills_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_skills
    ADD CONSTRAINT player_skills_skills_fk FOREIGN KEY (skill_id) REFERENCES attributes.skills(id);


--
-- TOC entry 5225 (class 2606 OID 31243)
-- Name: player_stats player_stats_players_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5226 (class 2606 OID 31248)
-- Name: player_stats player_stats_stats_fk; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.player_stats
    ADD CONSTRAINT player_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5227 (class 2606 OID 31253)
-- Name: accounts accounts_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_users_fk FOREIGN KEY ("userId") REFERENCES auth.users(id);


--
-- TOC entry 5228 (class 2606 OID 31258)
-- Name: sessions sessions_users_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_users_fk FOREIGN KEY (id) REFERENCES auth.users(id);


--
-- TOC entry 5229 (class 2606 OID 31263)
-- Name: building_roles building_roles_buildings_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_buildings_fk FOREIGN KEY (building_id) REFERENCES buildings.buildings(id);


--
-- TOC entry 5230 (class 2606 OID 31268)
-- Name: building_roles building_roles_players_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5231 (class 2606 OID 31273)
-- Name: building_roles building_roles_roles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.building_roles
    ADD CONSTRAINT building_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5206 (class 2606 OID 31278)
-- Name: buildings buildings_building_types_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_building_types_fk FOREIGN KEY (building_type_id) REFERENCES buildings.building_types(id);


--
-- TOC entry 5207 (class 2606 OID 31283)
-- Name: buildings buildings_cities_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_cities_fk FOREIGN KEY (city_id) REFERENCES cities.cities(id);


--
-- TOC entry 5208 (class 2606 OID 31288)
-- Name: buildings buildings_city_tiles_fk; Type: FK CONSTRAINT; Schema: buildings; Owner: postgres
--

ALTER TABLE ONLY buildings.buildings
    ADD CONSTRAINT buildings_city_tiles_fk FOREIGN KEY (city_id, city_tile_x, city_tile_y) REFERENCES cities.city_tiles(city_id, x, y);


--
-- TOC entry 5209 (class 2606 OID 31293)
-- Name: cities cities_map_tiles_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5210 (class 2606 OID 31298)
-- Name: cities cities_maps_fk; Type: FK CONSTRAINT; Schema: cities; Owner: postgres
--

ALTER TABLE ONLY cities.cities
    ADD CONSTRAINT cities_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5232 (class 2606 OID 31303)
-- Name: district_roles district_roles_districts_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_districts_fk FOREIGN KEY (district_id) REFERENCES districts.districts(id);


--
-- TOC entry 5233 (class 2606 OID 31308)
-- Name: district_roles district_roles_players_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5234 (class 2606 OID 31313)
-- Name: district_roles district_roles_roles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.district_roles
    ADD CONSTRAINT district_roles_roles_fk FOREIGN KEY (role_id) REFERENCES attributes.roles(id);


--
-- TOC entry 5211 (class 2606 OID 31318)
-- Name: districts districts_district_types_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_district_types_fk FOREIGN KEY (district_type_id) REFERENCES districts.district_types(id);


--
-- TOC entry 5212 (class 2606 OID 31323)
-- Name: districts districts_map_tiles_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5213 (class 2606 OID 31328)
-- Name: districts districts_maps_fk; Type: FK CONSTRAINT; Schema: districts; Owner: postgres
--

ALTER TABLE ONLY districts.districts
    ADD CONSTRAINT districts_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5235 (class 2606 OID 31333)
-- Name: inventory_container_building inventory_container_building_buildings_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_building
    ADD CONSTRAINT inventory_container_building_buildings_fk FOREIGN KEY (building_id) REFERENCES buildings.buildings(id);


--
-- TOC entry 5236 (class 2606 OID 31338)
-- Name: inventory_container_building inventory_container_building_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_building
    ADD CONSTRAINT inventory_container_building_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5237 (class 2606 OID 31343)
-- Name: inventory_container_district inventory_container_district_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_district
    ADD CONSTRAINT inventory_container_district_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5238 (class 2606 OID 31348)
-- Name: inventory_container_district inventory_container_district_districts_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_district
    ADD CONSTRAINT inventory_container_district_districts_fk FOREIGN KEY (district_id) REFERENCES districts.districts(id);


--
-- TOC entry 5239 (class 2606 OID 31353)
-- Name: inventory_container_player inventory_container_player_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_player
    ADD CONSTRAINT inventory_container_player_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5240 (class 2606 OID 31358)
-- Name: inventory_container_player inventory_container_player_players_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_container_player
    ADD CONSTRAINT inventory_container_player_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5241 (class 2606 OID 31363)
-- Name: inventory_slots inventory_slots_inventory_container_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_container_id_fkey FOREIGN KEY (inventory_container_id) REFERENCES inventory.inventory_containers(id) ON DELETE CASCADE;


--
-- TOC entry 5242 (class 2606 OID 31368)
-- Name: inventory_slots inventory_slots_items_fk; Type: FK CONSTRAINT; Schema: inventory; Owner: postgres
--

ALTER TABLE ONLY inventory.inventory_slots
    ADD CONSTRAINT inventory_slots_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5214 (class 2606 OID 31373)
-- Name: item_stats item_stats_items_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_items_fk FOREIGN KEY (item_id) REFERENCES items.items(id);


--
-- TOC entry 5215 (class 2606 OID 31378)
-- Name: item_stats item_stats_stats_fk; Type: FK CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_stats_fk FOREIGN KEY (stat_id) REFERENCES attributes.stats(id);


--
-- TOC entry 5216 (class 2606 OID 31383)
-- Name: map_tiles map_tiles_landscape_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_landscape_types_fk FOREIGN KEY (landscape_type_id) REFERENCES world.landscape_types(id);


--
-- TOC entry 5217 (class 2606 OID 31388)
-- Name: map_tiles map_tiles_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5243 (class 2606 OID 31393)
-- Name: map_tiles_players_positions map_tiles_players_positions_map_tiles_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_map_tiles_fk FOREIGN KEY (map_id, map_tile_x, map_tile_y) REFERENCES world.map_tiles(map_id, x, y);


--
-- TOC entry 5244 (class 2606 OID 31398)
-- Name: map_tiles_players_positions map_tiles_players_positions_maps_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_maps_fk FOREIGN KEY (map_id) REFERENCES world.maps(id);


--
-- TOC entry 5245 (class 2606 OID 31403)
-- Name: map_tiles_players_positions map_tiles_players_positions_players_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_players_fk FOREIGN KEY (player_id) REFERENCES players.players(id);


--
-- TOC entry 5218 (class 2606 OID 31408)
-- Name: map_tiles map_tiles_terrain_types_fk; Type: FK CONSTRAINT; Schema: world; Owner: postgres
--

ALTER TABLE ONLY world.map_tiles
    ADD CONSTRAINT map_tiles_terrain_types_fk FOREIGN KEY (terrain_type_id) REFERENCES world.terrain_types(id);


-- Completed on 2026-01-23 15:39:34

--
-- PostgreSQL database dump complete
--

\unrestrict VSSDwMtKutxR5vhbTY4NueHSB9HZjPkJiwGCNMI3yoKHhhMwEU0uWPQDbwTG5eh

