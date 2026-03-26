// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ローカルマップとトラックログ';

  @override
  String get login => 'ログイン';

  @override
  String get register => 'アカウント作成';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get confirmPassword => 'パスワード再入力';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get profile => 'プロフィール';

  @override
  String get logout => 'ログアウト';

  @override
  String get account => 'アカウント';

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get dangerZone => '危険ゾーン';

  @override
  String get deleteAccountSubtitle => 'アカウントを完全に削除します';

  @override
  String get deleteAccountIrreversible => 'この操作は元に戻せません。';

  @override
  String get language => '言語';

  @override
  String get theme => 'テーマ';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get system => 'システム設定';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get retry => '再試行';

  @override
  String get notifications => '通知';

  @override
  String get map => 'マップ';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get welcomeBack => 'おかえりなさい';

  @override
  String get signInToContinue => 'ログインして続行してください';

  @override
  String get forgotPassword => 'パスワードを忘れた場合';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでない場合';

  @override
  String get signIn => 'ログイン';

  @override
  String get or => 'または';

  @override
  String get continueWithGoogle => 'Googleで続行';

  @override
  String get continueWithApple => 'Appleで続行';

  @override
  String get welcome => 'ようこそ！';

  @override
  String get createAccountToSave => 'アカウントを作成してトラックログを保存しましょう';

  @override
  String get alreadyHaveAccount => '既にアカウントをお持ちですか？';

  @override
  String get passwordRequirements => 'パスワードは、大文字、小文字、数字を含む8文字以上である必要があります';

  @override
  String get storageWarning => 'ストレージ警告';

  @override
  String get storageWarningMessage =>
      'マップのキャッシュが大量のストレージを消費しています。古いデータを削除して空き容量を増やしますか？';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get notNow => 'あとで';

  @override
  String get cacheCleared => 'キャッシュが正常にクリアされました';

  @override
  String get importTrack => 'トラックをインポート';

  @override
  String get centerOnLocation => '現在地に移動';

  @override
  String get toNorth => '北を上にする';

  @override
  String get anonymousUser => '匿名ユーザー';

  @override
  String get noUserSignedIn => 'ユーザーがログインしていません';

  @override
  String get editDisplayName => '表示名を編集';

  @override
  String get displayName => '表示名';

  @override
  String get displayNameUpdatedSuccessfully => '表示名を更新しました';

  @override
  String get connectionError => '接続エラー';

  @override
  String get unableToUpdateProfile =>
      'プロフィールを更新できません。インターネット接続を確認してもう一度お試しください。';

  @override
  String get accountInformation => 'アカウント情報';

  @override
  String get memberSince => '登録日';

  @override
  String get emailVerified => 'メール認証済み';

  @override
  String get accountSettings => 'アカウント設定';

  @override
  String get viewAndEditYourProfile => 'プロフィールを表示・編集する';

  @override
  String get changeProfilePicture => 'プロフィール写真を変更';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get about => 'このアプリについて';

  @override
  String get legal => '法的情報';

  @override
  String get openSettings => '設定を開く';

  @override
  String get logoutConfirmationTitle => 'ログアウトしますか？';

  @override
  String get logoutConfirmationBody => 'アカウントからサインアウトしますか？';

  @override
  String logoutFailed(String error) {
    return 'ログアウトに失敗しました: $error';
  }

  @override
  String get deleteAccountConfirm => 'アカウントを削除しますか？';

  @override
  String get deletionWarning => 'この操作は取り消せません！';

  @override
  String get deletionItems => 'アカウントを削除すると：';

  @override
  String get deletionPermanentlyRemove => 'すべてのアカウントデータが完全に削除されます';

  @override
  String get deletionDeleteTracks => '保存されたすべてのトラックログが削除されます';

  @override
  String get deletionCancelSessions => '進行中のセッションがすべて解除されます';

  @override
  String get deletionRemoveProfile => 'プロフィール情報が削除されます';

  @override
  String get enterPasswordToConfirm => '確認のためパスワードを入力してください：';

  @override
  String get loading => '読み込み中...';

  @override
  String get verifying => '確認中...';

  @override
  String get updating => '更新中...';

  @override
  String get locationPermissionDenied => '位置情報の権限が拒否されました';

  @override
  String get photoPickerCancelled => '写真が選択されていません。';

  @override
  String get photoPermissionDenied => '写真へのアクセスが拒否されました。';

  @override
  String get photoPickerFailed => '写真を選択できませんでした。もう一度お試しください。';

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした。';

  @override
  String get couldNotLoadTracklogs => '保存されたトラックログを読み込めませんでした';

  @override
  String trackImportedSuccessfully(String name) {
    return 'トラック \"$name\" が正常にインポートされました';
  }

  @override
  String get importingTrack => 'トラックをインポート中...';

  @override
  String failedToImportTrack(String error) {
    return 'トラックのインポートに失敗しました: $error';
  }

  @override
  String failedToUpdateTracklog(String error) {
    return 'トラックログの更新に失敗しました: $error';
  }

  @override
  String failedToDeleteTracklog(String error) {
    return 'トラックログの削除に失敗しました: $error';
  }

  @override
  String get cacheStorageInfo => 'キャッシュストレージ情報';

  @override
  String get totalSize => '合計サイズ';

  @override
  String get tileCount => 'タイル数';

  @override
  String get storageUsage => 'ストレージ使用状況';

  @override
  String get storageWarningThresholdReached => 'ストレージ警告のしきい値に達しました';

  @override
  String get storageUsageNormal => 'ストレージ使用状況は正常です';

  @override
  String get close => '閉じる';

  @override
  String get undo => '元に戻す';

  @override
  String get tracklogs => 'トラックログ';

  @override
  String get noTracklogsAdded => 'トラックログはまだ追加されていません';

  @override
  String get imported => 'インポート済み';

  @override
  String get hide => '非表示';

  @override
  String get show => '表示';

  @override
  String get rename => '名前の変更';

  @override
  String get changeColor => '色の変更';

  @override
  String get remove => '削除';

  @override
  String get renameTracklog => 'トラックログの名前を変更';

  @override
  String isVisibleNow(String name) {
    return '$name が表示されました';
  }

  @override
  String isHiddenNow(String name) {
    return '$name が非表示になりました';
  }

  @override
  String get nameTracklog => 'トラックログに名前を付ける';

  @override
  String get name => '名前';

  @override
  String get enterTracklogName => 'トラックログの名前を入力してください';

  @override
  String get nameCannotBeEmpty => '名前は空にできません';

  @override
  String get ok => 'OK';

  @override
  String get chooseColor => '色を選択';

  @override
  String get addMarker => 'マーカーを追加';

  @override
  String get addMarkerQuestion => 'マーカーを追加しますか？';

  @override
  String get addMarkerAtLocation => 'この位置にマーカーを追加しますか？';

  @override
  String get chooseIcon => 'アイコンを選択';

  @override
  String get nameMarker => 'マーカーの名前';

  @override
  String get next => '次へ';

  @override
  String get back => '戻る';

  @override
  String get create => '作成';

  @override
  String get markerName => 'マーカー名';

  @override
  String get enterName => '名前を入力';

  @override
  String get markerStepInstruction => '次のステップでアイコン、色、名前を選択できます。';
}
