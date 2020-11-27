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

Activate our venv and isntall all requirements  
