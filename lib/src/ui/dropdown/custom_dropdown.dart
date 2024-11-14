library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

export 'custom_dropdown.dart';

// models
part 'models/custom_dropdown_decoration.dart';
part 'models/custom_dropdown_list_filter.dart';
part 'models/disabled_decoration.dart';
part 'models/list_item_decoration.dart';
part 'models/controllers.dart';
part 'models/search_field_decoration.dart';
// utils
part 'utils/signatures.dart';
// widgets
part 'components/animated_section.dart';
part 'components/dropdown_field.dart';
part 'components/dropdown_overlay/dropdown_overlay.dart';
part 'components/dropdown_overlay/components/items_list.dart';
part 'components/dropdown_overlay/components/search_field.dart';
part 'components/overlay_builder.dart';

enum _DropdownType { singleSelect, multipleSelect }

enum _SearchType { onListData, onRequestData }

const _defaultErrorColor = Colors.red;

const _defaultBorderRadius = BorderRadius.all(
  Radius.circular(12),
);

final Border _defaultErrorBorder = Border.all(
  color: _defaultErrorColor,
  width: 1.5,
);

const _defaultErrorStyle = TextStyle(
  color: _defaultErrorColor,
  fontSize: 14,
  height: 0.5,
);

class CustomDropdown<T> extends StatefulWidget {
  /// The list of items user can select.
  final List<T>? items;

  /// Initial selected item from the list of [items].
  final T? initialItem;

  /// Initial selected items from the list of [items].
  final List<T>? initialItems;

  /// Scroll controller to access items list scroll behavior.
  final ScrollController? itemsScrollController;

  /// Text that suggests what sort of data the dropdown represents.
  ///
  /// Default to "Select value".
  final String? hintText;

  /// Text that suggests what to search in the search field.
  ///
  /// Default to "Search".
  final String? searchHintText;

  /// A method that validates the selected item.
  /// Returns an error string to display as per the validation, or null otherwise.
  final String? Function(T?)? validator;

  /// A method that validates the selected items.
  /// Returns an error string to display as per the validation, or null otherwise.
  final String? Function(List<T>)? listValidator;

  /// Enable the validation listener on item change.
  /// This implies to [validator] everytime when the item change.
  final bool validateOnChange;

  /// Called when the item of the [CustomDropdown] should change.
  final Function(T?)? onChanged;

  /// Called when the list of items of the [CustomDropdown] should change.
  final Function(List<T>)? onListChanged;

  /// Hide the selected item from the [items] list.
  final bool excludeSelected;

  /// Can close [CustomDropdown] overlay by tapping outside.
  /// Here "outside" covers the entire screen.
  final bool canCloseOutsideBounds;

  /// Hide the header field when [CustomDropdown] overlay opened/expanded.
  final bool hideSelectedFieldWhenExpanded;

  /// The asynchronous computation from which the items list returns.
  final Future<List<T>> Function(String)? futureRequest;

  /// Text that notify there's no search results match.
  ///
  /// Default to "No result found.".
  final String? noResultFoundText;

  /// Duration after which the [futureRequest] is to be executed.
  final Duration? futureRequestDelay;

  /// Text maxLines for header and list item text.
  final int maxLines;

  /// Padding for [CustomDropdown] header (closed state).
  final EdgeInsets? closedHeaderPadding;

  /// Padding for [CustomDropdown] header (opened/expanded state).
  final EdgeInsets? expandedHeaderPadding;

  /// Padding for [CustomDropdown] items list.
  final EdgeInsets? itemsListPadding;

  /// Padding for [CustomDropdown] each list item.
  final EdgeInsets? listItemPadding;

  /// Widget to display while search request loading.
  final Widget? searchRequestLoadingIndicator;

  /// [CustomDropdown] opened/expanded area height.
  /// Only applicable if items are greater than 4 otherwise adjust automatically.
  final double? overlayHeight;

  /// The [listItemBuilder] that will be used to build item on demand.
  final ListItemBuilder<T>? listItemBuilder;

  /// The [headerBuilder] that will be used to build [CustomDropdown] header field.
  final HeaderBuilder<T>? headerBuilder;

  /// The [hintBuilder] that will be used to build [CustomDropdown] hint of header field.
  final HintBuilder? hintBuilder;

  /// The [noResultFoundBuilder] that will be used to build area when there's no search results match.
  final NoResultFoundBuilder? noResultFoundBuilder;

  /// The [headerListBuilder] that will be used to build [CustomDropdown] header field.
  final HeaderListBuilder<T>? headerListBuilder;

  /// [CustomDropdown] decoration.
  /// Contain sub-decorations [SearchFieldDecoration], [ListItemDecoration] and [ScrollbarThemeData].
  final CustomDropdownDecoration? decoration;

  /// [CustomDropdown] enabled/disabled state.
  /// If disabled, you can not open the dropdown.
  final bool enabled;

  /// [CustomDropdown] disabled decoration.
  ///
  /// Note: Only applicable if dropdown is disabled.
  final CustomDropdownDisabledDecoration? disabledDecoration;

  /// [CustomDropdown] will close on tap Clear filter for all search
  /// and searchRequest constructors
  final bool closeDropDownOnClearFilterSearch;

  /// The [overlayController] allows you to explicitly handle the [CustomDropdown] overlay states (show/hide).
  final OverlayPortalController? overlayController;

  /// The [controller] that can be used to control [CustomDropdown] selected item.
  final SingleSelectController<T?>? controller;

  /// The [multiSelectController] that can be used to control [CustomDropdown.multiSelect] selected items.
  final MultiSelectController<T>? multiSelectController;

  /// Callback for dropdown [visibility].
  ///
  /// If both [visibility] and [overlayController] are provided, this callback never listens the changes of [overlayController].
  /// You have to explicitly check for [overlayController] visibility states using [overlayController.isShowing] property.
  final Function(bool)? visibility;

  final _SearchType? _searchType;

  final _DropdownType _dropdownType;

  CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.controller,
    this.itemsScrollController,
    this.initialItem,
    this.hintText,
    this.decoration,
    this.validator,
    this.validateOnChange = true,
    this.visibility,
    this.overlayController,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
    this.maxLines = 1,
    this.overlayHeight,
    this.closedHeaderPadding,
    this.expandedHeaderPadding,
    this.itemsListPadding,
    this.listItemPadding,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.excludeSelected = true,
    this.enabled = true,
    this.disabledDecoration,
  })  : assert(
          initialItem == null || controller == null,
          'Only one of initialItem or controller can be specified at a time',
        ),
        assert(
          initialItem == null || items!.contains(initialItem),
          'Initial item must match with one of the item in items list.',
        ),
        assert(
          controller == null ||
              controller.value == null ||
              items!.contains(controller.value),
          'Controller value must match with one of the item in items list.',
        ),
        _searchType = null,
        _dropdownType = _DropdownType.singleSelect,
        futureRequest = null,
        futureRequestDelay = null,
        noResultFoundBuilder = null,
        noResultFoundText = null,
        searchHintText = null,
        initialItems = null,
        onListChanged = null,
        listValidator = null,
        headerListBuilder = null,
        searchRequestLoadingIndicator = null,
        closeDropDownOnClearFilterSearch = false,
        multiSelectController = null;

  CustomDropdown.search({
    super.key,
    required this.items,
    required this.onChanged,
    this.controller,
    this.itemsScrollController,
    this.initialItem,
    this.hintText,
    this.decoration,
    this.visibility,
    this.overlayController,
    this.searchHintText,
    this.noResultFoundText,
    this.listItemBuilder,
    this.headerBuilder,
    this.hintBuilder,
    this.noResultFoundBuilder,
    this.validator,
    this.validateOnChange = true,
    this.maxLines = 1,
    this.overlayHeight,
    this.closedHeaderPadding,
    this.expandedHeaderPadding,
    this.itemsListPadding,
    this.listItemPadding,
    this.excludeSelected = true,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.enabled = true,
    this.disabledDecoration,
    this.closeDropDownOnClearFilterSearch = false,
  })  : assert(
          initialItem == null || controller == null,
          'Only one of initialItem or controller can be specified at a time',
        ),
        assert(
          initialItem == null || items!.contains(initialItem),
          'Initial item must match with one of the item in items list.',
        ),
        assert(
          controller == null ||
              controller.value == null ||
              items!.contains(controller.value),
          'Controller value must match with one of the item in items list.',
        ),
        _searchType = _SearchType.onListData,
        _dropdownType = _DropdownType.singleSelect,
        futureRequest = null,
        futureRequestDelay = null,
        initialItems = null,
        onListChanged = null,
        listValidator = null,
        headerListBuilder = null,
        searchRequestLoadingIndicator = null,
        multiSelectController = null;

  CustomDropdown.multiSelect({
    super.key,
    required this.items,
    required this.onListChanged,
    this.multiSelectController,
    this.controller,
    this.initialItems,
    this.overlayController,
    this.itemsScrollController,
    this.listValidator,
    this.visibility,
    this.headerListBuilder,
    this.hintText,
    this.decoration,
    this.validateOnChange = true,
    this.listItemBuilder,
    this.hintBuilder,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.maxLines = 1,
    this.overlayHeight,
    this.closedHeaderPadding,
    this.expandedHeaderPadding,
    this.itemsListPadding,
    this.listItemPadding,
    this.enabled = true,
    this.disabledDecoration,
  })  : assert(
          initialItems == null || multiSelectController == null,
          'Only one of initialItems or controller can be specified at a time',
        ),
        assert(
          initialItems == null ||
              initialItems.isEmpty ||
              initialItems.any((e) => items!.contains(e)),
          'Initial items must match with the items in the items list.',
        ),
        assert(
          multiSelectController == null ||
              multiSelectController.value.isEmpty ||
              multiSelectController.value.any((e) => items!.contains(e)),
          'Controller value must match with one of the item in items list.',
        ),
        _searchType = null,
        _dropdownType = _DropdownType.multipleSelect,
        initialItem = null,
        noResultFoundText = null,
        validator = null,
        headerBuilder = null,
        onChanged = null,
        excludeSelected = false,
        futureRequest = null,
        futureRequestDelay = null,
        noResultFoundBuilder = null,
        searchHintText = null,
        searchRequestLoadingIndicator = null,
        closeDropDownOnClearFilterSearch = false;

  CustomDropdown.multiSelectSearch({
    super.key,
    required this.items,
    required this.onListChanged,
    this.multiSelectController,
    this.initialItems,
    this.controller,
    this.visibility,
    this.itemsScrollController,
    this.overlayController,
    this.listValidator,
    this.listItemBuilder,
    this.hintBuilder,
    this.decoration,
    this.headerListBuilder,
    this.noResultFoundText,
    this.noResultFoundBuilder,
    this.hintText,
    this.searchHintText,
    this.validateOnChange = true,
    this.canCloseOutsideBounds = true,
    this.hideSelectedFieldWhenExpanded = false,
    this.maxLines = 1,
    this.overlayHeight,
    this.closedHeaderPadding,
    this.expandedHeaderPadding,
    this.itemsListPadding,
    this.listItemPadding,
    this.enabled = true,
    this.disabledDecoration,
    this.closeDropDownOnClearFilterSearch = false,
  })  : assert(
          initialItems == null || multiSelectController == null,
          'Only one of initialItems or controller can be specified at a time',
        ),
        assert(
          initialItems == null ||
              initialItems.isEmpty ||
              initialItems.any((e) => items!.contains(e)),
          'Initial items must match with the items in the items list.',
        ),
        assert(
          multiSelectController == null ||
              multiSelectController.value.isEmpty ||
              multiSelectController.value.any((e) => items!.contains(e)),
          'Controller value must match with one of the item in items list.',
        ),
        _searchType = _SearchType.onListData,
        _dropdownType = _DropdownType.multipleSelect,
        initialItem = null,
        onChanged = null,
        validator = null,
        excludeSelected = false,
        headerBuilder = null,
        futureRequest = null,
        futureRequestDelay = null,
        searchRequestLoadingIndicator = null;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final layerLink = LayerLink();
  late SingleSelectController<T?> selectedItemNotifier;
  late MultiSelectController<T> selectedItemsNotifier;
  FormFieldState<(T?, List<T>)>? _formFieldState;

  void _selectedItemListener() {
    widget.onChanged?.call(selectedItemNotifier.value);
    _formFieldState?.didChange((selectedItemNotifier.value, []));
    if (widget.validateOnChange) {
      _formFieldState?.validate();
    }
  }

  void _selectedItemsListener() {
    widget.onListChanged?.call(selectedItemsNotifier.value);
    _formFieldState?.didChange((null, selectedItemsNotifier.value));
    if (widget.validateOnChange) {
      _formFieldState?.validate();
    }
  }

  @override
  void initState() {
    super.initState();

    selectedItemNotifier =
        widget.controller ?? SingleSelectController(widget.initialItem);

    selectedItemsNotifier = widget.multiSelectController ??
        MultiSelectController(widget.initialItems ?? []);

    selectedItemNotifier.addListener(_selectedItemListener);

    selectedItemsNotifier.addListener(_selectedItemsListener);
  }

  @override
  void didUpdateWidget(covariant CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialItem != oldWidget.initialItem &&
        selectedItemNotifier.value != widget.initialItem) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        selectedItemNotifier.value = widget.initialItem;
      });
    }

    if (widget.initialItems != oldWidget.initialItems &&
        selectedItemsNotifier.value != widget.initialItems) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        selectedItemsNotifier.value = widget.initialItems ?? [];
      });
    }

    if (widget.controller != oldWidget.controller &&
        widget.controller != null) {
      selectedItemNotifier = widget.controller!;
    }

    if (widget.multiSelectController != oldWidget.multiSelectController &&
        widget.multiSelectController != null) {
      selectedItemsNotifier = widget.multiSelectController!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      selectedItemNotifier.dispose();
    } else {
      selectedItemNotifier.removeListener(_selectedItemListener);
    }

    if (widget.multiSelectController == null) {
      selectedItemsNotifier.dispose();
    } else {
      selectedItemsNotifier.removeListener(_selectedItemsListener);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final decoration = widget.decoration;
    final disabledDecoration = widget.disabledDecoration;
    final safeHintText = widget.hintText ?? 'Select value';

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: FormField<(T?, List<T>)>(
        initialValue: (selectedItemNotifier.value, selectedItemsNotifier.value),
        validator: (val) {
          if (widget._dropdownType == _DropdownType.singleSelect &&
              widget.validator != null) {
            return widget.validator!(val?.$1);
          }
          if (widget._dropdownType == _DropdownType.multipleSelect &&
              widget.listValidator != null) {
            return widget.listValidator!(val?.$2 ?? []);
          }
          return null;
        },
        builder: (formFieldState) {
          _formFieldState = formFieldState;
          return InputDecorator(
            decoration: InputDecoration(
              errorStyle: decoration?.errorStyle ?? _defaultErrorStyle,
              errorText: formFieldState.errorText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            child: _OverlayBuilder(
              overlayPortalController: widget.overlayController,
              visibility: widget.visibility,
              overlay: (size, hideCallback) {
                return _DropdownOverlay<T>(
                  onItemSelect: (T value) {
                    switch (widget._dropdownType) {
                      case _DropdownType.singleSelect:
                        selectedItemNotifier.value = value;
                      case _DropdownType.multipleSelect:
                        final currentVal = selectedItemsNotifier.value.toList();
                        if (currentVal.contains(value)) {
                          currentVal.remove(value);
                        } else {
                          currentVal.add(value);
                        }
                        selectedItemsNotifier.value = currentVal;
                    }
                  },
                  noResultFoundText:
                      widget.noResultFoundText ?? 'No result found.',
                  noResultFoundBuilder: widget.noResultFoundBuilder,
                  items: widget.items ?? [],
                  itemsScrollCtrl: widget.itemsScrollController,
                  selectedItemNotifier: selectedItemNotifier,
                  selectedItemsNotifier: selectedItemsNotifier,
                  size: size,
                  listItemBuilder: widget.listItemBuilder,
                  layerLink: layerLink,
                  hideOverlay: hideCallback,
                  hintStyle: decoration?.hintStyle,
                  headerStyle: decoration?.headerStyle,
                  noResultFoundStyle: decoration?.noResultFoundStyle,
                  listItemStyle: decoration?.listItemStyle,
                  headerBuilder: widget.headerBuilder,
                  headerListBuilder: widget.headerListBuilder,
                  hintText: safeHintText,
                  searchHintText: widget.searchHintText ?? 'Search',
                  hintBuilder: widget.hintBuilder,
                  decoration: decoration,
                  overlayHeight: widget.overlayHeight,
                  excludeSelected: widget.excludeSelected,
                  canCloseOutsideBounds: widget.canCloseOutsideBounds,
                  searchType: widget._searchType,
                  futureRequest: widget.futureRequest,
                  futureRequestDelay: widget.futureRequestDelay,
                  hideSelectedFieldWhenOpen:
                      widget.hideSelectedFieldWhenExpanded,
                  maxLines: widget.maxLines,
                  headerPadding: widget.expandedHeaderPadding,
                  itemsListPadding: widget.itemsListPadding,
                  listItemPadding: widget.listItemPadding,
                  searchRequestLoadingIndicator:
                      widget.searchRequestLoadingIndicator,
                  dropdownType: widget._dropdownType,
                );
              },
              child: (showCallback) {
                return CompositedTransformTarget(
                  link: layerLink,
                  child: _DropDownField<T>(
                    onTap: showCallback,
                    selectedItemNotifier: selectedItemNotifier,
                    border: formFieldState.hasError
                        ? (decoration?.closedErrorBorder ?? _defaultErrorBorder)
                        : enabled
                            ? decoration?.closedBorder
                            : disabledDecoration?.border,
                    borderRadius: formFieldState.hasError
                        ? decoration?.closedErrorBorderRadius
                        : enabled
                            ? decoration?.closedBorderRadius
                            : disabledDecoration?.borderRadius,
                    shadow: enabled
                        ? decoration?.closedShadow
                        : disabledDecoration?.shadow,
                    hintStyle: enabled
                        ? decoration?.hintStyle
                        : disabledDecoration?.hintStyle,
                    headerStyle: enabled
                        ? decoration?.headerStyle
                        : disabledDecoration?.headerStyle,
                    hintText: safeHintText,
                    hintBuilder: widget.hintBuilder,
                    headerBuilder: widget.headerBuilder,
                    headerListBuilder: widget.headerListBuilder,
                    prefixIcon: enabled
                        ? decoration?.prefixIcon
                        : disabledDecoration?.prefixIcon,
                    suffixIcon: enabled
                        ? decoration?.closedSuffixIcon
                        : disabledDecoration?.suffixIcon,
                    fillColor: enabled
                        ? decoration?.closedFillColor
                        : disabledDecoration?.fillColor,
                    maxLines: widget.maxLines,
                    headerPadding: widget.closedHeaderPadding,
                    dropdownType: widget._dropdownType,
                    selectedItemsNotifier: selectedItemsNotifier,
                    enabled: widget.enabled,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
