// Auth view: register, sign-in, and simulated social providers.
// Email registration calls supabase.auth.signUp via the session
// store; simulated Google / Microsoft buttons call
// supabase.auth.signInAnonymously and stamp the resulting session
// with a provider label.

export function authView() {
  return {
    mode: "signin",
    email: "",
    displayName: "",
    password: "",
    error: "",
    processing: false,
    setMode(mode) {
      this.mode = mode;
      this.error = "";
    },
    async submit() {
      if (this.processing) return;
      this.error = "";
      this.processing = true;
      try {
        if (this.mode === "register") {
          await Alpine.store("session").register({
            email: this.email,
            displayName: this.displayName,
            password: this.password,
          });
        } else {
          await Alpine.store("session").signIn({
            email: this.email,
            password: this.password,
          });
        }
        this.email = "";
        this.displayName = "";
        this.password = "";
        Alpine.store("app").afterAuth();
      } catch (err) {
        this.error =
          err.message || Alpine.store("lang").t("auth.generic_error");
      } finally {
        this.processing = false;
      }
    },
    async socialSignIn(provider) {
      if (this.processing) return;
      this.error = "";
      this.processing = true;
      try {
        await Alpine.store("session").simulatedSocialSignIn(provider);
        Alpine.store("app").afterAuth();
      } catch (err) {
        this.error =
          err.message || Alpine.store("lang").t("auth.generic_error");
      } finally {
        this.processing = false;
      }
    },
  };
}
