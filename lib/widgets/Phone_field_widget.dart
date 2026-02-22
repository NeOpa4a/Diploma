import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';

class PhoneInputWidget extends StatefulWidget {
  final void Function(String fullPhone)? onChanged;

  const PhoneInputWidget({super.key, this.onChanged});

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  String fullPhone = '';

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      style: const TextStyle(color: Color(0xFFFF8C0F)),
      initialCountryCode: 'UA',
      disableLengthCheck: false,
      decoration: const InputDecoration(
        labelText: 'Phone number',
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF8C0F))),
        labelStyle: TextStyle(color: Color(0xFFFF8C0F)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF8C0F)),
        ),
      ),
      dropdownTextStyle:
          const TextStyle(color: Color(0xFFFF8C0F), fontSize: 16),
      dropdownIcon: const Icon(
        Icons.arrow_drop_down,
        color: Color(0xFFFF8C0F),
      ),
      onChanged: (phone) {
        fullPhone = phone.completeNumber;
        widget.onChanged?.call(fullPhone);
      },
      onCountryChanged: (country) {
        debugPrint('Country changed to: ${country.code}');
      },
    );
  }
}
