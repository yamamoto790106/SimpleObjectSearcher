({    
    navigateToDetailsView : function(Id) {
        console.log('**** navigateToDetailsView Start');
        console.log('*** Id:' + Id);
        var event = $A.get("e.force:navigateToSObject ");
        event.setParams({
            "recordId": Id
        });
        event.fire();
        console.log('**** navigateToDetailsView End');
	},
    cellUpdateModalView : function(cellId) {
        console.log('**** cellUpdateModalView Start');
        var cellProp = cellId.replace('UPDATABLE_ID_', '').split('___XXX___');
        console.log('**** cellUpdateModalView End');
    },
    toggle : function() {
        console.log('**** toggle Start');
        var $ = SimpleObjectSearcher.jq();
        if ($('#simplesearch_searchField').hasClass('in')) {
            $('#simplesearch_searchField').removeClass('in');
            $('#simplesearch_searchField_toggle_icon').removeClass('glyphicon-chevron-up');
            $('#simplesearch_searchField_toggle_icon').addClass('glyphicon-chevron-down');
        } else {
            $('#simplesearch_searchField').addClass('in');
            $('#simplesearch_searchField_toggle_icon').removeClass('glyphicon-chevron-down');
            $('#simplesearch_searchField_toggle_icon').addClass('glyphicon-chevron-up');
        }
        console.log('**** toggle End');
    },
    pushInputComponent : function(cmp, id, uiname, attribute, compAttName, opts) {
        try{
            console.log('**** pushInputComponent Start');
            $A.createComponent(
                uiname,
                attribute,
                function(newInputComp){
                    console.log('***** cmp.isValid():' + cmp.isValid());
                    if (cmp.isValid()) {
                    	var targetCmp = cmp.find(compAttName);
                        console.log('***** targetCmp:' + targetCmp);
                        var body = targetCmp.get('v.body');
                        console.log('***** body:' + body);
                        if (uiname == 'ui:inputSelect') {
                            newInputComp.set("v.options", opts);
                        }
                        body.push(newInputComp);
                        targetCmp.set('v.body', body);
                    }
                }
            );
            console.log('**** pushInputComponent End');
        } catch(e) {
            console.log(e);
        }
	},
    setId : function(tag) {
        try{
            var $ = SimpleObjectSearcher.jq();
	        $("[class^=SIMPLE_SEARCH_ID_]").each(function(){
                var cls = $(this).attr('class');
                var t = cls.split(' ');
                console.log('*****' + t);
                for (var i =0; i < t.length; i++) {
	                console.log('*****' + t[i]);
                    if(t[i].startsWith('SIMPLE_SEARCH_ID_')){
                       console.log("*** CLASS:" + t[i]);
                        $(this).attr("id", t[i]);
                    }
                }
            });
        } catch(e) {
            console.log(e);
        }
	}
})