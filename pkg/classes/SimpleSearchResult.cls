public class SimpleSearchResult {
	@AuraEnabled
    public Boolean isSuccess { get; set; }
    @AuraEnabled 
    public String message { get; set; }
    @AuraEnabled 
    public String id { get; set; }
    @AuraEnabled
    public Map<Object, Object> values { get; set; }
    
    public SimpleSearchResult(Boolean isSuccess, String msg){
    	this.isSuccess = isSuccess;
        this.message = msg;
        this.values = new Map<Object, Object>();
    }

    public SimpleSearchResult(Boolean isSuccess, String msg, String id){
    	this.isSuccess = isSuccess;
        this.message = msg;
        this.id = id;
        this.values = new Map<Object, Object>();
	}
}