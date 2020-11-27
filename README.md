Hello!

This is a small project which consist of:
1) Creating a django start project 
2) Isntall and configure Nginx 
3) Connect Nginx and django through uWSGI
4) Install PostrgeSQL and connect it to django 



First of all need to update system and install needed packages 

sudo apt update
sudo apt install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl python3-venv

Then create venv for out django project 

python3 -m venv djangoenv

and add this venv to .gitignore

Activate our venv and isntall all requirements from txt file (in shell script file)

Then we need to configure PostgreSQL db to make it work with django 

Firstly enter into db under postgres user, cuz during the installation that user declaried as admin user

sudo -u postgres psql

Need to create db for django

CREATE DATABASE myproject;

And django user 

CREATE USER django WITH PASSWORD 'XXXXXXXXXXX';

And some small changes that Django project recommend to apply 

ALTER ROLE django SET client_encoding TO 'utf8';
ALTER ROLE django SET default_transaction_isolation TO 'read committed';
ALTER ROLE django SET timezone TO 'UTC';
 


