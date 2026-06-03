import 'dart:math';
import 'package:flutter/material.dart';

import '../models/adventure_models.dart';
import '../models/quest_theme.dart';
import '../services/user_profile_service.dart';

class ChapterDetailScreen extends StatefulWidget {
  final AdventureChapter chapter;
  final AdventureProgress progress;
  final QuestTheme mode;

  final String field;
  final String topic;
  final String level;
  final String modeTitle;
  final String mapTitle;

  final VoidCallback onNewAdventureRequested;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
    required this.progress,
    required this.mode,
    required this.field,
    required this.topic,
    required this.level,
    required this.modeTitle,
    required this.mapTitle,
    required this.onNewAdventureRequested,
  });

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  final UserProfileService profileService = UserProfileService();

  int? selectedAnswer;

  int currentFinalQuestionIndex = 0;
  int finalCorrectCount = 0;
  int finalWrongCount = 0;
  int normalWrongCount = 0;

  bool showHint = false;
  bool showIdea = false;
  bool answered = false;
  bool quizFinished = false;
  bool rewardSaved = false;
  bool taskFailed = false;
  bool isProcessing = false;

  bool coinAnimVisible = false;
  int lastCoinChange = 0;

  int taskGold = 0;

  String feedbackText = '';
  String ideaText = '';

  late AdventureProgress currentProgress;

  bool get isBoss => widget.chapter.isBoss;

  QuizQuestion? get currentFinalQuestion {
    if (!isBoss) return null;
    if (widget.chapter.finalQuiz.isEmpty) return null;
    if (currentFinalQuestionIndex >= widget.chapter.finalQuiz.length) {
      return null;
    }

    return widget.chapter.finalQuiz[currentFinalQuestionIndex];
  }

  @override
  void initState() {
    super.initState();

    currentProgress = widget.progress;
    taskGold = 0;

    final alreadyCompleted =
        widget.progress.completedChapters.contains(widget.chapter.id);

    if (alreadyCompleted) {
      answered = true;
      quizFinished = true;
      rewardSaved = true;
      feedbackText = 'Bu görev daha önce tamamlandı.';
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2A211B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  void showCoinAnimation(int amount) {
    setState(() {
      lastCoinChange = amount;
      coinAnimVisible = true;
    });

    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;

      setState(() {
        coinAnimVisible = false;
      });
    });
  }

  Future<bool> spendFiveGoldIfPossible() async {
    final currentGold = await profileService.getCurrentGold();

    if (currentGold < 5) {
      showCoinAnimation(0);
      return false;
    }

    final spent = await profileService.spendProfileGold(5);

    if (!spent) {
      showCoinAnimation(0);
      return false;
    }

    setState(() {
      currentProgress = currentProgress.copyWith(
        gold: currentProgress.gold >= 5 ? currentProgress.gold - 5 : 0,
      );
    });

    showCoinAnimation(-5);
    return true;
  }

  Future<void> saveFailedAdventureToHistory() async {
    try {
      await profileService.saveAdventureHistory(
        field: widget.field,
        topic: widget.topic,
        level: widget.level,
        mode: widget.modeTitle,
        mapTitle: '${widget.mapTitle} - Tamamlanamadı',
        earnedGold: 0,
        earnedXp: 0,
      );
    } catch (e) {
      // Geçmiş kaydı olmazsa uygulama çökmesin.
    }
  }

  String buildIdeaText() {
    if (isBoss) {
      return 'Bu final sorusunda önce sorunun senden tanım mı, amaç mı, kullanım mı istediğini ayır. Sonra seçenekleri tek tek ele.';
    }

    return 'Bu soruda bölümdeki ana açıklamaya odaklan. Cevabı ezberlemeye değil, kavramın ne işe yaradığını anlamaya çalış.';
  }

  Future<void> buyHint() async {
    if (!isBoss && widget.chapter.id == 1) {
      showMessage('İlk görevde ipucu kullanılamaz. Önce görevi kendin dene.');
      return;
    }

    final currentGold = await profileService.getCurrentGold();

    if (currentGold < 5) {
      showMessage('İpucu almak için en az 5 altının olmalı.');
      return;
    }

    final spent = await profileService.spendProfileGold(5);

    if (!spent) {
      showMessage('Yeterli altının yok.');
      return;
    }

    setState(() {
      showHint = true;
      currentProgress = currentProgress.copyWith(
        gold: currentProgress.gold >= 5 ? currentProgress.gold - 5 : 0,
      );
    });

    showCoinAnimation(-5);
    showMessage('5 altın harcandı. İpucu açıldı.');
  }

  Future<void> buyIdea() async {
    if (!isBoss && widget.chapter.id == 1) {
      showMessage('İlk görevde fikir kullanılamaz. Önce görevi kendin dene.');
      return;
    }

    final currentGold = await profileService.getCurrentGold();

    if (currentGold < 10) {
      showMessage('Fikir almak için en az 10 altının olmalı.');
      return;
    }

    final spent = await profileService.spendProfileGold(10);

    if (!spent) {
      showMessage('Yeterli altının yok.');
      return;
    }

    setState(() {
      showIdea = true;
      ideaText = buildIdeaText();
      currentProgress = currentProgress.copyWith(
        gold: currentProgress.gold >= 10 ? currentProgress.gold - 10 : 0,
      );
    });

    showCoinAnimation(-10);
    showMessage('10 altın harcandı. Fikir açıldı.');
  }

  Future<void> answerNormalQuestion(int index) async {
    if (answered || isProcessing || rewardSaved || taskFailed) return;

    final isCorrect = index == widget.chapter.correctIndex;
    final isFirstChapter = widget.chapter.id == 1;

    setState(() {
      selectedAnswer = index;
      answered = true;
      isProcessing = true;
    });

    /*
      DOĞRU CEVAP:
      - Kullanıcı 15 altın kazanır.
      - Görevi tamamla butonu çıkar.
    */
    if (isCorrect) {
      setState(() {
        taskGold = 15;
        quizFinished = true;
        taskFailed = false;
        isProcessing = false;
        feedbackText =
            'Doğru cevap! Görevi tamamlayınca 15 altın kazanacaksın.';
      });

      showCoinAnimation(15);
      return;
    }

    /*
      YANLIŞ CEVAP SAYISI ARTAR
    */
    normalWrongCount++;

    /*
      1. GÖREV - İLK YANLIŞ:
      - Kullanıcı 0 altınla başladığı için altın düşmez.
      - Doğru cevap yeşil gösterilmez.
      - Tekrar dene hakkı verilir.
      - Görevi Tamamla çıkmaz.
    */
    if (isFirstChapter && normalWrongCount == 1) {
      setState(() {
        taskGold = 0;
        quizFinished = false;
        taskFailed = false;
        isProcessing = false;
        feedbackText =
            'Yanlış cevap. İlk görev olduğu için altın düşmedi. Tekrar dene.';
      });

      return;
    }

    /*
      1. GÖREV - İKİNCİ YANLIŞ:
      - Altın düşmez.
      - "5 altın kaybettin" yazmaz.
      - Görev başarısız olur.
      - Doğru cevap gösterilir.
      - Görevi Tamamla çıkmaz.
      - Yeni Görev Üret çıkar.
      - Geçmişe kaydedilir.
    */
    if (isFirstChapter && normalWrongCount >= 2) {
      await saveFailedAdventureToHistory();

      setState(() {
        taskGold = 0;
        quizFinished = false;
        taskFailed = true;
        isProcessing = false;
        feedbackText =
            'Görev tamamlanamadı. İlk görevde altının olmadığı için altın düşmedi. Bu deneme geçmişe kaydedildi. Yeni görev üretebilirsin.';
      });

      return;
    }

    /*
      2, 3, 4, 5. GÖREVLERDE YANLIŞ:
      - Altın yeterliyse 5 altın düşer.
      - Doğru cevap yeşil gösterilir.
      - Bu görevden altın kazanmaz.
      - Tekrar Dene çıkmaz.
      - Görevi Tamamla çıkar.
      - Sonraki göreve geçebilir.
    */
    final spentGold = await spendFiveGoldIfPossible();

    if (spentGold) {
      setState(() {
        taskGold = 0;
        quizFinished = true;
        taskFailed = false;
        isProcessing = false;
        feedbackText =
            'Yanlış cevap. Doğru cevap gösterildi. 5 altın kaybettin. Bu görevden altın kazanamazsın ama devam edebilirsin.';
      });

      return;
    }

    /*
      2, 3, 4, 5. GÖREVLERDE ALTIN YETERSİZ:
      - Altın yetersizse görev başarısız olur.
      - Görevi Tamamla çıkmaz.
      - Yeni Görev Üret çıkar.
      - Geçmişe kaydedilir.
    */
    await saveFailedAdventureToHistory();

    setState(() {
      taskGold = 0;
      quizFinished = false;
      taskFailed = true;
      isProcessing = false;
      feedbackText =
          'Görev tamamlanamadı. Altının yetersiz olduğu için devam edemezsin. Bu deneme geçmişe kaydedildi. Yeni görev üretebilirsin.';
    });
  }

  Future<void> retryNormalQuestion() async {
    if (widget.chapter.id != 1) return;
    if (normalWrongCount != 1 || taskFailed || quizFinished) return;

    setState(() {
      selectedAnswer = null;
      answered = false;
      isProcessing = false;
      feedbackText = 'Tekrar dene. Doğru cevabı bulmadan ilerleyemezsin.';
    });
  }

  Future<void> answerFinalQuestion(int index) async {
    if (isProcessing || currentFinalQuestion == null || quizFinished) return;
    if (selectedAnswer != null) return;

    final question = currentFinalQuestion!;
    final isCorrect = index == question.correctIndex;
    final isLastQuestion =
        currentFinalQuestionIndex >= widget.chapter.finalQuiz.length - 1;

    setState(() {
      selectedAnswer = index;
      isProcessing = true;
    });

    if (isCorrect) {
      setState(() {
        finalCorrectCount++;
        taskGold += 15;
        feedbackText = 'Doğru cevap! +15 altın.';
      });

      showCoinAnimation(15);

      Future.delayed(const Duration(milliseconds: 850), () {
        if (!mounted) return;

        if (isLastQuestion) {
          setState(() {
            quizFinished = true;
            selectedAnswer = null;
            isProcessing = false;
            feedbackText =
                'Final mini quiz bitti. Doğru: $finalCorrectCount / Yanlış: $finalWrongCount. Görevi tamamlayabilirsin.';
          });
        } else {
          setState(() {
            currentFinalQuestionIndex++;
            selectedAnswer = null;
            isProcessing = false;
            feedbackText = '';
          });
        }
      });

      return;
    }

    finalWrongCount++;

    final spentGold = await spendFiveGoldIfPossible();

    if (!spentGold) {
      await saveFailedAdventureToHistory();

      setState(() {
        isProcessing = false;
        taskFailed = true;
        quizFinished = false;
        feedbackText =
            'Final görev başarısız oldu. Altının yetersiz olduğu için devam edemedin. Bu deneme geçmişe kaydedildi.';
      });

      return;
    }

    setState(() {
      isProcessing = false;
      feedbackText =
          'Yanlış cevap. 5 altın kaybettin. Aynı soruyu tekrar dene.';
    });

    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;

      setState(() {
        selectedAnswer = null;
        feedbackText =
            'Aynı soruyu tekrar çöz. Doğru cevap vermeden ilerleyemezsin.';
      });
    });
  }

  Future<void> completeTask() async {
    if (taskFailed) {
      showMessage('Başarısız görev zaten geçmişe kaydedildi.');
      return;
    }

    if (!quizFinished || isProcessing || rewardSaved) return;

    setState(() {
      isProcessing = true;
    });

    final updatedCompleted = Set<int>.from(currentProgress.completedChapters)
      ..add(widget.chapter.id);

    final nextUnlock = widget.chapter.id >= currentProgress.unlockedChapter
        ? widget.chapter.id + 1
        : currentProgress.unlockedChapter;

    try {
      await profileService.addReward(
        gold: taskGold,
        xp: 0,
      );

      if (isBoss) {
        await profileService.addBadge();
      }

      await profileService.saveAdventureHistory(
        field: widget.field,
        topic: widget.topic,
        level: widget.level,
        mode: widget.modeTitle,
        mapTitle: widget.mapTitle,
        earnedGold: taskGold,
        earnedXp: 0,
      );

      setState(() {
        rewardSaved = true;
        isProcessing = false;

        currentProgress = currentProgress.copyWith(
          gold: currentProgress.gold + taskGold,
          unlockedChapter: nextUnlock > 6 ? 6 : nextUnlock,
          completedChapters: updatedCompleted,
        );

        feedbackText = isBoss
            ? 'Final boss tamamlandı! $taskGold altın ve 1 rozet kazandın.'
            : taskGold > 0
                ? 'Görev tamamlandı! $taskGold altın kazandın.'
                : 'Görev tamamlandı. Bu görevden altın kazanmadın.';
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      showMessage('Ödül kaydedilemedi. İnternet bağlantını kontrol et.');
    }
  }

  void finishChapter() {
    Navigator.pop(context, currentProgress);
  }

  void requestNewAdventure() {
    widget.onNewAdventureRequested();
  }

  Color normalOptionBorderColor(int index) {
    if (selectedAnswer == null) {
      return Colors.white.withOpacity(0.14);
    }

    final correctIndex = widget.chapter.correctIndex;
    final selectedIsWrong = selectedAnswer != correctIndex;

    final isFirstChapterFirstWrong =
        widget.chapter.id == 1 &&
        normalWrongCount == 1 &&
        !quizFinished &&
        !taskFailed;

    if (selectedAnswer == index && index == correctIndex) {
      return const Color(0xFF60D394);
    }

    if (selectedAnswer == index && index != correctIndex) {
      return const Color(0xFFFF4F6D);
    }

    /*
      Yanlış cevap sonrası doğru cevabı yeşil göster.
      Ama 1. görevin ilk yanlışında gösterme.
    */
    if (selectedIsWrong && index == correctIndex && !isFirstChapterFirstWrong) {
      return const Color(0xFF60D394);
    }

    return Colors.white.withOpacity(0.14);
  }

  Color finalOptionBorderColor(int index) {
    if (currentFinalQuestion == null || selectedAnswer == null) {
      return Colors.white.withOpacity(0.14);
    }

    // Final mini quizde yanlış cevap sonrası doğru cevabı göstermiyoruz.
    // Kullanıcı aynı soruyu tekrar çözeceği için sadece seçtiği şık renklensin.
    if (selectedAnswer == index) {
      if (index == currentFinalQuestion!.correctIndex) {
        return const Color(0xFF60D394);
      }

      return const Color(0xFFFF4F6D);
    }

    return Colors.white.withOpacity(0.14);
  }

  @override
  Widget build(BuildContext context) {
    final finalQuestion = currentFinalQuestion;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  widget.mode.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.34),
                        Colors.black.withOpacity(0.76),
                        Colors.black.withOpacity(0.97),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
                  children: [
                    _TopBar(
                      title: widget.chapter.title,
                      subtitle: widget.chapter.subtitle,
                      onBack: finishChapter,
                    ),
                    const SizedBox(height: 14),
                    _TaskRewardBar(
                      rewardGold: taskGold,
                      profileGold: currentProgress.gold,
                      isBoss: isBoss,
                      finalCorrect: finalCorrectCount,
                      finalTotal: widget.chapter.finalQuiz.length,
                    ),
                    const SizedBox(height: 16),
                    _TextPanel(
                      title: 'Hikâye',
                      text: widget.chapter.story,
                      mode: widget.mode,
                    ),
                    const SizedBox(height: 12),
                    _TextPanel(
                      title: 'Konu Anlatımı',
                      text: widget.chapter.explanation,
                      mode: widget.mode,
                    ),
                    const SizedBox(height: 12),
                    _HelpPanel(
                      showHint: showHint,
                      showIdea: showIdea,
                      firstChapterLocked: !isBoss && widget.chapter.id == 1,
                      hint: widget.chapter.memoryTip,
                      idea: ideaText,
                      onBuyHint: buyHint,
                      onBuyIdea: buyIdea,
                    ),
                    const SizedBox(height: 16),
                    if (!isBoss)
                      _NormalQuizPanel(
                        chapter: widget.chapter,
                        selectedAnswer: selectedAnswer,
                        answered: answered,
                        borderColorBuilder: normalOptionBorderColor,
                        onAnswer: answerNormalQuestion,
                      )
                    else
                      _FinalQuizPanel(
                        question: finalQuestion,
                        questionIndex: currentFinalQuestionIndex,
                        totalQuestions: widget.chapter.finalQuiz.length,
                        selectedAnswer: selectedAnswer,
                        quizFinished: quizFinished,
                        borderColorBuilder: finalOptionBorderColor,
                        onAnswer: answerFinalQuestion,
                      ),
                    if (feedbackText.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _FeedbackPanel(
                        text: feedbackText,
                        success: !feedbackText.contains('Yanlış') &&
                            !feedbackText.contains('başarısız') &&
                            !feedbackText.contains('tamamlanamadı') &&
                            !feedbackText.contains('yetersiz') &&
                            !feedbackText.contains('kaybettin'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (!isBoss &&
                        widget.chapter.id == 1 &&
                        normalWrongCount == 1 &&
                        !taskFailed &&
                        !quizFinished)
                      _RetryButton(
                        mode: widget.mode,
                        onTap: retryNormalQuestion,
                      ),
                    if (taskFailed) ...[
                      const SizedBox(height: 12),
                      _NewAdventureButton(
                        mode: widget.mode,
                        onTap: requestNewAdventure,
                      ),
                    ],
                    if (!taskFailed && quizFinished)
                      _CompleteTaskButton(
                        enabled: !rewardSaved && !isProcessing,
                        rewardSaved: rewardSaved,
                        mode: widget.mode,
                        onTap: completeTask,
                      ),
                    if (rewardSaved) ...[
                      const SizedBox(height: 12),
                      _FinishButton(
                        mode: widget.mode,
                        onTap: finishChapter,
                      ),
                    ],
                  ],
                ),
              ),
              if (coinAnimVisible)
                Positioned(
                  top: 94,
                  right: 34,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 850),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -34 * value),
                        child: Opacity(
                          opacity: 1 - value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: lastCoinChange > 0
                                  ? const Color(0xFF163B2C)
                                  : lastCoinChange < 0
                                      ? const Color(0xFF3B161D)
                                      : const Color(0xFF2A211B),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: lastCoinChange > 0
                                    ? const Color(0xFF60D394)
                                    : lastCoinChange < 0
                                        ? const Color(0xFFFF4F6D)
                                        : const Color(0xFFFFD58A),
                              ),
                            ),
                            child: Text(
                              lastCoinChange == 0
                                  ? 'Altın yetersiz'
                                  : '${lastCoinChange > 0 ? '+' : ''}$lastCoinChange 🪙',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.38),
              border: Border.all(
                color: const Color(0xFFFFD58A).withOpacity(0.45),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFFFE7B2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Görev Bölümü',
                style: TextStyle(
                  color: Color(0xFFFFE7B2),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskRewardBar extends StatelessWidget {
  final int rewardGold;
  final int profileGold;
  final bool isBoss;
  final int finalCorrect;
  final int finalTotal;

  const _TaskRewardBar({
    required this.rewardGold,
    required this.profileGold,
    required this.isBoss,
    required this.finalCorrect,
    required this.finalTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniReward(label: 'Ödül', value: '$rewardGold', icon: '🪙'),
        const SizedBox(width: 8),
        _MiniReward(label: 'Altın', value: '$profileGold', icon: '💰'),
        if (isBoss) ...[
          const SizedBox(width: 8),
          _MiniReward(
            label: 'Quiz',
            value: '$finalCorrect/$finalTotal',
            icon: '🏆',
          ),
        ],
      ],
    );
  }
}

class _MiniReward extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _MiniReward({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF241A18).withOpacity(0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFFD58A).withOpacity(0.20),
          ),
        ),
        child: Row(
          children: [
            Text(icon),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 9.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFFE7B2),
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextPanel extends StatelessWidget {
  final String title;
  final String text;
  final QuestTheme mode;

  const _TextPanel({
    required this.title,
    required this.text,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFF201817).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: mode.glowColor.withOpacity(0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE7B2),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.80),
              fontSize: 13,
              height: 1.48,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpPanel extends StatefulWidget {
  final bool showHint;
  final bool showIdea;
  final bool firstChapterLocked;
  final String hint;
  final String idea;
  final VoidCallback onBuyHint;
  final VoidCallback onBuyIdea;

  const _HelpPanel({
    required this.showHint,
    required this.showIdea,
    required this.firstChapterLocked,
    required this.hint,
    required this.idea,
    required this.onBuyHint,
    required this.onBuyIdea,
  });

  @override
  State<_HelpPanel> createState() => _HelpPanelState();
}

class _HelpPanelState extends State<_HelpPanel> with TickerProviderStateMixin {
  late final AnimationController _lidCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _runeCtrl;

  late final Animation<double> _lidAngle;
  late final Animation<double> _glowRadius;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    _lidCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _lidAngle = Tween<double>(begin: 0, end: -0.7).animate(
      CurvedAnimation(parent: _lidCtrl, curve: Curves.easeInOut),
    );

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowRadius = Tween<double>(begin: 35, end: 62).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _runeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _lidCtrl.dispose();
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _runeCtrl.dispose();
    super.dispose();
  }

  void _toggleChest() {
    setState(() {
      _isOpen = !_isOpen;
    });

    if (_isOpen) {
      _lidCtrl.forward();
    } else {
      _lidCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3B2417).withOpacity(0.96),
            const Color(0xFF17111F).withOpacity(0.96),
            const Color(0xFF271537).withOpacity(0.96),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.36),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD58A).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF8A4FFF).withOpacity(0.14),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _toggleChest,
                child: SizedBox(
                  width: 118,
                  height: 118,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _runeCtrl,
                        builder: (_, __) {
                          return Transform.rotate(
                            angle: _runeCtrl.value * 2 * pi,
                            child: CustomPaint(
                              size: const Size(116, 116),
                              painter: _SmallRuneRingPainter(
                                color: const Color(0xFF9B5CFF)
                                    .withOpacity(0.55),
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _orbitCtrl,
                        builder: (_, __) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              _OrbitGem(
                                angle: _orbitCtrl.value * 2 * pi,
                                color: const Color(0xFFFF6B2B),
                                radius: 48,
                                size: 7,
                              ),
                              _OrbitGem(
                                angle: -_orbitCtrl.value * 2 * pi * 1.3,
                                color: const Color(0xFF00E5CC),
                                radius: 44,
                                size: 5,
                              ),
                              _OrbitGem(
                                angle: _orbitCtrl.value * 2 * pi * 0.7,
                                color: const Color(0xFFFFD700),
                                radius: 51,
                                size: 6,
                              ),
                            ],
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _glowRadius,
                        builder: (_, __) {
                          return Container(
                            width: _glowRadius.value * 1.55,
                            height: _glowRadius.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFD700)
                                      .withOpacity(_isOpen ? 0.54 : 0.22),
                                  const Color(0xFFFF6B2B)
                                      .withOpacity(_isOpen ? 0.28 : 0.10),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _lidAngle,
                        builder: (_, __) {
                          return CustomPaint(
                            size: const Size(86, 80),
                            painter: _SmallChestPainter(
                              lidAngle: _lidAngle.value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yardım Sandığı',
                      style: TextStyle(
                        color: Color(0xFFFFE7B2),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Sandığa dokun, büyülü destekleri aç.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.firstChapterLocked) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFD58A).withOpacity(0.18),
                ),
              ),
              child: const Text(
                'İlk görevde yardım sandığı kapalıdır. İlk altınını kazanmak için görevi kendin denemelisin.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _MagicHelpButton(
                  label: 'İpucu',
                  cost: widget.firstChapterLocked ? 'Kapalı' : '5 altın',
                  icon: '🔮',
                  locked: widget.firstChapterLocked,
                  color: const Color(0xFF7B2FBE),
                  onTap: widget.onBuyHint,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _MagicHelpButton(
                  label: 'Fikir ver',
                  cost: widget.firstChapterLocked ? 'Kapalı' : '10 altın',
                  icon: '✨',
                  locked: widget.firstChapterLocked,
                  color: const Color(0xFFFF6B2B),
                  onTap: widget.onBuyIdea,
                ),
              ),
            ],
          ),
          if (widget.showHint) ...[
            const SizedBox(height: 12),
            _UnlockedHelpText(title: 'İpucu', text: widget.hint),
          ],
          if (widget.showIdea) ...[
            const SizedBox(height: 12),
            _UnlockedHelpText(title: 'Fikir', text: widget.idea),
          ],
        ],
      ),
    );
  }
}

class _MagicHelpButton extends StatefulWidget {
  final String label;
  final String cost;
  final String icon;
  final bool locked;
  final Color color;
  final VoidCallback onTap;

  const _MagicHelpButton({
    required this.label,
    required this.cost,
    required this.icon,
    required this.color,
    required this.onTap,
    this.locked = false,
  });

  @override
  State<_MagicHelpButton> createState() => _MagicHelpButtonState();
}

class _MagicHelpButtonState extends State<_MagicHelpButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  bool _hovered = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 190),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.045).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.locked;

    return Opacity(
      opacity: disabled ? 0.54 : 1,
      child: MouseRegion(
        onEnter: (_) {
          if (disabled) return;
          setState(() => _hovered = true);
          _ctrl.forward();
        },
        onExit: (_) {
          if (disabled) return;
          setState(() => _hovered = false);
          _ctrl.reverse();
        },
        child: GestureDetector(
          onTap: disabled ? null : widget.onTap,
          onTapDown: (_) {
            if (!disabled) _ctrl.forward();
          },
          onTapUp: (_) {
            if (!disabled) _ctrl.reverse();
          },
          onTapCancel: () {
            if (!disabled) _ctrl.reverse();
          },
          child: AnimatedBuilder(
            animation: _scale,
            builder: (_, child) {
              return Transform.scale(
                scale: _scale.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: disabled
                    ? const Color(0xFF5A5148).withOpacity(0.55)
                    : widget.color.withOpacity(0.18),
                border: Border.all(
                  color: disabled
                      ? Colors.white24
                      : widget.color.withOpacity(0.72),
                  width: 1,
                ),
                boxShadow: [
                  if (!disabled)
                    BoxShadow(
                      color: widget.color.withOpacity(_hovered ? 0.58 : 0.30),
                      blurRadius: _hovered ? 24 : 13,
                      spreadRadius: _hovered ? 1 : 0,
                    ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${widget.label} • ${widget.cost}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: disabled
                            ? Colors.white70
                            : Colors.white.withOpacity(0.92),
                        fontSize: 10.7,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnlockedHelpText extends StatelessWidget {
  final String title;
  final String text;

  const _UnlockedHelpText({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE7B2),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12.2,
              height: 1.38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NormalQuizPanel extends StatelessWidget {
  final AdventureChapter chapter;
  final int? selectedAnswer;
  final bool answered;
  final Color Function(int index) borderColorBuilder;
  final Future<void> Function(int index) onAnswer;

  const _NormalQuizPanel({
    required this.chapter,
    required this.selectedAnswer,
    required this.answered,
    required this.borderColorBuilder,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return _QuizBox(
      title: 'Kontrol Sorusu',
      question: chapter.question,
      options: chapter.options,
      borderColorBuilder: borderColorBuilder,
      onAnswer: answered ? null : onAnswer,
    );
  }
}

class _FinalQuizPanel extends StatelessWidget {
  final QuizQuestion? question;
  final int questionIndex;
  final int totalQuestions;
  final int? selectedAnswer;
  final bool quizFinished;
  final Color Function(int index) borderColorBuilder;
  final Future<void> Function(int index) onAnswer;

  const _FinalQuizPanel({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.quizFinished,
    required this.borderColorBuilder,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    if (quizFinished) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF201817).withOpacity(0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD58A).withOpacity(0.24),
          ),
        ),
        child: const Column(
          children: [
            Text(
              'Mini Quiz Tamamlandı',
              style: TextStyle(
                color: Color(0xFFFFE7B2),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Artık final görevini tamamlayıp ödülünü profile ekleyebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    if (question == null) {
      return const SizedBox.shrink();
    }

  final safeQuestion = question!;

return _QuizBox(
  title: 'Final Mini Quiz • ${questionIndex + 1}/$totalQuestions',
  question: safeQuestion.question,
  options: safeQuestion.options,
  borderColorBuilder: borderColorBuilder,
  onAnswer: selectedAnswer == null ? onAnswer : null,
);
  }
}

class _QuizBox extends StatelessWidget {
  final String title;
  final String question;
  final List<String> options;
  final Color Function(int index) borderColorBuilder;
  final Future<void> Function(int index)? onAnswer;

  const _QuizBox({
    required this.title,
    required this.question,
    required this.options,
    required this.borderColorBuilder,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFF201817).withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD58A).withOpacity(0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE7B2),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onAnswer == null ? null : () => onAnswer!(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColorBuilder(index),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(
                          color: Color(0xFFFFD58A),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  final String text;
  final bool success;

  const _FeedbackPanel({
    required this.text,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: success
            ? const Color(0xFF163B2C).withOpacity(0.92)
            : const Color(0xFF3B161D).withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: success ? const Color(0xFF60D394) : const Color(0xFFFF4F6D),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final QuestTheme mode;
  final VoidCallback onTap;

  const _RetryButton({
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: mode.glowColor.withOpacity(0.75),
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B1514),
          foregroundColor: const Color(0xFFFFE7B2),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Tekrar Dene',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _NewAdventureButton extends StatelessWidget {
  final QuestTheme mode;
  final VoidCallback onTap;

  const _NewAdventureButton({
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF4F6D),
            mode.glowColor,
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Yeni Görev Üret',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CompleteTaskButton extends StatelessWidget {
  final bool enabled;
  final bool rewardSaved;
  final QuestTheme mode;
  final VoidCallback onTap;

  const _CompleteTaskButton({
    required this.enabled,
    required this.rewardSaved,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [
              mode.glowColor,
              const Color(0xFFFFD58A),
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF231309),
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(
            rewardSaved ? 'Ödül Kaydedildi' : 'Görevi Tamamla',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  final QuestTheme mode;
  final VoidCallback onTap;

  const _FinishButton({
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: mode.glowColor.withOpacity(0.8),
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B1514),
          foregroundColor: const Color(0xFFFFE7B2),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: const Text(
          'Haritaya Dön',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
class _SmallChestPainter extends CustomPainter {
  final double lidAngle;

  _SmallChestPainter({required this.lidAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + 6;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 37, cy, 74, 38),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A2000),
            Color(0xFF1A0800),
          ],
        ).createShader(bodyRect.outerRect),
    );

    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    _drawBand(canvas, Offset(cx - 37, cy + 10), 74);
    _drawBand(canvas, Offset(cx - 37, cy + 29), 74);

    canvas.save();
    canvas.translate(cx, cy + 1);

    final squeeze = 1.0 + lidAngle.abs() * 0.3;

    final lidPath = Path()
      ..moveTo(-37, 0)
      ..quadraticBezierTo(0, -30 * squeeze, 37, 0)
      ..close();

    canvas.drawPath(
      lidPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5A2A00),
            Color(0xFF1A0800),
          ],
        ).createShader(Rect.fromLTWH(-37, -30, 74, 30)),
    );

    canvas.drawPath(
      lidPath,
      Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    canvas.drawPath(
      Path()
        ..moveTo(-37, -8 * squeeze * 0.5)
        ..quadraticBezierTo(0, -19 * squeeze, 37, -8 * squeeze * 0.5),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF5C3800),
            Color(0xFFFFD700),
            Color(0xFF5C3800),
          ],
        ).createShader(Rect.fromLTWH(-37, -20, 74, 8))
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -15 * squeeze * 0.7),
        width: 16,
        height: 10,
      ),
      Paint()..color = const Color(0xFF1A0800),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -15 * squeeze * 0.7),
        width: 16,
        height: 10,
      ),
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -15 * squeeze * 0.7),
        width: 8,
        height: 5,
      ),
      Paint()..color = const Color(0xFF7B2FBE),
    );

    canvas.restore();

    final lockRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + 4),
        width: 18,
        height: 15,
      ),
      const Radius.circular(3),
    );

    canvas.drawRRect(
      lockRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE566),
            Color(0xFFB8860B),
          ],
        ).createShader(lockRect.outerRect),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 44),
        width: 78,
        height: 12,
      ),
      Paint()..color = Colors.black.withOpacity(0.42),
    );
  }

  void _drawBand(Canvas canvas, Offset origin, double width) {
    canvas.drawRect(
      Rect.fromLTWH(origin.dx, origin.dy, width, 4),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF5C3800),
            Color(0xFFFFD700),
            Color(0xFF5C3800),
          ],
        ).createShader(Rect.fromLTWH(origin.dx, origin.dy, width, 4)),
    );
  }

  @override
  bool shouldRepaint(_SmallChestPainter oldDelegate) {
    return oldDelegate.lidAngle != lidAngle;
  }
}

class _SmallRuneRingPainter extends CustomPainter {
  final Color color;

  _SmallRuneRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 7;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withOpacity(0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );

    const marks = 22;
    final step = 2 * pi / marks;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < marks; i++) {
      final angle = i * step;
      final inner = r - 4;
      final outer = r;

      final x1 = cx + inner * cos(angle);
      final y1 = cy + inner * sin(angle);
      final x2 = cx + outer * cos(angle);
      final y2 = cy + outer * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_SmallRuneRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _OrbitGem extends StatelessWidget {
  final double angle;
  final double radius;
  final double size;
  final Color color;

  const _OrbitGem({
    required this.angle,
    required this.color,
    required this.radius,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final x = cos(angle) * radius;
    final y = sin(angle) * radius;

    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.75),
              blurRadius: 10,
              spreadRadius: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}