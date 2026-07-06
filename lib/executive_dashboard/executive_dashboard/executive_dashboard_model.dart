import '/components/sidebar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'executive_dashboard_widget.dart' show ExecutiveDashboardWidget;
import 'package:flutter/material.dart';

class ExecutiveDashboardModel
    extends FlutterFlowModel<ExecutiveDashboardWidget> {
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
