import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';

import '/main.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:ff_commons/flutter_flow/lat_lng.dart';
import 'package:ff_commons/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';
import "package:u_i_library_3c2hbt/backend/schema/structs/index.dart"
    as u_i_library_3c2hbt_data_schema;

import '/index.dart';
import 'package:u_i_library_3c2hbt/index.dart' as $u_i_library_3c2hbt;

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) {
  $u_i_library_3c2hbt.initializeRoutes(
    coverWidgetName: 'u_i_library_3c2hbt.Cover',
    coverWidgetPath: '/cover',
    columnStackedChartWidgetName: 'u_i_library_3c2hbt.ColumnStackedChart',
    columnStackedChartWidgetPath: '/columnStackedChart',
    barStackedChartWidgetName: 'u_i_library_3c2hbt.BarStackedChart',
    barStackedChartWidgetPath: '/barStackedChart',
    columnChartWidgetName: 'u_i_library_3c2hbt.ColumnChart',
    columnChartWidgetPath: '/columnChart',
    previewSpikeChartWidgetName: 'u_i_library_3c2hbt.previewSpikeChart',
    previewSpikeChartWidgetPath: '/previewSpikeChart',
    rippleDemoWidgetName: 'u_i_library_3c2hbt.RippleDemo',
    rippleDemoWidgetPath: '/rippleDemo',
    sliverWidgetName: 'u_i_library_3c2hbt.Sliver',
    sliverWidgetPath: '/sliver',
    stepperDemoWidgetName: 'u_i_library_3c2hbt.StepperDemo',
    stepperDemoWidgetPath: '/stepperDemo',
    staticLabelDemoWidgetName: 'u_i_library_3c2hbt.StaticLabelDemo',
    staticLabelDemoWidgetPath: '/staticLabelDemo',
    animatedListDemoWidgetName: 'u_i_library_3c2hbt.AnimatedListDemo',
    animatedListDemoWidgetPath: '/animatedListDemo',
    multipleSelectableSearchDemoWidgetName:
        'u_i_library_3c2hbt.MultipleSelectableSearchDemo',
    experimentalWidgetName: 'u_i_library_3c2hbt.experimental',
  );

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: appStateNotifier,
    navigatorKey: appNavigatorKey,
    errorBuilder: (context, state) => appStateNotifier.showSplashImage
        ? Builder(
            builder: (context) => Container(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              child: Image.asset(
                'assets/images/image_22-removebg-preview.png',
                fit: BoxFit.cover,
              ),
            ),
          )
        : BookingDetailWidget(),
    routes: [
      FFRoute(
        name: '_initialize',
        path: '/',
        builder: (context, _) => appStateNotifier.showSplashImage
            ? Builder(
                builder: (context) => Container(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  child: Image.asset(
                    'assets/images/image_22-removebg-preview.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : BookingDetailWidget(),
      ),
      FFRoute(
        name: BookingListWidget.routeName,
        path: BookingListWidget.routePath,
        builder: (context, params) => BookingListWidget(),
      ),
      FFRoute(
        name: BookingDetailWidget.routeName,
        path: BookingDetailWidget.routePath,
        builder: (context, params) => BookingDetailWidget(),
      ),
      FFRoute(
        name: ExecutiveDashboardWidget.routeName,
        path: ExecutiveDashboardWidget.routePath,
        builder: (context, params) => ExecutiveDashboardWidget(),
      ),
      FFRoute(
        name: WorkDetailPageWidget.routeName,
        path: WorkDetailPageWidget.routePath,
        builder: (context, params) => WorkDetailPageWidget(
          workId: params.getParam('id', ParamType.String),
        ),
      ),
      FFRoute(
        name: PmDetailPageWidget.routeName,
        path: PmDetailPageWidget.routePath,
        builder: (context, params) => PmDetailPageWidget(
          managerId: params.getParam('id', ParamType.String),
        ),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.CoverWidget.routeName,
        path: $u_i_library_3c2hbt.CoverWidget.routePath,
        builder: (context, params) => $u_i_library_3c2hbt.CoverWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.ColumnStackedChartWidget.routeName,
        path: $u_i_library_3c2hbt.ColumnStackedChartWidget.routePath,
        builder: (context, params) =>
            $u_i_library_3c2hbt.ColumnStackedChartWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.BarStackedChartWidget.routeName,
        path: $u_i_library_3c2hbt.BarStackedChartWidget.routePath,
        builder: (context, params) =>
            $u_i_library_3c2hbt.BarStackedChartWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.ColumnChartWidget.routeName,
        path: $u_i_library_3c2hbt.ColumnChartWidget.routePath,
        builder: (context, params) => $u_i_library_3c2hbt.ColumnChartWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.PreviewSpikeChartWidget.routeName,
        path: $u_i_library_3c2hbt.PreviewSpikeChartWidget.routePath,
        builder: (context, params) =>
            $u_i_library_3c2hbt.PreviewSpikeChartWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.RippleDemoWidget.routeName,
        path: $u_i_library_3c2hbt.RippleDemoWidget.routePath,
        builder: (context, params) => $u_i_library_3c2hbt.RippleDemoWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.SliverWidget.routeName,
        path: $u_i_library_3c2hbt.SliverWidget.routePath,
        builder: (context, params) => $u_i_library_3c2hbt.SliverWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.StepperDemoWidget.routeName,
        path: $u_i_library_3c2hbt.StepperDemoWidget.routePath,
        builder: (context, params) => $u_i_library_3c2hbt.StepperDemoWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.StaticLabelDemoWidget.routeName,
        path: $u_i_library_3c2hbt.StaticLabelDemoWidget.routePath,
        builder: (context, params) =>
            $u_i_library_3c2hbt.StaticLabelDemoWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.AnimatedListDemoWidget.routeName,
        path: $u_i_library_3c2hbt.AnimatedListDemoWidget.routePath,
        builder: (context, params) =>
            $u_i_library_3c2hbt.AnimatedListDemoWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.MultipleSelectableSearchDemoWidget.routeName,
        path: $u_i_library_3c2hbt.MultipleSelectableSearchDemoWidget.routePath,
        builder: (context, params) =>
            $u_i_library_3c2hbt.MultipleSelectableSearchDemoWidget(),
      ),
      FFRoute(
        name: $u_i_library_3c2hbt.ExperimentalWidget.routeName,
        path: $u_i_library_3c2hbt.ExperimentalWidget.routePath,
        builder: (context, params) => $u_i_library_3c2hbt.ExperimentalWidget(),
      )
    ].map((r) => r.toRoute(appStateNotifier)).toList(),
  );
}

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo {
    final possibleKeys = [
      '__transition_info__',
      '__transition_info__u_i_library_3c2hbt'
    ];
    for (final key in possibleKeys) {
      if (extraMap.containsKey(key)) {
        return extraMap[key] as TransitionInfo;
      }
    }
    return TransitionInfo.appDefault();
  }
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
