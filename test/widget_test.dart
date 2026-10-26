import 'package:flutter_test/flutter_test.dart';
import 'package:netraone_mobile/main.dart';

void main() {
  test('role menus are scoped', () {
    expect(roleScreens('member_user').any((s) => s.resource == 'companies'),
        false);
    expect(roleScreens('platform_admin').any((s) => s.resource == 'companies'),
        true);
    expect(
        roleScreens('member_admin').any((s) => s.resource == 'groups'), true);
  });
}
