import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'gamifyhost_config.dart';
import 'html_template.dart';

/// Controller for the GamifyHost widget WebView.
///
/// Create this controller and pass it to [GamifyHostWidget] for programmatic
/// control over the widget (reload, navigate, execute JS, etc.).
class GamifyHostController {
  WebViewController? _webViewController;
  GamifyHostConfig? _config;

  /// Whether the WebView has finished its initial load.
  final ValueNotifier<bool> isReady = ValueNotifier(false);

  /// Bind the underlying WebViewController. Called internally by [GamifyHostWidget].
  void attach(WebViewController controller, GamifyHostConfig config) {
    _webViewController = controller;
    _config = config;
  }

  /// Reload the widget with the current configuration.
  Future<void> reload() async {
    if (_webViewController == null || _config == null) return;
    final html = buildWidgetHtml(_config!);
    await _webViewController!.loadHtmlString(html);
  }

  /// Reload the widget with a new configuration (e.g. after user login changes).
  Future<void> reloadWithConfig(GamifyHostConfig config) async {
    _config = config;
    if (_webViewController == null) return;
    final html = buildWidgetHtml(config);
    await _webViewController!.loadHtmlString(html);
  }

  /// Execute arbitrary JavaScript inside the widget WebView.
  Future<Object> runJavaScript(String js) async {
    if (_webViewController == null) {
      throw StateError('GamifyHostController is not attached to a WebView');
    }
    return _webViewController!.runJavaScriptReturningResult(js);
  }

  /// Dispose resources.
  void dispose() {
    isReady.dispose();
    _webViewController = null;
    _config = null;
  }
}
