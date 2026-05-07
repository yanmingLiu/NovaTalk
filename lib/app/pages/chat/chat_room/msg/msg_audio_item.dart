import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:novatalk/app/configs/app_theme.dart';
import 'package:novatalk/app/pages/chat/chat_room/chat_room_controller.dart';
import 'package:novatalk/app/utils/app_user.dart';
import 'package:novatalk/app/widgets/blur_background.dart';
import 'package:novatalk/app/widgets/common_widget.dart';

import '../../../../../generated/assets.dart';
import '../../../../../generated/locales.g.dart';
import '../../../../configs/constans.dart';
import '../../../../entities/msg_res.dart';
import '../../../../utils/audio_player_util.dart';
import '../../../../utils/common_utils.dart';
import '../../../../utils/download_util.dart';
import '../../../../utils/log/log_event.dart';
import '../../../vip/vip_view.dart';
import 'msg_text_item.dart';

enum AudioPlayState { downloading, playing, paused, stopped }

class MsgAudioItem extends StatefulWidget {
  const MsgAudioItem({super.key, required this.msg, required this.ctr});

  final Msg msg;
  final ChatRoomController ctr;

  @override
  State<MsgAudioItem> createState() => _ChatMsgVoiceWidgetState();
}

class _ChatMsgVoiceWidgetState extends State<MsgAudioItem>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  //
  // final List<String> fromAniList = [
  //   Assets.imagesSound1,
  //   Assets.imagesSound2,
  //   Assets.imagesSound3,
  // ];

  StreamSubscription? _phoneStateSub;

  int aniIndex = 2;

  Timer? _timer;

  final audioPlayState = AudioPlayState.stopped.obs;
  late final AnimationController lottieController = AnimationController(
    vsync: this,
    value: 0.02,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final msgId = widget.msg.id.toString();
    AudioPlayerUtil.instance.getCurrentPosition(msgId).then((value) {
      //如果消息未播放完成则恢复动画
      if (value != null) {
        var duration = widget.msg.audioDuration ?? 0;
        var durLast = duration - value.inMilliseconds;
        audioPlayState.value = AudioPlayState.playing;
        _startPlayAni(durLast);
      }
    });
    audioPlayState.listen((state) {
      switch (state) {
        case AudioPlayState.downloading:
          break;
        case AudioPlayState.playing:
          lottieController.repeat();
          break;
        case AudioPlayState.paused:
        case AudioPlayState.stopped:
          lottieController.stop();
          lottieController.reset();
          break;
      }
    });
  }

  @override
  void dispose() {
    lottieController.stop();
    lottieController.dispose();
    _timer?.cancel();
    AudioPlayerUtil.instance.stopAll();
    _phoneStateSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioPlayerUtil.instance.stopAll();
    }
  }

  int _getAudioLen(Msg msg) {
    int len = msg.audioDuration ?? 0;
    return len.truncate();
  }

  Widget _getAudioUI(Msg msg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
          goPrint("-----------------${audioPlayState.value}");
          return SizedBox(
            height: 30.h,
            width: 130.w,
            child: audioPlayState.value == AudioPlayState.downloading
                ? Center(
                    child: LoadingAnimationWidget.inkDrop(
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : Lottie.asset(
                    Assets.animationAudioVoice,
                    controller: lottieController,
                    delegates: LottieDelegates(
                      values: [
                        // 修改所有填充颜色
                        ValueDelegate.colorFilter(
                          const ['**'], // 匹配所有图层
                          value: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
              fit: BoxFit.fill,
                  ),
            // : SvgPicture.asset(
            //     audioPlayState.value == AudioPlayState.playing
            //         ? fromAniList[aniIndex]
            //         : fromAniList[2],
            //     width: 28,
            //     height: 28,
            //     colorFilter: const ColorFilter.mode(
            //       Colors.white, // 颜色
            //       BlendMode.srcIn, // 混合模式
            //     ),
            //   ),
          );
        }),
        // const SizedBox(width: 38),
        // Text(
        //   AudioPlayerUtil.instance.audioTimer(_getAudioLen(msg)),
        //   style: const TextStyle(
        //     fontSize: 13,
        //     color: Colors.white,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
      ],
    );
  }

  void _startAudioPlay(Msg msg) async {
    logEvent('c_news_voice');
    _timer?.cancel();
    var url = msg.audioUrl ?? '';
    var duration = msg.audioDuration ?? 0;

    audioPlayState.value = AudioPlayState.downloading;

    final filePath = await DownloadUtil.download(url);
    if (filePath == null || filePath.isEmpty) {
      audioPlayState.value = AudioPlayState.stopped;
      return;
    }

    if (mounted) {
      _playAudio(filePath, duration);
    }
  }

  void _playAudio(String path, int duration) async {
    AudioPlayerUtil.instance
        .play(
          widget.msg.id.toString(),
          DeviceFileSource(path),
          stopAction: _stopPlayAni,
        )
        .then((value) {
          if (value) {
            // _startPlayAni(duration);
            audioPlayState.value = AudioPlayState.playing;
          } else {
            audioPlayState.value = AudioPlayState.stopped;
          }
        });
  }

  void _stopAudioPlay() {
    AudioPlayerUtil.instance.stop(widget.msg.id.toString());
    _stopPlayAni();
  }

  void _startPlayAni(int duration) {
    if (audioPlayState.value == AudioPlayState.playing) {
      _stopAudioPlay();
      return;
    }

    audioPlayState.value = AudioPlayState.playing;

    int durationInMilliseconds = duration * 1000;

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        if (aniIndex >= 2) {
          aniIndex = 0;
        } else {
          aniIndex++;
        }
      });
      if (200 * timer.tick >= durationInMilliseconds) {
        _stopAudioPlay();
      }
    });
  }

  void _stopPlayAni() {
    _timer?.cancel();
    audioPlayState.value = AudioPlayState.stopped;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var isRead = true; //widget.msg.isRead;
    var isShowTrial = !AppUser.inst.isVip.value;

    return Column(
      children: [
        MsgTextItem(msg: widget.msg, ctr: widget.ctr),
        const SizedBox(height: 10),
        Row(children: [_buildAudio(isShowTrial, isRead)]),
      ],
    );
  }

  Widget _buildAudio(bool isShowTrial, bool isRead) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        GestureDetector(
          onTap: () {
            if (!AppUser.inst.isVip.value) {
              logEvent('c_news_lockaudio');
              pushVip(VipFrom.lockaudio);
              return;
            }
            if (audioPlayState.value == AudioPlayState.playing) {
              _stopAudioPlay();
            } else {
              _startAudioPlay(widget.msg);
            }
            if (!isRead) {
              // MsgService.to.markMessageAsRead(widget.msg.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SBlurBackground(
                  blur: 50,
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _getAudioUI(widget.msg),
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFFEBFF4C),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Color(0xff78D5FA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Obx(() {
                switch (audioPlayState.value) {
                  case AudioPlayState.downloading:
                    return Center(
                      child: LoadingAnimationWidget.inkDrop(
                        color: Colors.white,
                        size: 12,
                      ),
                    );
                  case AudioPlayState.playing:
                    return Assets.imagesPhAdPause.iv(width: 12);
                  default:
                    return Assets.imagesPhAdPlay.iv(width: 12);
                }
              }),
              5.horizontalSpace,
              Text(
                LocaleKeys.sForYou.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
