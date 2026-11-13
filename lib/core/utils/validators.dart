class Validators {
  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe um apelido';
    if (value.trim().length < 3) return 'Mínimo de 3 caracteres';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }
}
