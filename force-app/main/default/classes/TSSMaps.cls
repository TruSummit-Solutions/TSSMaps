/**
 * The TSSMaps wrapper class from TruSummit Solutions is a Salesforce Apex class that provides a simple
 * interface for interacting with the Salesforce Maps Distance Matrix API. This class offers a series of
 * helper methods for retrieving distance and time data between multiple locations, as well as converting
 * the raw data into more human-readable formats.
 *
 * NOTE: This class is intended to be used in conjunction with Salesforce Maps. You must have Salesforce Maps
 * enabled in your Salesforce org to use this class. For more information on Salesforce Maps, visit:
 * https://developer.salesforce.com/docs/atlas.en-us.maps_developer_guide.meta/maps_developer_guide/maps_overview.htm
 *
 * Author: TruSummit Solutions
 * Home: https://www.trusummitsolutions.com
 */
public with sharing class TSSMaps {

    /**
     * @param allLocations A List of Maps containing the locations you want to include in the Distance Matrix request.
     * NOTE: you must include at least 2 locations and no more than 20 locations.
     *
     * @return A Matrix object containing the Distance Matrix data.
     */
    public static Matrix getDistanceMatrix(List<Map<String, Object>> allLocations) {
        if (allLocations == null || allLocations.size() <= 1) {
            throw new TSSMapsException('You must include at least 2 locations to request a Distance Matrix.');
        }

        if (allLocations.size() > 20) {
            throw new TSSMapsException('You cannot request a Distance Matrix with more than 20 locations.');
        }

        Map<String, Object> distanceMatrix = (!Test.isRunningTest()) ? maps.API.GetDistanceMatrix(allLocations) : getTestResponse();
        return new Matrix(distanceMatrix);
    }

    private static Map<String, Object> getTestResponse() {
        String testJson = '{"endPoint":"test","limitInfo":{"QueryRows":"12 / 50000","Queries":"8 / 100","HeapSize":"73745 / 6000000","CPUTime":"150 / 10000"},"request":"","params":{"locations":[],"vehicle":{"type":"car"}},"success":true,"data":{"Solution":{"travel_costs":{"grocerySouth":{"grocerySouth":[0,0,0,0,0,0,0,0,0],"groceryNorth":[9210,794.6,810.5,890,920.7,965.7,1047.2,1048.8,952.5]}},"traffic_windows":[],"status":"Ok","locations":[]},"JobStatus":"Completed","JobMessage":{"comment":""},"JobId":""}}';
        return (Map<String, Object>) JSON.deserializeUntyped(testJson);
    }

    public class Matrix {
        private final Map<String, Object> distanceMatrix;
        private final Boolean successful;
        private final Map<String, Object> travelCosts;
        private final List<Object> trafficWindows;

        /**
         * This constructor method is used to parse the raw Distance Matrix data returned from the Salesforce Maps API.
         *
         * @param mtx The raw Distance Matrix data returned from the Salesforce Maps API.
         */
        public Matrix(Map<String, Object> mtx) {
            this.distanceMatrix = mtx;
            this.successful = (Boolean) mtx.get('success');

            try {
                Map<String, Object> dataNode = (Map<String, Object>) mtx.get('data');
                Map<String, Object> solutionNode = (Map<String, Object>) dataNode.get('Solution');

                this.travelCosts = (Map<String, Object>) solutionNode.get('travel_costs');
                this.trafficWindows = (List<Object>) solutionNode.get('traffic_windows');
            } catch (Exception ex) {
                throw new TSSMapsException(ex);
            }
        }

        /**
         * This method can be used to determine if the request for a Distance Matrix was successful.
         *
         * @return A Boolean value indicating whether the Distance Matrix request was successful.
         */
        public Boolean isSuccessful() {
            return successful != null ? successful : false;
        }

        /**
         * This method is used to retrieve a Location object from the Distance Matrix. A Location can be defined
         * as a starting point, as opposed to a Destination which is an ending point. The Location object contains
         * all of the data for a specific location, including the distances and times to all related destinations.
         *
         * @param locationId The string value representing the location you want to retrieve from the Distance
         * Matrix data. This value should match the 'location_id' you provided in the original request.
         *
         * @return A MatrixLocation object containing the data for the specified location.
         */
        public MatrixLocation getLocationById(String locationId) {
            if (!travelCosts.containsKey(locationId)) {
                throw new TSSMapsException('The Location ID you specified (' + locationId + ') does not exist in the Distance Matrix.');
            }

            Map<String, Object> locationNode = (Map<String, Object>) travelCosts.get(locationId);
            return new MatrixLocation(locationNode, locationId);
        }
    }

    public class MatrixLocation {
        private final Map<String, Object> locationNode;
        private final String id;

        /**
         * This constructor method is used to parse the raw location data from the Distance Matrix.
         *
         * @param loc A Map representing the location data for a specific location in the Distance Matrix.
         * @param locationId The string value representing the location ID for the specified location.
         */
        public MatrixLocation(Map<String, Object> loc, String locationId) {
            this.locationNode = loc;
            this.id = locationId;
        }

        /**
         * @return The location ID for this location.
         */
        public String getId() {
            return id;
        }

        /**
         * This method is used to retrieve Destination data from the Distance Matrix. A Destination can be defined
         * as an ending point, as opposed to a Location which is a starting point. The Destination object contains
         * all of the data for a specific destination, including the distance and time data for the specified location.
         * To successfully retrieve a Destination object, you must provide the 'location_id' of the destination you want
         * to retrieve from your location.
         *
         * @param locationId The string value representing the destination you want to retrieve from your location.
         *
         * @return A MatrixDestination object containing the distance and time data for the specified destination.
         */
        public MatrixDestination getDestinationById(String locationId) {
            if (!locationNode.containsKey(locationId)) {
                throw new TSSMapsException('The Location ID you specified (' + locationId + ') does not exist in the Distance Matrix.');
            }

            List<Object> destinationNode = (List<Object>) locationNode.get(locationId);
            return new MatrixDestination(destinationNode, locationId);
        }

        /**
         * This method is used to retrieve all Destination objects for the specified location. This method will return
         * a List of all Destination objects for the specified location, including the distance and time data for each
         * destination.
         *
         * @return A List of all Destination objects for the specified location.
         */
        public List<MatrixDestination> getAllDestinations() {
            List<MatrixDestination> allDestinations = new List<MatrixDestination>();

            for (String key : locationNode.keySet()) {
                List<Object> destinationNode = (List<Object>) locationNode.get(key);
                allDestinations.add(new MatrixDestination(destinationNode, key));
            }

            return allDestinations;
        }
    }

    public class MatrixDestination {
        private final List<Object> destinationNode;
        private final MatrixDistance distance;
        private final MatrixTime trafficWindow1;
        private final MatrixTime trafficWindow2;
        private final MatrixTime trafficWindow3;
        private final MatrixTime trafficWindow4;
        private final MatrixTime trafficWindow5;
        private final MatrixTime trafficWindow6;
        private final MatrixTime trafficWindow7;
        private final MatrixTime trafficWindow8;
        private final String id;

        /**
         * This constructor method is used to parse the raw destination distance and time values from the Distance Matrix.
         *
         * @param nodes A List of Objects representing the destination data for a specific location in the Distance Matrix.
         * @param destinationId The string value representing the destination ID for this destination.
         */
        public MatrixDestination(List<Object> nodes, String destinationId) {
            this.destinationNode = nodes;
            this.distance = new MatrixDistance(this.destinationNode.get(0));
            this.trafficWindow1 = new MatrixTime(this.destinationNode.get(1));
            this.trafficWindow2 = new MatrixTime(this.destinationNode.get(2));
            this.trafficWindow3 = new MatrixTime(this.destinationNode.get(3));
            this.trafficWindow4 = new MatrixTime(this.destinationNode.get(4));
            this.trafficWindow5 = new MatrixTime(this.destinationNode.get(5));
            this.trafficWindow6 = new MatrixTime(this.destinationNode.get(6));
            this.trafficWindow7 = new MatrixTime(this.destinationNode.get(7));
            this.trafficWindow8 = new MatrixTime(this.destinationNode.get(8));
            this.id = destinationId;
        }

        /**
         * @return The destination ID for this destination.
         */
        public String getId() {
            return id;
        }

        /**
         * This method will return an object that wraps the raw distance value for the specified destination. The
         * object wrapper provides helper methods for converting the raw distance value into more human-readable formats.
         *
         * @return A MatrixDistance object representing the distance details for the specified destination.
         */
        public MatrixDistance getDistance() {
            return distance;
        }

        /**
         * This method will return an object that wraps the raw time value for the specified destination. The object
         * wrapper provides helper methods for converting the raw time value into more human-readable formats.
         *
         * @param trafficWindowNumber An integer representing the traffic window number you want to retrieve from the Distance Matrix for this destination.
         *
         * @return A MatrixTime object representing the time details for the specified destination and traffic window.
         */
        public MatrixTime getTrafficByWindow(Integer trafficWindowNumber) {
            switch on trafficWindowNumber {
                when 1 {
                    return trafficWindow1;
                }
                when 2 {
                    return trafficWindow2;
                }
                when 3 {
                    return trafficWindow3;
                }
                when 4 {
                    return trafficWindow4;
                }
                when 5 {
                    return trafficWindow5;
                }
                when 6 {
                    return trafficWindow6;
                }
                when 7 {
                    return trafficWindow7;
                }
                when 8 {
                    return trafficWindow8;
                }
                when else {
                    throw new TSSMapsException('The Traffic Window Number you specified (' + trafficWindowNumber + ') does not exist in the Distance Matrix.');
                }
            }
        }
    }

    public class MatrixDistance {
        private final Decimal distanceValue;

        public MatrixDistance(Object value) {
            distanceValue = (Decimal) value;
        }

        /**
         * @return The distance value in miles.
         */
        public Decimal miles() {
            Decimal totalMiles = distanceValue * 0.000621371;
            return totalMiles.setScale(2);
        }

        /**
         * @return The distance value in kilometers.
         */
        public Decimal kilometers() {
            Decimal totalKilometers = distanceValue / 1000;
            return totalKilometers.setScale(2);
        }

        /**
         * @return The distance value in meters.
         */
        public Decimal meters() {
            return distanceValue.setScale(2);
        }
    }

    public class MatrixTime {
        private final Decimal timeValue;

        public MatrixTime(Object value) {
            timeValue = (Decimal) value;
        }

        /**
         * @return The time value in seconds.
         */
        public Decimal seconds() {
            return timeValue.setScale(2);
        }

        /**
         * @return The time value in minutes.
         */
        public Decimal minutes() {
            Decimal totalMinutes = timeValue / 60;
            return totalMinutes.setScale(2);
        }

        /**
         * @return The time value in hours.
         */
        public Decimal hours() {
            Decimal totalHours = timeValue / 3600;
            return totalHours.setScale(2);
        }
    }

    public class TSSMapsException extends Exception {}

}