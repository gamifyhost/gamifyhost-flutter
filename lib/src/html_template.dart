import 'gamifyhost_config.dart';

/// Generates the HTML document that loads the GamifyHost widget inside a WebView.
String buildWidgetHtml(GamifyHostConfig config) {
  // Escape values for safe HTML attribute insertion
  final publicKey = _escapeAttr(config.publicKey);
  final userId = _escapeAttr(config.userId);
  final apiUrl = _escapeAttr(config.apiUrl);
  final widgetUrl = _escapeAttr(config.widgetUrl);
  final initialBalance = config.initialBalance;

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <title>GamifyHost</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      min-height: 100%;
      overflow-x: hidden;
      overflow-y: auto;
      background: transparent;
      -webkit-tap-highlight-color: transparent;
      -webkit-overflow-scrolling: touch;
    }
    #gamifyhost {
      width: 100%;
      min-height: 100%;
    }
  </style>
</head>
<body>
  <div id="gamifyhost"></div>
  <script
    src="$widgetUrl"
    data-public-key="$publicKey"
    data-user-id="$userId"
    data-api-url="$apiUrl"
    data-initial-balance="$initialBalance"
  ></script>
</body>
</html>
''';
}

/// Escapes a string for safe insertion into an HTML attribute.
String _escapeAttr(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
