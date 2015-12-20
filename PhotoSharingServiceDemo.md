

# Introduction #

The purpose of this sample application is to demonstrate how to build a real world cloud application based upon various pieces of the Google Cloud Platform.

# Requirements Specification #
## Functional Requirements ##
  * User has to login with any valid Google account to use the application
  * User uploads a photo from local disk with a description
  * The photos uploaded by all users are fed into the "Photofeed" and shown in chronic order by the time the photo is uploaded.
  * User adds comments to any photo and the comments are visible to all users.

## Non-Functional Requirements ##
  * Java is used to develop the GAE application
  * Google Cloud Storage is used to store the photos.
  * User could select either App Engine NoSQL datastore or Google Cloud SQL to store the application data model including the meta data about the photos for query purpose.
# Design and Implementation #
![http://google-cloud-solutions.googlecode.com/svn/wiki/PhotoSharingServiceArchitectureDiagram.png](http://google-cloud-solutions.googlecode.com/svn/wiki/PhotoSharingServiceArchitectureDiagram.png)

The architecture diagram shows the major components of the deployed system. In the diagram, the thin curved lines with arrows show the communication between different components without particular orders. The thick arrow-ed lines in green color show the data flow of photo media files.

## System Components ##
### Web Applications inside App Engine ###
The photo sharing application is hosted inside Google App Engine(GAE). It handles all user requests from the browser, provides user interfaces for photo uploading, navigation, and comment posting etc. It also orchestrates the media data flow between the browser and the Google Cloud Storage.

### App Engine Datastore ###
The NoSQL datastore is used to store the meta data about each photo uploaded, including the description, uploader, timestamp, and a key to the media file in the Cloud Storage. It also hosts the application data model, such as the users and comments information.

### Google Cloud SQL ###
This is an alternative for the NoSQL datastore. You could switch between the two data store options between simply change the configuration file.

### Google Cloud Storage ###
The Google Cloud Storage (GCS) stores all the binary media files for the uploaded photos. With the integration between the GAE and GCS via the Blobstore API, photos are uploaded and served directly between user's browser and the GCS through the Google Network.

### Google Global Network ###
All traffic from the Browser to the GCS and GAE goes through the Google Global Network. The Google Globa Network not only provides necessary load balancing for global users requests to GCS And GAE, it also honors the standard HTTP caching headers. So media files are cached at the network edge and significantly improves the speed of serving static images.

## Communication Flow ##
The diagram shows the communication between components without particular orders:
  1. Browser requests are routed to the Web Application hosted inside App Engine. The built-in auto-scaling of App Engine would start App Engine instances based on the amount of traffic, and automatically load balancing the requests based on the load on each GAE instance.
  1. Via the Blobstore APIs, the App Engine could generated URLs for uploading and serving files from the Google Cloud Storage. Also after the media files uploaded to the Google Cloud Storage, the original HTTP request is forward to a callback URL provided by the App Engine application.
  1. The web application inside the App Engine uses the NoSQL datastore to store application model, including user information and comments to the photos. Also via the callback from the Google Cloud Storage, photo metadata is stored in the datastore as well. With the datastore, user could do query and search based on users, photo metadata, and comments etc.
  1. Alternatively, the web application could use Cloud SQL instance as the application datastore.

## Media Data Flow ##
  1. Photos are uploaded and downloaded to and from GCS through the Google Global Network. For download, the Google network honors the HTTP caching headers and provides the edge caching for media files. Only in case of cache miss, media data is requested from the Cloud Storage.
  1. Photos are uploaded and downloaded from the GCS.

# Build and Run #

You could build and deploy the application using either Apache Ant or using Eclipse with Google plugin. However, even if you use Eclipse, modify the "build.properties" to set the properties in right values and run "ant init" first. After that you could import the project into Eclipse.

## Build Configuration ##

You should modify the "build.properties" to configure several build properties to the appropriate values:
  * _sdk.dir_: point to the directory where the App Engine Java SDK is located.
  * _cloud.sql.jdbc.url_: Cloud SQL JDBC URL, ex jdbc:google:rdbms://db\_instance/database. Remember to give access permission to this App Engine application id.
  * _cloud.storage.bucket.name_: Cloud Storage bucket name. Remember to gives read/write permission to the application service account.
  * _application.id_: App Engine application id where you want to deploy the application.
  * _application.entity.manager.factory_: The entity manager factory class name. Currently, this value could be set as "com.google.cloud.demo.model.nosql.DemoEntityManagerNoSqlFactory" which means App Engine NoSQL datastore is used; or set as "com.google.cloud.demo.model.sql.DemoEntityManagerSqlFactory" which means Cloud SQL is used.

## System Set up ##
To set up the application, the following set up needs to be done:
  * Creates an App Engine application with valid application id.
  * Set up Cloud Storage bucket that is used to store the uploaded photos. Remember to configure the ACL to allow App Engine application to access the bucket.
  * If you decides to use Cloud SQL as backend storage, you need to configure an SQL instance and create a database. The database schema is provided under war/WEB-INF/photo\_sharing\_demo\_db.sql. Remember to allow App Engine application to access the database instance.