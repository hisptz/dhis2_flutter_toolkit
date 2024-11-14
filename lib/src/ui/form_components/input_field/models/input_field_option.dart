import 'package:dhis2_flutter_toolkit/src/ui/dropdown/custom_dropdown.dart';

class D2InputFieldOption with CustomDropdownListFilter{
  String code;
  String name;
  int sortOrder;

  D2InputFieldOption({
    required this.code,
    required this.name,
    this.sortOrder = 0,
  });

  @override
  String toString() {
    return code;
  }
  
  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}
