import 'dart:async';

import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:bumditbul_mobile/core/components/app_snack_bar.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:bumditbul_mobile/core/services/neis_service.dart';
import 'package:flutter/material.dart';

export 'package:bumditbul_mobile/core/services/neis_service.dart'
    show NeisSchool;

Future<NeisSchool?> showSchoolSearchSheet(BuildContext context) {
  return showModalBottomSheet<NeisSchool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BumditbulColor.black850,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _SchoolSearchSheet(),
  );
}

class _SchoolSearchSheet extends StatefulWidget {
  const _SchoolSearchSheet();

  @override
  State<_SchoolSearchSheet> createState() => _SchoolSearchSheetState();
}

enum _Step { search, grade }

class _SchoolSearchSheetState extends State<_SchoolSearchSheet> {
  final _controller = TextEditingController();
  List<NeisSchool> _results = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce;

  _Step _step = _Step.search;
  NeisSchool? _selectedSchool;
  int? _selectedGrade;
  bool _isFetchingSchedule = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final q = _controller.text.trim();
    if (q.length < 2) {
      setState(() {
        _results = [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final results = await NeisService.searchSchools(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
          _searchError = results.isEmpty ? '검색 결과가 없습니다.' : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchError = '검색 중 오류가 발생했습니다.';
        });
      }
    }
  }

  void _onSchoolSelected(NeisSchool school) {
    setState(() {
      _selectedSchool = school;
      _selectedGrade = null;
      _step = _Step.grade;
    });
  }

  Future<void> _onGradeConfirmed() async {
    final school = _selectedSchool;
    final grade = _selectedGrade;
    if (school == null || grade == null) return;

    setState(() => _isFetchingSchedule = true);
    try {
      final examDate = await NeisService.getNearestExamDate(
        school.officeCode,
        school.schoolCode,
        grade: grade,
      );
      if (!mounted) return;
      if (examDate == null) {
        showAppSnackBar(
          context,
          'NEIS에서 시험 날짜를 찾을 수 없어요. 홈 화면에서 직접 설정해주세요.',
          duration: const Duration(seconds: 4),
        );
      }
      Navigator.of(
        context,
      ).pop(school.copyWith(grade: grade, nearestExamDate: examDate));
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        '학사일정 조회에 실패했어요. 홈 화면에서 날짜를 직접 설정해주세요.',
        isError: true,
        duration: const Duration(seconds: 4),
      );
      Navigator.of(context).pop(school.copyWith(grade: grade));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _step == _Step.search ? _buildSearchStep() : _buildGradeStep(),
        ),
      ),
    );
  }

  Widget _buildSearchStep() {
    return Column(
      key: const ValueKey('search'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        const SizedBox(height: 16),
        _titleRow('학교 검색'),
        const SizedBox(height: 16),
        _searchField(),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          child: _buildResultsList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _controller,
        autofocus: true,
        style: BumditbulTextStyle.bodyLarge1.copyWith(
          color: BumditbulColor.white,
        ),
        decoration: InputDecoration(
          hintText: '학교명을 2자 이상 입력하세요.',
          hintStyle: BumditbulTextStyle.bodyLarge1.copyWith(
            color: BumditbulColor.black600,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: BumditbulColor.black500,
            size: 20,
          ),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BumditbulColor.green400,
                    ),
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: BumditbulColor.black600),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: BumditbulColor.green400),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: BumditbulColor.black850,
        ),
        cursorColor: BumditbulColor.green400,
      ),
    );
  }

  Widget _buildResultsList() {
    if (_controller.text.trim().length < 2) {
      return _placeholder('학교명을 2자 이상 입력하세요.');
    }
    if (_isSearching && _results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: BumditbulColor.green400),
        ),
      );
    }
    if (_searchError != null) return _placeholder(_searchError!);
    if (_results.isEmpty) return const SizedBox();

    final q = _controller.text.trim();
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: BumditbulColor.black700,
        indent: 20,
        endIndent: 20,
      ),
      itemBuilder: (_, idx) {
        final school = _results[idx];
        final start = school.name.indexOf(q);
        return ListTile(
          onTap: () => _onSchoolSelected(school),
          title: start >= 0
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: school.name.substring(0, start),
                        style: BumditbulTextStyle.bodyLarge2.copyWith(
                          color: BumditbulColor.white,
                        ),
                      ),
                      TextSpan(
                        text: school.name.substring(start, start + q.length),
                        style: BumditbulTextStyle.headline4.copyWith(
                          color: BumditbulColor.green400,
                        ),
                      ),
                      TextSpan(
                        text: school.name.substring(start + q.length),
                        style: BumditbulTextStyle.bodyLarge2.copyWith(
                          color: BumditbulColor.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  school.name,
                  style: BumditbulTextStyle.bodyLarge2.copyWith(
                    color: BumditbulColor.white,
                  ),
                ),
          subtitle: Text(
            '${school.location} · ${school.schoolType}',
            style: BumditbulTextStyle.bodyMedium2.copyWith(
              color: BumditbulColor.black500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: BumditbulColor.black600,
            size: 18,
          ),
        );
      },
    );
  }

  Widget _buildGradeStep() {
    return Column(
      key: const ValueKey('grade'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _handle(),
        const SizedBox(height: 16),
        _titleRow(
          '학년 선택',
          leading: GestureDetector(
            onTap: () => setState(() {
              _step = _Step.search;
              _selectedGrade = null;
            }),
            child: const Iconify(
              Ic.round_arrow_back_ios,
              color: BumditbulColor.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BumditbulColor.black800,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BumditbulColor.black700, width: 0.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedSchool?.name ?? '',
                    style: BumditbulTextStyle.bodyLarge2.copyWith(
                      color: BumditbulColor.white,
                    ),
                  ),
                ),
                Text(
                  '${_selectedSchool?.location ?? ''} · ${_selectedSchool?.schoolType ?? ''}',
                  style: BumditbulTextStyle.bodyMedium2.copyWith(
                    color: BumditbulColor.black500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '몇 학년인가요?',
            style: BumditbulTextStyle.bodyMedium1.copyWith(
              color: BumditbulColor.black400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [1, 2, 3].map((grade) {
              final isSelected = _selectedGrade == grade;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: grade < 3 ? 10 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGrade = grade),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BumditbulColor.green600.withValues(alpha: 0.15)
                            : BumditbulColor.black800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? BumditbulColor.green600
                              : BumditbulColor.black700,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$grade학년',
                            style: BumditbulTextStyle.headline4.copyWith(
                              color: isSelected
                                  ? BumditbulColor.green400
                                  : BumditbulColor.white,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedGrade != null && !_isFetchingSchedule)
                  ? _onGradeConfirmed
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: BumditbulColor.green600,
                disabledBackgroundColor: BumditbulColor.black700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isFetchingSchedule
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: BumditbulColor.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '학사일정 조회 중...',
                          style: BumditbulTextStyle.bodyLarge1.copyWith(
                            color: BumditbulColor.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '선택 완료',
                      style: BumditbulTextStyle.bodyLarge1.copyWith(
                        color: BumditbulColor.white,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _handle() => Column(
    children: [
      const SizedBox(height: 12),
      Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: BumditbulColor.black600,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    ],
  );

  Widget _titleRow(String title, {Widget? leading}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 10)],
        Expanded(
          child: Text(
            title,
            style: BumditbulTextStyle.headline3.copyWith(
              color: BumditbulColor.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Iconify(
            Ic.round_close,
            color: BumditbulColor.black400,
            size: 20,
          ),
        ),
      ],
    ),
  );

  Widget _placeholder(String msg) => Padding(
    padding: const EdgeInsets.all(32),
    child: Text(
      msg,
      style: BumditbulTextStyle.bodyLarge1.copyWith(
        color: BumditbulColor.black500,
      ),
    ),
  );
}
