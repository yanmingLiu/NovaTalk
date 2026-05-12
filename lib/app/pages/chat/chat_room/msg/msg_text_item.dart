import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/utils/clo_util.dart';
import 'package:novatalk/app/widgets/blur_background.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../../../generated/assets.dart';
import '../../../../../generated/locales.g.dart';
import '../../../../configs/app_theme.dart';
import '../../../../configs/constans.dart';
import '../../../../entities/msg_res.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/audio_player_util.dart';
import '../../../../utils/common_utils.dart';
import '../../../../utils/download_util.dart';
import '../../../../utils/log/log_event.dart';
import '../../role_profile/role_profile_view.dart';
import '../msg_rich_text.dart';
import 'msg_send_item.dart';
import 'msg_text_lock_item.dart';

enum PlayState { none, playing, downloading }

class MsgTextItem extends StatefulWidget {
  const MsgTextItem({super.key, required this.msg, required this.ctr});

  final Msg msg;
  final ChatRoomController ctr;

  @override
  State<MsgTextItem> createState() => _MsgTextItemState();
}

class _MsgTextItemState extends State<MsgTextItem> with WidgetsBindingObserver {
  var hasVoice = false;
  late String timer = '1s';
  PlayState _playState = PlayState.none;

  bool _autoPlay = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    hasVoice = widget.msg.voiceUrl != null && widget.msg.voiceDur != null;

    _autoPlay =
        widget.ctr.isNewChat &&
        widget.msg.source == MsgSource.welcome &&
        CloUtil.isCloB &&
        _playState == PlayState.none;

    if (_autoPlay) {
      _startAudioPlay();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioPlayerUtil.instance.stopAll();
    }
  }

  @override
  void dispose() {
    super.dispose();
    AudioPlayerUtil.instance.stopAll();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _startAudioPlay() async {
    logEvent('c_news_voice');
    if (!AppUser.inst.isVip.value &&
        widget.msg.source != MsgSource.welcome &&
        !AppUser.inst.isBalanceEnough(ConsumeFrom.audio)) {
      Get.toNamed(Routes.GEM, arguments: ConsumeFrom.audio);
      return;
    }

    if (_playState == PlayState.downloading) {
      return;
    }

    if (_playState == PlayState.playing) {
      _stopAudioPlay();
      _stopPlayAni();
      return;
    }

    var url = widget.msg.voiceUrl;
    var duration = widget.msg.voiceDur ?? 0;

    setState(() {
      _playState = PlayState.downloading;
    });

    if (url != null) {
      final filePath = await DownloadUtil.download(url);
      if (filePath == null || filePath.isEmpty) {
        setState(() {
          _playState = PlayState.none;
        });
        return;
      }

      if (!_autoPlay && !AppUser.inst.isVip.value) {
        AppUser.inst.consume(ConsumeFrom.audio);
      }

      if (mounted) {
        _playAudio(filePath, duration);
      }
    } else {
      setState(() {
        _playState = PlayState.none;
      });
      SmartDialog.showToast('audio url error');
    }
  }

  void _playAudio(String path, int duration) async {
    if (_playState == PlayState.playing) {
      return;
    }
    // _handlePhoneCall();
    final reslut = await AudioPlayerUtil.instance.play(
      widget.msg.id.toString(),
      DeviceFileSource(path),
      stopAction: _stopPlayAni,
      position: Duration.zero,
    );

    if (reslut) {
      _playState = PlayState.playing;
    } else {
      _playState = PlayState.none;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _stopAudioPlay() {
    AudioPlayerUtil.instance.stop(widget.msg.id.toString());
  }

  void _stopPlayAni() {
    if (mounted) {
      setState(() {
        _playState = PlayState.none;
      });
      if (_autoPlay) {
        widget.ctr.isNewChat = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var msg = widget.msg;
    final sendText = msg.question;
    final receivText = msg.answer;

    hasVoice = widget.msg.voiceUrl != null && widget.msg.voiceDur != null;

    timer = formatTime(widget.msg.voiceDur ?? 0);

    bool showSend = sendText != null && (msg.onAnswer == false);
    bool notShowSend = msg.source == MsgSource.clothe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSend && !notShowSend)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: MsgSendItem(msg: msg, ctr: widget.ctr),
          ),
        if (receivText != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final isVip = AppUser.inst.isVip.value;
              final lock = widget.msg.textLock == LockLevel.private.value;
              if (!isVip && lock) {
                return const MsgTextLockItem();
              }
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildText(context),
                  if (hasVoice)
                    Positioned(top: -8, left: 0, child: _buildPlayButton()),
                ],
              );
            }),
          ),
      ],
    );
  }

  Widget _buildText(BuildContext context) {
    final padding = hasVoice
        ? const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 12)
        : EdgeInsets.all(12.w);

    final borderRadius = hasVoice
        ? BorderRadius.circular(12)
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    final margin = hasVoice ? const EdgeInsets.only(top: 15) : EdgeInsets.zero;

    final msg = widget.msg;
    // var showTransBtn = false;

    // if (AccountUtil().user?.autoTranslate == true) {
    //   showTransBtn = false;
    //   if (msg.translateAnswer == null || msg.translateAnswer!.isEmpty) {
    //     showTranslate = false;
    //   } else {
    //     showTranslate = true;
    //   }
    // } else {
    //   if (Get.deviceLocale?.languageCode == 'en') {
    //     showTransBtn = false;
    //   }
    // }
    final content = msg.answer ?? '';
    final translate = msg.translateAnswer ?? content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SBlurBackground(
              blur: 50,
              borderRadius: borderRadius,
              backgroundColor: Color(0x80262626),
              child: Container(
                padding: padding,
                margin: margin,
                decoration: BoxDecoration(borderRadius: borderRadius),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: MsgRichText(
                  text: translate,
                  isSend: false,
                  isTypingAnimation: msg.typewriterAnimated,
                  onAnimationComplete: () {
                    // 打字动画完成后的回调
                    if (msg.typewriterAnimated) {
                      setState(() {
                        msg.typewriterAnimated = false;
                        widget.ctr.isReceiving = false;
                        widget.ctr.pageData.refresh();
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        if (!msg.typewriterAnimated)
          Row(
            spacing: 16,
            children: [
              // 只有最后一条消息才显示这3个按钮 并且判断 msg.source
              if (widget.msg == widget.ctr.pageData.lastOrNull)
                _buildMsgActions(msg),
              if (!CloUtil.isCloB)
                GestureDetector(
                  onTap: report,
                  child: Assets.imagesPhMgReport.iv(width: 24),
                ),
            ],
          ),
      ],
    ).marginOnly(right: 43.w);
  }

  Row _buildMsgActions(Msg msg) {
    /// 有编辑和刷新的消息类型
    /// - text('TEXT_GEN'): 文本消息
    /// - video('VIDEO'): 视频消息
    /// - audio('AUDIO'): 音频消息
    /// - photo('PHOTO'): 图片消息

    final hasEditAndRefresh =
        msg.source == MsgSource.text ||
        msg.source == MsgSource.video ||
        msg.source == MsgSource.audio ||
        msg.source == MsgSource.photo;

    return Row(
      spacing: 16,
      children: [
        // 续写
        InkWell(
          splashColor: Colors.transparent,
          child: Assets.imagesPhMgWrite.iv(width: 48, height: 24),
          onTap: () => widget.ctr.continueMsg(),
        ),
        if (hasEditAndRefresh) ...[
          InkWell(
            splashColor: Colors.transparent,
            child: Assets.imagesPhMgEdit.iv(width: 24, height: 24),
            onTap: () {
              showEditContentSheet(
                defTxt: widget.msg.answer,
                title: LocaleKeys.write.tr,
                onConfirm: (v) {
                  return widget.ctr.editMsg(widget.msg, v ?? "");
                },
              );
            },
          ),
          InkWell(
            splashColor: Colors.transparent,
            child: Assets.imagesPhMgRefresh.iv(width: 24, height: 24),
            onTap: () {
              widget.ctr.refreshMsg(msg);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPlayButton() {
    return TapBox(
      onTap: _startAudioPlay,
      child: IgnorePointer(
        ignoring: true,
        child: Container(
          height: 25,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Color(0xff262008),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.w),
              topRight: Radius.circular(8.w),
              bottomLeft: Radius.circular(1.w),
              bottomRight: Radius.circular(8.w),
            ),
          ),
          child: Center(
            child: Row(
              children: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _playIcon,
                      const SizedBox(width: 4),
                      Text(
                        timer,
                        style: TextStyle(
                          color: cTheme.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _playIcon {
    Widget icon;
    switch (_playState) {
      case PlayState.none:
        icon = Icon(Icons.play_arrow, size: 18.w, color: cTheme.primary);
        break;
      case PlayState.downloading:
        icon = LoadingAnimationWidget.inkDrop(
          color: cTheme.primary,
          size: 10.w,
        );
        break;
      case PlayState.playing:
        icon = LoadingAnimationWidget.staggeredDotsWave(
          color: cTheme.primary,
          size: 20.w,
        );
        break;
    }
    return icon;
  }
}
