

# Creating cluster member
AdminClusterManagement.createClusterMember("maximomCluster", "node_name", "appserver")
AdminConfig.save()
AdminNodeManagement.syncActiveNodes()

# Starting the app server
AdminServerManagement.startAllServers("node_name")

# saving the configurations
AdminNodeManagement.syncActiveNodes()
AdminConfig.save()
appManager = AdminControl.queryNames('cell=mxCell01,node=node_name,type=ApplicationManager,process=appserver,*')
maximoObject = AdminControl.completeObjectName('type=Application,name=maximo,*')

# changing the App server web container settings to not overwrite the Load balancer URL with ports
serverId = AdminConfig.getid('/Cell:mxCell01/Node:node_name/Server:appserver/')
webContainer = AdminConfig.list("WebContainer",serverId)
AdminConfig.create('Property', webContainer, [['name','trusthostheaderport'],['value','true']])
AdminConfig.create('Property', webContainer, [['name','com.ibm.ws.webcontainer.extractHostHeaderPort'],['value','true']])
AdminConfig.save()

# restarting application servers to apply the custom settings
AdminServerManagement.stopAllServers("node_name")
AdminServerManagement.startAllServers("node_name")
AdminConfig.save()
AdminNodeManagement.syncActiveNodes()







