import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'gamifyhost_config.dart';
import 'gamifyhost_controller.dart';
import 'html_template.dart';

/// A Flutter widget that embeds the GamifyHost game experience via WebView.
///
/// ```dart
/// GamifyHostWidget(
///   config: GamifyHostConfig(
///     publicKey: 'pk_live_abc123',
///     userId: 'user_12345',
///   ),
/// )
/// ```
class GamifyHostWidget extends StatefulWidget {
  /// Configuration for the GamifyHost widget.
  final GamifyHostConfig config;

  /// Optional controller for programmatic access (reload, JS execution, etc.).
  final GamifyHostController? controller;

  /// Called when the widget has finished loading.
  final VoidCallback? onReady;

  /// Called when the WebView encounters a loading error.
  final void Function(String error)? onError;

  /// Background color shown while the widget loads.
  final Color backgroundColor;

  /// Whether to show a loading indicator while the widget loads.
  final bool showLoadingIndicator;

  /// Loading indicator color. Defaults to the theme's primary color.
  final Color? loadingIndicatorColor;

  const GamifyHostWidget({
    super.key,
    required this.config,
    this.controller,
    this.onReady,
    this.onError,
    this.backgroundColor = const Color(0xFF1F1022),
    this.showLoadingIndicator = true,
    this.loadingIndicatorColor,
  });

  @override
  State<GamifyHostWidget> createState() => _GamifyHostWidgetState();
}

class _GamifyHostWidgetState extends State<GamifyHostWidget> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            widget.controller?.isReady.value = true;
            widget.onReady?.call();
          },
          onWebResourceError: (error) {
            widget.onError?.call(error.description);
          },
          onNavigationRequest: (request) {
            // Allow data URIs and the API domain; block external navigation
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            // Always allow about:blank and data URIs (used by loadHtmlString)
            if (uri.scheme == 'about' || uri.scheme == 'data') {
              return NavigationDecision.navigate;
            }

            // Allow API calls and widget CDN
            final apiHost = Uri.tryParse(widget.config.apiUrl)?.host ?? '';
            final widgetHost = Uri.tryParse(widget.config.widgetUrl)?.host ?? '';
            final allowedHosts = {
              apiHost,
              widgetHost,
              'fonts.googleapis.com',
              'fonts.gstatic.com',
            };

            if (allowedHosts.contains(uri.host)) {
              return NavigationDecision.navigate;
            }

            return NavigationDecision.prevent;
          },
        ),
      );

    // Attach controller if provided
    widget.controller?.attach(_webViewController, widget.config);

    // Load the widget HTML
    final html = buildWidgetHtml(widget.config);
    _webViewController.loadHtmlString(html);
  }

  @override
  void didUpdateWidget(covariant GamifyHostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If config changed, reload the widget
    if (oldWidget.config.publicKey != widget.config.publicKey ||
        oldWidget.config.userId != widget.config.userId ||
        oldWidget.config.apiUrl != widget.config.apiUrl ||
        oldWidget.config.widgetUrl != widget.config.widgetUrl ||
        oldWidget.config.initialBalance != widget.config.initialBalance) {
      setState(() => _isLoading = true);
      widget.controller?.attach(_webViewController, widget.config);
      final html = buildWidgetHtml(widget.config);
      _webViewController.loadHtmlString(html);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading && widget.showLoadingIndicator)
            Center(
              child: CircularProgressIndicator(
                color: widget.loadingIndicatorColor ??
                    Theme.of(context).colorScheme.primary,
                strokeWidth: 2.5,
              ),
            ),
        ],
      ),
    );
  }
}
