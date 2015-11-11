#!/usr/bin/perl -w

# For troubleshooting and debugging purposes you can use +trace => qw( debug ) 
# use SOAP::Lite +trace => qw( debug ) ; 
use SOAP::Lite; 

# Convenient subroutine for printing all SOAP faults 
sub print_fault { 
my ($result) = @_; 

if ($result->fault) { 
print "faultcode=" . $result->fault->{'faultcode'} . "\n"; 
print "faultstring=" . $result->fault->{'faultstring'} . "\n"; 
#print "detail=" . $result->fault->{'detail'} . "\n"; 
} 
} 

# Variable to hold URL of WSDL location 
# Change localhost to the name of your Zephyr Server 
my $url = 'http://localhost:81/flex/services/soap/zephyrsoapservice-v1'; 

# Initiliaze soap variable object 
# SOAP::Lite wants to add a SOAPAction but Zephyr doesn't want it. So we replace it with empty space for every call 
my $soap = SOAP::Lite-> new(proxy => $url); 
$soap-> ns('http://soap.service.thed.com/', 'thed'); 
$soap-> on_action( sub { '""' } ); 

# Previously defined login params are saved in @params 
my @params = ( SOAP::Data->name("username" => 'test.manager'), 
SOAP::Data->name("password" => 'test.manager') ); 

# Initializes a method for logging in from WSDL's call: login 
my $login = SOAP::Data->name('thed:login'); 

# Passes the parameters to the method and calls the method to be run 
# Saves the result of the call in '$result' 
my $result = $soap->call($login => @params); 

# If statement to test if login was a success 
# If the statement has a fault, it will 'pass' the If statement and print failure 
# If the statement fails, it will print successful login and session token 
if ($result->fault) 
{ 
print 'Login Failed, Try again: '; 
print_fault($result); 
} 
else 
{ 
print 'Logged In.'; 
print "\n\n"; 
print 'The session token is: '; 
print $result->result(); 
} 

# Saves token into session variable 
my $session = $result->result(); 

print "\n"; 

# Creates a getTestCaseTreesByCriteria method from WSDL's call: getTestCaseTreesByCriteria 
$getTestCaseTreesByCriteria = SOAP::Data->name('thed:getTestCaseTreesByCriteria'); 

# Creates and initializes variables for getTestCaseTreesByCriteria 
# searchCriteria is a value made up of: searchName, searchOperation, and searchValue 
# returnAllDataFlag is false, true would return all projects, regardless of criteria 
# token is set to the session token created at login 
@params = ( SOAP::Data->name("searchCriterias" => 
{}SOAP::Data->value( 
SOAP::Data->name("searchName" => SOAP::Data->value('releaseId')), 
SOAP::Data->name("searchOperation" => SOAP::Data->value('EQUALS')), 
SOAP::Data->name("searchValue" => SOAP::Data->value('2')))), 
SOAP::Data->name("searchCriterias" => 
{}SOAP::Data->value( 
SOAP::Data->name("searchName" => SOAP::Data->value('name')), 
SOAP::Data->name("searchOperation" => SOAP::Data->value('EQUALS')), 
SOAP::Data->name("searchValue" => SOAP::Data->value('DevZone')))), 
SOAP::Data->name("returnAllDataFlag" => 'false'), 
SOAP::Data->name("token" => $session) ); 

# Saves return from Zephyr Server to result variable 
$result = $soap->call($getTestCaseTreesByCriteria => @params); 

# Created for saving information returned from getTestCaseTrees call and used later 
my $treeId; 
my $treeReleaseId; 

# Checks if return is valid or not 
# Valid returns list Testcase Tree details 
if ($result->fault) 
{ 
print 'getTestCaseTreesByCriteria Failed, Try again: '; 
print_fault($result); 
} 
else 
{ 
# First array entry will be in result 
my @listings1 = $result->result(); 

# $listing1 is the array of structs 
foreach my $listing1 (@listings1) { 
# Save parameters for later use 
$treeId = $listing1->{id}; 
$treeReleaseId = $listing1->{releaseId}; 

print "\n-----------------------------------------\n"; 
print "Returned Values for Testcase Tree\n"; 
print "\n-----------------------------------------\n"; 
# print description for every listing 
foreach my $key (keys %{$listing1}) { 
print $key, ": ", $listing1->{$key} || '', "\n"; 
} 
} 
} 

print "\n"; 

# Creates a createNewTestcase method from WSDL's call: createNewTestcase 
$createNewTestcase = SOAP::Data->name('thed:createNewTestcase'); 

# Creates and initializes variables for createNewTestcase 
# remoteRepositoryTreeTestcase is made of fields and another object of 'testcase' 
# remoteRepositoryTreeTestcase and the testcase inside it use the 2 global variables we created earlier (treeId, treeReleaseId) 
# token is set to the session token created at login 
@params = ( SOAP::Data->name("remoteRepositoryTreeTestcase" => 
{}SOAP::Data->value( 
SOAP::Data->name("remoteRepositoryId" => $treeId), 
SOAP::Data->name("testSteps" => '<steps maxId=\"3\"><step id=\"1\" orderId=\"1\" detail=\"Test Step 1\" data=\"Test Data \" result=\"Excepted Results \" /> <step id=\"2\" orderId=\"2\" detail=\"Test Step T2 \" data=\"\" result=\"\" /> <step id=\"3\" orderId=\"3\" detail=\"Test Step T3 -Test\" data=\"\" result=\"\" /></steps>'), 
SOAP::Data->name("testcase" => 
{}SOAP::Data->value( 
SOAP::Data->name("name" => 'Created in Perl via API!'), 
SOAP::Data->name("comments" => 'test.manager'), 
SOAP::Data->name("externalId" => '99999'), 
SOAP::Data->name("priority" => '1'), 
SOAP::Data->name("tag" => 'API'), 
SOAP::Data->name("automated" => '0'), 
SOAP::Data->name("releaseId" => $treeReleaseId)))), 
SOAP::Data->name("token" => $session)) ); 

# Saves return from Zephyr Server to result variable 
$result = $soap->call($createNewTestcase => @params); 

# Checks if return is valid or not 
# Valid returns list of new Testcase details 
if ($result->fault) 
{ 
print 'createNewTestcase Failed, Try again: '; 
print_fault($result); 
} 
else 
{ 
print "\n-----------------------------------------\n"; 
print "Returned Values for New Testcase\n"; 
print "\n-----------------------------------------\n"; 
my @listings1 = $result->result(); 
my @listings2 = $result->paramsout(); 

# @listings is the array of structs 
foreach my $listing2 (@listings2) { 
print "\n"; 
# print description for every listing 
foreach my $key (keys %{$listing2}) { 
print $key, ": ", $listing2->{$key} || '', "\n"; 
} 
} 

foreach my $listing1 (@listings1) { 
print "\n"; 
# print description for every listing 
foreach my $key (keys %{$listing1}) { 
print $key, ": ", $listing1->{$key} || '', "\n"; 
} 
} 
} 

print "\n"; 

# Creates a logout method from WSDL's call: logout 
my $logout = SOAP::Data->name('thed:logout'); 

@params = ( SOAP::Data->name("token" => $session ) ); 

$result = $soap->call($logout => @params); 

# Checks if return is valid or not 
if ($result->fault) 
{ 
print 'Logout Failed, Try again: '; 
print_fault($result); 
} 
else 
{ 
print 'Logged out.'; 
print "\n\n"; 
print $result->result(); 
} 

print "\n";