import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/event_provider.dart';
import '../theme/app_colors.dart';

class AiInboxScreen extends StatefulWidget {
  final VoidCallback? onEventCreated;

  const AiInboxScreen({super.key, this.onEventCreated});

  @override
  State<AiInboxScreen> createState() => _AiInboxScreenState();
}

class _AiInboxScreenState extends State<AiInboxScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isExtracting = false;
  Event? _extractedEvent;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadSampleAnnouncement() {
    setState(() {
      _textController.text =
          '📢 CALL FOR MAKERS! Hardware Hack & IoT Showcase is happening on OCT 14, 2026 from 10:00 AM to 5:00 PM at MakerSpace Hall B. Free pizza, microcontrollers provided. Register by OCT 10!';
    });
  }

  Future<void> _extractDetails() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or paste an announcement first.'),
        ),
      );
      return;
    }

    setState(() {
      _isExtracting = true;
      _extractedEvent = null;
    });

    // Simulate AI extraction response
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isExtracting = false;
      _extractedEvent = Event(
        id: 'ai-evt-${DateTime.now().millisecondsSinceEpoch}',
        eventName: 'Hardware Hack & IoT Showcase',
        description: text,
        date: DateTime(2026, 10, 14, 10, 0),
        time: '10:00 AM - 5:00 PM',
        venue: 'MakerSpace Hall B',
        categories: ['Hardware', 'IoT', 'Hackathon'],
        registrationDeadline: DateTime(2026, 10, 10, 23, 59),
        registrationUrl: 'https://makerspace.campus.edu/iot-showcase',
        organizer: 'Campus Robotics & IoT Club',
      );
    });
  }

  void _saveExtractedEvent() {
    if (_extractedEvent == null) return;

    context.read<EventProvider>().addEvent(_extractedEvent!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '🎉 Event successfully added to campus calendar and dashboard!',
        ),
        backgroundColor: AppColors.navyDark,
      ),
    );

    setState(() {
      _textController.clear();
      _extractedEvent = null;
    });

    widget.onEventCreated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyDark,
        elevation: 0,
        title: const Text(
          'AI Announcement Inbox',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Banner
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
                          'Intelligent Event Extractor',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purpleDarkText,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Paste Discord pings, WhatsApp flyers, or emails to auto-parse structured dates, locations, and tags.',
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

            // Input field label & Sample trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Announcement Content',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _loadSampleAnnouncement,
                  child: const Text(
                    'Load Sample',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.purpleAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Text input area
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Paste announcement message, email body, or club flyer text here...',
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                ),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.purpleAccent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Extract Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isExtracting ? null : _extractDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: AppColors.greenBadge,
                      ),
                label: Text(
                  _isExtracting
                      ? 'Analyzing with AI...'
                      : 'Extract Event Details',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Extracted Result Card
            if (_extractedEvent != null) ...[
              const SizedBox(height: 24),
              const Text(
                'AI Extracted Event Preview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CONFIDENCE: 98%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.greenIndicator,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _extractedEvent!.formattedDate,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _extractedEvent!.eventName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _extractedEvent!.time,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _extractedEvent!.venue,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveExtractedEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text(
                          'Save to Campus Events',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
