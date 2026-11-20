using System;
using System.Collections.Generic;
using UnityEngine;
using ProbablyStolen.Port;

internal static class Program
{
    private static int assertions;

    private static void Assert(bool condition, string message)
    {
        assertions++;
        if (!condition) throw new Exception("FAIL: " + message);
    }

    private static void AssertEqual<T>(T expected, T actual, string message)
    {
        assertions++;
        if (!EqualityComparer<T>.Default.Equals(expected, actual))
            throw new Exception($"FAIL {message}: expected {expected}, got {actual}");
    }

    public static int Main()
    {
        try
        {
            // Suite 1: Core Gesture Machine State & Contacts (103 assertions)
            TestSingleTap();
            TestConsecutiveFastTaps();
            TestReleaseBeforeNextHold();
            TestNormalLongPressRightClick();
            TestHoldToConfirmLeftHold();
            TestDragEndPointAndRelease();
            TestSingleFrameLargeDisplacementRelease();
            TestTwoFingerJoinDuringDrag();
            TestTwoFingerDroppedToOneFingerNoClick();
            TestCancelAndLoseFocusNoAction();
            TestNoStuckHeldState();

            // Suite 2: Toolbar Contact Isolation & Router (21 assertions)
            TestToolbarTouchIsolation();
            TestToolbarTouchSlideOutNeverLeaks();
            TestContactRouterCancelOnFocusLoss();

            // Suite 3: Virtual Key Request / Frame Snapshot Contract (New Rework Verification)
            TestVirtualKeyHoldAndSnapshotContract();
            TestVirtualKeyPulseContract();
            TestHeldKeyPulseDoesNotRelease();
            TestHoldReleaseRepressInOneSnapshot();
            TestIndependentHoldOwnersAndSuppression();
            TestVirtualKeyResetClearsAll();
            TestReboundMouseKeySymmetry();

            // Suite 4: Scroll Delta Lifecycle & Default Zeroing (New Rework Verification)
            TestScrollDeltaZeroingAndMultiFrameLifecycle();

            // Suite 5: Toolbar Layout Calculation & SafeArea Bounds Check (New Rework Verification)
            TestToolbarLayoutSafeAreaConstraints();

            Console.WriteLine($"ALL PASS: {assertions} assertions succeeded across all gesture state machine, virtual input contract, and layout scenarios.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(ex);
            return 1;
        }
    }

    private static void TestReleaseBeforeNextHold()
    {
        var gm = new PortGestureMachine { RequiresLeftHold = p => p.x > 200 };
        var first = new Vector2(100, 100);
        var next = new Vector2(500, 100);
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = first, Phase = TouchPhase.Began } }, 0, 1);
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = first, Phase = TouchPhase.Ended } }, 0.03f, 1);
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 2, Position = next, Phase = TouchPhase.Began } }, 0.04f, 1);
        Assert(gm.Up[0] && !gm.Down[0] && !gm.Held[0], "Previous click releases before next hold presses");
        AssertEqual(first, gm.Position, "Previous release retains original target position");
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 2, Position = next, Phase = TouchPhase.Stationary } }, 0.05f, 1);
        Assert(gm.Down[0] && gm.Held[0] && !gm.Up[0], "Next hold starts on following frame");
        AssertEqual(next, gm.Position, "Next hold presses at its own target");
        AssertEqual(PortGestureMachine.Mode.LeftHold, gm.State, "Next hold keeps hold-to-confirm semantics");
    }

    // 1. 短按一次 (Tap)
    private static void TestSingleTap()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(100, 100);

        // Frame 1: Touch began
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Pending, gm.State, "Tap: F1 should be Pending");
        AssertEqual(false, gm.Held[0], "Tap: F1 mouse0 should not be held yet");

        // Frame 2: Touch ended quickly without moving
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Ended } }, 0.05f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.TapRelease, gm.State, "Tap: F2 on touch end should transition to TapRelease");
        AssertEqual(true, gm.Down[0], "Tap: F2 mouse0 down triggered");
        AssertEqual(true, gm.Held[0], "Tap: F2 mouse0 held");

        // Frame 3: Completed tap release
        gm.Step(Array.Empty<PortGestureMachine.Contact>(), 0.07f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "Tap: F3 should return to Idle");
        AssertEqual(true, gm.Up[0], "Tap: F3 mouse0 up triggered");
        AssertEqual(false, gm.Held[0], "Tap: F3 mouse0 held false");
    }

    // 2. 快速连续两次短按 (Fast consecutive double tap,新接触在TapRelease帧按下)
    private static void TestConsecutiveFastTaps()
    {
        var gm = new PortGestureMachine();
        var p1 = new Vector2(100, 100);
        var p2 = new Vector2(102, 101);

        // Tap 1 down
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        // Tap 1 ended
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Ended } }, 0.03f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.TapRelease, gm.State, "DoubleTap: F2 in TapRelease");
        AssertEqual(true, gm.Down[0], "DoubleTap: F2 down[0]");

        // Frame 3: TapRelease frame where Finger 2 is already down (active == 1)!
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 2, Position = p2, Phase = TouchPhase.Began } }, 0.05f, 1.0f);
        AssertEqual(true, gm.Up[0], "DoubleTap: F3 tap 1 finishes with mouse0 Up");
        AssertEqual(false, gm.Held[0], "DoubleTap: F3 tap 1 released");
        AssertEqual(PortGestureMachine.Mode.Pending, gm.State, "DoubleTap: F3 seamlessly transitions to Pending for tap 2");

        // Frame 4: Finger 2 ended
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 2, Position = p2, Phase = TouchPhase.Ended } }, 0.08f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.TapRelease, gm.State, "DoubleTap: F4 tap 2 ended -> TapRelease");
        AssertEqual(true, gm.Down[0], "DoubleTap: F4 tap 2 mouse0 down");

        // Frame 5: Finger 2 released
        gm.Step(Array.Empty<PortGestureMachine.Contact>(), 0.10f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "DoubleTap: F5 tap 2 complete -> Idle");
        AssertEqual(true, gm.Up[0], "DoubleTap: F5 tap 2 mouse0 up");
        AssertEqual(false, gm.Held[0], "DoubleTap: F5 mouse0 no longer held");
    }

    // 3. 普通长按只产生右键 (Long press generates only Right Click)
    private static void TestNormalLongPressRightClick()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(200, 200);

        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Pending, gm.State, "LongPress: F1 Pending");

        // Still pending before LongPressSeconds (0.4s)
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Stationary } }, 0.35f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Pending, gm.State, "LongPress: F2 still Pending before 0.4s");
        AssertEqual(false, gm.Held[0], "LongPress: F2 no left hold");
        AssertEqual(false, gm.Held[1], "LongPress: F2 no right hold yet");

        // Exceeds 0.4s: transitions to Mode.Right
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Stationary } }, 0.45f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Right, gm.State, "LongPress: F3 should transition to Right");
        AssertEqual(true, gm.Down[1], "LongPress: F3 Right button down triggered");
        AssertEqual(true, gm.Held[1], "LongPress: F3 Right button held");
        AssertEqual(false, gm.Held[0], "LongPress: F3 Left button must never be pressed");

        // Finger ends
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Ended } }, 0.60f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "LongPress: F4 finger up -> Idle");
        AssertEqual(true, gm.Up[1], "LongPress: F4 Right button up triggered");
        AssertEqual(false, gm.Held[1], "LongPress: F4 Right button held cleared");
        AssertEqual(false, gm.Held[0], "LongPress: F4 Left button held still false");
    }

    // 4. 需要确认的左键长按 (RequiresLeftHold -> LeftHold, no Right Click)
    private static void TestHoldToConfirmLeftHold()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(300, 300);
        gm.RequiresLeftHold = pos => pos == p0;

        // F1: Touch began on confirm button -> immediately enters LeftHold and presses Mouse0!
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.LeftHold, gm.State, "HoldToConfirm: F1 enters LeftHold immediately");
        AssertEqual(true, gm.Down[0], "HoldToConfirm: F1 Left button down triggered");
        AssertEqual(true, gm.Held[0], "HoldToConfirm: F1 Left button held");

        // F2: Holding long past 0.4s: MUST NOT trigger Right click!
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Stationary } }, 0.8f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.LeftHold, gm.State, "HoldToConfirm: F2 still in LeftHold after 0.8s");
        AssertEqual(false, gm.Held[1], "HoldToConfirm: F2 Right button must never be pressed");
        AssertEqual(true, gm.Held[0], "HoldToConfirm: F2 Left button still held");

        // F3: Finger release -> DragRelease
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Ended } }, 1.25f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.DragRelease, gm.State, "HoldToConfirm: F3 enters DragRelease");
        AssertEqual(true, gm.Held[0], "HoldToConfirm: F3 still held on ended frame");

        // F4: DragRelease completes -> Mouse0 Up
        gm.Step(Array.Empty<PortGestureMachine.Contact>(), 1.26f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "HoldToConfirm: F4 returns to Idle");
        AssertEqual(true, gm.Up[0], "HoldToConfirm: F4 Left button up triggered to complete confirm");
        AssertEqual(false, gm.Held[0], "HoldToConfirm: F4 Left button released");
    }

    // 5. 拖动终点再释放 (Drag to end point and release)
    private static void TestDragEndPointAndRelease()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(100, 100);
        var p1 = new Vector2(110, 100); // 10 points > 8 drag points
        var p2 = new Vector2(200, 200);

        // F1: began
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Pending, gm.State, "Drag: F1 Pending");

        // F2: moved past drag threshold -> Drag started at origin
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Moved } }, 0.05f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Drag, gm.State, "Drag: F2 enters Drag");
        AssertEqual(p0, gm.Position, "Drag: F2 position is origin on drag start frame");
        AssertEqual(true, gm.Down[0], "Drag: F2 Left button down triggered");

        // F3: dragging to destination p2
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p2, Phase = TouchPhase.Moved } }, 0.10f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Drag, gm.State, "Drag: F3 in Drag");
        AssertEqual(p2, gm.Position, "Drag: F3 position is p2");
        AssertEqual(true, gm.Held[0], "Drag: F3 Left button still held");

        // F4: touch ended at p2
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p2, Phase = TouchPhase.Ended } }, 0.15f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.DragRelease, gm.State, "Drag: F4 on ended enters DragRelease");
        AssertEqual(p2, gm.Position, "Drag: F4 position at p2");
        AssertEqual(true, gm.Held[0], "Drag: F4 Left button still held at drop position");

        // F5: DragRelease frame -> Mouse0 Up at destination p2
        gm.Step(Array.Empty<PortGestureMachine.Contact>(), 0.16f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "Drag: F5 returns to Idle");
        AssertEqual(true, gm.Up[0], "Drag: F5 mouse0 up fired");
        AssertEqual(p2, gm.Position, "Drag: F5 drop position remains p2");
    }

    // 6. 单帧大位移后松手 (Single frame fling/large displacement release)
    private static void TestSingleFrameLargeDisplacementRelease()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(50, 50);
        var pDest = new Vector2(150, 150);

        // F1: Touch began
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Pending, gm.State, "Fling: F1 Pending");

        // F2: Ended with large distance in single stroke -> DragFinalMove
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = pDest, Phase = TouchPhase.Ended } }, 0.04f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.DragFinalMove, gm.State, "Fling: F2 enters DragFinalMove");
        AssertEqual(p0, gm.Position, "Fling: F2 origin position on press");
        AssertEqual(true, gm.Down[0], "Fling: F2 down triggered");

        // F3: DragFinalMove moves to finalPosition then enters DragRelease
        gm.Step(Array.Empty<PortGestureMachine.Contact>(), 0.06f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.DragRelease, gm.State, "Fling: F3 enters DragRelease");
        AssertEqual(pDest, gm.Position, "Fling: F3 moved to final destination");
        AssertEqual(pDest - p0, gm.Delta, "Fling: F3 delta calculated");
        AssertEqual(true, gm.Held[0], "Fling: F3 still held before release");

        // F4: DragRelease releases mouse0
        gm.Step(Array.Empty<PortGestureMachine.Contact>(), 0.08f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "Fling: F4 Idle");
        AssertEqual(true, gm.Up[0], "Fling: F4 mouse0 up triggered");
        AssertEqual(pDest, gm.Position, "Fling: F4 release position at destination");
    }

    // 7. 拖动中双指加入 (Two-finger joined during drag)
    private static void TestTwoFingerJoinDuringDrag()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(100, 100);
        var p1 = new Vector2(120, 100);
        var p2 = new Vector2(180, 100);

        // Drag active
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Moved } }, 0.05f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Drag, gm.State, "TwoFingerJoin: in Drag");
        AssertEqual(true, gm.Held[0], "TwoFingerJoin: mouse0 held");

        // Second finger joins!
        gm.Step(new[] {
            new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Moved },
            new PortGestureMachine.Contact { Id = 2, Position = p2, Phase = TouchPhase.Began }
        }, 0.08f, 1.0f);

        AssertEqual(PortGestureMachine.Mode.Dual, gm.State, "TwoFingerJoin: enters Dual");
        AssertEqual(true, gm.TwoFinger, "TwoFingerJoin: TwoFinger flag true");
        AssertEqual(true, gm.Cancelled, "TwoFingerJoin: Cancelled flag set to abort single finger actions");
        AssertEqual(false, gm.Held[0], "TwoFingerJoin: mouse0 held MUST be cancelled");
        AssertEqual(false, gm.Held[1], "TwoFingerJoin: mouse1 held false");
    }

    // 8. 双指剩一指 (Dropping from 2 fingers to 1 finger MUST NOT click)
    private static void TestTwoFingerDroppedToOneFingerNoClick()
    {
        var gm = new PortGestureMachine();
        var f1 = new Vector2(100, 100);
        var f2 = new Vector2(200, 200);

        // Start in dual
        gm.Step(new[] {
            new PortGestureMachine.Contact { Id = 1, Position = f1, Phase = TouchPhase.Began },
            new PortGestureMachine.Contact { Id = 2, Position = f2, Phase = TouchPhase.Began }
        }, 0.0f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Dual, gm.State, "DropToOne: Dual mode");

        // One finger lifts, one remains active!
        gm.Step(new[] {
            new PortGestureMachine.Contact { Id = 1, Position = f1, Phase = TouchPhase.Moved }
        }, 0.05f, 1.0f);

        // Must enter Blocked, NEVER trigger click/press!
        AssertEqual(PortGestureMachine.Mode.Blocked, gm.State, "DropToOne: must enter Blocked mode");
        AssertEqual(false, gm.Held[0], "DropToOne: no mouse0 held");
        AssertEqual(false, gm.Down[0], "DropToOne: no mouse0 down");
        AssertEqual(false, gm.Held[1], "DropToOne: no mouse1 held");

        // Remaining finger moves around in Blocked state
        gm.Step(new[] {
            new PortGestureMachine.Contact { Id = 1, Position = new Vector2(150, 150), Phase = TouchPhase.Moved }
        }, 0.10f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Blocked, gm.State, "DropToOne: remains Blocked while finger moves");
        AssertEqual(false, gm.Down[0], "DropToOne: still no down");

        // Remaining finger lifts
        gm.Step(new[] {
            new PortGestureMachine.Contact { Id = 1, Position = new Vector2(150, 150), Phase = TouchPhase.Ended }
        }, 0.15f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "DropToOne: returns to Idle when all fingers are up");
        AssertEqual(false, gm.Down[0], "DropToOne: no down on release");
        AssertEqual(false, gm.Up[0], "DropToOne: no up on release");
    }

    // 9. 取消/失焦不提交动作 (Cancellation and Focus loss)
    private static void TestCancelAndLoseFocusNoAction()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(100, 100);
        var p1 = new Vector2(150, 150);

        // Dragging an item
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Moved } }, 0.05f, 1.0f);
        AssertEqual(PortGestureMachine.Mode.Drag, gm.State, "Cancel: in Drag");
        AssertEqual(true, gm.Held[0], "Cancel: held");

        // System interrupts with CancelRequested (e.g. OnApplicationFocus(false))
        gm.Cancel();
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Moved } }, 0.08f, 1.0f);
        AssertEqual(true, gm.Cancelled, "Cancel: Cancelled flag set");
        AssertEqual(false, gm.Held[0], "Cancel: Held[0] cleared immediately");
        AssertEqual(PortGestureMachine.Mode.Blocked, gm.State, "Cancel: in Blocked state because finger still on screen");

        // Finger lifts afterwards: MUST NOT trigger click or drop
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p1, Phase = TouchPhase.Ended } }, 0.10f, 1.0f);
        AssertEqual(false, gm.Held[0], "Cancel: not held on lift");
        AssertEqual(false, gm.Down[0], "Cancel: no down");
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "Cancel: Idle after lift");
    }

    // 10. 不残留 Held (Verify no scenario leaves stuck Held flags)
    private static void TestNoStuckHeldState()
    {
        var gm = new PortGestureMachine();
        var p0 = new Vector2(100, 100);

        // Case A: Primary contact suddenly lost without Ended phase
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = p0, Phase = TouchPhase.Began } }, 0.0f, 1.0f);
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 1, Position = new Vector2(120, 100), Phase = TouchPhase.Moved } }, 0.05f, 1.0f);
        AssertEqual(true, gm.Held[0], "NoStuck: Drag held");

        // Frame: Finger 1 disappears, empty contacts
        gm.Step(Array.Empty<PortGestureMachine.Contact>(), 0.08f, 1.0f);
        AssertEqual(false, gm.Held[0], "NoStuck: Held[0] must be false when finger lost");
        AssertEqual(false, gm.Held[1], "NoStuck: Held[1] false");
        AssertEqual(false, gm.Held[2], "NoStuck: Held[2] false");
        AssertEqual(PortGestureMachine.Mode.Idle, gm.State, "NoStuck: State returns to Idle");

        // Case B: TouchPhase.Canceled
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 5, Position = p0, Phase = TouchPhase.Began } }, 0.10f, 1.0f);
        gm.Step(new[] { new PortGestureMachine.Contact { Id = 5, Position = p0, Phase = TouchPhase.Canceled } }, 0.12f, 1.0f);
        AssertEqual(false, gm.Held[0], "NoStuck: Held[0] false on Canceled");
        AssertEqual(false, gm.Held[1], "NoStuck: Held[1] false on Canceled");
        AssertEqual(false, gm.Held[2], "NoStuck: Held[2] false on Canceled");
    }

    private static void TestToolbarTouchIsolation()
    {
        var router = new PortContactRouter();
        var gm = new PortGestureMachine();
        PortTouchControl.Controls.Clear();

        var control = (PortTouchControl)System.Runtime.Serialization.FormatterServices.GetUninitializedObject(typeof(PortTouchControl));
        control.CustomContains = p => p.x >= 0 && p.x <= 100 && p.y >= 0 && p.y <= 50;
        bool pressed = false;
        bool clicked = false;
        bool released = false;
        control.Pressed = () => pressed = true;
        control.Clicked = () => clicked = true;
        control.Released = () => released = true;
        PortTouchControl.Controls.Add(control);

        var touches = new List<PortContact>();
        var gameTouches = new List<PortContact>();

        // Step 1: Touch 1 begins on game canvas (x=500, y=500)
        touches.Add(new PortContact(1, new Vector2(500, 500), TouchPhase.Began));
        router.Filter(touches, gameTouches);
        AssertEqual(1, gameTouches.Count, "Game touch passed through");
        AssertEqual(1, gameTouches[0].Id, "Touch 1 is in game touches");
        gm.Step(gameTouches, 0f, 1f);

        // Drag finger 1 to move item
        touches.Clear();
        touches.Add(new PortContact(1, new Vector2(520, 500), TouchPhase.Moved));
        router.Filter(touches, gameTouches);
        gm.Step(gameTouches, 0.05f, 1f);
        AssertEqual(true, gm.Held[0], "Finger 1 dragging item");

        // Step 2: Touch 2 begins ON THE TOOLBAR (x=50, y=25)
        touches.Clear();
        touches.Add(new PortContact(1, new Vector2(525, 500), TouchPhase.Moved));
        touches.Add(new PortContact(2, new Vector2(50, 25), TouchPhase.Began));
        router.Filter(touches, gameTouches);

        AssertEqual(1, gameTouches.Count, "Toolbar touch 2 intercepted, only 1 touch in game");
        AssertEqual(1, gameTouches[0].Id, "Only finger 1 reaches game");
        AssertEqual(true, pressed, "Control pressed on touch began");

        // Step the gesture machine: MUST NOT consider this two fingers!
        gm.Step(gameTouches, 0.08f, 1f);
        AssertEqual(false, gm.TwoFinger, "Toolbar touch must NOT trigger two-finger mode in game");
        AssertEqual(false, gm.Cancelled, "Toolbar touch must NOT cancel ongoing item drag");
        AssertEqual(true, gm.Held[0], "Finger 1 remains held/dragging");

        // Step 3: Touch 2 lifts on toolbar
        touches.Clear();
        touches.Add(new PortContact(1, new Vector2(530, 500), TouchPhase.Moved));
        touches.Add(new PortContact(2, new Vector2(50, 25), TouchPhase.Ended));
        router.Filter(touches, gameTouches);
        AssertEqual(1, gameTouches.Count, "Touch 2 lift intercepted by router");
        AssertEqual(true, released, "Control released on touch ended");
        AssertEqual(true, clicked, "Control clicked");

        PortTouchControl.Controls.Clear();
    }

    private static void TestToolbarTouchSlideOutNeverLeaks()
    {
        var router = new PortContactRouter();
        PortTouchControl.Controls.Clear();

        var control = (PortTouchControl)System.Runtime.Serialization.FormatterServices.GetUninitializedObject(typeof(PortTouchControl));
        control.CustomContains = p => p.x >= 0 && p.x <= 100 && p.y >= 0 && p.y <= 50;
        bool clicked = false;
        control.Clicked = () => clicked = true;
        PortTouchControl.Controls.Add(control);

        var touches = new List<PortContact>();
        var gameTouches = new List<PortContact>();

        // Began inside toolbar button
        touches.Add(new PortContact(1, new Vector2(50, 25), TouchPhase.Began));
        router.Filter(touches, gameTouches);
        AssertEqual(0, gameTouches.Count, "Intercepted at Began");

        // Finger slides far outside the toolbar (x=800, y=800)
        touches.Clear();
        touches.Add(new PortContact(1, new Vector2(800, 800), TouchPhase.Moved));
        router.Filter(touches, gameTouches);
        AssertEqual(0, gameTouches.Count, "Slide-out does NOT leak into game touches");

        // Finger lifts outside
        touches.Clear();
        touches.Add(new PortContact(1, new Vector2(800, 800), TouchPhase.Ended));
        router.Filter(touches, gameTouches);
        AssertEqual(0, gameTouches.Count, "Lift does not leak into game touches");
        AssertEqual(false, clicked, "Cancelled slide-out does not trigger button click");

        // Next touch from this fingerId in game canvas is now free to act as game touch
        touches.Clear();
        touches.Add(new PortContact(1, new Vector2(500, 500), TouchPhase.Began));
        router.Filter(touches, gameTouches);
        AssertEqual(1, gameTouches.Count, "New touch correctly passed to game");

        PortTouchControl.Controls.Clear();
    }

    private static void TestContactRouterCancelOnFocusLoss()
    {
        var router = new PortContactRouter();
        PortTouchControl.Controls.Clear();

        var control = (PortTouchControl)System.Runtime.Serialization.FormatterServices.GetUninitializedObject(typeof(PortTouchControl));
        control.CustomContains = p => p.x >= 0 && p.x <= 100 && p.y >= 0 && p.y <= 50;
        bool released = false;
        control.Released = () => released = true;
        PortTouchControl.Controls.Add(control);

        var touches = new List<PortContact>();
        var gameTouches = new List<PortContact>();

        touches.Add(new PortContact(3, new Vector2(50, 25), TouchPhase.Began));
        router.Filter(touches, gameTouches);
        AssertEqual(0, gameTouches.Count, "Held by router");

        // App loses focus -> Cancel()
        router.Cancel();
        AssertEqual(true, released, "Control released on router cancel");

        // Finger 3 still physically on screen, moving: MUST NOT leak to game touches!
        touches.Clear();
        touches.Add(new PortContact(3, new Vector2(60, 25), TouchPhase.Moved));
        router.Filter(touches, gameTouches);
        AssertEqual(0, gameTouches.Count, "After cancel, held finger does NOT leak to game");

        // Finger 3 lifts: cleans up
        touches.Clear();
        touches.Add(new PortContact(3, new Vector2(60, 25), TouchPhase.Ended));
        router.Filter(touches, gameTouches);
        AssertEqual(0, gameTouches.Count, "Lift cleans up cleanly");

        PortTouchControl.Controls.Clear();
    }

    private static void TestHeldKeyPulseDoesNotRelease()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();
        PortInput.HoldKey(KeyCode.B, true);
        PortInput.SnapshotKeys();
        PortInput.PulseKey(KeyCode.B);
        PortInput.SnapshotKeys();
        PortInput.SnapshotKeys();
        Assert(PortInput.GetKey(KeyCode.B), "Pulse expiry must preserve an existing hold");
        Assert(!PortInput.GetKeyUp(KeyCode.B), "Pulse expiry must not emit Up while key is still held");
        PortInput.Reset();
    }

    private static void TestIndependentHoldOwnersAndSuppression()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();
        var transfer = new object(); var customer = new object();
        PortInput.HoldKey(transfer, KeyCode.B, true);
        PortInput.HoldKey(customer, KeyCode.B, true);
        PortInput.SnapshotKeys();
        Assert(PortInput.GetKeyDown(KeyCode.B), "Two owners produce one initial press");
        PortInput.HoldKey(transfer, KeyCode.B, false);
        PortInput.SnapshotKeys();
        Assert(PortInput.GetKey(KeyCode.B) && !PortInput.GetKeyUp(KeyCode.B), "Other owner keeps key held");
        PortInput.HoldKey(customer, KeyCode.B, false);
        PortInput.SnapshotKeys();
        Assert(!PortInput.GetKey(KeyCode.B) && PortInput.GetKeyUp(KeyCode.B), "Last owner releases key");
        PortInput.HoldKey(transfer, KeyCode.B, true);
        PortInput.PulseKey(KeyCode.Escape);
        PortInput.IsTypingSuppressed = () => true;
        PortInput.SnapshotKeys();
        Assert(!PortInput.GetKey(KeyCode.B) && !PortInput.GetKeyDown(KeyCode.Escape), "Suppression discards pending requests");
        PortInput.IsTypingSuppressed = () => false;
        PortInput.SnapshotKeys();
        Assert(!PortInput.GetKey(KeyCode.B) && !PortInput.GetKeyDown(KeyCode.Escape), "Discarded requests never resume later");
        PortInput.Reset();
    }

    private static void TestHoldReleaseRepressInOneSnapshot()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();
        PortInput.HoldKey(KeyCode.B, true);
        PortInput.SnapshotKeys();
        PortInput.HoldKey(KeyCode.B, false);
        PortInput.HoldKey(KeyCode.B, true);
        PortInput.SnapshotKeys();
        Assert(PortInput.GetKey(KeyCode.B), "Release then repress before snapshot must end held");
        Assert(!PortInput.GetKeyUp(KeyCode.B), "Repress must cancel the pending release");
        PortInput.Reset();
    }

    private static void TestVirtualKeyHoldAndSnapshotContract()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();

        // Frame 1: Key pressed/held before SnapshotKeys (e.g. NextCustomer pressed)
        PortInput.HoldKey(KeyCode.B, true);
        PortInput.SnapshotKeys();

        // Game Update queries in Frame 1:
        AssertEqual(true, PortInput.GetKeyDown(KeyCode.B), "Frame 1: GetKeyDown(B) promoted by snapshot, not wiped");
        AssertEqual(true, PortInput.GetKey(KeyCode.B), "Frame 1: GetKey(B) true");
        AssertEqual(false, PortInput.GetKeyUp(KeyCode.B), "Frame 1: GetKeyUp(B) false");

        // Frame 2: Still held, next snapshot advances
        PortInput.SnapshotKeys();
        AssertEqual(false, PortInput.GetKeyDown(KeyCode.B), "Frame 2: GetKeyDown(B) exposed for exactly 1 frame");
        AssertEqual(true, PortInput.GetKey(KeyCode.B), "Frame 2: GetKey(B) remains true while held");
        AssertEqual(false, PortInput.GetKeyUp(KeyCode.B), "Frame 2: GetKeyUp(B) false");

        // Frame 3: Key released before snapshot
        PortInput.HoldKey(KeyCode.B, false);
        PortInput.SnapshotKeys();
        AssertEqual(false, PortInput.GetKeyDown(KeyCode.B), "Frame 3: GetKeyDown(B) false on release");
        AssertEqual(false, PortInput.GetKey(KeyCode.B), "Frame 3: GetKey(B) false on release");
        AssertEqual(true, PortInput.GetKeyUp(KeyCode.B), "Frame 3: GetKeyUp(B) exposed for exactly 1 frame");

        // Frame 4: Next frame after release
        PortInput.SnapshotKeys();
        AssertEqual(false, PortInput.GetKeyUp(KeyCode.B), "Frame 4: GetKeyUp(B) retired");
    }

    private static void TestVirtualKeyPulseContract()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();

        // Frame 1: Pulse registered (e.g. Back/Escape pulse)
        PortInput.PulseKey(KeyCode.Escape);
        PortInput.SnapshotKeys();

        AssertEqual(true, PortInput.GetKeyDown(KeyCode.Escape), "Pulse Frame 1: GetKeyDown true");
        AssertEqual(true, PortInput.GetKey(KeyCode.Escape), "Pulse Frame 1: GetKey true");
        AssertEqual(false, PortInput.GetKeyUp(KeyCode.Escape), "Pulse Frame 1: GetKeyUp false");

        // Frame 2: Active pulse transitions to Up
        PortInput.SnapshotKeys();
        AssertEqual(false, PortInput.GetKeyDown(KeyCode.Escape), "Pulse Frame 2: GetKeyDown false");
        AssertEqual(false, PortInput.GetKey(KeyCode.Escape), "Pulse Frame 2: GetKey false");
        AssertEqual(true, PortInput.GetKeyUp(KeyCode.Escape), "Pulse Frame 2: GetKeyUp true");

        // Frame 3: Retired
        PortInput.SnapshotKeys();
        AssertEqual(false, PortInput.GetKeyDown(KeyCode.Escape), "Pulse Frame 3: GetKeyDown false");
        AssertEqual(false, PortInput.GetKey(KeyCode.Escape), "Pulse Frame 3: GetKey false");
        AssertEqual(false, PortInput.GetKeyUp(KeyCode.Escape), "Pulse Frame 3: GetKeyUp false");
    }

    private static void TestVirtualKeyResetClearsAll()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();

        PortInput.HoldKey(KeyCode.B, true);
        PortInput.PulseKey(KeyCode.Escape);
        PortInput.Reset(); // Focus loss / Scene switch cancel

        PortInput.SnapshotKeys();
        AssertEqual(false, PortInput.GetKeyDown(KeyCode.B), "Reset: B Down must be false");
        AssertEqual(false, PortInput.GetKey(KeyCode.B), "Reset: B Held must be false");
        AssertEqual(false, PortInput.GetKeyDown(KeyCode.Escape), "Reset: Escape Down must be false");
        AssertEqual(false, PortInput.GetKey(KeyCode.Escape), "Reset: Escape Held must be false");
        AssertEqual(false, PortInput.GetKeyUp(KeyCode.Escape), "Reset: Escape Up must be false");
    }

    private static void TestReboundMouseKeySymmetry()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();

        // Rebound hotkey triggers Mouse1 (Right click) pulse
        PortInput.PulseKey(KeyCode.Mouse1);
        PortInput.SnapshotKeys();

        // Must be visible both through GetMouseButtonDown(1) and GetKeyDown(KeyCode.Mouse1)
        AssertEqual(true, PortInput.GetMouseButtonDown(1), "Mouse1 symmetry: GetMouseButtonDown(1) true");
        AssertEqual(true, PortInput.GetKeyDown(KeyCode.Mouse1), "Mouse1 symmetry: GetKeyDown(Mouse1) true");
        AssertEqual(true, PortInput.GetMouseButton(1), "Mouse1 symmetry: GetMouseButton(1) true");
        AssertEqual(true, PortInput.GetKey(KeyCode.Mouse1), "Mouse1 symmetry: GetKey(Mouse1) true");

        // Frame 2: Up frame
        PortInput.SnapshotKeys();
        AssertEqual(true, PortInput.GetMouseButtonUp(1), "Mouse1 symmetry: GetMouseButtonUp(1) true");
        AssertEqual(true, PortInput.GetKeyUp(KeyCode.Mouse1), "Mouse1 symmetry: GetKeyUp(Mouse1) true");
        AssertEqual(false, PortInput.GetMouseButtonDown(1), "Mouse1 symmetry: GetMouseButtonDown(1) false");
        AssertEqual(false, PortInput.GetKeyDown(KeyCode.Mouse1), "Mouse1 symmetry: GetKeyDown(Mouse1) false");
    }

    private static void TestScrollDeltaZeroingAndMultiFrameLifecycle()
    {
        PortInput.ActiveProvider = () => true;
        PortInput.Reset();

        // Frame 1: Non-zero scroll generated by gesture
        PortInput.mouseScrollDelta = new Vector2(0f, 1f);
        AssertEqual(new Vector2(0f, 1f), PortInput.mouseScrollDelta, "Scroll F1: scroll delta is (0, 1)");

        // Frame 2: TouchInputBridge resets scroll delta at start of frame, fingers stationary
        PortInput.ResetScroll();
        AssertEqual(Vector2.zero, PortInput.mouseScrollDelta, "Scroll F2: stationary fingers zero scroll delta");

        // Frame 3: Next frame without motion
        PortInput.ResetScroll();
        AssertEqual(Vector2.zero, PortInput.mouseScrollDelta, "Scroll F3: scroll delta remains zero across multiple frames");
    }

    private static void TestToolbarLayoutSafeAreaConstraints()
    {
        // Scenario 1: iPhone 15 Pro Max Landscape (2796 x 1290) with Dynamic Island / Home Indicator
        // safeArea: xMin=132, xMax=2664, yMin=63, yMax=1290, width=2532, height=1227
        var saMax = new Rect(132f, 63f, 2532f, 1227f);
        float scaleMax = 3.0f;
        int totalMax = 20;

        for (int i = 0; i < totalMax; i++)
        {
            PortTouchLayout.CalculateButtonRect(saMax, scaleMax, i, totalMax, out var size, out var pos, out var fontSize);

            // Check font scaling
            AssertEqual(18f * scaleMax, fontSize, $"Max layout: button {i} fontSize scaled to {18f * scaleMax}");

            // Check 4-sided bounds
            float left = pos.x;
            float right = pos.x + size.x;
            float bottom = pos.y;
            float top = pos.y + size.y;

            Assert(left >= saMax.xMin - 0.01f, $"Max layout: button {i} left ({left}) inside safeArea.xMin ({saMax.xMin})");
            Assert(right <= saMax.xMax + 0.01f, $"Max layout: button {i} right ({right}) inside safeArea.xMax ({saMax.xMax})");
            Assert(bottom >= saMax.yMin - 0.01f, $"Max layout: button {i} bottom ({bottom}) inside safeArea.yMin ({saMax.yMin})");
            Assert(top <= saMax.yMax + 0.01f, $"Max layout: button {i} top ({top}) inside safeArea.yMax ({saMax.yMax})");
        }

        // Scenario 2: iPhone SE / 8 Landscape (1334 x 750), scale = 2.0f
        var saSE = new Rect(44f, 0f, 1246f, 750f);
        float scaleSE = 2.0f;
        int totalSE = 14;

        for (int i = 0; i < totalSE; i++)
        {
            PortTouchLayout.CalculateButtonRect(saSE, scaleSE, i, totalSE, out var size, out var pos, out var fontSize);
            AssertEqual(18f * scaleSE, fontSize, $"SE layout: button {i} fontSize scaled to {18f * scaleSE}");

            float left = pos.x;
            float right = pos.x + size.x;
            float bottom = pos.y;
            float top = pos.y + size.y;

            Assert(left >= saSE.xMin - 0.01f, $"SE layout: button {i} left ({left}) inside safeArea.xMin ({saSE.xMin})");
            Assert(right <= saSE.xMax + 0.01f, $"SE layout: button {i} right ({right}) inside safeArea.xMax ({saSE.xMax})");
            Assert(bottom >= saSE.yMin - 0.01f, $"SE layout: button {i} bottom ({bottom}) inside safeArea.yMin ({saSE.yMin})");
            Assert(top <= saSE.yMax + 0.01f, $"SE layout: button {i} top ({top}) inside safeArea.yMax ({saSE.yMax})");
        }

        // Scenario 3: Small compact resolution (800 x 600), scale = 1.0f
        var saSmall = new Rect(0f, 0f, 800f, 600f);
        float scaleSmall = 1.0f;
        int totalSmall = 7;

        for (int i = 0; i < totalSmall; i++)
        {
            PortTouchLayout.CalculateButtonRect(saSmall, scaleSmall, i, totalSmall, out var size, out var pos, out var fontSize);
            AssertEqual(18f * scaleSmall, fontSize, $"Small layout: button {i} fontSize scaled to {18f * scaleSmall}");

            float left = pos.x;
            float right = pos.x + size.x;
            float bottom = pos.y;
            float top = pos.y + size.y;

            Assert(left >= saSmall.xMin - 0.01f, $"Small layout: button {i} left ({left}) inside safeArea.xMin ({saSmall.xMin})");
            Assert(right <= saSmall.xMax + 0.01f, $"Small layout: button {i} right ({right}) inside safeArea.xMax ({saSmall.xMax})");
            Assert(bottom >= saSmall.yMin - 0.01f, $"Small layout: button {i} bottom ({bottom}) inside safeArea.yMin ({saSmall.yMin})");
            Assert(top <= saSmall.yMax + 0.01f, $"Small layout: button {i} top ({top}) inside safeArea.yMax ({saSmall.yMax})");
        }
    }
}
