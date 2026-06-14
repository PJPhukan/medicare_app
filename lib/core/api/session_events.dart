import 'package:flutter/foundation.dart';

/// Decouples the HTTP layer from auth: the dio session interceptor fires
/// [onUnauthorized] on a 401, and the auth layer registers the handler.
/// Avoids a provider dependency cycle (dio ↔ auth).
class SessionEvents {
  SessionEvents._();
  static final SessionEvents instance = SessionEvents._();

  VoidCallback? onUnauthorized;
}
