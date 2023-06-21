#! /bin/bash

if [[ $1 == "test" ]]; then
    PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
    PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear tables before seeding database
echo "$($PSQL "TRUNCATE TABLE games, teams")"

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
    # Skip csv header
    if [ "$YEAR" != "year" ]; then

        # Iterate winners and opponents
        for TEAM in "$WINNER" "$OPPONENT"; do
            # Check if team already in 'teams' table
            RESULT="$($PSQL "SELECT * FROM teams WHERE name LIKE '$TEAM'")"

            # Add to table if not present yet
            if [[ -z $RESULT ]]; then
                echo "$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")"

            fi
        done
    fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
    # Skip csv header
    if [ "$YEAR" != "year" ]; then
        # Seed 'games' table
        echo "$(
            $PSQL "
        INSERT INTO games
            (year,
             round,
             winner_goals,
             opponent_goals,
             winner_id,
             opponent_id)
        VALUES ('$YEAR',
            '$ROUND',
            '$WINNER_GOALS',
            '$OPPONENT_GOALS',
            (SELECT team_id
             FROM   teams
             WHERE  name = '$WINNER'),
            (SELECT team_id
             FROM   teams
             WHERE  name = '$OPPONENT'))"
        )"
    fi
done
