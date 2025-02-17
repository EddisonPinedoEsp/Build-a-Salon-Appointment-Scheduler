#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?"
SERVICES() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES_=$($PSQL "select service_id, name from services")

  echo "$SERVICES_" | while read SERVICES_ID SERVICE_NAME
  do 
    echo "$SERVICES_ID) $SERVICE_NAME" | sed 's/ |//'
  done

  read SERVICE_ID_SELECTED
  SERVICES_NAME=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")

  if [[ -z $SERVICES_NAME ]] 
  then
    SERVICES "\nI could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_PHONE_HAVE=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    
    if [[ -z $CUSTOMER_PHONE_HAVE ]]
    then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      ADD_CUSTOMER_PHONE=$($PSQL "insert into customers(name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    read SERVICE_TIME
    ADD_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    echo -e "\nI have put you down for a $SERVICES_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  fi
}

SERVICES