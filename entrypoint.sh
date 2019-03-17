#!/bin/bash

if [ ! -v DBHOST ];then
    DBHOST=localhost
fi

if [ ! -v DBUSER ];then
    DBUSER=${ASTERISKUSER}
fi

if [ ! -v DBPASS ];then
    DBPASS=
fi

if [ ! -v DBNAME ];then
    DBNAME=asterisk
fi

if [ ! -v CDR_DBHOST ];then
    CDR_DBHOST="${DBHOST}"
fi

if [ ! -v CDR_DBUSER ];then
    CDR_DBUSER="${DBUSER}"
fi

if [ ! -v CDR_DBPASS ];then
    CDR_DBPASS="${DBPASS}"
fi

if [ ! -v CDR_DBNAME ];then
    CDR_DBNAME=asteriskcdrdb
fi

if [ $CDR_DBHOST -eq "localhost" ]; then
    CDR_DBSOCKET=/var/run/mysqld/mysqld.sock
fi

# update db information
sed -i "s/\(.*AMPDBHOST[^=]*= \)\(.*\)/\\1'${DBHOST}';/g" /etc/freepbx.conf 
sed -i "s/\(.*AMPDBUSER[^=]*= \)\(.*\)/\\1'${DBUSER}';/g" /etc/freepbx.conf 
sed -i "s/\(.*AMPDBPASS[^=]*= \)\(.*\)/\\1'${DBPASS}';/g" /etc/freepbx.conf 
sed -i "s/\(.*AMPDBNAME[^=]*= \)\(.*\)/\\1'${DBNAME}';/g" /etc/freepbx.conf 

sed -i "s/\(.*CDRDBHOST[^=]*= \)\(.*\)/\\1'${CDR_DBHOST}';/g" /etc/freepbx.conf 
sed -i "s/\(.*CDRDBUSER[^=]*= \)\(.*\)/\\1'${CDR_DBUSER}';/g" /etc/freepbx.conf 
sed -i "s/\(.*CDRDBPASS[^=]*= \)\(.*\)/\\1'${CDR_DBPASS}';/g" /etc/freepbx.conf 
sed -i "s/\(.*CDRDBNAME[^=]*= \)\(.*\)/\\1'${CDR_DBNAME}';/g" /etc/freepbx.conf 

sed -i "s/\(^Server[^=]*= \)\(.*\)/\\1${CDR_DBHOST}/g" /etc/odbc.ini
sed -i "s/\(^USER[^=]*= \)\(.*\)/\\1${CDR_DBUSER}/g" /etc/odbc.ini
sed -i "s/\(^Password[^=]*= \)\(.*\)/\\1${CDR_DBPASS}/g" /etc/odbc.ini 
sed -i "s/\(^Database[^=]*= \)\(.*\)/\\1${CDR_DBNAME}/g" /etc/odbc.ini
sed -i "s/\(^Socket[^=]*= \)\(.*\)/\\1${CDR_DBSOCKET}/g" /etc/odbc.ini

# start mysql if required
if [ $DBHOST == "localhost" || $CDR_DBHOST == "localhost" ];then
    /etc/init.d/mysql start
fi 

# create tables if required
if [ -z $DBPASS ]; then
    check=`echo show tables | mysql -h$DBHOST -u$DBUSER $DBNAME | wc -l`
    if [ $check == 0 ];then
        cat ~/asterisk.sql | mysql -h$DBHOST -u$DBUSER $DBNAME
    fi
else
    check=`echo show tables | mysql -h$DBHOST -u$DBUSER -p$DBPASS $DBNAME | wc -l`
    if [ $check == 0 ];then
        cat ~/asterisk.sql | mysql -h$DBHOST -u$DBUSER -p$DBPASS $DBNAME
    fi
fi

echo show tables | mysql $CDR_DBNAME | grep cdr
if [ -z $CDR_DBPASS ]; then
    check=`echo show tables | mysql -h$CDR_DBHOST -u$CDR_DBUSER $CDR_DBNAME | grep cdr | wc -l`
    if [ $check == 0 ];then
        cat ~/asterisk_cdr.sql | mysql -h$CDR_DBHOST -u$CDR_DBUSER $CDR_DBNAME
    fi
else
    check=`echo show tables | mysql -h$CDR_DBHOST -u$CDR_DBUSER -p$CDR_DBPASS $CDR_DBNAME | grep cdr | wc -l`
    if [ $check == 0 ];then
        cat ~/asterisk_cdr.sql | mysql -h$CDR_DBHOST -u$CDR_DBUSER -p$CDR_DBPASS $CDR_DBNAME
    fi
fi
# start apache
/etc/init.d/apache2 start

# start asterisk
asterisk -f -U ${ASTERISKUSER} &

sleep 10

# reload config
fwconsole r

tail -F /var/log/mysql/* /var/log/apache2/*

