# SystemUI Reticker Crash — Detached View Animation

## Symptom
SystemUI crashes once on boot (PID changes). Logcat shows:
```
FATAL EXCEPTION: main
Process: com.android.systemui
java.lang.IllegalStateException: Cannot start this animator on a detached view!
  at android.view.ViewAnimationUtils.createCircularReveal()
  at com.android.systemui.RetickerAnimations.revealAnimationHide()
  at ...NotificationPanelViewController.reTickerDismissal()
  at ...QuickSettingsController.updateExpansion()
  at ...QuickSettingsController$QsFragmentListener.onFragmentViewCreated()
```

## Root Cause
DerpFest Reticker (notification ticker) uses ViewAnimationUtils.createCircularReveal()
to animate the ticker view. During QS fragment creation, updateExpansion() triggers
reTickerDismissal() which calls revealAnimationHide().

At this point, the ticker view exists but is NOT yet attached to the window hierarchy.
createCircularReveal() requires the view to be attached — it needs a RenderNode,
which is only available after onAttachedToWindow().

## Fix
Add isAttachedToWindow() guard before createCircularReveal():
```java
if (!targetView.isAttachedToWindow()) {
    notificationStackScroller.setVisibility(View.VISIBLE);
    targetView.setVisibility(View.GONE);
    mIsAnimatingTicker = false;
    return;
}
```
Applied to both revealAnimation() and revealAnimationHide().

## Lessons
- Always check isAttachedToWindow() before createCircularReveal()
- Custom ROM UI features (Reticker, QS tiles) can crash when called during fragment lifecycle transitions
