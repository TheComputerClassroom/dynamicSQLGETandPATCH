# Safe Dynamic SQL **SELECT** and **UPDATE** operations in MuleSoft projects

This GitHub project contains:
- This README.me file describing the project
- A MuleSoft *design project* with sources (no 'targets' or dependent JAR files) that is an example project showing how to create code with dynamic SQL statements for GET and PATCH methods on collections and individual members of a collection, respectively.
- A dump of a sample database that persists the *jobs* and *people* resources

The API's RAML definition can be found in the *blog-dw-sapi-ws/blog-dw-sapi* folder. That is actually a MAVEN artifact, imported from Anypoint Platform's Exchange component via a reference in the *blog-dw-sapi-ws/pom.xml* file.

To understand details of this project, see [this blog](URL 'www.compclass.com/blogs/dynamicSQLDataWeave').

To use this project, you need to:
1. Install MySQL onto your localhost (or have it loaded elsewhere)
2. Cloan this project.
3. Load the database dump file (https://github.com/TheComputerClassroom/dynamicSQLGETandPATCH/blob/main/dump-dwdemo-202204211202.sql) into a database in your MySQL server.
4. Import the project directory (blog-dw-sapi-ws) into your MuleSoft Studio 7.12 as a project in your filesystem.
5. Open the src/main/mule/global.xml file and modify the global element for **Database_Config** to reflect your mySQL server's host, port, user, password, and database name (where you loaded the data in step 3.
