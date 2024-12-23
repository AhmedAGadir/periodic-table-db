#!/usr/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# If you leave your virtual machine, your database may not be saved. You can make a dump of it 
# by entering pg_dump -cC --inserts -U freecodecamp periodic_table > periodic_table.sql in a bash terminal (not the psql one). 
# It will save the commands to rebuild your database in periodic_table.sql. 
# The file will be located where the command was entered. If it's anything inside the project folder, the file will be saved in the VM. 
# You can rebuild the database by entering psql -U postgres < periodic_table.sql in a terminal where the .sql file is.

GET_ELEMENT() {
  QUERY="SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id)"
  case "$1" in
    "atomic_number") 
      # echo "user entered validatomic number - $2" 
      QUERY+=" WHERE atomic_number=$2"
      ;;
    "symbol") 
      QUERY+=" WHERE symbol='$2'"
      ;;
    "name") 
      QUERY+=" WHERE name='$2'"
      ;;
  esac

  ELEMENT_DETAILS=$($PSQL "$QUERY")

  echo "$ELEMENT_DETAILS" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  done
}

# if user doesnt pass a parameter
if [[ -z $1 ]]
then
  # tell them to enter an argument
  echo "Please provide an element as an argument."
  exit 0;
fi

# check if user entered an atomic number
ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = '$1';") 
if [[ ! -z $ATOMIC_NUMBER ]] 
then
  # get element from atomic number
  GET_ELEMENT atomic_number $ATOMIC_NUMBER
else 
  # check if user entered a symbol
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1';") 
  if [[ ! -z $SYMBOL ]]
  then 
    # get element from symbol
    GET_ELEMENT symbol $SYMBOL
  else
    # check if user entered a name
    NAME=$($PSQL "SELECT name FROM elements WHERE name = '$1';") 
    if [[ ! -z $NAME ]] 
      then
      # get element from name
      GET_ELEMENT name $NAME
    else 
      echo "I could not find that element in the database."
    fi
  fi
fi
