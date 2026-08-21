/// Session authentifiée d'un étudiant.
///
/// ⚠️ Forme provisoire : aucun contrat OpenAPI n'est fourni. À aligner sur la
/// réponse réelle du backend quand elle sera disponible
/// (cf. `docs/api/MISSING_CONTRACTS.md`).
class AuthSession {
  const AuthSession({
    required this.token,
    required this.studentId,
    required this.displayName,
  });

  final String token;
  final String studentId;
  final String displayName;
}
