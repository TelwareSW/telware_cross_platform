import 'package:flutter_test/flutter_test.dart';
import 'package:telware_cross_platform/core/utils.dart';

void main() {
  group('emailValidator', () {
    test('returns null for valid email', () {
      expect(emailValidator('test@example.com'), null);
    });

    test('returns null for valid email v2', () {
      expect(emailValidator('test.user@eng-st.cu.edu.eg'), null);
    });

    test('returns error message for invalid email', () {
      expect(emailValidator('invalid-email'), 'Enter a valid email address');
    });

    test('returns error message for invalid email v2', () {
      expect(
          emailValidator('invalid-email@.com'), 'Enter a valid email address');
    });

    test('returns null for empty email', () {
      expect(emailValidator(''), null);
    });

    test('returns null for null email', () {
      expect(emailValidator(null), null);
    });
  });

  group('passwordValidator', () {
    test('returns null for valid password', () {
      expect(passwordValidator('Password1'), null);
    });

    test('returns error message for short password', () {
      expect(passwordValidator('Pass1'),
          'Password must be at least 8 characters long');
    });

    test('returns null for empty password', () {
      expect(passwordValidator(''), null);
    });

    test('returns null for null password', () {
      expect(passwordValidator(null), null);
    });
  });

  group('confirmPasswordValidation', () {
    test('returns null for matching passwords', () {
      expect(confirmPasswordValidation('Password1', 'Password1'), null);
    });

    test('returns error message for non-matching passwords', () {
      expect(confirmPasswordValidation('Password1', 'Password2'),
          'Passwords do not match.');
    });

    test('returns null for empty password', () {
      expect(confirmPasswordValidation('', ''), null);
    });

    test('returns null for null password', () {
      expect(confirmPasswordValidation(null, null), null);
    });
  });

  group('formatPhoneNumber', () {
    test('formats phone number correctly', () {
      expect(formatPhoneNumber('01093401932'), '+20 109 3401932');
    });

    test('returns original phone number if already formatted', () {
      expect(formatPhoneNumber('+20 109 3401932'), '+20 109 3401932');
    });

    test('format an egyptian phone number', () {
      expect(formatPhoneNumber('+201093401932'), '+20 109 3401932');
    });

    test('format a phone number with a country code', () {
      expect(formatPhoneNumber('+9661093401932'), '+966 109 3401932');
    });

    test('format phone number with a country code', () {
      expect(formatPhoneNumber('+966 109 3401932'), '+966 109 3401932');
    });

    test('returns original phone number if format is incorrect', () {
      expect(formatPhoneNumber('12345'), '12345');
    });
  });

  group('toKebabCase', () {
    test('converts string to kebab case', () {
      expect(toKebabCase('Hello World'), 'hello-world');
    });

    test('Single word input', () {
      expect(toKebabCase('Hello'), 'hello');
    });

    test('Multi-Word input', () {
      expect(toKebabCase('I am the king of the world'), 'i-am-the-king-of-the-world');
    });

    test('handles multiple spaces', () {
      expect(toKebabCase('Hello    World'), 'hello-world');
    });

    test('removes non-alphanumeric characters', () {
      expect(toKebabCase('Hello@World!'), 'hello-world');
    });

    test('removes leading and trailing hyphens', () {
      expect(toKebabCase('-Hello World-'), 'hello-world');
    });
  });

  group('getInitials', () {
    test('returns initials for a single name', () {
      expect(getInitials('John'), 'J');
    });

    test('Name with small letters', () {
      expect(getInitials('john cena'), 'JC');
    });

    test('returns initials for a full name', () {
      expect(getInitials('John Doe'), 'JD');
    });

    test('returns initials for multiple names', () {
      expect(getInitials('John Michael Doe'), 'JM');
    });

    test('returns NN for empty name', () {
      expect(getInitials(''), 'NN');
    });
  });

  group('getRandomColor', () {
    test('returns a color within the expected range', () {
      final color = getRandomColor();
      expect(color.red, inInclusiveRange(50, 149));
      expect(color.green, inInclusiveRange(50, 149));
      expect(color.blue, inInclusiveRange(50, 149));
    });
  });
}