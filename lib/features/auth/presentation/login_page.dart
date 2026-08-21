import 'package:flutter/material.dart';

import '../../../app/auth_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Écran de connexion (M2).
///
/// Basé sur la maquette Figma (header blanc + panneau rose), amélioré :
/// logo réel, contraste corrigé (labels/sous-titre en blanc, CTA navy au lieu
/// de rose-sur-rose), champs en pilule, états loading/erreur/validation,
/// anti double-submit. Cf. `docs/design/login.md`.
///
/// L'appel réseau réel et la gestion d'erreurs par `code` API arrivent en M2 ;
/// ici la soumission est simulée puis redirige vers l'app shell.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthScope.of(context, listen: false);
    final loc = AppLocalizations.of(context);

    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;

    // En cas de succès, AuthGate bascule automatiquement vers l'app shell ;
    // sinon on affiche le message dérivé du `code` d'erreur.
    setState(() {
      _loading = false;
      _error = ok
          ? null
          : loc.errorMessage(auth.errorCode ?? ApiCodes.internalError);
    });
  }

  String? _validateEmail(String? value) {
    final loc = AppLocalizations.of(context);
    final email = value?.trim() ?? '';
    if (email.isEmpty) return loc.loginEmailRequired;
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : loc.loginEmailInvalid;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return AppLocalizations.of(context).loginPasswordRequired;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral0,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: const _BrandHeader(),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.pink600,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(key: _formKey, child: _buildForm(loc)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppLocalizations loc) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          loc.loginTitle,
          style: text.headlineSmall?.copyWith(color: AppColors.navy900),
        ),
        const SizedBox(height: 8),
        Text(
          loc.loginSubtitle,
          style: text.bodyMedium?.copyWith(color: AppColors.neutral0),
        ),
        const SizedBox(height: 24),
        _FieldLabel(loc.loginEmailLabel),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('login_email'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_loading,
          autocorrect: false,
          decoration: _pillDecoration(
            hint: loc.loginEmailHint,
            icon: Icons.mail_outline,
          ),
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        _FieldLabel(loc.loginPasswordLabel),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('login_password'),
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: !_loading,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: _pillDecoration(
            hint: loc.loginPasswordHint,
            icon: Icons.lock_outline,
            suffix: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.muted,
              ),
              tooltip: _obscurePassword
                  ? loc.loginShowPassword
                  : loc.loginHidePassword,
            ),
          ),
          validator: _validatePassword,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _InlineError(message: _error!),
        ],
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            key: const Key('login_submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy900,
              foregroundColor: AppColors.neutral0,
              shape: const StadiumBorder(),
            ),
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.neutral0,
                    ),
                  )
                : Text(loc.loginSubmit),
          ),
        ),
      ],
    );
  }

  InputDecoration _pillDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    const pill = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      filled: true,
      fillColor: AppColors.neutral0,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIcon: Icon(icon, color: AppColors.navy900),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: pill,
      enabledBorder: pill,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(color: AppColors.navy900, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(
        color: AppColors.neutral0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: [
        Image.asset(
          'assets/images/sup2i_logo.png',
          height: 120,
          width: 120,
          errorBuilder: (context, error, stack) => Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.navy900,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: AppColors.neutral0,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Reconnu par l\'État',
          style: text.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: AppColors.neutral0),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: text.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
