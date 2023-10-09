({
	formatName: function(input, component) {
		if (input) {
			input = input.charAt(0).toUpperCase() + input.substring(1);
		}
		return input;
	}
});