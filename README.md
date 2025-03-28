# Couchbase Lite iOS - Hotel Management Sample App 👋

# Overview

This is an example app of a simple iOS app that uses the [Couchbase Lite](https://www.couchbase.com/products/lite) database. The app lists a set of Hotels that are provided as part of the [Couchbase Travel-Sample](https://docs.couchbase.com/cloud/get-started/run-first-queries.html) dataset. 

This app assumes you have a Capella Free Tier operational cluster with the travel-sample dataset installed.  To find out more information about the free tier, please visit this blog post [Couchbase Cloud](https://www.couchbase.com/blog/free-tier-capella-dev-available/).

## Project requirements/used frameworks  
Xcode: 15.0+  
iOS: 16+  
Framework: SwiftUI  
Dependency Management: Swift Package Manager (SPM)  
Unit Tests and UI Tests written with XCTest  
Database: Couchbase Lite’s Swift SDK (3.2.1+)  

## App Services Setup
Log into your Capella Free-Tier account.  A listing of Operational Clusters should appear.  Click on your demo-cluster in the listing.  This should bring up the Home page for your cluster.

### Create a new App Service
On the Home tab under the `Explore your cluster` section find the section `Try App Services` and click on the link `Deploy App Services`.

On the main App Services page click the `Create App Service` button.  The Create App Services page should appear.

On the Create App Services page, give your app service a name.  You can name it anything you like, for example `demo-app-service`.  Under the Linked Cluster section select `demo-cluster` from the pull-down select list.  Finally, you can click the `Create App Service` button.

It will take between 5 and 25 minutes for your new App Service to be created. 

### Creating a new Endpoint

Once your cluster is created and the status is listed as `Healthy`, click on the newly created App Service name in the list , i.e. `demo-app-service`.

One the App Endpoints screen, click the `Create App Endpoint` button to create a new Endpoint.

On the Create App Endpoint page, enter custom name for example `hotels` in the App Endpoint Name field.  In the Bucket selection list, select the `travel-sample` bucket.  In the Scope selection list, select the `inventory` scope.

Under the `Chose collections to link` section, click the `Link` switch for `hotel` collection.  This will link `hotel` collection to this App Endpoint and allow us to sync data from this collection to our mobile app.  

Finally, click the `Create App Endpoint` button.  The App Endpoints listing page should appear.

### Setup App Endpoint Security
On the App Endpoints listing page, click on the newly created endpoint `hotels`.  This will bring up the App Endpoint section of Capella App Services. 

On the Security page the Access and Validation screen should appear.  A message on this page states that the App Endpoint is paused.  Click the `Resume app endpoint` link to resume the endpoint.   This may take a few seconds to complete.

We are going to use the default  Access Control and Data Validation scripts, so click the `App Users` tab from the navigation menu on the left.

On the App Users page, click the `Create App User` button.  This will bring up the Create App User page.  Enter a username and password for the new user. (please remember the credentials for app configuration)

Click the `Configure Access Grants` link to expand the grants section.  Under the `Assign Channels` section locate the `hotel` listing under `LINKED COLLECTIONS`  and add an Admin Channel name of `hotel` and hit the enter key. It should show the name in a chip format. This will give the new user access to the `hotel` collection.
Click the `Create App User` button to create the new user.

### Get the Endpoint URL 

Click on the `Connect` tab on the navigation menu in the header of the page.  The Connect page should appear.  The URL for the App Endpoint is listed in the `Public Connection` section.  You will need this URL to connect the mobile app to the App Endpoint.  Click the two sheets of paper (copy) button next to the public connection string in order to copy the URL to your clipboard on your computer.  We can then paste in the URL into the code.

## Pull down the code
From a terminal you can use the git command to pull down the code from the repository:

```bash
git clone https://github.com/DominikBrozioKruko/ios-swift-quickstart
````


## Set up the Mobile App 

To set up the mobile app double click the ios-swift-quickstart.xcodeproj file, and xCode should open the project.  

Inside the project navigator (left side with all files listed) inside the folder `ios-swift-quickstart` there should be a `Config` file.  
In order for the application to know what database to connect to you need to fill the config file with proper information.

### Inside the config file:
Remote Capella endpoint URL - Please put here the url that you saved from [Get the Endpoint URL](#get-the-endpoint-url)
Authentication/ User name - Please put here the user that you created for [Setup app endpoint security](#setup-app-endpoint-security)
Authentication/ Password - Please put here the password for the user that you created for [Setup app endpoint security](#setup-app-endpoint-security)

>[!CAUTION]
> Project without config file filled, will not sinc the data with your cluster/endpoint.


### Running the app
To run the app select the device that you want to run it on (middle of xCode top bar, change `Any iOS Device` to one of the simulator devices installed with your xCode.

>[!WARNING] 
>Before running the project. Please make sure that Swift package manager has loaded couchbase SDK. You can see it at the bottom of your project navigator there will be `Package dependencies` section. There will be spinner next to still loading dependency.

If everything has build correctly, and you filled the config file with correct data. You should be presented with application for hotel management, and list of hotels inside your couchbase cluster.

## Learn more

To learn more about Couchbase Lite and the Capacitor plugin, look at the following resources:
- [Couchbase lite on swift](#https://docs.couchbase.com/couchbase-lite/current/swift/quickstart.html)

Join our community of developers 

- [Discord community](https://bit.ly/3NbK5vg): Chat with Couchbase developers and ask questions.
- [Stack Overflow community](https://stackoverflow.com/tags/couchbase/info/): Ask questions.
- [Developer Portal](https://www.couchbase.com/developer): more information including tutorials and learning paths. 
