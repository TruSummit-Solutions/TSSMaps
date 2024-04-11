@IsTest
public with sharing class TSSMapsTest {

    static List<Map<String, Object>> getTestLocations(String sourceId, String destinationId) {
        List<Map<String, Object>> locations = new List<Map<String, Object>>();
        locations.add(new Map<String, Object>{'location_id' => sourceId, 'latitude' => 37.7749, 'longitude' => -122.4194});
        locations.add(new Map<String, Object>{'location_id' => destinationId, 'latitude' => 37.7749, 'longitude' => -122.4194});
        return locations;
    }

    static Map<String, Object> getTestMatrix(String sourceId, String destinationId) {
        String testJson = '{"endPoint":"test","limitInfo":{"QueryRows":"12 / 50000","Queries":"8 / 100","HeapSize":"73745 / 6000000","CPUTime":"150 / 10000"},"request":"","params":{"locations":[],"vehicle":{"type":"car"}},"success":true,"data":{"Solution":{"travel_costs":{"' + sourceId + '":{"' + sourceId + '":[0,0,0,0,0,0,0,0,0],"' + destinationId + '":[9210,794.6,810.5,890,920.7,965.7,1047.2,1048.8,952.5]}},"traffic_windows":[],"status":"Ok","locations":[]},"JobStatus":"Completed","JobMessage":{"comment":""},"JobId":""}}';
        return (Map<String, Object>) JSON.deserializeUntyped(testJson);
    }

    @IsTest
    static void distanceMatrixTest() {
        List<Map<String, Object>> locations = getTestLocations('a0B1a000001Z1Z1EAK', 'a0B1a000001Z1Z2EAL');
        TSSMaps.Matrix distanceMatrix = TSSMaps.getDistanceMatrix(locations);

        System.assert(distanceMatrix != null);
        locations.remove(1);

        Boolean failureCaptured = false;
        try {
            TSSMaps.getDistanceMatrix(locations);
        } catch (TSSMaps.TSSMapsException e) {
            failureCaptured = true;
        }

        System.assert(failureCaptured);

        Map<String, Object> aLocation = locations.get(0);

        for (Integer i = 0; i < 25; i++) {
            Map<String, Object> dupeLocation = aLocation.clone();
            locations.add(dupeLocation);
        }

        failureCaptured = false;
        try {
            TSSMaps.getDistanceMatrix(locations);
        } catch (TSSMaps.TSSMapsException e) {
            failureCaptured = true;
        }

        System.assert(failureCaptured);

    }

    @IsTest
    static void testMatrix() {
        Map<String, Object> distanceMatrix = getTestMatrix('a0B1a000001Z1Z1EAK', 'a0B1a000001Z1Z2EAL');
        TSSMaps.Matrix matrix = new TSSMaps.Matrix(distanceMatrix);

        System.assert(matrix.isSuccessful());

        TSSMaps.MatrixLocation location = matrix.getLocationById('a0B1a000001Z1Z1EAK');
        System.assert(location != null);

        Boolean failureCaptured = false;
        try {
            matrix.getLocationById('BOGUS');
        } catch (TSSMaps.TSSMapsException e) {
            failureCaptured = true;
        }

        System.assert(failureCaptured);
    }

    @IsTest
    static void testMatrixLocation() {
        Map<String, Object> distanceMatrix = getTestMatrix('a0B1a000001Z1Z1EAK', 'a0B1a000001Z1Z2EAL');
        TSSMaps.Matrix matrix = new TSSMaps.Matrix(distanceMatrix);
        TSSMaps.MatrixLocation location = matrix.getLocationById('a0B1a000001Z1Z1EAK');

        System.assertEquals('a0B1a000001Z1Z1EAK', location.getId());

        TSSMaps.MatrixDestination destination = location.getDestinationById('a0B1a000001Z1Z2EAL');
        System.assert(destination != null);

        List<TSSMaps.MatrixDestination> allDestinations = location.getAllDestinations();
        System.assertEquals(2, allDestinations.size());

        Boolean failureCaptured = false;
        try {
            location.getDestinationById('BOGUS');
        } catch (TSSMaps.TSSMapsException e) {
            failureCaptured = true;
        }

        System.assert(failureCaptured);
    }

    @IsTest
    static void testMatrixDestination() {
        Map<String, Object> distanceMatrix = getTestMatrix('a0B1a000001Z1Z1EAK', 'a0B1a000001Z1Z2EAL');
        TSSMaps.Matrix matrix = new TSSMaps.Matrix(distanceMatrix);
        TSSMaps.MatrixLocation location = matrix.getLocationById('a0B1a000001Z1Z1EAK');
        TSSMaps.MatrixDestination destination = location.getDestinationById('a0B1a000001Z1Z2EAL');

        System.assertEquals('a0B1a000001Z1Z2EAL', destination.getId());

        TSSMaps.MatrixDistance distance = destination.getDistance();
        System.assert(distance != null);

        TSSMaps.MatrixTime timeWindow = destination.getTrafficByWindow(1);
        System.assert(timeWindow != null);

        System.assert(distance.meters() != null);
        System.assert(distance.kilometers() != null);
        System.assert(distance.miles() != null);

        System.assert(timeWindow.seconds() != null);
        System.assert(timeWindow.minutes() != null);
        System.assert(timeWindow.hours() != null);
    }

    @IsTest
    static void testTrafficWindows() {
        Map<String, Object> distanceMatrix = getTestMatrix('a0B1a000001Z1Z1EAK', 'a0B1a000001Z1Z2EAL');
        TSSMaps.Matrix matrix = new TSSMaps.Matrix(distanceMatrix);
        TSSMaps.MatrixLocation location = matrix.getLocationById('a0B1a000001Z1Z1EAK');
        TSSMaps.MatrixDestination destination = location.getDestinationById('a0B1a000001Z1Z2EAL');

        for (Integer i = 1; i <= 8; i++) {
            TSSMaps.MatrixTime timeWindow = destination.getTrafficByWindow(i);
            System.assert(timeWindow != null);
        }
    }

}