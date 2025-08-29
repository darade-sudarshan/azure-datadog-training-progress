# Project02 - End to End Azure Data Engineering Real Time Project
Udemy Link :https://einfochips.udemy.com/course/end-to-end-azure-data-engineering-real-time-project/learn/lecture/45486093#overview
## Task 07: Create Resources in Azure Portal

### Create Resource Group

Step 1: Login to Azure Portal


Open your browser and type, https://portal.azure.com/ , this will take you to the home page of the Azure Portal after authenticating with your user account. The home page of the portal will look like below,

![alt text](Task07_images/azure_portal.png)

Step 2. Search for Resource Group in the search bar
![alt text](Task07_images/RG.png)

In the search bar at the top, type the keyword 'resource groups' and select the correct service as shown in the screenshot below.



Click on the create Button

![alt text](Task07_images/create_RG.png)

Step 3: Fill in the details to create the Resource Group


Basics Tab
![alt text](Task07_images/RG_basic.png)

1. Give a name based on your preference (You will receive an error message if you use any unsupported symbols)

2. Choose the location closest to your current region


Tags Tab
![alt text](Task07_images/RG_tags.png)

You can ignore this tab since it is just used to classify the resources we have created in the subscription.


Review and Create

![alt text](Task07_images/RG_validation.png)

Once the validation is passed, you can click on the create button as below.



Step 4: Open the Resource Group that you have created


Once created, click on the "Go to Resource Groups" button to open your resource Group. You can also open your resource group by searching your resource group name in the search bar as below,

![alt text](Task07_images/RG_created.png)

Click on your Resource Group, it looks like below.

![alt text](Task07_images/RG_homepage.png)

This is the resource group that you will be using in building this complete end to end project. Inside this resource group, we will be creating all the required tools used in this project. Let's see how we can create these in the next section. 

### Create Azure Synapse Analytics and Storage Account (DatalakeGen2)
Step 1: Choose the Create option from the Resource Group
![alt text](Task07_images/choose_RG.png)

From your resource group page, click on the create button as below, (This will open the Azure Market place, where we can create all the resources)



Step 2: Search for Synapse in the Market Place

In the market place search box, search for "synapse" and click on the Create -> Azure Synapse Analytics option as below,

![alt text](Task07_images/create_Synapse.png)


Step 3: Fill in the details for creating Data Factory

![alt text](Task07_images/Synapse_basic.png)
Basics Tab (Project Details)

Choose your subscription and resource group (This will be automatically selected)

Ignore the Managed resource group drop down. (This will be automatically created if not specified)

![alt text](Task07_images/synapse_basic2.png)

Basics Tab (Workspace Details)


Fill in the workspace name and choose the region closest to your region.



The remaining options in the Basics tab is for creating the Storage Account (DatalakeGen2)- This will be created along with the Synapse Analytics. We can either select already existing storage account or create a new one from scratch. Since we are creating everything from scratch, let's create a new storage account as below,


1. Account Name (This is the Storage Account Name)- Click on the "Create new" link and give it a name.

2. File System Name (This is the container name)- Click on the "Create new" link and give it a name as "bronze".


You will get full understanding of the Account Name and File System name when you are actually implementing the project from this course.


Note: Make sure the "Assign myself the Storage Blob Data Contributor role on the Data Lake Storage Gen2 account to interactively query it in the workspace." check box is enabled.  This will make sure the Synapse Analytics have required access to the Storage account.



Security Tab
![alt text](Task07_images/synapse_security.png)


Networking Tab


Leave this tab as it is, we don't require to change anything as part of this project.

![alt text](Task07_images/Synapse_networking.png)

Tags Tab


As seen earlier, we can ignore this tab.



Review + Create Tab


Once all the validation is successful, click on the Create button as below,

![alt text](Task07_images/synapse_validation.png)

Step 4: View the created resources


Once you have done all the steps correctly, you will see a status as below. Now, click on the Go to resource group button to view the created resources.



Now you will be seeing two resources created, Synapse Analytics and a Storage account in your resource group as below,

![alt text](Task07_images/synapse_created.png)

### Create Azure Data Factory

Step 1: Choose the Create option from the Resource Group
![alt text](Task07_images/adf_create.png)

From your resource group page, click on the create button as below,



Step 2: Search for Data Factory in the Market Place


In the market place search box, search for "data factory" and click on the Create -> Data Factory option as below,

![alt text](Task07_images/adf_search.png)

Step 3: Fill in the details for creating Data Factory


Basics Tab


Choose your subscription and resource group (This will be automatically selected)

Fill in the Name, region and version as below.

![alt text](Task07_images/adf_basic.png)


Git configuration Tab

Leave this tab as it is. We are not going to cover the Git functionality as part of this Course.

![alt text](Task07_images/adf_git.png)

Networking tab


Leave this tab as it is. We are not going to cover any Networking as part of this Course.
![alt text](Task07_images/adf_networking.png)


Advanced Tab


Leave this tab as it is. This tab is mostly for performing custom managed Encryption, but by default all the Data processed by Data Factory is encrypted automatically.

![alt text](Task07_images/adf_advanced.png)

Tags Tab


As seen earlier, we can ignore this Tab.



Review + Create Tab

![alt text](Task07_images/adf_vaidation.png)

Once all the validation is successful, click on the Create button as below,



Once you have done all the steps correctly, you will be able to create Azure Data Factory successfully as below,

![alt text](Task07_images/adf_created.png)

### Create Azure Databricks

Step 1: Choose the Create option from the Resource Group
![alt text](Task07_images/choose_RG.png)

From your resource group page, click on the create button as below,


Step 2: Search for Databricks in the Market Place


In the market place search box, search for "databricks" and click on the Create -> Azure Databricks option as below,
![alt text](Task07_images/adb_search.png)


Step 3: Fill in the details for creating Azure Databricks

![alt text](Task07_images/adb_create.png)

Basics Tab


Choose your subscription and resource group (This will be automatically selected). Fill in all the other info by taking the below screenshot as the reference,

![alt text](Task07_images/adb_networking.png)

Networking Tab


Leave this tab as it is. We are not going to cover any Networking as part of this Course.


![alt text](Task07_images/adb_encryption.png)
Encryption Tab


Leave this tab as it is. This tab is mostly for performing custom managed Encryption, but by default all the Data processed by Azure Databricks is encrypted automatically.



Security & Compliance Tab
![alt text](Task07_images/adb_security.png)

Leave this tab as it is, we don't have to change anything as part of this course.



Tags Tab


As seen earlier, we can ignore this Tab.



Review + Create Tab

![alt text](Task07_images/adb_validation.png)

Once all the validation is successful, click on the Create button as below,

![alt text](Task07_images/adb_created.png)

Once you have done all the steps correctly, you will be able to create Azure Databricks successfully as below,


### Create Azure Key Vault

Step 1: Choose the Create option from the Resource Group


From your resource group page, click on the create button as below,
![alt text](Task07_images/choose_RG.png)


Step 2: Search for Key Vault in the Market Place


In the market place search box, search for "key vault" and click on the Create -> Key Vault option as below,

![alt text](Task07_images/kv_search.png)

Step 3: Fill in the details for creating Azure Key Vault


Basics Tab
![alt text](Task07_images/kv_basic.png)

Choose your subscription and resource group (This will be automatically selected). Fill in all the other info by taking the below screenshot as the reference,



Access Configuration Tab
![alt text](Task07_images/kv_access.png)

Configure the options as per the below screenshot. (Note: In this course we are going with the "Vault Access Policy" Permission model, however it's not recommended currently).



Networking Tab


Leave this tab as it is. We are not going to cover any Networking as part of this Course.

![alt text](Task07_images/kv_networking.png)

Tags Tab


As seen earlier, we can ignore this Tab.



Review + Create Tab

![alt text](Task07_images/kv_validation.png)

Once all the validation is successful, click on the Create button as below,

![alt text](Task07_images/kv-created.png)

Once you have done all the steps correctly, you will be able to create Azure Databricks successfully as below,

### Check All the Created Resources

Sweet! At this stage, you should have created all the required resources used in this End to End Project course. If you open your resource group, you should be seeing all the tools created as below,

![alt text](Task07_images/all_resources.png)

Nice! Now let's start building the Project. 




