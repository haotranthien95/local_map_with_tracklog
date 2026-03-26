// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '本地地图与轨迹追踪';

  @override
  String get login => '登录';

  @override
  String get register => '创建账号';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get home => '首页';

  @override
  String get settings => '设置';

  @override
  String get profile => '个人资料';

  @override
  String get logout => '退出登录';

  @override
  String get account => '账户';

  @override
  String get deleteAccount => '注销账号';

  @override
  String get dangerZone => '危险区域';

  @override
  String get deleteAccountSubtitle => '永久删除您的账号';

  @override
  String get deleteAccountIrreversible => '此操作无法撤销。';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get system => '跟随系统';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get retry => '重试';

  @override
  String get notifications => '通知';

  @override
  String get map => '地图';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get signInToContinue => '登录以继续';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get dontHaveAccount => '没有账号？';

  @override
  String get signIn => '登录';

  @override
  String get or => '或者';

  @override
  String get continueWithGoogle => '使用 Google 继续';

  @override
  String get continueWithApple => '使用 Apple 继续';

  @override
  String get welcome => '欢迎！';

  @override
  String get createAccountToSave => '创建账号以保存您的轨迹日志';

  @override
  String get alreadyHaveAccount => '已有账号？';

  @override
  String get passwordRequirements => '密码必须至少包含 8 个字符，且包括大写字母、小写字母和数字';

  @override
  String get storageWarning => '存储警告';

  @override
  String get storageWarningMessage => '您的地图缓存占用大量存储空间。是否要清除旧的切片以释放空间？';

  @override
  String get clearCache => '清除缓存';

  @override
  String get notNow => '以后再说';

  @override
  String get cacheCleared => '缓存清除成功';

  @override
  String get importTrack => '导入轨迹';

  @override
  String get centerOnLocation => '定位到当前位置';

  @override
  String get toNorth => '指北';

  @override
  String get anonymousUser => '匿名用户';

  @override
  String get noUserSignedIn => '未登录用户';

  @override
  String get editDisplayName => '编辑显示名称';

  @override
  String get displayName => '显示名称';

  @override
  String get displayNameUpdatedSuccessfully => '显示名称更新成功';

  @override
  String get connectionError => '连接错误';

  @override
  String get unableToUpdateProfile => '无法更新资料。请检查网络连接后重试。';

  @override
  String get accountInformation => '账号信息';

  @override
  String get memberSince => '成员时间';

  @override
  String get emailVerified => '邮箱已验证';

  @override
  String get accountSettings => '账号设置';

  @override
  String get viewAndEditYourProfile => '查看并编辑您的个人资料';

  @override
  String get changeProfilePicture => '更换头像';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get about => '关于';

  @override
  String get legal => '法律信息';

  @override
  String get openSettings => '打开设置';

  @override
  String get logoutConfirmationTitle => '退出登录？';

  @override
  String get logoutConfirmationBody => '确定要退出当前账户吗？';

  @override
  String logoutFailed(String error) {
    return '退出登录失败: $error';
  }

  @override
  String get deleteAccountConfirm => '注销账号？';

  @override
  String get deletionWarning => '此操作将无法撤销！';

  @override
  String get deletionItems => '注销账号将会：';

  @override
  String get deletionPermanentlyRemove => '永久移除所有账号数据';

  @override
  String get deletionDeleteTracks => '删除所有保存的轨迹日志';

  @override
  String get deletionCancelSessions => '取消所有活动会话';

  @override
  String get deletionRemoveProfile => '移除您的个人资料信息';

  @override
  String get enterPasswordToConfirm => '输入密码以确认：';

  @override
  String get loading => '加载中...';

  @override
  String get verifying => '验证中...';

  @override
  String get updating => '更新中...';

  @override
  String get locationPermissionDenied => '位置权限被拒绝';

  @override
  String get photoPickerCancelled => '未选择照片。';

  @override
  String get photoPermissionDenied => '照片权限被拒绝。';

  @override
  String get photoPickerFailed => '无法选择照片，请重试。';

  @override
  String get couldNotOpenLink => '无法打开链接。';

  @override
  String get couldNotLoadTracklogs => '无法加载保存的轨迹日志';

  @override
  String trackImportedSuccessfully(String name) {
    return '轨迹 \"$name\" 导入成功';
  }

  @override
  String get importingTrack => '正在导入轨迹...';

  @override
  String failedToImportTrack(String error) {
    return '导入轨迹失败: $error';
  }

  @override
  String failedToUpdateTracklog(String error) {
    return '更新轨迹日志失败: $error';
  }

  @override
  String failedToDeleteTracklog(String error) {
    return '删除轨迹日志失败: $error';
  }

  @override
  String get cacheStorageInfo => '缓存存储信息';

  @override
  String get totalSize => '总大小';

  @override
  String get tileCount => '切片数量';

  @override
  String get storageUsage => '存储使用情况';

  @override
  String get storageWarningThresholdReached => '已达到存储警告阈值';

  @override
  String get storageUsageNormal => '存储使用正常';

  @override
  String get close => '关闭';

  @override
  String get undo => '撤销';

  @override
  String get tracklogs => '轨迹日志';

  @override
  String get noTracklogsAdded => '尚未添加轨迹日志';

  @override
  String get imported => '已导入';

  @override
  String get hide => '隐藏';

  @override
  String get show => '显示';

  @override
  String get rename => '重命名';

  @override
  String get changeColor => '修改颜色';

  @override
  String get remove => '移除';

  @override
  String get renameTracklog => '重命名轨迹日志';

  @override
  String isVisibleNow(String name) {
    return '$name 现在可见';
  }

  @override
  String isHiddenNow(String name) {
    return '$name 现在已隐藏';
  }

  @override
  String get nameTracklog => '命名轨迹日志';

  @override
  String get name => '名称';

  @override
  String get enterTracklogName => '输入轨迹日志名称';

  @override
  String get nameCannotBeEmpty => '名称不能为空';

  @override
  String get ok => '确定';

  @override
  String get chooseColor => '选择颜色';

  @override
  String get addMarker => '添加标记';

  @override
  String get addMarkerQuestion => '添加标记？';

  @override
  String get addMarkerAtLocation => '在此位置添加标记？';

  @override
  String get chooseIcon => '选择图标';

  @override
  String get nameMarker => '命名标记';

  @override
  String get next => '下一步';

  @override
  String get back => '上一步';

  @override
  String get create => '创建';

  @override
  String get markerName => '标记名称';

  @override
  String get enterName => '输入名称';

  @override
  String get markerStepInstruction => '您可以在接下来的步骤中选择图标、颜色和名称。';
}
