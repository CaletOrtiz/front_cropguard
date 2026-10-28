class Validators {
  Validators._();

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre completo';
    }
    if (value.trim().length < 3) return 'El nombre es muy corto';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Ingresa un correo válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  /// Celular colombiano (10 dígitos que empiezan en 3). Es opcional:
  /// vacío es válido. Acepta espacios, guiones y prefijo +57.
  static String? phone(String? value) {
    final digits = normalizePhone(value);
    if (digits == null) return null;
    if (!RegExp(r'^3\d{9}$').hasMatch(digits)) {
      return 'Ingresa un celular de 10 dígitos (ej. 3001234567)';
    }
    return null;
  }

  /// Deja solo los dígitos (sin +57); null si quedó vacío.
  static String? normalizePhone(String? value) {
    var digits = (value ?? '').replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+57')) digits = digits.substring(3);
    digits = digits.replaceAll('+', '');
    return digits.isEmpty ? null : digits;
  }

  static String? municipality(String? value) {
    if (value == null || value.isEmpty) return 'Selecciona tu municipio';
    return null;
  }

  static String? role(String? value) {
    if (value == null || value.isEmpty) return 'Selecciona tu rol';
    return null;
  }
}
