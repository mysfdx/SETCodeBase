/*
Change Log
08/13/2020 Neha Agrawal Added Contest Name and changed the type of Incentive amount for getCase Method.
*/

public class FormRequest {
    public FormName formType { get; set; }
    public ContactDetail contact { get; set; }
    public String accessory1 { get; set; }
    public String accessory2 { get; set; }
    public String accessory3 { get; set; }
    public String accessory4 { get; set; }
    public String accessory5 { get; set; }
    public String accessory6 { get; set; }
    public String accessory7 { get; set; }
    public String accessory8 { get; set; }
    public String accessory9 { get; set; }
    public String accessory10 { get; set; }
    public String authorizedName { get; set; }
    public String backhaulDateRequested { get; set; }
    public String backhaulRequested { get; set; }
    public String challenge { get; set; }
    public String challengeReason { get; set; }
    public String comments { get; set; }
    public String confirmationNumber { get; set; }
    public String contestNumber { get; set; }
    public String customerOfferNumber { get; set; }
    public String dealerSignature { get; set; }
    public String deliveryStatus { get; set; }
    public String duplicateReason { get; set; }
    public String faxNumber { get; set; }
    public String fedexNumber { get; set; }
    public String incentiveAmount { get; set; }
    public String model { get; set; }
    public String modelYear { get; set; }
    public String officersName { get; set; }
    public String officersTitle { get; set; }
    public String other { get; set; }
    public String preferredShipping { get; set; }
    public String requesterName { get; set; }
    public String requesterPhone { get; set; }
    public String requestReason { get; set; }
    public String retailDate { get; set; }
    public String returnPort { get; set; }
    public String titledVehicle { get; set; }
    public String vin { get; set; }
    public String[] vins { get; set; }
    public String contestName{get; set;}
    public String vin1{get; set;}
    public String etaReason{get; set;}
    public String interiorColor{get; set;}
    public String exteriorColor{get; set;}
    public String series{get; set;}
    public String description{get; set;}
    public String accessoryPackages{get; set;}
    public String fileVersionData{get; set;}
    public String salesPersonFirstName{get; set;}
    public String salesPersonLastName{get; set;}
    public String salesPersonEmail{get; set;}
    public String customerFirstName{get; set;}
    public String customerLastName{get; set;}
    public String buyerOrderVersionData{get; set;}
    public String buyersOrderFileName{get; set;}
    public String driverLicenseVersionData{get; set;}
    public String driverLicenseFileName{get; set;}
        
   
    
    private String getFormName() {
        Map<FormName, String> formTypeMap = new Map<FormName, String> {
            FormName.INCENTIVES_CHALLENGE => 'Incentives Challenge',
            FormName.RETURN_TO_PORT => 'Return to Port',
            FormName.ETA => 'ETA',
            FormName.VOID_FOR_TRADE =>'Void for Trade',
            FormName.SOLD_ORDER =>'Sold Order',    
            FormName.MONRONEY_LABEL_REQUEST => 'NV Monroney Label Req',
            FormName.ACCT_DUP_CERT_OF_ORIGIN => 'ACCT Dup C of O'
        };
        return formTypeMap.get(this.formType);
    }
    
    public Case getCase() {
        system.debug('incentiveAmount is '+ this.incentiveAmount);
        return new Case(
            Accessory_and_Applicable_PIO_code_1__c = this.accessory1,
            Accessory_and_Applicable_PIO_code_2__c = this.accessory2,
            Accessory_and_Applicable_PIO_code_3__c = this.accessory3,
            Accessory_and_Applicable_PIO_code_4__c = this.accessory4,
            Accessory_and_Applicable_PIO_code_5__c = this.accessory5,
            Accessory_and_Applicable_PIO_code_6__c = this.accessory6,
            Accessory_and_Applicable_PIO_code_7__c = this.accessory7,
            Accessory_and_Applicable_PIO_code_8__c = this.accessory8,
            Accessory_and_Applicable_PIO_code_9__c = this.accessory9,
            Accessory_and_Applicable_PIO_code_10__c = this.accessory10,
            Authorized_Name__c = this.authorizedName,
            Backhaul_Confirmation_Number__c = this.confirmationNumber,
            Backhaul_Date_Requested__c = this.backhaulDateRequested == null ? null : Date.valueOf(this.backhaulDateRequested),
            Challenge__c = this.challenge,
            Comments__c = this.comments,
            Contest_Number__c = this.contestNumber,
            Customer_Offer_Number__c = this.customerOfferNumber,
            Dealer_Signature__c = this.dealerSignature == null ? false : getDealerSignature(),
            Fax_Number__c = this.faxNumber,
            FedEx_Number__c = this.fedexNumber,
            Form_Name__c = getFormName(),
            How_will_the_vehicle_get_back_to_port__c = this.backhaulRequested == null ? null : getVehicleReturnAnswer(),
            Incentive_Amount__c =this.incentiveAmount==null? null : Decimal.ValueOf(this.incentiveAmount),
            Model_Number__c = this.model,
            Model_Year__c = this.modelYear,
            Officers_Name__c = this.officersName,
            Officers_Title__c = this.officersTitle,
            Other__c = this.other,
            Preferred_Shipping__c = this.preferredShipping,
            Reason_for_Challenge__c = this.challengeReason,
            Reason_for_Duplicate__c = this.duplicateReason,
            Reason_for_Request__c = this.requestReason,
            Retail_Date__c = this.retailDate == null ? null : Date.valueOf(this.retailDate),
            Return_to_Port__c = this.returnPort,
            RTP_Contact_Name__c = getContactName(),
            RTP_Contact_Phone__c = getContactPhone(),
            SET_VIN__c = this.vin,
            Vehicle_Delivery_Status__c = this.deliveryStatus == null ? null : getVehicleDeliveryStatus(),
            Vehicle_Titled__c = this.titledVehicle == null ? null : getTitledVehicleAnswer(),
            Contest_Name__c=this.contestName,
            VIN1__c=this.vin1,
            Interior_Color__c=this.interiorColor,
            Exterior_Color__c=this.exteriorColor,
            Series__c=this.series,
            Description=this.description,
            Accessory_Packages__c=this.accessoryPackages,
            Reason_for_ETA__c=this.etaReason,
            subject=getDistributionSubject(),
            Parts_Category__c=getSoldOrderCategory(),
            Sales_Person_First_Name__c=this.salesPersonFirstName,
            Sales_Person_Last_Name__c=this.salesPersonLastName,
            Sales_Person_Email__c=this.salesPersonEmail,
            SET_Customer_First_Name__c=this.customerFirstName,
            SET_Customer_Last_Name__c=this.customerLastName
        );
        
    }
    
    private String getVehicleReturnAnswer() {
        String vehicleReturnAnswer;
        if (this.backhaulRequested.equalsIgnoreCase('true')) {
            vehicleReturnAnswer = 'Someone from the dealership will take the vehicle back to the port. Please schedule an appointment and notify me as to when I should bring the vehicle to port.';
        } else if (this.backhaulRequested.equalsIgnoreCase('false')) {
            vehicleReturnAnswer = 'Please set up a backhaul.';
        } else {
            throw new NoSuchElementException();
        }
        return vehicleReturnAnswer;
    }
    
    private String getContactName() {
        if (String.isBlank(this.requesterName)) {
            return this.contact.firstName + ' ' + this.contact.lastName;
            
        }
        return this.requesterName;
    }
    
    private String getDistributionSubject() {
        string caseName=getFormName();
        if (caseName=='ETA' || caseName=='Void for Trade' || caseName=='Sold Order') {
            return 'Distribution Call - '+ caseName + ' - ' + this.contact.dealerCode;
        }
        return null;
    }
    private String getSoldOrderCategory() {
        string caseName=getFormName();
        if (caseName=='Sold Order') {
            return 'Sold Order';
        }
        if (caseName=='ETA') {
            return 'ETA';
        }
        if (caseName=='Void for Trade') {
            return 'Void for Trade';
        }
        return null;
    }
    
    private String getContactPhone() {
        if (String.isBlank(this.requesterPhone)) {
            return this.contact.phone;
        }
        return this.requesterPhone;
    }
    
    private String getTitledVehicleAnswer() {
        String titledVehicle;
        if (this.titledVehicle.equalsIgnoreCase('true')) {
            titledVehicle = 'Yes';
        } else if (this.titledVehicle.equalsIgnoreCase('false')) {
            titledVehicle = 'No';
        } else {
            throw new NoSuchElementException();
        }
        return titledVehicle;
    }
    
    private String getVehicleDeliveryStatus() {
        String deliveryStatus;
        if (this.deliveryStatus.equalsIgnoreCase('DEALERSHIP')) {
            deliveryStatus = 'Vehicle at Dealership';
        } else if (this.deliveryStatus.equalsIgnoreCase('CUSTOMER')) {
            deliveryStatus = 'Vehicle with Customer';
        } else {
            throw new NoSuchElementException();
        }
        return deliveryStatus;
    }
    
    private Boolean getDealerSignature() {
        Boolean dealerSigned;
        if (this.dealerSignature.equalsIgnoreCase('true')) {
            dealerSigned = true;
        } else if (this.dealerSignature.equalsIgnoreCase('false')) {
            dealerSigned = false;
        } else {
            throw new NoSuchElementException();
        }
        return dealerSigned;
    }
    
    public Contact getContact() {
        ContactDetail contact = this.contact;
        return new Contact(
            Current_Dealer_Code__c = contact.dealerCode,
            Current_Dealer_Role__c= contact.dealerRole,
            Current_SPIN__c = contact.spin,
            Email = contact.email,
            FirstName = contact.firstName,
            LastName = contact.lastName,
            Phone = contact.phone,
            Username__c = contact.username
        );
    }
    
    public class ContactDetail {
        public String email { get; set; }
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String username { get; set; }
        public String phone { get; set; }
        public String dealerCode { get; set; }
        public String dealerRole { get; set; }
        public String spin { get; set; }
    }
    
    public enum FormName {
        RETURN_TO_PORT,
        ETA,
        VOID_FOR_TRADE,
        SOLD_ORDER,    
        INCENTIVES_CHALLENGE,
        MONRONEY_LABEL_REQUEST,
        ACCT_DUP_CERT_OF_ORIGIN
    }
}