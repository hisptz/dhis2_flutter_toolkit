import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:dhis2_flutter_toolkit/dhis2_flutter_toolkit.dart';
import 'package:dhis2_flutter_toolkit/objectbox.g.dart';
import 'package:dhis2_flutter_toolkit/src/ui/form_components/input_field/components/org_unit_input/models/org_unit_data.dart';

class D2LocalOrgUnitSelectorService
    extends D2BaseOrgUnitSelectorService<D2OrgUnit> {
  D2ObjectBox db;
  List<TreeNode<OrgUnitData>>? roots;

  D2LocalOrgUnitSelectorService(this.db, {List<OrgUnitData>? initialRoots}) {
    if (initialRoots != null) {
      roots = initialRoots.map(getTreeNodeFromOrgUnitData).toList();
    }
  }

  initializeRoots() async {
    if (roots == null || roots!.isEmpty) {
      List<D2OrgUnit> rootOrgUnits =
          await D2OrgUnitRepository(db).getByLevel(1);
      List<OrgUnitData> orgUnitData =
          rootOrgUnits.map(getOrgUnitDataFromOrgUnit).toList();
      roots = orgUnitData
          .map<TreeNode<OrgUnitData>>(getTreeNodeFromOrgUnitData)
          .toList();
    }
  }

  @override
  OrgUnitData getOrgUnitDataFromOrgUnit(D2OrgUnit orgUnit) {
    return OrgUnitData(
        displayName: orgUnit.displayName ?? orgUnit.name,
        level: orgUnit.level.target!.level,
        hasChildren: orgUnit.children.isNotEmpty,
        children: orgUnit.children.map(getOrgUnitDataFromOrgUnit).toList(),
        id: orgUnit.uid,
        path: orgUnit.path);
  }

  @override
  TreeNode<OrgUnitData> getTreeNodeFromOrgUnitData(OrgUnitData orgUnitData) {
    return TreeNode(key: orgUnitData.id, data: orgUnitData)
      ..addAll(orgUnitData.children?.map(getTreeNodeFromOrgUnitData) ?? []);
  }

  @override
  Future initialize() async {
    await initializeRoots();
    if (roots != null) {
      setTree(TreeNode.root()..addAll(roots!));
    }
  }

  @override
  Future<List<TreeNode<OrgUnitData>>> getChildren(
      TreeNode<OrgUnitData> node) async {
    D2OrgUnit? orgUnit = D2OrgUnitRepository(db).getByUid(node.data!.id);
    if (orgUnit != null) {
      return orgUnit.children
          .map(getOrgUnitDataFromOrgUnit)
          .map(getTreeNodeFromOrgUnitData)
          .toList();
    }
    return [];
  }

  @override
  Future<List<OrgUnitData>> getOrgUnitDataFromId(List<String> values) async {
    List<D2OrgUnit> orgUnits = await D2OrgUnitRepository(db)
        .box
        .query(D2OrgUnit_.uid.oneOf(values))
        .build()
        .findAsync();

    return orgUnits.map(getOrgUnitDataFromOrgUnit).toList();
  }

  @override
  List<OrgUnitData> getOrgUnitDataFromIdSync(List<String> values) {
    List<D2OrgUnit> orgUnits = D2OrgUnitRepository(db)
        .box
        .query(D2OrgUnit_.uid.oneOf(values))
        .build()
        .find();

    return orgUnits.map(getOrgUnitDataFromOrgUnit).toList();
  }

  @override
  Future<List<OrgUnitData>> searchOrgUnitDataFromKeyword(String keyword) async {
    QueryBuilder<D2OrgUnit> queryBuilder = D2OrgUnitRepository(db).box.query(
        D2OrgUnit_.name.contains(keyword, caseSensitive: false).or(D2OrgUnit_
            .code
            .contains(keyword, caseSensitive: false)
            .or(D2OrgUnit_.uid.contains(keyword, caseSensitive: false))));
    List<D2OrgUnit> orgUnits = await queryBuilder.build().findAsync();
    return orgUnits.map(getOrgUnitDataFromOrgUnit).toList();
  }
}
