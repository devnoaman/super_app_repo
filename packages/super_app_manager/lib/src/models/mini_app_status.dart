sealed class MiniAppStatus {
  const MiniAppStatus();
}

//   loading,
//   verifying,
//   verified,
//   unauthorized,
//   error,
class Loading extends MiniAppStatus {}

class Verifying extends MiniAppStatus {}

class Verified extends MiniAppStatus {}
enum UnauthorizedReason {
  apiKey,
  version,
}

class Unauthorized extends MiniAppStatus {
  final UnauthorizedReason reason;
  const Unauthorized(this.reason);
}

class Error extends MiniAppStatus {}
