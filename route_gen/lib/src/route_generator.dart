import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:collection/collection.dart';
import 'package:route_gen/anotations.dart';
import 'package:source_gen/source_gen.dart';

typedef Route = Map<String, DartObject>;

class ResolvedRoute {
  final String path;
  final String namePostfix;
  final ParameterizedType? pageType;
  final List<ResolvedRoute> children;

  ResolvedRoute prependPath(String path) {
    if (path == "/") return this;
    return ResolvedRoute(
      path: path + this.path,
      namePostfix: namePostfix,
      pageType: pageType,
      children: children,
    );
  }

  const ResolvedRoute({
    required this.path,
    required this.namePostfix,
    required this.pageType,
    required this.children,
  });
}

class RouteGenerator extends GeneratorForAnnotation<AppRoutes> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // Cast the Element instance to VariableElement
    final variableElement = element as VariableElement;
    final name = variableElement.name;

    final routesList = variableElement
        .computeConstantValue()
        ?.toListValue()
        ?.namedArgumentsList;

    final resolvedRoutes = resolveRoutes(routesList ?? []);

    final expandedRoutes = expandRoutes(resolvedRoutes);

    final routes = expandedRoutes.map((listItem) {
      final pageType = listItem.pageType;
      if (pageType == null) return null;
      final name = pageType.getDisplayString(withNullability: false);
      final constructorParams = ((pageType.element as ClassElement)
                  .constructors
                  .firstOrNull
                  ?.parameters ??
              [])
          .where(
            (param) => !param.isSuperFormal,
          )
          .toList();

      final List<(String, String, String?)> args = [];
      for (final param in constructorParams) {
        if (param.isRequired) {
          throw Exception(
              "No Required Parameters Allowed. Either make it optional or provide a default value");
        }
        final type = param.type.getDisplayString(withNullability: true);
        final name = param.name;
        final defaultValue = param.defaultValueCode;

        args.add((type, name, defaultValue));
      }

      return (name, listItem.namePostfix, listItem.path, args);
    }).whereType<(String, String, String, List<(String, String, String?)>)>();

    final buffer = StringBuffer();

    ///
    /// AppRouter
    ///
    buffer.writeln("class AppRouter extends NomoAppRouter {");

    buffer.writeln("AppRouter() : super(");
    buffer.writeln("{");
    for (final route in routes) {
      final name = "${route.$1}${route.$2}";

      if (route.$4.isEmpty)
        buffer.writeln("${name}Route.path: ([a]) => ${name}Route(),");
      else {
        buffer.writeln("${name}Route.path: ([a]) {");
        buffer.writeln("final typedArgs = a as ${name}Arguments?;");
        buffer.writeln("return ${name}Route(");
        for (final field in route.$4) {
          if (field.$3 != null)
            buffer.write("${field.$2}: typedArgs?.${field.$2} ?? ${field.$3},");
          else
            buffer.writeln("${field.$2}: typedArgs?.${field.$2},");
        }
        buffer.writeln(");");
        buffer.writeln("},");
      }
    }
    buffer.writeln("},");
    buffer.writeln(
        "${name}.expanded.where((r) => r is! NestedPageRouteInfo).toList(),");
    buffer
        .writeln("${name}.expanded.whereType<NestedPageRouteInfo>().toList(),");
    buffer.writeln(");");

    buffer.writeln("}");

    ///
    /// Routes
    ///
    for (final route in routes) {
      genRoute(route, buffer);
    }

    return buffer.toString();
  }

  ///
  /// void expanded Routes
  ///
  void genRoute(
    (String, String, String, List<(String, String, String?)>) route,
    StringBuffer buffer,
  ) {
    final (name, postFix, path, args) = route;

    final nameWithPostFix = "${name}${postFix}";

    /// Args
    buffer.writeln("class ${nameWithPostFix}Arguments {");

    for (final field in args) {
      buffer.writeln("final ${field.$1} ${field.$2};");
    }

    // Constructor

    buffer.writeln("const ${nameWithPostFix}Arguments(");
    if (args.isNotEmpty) buffer.writeln("{");
    for (final field in args) {
      if (field.$3 != null) {
        buffer.write("required ");
      }
      buffer.writeln("this.${field.$2},");
    }
    if (args.isNotEmpty) buffer.writeln("}");
    buffer.writeln(");");

    buffer.writeln("}");

    /// Route

    buffer.writeln(
        "class ${nameWithPostFix}Route extends AppRoute implements ${nameWithPostFix}Arguments {");
    for (final field in args) {
      buffer.writeln("@override");
      buffer.writeln("final ${field.$1} ${field.$2};");
    }

    buffer.writeln("${nameWithPostFix}Route(");
    if (args.isNotEmpty) buffer.writeln("{");
    for (final field in args) {
      if (field.$3 != null)
        buffer.write("this.${field.$2} = ${field.$3}, ");
      else
        buffer.writeln("this.${field.$2},");
    }
    if (args.isNotEmpty) buffer.writeln("}");
    buffer.writeln(")");
    buffer.writeln(": super(");
    buffer.writeln("name: '$path',");
    buffer.writeln("page: ${name}(");
    for (final field in args) {
      buffer.writeln("${field.$2}: ${field.$2},");
    }
    buffer.writeln("),");
    buffer.writeln(");");

    // static name
    buffer.writeln("static String path = '$path';");

    buffer.writeln("}");
  }
}

///
/// Utils
///

extension on List<DartObject> {
  List<Map<String, DartObject>> get namedArgumentsList {
    return map((e) => ConstantReader(e).revive().namedArguments).toList();
  }
}

List<ResolvedRoute> expandChildren(ResolvedRoute route) {
  if (route.children.isEmpty) {
    return [route];
  }

  final recursedChildren = route.children
      .map(
        (r) {
          return expandChildren(r.prependPath(route.path));
        },
      )
      .expand((e) => e)
      .toList();

  return [
    route,
    ...recursedChildren,
  ];
}

List<ResolvedRoute> expandRoutes(List<ResolvedRoute> routes) {
  return [
    for (final route in routes) ...expandChildren(route),
  ];
}

List<ResolvedRoute> resolveRoutes(List<Route> routes) {
  return routes.map((e) => resolveRoute(e)).toList();
}

ResolvedRoute resolveRoute(Route route) {
  final path = route["path"]?.toStringValue() ?? "/";
  final namePostfix = route["routePostfix"]?.toStringValue() ?? "";
  final pageType = route["page"]?.toTypeValue() as ParameterizedType?;

  final children = route["children"]
      ?.toListValue()
      ?.namedArgumentsList
      .map((e) => resolveRoute(e))
      .toList();

  return ResolvedRoute(
    path: path,
    namePostfix: namePostfix,
    pageType: pageType,
    children: children ?? [],
  );
}
