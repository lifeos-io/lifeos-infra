-- One database and one owner per service (database per service). Runs only on an empty data volume.
CREATE USER strategy;
CREATE DATABASE strategy OWNER strategy;
CREATE USER coach;
CREATE DATABASE coach OWNER coach;
CREATE USER trigger;
CREATE DATABASE trigger OWNER trigger;
CREATE USER notification;
CREATE DATABASE notification OWNER notification;
CREATE USER keycloak WITH PASSWORD 'keycloak';
CREATE DATABASE keycloak OWNER keycloak;
