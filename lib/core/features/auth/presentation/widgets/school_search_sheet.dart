import 'package:bumditbul_mobile/constants/color.dart';
import 'package:bumditbul_mobile/constants/text_style.dart';
import 'package:flutter/material.dart';

const _mockSchools = [
  '서울고등학교',
  '경복고등학교',
  '한성고등학교',
  '용산고등학교',
  '배재고등학교',
  '서울여자고등학교',
  '이화여자고등학교',
  '숙명여자고등학교',
  '동덕여자고등학교',
  '대원고등학교',
  '서울과학고등학교',
  '한국과학영재학교',
  '서울대학교사범대학부설고등학교',
  '세화고등학교',
  '중동고등학교',
  '인천고등학교',
  '인천과학예술영재학교',
  '부평고등학교',
  '부산고등학교',
  '경남고등학교',
  '부일외국어고등학교',
  '대전고등학교',
  '충남고등학교',
  '대전대신고등학교',
  '광주고등학교',
  '무등고등학교',
  '광주제일고등학교',
  '대구고등학교',
  '경신고등학교',
  '대구외국어고등학교',
  '수원고등학교',
  '수원외국어고등학교',
  '화성고등학교',
  '성남고등학교',
  '분당중앙고등학교',
  '낙생고등학교',
];

Future<String?> showSchoolSearchSheet(BuildContext context) {
  return showModalBottomSheet<String>(
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

class _SchoolSearchSheetState extends State<_SchoolSearchSheet> {
  final _controller = TextEditingController();
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearch);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _controller.text.trim();
    setState(() {
      if (q.isEmpty) {
        _results = [];
      } else {
        _results = _mockSchools.where((s) => s.contains(q)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '학교 검색',
                    style: BumditbulTextStyle.headline3.copyWith(
                      color: BumditbulColor.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: BumditbulColor.black400,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: BumditbulTextStyle.bodyLarge1.copyWith(
                  color: BumditbulColor.white,
                ),
                decoration: InputDecoration(
                  hintText: '학교명을 검색해주세요.',
                  hintStyle: BumditbulTextStyle.bodyLarge1.copyWith(
                    color: BumditbulColor.black600,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BumditbulColor.black500,
                    size: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: BumditbulColor.black600,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: BumditbulColor.green400,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: BumditbulColor.black850,
                ),
                cursorColor: BumditbulColor.green400,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: _results.isEmpty
                  ? _controller.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              '학교명을 입력해 검색하세요.',
                              style: BumditbulTextStyle.bodyLarge1.copyWith(
                                color: BumditbulColor.black500,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              '검색 결과가 없습니다.',
                              style: BumditbulTextStyle.bodyLarge1.copyWith(
                                color: BumditbulColor.black500,
                              ),
                            ),
                          )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: BumditbulColor.black850,
                        indent: 20,
                        endIndent: 20,
                      ),
                      itemBuilder: (ctx, idx) {
                        final school = _results[idx];
                        final q = _controller.text.trim();
                        final start = school.indexOf(q);
                        return ListTile(
                          onTap: () => Navigator.of(context).pop(school),
                          leading: const Icon(
                            Icons.school_outlined,
                            color: BumditbulColor.black500,
                            size: 20,
                          ),
                          title: start >= 0
                              ? RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: school.substring(0, start),
                                        style: BumditbulTextStyle.bodyLarge2
                                            .copyWith(
                                              color: BumditbulColor.white,
                                            ),
                                      ),
                                      TextSpan(
                                        text: school.substring(
                                          start,
                                          start + q.length,
                                        ),
                                        style: BumditbulTextStyle.headline4
                                            .copyWith(
                                              color: BumditbulColor.green400,
                                            ),
                                      ),
                                      TextSpan(
                                        text: school.substring(
                                          start + q.length,
                                        ),
                                        style: BumditbulTextStyle.bodyLarge2
                                            .copyWith(
                                              color: BumditbulColor.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(
                                  school,
                                  style: BumditbulTextStyle.bodyLarge2.copyWith(
                                    color: BumditbulColor.white,
                                  ),
                                ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
