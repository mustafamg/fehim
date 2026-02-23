class Validator {
  Validator._();

  static bool isValidPassword(String password) {
    return password.isNotEmpty;
  }

  static bool isValidEmail(String? email) {
    const emailRegExpString = r'[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9]'
        r'[a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+';
    return RegExp(emailRegExpString, caseSensitive: false).hasMatch(email!);
  }

  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;

    const pattern = r'^[3567]\d{7}$';
    return RegExp(pattern).hasMatch(phone.trim());
  }

  static bool isValidUserName(String? userName) {
    return userName!.length >= 3;
  }

  static bool isPasswordValid(String? password) {
    if (!RegExp(r'^(?=.*?[0-9]).{8,}$').hasMatch(password!)) {
      return false;
    }
    return true;
  }

  static isValidCode(String? code) {
    return code!.length >= 4;
  }

  static bool isMatchPassword(String password, String matchPassword) {
    return password == matchPassword;
  }

  static bool isNotEmpty(String? text) {
    return text.toString().isNotEmpty;
  }

  static String? textEmptyDropDownValidation(
      {required value, required String errorMsg}) {
    if (value == null) {
      return errorMsg;
    }
    return null;
  }

  static bool isValidLocation(String? location) {
    if (location == null || location.trim().isEmpty) return false;

    final value = location.trim();

    final coordRegex = RegExp(r'^-?\d{1,2}(\.\d+)?\s*,\s*-?\d{1,3}(\.\d+)?$');
    if (coordRegex.hasMatch(value)) {
      final parts = value.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());

      if (lat == null || lng == null) return false;
      if (lat < -90 || lat > 90) return false;
      if (lng < -180 || lng > 180) return false;

      return true;
    }

    final addressRegex = RegExp(r"^[\p{L}0-9\s,.'#\-\/]{3,}$", unicode: true);

    return addressRegex.hasMatch(value);
  }
}
