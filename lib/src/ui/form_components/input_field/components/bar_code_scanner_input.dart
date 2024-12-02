import 'package:dhis2_flutter_toolkit/dhis2_flutter_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'base_input.dart';
import 'input_field_icon.dart';

class BarCodeScannerInput
    extends BaseStatelessInput<D2BarCodeScannerInputFieldConfig, String> {
  BarCodeScannerInput(
      {super.key,
      super.disabled,
      required super.input,
      required super.onChange,
      required super.color,
      super.value,
      required super.decoration});

  late TextEditingController controller;

  Future<void> onOpenBarCodeScanner(BuildContext context) async {
    if (disabled) return;
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        onChange(result.rawContent);
        controller.text = result.rawContent;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error scanning barcode: $e',
              style: const TextStyle(color: Colors.white),
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(text: value);
    return TextFormField(
        enabled: !disabled,
        showCursor: false,
        controller: controller,
        keyboardType: TextInputType.none,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: IconButton(
              color: color,
              padding: EdgeInsets.zero,
              constraints: iconConstraints,
              onPressed: disabled
                  ? null
                  : () {
                      onOpenBarCodeScanner(context);
                    },
              icon: InputFieldIcon(
                  backgroundColor: color,
                  iconColor: color,
                  iconData: Icons.document_scanner_outlined),
            )),
        onTap: disabled
            ? null
            : () {
                onOpenBarCodeScanner(context);
              });
  }
}
