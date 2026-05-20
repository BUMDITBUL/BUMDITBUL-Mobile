import 'dart:ui';

import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/button/difficulty_dropdown.dart';
import 'package:bumditbul_mobile/core/components/button/default_button.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/providers/study_provider.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/widgets/exam_date_picker_sheet.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/widgets/month_calendar.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/widgets/study_subject_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bumditbul_mobile/constants/app_icons.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final subjects = ref.watch(studyProvider).getSubjectsForDate(selectedDate);
    final examDate = ref.watch(examDateProvider);
    final authState = ref.watch(authStateProvider);

    final dDay = examDate?.difference(DateTime.now()).inDays;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BumditbulColor.green800.withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BumditbulColor.green600.withValues(alpha: 0.15),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(
                  context,
                  ref,
                  authState.user?.nickname,
                  authState.user?.profileImageUrl,
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildGlassDDayBanner(context, ref, dDay, examDate),
                            const SizedBox(height: 20),
                            const MonthCalendar(),
                            const SizedBox(height: 24),
                            _buildStudySection(
                              context,
                              ref,
                              selectedDate,
                              subjects,
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    String? nickname,
    String? profileImageUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TODO: 더미 데이터 버튼 — 확인 후 제거
          GestureDetector(
            onTap: () => ref.read(dailyPlanProvider.notifier).loadDummy(),
            child: Image.asset('assets/images/header_logo.png', height: 36),
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Row(
              children: [
                if (nickname != null && nickname.isNotEmpty) ...[
                  Text(
                    nickname,
                    style: BumditbulTextStyle.bodyMedium1.copyWith(
                      color: BumditbulColor.black400,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: BumditbulColor.black850,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: BumditbulColor.black700,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: profileImageUrl != null
                      ? Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Iconify(
                            Ic.round_person,
                            color: BumditbulColor.black400,
                          ),
                        )
                      : const Iconify(
                          Ic.round_person,
                          color: BumditbulColor.black400,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDDayBanner(
    BuildContext context,
    WidgetRef ref,
    int? dDay,
    DateTime? examDate,
  ) {
    final dDayText = dDay == null
        ? 'D-?'
        : dDay == 0
        ? 'D-Day'
        : dDay > 0
        ? 'D-$dDay'
        : 'D+${dDay.abs()}';

    return GestureDetector(
      onTap: () => _showExamDatePicker(context, ref, examDate),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BumditbulColor.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: BumditbulColor.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시험까지',
                          style: BumditbulTextStyle.bodyMedium1.copyWith(
                            color: BumditbulColor.black400,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dDayText,
                          style: BumditbulTextStyle.headline2.copyWith(
                            color: BumditbulColor.green400,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '무엇을 할지 고민하는 시간,\n이제는 공부에만 쓰세요.',
                          style: BumditbulTextStyle.bodyMedium1.copyWith(
                            color: BumditbulColor.black500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BumditbulColor.green600.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Iconify(
                          Ic.round_edit_calendar,
                          color: BumditbulColor.green400,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (examDate != null)
                        Text(
                          '${examDate.year}.${examDate.month.toString().padLeft(2, '0')}.${examDate.day.toString().padLeft(2, '0')}',
                          style: BumditbulTextStyle.bodyMedium2.copyWith(
                            color: BumditbulColor.black500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudySection(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    List subjects,
  ) {
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(selectedDate, today);
    final dateLabel = isToday
        ? '오늘 할 공부'
        : '${selectedDate.month}월 ${selectedDate.day}일 공부';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: BumditbulTextStyle.headline3.copyWith(
                  color: BumditbulColor.white,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddSubjectModal(context, ref, selectedDate),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      color: BumditbulColor.green400,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '과목 추가',
                      style: BumditbulTextStyle.bodyMedium1.copyWith(
                        color: BumditbulColor.green400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (subjects.isEmpty)
            _buildEmptyState(context, ref, selectedDate)
          else
            ...subjects.map(
              (subject) =>
                  StudySubjectCard(subject: subject, date: selectedDate),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    return GestureDetector(
      onTap: () => _showAddSubjectModal(context, ref, selectedDate),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: BumditbulColor.black850,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BumditbulColor.black700),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: BumditbulColor.black600,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              '공부할 과목을 추가해보세요!',
              style: BumditbulTextStyle.bodyLarge1.copyWith(
                color: BumditbulColor.black500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubjectModal(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BumditbulColor.black850,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddSubjectSheet(
        onConfirm: (name, difficulty) {
          ref
              .read(studyProvider.notifier)
              .addSubject(date, name, difficulty: difficulty);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _showExamDatePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime? current,
  ) async {
    final picked = await showExamDatePickerSheet(context, initialDate: current);
    if (picked != null) {
      setExamDateOverride(ref, picked);
    }
  }
}

class _AddSubjectSheet extends StatefulWidget {
  final void Function(String name, String difficulty) onConfirm;

  const _AddSubjectSheet({required this.onConfirm});

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  final _nameCtrl = TextEditingController();
  String _difficulty = '중';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _nameCtrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BumditbulColor.black600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '과목 추가',
                  style: BumditbulTextStyle.headline2.copyWith(
                    color: BumditbulColor.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BumditbulColor.black850,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: BumditbulColor.black600,
                            width: 0.5,
                          ),
                        ),
                        child: TextField(
                          controller: _nameCtrl,
                          autofocus: true,
                          onChanged: (_) => setState(() {}),
                          style: BumditbulTextStyle.bodyLarge2.copyWith(
                            color: BumditbulColor.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '과목명 (예: 수학)',
                            hintStyle: BumditbulTextStyle.bodyLarge2.copyWith(
                              color: BumditbulColor.black600,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: BumditbulColor.green400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DifficultyDropdown(
                      value: _difficulty,
                      width: 80,
                      onChanged: (v) => setState(() => _difficulty = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DefaultButton(
                  onPressed: isValid
                      ? () =>
                            widget.onConfirm(_nameCtrl.text.trim(), _difficulty)
                      : null,
                  child: Text(
                    '추가',
                    style: BumditbulTextStyle.bodyLarge1.copyWith(
                      color: BumditbulColor.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
