({
    invoke: function (component, event, helper) {
        var destinationUrl = component.get('v.destinationUrl');

        // Check if the destination URL is present
        if (destinationUrl) {
            // Use JavaScript to navigate to the URL in the same tab
            window.location.href = destinationUrl;
        } else {
            throw new Error('Missing DestinationUrl. Since you have forced DestinationType to be "url", you need to pass in a valid URL');
        }
    }
})