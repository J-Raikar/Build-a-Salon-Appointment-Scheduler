#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#Intro
echo -e "\n\n***** Salon de thérapie *****\n_____________________________\n"

SERVICE_SCREEN() {

  #Set "error" prompt
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #Display service screen
  echo -e "How can we help you today?\n"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  #Select option
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED != 1 && $SERVICE_ID_SELECTED != 2 && $SERVICE_ID_SELECTED != 3 && $SERVICE_ID_SELECTED != 4 ]]
  then
    SERVICE_SCREEN "We could not find that service (Please enter a valid number)"
  else
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    #Get customer information
    echo -e "\nYou have selected: $SERVICE_NAME_SELECTED"
    echo -e "Please enter your phone number. (format as xxx-xxxx OR xxx-xxx-xxxx)"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      #create new account
      echo -e "\nOh, new customer! What is your name?"
      read CUSTOMER_NAME
      ENTER_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    else
      echo -e "\nThat's a familiar number. Welcome back, $CUSTOMER_NAME!"
    fi
    #Get time
    echo -e "\nWhat time would you like to make an appointment?"
    read SERVICE_TIME

    #Record appointment
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    ENTER_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    echo -e "Have a wonderful rest of your day!\n\n"
  fi
}

SERVICE_SCREEN