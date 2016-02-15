public with sharing class SimpleObjectSearcherController {
    private static String ID_PREFIX = 'SIMPLE_SEARCH_ID_';
    private static String ID_PREFIX_UPD = 'UPDATABLE_ID_';
    private static String PARAM_SP1 = '___XXX___';
    private static String PARAM_SP2 = '___SSS___';
    
    @AuraEnabled
    public static SimpleSearchResult getSearchField(String objectName, String searchFields){
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getSearchField ***** Start');
        SimpleSearchResult res = new SimpleSearchResult(true, '');
        try {
            List<String> fNames = convCommaStrToArray(searchFields);
            List<Map<String, String>> searchFieldProperty = getSObjectField(objectName, fNames);
            System.debug('searchFieldProperty:'+searchFieldProperty);
	        res.values.put('searchFieldProperty', searchFieldProperty);
        } catch (Exception e) {
            res.isSuccess = false;
            System.debug(LoggingLevel.ERROR, 'Exception type caught: ' + e.getTypeName());    
            System.debug(LoggingLevel.ERROR, 'Message: ' + e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Cause: ' + e.getCause());    // returns null
            System.debug(LoggingLevel.ERROR, 'Line number: ' + e.getLineNumber());    
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            res.message = 'Initial display failed. Please check the setting of the property editor.';
        }
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getSearchField ***** End');
        return res;
    }
    
    @AuraEnabled
    public static SimpleSearchResult searchRecord(String objectName, String listFields, String paramsStr){
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.searchRecord ***** Start');
        SimpleSearchResult res = new SimpleSearchResult(true, '');
        try {
            validation(objectName, listFields, paramsStr);
    	    Map<String, String> recordData = getRecordData(objectName, listFields, paramsStr);
            res.values.put('recordData', recordData);
            System.debug('**** res:'+res);
        } catch (SimpleSearchException e) {
            res.isSuccess = false;
            res.message = e.getMessage();
            res.id = e.id;
            System.debug(LoggingLevel.ERROR, 'Exception type caught: ' + e.getTypeName());    
            System.debug(LoggingLevel.ERROR, 'Message: ' + e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Cause: ' + e.getCause());    // returns null
            System.debug(LoggingLevel.ERROR, 'Line number: ' + e.getLineNumber());    
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());    
        } catch (Exception e) {
            res.isSuccess = false;
            System.debug(LoggingLevel.ERROR, 'Exception type caught: ' + e.getTypeName());    
            System.debug(LoggingLevel.ERROR, 'Message: ' + e.getMessage());    
            System.debug(LoggingLevel.ERROR, 'Cause: ' + e.getCause());    // returns null
            System.debug(LoggingLevel.ERROR, 'Line number: ' + e.getLineNumber());    
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());    
            res.message = 'Search failed. Please contact the system administrator.';
        }
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.searchRecord ***** End');
        return res;
    }
    
    public static void validation(String objectName, String listFields, String paramsStr) {
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.validation ***** Start');
        List<String> params = convCommaStrToArray(paramsStr, PARAM_SP2);
        if (params.size() > 0) {
            for(String s : params) {
                List<String> p = s.split(PARAM_SP1);
                if (p.size() == 3 && String.isNotBlank(p[2])) {
                    if (p[0] == 'DATE' || p[0] == 'DATETIME') {
                        try {
                            Date dt = Date.parse(p[2].replace('-', '/'));
                        } catch(Exception e) {
                            throw new SimpleSearchException('日付を指定してください。', ID_PREFIX + p[0] + PARAM_SP1 + p[1] + PARAM_SP1); 
                        }
                    } else if (p[0] == 'NUMBER') {
                        try {
                            double.valueOf(p[2]);
                        } catch(Exception e) {
                            throw new SimpleSearchException('数値を入力してください。', ID_PREFIX + p[0] + PARAM_SP1 + p[1] + PARAM_SP1); 
                        }
                    } else if (p[0] == 'BOOLEAN') {
                    } else if (p[0] == 'PICKLIST') {
                    } else {
                    }
                }
            }
        }
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.validation ***** End');
    }
    
    public static Map<String, String> getRecordData(String objectName, String listFields, String paramsStr) {
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getRecordData ***** Start');
        //System.debug('****** objectName:'+objectName);
        //System.debug('****** listFields:'+listFields);
        //System.debug('****** paramsStr:'+paramsStr);
        String query = 'SELECT ID, ';
        List<String> fNames = convCommaStrToArray(listFields);
	    //System.debug('****fNames:' + fNames);
        
        List<String> params = convCommaStrToArray(paramsStr, PARAM_SP2);
	    //System.debug('****params:' + params);

        Map<String, String> retData = new Map<String, String>();
        List<Map<String, String>> fieldProperties = getSObjectField(objectName, fNames);
	    //System.debug('****fieldProperties:' + fieldProperties);
        String columns = '[';
        boolean isFirst = true;
        for(Integer i = 0; i < fNames.size(); i++) {
            if (fNames[i].toUpperCase() == 'ID') {
                continue;
            }
            if (isFirst) {
                query += '' + fNames[i];// + ' c' + i;
                Map<String, String> p = fieldProperties[i];
                columns += '{title:"' + p.get('Label') + '"}';
                isFirst = false;
            } else {
                query += ',' + fNames[i];// + ' c' + i;
                Map<String, String> p = fieldProperties[i];
                columns += ',{title:"' + p.get('Label') + '"}';
            }
        }
        columns += ']'; 
        retData.put('columns', columns);

        query += ' FROM ' + objectName;
        if (params.size() > 0) {
            query += ' WHERE ';
		    //System.debug('****query:' + query);
            isFirst = true;
            for(String s : params) {
	    		//System.debug('****s:' + s);
                List<String> p = s.split(PARAM_SP1);
	        	//System.debug('****p:' + p);
                if (isFirst) {
                    query += convQueryWereString(p);
                    isFirst = false;
                } else {
                    query += ' and ' + convQueryWereString(p);
                }
            }
        }

        System.debug('****query:' + query);
        List<sObject> resultList = new List<sObject>();
        try {
	        resultList = Database.query(Database.getQueryLocator(query).getQuery());
        } catch (Exception e) {
            throw new SimpleSearchException('検索できませんでした。条件を見直してください。');
        }
        String data = '[';
        isFirst = true;
		boolean isFirst2 = true;
        for (sObject result : resultList) {
            if (isFirst) {
                isFirst = false;
            } else {
                data += ',';
            }
            isFirst2 = true;
            data += '[';
            for(Integer i = 0; i < fNames.size(); i++){
                //String alias = 'c' + i;
                String alias = fNames[i];
                if (isFirst2) {
                    data += '"';
                    data += convColumnString(result, alias, fieldProperties[i], result.get('Id'));
                    data += '"';
                    isFirst2 = false;
                } else {
                    data += ',"';
                    data += convColumnString(result, alias, fieldProperties[i]);
                    data += '"';
                }
            }   
            data += ']';                
        }
        data += ']';
        retData.put('data', data);
        System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getRecordData ***** End');
        return retData;
    }
    
    public static String convQueryWereString(List<String> p) {
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.convQueryWereString ***** Start');
        String retStr = '';
        if (p[0] == 'DATE') {
            retStr = p[1] + ' >= ' + p[2].replace('/', '-');
        } else if (p[0] == 'DATETIME') {
            retStr = p[1] + ' >= ' + p[2].replace('/', '-') + 'T00:00:00Z';
        } else if (p[0] == 'NUMBER') {
            retStr = p[1] + ' >= ' + p[2];
        } else if (p[0] == 'BOOLEAN') {
            if (p[2].toUpperCase() == 'TRUE' || p[2].toUpperCase() == 'ON') {
	            retStr = p[1] + ' = TRUE';
            } else {
	            retStr = p[1] + ' = FALSE';
            }
        } else if (p[0] == 'PICKLIST') {
            retStr = p[1] + ' = \'' + p[2] + '\'';
        } else {
            retStr = p[1] + ' like \'%' + p[2] + '%\'';
        }
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.convQueryWereString ***** End');
        return retStr;
    }

    public static String convColumnString(sObject obj, String aliasName, Map<String, String> searchFieldProperty) {
        return convColumnString(obj, aliasName, searchFieldProperty, null);
    }

    public static String convColumnString(sObject obj, String aliasName, Map<String, String> searchFieldProperty, Object Id) {
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.convColumnString ***** Start');
        //System.debug('sObject:' + obj + ' aliasName:' + aliasName);
        String columnString = '';
		String data = '';
        if (aliasName.indexOf('.') > -1) {
            Integer c = aliasName.indexOf('.');
	        sObject obj2 = obj.getSObject(aliasName.left(c));
        	//System.debug('c:' + c);
        	//System.debug('obj2:' + obj2);
        	//System.debug('aliasName:' + aliasName);
            if (obj2 != null) {
                data = '' + obj2.get(aliasName.substring(c+1));
                String key = aliasName.left(c).replace('__r', '__c');
           		//System.debug('*** key:' + key);
                if (key.endsWith('__r') || key.endsWith('__c')) {
                } else {
                    key += 'id';
                }
                //System.debug('*** key:' + key);
                Id = obj.get(key);
            }
        } else {
            data = '' + obj.get(aliasName);
            if (data.startsWith('System.Address')) {
                System.Address a = (System.Address)obj.get(aliasName);
                data = '' + a.getPostalCode() + ' ' + a.getState() + a.getCity() + a.getStreet();
            }
        }

        if (Id != null) {
            columnString = '<a target=\'_blank\' class=\'showDetail\' id=\''+Id+'\' >' +data+ '</a>';
        } else {
           	columnString = data; 
            if (searchFieldProperty.get('isUpdatable').toUpperCase() == 'TRUE') {
                String updId = ID_PREFIX_UPD + searchFieldProperty.get('Name');
                columnString = '<div class=\'isUpdatable\' id=\''+updId+'\'>' + data+ '</div>'; 
            }
        }
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.convColumnString ***** End');
        return columnString;
    }

    public static List<String> convCommaStrToArray(String propString) {
        String separator = ',';
        return convCommaStrToArray(propString, separator);
    }
    
    public static List<String> convCommaStrToArray(String propString, String separator) {
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.convCommaStrToArray ***** Start');
        if (String.isEmpty(propString)) {
            return new List<String>();
        }
        List<String> retList = new List<String>();
        if (propString.indexOf(separator) > -1) {
            retList = propString.split(separator);
        } else {
            retList.add(propString);
        }
        //System.debug('*** retList:' + retList);
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.convCommaStrToArray ***** End');
        return retList;
    }

    public static List<Map<String, String>> getSObjectField(String objectName, List<String> selectFields) {
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getSObjectField ***** Start');
        //System.debug('**** objectName:' + objectName);
        //System.debug('**** selectFields:' + selectFields);
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        List<Map<String, String>> retFields = new List<Map<String, String>>();
        for(String s : selectFields) {
            //System.debug('*** s:' + s);
            Map<String, String> fieldProperty = new Map<String, String>();
            if (s.indexOf('.') > -1) {
            	//System.debug('*** sn:' + s.left(s.indexOf('.')).replace('__r', '__c'));
             	//System.debug('*** objectFields:' + objectFields);
                for (String key : objectFields.keySet()) {
             		//System.debug('*** key:' + key);
                }
                String key = s.left(s.indexOf('.')).replace('__r', '__c');
           		//System.debug('*** key:' + key);
                if (key.endsWith('__r') || key.endsWith('__c')) {
                } else {
                    key += 'id';
                }
                //System.debug('*** key:' + key);
                Schema.SObjectField f = objectFields.get(key);
                fieldProperty.put('Name', getTypeString(f.getDescribe().getType()) + PARAM_SP1 + s + PARAM_SP1);
                fieldProperty.put('Label', f.getDescribe().getLabel().replace('ID',''));
                fieldProperty.put('Length', '80');
                fieldProperty.put('Type', getTypeString(f.getDescribe().getType()));
                fieldProperty.put('isUpdatable', '' + f.getDescribe().isUpdateable());
            } else {
                Schema.SObjectField f = objectFields.get(s);
                fieldProperty.put('Name', getTypeString(f.getDescribe().getType()) + PARAM_SP1 + s + PARAM_SP1);
                fieldProperty.put('Label', f.getDescribe().getLabel());
                fieldProperty.put('Length', '' + f.getDescribe().getLength());
                fieldProperty.put('Type', getTypeString(f.getDescribe().getType()));
                fieldProperty.put('isUpdatable', '' + f.getDescribe().isUpdateable());
                if (f.getDescribe().getType().equals(Schema.DisplayType.PICKLIST)) {
                    List<Schema.PicklistEntry> ples = f.getDescribe().getPicklistValues();
                    String picklistString = '';
                    boolean isFirst = true;
                    for (Schema.PicklistEntry ple: ples) {
                        if (isFirst) {
                            picklistString += ple.getLabel();
                            isFirst = false;
                        } else {
                            picklistString += ',' + ple.getLabel();
                        }
                    }
                    fieldProperty.put('PicklistEntry', picklistString);
                }
            }
            retFields.add(fieldProperty);
        }
        //System.debug('**** retFields:' + retFields);
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getSObjectField ***** End');
        return retFields;
    } 
    
    public static String getTypeString(Schema.DisplayType t) {
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getTypeString ***** Start');
        String res = '';
        if (t == Schema.DisplayType.DATE) {
            res = 'DATE';
        } else if (t == Schema.DisplayType.DATETIME) {
            res ='DATETIME';
        } else if (t == Schema.DisplayType.INTEGER || t == Schema.DisplayType.DOUBLE || t == Schema.DisplayType.CURRENCY) {
            res = 'NUMBER';
        } else if (t == Schema.DisplayType.EMAIL) {
            res = 'EMAIL';
        } else if (t == Schema.DisplayType.BOOLEAN) {
            res = 'BOOLEAN';
        } else if (t == Schema.DisplayType.PICKLIST) {
            res = 'PICKLIST';
        } else if (t == Schema.DisplayType.PHONE) {
            res = 'PHONE';
        } else {
            res = 'STRING';
        }
        //System.debug(Logginglevel.INFO, '****** SimpleObjectSearcherController.getTypeString ***** End');
        return res;
    }

    public class SimpleSearchException extends Exception {
        public String id { get; set; }
        public SimpleSearchException(String msg, String id) {
            this.setMessage(msg);
            this.id = id;
        }
    }
}