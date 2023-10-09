public class BackhaulCostResponse {

	public class Status {
		public Boolean hasError;
		public String message;
	}

	public Status status;
	public Data data;

	public class Data {
		public String dealerNumber;
		public String fromDealer;
		public String toDealer;
		public String modelYear;
		public String modelNumber;
		public String vinIn;
		public String cost;
	}

	
	public static BackhaulCostResponse parse(String json) {
		return (BackhaulCostResponse) System.JSON.deserialize(json, BackhaulCostResponse.class);
	}
}