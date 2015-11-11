# Imports logging and from external SUDS installation 
import logging 
from suds.client import Client 

# Setup logging for file 
logging.basicConfig(level=logging.INFO) 

# Setup logging for the SOAP client to show soap messages (in & out) and http headers: 
# logging.getLogger('suds.client').setLevel(logging.DEBUG) 

# URL to WSDL file on server and setup client variable 
url = 'http://localhost:81/flex/services/soap/zephyrsoapservice-v1?wsdl' 
client = Client(url) 

# To get a list of methods provided by the Zephyr service, uncomment: 
# print client 

# Set username and password used to log in. Must have privileges to perform operations below. 
username = 'test.manager' 
password = 'test.manager' 

# Creates variable for holding remoteCriteria information 
remoteCriteria = client.factory.create('ns0:remoteCriteria') 
remoteCriteria2 = client.factory.create('ns0:remoteCriteria') 

# Logs into Zephyr using predefined credentials (username and password) 
# prints generated session token for confirmation 
session = client.service.login(username, password) 
print 'Logged In.' 
print 'The session token is: %s\n' % session 

# Name, Operation, and Value of search can all be modified 
# In this case, having both filters for a search is redundant since no Release can have the same Id, but it does serve to show how multiple criteria searchs work 
remoteCriteria.searchName = 'releaseId' 
remoteCriteria.searchOperation = 'EQUALS' 
remoteCriteria.searchValue = '2' 

remoteCriteria2.searchName = 'name' 
remoteCriteria2.searchOperation = 'EQUALS' 
remoteCriteria2.searchValue = 'DevZone' 

# Performs search operation and holds the findings in 'treeList' 
# Variables passed to method are the remoteCriteria from above, a flag for returning all or some of the project information, and the session token for authentication 
treeList = client.service.getTestCaseTreesByCriteria((remoteCriteria, remoteCriteria2), 'false', session) 

# Saves the only returned testcase tree in the list to 'tree' 
for i in treeList: 
tree = i 

# Creates variables for holding Testcase and Tree Testcase information 
testcase = client.factory.create('ns0:remoteTestcase') 
treeTestcase = client.factory.create('ns0:remoteRepositoryTreeTestcase') 

# Field information for newly created testcase - input 
testcase.name = 'This Testcase was created via API' 
testcase.comments = 'Created via API!' 
testcase.automated = 'false' 
testcase.externalId = '99999' 
testcase.priority = '1' 
testcase.tag = 'API' 
testcase.releaseId = tree.releaseId 

# Continue, detailed information for newly created testcase - input 
# Major point here is the formatting of test steps when creating via API 
treeTestcase.remoteRepositoryId = tree.id 
treeTestcase.testSteps = '<steps maxId=\"3\"><step id=\"1\" orderId=\"1\" detail=\"Test Step 1\" data=\"Test Data \" result=\"Excepted Results \" /> <step id=\"2\" orderId=\"2\" detail=\"Test Step T2 \" data=\"\" result=\"\" /> <step id=\"3\" orderId=\"3\" detail=\"Test Step T3 -Test\" data=\"\" result=\"\" /></steps>' 
treeTestcase.testcase = testcase 

# Grab response from Zephyr DB when testcase creation is attempted 
response = client.service.createNewTestcase(treeTestcase, session) 

# Prints newly created testcase DB information, if successful 
print 'Testcase Created!' 
for rfv in response: 
print rfv.key 