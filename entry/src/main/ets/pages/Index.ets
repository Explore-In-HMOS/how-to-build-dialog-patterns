import {
  AdvancedDialogV2Button,
  AlertDialogV2,
  CustomContentDialogV2,
  LengthMetrics,
  PopoverDialogV2,
  PopoverDialogV2Options
} from '@kit.ArkUI'

@CustomDialog
struct AlarmConfirmationDialog {
  controller?: CustomDialogController
  onStop: () => void = () => {}
  onSnooze: () => void = () => {}

  /**
   * Builds a custom-designed alarm confirmation dialog for a round wearable screen.
   */
  build() {
    Column({ space: 10 }) {
      Text($r('app.string.alarm_time'))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)

      Text($r('app.string.alarm_title'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)

      Text($r('app.string.alarm_message'))
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)

      Row({ space: 8 }) {
        Button($r('app.string.action_stop'))
          .height(34)
          .layoutWeight(1)
          .fontSize(11)
          .borderRadius(17)
          .backgroundColor($r('app.color.accent_orange'))
          .onClick(() => {
            this.onStop()
            this.controller?.close()
          })

        Button($r('app.string.action_snooze'))
          .height(34)
          .layoutWeight(1)
          .fontSize(11)
          .borderRadius(17)
          .backgroundColor($r('app.color.button_secondary_background'))
          .onClick(() => {
            this.onSnooze()
            this.controller?.close()
          })
      }
      .width('86%')
    }
    .width(210)
    .height(210)
    .padding(18)
    .borderRadius(105)
    .clip(true)
    .backgroundColor($r('app.color.dialog_background'))
  }
}

@Entry
@Component
struct Index {
  @State lastActionText: ResourceStr = $r('app.string.status_ready')
  @State isSettingsSheetVisible: boolean = false
  @State isQuickReplyPopoverVisible: boolean = false

  private dialogV2Id: number = -1

  private alarmDialogController: CustomDialogController = new CustomDialogController({
    builder: AlarmConfirmationDialog({
      onStop: () => {
        this.lastActionText = $r('app.string.status_alarm_stopped')
      },
      onSnooze: () => {
        this.lastActionText = $r('app.string.status_alarm_snoozed')
      }
    }),
    customStyle: true,
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  /**
   * Opens the alarm confirmation CustomDialog.
   */
  private openAlarmDialog(): void {
    this.alarmDialogController.open()
  }

  /**
   * Stores the id of the currently opened DialogV2 dialog.
   */
  private saveDialogV2Id(id: number): void {
    this.dialogV2Id = id
  }

  /**
   * Closes the currently opened DialogV2 dialog.
   */
  private closeDialogV2(): void {
    if (this.dialogV2Id < 0) {
      return
    }

    this.getUIContext().getPromptAction().closeCustomDialog(this.dialogV2Id)
    this.dialogV2Id = -1
  }

  /**
   * Opens the workout pause menu using DialogV2 custom content.
   */
  private openWorkoutDialogV2(): void {
    this.getUIContext()
      .getPromptAction()
      .openCustomDialog({
        builder: () => {
          this.workoutDialogV2()
        },
        alignment: DialogAlignment.Center
      })
      .then((id: number) => {
        this.saveDialogV2Id(id)
      })
  }

  /**
   * Opens the settings panel using Sheet Transition.
   */
  private openSettingsSheet(): void {
    this.isSettingsSheetVisible = true
  }

  /**
   * Opens the notification action menu using ActionSheet.
   */
  private openNotificationActionSheet(): void {
    this.getUIContext().showActionSheet({
      title: $r('app.string.action_sheet_title'),
      subtitle: $r('app.string.action_sheet_subtitle'),
      message: $r('app.string.action_sheet_message'),
      autoCancel: true,
      alignment: DialogAlignment.Bottom,
      offset: {
        dx: 0,
        dy: -10
      },
      sheets: [
        {
          title: $r('app.string.action_reply'),
          action: () => {
            this.lastActionText = $r('app.string.status_reply_selected')
          }
        },
        {
          title: $r('app.string.action_mute'),
          action: () => {
            this.lastActionText = $r('app.string.status_notification_muted')
          }
        },
        {
          title: $r('app.string.action_delete'),
          action: () => {
            this.lastActionText = $r('app.string.status_notification_deleted')
          }
        }
      ],
      cancel: () => {
        this.lastActionText = $r('app.string.status_action_sheet_cancelled')
      }
    })
  }

  /**
   * Opens the timer finished prompt using AlertDialogV2.
   */
  private openTimerAlertDialogV2(): void {
    this.getUIContext()
      .getPromptAction()
      .openCustomDialog({
        builder: () => {
          this.timerAlertDialogV2()
        },
        alignment: DialogAlignment.Center
      })
      .then((id: number) => {
        this.saveDialogV2Id(id)
      })
  }

  /**
   * Shows the quick reply popover dialog.
   */
  private openQuickReplyPopoverDialogV2(): void {
    this.isQuickReplyPopoverVisible = true
  }

  /**
   * Handles the workout resume action.
   */
  private resumeWorkout(): void {
    this.lastActionText = $r('app.string.status_workout_resumed')
    this.closeDialogV2()
  }

  /**
   * Handles the workout end action.
   */
  private endWorkout(): void {
    this.lastActionText = $r('app.string.status_workout_ended')
    this.closeDialogV2()
  }

  /**
   * Enables the settings option and closes the sheet.
   */
  private enableSettings(): void {
    this.lastActionText = $r('app.string.status_reminders_enabled')
    this.isSettingsSheetVisible = false
  }

  /**
   * Cancels the settings action and closes the sheet.
   */
  private cancelSettings(): void {
    this.lastActionText = $r('app.string.status_settings_cancelled')
    this.isSettingsSheetVisible = false
  }

  /**
   * Dismisses the timer alert.
   */
  private dismissTimer(): void {
    this.lastActionText = $r('app.string.status_timer_dismissed')
    this.closeDialogV2()
  }

  /**
   * Restarts the timer alert.
   */
  private restartTimer(): void {
    this.lastActionText = $r('app.string.status_timer_restarted')
    this.closeDialogV2()
  }

  /**
   * Sends the quick reply and closes the popover.
   */
  private sendQuickReply(): void {
    this.lastActionText = $r('app.string.status_quick_reply_sent')
    this.isQuickReplyPopoverVisible = false
  }

  /**
   * Cancels the quick reply and closes the popover.
   */
  private cancelQuickReply(): void {
    this.lastActionText = $r('app.string.status_quick_reply_cancelled')
    this.isQuickReplyPopoverVisible = false
  }

  /**
   * Builds the custom body shown inside the DialogV2 workout pause menu.
   */
  @Builder
  private workoutDialogBody() {
    Column({ space: 6 }) {
      Text($r('app.string.workout_dialog_title'))
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)

      Text($r('app.string.workout_dialog_value'))
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.accent_cyan'))
        .maxLines(1)

      Text($r('app.string.workout_dialog_description'))
        .fontSize(10)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)
    }
    .width(190)
    .padding({
      top: 8,
      bottom: 4
    })
  }

  /**
   * Builds the DialogV2 workout pause menu.
   */
  @Builder
  private workoutDialogV2() {
    CustomContentDialogV2({
      contentBuilder: this.workoutDialogBody,
      buttons: [
        new AdvancedDialogV2Button({
          content: $r('app.string.action_resume'),
          action: () => {
            this.resumeWorkout()
          }
        }),
        new AdvancedDialogV2Button({
          content: $r('app.string.action_end'),
          action: () => {
            this.endWorkout()
          }
        })
      ]
    })
  }

  /**
   * Builds the Sheet Transition settings panel content.
   */
  @Builder
  private settingsSheetContent() {
    Column({ space: 10 }) {
      Text($r('app.string.settings_title'))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)

      Text($r('app.string.settings_message'))
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)

      Row({ space: 8 }) {
        Button($r('app.string.action_enable'))
          .height(32)
          .layoutWeight(1)
          .fontSize(11)
          .borderRadius(16)
          .backgroundColor($r('app.color.accent_green'))
          .onClick(() => {
            this.enableSettings()
          })

        Button($r('app.string.action_cancel'))
          .height(32)
          .layoutWeight(1)
          .fontSize(11)
          .borderRadius(16)
          .backgroundColor($r('app.color.button_secondary_background'))
          .onClick(() => {
            this.cancelSettings()
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding({
      left: 18,
      right: 18,
      top: 14,
      bottom: 16
    })
  }

  /**
   * Builds the AlertDialogV2 timer alert.
   */
  @Builder
  private timerAlertDialogV2() {
    AlertDialogV2({
      primaryTitle: $r('app.string.timer_dialog_title'),
      content: $r('app.string.timer_dialog_content'),
      primaryButton: new AdvancedDialogV2Button({
        content: $r('app.string.action_ok'),
        action: () => {
          this.dismissTimer()
        }
      }),
      secondaryButton: new AdvancedDialogV2Button({
        content: $r('app.string.action_again'),
        action: () => {
          this.restartTimer()
        }
      })
    })
  }

  /**
   * Builds a compact custom body for the quick reply popover.
   */
  @Builder
  private quickReplyBody() {
    Column({ space: 4 }) {
      Text($r('app.string.quick_reply_title'))
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)

      Text($r('app.string.quick_reply_message'))
        .fontSize(10)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)
    }
    .width(110)
  }

  /**
   * Builds the popover dialog content for quick reply.
   */
  @Builder
  private quickReplyPopoverContent() {
    CustomContentDialogV2({
      contentBuilder: this.quickReplyBody,
      contentAreaPadding: {
        start: LengthMetrics.vp(6),
        end: LengthMetrics.vp(6),
        top: LengthMetrics.vp(6),
        bottom: LengthMetrics.vp(6)
      },
      buttons: [
        new AdvancedDialogV2Button({
          content: $r('app.string.action_send'),
          action: () => {
            this.sendQuickReply()
          }
        }),
        new AdvancedDialogV2Button({
          content: $r('app.string.action_later'),
          action: () => {
            this.cancelQuickReply()
          }
        })
      ]
    })
  }

  /**
   * Builds the target component used by PopoverDialogV2.
   */
  @Builder
  private quickReplyTarget() {
    this.patternLauncher(
      $r('app.string.pattern_popover_dialog_v2'),
      $r('app.string.pattern_popover_subtitle'),
      $r('app.color.accent_blue'),
      () => {
        this.openQuickReplyPopoverDialogV2()
      }
    )
  }

  /**
   * Builds the PopoverDialogV2 launcher and binds the popover to its target.
   */
  @Builder
  private quickReplyPopoverLauncher() {
    PopoverDialogV2({
      visible: this.isQuickReplyPopoverVisible,
      $visible: (visible: boolean) => {
        this.isQuickReplyPopoverVisible = visible
      },
      popover: {
        builder: () => {
          this.quickReplyPopoverContent()
        },
        placement: Placement.Top,
        targetSpace: '2vp',
        enableArrow: false
      } as PopoverDialogV2Options,
      targetBuilder: () => {
        this.quickReplyTarget()
      }
    })
  }

  /**
   * Builds one launcher card for a dialog pattern.
   */
  @Builder
  private patternLauncher(
    title: ResourceStr,
    subtitle: ResourceStr,
    color: ResourceColor,
    action: () => void
  ) {
    Row({ space: 10 }) {
      Rect()
        .width(3)
        .height(26)
        .borderRadius(2)
        .fill(color)

      Column({ space: 2 }) {
        Text(title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(subtitle)
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text($r('app.string.card_arrow'))
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('82%')
    .height(46)
    .padding({
      left: 12,
      right: 10
    })
    .borderRadius(23)
    .backgroundColor($r('app.color.card_background'))
    .onClick(() => {
      action()
    })
  }

  /**
   * Builds the last action preview text.
   */
  @Builder
  private statusView() {
    Column({ space: 3 }) {
      Text($r('app.string.last_action_label'))
        .fontSize(10)
        .fontColor($r('app.color.text_secondary'))
        .maxLines(1)

      Text(this.lastActionText)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('82%')
    .padding({
      top: 10,
      bottom: 10,
      left: 12,
      right: 12
    })
    .borderRadius(22)
    .backgroundColor($r('app.color.status_background'))
  }

  /**
   * Builds the dialog pattern launcher list.
   */
  @Builder
  private patternList() {
    Column({ space: 10 }) {
      this.patternLauncher(
        $r('app.string.pattern_custom_dialog'),
        $r('app.string.pattern_custom_dialog_subtitle'),
        $r('app.color.accent_orange'),
        () => {
          this.openAlarmDialog()
        }
      )

      this.patternLauncher(
        $r('app.string.pattern_dialog_v2'),
        $r('app.string.pattern_dialog_v2_subtitle'),
        $r('app.color.accent_cyan'),
        () => {
          this.openWorkoutDialogV2()
        }
      )

      this.patternLauncher(
        $r('app.string.pattern_sheet_transition'),
        $r('app.string.pattern_sheet_transition_subtitle'),
        $r('app.color.accent_green'),
        () => {
          this.openSettingsSheet()
        }
      )

      this.patternLauncher(
        $r('app.string.pattern_action_sheet'),
        $r('app.string.pattern_action_sheet_subtitle'),
        $r('app.color.accent_red'),
        () => {
          this.openNotificationActionSheet()
        }
      )

      this.patternLauncher(
        $r('app.string.pattern_alert_dialog_v2'),
        $r('app.string.pattern_alert_dialog_v2_subtitle'),
        $r('app.color.accent_purple'),
        () => {
          this.openTimerAlertDialogV2()
        }
      )

      this.quickReplyPopoverLauncher()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * Builds the scrollable content for the dialog pattern demo screen.
   */
  @Builder
  private pageContent() {
    Column({ space: 14 }) {
      Text($r('app.string.dialog_lab_title'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)

      this.statusView()

      this.patternList()
    }
    .width('100%')
    .padding({
      top: 24,
      bottom: 24
    })
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * Builds the scrollable dialog pattern demo screen.
   */
  build() {
    Scroll() {
      this.pageContent()
    }
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
    .bindSheet(
      $$this.isSettingsSheetVisible,
      this.settingsSheetContent(),
      {
        height: 160,
        dragBar: true,
        backgroundColor: $r('app.color.dialog_background')
      }
    )
  }
}