# Master Prompt: Create a Safe Arch Linux System Cleanup Script

## Role

You are an expert **Arch Linux system administrator and Bash developer**.

Create a **single production-quality Bash script** named:

`system-cleanup`

The result must be a **script**, not a full application, daemon, service, package, GUI, or separate utility framework.

The script should provide a polished **interactive terminal UI/UX** while remaining a straightforward, maintainable Bash script.

Do not create multiple scripts unless absolutely required. Keep the implementation self-contained.

The script must be designed specifically for:

- Arch Linux
- systemd
- pacman
- Snapper
- Btrfs systems
- Normal desktop users

The cleanup scope is strictly limited to the cleanup categories defined below.

---

# 1. Script Startup

When the script starts:

1. Detect the current user.
2. Verify that `sudo` is available.
3. Verify that the user can authenticate with sudo.
4. Ask for the sudo password **once at the beginning**.
5. Validate sudo authentication before beginning cleanup.
6. Keep the sudo credential cached for the duration of the script where possible.
7. Do not repeatedly ask for the sudo password for every cleanup step.

If authentication fails:

- Show a clear error.
- Allow retry.
- Allow exit.

Do not run the entire script as root.

---

# 2. Terminal UI / UX

The script must have a clean, readable terminal interface.

This is still a **Bash script**, so do not build an application framework.

Use normal shell techniques such as:

- ANSI escape sequences where appropriate
- Functions
- Tables
- Progress indicators
- Spinners where useful
- Clear section headers
- Confirmation prompts

Provide consistent statuses:

- `[INFO]`
- `[CHECK]`
- `[CLEAN]`
- `[DONE]`
- `[SKIP]`
- `[WARN]`
- `[ERROR]`

Avoid flooding the terminal with raw command output.

Capture command output internally where practical and show a concise explanation to the user.

Provide a detailed error output option when necessary.

---

# 3. Initial System Overview

After sudo authentication, display a concise system overview.

Include:

- Hostname
- Username
- Root filesystem usage
- Home filesystem usage
- Available space
- systemd journal size
- Pacman cache size
- Coredump size
- Trash size
- `/tmp` size
- `/var/tmp` size
- Snapper snapshot count

Use appropriate commands such as:

- `df`
- `du`
- `journalctl --disk-usage`
- `snapper list`

Do not perform cleanup during this initial scan.

---

# 4. Cleanup Progress

The script must make progression extremely clear.

Display the current stage, for example:

`[ 3/10 ] Cleaning Pacman package cache...`

For every cleanup stage:

### Before

Measure the relevant target with `du` or another appropriate mechanism.

Display:

`Before: 1.42 GiB`

### During

Show:

- Current operation
- Spinner or progress indicator when useful
- Warning/error messages if something unexpected happens

Do not fake percentage progress where the underlying command cannot provide meaningful progress.

### After

Measure the target again.

Calculate:

`reclaimed = before - after`

Display:

`After: 120 MiB`
`Reclaimed: 1.30 GiB`

Maintain a global total:

`Total reclaimed: 2.41 GiB`

---

# 5. Space Accounting

Maintain an accurate running cleanup total.

For every cleanup category:

- Measure before
- Perform cleanup
- Measure after
- Calculate difference
- Add positive reclaimed space to the global total

At the end show:

- Space before
- Space after
- Total reclaimed
- Reclaimed space per category

Do not rely solely on tool output such as:

`freed 87.5M`

when before/after filesystem measurements are available.

Use measured filesystem usage wherever practical.

Handle zero or negligible differences correctly.

Never display negative reclaimed space as a successful cleanup.

---

# 6. Main Menu

Provide a simple Bash menu.

The exact implementation is up to you, but it should expose options similar to:

```text
System Cleanup
───────────────

1. Review cleanup targets
2. Clean coredumps
3. Clean pacman cache
4. Clean user cache
5. Clean trash
6. Clean /tmp
7. Clean /var/tmp
8. Clean traditional system logs
9. Clean systemd journal
10. Review/remove Snapper snapshots
11. Run full cleanup
12. Exit
```

The user must be able to perform individual cleanup operations or run the full cleanup sequence.

---

# 7. Review / Dry-Run Mode

Option 1 must perform **inspection only**.

It must not delete anything.

Show:

- Coredump size
- Pacman cache size
- User cache size
- Trash size
- `/tmp` size
- `/var/tmp` size
- Traditional `/var/log` usage
- systemd journal usage
- Snapper snapshots
- Number of removable Snapper snapshots

Show a summary of potentially reclaimable space.

Clearly identify:

- Cleanable
- Requires confirmation
- Protected
- Unavailable

---

# 8. Coredump Cleanup

Clean **existing stored coredump files only**.

Do NOT:

- Disable coredumps
- Modify `/etc/systemd/coredump.conf`
- Configure coredump limits
- Configure future automatic retention
- Disable `systemd-coredump`

Inspect:

`/var/lib/systemd/coredump`

Use `coredumpctl` where useful for information.

Before cleanup:

- Show coredump count
- Show total size

After cleanup:

- Measure again
- Calculate reclaimed space

Use controlled deletion of regular files inside the coredump directory.

Do not delete the directory itself.

Explain that after deletion:

`coredumpctl list`

may still show:

`COREFILE=missing`

because journal metadata remains.

This is expected.

Do not erase journal records merely to remove `missing`.

---

# 9. Full Pacman Cache Cleanup

Use exactly the native Arch package cleanup mechanism:

`pacman -Scc`

Do not replace it with:

- `paccache`
- `yay -Scc`
- Other third-party package cache tools

Before cleanup:

- Measure `/var/cache/pacman/pkg`
- Explain that **all cached packages** will be removed
- Warn that packages may need to be downloaded again
- Ask for confirmation

Run the native `pacman -Scc` process.

## Required fallback

Handle this known failure:

`error: could not remove /var/cache/pacman/pkg/download-XXXXXX: Is a directory`

If leftover directories matching:

`/var/cache/pacman/pkg/download-*`

remain:

1. Detect them.
2. Report them as residual pacman download directories.
3. Clearly display the error.
4. Offer a fallback cleanup.
5. The fallback must target **only** those `download-*` directories.
6. Do not delete unrelated pacman files.
7. Re-measure the cache afterward.
8. Report whether the fallback succeeded.

The fallback may use controlled recursive removal specifically for those `download-*` directories because this case is explicitly part of the requested cleanup behavior.

---

# 10. User Cache Cleanup

Target:

`~/.cache/*`

Before cleanup:

- Measure `~/.cache`
- Show its size
- Warn that applications can regenerate cache data
- Ask for confirmation

Clean the contents of `~/.cache`.

Preserve the `~/.cache` directory itself.

Do not touch:

- `~/.config`
- `~/.local/share`
- Projects
- Documents
- Downloads
- Source code
- Arbitrary application data

Measure afterward and report reclaimed space.

The cleanup must not fail merely because the cache directory is empty.

---

# 11. Trash Cleanup

Target:

`~/.local/share/Trash/`

Measure current size.

Ask exactly or equivalently:

`Do you wish to permanently remove everything in Trash?`

Warn that the operation is permanent.

Only proceed on explicit confirmation.

Clean the contents but preserve the Trash directory structure.

Measure afterward.

Report reclaimed space.

If Trash does not exist, report:

`[SKIP] Trash directory not found.`

Do not treat that as a failure.

---

# 12. `/tmp` Cleanup

Clean the contents of:

`/tmp`

Do not delete the `/tmp` directory itself.

Recognize that `/tmp` is actively used by running applications.

Use safe temporary-file cleanup behavior and avoid indiscriminate deletion of currently required runtime files.

Measure before and after.

If some files cannot be removed because they are in use:

- Continue
- Report the skipped files/count
- Mark the stage as partial rather than falsely reporting complete success

---

# 13. `/var/tmp` Cleanup

Clean:

`/var/tmp`

Do not delete the `/var/tmp` directory itself.

Recognize that `/var/tmp` can intentionally contain files across reboots.

Use an appropriate controlled cleanup strategy.

Measure before and after.

Report:

- Removed data
- Skipped data
- Errors
- Reclaimed space

---

# 14. Traditional System Logs

Target:

`/var/log`

This category concerns **traditional log files outside the systemd journal**.

Before cleanup:

- Measure `/var/log`
- Identify major consumers
- Distinguish `/var/log/journal` from traditional logs

Do not blindly run:

`rm -rf /var/log/*`

Do not delete:

- `/var/log` itself
- Active log directories indiscriminately
- Configuration files
- Runtime state

Clean only the requested traditional log data using a controlled method.

If a file cannot safely be cleaned, report it rather than forcing deletion.

Measure before and after.

---

# 15. systemd Journal Cleanup

Use native systemd journal management.

Inspection:

`journalctl --disk-usage`

Cleanup:

`journalctl --vacuum-*`

The script should provide at least:

- Conservative cleanup option
- Aggressive cleanup option

The demonstrated aggressive policy:

`journalctl --vacuum-size=1M`

may be offered.

Before an aggressive cleanup, clearly warn that very little historical journal data will remain.

Do not manually delete files in:

`/var/log/journal`

Measure journal usage before and after.

Report reclaimed space.

---

# 16. Snapper Cleanup

The system uses Snapper with Btrfs.

Inspect:

`snapper list`

Snapshot:

`0`

is protected and **must never be deleted**.

Only snapshots with numbers other than `0` may be removed.

If output contains only:

`0 | current`

display:

`[SKIP] No removable Snapper snapshots found.`

If other snapshots exist:

- List them
- Show number
- Date
- Type
- Description
- Cleanup state where available
- Clearly mark snapshot `0` as protected

Allow the user to choose which non-zero snapshots to delete.

Use:

`snapper delete <number>`

or the appropriate native Snapper mechanism.

Never use raw filesystem deletion on `.snapshots`.

Reject any attempt to select snapshot `0`.

---

# 17. Snapper Edge Cases

Handle:

- Snapper not installed
- No Snapper configuration
- Only snapshot `0`
- Multiple snapshots
- Invalid snapshot number
- Snapshot deletion failure
- Permission errors

These conditions must not terminate the entire script.

Record failures and continue.

---

# 18. Full Cleanup Flow

The full cleanup option should run the cleanup categories in this order:

```text
1. Initial measurements
2. Coredumps
3. Pacman cache
4. User cache
5. Trash
6. /tmp
7. /var/tmp
8. Traditional /var/log
9. systemd journal
10. Snapper snapshot review
11. Final measurements
12. Final summary
13. Exit/BleachBit menu
```

Before each stage:

- Show stage number
- Show target
- Show current size
- Ask for confirmation where required

For a full cleanup, allow the user to choose:

`Confirm all`
or
`Confirm each stage`

Do not remove protected data automatically.

---

# 19. Error Handling

Implement robust Bash error handling.

The script must:

- Check command exit statuses
- Capture stderr where useful
- Detect missing commands
- Detect missing directories
- Detect permission failures
- Detect partial cleanup
- Detect residual files after cleanup
- Continue to independent cleanup stages

Do not use `set -e` in a way that causes the entire cleanup process to terminate after one cleanup failure.

Use controlled error handling instead.

For every failure show:

- Stage
- Operation
- Error
- Whether cleanup partially succeeded
- Recommended next action

---

# 20. Failure Tracking

Maintain arrays/lists internally for:

### Successful

Cleanup completed successfully.

### Partial

Some data was removed but residual data/errors remain.

### Skipped

User declined, target unavailable, or no cleanup was necessary.

### Failed

Cleanup could not be completed.

At the end show every failed or partial stage.

Do not hide failures.

Do not claim complete success when an important operation failed.

---

# 21. Final Summary

After cleanup, display a clear final report.

Include:

### Space Summary

```text
Initial selected cleanup data : X GiB
Final selected cleanup data   : Y GiB
Total reclaimed               : Z GiB
```

### Per-stage Summary

```text
Coredumps        X → Y    reclaimed Z
Pacman cache     X → Y    reclaimed Z
User cache       X → Y    reclaimed Z
Trash            X → Y    reclaimed Z
/tmp             X → Y    reclaimed Z
/var/tmp         X → Y    reclaimed Z
Logs             X → Y    reclaimed Z
Journal          X → Y    reclaimed Z
```

### Result Summary

```text
Successful : N
Partial    : N
Skipped    : N
Failed     : N
```

Then list any failed/partial operations.

---

# 22. BleachBit Exit Option

At the end of the cleanup session, provide:

```text
1. Exit
2. Launch BleachBit
3. Return to main menu
```

Only show option 2 when BleachBit is actually installed.

Detect it rather than assuming its existence.

If installed:

- Show its detected executable
- Ask before launching
- Launch BleachBit normally
- Do not automatically perform BleachBit cleanup
- Return to the script when practical

Do not install BleachBit automatically.

BleachBit is an optional final hand-off, not part of the script's cleanup logic.

---

# 23. Safety Requirements

Never blindly perform:

- `rm -rf /`
- `rm -rf /usr/*`
- `rm -rf /etc/*`
- `rm -rf /var/lib/*`
- `rm -rf /var/log/*`
- Delete `/tmp` directory itself
- Delete `/var/tmp` directory itself
- Delete Snapper snapshot `0`
- Delete Btrfs subvolumes
- Delete pacman database
- Automatically remove unrelated packages
- Modify coredump configuration
- Install or run external cleanup utilities automatically

Keep the script strictly limited to the requested cleanup targets.

---

# 24. Bash Implementation Quality

Use clean, maintainable Bash.

Requirements:

- Functions for every cleanup category
- Centralized UI functions
- Centralized size-formatting functions
- Centralized confirmation handling
- Centralized error reporting
- Safe variable quoting
- Safe path handling
- Correct handling of paths containing spaces
- No unnecessary subprocess loops
- Avoid useless parsing where a native command provides structured information
- Graceful handling of empty results
- Clear comments for destructive operations

The script should be easy to modify later.

Do not create a package, daemon, systemd service, GUI, or separate application.

The deliverable is specifically:

**one interactive Bash cleanup script named `system-cleanup`.**

---

# 25. Required Command / Tool Hints

Use these as implementation references:

- `sudo`
- `du`
- `df`
- `coredumpctl`
- `pacman -Scc`
- controlled fallback removal of `/var/cache/pacman/pkg/download-*`
- `journalctl --disk-usage`
- `journalctl --vacuum-*`
- `systemd-tmpfiles --clean`
- `snapper list`
- `snapper delete <number>`
- `~/.cache/*`
- `~/.local/share/Trash/`
- `/tmp`
- `/var/tmp`
- `/var/log`
- BleachBit executable detection

These are **implementation hints**, not commands that must simply be printed to the user.

---

# 26. Final Goal

The finished Bash script should feel like a **well-designed Arch Linux maintenance script with a polished interactive terminal interface**.

It must provide:

- Sudo authentication at startup
- Clear cleanup progression
- Before/after `du` measurements
- Per-stage reclaimed space
- Running reclaimed-space total
- Clear warnings
- Strong backend error handling
- Complete failure tracking
- Safe Snapper handling with snapshot `0` protected
- Native `pacman -Scc` cleanup
- Pacman `download-*` fallback
- Coredump cleanup without changing future coredump policy
- User cache cleanup
- Explicit Trash confirmation
- `/tmp` and `/var/tmp` cleanup
- Traditional `/var/log` cleanup
- systemd journal cleanup
- Final summary
- Optional BleachBit launch
- Exit to shell

Do not expand the scope with unrelated cleaners or automatic system modifications.

The output must be a **single Bash script**, not a full application or utility package.