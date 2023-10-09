/**
 * An Apex page controller that supports self-registration of users in communities that allow self-registration.
 */
public class CommunitiesSelfRegController {

    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String password { get; set { password = value == null ? value : value.trim(); } }
    public String confirmPassword { get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String companyName { get; set { companyName = value == null ? value : value.trim(); } }
    public String phone { get; set; }
    public Id accountId { get; set; }
    public Id profileId { get; set; }
    public Id roleEnum { get; set; }
    public String communityNickname { get; set; }
    public String username { get; set; } // Fixed the variable name

    public CommunitiesSelfRegController() {
        firstName = ApexPages.currentPage().getParameters().get('firstName');
        lastName = ApexPages.currentPage().getParameters().get('lastName');
        email = ApexPages.currentPage().getParameters().get('email');
        password = ApexPages.currentPage().getParameters().get('password');
        confirmPassword = ApexPages.currentPage().getParameters().get('confirmPassword');
        companyName = ApexPages.currentPage().getParameters().get('companyName');
        phone = ApexPages.currentPage().getParameters().get('phone');
        username = ApexPages.currentPage().getParameters().get('username');
        String expId = ApexPages.currentPage().getParameters().get('expid');
        if (expId != null) {
            Site.setExperienceId(expId);
        }
    }

    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }

        // Generate the community nickname
        if (!String.isBlank(firstName) && !String.isBlank(lastName)) {
            // Get the first letter of the first name
            String firstLetter = firstName.substring(0, 1);

            // Get the first four characters of the last name (or fewer if the last name is shorter)
            String lastChars = lastName.substring(0, Math.min(4, lastName.length()));

            // Combine them to create the community nickname
            communityNickname = firstLetter + lastChars;
        }

        // Find the Account with the name "SET Marketing Show Car Account"
        List<Account> matchingAccounts = [SELECT Id FROM Account WHERE Name = 'SET Marketing Show Car Account' LIMIT 1];
        if (matchingAccounts.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account not found.'));
            return null;
        }
        accountId = matchingAccounts[0].Id;

        // Find the Profile with the name "Marketing Show Car Community User"
        List<Profile> matchingProfiles = [SELECT Id FROM Profile WHERE Name = 'Marketing Show Car Community User' LIMIT 1];
        if (matchingProfiles.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Profile not found.'));
            return null;
        }
        profileId = matchingProfiles[0].Id;

        // Find the Role with the name "SET Marketing Show Car Account Customer User"
        List<UserRole> matchingRoles = [SELECT Id FROM UserRole WHERE Name = 'SET Marketing Show Car Account Customer User' LIMIT 1];
        if (matchingRoles.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Role not found.'));
            return null;
        }
        roleEnum = matchingRoles[0].Id;

        if (String.isNotBlank(email)) {
            username = email + '.set';
        }
        User u = new User();
        u.Username = username; // Fixed the variable name
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = string.valueOf(math.random()).substring(0,6);
        u.ProfileId = profileId;
        u.CompanyName = companyName; // Assuming CompanyName__c is the custom field for company name
        u.Phone = phone; // Assuming Phone is the standard field for phone number

        String userId;

try {
    userId = Site.createExternalUser(u, accountId, password);
} catch(Site.ExternalUserCreateException ex) {
    List<String> errors = ex.getDisplayMessages();
    for (String error : errors)  {
        // Include the input variables in the error message
        String errorMessage = 'Error creating user - ' +
            'Username: ' + u.Username + ', ' +
            'Email: ' + u.Email + ', ' +
            'FirstName: ' + u.FirstName + ', ' +
            'LastName: ' + u.LastName + ', ' +
            'CommunityNickname: ' + u.CommunityNickname + ', ' +
            'ProfileId: ' + u.ProfileId + ', ' +
            'CompanyName: ' + u.CompanyName + ', ' +
            'Phone: ' + u.Phone +
            ': ' + error;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
    }

            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }

        if (userId != null) { 
            if (password != null && password.length() > 1) {
                return Site.login(username, password, ApexPages.currentPage().getParameters().get('startURL'));
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;
            }
        }

        return null;
    }
}