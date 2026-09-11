/// Basic content filtering for the live chat, per App Store Guideline 1.2.
///
/// This is intentionally a simple blocklist rather than a full profanity
/// library: it is the "method for filtering objectionable content" Apple
/// requires alongside reporting and blocking, not a complete moderation
/// system on its own.
class Moderation {
  Moderation._();

  static const List<String> _blockedTerms = [
    'fuck',
    'shit',
    'bitch',
    'asshole',
    'bastard',
    'slut',
    'whore',
    'rape',
    'nigger',
    'nigga',
    'faggot',
    'retard',
    'cunt',
  ];

  /// True if [text] contains a blocked term as a whole word (case-insensitive).
  static bool containsProhibitedContent(String text) {
    final normalized = text.toLowerCase();
    for (final term in _blockedTerms) {
      final pattern = RegExp(r'\b' + RegExp.escape(term) + r'\b');
      if (pattern.hasMatch(normalized)) return true;
    }
    return false;
  }
}
