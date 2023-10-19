extension UriUtil on String? {
  Uri get uri {
    return Uri.parse(this ?? "");
  }

  Uri? get uriOrNull {
    return Uri.tryParse(this ?? "");
  }
}
