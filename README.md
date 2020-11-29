# Hello!

# This is a small project which consist of:
1) Creating a django start project 
2) Isntall and configure Nginx 
3) Install PostrgeSQL and connect it to django
4) Install pgAdmin web-interface
5) Connect Nginx and django through uWSGI
6) Configure Nginx to work with domain name
7) Configure HTTPS to work with ssl-certs from Let's Encrypt
8) Autumatically renew certs if they expired 
9) Configure redirecting from HTTP to HTTPS
10) Configure firewall to enable ssh/http/https connections
11) Do all above stuff with Ansible magic :) 



# First of all need to update system and install needed packages 
```
sudo apt update
sudo apt install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl python3-venv
```
# Then create venv for out django project 
```
python3 -m venv djangoenv
```
And add this venv to .gitignore

Activate our venv and isntall all requirements from txt file (in shell script file)

# Then we need to configure PostgreSQL db to make it work with django 

Firstly enter into db under postgres user, cuz during the installation that user declaried as admin user
```
sudo -u postgres psql
```
Need to create db for django
```
CREATE DATABASE myproject;
```
And django user 
```
CREATE USER django WITH PASSWORD 'XXXXXXXXXXX';
```
And some small changes that Django project recommend to apply 
```
ALTER ROLE django SET client_encoding TO 'utf8';
ALTER ROLE django SET default_transaction_isolation TO 'read committed';
ALTER ROLE django SET timezone TO 'UTC';
```

# Now we need to create our 'hello' django project 
```
django-admin.py startproject django_hello_page ~/django-project
```

Now we need to change 2 blocks in settings.py of our django project. There are that blocks ALLOWED_HOSTS and DATABASES.

In ALLOWED_HOSTS we need to add the IP-addresses or domain names associated with your Django server. 
We will use localhost and our dns name, because going to use nginx as proxy-server


In DATABASES block need to add parameters of our PostgreSQL db, to make django project connect to db
```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'myproject',
        'USER': 'myprojectuser',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '',
    }
}
```

Also add in setting.py file lines which will tell django where static file will land 
```
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static/')
```
To apply all above changes, need to run such commands:
```
~/django-project/manage.py makemigrations
~/django-project/manage.py migrate
~/django-project/manage.py collectstatic
```


# Now we will create script which will create backup of whole PostgeSQL DB

Also will create cron job that will start every day in 00:59 UTC 
In the end we will have archives with our DB in /tmp/pg_backup/

Create backupscript.sh with backup command and put it into postgres home directory(/var/lib/postgresql):
```
pg_basebackup --format=t -z -X fetch -D /tmp/pg_backup/backup-$(date +"%T:%A:%d:%m:%y")
```
To create cron job need become a user 'postgres'
Then run  crontab -e  and add line 
```
59 0 * * * ./backupscript.sh

```

# Now we going to setup Nginx to serve our django project 

We will use file uwsgi_params provided by nginx, copy the content of that file from 
https://github.com/nginx/nginx/blob/master/conf/uwsgi_params

and paste into file uwsgi_params (create it beforehand), located in our project folder

Then we need to configure nginx virtual host. 

Create file django_nginx.conf in folder /etc/nginx/site-available

How django_nginx.conf is look like you may take a look in repo

Then create sym link from /etc/nginx/site-available/django_nginx.conf to /etc/nginx/site-enabled/django_nginx.conf
And restart nginx

# Then start our django project: 
```
uwsgi --socket :8001 --module django_hello_page.wsgi 
```
Go to browser and check django welcome page http://devops03.3dlook.me

Also u may check how nginx serve media file in ur django project 

Add any picture to media folder in ur project 

Then go http://devops03.3dlook.me/media/(name of your pic).png


# Now we going to create ssl certificates from Let's Encrypt 

For this we need to use progamm certbot
```
sudo certbot --nginx --email jakethedogg@ukr.net -d devops03.3dlook.me
```
Now we need to configure redirection from HTTP to HTTPS
Fortynetly to us certbot is changing our configurations of django_nginx.conf 
And creates the redirection, of course if we will agree with that :) 

Now we need to ensure that our certs will be re-created automatically when it will expire
```
sudo certbot renew --dry-run
```
# Configure firewall and open ssh, http and https connections
To do this we need to do such commands 
```
sudo ufw allow 'Nginx Full'  # to allow http and https ports
sudo ufw allow ssh           # to allow ssh 
```

# Install and run pgAdmin web-interface
Run this command (don't forget to use it inside of venv)
```
pip install pgadmin4
```
Then create file ``` config_local.py ``` in such path
```
djangoenv/lib/python3.6/site-packages/pgadmin4/config_local.py
```
And put there such content 
```
import os
SERVER_MODE = False
DATA_DIR = os.path.realpath(os.path.expanduser(u'~/.pgadmin/'))
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions') 
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
```
After that run 
```
python djangoenv/lib/python3.6/site-packages/pgadmin4/setup.py
```
Our pgAdmin is installed and configured! 
Now we need to it run with uwsgi
```
uwsgi --http-socket :8010 --chdir /home/devops/django-project/djangoenv/lib/python3.6/site-packages/pgadmin4 --manage-script-name --mount /=pgAdmin4:app 
```



