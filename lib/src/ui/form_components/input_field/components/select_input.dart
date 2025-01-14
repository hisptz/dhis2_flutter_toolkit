import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../models/input_field_option.dart';
import '../models/select_input_field.dart';
import 'base_input.dart';

class SelectInput extends BaseStatelessInput<D2SelectInputFieldConfig, String> {
  const SelectInput({
    super.key,
    super.value,
    super.disabled,
    required super.input,
    required super.color,
    required super.onChange,
    required super.decoration,
  });

  @override
  Widget build(BuildContext context) {
    List<D2InputFieldOption> optionNames = input.filteredOptions;
    D2InputFieldOption? valueOption = input.filteredOptions
        .firstWhereOrNull((D2InputFieldOption option) => option.code == value);
    final bool shouldShowSearch = optionNames.length >= 10;
    return DropdownSearch<D2InputFieldOption>(
      suffixProps: DropdownSuffixProps(
          dropdownButtonProps: DropdownButtonProps(
        iconClosed: Transform.rotate(
          angle: -(pi / 2),
          child: const Icon(
            Icons.chevron_left,
            size: 32,
          ),
        ),
        iconOpened: Transform.rotate(
          angle: (pi / 2),
          child: const Icon(
            Icons.chevron_left,
            size: 32,
          ),
        ),
      )),
      popupProps: PopupProps.menu(
        showSearchBox: shouldShowSearch,
        searchFieldProps: const TextFieldProps(
          autofocus: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Search here',
          ),
        ),
        onDismissed: () {
          FocusScope.of(context).unfocus();
        },
        fit: FlexFit.tight,
        constraints: BoxConstraints(
          maxHeight: optionNames.length * 50.0 >
                  MediaQuery.of(context).size.height * 0.5
              ? MediaQuery.of(context).size.height * 0.5
              : optionNames.length * 60.0,
        ),
      ),
      decoratorProps: const DropDownDecoratorProps(
          decoration: InputDecoration(
        border: InputBorder.none,
      )),
      enabled: !disabled,
      itemAsString: (D2InputFieldOption option) => option.name,
      items: (filter, loadProps) {
        return optionNames;
      },
      compareFn:
          (D2InputFieldOption? item, D2InputFieldOption? selectedItem) {
        return item?.name == selectedItem?.name;
      },
      onChanged: disabled
          ? null
          : (D2InputFieldOption? selectedOption) {
              onChange(selectedOption?.code);
              FocusScope.of(context).requestFocus(FocusNode());
            },
      selectedItem: valueOption,
    );
  }
}
