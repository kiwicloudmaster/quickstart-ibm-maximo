#!/bin/bash
# Oracle Objects creation

# extract command-line options into variables.
DBUser=$1
DBPassword=$2
Endpoint=$3
Port=$4
DBName=$5

# Extract the client packages
cd /home/ec2-user
unzip -o instantclient-basiclite-linux.x64-19.6.0.0.0dbru.zip
unzip -o instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip

# Install the operating system packsge - libaio
sudo yum install libaio

# Update the runtime link path
sudo sh -c "echo /home/ec2-user/instantclient_19_3 > \
   		/etc/ld.so.conf.d/oracle-instantclient.conf"
sudo ldconfig

# Set file and folder permissions / ownership
chown -R ec2-user:ec2-user /home/ec2-user/instantclient_19_3
chown ec2-user:ec2-user /home/ec2-user/maximo_oracle_commands.sh
chown ec2-user:ec2-user /home/ec2-user/maximo_oracle_database_objects.sql
chmod 755 /home/ec2-user/maximo_oracle_commands.sh


# Build the sqlplus command
Connection="/home/ec2-user/instantclient_19_3/sqlplus '$DBUser/$DBPassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$Endpoint)(PORT=$Port))(CONNECT_DATA=(SID=$DBName)))' @maximo_oracle_database_objects.sql"

# Write command to shell script file
Executable="/home/ec2-user/create_objects.sh"
echo "#!/bin/bash" > $Executable
echo "LD_LIBRARY_PATH=/home/ec2-user/instantclient_19_3:$LD_LIBRARY_PATH" >> $Executable
echo "export LD_LIBRARY_PATH" >> $Executable
echo "PATH=$PATH:/home/ec2-user/instantclient_19_3" >> $Executable
echo "export PATH" >> $Executable
echo $Connection >> $Executable

#Execute script
chown ec2-user:ec2-user $Executable
chmod 755 $Executable
exec $Executable

echo "Object creation complete."
