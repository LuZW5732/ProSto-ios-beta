using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

namespace ProbablyStolen.Port
{
    [DefaultExecutionOrder(-10000)]
    public sealed class TouchInputBridge : MonoBehaviour
    {
        public static TouchInputBridge Instance { get; private set; }
        internal readonly PortGestureMachine Gestures = new PortGestureMachine();
        internal readonly PortContactRouter ContactRouter = new PortContactRouter();
        internal readonly PortTwoFingerRouter TwoFinger = new PortTwoFingerRouter();
        public PortTouchToolbar Toolbar { get; private set; }

        public float PixelsPerPoint => Mathf.Max(1f, Screen.dpi / 163f);
        internal Vector2 Scroll { get; private set; }

        private readonly List<PortContact> contacts = new List<PortContact>();
        private readonly List<PortContact> gameContacts = new List<PortContact>();
        private readonly List<RaycastResult> hits = new List<RaycastResult>();
        private bool previousSimulation;
        private EventSystem installedSystem;

#if UNITY_IOS && !UNITY_EDITOR
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
#endif
        private static void Bootstrap()
        {
            if (Instance == null) new GameObject("iOS Touch Input").AddComponent<TouchInputBridge>();
        }

        private void Awake()
        {
            if (Instance != null && Instance != this) { Destroy(gameObject); return; }
            Instance = this;
            DontDestroyOnLoad(gameObject);
            previousSimulation = UnityEngine.Input.simulateMouseWithTouches;
            UnityEngine.Input.simulateMouseWithTouches = false;
            UnityEngine.Input.multiTouchEnabled = true;

            PortInput.FrameProvider = () => Gestures;
            PortInput.ActiveProvider = () => Instance != null;
            PortInput.IsTypingSuppressed = () => StoreUIManager.IsAnyTyping() || KeyBindHelper.SuppressHotkeys;
            PortInput.ResolveActionKey = KeyBindHelper.Get;

            Gestures.RequiresLeftHold = RequiresLeftHold;
            Toolbar = gameObject.AddComponent<PortTouchToolbar>();

            SceneManager.sceneLoaded += SceneLoaded;
        }

        private void SceneLoaded(Scene scene, LoadSceneMode mode)
        {
            ResetState();
            installedSystem = null;
        }

        private void OnApplicationFocus(bool value)
        {
            if (!value) ResetState();
        }

        private void OnApplicationPause(bool value)
        {
            if (value) ResetState();
        }

        private void OnDestroy()
        {
            if (Instance != this) return;
            SceneManager.sceneLoaded -= SceneLoaded;
            UnityEngine.Input.simulateMouseWithTouches = previousSimulation;
            ResetState();
            Instance = null;
        }

        public void ResetState()
        {
            Gestures.Cancel();
            ContactRouter.Cancel();
            TwoFinger.Reset();
            Toolbar?.ResetState();
            PortInput.Reset();

            if (installedSystem != null)
            {
                var module = installedSystem.GetComponent<PortStandaloneInputModule>();
                module?.CancelPointers();
            }
        }

        private bool RequiresLeftHold(Vector2 position)
        {
            if (EventSystem.current == null || Interactable.isPaused) return false;
            hits.Clear();
            EventSystem.current.RaycastAll(new PointerEventData(EventSystem.current) { position = position }, hits);
            if (hits.Count == 0) return false;
            var target = hits[0].gameObject.GetComponentInParent<Interactable>();
            return target != null && target.isAvailable && !target.isControlable &&
                target.TryGetComponent<IHoldClickable>(out var hold) && hold.ShouldRequireHold();
        }

        private void Update()
        {
            InstallUI();

            // Reset scroll delta at start of frame
            PortInput.ResetScroll();

            contacts.Clear();
            for (int i = 0; i < UnityEngine.Input.touchCount; i++)
            {
                var touch = UnityEngine.Input.GetTouch(i);
                contacts.Add(new PortContact(touch.fingerId, touch.position, touch.phase));
            }

            // Step 1: Filter raw contacts - toolbar controls intercept their touches completely
            ContactRouter.Filter(contacts, gameContacts);

            // Step 2: Step the gesture machine on the game contacts
            float ppp = PixelsPerPoint;
            Gestures.Step(gameContacts, Time.unscaledTime, ppp);

            // Step 3: Update contextual two-finger navigation (scroll / grid / panel zoom)
            TwoFinger.Update(Gestures, ppp);

            // Step 4: Advance simulated input keys
            PortInput.SnapshotKeys();
        }

        private void InstallUI()
        {
            var system = EventSystem.current;
            if (system == null || system == installedSystem) return;
            var original = system.GetComponent<StandaloneInputModule>();
            var input = system.GetComponent<PortUIInput>() ?? system.gameObject.AddComponent<PortUIInput>();
            var module = system.GetComponent<PortStandaloneInputModule>() ?? system.gameObject.AddComponent<PortStandaloneInputModule>();
            module.inputOverride = input;
            if (original != null && original != module)
            {
                module.horizontalAxis = original.horizontalAxis;
                module.verticalAxis = original.verticalAxis;
                module.submitButton = original.submitButton;
                module.cancelButton = original.cancelButton;
                module.inputActionsPerSecond = original.inputActionsPerSecond;
                module.repeatDelay = original.repeatDelay;
                original.enabled = false;
            }
            installedSystem = system;
        }
    }
}
