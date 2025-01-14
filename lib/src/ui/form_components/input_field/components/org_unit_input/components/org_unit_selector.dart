import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:collection/collection.dart';
import 'package:dhis2_flutter_toolkit/src/ui/form_components/input_field/components/base_input.dart';
import 'package:dhis2_flutter_toolkit/src/ui/form_components/input_field/components/org_unit_input/components/org_unit_expansion_indicator.dart';
import 'package:dhis2_flutter_toolkit/src/ui/form_components/input_field/components/org_unit_input/components/org_unit_tree_tile.dart';
import 'package:flutter/material.dart';

import '../../../models/org_unit_input_field.dart';
import '../models/base/base_org_unit_selector_service.dart';
import '../models/org_unit_data.dart';

class OrgUnitSelector extends StatefulWidget {
  final D2OrgUnitInputFieldConfig config;
  final List<String>? selectedOrgUnits;
  final OnChange<List<String>> onSelect;
  final Color color;
  final List<String> limitSelectionTo;

  const OrgUnitSelector({
    super.key,
    this.selectedOrgUnits = const [],
    this.limitSelectionTo = const [],
    required this.onSelect,
    required this.config,
    required this.color,
  });

  @override
  State<OrgUnitSelector> createState() => OrgUnitSelectorState();
}

class OrgUnitSelectorState extends State<OrgUnitSelector> {
  bool _loading = true;
  bool multiple = false;
  List<String> selectedOrgUnits = [];
  D2BaseOrgUnitSelectorService? service;

  initializeService() async {
    setState(() {
      _loading = true;
    });
    await service!.initialize();
    setState(() {
      _loading = false;
    });
  }

  toggleOrgUnitSelection(OrgUnitData orgUnitData) {
    bool disableSelection = getDisabledSelectionStatus(orgUnitData.id);
    if (disableSelection) {
      return;
    }

    if (selectedOrgUnits.contains(orgUnitData.id)) {
      setState(() {
        selectedOrgUnits = selectedOrgUnits
            .whereNot((orgUnitId) => orgUnitId == orgUnitData.id)
            .toList();
      });
    } else {
      if (multiple) {
        setState(() {
          selectedOrgUnits.add(orgUnitData.id);
        });
      } else {
        setState(() {
          selectedOrgUnits = [orgUnitData.id];
        });
      }
    }
  }

  bool getDisabledSelectionStatus(String id) {
    if (widget.limitSelectionTo.isEmpty) {
      return false;
    }
    return !widget.limitSelectionTo.contains(id);
  }

  @override
  void initState() {
    setState(() {
      service = widget.config.service;
      multiple = widget.config.multiple;
      selectedOrgUnits = widget.selectedOrgUnits ?? [];
    });
    initializeService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        buttonPadding: const EdgeInsets.all(4.0),
        title: Text(widget.config.label),
        content: Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.9,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : TreeView.simpleTyped<OrgUnitData, TreeNode<OrgUnitData>>(
                    indentation: const Indentation(),
                    expansionBehavior: ExpansionBehavior.none,
                    expansionIndicatorBuilder: (BuildContext context, node) {
                      return OrgUnitExpansionIndicator(
                        tree: node,
                        alignment: Alignment.centerLeft,
                      );
                    },
                    showRootNode: false,
                    shrinkWrap: true,
                    onTreeReady: (controller) {
                      service!.setController(controller);
                      service!.expandInitiallySelected(
                          initiallySelected: widget.selectedOrgUnits);
                    },
                    builder:
                        (BuildContext context, TreeNode<OrgUnitData> node) {
                      if (node.data != null) {
                        return InkWell(
                          onTap: () {
                            toggleOrgUnitSelection(node.data!);
                          },
                          child: OrgUnitTreeTile(
                              disabledSelection:
                                  getDisabledSelectionStatus(node.data!.id),
                              toggleSelection: toggleOrgUnitSelection,
                              node: node,
                              color: widget.color,
                              multiple: multiple,
                              selected: selectedOrgUnits),
                        );
                      }
                      return const Text("Root");
                    },
                    tree: service!.tree),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                widget.onSelect(selectedOrgUnits);
                Navigator.of(context).pop();
              },
              child: const Text("Select")),
        ]);
  }
}
