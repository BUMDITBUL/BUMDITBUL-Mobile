abstract final class AppStrings {
  /// 입력 레이블
  static const String labelEmail = '이메일';
  static const String labelPassword = '비밀번호';
  static const String labelPasswordConfirm = '비밀번호 확인';
  static const String labelCode = '인증번호';
  static const String labelNickname = '닉네임';
  static const String labelSchool = '교명';

  /// 힌트 텍스트
  static const String hintEmail = '이메일을 입력해주세요.';
  static const String hintPassword = '8자 이상 특수문자를 포함하여 입력해주세요.';
  static const String hintCode = '인증번호 6자리 입력해주세요.';
  static const String hintNickname = '닉네임은 2~5자의 한글만 가능합니다.';
  static const String hintSchool = '학교명을 검색해주세요.';
  static const String hintSchoolOptional = '학교명을 검색해주세요. (선택)';

  /// 에러 메시지
  static const String errEmailEmpty = '이메일을 입력해주세요.';
  static const String errEmailInvalid = '⚠︎ 이메일 형식이 올바르지 않습니다.';
  static const String errCodeEmpty = '인증번호를 입력해주세요.';
  static const String errCodeInvalid = '⚠︎ 인증번호를 다시 확인해주세요.';
  static const String errPasswordEmpty = '⚠︎ 비밀번호를 입력해주세요.';
  static const String errPasswordInvalid = '⚠︎ 비밀번호 형식이 올바르지 않습니다.';
  static const String errPasswordConfirmEmpty = '⚠︎ 비밀번호 확인을 입력해주세요.';
  static const String errPasswordMismatch = '⚠︎ 비밀번호가 일치하지 않습니다.';
  static const String errNicknameEmpty = '⚠︎ 닉네임을 입력해주세요.';
  static const String errSchoolEmpty = '⚠︎ 학교명을 입력해주세요.';

  /// 다이얼로그 문자열
  static const String dialogUnsavedTitle = '저장하지 않고 나가시겠어요?';
  static const String dialogUnsavedBody = '입력한 내용이 저장되지 않습니다.';
  static const String dialogWithdrawalTitle = '회원탈퇴';
  static const String dialogWithdrawalBody =
      '탈퇴 시 모든 데이터가 영구적으로\n삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠어요?';

  /// 버튼 레이블
  static const String btnCancel = '취소';
  static const String btnLeave = '나가기';
  static const String btnWithdraw = '탈퇴하기';
  static const String btnSave = '저장';
  static const String btnComplete = '완료';
}
