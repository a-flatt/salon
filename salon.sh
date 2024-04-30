#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU () {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim\n"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) MAKE_APPOINTMENT 1 ;;
    2) MAKE_APPOINTMENT 2 ;;
    3) MAKE_APPOINTMENT 3 ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac

}

MAKE_APPOINTMENT() {
  if [[ $1 ]]
  then
    SERVICE_ID_SELECTED=$1
    echo -e "\nWhat's your phone number?\n"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?\n"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ /"/')
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME_FORMATTED?\n"
    read SERVICE_TIME
    GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$GET_CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
    then
      GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      SERVICE_NAME_FORMATTED=$(echo $GET_SERVICE_NAME | sed 's/ /"/')
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU