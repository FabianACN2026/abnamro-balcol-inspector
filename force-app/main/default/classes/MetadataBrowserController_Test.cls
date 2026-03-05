@IsTest
private class MetadataBrowserController_Test {

    @IsTest
    static void testGetAccessibleObjects_NoSearch() {
        List<MetadataBrowserController.ObjectSummary> objects = MetadataBrowserController.getAccessibleObjects(null);
        System.assert(objects.size() > 0, 'Should return accessible objects');
        // Verify wrapper properties are populated
        MetadataBrowserController.ObjectSummary first = objects[0];
        System.assertNotEquals(null, first.apiName);
        System.assertNotEquals(null, first.label);
    }

    @IsTest
    static void testGetAccessibleObjects_WithSearch() {
        List<MetadataBrowserController.ObjectSummary> objects = MetadataBrowserController.getAccessibleObjects('Account');
        System.assert(objects.size() > 0);
        // All results should contain 'Account' in API name or label
        for (MetadataBrowserController.ObjectSummary obj : objects) {
            System.assert(
                obj.apiName.containsIgnoreCase('Account') ||
                (obj.label != null && obj.label.containsIgnoreCase('Account')),
                'Result should match search term: ' + obj.apiName
            );
        }
    }

    @IsTest
    static void testGetAccessibleObjects_EmptySearch() {
        List<MetadataBrowserController.ObjectSummary> objects = MetadataBrowserController.getAccessibleObjects('');
        System.assert(objects.size() > 0);
    }

    @IsTest
    static void testGetAccessibleObjects_NoResults() {
        List<MetadataBrowserController.ObjectSummary> objects = MetadataBrowserController.getAccessibleObjects('xyznonexistent12345');
        System.assertEquals(0, objects.size());
    }

    @IsTest
    static void testGetObjectDetail() {
        MetadataBrowserController.ObjectDetail detail = MetadataBrowserController.getObjectDetail('Account');
        System.assertNotEquals(null, detail);
        System.assertEquals('Account', detail.apiName);
        System.assert(detail.fields.size() > 0);
        System.assert(detail.fieldCount > 0);
        // Account has child relationships
        System.assert(detail.relationships.size() > 0);

        // Verify field info structure
        MetadataBrowserController.FieldInfo field = detail.fields[0];
        System.assertNotEquals(null, field.apiName);
        System.assertNotEquals(null, field.type);
    }

    @IsTest
    static void testGetObjectDetail_InvalidObject() {
        try {
            MetadataBrowserController.getObjectDetail('NonExistentObject__xyz');
            System.assert(false, 'Expected exception');
        } catch (SecurityUtil.SecurityException e) {
            System.assert(e.getMessage().contains('Invalid object'), e.getMessage());
        }
    }

    @IsTest
    static void testObjectSummaryWrapper() {
        List<MetadataBrowserController.ObjectSummary> objects = MetadataBrowserController.getAccessibleObjects('Contact');
        Boolean foundContact = false;
        for (MetadataBrowserController.ObjectSummary obj : objects) {
            if (obj.apiName == 'Contact') {
                foundContact = true;
                System.assertNotEquals(null, obj.keyPrefix);
                break;
            }
        }
    }

    @IsTest
    static void testGetAccessibleObjects_FindsStandardObjects() {
        // Regression: globalDescribe must return standard objects like Account
        List<MetadataBrowserController.ObjectSummary> objects = MetadataBrowserController.getAccessibleObjects('Account');
        Boolean foundAccount = false;
        for (MetadataBrowserController.ObjectSummary obj : objects) {
            if (obj.apiName == 'Account') {
                foundAccount = true;
                System.assertEquals(false, obj.isCustom, 'Account should not be custom');
                System.assertNotEquals(null, obj.label);
                break;
            }
        }
        System.assert(foundAccount, 'Account must be found in accessible objects');
    }

    @IsTest
    static void testObjectSummary_StringConstructor() {
        MetadataBrowserController.ObjectSummary os = new MetadataBrowserController.ObjectSummary('MyObj__c', 'My Object', '0Af');
        System.assertEquals('MyObj__c', os.apiName);
        System.assertEquals('My Object', os.label);
        System.assertEquals('0Af', os.keyPrefix);
        System.assertEquals(true, os.isCustom);

        MetadataBrowserController.ObjectSummary std = new MetadataBrowserController.ObjectSummary('Account', 'Account', '001');
        System.assertEquals(false, std.isCustom);
    }

    @IsTest
    static void testObjectSummary_Comparable() {
        MetadataBrowserController.ObjectSummary a = new MetadataBrowserController.ObjectSummary('Account', 'Account', '001');
        MetadataBrowserController.ObjectSummary b = new MetadataBrowserController.ObjectSummary('Contact', 'Contact', '003');
        // Account should sort before Contact
        System.assert(a.compareTo(b) < 0, 'Account should sort before Contact');
        System.assert(b.compareTo(a) > 0, 'Contact should sort after Account');
        System.assertEquals(0, a.compareTo(a), 'Same object should return 0');
    }

    @IsTest
    static void testGetAccessibleObjects_ResultsSorted() {
        List<MetadataBrowserController.ObjectSummary> objects = MetadataBrowserController.getAccessibleObjects(null);
        // Verify results are sorted by label
        for (Integer i = 1; i < objects.size() && i < 20; i++) {
            String prevLabel = objects[i-1].label != null ? objects[i-1].label : objects[i-1].apiName;
            String currLabel = objects[i].label != null ? objects[i].label : objects[i].apiName;
            System.assert(prevLabel.compareTo(currLabel) <= 0,
                'Results should be sorted: ' + prevLabel + ' should come before ' + currLabel);
        }
    }

    @IsTest
    static void testRelationshipInfoWrapper() {
        MetadataBrowserController.ObjectDetail detail = MetadataBrowserController.getObjectDetail('Account');
        if (!detail.relationships.isEmpty()) {
            MetadataBrowserController.RelationshipInfo rel = detail.relationships[0];
            System.assertNotEquals(null, rel.relationshipName);
            System.assertNotEquals(null, rel.childObject);
            System.assertNotEquals(null, rel.fieldName);
        }
    }
}
