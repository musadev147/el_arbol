// ignore_for_file: constant_identifier_names
String? url = 'https://api.briic.cloud/api/';

final class NetworkConstants {
  NetworkConstants._();
  static const ACCEPT = "Accept";
  static const APP_KEY = "App-Key";
  static const ACCEPT_LANGUAGE = "Accept-Language";
  static const ACCEPT_LANGUAGE_VALUE = "pt";
  static const APP_KEY_VALUE = String.fromEnvironment("APP_KEY_VALUE");
  static const ACCEPT_TYPE = "application/json";
  static const AUTHORIZATION = "Authorization";
  static const CONTENT_TYPE = "content-Type";
}

final class Endpoints {
  Endpoints._();
  //backend_url
  // App Url

  static String register() => "/auth/register";
  static String signIn() => "/auth/login";
  static String otpVerify() => "/auth/verify-email";
  static String login() => "/login";
  static String profile() => "/profile";
  static String patientStatistics() => "/patient-stats";
  static String logout() => "/logout";
  static String profileEdit() => "/profile/update";
  static String updateAvater() => "/profile/update-avatar";
  static String pasaUpdate() => "/update-password";
  static String sendOtp() => "/forgot-password";
  static String forgetOtp() => "/verify_otp-otp";
  static String forgetChange() => "/reset-password";
  static String patientInfo() => "/patient-information";
  static String patientDetails(int page) => "/patient-information?page=$page";
  static String patientUpdate(int id) => "/patient-information/$id";
  static String deleteSingle(int id) => "/patient-information/$id";
  static String status(int id) => "/patient-information/tasks/toggle/$id";
  static String postCustom() => "/custom-tasks/store";
  static String getCustom() => "/custom-tasks";
  static String resendEmailVerification() => "/auth/resend-otp";
  static String forgotEmail() => "/auth/forgot-password";
  static String resetOtpVerify() => "/auth/verify-password-reset-otp";
  static String forgotNewPassword() => "/auth/reset-password";
  // static String getProperty() => "/property/index";
  static String logOut() => "/auth/logout";
  static String getData() => "/profile/get-user";
  static String getPropertyList() => "/property/my-properties/index";
  static String singelProperty({required int id}) => "/property/$id/show";
  static String allUser() => "/chatting/get/users/index";
  static String thread({required int id}) =>
      "/chatting/get/single/messages/$id";
  static String sendMessage() => "/chatting/send/single/messages";
  static String blockUser({required int id}) => "/chatting/user/$id/block";
  static String unblockUser({required int id}) => "/chatting/user/$id/unblock";
  static String updateProfile() => "/profile/update";
  static String getIssueAll() => "/issue/tenant/index";
  static String getLandlordIssue() => "/issue/owner/index";
  static String getSingelTenant({required int id}) => "property/$id/show";
  static String getTenantProperty() => "property/tenant/my-properties/index";
  static String getDetailsIssue({required int id}) => "/issue/owner/$id/show";

  static String issueReport() => "issue/tenant/store";
  static String deleteAccount() => "/profile/delete";
  static String issueTenantDelete({required int id}) =>
      "issue/tenant/$id/delete";

  static String getPropertyType() => "/property/types/index";
  static String addPropertyStore() => "/property/landlord/store";
  static String propertyStatus({required int id}) =>
      "/property/landlord/$id/toggle";
  static String postTenantSave() => "/property/owner/tenancy/store";
  static String updatePassword() => "/profile/update";
  static String getPending() => "/workman/jobs/pending/index";
  static String getAllWorkmen() => "/owner/jobs/workmen/index";
  static String getInProgress() => "/workman/jobs/accepted/index";
  static String getTentency() => "/property/owner/tenancy/index";
  static String getAssignWorken() => "/owner/jobs/workmen/index";
  static String postAssignWorken() => "/owner/jobs/issue/store";
  static String getAllTentency({required int id}) =>
      "/property/$id/all-tenancies";

  //update
  static String updateProperty() => "/property/landlord/store";
  static String postApprove() => "/workman/jobs/consent/store";
  static String jobStatus() => "/workman/jobs/status/store";
  static String getJobDetails({required int id}) => "/jobs/$id/show";
  static String getComplete() => "/workman/jobs/completed/index";
  static String getLegel() => "/profile/settings/static-pages";
  static String getTiketDetails({required int id}) => "/issue/tenant/$id/show";
  static String postTicketDelete({required int id}) =>
      "/issue/tenant/$id/delete";
  static String postLandlordCreate() => "ast/document/initiate";
  static String createAstPdf() => "ast/document/generate";
  static String postTanentSubmit() => "ast/document/submit";
  static String getAllRoleProperty() => "/property/index";
  static String getAlllandlordAst() => "/ast/landlord/all-asts/index";
  static String getHomeTanent() => "/property/owner/my-tenants";
  static String getCheckLandlord({required int id}) => "ast/property/$id/index";
  static String getAstCheck({required int id}) =>
      "ast/property/$id/my-current-ast";
  static String propertyDelete({required int id}) =>
      "property/landlord/$id/delete";
  static String getTanentPublic({required int id}) => "/public/user/$id/show";
  static String getAllTanentAst() => "/ast/tenant/all-asts/index";
  static String getAllLandlordInventory({required int id}) =>
      "/inventory/landlord/property/$id/index";
  static String completeInventory() => "/inventory/tasks/status";
  static String createInventory() => "/inventory/tasks/store";
  static String getSingelInventory({required int id}) =>
      "/inventory/$id/tenant/show";
  static String deleteInventory({required int id}) => "/inventory/$id/delete";
  static String getInventoryTenant({required int id}) =>
      "/inventory/tenant/property/$id/index";
  static String postReviewTenant() => "/review/property/store";
  static String getReviewTenant({required int id}) =>
      "/public/property/$id/reviews/index";
  static String docUpload() => "/property/document/store";
  static String getAllDocList() => "/property/documents/index";
  static String getAllAgent() => "/property/all-agents/index";
  static String postCrateUser() => "profile/make-user/store";

  static String propertySearch({required String query}) =>"property/search?q=$query";
  static String deleteDoc({required int id}) =>"property/document/$id/delete";
  // static String propertySearch({required String query}) => "property/search?q=$query";

  static String aiSend() => "ai/send";
  static String userDelete({required int id}) => "/profile/user/$id/delete";
  static String issueUnder({required int id}) => "/issue/property/$id/index";
  static String deleteAgent({required int id}) => "/profile/user/$id/delete";
  static String getAgentProperty({required int id}) => "/property/$id/agents/index";
  static String UnAssign({required int id}) => "/landlord/agent/assignment/$id/unassign";
  static String getAgent() => "/property/agents/index";
  static String getAssign() => "/property/all-agents/index";
  static String postAssignAgent() => "/property/agents/store";
  static String getAllTenantDropDown() => "/all-tenants/index";

}
