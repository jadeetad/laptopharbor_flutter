import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/shared_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _messageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavBar(currentRoute: '/support'),
      body: SingleChildScrollView(
        child: Column(children: [
          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppColors.ink,
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Support', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
              SizedBox(height: 6),
              Text('How can we\nhelp you?', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.1)),
              SizedBox(height: 8),
              Text('Our tech experts are ready to assist you.', style: TextStyle(color: Colors.white54, fontSize: 14)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Quick options
              Row(children: [
                Expanded(child: _SupportCard(Icons.chat_bubble_outline, 'Live Chat', 'Instant help from a tech expert')),
                const SizedBox(width: 12),
                Expanded(child: _SupportCard(Icons.email_outlined, 'Email Us', 'Response within 24 hours')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _SupportCard(Icons.phone_outlined, 'Call Us', '+1 (800) 555-HARBOR')),
                const SizedBox(width: 12),
                Expanded(child: _SupportCard(Icons.quiz_outlined, 'FAQ', 'Quick answers to common questions')),
              ]),
              const SizedBox(height: 28),

              // Contact form
              if (_sent)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Column(children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
                    SizedBox(height: 12),
                    Text('Message sent!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    SizedBox(height: 6),
                    Text("We'll get back to you within 24 hours.",
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
                  ]),
                )
              else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Send us a message', style: Theme.of(context).textTheme.headlineSmall),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                      decoration: const InputDecoration(hintText: 'Your name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                      decoration: const InputDecoration(hintText: 'Email address'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageCtrl,
                      maxLines: 4,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                      decoration: const InputDecoration(hintText: 'How can we help?', alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) setState(() => _sent = true);
                        },
                        child: const Text('Send Message'),
                      ),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
          const AppFooter(),
        ]),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _SupportCard(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 22, color: AppColors.accent),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), maxLines: 2),
    ]),
  );
}
