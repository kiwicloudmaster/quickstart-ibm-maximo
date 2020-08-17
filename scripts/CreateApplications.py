import time

AdminApp.install('/opt/IBM/SMP/maximo/deployment/default/maximo.ear',['-server', 'server1','-appname', 'maximo', '-usedefaultbindings' ,'-node' ,'mxNode01', '-cell' ,'mxCell01'])
AdminConfig.save()

AdminApp.install('/opt/IBM/SMP/maximo/deployment/default/maximo-x.war',['-server', 'server1','-appname', 'maximo-x', '-usedefaultbindings','-node' ,'mxNode01', '-cell' ,'mxCell01'])
AdminConfig.save()


print AdminApp.list("WebSphere:cell=mxCell01,node=mxNode01,server=server1")

appManager = AdminControl.queryNames('cell=mxCell01,node=mxNode01,type=ApplicationManager,process=server1,*')
print appManager
result = AdminApp.isAppReady('maximo')
while (result == "false"):
    ### Wait 5 seconds before checking again
    time.sleep(5)
    result = AdminApp.isAppReady('maximo')
print("Starting applications...")

AdminControl.invoke(appManager, 'startApplication', 'maximo')
AdminControl.invoke(appManager, 'startApplication', 'maximo-x')

AdminConfig.save()

