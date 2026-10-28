/// Opciones fijas del formulario de registro (alineadas con `profiles`).
class RegisterOptions {
  RegisterOptions._();

  static const department = 'Cesar';

  /// Los 25 municipios del departamento del Cesar.
  static const cesarMunicipalities = <String>[
    'Aguachica',
    'Agustín Codazzi',
    'Astrea',
    'Becerril',
    'Bosconia',
    'Chimichagua',
    'Chiriguaná',
    'Curumaní',
    'El Copey',
    'El Paso',
    'Gamarra',
    'González',
    'La Gloria',
    'La Jagua de Ibirico',
    'La Paz',
    'Manaure Balcón del Cesar',
    'Pailitas',
    'Pelaya',
    'Pueblo Bello',
    'Río de Oro',
    'San Alberto',
    'San Diego',
    'San Martín',
    'Tamalameque',
    'Valledupar',
  ];

  static const roleFarmer = 'FARMER';
  static const roleAgronomist = 'AGRONOMIST';

  /// Valor guardado en `profiles.role` -> texto visible. ADMIN no se ofrece:
  /// se asigna solo desde la base de datos.
  static const roles = <String, String>{
    roleFarmer: 'Agricultor',
    roleAgronomist: 'Agrónomo',
  };

  static const phoneLabel = 'Celular (opcional)';
  static const municipalityLabel = 'Municipio (Cesar)';
  static const roleLabel = 'Soy';
  static const registering = 'Creando cuenta…';
  static const loggingIn = 'Ingresando…';
}
