@isTest
public class SimpleObjectSearcherControllerTest {
    static testMethod void test_getSearchField() {
		SimpleSearchResult result = SimpleObjectSearcherController.getSearchField('Account', 'Name,Industry,Phone,Createddate,CreatedBy.Name,Website');
        System.debug('result:'+result);
        System.assert(result.isSuccess);
		result = SimpleObjectSearcherController.getSearchField('Account', 'xxxx,,');
        System.assert(!result.isSuccess);
		result = SimpleObjectSearcherController.getSearchField('Contact', 'Name,HasOptedOutOfEmail,Email,Birthdate');
        System.assert(result.isSuccess);
    }

    static testMethod void test_searchRecord() {
        Account a = new Account(Name='A', Industry='Agriculture', Phone='03-3333-3333', AnnualRevenue=100);
        insert a;
        SimpleObjectSearcherController.searchRecord('Account', 'Name,Industry,Phone,Createddate,CreatedBy.Name,Website', 'STRING___XXX___name___XXX___A___SSS___PICKLIST___XXX___industry___XXX___Agriculture___SSS___STRING___XXX___phone___XXX___03-3333-3333___SSS___DATETIME___XXX___createddate___XXX___2015/01/01___SSS___NUMBER___XXX___AnnualRevenue___XXX___100');
        SimpleObjectSearcherController.searchRecord('Account', 'Name,Industry,Phone,Createddate,CreatedBy.Name,Website', 'STRING___XXX___name___XXX___A___SSS___PICKLIST___XXX___industry___XXX___Agriculture___SSS___STRING___XXX___phone___XXX___03-3333-3333___SSS___DATETIME___XXX___createddate___XXX___20150101___SSS___NUMBER___XXX___AnnualRevenue___XXX___100');
        SimpleObjectSearcherController.searchRecord('Account', 'Name,Industry,Phone,Createddate,CreatedBy.Name,Website', 'STRING___XXX___name___XXX___A___SSS___PICKLIST___XXX___industry___XXX___Agriculture___SSS___STRING___XXX___phone___XXX___03-3333-3333___SSS___DATETIME___XXX___createddate___XXX___20150101___SSS___NUMBER___XXX___AnnualRevenue___XXX___A');

        Contact c = new Contact(LastName='LAST', FirstName='First', HasOptedOutOfEmail=true, Email='test@test.co.jp', Birthdate=Date.parse('1980/01/01'));
        insert c;
        c = new Contact(LastName='LAST2', FirstName='First2', HasOptedOutOfEmail=true, Email='test@test.co.jp', Birthdate=Date.parse('1980/01/01'));
        insert c;
        SimpleObjectSearcherController.searchRecord('Contact', 'Name,HasOptedOutOfEmail,Email,Birthdate', 'STRING___XXX___name___XXX___LAST___SSS___BOOLEAN___XXX___HasOptedOutOfEmail___XXX___TRUE___SSS___STRING___XXX___Email___XXX___test@test.co.jp___SSS___DATE___XXX___Birthdate___XXX___1980/01/01');
        SimpleObjectSearcherController.searchRecord('Contact', 'Name,HasOptedOutOfEmail,Email,Birthdate', 'STRING___XXX___name___XXX___YYXYXYXYX___SSS___BOOLEAN___XXX___HasOptedOutOfEmail___XXX___FALSE___SSS___STRING___XXX___Email___XXX___test@test.co.jp___SSS___DATE___XXX___Birthdate___XXX___1980/01/01');
    }

    static testMethod void test_convCommaStrToArray() {
        SimpleObjectSearcherController.convCommaStrToArray('AA,BB,CC.XXX');
        SimpleObjectSearcherController.convCommaStrToArray('AA');
        SimpleObjectSearcherController.convCommaStrToArray('AA,BB,CC.XXX', ',');
    }

    static testMethod void test_getSObjectField() {
        List<String> l = new List<String>();
        l.add('Name');
        l.add('Industry');
        l.add('Createdby.Name');
        SimpleObjectSearcherController.getSObjectField('Account', l);
    }

    static testMethod void test_getTypeString() {
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.DATE) == 'DATE');
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.DATETIME) == 'DATETIME');
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.INTEGER) == 'NUMBER');
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.DOUBLE) == 'NUMBER');
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.EMAIL) == 'EMAIL');
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.BOOLEAN) == 'BOOLEAN');
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.PICKLIST) == 'PICKLIST');
        System.assert(SimpleObjectSearcherController.getTypeString(Schema.DisplayType.STRING) == 'STRING');
    }

	static testMethod void test_SimpleSearchResult() {
		SimpleSearchResult ssr = new SimpleSearchResult(true, 'message', 'id');
	}

}