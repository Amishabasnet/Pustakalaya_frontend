import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pustakalaya/core/constants/app_colors.dart';
import 'package:pustakalaya/core/router/app_router.dart';


class TrackOrderScreen extends StatelessWidget {
  final String orderId;
  final double total;
  final String paymentMethod;
  final String bookTitle;
  final String bookAuthor;
  final String bookColor;
  final String placedDate;

  const TrackOrderScreen({
    super.key,
    required this.orderId,
    required this.total,
    required this.paymentMethod,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookColor,
    required this.placedDate,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final hPad = screenW > 600 ? 40.0 : 20.0;

    final hexColor = bookColor.replaceFirst('#', '');
    final coverColor = Color(int.parse('FF$hexColor', radix: 16));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0EA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              child: Row(
                children: [
                  _BackBtn(onTap: () => Navigator.of(context).maybePop()),
                  Expanded(
                    child: Text(
                      'Track your order',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEE8E0)),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OUT FOR DELIVERY',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _OrderSummaryCard(
                      orderId: orderId,
                      total: total,
                      paymentMethod: paymentMethod,
                      bookTitle: bookTitle,
                      bookAuthor: bookAuthor,
                      coverColor: coverColor,
                      placedDate: placedDate,
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'LIVE TRACKING',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _TrackingTimeline(orderId: orderId),
                  ],
                ),
              ),
            ),

            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                hPad,
                12,
                hPad,
                mq.padding.bottom + 12,
              ),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRouter.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CLOSE',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final String orderId;
  final double total;
  final String paymentMethod;
  final String bookTitle;
  final String bookAuthor;
  final Color coverColor;
  final String placedDate;

  const _OrderSummaryCard({
    required this.orderId,
    required this.total,
    required this.paymentMethod,
    required this.bookTitle,
    required this.bookAuthor,
    required this.coverColor,
    required this.placedDate,
  });

  bool get _isDark =>
      (0.299 * coverColor.red +
              0.587 * coverColor.green +
              0.114 * coverColor.blue) /
          255 <
      0.55;

  @override
  Widget build(BuildContext context) {
    final textOnCover = _isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEE8E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(coverColor, Colors.white, 0.1)!,
                    coverColor,
                    Color.lerp(coverColor, Colors.black, 0.28)!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Container(width: 5, color: Colors.black.withValues(alpha: 0.2)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 5, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookTitle.toUpperCase(),
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: textOnCover,
                            height: 1.2,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          bookAuthor,
                          style: GoogleFonts.lato(
                            fontSize: 5.5,
                            color: textOnCover.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        bookTitle,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Out for delivery',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Order $orderId',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Placed $placedDate',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'NRs. ${total.toStringAsFixed(0)}',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '  •  $paymentMethod',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingTimeline extends StatefulWidget {
  final String orderId;
  const _TrackingTimeline({required this.orderId});

  @override
  State<_TrackingTimeline> createState() => _TrackingTimelineState();
}

class _TrackingTimelineState extends State<_TrackingTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;

  static const _steps = [
    _StepData(
      title: 'Order placed',
      descTemplate: 'Your order __ID__ is placed\nsuccessfully.',
    ),
    _StepData(
      title: 'Confirmed',
      descTemplate: 'Your order is confirmed. Will\ndeliver it soon.',
    ),
    _StepData(
      title: 'Processing',
      descTemplate: 'Your product is processing to\ndeliver you on time.',
    ),
    _StepData(
      title: 'Dispatched',
      descTemplate: 'Your order is on the way to your\nlocation.',
    ),
    _StepData(
      title: 'Delivered',
      descTemplate: 'Your order is delivered\nsuccessfully.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Stagger each step 180ms apart
    _anims = List.generate(_steps.length, (i) {
      final start = i * 0.18;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEE8E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final step = _steps[i];
          final isLast = i == _steps.length - 1;
          final desc = step.descTemplate.replaceAll('__ID__', widget.orderId);

          return _AnimatedStep(
            animation: _anims[i],
            title: step.title,
            description: desc,
            isLast: isLast,
          );
        }),
      ),
    );
  }
}

class _AnimatedStep extends AnimatedWidget {
  final String title;
  final String description;
  final bool isLast;

  const _AnimatedStep({
    required Animation<double> animation,
    required this.title,
    required this.description,
    required this.isLast,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final anim = listenable as Animation<double>;
    final v = anim.value;

    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - v)),
        child: _TrackingStep(
          title: title,
          description: description,
          isLast: isLast,
        ),
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String title;
  final String description;
  final bool isLast;

  const _TrackingStep({
    required this.title,
    required this.description,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Checkmark circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.textMedium,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String descTemplate;
  const _StepData({required this.title, required this.descTemplate});
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
