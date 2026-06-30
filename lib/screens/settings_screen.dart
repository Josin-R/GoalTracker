import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/language_provider.dart';
import '../services/goals_provider.dart';
import '../services/backup_service.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);

    final user = FirebaseAuth.instance.currentUser;
    final isConnected = user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('parametres', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profil
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: kAccent, radius: 22,
                child: Text(
                  isConnected ? (user.email?[0].toUpperCase() ?? 'U') : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    isConnected ? (user.email ?? 'Utilisateur') : AppStrings.get('utilisateur', lang),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isConnected
                        ? (lang == 'fr' ? 'Compte connecté ' : 'Account connected ')
                        : AppStrings.get('mode_local', lang),
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected ? kAccent.withValues(alpha: 0.1) : surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isConnected ? kAccent.withValues(alpha: 0.4) : border,
                  ),
                ),
                child: Text(
                  isConnected
                      ? (lang == 'fr' ? 'En ligne' : 'Online')
                      : AppStrings.get('hors_ligne', lang),
                  style: TextStyle(
                    fontSize: 10,
                    color: isConnected ? kAccent : muted,
                    fontWeight: isConnected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Cloud info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kAccent.withValues(alpha: 0.4)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.cloud_outlined, color: kAccent),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppStrings.get('sauvegarde_titre', lang),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(AppStrings.get('sauvegarde_desc', lang),
                    style: TextStyle(fontSize: 11, color: muted, height: 1.5)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          _SectionTitle(title: AppStrings.get('compte', lang), muted: muted),
          const SizedBox(height: 8),

          if (!isConnected)
            _PrefItem(
              icon: Icons.mail_outline_rounded,
              title: AppStrings.get('connecter_email', lang),
              subtitle: 'Gmail, Yahoo, Outlook…',
              onTap: () => _showEmailDialog(context, ref, lang),
            )
          else
            _PrefItem(
              icon: Icons.logout_rounded,
              title: lang == 'fr' ? 'Se déconnecter' : 'Sign out',
              subtitle: user.email ?? '',
              onTap: () => _showSignOutDialog(context, ref, lang),
            ),

          const SizedBox(height: 6),
          _PrefItem(
            icon: Icons.cloud_upload_outlined,
            title: AppStrings.get('sauvegarder', lang),
            subtitle: lang == 'fr' ? 'Envoyer mes données vers le cloud' : 'Send my data to the cloud',
            onTap: () => _handleBackup(context, lang, isConnected),
          ),
          const SizedBox(height: 6),
          _PrefItem(
            icon: Icons.cloud_download_outlined,
            title: AppStrings.get('restaurer', lang),
            subtitle: lang == 'fr' ? 'Récupérer depuis un ancien téléphone' : 'Recover from an old phone',
            onTap: () => _handleRestore(context, ref, lang, isConnected),
          ),
          const SizedBox(height: 20),

          _SectionTitle(title: AppStrings.get('preferences', lang), muted: muted),
          const SizedBox(height: 8),
          _PrefItem(
            icon: Icons.language_rounded,
            title: AppStrings.get('langue', lang),
            subtitle: lang == 'fr' ? '🇫🇷 Français' : '🇬🇧 English',
            onTap: () => _showLanguageDialog(context, ref, lang),
          ),
          const SizedBox(height: 20),

          _SectionTitle(title: AppStrings.get('informations', lang), muted: muted),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: muted, size: 20),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppStrings.get('a_propos', lang),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(AppStrings.get('version', lang),
                    style: TextStyle(fontSize: 10, color: muted)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  // ─── Backup / Restore ───────────────────────────────────────────────────
  Future<void> _handleBackup(BuildContext context, String lang, bool isConnected) async {
    if (!isConnected) {
      _showSnack(context, lang == 'fr' ? 'Connectez d\'abord un email' : 'Connect an email first');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await BackupService.backup();
      if (context.mounted) {
        Navigator.pop(context);
        _showSnack(context, lang == 'fr' ? ' Sauvegarde réussie !' : ' Backup successful!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showSnack(context, lang == 'fr'
            ? ' Erreur : vérifiez votre connexion internet'
            : ' Error: check your internet connection');
      }
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref, String lang, bool isConnected) async {
    if (!isConnected) {
      _showSnack(context, lang == 'fr' ? 'Connectez d\'abord un email' : 'Connect an email first');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'fr' ? 'Restaurer ?' : 'Restore?'),
        content: Text(lang == 'fr'
            ? 'Vos objectifs locaux actuels seront remplacés par ceux du cloud.'
            : 'Your current local goals will be replaced by the cloud ones.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(lang == 'fr' ? 'Annuler' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(lang == 'fr' ? 'Restaurer' : 'Restore', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final count = await BackupService.restore();
      if (context.mounted) {
        Navigator.pop(context);
        _showSnack(context, lang == 'fr' ? ' $count objectif(s) restauré(s) !' : ' $count goal(s) restored!');
        ref.invalidate(goalsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showSnack(context, lang == 'fr' ? ' Erreur de restauration' : ' Restore error');
      }
    }
  }

  // ─── Dialogue Email ───────────────────────────────────────────────────────
  void _showEmailDialog(BuildContext context, WidgetRef ref, String lang) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? emailError;
    String? passError;
    bool step2 = false;
    bool obscure = true;
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(step2
              ? (lang == 'fr' ? 'Mot de passe' : 'Password')
              : AppStrings.get('connecter_email', lang)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!step2) ...[
                Text(
                  lang == 'fr'
                      ? 'Entrez votre adresse email pour connecter votre compte.'
                      : 'Enter your email address to connect your account.',
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'nom@gmail.com',
                    prefixIcon: const Icon(Icons.mail_outline),
                    errorText: emailError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => emailError = null),
                ),
              ] else ...[
                Text(
                  lang == 'fr'
                      ? 'Email : ${emailCtrl.text}\n\nEntrez votre mot de passe.\nSi vous n\'avez pas de compte, il sera créé automatiquement.'
                      : 'Email: ${emailCtrl.text}\n\nEnter your password.\nIf you have no account, one will be created.',
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: obscure,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: lang == 'fr' ? 'Mot de passe' : 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: passError,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                  onChanged: (_) => setState(() => passError = null),
                ),
                if (loading) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ]),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () {
                if (step2) {
                  setState(() { step2 = false; passCtrl.clear(); passError = null; });
                } else {
                  Navigator.pop(ctx);
                }
              },
              child: Text(step2
                  ? (lang == 'fr' ? 'Retour' : 'Back')
                  : AppStrings.get('annuler', lang)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAccent),
              onPressed: loading ? null : () async {
                if (!step2) {
                  final email = emailCtrl.text.trim();
                  final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
                  if (email.isEmpty) {
                    setState(() => emailError = lang == 'fr' ? 'Entrez un email' : 'Enter an email');
                    return;
                  }
                  if (!emailRegex.hasMatch(email)) {
                    setState(() => emailError = lang == 'fr'
                        ? 'Format invalide (ex: nom@gmail.com)'
                        : 'Invalid format (e.g. name@gmail.com)');
                    return;
                  }
                  setState(() => step2 = true);
                } else {
                  if (passCtrl.text.isEmpty) {
                    setState(() => passError = lang == 'fr' ? 'Entrez un mot de passe' : 'Enter a password');
                    return;
                  }
                  if (passCtrl.text.length < 6) {
                    setState(() => passError = lang == 'fr' ? 'Minimum 6 caractères' : 'Minimum 6 characters');
                    return;
                  }

                  setState(() => loading = true);

                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text,
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(lang == 'fr' ? ' Connecté avec succès !' : ' Successfully connected!'),
                        backgroundColor: Colors.green,
                      ));
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
                      try {
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text,
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(lang == 'fr' ? '🎉 Compte créé et connecté !' : '🎉 Account created and connected!'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      } on FirebaseAuthException catch (e2) {
                        if (ctx.mounted) {
                          setState(() { loading = false; passError = e2.message; });
                        }
                      }
                    } else if (e.code == 'wrong-password') {
                      setState(() { loading = false; passError = lang == 'fr' ? 'Mot de passe incorrect' : 'Wrong password'; });
                    } else {
                      setState(() { loading = false; passError = e.message; });
                    }
                  }
                }
              },
              child: Text(
                step2 ? (lang == 'fr' ? 'Se connecter' : 'Log in') : (lang == 'fr' ? 'Suivant' : 'Next'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialogue Déconnexion ─────────────────────────────────────────────────
  void _showSignOutDialog(BuildContext context, WidgetRef ref, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'fr' ? 'Se déconnecter ?' : 'Sign out?'),
        content: Text(lang == 'fr'
            ? 'Vos données locales seront conservées.'
            : 'Your local data will be kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang == 'fr' ? 'Annuler' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(lang == 'fr' ? 'Déconnecté ✓' : 'Signed out ✓'),
                ));
              }
            },
            child: Text(lang == 'fr' ? 'Se déconnecter' : 'Sign out',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Dialogue Langue ──────────────────────────────────────────────────────
  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLang) {
    String selected = currentLang;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Langue / Language'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _LangOption(flag: '🇫🇷', label: 'Français', sublabel: 'French',
                selected: selected == 'fr', onTap: () => setState(() => selected = 'fr')),
            const SizedBox(height: 8),
            _LangOption(flag: '🇬🇧', label: 'English', sublabel: 'Anglais',
                selected: selected == 'en', onTap: () => setState(() => selected = 'en')),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler / Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAccent),
              onPressed: () {
                ref.read(languageProvider.notifier).state = selected;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(selected == 'fr' ? 'Langue : Français ✓' : 'Language: English ✓'),
                ));
              },
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ─── Widgets helpers ──────────────────────────────────────────────────────────

class _LangOption extends StatelessWidget {
  final String flag, label, sublabel;
  final bool selected;
  final VoidCallback onTap;
  const _LangOption({required this.flag, required this.label, required this.sublabel,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kAccent : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          color: selected ? kAccent.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? kAccent : null)),
            Text(sublabel, style: TextStyle(fontSize: 11, color: muted)),
          ]),
          const Spacer(),
          if (selected) const Icon(Icons.check_circle_rounded, color: kAccent, size: 20),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color muted;
  const _SectionTitle({required this.title, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Text(title.toUpperCase(),
        style: TextStyle(fontSize: 10, color: muted,
            fontWeight: FontWeight.w600, letterSpacing: 0.5));
  }
}

class _PrefItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _PrefItem({required this.icon, required this.title,
      required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardColor;
    final border = Theme.of(context).dividerColor;
    final muted = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF484F58) : const Color(0xFF8C959F);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(children: [
          Icon(icon, color: kAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(subtitle, style: TextStyle(fontSize: 10, color: muted)),
          ])),
          Icon(Icons.chevron_right_rounded, color: muted, size: 18),
        ]),
      ),
    );
  }
}