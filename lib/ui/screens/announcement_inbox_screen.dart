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
  final TextEditingController _rawTextController = TextEditingController();

  // Form controllers for review & edit mode
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  bool _isExtracting = false;
  bool _hasExtracted = false;
  bool _isSaving = false;

  String _selectedCategory = 'Hackathon';
  late DateTime _eventDate;
  DateTime? _registrationDeadline;

  final List<String> _availableCategories = [
    'Hackathon',
    'Tech',
    'AI',
    'Workshop',
    'Career',
    'Design',
  ];

  @override
  void initState() {
    super.initState();
    _eventDate = DateTime(2026, 9, 22);
    _registrationDeadline = DateTime(2026, 9, 19);

    _rawTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _rawTextController.dispose();
    _titleController.dispose();
    _venueController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _loadSampleAnnouncement() {
    setState(() {
      _rawTextController.text =
          '🚀 ACM HackFest 2026! Join us for a 24-hour campus hackathon on Sep 22, 2026 from 9:00 AM to 5:00 PM at Student Activity Center 3rd Floor. Build cutting-edge web & AI apps. Food & swag provided! Register before Sep 19.';
    });
  }

  Future<void> _extractEventDetails() async {
    final text = _rawTextController.text.trim();
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
      _hasExtracted = false;
    });

    // Simulate AI parsing latency
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    // Pre-populate editable form fields from parsed text
    setState(() {
      _isExtracting = false;
      _hasExtracted = true;

      _titleController.text = 'ACM HackFest 2026';
      _venueController.text = 'Student Activity Center 3rd Floor';
      _timeController.text = '09:00 AM - 5:00 PM';
      _selectedCategory = 'Hackathon';
      _eventDate = DateTime(2026, 9, 22);
      _registrationDeadline = DateTime(2026, 9, 19);
    });
  }

  Future<void> _pickEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2028, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.navyDark,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _eventDate = picked;
        // Adjust registration deadline if it exceeds event date
        if (_registrationDeadline != null &&
            _registrationDeadline!.isAfter(_eventDate)) {
          _registrationDeadline = _eventDate.subtract(const Duration(days: 2));
        }
      });
    }
  }

  Future<void> _pickRegistrationDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _registrationDeadline ?? _eventDate.subtract(const Duration(days: 2)),
      firstDate: DateTime(2026, 1, 1),
      lastDate: _eventDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.purpleAccent,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _registrationDeadline = picked;
      });
    }
  }

  void _saveEvent() {
    if (_isSaving) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event title before saving.'),
          backgroundColor: AppColors.pinkIndicator,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newEvent = Event(
      id: 'ai-evt-${DateTime.now().millisecondsSinceEpoch}',
      eventName: title,
      description: _rawTextController.text.isNotEmpty
          ? _rawTextController.text
          : 'Extracted campus event',
      date: _eventDate,
      time: _timeController.text.isNotEmpty
          ? _timeController.text
          : '10:00 AM - 4:00 PM',
      venue: _venueController.text.isNotEmpty
          ? _venueController.text
          : 'Campus Student Center',
      categories: [_selectedCategory, 'Campus'],
      registrationDeadline: _registrationDeadline,
      isCalendarMarked: true,
      organizer: 'Campus Student Council',
    );

    context.read<EventProvider>().addEvent(newEvent);

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
                'Event saved successfully!',
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
      _rawTextController.clear();
      _titleController.clear();
      _venueController.clear();
      _timeController.clear();
      _hasExtracted = false;
      _isSaving = false;
    });

    if (widget.onEventCreated != null) {
      widget.onEventCreated!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _rawTextController.text.length;

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
          if (_rawTextController.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.clear_rounded,
                color: Colors.white70,
                size: 20,
              ),
              tooltip: 'Clear input',
              onPressed: () {
                _rawTextController.clear();
                setState(() {
                  _hasExtracted = false;
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
                const Expanded(
                  child: Text(
                    'Raw Announcement Text',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
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
                  color: _rawTextController.text.isNotEmpty
                      ? AppColors.purpleAccent
                      : AppColors.cardBorder,
                  width: _rawTextController.text.isNotEmpty ? 1.5 : 1,
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
                    controller: _rawTextController,
                    maxLines: 6,
                    minLines: 4,
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
                  // Bottom bar with character counter
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

            const SizedBox(height: 18),

            // Primary Extraction Button
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

            // EDITABLE EXTRACTED EVENT FORM CARD
            if (_hasExtracted) ...[
              const SizedBox(height: 28),

              // Form Header
              Row(
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.purpleAccent,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Review & Edit Event',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AI Parsed • Editable',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenIndicator,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Editable Form Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.purpleBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purpleAccent.withAlpha(20),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Event Title
                    const Text(
                      'Event Title',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter event title',
                        prefixIcon: const Icon(
                          Icons.title_rounded,
                          size: 18,
                          color: AppColors.purpleAccent,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.purpleAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Field 2: Category Selector (Pills)
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCategories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.purpleAccent
                                  : AppColors.purpleLight.withAlpha(100),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.purpleAccent
                                    : AppColors.purpleBorder,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.purpleDarkText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Field 3 & 4: Event Date & Registration Deadline Pickers
                    Row(
                      children: [
                        // Event Date Picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Event Date',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _pickEventDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 16,
                                        color: AppColors.purpleAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _formatDate(_eventDate),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Registration Deadline Picker
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registration Deadline',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: _pickRegistrationDeadline,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.alarm_rounded,
                                        size: 16,
                                        color: AppColors.pinkIndicator,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _registrationDeadline != null
                                              ? _formatDate(
                                                  _registrationDeadline!,
                                                )
                                              : 'None set',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Venue & Time Fields Row
                    Row(
                      children: [
                        // Venue
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Venue',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _venueController,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Venue location',
                                  prefixIcon: const Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: AppColors.greenIndicator,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.purpleAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _timeController,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 10 AM - 4 PM',
                                  prefixIcon: const Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: AppColors.purpleAccent,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.cardBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.purpleAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Primary Full-width "Save Event" Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: AppColors.navySurface,
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.greenBadge,
                              ),
                        label: Text(
                          _isSaving ? 'Saving Event...' : 'Save Event',
                          style: const TextStyle(
                            fontSize: 15,
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
