import 'package:flutter/material.dart';

class SmsCodeInput extends StatefulWidget {
  final void Function(String code)? onChanged;

  const SmsCodeInput({super.key, this.onChanged});

  @override
  State<SmsCodeInput> createState() => _SmsCodeInputState();
}

class _SmsCodeInputState extends State<SmsCodeInput> {
  final int length = 6;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(length, (_) => TextEditingController());
    focusNodes = List.generate(length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < length - 1) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }

    final code = controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    print('Current SMS code: $code');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (index) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.125,
          height: MediaQuery.of(context).size.height * 0.09,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              color: Color(0xFFFF8C0F),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF8C0F)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF8C0F)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}
