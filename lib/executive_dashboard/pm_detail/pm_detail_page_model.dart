import '/components/sidebar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pm_detail_page_widget.dart' show PmDetailPageWidget;
import 'package:flutter/material.dart';

class PmDetailPageModel extends FlutterFlowModel<PmDetailPageWidget> {
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
