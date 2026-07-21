# Deployment checklist — SquidNoMo 1.1 beta 1 ultralight stable r4

The loader executes the GitHub repository, not files inside a downloaded ZIP. Deploying only selected files will create a mixed build.

1. Replace the repository contents with the complete `SquidNoMo-main` folder from this archive.
2. Confirm `BuildManifest.lua` reports `Revision = "ultralight-stable-r4"`.
3. Confirm `Features/Shared/Runtime.lua` reports `Revision = "1.1b1-ultralight-r4"`.
4. Confirm `Features/Shared/PlayerRuntime.lua` reports `Revision = "1.1b1-player-ultralight-r3"`.
5. Upload all 65 Games/Guard/Detective wrappers and all 25 Player wrappers with the shared runtimes.
6. Upload `Modules/FeatureCatalog.lua`, `Features/FeatureManager.lua`, `Core/App.lua`, `Loader.lua`, and `Main.lua` in the same commit.
7. Wait until the raw GitHub files show the new revisions before executing.
8. Re-execute once. The build revision retires an older in-server session and cache-busts remote file requests.
9. If the loader reports a manifest, runtime, or registry mismatch, do not bypass it; the repository is incomplete or stale.
10. Use `OPTIMIZATION_REPORT.md` for the live RLGL and auto-apply test order.
