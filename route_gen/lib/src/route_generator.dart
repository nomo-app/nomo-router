import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:collection/collection.dart';
import 'package:route_gen/annotations.dart';
import 'package:source_gen/source_gen.dart';

typedef Route = Map<String, DartObject>;

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

    final expandedRoutes = expandRoutes(routesList ?? []);

    final routes = expandedRoutes.map((listItem) {
      final path = listItem["name"]?.toStringValue() ?? "";

      final pageType = listItem["page"]?.toTypeValue() as ParameterizedType;
      final classElement = pageType.element as ClassElement;
      final args = [
        for (final field in classElement.fields)
          (field.type.getDisplayString(withNullability: true), field.name)
      ];
      final constructor = classElement.constructors.first;
      final defaultValues = constructor.parameters.map((constructorPar) {
        if (constructorPar.hasDefaultValue) {
          return constructorPar.defaultValueCode;
        }
        if (constructorPar.isRequired) {
          throw Exception(
            "No Required Parameters Allowed. Either make it optional or provide a default value",
          );
        }
        return null;
      }).toList();
      final argsWithValues = args
          .mapIndexed((index, args) => (args.$1, args.$2, defaultValues[index]))
          .toList();

      return (
        pageType.getDisplayString(withNullability: false),
        path,
        argsWithValues
      );
    });

    final buffer = StringBuffer();

    ///
    /// AppRouter
    ///
    buffer.writeln("class AppRouter extends NomoAppRouter {");

    buffer.writeln("AppRouter() : super(");
    buffer.writeln("{");
    for (final route in routes) {
      if (route.$3.isEmpty)
        buffer.writeln("'${route.$2}': ([a]) => ${route.$1}Route(),");
      else {
        buffer.writeln("'${route.$2}': ([a]) {");
        buffer.writeln("final typedArgs = a as ${route.$1}Arguments?;");
        buffer.writeln("return ${route.$1}Route(");
        for (final field in route.$3) {
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
    buffer.writeln("${name}.expanded.toList(),");
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
    (String, String, List<(String, String, String?)>) route,
    StringBuffer buffer,
  ) {
    final (name, path, args) = route;

    /// Args
    buffer.writeln("class ${name}Arguments {");

    for (final field in args) {
      buffer.writeln("final ${field.$1} ${field.$2};");
    }

    // Constructor

    buffer.writeln("const ${name}Arguments(");
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
        "class ${name}Route extends AppRoute implements ${name}Arguments {");
    for (final field in args) {
      buffer.writeln("@override");
      buffer.writeln("final ${field.$1} ${field.$2};");
    }

    buffer.writeln("${name}Route(");
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

List<Route> expandChildren(Route route) {
  final children = route["children"]?.toListValue()?.namedArgumentsList;

  if (children == null) {
    return [route];
  }

  final recursedChildren =
      children.map(expandChildren).expand((e) => e).toList();

  return [
    route,
    ...recursedChildren,
  ];
}

List<Route> expandRoutes(List<Route> routes) {
  return [
    for (final route in routes) ...expandChildren(route),
  ];
}
