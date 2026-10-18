# dotfiles

Configuration for my Arch Linux PC (Hyprland + Noctalia, uwsm session). This repo holds two kinds of files:

| Where | What | How it gets into place |
|---|---|---|
| `<package>/…` (e.g. `kitty/`, `hypr/`) | User configs under `~` | **Symlinked** by GNU Stow |
| `system/…` | Root-owned files under `/etc` and `/usr` | **Copied** by `system/install.sh` |

The real files live in this repo. Symlinks in `~` point into it, so editing `~/.config/kitty/kitty.conf` edits the repo copy directly.

---

## Layout

```
~/dotfiles/
├── .stowrc              # stow defaults: --no-folding, target = $HOME
├── .gitignore           # generated files and secrets that must never be committed
├── pkglist-repo.txt     # explicitly installed packages (official repos)
├── pkglist-aur.txt      # explicitly installed packages (AUR)
├── notes/               # reference material (e.g. the Plasma removal lists)
├── system/              # files for /etc and /usr + install.sh
└── <package>/           # one folder per program, mirroring $HOME
    └── .config/<program>/…
```

A stow **package** is a folder whose contents mirror your home folder. For example, `kitty/.config/kitty/kitty.conf` becomes `~/.config/kitty/kitty.conf`.

Current packages: `btop fontconfig git hypr kanshi kitty noctalia nvim pacman qt5ct scripts starship systemd uwsm xkb yazi zsh`. Run `ls ~/dotfiles` for the up-to-date list.

---

## Stow

### Everyday commands (run from `~/dotfiles`)

```bash
stow kitty          # link a package
stow -R kitty       # re-link (after adding or removing files in the package)
stow -D kitty       # remove the links (files in the repo are untouched)
stow -n -v kitty    # dry run: show what would happen
```

### `--no-folding` (set in `.stowrc`)

By default, stow links whole folders where it can. With `--no-folding`, it creates real folders in `~` and links **each file** separately. This matters because programs write generated files (Noctalia's palette files, caches) into their config folders. With per-file links, those files land in `~/.config/…` and stay out of the repo.

The trade-off: **a new file you add to a package isn't linked until you run `stow -R <package>`.**

### Adding a new config

```bash
mkdir -p foo/.config/foo
mv ~/.config/foo/foo.conf foo/.config/foo/     # only the files you want tracked
stow foo
ls -l ~/.config/foo                             # foo.conf → symlink into ~/dotfiles
```

For a program that's **running** and reads its config live (Hyprland, Noctalia), copy first and let stow swap the files:

```bash
cp -a ~/.config/foo foo/.config/
rm foo/.config/foo/<generated files>            # keep generated files out of the repo
stow --adopt foo
```

⚠️ `--adopt` **overwrites the repo copy with whatever is in `~`**. Use it only when both are identical, as above. Never use it on a fresh machine whose configs are still the defaults.

### Things to know

- **"existing target is not owned by stow"**: a real file is in the way. Stow refuses rather than overwrite it. Move the file aside, then stow again.
- **Programs that save by rename** (write a temp file, then rename it over the original) replace the symlink with a regular file, and the repo copy silently goes stale. Check with `ls -l` after a program saves its settings. Noctalia's GUI settings live in `~/.local/state/noctalia/` and aren't tracked.
- **Stow ignores** `.git`, `.gitignore`, and `README*` / `LICENSE*` at a package's top level. That's why `nvim/.config/nvim/.gitignore` is never linked.
- **Generated files** are listed in `.gitignore`: `noctalia*` palettes, `current-theme.lua`, `qt*ct/colors/noctalia.conf`, and so on. If `git status` shows a file that's regenerated automatically, add it there.

---

## System files (`system/install.sh`)

Files that root reads or runs (udev rules, sleep hooks, GRUB scripts, systemd units) are **copied, never symlinked**. A symlink into a folder you own would let anything running as your user change what root executes.

```bash
./system/install.sh            # diff:    compare repo with the live system (no output = identical)
./system/install.sh collect    # live → repo: run after editing a file in /etc
./system/install.sh install    # repo → live: only files listed in INSTALL
```

- **Run it as your user**, not with `sudo`. It calls `sudo` itself and refuses to run as root.
- **`INSTALL`** (at the top of the script) lists `"path mode"` pairs. Git only records whether a file is executable, so the script sets owner and mode itself.
- **Backups** of overwritten files go to `/var/backups/dotfiles/<timestamp>/`. They don't go next to the original, because GRUB and systemd-sleep run every executable file in their folders.
- **Reference-only files** are tracked but deliberately **not** in `INSTALL`: `fstab`, `default/grub`, `pacman.conf`. They contain this install's UUIDs. On a new install, compare them and merge by hand.
- **`install`** also sets up the SDDM theme's user-writable files (`sddm_setup`).
- After installing, run what applies: `sudo grub-mkconfig -o /boot/grub/grub.cfg`, `sudo udevadm control --reload`, `sudo systemctl daemon-reload`.

### Adding a system file

```bash
mkdir -p system/etc/foo
sudo cat /etc/foo/bar.conf > system/etc/foo/bar.conf   # copy stays owned by you
# then add "etc/foo/bar.conf 644" to INSTALL if it should be installed automatically
```

`collect` only refreshes files already in `system/`. New files are never picked up automatically, so a secret can't slip in by accident.

**Never track:** `/etc/restic/password`, `/etc/sing-box`, `/etc/NetworkManager/system-connections`, NUT's `upsd.users` and `upsmon.conf`, SSH host keys.

---

## Git

### Routine

```bash
git status                      # what changed
git diff                        # review before committing
git add -A && git commit -m "…" && git push
```

`starship.toml` shows as modified after every theme switch, because `theme-sync` rewrites its `palette =` line. Commit it, or discard the change with `git checkout starship`.

### ⚠️ This repo is live

Every config in `~` is a symlink into this working tree, so **any git command that changes files on disk changes your running system**.

| Safe | Changes live configs |
|---|---|
| `status` `diff` `log` `add` `commit` `push` `fetch` | `checkout` `switch` `restore` `stash` `reset --hard` `rebase` `pull` (merges) |

Example: during a `rebase`, older commits are checked out one after another. Hyprland's config disappears for a moment and Hyprland drops into emergency mode.

**To rewrite history** (fix an author, squash commits), do it in a separate clone and bring the result back:

```bash
git clone ~/dotfiles /tmp/df && cd /tmp/df
# … rebase / amend here …
cd ~/dotfiles && git status            # must be clean
git fetch /tmp/df main && git reset --hard FETCH_HEAD
git push --force-with-lease
```

`~/.gitconfig` is itself a link into the repo. A history rewrite in place would make git read old versions of it mid-rebase.

---

## Package lists

```bash
pacman -Qqen > pkglist-repo.txt          # refresh (after installing/removing things)
pacman -Qqem > pkglist-aur.txt

sudo pacman -S --needed - < pkglist-repo.txt   # restore
yay -S --needed - < pkglist-aur.txt
```

---

## New machine / reinstall

1. Install Arch: Btrfs with the same subvolume layout, LUKS root, GRUB. Set up the snapper config for `/`.
2. Install packages from the two lists (see above).
3. Get the repo: `gh auth login`, then `git clone git@github.com:<user>/dotfiles.git ~/dotfiles`.
4. Link the user configs. Default configs that already exist are in the way, so remove or move them first:
   ```bash
   cd ~/dotfiles
   for p in */; do p=${p%/}; [[ $p == system || $p == notes ]] || stow -n "$p"; done   # dry run
   for p in */; do p=${p%/}; [[ $p == system || $p == notes ]] || stow "$p"; done
   ```
5. System files: `./system/install.sh install`, then `grub-mkconfig`. Merge `fstab`, `default/grub` and `pacman.conf` by hand.
6. Enable services:
   ```bash
   sudo systemctl enable --now restic-backup.timer paccache.timer reflector.timer \
        btrfs-scrub@-.timer snapper-cleanup.timer smartd
   systemctl --user enable --now syncthing.service noctalia.service
   ```
7. Secrets that aren't in the repo:
   - KeePass database: pair Syncthing with the phone and sync `~/Sync/keepass`.
   - Restic password: from KeePass, into `/etc/restic/password` (mode `600`).
   - SSH keys, sing-box configs.
8. Restore personal data from restic if needed: `sudo restic-sys restore latest --target / --include /home/<user>/…`.
9. In SDDM, pick the **Hyprland** session (the uwsm-managed one), log in, and switch the Noctalia palette once so all templates are generated.

---

## Maintenance (weekly)

```bash
yay -Pw                              # read unread Arch news first
yay -Syu
sudo DIFFPROG='nvim -d' pacdiff      # merge .pacnew files, then ./system/install.sh collect
systemctl --failed; journalctl -p 3 -b
```

Monthly: review orphans (`pacman -Qdtq`), check SMART and Btrfs device stats, refresh the package lists, commit and push.
