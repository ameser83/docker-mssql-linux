FROM microsoft/mssql-server-linux:2017-latest
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=SuperStrongPwd1!
EXPOSE 1433

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY TestDB.bak  .
COPY TestDBRestoreScript.sql .
COPY database-setup.sh .
COPY entrypoint.sh .

RUN chmod +x /usr/src/app/database-setup.sh
RUN /bin/bash ./entrypoint.sh