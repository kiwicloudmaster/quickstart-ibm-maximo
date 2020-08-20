
# Creating cluster member
AdminClusterManagement.createClusterMember("maximomCluster", "node_name", "appserver")
AdminConfig.save()
AdminNodeManagement.syncActiveNodes()

# Starting the app server
AdminServerManagement.startAllServers("node_name")
AdminNodeManagement.syncActiveNodes()

# changing the App server web container settings to not overwrite the Load balancer URL with ports
serverId = AdminConfig.getid('/Cell:mxCell01/Node:node_name/Server:appserver/')
if serverId != "":
    webContainer = AdminConfig.list("WebContainer",serverId)
    if webContainer != "":
        AdminConfig.create('Property', webContainer, [['name','trusthostheaderport'],['value','true']])
        AdminConfig.create('Property', webContainer, [['name','com.ibm.ws.webcontainer.extractHostHeaderPort'],['value','true']])
        AdminConfig.save()
        AdminNodeManagement.syncActiveNodes()