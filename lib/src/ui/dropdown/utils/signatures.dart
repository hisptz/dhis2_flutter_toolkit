part of '../custom_dropdown.dart';

typedef ListItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
  VoidCallback onItemSelect,
);
typedef HeaderBuilder<T> = Widget Function(
  BuildContext context,
  T selectedItem,
  bool enabled,
);
typedef HeaderListBuilder<T> = Widget Function(
  BuildContext context,
  List<T> selectedItems,
  bool enabled,
);
typedef HintBuilder = Widget Function(
  BuildContext context,
  String hint,
  bool enabled,
);
typedef NoResultFoundBuilder = Widget Function(
  BuildContext context,
  String text,
);
