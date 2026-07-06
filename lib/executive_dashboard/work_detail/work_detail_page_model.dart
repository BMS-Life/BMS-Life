import '/components/sidebar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'work_detail_page_widget.dart' show WorkDetailPageWidget;
import 'package:flutter/material.dart';

class WorkDetailPageModel extends FlutterFlowModel<WorkDetailPageWidget> {
  // Model for Sidebar component.
  late SidebarModel sidebarModel;

  @override
  void initState(BuildContext context) {
    sidebarModel = createModel(context, () => SidebarModel());
  }

  @override
  void dispose() {
    sidebarModel.dispose();
  }
}
