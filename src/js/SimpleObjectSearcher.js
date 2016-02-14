var $ = require("jquery");
require('datatables.net')(window, $);
require('datatables.net-bs')(window, $);
require('datatables.net-responsive')(window, $);
require('datatables.net-scroller')(window, $);

//require('datatables.net-buttons')(window, $);
//require('datatables.net-buttons-bs')(window, $);

module.exports = {
	jqueryVersion: function() {
	    return $.fn.jquery;
	},
	jq: function() {
	    return $;
	},
	datatables: function(id, data, columns, dispLen, helper) {
		try {
		    var table = $('#' + id).DataTable({
		        data: data,
		        columns: columns,
		        "scrollX": true,
		        "fnDrawCallback": function( oSettings ) {                          
		            $('.showDetail').css({"cursor":"pointer","text-decoration":"none"});                        
		            $('.showDetail').click(function(){
		                var recordId = $(this).attr('id');
		                console.log('XXXX');
		                helper.navigateToDetailsView(recordId);   
		            });
		            $('.isUpdatable').click(function(){
		                var Id = $(this).attr('id');
		                helper.cellUpdateModalView(Id);   
		            });
		        },
		        dom: 'Bfrtip',
		        buttons: [
		            {
		                extend: 'copyHtml5'
		            },
		            {
		                extend: 'csvHtml5',
		                title: 'Data export'
		            }
		        ],
		        "scrollX": true,
		        iDisplayLength:dispLen,
		        "language": {
		            "emptyTable" : "データが登録されていません。",
		            "info" : "_TOTAL_ 件中 _START_ 件から _END_ 件を表示",   
		            "infoEmpty" : "",
		            "infoFiltered" : "(_MAX_ 件からの絞り込み表示)",
		            "infoPostFix" : "",
		            "thousands" : ",",
		            "lengthMenu" : "表示件数: _MENU_ 件",
		            "loadingRecords" : "ロード中",
		            "processing" : "処理中...",
		            "search" : "絞込み",
		            "zeroRecords" : "該当するデータが見つかりませんでした。",
		            "paginate" : {
		                "previous" : "前のページ",
		                "next" : "次のページ"
		            }
		        }
		    }); 
		}catch(e) {
			console.log(e);
		}
	    return table;
	}
};
