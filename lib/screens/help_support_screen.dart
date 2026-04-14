import 'package:flutter/material.dart';
import 'package:shg_customer_app/utils/theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedIndex;

  static const List<Map<String, String>> _faqs = [
    {
      'category': 'Account',
      'question': 'How do I check my savings account balance?',
      'answer':
          'Go to the "Savings" tab from the bottom navigation bar. Your current account balance and all deposit transactions will be listed there. You can tap on any account for detailed information.',
    },
    {
      'category': 'Account',
      'question': 'How can I view my loan details?',
      'answer':
          'Navigate to the "Loans" tab. All your active loan accounts will be displayed. Tap on a loan card to see the full details including outstanding balance, EMI amount, and loan ID.',
    },
    {
      'category': 'Transactions',
      'question': 'Where can I see my transaction history?',
      'answer':
          'Tap the "History" tab in the bottom navigation. Transactions are organized into two sections — Savings Deposits and Loan Transactions — so you can easily track each type separately.',
    },
    {
      'category': 'Transactions',
      'question': 'Why is a transaction not showing in History?',
      'answer':
          'Transactions may take a few minutes to reflect after processing. Pull down to refresh the history screen. If the issue persists, please contact your SHG coordinator or Sakhi.',
    },
    {
      'category': 'Loans',
      'question': 'How do I view my loan repayment schedule?',
      'answer':
          'Go to the "Loans" tab → tap on a loan card → tap "View Repayment Schedule". This shows each installment with its due date, EMI amount, and payment status (Paid / Pending / Overdue).',
    },
    {
      'category': 'Loans',
      'question': 'What does "Loan Outstanding" mean?',
      'answer':
          '"Loan Outstanding" is the total amount you still owe on your loan, including principal and accrued interest. It gets updated automatically whenever a repayment is recorded.',
    },
    {
      'category': 'Loans',
      'question': 'My loan EMI is showing as Overdue. What should I do?',
      'answer':
          'An overdue EMI means the due date has passed without full payment. Please contact your group Sakhi or the nearest branch office immediately to make the payment and avoid additional charges.',
    },
    {
      'category': 'Profile',
      'question': 'How do I update my personal information?',
      'answer':
          'Currently, personal information updates must be done through your SHG coordinator or branch office. Please bring valid identity documents when visiting.',
    },
    {
      'category': 'Profile',
      'question': 'How do I log out of the app?',
      'answer':
          'Go to the "Profile" tab and scroll to the bottom. Tap the "Logout" button to securely sign out of your account.',
    },
    {
      'category': 'General',
      'question': 'Who do I contact for support?',
      'answer':
          'You can reach out to your group Sakhi (shown on the Home screen) or visit your nearest branch office. For technical issues with the app, contact your SHG coordinator.',
    },
    {
      'category': 'General',
      'question': 'Is my financial data safe in this app?',
      'answer':
          'Yes. All data is fetched securely from the Fineract banking platform using encrypted connections. Your login is protected by OTP authentication, and no sensitive data is stored on your device.',
    },
  ];

  // Group FAQs by category
  Map<String, List<Map<String, String>>> get _grouped {
    final map = <String, List<Map<String, String>>>{};
    for (final faq in _faqs) {
      map.putIfAbsent(faq['category']!, () => []).add(faq);
    }
    return map;
  }

  // Flat index for expansion tracking
  List<Map<String, String>> get _flatList => _faqs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Find answers to common questions below. Tap a question to expand the answer.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // FAQ List grouped by category
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Build category headers + items
                  final categories = _grouped.keys.toList();
                  int cursor = 0;
                  for (final cat in categories) {
                    // Category header
                    if (index == cursor) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 10, left: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    cursor++;

                    final items = _grouped[cat]!;
                    for (int i = 0; i < items.length; i++) {
                      if (index == cursor) {
                        final globalIndex = _flatList.indexOf(items[i]);
                        final isExpanded = _expandedIndex == globalIndex;
                        return _FaqCard(
                          question: items[i]['question']!,
                          answer: items[i]['answer']!,
                          isExpanded: isExpanded,
                          isLast: i == items.length - 1,
                          onTap: () {
                            setState(() {
                              _expandedIndex =
                                  isExpanded ? null : globalIndex;
                            });
                          },
                        );
                      }
                      cursor++;
                    }
                  }
                  return const SizedBox.shrink();
                },
                childCount: _grouped.keys.length +
                    _grouped.values.fold(0, (sum, list) => sum + list.length),
              ),
            ),
          ),

          // Contact Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.accent.withOpacity(0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.15), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.support_agent_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Still need help?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Contact your Sakhi or branch office',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  const _FaqCard({
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: isLast ? 16 : 8),
        decoration: BoxDecoration(
          color: isExpanded
              ? AppColors.primary.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.divider.withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isExpanded ? 0.04 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.remove_rounded
                          : Icons.add_rounded,
                      color: isExpanded ? Colors.white : AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isExpanded
                            ? AppColors.primary
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGray,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
