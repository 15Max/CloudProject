# Cloud Basic Final Project

This repository contains the final project for the Cloud Basic Course, taught at University of Trieste in 2023/2024.

# Cloud Based File Storage System

## Task Description

The task is to identify, deploy and implement a cloud-based file storage system. The system should allow users to upload, download, and delete files. Each user should have a private storage space. The system should be scalable, secure, and cost-efficient. 
The requirements for the deployed platform are: 

**Manage User Authentication and Authorization:**
- Users should be able to sign up, log in, and log out.
- Users should have different roles (e.g., regular user and admin).
- Regular users should have their private storage space.
- Admins should have the ability to manage users.

**Manage File Operations:**
- Users should be able to upload files to their private storage.
- Users should be able to download files from their private storage.
- Users should be able to delete files from their private storage.

**Address Scalability:**
- Design the system to handle a growing number of users and files.
- Discuss theoretically how to handle increased load and traffic.

**Address Security:**
- Implement secure file storage and transmission.
- Discuss how to secure user authentication.
- Discuss measures to prevent unauthorized access.

**Discuss Cost-Efficiency:**
- Consider the cost implications of the chosen design.
- Discuss how to optimize the system for cost efficiency.

**Deployment:**
- Provide a deployment plan for the system in a containerized environment on your laptop based on docker and docker-compose.
- Discuss how to monitor and manage the deployed system.
- Choose a cloud provider that could be used to deploy the system in production and justify your choice.

**Test the infrastructure:**
- Consider the performance of the system in terms of load and IO operations


## Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) 
- [Python 3.12+](https://www.python.org/downloads/) (for locust)
- [Pip](https://pip.pypa.io/en/stable/installation/) (for locust)
- [Locust](https://docs.locust.io/en/stable/installation.html) (for load testing)

## Project Documentation
The following sections will guide you through the setup and usage of the cloud-based file storage system, for all the details about the design choices and theoretical discussions, please refer to the [report](report/LUCAS_Report.pdf).
### Setup
Use `docker-compose up -d` to start the containers.
This will start the following services:
- [Nextcloud:](https://nextcloud.com/) the main application for file storage and management
- [MariaDB:](https://mariadb.org/) a drop in replacement for SQL lite, offering better performance and features

Once the containers are up and running you can access Nextcloud at `http://localhost:8080`. The default Nextcloud admin credentials are present in the [.env](.env) file.
In this case the username is `admin` and the password is `SecureAdmin15$`.
This information is provided againts best security practices, but since this is a local deployment for testing purposes only I opted for this solution to make it easier to access the platform.


### Security
The Nextcloud platform offers a wide range of security features, to set some of them up before creating any new users, you can directly run the shell script `password_security.sh` present in the [scripts](scripts/password_security.sh) folder.
In addition to the default settings of Nextcloud, which check for commonly used passwords and ensure they are not found in the *haveibeenpwned* database of compromised passwords, this script will configure some security measures to create stronger passwords and protect user accounts.
The password policy enforced by this script includes:
- Minimum password length set to 10 characters 
- Inclusion of both uppercase and lowercase letters
- Inclusion of at least one number
- Inclusion of at least one special character

Additionally accounts will be locked after **5 failed login attempts** and must be unlocked by an admin. Also **password expiration** is set to **30 days**, after which users will be prompted to change their password.

To check if these settings have been correctly applied, you can execute the `scripts/test_password_security.sh` script, which will  try and reset the password of a test user with unsecure ones and also try to login with wrong credentials multiple times to see if the account gets locked.

If you want to modify the password settings, you can do so by changing the values in the `password_security.sh` script before running it or directly through the Nextcloud admin interface at `http://localhost:8080/settings/admin/security`.

Other security features could also be enabled, such as:
- Two-Factor Authentication (2FA): adds an extra layer of security by requiring a second form of verification during login.
- Authenticated encryption: ensures that data is encrypted during transmission and storage, protecting it from unauthorized access.

These measures weren't considered for the scopes of this project, given slower usability, but they are highly recommended for production environments.

### User Management
To **create** new users you can directly run the shell script `scripts/create_user.sh`, which will create 100 test users with usernames `test_user1`, `test_user2`, ..., `test_user100`, these will be displayed on the platform as `TestUser 1`, `TestUser 2`, ..., `TestUser 100`.
Passwords contain the user index and keep a common prefix and suffix: `Test_password1!`, `Test_password2!`, ..., `Test_password100!`.
You can modify the number of users to create by changing the `NUMBER_OF_USERS` variable in the script.

Each user will have a private storage of **4GB** and will be part of the group `Users`, if you want to change these settings, please refer to the `create_user.sh` script.
It's important to note that by default some files will be already included in the private storage of each user, such as the Nextcloud .pdf manual or the default README.md file. This should not affect the storage quota significantly, but it's something to keep in mind. I didn't change this default behavior, also because I used these files later on to test some locust tasks.

If you want to **delete** users, you can run the `scripts/delete_user.sh` script, which will remove the 100 test users created earlier.

You can also **delete all files** stored by these users, without deleting the users themselves, by running the `scripts/delete_files.sh` script. It's also recommended to run this script before deleting the users, to avoid unnecessary storage usage.

If you instead prefer to create or delete users manually, you can do so through the Nextcloud admin interface at `http://localhost:8080/settings/users`.

### Locust
Locust is an open source load testing tool that allows you to define user behavior with Python code, and then simulate  users to test the performance of your system while providing real-time statistics and charts.

Make sure you have python 3.12 and pip installed, then proceed to add locust with the following command:
`pip install locust`.

Before running any tests, we need some files to upload. There is a shell script that creates three files of different sizes (1MB, 1KB, 1GB) in the test_files folder.

Note: The test_files/ directory is ignored in version control via .gitignore to avoid storing large files in the repository. You can recreate them locally using the provided script: `scripts/create_test_files.sh`.
They are simply files filled with zeros, created with the `dd` command.

If you have not already done so, you can also create the test users by running the `scripts/create_user.sh` script.

Afterwards, you can choose between three different locust test files, depending on the intensity of the **load** you want to simulate:
- [locust_tasks_light.py](locust/locust_tasks_light.py): simulates a light load with small files (1KB);
- [locust_tasks_medium.py](locust/locust_tasks_medium.py): simulates a medium load with both tiny (1MB) and light (1KB) files, also the request frequency is the highest;
- [locust_tasks_heavy.py](locust/locust_tasks_heavy.py): simulates a heavy load with the same files as in the medium load and the addition of large (1GB) files;

To run locust, use one of the following commands, based on your choice:

`locust -f locust/locust_tasks_light.py --host http://localhost:8080`

`locust -f locust/locust_tasks_medium.py --host http://localhost:8080`

`locust -f locust/locust_tasks_heavy.py --host http://localhost:8080`

Then, open your browser and go to `http://localhost:8089` to access the locust web interface. From there, you can start the test by specifying the number of users, the spawn rate and if you open the advanced options you can also set the run time.

This is what the interface should look like when starting a test:

![Locust Start Test](results/example_locust_test.png)

After starting the test, you will be able to see real-time statistics and charts about the performance of your system, such as the number of requests per second, the response time distribution, and the number of failures.
#### Test Results
In the [results](results) folder you can find a selection of graphs and statistics form the tests I ran with locust, for each of the three different load levels:

- *Test 1* : Light load with 80 users, spawn rate 1 user/s, run time 5 minutes
- *Test 2* : Medium load with 80 users, spawn rate 1 user/s, run time 5 minutes
- *Test 3* : Heavy load with 10 users, spawn rate 1 user/s, run time 5 minutes

## Author
[**Marta Lucas**](https://github.com/15Max)

Check out the [presentation](https://github.com/15Max/CloudProject/presentation) for a quick overview of the project.  #TODO add correct link