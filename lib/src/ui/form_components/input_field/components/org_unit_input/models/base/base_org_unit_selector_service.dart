import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:collection/collection.dart';

import '../org_unit_data.dart';

abstract class D2BaseOrgUnitSelectorService<T> {
  TreeNode<OrgUnitData>? _tree;
  TreeViewController<OrgUnitData, TreeNode<OrgUnitData>>? _controller;
  List<String>? selectedOrgUnits;

  D2BaseOrgUnitSelectorService({this.selectedOrgUnits});

  TreeNode<OrgUnitData> get tree {
    if (_tree == null) {
      throw "You need to call initialize first";
    }
    return _tree!;
  }

  TreeViewController<OrgUnitData, TreeNode<OrgUnitData>> get controller {
    if (_controller == null) {
      throw "Controller is not initialized";
    }
    return _controller!;
  }

  OrgUnitData getOrgUnitDataFromOrgUnit(T orgUnit);

  TreeNode<OrgUnitData> getTreeNodeFromOrgUnitData(OrgUnitData orgUnitData);

  setTree(TreeNode<OrgUnitData> tree) {
    _tree = tree;
  }

  setController(
      TreeViewController<OrgUnitData, TreeNode<OrgUnitData>> controller) {
    _controller = controller;
  }

  Future<List<TreeNode<OrgUnitData>>> getChildren(TreeNode<OrgUnitData> node);

  Future<void> initialize();

  Future<List<OrgUnitData>> getOrgUnitDataFromId(List<String> values);

  void expandInitiallySelected({List<String>? initiallySelected}) {
    if (initiallySelected != null) {
      List<ListenableNode> allNodes = controller.tree.childrenAsList;
      List<ListenableNode?> initiallySelectedNodesNullable =
          initiallySelected.map<ListenableNode?>((key) {
        return allNodes
            .firstWhereOrNull((ListenableNode element) => element.key == key);
      }).toList();
    }
  }
}
