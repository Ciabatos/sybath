
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
                ,(ARRAY[
                    '#FF3B3B', -- red
                    '#FF8C00', -- orange
                    '#FFD700', -- yellow
                    '#7CFF00', -- lime
                    '#32CD32', -- green
                    '#00FFAA', -- mint
                    '#00E5FF', -- cyan
                    '#1E90FF', -- blue
                    '#5DA9FF', -- light blue
                    '#8A2BE2', -- purple
                    '#B266FF', -- light purple
                    '#FF4FD8', -- pink
                    '#FF77AA', -- light pink
                    '#FF6F61', -- coral
                    '#40E0D0', -- turquoise
                    '#00FA9A', -- spring green
                    '#ADFF2F', -- green yellow
                    '#F4D03F', -- soft yellow
                    '#F39CFF', -- pastel violet
                    '#A3FFCE'  -- light mint
                ])[ceil(random() * 20)]
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
