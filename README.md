### Guide for creating a simple CAP application with XSUAA authentication

#### Creating a dev space and CAP project in SAP Business Application Studio

1.	Create a new “Full Stack Cloud Application” dev space in BAS
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/c50bc18c-fb46-4197-b44d-02a7eb4774f4)
  Note: name of the configuration might change in the future, choose the one that has CAP tools and MTA tools included

2.	Create a new project using the CAP template:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/1dc82208-122e-46dc-80d2-084f1ff50b6c)
  Note: it might take up to 30 minutes for all extensions to be installed in your dev space, so you might not see all templates just after creation.

3. Select the following details:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/b96d95bc-9cf0-48b6-bc02-523b9159c0ec)
  This creates a project that includes a sample data model and service definition:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/3dc910a5-e8b4-48e5-ae0c-91f0c3823fa3)
  If you run “cds watch” in the terminal, you will see that you have a functioning OData service layer already:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/19ecc140-dcbc-4ba5-a098-13f481d12bad)

#### Creating a simple HTML app

4.	Run “cds add approuter” which creates the following artifacts:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/82b74241-a1bf-4ab9-989a-33a60e600c82)
  Check if app dependencies in app/package.json are installed!

5.	Make sure to run “npm install @sap/xssec” and “npm install passport” since these are required dependencies.

6.	Create a simple HTML page under a subfolder in app/ that can display the data from the OData service:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/af5bccdf-a5fd-4969-bc65-8384a44f1701)
  If you run CDS watch again, you should be able to access your HTML page:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/eda63b66-ade1-4ba2-a726-088ef1bdbd46)

7. Add an instruction “- cp -r app/. gen/srv/app/” to MTA.yaml that will copy over the contents of your app folder when you deploy the app:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/bebb6e31-09a9-4457-b18e-476fa4a49ed1)

 
#### Configure XSUAA authorization and restrictions

8.	Let’s add a role-based access restriction to the Books entity:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/72562ee2-c9fc-4aed-a5ad-f1543c0024b9)
  If we now open the OData service, we will get an error that we are unauthorized:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/dc13a38c-2133-479a-8771-b872e71d448f)
  To fix this, we will configure authentication in the following steps.

9. Run “cds compile srv/ --to xsuaa > xs-security.json” to add the role definitions defined in the data model to the security configuration:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/f5a6f9a2-9835-44d8-8484-f641acffd965)

10.	Add the following details manually:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/8c13cc9b-42ac-42ee-9675-a1f951edcd82)
  Note: the "redirect-uris" specifies from which URLs the application can be accessed.

11.	Create a service instance based on this configuration by running “cf create-service xsuaa application bookstore-demo-auth -c xs-security.json”, create a service key by running “cf create-service-key bookstore-demo-auth default” and create a binding by running “cds bind -2 bookstore-demo-auth:default”
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/196ac2ff-3c5b-451e-975f-b03b304e5694)
  Note: you need to run “cf update-service bookstore-demo-auth -p application -c xs-security.json” to update the service if you make any changes.

12.	Go to BTP, create a new role collection, assign the “Admin” role from our application and assign any users who need access to the app:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/a307cd1d-1618-48b3-9908-60e0229fd9d1)

13.	Add the following details to your xs-app.json:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/2c623b59-db74-439d-abe8-b7d9ccc6b63b)
  Notes: 
  1.	/user-api/attributes path in the URL can be used to check the authorization roles of your user.
  2.	“cds bind –exec – npm start –prefix app” can be used to run the approuter locally.
  3.	All requests should go through the approuter
  You can run the approuter locally by executing “cds bind --exec -- npm start --prefix app”:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/ccd429b8-e485-4a94-8c8b-45b78f31e5db)
  Execute a “cds watch” in another console instance to start the service layer as well:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/641ca669-8fb9-4291-afab-6a0857066d13)
  You should now be able to see your user access scopes via “/user-api/attributes”:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/31172b97-3014-464c-b258-001048b86439)

#### Configure an in-memory database

14.	Due to limitations with our BTP tenant (no HANA instance available), in this demo we only use an in-memory database which deletes all data on instance restart. To configure this, add the following to package.json:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/267036b4-a21a-4b04-afa8-e0b00dcf9338)
  Also, add the following to mta.yaml:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/6a0b0ae0-fef1-4b3c-a239-53600e3c5521)
  The cp -r db/data… command makes sue that the sample data is copied over to the production build during deployment.

#### Deploy the application to Cloud Foundry

15.	Build the project via the mta.yaml file:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/ce26dc0b-774d-43c5-98d8-bc1fef83a5e1)

16.	Deploy the generated archive:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/78181aad-920e-409a-acac-973b255cad69)
 
#### Launch the application

17.	Go to spaces and open your dev space
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/f4f82169-1c80-4a60-a823-bc3a726fede9)

18.	Find the approuter and open it
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/d818d69b-59e3-4698-b912-379f8bdb7db8)
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/054e1d68-ec05-4d21-b3e9-60e55d6ac7a0)

20.	You should be now able to access your application with your BTP user:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/e649f882-fbd8-49a4-b9cd-7f0b01c85226)
  If you open the URL while logged out of BTP, you will be prompted to log in with your BTP user:
  ![image](https://github.com/tszalama/cap-xsuaa-app-demo/assets/96135418/471a0a06-7b71-4437-b883-a98493f2dc33)
