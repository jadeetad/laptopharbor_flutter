import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() { super.initState(); _loadProfile(); }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', auth.user!.id)
          .single();
      if (mounted) {
        setState(() {
          _profile = data;
          _firstNameCtrl.text = data['first_name'] ?? '';
          _lastNameCtrl.text  = data['last_name'] ?? '';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    setState(() => _saving = true);
    await _supabase.from('profiles').update({
      'first_name': _firstNameCtrl.text.trim(),
      'last_name':  _lastNameCtrl.text.trim(),
    }).eq('id', auth.user!.id);
    if (mounted) setState(() { _saving = false; _editing = false; });
  }

  @override
  void dispose() { _firstNameCtrl.dispose(); _lastNameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const AppNavBar(currentRoute: '/profile'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // Avatar
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (_profile?['first_name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_profile?['first_name'] ?? ''} ${_profile?['last_name'] ?? ''}'.trim().isEmpty
                      ? 'Your Account'
                      : '${_profile?['first_name'] ?? ''} ${_profile?['last_name'] ?? ''}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(auth.user?.email ?? '', style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 28),

                // Profile form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Personal info', style: Theme.of(context).textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () => setState(() => _editing = !_editing),
                        icon: Icon(_editing ? Icons.close : Icons.edit, size: 16),
                        label: Text(_editing ? 'Cancel' : 'Edit'),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (_editing) ...[
                      Row(children: [
                        Expanded(child: TextFormField(
                          controller: _firstNameCtrl,
                          decoration: const InputDecoration(hintText: 'First name'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(
                          controller: _lastNameCtrl,
                          decoration: const InputDecoration(hintText: 'Last name'),
                        )),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: ElevatedButton(
                        onPressed: _saving ? null : _saveProfile,
                        child: _saving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save changes'),
                      )),
                    ] else ...[
                      _ProfileField('First name', _profile?['first_name'] ?? '—'),
                      _ProfileField('Last name', _profile?['last_name'] ?? '—'),
                      _ProfileField('Email', auth.user?.email ?? '—'),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),

                // Quick links
                _QuickLink(Icons.shopping_bag_outlined, 'Order History', '/orders'),
                _QuickLink(Icons.favorite_border, 'Wishlist', '/wishlist'),
                _QuickLink(Icons.headset_mic_outlined, 'Support', '/support'),
                const SizedBox(height: 16),

                // Sign out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.signOut();
                      if (context.mounted) context.go('/');
                    },
                    icon: const Icon(Icons.logout, size: 18, color: Colors.red),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  ),
                ),
              ]),
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label, value;
  const _ProfileField(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]),
  );
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label, route;
  const _QuickLink(this.icon, this.label, this.route);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.go(route),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.ink),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      ]),
    ),
  );
}
