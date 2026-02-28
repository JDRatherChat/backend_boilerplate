# Git usage guide + cheat sheet

This is a practical Git reference for day-to-day work on Django projects.

---

## Core concepts (quick)

- **Working tree**: your files on disk
- **Staging area (index)**: what will go into the next commit
- **Commit**: a snapshot of staged changes
- **Branch**: a movable pointer to a commit
- **Tag**: a named pointer (usually to mark releases)

---

## Initial project setup

### Configure identity
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Create repo (if not already)
```bash
git init
git add .
git commit -m "Initial commit"
```

Add remote
```bash
git remote add origin <REMOTE_URL>
git push -u origin main
```

---
## Everyday workflow
### Check status
```bash
git status
```

### Pull latest changes
```bash
git pull
```

### Create a branch
```bash
git checkout -b feature/user-signup
```

### Stage + commit
```bash
git add .
git commit -m "Add user signup flow"
```

### Push branch
```bash
git push -u origin feature/user-signup
```

### Update your branch from main
```bash
git checkout main
git pull
git checkout feature/user-signup
git merge main
```

(or rebase, if your team prefers)
```bash
git rebase main
```

---
## Undo / recovery 
### Unstage a file
```bash
git restore --staged path/to/file
```

### Discard local changes in a file
```bash
git restore path/to/file
```

### Amend the last commit (message or staged changes)
```bash
git commit --amend
```

### Revert a commit (safe; makes a new commit)
```bash
git revert <commit_sha>
```

---
## Viewing history
### Log
```bash
git log --oneline --decorate --graph --all
```

### Show changes in a commit
```bash
git show <commit_sha>
```

---
## Tagging (releases)
 Use tags to mark releases like v0.0.2.

### Create an annotated tag (recommended)
```bash 
git tag -a v0.0.2 -m "Release v0.0.2"
```

### Push tags
```bash
git push origin v0.0.2
```

### Push all tags
```bash
git push --tags
```

### List tags
```bash
git tag --list
```

### Checkout a tag (detached HEAD)
```bash
git checkout v0.0.2
```

### Delete a tag

Local:
```bash
git tag -d v0.0.2
```

Remote:
```bash 
git push origin :refs/tags/v0.0.2
```

---
## A sensible commit style (simple)
- `feat: add login endpoint`
- `fix: handle null email`
- `chore: bump deps`
- `docs: update setup guide`
- `refactor: extract user service`

---
## Useful aliases (optional)
```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.last "log -1 HEAD"
git config --global alias.graph "log --oneline --decorate --graph --all"
```
