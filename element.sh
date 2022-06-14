#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$1
  NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
fi

if [[ $1 =~ ^[A-Z][a-z]{2,} ]]
then
  NAME=$1
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$NAME'")
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME'")
fi

if [[ $1 =~ ^[A-Z][a-z]?$ ]]
then
  SYMBOL=$1
  NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$SYMBOL'")
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL'")
fi

if [[ -z $SYMBOL || -z $NAME || -z $ATOMIC_NUMBER ]]
then
  echo "I could not find that element in the database."
  exit
fi

PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")

echo $PROPERTIES | while IFS="|" read MASS MELTING_POINT BOILING_POINT TYPE
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
done
