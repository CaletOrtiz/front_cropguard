import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/core/utils/number_format.dart';

void main() {
  group('formatMoney', () {
    test('COP sin decimales con separador de miles', () {
      expect(formatMoney(2700000, 'COP'), r'$2.700.000');
      expect(formatMoney(9000.6, 'COP'), r'$9.001');
    });

    test('USD con prefijo US\$ y 2 decimales', () {
      expect(formatMoney(1234.5, 'USD'), r'US$1,234.50');
    });

    test('null se muestra como 0', () {
      expect(formatMoney(null, 'COP'), contains('0'));
    });
  });

  test('formatKg usa miles y hasta 2 decimales', () {
    expect(formatKg(1200), '1.200 kg');
    expect(formatKg(900.256), '900,26 kg');
  });

  group('parseDecimal', () {
    test('acepta coma o punto decimal', () {
      expect(parseDecimal('12,5'), 12.5);
      expect(parseDecimal('12.5'), 12.5);
    });

    test('entiende puntos de miles', () {
      expect(parseDecimal('1.234'), 1234);
      expect(parseDecimal('1.234,56'), 1234.56);
      expect(parseDecimal('1.234.567'), 1234567);
    });

    test('ignora letras y devuelve null si está vacío', () {
      expect(parseDecimal('12a3'), 123);
      expect(parseDecimal(''), isNull);
      expect(parseDecimal('abc'), isNull);
    });
  });

  group('DecimalInputFormatter', () {
    test('agrupa miles mientras se escribe', () {
      expect(DecimalInputFormatter.format('1234567'), '1.234.567');
    });

    test('normaliza el punto decimal a coma y limita a 2 decimales', () {
      expect(DecimalInputFormatter.format('12.'), '12,');
      expect(DecimalInputFormatter.format('12.345'), '12.345');
      expect(DecimalInputFormatter.format('12,345'), '12,34');
    });

    test('no acepta letras', () {
      expect(DecimalInputFormatter.format('1a2b'), '12');
    });

    test('fromNumber produce un texto que parseDecimal relee igual', () {
      final text = DecimalInputFormatter.fromNumber(1234.5);
      expect(text, '1.234,5');
      expect(parseDecimal(text), 1234.5);
    });
  
  group('DecimalInputFormatter al teclear', () {
    // Simula escribir carácter por carácter como lo hace el TextField.
    String type(String keys, {String start = ''}) {
      const formatter = DecimalInputFormatter();
      var value = TextEditingValue(text: start);
      for (final key in keys.split('')) {
        final next = key == '<'
            ? value.text.substring(0, value.text.length - 1)
            : value.text + key;
        value = formatter.formatEditUpdate(value, TextEditingValue(text: next));
      }
      return value.text;
    }

    test('10000 no se convierte en 1,00', () {
      expect(type('10000'), '10.000');
      expect(type('1234567'), '1.234.567');
    });

    test('borrar no reinterpreta los miles como decimales', () {
      expect(type('<', start: '1.000'), '100');
      expect(type('<', start: '10.000'), '1.000');
    });

    test('punto o coma tecleados son el separador decimal', () {
      expect(type('9000.5'), '9.000,5');
      expect(type('9000,25'), '9.000,25');
      expect(parseDecimal(type('10000')), 10000);
    });

    test('al pegar se sigue aceptando punto decimal', () {
      const formatter = DecimalInputFormatter();
      final pasted = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '12.5'),
      );
      expect(pasted.text, '12,5');
    });
  });
});
}
