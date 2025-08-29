# Project02 - End to End Azure Data Engineering Real Time Project
Udemy Link :https://einfochips.udemy.com/course/end-to-end-azure-data-engineering-real-time-project/learn/lecture/45486093#overview
## Task 07: Setting up the Data Source

### Import the AdventureWorks Database:


The AdventureWorks database is a popular and widely-used sample database provided by Microsoft for SQL Server. It serves as an excellent resource for learning and practicing SQL queries, database design, and various data-related tasks. In this article, we will provide a detailed walkthrough of the process to install and configure the AdventureWorks database on SQL Server.

Follow the below link to import the database which is used in this project to the SSMS (I used the light weight version)

https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms


### Prerequisites:

Before proceeding with the installation, ensure that you have the following prerequisites in place:

    SQL Server Instance: A running instance of SQL Server on your machine or network.

    SQL Server Management Studio (SSMS): Installed SSMS to execute queries and manage the SQL Server.

#### Step 1: Download AdventureWorks Database Files

Visit the official Microsoft GitHub repository for AdventureWorks samples at https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks. Download the AdventureWorks backup file (AdventureWorks.bak) from the 'AdventureWorks backup' section.

#### Step 2: Restore Database Using SQL Server Management Studio (SSMS)

    Open SSMS and connect to your SQL Server instance.

    In the Object Explorer, right-click on "Databases" and choose "Restore Database."

    In the Restore Database window, select the "Device" option and click the ellipsis (...) to locate the AdventureWorks.bak file.

    Add the AdventureWorks.bak file and click "OK" to close the window.

    Back in the Restore Database window, ensure the "Destination Database" is set to "AdventureWorks" and click "OK" to initiate the restore process.

#### Step 3: Verify Database Restoration

After the restoration process completes, verify that the AdventureWorks database is now listed under the Databases node in SSMS.

#### Step 4: Configure Sample Queries and Applications

AdventureWorks database provides a rich set of sample queries and applications. Explore and run sample queries using SSMS to get familiar with the database structure and data. Additionally, consider installing sample applications or integrating AdventureWorks into your existing projects for practical learning.