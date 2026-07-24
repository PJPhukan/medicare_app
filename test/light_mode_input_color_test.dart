import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_medicare/core/theme/app_colors.dart';
import 'package:app_medicare/core/theme/app_theme.dart';
import 'package:app_medicare/shared/widgets/inputs/app_text_field.dart';
import 'package:app_medicare/shared/widgets/inputs/email_phone_input.dart';

void main() {
  Future<void> pumpLight(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
      ),
    );
  }

  testWidgets('AppTextField label + value are dark in light mode', (tester) async {
    final ctrl = TextEditingController(text: 'hello@x.com');
    await pumpLight(tester, AppTextField(controller: ctrl, label: 'Email'));

    final labelText = tester.widget<Text>(find.text('Email'));
    debugPrint('LABEL color: ${labelText.style?.color}');

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    debugPrint('VALUE color: ${editable.style.color}');

    expect(labelText.style?.color, AppColors.textPrimaryLight,
        reason: 'label should use light-mode primary text');
    expect(editable.style.color, AppColors.textPrimaryLight,
        reason: 'value should use light-mode primary text');
    ctrl.dispose();
    expect(field, isNotNull);
  });

  testWidgets('AppEmailPhoneInput label + value are dark in light mode', (tester) async {
    final ctrl = TextEditingController(text: 'hello@x.com');
    await pumpLight(
      tester,
      AppEmailPhoneInput(controller: ctrl, label: 'Email or mobile'),
    );

    final labelText = tester.widget<Text>(find.text('Email or mobile'));
    debugPrint('EP LABEL color: ${labelText.style?.color}');
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    debugPrint('EP VALUE color: ${editable.style.color}');

    expect(labelText.style?.color, AppColors.textSecondaryLight);
    expect(editable.style.color, AppColors.textPrimaryLight);
    ctrl.dispose();
  });
}
