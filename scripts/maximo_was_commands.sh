#!/bin/bash -x

# extract command-line options into variables.
Endpoint=$1
Port=$2
DBName=$3
Maximos3location=$4
DeployUtilities=$5



# Install aws cli
yum -y install  unzip telnet

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

mkdir /work
cd /work

# Download the installer files from S3
/usr/local/bin/aws s3 cp s3://$Maximos3location/IED_V1.8.8_Wins_Linux_86.zip .
/usr/local/bin/aws s3 cp s3://$Maximos3location/WAS_ND_V9.0_MP_ML.zip .
/usr/local/bin/aws s3 cp s3://$Maximos3location/was.repo.9000.java8_part1.zip .
/usr/local/bin/aws s3 cp s3://$Maximos3location/was.repo.9000.java8_part2.zip .
/usr/local/bin/aws s3 cp s3://$Maximos3location/was.repo.9000.java8_part3.zip .

# Install IBM Installation manager
unzip -q IED_V1.8.8_Wins_Linux_86.zip
./EnterpriseDVD/Linux_x86_64/EnterpriseCD-Linux-x86_64/InstallationManager/installc -log /tmp/IM_Install_Unix.xml -acceptLicense

# Extract java8 repositories
cd /work
mkdir java8
unzip -q was.repo.9000.java8_part1.zip -d java8
unzip -q was.repo.9000.java8_part2.zip -d java8
unzip -q was.repo.9000.java8_part3.zip -d java8


# Install the Websphere 9.0 and IBM java sdk 8

/opt/IBM/InstallationManager/eclipse/tools/imcl -acceptLicense install com.ibm.websphere.ND.v90 com.ibm.java.jdk.v8 -repositories WAS_ND_V9.0_MP_ML.zip,java8 -installationDirectory /opt``/IBM/WebSphere/AppServer -preferences com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts=false

export WAS_HOME=/opt/IBM/WebSphere/AppServer


# Create the DMGR profile and start the deployment manager
sh $WAS_HOME/bin/manageprofiles.sh -create -templatePath $WAS_HOME/profileTemplates/management -hostName `hostname -f` -profileName mxDmgr01  -profilePath $WAS_HOME/profiles/mxDmgr01 -cellName mxCell01 -nodeName mxCellManager01 -enableAdminSecurity  "true" -adminUserName "wasadmin" -adminPassword "wasadmin"

sh $WAS_HOME/profiles/mxDmgr01/bin/startManager.sh

# Create appserver profile and start the node

sh $WAS_HOME/bin/manageprofiles.sh -create -templatePath $WAS_HOME/profileTemplates/managed -hostName `hostname -f` -profileName mxAppSrv01 -profilePath $WAS_HOME/profiles/mxAppSrv01 -cellName mxNodeCell01 -nodeName mxNode01

sh $WAS_HOME/profiles/mxAppSrv01/bin/addNode.sh localhost 8879 -username wasadmin -password wasadmin

sh $WAS_HOME/profiles/mxAppSrv01/bin/startNode.sh

# Create the app server

sh $WAS_HOME/bin/wsadmin.sh -lang jython -username "wasadmin" -password "wasadmin" -c "AdminServerManagement.createApplicationServer('mxNode01', 'server1','default')" &



# Download  and install the maximo
mkdir /Launchpad
cd /Launchpad
/usr/local/bin/aws s3 cp s3://$Maximos3location/MAM_7.6.1.0_LINUX64.tar.gz .
tar -xf MAM_7.6.1.0_LINUX64.tar.gz
export BYPASS_PRS=True # Bypass the prechecks
/opt/IBM/InstallationManager/eclipse/tools/imcl input /Launchpad/SilentResponseFiles/Unix/ResponseFile_MAM_Install_Unix.xml -log /tmp/MAM_Install_log.xml -acceptLicense

if [ $DeployUtilities = "Yes" ];
then
  mkdir /Launchpad/utilities
  cd /Launchpad/utilities
  /usr/local/bin/aws s3 cp s3://$Maximos3location/MAXIMO_UTILITIES_7.6_MP_ML.zip
  unzip -q MAXIMO_UTILITIES_7.6_MP_ML.zip
  /opt/IBM/InstallationManager/eclipse/tools/imcl input /Launchpad/utilities/Utilities_Silent_ResponseFile.xml -log /tmp/UtilitiesInstall_log.xml -acceptLicense
fi

cp /opt/IBM/SMP/maximo/applications/maximo/properties/maximo.properties.orig/maximo.properties /opt/IBM/SMP/maximo/applications/maximo/properties/
sed -i "s/^[[:blank:]]*mxe.db.url=jdbc:oracle:thin:/mxe.db.url=jdbc:oracle:thin:@$Endpoint:$Port:$DBName/" /opt/IBM/SMP/maximo/applications/maximo/properties/maximo.properties


# Deploy the empty database schema and tables
cd /opt/IBM/SMP/maximo/tools/maximo
./maxinst.sh -sMAXINDEX -tMAXDATA -imaximo

# Start the app server
sh $WAS_HOME/profiles/mxAppSrv01/bin/startServer.sh server1

# Generate the maximo ear files
cd /opt/IBM/SMP/maximo/deployment
sh buildmaximoear.sh
sh buildmaximo-xwar.sh

sh $WAS_HOME/bin/wsadmin.sh -lang jython -username "wasadmin" -password "wasadmin" -f /home/ec2-user/CreateApplications.py