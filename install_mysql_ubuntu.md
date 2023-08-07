To run a Django application with a MySQL database on Ubuntu, you'll need to set up the necessary software, configure the database, and deploy the Django application. Here's a step-by-step guide to help you:

1. Install Required Packages: First, ensure that your Ubuntu system is up to date:

```
sudo apt update
sudo apt upgrade
```

Then, install the required packages for Python, MySQL, and other dependencies:

```
sudo apt install python3 python3-pip mysql-server libmysqlclient-dev
```

2. Set Up MySQL Database: During the MySQL installation, you will be prompted to set a root password for the MySQL server. Follow the instructions to set the password.
 
3. Create a MySQL Database and User: Log in to the MySQL server as the root user:

```
sudo mysql -u root -p
```

Once you're in the MySQL shell, create a new database and a user with appropriate privileges:

```
CREATE DATABASE your_database_name;
CREATE USER 'your_username'@'localhost' IDENTIFIED BY 'StrongPassword123@';
GRANT ALL PRIVILEGES ON your_database_name.* TO 'your_username'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```


Example:

```
create database kumardb;
CREATE USER 'kumar'@'localhost' IDENTIFIED BY 'StrongPassword123@';
GRANT ALL PRIVILEGES ON kumardb.* TO 'kumar'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```


4. Clone and Set Up Your Django Project:
Clone your Django project from its repository or copy it to your Ubuntu server. Make sure you have the necessary files, including the requirements.txt file.

Navigate to the project directory:

```
cd /path/to/your/django/project
```

Install the Python dependencies using pip:

```
pip3 install -r requirements.txt
```

5. Configure Django Settings:
Update your Django project settings (settings.py) to use the MySQL database. Modify the DATABASES section to use the MySQL backend and provide the database name, user, and password you created earlier:

```
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'your_database_name',
        'USER': 'your_username',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '',
    }
}
```

6. Run Django Migrations:
Apply the database migrations to create the necessary database tables:

```
python3 manage.py migrate
```

7. Create Django Superuser (Optional):
If your Django application includes user authentication, you can create a superuser to access the Django admin interface:

```
python3 manage.py createsuperuser
```

8. Run the Development Server:
Start the Django development server to test your application:

```
python3 manage.py runserver
```

Your Django application should now be accessible at http://localhost:8000/.