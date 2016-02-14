({
    toggle : function(component, event, helper) {
        console.log('****** toggle ******');
        helper.toggle();
    },
    doInit : function(component, event, helper) {
        console.log('***** doInit() Start');
        var $ = SimpleObjectSearcher.jq();
        var globalId = component.getGlobalId();
        var dataTableId = 'simplesearch_DataTable';
        var searchFieldId = 'simplesearch_searchField';
        console.log('*** dataTableId:'+dataTableId);
        console.log('*** searchFieldId:'+searchFieldId);
        console.log('*** $:'+$);
        console.log('*** globalId:'+globalId);

        var objectName = component.get("v.objectName");        
        var searchFields = component.get("v.searchFields");
        var title = component.get("v.title");
        component.set("v.title", title);
        $('#' + dataTableId).empty();
        $('#' + dataTableId).append('<table class="table display table-striped table-bordered nowrap dtr-inline" style="width: 100%;" cellspacing="0" id="SimpleSearchListField"></table>');
        var dataSet;
        var columns;        
        var action = component.get("c.getSearchField");
        action.setParams({
            "objectName":objectName,
            "searchFields":searchFields
        }) ;
        try {
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('**** isValid:' + component.isValid() + ' **** state:' + state);
            var sResult = response.getReturnValue();
            console.log('*** response.getReturnValue():' + response.getReturnValue());
            if(component.isValid() && state === "SUCCESS" && sResult.isSuccess){
                var data = eval(sResult.values.searchFieldProperty);
                console.log('**** data:' + data);
                var isFirst = true;
                var fgNum = 0;
                for (var i = 0; i < data.length; i++) {
                    var prop = data[i];
                    var id = 'SIMPLE_SEARCH_ID_' + prop['Name'];
                    var label = prop['Label'];
                    var Length = prop['Length'];
                    var Type = prop['Type'];
                    var pickListEntry = null;
                    var tag = '';
                    var sCompNm = 'simplesearch_searchField_left';

                    console.log('**** Type:' + Type);

                    if (i%2 != 0) {
                        if (isFirst != false) {
                            $('#' + searchFieldId).append('</div>');
                        } else {
                            isFirst = false;
                        }
                        $('#' + searchFieldId).append('<div id=' + searchFieldId +'_' + ++fgNum +' class="form-group">');
                        sCompNm = 'simplesearch_searchField_right';
                    }
                    if (Type == 'PICKLIST') {
                        var pickListEntry = prop['PicklistEntry'];
                        var list = pickListEntry.split(',');
                        var ops = [];
                        ops[0] = {"label":"", "value":""};
                        for (var j = 0; j < list.length; j++) {
                            ops[j+1] = {"label":list[j+1], "value":list[j+1]};
                        }
                        helper.pushInputComponent(component, id, 'ui:inputSelect', {"aura:id": id, "class": id + " form-control", "label":label}, sCompNm, ops);
                    } else if (Type == 'DATE' || Type == 'DATETIME') {
                        helper.pushInputComponent(component, id, 'ui:inputDate', {"aura:id": id, "class": id + " form-control", "label":label,"displayDatePicker":"true"}, sCompNm);
                    } else if (Type == 'BOOLEAN') {
                        var ops = [{"label":"", "value":""},{"label":"ON", "value":"TRUE"},{"label":"OFF", "value":"FALSE"}];
                        helper.pushInputComponent(component, id, 'ui:inputSelect', {"aura:id": id, "class": id + " form-control", "label":label}, sCompNm, ops);
                    } else if (Type == 'EMAIL') {
                        helper.pushInputComponent(component, id, 'ui:inputEmail', {"aura:id": id+'aura', "class": id + " form-control", "label":label}, sCompNm);
                    } else {
                        helper.pushInputComponent(component, id, 'ui:inputText', {"aura:id": id+'aura', "class": id + " form-control", "label":label}, sCompNm);
                    }
                }
                console.log('**** searchFieldId:' + searchFieldId);
                $('#' + searchFieldId).append('</div>');
                console.log('**** cxxxx:' + $('#' + searchFieldId));
            } else if (state === "ERROR" || !sResult.isSuccess) {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    component.set("v.message", "Search failed. Please contact the system administrator.");
                    console.log("Error message: " + errors[0].message);
                } else if ( !sResult.isSuccess ) {
                    component.set("v.message", sResult.message);
                    console.log("Unknown error");
                }
            }
        });
        } catch(e) {
            console.log(e);
        }
        $A.enqueueAction(action);
        console.log('***** doInit() End');
    },
    doSearch : function(component, event, helper) {
        console.log('***** doSearch() Start');
        var $ = SimpleObjectSearcher.jq();
        var id = 'simplesearch_spinner';
        $('#' + id).css("display","");
        var globalId = component.getGlobalId();
        var dataTableId = 'simplesearch_DataTable';

        var objectName = component.get("v.objectName");        
        var searchFields = component.get("v.searchFields");
        var listFields = component.get("v.listFields");
        var paramsStr = '';
        helper.setId();
        $("[id^=SIMPLE_SEARCH_ID_]").each(function(){
            $('#' + $(this).attr("id")).parent().removeClass("has-error");
            $("label[for='" + $(this).attr("id") +"']").parent().removeClass("has-error");
            if ($(this).attr('type') != null && $(this).attr('type').toUpperCase() == 'CHECKBOX') {
                console.log("*** CHACKED:" + $(this).prop('checked'));
                var val = 'FALSE';
                if ($(this).prop('checked')) {
                    var val = 'TRUE';
                }
            } else {
                var val = $(this).val();
                console.log("*** VAL:" + val);
            }
            if (val != null && val != '' && val.length != 0) {
                if (paramsStr.length > 0) {
                    paramsStr += '___SSS___';
                }
                paramsStr += ($(this).attr("id")).replace('SIMPLE_SEARCH_ID_', '') + val;
            }
        });
        $('#' + dataTableId).empty();
        $('#' + dataTableId).append('<table class="table display table-striped table-bordered nowrap dtr-inline" style="width: 100%;" cellspacing="0" id="SimpleSearchListField"></table>');

        var action = component.get("c.searchRecord");
        action.setParams({
            "objectName":objectName,
            "listFields":listFields,
            "paramsStr":paramsStr
        }) ;
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('***** state:' + state);
            var sResult = response.getReturnValue();
            console.log('*** response.getReturnValue():' + response.getReturnValue());
            component.set("v.message", "");
            if(component.isValid() && state === "SUCCESS" && sResult.isSuccess) {
                var data = eval(sResult.values.recordData);
                $(function(){
                    $(window).resize(function(){
                           if ($(window).width() <= 700) {                      
                               $('.container ').css({"overflow-x":"scroll","width":"100%"});                     
                           }
                        else{
                            $('.container ').css({"overflow-x":"none","width":"100%"});
                        }
                    });
                    //console.log('*** data:' + data['data']);
                    //console.log('*** columns:' + data['columns']);
                    var dispLen = 20;
                    console.log('*** dispLen:' + dispLen);
                    if (component.get("v.listDisplayLength") != null) {
                        console.log('*** v.listDisplayLength:' + component.get("v.listDisplayLength"));
                        dispLen = parseInt (component.get("v.listDisplayLength"));
                    }
                        
                    var id = 'simplesearch_spinner';
                    $('#' + id).css("display","none");
                    
                    helper.toggle();

                    try{
                        var table = SimpleObjectSearcher.datatables('SimpleSearchListField', eval(data['data']), eval(data['columns']), dispLen, helper);
                    } catch(e) {
                        console.log(e);
                    }      
                });

            } else if (state === "ERROR" || !sResult.isSuccess) {
            console.log('***** xxx3');
                var id = 'simplesearch_spinner';
                $('#' + id).css("display","none");
                
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    component.set("v.message", "Search failed. Please contact the system administrator.");
                    console.log("Error message: " + errors[0].message);
                } else if ( !sResult.isSuccess ) {
                    component.set("v.message", sResult.message);
                    console.log("***sResult.id:" + sResult.id);
                    $('#' + sResult.id).parent().addClass("has-error");
                    $("label[for='" + sResult.id +"']").parent().addClass("has-error");
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);        
        console.log('***** doSearch() End');
    }
})