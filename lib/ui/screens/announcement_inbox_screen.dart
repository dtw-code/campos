import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/event_provider.dart';
import '../theme/app_colors.dart';

class AnnouncementInboxScreen extends StatefulWidget {
  final VoidCallback? onEventCreated;
  final VoidCallback? onBack;

  const AnnouncementInboxScreen({super.key, this.onEventCreated, this.onBack});

  @override
  State<AnnouncementInboxScreen> createState() =>
      _AnnouncementInboxScreenState();
}

class _AnnouncementInboxScreenState extends State<AnnouncementInboxScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isExtracting = false;
  Event? _extractedEvent;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadSampleAnnouncement() {
    setState(() {
      _textController.text =
          '🚀 ACM HackFest 2026! Join us for a 24-hour campus hackathon on Sep 22, 2026 from 9:00 AM to 5:00 PM at Student Activity Center 3rd Floor. Build cutting-edge web & AI apps. Food & swag provided! Register before Sep 19.';
    });
  }

  Future<void> _extractEventDetails() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please paste or type an announcement first.'),
          backgroundColor: AppColors.navyDark,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isExtracting = true;
      _extractedEvent = null;
    });

    // Simulate AI parsing latency
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _isExtracting = false;
      _extractedEvent = Event(
        id: 'ai-evt-${DateTime.now().millisecondsSinceEpoch}',
        eventName: 'ACM HackFest 2026',
        description: text,
        date: DateTime(2026, 9, 22, 9, 0),
        time: '09:00 AM - 5:00 PM',
        venue: 'Student Activity Center 3rd Floor',
        categories: ['Hackathon', 'Tech', 'AI'],
        registrationDeadline: DateTime(2026, 9, 19, 23, 59),
        registrationUrl: 'https://acm.campus.edu/hackfest-2026',
        isCalendarMarked: true,
        organizer: 'ACM Student Chapter',
      );
    });
  }

  void _saveExtractedEvent() {
    if (_extractedEvent == null) return;

    context.read<EventProvider>().addEvent(_extractedEvent!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.greenBadge,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Event extracted and marked on your calendar!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.navyDark,
        duration: Duration(seconds: 3),
      ),
    );

    setState(() {
      _textController.clear();
      _extractedEvent = null;
    });

    widget.onEventCreated?.call();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _textController.text.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: 'Back',
          onPressed: _handleBack,
        ),
        title: const Text(
          'Announcement Inbox',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_textController.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.clear_rounded,
                color: Colors.white70,
                size: 20,
              ),
              tooltip: 'Clear input',
              onPressed: () {
                _textController.clear();
                setState(() {
                  _extractedEvent = null;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guidance Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFAF5FF), Color(0xFFEDE9FE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.purpleBorder),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.purpleAccent,
                    size: 26,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI-Powered Event Extractor',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purpleDarkText,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Paste Discord pings, emails, or flyer text to automatically generate calendar dates, locations, and deadlines.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B21A8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Input Header & Sample Prompt trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Raw Announcement Text',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: _loadSampleAnnouncement,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.purpleBorder),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.content_paste_rounded,
                          size: 13,
                          color: AppColors.purpleDarkText,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Load Sample',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purpleDarkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Large Multi-line TextField with Character Counter
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _textController.text.isNotEmpty
                      ? AppColors.purpleAccent
                      : AppColors.cardBorder,
                  width: _textController.text.isNotEmpty ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 7,
                    minLines: 5,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          'Paste your announcement here... e.g., Join us for a tech workshop on AI on Oct 14 at 10 AM in Hall B...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                  // Bottom bar of input container showing live character count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.cardBorder,
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Supports unformatted text, Discord pings, and flyers',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$charCount characters',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: charCount > 0
                                ? AppColors.purpleAccent
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Primary Action Button: "+ Extract Event Details"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isExtracting ? null : _extractEventDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.navySurface,
                ),
                icon: _isExtracting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: AppColors.greenBadge,
                      ),
                label: Text(
                  _isExtracting
                      ? 'Extracting Event Details...'
                      : '+ Extract Event Details',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            // Extracted Event Preview Card
            if (_extractedEvent != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Extracted Result',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Ready to Add',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenIndicator,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.purpleBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purpleAccent.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _extractedEvent!.eventName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Event Details Badges
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.purpleAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _extractedEvent!.formattedDate,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.purpleAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _extractedEvent!.time,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.greenIndicator,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _extractedEvent!.venue,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Save Event Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveExtractedEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenIndicator,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Save to Campus Events & Calendar',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
