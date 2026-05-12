# Capture Pipeline

A portfolio that targets 10–15 annotated screenshots per module has two failure modes. Either I capture too few during a configuration session and lose the moments I needed, or I stop too often to snip and the configuration itself slows down enough that I lose context. The second problem is worse — interrupted configuration produces interrupted understanding.

`capture.ps1` is the engineering response. It runs as a background PowerShell daemon while I work in D365 and snapshots the active browser window on three triggers:

| Trigger | Reason tag | When it fires |
|---|---|---|
| Window-title change | `NAV` | D365 navigates to a new page (the page name is embedded in the browser tab's window title) |
| Stationary timer | `STAT` | Same page held for 10+ seconds (I've finished filling a form) |
| Manual hotkey | `FORCE` | I press `Ctrl+Alt+S` for a specific framing I want |

Three design choices keep the inbox usable:

- **Hash deduplication.** Each captured frame is sampled along its diagonal into a 256-pixel fingerprint and compared against the previous save. Identical-pixel frames (stationary load states, momentary tab focus losses) are dropped before they hit disk.
- **Window-title detection.** D365 F&O encodes the current page name in the browser tab title (`"Legal entities | Dynamics 365 - Edge"`). The daemon reads that via Win32's `GetForegroundWindow` and `GetWindowText` calls, so navigation events fire a capture without instrumenting the page itself or violating Microsoft's terms on browser automation.
- **Filename embedding.** Each saved PNG carries the timestamp, the trigger reason, and a sanitised page name in its filename. The inbox becomes self-documenting — I can scan filenames and reconstruct the configuration sequence without opening any image.

## Hotkeys
- `Ctrl+Alt+S` — force-capture the current window
- `Ctrl+Alt+X` — stop the daemon

## Run it
```powershell
cd "G:\My Drive\d365-finance-functional-portfolio\_automation"
.\capture.ps1 -Module 01
```

Pass the two-digit module prefix. The script resolves the matching `NN-*` folder and writes into its `_inbox/`.

## First-run setup
If PowerShell blocks the script with `cannot be loaded because running scripts is disabled`, run once in a regular (non-admin) PowerShell:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## Post-processing

A typical one-hour configuration session leaves 30–80 raw frames in the inbox. Two tasks remain: file management (renaming each PNG to match the module's step list, moving the chosen frames to `screenshots/`, archiving duplicates) and markdown wiring (slotting the chosen frame into the right inline reference in the module README).

Both tasks are mechanical and asset-oriented, not authorship. I run them as a vision-enabled LLM post-processing step:

1. The model reads each PNG and identifies which configuration screen it shows
2. Matches each screen against the inline screenshot markers in the module's README
3. Renames the selected frames and writes them into `screenshots/`
4. Edits the README to insert the markdown image links in the right positions
5. Flags any expected screens missing from the inbox so I know what to re-capture

This split is deliberate. The pipeline owns asset orchestration — file naming, directory placement, markdown link insertion, duplicate handling. I own everything that affects the substance of the portfolio: the configuration decisions themselves, the SLFRS / IFRS rationale in each module README, the field notes captured during the session, and the architectural choices about module sequencing and scope. Technical accuracy is reviewed against the linked Microsoft Learn sources before any commit.

The framing matters because the portfolio's value to a hiring manager isn't the screenshots. It's the accounting reasoning behind each configuration choice — and that reasoning has a single author.
