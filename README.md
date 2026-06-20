<p align="center">
  <img src="logo.png" alt="Banners-Turnip" width="600"/>
</p>

# Banners-Turnip
[![Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?logo=discord&logoColor=white)](https://discord.gg/n8S4G2WZQ4)


> Automated, bleeding-edge builds of the [Mesa Turnip](https://docs.mesa3d.org/drivers/freedreno.html) Vulkan driver — compiled directly from the latest upstream Mesa commits and packaged for [AdrenoTools](https://github.com/K11MCH1/AdrenoToolsDrivers)-compatible apps on Qualcomm Adreno GPUs.

[![Build Turnip (Combined)](https://github.com/The412Banner/Banners-Turnip/actions/workflows/turnip_build_combined.yml/badge.svg?branch=A8xx)](https://github.com/The412Banner/Banners-Turnip/actions/workflows/turnip_build_combined.yml)
[![Latest Release](https://img.shields.io/github/v/release/The412Banner/Banners-Turnip?label=latest%20release&color=blue)](https://github.com/The412Banner/Banners-Turnip/releases/latest)

---

## What Is This?

[Turnip](https://docs.mesa3d.org/drivers/freedreno.html) is the open-source Mesa Vulkan driver for Qualcomm Adreno GPUs — developed as part of the [Mesa](https://gitlab.freedesktop.org/mesa/mesa) project and maintained by the Freedreno community. Unlike the proprietary Qualcomm driver, Turnip is fully open-source and often ships fixes and feature support ahead of official Qualcomm releases.

This repo automatically builds Turnip from the absolute latest commit on `mesa/main` — no waiting for official Mesa releases. A [Mesa upstream watcher](.github/workflows/mesa-watcher.yml) polls for new commits every hour and triggers a fresh build automatically whenever `mesa/main` advances. The result is an [AdrenoTools](https://github.com/K11MCH1/AdrenoToolsDrivers)-compatible ZIP you can drop straight into any compatible app (BannerHub/BCI, Winlator, etc.) to get the most up-to-date driver available.

---

## Driver Variants & Downloads

Each release ships three driver ZIPs — pick the one matching your GPU.

[**Download latest →**](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases) · [**Full build history →**](Mesa-commit-history.md)

### A6xx / A7xx — Standard

Pure Mesa `main`, no source patches. Compatible with Adreno 600–700 series GPUs (Snapdragon 600–800 series, including 7 Gen and 8 Gen 1–3).

### A710 / A720 / A722 — Experimental / Work in Progress

Injects hardware-specific GPU entries and magic registers for Adreno 710, 720, and 722 on top of Mesa `main` via [`a710-720.py`](patches/a710-720.py) — based on community research by [Vauzi-17](https://github.com/Vauzi-17/710). No upstream Mesa support exists for these GPUs yet. Early results are promising. Recommended: force sysmem mode via `TU_DEBUG=sysmem` until GMEM is confirmed stable. Winlator users: set `WRAPPER_BLIT=1`.

### A8xx — Experimental

Targets Adreno 800-series (Snapdragon 8 Elite — A810, A825, A829, A830). Built from Mesa `main` with the following patches on top:

| Patch | What it does |
| :--- | :--- |
| `tu8_kgsl_26.patch` | 9 commits from [whitebelyash/mesa-tu8](https://github.com/whitebelyash/mesa-tu8): UBWC gralloc detection, `disable_gmem` GPU property, A8xx magic regs, A810/A825/A829/A830 GPU configs, gmem cache fixes |
| `fix_a8xx_dev_info.py` | Re-adds `disable_gmem` to `freedreno_dev_info.h` and `tu_cmd_buffer.cc` — safeguard if the patch hunk drifts on a new Mesa commit |
| `apply_a8xx_gpus.py` | Ensures A810/A825/A829 GPU entries are present in `freedreno_devices.py` — safeguard if the patch hunk drifts on a new Mesa commit |

**Use at your own risk.**

---

## Workflows

| Workflow | Trigger | What it builds |
| :--- | :--- | :--- |
| **Build Turnip (Combined)** | Auto (mesa-watcher) or manual | Standard + A8xx + A710/A720/A722 in parallel; published as a single tagged release |
| **Build Turnip A8xx (Experimental)** | Manual | Standalone A8xx test build — faster iteration outside the release cycle |
| **Build Turnip (Perf 6xx/7xx)** | Manual | A6xx/A7xx only, compiled with `-O3` + ThinLTO for performance testing |

---

## Installation

- **BannerHub / BCI:** Component Manager → Add New Component → select the ZIP
- **AdrenoTools-compatible apps (Winlator, etc.):** load the ZIP in GPU driver settings

---

## Latest Build

<!-- LATEST_BUILD_START -->
| | |
| :--- | :--- |
| **Mesa version** | 26.2.0 |
| **Vulkan version** | Vulkan 1.4.354 |
| **Commit** | [`304324e`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/304324eb288de91ab6440d95a2d2e54e3d6573ee) |
| **Commit date** | 2026-06-20 |
| **Commit title** | nak: convert base to iadd for non-uniform ldcx lowering |
| **Build date** | 20260620 |
| **Release** | [v26.2.0-20260620-r5](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260620-r5) |
<!-- LATEST_BUILD_END -->

---

## Recent Builds (Last 24 Hours)

<!-- RECENT_BUILDS_START -->
| Tag | Date | Commit | Description | Vulkan |
| :--- | :--- | :--- | :--- | :--- |
| [v26.2.0-20260620-r5](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260620-r5) | 2026-06-20 | [`304324e`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/304324eb288de91ab6440d95a2d2e54e3d6573ee) | nak: convert base to iadd for non-uniform ldcx lowering | Vulkan 1.4.354 |
| [v26.2.0-20260620-r4](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260620-r4) | 2026-06-20 | [`6f0d6f7`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/6f0d6f7c044ab6a0d1a00d10367df01496c4eb16) | meson: require r300 LLVM draw only on x86 | Vulkan 1.4.354 |
| [v26.2.0-20260620-r3](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260620-r3) | 2026-06-20 | [`2046b79`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/2046b79f2f043502a44bd86b64f2db256b002697) | vulkan/wsi/wayland: Do a roundtrip after retiring the old swapchain. | Vulkan 1.4.354 |
| [v26.2.0-20260620-r2](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260620-r2) | 2026-06-20 | [`27e63a9`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/27e63a959ee44b7b18bce07cb32d7f3c6a08fb4b) | nak: normalize lop3 constant sources | Vulkan 1.4.354 |
| [v26.2.0-20260620](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260620) | 2026-06-20 | [`9dbe884`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/9dbe8846f5f94699ef4080dd58e31f9a1fdca836) | d3d12/wgl: reclaim deferred BOs before ResizeBuffers | Vulkan 1.4.354 |
| [v26.2.0-20260619-r8](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260619-r8) | 2026-06-19 | [`59a9e21`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/59a9e21652eaf7309b000a5ea751ec85a781f3ce) | ac,radeonsi: remove uses_kernel_cu_mask and associated code | Vulkan 1.4.354 |
| [v26.2.0-20260619-r7](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260619-r7) | 2026-06-19 | [`2ed09c8`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/2ed09c8b110f913365ba0bfd7e7d34cea26030f0) | kraid: Add OpRegIn and OpRegOut | Vulkan 1.4.354 |
| [v26.2.0-20260619-r6](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260619-r6) | 2026-06-19 | [`805b6e7`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/805b6e75e7e95ed78bf81c840878da572a1758ca) | nvk: add env var to allow backwards compat in dlss | Vulkan 1.4.354 |
| [v26.2.0-20260619-r5](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260619-r5) | 2026-06-19 | [`08c2bb3`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/08c2bb3b31db0eb9414ca0c8455c7a962797369c) | radeonsi/mm: Set correct usage in si_dec_fill_surface | Vulkan 1.4.354 |
| [v26.2.0-20260619-r4](https://github.com/as14725836/termux-glibc-Banners-Turnip/releases/tag/v26.2.0-20260619-r4) | 2026-06-19 | [`a9d7022`](https://gitlab.freedesktop.org/mesa/mesa/-/commit/a9d70225eca226410a7455bbbb1eb6925b56b4b9) | gallivm: fix lp_build_round on altivec/VSX | Vulkan 1.4.354 |
<!-- RECENT_BUILDS_END -->

---

## Release Tags

Tags follow the format `v{mesa-version}-{YYYYMMDD}`:

| Tag | Meaning |
| :--- | :--- |
| `v26.2.0-20260427` | First build of the day |
| `v26.2.0-20260427-r2` | Second build of the same day |
| `v26.2.0-20260427-r3` | Third build of the same day |

The `-r` counter starts fresh each day. Multiple builds on the same day happen when Mesa receives more than one commit within 24 hours — each new upstream commit triggers a new build.

---

## Forking / Self-Hosting

You can fork this repo and get fully automated builds running with minimal setup — no custom secrets or external accounts required. All CI uses the built-in `GITHUB_TOKEN`.

**After forking:**

1. **Enable Actions** — GitHub disables Actions on forks by default. Go to **Settings → Actions → General** and set it to *Allow all actions*.

2. **Enable write permissions for Actions** — Under **Settings → Actions → General → Workflow permissions**, select *Read and write permissions*. This is required for the watcher to commit hash files, update the README, and trigger builds.

3. **Reset state files** — The repo ships with state files that track upstream positions. Reset them so your fork starts clean:
   - `mesa_hash.txt` — clear or delete (watcher records the current Mesa HEAD here; a stale value skips the first build trigger)
   - `steven_last_tag.txt` — clear or delete (same, for the StevenMXZ release watcher)
   - `perf_build_number.txt` — set to `1` (incremented and committed by the perf build workflow; leaving it at the current value just means your first perf build gets a higher number, which is harmless but confusing)

4. **Keep the branch named `A8xx`** — The README auto-update step in `turnip_build_combined.yml` has `A8xx` hardcoded in four places (`git fetch/checkout/pull/push origin A8xx`). If you rename the branch, that step will fail and your README won't auto-update. Either keep the branch as `A8xx` or do a find-and-replace in `.github/workflows/turnip_build_combined.yml` to match your branch name.

5. **Update cosmetic repo references** *(optional)* — A few strings in the workflows reference the original repo: patch links in release note bodies and `"author"` in `meta.json`. Search for `The412Banner` in `.github/workflows/` and update to your own username/repo if desired. These don't affect build functionality.

6. **Kick off your first build** — GitHub Actions schedules don't fire automatically on forks until the repo sees some activity. Manually trigger either:
   - **Mesa Upstream Watcher** → *Run workflow* — records the current Mesa HEAD and fires a combined build if it's new
   - **Build Turnip (Combined)** → *Run workflow* — builds and publishes a release immediately without waiting for the watcher

Once those steps are done, the watcher polls Mesa upstream every hour and triggers a fresh build automatically — no further maintenance needed.

---

## Credits

This project wouldn't exist without the hard work and dedication of these community members. A huge thank you to each of them for sharing their knowledge, publishing their work openly, and being available to help — they're the reason any of this is possible.

| | |
| :--- | :--- |
| [**Mesa / Freedreno**](https://gitlab.freedesktop.org/mesa/mesa) | The open-source project that Turnip is part of — without Mesa and the Freedreno community's ongoing development, none of this exists. |
| [**whitebelyash**](https://github.com/whitebelyash) | Author of the [mesa-tu8](https://github.com/whitebelyash/mesa-tu8) A8xx patchset — the foundation of our A8xx driver variant. His research into A810/A825/A829/A830 GPU enablement, KGSL support, and UBWC fixes made Snapdragon 8 Elite Turnip support possible. |
| [**Vauzi**](https://github.com/Vauzi-17) | Author of the [A710/A720/A722 GPU enablement work](https://github.com/Vauzi-17/710) — hardware-specific magic registers, tuned GPU properties, and chip ID research that our experimental 710/720/722 test build is built on. |
| [**bylaws**](https://github.com/bylaws) | Creator of [libadrenotools](https://github.com/bylaws/libadrenotools) — the driver loading framework that makes all of this usable on Android without root. Without libadrenotools, custom Turnip builds would have no delivery mechanism. |
| [**Kimchi**](https://github.com/K11MCH1) | Maintainer of [AdrenoToolsDrivers](https://github.com/K11MCH1/AdrenoToolsDrivers) — one of the most well-established and trusted custom driver repositories in the Android GPU community, built on top of libadrenotools. |
| [**StevenMXZ**](https://github.com/StevenMXZ) | For his ongoing Turnip builds and releases that the community relies on, and for making his work openly available for others to build upon. |

Also thanks to anyone I forgot and not listed — the Android GPU community is full of people whose contributions quietly make things work, and they deserve recognition too.

---

<sub>☕ [Support on Ko-fi](https://ko-fi.com/the412banner)</sub>


## Community

Join our Discord: https://discord.gg/n8S4G2WZQ4
