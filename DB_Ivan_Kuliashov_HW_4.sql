-- Drop existing elements if they exist for a clean setup
DROP TABLE IF EXISTS tic_tac_toe CASCADE;
DROP FUNCTION IF EXISTS NewGame();
DROP FUNCTION IF EXISTS NextMove(integer, integer, char);

-- Create the game table
CREATE TABLE tic_tac_toe (
    game_id serial PRIMARY KEY,
    board char(3)[][] DEFAULT ARRAY[['-', '-', '-'], ['-', '-', '-'], ['-', '-', '-']],
    current_player char(1) DEFAULT 'X'
);

-- Function to start a new game
CREATE OR REPLACE FUNCTION NewGame()
RETURNS void AS $$
BEGIN
    INSERT INTO tic_tac_toe (board, current_player) VALUES (DEFAULT, DEFAULT);
END;
$$ LANGUAGE plpgsql;

-- Function to make a move and visualize the board
CREATE OR REPLACE FUNCTION NextMove(X integer, Y integer, Val char(1) DEFAULT NULL)
RETURNS text AS $$
DECLARE
    game_state char(3)[][];
    player char(1);
    winner text;
    max_game_id integer;
BEGIN
    SELECT max(game_id) INTO max_game_id FROM tic_tac_toe;
    SELECT board, current_player INTO game_state, player FROM tic_tac_toe WHERE game_id = max_game_id;

    IF Val IS NULL THEN
        Val := player;
    END IF;

    IF game_state[X][Y] != '-' THEN
        RAISE EXCEPTION 'This cell is already occupied';
    END IF;

    game_state[X][Y] := Val;
    UPDATE tic_tac_toe SET board = game_state WHERE game_id = max_game_id;

    winner := check_winner(game_state);
    IF winner IS NOT NULL THEN
        RETURN winner;
    END IF;

    IF player = 'X' THEN
        UPDATE tic_tac_toe SET current_player = 'O' WHERE game_id = max_game_id;
    ELSE
        UPDATE tic_tac_toe SET current_player = 'X' WHERE game_id = max_game_id;
    END IF;

    RETURN array_to_string(game_state, E'\n');
END;
$$ LANGUAGE plpgsql;

-- Helper function to determine the game's outcome
CREATE OR REPLACE FUNCTION check_winner(board char(3)[][])
RETURNS text AS $$
DECLARE
    i integer;
BEGIN
    FOR i IN 1..3 LOOP
        IF board[i][1] = board[i][2] AND board[i][2] = board[i][3] AND board[i][1] != '-' THEN
            RETURN board[i][1] || ' wins!';
        END IF;
        IF board[1][i] = board[2][i] AND board[2][i] = board[3][i] AND board[1][i] != '-' THEN
            RETURN board[1][i] || ' wins!';
        END IF;
    END LOOP;
    IF board[1][1] = board[2][2] AND board[2][2] = board[3][3] AND board[1][1] != '-' THEN
        RETURN board[1][1] || ' wins!';
    END IF;
    IF board[1][3] = board[2][2] AND board[2][2] = board[3][1] AND board[1][3] != '-' THEN
        RETURN board[1][3] || ' wins!';
    END IF;
    FOR i IN 1..3 LOOP
        FOR j IN 1..3 LOOP
            IF board[i][j] = '-' THEN
                RETURN NULL; -- Game continues
            END IF;
        END LOOP;
    END LOOP;
    RETURN 'It''s a tie!';
END;
$$ LANGUAGE plpgsql;




SELECT NewGame();

SELECT NextMove(1, 1); 
SELECT NextMove(2, 2, 'O'); 
SELECT NextMove(1, 2); 
SELECT NextMove(3, 3, 'O'); 
SELECT NextMove(1, 3); 

select * from tic_tac_toe