# ords-demo

Outline of a Github Project to demonstrate the end to end deployment of a python flask project to work with Oracle ORDS. 

Oracle REST Data Services (ORDS) bridges HTTPS and your Oracle Database. A mid-tier Java application, ORDS provides a Database Management REST API, SQL Developer Web, a PL/SQL Gateway, SODA for REST, and the ability to publish RESTful Web Services for interacting with the data and stored procedures in your Oracle Database.

Ref : https://www.oracle.com/uk/database/technologies/appdev/rest.html

ORDS/APEX Configuration

The Database has been setup on Oracle Cloud Infrastructure (OCI) for Production and on Docker for developmemtb purposes. Scripts provided are for demonstration purposes only and may be incomplete as they are written for EPA presentation on a deadline. They may be revised and completed after this date.

Oracle Application Express (APEX) is low code enabling a web interface over https in order to configure reporting agaoimst the Database. This is not essential for ORDS but another Devops possibility allowing reports to be quickly written and available on the web.

Apex Login is available here : http://localhost:8181/ords/f?p=4550:10:3358144813296:::::

Password Admin

Apex Reference : https://apex.oracle.com/en/learn/tutorials/

Ords Reference : https://oracle-base.com/articles/misc/oracle-rest-data-services-ords-create-basic-rest-web-services-using-plsql

Sample ORDS output

http://localhost:8181/ords/hr/rest-v1/employees/

![image](https://user-images.githubusercontent.com/71491954/155895602-1b262242-1252-4600-8255-1d980b3d4b02.png)
