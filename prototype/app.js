(() => {
  "use strict";

  const app = document.querySelector("#app");
  const statusBar = document.querySelector(".device-status");
  const panel = document.querySelector("#prototype-panel");
  const panelTrigger = document.querySelector("#prototype-trigger");
  const panelClose = document.querySelector("#prototype-close");
  const personaControls = document.querySelector("#persona-controls");
  const screenControls = document.querySelector("#screen-controls");
  const toastRegion = document.querySelector("#toast-region");

  const icons = {
    arrow: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="m9.3 5.3 1.4-1.4 8.1 8.1-8.1 8.1-1.4-1.4 6.7-6.7Z"/></svg>',
    back: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="m14.7 5.3-1.4-1.4L5.2 12l8.1 8.1 1.4-1.4L8 12Z"/></svg>',
    child: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 2a4 4 0 0 0-4 4c0 .6.1 1.1.4 1.6A7 7 0 0 0 5 13.5V22h14v-8.5a7 7 0 0 0-3.4-5.9A4 4 0 0 0 12 2Zm0 2a2 2 0 1 1 0 4 2 2 0 0 1 0-4Zm-5 9.5a5 5 0 0 1 10 0V20h-2v-5h-2v5h-2v-5H9v5H7Z"/></svg>',
    check: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="m9.2 16.2-4.3-4.3-1.4 1.4L9.2 19 21 7.2l-1.4-1.4Z"/></svg>',
    copy: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M8 7V3h13v13h-4v5H3V7Zm2 0h7v7h2V5h-9Zm5 2H5v10h10Z"/></svg>',
    error: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M11 7h2v7h-2Zm0 9h2v2h-2Zm1-14a10 10 0 1 0 10 10A10 10 0 0 0 12 2Zm0 18a8 8 0 1 1 8-8 8 8 0 0 1-8 8Z"/></svg>',
    eye: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 5c-5 0-9 4.4-10 7 1 2.6 5 7 10 7s9-4.4 10-7c-1-2.6-5-7-10-7Zm0 12c-3.5 0-6.5-2.8-7.8-5C5.5 9.8 8.5 7 12 7s6.5 2.8 7.8 5c-1.3 2.2-4.3 5-7.8 5Zm0-8a3 3 0 1 0 3 3 3 3 0 0 0-3-3Z"/></svg>',
    heart: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 21 3.6 12.8A5.7 5.7 0 0 1 12 5.1a5.7 5.7 0 0 1 8.4 7.7ZM7.7 5.8a3.7 3.7 0 0 0-2.6 6.3l6.9 6.7 6.9-6.7a3.7 3.7 0 1 0-5.2-5.2L12 8.6l-1.7-1.7a3.7 3.7 0 0 0-2.6-1.1Z"/></svg>',
    heartFilled: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 21 3.6 12.8A5.7 5.7 0 0 1 12 5.1a5.7 5.7 0 0 1 8.4 7.7Z"/></svg>',
    info: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M11 10h2v8h-2Zm0-4h2v2h-2Zm1-4a10 10 0 1 0 10 10A10 10 0 0 0 12 2Zm0 18a8 8 0 1 1 8-8 8 8 0 0 1-8 8Z"/></svg>',
    link: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10.6 13.4a2 2 0 0 0 2.8 0l3-3a2 2 0 1 0-2.8-2.8l-1.5 1.5-1.4-1.4 1.5-1.5a4 4 0 0 1 5.6 5.6l-3 3a4 4 0 0 1-5.6 0Zm2.8-2.8a2 2 0 0 0-2.8 0l-3 3a2 2 0 1 0 2.8 2.8l1.5-1.5 1.4 1.4-1.5 1.5a4 4 0 1 1-5.6-5.6l3-3a4 4 0 0 1 5.6 0Z"/></svg>',
    logout: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M10 4H5v16h5v2H3V2h7Zm3.6 3.6L18 12l-4.4 4.4 1.4 1.4 6-6-6-6ZM7 11h12v2H7Z"/></svg>',
    pause: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M6 4h4v16H6Zm8 0h4v16h-4Z"/></svg>',
    person: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M12 2a5 5 0 1 0 5 5 5 5 0 0 0-5-5Zm0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3Zm0 2c-5 0-9 2.5-9 6v4h18v-4c0-3.5-4-6-9-6Zm7 8H5v-2c0-2 3-4 7-4s7 2 7 4Z"/></svg>',
    play: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M8 5v14l11-7Z"/></svg>',
    refresh: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M17.7 6.3A8 8 0 1 0 20 12h-2a6 6 0 1 1-1.7-4.3L13 11h8V3Z"/></svg>',
    share: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M18 16a3 3 0 0 0-2.4 1.2l-6.7-3.9A3.3 3.3 0 0 0 9 12a3.3 3.3 0 0 0-.1-.8l6.8-3.9A3 3 0 1 0 15 5.5a3.3 3.3 0 0 0 .1.8L8.3 10.2A3 3 0 1 0 8.2 14l6.9 4a3 3 0 1 0 2.9-2Z"/></svg>',
    signal: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M2.3 4.9 3.7 3.5l16.8 16.8-1.4 1.4-2.6-2.6A11.7 11.7 0 0 1 12 20l-4-4a5.6 5.6 0 0 1 4-1.7l-2-2a8.4 8.4 0 0 0-4.1 2.2L4.4 13A10.6 10.6 0 0 1 8 10.8L5.9 8.7a13.5 13.5 0 0 0-3 2L1.5 9.3a15.3 15.3 0 0 1 2.9-2.1Zm19.9 4.4-1.4 1.4a13.5 13.5 0 0 0-8.8-3.2l-2-2a15.5 15.5 0 0 1 12.2 3.8ZM18 13l-1.5 1.5a8.2 8.2 0 0 0-2.7-1.7l-2.5-2.5A10.4 10.4 0 0 1 18 13Z"/></svg>',
    sparkle: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="m12 1 1.7 6.3L20 9l-6.3 1.7L12 17l-1.7-6.3L4 9l6.3-1.7Zm7 13 .9 3.1L23 18l-3.1.9L19 22l-.9-3.1L15 18l3.1-.9Z"/></svg>',
    video: '<svg aria-hidden="true" viewBox="0 0 24 24"><path d="M4 4h12a2 2 0 0 1 2 2v2.8L22 6v12l-4-2.8V18a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Zm0 2v12h12V6Z"/></svg>'
  };

  const masterclasses = [
    {
      id: "feelings",
      title: "Understanding Big Feelings",
      description: "Simple, expert-informed ways to meet intense emotions with connection before correction.",
      art: "feelings",
      videos: [
        { id: "name-feeling", title: "Naming the feeling", duration: 78 },
        { id: "coregulate", title: "Co-regulation before correction", duration: 96 },
        { id: "calm-routine", title: "Building a calm-down routine", duration: 88 },
        { id: "reconnect", title: "Reconnecting after a difficult moment", duration: 105 }
      ]
    },
    {
      id: "play",
      title: "Play That Builds Connection",
      description: "Turn ordinary moments into playful opportunities for confidence, closeness, and learning.",
      art: "play",
      videos: [
        { id: "follow-lead", title: "Following your child's lead", duration: 82 },
        { id: "routine-play", title: "Turning routines into play", duration: 74 },
        { id: "open-play", title: "Simple open-ended play", duration: 91 },
        { id: "end-play", title: "Ending play without a battle", duration: 99 }
      ]
    }
  ];

  const initialActivity = {
    mom: {
      "name-feeling": { progress: 100, liked: true },
      coregulate: { progress: 52, liked: true },
      "calm-routine": { progress: 0, liked: false },
      reconnect: { progress: 0, liked: false },
      "follow-lead": { progress: 22, liked: false },
      "routine-play": { progress: 0, liked: false },
      "open-play": { progress: 0, liked: false },
      "end-play": { progress: 0, liked: false }
    },
    dad: {
      "name-feeling": { progress: 28, liked: false },
      coregulate: { progress: 0, liked: false },
      "calm-routine": { progress: 0, liked: false },
      reconnect: { progress: 0, liked: false },
      "follow-lead": { progress: 100, liked: true },
      "routine-play": { progress: 64, liked: false },
      "open-play": { progress: 0, liked: false },
      "end-play": { progress: 0, liked: false }
    }
  };

  const state = {
    screen: "launch",
    history: [],
    persona: "mom",
    roleChoice: "mom",
    linked: true,
    selectedMasterclass: "feelings",
    selectedVideo: "coregulate",
    playing: false,
    authError: "",
    joinError: "",
    activity: structuredClone(initialActivity)
  };

  let playerTimer = null;

  const screenNames = {
    launch: "Launch",
    welcome: "Welcome",
    signup: "Sign up",
    login: "Log in",
    path: "Family path",
    create: "Create child",
    join: "Join family",
    invite: "Invite partner",
    library: "Library",
    masterclass: "Masterclass",
    player: "Video player",
    account: "Account"
  };

  const esc = (value) => String(value).replace(/[&<>'"]/g, (character) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", "'": "&#39;", '"': "&quot;"
  })[character]);

  const currentRole = () => (state.persona === "dad" ? "Dad" : "Mom");
  const partnerRole = () => (state.persona === "dad" ? "Mom" : "Dad");
  const activityKey = () => (state.persona === "dad" ? "dad" : "mom");
  const partnerKey = () => (state.persona === "dad" ? "mom" : "dad");
  const initials = () => (state.persona === "dad" ? "DA" : "MO");
  const accountEmail = () => (state.persona === "dad" ? "dad@sitaara.demo" : "mom@sitaara.demo");

  function getMasterclass(id = state.selectedMasterclass) {
    return masterclasses.find((item) => item.id === id) || masterclasses[0];
  }

  function getVideo(id = state.selectedVideo) {
    return masterclasses.flatMap((item) => item.videos).find((item) => item.id === id) || masterclasses[0].videos[0];
  }

  function getActivity(person, videoId) {
    return state.activity[person][videoId] || { progress: 0, liked: false };
  }

  function classProgress(masterclass, person) {
    const total = masterclass.videos.reduce((sum, video) => sum + video.duration, 0);
    const watched = masterclass.videos.reduce((sum, video) => {
      return sum + video.duration * Math.min(getActivity(person, video.id).progress, 100) / 100;
    }, 0);
    return Math.round((watched / total) * 100);
  }

  function completedCount(masterclass, person) {
    return masterclass.videos.filter((video) => getActivity(person, video.id).progress >= 90).length;
  }

  function formatTime(seconds) {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60).toString().padStart(2, "0");
    return `${mins}:${secs}`;
  }

  function setScreen(screen, options = {}) {
    stopPlayback();
    if (!options.replace && state.screen !== screen) state.history.push(state.screen);
    state.screen = screen;
    state.authError = "";
    state.joinError = "";
    render();
    app.scrollTop = 0;
    requestAnimationFrame(() => app.focus({ preventScroll: true }));
  }

  function goBack(fallback = "library") {
    stopPlayback();
    const previous = state.history.pop();
    state.screen = previous && previous !== "launch" ? previous : fallback;
    render();
    app.scrollTop = 0;
  }

  function backButton(label = "Go back") {
    return `<button class="icon-button subtle" type="button" data-action="back" aria-label="${label}">${icons.back}</button>`;
  }

  function toast(message) {
    const item = document.createElement("div");
    item.className = "toast";
    item.innerHTML = `${icons.check}<span>${esc(message)}</span>`;
    toastRegion.appendChild(item);
    window.setTimeout(() => item.remove(), 2600);
  }

  function render() {
    const purpleStatus = ["launch", "welcome"].includes(state.screen);
    statusBar.classList.toggle("on-purple", purpleStatus);
    app.innerHTML = renderScreen();
    updatePersonaControls();
  }

  function renderScreen() {
    switch (state.screen) {
      case "launch": return launchScreen();
      case "welcome": return welcomeScreen();
      case "signup": return authScreen("signup");
      case "login": return authScreen("login");
      case "path": return pathScreen();
      case "create": return createScreen();
      case "join": return joinScreen();
      case "invite": return inviteScreen();
      case "library": return libraryScreen();
      case "masterclass": return masterclassScreen();
      case "player": return playerScreen();
      case "account": return accountScreen();
      case "loading": return loadingScreen();
      case "offline": return errorStateScreen("offline");
      case "server": return errorStateScreen("server");
      default: return welcomeScreen();
    }
  }

  function launchScreen() {
    return `
      <section class="state-screen purple-screen">
        <img class="welcome-logo" src="assets/sitaara-logo.png" alt="Sitaara — Simplifying Parenthood" />
        <div class="spinner" style="margin-top:32px;border-color:rgba(255,255,255,.2);border-top-color:#8AC340" aria-label="Restoring session"></div>
        <p style="color:#dcd3f1">Bringing your family learning together…</p>
      </section>`;
  }

  function welcomeScreen() {
    return `
      <section class="welcome-screen">
        <img class="welcome-logo" src="assets/sitaara-logo.png" alt="Sitaara — Simplifying Parenthood" />
        <div class="welcome-art" aria-hidden="true">
          <div class="orbit"></div>
          <div class="family-illustration"><span class="family-heart"></span></div>
        </div>
        <div class="welcome-copy">
          <h1>Parenting feels lighter, together.</h1>
          <p>Expert-led learning you and your partner can explore at your own pace—while always staying in sync.</p>
          <div class="button-stack">
            <button class="button primary-on-dark full" type="button" data-screen="signup">Create account</button>
            <button class="button secondary-on-dark full" type="button" data-screen="login">Log in</button>
            <button class="text-button" style="color:#dcd3f1" type="button" data-action="demo">Explore the linked demo</button>
          </div>
        </div>
      </section>`;
  }

  function authScreen(type) {
    const signup = type === "signup";
    const error = state.authError ? `<div class="status-banner error">${icons.error}<span>${esc(state.authError)}</span></div>` : "";
    return `
      <section class="screen">
        <header class="app-header">${backButton()}<span></span></header>
        <div class="step-indicator"><span class="active"></span><span></span><span></span></div>
        <h1 class="screen-title">${signup ? "Create your account" : "Welcome back"}</h1>
        <p class="screen-subtitle">${signup ? "A separate account keeps your learning personal while still letting you share progress." : "Log in to continue learning with your family."}</p>
        <form class="form" data-form="${type}" novalidate>
          ${error}
          <div class="field">
            <label for="email">Email address</label>
            <input class="input" id="email" name="email" type="email" autocomplete="email" placeholder="you@example.com" required />
          </div>
          <div class="field">
            <label for="password">Password</label>
            <div class="input-wrap">
              <input class="input has-icon" id="password" name="password" type="password" autocomplete="${signup ? "new-password" : "current-password"}" placeholder="${signup ? "At least 8 characters" : "Your password"}" required minlength="8" />
              <button class="input-action" type="button" data-action="toggle-password" aria-label="Show password">${icons.eye}</button>
            </div>
            ${signup ? '<p class="field-help">Use at least 8 characters, including a number.</p>' : ""}
          </div>
          ${signup ? `
            <div class="field">
              <label for="confirm-password">Confirm password</label>
              <input class="input" id="confirm-password" name="confirm" type="password" autocomplete="new-password" placeholder="Enter it again" required />
            </div>` : ""}
          <button class="button primary full" type="submit">${signup ? "Create account" : "Log in"}</button>
        </form>
        <p class="form-footer">${signup ? "Already have an account?" : "New to Sitaara?"} <button type="button" data-screen="${signup ? "login" : "signup"}">${signup ? "Log in" : "Create account"}</button></p>
      </section>`;
  }

  function pathScreen() {
    return `
      <section class="screen">
        <header class="app-header">${backButton()}<span></span></header>
        <div class="step-indicator"><span></span><span class="active"></span><span></span></div>
        <h1 class="screen-title">How would you like to begin?</h1>
        <p class="screen-subtitle">One parent creates your family. The other joins with a private invitation code.</p>
        <div class="choice-list">
          <button class="choice-card" type="button" data-screen="create">
            <span class="choice-icon">${icons.child}</span>
            <span class="choice-copy"><strong>Create our family</strong><small>Add your child, then invite your partner.</small></span>
            <span class="choice-arrow">${icons.arrow}</span>
          </button>
          <button class="choice-card" type="button" data-screen="join">
            <span class="choice-icon green">${icons.link}</span>
            <span class="choice-copy"><strong>Join my partner</strong><small>Use the six-character code they shared.</small></span>
            <span class="choice-arrow">${icons.arrow}</span>
          </button>
        </div>
        <div class="info-note" style="margin-top:20px">${icons.info}<span>You will each keep your own likes and watch progress after linking.</span></div>
      </section>`;
  }

  function rolePicker() {
    return `
      <div class="field">
        <span class="field-label">Your role</span>
        <div class="segmented" role="group" aria-label="Choose your role">
          <button type="button" data-role="mom" class="${state.roleChoice === "mom" ? "active" : ""}" aria-pressed="${state.roleChoice === "mom"}">Mom</button>
          <button type="button" data-role="dad" class="${state.roleChoice === "dad" ? "active" : ""}" aria-pressed="${state.roleChoice === "dad"}">Dad</button>
        </div>
      </div>`;
  }

  function createScreen() {
    return `
      <section class="screen">
        <header class="app-header">${backButton()}<span></span></header>
        <div class="step-indicator"><span></span><span></span><span class="active"></span></div>
        <h1 class="screen-title">Tell us about your family</h1>
        <p class="screen-subtitle">This child profile will be shared with your partner after they join.</p>
        <form class="form" data-form="create-family">
          ${rolePicker()}
          <div class="field">
            <label for="child-name">Child's first name</label>
            <input class="input" id="child-name" name="childName" value="Tara" placeholder="First name" required maxlength="80" />
          </div>
          <div class="field">
            <label for="child-dob">Date of birth</label>
            <input class="input" id="child-dob" name="dob" type="date" value="2023-04-18" required />
          </div>
          <div class="info-note">${icons.info}<span>You can add one child in this demo. Your partner will see the same profile.</span></div>
          <button class="button primary full" type="submit">Create family</button>
        </form>
      </section>`;
  }

  function joinScreen() {
    const error = state.joinError ? `<p class="field-error">${icons.error}<span>${esc(state.joinError)}</span></p>` : '<p class="field-help">Letters are automatically capitalized. Dashes are optional.</p>';
    return `
      <section class="screen">
        <header class="app-header">${backButton()}<span></span></header>
        <div class="step-indicator"><span></span><span></span><span class="active"></span></div>
        <h1 class="screen-title">Join your partner</h1>
        <p class="screen-subtitle">Enter the private code your partner generated from their Sitaara account.</p>
        <form class="form" data-form="join-family">
          ${rolePicker()}
          <div class="field">
            <label for="invite-code">Invitation code</label>
            <input class="input code-input ${state.joinError ? "error" : ""}" id="invite-code" name="code" value="STAR42" maxlength="6" inputmode="text" autocomplete="one-time-code" required />
            ${error}
          </div>
          <button class="button primary full" type="submit">Join family</button>
        </form>
        <div class="info-note" style="margin-top:22px">${icons.link}<span>Once linked, you will both see Tara's profile and one another's learning activity.</span></div>
      </section>`;
  }

  function inviteScreen() {
    return `
      <section class="screen">
        <header class="app-header">${backButton()}<span></span></header>
        <h1 class="screen-title">Invite your partner</h1>
        <p class="screen-subtitle">Share this one-time code. It can only be used by one account.</p>
        <div class="invite-card">
          <div class="invite-mark">${icons.link}</div>
          <h2>Learn together</h2>
          <p>Your partner will join Tara's profile and keep their own learning history.</p>
          <div class="invite-code" aria-label="Invitation code STAR 42">STAR42</div>
          <div class="invite-expiry">Expires tomorrow at 6:30 PM</div>
          <div class="invite-actions">
            <button class="button primary-on-dark" type="button" data-action="copy-code">${icons.copy} Copy</button>
            <button class="button secondary-on-dark" type="button" data-action="share-code">${icons.share} Share</button>
          </div>
        </div>
        <button class="button ghost full" style="margin-top:12px" type="button" data-action="regenerate">Generate a new code</button>
        <div class="status-banner warning" style="margin-top:10px">${icons.info}<span>Generating a new code will stop the current one from working.</span></div>
      </section>`;
  }

  function libraryScreen() {
    const linked = state.persona !== "unlinked" && state.linked;
    const person = activityKey();
    return `
      <section class="screen">
        <div class="hero-block">
          <div class="hero-header">
            <img src="assets/sitaara-logo-wide.png" alt="Sitaara" style="width:142px;height:auto" />
            <button class="avatar-button ${linked ? "linked" : ""}" type="button" data-screen="account" aria-label="Open account">${initials()}</button>
          </div>
          <div class="hero-greeting">
            <p>Good morning, ${currentRole()}</p>
            <h1>What will you learn together today?</h1>
            <span class="hero-child">${icons.child} For Tara · 3 years old</span>
          </div>
        </div>

        <div class="partner-card">
          ${linked ? `
            <div class="partner-top">
              <div class="partner-avatars"><span class="mini-avatar">${currentRole().slice(0,1)}</span><span class="mini-avatar">${partnerRole().slice(0,1)}</span></div>
              <div class="partner-copy"><strong>Learning together with ${partnerRole()}</strong><small>Your shared progress is up to date.</small></div>
            </div>
            <div class="partner-action">${icons.sparkle}<span>${partnerRole()} completed a lesson this week</span></div>` : `
            <div class="partner-top">
              <span class="choice-icon">${icons.link}</span>
              <div class="partner-copy"><strong>Invite your partner</strong><small>Learn separately, stay connected.</small></div>
            </div>
            <button class="button primary full" style="margin-top:14px" type="button" data-screen="invite">Create invitation code</button>`}
        </div>

        <div class="section-heading"><div><h2>Masterclasses</h2><p>Short lessons for everyday moments</p></div><button type="button" data-action="refresh">Refresh</button></div>
        <div class="masterclass-list">
          ${masterclasses.map((masterclass) => masterclassCard(masterclass, person, linked)).join("")}
        </div>
      </section>`;
  }

  function masterclassCard(masterclass, person, linked) {
    const own = classProgress(masterclass, person);
    const partner = classProgress(masterclass, partnerKey());
    const partnerDone = completedCount(masterclass, partnerKey());
    const watching = masterclass.id === "feelings" && linked;
    return `
      <article class="masterclass-card" data-masterclass="${masterclass.id}" tabindex="0" role="button" aria-label="Open ${esc(masterclass.title)}">
        <div class="cover-art ${masterclass.art}">
          <span class="cover-badge">${icons.video} ${masterclass.videos.length} lessons</span>
          <span class="cover-person" aria-hidden="true"></span>
        </div>
        <div class="masterclass-body">
          <span class="masterclass-meta">${masterclass.id === "feelings" ? "EMOTIONAL DEVELOPMENT" : "PLAY & CONNECTION"}</span>
          <h3>${esc(masterclass.title)}</h3>
          <div class="progress-row"><span>You</span><div class="progress-track"><div class="progress-fill" style="width:${own}%"></div></div><strong>${own}%</strong></div>
          ${linked ? `<div class="partner-summary"><span><strong>${partnerRole()}</strong> · ${partnerDone}/${masterclass.videos.length} completed (${partner}%)</span>${watching ? '<span class="chip green"><i class="live-dot"></i> Watching now</span>' : icons.arrow}</div>` : ""}
        </div>
      </article>`;
  }

  function masterclassScreen() {
    const masterclass = getMasterclass();
    const person = activityKey();
    const linked = state.persona !== "unlinked" && state.linked;
    const own = classProgress(masterclass, person);
    const partner = classProgress(masterclass, partnerKey());
    return `
      <section class="screen flush">
        <div class="detail-cover">
          ${backButton("Back to library")}
          <span class="cover-person" aria-hidden="true"></span>
          <div class="detail-cover-copy">
            <p>${masterclass.id === "feelings" ? "EMOTIONAL DEVELOPMENT" : "PLAY & CONNECTION"}</p>
            <h1>${esc(masterclass.title)}</h1>
          </div>
        </div>
        <div class="detail-body">
          <p class="screen-subtitle" style="margin-top:0">${esc(masterclass.description)}</p>
          <div class="dual-progress" style="margin-top:18px">
            <div class="progress-card"><small>Your progress</small><strong>${own}%</strong><div class="progress-track"><div class="progress-fill" style="width:${own}%"></div></div></div>
            <div class="progress-card"><small>${linked ? partnerRole() + "'s progress" : "Partner progress"}</small><strong>${linked ? partner + "%" : "Not linked"}</strong><div class="progress-track"><div class="progress-fill" style="width:${linked ? partner : 0}%"></div></div></div>
          </div>
          <div class="section-heading"><div><h2>Lessons</h2><p>${masterclass.videos.length} videos · ${formatTime(masterclass.videos.reduce((sum, item) => sum + item.duration, 0))}</p></div></div>
          <div class="video-list">${masterclass.videos.map((video, index) => videoRow(video, index, person, linked)).join("")}</div>
        </div>
      </section>`;
  }

  function videoRow(video, index, person, linked) {
    const own = getActivity(person, video.id);
    const partner = getActivity(partnerKey(), video.id);
    let partnerText = `${partnerRole()} has not started`;
    if (partner.progress >= 90) partnerText = `Completed by ${partnerRole()}`;
    else if (partner.progress > 0) partnerText = `${partnerRole()} watched ${partner.progress}%`;
    if (partner.liked) partnerText += " · Liked";
    return `
      <button class="video-row" type="button" data-video="${video.id}">
        <span class="video-thumb ${index % 2 ? "green" : ""}">${own.progress >= 90 ? icons.check : icons.play}</span>
        <span class="video-copy">
          <strong>${index + 1}. ${esc(video.title)}</strong>
          <small>${formatTime(video.duration)} · ${own.progress >= 90 ? "Completed" : own.progress ? own.progress + "% watched" : "Not started"}</small>
          ${linked ? `<span class="video-partner">${partner.liked ? icons.heartFilled : ""}<span>${partnerText}</span></span>` : ""}
        </span>
        <span class="video-end">${icons.arrow}</span>
      </button>`;
  }

  function playerScreen() {
    const video = getVideo();
    const own = getActivity(activityKey(), video.id);
    const partner = getActivity(partnerKey(), video.id);
    const linked = state.persona !== "unlinked" && state.linked;
    const elapsed = Math.round(video.duration * own.progress / 100);
    return `
      <section class="screen player-screen">
        <div class="player-stage">
          <button class="icon-button back-float" type="button" data-action="back" aria-label="Back to masterclass">${icons.back}</button>
          <div class="video-visual" aria-hidden="true"></div>
          <button class="play-control" type="button" data-action="play" aria-label="${state.playing ? "Pause" : "Play"} video">${state.playing ? icons.pause : icons.play}</button>
          <div class="player-controls">
            <div class="player-timeline" role="progressbar" aria-label="Video progress" aria-valuemin="0" aria-valuemax="100" aria-valuenow="${own.progress}"><div id="player-progress-fill" class="player-timeline-fill" style="width:${own.progress}%"></div></div>
            <div class="player-time"><span id="player-elapsed">${formatTime(elapsed)}</span><span>${formatTime(video.duration)}</span></div>
          </div>
        </div>
        <div class="player-body">
          <span class="player-kicker">${esc(getMasterclass().title)}</span>
          <div class="player-title-row"><h1>${esc(video.title)}</h1><button class="like-button ${own.liked ? "liked" : ""}" type="button" data-action="like" aria-pressed="${own.liked}" aria-label="${own.liked ? "Unlike" : "Like"} video">${own.liked ? icons.heartFilled : icons.heart}</button></div>
          <p class="player-description">A short, practical lesson to help you respond with calm, connection, and confidence in everyday moments.</p>
          <div class="activity-card">
            <div class="activity-line"><span class="activity-icon">${own.progress >= 90 ? icons.check : icons.play}</span><span><strong>Your progress · <span id="player-own-percent">${own.progress}%</span></strong><small>${own.progress >= 90 ? "Completed" : own.progress ? "Keep going from your furthest point" : "Ready when you are"}</small></span></div>
            ${linked ? `<div class="activity-line"><span class="activity-icon green">${partner.liked ? icons.heartFilled : icons.person}</span><span><strong>${partner.liked ? "Liked by " + partnerRole() : partnerRole() + "'s activity"}</strong><small>${partner.progress >= 90 ? "Completed this lesson" : partner.progress ? "Watched " + partner.progress + "%" : "Has not started yet"}</small></span></div>` : ""}
          </div>
        </div>
      </section>`;
  }

  function accountScreen() {
    const linked = state.persona !== "unlinked" && state.linked;
    return `
      <section class="screen">
        <header class="app-header">${backButton()}<span></span></header>
        <div class="account-hero"><div class="account-avatar">${initials()}</div><h1>${currentRole()}'s account</h1><p>${accountEmail()}</p></div>
        <div class="settings-list">
          <div class="settings-card">
            <div class="settings-row"><span class="settings-icon">${icons.person}</span><span class="settings-copy"><strong>Your role</strong><small>Visible to your linked partner</small></span><span class="settings-value">${currentRole()}</span></div>
            <div class="settings-row"><span class="settings-icon">${icons.child}</span><span class="settings-copy"><strong>Shared child</strong><small>18 April 2023</small></span><span class="settings-value">Tara</span></div>
            <div class="settings-row"><span class="settings-icon">${icons.link}</span><span class="settings-copy"><strong>Partner</strong><small>${linked ? "Accounts securely linked" : "Not linked yet"}</small></span><span class="settings-value">${linked ? partnerRole() : "—"}</span></div>
          </div>
          <div class="settings-card">
            <div class="settings-row"><span class="settings-icon">${icons.info}</span><span class="settings-copy"><strong>Prototype build</strong><small>Mobile design preview</small></span><span class="settings-value">v0.1</span></div>
          </div>
        </div>
        ${!linked ? '<button class="button primary full" style="margin-top:18px" type="button" data-screen="invite">Invite your partner</button>' : ""}
        <button class="button danger full" style="margin-top:18px" type="button" data-action="logout">${icons.logout} Log out</button>
      </section>`;
  }

  function loadingScreen() {
    return `
      <section class="screen">
        <header class="app-header">${backButton()}<div class="skeleton" style="width:46px;height:46px;border-radius:50%"></div></header>
        <div class="skeleton" style="height:136px;border-radius:22px"></div>
        <div class="section-heading"><div><div class="skeleton" style="width:120px;height:19px"></div><div class="skeleton" style="width:190px;height:11px;margin-top:8px"></div></div></div>
        <div class="skeleton" style="height:245px;border-radius:22px"></div>
        <div class="skeleton" style="height:245px;border-radius:22px;margin-top:14px"></div>
      </section>`;
  }

  function errorStateScreen(type) {
    const offline = type === "offline";
    return `
      <section class="state-screen">
        <div class="state-art ${offline ? "warning" : "error"}">${offline ? icons.signal : icons.error}</div>
        <h1>${offline ? "You're offline" : "Something went wrong"}</h1>
        <p>${offline ? "Check your connection and try again. Your current progress is safe on this device." : "We couldn't load this screen right now. Try again, or use the request ID if you need help."}</p>
        ${offline ? "" : '<p style="margin-top:-12px;font-size:.68rem">Request ID: DEMO-7A42</p>'}
        <button class="button primary full" type="button" data-action="retry">${icons.refresh} Try again</button>
        <button class="button ghost full" type="button" data-screen="library">Return home</button>
      </section>`;
  }

  function stopPlayback() {
    state.playing = false;
    if (playerTimer) window.clearInterval(playerTimer);
    playerTimer = null;
  }

  function togglePlayback() {
    state.playing = !state.playing;
    const button = app.querySelector('[data-action="play"]');
    if (button) {
      button.innerHTML = state.playing ? icons.pause : icons.play;
      button.setAttribute("aria-label", state.playing ? "Pause video" : "Play video");
    }
    if (state.playing) {
      tickPlayback();
      playerTimer = window.setInterval(tickPlayback, 1000);
    } else {
      stopPlayback();
    }
  }

  function tickPlayback() {
    const video = getVideo();
    const own = getActivity(activityKey(), video.id);
    if (own.progress >= 100) {
      stopPlayback();
      render();
      toast("Lesson completed");
      return;
    }
    own.progress = Math.min(100, own.progress + Math.max(1, Math.round(100 / video.duration)));
    const fill = app.querySelector("#player-progress-fill");
    const elapsed = app.querySelector("#player-elapsed");
    const percent = app.querySelector("#player-own-percent");
    if (fill) fill.style.width = `${own.progress}%`;
    if (elapsed) elapsed.textContent = formatTime(video.duration * own.progress / 100);
    if (percent) percent.textContent = `${own.progress}%`;
  }

  function updatePersonaControls() {
    personaControls.querySelectorAll("button").forEach((button) => {
      button.classList.toggle("active", button.dataset.persona === state.persona);
      button.setAttribute("aria-pressed", String(button.dataset.persona === state.persona));
    });
  }

  function setPersona(persona) {
    state.persona = persona;
    state.linked = persona !== "unlinked";
    if (persona === "unlinked") state.roleChoice = "mom";
    render();
    toast(persona === "unlinked" ? "Showing an unlinked account" : `Viewing as ${currentRole()}`);
  }

  function resetDemo() {
    stopPlayback();
    state.activity = structuredClone(initialActivity);
    state.persona = "mom";
    state.roleChoice = "mom";
    state.linked = true;
    state.history = [];
    state.selectedMasterclass = "feelings";
    state.selectedVideo = "coregulate";
    state.screen = "welcome";
    render();
    closePanel();
    toast("Prototype reset");
  }

  function openPanel() {
    panel.hidden = false;
    panelTrigger.setAttribute("aria-expanded", "true");
    panel.querySelector("button")?.focus();
  }

  function closePanel() {
    panel.hidden = true;
    panelTrigger.setAttribute("aria-expanded", "false");
    panelTrigger.focus();
  }

  screenControls.innerHTML = Object.entries(screenNames).map(([id, label]) => `<button type="button" data-jump="${id}">${label}</button>`).join("");

  panelTrigger.addEventListener("click", () => panel.hidden ? openPanel() : closePanel());
  panelClose.addEventListener("click", closePanel);

  panel.addEventListener("click", (event) => {
    const persona = event.target.closest("[data-persona]")?.dataset.persona;
    const jump = event.target.closest("[data-jump]")?.dataset.jump;
    const preview = event.target.closest("[data-preview]")?.dataset.preview;
    if (persona) setPersona(persona);
    if (jump) {
      state.history = [];
      state.screen = jump;
      render();
      closePanel();
    }
    if (preview === "reset") resetDemo();
    else if (preview) {
      state.history.push(state.screen);
      state.screen = preview;
      render();
      closePanel();
    }
  });

  app.addEventListener("click", async (event) => {
    const target = event.target.closest("button, [data-masterclass], [data-video]");
    if (!target) return;

    if (target.dataset.screen) setScreen(target.dataset.screen);
    if (target.dataset.masterclass) {
      state.selectedMasterclass = target.dataset.masterclass;
      setScreen("masterclass");
    }
    if (target.dataset.video) {
      state.selectedVideo = target.dataset.video;
      setScreen("player");
    }
    if (target.dataset.role) {
      state.roleChoice = target.dataset.role;
      render();
    }

    switch (target.dataset.action) {
      case "back": goBack(); break;
      case "demo": state.persona = "mom"; state.linked = true; state.history = []; setScreen("library", { replace: true }); break;
      case "toggle-password": {
        const input = app.querySelector("#password");
        input.type = input.type === "password" ? "text" : "password";
        target.setAttribute("aria-label", input.type === "password" ? "Show password" : "Hide password");
        break;
      }
      case "copy-code": {
        try { await navigator.clipboard.writeText("STAR42"); } catch (_) { /* Clipboard may be unavailable on file://. */ }
        toast("Invitation code copied");
        break;
      }
      case "share-code": toast("Share sheet previewed"); break;
      case "regenerate": toast("New code generated · MOON73"); break;
      case "refresh": toast("Partner activity is up to date"); break;
      case "play": togglePlayback(); break;
      case "like": {
        const own = getActivity(activityKey(), state.selectedVideo);
        own.liked = !own.liked;
        render();
        toast(own.liked ? "Added to your likes" : "Removed from your likes");
        break;
      }
      case "retry": {
        state.screen = "loading";
        render();
        window.setTimeout(() => { state.screen = "library"; render(); toast("You're back online"); }, 650);
        break;
      }
      case "logout": state.history = []; state.screen = "welcome"; render(); toast("Logged out of the prototype"); break;
      default: break;
    }
  });

  app.addEventListener("keydown", (event) => {
    const card = event.target.closest("[data-masterclass]");
    if (card && (event.key === "Enter" || event.key === " ")) {
      event.preventDefault();
      state.selectedMasterclass = card.dataset.masterclass;
      setScreen("masterclass");
    }
  });

  app.addEventListener("input", (event) => {
    if (event.target.id === "invite-code") {
      event.target.value = event.target.value.toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 6);
    }
  });

  app.addEventListener("submit", (event) => {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);
    if (!form.checkValidity()) {
      form.reportValidity();
      return;
    }

    if (form.dataset.form === "signup") {
      const password = formData.get("password");
      const confirm = formData.get("confirm");
      if (password !== confirm) {
        state.authError = "Those passwords do not match. Try entering them again.";
        render();
        return;
      }
      state.persona = "unlinked";
      state.linked = false;
      setScreen("path");
    }

    if (form.dataset.form === "login") {
      state.persona = "mom";
      state.linked = true;
      setScreen("library");
    }

    if (form.dataset.form === "create-family") {
      state.persona = "unlinked";
      state.linked = false;
      state.history = [];
      setScreen("library", { replace: true });
      toast("Tara's profile is ready");
    }

    if (form.dataset.form === "join-family") {
      const code = String(formData.get("code") || "").toUpperCase();
      if (code !== "STAR42") {
        state.joinError = "That code is invalid or no longer available.";
        render();
        return;
      }
      state.persona = state.roleChoice;
      state.linked = true;
      state.history = [];
      setScreen("library", { replace: true });
      toast(`You're now linked with ${partnerRole()}`);
    }
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && !panel.hidden) closePanel();
  });

  const now = new Date();
  document.querySelector("#status-time").textContent = now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  render();
  window.setTimeout(() => {
    if (state.screen === "launch") setScreen("welcome", { replace: true });
  }, 850);
})();
