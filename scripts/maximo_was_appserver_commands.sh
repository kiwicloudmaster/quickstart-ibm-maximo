#!/bin/bash -x

# extract command-line options into variables.
Maximos3location=$1
DMGRAutoscalingGroup=$2



# Install aws cli
yum -y install  unzip telnet dos2unix

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install

mkdir /work
cd /work

REGION=$(curl -sq http://169.254.169.254/latest/meta-data/placement/availability-zone/)
#ex: us-east-1a => us-east-1
REGION=${REGION: :-1}
export AWS_DEFAULT_REGION=${REGION}

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


dmgripaddress=localhost
nodeName=mxNode-`hostname -f`

# Create appserver profile and start the node

sh $WAS_HOME/bin/manageprofiles.sh -create -templatePath $WAS_HOME/profileTemplates/managed -hostName `hostname -f` -profileName mxClusterAppSrv -profilePath $WAS_HOME/profiles/mxClusterAppSrv -cellName mxNodeCell01 -nodeName $nodeName



for ID in `/usr/local/bin/aws autoscaling describe-auto-scaling-groups  --auto-scaling-group-name $DMGRAutoscalingGroup --query AutoScalingGroups[].Instances[].InstanceId  --output text`
do
dmgripaddress=`/usr/local/bin/aws ec2 describe-instances --instance-ids $ID --query Reservations[].Instances[].PrivateIpAddress --output text`
done;

echo $dmgripaddress


until sh $WAS_HOME/profiles/mxClusterAppSrv/bin/addNode.sh $dmgripaddress 8879 -username wasadmin -password wasadmin -noagent
do
  sleep 5
done
sh $WAS_HOME/profiles/mxClusterAppSrv/bin/startNode.sh



sed -i "s/node_name/$nodeName/" /home/ec2-user/CreateAppServer.py


sh $WAS_HOME/profiles/mxClusterAppSrv/bin/wsadmin.sh -lang jython -username "wasadmin" -password "wasadmin" -f /home/ec2-user/CreateAppServer.py
sleep 10
# restarting the app server
sh $WAS_HOME/profiles/mxClusterAppSrv/bin/wsadmin.sh -lang jython -username "wasadmin" -password "wasadmin" -c "AdminControl.stopServer('appserver', '$nodeName', 'immediate')"
sh $WAS_HOME/profiles/mxClusterAppSrv/bin/wsadmin.sh -lang jython -username "wasadmin" -password "wasadmin" -c "AdminControl.startServer('appserver', '$nodeName')"



