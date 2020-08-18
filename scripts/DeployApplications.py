#Creating the empty cluster for maximo
AdminConfig.create('ServerCluster', AdminConfig.getid('/Cell:mxCell01/'), '[[name maximomCluster]]')

# deploying the maximo ear & war files to cluster
AdminApp.install('/opt/IBM/SMP/maximo/deployment/default/maximo-x.war', '[ -nopreCompileJSPs -distributeApp -nouseMetaDataFromBinary -nodeployejb -appname maximo-x -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn -noprocessEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema -contextroot /maximo-x -MapModulesToServers [[ Maximo-X maximo-x.war,WEB-INF/web.xml WebSphere:cell=mxCell01,cluster=maximomCluster ]] -MapWebModToVH [[ Maximo-X maximo-x.war,WEB-INF/web.xml default_host ]]]' )
AdminApp.install('/opt/IBM/SMP/maximo/deployment/default/maximo.ear', '[ -nopreCompileJSPs -distributeApp -nouseMetaDataFromBinary -deployejb -appname maximo -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn -noprocessEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema -MapModulesToServers [[ "MBO EJB Module" mboejb.jar,META-INF/ejb-jar.xml WebSphere:cell=mxCell01,cluster=maximomCluster ][ "MAXIMO Web Application" maximouiweb.war,WEB-INF/web.xml WebSphere:cell=mxCell01,cluster=maximomCluster ][ "MBO Web Application" mboweb.war,WEB-INF/web.xml WebSphere:cell=mxCell01,cluster=maximomCluster ][ "MEA Web Application" meaweb.war,WEB-INF/web.xml WebSphere:cell=mxCell01,cluster=maximomCluster ][ "REST Web Application" maxrestweb.war,WEB-INF/web.xml WebSphere:cell=mxCell01,cluster=maximomCluster ]] -MapWebModToVH [[ "MBO Web Application" mboweb.war,WEB-INF/web.xml default_host ]]]' )
#save the configurations
AdminConfig.save()



