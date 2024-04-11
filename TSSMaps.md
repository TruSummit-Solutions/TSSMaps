---
layout: default
---
# TSSMaps

The TSSMaps wrapper class from TruSummit Solutions is a Salesforce Apex class that provides a simple
interface for interacting with the Salesforce Maps Distance Matrix API. This class offers a series of
helper methods for retrieving distance and time data between multiple locations, as well as converting
the raw data into more human-readable formats.
NOTE: This class is intended to be used in conjunction with Salesforce Maps. You must have Salesforce Maps
enabled in your Salesforce org to use this class. For more information on Salesforce Maps, visit:
https://developer.salesforce.com/docs/atlas.en-us.maps_developer_guide.meta/maps_developer_guide/maps_overview.htm
Author: TruSummit Solutions
Home: https://www.trusummitsolutions.com

## Methods
### `public static Matrix getDistanceMatrix(List<Map<String,Object>> allLocations)`
#### Parameters

|Param|Description|
|---|---|
|`allLocations`|A List of Maps containing the locations you want to include in the Distance Matrix request. NOTE: you must include at least 2 locations and no more than 20 locations.|

#### Returns

|Type|Description|
|---|---|
|`Matrix`|A Matrix object containing the Distance Matrix data.|

---
## Classes
### Matrix
#### Constructors
##### `public Matrix(Map&lt;String,Object&gt; mtx)`

This constructor method is used to parse the raw Distance Matrix data returned from the Salesforce Maps API.

###### Parameters

|Param|Description|
|---|---|
|`mtx`|The raw Distance Matrix data returned from the Salesforce Maps API.|

---
#### Methods
##### `public Boolean isSuccessful()`

This method can be used to determine if the request for a Distance Matrix was successful.

###### Returns

|Type|Description|
|---|---|
|`Boolean`|A Boolean value indicating whether the Distance Matrix request was successful.|

##### `public MatrixLocation getLocationById(String locationId)`

This method is used to retrieve a Location object from the Distance Matrix. A Location can be defined as a starting point, as opposed to a Destination which is an ending point. The Location object contains all of the data for a specific location, including the distances and times to all related destinations.

###### Parameters

|Param|Description|
|---|---|
|`locationId`|The string value representing the location you want to retrieve from the Distance Matrix data. This value should match the 'location_id' you provided in the original request.|

###### Returns

|Type|Description|
|---|---|
|`MatrixLocation`|A MatrixLocation object containing the data for the specified location.|

---

### MatrixDestination
#### Constructors
##### `public MatrixDestination(List&lt;Object&gt; nodes, String destinationId)`

This constructor method is used to parse the raw destination distance and time values from the Distance Matrix.

###### Parameters

|Param|Description|
|---|---|
|`nodes`|A List of Objects representing the destination data for a specific location in the Distance Matrix.|
|`destinationId`|The string value representing the destination ID for this destination.|

---
#### Methods
##### `public String getId()`
###### Returns

|Type|Description|
|---|---|
|`String`|The destination ID for this destination.|

##### `public MatrixDistance getDistance()`

This method will return an object that wraps the raw distance value for the specified destination. The object wrapper provides helper methods for converting the raw distance value into more human-readable formats.

###### Returns

|Type|Description|
|---|---|
|`MatrixDistance`|A MatrixDistance object representing the distance details for the specified destination.|

##### `public MatrixTime getTrafficByWindow(Integer trafficWindowNumber)`

This method will return an object that wraps the raw time value for the specified destination. The object wrapper provides helper methods for converting the raw time value into more human-readable formats.

###### Parameters

|Param|Description|
|---|---|
|`trafficWindowNumber`|An integer representing the traffic window number you want to retrieve from the Distance Matrix for this destination.|

###### Returns

|Type|Description|
|---|---|
|`MatrixTime`|A MatrixTime object representing the time details for the specified destination and traffic window.|

---

### MatrixDistance
#### Constructors
##### `public MatrixDistance(Object value)`
---
#### Methods
##### `public Decimal miles()`
###### Returns

|Type|Description|
|---|---|
|`Decimal`|The distance value in miles.|

##### `public Decimal kilometers()`
###### Returns

|Type|Description|
|---|---|
|`Decimal`|The distance value in kilometers.|

##### `public Decimal meters()`
###### Returns

|Type|Description|
|---|---|
|`Decimal`|The distance value in meters.|

---

### MatrixLocation
#### Constructors
##### `public MatrixLocation(Map&lt;String,Object&gt; loc, String locationId)`

This constructor method is used to parse the raw location data from the Distance Matrix.

###### Parameters

|Param|Description|
|---|---|
|`loc`|A Map representing the location data for a specific location in the Distance Matrix.|
|`locationId`|The string value representing the location ID for the specified location.|

---
#### Methods
##### `public String getId()`
###### Returns

|Type|Description|
|---|---|
|`String`|The location ID for this location.|

##### `public MatrixDestination getDestinationById(String locationId)`

This method is used to retrieve Destination data from the Distance Matrix. A Destination can be defined as an ending point, as opposed to a Location which is a starting point. The Destination object contains all of the data for a specific destination, including the distance and time data for the specified location. To successfully retrieve a Destination object, you must provide the 'location_id' of the destination you want to retrieve from your location.

###### Parameters

|Param|Description|
|---|---|
|`locationId`|The string value representing the destination you want to retrieve from your location.|

###### Returns

|Type|Description|
|---|---|
|`MatrixDestination`|A MatrixDestination object containing the distance and time data for the specified destination.|

##### `public List&lt;MatrixDestination&gt; getAllDestinations()`

This method is used to retrieve all Destination objects for the specified location. This method will return a List of all Destination objects for the specified location, including the distance and time data for each destination.

###### Returns

|Type|Description|
|---|---|
|`List&lt;MatrixDestination&gt;`|A List of all Destination objects for the specified location.|

---

### MatrixTime
#### Constructors
##### `public MatrixTime(Object value)`
---
#### Methods
##### `public Decimal seconds()`
###### Returns

|Type|Description|
|---|---|
|`Decimal`|The time value in seconds.|

##### `public Decimal minutes()`
###### Returns

|Type|Description|
|---|---|
|`Decimal`|The time value in minutes.|

##### `public Decimal hours()`
###### Returns

|Type|Description|
|---|---|
|`Decimal`|The time value in hours.|

---

### TSSMapsException

**Inheritance**

TSSMapsException


---
