import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/features/auth/presentation/providers/auth_providers.dart';
import 'package:bumditbul_mobile/core/features/main/presentation/providers/study_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final examDate = ref.watch(examDateProvider);
    final achievement = ref.watch(todayAchievementProvider);
    final streak = ref.watch(studyStreakProvider);
    final dDay = examDate?.difference(DateTime.now()).inDays;

    final dDayText = dDay == null
        ? 'D-?'
        : dDay == 0
        ? 'D-Day'
        : dDay > 0
        ? 'D-$dDay'
        : 'D+${dDay.abs()}';

    final achievePct = achievement.total == 0
        ? 0.0
        : achievement.completed / achievement.total;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: BumditbulColor.black700,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BumditbulColor.black600,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: BumditbulColor.black500,
                              size: 52,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user?.nickname ?? '사용자',
                            style: BumditbulTextStyle.headline4.copyWith(
                              color: BumditbulColor.white,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user?.nickname ?? 'user'}',
                            style: BumditbulTextStyle.bodyMedium2.copyWith(
                              color: BumditbulColor.black500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: '시험까지',
                                  child: Text(
                                    dDayText,
                                    style: BumditbulTextStyle.headline2
                                        .copyWith(
                                          color: BumditbulColor.green400,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  label: '달성률',
                                  trailing: Text(
                                    '${achievement.completed}/${achievement.total}',
                                    style: BumditbulTextStyle.bodyMedium2
                                        .copyWith(
                                          color: BumditbulColor.black500,
                                        ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${(achievePct * 100).toInt()}%',
                                        style: BumditbulTextStyle.headline2
                                            .copyWith(
                                              color: BumditbulColor.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: achievePct,
                                          backgroundColor:
                                              BumditbulColor.black700,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                BumditbulColor.green400,
                                              ),
                                          minHeight: 4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _StatCard(
                            label: '연속 학습',
                            child: Text(
                              '$streak일',
                              style: BumditbulTextStyle.headline2.copyWith(
                                color: BumditbulColor.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BumditbulColor.black850,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '아직 예정된 학습이 없어요.\n한번 생성해볼까요?',
                        textAlign: TextAlign.center,
                        style: BumditbulTextStyle.bodyMedium1.copyWith(
                          color: BumditbulColor.black400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 140,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => context.push('/exam-scope'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BumditbulColor.green600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            '일정 생성하기',
                            style: BumditbulTextStyle.bodyMedium1.copyWith(
                              color: BumditbulColor.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _ActionButton(
                      label: '프로필 수정',
                      onTap: () => context.push('/profile-edit'),
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: '시험범위 수정',
                      onTap: () => context.push('/exam-scope'),
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: '과목별 성적 수정',
                      onTap: () => context.push('/subject-grade-edit'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(authStateProvider.notifier).logout();
                      context.go('/');
                    },
                    child: Text(
                      '로그아웃',
                      style: BumditbulTextStyle.bodyMedium1.copyWith(
                        color: BumditbulColor.black500,
                      ),
                    ),
                  ),
                  Text(
                    '  |  ',
                    style: BumditbulTextStyle.bodyMedium1.copyWith(
                      color: BumditbulColor.black700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showWithdrawalDialog(context, ref),
                    child: Text(
                      '회원탈퇴',
                      style: BumditbulTextStyle.bodyMedium1.copyWith(
                        color: BumditbulColor.black500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

void _showWithdrawalDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: BumditbulColor.black850,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: BumditbulColor.red,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              '회원탈퇴',
              style: BumditbulTextStyle.headline3.copyWith(
                color: BumditbulColor.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '탈퇴 시 모든 데이터가 영구적으로\n삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠어요?',
              textAlign: TextAlign.center,
              style: BumditbulTextStyle.bodyMedium1.copyWith(
                color: BumditbulColor.black400,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: BumditbulColor.black600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      '취소',
                      style: BumditbulTextStyle.bodyLarge1.copyWith(
                        color: BumditbulColor.black400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ref.read(authStateProvider.notifier).logout();
                      GoRouter.of(context).go('/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BumditbulColor.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      '탈퇴하기',
                      style: BumditbulTextStyle.bodyLarge1.copyWith(
                        color: BumditbulColor.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;

  const _StatCard({required this.label, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BumditbulColor.black850,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: BumditbulTextStyle.bodyMedium2.copyWith(
                  color: BumditbulColor.black500,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: BumditbulColor.black700, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: BumditbulTextStyle.bodyLarge2.copyWith(
                color: BumditbulColor.white,
              ),
            ),
            const Icon(
              Icons.edit_outlined,
              color: BumditbulColor.black500,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
