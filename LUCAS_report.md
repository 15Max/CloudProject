# Cloud Computing Final Project Report - Cloud Based File Storage System
#### Marta Lucas SM3800043- Data Science and Artificial Intelligence year 2023/2024, University of Trieste
07/09/2025

## Introduction
The final project for the cloud course involves identifying, deploying and implementing a **Cloud-Based file storage system**. The system must allow users to upload, download, and delete files each within their own private storage space. The system should be scalable, secure, and cost-efficient.
This report includes design choice motivations, implementation details, security measures and a scalability/cost-efficiency analysis of the deployed system.

### Nextcloud
For the file storage platform, **Nextcloud** was selected. Nextcloud is an open-source self-hosting cloud storage solution that allows users to store and share files in a private storage space.

It supports file uploads, downloads, and deletions, along with robust user and group management for administrators.

Nextcloud also offers several built-in security features, including two-factor authentication, server-side encryption, and OAuth2 support. These features, along with its ease of deployment and strong community support, made Nextcloud a better fit for this project compared to other alternatives.

### MariaDB
The system uses **MariaDB** as its database backend to store file metadata, and configuration settings. MariaDB is a relational database management system that is fully open-source and known for better performance and scalability compared to the default SQLite option offered by Nextcloud. 

Nextcloud and MariaDB were both deployed using **Docker Compose**, allowing for modular and reproducible setup in containerized environments.

### Docker and Docker Compose
Docker is a platform that allows for the creation, deployment, and management of containerized applications. Docker Compose is a complimentary tool that simplifies the process of defining and running multi-container Docker applications using a YAML file.
In this project Nextcloud and MariaDB were deployed using Docker Compose, which allowed for easy configuration and management of the two services. The `docker-compose.yml` file defines the services, their dependencies, and the necessary environment variables. Also two volumes were created to persist data for both Nextcloud and MariaDB, ensuring that data is not lost when the containers are stopped or removed.

To deploy the system run `docker-compose up -d` in the directory containing the `docker-compose.yml` file. 
This will start both services in the background. Once the containers are up and running, you can access the Nextcloud web interface by navigating to: `http://localhost:8080`.
First access can be done with the admin credentials specified in the `.env` file (see Security section for more details).

### Security
Security is a crucial aspect of any cloud-based system, especially when dealing with sensitive data. In this project, some best practices have been intentionally relaxed for demonstration purposes. For example, the .env file containing credentials is included in the GitHub repository. In a real-world deployment, this should be excluded using .gitignore, and credentials should be stored in a secure, encrypted environment.

After registration, Nextcloud users authenticate via their username and password. Once logged in, Nextcloud issues an access token, which is used by the client for all subsequent HTTP requests. This token should be stored securely on the client side and must not be shared or saved on any other system.
Additionally, user passwords are stored in encrypted form within the Nextcloud database, ensuring that even in the event of a database breach, raw passwords remain protected.

Nextcloud provides several built-in security features, many of which are configurable through the admin interface or via the command line. These include:
- **Two-factor authentication**: Adds an extra layer of protection by requiring a second form of verification during login.
- **Server-side Encryption**: Encrypts files at rest on the server to prevent unauthorized access, even if the storage backend is compromised.
- **OAuth2**: Allows secure authentication and token-based access using external identity providers (e.g., Google, GitHub).
- **Logging and monitoring**: Tracks user activity and system events to detect and investigate potential security incidents.
- **Password policies**: Enforces secure password creation through configurable rules
- **Brute-force protection**: Limits the number of login attempts to prevent brute-force attacks.

In this case only the last two security measures were enabled. This is because the other features, while valuable in production, introduce additional overhead that may hinder performance or usability in a lightweight demonstration setup.

The password policy can be directly configured by running the `password_security.sh` script. You can directly verify these settings using the `test_password_security.sh` script, which attempts weak password resets and multiple failed logins to test enforcement.

In addition to the default settings of Nextcloud, which check for commonly used passwords and ensure they are not found in the *haveibeenpwned* database of compromised passwords, this script will configure some security measures to create stronger passwords and protect user accounts.
The password policy enforced by this script includes:
- Minimum password length set to 10 characters 
- Inclusion of both uppercase and lowercase letters
- Inclusion of at least one number
- Inclusion of at least one special character

Additionally accounts will be locked after **5 failed login attempts** and must be unlocked by an admin. Also **password expiration** is set to **30 days**, after which users will be prompted to change their password.

These settings can be modified by editing the script or manually adjusting the values in the Nextcloud admin interface . The same goes for the other types of security measures mentioned above. *For production deployments, it is strongly recommended to enable 2FA and encryption and use OAuth2 for improved access control.*

### User Management
Admin users can create and manage user accounts through the Nextcloud web interface. Each user is provided with a private storage space where they can upload, download, and delete files. Admins can also assign users to groups, set storage quotas, and monitor user activity.

In this project, a script named `create_user.sh` was created to automate the creation of multiple user accounts for testing purposes. It generates 100 test users with a space quota of 4GB, which will be used for load testing with Locust.

The usernames are in the format `test_userX` while display names are in the format `Test User X`, where `X` is the numeric index of the user (from 1 to 100). The password follows the format `Test_passwordX!`, which complies with the password policy set in the previous section.

Deletion of users can be done manually through the admin interface or by using the `delete_user.sh` script, which removes all test users created by the `create_user.sh` script.

It's recommended to run the `delete_files.sh` script before clearing users, as it will delete all files uploaded by the test users, helping free up storage and keep the environment clean.

### Locust Testing
Locust is an open-source load testing tool that allows you to define user behavior in Python code and simulate concurrent users. It provides a web-based interface to monitor the progress of the tests and analyze the results.
To properly test the system users must already be present on the Nexcloud platform. 
Since one of the objectives is to test operations such as file uploads, you should first run the `create_test_files.sh` script.This script generates three different sized test files: 1MB, 1KB and 1GB.

The tasks to be perfomed during the simulations are defined in the .py files in the `locust` directory. 
Common elements across all files include:
- Authentication (HEAD): Sends a request to verify credentials and server availability.
- Search (PROPFIND): Lists the contents of the user's root directory.
- Deletion (PUT + DELETE): A small file is added and then immediately deleted (to avoid errors like in cases where a file that is attempted to be deleted does not exist).
- Read (GET): Retrieves the contents of the Readme.md file, which is included by default in every new user’s storage.
- Upload (PUT): Uploads files of different sizes depending on the load scenario.

Each .py script represents a different load testing scenario:
- `locust_tasks_light.py`: Lighteight file (1KB) upload tasks are performed at a frequency of 1 to 5 seconds.
- `locust_tasks_medium.py`: Medium load with a mix of 1KB and 1MB file uploads, with tasks occurring every 1 to 3 seconds.
- `locust_tasks_heavy.py`: Heavy load with a mix of 1KB, 1MB, and 1GB file uploads, with tasks occurring every 2 to 4 seconds. 

Information regarding locust test execution can be found in the project's README file.

### Locust test results
For the first test (light load), 80 users were simulated over a period of 5 minutes. The spawn rate was set to 1 user per second. The following are plots representing the request per second and response time percentiles.

![LightLoadTest](results/test1.png)

The following are some statistics from the test:



For the second test (medium load), 80 users were simulated over a period of 5 minutes. The spawn rate was also set to 1 user per second. The results are displayed below:

![MediumLoadTest](results/test2.png)

The following are some statistics from the test:

For the third test (heavy load), 10 users were also simulated over a period of 5 minutes. The spawn rate was set to 1 user per second. 
Only 10 users were used for this test because the system was not able to handle more concurrent users while uploading large files (1GB). The following are the results:

![HeavyLoadTest](results/test3.png)

The following are some statistics from the test:




### Scalability
As observed from the stress tests, as concurrent users, request frequency and file sizes increase the system's performances degrade. To address this, it’s essential to consider scalability strategies that ensure the system remains responsive under higher loads.

In cloud computing there are two main approaches to scalability: vertical and horizontal scaling.

Vertical scaling involves upgrading the existing server's hardware resources, such as increasing CPU, RAM, or storage capacity. This approach is relatively straightforward and can provide immediate performance improvements. However, it has limitations, as there is a maximum capacity that a single server can reach, and it may lead to downtime during the upgrade process.
Furthermore in the case of failure of the single server, the entire system would be unavailable.

Horizontal scaling, on the other hand, involves adding more servers to distribute the load and increase capacity. This is usually the preferred approach for scalable cloud-native systems. In the context of Docker and Nextcloud, this could mean running multiple instances of the Nextcloud container behind a load balancer, which distributes incoming requests across all available instances.

This last approach offers several advantages:
- Improved fault tolerance: If one server fails, others can continue to handle requests, ensuring high availability.
- Better resource utilization: Workloads can be distributed across multiple servers, preventing any single server from becoming a bottleneck.
- Flexibility: New servers can be added or removed dynamically based on demand.
- Reduced downtime: Updates and maintenance can be performed on individual servers without affecting the entire system.
This architecture could be further enhanced by separating out services such as the database (e.g., MariaDB), static file storage (e.g., mounted volumes), and background jobs, allowing each component to scale independently.
### Cost Efficiency






### Conclusions