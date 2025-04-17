// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userlogin_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserLoginController on _UserLoginControllerBase, Store {
  final _$isLoggedInAtom = Atom(name: '_UserLoginControllerBase.isLoggedIn');

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  final _$loggedInAsAtom = Atom(name: '_UserLoginControllerBase.loggedInAs');

  @override
  String get loggedInAs {
    _$loggedInAsAtom.reportRead();
    return super.loggedInAs;
  }

  @override
  set loggedInAs(String value) {
    _$loggedInAsAtom.reportWrite(value, super.loggedInAs, () {
      super.loggedInAs = value;
    });
  }

  final _$loginAsAdminAsyncAction =
      AsyncAction('_UserLoginControllerBase.loginAsAdmin');

  @override
  Future<bool> loginAsAdmin(String loginAdmin, String senhaDigitada) {
    return _$loginAsAdminAsyncAction
        .run(() => super.loginAsAdmin(loginAdmin, senhaDigitada));
  }

  final _$_UserLoginControllerBaseActionController =
      ActionController(name: '_UserLoginControllerBase');

  @override
  dynamic logOut() {
    final _$actionInfo = _$_UserLoginControllerBaseActionController.startAction(
        name: '_UserLoginControllerBase.logOut');
    try {
      return super.logOut();
    } finally {
      _$_UserLoginControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
loggedInAs: ${loggedInAs}
    ''';
  }
}
