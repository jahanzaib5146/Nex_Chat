String? phoneValidator(String? phone) {
  if (phone!.isEmpty) {
    return "Phone No is Required";
  } else if (phone.length > 11 || phone.length < 11) {
    return "Phone No Must be 11 digits";
  }
  return null;
}

String? passWordValidator(String? pass) {
  if (pass!.isEmpty) {
    return "Password is Required";
  }
  return null;
}

String? userNameValidator(String? name) {
  if (name!.isEmpty) {
    return "UserName is Required";
  }
  return null;
}
