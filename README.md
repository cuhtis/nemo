# Nemo

![nemo icon](Nemo-Master/Assets.xcassets/AppIcon.appiconset/Nemo_180_180.png)

Created by Robin Huang, Jonathan Chen and Curtis Li

## Problem Statement

It is very difficult to find parking in certain cities, at certain times. When everyone is trying to find parking around Venice Beach, information is the key advantage. Nemo aims to provide information about open parking spots through crowdsourcing. Anyone can take a picture of an empty parking spot they see when they walk by it, and post it. Someone looking for a parking spot can open the app and view this information.

## Configuration Instructions

1. Clone the project repo
2. In terminal, run '$ pod install'
3. Download the Cloudinary repo, and add it to the project workspace
4. Open the project from the file 'Nemo-Master/Nemo-Master.xcoworkspace'

## How It Works

1. To find a parking spot, the user needs to open the app, which brings him to the Google Maps view. The nemo icons on the map represent free parking spots that are pulled from our server. They display data such as Name/Address, Time Past since posting, and price.
2. The nemo button on the UIToolBar at the top of the app will refresh the map with the most updated information from the server.
3. The camera button on the UIToolBar at the top of the app will bring the user to the CameraView. Through this, the user can take a picture of a parking spot and post it to our server. Additionally, the user can add information about the address (which is automatically filled), and an asking price.

## Technical Architecture

#### UIToolBar
This is a custom UIToolbar that is customized to fit two buttons in the middle of the toolbar, fixed to the top of the screen below the status bar. Here we have a Camera button, which navigates to the CameraView, and a Nemo button, which refreshes the GMSMapView.

#### Google Maps View
Below the UIToolbar is UIView that is of the class GMSMapView. This allows the Google Maps UI to be displayed in this UIView container. This takes up the rest of the screen. Google Maps SDK is installed through Cocoa Pods (version can be seen in our Podfile). Google provides many functionality out of the box, such as locating the user’s current location through CLLocationManager. Additionally, it allows us to add Markers onto the map with a customized infowindow and icon. We used a ‘clown fish’ icon, and an Info Window that displays information about Address, Price, Time Posted, and Image. 

#### CameraView
We implemented AVFoundation to allow for the live camera to be linked to the frameforCapture View. In addition, this view also incorporates a segue to the submit page, and an unwind segue back to the map view. Depending on the different states of the picture taking, the various functional buttons will disable, hide, enable, and unhide themselves. *IMPORTANT* Due to the way the AVFoundation works, you will NOT be able to test the camera in any shape way or form on a simulator. Testing the camera MUST be done on a device. 

#### SubmitView
As it stands right now, the view has Latitude and Longitude automatically populated into its fields, and automatically determines the street address and sets it as the parking spot's name, though the name can be manually changed by the user. These pieces of information are obtained by reloading and reusing CoreLocation and using GoogleMap's Geocoder. The SubmitView has a button that can be used to unwind back to the CameraView, or upon completion of the form, unwinds back to the MapView. Submit takes the information and the picture taken and sends it to the database, where it will then be seen as a new marker on the map. 

#### Backend
For our back-end processing, we hosted a server on Heroku running Node / Express (http://nemo-server.herokuapp.com) and a MongoDB database, which is a document-based database store. The server will accept RESTful calls (GET / POST / PUT / DELETE) to URLs in the form of:

>http://nemo-server.herokuapp.com/[collection_name]/[document_id]/

The server will accept and respond with JSON object strings as the HTTP request / response body. We parsed the JSON objects in our application using the class NSJSONSerialization, which allows us to convert JSON objects to and from NSDictionary objects. We then use the NSDictionary to initialize our ParkingSpot objects.

We are using MongoDB as our primary database storage, and Cloudinary as our image storage.

## Technical Challenges

* We encountered race conditions between pulling data from the database and populating the GMSMapView, as they are processed by different threads. To resolve this, we used a polling wait on the main thread, until the parking spots information had been retrieved.
* GMSMapView can only be updated by the main thread, so when a worker thread attempts to update it, it will fail. We resolved this by using an dispatch_async call, which communicates a code block to the main thread's work stack.
* We originally wanted to implement a claim button within the GMS' custom info view, however the view displayed is actually not the original view, but an image capture of the view, rendering buttons in the view unclickable. We resolved this by pursuing a different method for claiming the parking spot, by using a UIAlert.
* It was generally difficult to learn the APIs, such as the Google Maps API, as they contained more complex concepts such as key-value observation.

## Future Features / TODO List

* To reduce fraudulent use, some sort of authentication will be implemented. The simplest way being through a FB login.
* Due to the nature of parking spots in the big city. An algorithm to go through the database and weed out parking spots that have existed over a certain time limit.
* Another database-centric feature that can be added would be a searching means, so that users can remotely look up locations without needing to be physically there.
* GPS integration to allow for users to get directions to parking spaces that they have found using Nemo.
* To provide more value to parking-seekers, we will add locations about parking garages, and other private parking locations so that spots will be guaranteed and paid for.
* To enable in-app payments, we will look into using Braintree or Stripe payment processing services.
