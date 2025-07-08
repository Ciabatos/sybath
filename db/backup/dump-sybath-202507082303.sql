--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-07-08 23:03:40

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
-- TOC entry 10 (class 2615 OID 17193)
-- Name: attributes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA attributes;


ALTER SCHEMA attributes OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 16389)
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 17178)
-- Name: items; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA items;


ALTER SCHEMA items OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 16521)
-- Name: map; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA map;


ALTER SCHEMA map OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 16629)
-- Name: players; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA players;


ALTER SCHEMA players OWNER TO postgres;

--
-- TOC entry 11 (class 2615 OID 17283)
-- Name: tasks; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tasks;


ALTER SCHEMA tasks OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 16520)
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
-- TOC entry 304 (class 1255 OID 16902)
-- Name: add_item_to_inventory(integer, integer, integer); Type: PROCEDURE; Schema: items; Owner: postgres
--

CREATE PROCEDURE items.add_item_to_inventory(IN p_player_id integer, IN p_item_id integer, IN p_quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

WITH updated_row AS (
		SELECT
              T2.row
              ,T2.col
              ,T2.inventory_container_id
              ,T2.item_id
              ,T2.quantity
              FROM players.inventory_containers T1
              JOIN players.inventory_slots T2 ON T2.inventory_container_id= T1.id
			  WHERE T1.player_id = p_player_id
			  AND T2.item_id IS NULL
			  ORDER BY  T2.row ASC, T2.col ASC
			  LIMIT 1

	)

	UPDATE players.inventory_slots T1
SET item_id = p_item_id, 
    quantity = COALESCE(T1.quantity, 0) +  p_quantity
FROM updated_row
WHERE T1.inventory_container_id = updated_row.inventory_container_id
  AND T1.row = updated_row.row
  AND T1.col = updated_row.col;

	
    COMMIT;
END;
$$;


ALTER PROCEDURE items.add_item_to_inventory(IN p_player_id integer, IN p_item_id integer, IN p_quantity integer) OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 17258)
-- Name: building_inventory(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.building_inventory(p_player_id integer, p_building_id integer) RETURNS TABLE("row" integer, col integer, inventory_container_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN QUERY
  
		SELECT 
              T4.row
              ,T4.col
              ,T4.inventory_container_id
              ,T4.item_id
			  ,T5.name
              ,T4.quantity
              FROM items.inventory_container_roles T1
			  JOIN items.inventory_containers T2 ON T2.id = T1.inventory_container_id
			  JOIN items.inventory_container_types T3 ON T3.id = T2.type_id
              JOIN items.inventory_slots T4 ON T4.inventory_container_id= T2.id
			  LEFT JOIN items.items T5 ON T4.item_id = T5.id
		WHERE T1.player_id = p_player_id
		AND T3.id = 2 -- BUILDING
		AND T2.entity_id = p_building_id
		ORDER BY T4.ROW, T4.COL; 

	
END;
$$;


ALTER FUNCTION items.building_inventory(p_player_id integer, p_building_id integer) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 17259)
-- Name: district_inventory(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.district_inventory(p_player_id integer, p_district_id integer) RETURNS TABLE("row" integer, col integer, inventory_container_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN QUERY
  
		SELECT 
              T4.row
              ,T4.col
              ,T4.inventory_container_id
              ,T4.item_id
			  ,T5.name
              ,T4.quantity
              FROM items.inventory_container_roles T1
			  JOIN items.inventory_containers T2 ON T2.id = T1.inventory_container_id
			  JOIN items.inventory_container_types T3 ON T3.id = T2.type_id
              JOIN items.inventory_slots T4 ON T4.inventory_container_id= T2.id
			  LEFT JOIN items.items T5 ON T4.item_id = T5.id
		WHERE T1.player_id = p_player_id
		AND T3.id = 3 -- DISTRICT
		AND T2.entity_id = p_district_id
		ORDER BY T4.ROW, T4.COL; 

	
END;
$$;


ALTER FUNCTION items.district_inventory(p_player_id integer, p_district_id integer) OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 17260)
-- Name: other_player_inventory(integer, integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.other_player_inventory(p_player_id integer, p_other_player_id integer) RETURNS TABLE("row" integer, col integer, inventory_container_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN QUERY
  
		SELECT 
              T4.row
              ,T4.col
              ,T4.inventory_container_id
              ,T4.item_id
			  ,T5.name
              ,T4.quantity
              FROM items.inventory_container_roles T1
			  JOIN items.inventory_containers T2 ON T2.id = T1.inventory_container_id
			  JOIN items.inventory_container_types T3 ON T3.id = T2.type_id
              JOIN items.inventory_slots T4 ON T4.inventory_container_id= T2.id
			  LEFT JOIN items.items T5 ON T4.item_id = T5.id
		WHERE T1.player_id = p_other_player_id
		AND T3.id = 1 -- PLAYER
		AND T2.entity_id = p_district_id
		ORDER BY T4.ROW, T4.COL; 

	
END;
$$;


ALTER FUNCTION items.other_player_inventory(p_player_id integer, p_other_player_id integer) OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 17206)
-- Name: player_inventory(integer); Type: FUNCTION; Schema: items; Owner: postgres
--

CREATE FUNCTION items.player_inventory(p_player_id integer) RETURNS TABLE("row" integer, col integer, inventory_container_id integer, item_id integer, name character varying, quantity integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN QUERY
  
		SELECT 
              T4.row
              ,T4.col
              ,T4.inventory_container_id
              ,T4.item_id
			  ,T5.name
              ,T4.quantity
              FROM items.inventory_container_roles T1
			  JOIN items.inventory_containers T2 ON T2.id = T1.inventory_container_id
			  JOIN items.inventory_container_types T3 ON T3.id = T2.type_id
              JOIN items.inventory_slots T4 ON T4.inventory_container_id= T2.id
			  LEFT JOIN items.items T5 ON T4.item_id = T5.id
		WHERE T1.player_id = p_player_id
		AND T3.id = 1
		ORDER BY T4.ROW, T4.COL; -- PLAYER

	
END;
$$;


ALTER FUNCTION items.player_inventory(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 16725)
-- Name: choose_terrain_based_on_neighbors(integer[], integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: map; Owner: postgres
--

CREATE FUNCTION map.choose_terrain_based_on_neighbors(terrain_grid integer[], x integer, y integer, width integer, height integer, upper1 integer, lower1 integer) RETURNS integer
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


ALTER FUNCTION map.choose_terrain_based_on_neighbors(terrain_grid integer[], x integer, y integer, width integer, height integer, upper1 integer, lower1 integer) OWNER TO postgres;

--
-- TOC entry 303 (class 1255 OID 17030)
-- Name: city_insert(integer, integer, character varying); Type: PROCEDURE; Schema: map; Owner: postgres
--

CREATE PROCEDURE map.city_insert(IN p_map_tile_x integer, IN p_map_tile_y integer, IN p_map_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_city_id INT;
    width INT := 10;
    height INT := 10;
	
    countW INT := 1;
    countH INT := 1;

    p_terrain_type_id INT := (SELECT terrain_type_id FROM map.map_tiles WHERE X = p_map_tile_x AND Y = p_map_tile_y );

BEGIN

	INSERT INTO map.cities(	map_tile_x, map_tile_y, name, move_cost, image_url)
	VALUES (p_map_tile_x, p_map_tile_y, p_map_name, 1, 'City_1.png')
	RETURNING id INTO new_city_id;

    WHILE countH <= width LOOP
        WHILE countW <= height LOOP

INSERT INTO map.city_tiles(	city_id, x, y, terrain_type_id, landscape_type_id)
VALUES (new_city_id, countW, countH, p_terrain_type_id, NULL);

			countW := countW + 1;    
        END LOOP;
        
        countH := countH + 1;
        countW := 1;
    END LOOP;
END;
$$;


ALTER PROCEDURE map.city_insert(IN p_map_tile_x integer, IN p_map_tile_y integer, IN p_map_name character varying) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 16579)
-- Name: map_delete(); Type: PROCEDURE; Schema: map; Owner: postgres
--

CREATE PROCEDURE map.map_delete()
    LANGUAGE plpgsql
    AS $$

BEGIN
TRUNCATE TABLE map.maps RESTART IDENTITY CASCADE;

TRUNCATE TABLE map.map_tiles RESTART IDENTITY CASCADE;
   
END;
$$;


ALTER PROCEDURE map.map_delete() OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 16577)
-- Name: map_insert(); Type: PROCEDURE; Schema: map; Owner: postgres
--

CREATE PROCEDURE map.map_insert()
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_map_id INT;
    width INT := 30;
    height INT := 30;
	
    countW INT := 1;
    countH INT := 1;

    upper1 INT := (SELECT MAX(id) FROM map.terrain_types);
    lower1 INT := 1;
	random1 INT := 1;
	random2 INT := NULL;

	terrain_grid INT[][] := array_fill(0, ARRAY[width, height]);
BEGIN

    INSERT INTO map.maps (name)
    VALUES ('NowaMapa')
    RETURNING id INTO new_map_id;

    WHILE countH <= width LOOP
        WHILE countW <= height LOOP

            IF countW = 1 AND countH = 1 THEN
                random1 := floor((upper1 - lower1 + 1) * random() + lower1);
            ELSE
               random1 := map.choose_terrain_based_on_neighbors(terrain_grid, countW, countH, width, height, upper1, lower1);
            END IF;

            --random1 := floor((upper1 - lower1 + 1) * random() + lower1);
			     terrain_grid[countW][countH] := random1;

			
        	random2 := map.random_landscape_types(random1);

            INSERT INTO map.map_tiles (
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


ALTER PROCEDURE map.map_insert() OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 17344)
-- Name: movement_action_in_process(integer); Type: FUNCTION; Schema: map; Owner: postgres
--

CREATE FUNCTION map.movement_action_in_process(p_player_id integer) RETURNS TABLE(scheduled_at timestamp with time zone, method_parameters jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM tasks.tasks
        WHERE method_name = 'map.movmentAction'
          AND status IN (1, 2)
          AND player_id = p_player_id
    ) THEN

        -- Jeśli są, wykonaj oba SELECT-y
        RETURN QUERY
        SELECT
            NULL::timestamp AS scheduled_at,
            jsonb_build_object(
                'x', map_tile_x,
                'y', map_tile_y,
                'playerId', player_id
            ) AS method_parameters
        FROM
            map.map_tiles_players_positions t1
        WHERE
            player_id = p_player_id

        UNION ALL

        SELECT
            t1.scheduled_at,
            t1.method_parameters
        FROM
            tasks.tasks t1
        WHERE
            method_name = 'map.movementAction'
            AND status IN (1, 2)
            AND player_id = p_player_id;

    END IF;

END;
$$;


ALTER FUNCTION map.movement_action_in_process(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 16974)
-- Name: player_visible_map_data(integer); Type: FUNCTION; Schema: map; Owner: postgres
--

CREATE FUNCTION map.player_visible_map_data(p_player_id integer) RETURNS TABLE(player_id integer, player_name character varying, player_image_url character varying, map_tile_x integer, map_tile_y integer)
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN QUERY
  
  SELECT 
    t2.player_id,
    t1.name as player_name,
    t1.image_url as player_image_url,
    t2.map_tile_x,
	t2.map_tile_y
  FROM  players.players t1
  JOIN map.map_tiles_players_positions t2 ON t1.id = t2.player_id
  WHERE t1.id = p_player_id;
END;

$$;


ALTER FUNCTION map.player_visible_map_data(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 311 (class 1255 OID 16696)
-- Name: random_landscape_types(integer); Type: FUNCTION; Schema: map; Owner: postgres
--

CREATE FUNCTION map.random_landscape_types(terrain_type_id integer) RETURNS integer
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
            FROM map.landscape_types
            WHERE name IN ('Forest', 'Hills')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 2 THEN -- Grasslands
            SELECT landscape_type_id INTO random_value
            FROM map.landscape_types
            WHERE name IN ('Forest')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 3 THEN -- Shrubland
            SELECT landscape_type_id INTO random_value
            FROM map.landscape_types
            WHERE name IN ('Mountain', 'Volcano')
            ORDER BY log(random()) / landscape_type_id
            LIMIT 1;

        ELSIF terrain_type_id = 4 THEN -- Desert
            SELECT landscape_type_id INTO random_value
            FROM map.landscape_types
            WHERE name IN ('Dunes')
            ORDER BY random()
            LIMIT 1;

        ELSIF terrain_type_id = 5 THEN -- Marsh
            SELECT landscape_type_id INTO random_value
            FROM map.landscape_types
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


ALTER FUNCTION map.random_landscape_types(terrain_type_id integer) OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 16954)
-- Name: add_player_ability(integer, integer, integer); Type: PROCEDURE; Schema: players; Owner: postgres
--

CREATE PROCEDURE players.add_player_ability(IN p_player_id integer, IN p_ability_id integer, IN p_value integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_exists boolean;
BEGIN

    SELECT EXISTS (
        SELECT 1 FROM players.player_abilities
        WHERE player_id = p_player_id AND ability_id = p_ability_id
    ) INTO v_exists;
    
    IF NOT v_exists THEN
        INSERT INTO players.player_abilities(player_id, ability_id, value)
        VALUES (p_player_id, p_ability_id, p_value);
        
        RAISE NOTICE 'Added ability % to player %', p_ability_id, p_player_id;
    ELSE
        RAISE NOTICE 'Player % already has ability %', p_player_id, p_ability_id;
    END IF;
    
    COMMIT;
END;
$$;


ALTER PROCEDURE players.add_player_ability(IN p_player_id integer, IN p_ability_id integer, IN p_value integer) OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 16953)
-- Name: add_player_skill(integer, integer, integer); Type: PROCEDURE; Schema: players; Owner: postgres
--

CREATE PROCEDURE players.add_player_skill(IN p_player_id integer, IN p_skill_id integer, IN p_value integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_exists boolean;
BEGIN

    SELECT EXISTS (
        SELECT 1 FROM players.player_skills
        WHERE player_id = p_player_id AND skill_id = p_skill_id
    ) INTO v_exists;
    
    IF NOT v_exists THEN
		INSERT INTO players.player_skills(
			 player_id, skill_id, value)
			VALUES (p_player_id, p_skill_id, p_value);
        
        RAISE NOTICE 'Added skill % to player %', p_skill_id, p_player_id;
    ELSE
        RAISE NOTICE 'Player % already has skill %', p_player_id, p_skill_id;
    END IF;
    
    COMMIT;

END;
$$;


ALTER PROCEDURE players.add_player_skill(IN p_player_id integer, IN p_skill_id integer, IN p_value integer) OWNER TO postgres;

--
-- TOC entry 300 (class 1255 OID 16971)
-- Name: check_ability_unlocks(integer); Type: PROCEDURE; Schema: players; Owner: postgres
--

CREATE PROCEDURE players.check_ability_unlocks(IN p_player_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ability_id INTEGER;
BEGIN

FOR v_ability_id IN 

    WITH fulfilled_requirements AS (
	
        SELECT ar.ability_id
        FROM attributes.ability_requirements ar
        JOIN (
            SELECT 
			'SKILL' AS requirement_type,
			skill_id AS requirement_id,
			value 
            FROM players.player_skills 
            WHERE player_id = p_player_id
            
            UNION ALL
            
            SELECT 
			'STAT' AS requirement_type,
			stat_id AS requirement_id,
			value
            FROM players.player_stats
            WHERE player_id = p_player_id
            
        ) checks ON ar.requirement_type = checks.requirement_type 
                 AND ar.requirement_id = checks.requirement_id
                 AND checks.value >= ar.min_value

    )
	
 SELECT ability_id 
 FROM fulfilled_requirements
 
    LOOP
        CALL players.add_player_ability(
            p_player_id := p_player_id,
            p_ability_id := v_ability_id,
            p_value := 1
        );
    END LOOP;
	

END;
$$;


ALTER PROCEDURE players.check_ability_unlocks(IN p_player_id integer) OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 17203)
-- Name: player_abilities(integer); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.player_abilities(p_player_id integer) RETURNS TABLE(id integer, player_id integer, ability_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN QUERY
  
 SELECT t1.id,
    t1.player_id,
    t1.ability_id,
    t1.value,
    t2.name
   FROM players.player_abilities t1
     JOIN attributes.abilities t2 ON t1.ability_id = t2.id
  WHERE t1.player_id = p_player_id
    ORDER BY t1.id;
END;

$$;


ALTER FUNCTION players.player_abilities(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 17204)
-- Name: player_skills(integer); Type: FUNCTION; Schema: players; Owner: postgres
--

CREATE FUNCTION players.player_skills(p_player_id integer) RETURNS TABLE(id integer, player_id integer, skill_id integer, value integer, name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN

  RETURN QUERY

 SELECT t1.id,
    t1.player_id,
    t1.skill_id,
    t1.value,
    t2.name
   FROM players.player_skills t1
     JOIN attributes.skills t2 ON t1.skill_id = t2.id
   WHERE t1.player_id = p_player_id
    ORDER BY t1.id;
	
END;
$$;


ALTER FUNCTION players.player_skills(p_player_id integer) OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 17331)
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
-- TOC entry 301 (class 1255 OID 17310)
-- Name: insert_task(integer, character varying, json); Type: FUNCTION; Schema: tasks; Owner: postgres
--

CREATE FUNCTION tasks.insert_task(p_player_id integer, p_method_name character varying, p_parameters json) RETURNS void
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
            p_parameters::jsonb

        );

END;

$$;


ALTER FUNCTION tasks.insert_task(p_player_id integer, p_method_name character varying, p_parameters json) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 250 (class 1259 OID 16933)
-- Name: abilities; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.abilities (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE attributes.abilities OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16932)
-- Name: abilities_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

CREATE SEQUENCE attributes.abilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE attributes.abilities_id_seq OWNER TO postgres;

--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 249
-- Name: abilities_id_seq; Type: SEQUENCE OWNED BY; Schema: attributes; Owner: postgres
--

ALTER SEQUENCE attributes.abilities_id_seq OWNED BY attributes.abilities.id;


--
-- TOC entry 274 (class 1259 OID 17229)
-- Name: ability_requirements; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.ability_requirements (
    ability_id integer NOT NULL,
    requirement_type character varying(20) NOT NULL,
    requirement_id integer NOT NULL,
    min_value integer DEFAULT 1 NOT NULL,
    CONSTRAINT ability_requirements_requirement_type_check CHECK (((requirement_type)::text = ANY (ARRAY[('SKILL'::character varying)::text, ('STAT'::character varying)::text])))
);


ALTER TABLE attributes.ability_requirements OWNER TO postgres;

--
-- TOC entry 278 (class 1259 OID 17262)
-- Name: roles; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.roles (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE attributes.roles OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 17261)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

CREATE SEQUENCE attributes.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE attributes.roles_id_seq OWNER TO postgres;

--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 277
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: attributes; Owner: postgres
--

ALTER SEQUENCE attributes.roles_id_seq OWNED BY attributes.roles.id;


--
-- TOC entry 246 (class 1259 OID 16919)
-- Name: skills; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.skills (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE attributes.skills OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16918)
-- Name: skills_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

CREATE SEQUENCE attributes.skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE attributes.skills_id_seq OWNER TO postgres;

--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 245
-- Name: skills_id_seq; Type: SEQUENCE OWNED BY; Schema: attributes; Owner: postgres
--

ALTER SEQUENCE attributes.skills_id_seq OWNED BY attributes.skills.id;


--
-- TOC entry 248 (class 1259 OID 16926)
-- Name: stats; Type: TABLE; Schema: attributes; Owner: postgres
--

CREATE TABLE attributes.stats (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE attributes.stats OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16925)
-- Name: stats_id_seq; Type: SEQUENCE; Schema: attributes; Owner: postgres
--

CREATE SEQUENCE attributes.stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE attributes.stats_id_seq OWNER TO postgres;

--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 247
-- Name: stats_id_seq; Type: SEQUENCE OWNED BY; Schema: attributes; Owner: postgres
--

ALTER SEQUENCE attributes.stats_id_seq OWNED BY attributes.stats.id;


--
-- TOC entry 225 (class 1259 OID 16471)
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
-- TOC entry 224 (class 1259 OID 16470)
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

CREATE SEQUENCE auth.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.accounts_id_seq OWNER TO postgres;

--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 224
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: postgres
--

ALTER SEQUENCE auth.accounts_id_seq OWNED BY auth.accounts.id;


--
-- TOC entry 227 (class 1259 OID 16480)
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
-- TOC entry 226 (class 1259 OID 16479)
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

CREATE SEQUENCE auth.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.sessions_id_seq OWNER TO postgres;

--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 226
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: postgres
--

ALTER SEQUENCE auth.sessions_id_seq OWNED BY auth.sessions.id;


--
-- TOC entry 229 (class 1259 OID 16510)
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
-- TOC entry 228 (class 1259 OID 16509)
-- Name: users_id_seq; Type: SEQUENCE; Schema: auth; Owner: postgres
--

CREATE SEQUENCE auth.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.users_id_seq OWNER TO postgres;

--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: postgres
--

ALTER SEQUENCE auth.users_id_seq OWNED BY auth.users.id;


--
-- TOC entry 223 (class 1259 OID 16463)
-- Name: verification_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.verification_token (
    identifier text NOT NULL,
    expires timestamp with time zone NOT NULL,
    token text NOT NULL
);


ALTER TABLE auth.verification_token OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 17207)
-- Name: inventory_container_roles; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.inventory_container_roles (
    inventory_container_id integer NOT NULL,
    player_id integer NOT NULL
);


ALTER TABLE items.inventory_container_roles OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 17251)
-- Name: inventory_container_types; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.inventory_container_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE items.inventory_container_types OWNER TO postgres;

--
-- TOC entry 275 (class 1259 OID 17250)
-- Name: inventory_container_types_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

CREATE SEQUENCE items.inventory_container_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE items.inventory_container_types_id_seq OWNER TO postgres;

--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 275
-- Name: inventory_container_types_id_seq; Type: SEQUENCE OWNED BY; Schema: items; Owner: postgres
--

ALTER SEQUENCE items.inventory_container_types_id_seq OWNED BY items.inventory_container_types.id;


--
-- TOC entry 242 (class 1259 OID 16882)
-- Name: inventory_containers; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.inventory_containers (
    id integer NOT NULL,
    inventory_size integer NOT NULL,
    type_id integer DEFAULT 1 NOT NULL,
    entity_id integer,
    CONSTRAINT inventory_containers_inventory_size_check CHECK ((inventory_size > 0))
);


ALTER TABLE items.inventory_containers OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 16881)
-- Name: inventory_containers_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

CREATE SEQUENCE items.inventory_containers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE items.inventory_containers_id_seq OWNER TO postgres;

--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 241
-- Name: inventory_containers_id_seq; Type: SEQUENCE OWNED BY; Schema: items; Owner: postgres
--

ALTER SEQUENCE items.inventory_containers_id_seq OWNED BY items.inventory_containers.id;


--
-- TOC entry 244 (class 1259 OID 16892)
-- Name: inventory_slots; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.inventory_slots (
    id integer NOT NULL,
    inventory_container_id integer NOT NULL,
    item_id integer,
    quantity integer,
    "row" integer NOT NULL,
    col integer NOT NULL,
    CONSTRAINT inventory_slots_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE items.inventory_slots OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16891)
-- Name: inventory_slots_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

CREATE SEQUENCE items.inventory_slots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE items.inventory_slots_id_seq OWNER TO postgres;

--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 243
-- Name: inventory_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: items; Owner: postgres
--

ALTER SEQUENCE items.inventory_slots_id_seq OWNED BY items.inventory_slots.id;


--
-- TOC entry 272 (class 1259 OID 17187)
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
-- TOC entry 271 (class 1259 OID 17186)
-- Name: item_stats_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

CREATE SEQUENCE items.item_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE items.item_stats_id_seq OWNER TO postgres;

--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 271
-- Name: item_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: items; Owner: postgres
--

ALTER SEQUENCE items.item_stats_id_seq OWNED BY items.item_stats.id;


--
-- TOC entry 270 (class 1259 OID 17180)
-- Name: items; Type: TABLE; Schema: items; Owner: postgres
--

CREATE TABLE items.items (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE items.items OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 17179)
-- Name: items_id_seq; Type: SEQUENCE; Schema: items; Owner: postgres
--

CREATE SEQUENCE items.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE items.items_id_seq OWNER TO postgres;

--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 269
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: items; Owner: postgres
--

ALTER SEQUENCE items.items_id_seq OWNED BY items.items.id;


--
-- TOC entry 279 (class 1259 OID 17268)
-- Name: building_roles; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.building_roles (
    building_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE map.building_roles OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 17094)
-- Name: building_types; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.building_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    image_url character varying(255)
);


ALTER TABLE map.building_types OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 17093)
-- Name: building_types_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.building_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.building_types_id_seq OWNER TO postgres;

--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 261
-- Name: building_types_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.building_types_id_seq OWNED BY map.building_types.id;


--
-- TOC entry 260 (class 1259 OID 17087)
-- Name: buildings; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.buildings (
    id integer NOT NULL,
    city_id integer NOT NULL,
    city_tile_x integer NOT NULL,
    city_tile_y integer NOT NULL,
    building_type_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE map.buildings OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 17086)
-- Name: buildings_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.buildings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.buildings_id_seq OWNER TO postgres;

--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 259
-- Name: buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.buildings_id_seq OWNED BY map.buildings.id;


--
-- TOC entry 256 (class 1259 OID 17003)
-- Name: cities; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.cities (
    id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE map.cities OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 17002)
-- Name: cities_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.cities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.cities_id_seq OWNER TO postgres;

--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 255
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.cities_id_seq OWNED BY map.cities.id;


--
-- TOC entry 280 (class 1259 OID 17273)
-- Name: city_roles; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.city_roles (
    city_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE map.city_roles OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 17070)
-- Name: city_tiles; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.city_tiles (
    city_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    terrain_type_id integer DEFAULT 1 NOT NULL,
    landscape_type_id integer
);


ALTER TABLE map.city_tiles OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 17278)
-- Name: district_roles; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.district_roles (
    district_id integer NOT NULL,
    player_id integer NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE map.district_roles OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 17101)
-- Name: district_types; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.district_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE map.district_types OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 17100)
-- Name: district_types_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.district_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.district_types_id_seq OWNER TO postgres;

--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 263
-- Name: district_types_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.district_types_id_seq OWNED BY map.district_types.id;


--
-- TOC entry 266 (class 1259 OID 17123)
-- Name: districts; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.districts (
    id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL,
    district_type_id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE map.districts OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 17122)
-- Name: districts_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.districts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.districts_id_seq OWNER TO postgres;

--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 265
-- Name: districts_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.districts_id_seq OWNED BY map.districts.id;


--
-- TOC entry 240 (class 1259 OID 16687)
-- Name: landscape_types; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.landscape_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE map.landscape_types OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16686)
-- Name: landscape_types_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.landscape_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.landscape_types_id_seq OWNER TO postgres;

--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 239
-- Name: landscape_types_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.landscape_types_id_seq OWNED BY map.landscape_types.id;


--
-- TOC entry 234 (class 1259 OID 16558)
-- Name: map_tiles; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.map_tiles (
    map_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    terrain_type_id integer DEFAULT 1 NOT NULL,
    landscape_type_id integer
);


ALTER TABLE map.map_tiles OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 17017)
-- Name: map_tiles_players_positions; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.map_tiles_players_positions (
    player_id integer NOT NULL,
    map_tile_x integer NOT NULL,
    map_tile_y integer NOT NULL
);


ALTER TABLE map.map_tiles_players_positions OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16537)
-- Name: maps; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.maps (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE map.maps OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16536)
-- Name: maps_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.maps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.maps_id_seq OWNER TO postgres;

--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 230
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.maps_id_seq OWNED BY map.maps.id;


--
-- TOC entry 233 (class 1259 OID 16544)
-- Name: terrain_types; Type: TABLE; Schema: map; Owner: postgres
--

CREATE TABLE map.terrain_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    move_cost integer NOT NULL,
    image_url character varying(255)
);


ALTER TABLE map.terrain_types OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16543)
-- Name: terrain_types_id_seq; Type: SEQUENCE; Schema: map; Owner: postgres
--

CREATE SEQUENCE map.terrain_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE map.terrain_types_id_seq OWNER TO postgres;

--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 232
-- Name: terrain_types_id_seq; Type: SEQUENCE OWNED BY; Schema: map; Owner: postgres
--

ALTER SEQUENCE map.terrain_types_id_seq OWNED BY map.terrain_types.id;


--
-- TOC entry 268 (class 1259 OID 17174)
-- Name: v_buildings; Type: VIEW; Schema: map; Owner: postgres
--

CREATE VIEW map.v_buildings AS
 SELECT t1.id,
    t1.city_id,
    t1.city_tile_x,
    t1.city_tile_y,
    t1.name,
    t2.name AS type_name,
    t2.image_url
   FROM (map.buildings t1
     JOIN map.building_types t2 ON ((t1.building_type_id = t2.id)));


ALTER VIEW map.v_buildings OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 17170)
-- Name: v_districts; Type: VIEW; Schema: map; Owner: postgres
--

CREATE VIEW map.v_districts AS
 SELECT t1.id,
    t1.map_tile_x,
    t1.map_tile_y,
    t1.name,
    t2.name AS type_name,
    t2.move_cost,
    t2.image_url
   FROM (map.districts t1
     JOIN map.district_types t2 ON ((t1.district_type_id = t2.id)));


ALTER VIEW map.v_districts OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 16947)
-- Name: player_abilities; Type: TABLE; Schema: players; Owner: postgres
--

CREATE TABLE players.player_abilities (
    id integer NOT NULL,
    player_id integer NOT NULL,
    ability_id integer NOT NULL,
    value integer NOT NULL
);


ALTER TABLE players.player_abilities OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 16946)
-- Name: player_abilities_id_seq; Type: SEQUENCE; Schema: players; Owner: postgres
--

CREATE SEQUENCE players.player_abilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE players.player_abilities_id_seq OWNER TO postgres;

--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 253
-- Name: player_abilities_id_seq; Type: SEQUENCE OWNED BY; Schema: players; Owner: postgres
--

ALTER SEQUENCE players.player_abilities_id_seq OWNED BY players.player_abilities.id;


--
-- TOC entry 252 (class 1259 OID 16940)
-- Name: player_skills; Type: TABLE; Schema: players; Owner: postgres
--

CREATE TABLE players.player_skills (
    id integer NOT NULL,
    player_id integer NOT NULL,
    skill_id integer NOT NULL,
    value integer NOT NULL
);


ALTER TABLE players.player_skills OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 16939)
-- Name: player_skills_id_seq; Type: SEQUENCE; Schema: players; Owner: postgres
--

CREATE SEQUENCE players.player_skills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE players.player_skills_id_seq OWNER TO postgres;

--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 251
-- Name: player_skills_id_seq; Type: SEQUENCE OWNED BY; Schema: players; Owner: postgres
--

ALTER SEQUENCE players.player_skills_id_seq OWNED BY players.player_skills.id;


--
-- TOC entry 238 (class 1259 OID 16644)
-- Name: player_stats; Type: TABLE; Schema: players; Owner: postgres
--

CREATE TABLE players.player_stats (
    id integer NOT NULL,
    player_id integer NOT NULL,
    stat_id integer NOT NULL,
    value integer NOT NULL
);


ALTER TABLE players.player_stats OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16643)
-- Name: player_stats_id_seq; Type: SEQUENCE; Schema: players; Owner: postgres
--

CREATE SEQUENCE players.player_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE players.player_stats_id_seq OWNER TO postgres;

--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 237
-- Name: player_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: players; Owner: postgres
--

ALTER SEQUENCE players.player_stats_id_seq OWNED BY players.player_stats.id;


--
-- TOC entry 236 (class 1259 OID 16631)
-- Name: players; Type: TABLE; Schema: players; Owner: postgres
--

CREATE TABLE players.players (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying(255) NOT NULL,
    image_url character varying(255) DEFAULT 'default.png'::character varying NOT NULL
);


ALTER TABLE players.players OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16630)
-- Name: players_id_seq; Type: SEQUENCE; Schema: players; Owner: postgres
--

CREATE SEQUENCE players.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE players.players_id_seq OWNER TO postgres;

--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 235
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: players; Owner: postgres
--

ALTER SEQUENCE players.players_id_seq OWNED BY players.players.id;


--
-- TOC entry 284 (class 1259 OID 17321)
-- Name: status_types; Type: TABLE; Schema: tasks; Owner: postgres
--

CREATE TABLE tasks.status_types (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE tasks.status_types OWNER TO postgres;

--
-- TOC entry 285 (class 1259 OID 17324)
-- Name: status_types_id_seq; Type: SEQUENCE; Schema: tasks; Owner: postgres
--

CREATE SEQUENCE tasks.status_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tasks.status_types_id_seq OWNER TO postgres;

--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 285
-- Name: status_types_id_seq; Type: SEQUENCE OWNED BY; Schema: tasks; Owner: postgres
--

ALTER SEQUENCE tasks.status_types_id_seq OWNED BY tasks.status_types.id;


--
-- TOC entry 283 (class 1259 OID 17313)
-- Name: tasks; Type: TABLE; Schema: tasks; Owner: postgres
--

CREATE TABLE tasks.tasks (
    id integer NOT NULL,
    player_id integer NOT NULL,
    status integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    scheduled_at information_schema.time_stamp NOT NULL,
    last_executed_at timestamp without time zone,
    error text,
    method_name character varying(100),
    method_parameters jsonb
);


ALTER TABLE tasks.tasks OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 17312)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: tasks; Owner: postgres
--

CREATE SEQUENCE tasks.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE tasks.tasks_id_seq OWNER TO postgres;

--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 282
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: tasks; Owner: postgres
--

ALTER SEQUENCE tasks.tasks_id_seq OWNED BY tasks.tasks.id;


--
-- TOC entry 4851 (class 2604 OID 16936)
-- Name: abilities id; Type: DEFAULT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities ALTER COLUMN id SET DEFAULT nextval('attributes.abilities_id_seq'::regclass);


--
-- TOC entry 4864 (class 2604 OID 17265)
-- Name: roles id; Type: DEFAULT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles ALTER COLUMN id SET DEFAULT nextval('attributes.roles_id_seq'::regclass);


--
-- TOC entry 4849 (class 2604 OID 16922)
-- Name: skills id; Type: DEFAULT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills ALTER COLUMN id SET DEFAULT nextval('attributes.skills_id_seq'::regclass);


--
-- TOC entry 4850 (class 2604 OID 16929)
-- Name: stats id; Type: DEFAULT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats ALTER COLUMN id SET DEFAULT nextval('attributes.stats_id_seq'::regclass);


--
-- TOC entry 4836 (class 2604 OID 16474)
-- Name: accounts id; Type: DEFAULT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts ALTER COLUMN id SET DEFAULT nextval('auth.accounts_id_seq'::regclass);


--
-- TOC entry 4837 (class 2604 OID 16483)
-- Name: sessions id; Type: DEFAULT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions ALTER COLUMN id SET DEFAULT nextval('auth.sessions_id_seq'::regclass);


--
-- TOC entry 4838 (class 2604 OID 16513)
-- Name: users id; Type: DEFAULT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users ALTER COLUMN id SET DEFAULT nextval('auth.users_id_seq'::regclass);


--
-- TOC entry 4863 (class 2604 OID 17254)
-- Name: inventory_container_types id; Type: DEFAULT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_container_types ALTER COLUMN id SET DEFAULT nextval('items.inventory_container_types_id_seq'::regclass);


--
-- TOC entry 4846 (class 2604 OID 16885)
-- Name: inventory_containers id; Type: DEFAULT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_containers ALTER COLUMN id SET DEFAULT nextval('items.inventory_containers_id_seq'::regclass);


--
-- TOC entry 4848 (class 2604 OID 16895)
-- Name: inventory_slots id; Type: DEFAULT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_slots ALTER COLUMN id SET DEFAULT nextval('items.inventory_slots_id_seq'::regclass);


--
-- TOC entry 4861 (class 2604 OID 17190)
-- Name: item_stats id; Type: DEFAULT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats ALTER COLUMN id SET DEFAULT nextval('items.item_stats_id_seq'::regclass);


--
-- TOC entry 4860 (class 2604 OID 17183)
-- Name: items id; Type: DEFAULT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items ALTER COLUMN id SET DEFAULT nextval('items.items_id_seq'::regclass);


--
-- TOC entry 4857 (class 2604 OID 17097)
-- Name: building_types id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.building_types ALTER COLUMN id SET DEFAULT nextval('map.building_types_id_seq'::regclass);


--
-- TOC entry 4856 (class 2604 OID 17090)
-- Name: buildings id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.buildings ALTER COLUMN id SET DEFAULT nextval('map.buildings_id_seq'::regclass);


--
-- TOC entry 4854 (class 2604 OID 17006)
-- Name: cities id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.cities ALTER COLUMN id SET DEFAULT nextval('map.cities_id_seq'::regclass);


--
-- TOC entry 4858 (class 2604 OID 17104)
-- Name: district_types id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.district_types ALTER COLUMN id SET DEFAULT nextval('map.district_types_id_seq'::regclass);


--
-- TOC entry 4859 (class 2604 OID 17126)
-- Name: districts id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.districts ALTER COLUMN id SET DEFAULT nextval('map.districts_id_seq'::regclass);


--
-- TOC entry 4845 (class 2604 OID 16690)
-- Name: landscape_types id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.landscape_types ALTER COLUMN id SET DEFAULT nextval('map.landscape_types_id_seq'::regclass);


--
-- TOC entry 4839 (class 2604 OID 16540)
-- Name: maps id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.maps ALTER COLUMN id SET DEFAULT nextval('map.maps_id_seq'::regclass);


--
-- TOC entry 4840 (class 2604 OID 16547)
-- Name: terrain_types id; Type: DEFAULT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.terrain_types ALTER COLUMN id SET DEFAULT nextval('map.terrain_types_id_seq'::regclass);


--
-- TOC entry 4853 (class 2604 OID 16950)
-- Name: player_abilities id; Type: DEFAULT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.player_abilities ALTER COLUMN id SET DEFAULT nextval('players.player_abilities_id_seq'::regclass);


--
-- TOC entry 4852 (class 2604 OID 16943)
-- Name: player_skills id; Type: DEFAULT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.player_skills ALTER COLUMN id SET DEFAULT nextval('players.player_skills_id_seq'::regclass);


--
-- TOC entry 4844 (class 2604 OID 16647)
-- Name: player_stats id; Type: DEFAULT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.player_stats ALTER COLUMN id SET DEFAULT nextval('players.player_stats_id_seq'::regclass);


--
-- TOC entry 4842 (class 2604 OID 16634)
-- Name: players id; Type: DEFAULT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players ALTER COLUMN id SET DEFAULT nextval('players.players_id_seq'::regclass);


--
-- TOC entry 4866 (class 2604 OID 17325)
-- Name: status_types id; Type: DEFAULT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types ALTER COLUMN id SET DEFAULT nextval('tasks.status_types_id_seq'::regclass);


--
-- TOC entry 4865 (class 2604 OID 17316)
-- Name: tasks id; Type: DEFAULT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks ALTER COLUMN id SET DEFAULT nextval('tasks.tasks_id_seq'::regclass);


--
-- TOC entry 5120 (class 0 OID 16933)
-- Dependencies: 250
-- Data for Name: abilities; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

INSERT INTO attributes.abilities VALUES (1, 'Colonize');


--
-- TOC entry 5142 (class 0 OID 17229)
-- Dependencies: 274
-- Data for Name: ability_requirements; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

INSERT INTO attributes.ability_requirements VALUES (1, 'SKILL', 1, 1);


--
-- TOC entry 5146 (class 0 OID 17262)
-- Dependencies: 278
-- Data for Name: roles; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

INSERT INTO attributes.roles VALUES (1, 'Owner');


--
-- TOC entry 5116 (class 0 OID 16919)
-- Dependencies: 246
-- Data for Name: skills; Type: TABLE DATA; Schema: attributes; Owner: postgres
--

INSERT INTO attributes.skills VALUES (1, 'Colonization');


--
-- TOC entry 5118 (class 0 OID 16926)
-- Dependencies: 248
-- Data for Name: stats; Type: TABLE DATA; Schema: attributes; Owner: postgres
--



--
-- TOC entry 5095 (class 0 OID 16471)
-- Dependencies: 225
-- Data for Name: accounts; Type: TABLE DATA; Schema: auth; Owner: postgres
--



--
-- TOC entry 5097 (class 0 OID 16480)
-- Dependencies: 227
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: postgres
--



--
-- TOC entry 5099 (class 0 OID 16510)
-- Dependencies: 229
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: postgres
--

INSERT INTO auth.users VALUES (15, 'ciabat', 'pszabat001@gmail.com', NULL, NULL, '$2b$10$4IQKRdaQ8l29u9KEdy6G6esjYGPJe9rQsWlAqPSe0OgbzyjsV6rCW');
INSERT INTO auth.users VALUES (16, 'Ciabat2', 'gbfd@dfss', NULL, NULL, '$2b$10$yLt6ItQ02xBIPkv46D0E8uuguJe839vCekaOftroPtkA3vXqnEFpa');


--
-- TOC entry 5093 (class 0 OID 16463)
-- Dependencies: 223
-- Data for Name: verification_token; Type: TABLE DATA; Schema: auth; Owner: postgres
--



--
-- TOC entry 5141 (class 0 OID 17207)
-- Dependencies: 273
-- Data for Name: inventory_container_roles; Type: TABLE DATA; Schema: items; Owner: postgres
--

INSERT INTO items.inventory_container_roles VALUES (1, 1);
INSERT INTO items.inventory_container_roles VALUES (2, 1);


--
-- TOC entry 5144 (class 0 OID 17251)
-- Dependencies: 276
-- Data for Name: inventory_container_types; Type: TABLE DATA; Schema: items; Owner: postgres
--

INSERT INTO items.inventory_container_types VALUES (1, 'PLAYER');
INSERT INTO items.inventory_container_types VALUES (2, 'BUILDING');
INSERT INTO items.inventory_container_types VALUES (3, 'DISTRICT');


--
-- TOC entry 5112 (class 0 OID 16882)
-- Dependencies: 242
-- Data for Name: inventory_containers; Type: TABLE DATA; Schema: items; Owner: postgres
--

INSERT INTO items.inventory_containers VALUES (1, 18, 1, NULL);
INSERT INTO items.inventory_containers VALUES (2, 5, 2, 1);


--
-- TOC entry 5114 (class 0 OID 16892)
-- Dependencies: 244
-- Data for Name: inventory_slots; Type: TABLE DATA; Schema: items; Owner: postgres
--

INSERT INTO items.inventory_slots VALUES (5, 1, NULL, NULL, 1, 5);
INSERT INTO items.inventory_slots VALUES (6, 1, NULL, NULL, 1, 6);
INSERT INTO items.inventory_slots VALUES (8, 1, NULL, NULL, 2, 2);
INSERT INTO items.inventory_slots VALUES (9, 1, NULL, NULL, 2, 3);
INSERT INTO items.inventory_slots VALUES (10, 1, NULL, NULL, 2, 4);
INSERT INTO items.inventory_slots VALUES (11, 1, NULL, NULL, 2, 5);
INSERT INTO items.inventory_slots VALUES (12, 1, NULL, NULL, 2, 6);
INSERT INTO items.inventory_slots VALUES (14, 1, NULL, NULL, 3, 2);
INSERT INTO items.inventory_slots VALUES (15, 1, NULL, NULL, 3, 3);
INSERT INTO items.inventory_slots VALUES (16, 1, NULL, NULL, 3, 4);
INSERT INTO items.inventory_slots VALUES (17, 1, NULL, NULL, 3, 5);
INSERT INTO items.inventory_slots VALUES (18, 1, NULL, NULL, 3, 6);
INSERT INTO items.inventory_slots VALUES (7, 1, 1, 3, 2, 1);
INSERT INTO items.inventory_slots VALUES (13, 1, 1, 3, 3, 1);
INSERT INTO items.inventory_slots VALUES (2, 1, 1, 3, 1, 2);
INSERT INTO items.inventory_slots VALUES (3, 1, 1, 3, 1, 3);
INSERT INTO items.inventory_slots VALUES (4, 1, NULL, NULL, 1, 4);
INSERT INTO items.inventory_slots VALUES (1, 1, 1, 1, 1, 1);
INSERT INTO items.inventory_slots VALUES (19, 2, NULL, NULL, 1, 1);
INSERT INTO items.inventory_slots VALUES (20, 2, NULL, NULL, 1, 2);
INSERT INTO items.inventory_slots VALUES (21, 2, NULL, NULL, 1, 3);
INSERT INTO items.inventory_slots VALUES (22, 2, NULL, NULL, 1, 4);
INSERT INTO items.inventory_slots VALUES (23, 2, NULL, NULL, 1, 5);


--
-- TOC entry 5140 (class 0 OID 17187)
-- Dependencies: 272
-- Data for Name: item_stats; Type: TABLE DATA; Schema: items; Owner: postgres
--



--
-- TOC entry 5138 (class 0 OID 17180)
-- Dependencies: 270
-- Data for Name: items; Type: TABLE DATA; Schema: items; Owner: postgres
--

INSERT INTO items.items VALUES (1, 'Food');


--
-- TOC entry 5147 (class 0 OID 17268)
-- Dependencies: 279
-- Data for Name: building_roles; Type: TABLE DATA; Schema: map; Owner: postgres
--



--
-- TOC entry 5132 (class 0 OID 17094)
-- Dependencies: 262
-- Data for Name: building_types; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.building_types VALUES (1, 'Townhall', 'Townhall.png');
INSERT INTO map.building_types VALUES (2, 'Marketplace', 'Marketplace.png');
INSERT INTO map.building_types VALUES (3, 'Shacks', 'Shacks.png');
INSERT INTO map.building_types VALUES (4, 'Logistics', 'Logistics.png');


--
-- TOC entry 5130 (class 0 OID 17087)
-- Dependencies: 260
-- Data for Name: buildings; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.buildings VALUES (1, 2, 5, 5, 1, 'First');
INSERT INTO map.buildings VALUES (2, 2, 5, 6, 2, 'Second');
INSERT INTO map.buildings VALUES (5, 2, 5, 4, 3, 'Third');
INSERT INTO map.buildings VALUES (3, 2, 6, 5, 3, 'Third');
INSERT INTO map.buildings VALUES (4, 2, 4, 5, 3, 'Third');
INSERT INTO map.buildings VALUES (6, 2, 4, 4, 3, 'Third');
INSERT INTO map.buildings VALUES (7, 2, 6, 4, 3, 'Third');
INSERT INTO map.buildings VALUES (8, 2, 6, 6, 4, 'Third');


--
-- TOC entry 5126 (class 0 OID 17003)
-- Dependencies: 256
-- Data for Name: cities; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.cities VALUES (2, 4, 3, 'Nashkel', 1, 'City_1.png');


--
-- TOC entry 5148 (class 0 OID 17273)
-- Dependencies: 280
-- Data for Name: city_roles; Type: TABLE DATA; Schema: map; Owner: postgres
--



--
-- TOC entry 5128 (class 0 OID 17070)
-- Dependencies: 258
-- Data for Name: city_tiles; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.city_tiles VALUES (2, 1, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 1, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 2, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 3, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 4, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 5, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 6, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 7, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 8, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 9, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 1, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 2, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 3, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 4, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 5, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 6, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 7, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 8, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 9, 10, 1, NULL);
INSERT INTO map.city_tiles VALUES (2, 10, 10, 1, NULL);


--
-- TOC entry 5149 (class 0 OID 17278)
-- Dependencies: 281
-- Data for Name: district_roles; Type: TABLE DATA; Schema: map; Owner: postgres
--



--
-- TOC entry 5134 (class 0 OID 17101)
-- Dependencies: 264
-- Data for Name: district_types; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.district_types VALUES (1, 'Farmland', 1, 'full_farmland.png');


--
-- TOC entry 5136 (class 0 OID 17123)
-- Dependencies: 266
-- Data for Name: districts; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.districts VALUES (1, 4, 4, 1, '"Green Hills"');


--
-- TOC entry 5110 (class 0 OID 16687)
-- Dependencies: 240
-- Data for Name: landscape_types; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.landscape_types VALUES (1, 'Forest', 2, 'forest.png');
INSERT INTO map.landscape_types VALUES (2, 'Mountain', 5, 'mountain.png');
INSERT INTO map.landscape_types VALUES (3, 'Volcano', 5, 'volcano.png');
INSERT INTO map.landscape_types VALUES (6, 'Jungle', 3, 'jungle.png');
INSERT INTO map.landscape_types VALUES (7, 'Dunes', 5, 'dunes.png');
INSERT INTO map.landscape_types VALUES (8, 'Swamp', 6, 'swamp.png');
INSERT INTO map.landscape_types VALUES (5, 'Forest Savanna', 1, 'forest_savanna.png');
INSERT INTO map.landscape_types VALUES (4, 'Volcano Activated', 10, 'volcano_activated.png');
INSERT INTO map.landscape_types VALUES (9, 'Hills', 2, 'hills.png');


--
-- TOC entry 5104 (class 0 OID 16558)
-- Dependencies: 234
-- Data for Name: map_tiles; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.map_tiles VALUES (1, 1, 1, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 1, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 1, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 1, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 1, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 6, 1, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 1, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 8, 1, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 9, 1, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 10, 1, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 11, 1, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 1, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 13, 1, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 1, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 15, 1, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 1, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 17, 1, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 18, 1, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 1, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 20, 1, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 1, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 22, 1, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 23, 1, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 24, 1, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 25, 1, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 26, 1, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 27, 1, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 28, 1, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 1, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 1, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 2, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 2, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 2, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 2, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 2, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 6, 2, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 2, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 2, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 9, 2, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 2, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 2, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 2, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 13, 2, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 14, 2, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 15, 2, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 2, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 2, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 18, 2, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 19, 2, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 20, 2, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 2, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 22, 2, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 23, 2, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 24, 2, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 25, 2, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 26, 2, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 2, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 2, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 29, 2, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 2, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 1, 3, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 2, 3, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 3, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 3, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 3, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 6, 3, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 7, 3, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 8, 3, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 9, 3, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 3, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 11, 3, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 12, 3, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 3, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 14, 3, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 15, 3, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 16, 3, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 17, 3, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 18, 3, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 19, 3, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 20, 3, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 21, 3, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 3, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 3, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 24, 3, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 25, 3, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 26, 3, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 3, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 28, 3, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 3, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 30, 3, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 1, 4, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 4, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 4, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 4, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 4, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 4, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 4, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 8, 4, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 9, 4, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 10, 4, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 4, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 12, 4, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 13, 4, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 14, 4, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 15, 4, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 16, 4, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 4, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 18, 4, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 19, 4, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 20, 4, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 4, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 4, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 23, 4, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 24, 4, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 25, 4, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 26, 4, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 27, 4, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 4, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 4, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 4, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 1, 5, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 5, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 5, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 5, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 5, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 5, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 7, 5, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 8, 5, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 9, 5, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 5, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 5, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 12, 5, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 13, 5, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 14, 5, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 15, 5, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 5, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 17, 5, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 18, 5, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 19, 5, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 20, 5, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 21, 5, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 5, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 5, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 5, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 25, 5, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 26, 5, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 5, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 5, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 5, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 5, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 1, 6, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 6, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 6, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 6, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 6, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 6, 6, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 6, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 8, 6, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 6, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 6, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 6, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 6, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 6, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 6, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 15, 6, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 6, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 17, 6, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 18, 6, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 19, 6, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 20, 6, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 6, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 6, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 6, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 6, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 25, 6, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 26, 6, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 6, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 6, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 6, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 6, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 7, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 7, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 3, 7, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 7, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 7, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 6, 7, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 7, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 8, 7, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 7, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 10, 7, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 7, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 7, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 7, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 7, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 15, 7, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 7, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 7, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 18, 7, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 19, 7, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 20, 7, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 7, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 7, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 7, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 7, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 7, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 26, 7, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 7, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 7, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 7, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 7, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 8, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 8, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 8, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 4, 8, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 5, 8, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 6, 8, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 8, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 8, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 9, 8, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 8, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 8, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 8, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 8, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 8, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 8, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 8, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 8, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 18, 8, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 19, 8, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 20, 8, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 21, 8, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 8, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 8, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 8, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 25, 8, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 26, 8, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 8, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 8, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 8, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 8, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 9, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 9, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 9, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 9, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 5, 9, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 6, 9, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 9, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 9, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 9, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 9, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 9, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 16, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 9, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 9, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 19, 9, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 20, 9, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 21, 9, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 22, 9, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 9, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 9, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 25, 9, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 26, 9, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 9, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 9, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 1, 10, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 10, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 10, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 10, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 5, 10, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 6, 10, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 10, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 10, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 10, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 10, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 11, 10, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 10, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 10, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 10, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 10, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 16, 10, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 10, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 10, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 19, 10, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 20, 10, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 10, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 10, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 10, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 24, 10, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 25, 10, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 10, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 10, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 10, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 10, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 10, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 1, 11, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 11, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 11, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 11, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 11, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 9, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 11, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 11, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 11, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 11, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 11, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 11, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 11, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 11, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 18, 11, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 19, 11, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 20, 11, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 11, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 11, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 11, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 24, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 27, 11, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 28, 11, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 11, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 11, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 1, 12, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 12, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 12, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 12, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 12, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 12, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 12, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 8, 12, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 12, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 12, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 11, 12, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 12, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 12, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 12, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 12, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 12, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 12, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 12, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 12, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 20, 12, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 12, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 12, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 12, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 24, 12, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 25, 12, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 12, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 27, 12, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 28, 12, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 12, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 12, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 1, 13, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 13, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 13, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 13, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 5, 13, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 6, 13, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 7, 13, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 13, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 13, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 13, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 13, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 13, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 13, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 13, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 15, 13, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 16, 13, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 13, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 13, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 19, 13, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 20, 13, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 13, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 13, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 13, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 24, 13, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 25, 13, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 26, 13, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 13, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 28, 13, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 29, 13, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 13, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 1, 14, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 5, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 14, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 14, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 14, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 14, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 14, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 13, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 14, 14, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 14, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 16, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 17, 14, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 18, 14, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 14, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 20, 14, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 14, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 14, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 14, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 24, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 14, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 27, 14, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 14, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 14, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 14, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 1, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 15, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 15, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 6, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 7, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 8, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 15, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 15, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 15, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 15, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 14, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 15, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 17, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 15, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 20, 15, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 15, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 15, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 15, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 28, 15, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 15, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 30, 15, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 16, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 16, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 8, 16, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 16, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 16, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 16, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 14, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 15, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 16, 16, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 16, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 19, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 20, 16, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 16, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 16, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 16, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 16, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 26, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 28, 16, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 29, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 16, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 17, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 17, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 6, 17, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 17, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 8, 17, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 9, 17, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 10, 17, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 15, 17, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 17, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 18, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 17, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 20, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 17, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 22, 17, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 25, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 26, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 17, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 17, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 1, 18, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 5, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 6, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 18, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 8, 18, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 18, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 10, 18, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 11, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 15, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 18, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 19, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 20, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 21, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 22, 18, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 18, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 18, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 18, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 30, 18, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 1, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 2, 19, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 5, 19, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 6, 19, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 19, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 19, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 9, 19, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 19, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 11, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 19, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 14, 19, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 15, 19, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 19, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 19, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 18, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 19, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 20, 19, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 22, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 23, 19, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 19, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 25, 19, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 26, 19, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 19, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 19, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 19, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 19, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 20, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 20, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 20, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 8, 20, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 9, 20, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 20, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 20, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 15, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 20, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 20, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 20, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 20, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 20, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 20, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 20, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 20, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 1, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 21, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 7, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 10, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 11, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 21, 5, 8);
INSERT INTO map.map_tiles VALUES (1, 17, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 20, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 21, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 26, 21, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 21, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 21, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 21, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 22, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 3, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 4, 22, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 6, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 7, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 22, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 22, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 11, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 22, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 15, 22, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 22, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 22, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 20, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 22, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 22, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 27, 22, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 29, 22, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 22, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 1, 23, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 2, 23, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 23, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 6, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 7, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 11, 23, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 23, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 14, 23, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 15, 23, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 19, 23, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 20, 23, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 23, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 25, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 26, 23, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 23, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 28, 23, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 23, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 30, 23, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 1, 24, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 2, 24, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 5, 24, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 6, 24, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 7, 24, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 24, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 24, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 24, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 13, 24, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 24, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 15, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 16, 24, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 24, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 24, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 19, 24, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 20, 24, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 21, 24, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 24, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 25, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 26, 24, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 24, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 24, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 30, 24, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 1, 25, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 25, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 3, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 25, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 5, 25, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 6, 25, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 7, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 25, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 25, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 25, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 11, 25, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 25, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 13, 25, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 14, 25, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 15, 25, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 16, 25, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 25, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 18, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 19, 25, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 20, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 25, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 25, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 25, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 26, 25, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 27, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 29, 25, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 25, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 26, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 26, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 3, 26, 4, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 26, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 5, 26, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 6, 26, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 7, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 9, 26, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 10, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 11, 26, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 12, 26, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 26, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 14, 26, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 15, 26, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 16, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 26, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 26, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 19, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 20, 26, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 21, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 26, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 23, 26, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 26, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 25, 26, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 26, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 27, 26, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 26, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 26, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 1, 27, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 27, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 27, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 27, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 27, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 6, 27, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 7, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 10, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 27, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 27, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 16, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 27, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 20, 27, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 21, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 27, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 27, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 27, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 28, 27, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 29, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 27, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 28, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 28, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 3, 28, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 4, 28, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 5, 28, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 6, 28, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 7, 28, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 8, 28, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 9, 28, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 28, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 28, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 12, 28, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 28, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 14, 28, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 15, 28, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 16, 28, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 17, 28, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 28, 5, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 28, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 20, 28, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 21, 28, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 28, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 28, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 24, 28, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 25, 28, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 26, 28, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 27, 28, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 28, 28, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 29, 28, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 30, 28, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 29, 2, NULL);
INSERT INTO map.map_tiles VALUES (1, 2, 29, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 29, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 4, 29, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 5, 29, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 6, 29, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 7, 29, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 8, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 9, 29, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 10, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 29, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 12, 29, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 13, 29, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 14, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 15, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 16, 29, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 17, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 18, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 19, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 20, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 21, 29, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 22, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 23, 29, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 24, 29, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 29, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 26, 29, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 27, 29, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 28, 29, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 29, 29, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 29, 7, NULL);
INSERT INTO map.map_tiles VALUES (1, 1, 30, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 2, 30, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 3, 30, 2, 1);
INSERT INTO map.map_tiles VALUES (1, 4, 30, 5, 6);
INSERT INTO map.map_tiles VALUES (1, 5, 30, 3, 3);
INSERT INTO map.map_tiles VALUES (1, 6, 30, 3, 2);
INSERT INTO map.map_tiles VALUES (1, 7, 30, 4, 7);
INSERT INTO map.map_tiles VALUES (1, 8, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 9, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 10, 30, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 11, 30, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 12, 30, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 13, 30, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 14, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 15, 30, 3, NULL);
INSERT INTO map.map_tiles VALUES (1, 16, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 17, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 18, 30, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 19, 30, 6, NULL);
INSERT INTO map.map_tiles VALUES (1, 20, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 21, 30, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 22, 30, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 23, 30, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 24, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 25, 30, 1, 1);
INSERT INTO map.map_tiles VALUES (1, 26, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 27, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 28, 30, 1, 9);
INSERT INTO map.map_tiles VALUES (1, 29, 30, 1, NULL);
INSERT INTO map.map_tiles VALUES (1, 30, 30, 5, 8);


--
-- TOC entry 5127 (class 0 OID 17017)
-- Dependencies: 257
-- Data for Name: map_tiles_players_positions; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.map_tiles_players_positions VALUES (1, 1, 4);
INSERT INTO map.map_tiles_players_positions VALUES (2, 2, 2);


--
-- TOC entry 5101 (class 0 OID 16537)
-- Dependencies: 231
-- Data for Name: maps; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.maps VALUES (1, 'NowaMapa');


--
-- TOC entry 5103 (class 0 OID 16544)
-- Dependencies: 233
-- Data for Name: terrain_types; Type: TABLE DATA; Schema: map; Owner: postgres
--

INSERT INTO map.terrain_types VALUES (1, 'Plains', 1, 'plains.png');
INSERT INTO map.terrain_types VALUES (2, 'Grasslands', 1, 'grasslands.png');
INSERT INTO map.terrain_types VALUES (3, 'Shrubland', 1, 'shrubland.png');
INSERT INTO map.terrain_types VALUES (4, 'Desert', 6, 'desert.png');
INSERT INTO map.terrain_types VALUES (6, 'Savannah', 5, 'savannah.png');
INSERT INTO map.terrain_types VALUES (5, 'Marsh', 6, 'marsh.png');
INSERT INTO map.terrain_types VALUES (7, 'Jungle', 4, 'jungle.png');


--
-- TOC entry 5124 (class 0 OID 16947)
-- Dependencies: 254
-- Data for Name: player_abilities; Type: TABLE DATA; Schema: players; Owner: postgres
--

INSERT INTO players.player_abilities VALUES (1, 1, 1, 1);


--
-- TOC entry 5122 (class 0 OID 16940)
-- Dependencies: 252
-- Data for Name: player_skills; Type: TABLE DATA; Schema: players; Owner: postgres
--

INSERT INTO players.player_skills VALUES (1, 1, 1, 1);


--
-- TOC entry 5108 (class 0 OID 16644)
-- Dependencies: 238
-- Data for Name: player_stats; Type: TABLE DATA; Schema: players; Owner: postgres
--



--
-- TOC entry 5106 (class 0 OID 16631)
-- Dependencies: 236
-- Data for Name: players; Type: TABLE DATA; Schema: players; Owner: postgres
--

INSERT INTO players.players VALUES (1, 15, 'ciabat', 'default.png');
INSERT INTO players.players VALUES (2, 16, 'DrugiGracz', 'default.png');


--
-- TOC entry 5152 (class 0 OID 17321)
-- Dependencies: 284
-- Data for Name: status_types; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

INSERT INTO tasks.status_types VALUES (1, 'to_process');
INSERT INTO tasks.status_types VALUES (2, 'in_process');
INSERT INTO tasks.status_types VALUES (3, 'done');
INSERT INTO tasks.status_types VALUES (4, 'retry');
INSERT INTO tasks.status_types VALUES (5, 'cancelled');
INSERT INTO tasks.status_types VALUES (6, 'error');


--
-- TOC entry 5151 (class 0 OID 17313)
-- Dependencies: 283
-- Data for Name: tasks; Type: TABLE DATA; Schema: tasks; Owner: postgres
--

INSERT INTO tasks.tasks VALUES (1, 1, 5, '2025-06-01 00:53:34.454705', '2025-06-01 00:58:34.45+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (2, 1, 5, '2025-06-01 00:53:34.456818', '2025-06-01 00:58:34.46+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (3, 1, 5, '2025-06-01 00:53:34.457512', '2025-06-01 00:58:34.46+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (4, 1, 5, '2025-06-01 01:34:30.884921', '2025-06-01 01:39:30.88+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (5, 1, 5, '2025-06-01 01:34:30.886684', '2025-06-01 01:39:30.89+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (6, 1, 5, '2025-06-01 01:34:30.887401', '2025-06-01 01:39:30.89+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (7, 1, 5, '2025-06-01 01:34:30.888079', '2025-06-01 01:39:30.89+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (8, 1, 5, '2025-06-01 01:34:30.888843', '2025-06-01 01:39:30.89+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (9, 1, 5, '2025-06-01 01:34:30.889622', '2025-06-01 01:39:30.89+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (10, 1, 5, '2025-06-01 01:34:30.89046', '2025-06-01 01:39:30.89+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (11, 1, 5, '2025-06-01 02:01:21.015456', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (12, 1, 5, '2025-06-01 02:01:21.019088', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (13, 1, 5, '2025-06-01 02:01:21.020172', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (14, 1, 5, '2025-06-01 02:01:21.020873', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (15, 1, 5, '2025-06-01 02:01:21.02173', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (16, 1, 5, '2025-06-01 02:01:21.022726', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (17, 1, 5, '2025-06-01 02:01:21.023341', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (18, 1, 5, '2025-06-01 02:01:21.024053', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (19, 1, 5, '2025-06-01 02:01:21.024776', '2025-06-01 02:06:21.02+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (20, 1, 5, '2025-06-01 02:01:21.025677', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (21, 1, 5, '2025-06-01 02:01:21.026743', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (22, 1, 5, '2025-06-01 02:01:21.02776', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (23, 1, 5, '2025-06-01 02:01:21.028559', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (24, 1, 5, '2025-06-01 02:01:21.029211', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (25, 1, 5, '2025-06-01 02:01:21.02982', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (26, 1, 5, '2025-06-01 02:01:21.030425', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (27, 1, 5, '2025-06-01 02:01:21.031038', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (28, 1, 5, '2025-06-01 02:01:21.03162', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (29, 1, 5, '2025-06-01 02:01:21.03247', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 22, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (30, 1, 5, '2025-06-01 02:01:21.034112', '2025-06-01 02:06:21.03+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 22, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (31, 1, 5, '2025-06-01 02:01:21.035319', '2025-06-01 02:06:21.04+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 23, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (32, 1, 5, '2025-06-01 02:01:21.036017', '2025-06-01 02:06:21.04+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 24, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (33, 1, 5, '2025-06-01 02:01:21.03665', '2025-06-01 02:06:21.04+02', NULL, NULL, 'map.movmentAction', '{"x": 22, "y": 24, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (34, 1, 5, '2025-06-03 23:30:10.91695', '2025-06-03 23:35:10.92+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (35, 1, 5, '2025-06-03 23:30:10.927372', '2025-06-03 23:35:10.93+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (36, 1, 5, '2025-06-03 23:30:10.92852', '2025-06-03 23:35:10.93+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (37, 1, 5, '2025-06-03 23:30:10.929375', '2025-06-03 23:35:10.93+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (38, 1, 5, '2025-06-03 23:30:10.93114', '2025-06-03 23:35:10.93+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (39, 1, 5, '2025-06-03 23:30:10.932109', '2025-06-03 23:35:10.93+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (40, 1, 5, '2025-06-03 23:33:57.201061', '2025-06-03 23:38:57.2+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (41, 1, 5, '2025-06-03 23:33:57.203162', '2025-06-03 23:38:57.2+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (42, 1, 5, '2025-06-03 23:33:57.204072', '2025-06-03 23:38:57.2+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (43, 1, 5, '2025-06-03 23:33:57.204872', '2025-06-03 23:38:57.2+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (44, 1, 5, '2025-06-03 23:33:57.205956', '2025-06-03 23:38:57.21+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (45, 1, 5, '2025-06-03 23:34:29.666917', '2025-06-03 23:39:29.67+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (46, 1, 5, '2025-06-03 23:34:29.670239', '2025-06-03 23:39:29.67+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (47, 1, 5, '2025-06-03 23:34:29.674294', '2025-06-03 23:39:29.67+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (48, 1, 5, '2025-06-03 23:34:29.676382', '2025-06-03 23:39:29.68+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (49, 1, 5, '2025-06-03 23:34:29.678532', '2025-06-03 23:39:29.68+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (50, 1, 5, '2025-06-03 23:34:29.681343', '2025-06-03 23:39:29.68+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (51, 1, 5, '2025-06-03 23:34:29.683733', '2025-06-03 23:39:29.68+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (52, 1, 5, '2025-06-03 23:34:37.970266', '2025-06-03 23:39:37.97+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (53, 1, 5, '2025-06-03 23:34:37.971667', '2025-06-03 23:39:37.97+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (54, 1, 5, '2025-06-03 23:34:37.972697', '2025-06-03 23:39:37.97+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (55, 1, 5, '2025-06-03 23:34:37.973795', '2025-06-03 23:39:37.97+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (56, 1, 5, '2025-06-03 23:34:37.974728', '2025-06-03 23:39:37.97+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (57, 1, 5, '2025-06-03 23:34:37.975825', '2025-06-03 23:39:37.98+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (58, 1, 5, '2025-06-03 23:34:37.977194', '2025-06-03 23:39:37.98+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (59, 1, 5, '2025-06-03 23:34:37.978362', '2025-06-03 23:39:37.98+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (60, 1, 5, '2025-06-03 23:34:37.979423', '2025-06-03 23:39:37.98+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (61, 1, 5, '2025-06-03 23:34:37.983815', '2025-06-03 23:39:37.98+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (62, 1, 5, '2025-06-03 23:34:38.000243', '2025-06-03 23:39:38+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (63, 1, 5, '2025-06-03 23:34:38.001896', '2025-06-03 23:39:38+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (64, 1, 5, '2025-06-03 23:34:38.003184', '2025-06-03 23:39:38+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (65, 1, 5, '2025-06-03 23:34:38.004513', '2025-06-03 23:39:38+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (66, 1, 5, '2025-06-03 23:34:38.006', '2025-06-03 23:39:38.01+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (67, 1, 5, '2025-06-03 23:34:38.007541', '2025-06-03 23:39:38.01+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (68, 1, 5, '2025-06-03 23:34:38.009093', '2025-06-03 23:39:38.01+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (69, 1, 5, '2025-06-03 23:34:55.658025', '2025-06-03 23:39:55.66+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (70, 1, 5, '2025-06-03 23:34:55.659036', '2025-06-03 23:39:55.66+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (71, 1, 5, '2025-06-03 23:34:55.659849', '2025-06-03 23:39:55.66+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (72, 1, 5, '2025-06-03 23:34:55.660655', '2025-06-03 23:39:55.66+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (73, 1, 5, '2025-06-03 23:34:55.661721', '2025-06-03 23:39:55.66+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (74, 1, 5, '2025-06-03 23:34:55.662701', '2025-06-03 23:39:55.66+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (75, 1, 5, '2025-06-03 23:34:55.664095', '2025-06-03 23:39:55.66+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (76, 1, 5, '2025-06-03 23:34:55.665785', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (77, 1, 5, '2025-06-03 23:34:55.667029', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (78, 1, 5, '2025-06-03 23:34:55.668121', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (79, 1, 5, '2025-06-03 23:34:55.669', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (80, 1, 5, '2025-06-03 23:34:55.670032', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (81, 1, 5, '2025-06-03 23:34:55.670849', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (82, 1, 5, '2025-06-03 23:34:55.67181', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (83, 1, 5, '2025-06-03 23:34:55.672854', '2025-06-03 23:39:55.67+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (84, 1, 5, '2025-06-03 23:35:25.264405', '2025-06-03 23:40:25.26+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (85, 1, 5, '2025-06-03 23:35:25.26573', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (86, 1, 5, '2025-06-03 23:35:25.26694', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (87, 1, 5, '2025-06-03 23:35:25.267944', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (88, 1, 5, '2025-06-03 23:35:25.269168', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (89, 1, 5, '2025-06-03 23:35:25.27068', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (90, 1, 5, '2025-06-03 23:35:25.272491', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (91, 1, 5, '2025-06-03 23:35:25.273685', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (92, 1, 5, '2025-06-03 23:35:25.274745', '2025-06-03 23:40:25.27+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (93, 1, 5, '2025-06-03 23:35:25.275811', '2025-06-03 23:40:25.28+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (94, 1, 5, '2025-06-03 23:35:25.276936', '2025-06-03 23:40:25.28+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (95, 1, 5, '2025-06-03 23:35:25.278132', '2025-06-03 23:40:25.28+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (96, 1, 5, '2025-06-03 23:35:25.279382', '2025-06-03 23:40:25.28+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (97, 1, 5, '2025-06-03 23:35:25.280794', '2025-06-03 23:40:25.28+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (98, 1, 5, '2025-06-03 23:35:25.282707', '2025-06-03 23:40:25.28+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (99, 1, 5, '2025-06-03 23:35:25.284214', '2025-06-03 23:40:25.28+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (100, 1, 5, '2025-06-03 23:35:25.285655', '2025-06-03 23:40:25.29+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (101, 1, 5, '2025-06-03 23:35:25.287245', '2025-06-03 23:40:25.29+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (102, 1, 5, '2025-06-03 23:38:48.473185', '2025-06-03 23:43:48.47+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (103, 1, 5, '2025-06-03 23:38:48.475395', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (104, 1, 5, '2025-06-03 23:38:48.476284', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (105, 1, 5, '2025-06-03 23:38:48.477077', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (106, 1, 5, '2025-06-03 23:38:48.477798', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (107, 1, 5, '2025-06-03 23:38:48.478524', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (108, 1, 5, '2025-06-03 23:38:48.479264', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (109, 1, 5, '2025-06-03 23:38:48.480132', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (110, 1, 5, '2025-06-03 23:38:48.481007', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (111, 1, 5, '2025-06-03 23:38:48.482247', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (112, 1, 5, '2025-06-03 23:38:48.482972', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (113, 1, 5, '2025-06-03 23:38:48.483671', '2025-06-03 23:43:48.48+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (114, 1, 5, '2025-06-03 23:39:03.350467', '2025-06-03 23:44:03.35+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (115, 1, 5, '2025-06-03 23:39:03.35172', '2025-06-03 23:44:03.35+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (116, 1, 5, '2025-06-03 23:39:03.352806', '2025-06-03 23:44:03.35+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (117, 1, 5, '2025-06-03 23:39:03.353771', '2025-06-03 23:44:03.35+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (118, 1, 5, '2025-06-03 23:39:03.354822', '2025-06-03 23:44:03.35+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (119, 1, 5, '2025-06-03 23:39:03.355794', '2025-06-03 23:44:03.36+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (120, 1, 5, '2025-06-03 23:39:03.356824', '2025-06-03 23:44:03.36+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (121, 1, 5, '2025-06-03 23:39:03.35799', '2025-06-03 23:44:03.36+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (122, 1, 5, '2025-06-03 23:39:03.359347', '2025-06-03 23:44:03.36+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (123, 1, 5, '2025-06-03 23:39:03.36041', '2025-06-03 23:44:03.36+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (124, 1, 5, '2025-06-03 23:40:41.016849', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (125, 1, 5, '2025-06-03 23:40:41.018501', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (126, 1, 5, '2025-06-03 23:40:41.019176', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (127, 1, 5, '2025-06-03 23:40:41.019626', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (128, 1, 5, '2025-06-03 23:40:41.020056', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (129, 1, 5, '2025-06-03 23:40:41.020455', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (130, 1, 5, '2025-06-03 23:40:41.020836', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (131, 1, 5, '2025-06-03 23:40:41.021171', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (132, 1, 5, '2025-06-03 23:40:41.021484', '2025-06-03 23:45:41.02+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (133, 1, 5, '2025-06-03 23:41:07.924264', '2025-06-03 23:46:07.92+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (134, 1, 5, '2025-06-03 23:41:07.924967', '2025-06-03 23:46:07.92+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (135, 1, 5, '2025-06-03 23:41:07.925491', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (136, 1, 5, '2025-06-03 23:41:07.925967', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (137, 1, 5, '2025-06-03 23:41:07.926488', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (138, 1, 5, '2025-06-03 23:41:07.927004', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (139, 1, 5, '2025-06-03 23:41:07.92748', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (140, 1, 5, '2025-06-03 23:41:07.92812', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (141, 1, 5, '2025-06-03 23:41:07.928508', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (142, 1, 5, '2025-06-03 23:41:07.928904', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (143, 1, 5, '2025-06-03 23:41:07.929286', '2025-06-03 23:46:07.93+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (144, 1, 5, '2025-06-03 23:42:38.035661', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (145, 1, 5, '2025-06-03 23:42:38.037699', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (146, 1, 5, '2025-06-03 23:42:38.038307', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (147, 1, 5, '2025-06-03 23:42:38.038869', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (148, 1, 5, '2025-06-03 23:42:38.039379', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (149, 1, 5, '2025-06-03 23:42:38.04002', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (150, 1, 5, '2025-06-03 23:42:38.040644', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (151, 1, 5, '2025-06-03 23:42:38.041152', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (152, 1, 5, '2025-06-03 23:42:38.041623', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (153, 1, 5, '2025-06-03 23:42:38.042042', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (154, 1, 5, '2025-06-03 23:42:38.042479', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (155, 1, 5, '2025-06-03 23:42:38.042854', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (156, 1, 5, '2025-06-03 23:42:38.043377', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (157, 1, 5, '2025-06-03 23:42:38.043773', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (158, 1, 5, '2025-06-03 23:42:38.044182', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (159, 1, 5, '2025-06-03 23:42:38.044581', '2025-06-03 23:47:38.04+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (160, 1, 5, '2025-06-03 23:42:38.045004', '2025-06-03 23:47:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (161, 1, 5, '2025-06-03 23:42:38.04539', '2025-06-03 23:47:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (162, 1, 5, '2025-06-03 23:42:38.045891', '2025-06-03 23:47:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (163, 1, 5, '2025-06-03 23:42:38.046341', '2025-06-03 23:47:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (164, 1, 5, '2025-06-03 23:42:38.04675', '2025-06-03 23:47:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 22, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (165, 1, 5, '2025-06-03 23:42:38.047143', '2025-06-03 23:47:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (166, 1, 5, '2025-06-03 23:42:47.681799', '2025-06-03 23:47:47.68+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (167, 1, 5, '2025-06-03 23:42:47.682322', '2025-06-03 23:47:47.68+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (168, 1, 5, '2025-06-03 23:42:47.682706', '2025-06-03 23:47:47.68+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (169, 1, 5, '2025-06-03 23:45:18.543379', '2025-06-03 23:50:18.54+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (170, 1, 5, '2025-06-03 23:45:18.545224', '2025-06-03 23:50:18.55+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (171, 1, 5, '2025-06-03 23:45:18.545864', '2025-06-03 23:50:18.55+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (172, 1, 5, '2025-06-03 23:45:18.546336', '2025-06-03 23:50:18.55+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (173, 1, 5, '2025-06-03 23:45:24.984806', '2025-06-03 23:50:24.98+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (174, 1, 5, '2025-06-03 23:45:24.985458', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (175, 1, 5, '2025-06-03 23:45:24.986068', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (176, 1, 5, '2025-06-03 23:45:24.986608', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (177, 1, 5, '2025-06-03 23:45:24.987133', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (178, 1, 5, '2025-06-03 23:45:24.987595', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (179, 1, 5, '2025-06-03 23:45:24.98805', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (180, 1, 5, '2025-06-03 23:45:24.988489', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (181, 1, 5, '2025-06-03 23:45:24.988897', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (182, 1, 5, '2025-06-03 23:45:24.989297', '2025-06-03 23:50:24.99+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (183, 1, 5, '2025-06-03 23:46:20.092559', '2025-06-03 23:51:20.09+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (184, 1, 5, '2025-06-03 23:46:20.093778', '2025-06-03 23:51:20.09+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (185, 1, 5, '2025-06-03 23:46:20.094169', '2025-06-03 23:51:20.09+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (186, 1, 5, '2025-06-03 23:46:20.094528', '2025-06-03 23:51:20.09+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (187, 1, 5, '2025-06-03 23:46:20.094867', '2025-06-03 23:51:20.09+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (188, 1, 5, '2025-06-03 23:46:20.095204', '2025-06-03 23:51:20.1+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (189, 1, 5, '2025-06-03 23:46:20.095525', '2025-06-03 23:51:20.1+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (190, 1, 5, '2025-06-03 23:46:26.69606', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (191, 1, 5, '2025-06-03 23:46:26.696701', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (192, 1, 5, '2025-06-03 23:46:26.69726', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (193, 1, 5, '2025-06-03 23:46:26.697873', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (194, 1, 5, '2025-06-03 23:46:26.69832', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (195, 1, 5, '2025-06-03 23:46:26.698812', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (196, 1, 5, '2025-06-03 23:46:26.699259', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (197, 1, 5, '2025-06-03 23:46:26.6997', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (198, 1, 5, '2025-06-03 23:46:26.700253', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (199, 1, 5, '2025-06-03 23:46:26.700658', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (200, 1, 5, '2025-06-03 23:46:26.701059', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (201, 1, 5, '2025-06-03 23:46:26.701459', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (202, 1, 5, '2025-06-03 23:46:26.701832', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (203, 1, 5, '2025-06-03 23:46:26.702253', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (204, 1, 5, '2025-06-03 23:46:26.702757', '2025-06-03 23:51:26.7+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (205, 1, 5, '2025-06-03 23:46:39.148365', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (206, 1, 5, '2025-06-03 23:46:39.14908', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (207, 1, 5, '2025-06-03 23:46:39.149586', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (208, 1, 5, '2025-06-03 23:46:39.150112', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (209, 1, 5, '2025-06-03 23:46:39.150537', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (210, 1, 5, '2025-06-03 23:46:39.150919', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (211, 1, 5, '2025-06-03 23:46:39.151431', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (212, 1, 5, '2025-06-03 23:46:39.151852', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (213, 1, 5, '2025-06-03 23:46:39.152252', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (214, 1, 5, '2025-06-03 23:46:39.152626', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (215, 1, 5, '2025-06-03 23:46:39.153045', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (216, 1, 5, '2025-06-03 23:46:39.153436', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (217, 1, 5, '2025-06-03 23:46:39.153786', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (218, 1, 5, '2025-06-03 23:46:39.154245', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (219, 1, 5, '2025-06-03 23:46:39.15461', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (220, 1, 5, '2025-06-03 23:46:39.15493', '2025-06-03 23:51:39.15+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (221, 1, 5, '2025-06-03 23:46:39.155272', '2025-06-03 23:51:39.16+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (222, 1, 5, '2025-06-03 23:46:39.15562', '2025-06-03 23:51:39.16+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (223, 1, 5, '2025-06-03 23:47:02.6815', '2025-06-03 23:52:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (224, 1, 5, '2025-06-03 23:47:02.682437', '2025-06-03 23:52:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (225, 1, 5, '2025-06-03 23:47:02.684123', '2025-06-03 23:52:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (226, 1, 5, '2025-06-03 23:47:02.684962', '2025-06-03 23:52:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (227, 1, 5, '2025-06-03 23:47:02.685677', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (228, 1, 5, '2025-06-03 23:47:02.686032', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (229, 1, 5, '2025-06-03 23:47:02.68657', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (230, 1, 5, '2025-06-03 23:47:02.686948', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (231, 1, 5, '2025-06-03 23:47:02.687277', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (232, 1, 5, '2025-06-03 23:47:02.687689', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (233, 1, 5, '2025-06-03 23:47:02.688073', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (234, 1, 5, '2025-06-03 23:47:02.688456', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (235, 1, 5, '2025-06-03 23:47:02.688812', '2025-06-03 23:52:02.69+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (236, 1, 5, '2025-06-03 23:47:25.795058', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (237, 1, 5, '2025-06-03 23:47:25.797813', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (238, 1, 5, '2025-06-03 23:47:25.799855', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (239, 1, 5, '2025-06-03 23:47:25.800841', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (240, 1, 5, '2025-06-03 23:47:25.80144', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (241, 1, 5, '2025-06-03 23:47:25.801959', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (242, 1, 5, '2025-06-03 23:47:25.802488', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (243, 1, 5, '2025-06-03 23:47:25.804484', '2025-06-03 23:52:25.8+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (244, 1, 5, '2025-06-03 23:47:25.805235', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (245, 1, 5, '2025-06-03 23:47:25.805853', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (246, 1, 5, '2025-06-03 23:47:25.8071', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (247, 1, 5, '2025-06-03 23:47:25.80883', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (248, 1, 5, '2025-06-03 23:47:25.810035', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (249, 1, 5, '2025-06-03 23:47:25.810715', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (250, 1, 5, '2025-06-03 23:47:25.811253', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (251, 1, 5, '2025-06-03 23:47:25.813019', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (252, 1, 5, '2025-06-03 23:47:25.814269', '2025-06-03 23:52:25.81+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (253, 1, 5, '2025-06-03 23:47:25.816822', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (254, 1, 5, '2025-06-03 23:47:25.817598', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (255, 1, 5, '2025-06-03 23:47:25.818322', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (256, 1, 5, '2025-06-03 23:47:25.819876', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (257, 1, 5, '2025-06-03 23:47:25.820966', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (258, 1, 5, '2025-06-03 23:47:25.821646', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (259, 1, 5, '2025-06-03 23:47:25.822181', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 22, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (260, 1, 5, '2025-06-03 23:47:25.822687', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 23, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (261, 1, 5, '2025-06-03 23:47:25.823757', '2025-06-03 23:52:25.82+02', NULL, NULL, 'map.movmentAction', '{"x": 24, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (262, 1, 5, '2025-06-04 00:07:03.336724', '2025-06-04 00:12:03.34+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (263, 1, 5, '2025-06-04 00:07:03.337672', '2025-06-04 00:12:03.34+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (264, 1, 5, '2025-06-04 00:07:03.33812', '2025-06-04 00:12:03.34+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (265, 1, 5, '2025-06-04 00:07:03.338505', '2025-06-04 00:12:03.34+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (266, 1, 5, '2025-06-04 00:07:12.153128', '2025-06-04 00:12:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (267, 1, 5, '2025-06-04 00:07:12.153753', '2025-06-04 00:12:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (268, 1, 5, '2025-06-04 00:07:12.154307', '2025-06-04 00:12:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (269, 1, 5, '2025-06-04 00:07:12.154721', '2025-06-04 00:12:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (270, 1, 5, '2025-06-04 00:07:12.155099', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (271, 1, 5, '2025-06-04 00:07:12.155471', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (272, 1, 5, '2025-06-04 00:07:12.155892', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (273, 1, 5, '2025-06-04 00:07:12.156275', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (274, 1, 5, '2025-06-04 00:07:12.1567', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (275, 1, 5, '2025-06-04 00:07:12.15703', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (276, 1, 5, '2025-06-04 00:07:12.157389', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (277, 1, 5, '2025-06-04 00:07:12.157784', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (278, 1, 5, '2025-06-04 00:07:12.158177', '2025-06-04 00:12:12.16+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (279, 1, 5, '2025-06-04 00:11:13.729942', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (280, 1, 5, '2025-06-04 00:11:13.7312', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (281, 1, 5, '2025-06-04 00:11:13.73178', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (282, 1, 5, '2025-06-04 00:11:13.73229', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (283, 1, 5, '2025-06-04 00:11:13.73279', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (284, 1, 5, '2025-06-04 00:11:13.733276', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (285, 1, 5, '2025-06-04 00:11:13.733742', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (286, 1, 5, '2025-06-04 00:11:13.734191', '2025-06-04 00:16:13.73+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (287, 1, 5, '2025-06-04 00:11:26.500385', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (288, 1, 5, '2025-06-04 00:11:26.501236', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (289, 1, 5, '2025-06-04 00:11:26.50181', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (290, 1, 5, '2025-06-04 00:11:26.502297', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (291, 1, 5, '2025-06-04 00:11:26.502785', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (292, 1, 5, '2025-06-04 00:11:26.503183', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (293, 1, 5, '2025-06-04 00:11:26.503615', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (294, 1, 5, '2025-06-04 00:11:26.504014', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (295, 1, 5, '2025-06-04 00:11:26.504478', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (296, 1, 5, '2025-06-04 00:11:26.50491', '2025-06-04 00:16:26.5+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (297, 1, 5, '2025-06-04 00:11:26.505309', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (298, 1, 5, '2025-06-04 00:11:26.505737', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (299, 1, 5, '2025-06-04 00:11:26.506182', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (300, 1, 5, '2025-06-04 00:11:26.506835', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (301, 1, 5, '2025-06-04 00:11:26.507358', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (302, 1, 5, '2025-06-04 00:11:26.507811', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (303, 1, 5, '2025-06-04 00:11:26.508217', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (304, 1, 5, '2025-06-04 00:11:26.508607', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (305, 1, 5, '2025-06-04 00:11:26.508958', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (306, 1, 5, '2025-06-04 00:11:26.509381', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (307, 1, 5, '2025-06-04 00:11:26.509763', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (308, 1, 5, '2025-06-04 00:11:26.510151', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 22, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (309, 1, 5, '2025-06-04 00:11:26.510529', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 23, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (310, 1, 5, '2025-06-04 00:11:26.510879', '2025-06-04 00:16:26.51+02', NULL, NULL, 'map.movmentAction', '{"x": 24, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (311, 1, 5, '2025-06-04 00:12:09.796727', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (312, 1, 5, '2025-06-04 00:12:09.797757', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (313, 1, 5, '2025-06-04 00:12:09.798218', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (314, 1, 5, '2025-06-04 00:12:09.798683', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (315, 1, 5, '2025-06-04 00:12:09.799166', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (316, 1, 5, '2025-06-04 00:12:09.799688', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (317, 1, 5, '2025-06-04 00:12:09.80009', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (318, 1, 5, '2025-06-04 00:12:09.800587', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (319, 1, 5, '2025-06-04 00:12:09.800952', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (320, 1, 5, '2025-06-04 00:12:09.801311', '2025-06-04 00:17:09.8+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (321, 1, 5, '2025-06-04 00:12:38.046177', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (322, 1, 5, '2025-06-04 00:12:38.046756', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (323, 1, 5, '2025-06-04 00:12:38.047212', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (324, 1, 5, '2025-06-04 00:12:38.047574', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (325, 1, 5, '2025-06-04 00:12:38.048034', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (326, 1, 5, '2025-06-04 00:12:38.04841', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (327, 1, 5, '2025-06-04 00:12:38.04891', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (328, 1, 5, '2025-06-04 00:12:38.049277', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (329, 1, 5, '2025-06-04 00:12:38.049652', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (330, 1, 5, '2025-06-04 00:12:38.05006', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (331, 1, 5, '2025-06-04 00:12:38.050422', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (332, 1, 5, '2025-06-04 00:12:38.050916', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (333, 1, 5, '2025-06-04 00:12:38.051243', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (334, 1, 5, '2025-06-04 00:12:38.05156', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (335, 1, 5, '2025-06-04 00:12:38.051909', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (336, 1, 5, '2025-06-04 00:12:38.052226', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (337, 1, 5, '2025-06-04 00:12:38.052694', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (338, 1, 5, '2025-06-04 00:12:38.05303', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (339, 1, 5, '2025-06-04 00:12:38.053646', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (340, 1, 5, '2025-06-04 00:12:38.054018', '2025-06-04 00:17:38.05+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (341, 1, 5, '2025-06-04 00:22:15.165195', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (342, 1, 5, '2025-06-04 00:22:15.166714', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (343, 1, 5, '2025-06-04 00:22:15.168343', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (344, 1, 5, '2025-06-04 00:22:15.168994', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (345, 1, 5, '2025-06-04 00:22:15.171278', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (346, 1, 5, '2025-06-04 00:22:15.171969', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (347, 1, 5, '2025-06-04 00:22:15.172549', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (348, 1, 5, '2025-06-04 00:22:15.17323', '2025-06-04 00:27:15.17+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (349, 1, 5, '2025-06-04 00:22:24.774003', '2025-06-04 00:27:24.77+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (350, 1, 5, '2025-06-04 00:22:24.774654', '2025-06-04 00:27:24.77+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (351, 1, 5, '2025-06-04 00:22:24.775152', '2025-06-04 00:27:24.78+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (352, 1, 5, '2025-06-04 00:22:24.775562', '2025-06-04 00:27:24.78+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (353, 1, 5, '2025-06-04 00:22:24.776079', '2025-06-04 00:27:24.78+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (354, 1, 5, '2025-06-04 00:22:24.776545', '2025-06-04 00:27:24.78+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (355, 1, 5, '2025-06-04 00:22:24.776902', '2025-06-04 00:27:24.78+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (356, 1, 5, '2025-06-04 00:22:24.7773', '2025-06-04 00:27:24.78+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (357, 1, 5, '2025-06-04 00:22:24.777703', '2025-06-04 00:27:24.78+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (358, 1, 5, '2025-06-04 00:22:50.679185', '2025-06-04 00:27:50.68+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (359, 1, 5, '2025-06-04 00:22:50.680612', '2025-06-04 00:27:50.68+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (360, 1, 5, '2025-06-04 00:22:50.681042', '2025-06-04 00:27:50.68+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (361, 1, 5, '2025-06-04 00:22:50.681472', '2025-06-04 00:27:50.68+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (362, 1, 5, '2025-06-04 00:22:50.681895', '2025-06-04 00:27:50.68+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (363, 1, 5, '2025-06-04 00:22:50.682242', '2025-06-04 00:27:50.68+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (364, 1, 5, '2025-06-04 00:22:50.682643', '2025-06-04 00:27:50.68+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (365, 1, 5, '2025-06-04 00:23:22.249503', '2025-06-04 00:28:22.25+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (366, 1, 5, '2025-06-04 00:23:22.25194', '2025-06-04 00:28:22.25+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (367, 1, 5, '2025-06-04 00:23:22.252551', '2025-06-04 00:28:22.25+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (368, 1, 5, '2025-06-04 00:23:22.25328', '2025-06-04 00:28:22.25+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (369, 1, 5, '2025-06-04 00:23:22.253826', '2025-06-04 00:28:22.25+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (370, 1, 5, '2025-06-04 00:23:22.254379', '2025-06-04 00:28:22.25+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (371, 1, 5, '2025-06-04 00:23:22.254933', '2025-06-04 00:28:22.25+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (372, 1, 5, '2025-06-04 00:23:22.255499', '2025-06-04 00:28:22.26+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (373, 1, 5, '2025-06-04 00:23:22.256022', '2025-06-04 00:28:22.26+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (374, 1, 5, '2025-06-04 00:23:29.931669', '2025-06-04 00:28:29.93+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (375, 1, 5, '2025-06-04 00:23:29.932272', '2025-06-04 00:28:29.93+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (376, 1, 5, '2025-06-04 00:23:29.932753', '2025-06-04 00:28:29.93+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (377, 1, 5, '2025-06-04 00:23:29.933232', '2025-06-04 00:28:29.93+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (378, 1, 5, '2025-06-04 00:23:29.933671', '2025-06-04 00:28:29.93+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (379, 1, 5, '2025-06-04 00:23:29.934061', '2025-06-04 00:28:29.93+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (380, 1, 5, '2025-06-04 00:23:29.934448', '2025-06-04 00:28:29.93+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (381, 1, 5, '2025-06-04 00:24:47.568208', '2025-06-04 00:29:47.57+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (382, 1, 5, '2025-06-04 00:24:47.579851', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (383, 1, 5, '2025-06-04 00:24:47.580649', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (384, 1, 5, '2025-06-04 00:24:47.581209', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (385, 1, 5, '2025-06-04 00:24:47.58168', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (386, 1, 5, '2025-06-04 00:24:47.582097', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (387, 1, 5, '2025-06-04 00:24:47.582556', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (388, 1, 5, '2025-06-04 00:24:47.582994', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (389, 1, 5, '2025-06-04 00:24:47.58343', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (390, 1, 5, '2025-06-04 00:24:47.583877', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (391, 1, 5, '2025-06-04 00:24:47.584283', '2025-06-04 00:29:47.58+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (392, 1, 5, '2025-06-04 00:42:26.436848', '2025-06-04 00:47:26.44+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (393, 1, 5, '2025-06-04 00:42:26.439124', '2025-06-04 00:47:26.44+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (394, 1, 5, '2025-06-04 00:42:26.439664', '2025-06-04 00:47:26.44+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (395, 1, 5, '2025-06-04 00:42:26.440109', '2025-06-04 00:47:26.44+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (396, 1, 5, '2025-06-04 00:42:26.440511', '2025-06-04 00:47:26.44+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (397, 1, 5, '2025-06-04 00:42:38.948496', '2025-06-04 00:47:38.95+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (398, 1, 5, '2025-06-04 00:42:38.95997', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (399, 1, 5, '2025-06-04 00:42:38.960741', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (400, 1, 5, '2025-06-04 00:42:38.961289', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (401, 1, 5, '2025-06-04 00:42:38.961726', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (402, 1, 5, '2025-06-04 00:42:38.962159', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (403, 1, 5, '2025-06-04 00:42:38.962606', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (404, 1, 5, '2025-06-04 00:42:38.963163', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (405, 1, 5, '2025-06-04 00:42:38.963673', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (406, 1, 5, '2025-06-04 00:42:38.964144', '2025-06-04 00:47:38.96+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (407, 1, 5, '2025-06-04 00:44:34.843776', '2025-06-04 00:49:34.84+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (408, 1, 5, '2025-06-04 00:44:34.845137', '2025-06-04 00:49:34.85+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (409, 1, 5, '2025-06-04 00:44:34.846027', '2025-06-04 00:49:34.85+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (410, 1, 5, '2025-06-04 00:44:34.846444', '2025-06-04 00:49:34.85+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (411, 1, 5, '2025-06-04 00:44:34.846838', '2025-06-04 00:49:34.85+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (412, 1, 5, '2025-06-04 00:44:53.136285', '2025-06-04 00:49:53.14+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (413, 1, 5, '2025-06-04 00:44:53.138584', '2025-06-04 00:49:53.14+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (414, 1, 5, '2025-06-04 00:44:53.139313', '2025-06-04 00:49:53.14+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (415, 1, 5, '2025-06-04 00:44:53.147936', '2025-06-04 00:49:53.15+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (416, 1, 5, '2025-06-04 00:44:53.150539', '2025-06-04 00:49:53.15+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (417, 1, 5, '2025-06-04 00:44:53.152327', '2025-06-04 00:49:53.15+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (418, 1, 5, '2025-06-04 00:48:16.402433', '2025-06-04 00:53:16.4+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (419, 1, 5, '2025-06-04 00:48:16.404059', '2025-06-04 00:53:16.4+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (420, 1, 5, '2025-06-04 00:48:16.404513', '2025-06-04 00:53:16.4+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (421, 1, 5, '2025-06-04 00:48:16.404953', '2025-06-04 00:53:16.4+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (422, 1, 5, '2025-06-04 00:48:16.405438', '2025-06-04 00:53:16.41+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (423, 1, 5, '2025-06-04 00:48:16.405865', '2025-06-04 00:53:16.41+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (424, 1, 5, '2025-06-04 00:48:16.406303', '2025-06-04 00:53:16.41+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (425, 1, 5, '2025-06-04 00:48:16.406771', '2025-06-04 00:53:16.41+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (426, 1, 5, '2025-06-04 00:48:24.191891', '2025-06-04 00:53:24.19+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (427, 1, 5, '2025-06-04 00:48:24.192515', '2025-06-04 00:53:24.19+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (428, 1, 5, '2025-06-04 00:48:24.192978', '2025-06-04 00:53:24.19+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (429, 1, 5, '2025-06-04 00:48:24.193407', '2025-06-04 00:53:24.19+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (430, 1, 5, '2025-06-04 00:48:24.193915', '2025-06-04 00:53:24.19+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (431, 1, 5, '2025-06-04 00:48:24.194304', '2025-06-04 00:53:24.19+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (432, 1, 5, '2025-06-04 00:48:24.194742', '2025-06-04 00:53:24.19+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (433, 1, 5, '2025-06-04 00:48:24.195168', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (434, 1, 5, '2025-06-04 00:48:24.19564', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (435, 1, 5, '2025-06-04 00:48:24.196098', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (436, 1, 5, '2025-06-04 00:48:24.197492', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (437, 1, 5, '2025-06-04 00:48:24.197916', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (438, 1, 5, '2025-06-04 00:48:24.198332', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (439, 1, 5, '2025-06-04 00:48:24.198865', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (440, 1, 5, '2025-06-04 00:48:24.199233', '2025-06-04 00:53:24.2+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (441, 1, 5, '2025-06-04 00:50:26.950597', '2025-06-04 00:55:26.95+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (442, 1, 5, '2025-06-04 00:50:26.951941', '2025-06-04 00:55:26.95+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (443, 1, 5, '2025-06-04 00:50:26.952444', '2025-06-04 00:55:26.95+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (444, 1, 5, '2025-06-04 00:50:26.952864', '2025-06-04 00:55:26.95+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (445, 1, 5, '2025-06-04 00:50:26.953404', '2025-06-04 00:55:26.95+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (446, 1, 5, '2025-06-04 00:50:26.953776', '2025-06-04 00:55:26.95+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (447, 1, 5, '2025-06-04 00:50:26.954142', '2025-06-04 00:55:26.95+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (448, 1, 5, '2025-06-04 00:50:32.555237', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (449, 1, 5, '2025-06-04 00:50:32.555792', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (450, 1, 5, '2025-06-04 00:50:32.556318', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (451, 1, 5, '2025-06-04 00:50:32.556849', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (452, 1, 5, '2025-06-04 00:50:32.557294', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (453, 1, 5, '2025-06-04 00:50:32.557742', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (454, 1, 5, '2025-06-04 00:50:32.558207', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (455, 1, 5, '2025-06-04 00:50:32.558648', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (456, 1, 5, '2025-06-04 00:50:32.559056', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (457, 1, 5, '2025-06-04 00:50:32.559535', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (458, 1, 5, '2025-06-04 00:50:32.559986', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (459, 1, 5, '2025-06-04 00:50:32.560364', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (460, 1, 5, '2025-06-04 00:50:32.560759', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (461, 1, 5, '2025-06-04 00:50:32.561148', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (462, 1, 5, '2025-06-04 00:50:32.56168', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (463, 1, 5, '2025-06-04 00:50:32.562046', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (464, 1, 5, '2025-06-04 00:50:32.56246', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (465, 1, 5, '2025-06-04 00:50:32.562861', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (466, 1, 5, '2025-06-04 00:50:32.56329', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (467, 1, 5, '2025-06-04 00:50:32.563696', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (468, 1, 5, '2025-06-04 00:50:32.56409', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 22, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (469, 1, 5, '2025-06-04 00:50:32.564437', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 23, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (470, 1, 5, '2025-06-04 00:50:32.564805', '2025-06-04 00:55:32.56+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 24, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (471, 1, 5, '2025-06-04 00:50:32.56525', '2025-06-04 00:55:32.57+02', NULL, NULL, 'map.movmentAction', '{"x": 22, "y": 24, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (472, 1, 5, '2025-06-04 00:50:32.565619', '2025-06-04 00:55:32.57+02', NULL, NULL, 'map.movmentAction', '{"x": 23, "y": 25, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (473, 1, 5, '2025-06-04 00:50:32.565983', '2025-06-04 00:55:32.57+02', NULL, NULL, 'map.movmentAction', '{"x": 24, "y": 26, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (474, 1, 5, '2025-06-04 00:50:32.566518', '2025-06-04 00:55:32.57+02', NULL, NULL, 'map.movmentAction', '{"x": 25, "y": 27, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (475, 1, 5, '2025-06-04 00:50:32.567064', '2025-06-04 00:55:32.57+02', NULL, NULL, 'map.movmentAction', '{"x": 26, "y": 27, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (476, 1, 5, '2025-06-04 00:52:34.826595', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (477, 1, 5, '2025-06-04 00:52:34.828128', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (478, 1, 5, '2025-06-04 00:52:34.828779', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (479, 1, 5, '2025-06-04 00:52:34.829316', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (480, 1, 5, '2025-06-04 00:52:34.829852', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (481, 1, 5, '2025-06-04 00:52:34.830395', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (482, 1, 5, '2025-06-04 00:52:34.830982', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (483, 1, 5, '2025-06-04 00:52:34.83161', '2025-06-04 00:57:34.83+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (484, 1, 5, '2025-06-04 01:00:56.049142', '2025-06-04 01:05:56.05+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (485, 1, 5, '2025-06-04 01:00:56.051472', '2025-06-04 01:05:56.05+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (486, 1, 5, '2025-06-04 01:00:56.052194', '2025-06-04 01:05:56.05+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (487, 1, 5, '2025-06-04 01:00:56.052718', '2025-06-04 01:05:56.05+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (488, 1, 5, '2025-06-04 01:00:56.053198', '2025-06-04 01:05:56.05+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (489, 1, 5, '2025-06-04 01:00:56.054596', '2025-06-04 01:05:56.05+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (490, 1, 5, '2025-06-04 01:00:56.055203', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (491, 1, 5, '2025-06-04 01:00:56.055834', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (492, 1, 5, '2025-06-04 01:00:56.056315', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (493, 1, 5, '2025-06-04 01:00:56.05677', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (494, 1, 5, '2025-06-04 01:00:56.057496', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (495, 1, 5, '2025-06-04 01:00:56.058192', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (496, 1, 5, '2025-06-04 01:00:56.058824', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (497, 1, 5, '2025-06-04 01:00:56.060088', '2025-06-04 01:05:56.06+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (498, 1, 5, '2025-06-04 01:08:33.840624', '2025-06-04 01:13:33.84+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (499, 1, 5, '2025-06-04 01:08:33.842787', '2025-06-04 01:13:33.84+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (500, 1, 5, '2025-06-04 01:08:33.843427', '2025-06-04 01:13:33.84+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (501, 1, 5, '2025-06-04 01:08:33.843939', '2025-06-04 01:13:33.84+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (502, 1, 5, '2025-06-04 01:08:33.844442', '2025-06-04 01:13:33.84+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (503, 1, 5, '2025-06-04 01:08:33.844876', '2025-06-04 01:13:33.84+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (504, 1, 5, '2025-06-04 01:08:33.845323', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (505, 1, 5, '2025-06-04 01:08:33.84583', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (506, 1, 5, '2025-06-04 01:08:33.846307', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (507, 1, 5, '2025-06-04 01:08:33.846703', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (508, 1, 5, '2025-06-04 01:08:33.847069', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (509, 1, 5, '2025-06-04 01:08:33.847438', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (510, 1, 5, '2025-06-04 01:08:33.847944', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (511, 1, 5, '2025-06-04 01:08:33.848342', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (512, 1, 5, '2025-06-04 01:08:33.848724', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (513, 1, 5, '2025-06-04 01:08:33.849091', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (514, 1, 5, '2025-06-04 01:08:33.849446', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (515, 1, 5, '2025-06-04 01:08:33.849828', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (516, 1, 5, '2025-06-04 01:08:33.850216', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (517, 1, 5, '2025-06-04 01:08:33.850604', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (518, 1, 5, '2025-06-04 01:08:33.851047', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 22, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (519, 1, 5, '2025-06-04 01:08:33.851471', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 23, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (520, 1, 5, '2025-06-04 01:08:33.851915', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 24, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (521, 1, 5, '2025-06-04 01:08:33.852306', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 25, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (522, 1, 5, '2025-06-04 01:08:33.852751', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 26, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (523, 1, 5, '2025-06-04 01:08:33.853108', '2025-06-04 01:13:33.85+02', NULL, NULL, 'map.movmentAction', '{"x": 26, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (524, 1, 5, '2025-06-04 01:12:41.35388', '2025-06-04 01:17:41.35+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 24, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (525, 1, 5, '2025-06-04 01:12:41.356111', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 23, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (526, 1, 5, '2025-06-04 01:12:41.356956', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 22, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (527, 1, 5, '2025-06-04 01:12:41.357628', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (528, 1, 5, '2025-06-04 01:12:41.358383', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (529, 1, 5, '2025-06-04 01:12:41.359096', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (530, 1, 5, '2025-06-04 01:12:41.359829', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (531, 1, 5, '2025-06-04 01:12:41.360498', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (532, 1, 5, '2025-06-04 01:12:41.361109', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (533, 1, 5, '2025-06-04 01:12:41.361659', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (534, 1, 5, '2025-06-04 01:12:41.36222', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (535, 1, 5, '2025-06-04 01:12:41.362716', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (536, 1, 5, '2025-06-04 01:12:41.363405', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (537, 1, 5, '2025-06-04 01:12:41.363837', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (538, 1, 5, '2025-06-04 01:12:41.364368', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (539, 1, 5, '2025-06-04 01:12:41.364855', '2025-06-04 01:17:41.36+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (540, 1, 5, '2025-06-04 01:12:56.774944', '2025-06-04 01:17:56.77+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (541, 1, 5, '2025-06-04 01:12:56.775481', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (542, 1, 5, '2025-06-04 01:12:56.776065', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (543, 1, 5, '2025-06-04 01:12:56.776601', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (544, 1, 5, '2025-06-04 01:12:56.777129', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (545, 1, 5, '2025-06-04 01:12:56.777747', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (546, 1, 5, '2025-06-04 01:12:56.778333', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (547, 1, 5, '2025-06-04 01:12:56.778864', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (548, 1, 5, '2025-06-04 01:12:56.779375', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (549, 1, 5, '2025-06-04 01:12:56.779835', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (550, 1, 5, '2025-06-04 01:12:56.780349', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (551, 1, 5, '2025-06-04 01:12:56.780769', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (552, 1, 5, '2025-06-04 01:12:56.781364', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (553, 1, 5, '2025-06-04 01:12:56.781739', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (554, 1, 5, '2025-06-04 01:12:56.782179', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (555, 1, 5, '2025-06-04 01:12:56.782598', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (556, 1, 5, '2025-06-04 01:12:56.783023', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (557, 1, 5, '2025-06-04 01:12:56.783498', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (558, 1, 5, '2025-06-04 01:12:56.78392', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (559, 1, 5, '2025-06-04 01:12:56.784349', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (560, 1, 5, '2025-06-04 01:12:56.784739', '2025-06-04 01:17:56.78+02', NULL, NULL, 'map.movmentAction', '{"x": 22, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (561, 1, 5, '2025-06-04 01:12:56.785184', '2025-06-04 01:17:56.79+02', NULL, NULL, 'map.movmentAction', '{"x": 23, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (562, 1, 5, '2025-06-04 01:13:14.67247', '2025-06-04 01:18:14.67+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (563, 1, 5, '2025-06-04 01:13:14.673796', '2025-06-04 01:18:14.67+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (564, 1, 5, '2025-06-04 01:13:14.674438', '2025-06-04 01:18:14.67+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (565, 1, 5, '2025-06-04 01:13:14.674967', '2025-06-04 01:18:14.67+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (566, 1, 5, '2025-06-04 01:13:14.675673', '2025-06-04 01:18:14.68+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (567, 1, 5, '2025-06-04 01:13:14.677264', '2025-06-04 01:18:14.68+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (568, 1, 5, '2025-06-04 01:13:14.677787', '2025-06-04 01:18:14.68+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (569, 1, 5, '2025-06-04 01:15:11.423063', '2025-06-04 01:20:11.42+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (570, 1, 5, '2025-06-04 01:15:11.426066', '2025-06-04 01:20:11.43+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (571, 1, 5, '2025-06-04 01:15:11.426776', '2025-06-04 01:20:11.43+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (572, 1, 5, '2025-06-04 01:15:11.427475', '2025-06-04 01:20:11.43+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (573, 1, 5, '2025-06-04 01:15:11.431496', '2025-06-04 01:20:11.43+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (574, 1, 5, '2025-06-04 01:15:11.432369', '2025-06-04 01:20:11.43+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (575, 1, 5, '2025-06-04 01:15:11.433002', '2025-06-04 01:20:11.43+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (576, 1, 5, '2025-06-04 01:15:11.433724', '2025-06-04 01:20:11.43+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (577, 1, 5, '2025-06-04 21:39:13.846131', '2025-06-04 21:44:13.85+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (578, 1, 5, '2025-06-04 21:39:13.857492', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (579, 1, 5, '2025-06-04 21:39:13.858386', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (580, 1, 5, '2025-06-04 21:39:13.859205', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (581, 1, 5, '2025-06-04 21:39:13.860159', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (582, 1, 5, '2025-06-04 21:39:13.861296', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (583, 1, 5, '2025-06-04 21:39:13.861797', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (584, 1, 5, '2025-06-04 21:39:13.862191', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (585, 1, 5, '2025-06-04 21:39:13.863024', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (586, 1, 5, '2025-06-04 21:39:13.863427', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (587, 1, 5, '2025-06-04 21:39:13.863837', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (588, 1, 5, '2025-06-04 21:39:13.864183', '2025-06-04 21:44:13.86+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (589, 1, 5, '2025-06-04 21:39:13.865028', '2025-06-04 21:44:13.87+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (590, 1, 5, '2025-06-04 21:39:22.494246', '2025-06-04 21:44:22.49+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (591, 1, 5, '2025-06-04 21:39:22.494612', '2025-06-04 21:44:22.49+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (592, 1, 5, '2025-06-04 21:39:22.494927', '2025-06-04 21:44:22.49+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (593, 1, 5, '2025-06-04 21:39:22.495225', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (594, 1, 5, '2025-06-04 21:39:22.49551', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (595, 1, 5, '2025-06-04 21:39:22.495826', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (596, 1, 5, '2025-06-04 21:39:22.496097', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (597, 1, 5, '2025-06-04 21:39:22.496347', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (598, 1, 5, '2025-06-04 21:39:22.496743', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (599, 1, 5, '2025-06-04 21:39:22.49704', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (600, 1, 5, '2025-06-04 21:39:22.497317', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (601, 1, 5, '2025-06-04 21:39:22.497679', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (602, 1, 5, '2025-06-04 21:39:22.498172', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (603, 1, 5, '2025-06-04 21:39:22.498494', '2025-06-04 21:44:22.5+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (604, 1, 5, '2025-06-04 21:40:54.122166', '2025-06-04 21:45:54.12+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (605, 1, 5, '2025-06-04 21:40:54.123012', '2025-06-04 21:45:54.12+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (606, 1, 5, '2025-06-04 21:40:54.123382', '2025-06-04 21:45:54.12+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (607, 1, 5, '2025-06-04 21:40:54.123743', '2025-06-04 21:45:54.12+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (608, 1, 5, '2025-06-04 21:40:54.124069', '2025-06-04 21:45:54.12+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (609, 1, 5, '2025-06-04 21:40:54.124389', '2025-06-04 21:45:54.12+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (610, 1, 5, '2025-06-04 21:40:54.124714', '2025-06-04 21:45:54.12+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (611, 1, 5, '2025-06-04 21:40:54.12501', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (612, 1, 5, '2025-06-04 21:40:54.125297', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (613, 1, 5, '2025-06-04 21:40:54.125588', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (614, 1, 5, '2025-06-04 21:40:54.125939', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (615, 1, 5, '2025-06-04 21:40:54.126214', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (616, 1, 5, '2025-06-04 21:40:54.126483', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (617, 1, 5, '2025-06-04 21:40:54.126753', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (618, 1, 5, '2025-06-04 21:40:54.127012', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (619, 1, 5, '2025-06-04 21:40:54.127262', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (620, 1, 5, '2025-06-04 21:40:54.127514', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 21, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (621, 1, 5, '2025-06-04 21:40:54.127782', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 22, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (622, 1, 5, '2025-06-04 21:40:54.128045', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 23, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (623, 1, 5, '2025-06-04 21:40:54.1283', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 24, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (624, 1, 5, '2025-06-04 21:40:54.128559', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 16, "y": 25, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (625, 1, 5, '2025-06-04 21:40:54.128821', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 17, "y": 26, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (626, 1, 5, '2025-06-04 21:40:54.12905', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 18, "y": 27, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (627, 1, 5, '2025-06-04 21:40:54.129307', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 19, "y": 28, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (628, 1, 5, '2025-06-04 21:40:54.129567', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 20, "y": 29, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (629, 1, 5, '2025-06-04 21:40:54.129821', '2025-06-04 21:45:54.13+02', NULL, NULL, 'map.movmentAction', '{"x": 21, "y": 30, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (630, 1, 5, '2025-06-04 21:52:52.94149', '2025-06-04 21:57:52.94+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (631, 1, 5, '2025-06-04 21:52:52.943306', '2025-06-04 21:57:52.94+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (632, 1, 5, '2025-06-04 21:52:52.943674', '2025-06-04 21:57:52.94+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (633, 1, 5, '2025-06-04 21:52:52.944016', '2025-06-04 21:57:52.94+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (634, 1, 5, '2025-06-04 21:52:52.944356', '2025-06-04 21:57:52.94+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (635, 1, 5, '2025-06-04 21:52:52.944684', '2025-06-04 21:57:52.94+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (636, 1, 5, '2025-06-04 21:52:59.532935', '2025-06-04 21:57:59.53+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (637, 1, 5, '2025-06-04 21:52:59.533317', '2025-06-04 21:57:59.53+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (638, 1, 5, '2025-06-04 21:52:59.533679', '2025-06-04 21:57:59.53+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (639, 1, 5, '2025-06-04 21:52:59.53399', '2025-06-04 21:57:59.53+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (640, 1, 5, '2025-06-04 21:52:59.534304', '2025-06-04 21:57:59.53+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (641, 1, 5, '2025-06-04 21:52:59.534665', '2025-06-04 21:57:59.53+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (642, 1, 5, '2025-06-04 21:52:59.534974', '2025-06-04 21:57:59.53+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (643, 1, 5, '2025-06-04 21:52:59.535291', '2025-06-04 21:57:59.54+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (644, 1, 5, '2025-06-04 21:52:59.53568', '2025-06-04 21:57:59.54+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (645, 1, 5, '2025-06-04 21:53:09.083929', '2025-06-04 21:58:09.08+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (646, 1, 5, '2025-06-04 21:53:09.084495', '2025-06-04 21:58:09.08+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (647, 1, 5, '2025-06-04 21:53:09.085194', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (648, 1, 5, '2025-06-04 21:53:09.085584', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (649, 1, 5, '2025-06-04 21:53:09.085942', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (650, 1, 5, '2025-06-04 21:53:09.086293', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (651, 1, 5, '2025-06-04 21:53:09.086607', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (652, 1, 5, '2025-06-04 21:53:09.086884', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (653, 1, 5, '2025-06-04 21:53:09.087167', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (654, 1, 5, '2025-06-04 21:53:09.087575', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (655, 1, 5, '2025-06-04 21:53:09.087874', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (656, 1, 5, '2025-06-04 21:53:09.088172', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (657, 1, 5, '2025-06-04 21:53:09.088489', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (658, 1, 5, '2025-06-04 21:53:09.088811', '2025-06-04 21:58:09.09+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (659, 1, 5, '2025-06-04 21:55:12.143902', '2025-06-04 22:00:12.14+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (660, 1, 5, '2025-06-04 21:55:12.144853', '2025-06-04 22:00:12.14+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (661, 1, 5, '2025-06-04 21:55:12.145242', '2025-06-04 22:00:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (662, 1, 5, '2025-06-04 21:55:12.146189', '2025-06-04 22:00:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (663, 1, 5, '2025-06-04 21:55:12.146537', '2025-06-04 22:00:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (664, 1, 5, '2025-06-04 21:55:12.146837', '2025-06-04 22:00:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (665, 1, 5, '2025-06-04 21:55:12.147155', '2025-06-04 22:00:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (666, 1, 5, '2025-06-04 21:55:12.147509', '2025-06-04 22:00:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (667, 1, 5, '2025-06-04 21:55:12.14783', '2025-06-04 22:00:12.15+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (668, 1, 5, '2025-06-04 21:55:26.255963', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (669, 1, 5, '2025-06-04 21:55:26.256462', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (670, 1, 5, '2025-06-04 21:55:26.256853', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (671, 1, 5, '2025-06-04 21:55:26.257267', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (672, 1, 5, '2025-06-04 21:55:26.257633', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (673, 1, 5, '2025-06-04 21:55:26.257966', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (674, 1, 5, '2025-06-04 21:55:26.258292', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (675, 1, 5, '2025-06-04 21:55:26.258666', '2025-06-04 22:00:26.26+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (676, 1, 5, '2025-06-04 21:55:29.978545', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (677, 1, 5, '2025-06-04 21:55:29.979168', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (678, 1, 5, '2025-06-04 21:55:29.979584', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (679, 1, 5, '2025-06-04 21:55:29.979969', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (680, 1, 5, '2025-06-04 21:55:29.980353', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (681, 1, 5, '2025-06-04 21:55:29.980798', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (682, 1, 5, '2025-06-04 21:55:29.981221', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (683, 1, 5, '2025-06-04 21:55:29.981651', '2025-06-04 22:00:29.98+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (684, 1, 5, '2025-06-04 22:11:38.788775', '2025-06-04 22:16:38.79+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (685, 1, 5, '2025-06-04 22:11:38.791556', '2025-06-04 22:16:38.79+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (686, 1, 5, '2025-06-04 22:11:38.792315', '2025-06-04 22:16:38.79+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (687, 1, 5, '2025-06-04 22:11:38.793646', '2025-06-04 22:16:38.79+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (688, 1, 5, '2025-06-04 22:11:38.794809', '2025-06-04 22:16:38.79+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (689, 1, 5, '2025-06-04 22:11:38.795443', '2025-06-04 22:16:38.8+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (690, 1, 5, '2025-06-04 22:11:38.795998', '2025-06-04 22:16:38.8+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (691, 1, 5, '2025-06-04 22:11:38.796456', '2025-06-04 22:16:38.8+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (692, 1, 5, '2025-06-04 22:31:19.851388', '2025-06-04 22:36:19.85+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (693, 1, 5, '2025-06-04 22:31:19.853308', '2025-06-04 22:36:19.85+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (694, 1, 5, '2025-06-04 22:31:19.853868', '2025-06-04 22:36:19.85+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (695, 1, 5, '2025-06-04 22:31:19.854569', '2025-06-04 22:36:19.85+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (696, 1, 5, '2025-06-04 22:31:19.85502', '2025-06-04 22:36:19.86+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (697, 1, 5, '2025-06-04 22:31:19.855499', '2025-06-04 22:36:19.86+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (698, 1, 5, '2025-06-04 22:31:19.856688', '2025-06-04 22:36:19.86+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (699, 1, 5, '2025-06-04 22:31:25.174073', '2025-06-04 22:36:25.17+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (700, 1, 5, '2025-06-04 22:31:25.174846', '2025-06-04 22:36:25.17+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (701, 1, 5, '2025-06-04 22:31:25.175471', '2025-06-04 22:36:25.18+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (702, 1, 5, '2025-06-04 22:31:25.179072', '2025-06-04 22:36:25.18+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (703, 1, 5, '2025-06-04 22:41:22.567506', '2025-06-04 22:46:22.57+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (704, 1, 5, '2025-06-04 22:41:22.569373', '2025-06-04 22:46:22.57+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (705, 1, 5, '2025-06-04 22:41:22.56986', '2025-06-04 22:46:22.57+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (706, 1, 5, '2025-06-04 22:41:22.5703', '2025-06-04 22:46:22.57+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (707, 1, 5, '2025-06-04 22:41:22.570783', '2025-06-04 22:46:22.57+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (708, 1, 5, '2025-06-04 22:41:22.57121', '2025-06-04 22:46:22.57+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (709, 1, 5, '2025-06-04 22:41:29.991661', '2025-06-04 22:46:29.99+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (710, 1, 5, '2025-06-04 22:41:29.994257', '2025-06-04 22:46:29.99+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (711, 1, 5, '2025-06-04 22:41:29.994734', '2025-06-04 22:46:29.99+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (712, 1, 5, '2025-06-04 22:41:29.995128', '2025-06-04 22:46:30+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (713, 1, 5, '2025-06-04 22:41:29.995588', '2025-06-04 22:46:30+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (714, 1, 5, '2025-06-04 22:41:29.996032', '2025-06-04 22:46:30+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (715, 1, 5, '2025-06-04 22:41:29.996451', '2025-06-04 22:46:30+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (716, 1, 5, '2025-06-04 22:41:45.023105', '2025-06-04 22:46:45.02+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (717, 1, 5, '2025-06-04 22:41:45.023944', '2025-06-04 22:46:45.02+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (718, 1, 5, '2025-06-04 22:41:45.024472', '2025-06-04 22:46:45.02+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (719, 1, 5, '2025-06-04 22:41:45.024946', '2025-06-04 22:46:45.02+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (720, 1, 5, '2025-06-04 22:41:45.025348', '2025-06-04 22:46:45.03+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (721, 1, 5, '2025-06-04 22:41:45.025682', '2025-06-04 22:46:45.03+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (722, 1, 5, '2025-06-04 22:41:45.025997', '2025-06-04 22:46:45.03+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (723, 1, 5, '2025-06-04 22:41:52.794349', '2025-06-04 22:46:52.79+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (724, 1, 5, '2025-06-04 22:41:52.795136', '2025-06-04 22:46:52.8+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (725, 1, 5, '2025-06-04 22:41:52.795573', '2025-06-04 22:46:52.8+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (726, 1, 5, '2025-06-04 22:41:52.795935', '2025-06-04 22:46:52.8+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (727, 1, 5, '2025-06-04 22:41:52.796278', '2025-06-04 22:46:52.8+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (728, 1, 5, '2025-06-04 22:41:52.79659', '2025-06-04 22:46:52.8+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (729, 1, 5, '2025-06-04 22:41:52.796911', '2025-06-04 22:46:52.8+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (730, 1, 5, '2025-06-04 22:41:52.797267', '2025-06-04 22:46:52.8+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (731, 1, 5, '2025-06-04 22:42:02.674923', '2025-06-04 22:47:02.67+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (732, 1, 5, '2025-06-04 22:42:02.675556', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (733, 1, 5, '2025-06-04 22:42:02.675947', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (734, 1, 5, '2025-06-04 22:42:02.676389', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (735, 1, 5, '2025-06-04 22:42:02.6768', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (736, 1, 5, '2025-06-04 22:42:02.677224', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (737, 1, 5, '2025-06-04 22:42:02.677613', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (738, 1, 5, '2025-06-04 22:42:02.677941', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (739, 1, 5, '2025-06-04 22:42:02.678247', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (740, 1, 5, '2025-06-04 22:42:02.678574', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (741, 1, 5, '2025-06-04 22:42:02.678899', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (742, 1, 5, '2025-06-04 22:42:02.679187', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (743, 1, 5, '2025-06-04 22:42:02.679501', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (744, 1, 5, '2025-06-04 22:42:02.680332', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (745, 1, 5, '2025-06-04 22:42:02.680672', '2025-06-04 22:47:02.68+02', NULL, NULL, 'map.movmentAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (746, 1, 5, '2025-06-04 22:42:16.428876', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (747, 1, 5, '2025-06-04 22:42:16.429451', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (748, 1, 5, '2025-06-04 22:42:16.430202', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (749, 1, 5, '2025-06-04 22:42:16.430629', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (750, 1, 5, '2025-06-04 22:42:16.432399', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (751, 1, 5, '2025-06-04 22:42:16.432895', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (752, 1, 5, '2025-06-04 22:42:16.433377', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (753, 1, 5, '2025-06-04 22:42:16.433824', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (754, 1, 5, '2025-06-04 22:42:16.434457', '2025-06-04 22:47:16.43+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (755, 1, 5, '2025-06-04 22:42:32.063996', '2025-06-04 22:47:32.06+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (756, 1, 5, '2025-06-04 22:42:32.064475', '2025-06-04 22:47:32.06+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (757, 1, 5, '2025-06-04 22:42:32.064859', '2025-06-04 22:47:32.06+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (758, 1, 5, '2025-06-04 22:42:32.065351', '2025-06-04 22:47:32.07+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (759, 1, 5, '2025-06-04 22:42:32.065731', '2025-06-04 22:47:32.07+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (760, 1, 5, '2025-06-04 22:42:32.066143', '2025-06-04 22:47:32.07+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (761, 1, 5, '2025-06-04 22:42:32.066563', '2025-06-04 22:47:32.07+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (762, 1, 5, '2025-06-04 22:42:32.067062', '2025-06-04 22:47:32.07+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (763, 1, 5, '2025-06-04 22:42:32.067404', '2025-06-04 22:47:32.07+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (764, 1, 5, '2025-06-04 22:42:32.067716', '2025-06-04 22:47:32.07+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (765, 1, 5, '2025-06-04 22:42:38.734971', '2025-06-04 22:47:38.73+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (766, 1, 5, '2025-06-04 22:42:38.735439', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (767, 1, 5, '2025-06-04 22:42:38.735856', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (768, 1, 5, '2025-06-04 22:42:38.736277', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (769, 1, 5, '2025-06-04 22:42:38.736666', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (770, 1, 5, '2025-06-04 22:42:38.737099', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (771, 1, 5, '2025-06-04 22:42:38.737485', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (772, 1, 5, '2025-06-04 22:42:38.737857', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (773, 1, 5, '2025-06-04 22:42:38.738219', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (774, 1, 5, '2025-06-04 22:42:38.73862', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (775, 1, 5, '2025-06-04 22:42:38.738963', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (776, 1, 5, '2025-06-04 22:42:38.739426', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (777, 1, 5, '2025-06-04 22:42:38.739896', '2025-06-04 22:47:38.74+02', NULL, NULL, 'map.movmentAction', '{"x": 14, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (778, 1, 5, '2025-06-04 22:42:46.397978', '2025-06-04 22:47:46.4+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (779, 1, 5, '2025-06-04 22:42:46.398595', '2025-06-04 22:47:46.4+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (780, 1, 5, '2025-06-04 22:42:46.399088', '2025-06-04 22:47:46.4+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (781, 1, 5, '2025-06-04 22:42:46.399652', '2025-06-04 22:47:46.4+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (782, 1, 5, '2025-06-04 22:42:46.40009', '2025-06-04 22:47:46.4+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 1, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (783, 1, 5, '2025-06-04 22:42:50.749083', '2025-06-04 22:47:50.75+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (784, 1, 5, '2025-06-04 22:42:50.750032', '2025-06-04 22:47:50.75+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (785, 1, 5, '2025-06-04 22:42:50.750471', '2025-06-04 22:47:50.75+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (786, 1, 5, '2025-06-04 22:42:50.750886', '2025-06-04 22:47:50.75+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (787, 1, 5, '2025-06-04 22:42:50.751254', '2025-06-04 22:47:50.75+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (788, 1, 5, '2025-06-04 22:42:50.751584', '2025-06-04 22:47:50.75+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (789, 1, 5, '2025-06-04 22:42:56.149714', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (790, 1, 5, '2025-06-04 22:42:56.150638', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (791, 1, 5, '2025-06-04 22:42:56.151273', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (792, 1, 5, '2025-06-04 22:42:56.151658', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (793, 1, 5, '2025-06-04 22:42:56.152028', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (794, 1, 5, '2025-06-04 22:42:56.152353', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (795, 1, 5, '2025-06-04 22:42:56.15267', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (796, 1, 5, '2025-06-04 22:42:56.153015', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (797, 1, 5, '2025-06-04 22:42:56.153367', '2025-06-04 22:47:56.15+02', NULL, NULL, 'map.movmentAction', '{"x": 10, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (798, 1, 5, '2025-06-04 22:43:01.987503', '2025-06-04 22:48:01.99+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (799, 1, 5, '2025-06-04 22:43:01.988638', '2025-06-04 22:48:01.99+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (800, 1, 5, '2025-06-04 22:43:01.989145', '2025-06-04 22:48:01.99+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (801, 1, 5, '2025-06-04 22:43:01.989753', '2025-06-04 22:48:01.99+02', NULL, NULL, 'map.movmentAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (802, 1, 5, '2025-06-04 22:43:01.99034', '2025-06-04 22:48:01.99+02', NULL, NULL, 'map.movmentAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (803, 1, 5, '2025-06-04 22:43:01.990785', '2025-06-04 22:48:01.99+02', NULL, NULL, 'map.movmentAction', '{"x": 7, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (804, 1, 5, '2025-06-04 22:43:01.991145', '2025-06-04 22:48:01.99+02', NULL, NULL, 'map.movmentAction', '{"x": 8, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (805, 1, 5, '2025-06-04 22:44:14.807143', '2025-06-04 22:49:14.81+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (806, 1, 5, '2025-06-04 22:44:14.808214', '2025-06-04 22:49:14.81+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (807, 1, 5, '2025-06-04 22:44:14.808596', '2025-06-04 22:49:14.81+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (808, 1, 5, '2025-06-04 22:44:20.361584', '2025-06-04 22:49:20.36+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (809, 1, 5, '2025-06-04 22:44:20.362125', '2025-06-04 22:49:20.36+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (810, 1, 5, '2025-06-04 22:44:20.362512', '2025-06-04 22:49:20.36+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (811, 1, 1, '2025-06-04 22:44:37.330353', '2025-06-04 22:49:37.33+02', NULL, NULL, 'map.movmentAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (812, 1, 1, '2025-06-04 22:44:37.330955', '2025-06-04 22:49:37.33+02', NULL, NULL, 'map.movmentAction', '{"x": 3, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (813, 1, 1, '2025-06-04 22:44:37.331552', '2025-06-04 22:49:37.33+02', NULL, NULL, 'map.movmentAction', '{"x": 4, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (814, 1, 5, '2025-06-05 20:34:30.881779', '2025-06-05 20:39:30.88+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (815, 1, 5, '2025-06-05 20:34:30.889127', '2025-06-05 20:39:30.89+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (816, 1, 5, '2025-06-05 20:34:30.889519', '2025-06-05 20:39:30.89+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (817, 1, 5, '2025-06-05 20:34:30.88983', '2025-06-05 20:39:30.89+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (818, 1, 5, '2025-06-05 20:34:30.89081', '2025-06-05 20:39:30.89+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (819, 1, 5, '2025-06-05 20:34:30.891207', '2025-06-05 20:39:30.89+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (820, 1, 5, '2025-06-05 20:34:35.405884', '2025-06-05 20:39:35.41+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (821, 1, 5, '2025-06-05 20:34:35.406345', '2025-06-05 20:39:35.41+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (822, 1, 5, '2025-06-05 20:34:35.406649', '2025-06-05 20:39:35.41+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (823, 1, 5, '2025-06-05 20:34:35.406924', '2025-06-05 20:39:35.41+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (824, 1, 5, '2025-06-05 20:34:35.407216', '2025-06-05 20:39:35.41+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (825, 1, 5, '2025-06-05 20:34:35.407528', '2025-06-05 20:39:35.41+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (826, 1, 5, '2025-06-05 20:34:35.407898', '2025-06-05 20:39:35.41+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (827, 1, 5, '2025-06-05 20:34:50.08206', '2025-06-05 20:39:50.08+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (828, 1, 5, '2025-06-05 20:34:50.082842', '2025-06-05 20:39:50.08+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (829, 1, 5, '2025-06-05 20:34:50.08366', '2025-06-05 20:39:50.08+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (830, 1, 5, '2025-06-05 20:34:50.085842', '2025-06-05 20:39:50.09+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (831, 1, 5, '2025-06-05 20:34:50.086679', '2025-06-05 20:39:50.09+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (832, 1, 5, '2025-06-05 21:01:06.316345', '2025-06-05 21:06:06.32+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (833, 1, 5, '2025-06-05 21:01:06.319454', '2025-06-05 21:06:06.32+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (834, 1, 5, '2025-06-05 21:01:06.319829', '2025-06-05 21:06:06.32+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (835, 1, 5, '2025-06-05 21:01:06.320143', '2025-06-05 21:06:06.32+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (836, 1, 5, '2025-06-05 21:01:06.32046', '2025-06-05 21:06:06.32+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (837, 1, 5, '2025-06-05 21:01:06.320804', '2025-06-05 21:06:06.32+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (838, 1, 5, '2025-06-05 21:01:06.321115', '2025-06-05 21:06:06.32+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (839, 1, 5, '2025-06-18 19:59:56.88923', '2025-06-18 20:04:56.89+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (840, 1, 5, '2025-06-18 19:59:56.898429', '2025-06-18 20:04:56.9+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (841, 1, 5, '2025-06-18 19:59:56.898877', '2025-06-18 20:04:56.9+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (842, 1, 5, '2025-06-18 19:59:56.899215', '2025-06-18 20:04:56.9+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (843, 1, 5, '2025-06-18 19:59:56.899558', '2025-06-18 20:04:56.9+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (844, 1, 5, '2025-06-18 19:59:56.899867', '2025-06-18 20:04:56.9+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (845, 1, 5, '2025-06-18 20:50:35.297888', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (846, 1, 5, '2025-06-18 20:50:35.299606', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (847, 1, 5, '2025-06-18 20:50:35.299991', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (848, 1, 5, '2025-06-18 20:50:35.300312', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (849, 1, 5, '2025-06-18 20:50:35.300623', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (850, 1, 5, '2025-06-18 20:50:35.300912', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (851, 1, 5, '2025-06-18 20:50:35.301193', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (852, 1, 5, '2025-06-18 20:50:35.301488', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (853, 1, 5, '2025-06-18 20:50:35.301776', '2025-06-18 20:55:35.3+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (854, 1, 5, '2025-06-18 23:34:23.750099', '2025-06-18 23:39:23.75+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (855, 1, 5, '2025-06-18 23:34:23.756752', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (856, 1, 5, '2025-06-18 23:34:23.757118', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (857, 1, 5, '2025-06-18 23:34:23.757429', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (858, 1, 5, '2025-06-18 23:34:23.757724', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (859, 1, 5, '2025-06-18 23:34:23.758058', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (860, 1, 5, '2025-06-18 23:34:23.758415', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (861, 1, 5, '2025-06-18 23:34:23.75872', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (862, 1, 5, '2025-06-18 23:34:23.759039', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (863, 1, 5, '2025-06-18 23:34:23.75933', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (864, 1, 5, '2025-06-18 23:34:23.759608', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (865, 1, 5, '2025-06-18 23:34:23.759885', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (866, 1, 5, '2025-06-18 23:34:23.76029', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (867, 1, 5, '2025-06-18 23:34:23.760572', '2025-06-18 23:39:23.76+02', NULL, NULL, 'map.movementAction', '{"x": 15, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (868, 1, 5, '2025-06-19 16:21:10.335404', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (869, 1, 5, '2025-06-19 16:21:10.338696', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (870, 1, 5, '2025-06-19 16:21:10.339076', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (871, 1, 5, '2025-06-19 16:21:10.339388', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (872, 1, 5, '2025-06-19 16:21:10.339685', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (873, 1, 5, '2025-06-19 16:21:10.339955', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (874, 1, 5, '2025-06-19 16:21:10.340248', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (875, 1, 5, '2025-06-19 16:21:10.340506', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (876, 1, 5, '2025-06-19 16:21:10.340782', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (877, 1, 5, '2025-06-19 16:21:10.341051', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (878, 1, 5, '2025-06-19 16:21:10.341347', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (879, 1, 5, '2025-06-19 16:21:10.341597', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (880, 1, 5, '2025-06-19 16:21:10.341978', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (881, 1, 5, '2025-06-19 16:21:10.342257', '2025-06-19 16:26:10.34+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (882, 1, 5, '2025-06-19 16:21:17.200231', '2025-06-19 16:26:17.2+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (883, 1, 5, '2025-06-19 16:21:17.200596', '2025-06-19 16:26:17.2+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (884, 1, 5, '2025-06-19 16:21:17.200862', '2025-06-19 16:26:17.2+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (885, 1, 5, '2025-06-19 16:21:17.201109', '2025-06-19 16:26:17.2+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (886, 1, 5, '2025-06-19 16:21:17.201348', '2025-06-19 16:26:17.2+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (887, 1, 5, '2025-06-19 16:21:17.201592', '2025-06-19 16:26:17.2+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (888, 1, 5, '2025-06-19 16:21:17.201827', '2025-06-19 16:26:17.2+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (889, 1, 5, '2025-06-19 16:21:24.931507', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (890, 1, 5, '2025-06-19 16:21:24.932292', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (891, 1, 5, '2025-06-19 16:21:24.932705', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (892, 1, 5, '2025-06-19 16:21:24.933036', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (893, 1, 5, '2025-06-19 16:21:24.933846', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (894, 1, 5, '2025-06-19 16:21:24.934178', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (895, 1, 5, '2025-06-19 16:21:24.934556', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (896, 1, 5, '2025-06-19 16:21:24.93493', '2025-06-19 16:26:24.93+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (897, 1, 5, '2025-06-19 16:21:24.935209', '2025-06-19 16:26:24.94+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (898, 1, 5, '2025-06-19 16:57:06.518717', '2025-06-19 17:02:06.52+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (899, 1, 5, '2025-06-19 16:58:34.613206', '2025-06-19 17:03:34.61+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (900, 1, 5, '2025-06-19 16:58:34.614377', '2025-06-19 17:03:34.61+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (901, 1, 5, '2025-06-19 16:58:34.614758', '2025-06-19 17:03:34.61+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (902, 1, 5, '2025-06-19 16:58:34.615077', '2025-06-19 17:03:34.62+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (903, 1, 5, '2025-06-19 17:04:55.422468', '2025-06-19 17:09:55.42+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (904, 1, 5, '2025-06-19 17:04:55.424235', '2025-06-19 17:09:55.42+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (905, 1, 5, '2025-06-19 17:04:55.424729', '2025-06-19 17:09:55.42+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 1, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (906, 1, 5, '2025-06-19 18:33:41.250735', '2025-06-19 18:38:41.25+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (907, 1, 5, '2025-06-19 18:33:41.252559', '2025-06-19 18:38:41.25+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (908, 1, 5, '2025-06-19 18:33:41.252989', '2025-06-19 18:38:41.25+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (909, 1, 5, '2025-06-19 18:33:41.253345', '2025-06-19 18:38:41.25+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (910, 1, 5, '2025-06-19 18:33:41.253682', '2025-06-19 18:38:41.25+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (911, 1, 5, '2025-06-19 19:51:57.874528', '2025-06-19 19:56:57.87+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (912, 1, 5, '2025-06-19 19:51:57.884792', '2025-06-19 19:56:57.88+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (913, 1, 5, '2025-06-19 19:51:57.885411', '2025-06-19 19:56:57.89+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (914, 1, 5, '2025-06-19 19:51:57.885856', '2025-06-19 19:56:57.89+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (915, 1, 5, '2025-06-19 19:52:05.391833', '2025-06-19 19:57:05.39+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (916, 1, 5, '2025-06-19 19:52:05.392562', '2025-06-19 19:57:05.39+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (917, 1, 5, '2025-06-19 19:52:05.393045', '2025-06-19 19:57:05.39+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (918, 1, 5, '2025-06-19 19:52:05.394543', '2025-06-19 19:57:05.39+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (919, 1, 5, '2025-06-19 19:52:05.395137', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (920, 1, 5, '2025-06-19 19:52:05.395639', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (921, 1, 5, '2025-06-19 19:52:05.396007', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (922, 1, 5, '2025-06-19 19:52:05.39638', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (923, 1, 5, '2025-06-19 19:52:05.396813', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (924, 1, 5, '2025-06-19 19:52:05.397136', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (925, 1, 5, '2025-06-19 19:52:05.397474', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (926, 1, 5, '2025-06-19 19:52:05.397794', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (927, 1, 5, '2025-06-19 19:52:05.398104', '2025-06-19 19:57:05.4+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (928, 1, 5, '2025-06-19 19:58:19.55596', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (929, 1, 5, '2025-06-19 19:58:19.557387', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (930, 1, 5, '2025-06-19 19:58:19.557814', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (931, 1, 5, '2025-06-19 19:58:19.558131', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (932, 1, 5, '2025-06-19 19:58:19.558424', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (933, 1, 5, '2025-06-19 19:58:19.558786', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (934, 1, 5, '2025-06-19 19:58:19.559074', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (935, 1, 5, '2025-06-19 19:58:19.559488', '2025-06-19 20:03:19.56+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (936, 1, 5, '2025-06-19 20:11:41.5629', '2025-06-19 20:16:41.56+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (937, 1, 5, '2025-06-19 20:11:41.564235', '2025-06-19 20:16:41.56+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (938, 1, 5, '2025-06-19 20:11:41.564563', '2025-06-19 20:16:41.56+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (939, 1, 5, '2025-06-19 20:11:41.564848', '2025-06-19 20:16:41.56+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (940, 1, 5, '2025-06-19 20:11:41.565119', '2025-06-19 20:16:41.57+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (941, 1, 5, '2025-06-19 20:11:41.565384', '2025-06-19 20:16:41.57+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (942, 1, 5, '2025-06-19 20:11:41.565657', '2025-06-19 20:16:41.57+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (943, 1, 5, '2025-06-19 21:06:03.234195', '2025-06-19 21:11:03.23+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (944, 1, 5, '2025-06-19 21:06:03.238124', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (945, 1, 5, '2025-06-19 21:06:03.238649', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (946, 1, 5, '2025-06-19 21:06:03.239064', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (947, 1, 5, '2025-06-19 21:06:03.239508', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (948, 1, 5, '2025-06-19 21:06:03.239993', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (949, 1, 5, '2025-06-19 21:06:03.240421', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (950, 1, 5, '2025-06-19 21:06:03.240904', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (951, 1, 5, '2025-06-19 21:06:03.24133', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (952, 1, 5, '2025-06-19 21:06:03.241734', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (953, 1, 5, '2025-06-19 21:06:03.24218', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (954, 1, 5, '2025-06-19 21:06:03.242561', '2025-06-19 21:11:03.24+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (955, 1, 5, '2025-06-19 21:06:15.731559', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (956, 1, 5, '2025-06-19 21:06:15.732094', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (957, 1, 5, '2025-06-19 21:06:15.73262', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (958, 1, 5, '2025-06-19 21:06:15.733002', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (959, 1, 5, '2025-06-19 21:06:15.733414', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (960, 1, 5, '2025-06-19 21:06:15.73376', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (961, 1, 5, '2025-06-19 21:06:15.734113', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (962, 1, 5, '2025-06-19 21:06:15.734434', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (963, 1, 5, '2025-06-19 21:06:15.734921', '2025-06-19 21:11:15.73+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (964, 1, 5, '2025-06-19 21:06:15.735556', '2025-06-19 21:11:15.74+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (965, 1, 5, '2025-06-19 21:06:15.736669', '2025-06-19 21:11:15.74+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (966, 1, 5, '2025-06-19 21:06:15.737074', '2025-06-19 21:11:15.74+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (967, 1, 5, '2025-06-19 21:38:31.800878', '2025-06-19 21:43:31.8+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (968, 1, 5, '2025-06-19 21:38:31.802652', '2025-06-19 21:43:31.8+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (969, 1, 5, '2025-06-19 21:38:31.803231', '2025-06-19 21:43:31.8+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (970, 1, 5, '2025-06-19 21:38:31.803791', '2025-06-19 21:43:31.8+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (971, 1, 5, '2025-06-19 21:38:31.804209', '2025-06-19 21:43:31.8+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (972, 1, 5, '2025-06-19 21:38:31.804892', '2025-06-19 21:43:31.8+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (973, 1, 5, '2025-06-19 21:41:15.204935', '2025-06-19 21:46:15.2+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (974, 1, 5, '2025-06-19 21:41:15.209374', '2025-06-19 21:46:15.21+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (975, 1, 5, '2025-06-19 21:41:15.210404', '2025-06-19 21:46:15.21+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (976, 1, 5, '2025-06-19 21:41:15.21198', '2025-06-19 21:46:15.21+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (977, 1, 5, '2025-06-24 19:25:22.278295', '2025-06-24 19:30:22.28+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (978, 1, 5, '2025-06-24 19:25:22.291659', '2025-06-24 19:30:22.29+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (979, 1, 5, '2025-06-24 19:25:22.292122', '2025-06-24 19:30:22.29+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (980, 1, 5, '2025-06-24 19:25:22.292417', '2025-06-24 19:30:22.29+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (981, 1, 5, '2025-06-24 19:25:22.292728', '2025-06-24 19:30:22.29+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (982, 1, 5, '2025-06-24 19:25:22.293059', '2025-06-24 19:30:22.29+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (983, 1, 5, '2025-06-24 19:25:22.293419', '2025-06-24 19:30:22.29+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (984, 1, 5, '2025-06-24 19:25:22.293678', '2025-06-24 19:30:22.29+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (985, 1, 5, '2025-06-24 19:25:27.914047', '2025-06-24 19:30:27.91+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (986, 1, 5, '2025-06-24 19:25:27.914462', '2025-06-24 19:30:27.91+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (987, 1, 5, '2025-06-24 19:25:27.914852', '2025-06-24 19:30:27.91+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (988, 1, 5, '2025-06-24 19:25:27.915218', '2025-06-24 19:30:27.92+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (989, 1, 5, '2025-06-24 19:25:27.915556', '2025-06-24 19:30:27.92+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (990, 1, 5, '2025-06-24 19:25:27.915856', '2025-06-24 19:30:27.92+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (991, 1, 5, '2025-06-24 19:25:27.91613', '2025-06-24 19:30:27.92+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (992, 1, 5, '2025-06-24 19:25:27.916497', '2025-06-24 19:30:27.92+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (993, 1, 5, '2025-06-24 19:31:44.056698', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (994, 1, 5, '2025-06-24 19:31:44.058012', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (995, 1, 5, '2025-06-24 19:31:44.058353', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (996, 1, 5, '2025-06-24 19:31:44.058654', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (997, 1, 5, '2025-06-24 19:31:44.058941', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (998, 1, 5, '2025-06-24 19:31:44.05922', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (999, 1, 5, '2025-06-24 19:31:44.059518', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1000, 1, 5, '2025-06-24 19:31:44.05984', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1001, 1, 5, '2025-06-24 19:31:44.060127', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1002, 1, 5, '2025-06-24 19:31:44.060871', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1003, 1, 5, '2025-06-24 19:31:44.061127', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1004, 1, 5, '2025-06-24 19:31:44.061415', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1005, 1, 5, '2025-06-24 19:31:44.06168', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1006, 1, 5, '2025-06-24 19:31:44.061926', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1007, 1, 5, '2025-06-24 19:31:44.062161', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1008, 1, 5, '2025-06-24 19:31:44.062389', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 16, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1009, 1, 5, '2025-06-24 19:31:44.062628', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1010, 1, 5, '2025-06-24 19:31:44.062892', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1011, 1, 5, '2025-06-24 19:31:44.063133', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 19, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1012, 1, 5, '2025-06-24 19:31:44.063368', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 20, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1013, 1, 5, '2025-06-24 19:31:44.063605', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1014, 1, 5, '2025-06-24 19:31:44.063838', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 22, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1015, 1, 5, '2025-06-24 19:31:44.064071', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1016, 1, 5, '2025-06-24 19:31:44.064297', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 20, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1017, 1, 5, '2025-06-24 19:31:44.064537', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1018, 1, 5, '2025-06-24 19:31:44.064768', '2025-06-24 19:36:44.06+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1019, 1, 5, '2025-06-24 19:31:44.065122', '2025-06-24 19:36:44.07+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1020, 1, 5, '2025-06-24 19:31:44.065676', '2025-06-24 19:36:44.07+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1021, 1, 5, '2025-06-24 19:33:35.812078', '2025-06-24 19:38:35.81+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1022, 1, 5, '2025-06-24 19:33:35.813286', '2025-06-24 19:38:35.81+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1023, 1, 5, '2025-06-24 19:33:35.813663', '2025-06-24 19:38:35.81+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1024, 1, 5, '2025-06-24 19:33:35.813973', '2025-06-24 19:38:35.81+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1025, 1, 5, '2025-06-24 19:33:35.81429', '2025-06-24 19:38:35.81+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1026, 1, 5, '2025-06-24 19:33:35.814575', '2025-06-24 19:38:35.81+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1027, 1, 5, '2025-06-24 19:33:35.814843', '2025-06-24 19:38:35.81+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1028, 1, 5, '2025-06-24 19:33:35.815089', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1029, 1, 5, '2025-06-24 19:33:35.815334', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1030, 1, 5, '2025-06-24 19:33:35.815576', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1031, 1, 5, '2025-06-24 19:33:35.815823', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1032, 1, 5, '2025-06-24 19:33:35.81606', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1033, 1, 5, '2025-06-24 19:33:35.816291', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1034, 1, 5, '2025-06-24 19:33:35.816674', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1035, 1, 5, '2025-06-24 19:33:35.816921', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1036, 1, 5, '2025-06-24 19:33:35.817161', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 16, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1037, 1, 5, '2025-06-24 19:33:35.81739', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1038, 1, 5, '2025-06-24 19:33:35.817635', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1039, 1, 5, '2025-06-24 19:33:35.81787', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 19, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1040, 1, 5, '2025-06-24 19:33:35.818102', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 20, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1041, 1, 5, '2025-06-24 19:33:35.818337', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1042, 1, 5, '2025-06-24 19:33:35.818572', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 22, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1043, 1, 5, '2025-06-24 19:33:35.818808', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 23, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1044, 1, 5, '2025-06-24 19:33:35.819041', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 24, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1045, 1, 5, '2025-06-24 19:33:35.819297', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 25, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1046, 1, 5, '2025-06-24 19:33:35.819577', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 26, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1047, 1, 5, '2025-06-24 19:33:35.819831', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 27, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1048, 1, 5, '2025-06-24 19:33:35.820072', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 28, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1049, 1, 5, '2025-06-24 19:33:35.820311', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 29, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1050, 1, 5, '2025-06-24 19:33:35.820595', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 30, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1051, 1, 5, '2025-06-24 19:33:35.820834', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 29, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1052, 1, 5, '2025-06-24 19:33:35.821071', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 29, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1053, 1, 5, '2025-06-24 19:33:35.821302', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 28, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1054, 1, 5, '2025-06-24 19:33:35.821629', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 29, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1055, 1, 5, '2025-06-24 19:33:35.821883', '2025-06-24 19:38:35.82+02', NULL, NULL, 'map.movementAction', '{"x": 30, "y": 1, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1056, 1, 5, '2025-06-28 10:34:22.258114', '2025-06-28 10:39:22.26+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1057, 1, 5, '2025-06-28 10:34:22.267383', '2025-06-28 10:39:22.27+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1058, 1, 5, '2025-06-28 10:34:22.268045', '2025-06-28 10:39:22.27+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1059, 1, 5, '2025-06-28 10:34:22.268514', '2025-06-28 10:39:22.27+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1060, 1, 5, '2025-06-28 10:34:22.26894', '2025-06-28 10:39:22.27+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1061, 1, 5, '2025-06-28 10:34:22.269288', '2025-06-28 10:39:22.27+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1062, 1, 5, '2025-06-28 10:34:43.368088', '2025-06-28 10:39:43.37+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1063, 1, 5, '2025-06-28 10:34:43.368689', '2025-06-28 10:39:43.37+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1064, 1, 5, '2025-06-28 10:34:43.369743', '2025-06-28 10:39:43.37+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1065, 1, 5, '2025-06-28 10:34:43.370733', '2025-06-28 10:39:43.37+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1066, 1, 5, '2025-06-28 10:34:43.371187', '2025-06-28 10:39:43.37+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1067, 1, 5, '2025-06-28 10:47:21.222187', '2025-06-28 10:52:21.22+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1068, 1, 5, '2025-06-28 10:47:21.227496', '2025-06-28 10:52:21.23+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1069, 1, 5, '2025-06-28 10:47:21.228228', '2025-06-28 10:52:21.23+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1070, 1, 5, '2025-06-28 10:47:36.315872', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1071, 1, 5, '2025-06-28 10:47:36.317532', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1072, 1, 5, '2025-06-28 10:47:36.318564', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1073, 1, 5, '2025-06-28 10:47:36.320001', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1074, 1, 5, '2025-06-28 10:47:36.321657', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1075, 1, 5, '2025-06-28 10:47:36.322386', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1076, 1, 5, '2025-06-28 10:47:36.322815', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1077, 1, 5, '2025-06-28 10:47:36.323263', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1078, 1, 5, '2025-06-28 10:47:36.323919', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1079, 1, 5, '2025-06-28 10:47:36.324563', '2025-06-28 10:52:36.32+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1080, 1, 5, '2025-06-28 10:47:36.325294', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1081, 1, 5, '2025-06-28 10:47:36.325778', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1082, 1, 5, '2025-06-28 10:47:36.327658', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1083, 1, 5, '2025-06-28 10:47:36.328179', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1084, 1, 5, '2025-06-28 10:47:36.328689', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1085, 1, 5, '2025-06-28 10:47:36.32918', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 16, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1086, 1, 5, '2025-06-28 10:47:36.330122', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1087, 1, 5, '2025-06-28 10:47:36.330597', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1088, 1, 5, '2025-06-28 10:47:36.331063', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 19, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1089, 1, 5, '2025-06-28 10:47:36.331469', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 20, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1090, 1, 5, '2025-06-28 10:47:36.332484', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1091, 1, 5, '2025-06-28 10:47:36.332842', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 22, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1092, 1, 5, '2025-06-28 10:47:36.333234', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 23, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1093, 1, 5, '2025-06-28 10:47:36.333812', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 24, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1094, 1, 5, '2025-06-28 10:47:36.334324', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 25, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1095, 1, 5, '2025-06-28 10:47:36.334801', '2025-06-28 10:52:36.33+02', NULL, NULL, 'map.movementAction', '{"x": 26, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1096, 1, 5, '2025-06-28 10:47:36.335232', '2025-06-28 10:52:36.34+02', NULL, NULL, 'map.movementAction', '{"x": 26, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1097, 1, 5, '2025-06-28 10:47:36.335692', '2025-06-28 10:52:36.34+02', NULL, NULL, 'map.movementAction', '{"x": 27, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1098, 1, 5, '2025-06-28 10:47:36.336108', '2025-06-28 10:52:36.34+02', NULL, NULL, 'map.movementAction', '{"x": 28, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1099, 1, 5, '2025-06-28 10:47:36.337332', '2025-06-28 10:52:36.34+02', NULL, NULL, 'map.movementAction', '{"x": 29, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1100, 1, 5, '2025-06-28 10:47:36.337746', '2025-06-28 10:52:36.34+02', NULL, NULL, 'map.movementAction', '{"x": 30, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1101, 1, 5, '2025-06-28 10:49:35.715135', '2025-06-28 10:54:35.72+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1102, 1, 5, '2025-06-28 10:49:35.717008', '2025-06-28 10:54:35.72+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1103, 1, 5, '2025-06-28 10:49:35.717984', '2025-06-28 10:54:35.72+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1104, 1, 5, '2025-06-28 10:49:35.720422', '2025-06-28 10:54:35.72+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1105, 1, 5, '2025-06-28 10:49:35.721132', '2025-06-28 10:54:35.72+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1106, 1, 5, '2025-06-28 10:57:34.997571', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1107, 1, 5, '2025-06-28 10:57:34.999226', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1108, 1, 5, '2025-06-28 10:57:35.000469', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1109, 1, 5, '2025-06-28 10:57:35.000945', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1110, 1, 5, '2025-06-28 10:57:35.00135', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1111, 1, 5, '2025-06-28 10:57:35.001922', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1112, 1, 5, '2025-06-28 10:57:35.002622', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1113, 1, 5, '2025-06-28 10:57:35.003094', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1114, 1, 5, '2025-06-28 10:57:35.003467', '2025-06-28 11:02:35+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1115, 1, 5, '2025-06-28 10:58:30.659221', '2025-06-28 11:03:30.66+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1116, 1, 5, '2025-06-28 10:58:30.660603', '2025-06-28 11:03:30.66+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1117, 1, 5, '2025-06-28 10:58:30.661085', '2025-06-28 11:03:30.66+02', NULL, NULL, 'map.movementAction', '{"x": 1, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1118, 1, 5, '2025-06-28 10:58:30.661547', '2025-06-28 11:03:30.66+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1119, 1, 5, '2025-06-28 12:03:16.9059', '2025-06-28 12:08:16.91+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1120, 1, 5, '2025-06-28 12:03:16.907138', '2025-06-28 12:08:16.91+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1121, 1, 5, '2025-06-28 12:03:16.910111', '2025-06-28 12:08:16.91+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1122, 1, 5, '2025-06-28 12:03:16.9106', '2025-06-28 12:08:16.91+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1123, 1, 5, '2025-06-28 12:03:16.911072', '2025-06-28 12:08:16.91+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1124, 1, 5, '2025-06-28 12:07:42.534688', '2025-06-28 12:12:42.53+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1125, 1, 5, '2025-06-28 12:07:42.536252', '2025-06-28 12:12:42.54+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1126, 1, 5, '2025-06-28 12:07:42.536747', '2025-06-28 12:12:42.54+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1127, 1, 5, '2025-06-28 12:07:42.537189', '2025-06-28 12:12:42.54+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1128, 1, 5, '2025-06-28 12:07:42.537592', '2025-06-28 12:12:42.54+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1129, 1, 5, '2025-06-28 12:07:42.538096', '2025-06-28 12:12:42.54+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1130, 1, 5, '2025-06-28 12:07:59.598054', '2025-06-28 12:12:59.6+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1131, 1, 5, '2025-06-28 12:07:59.598811', '2025-06-28 12:12:59.6+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1132, 1, 5, '2025-06-28 12:07:59.599373', '2025-06-28 12:12:59.6+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1133, 1, 5, '2025-06-28 12:07:59.600096', '2025-06-28 12:12:59.6+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1134, 1, 5, '2025-06-28 12:07:59.600586', '2025-06-28 12:12:59.6+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1135, 1, 5, '2025-06-28 12:07:59.60101', '2025-06-28 12:12:59.6+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1136, 1, 5, '2025-06-28 12:08:08.930022', '2025-06-28 12:13:08.93+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1137, 1, 5, '2025-06-28 12:08:08.930609', '2025-06-28 12:13:08.93+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1138, 1, 5, '2025-06-28 12:08:08.931041', '2025-06-28 12:13:08.93+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1139, 1, 5, '2025-06-28 12:08:08.931462', '2025-06-28 12:13:08.93+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1140, 1, 5, '2025-06-28 12:08:08.931843', '2025-06-28 12:13:08.93+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1141, 1, 5, '2025-06-28 12:08:08.932229', '2025-06-28 12:13:08.93+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1142, 1, 5, '2025-06-28 12:32:58.841063', '2025-06-28 12:37:58.84+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1143, 1, 5, '2025-06-28 12:32:58.842447', '2025-06-28 12:37:58.84+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1144, 1, 5, '2025-06-28 12:32:58.842916', '2025-06-28 12:37:58.84+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1145, 1, 5, '2025-06-28 12:32:58.843337', '2025-06-28 12:37:58.84+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1146, 1, 5, '2025-06-28 12:32:58.843758', '2025-06-28 12:37:58.84+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1147, 1, 5, '2025-06-28 12:32:58.844157', '2025-06-28 12:37:58.84+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1148, 1, 5, '2025-06-28 12:33:00.297817', '2025-06-28 12:38:00.3+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1149, 1, 5, '2025-06-28 12:33:00.298402', '2025-06-28 12:38:00.3+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1150, 1, 5, '2025-06-28 12:33:00.298913', '2025-06-28 12:38:00.3+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1151, 1, 5, '2025-06-28 12:33:00.299403', '2025-06-28 12:38:00.3+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1152, 1, 5, '2025-06-28 12:33:00.299929', '2025-06-28 12:38:00.3+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1153, 1, 5, '2025-06-28 12:33:00.300428', '2025-06-28 12:38:00.3+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1154, 1, 5, '2025-06-28 12:40:09.335295', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1155, 1, 5, '2025-06-28 12:40:09.336566', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1156, 1, 5, '2025-06-28 12:40:09.337059', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1157, 1, 5, '2025-06-28 12:40:09.337559', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1158, 1, 5, '2025-06-28 12:40:09.338017', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1159, 1, 5, '2025-06-28 12:40:09.338469', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1160, 1, 5, '2025-06-28 12:40:09.338948', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1161, 1, 5, '2025-06-28 12:40:09.33942', '2025-06-28 12:45:09.34+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1162, 1, 5, '2025-06-28 12:40:15.381133', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1163, 1, 5, '2025-06-28 12:40:15.381801', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1164, 1, 5, '2025-06-28 12:40:15.382321', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1165, 1, 5, '2025-06-28 12:40:15.382759', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1166, 1, 5, '2025-06-28 12:40:15.383195', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1167, 1, 5, '2025-06-28 12:40:15.383587', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1168, 1, 5, '2025-06-28 12:40:15.383963', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1169, 1, 5, '2025-06-28 12:40:15.384323', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1170, 1, 5, '2025-06-28 12:40:15.384687', '2025-06-28 12:45:15.38+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1171, 1, 5, '2025-06-28 12:40:15.385084', '2025-06-28 12:45:15.39+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1172, 1, 5, '2025-06-28 12:40:15.385429', '2025-06-28 12:45:15.39+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1173, 1, 5, '2025-06-28 12:40:54.968593', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1174, 1, 5, '2025-06-28 12:40:54.969681', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1175, 1, 5, '2025-06-28 12:40:54.970193', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1176, 1, 5, '2025-06-28 12:40:54.970616', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1177, 1, 5, '2025-06-28 12:40:54.971222', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1178, 1, 5, '2025-06-28 12:40:54.971862', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1179, 1, 5, '2025-06-28 12:40:54.972366', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1180, 1, 5, '2025-06-28 12:40:54.972918', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1181, 1, 5, '2025-06-28 12:40:54.973372', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1182, 1, 5, '2025-06-28 12:40:54.973835', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1183, 1, 5, '2025-06-28 12:40:54.974246', '2025-06-28 12:45:54.97+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 4, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1184, 1, 5, '2025-06-28 12:43:16.97265', '2025-06-28 12:48:16.97+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1185, 1, 5, '2025-06-28 12:43:16.974398', '2025-06-28 12:48:16.97+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1186, 1, 5, '2025-06-28 12:43:16.974971', '2025-06-28 12:48:16.97+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1187, 1, 5, '2025-06-28 12:43:16.975503', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1188, 1, 5, '2025-06-28 12:43:16.975931', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1189, 1, 5, '2025-06-28 12:43:16.97632', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1190, 1, 5, '2025-06-28 12:43:16.976705', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1191, 1, 5, '2025-06-28 12:43:16.977059', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1192, 1, 5, '2025-06-28 12:43:16.97743', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1193, 1, 5, '2025-06-28 12:43:16.97778', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1194, 1, 5, '2025-06-28 12:43:16.978109', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1195, 1, 5, '2025-06-28 12:43:16.97844', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1196, 1, 5, '2025-06-28 12:43:16.978787', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1197, 1, 5, '2025-06-28 12:43:16.979128', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 15, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1198, 1, 5, '2025-06-28 12:43:16.97948', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 16, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1199, 1, 5, '2025-06-28 12:43:16.979822', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 17, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1200, 1, 5, '2025-06-28 12:43:16.98016', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 18, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1201, 1, 5, '2025-06-28 12:43:16.980593', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 19, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1202, 1, 5, '2025-06-28 12:43:16.980977', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 20, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1203, 1, 5, '2025-06-28 12:43:16.981365', '2025-06-28 12:48:16.98+02', NULL, NULL, 'map.movementAction', '{"x": 19, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1204, 1, 5, '2025-06-28 12:46:05.215239', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1205, 1, 5, '2025-06-28 12:46:05.216426', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1206, 1, 5, '2025-06-28 12:46:05.217034', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1207, 1, 5, '2025-06-28 12:46:05.217554', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1208, 1, 5, '2025-06-28 12:46:05.218125', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1209, 1, 5, '2025-06-28 12:46:05.21856', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1210, 1, 5, '2025-06-28 12:46:05.219126', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1211, 1, 5, '2025-06-28 12:46:05.219842', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1212, 1, 5, '2025-06-28 12:46:05.220315', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1213, 1, 5, '2025-06-28 12:46:05.220797', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 14, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1214, 1, 5, '2025-06-28 12:46:05.221303', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 15, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1215, 1, 5, '2025-06-28 12:46:05.221741', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 16, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1216, 1, 5, '2025-06-28 12:46:05.222357', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 17, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1217, 1, 5, '2025-06-28 12:46:05.222802', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 18, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1218, 1, 5, '2025-06-28 12:46:05.223221', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 19, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1219, 1, 5, '2025-06-28 12:46:05.223599', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1220, 1, 5, '2025-06-28 12:46:05.22402', '2025-06-28 12:51:05.22+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 20, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1221, 1, 5, '2025-06-28 12:46:16.65822', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1222, 1, 5, '2025-06-28 12:46:16.658871', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1223, 1, 5, '2025-06-28 12:46:16.659343', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1224, 1, 5, '2025-06-28 12:46:16.659755', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1225, 1, 5, '2025-06-28 12:46:16.66015', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1226, 1, 5, '2025-06-28 12:46:16.660546', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1227, 1, 5, '2025-06-28 12:46:16.660921', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1228, 1, 5, '2025-06-28 12:46:16.661293', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1229, 1, 5, '2025-06-28 12:46:16.661761', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1230, 1, 5, '2025-06-28 12:46:16.662157', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1231, 1, 5, '2025-06-28 12:46:16.662565', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1232, 1, 5, '2025-06-28 12:46:16.66293', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1233, 1, 5, '2025-06-28 12:46:16.663295', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1234, 1, 5, '2025-06-28 12:46:16.663734', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 13, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1235, 1, 5, '2025-06-28 12:46:16.664142', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 15, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1236, 1, 5, '2025-06-28 12:46:16.664513', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 16, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1237, 1, 5, '2025-06-28 12:46:16.664901', '2025-06-28 12:51:16.66+02', NULL, NULL, 'map.movementAction', '{"x": 17, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1238, 1, 5, '2025-06-28 12:46:16.665311', '2025-06-28 12:51:16.67+02', NULL, NULL, 'map.movementAction', '{"x": 18, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1239, 1, 5, '2025-06-28 12:46:16.66569', '2025-06-28 12:51:16.67+02', NULL, NULL, 'map.movementAction', '{"x": 19, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1240, 1, 5, '2025-06-28 12:46:16.666764', '2025-06-28 12:51:16.67+02', NULL, NULL, 'map.movementAction', '{"x": 20, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1241, 1, 5, '2025-06-28 12:46:16.667135', '2025-06-28 12:51:16.67+02', NULL, NULL, 'map.movementAction', '{"x": 21, "y": 10, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1242, 1, 5, '2025-06-28 12:46:16.667514', '2025-06-28 12:51:16.67+02', NULL, NULL, 'map.movementAction', '{"x": 22, "y": 11, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1243, 1, 5, '2025-06-28 12:46:16.667904', '2025-06-28 12:51:16.67+02', NULL, NULL, 'map.movementAction', '{"x": 23, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1244, 1, 5, '2025-06-28 12:46:16.668292', '2025-06-28 12:51:16.67+02', NULL, NULL, 'map.movementAction', '{"x": 24, "y": 12, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1245, 1, 5, '2025-06-28 12:50:26.989057', '2025-06-28 12:55:26.99+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1246, 1, 5, '2025-06-28 12:50:26.990396', '2025-06-28 12:55:26.99+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1247, 1, 5, '2025-06-28 12:50:26.990865', '2025-06-28 12:55:26.99+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1248, 1, 5, '2025-06-28 12:50:26.991331', '2025-06-28 12:55:26.99+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1249, 1, 5, '2025-06-28 13:57:23.804145', '2025-06-28 14:02:23.8+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1250, 1, 5, '2025-06-28 13:57:23.807404', '2025-06-28 14:02:23.81+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1251, 1, 5, '2025-06-28 13:57:23.808331', '2025-06-28 14:02:23.81+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1252, 1, 5, '2025-06-28 13:57:23.809398', '2025-06-28 14:02:23.81+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1253, 1, 5, '2025-06-28 13:57:28.690344', '2025-06-28 14:02:28.69+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1254, 1, 5, '2025-06-28 13:57:28.691427', '2025-06-28 14:02:28.69+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1255, 1, 5, '2025-06-28 13:57:28.692056', '2025-06-28 14:02:28.69+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1256, 1, 5, '2025-06-28 13:57:28.692848', '2025-06-28 14:02:28.69+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1257, 1, 5, '2025-06-28 13:57:28.693372', '2025-06-28 14:02:28.69+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1258, 1, 5, '2025-06-30 22:27:42.44253', '2025-06-30 22:32:42.44+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1259, 1, 5, '2025-06-30 22:27:42.452903', '2025-06-30 22:32:42.45+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1260, 1, 5, '2025-06-30 22:27:42.453515', '2025-06-30 22:32:42.45+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1261, 1, 5, '2025-06-30 22:27:42.454016', '2025-06-30 22:32:42.45+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1262, 1, 5, '2025-06-30 22:27:42.45451', '2025-06-30 22:32:42.45+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1263, 1, 5, '2025-06-30 23:24:16.436885', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 5, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1264, 1, 5, '2025-06-30 23:24:16.439007', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1265, 1, 5, '2025-06-30 23:24:16.439749', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1266, 1, 5, '2025-06-30 23:24:16.441', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1267, 1, 5, '2025-06-30 23:24:16.441865', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1268, 1, 5, '2025-06-30 23:24:16.442373', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 7, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1269, 1, 5, '2025-06-30 23:24:16.44287', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 8, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1270, 1, 5, '2025-06-30 23:24:16.443313', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 9, "y": 9, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1271, 1, 5, '2025-06-30 23:24:16.44367', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 10, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1272, 1, 5, '2025-06-30 23:24:16.444711', '2025-06-30 23:29:16.44+02', NULL, NULL, 'map.movementAction', '{"x": 11, "y": 8, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1273, 1, 5, '2025-06-30 23:24:16.445116', '2025-06-30 23:29:16.45+02', NULL, NULL, 'map.movementAction', '{"x": 12, "y": 7, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1274, 1, 5, '2025-06-30 23:24:16.445682', '2025-06-30 23:29:16.45+02', NULL, NULL, 'map.movementAction', '{"x": 13, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1275, 1, 5, '2025-06-30 23:24:16.446101', '2025-06-30 23:29:16.45+02', NULL, NULL, 'map.movementAction', '{"x": 14, "y": 6, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1276, 1, 1, '2025-07-01 03:06:24.792785', '2025-07-01 03:11:24.79+02', NULL, NULL, 'map.movementAction', '{"x": 2, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1277, 1, 1, '2025-07-01 03:06:24.802364', '2025-07-01 03:11:24.8+02', NULL, NULL, 'map.movementAction', '{"x": 3, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1278, 1, 1, '2025-07-01 03:06:24.803419', '2025-07-01 03:11:24.8+02', NULL, NULL, 'map.movementAction', '{"x": 4, "y": 3, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1279, 1, 1, '2025-07-01 03:06:24.804612', '2025-07-01 03:11:24.8+02', NULL, NULL, 'map.movementAction', '{"x": 5, "y": 2, "playerId": 1}');
INSERT INTO tasks.tasks VALUES (1280, 1, 1, '2025-07-01 03:06:24.805394', '2025-07-01 03:11:24.81+02', NULL, NULL, 'map.movementAction', '{"x": 6, "y": 2, "playerId": 1}');


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 249
-- Name: abilities_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.abilities_id_seq', 1, true);


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 277
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.roles_id_seq', 1, true);


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 245
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.skills_id_seq', 1, true);


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 247
-- Name: stats_id_seq; Type: SEQUENCE SET; Schema: attributes; Owner: postgres
--

SELECT pg_catalog.setval('attributes.stats_id_seq', 1, false);


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 224
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.accounts_id_seq', 1, false);


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 226
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.sessions_id_seq', 1, false);


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: postgres
--

SELECT pg_catalog.setval('auth.users_id_seq', 28, true);


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 275
-- Name: inventory_container_types_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.inventory_container_types_id_seq', 4, false);


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 241
-- Name: inventory_containers_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.inventory_containers_id_seq', 2, true);


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 243
-- Name: inventory_slots_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.inventory_slots_id_seq', 23, true);


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 271
-- Name: item_stats_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.item_stats_id_seq', 1, false);


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 269
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: items; Owner: postgres
--

SELECT pg_catalog.setval('items.items_id_seq', 1, true);


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 261
-- Name: building_types_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.building_types_id_seq', 4, true);


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 259
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.buildings_id_seq', 8, true);


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 255
-- Name: cities_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.cities_id_seq', 2, true);


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 263
-- Name: district_types_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.district_types_id_seq', 1, true);


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 265
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.districts_id_seq', 1, true);


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 239
-- Name: landscape_types_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.landscape_types_id_seq', 9, true);


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 230
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.maps_id_seq', 1, true);


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 232
-- Name: terrain_types_id_seq; Type: SEQUENCE SET; Schema: map; Owner: postgres
--

SELECT pg_catalog.setval('map.terrain_types_id_seq', 7, true);


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 253
-- Name: player_abilities_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.player_abilities_id_seq', 1, true);


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 251
-- Name: player_skills_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.player_skills_id_seq', 1, true);


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 237
-- Name: player_stats_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.player_stats_id_seq', 1, false);


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 235
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: players; Owner: postgres
--

SELECT pg_catalog.setval('players.players_id_seq', 3, true);


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 285
-- Name: status_types_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.status_types_id_seq', 6, true);


--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 282
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: tasks; Owner: postgres
--

SELECT pg_catalog.setval('tasks.tasks_id_seq', 1280, true);


--
-- TOC entry 4903 (class 2606 OID 16938)
-- Name: abilities abilities_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.abilities
    ADD CONSTRAINT abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 4934 (class 2606 OID 17267)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4899 (class 2606 OID 16924)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- TOC entry 4901 (class 2606 OID 16931)
-- Name: stats stats_pkey; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (id);


--
-- TOC entry 4930 (class 2606 OID 17235)
-- Name: ability_requirements unique_requirement; Type: CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_requirements
    ADD CONSTRAINT unique_requirement PRIMARY KEY (ability_id, requirement_type, requirement_id);


--
-- TOC entry 4873 (class 2606 OID 16478)
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- TOC entry 4875 (class 2606 OID 16485)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4877 (class 2606 OID 16519)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4879 (class 2606 OID 16517)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4871 (class 2606 OID 16469)
-- Name: verification_token verification_token_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.verification_token
    ADD CONSTRAINT verification_token_pkey PRIMARY KEY (identifier, token);


--
-- TOC entry 4928 (class 2606 OID 17211)
-- Name: inventory_container_roles inventory_container_owners_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_container_roles
    ADD CONSTRAINT inventory_container_owners_pkey PRIMARY KEY (inventory_container_id, player_id);


--
-- TOC entry 4932 (class 2606 OID 17256)
-- Name: inventory_container_types inventory_container_types_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_container_types
    ADD CONSTRAINT inventory_container_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4893 (class 2606 OID 16888)
-- Name: inventory_containers inventory_containers_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_containers
    ADD CONSTRAINT inventory_containers_pkey PRIMARY KEY (id);


--
-- TOC entry 4895 (class 2606 OID 16900)
-- Name: inventory_slots inventory_slots_inventory_container_id_row_col_key; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_slots
    ADD CONSTRAINT inventory_slots_inventory_container_id_row_col_key UNIQUE (inventory_container_id, "row", col);


--
-- TOC entry 4897 (class 2606 OID 16898)
-- Name: inventory_slots inventory_slots_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.inventory_slots
    ADD CONSTRAINT inventory_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 4926 (class 2606 OID 17192)
-- Name: item_stats item_stats_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.item_stats
    ADD CONSTRAINT item_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 4924 (class 2606 OID 17185)
-- Name: items items_pkey; Type: CONSTRAINT; Schema: items; Owner: postgres
--

ALTER TABLE ONLY items.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- TOC entry 4936 (class 2606 OID 17272)
-- Name: building_roles building_owners_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.building_roles
    ADD CONSTRAINT building_owners_pkey PRIMARY KEY (building_id, player_id, role_id);


--
-- TOC entry 4918 (class 2606 OID 17099)
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4916 (class 2606 OID 17092)
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- TOC entry 4909 (class 2606 OID 17008)
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- TOC entry 4938 (class 2606 OID 17277)
-- Name: city_roles city_owners_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.city_roles
    ADD CONSTRAINT city_owners_pkey PRIMARY KEY (city_id, player_id, role_id);


--
-- TOC entry 4914 (class 2606 OID 17075)
-- Name: city_tiles city_tiles_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.city_tiles
    ADD CONSTRAINT city_tiles_pkey PRIMARY KEY (city_id, x, y);


--
-- TOC entry 4940 (class 2606 OID 17282)
-- Name: district_roles district_owners_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.district_roles
    ADD CONSTRAINT district_owners_pkey PRIMARY KEY (district_id, player_id, role_id);


--
-- TOC entry 4920 (class 2606 OID 17106)
-- Name: district_types district_types_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.district_types
    ADD CONSTRAINT district_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4922 (class 2606 OID 17128)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 4891 (class 2606 OID 16692)
-- Name: landscape_types landscape_types_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.landscape_types
    ADD CONSTRAINT landscape_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4885 (class 2606 OID 17001)
-- Name: map_tiles map_tiles_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.map_tiles
    ADD CONSTRAINT map_tiles_pkey PRIMARY KEY (x, y);


--
-- TOC entry 4912 (class 2606 OID 17021)
-- Name: map_tiles_players_positions map_tiles_players_positions_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.map_tiles_players_positions
    ADD CONSTRAINT map_tiles_players_positions_pkey PRIMARY KEY (player_id, map_tile_x, map_tile_y);


--
-- TOC entry 4881 (class 2606 OID 16542)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- TOC entry 4883 (class 2606 OID 16549)
-- Name: terrain_types terrain_types_pkey; Type: CONSTRAINT; Schema: map; Owner: postgres
--

ALTER TABLE ONLY map.terrain_types
    ADD CONSTRAINT terrain_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4907 (class 2606 OID 16952)
-- Name: player_abilities player_abilities_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.player_abilities
    ADD CONSTRAINT player_abilities_pkey PRIMARY KEY (id);


--
-- TOC entry 4905 (class 2606 OID 16945)
-- Name: player_skills player_skills_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.player_skills
    ADD CONSTRAINT player_skills_pkey PRIMARY KEY (id);


--
-- TOC entry 4887 (class 2606 OID 16636)
-- Name: players players_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- TOC entry 4889 (class 2606 OID 16649)
-- Name: player_stats players_stats_pkey; Type: CONSTRAINT; Schema: players; Owner: postgres
--

ALTER TABLE ONLY players.player_stats
    ADD CONSTRAINT players_stats_pkey PRIMARY KEY (id);


--
-- TOC entry 4944 (class 2606 OID 17330)
-- Name: status_types status_types_pk; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.status_types
    ADD CONSTRAINT status_types_pk PRIMARY KEY (id);


--
-- TOC entry 4942 (class 2606 OID 17320)
-- Name: tasks tasks_pk; Type: CONSTRAINT; Schema: tasks; Owner: postgres
--

ALTER TABLE ONLY tasks.tasks
    ADD CONSTRAINT tasks_pk PRIMARY KEY (id);


--
-- TOC entry 4910 (class 1259 OID 17036)
-- Name: unique_city_position; Type: INDEX; Schema: map; Owner: postgres
--

CREATE UNIQUE INDEX unique_city_position ON map.cities USING btree (map_tile_x, map_tile_y);


--
-- TOC entry 4945 (class 2606 OID 17236)
-- Name: ability_requirements ability_requirements_ability_id_fkey; Type: FK CONSTRAINT; Schema: attributes; Owner: postgres
--

ALTER TABLE ONLY attributes.ability_requirements
    ADD CONSTRAINT ability_requirements_ability_id_fkey FOREIGN KEY (ability_id) REFERENCES attributes.abilities(id);


-- Completed on 2025-07-08 23:03:40

--
-- PostgreSQL database dump complete
--

