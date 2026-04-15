class Env {
  // Base API URL for development and production
  // Supports build-time override: --dart-define=API_BASE=https://your-url.com
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://navachetana.co.in/backend/fineract-provider/api/v1',
  );

  // Allow self-signed/invalid TLS certs. OFF by default; enable only for
  // internal testing builds: --dart-define=ALLOW_BAD_CERTS=true
  static const allowBadCerts = bool.fromEnvironment(
    'ALLOW_BAD_CERTS',
    defaultValue: true, // ✅ Enabled for development
  );

  // Optional SHA1 fingerprint (hex, no colons) of the expected server cert.
  // If provided and allowBadCerts is true, the app will only accept certs
  // matching this fingerprint for the host in apiBase.
  // Example: --dart-define=CERT_SHA1=12ab34cd... (40 hex chars)
  static const certSha1 = String.fromEnvironment(
    'CERT_SHA1',
    defaultValue: '',
  );
}
