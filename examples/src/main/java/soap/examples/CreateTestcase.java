package soap.examples;

import java.net.MalformedURLException; 
import java.net.URL; 
import java.util.ArrayList; 
import java.util.List; 
import javax.xml.namespace.QName; 
import com.thed.service.soap.wsdl.RemoteCriteria; 
import com.thed.service.soap.wsdl.RemoteFieldValue; 
import com.thed.service.soap.wsdl.RemoteRepositoryTree; 
import com.thed.service.soap.wsdl.RemoteRepositoryTreeTestcase; 
import com.thed.service.soap.wsdl.RemoteTestcase; 
import com.thed.service.soap.wsdl.SearchOperation; 
import com.thed.service.soap.wsdl.ZephyrServiceException; 
import com.thed.service.soap.wsdl.ZephyrSoapService; 
import com.thed.service.soap.wsdl.ZephyrSoapService_Service; 

public class CreateTestcase { 

	/* 
	* startZephyrService() 
	*/ 
	//String URL variable that holds the location of your Zephyr WSDL file 
	//This example has http://localhost but yours may be different 
	private static String strURL = "http://localhost:81/flex/services/soap/zephyrsoapservice-v1?wsdl"; 
	// 
	public static ZephyrSoapService client; 

	/* 
	* loginProcess() 
	*/ 
	//Name of user performing operation. Test.manager is a default user name in a standard Zephyr installation 
	private static String username = "test.manager"; 
	//Password for named user performing the operation. Test.manager is a default password for the test.manager user name 
	private static String password = "test.manager"; 
	//Variable for token created in login process 
	public static String token = new String(); 

	/* 
	* Main() 
	*/ 
	static String tcReleaseId = "5"; 
	static String tcPhaseFolder = "DevZone"; 


	//List of remoteCriteria used to search for items in Zephyr DB - 'by Criteria' 
	public static List<RemoteCriteria> rcList = new ArrayList<RemoteCriteria>(); 
	//An individual criteria composed of 3 parts; name, operation, and value 
	//Mulitple criteria can be used in a search search for more refined searches/results 
	public static RemoteCriteria remoteCriteria = new RemoteCriteria(); 
	public static RemoteCriteria remoteCriteria2 = new RemoteCriteria(); 
	//Creates Repository Tree Testcase 
	public static RemoteRepositoryTreeTestcase treeTestcase = new RemoteRepositoryTreeTestcase(); 
	//Creates remoteTestcase item 
	public static RemoteTestcase testcase = new RemoteTestcase(); 
	//remoteTestcaseTrees list 
	public static List<RemoteRepositoryTree> treeList = new ArrayList<RemoteRepositoryTree>(); 
	//RemoteRepositryTree item 
	public static RemoteRepositoryTree tree = new RemoteRepositoryTree(); 
	//Stores response from Zephyr after testcase creation 
	List<RemoteFieldValue> response = new ArrayList<RemoteFieldValue>(); 

	public static void startZephyrService() { 
		try{ 
		//Initializes the URL data type with strURL created above 
		final URL WSDL_URL = new URL(strURL); 

		//Create an instance of ZephyrSoapService. And initialize it with namespaceUri and LocalPart 
		ZephyrSoapService_Service serviceWithUrl = new ZephyrSoapService_Service(WSDL_URL, new QName( 
		"http://soap.service.thed.com/", "ZephyrSoapService")); 
		//servicePortWithUrl is used for API calls to retrieve and add information in Zephyr 
		client = serviceWithUrl.getZephyrSoapServiceImplPort(); 

		} catch (MalformedURLException ex) { 
			throw new RuntimeException (ex); 
			} 
	} 

	public static void loginProcess() throws ZephyrServiceException { 
		startZephyrService(); 

		//Login to Zephyr and pass the returned token into the token variable for later use 
		token = client.login(username, password); 
		if(token == null) 
		System.out.println("Login Failed!"); 
		else 
		System.out.println("Successfully Logged In. Your Token is: " + token); 
	} 

	public static void logoutProcess() throws ZephyrServiceException { 
		client.logout(token); 
		System.out.println("\n" + "This session has ended."); 
	} 

	/* 
	* Create New Testcase In Zephyr via API 
	*/ 
	public static void main(String[] args) throws ZephyrServiceException { 
		loginProcess(); 

		//Search criteria to look for all repository trees//phases in release 2 
		remoteCriteria.setSearchName("releaseId"); 
		remoteCriteria.setSearchOperation(SearchOperation.EQUALS); 
		remoteCriteria.setSearchValue(tcReleaseId); 
		//Search criteria to additionally look for all trees//phases named DevZone (in the above release 2) 
		remoteCriteria2.setSearchName("name"); 
		remoteCriteria2.setSearchOperation(SearchOperation.EQUALS); 
		remoteCriteria2.setSearchValue(tcPhaseFolder); 

		//Adding the search criteria to the Remote Criteria list 
		rcList.add(remoteCriteria); 
		rcList.add(remoteCriteria2); 


		treeList = client.getTestCaseTreesByCriteria(rcList, false, token); 
		//If none are found or more than one tree is returned, you will need to write code to handle that 
		tree = treeList.get(0); 

		//Enter field information for the testcase 
		testcase.setName("This Testcase was created via API"); 
		testcase.setComments("Created via SOAP API!"); 
		testcase.setAutomated(false); 
		testcase.setExternalId("99999"); 
		testcase.setPriority("1"); 
		testcase.setTag("API"); 
		//Set release the testcase will be located at 
		testcase.setReleaseId(tree.getReleaseId()); 

		//Repository trees//phases Id used to link the new testcase to a tree//phase 
		treeTestcase.setRemoteRepositoryId(tree.getId()); 
		//Adding test steps to the testcase 
		treeTestcase.setTestSteps("<steps maxId=\"3\"><step id=\"1\" orderId=\"1\" detail=\"Test Step 1\" data=\"Test Data \" result=\"Excepted Results \" />" + 
		"<step id=\"2\" orderId=\"2\" detail=\"Test Step T2 \" data=\"\" result=\"\" />" + 
		"<step id=\"3\" orderId=\"3\" detail=\"Test Step T3 -Test\" data=\"\" result=\"\" /></steps>"); 
		//Loading the testcase object I changed just above into the remoteRepositoryTreeTestcase object 
		treeTestcase.setTestcase(testcase); 

		//Actually creating the new TC here 
		//With bulk testcases you may want to use loops and list arrays 
		//Response from Zephyr will give a list of 2 values; (0)-TCR Tree Testcase ID, (1)-Testcase ID (The one you see in the UI) 
		List<RemoteFieldValue> response = client.createNewTestcase(treeTestcase, token); 

		System.out.println("\n" + "Testcase Created!"); 
		System.out.println(response.get(0).getKey() + ": " + response.get(0).getValue()); 
		System.out.println(response.get(1).getKey() + ": " + response.get(1).getValue()); 

		logoutProcess(); 
	} 
}