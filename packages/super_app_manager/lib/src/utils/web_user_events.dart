import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebUserEvents {
  static final all = UnmodifiableListView<UserScript>([
    // used to stringify objects in console.log, console.debug, console.info
    UserScript(
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      source: """
          // Save the original console functions
          const originalLog = console.log;
          const originalDebug = console.debug; // dart.developer.log often uses this
          const originalInfo = console.info;
  
          // Function to safely stringify objects
          function parseArgs(args) {
            return Array.from(args).map(arg => {
              if (typeof arg === 'object' && arg !== null) {
                try {
                  return JSON.stringify(arg, null, 2); // The '2' makes it pretty-printed
                } catch (e) {
                  return '[Un-stringifiable Object]';
                }
              }
              return arg;
            });
          }
  
          // Override the console functions
          console.log = function() {
            originalLog.apply(console, parseArgs(arguments));
          };
          console.debug = function() {
            originalDebug.apply(console, parseArgs(arguments));
          };
          console.info = function() {
            originalInfo.apply(console, parseArgs(arguments));
          };
        """,
    ),

    // used to send scroll events to flutter
    UserScript(
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      source: """
    (() => {
        let _lastY = 0, _lastX = 0;

        // ── Touch (mobile) ──────────────────────────────────────────────
        window.addEventListener('touchstart', (e) => {
          _lastY = e.touches[0].clientY;
          _lastX = e.touches[0].clientX;
        }, { passive: true, capture: true });

        window.addEventListener('touchmove', (e) => {
          const dy = _lastY - e.touches[0].clientY;
          const dx = _lastX - e.touches[0].clientX;
          _lastY = e.touches[0].clientY;
          _lastX = e.touches[0].clientX;
          window.flutter_inappwebview.callHandler('onScroll', {
            deltaY: dy, deltaX: dx,
          });
        }, { passive: true, capture: true });

        // ── Mouse wheel / trackpad (simulator / desktop) ─────────────────
        window.addEventListener('wheel', (e) => {
          window.flutter_inappwebview.callHandler('onScroll', {
            deltaY: e.deltaY, deltaX: e.deltaX,
          });
        }, { passive: true, capture: true });
      })();
  """,
    ),
  ]);
}
