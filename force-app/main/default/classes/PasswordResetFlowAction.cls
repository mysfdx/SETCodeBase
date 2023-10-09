public with sharing class PasswordResetFlowAction {

    @InvocableMethod(label='Reset Password with Email Template' description='Resets user password using email template')
    public static void resetPasswordWithEmailTemplate(List<PasswordResetInput> inputs) {
        for (PasswordResetInput input : inputs) {
            System.resetPasswordWithEmailTemplate(input.userId, input.sendUserEmail, input.emailTemplateName);
        }
    }

    public class PasswordResetInput {
        @InvocableVariable(label='User ID' required=true)
        public Id userId;

        @InvocableVariable(label='Send User Email' required=true)
        public Boolean sendUserEmail;

        @InvocableVariable(label='Email Template Name' required=true)
        public String emailTemplateName;
    }
}