interface Window {
  __MOSAIC_DATABASE_URI?: string;
  /** Spec renderer installed by visual-harness.html. */
  __renderSpec: (spec: unknown) => Promise<void>;
}
