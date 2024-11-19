import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dhis2_flutter_toolkit/src/ui/dropdown/custom_dropdown.dart';
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

    final bool shouldShowSearch = optionNames.length >= 6;

    return shouldShowSearch
        ? CustomDropdown<D2InputFieldOption>.search(
            decoration: CustomDropdownDecoration(
              closedFillColor: Colors.transparent,
              hintStyle: TextStyle(color: color),
              listItemDecoration: ListItemDecoration(
                selectedColor: color.withOpacity(0.05),
                selectedIconColor: color.withOpacity(0.05),
              ),
            ),
            disabledDecoration: const CustomDropdownDisabledDecoration(
              fillColor: Colors.transparent,
            ),
            closedHeaderPadding: const EdgeInsets.all(0),
            headerBuilder: (context, selectedItem, enabled) {
              return Text(
                selectedItem.name,
              );
            },
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              bool isSelected = item.code == value;
              return ListTile(
                title: Text(item.name,
                    style: isSelected ? TextStyle(color: color) : null),
              );
            },
            overlayHeight: 400,
            itemsListPadding: const EdgeInsets.all(0.0),
            listItemPadding: const EdgeInsets.all(0.0),
            initialItem: valueOption,
            overlayController: OverlayPortalController(),
            hintText: '',
            items: optionNames,
            excludeSelected: false,
            enabled: !disabled,
            onChanged: disabled
                ? null
                : (D2InputFieldOption? selectedOption) {
                    onChange(selectedOption?.code);
                  },
          )
        : CustomDropdown<D2InputFieldOption>(
            decoration: CustomDropdownDecoration(
              closedFillColor: Colors.transparent,
              hintStyle: TextStyle(color: color),
              listItemDecoration: ListItemDecoration(
                selectedColor: color.withOpacity(0.05),
                selectedIconColor: color.withOpacity(0.05),
              ),
            ),
            disabledDecoration: const CustomDropdownDisabledDecoration(
              fillColor: Colors.transparent,
            ),
            closedHeaderPadding: const EdgeInsets.all(0),
            headerBuilder: (context, selectedItem, enabled) {
              return Text(
                selectedItem.name,
              );
            },
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              bool isSelected = item.code == value;
              return ListTile(
                title: Text(item.name,
                    style: isSelected ? TextStyle(color: color) : null),
              );
            },
            itemsListPadding: const EdgeInsets.all(0.0),
            listItemPadding: const EdgeInsets.all(0.0),
            initialItem: valueOption,
            hintText: '',
            items: optionNames,
            excludeSelected: false,
            enabled: !disabled,
            onChanged: disabled
                ? null
                : (D2InputFieldOption? selectedOption) {
                    onChange(selectedOption?.code);
                  },
          );
  }
}
