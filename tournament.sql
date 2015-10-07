-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- Table 1 = Participants.  Just ID and Name
-- Table 2 = Match Results.  Just Winner ID and Loser ID, keep addig to 
--    the bottom.
-- View 1 = Ranking.  Just sorted by wins.

-- Everything should be doable with these 3 simple tables.
-- Use a count function on the win column to determine # of wins

-- Always start from scratch
DROP DATABASE IF EXISTS tournament;

CREATE DATABASE tournament;
\c tournament;

-- Setup tables.  Assume they already exist, so get rid of anything
--    already there first.

CREATE TABLE participants (id serial, name text);
CREATE TABLE match_results (winner int, loser int);

--  Tricky bit.  Inner table is ID and win count.
--  Outer table mates that information with the name.

CREATE VIEW win_temp AS SELECT participants.id, participants.name, rank.wins as total_wins
	FROM (SELECT winner, COALESCE(count(*), 0) as wins
	FROM match_results
	GROUP BY winner) as rank RIGHT JOIN participants
	ON participants.id = rank.winner
	ORDER BY COALESCE(wins, 0) DESC;

CREATE VIEW matches AS SELECT winner, count(x) as match_count
	FROM (SELECT winner FROM match_results
	      UNION ALL SELECT loser FROM match_results) x
	GROUP BY winner;

CREATE VIEW standings AS SELECT participants.id, participants.name,
				COALESCE(win_temp.total_wins, 0) as wins,
				COALESCE(matches.match_count, 0) as matches
	FROM participants LEFT JOIN (
		win_temp JOIN matches ON win_temp.id = matches.winner)
	ON participants.id = win_temp.id
	ORDER BY COALESCE(total_wins, 0) DESC;

/* Test code
INSERT INTO participants (name) VALUES ('Alice');
INSERT INTO participants (name) VALUES ('Bert');
INSERT INTO participants (name) VALUES ('Candy');
INSERT INTO participants (name) VALUES ('David');
INSERT INTO participants (name) VALUES ('Earl');
INSERT INTO participants (name) VALUES ('Fred');
INSERT INTO participants (name) VALUES ('Gregory');
INSERT INTO participants (name) VALUES ('Hillary');

INSERT INTO match_results VALUES (1,2);
INSERT INTO match_results VALUES (3,4);
INSERT INTO match_results VALUES (5,6);
INSERT INTO match_results VALUES (7,8);
INSERT INTO match_results VALUES (1,3);
INSERT INTO match_results VALUES (5,7);
INSERT INTO match_results VALUES (2,4);
INSERT INTO match_results VALUES (6,8);

SELECT * FROM participants;
SELECT * FROM match_results;;
SELECT * FROM win_temp;
SELECT * FROM matches;
SELECT * FROM standings;
*/