# Git Setup Guide for Mac

## Checking Your Git Configuration

Before you start, check if Git is already configured with your name and email:

1. Open Terminal (Applications > Utilities > Terminal or search with Spotlight ⌘+Space)
2. Run these commands to check your current Git configuration:
   ```bash
   git config --global user.name
   git config --global user.email
   ```
3. If these commands return your name and email, Git is already configured
4. If not, continue with the setup instructions below

## Visual Step-by-Step: Setting Up Git with Source Control Panel

### Step 1: Open Your Project in VS Code
1. Launch VS Code (Applications folder or Dock)
2. Go to `File > Open Folder` (or `⌘+O`)
3. Navigate to `/Users/danielreis/web/danrtzaq` and click "Open"

### Step 2: Access the Source Control Panel
1. Click on the Source Control icon in the sidebar (looks like a branch fork)
   - Keyboard shortcut: `⌘+Shift+G`
2. You should see a message that says "There are no active source control providers." with an "Initialize Repository" button

### Step 3: Initialize Git Repository
1. Click the "Initialize Repository" button
2. VS Code will create a Git repository in your project folder
3. A notification will appear in the bottom right confirming the initialization

### Step 4: Configure Git (First Time Setup Only)
If this is your first time using Git on your Mac:
1. Open the integrated terminal in VS Code (`Terminal > New Terminal` or ``⌃+` ``)
2. Run these commands:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

### Step 5: Create .gitignore File
1. In the Source Control panel, you'll see many files listed under "Changes"
2. Look for the .gitignore file that was already created
3. If not present, right-click in the Explorer panel and select "New File"
4. Name it ".gitignore" and paste the prepared contents, then save it (⌘+S)

### Step 6: Make Your First Commit
1. In the Source Control panel, you'll see all your files listed
2. Click the "+" (stage changes) button next to each file you want to include
   - Or click the "+" button next to "Changes" to stage all files
3. Type a commit message in the text box (e.g., "Initial commit")
4. Click the checkmark (✓) button above the message box to commit (or press ⌘+Enter)

### Step 7: Create a Remote Repository (Optional)
1. Go to GitHub.com (or your preferred Git hosting service)
2. Create a new repository (don't initialize it with README or .gitignore)
3. Copy the repository URL

### Step 8: Link to Remote Repository (Optional)
1. In VS Code, click on the "..." (more actions) in the Source Control panel
2. Select "Remote" > "Add Remote..."
3. Paste the repository URL you copied (⌘+V)
4. Give it a name (typically "origin")
5. Click "Add Remote"

### Step 9: Push Your Code (Optional)
1. Click on the "..." (more actions) in the Source Control panel
2. Select "Push to..." or "Push"
3. Select the remote repository you added
4. VS Code will push your code to the remote repository

### Step 10: Regular Git Workflow
1. Make changes to your files
2. In the Source Control panel, review your changes
3. Stage the changes you want to commit (using the "+" button)
4. Enter a descriptive commit message
5. Click the checkmark (✓) to commit or press ⌘+Enter
6. Use the Sync button (circular arrows) to pull and push changes

## Using Source Control Panel Features

### Viewing Changes
- Click on any modified file in the Source Control panel to see a diff view
- Red highlights show removed content, green highlights show added content

### Managing Branches
1. Click on the current branch name in the bottom-left corner of VS Code
2. A dropdown will appear showing all branches
3. To create a new branch, select "Create new branch..."
4. To switch branches, simply click on the branch name

### Resolving Conflicts
1. If conflicts occur during a merge or pull, VS Code will show conflict markers
2. Open the conflicted file
3. VS Code provides "Accept Current Change," "Accept Incoming Change," "Accept Both Changes," and "Compare Changes" options
4. After resolving all conflicts, stage the files and commit

## How .gitignore Works

When you run `git add .` or use the "Stage All Changes" option in VS Code, the .gitignore file automatically prevents specified files and directories from being included:

1. **Automatic filtering**: Git automatically checks the .gitignore rules before staging files
2. **Already committed files**: .gitignore won't affect files that were already committed. To stop tracking a file that's already committed:
   ```bash
   git rm --cached <file>
   ```
3. **Testing your .gitignore**: To see which files would be added without actually adding them:
   ```bash
   git add --dry-run .
   ```
4. **Local vs. Global ignores**: Your repository .gitignore affects everyone, while your personal ignores can be added to `~/.gitignore_global`
5. **Hidden files**: Files starting with `.` (like .DS_Store) need to be explicitly ignored as they're hidden in Finder

To set your global ignore file:
```bash
git config --global core.excludesfile ~/.gitignore_global
```

## Mac-Specific Git Tools

### Installing Git (if not already installed)
Most Macs come with Git pre-installed. To check, open Terminal and type:
```bash
git --version
```

If Git is not installed, you'll be prompted to install the Xcode Command Line Tools, which include Git.

### Terminal Commands for Mac

## Command Line Setup (Alternative)

### Initialize Git Repository
```bash
cd /Users/danielreis/web/danrtzaq
git init
```

## Configure Git
```bash
# Set your name and email
git config user.name "dreisdesign"
git config user.email "danreisdesign@gmail.com"

# Optional: Set default editor
git config core.editor "nano"  # or vim, code, etc.
```

## Initial Commit
```bash
# Add all files
git add .

# Initial commit
git commit -m "Initial commit"
```

## Working with Remote Repositories
```bash
# Add a remote repository
git remote add origin <repository-url>

# Push to remote
git push -u origin main  # or master, depending on your default branch
```

## Daily Git Workflow
```bash
# Before starting work
git pull

# After making changes
git add .
git commit -m "Descriptive message about changes"
git push
```

## Branching Strategy
```bash
# Create a new feature branch
git checkout -b feature/new-feature

# Switch between branches
git checkout main

# Merge a branch
git merge feature/new-feature
```

## Useful Git Commands
```bash
# Check status
git status

# View commit history
git log

# Discard changes in working directory
git checkout -- <file>

# Unstage a file
git reset HEAD <file>

# Create and apply patches
git format-patch -1 <commit>
git am < patch-file
```

## Mac GUI Git Clients

If you prefer a graphical interface instead of the command line:

- [GitHub Desktop](https://desktop.github.com/) - Simple and integrates well with GitHub
- [GitKraken](https://www.gitkraken.com/) - Feature-rich Git client (works on macOS 10.9+)
- [Sourcetree](https://www.sourcetreeapp.com/) - Free Git client by Atlassian for macOS

## Mac-Specific Git Tips

1. **Ignore Mac-specific files**: The .gitignore already contains `.DS_Store` files
2. **Keychain integration**: Git on Mac can use the macOS Keychain to securely store credentials
   ```bash
   git config --global credential.helper osxkeychain
   ```
3. **HomeBrew**: Consider using Homebrew to install and manage Git
   ```bash
   brew install git
   ```
4. **File permissions**: Mac's Unix foundation may require attention to file permissions
   ```bash
   # If you need to make a file executable
   chmod +x filename
   ```

## Git Best Practices for Website Projects

1. **Commit frequently** with descriptive messages
2. **Branch for features** - Create branches for new features or major changes
3. **Ignore build artifacts** - Use .gitignore to exclude compiled files
4. **Test before committing** - Ensure your website works before committing changes
5. **Backup database separately** - Git is for code, not data
6. **Document deployment process** - Include instructions for server deployment
