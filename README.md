# Introduction 
This project contains the source files and example implementation for Docker MSSQL Container including a restore backup file

# Content
1.  Overview of Docker Containers
       + What is a Docker Container?
            + [Docker Container](https://www.docker.com/resources/what-container)
       + What is a Dockerfile?
            + [Dockerfile](https://docs.docker.com/engine/reference/builder)
       + What is a Docker Compose file?
            + [Docker Compose File](https://docs.docker.com/compose/compose-file)

# Getting Started
1.	Installation process
    +  Download Docker for Windows
        + [Docker Desktop](https://www.docker.com/products/docker-desktop)
        +  Follow the standard instructions from the wizard

2.	Clone git repo from vsts
    +  [docker-mssql-linux](https...)

    + How to run example project
        1. Open powershell
        2. Navigate to the solution folder
            ```
            > cd /yourRepoFolder/docker-mssql-linux/src
            ```
        3. Execute compose command
            ```
            > docker-compose up --build
            ```
             Note: The first time you run this command is going to download mssql image in your local and extract all download packages, So it's going to take some time (about 20 min based on internet connection speed)

                ```
                    Step 1/5 : FROM microsoft/mssql-server-windows-developer
                    latest: Pulling from microsoft/mssql-server-windows-developer
                    3889bb8d808b: Downloading [=====================>                             ]  1.773GB/4.07GB
                    449343c9d7e2: Downloading [===>                                               ]  88.88MB/1.304GB
                    08883151461d: Download complete
                    bafeb45a72fc: Download complete
                    f5c5aa235c5b: Download complete
                    158fead2ffa0: Download complete
                    746db9597cec: Download complete
                    9e96edbd8781: Download complete
                    c6dabab6234f: Download complete
                    975d0dccd859: Download complete
                    5b747cfb01b7: Download complete
                    c77992bbfd0f: Download complete
                ```
        4. Results
            ```
                Building mssql
                Step 1/5 : FROM microsoft/mssql-server-windows-developer
                latest: Pulling from microsoft/mssql-server-windows-developer
                3889bb8d808b: Pull complete
                449343c9d7e2: Pull complete
                08883151461d: Pull complete
                bafeb45a72fc: Pull complete
                f5c5aa235c5b: Pull complete
                158fead2ffa0: Pull complete
                746db9597cec: Pull complete
                9e96edbd8781: Pull complete
                c6dabab6234f: Pull complete
                975d0dccd859: Pull complete
                5b747cfb01b7: Pull complete
                c77992bbfd0f: Pull complete
                Digest: sha256:a3e77eb7ac136bf419269ab6a3f3387df5055d78b2b6ba2e930e1c6312b50e07
                Status: Downloaded newer image for microsoft/mssql-server-windows-developer:latest
                ---> 19873f41b375
                Step 2/5 : RUN powershell -Command mkdir C:\\SQLServer
                ---> Running in 8200439d3f39


                    Directory: C:\


                Mode                LastWriteTime         Length Name
                ----                -------------         ------ ----
                d-----        11/1/2018  12:56 PM                SQLServer


                Removing intermediate container 8200439d3f39
                ---> dfed5da3610a
                Step 3/5 : COPY TestDB.bak C:\\SQLServer
                ---> 9310513a50a8
                Step 4/5 : COPY TestDBRestoreScript.sql C:\\SQLServer
                ---> 7815324e3fda
                Step 5/5 : RUN sqlcmd -i C:\\SQLServer\\TestDBRestoreScript.sql
                ---> Running in 33d41624ccd9
                Changed database context to 'master'.
                Processed 344 pages for database 'TestDB', file 'TestDB' on file 1.
                Processed 5 pages for database 'TestDB', file 'TestDB_log' on file 1.
                RESTORE DATABASE successfully processed 349 pages in 0.037 seconds (73.572 MB/sec).
                Removing intermediate container 33d41624ccd9
                ---> b9191500434c

                Successfully built b9191500434c
                Successfully tagged src_mssql:latest
                WARNING: Image for service mssql was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
                Creating src_mssql_1 ... done
                Attaching to src_mssql_1
                mssql_1  | VERBOSE: Starting SQL Server
                mssql_1  | VERBOSE: Changing SA login credentials
                mssql_1  | VERBOSE: Started SQL Server.		
            ```
        5. Connect to your DB from SQL Management Studio using localhost as server name or address and the password defined in your Dockerfile and database-setup.sh

        Dockerfile

        ```
        ENV SA_PASSWORD=SuperStrongPwd1
        ```

        database-setup

        ```
        #wait for the SQL Server to come up
        sleep 30s

        #run the setup script to create the DB and the schema in the DB
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P SuperStrongPwd1! -d master -i TestDBRestoreScript.sql  
         ```

# Solution Template

+ Docker MSSQL Docker Container Template
    + Solution structure
        ```

            ├── docker-mssql-container      # Solution folder
            ├── src                         # Contains all files required
            │   ├── docker-compose.yml      # Docker compose file
            │   ├── Dockerfile              # Dockerfile 
            │   └── TestDBRestoreScript.sql # Scrip to restore DB backup in build process
            │   └── TestDB.bak              # Simple DB backup to restore
            │   └── database-setup.sh
            │   └── entrypoint.sh

        ```
    + Dockerfile script 	
        ```
            FROM microsoft/mssql-server-linux:2017-latest
            ENV ACCEPT_EULA=Y
            ENV SA_PASSWORD=SuperStrongPwd1
            EXPOSE 1433

            RUN mkdir -p /usr/src/app
            WORKDIR /usr/src/app

            COPY TestDB.bak  .
            COPY TestDBRestoreScript.sql .
            COPY database-setup.sh .
            COPY entrypoint.sh .

            RUN chmod +x /usr/src/app/database-setup.sh
            RUN /bin/bash ./entrypoint.sh
        ```
    + TestDBRestoreScript.sql script  
      ```
        USE [master]

        RESTORE DATABASE [TestDB]
        FROM DISK = '/usr/src/app/TestDB.bak' 
        WITH 
            MOVE 'TestDB' TO '/var/opt/mssql/data/TestDB.mdf',
            MOVE 'TestDB_Log' TO '/var/opt/mssql/data/TestDB_Log.ldf'
        ```
    + docker-compose.yml content
    	```
        version: '3.7'

        networks: 
        bridge:
            driver: bridge
            
        services:

        mssql:
        
            build:
            context: ./
            dockerfile: Dockerfile
            
            networks:
            - bridge
            
            ports:
            - "1433:1433"
            
            healthcheck:
            test: [ "CMD", "SQLCMD", "-U", "SA", "_P", "Administrador1", "-Q", "SELECT 1" ]
            interval: 1s
            retries: 20
		```
	
# Additional Resources
+ Create MSSQL DB backup 
    + [Create a Full Database Backup](https://docs.microsoft.com/en-us/sql/relational-databases/backup-restore/create-a-full-database-backup-sql-server?view=sql-server-2017)

+ Useful docker commands
    + List all images in local machine
        ```
            > docker images
        ```
    + List all containers in local machine
        ```
            > docker ps -a
        ```
    + Remove docker container 
        ```
            > docker rm [container name or id]
        ```
    + Remove docker image 
        ```
            > docker rmi [image name or id]
        ```
    + Open a container 
        ```
            > docker exec -it [container name or id] [powershell or bash param]
        ```
    + Stop a container 
        ```
            > docker stop [container name or id]
        ```
    + Start a container 
        ```
            > docker container start [container name or id]
        ```
        
