# Smarty Vault: Unify Your Academic Life

The modern academic career is fragmented, often requiring students to juggle coursework, research files, and professional networking data across disparate systems. Smarty Vault is a unified, shell-script-driven organization system built on the powerful foundation of Obsidian and designed to solve this fragmentation.

Smarty Vault's philosophy is simple: maximize consistency, minimize friction.

It's a dedicated workflow engine that allows users to:

1. Professionalize Output: maintain an organized system of raw, Obsidian-based Markdown files along with consistent, publication-ready PDFs all in one file system.

2. Streamline Organization: Enforce a reliable, consistent directory structure across all academic activities, from active coursework to long-term research.

3. Build Your Network: Maintain a focused, up-to-date Career Relationship Management (CRM) database for tracking professional contacts, organizations, and events, allowing for quick retrieval and snapshot compilation of networking efforts.

By placing scripts, raw files, and a personal knowledge vault in a single, portable directory, Smarty Vault ensures you spend your time mastering material instead of managing files.

## Directory Structure

Smarty Vault uses the following directory structure:

```
/
├── init.sh                 
├── LICENSE                 
├── README.md               
└── template-root/                                
    ├── .scripts/
    │   ├── compilation/
    │   │   ├── crm-compile.sh
    │   │   ├── crm-decompile.sh
    │   │   └── pandoc-compile.sh
    │   ├── file-management/
    │   │   ├── archive-course.sh
    │   │   ├── archive-project.sh
    │   │   ├── new-course.sh
    │   │   ├── new-exploration.sh
    │   │   ├── new-project.sh
    │   │   ├── remove-course.sh
    │   │   ├── remove-exploration.sh
    │   │   └── remove-project.sh
    │   │   ├── unarchive-course.sh
    │   │   ├── unarchive-project.sh
    │   └── system-health/
    │       ├── check-health.sh
    │       └── package.sh
    ├── 00.academic-network/    
    ├── 01.courses/
    │   └── 00.archived/
    ├── 02.engagements-projects/
    │   └── 00.archived/
    ├── 03.research-exploration/
    └── 04.vault/          
        └── 00.academic-network/
            ├── 00.templates/
            │   ├── 01.person-template.md
            │   ├── 02.org-template.md
            │   └── 03.event-template.md
            ├── 01.people/
            ├── 02.orgs/
            ├── 03.events/
            └── CRM-DASHBOARD.md
```

The provided directories and scripts serve the following purposes:

### template-root/ 

Root of the system. Stores all non-Obsidian files: compiled PDFs (assignments, research papers), reference materials (textbooks), and code repositories.

All `.scripts/` use this as the base working directory.

### 00.academic-network/ 

Target directory for compiled Career Relationship Management (CRM) reports. Stores PDF snapshots of your network at different points in time.

Reports can be generated using `crm-compile.sh`.

### 01.courses/

Stores compiled output for coursework: finalized lecture notes, submitted problem sets, and graded assignments.

`new-course.sh`, `archive-course.sh`, `unarchive-course.sh`, and `remove-course.sh` can be used to manipulate files stored within this directory.

**Sample Course Subdirectory**

When running `new-course.sh`, the following standard folder is created within `01.courses/` to ensure uniformity for every class:

```
template-root/
└── 01.courses/
    └── [COURSE-NAME]/
        ├── assignments/
        │   ├── raw/           <-- Your editable source files (Markdown/Obsidian/LaTeX)
        │   └── submissions/   <-- Compiled, final PDFs sent to the instructor
        ├── notes/
        │   ├── lecture/       <-- Compiled, organized lecture notes (e.g., PDF)
        │   └── misc/          <-- Compiled auxiliary materials (e.g., PDF)
        ├── textbooks/         <-- Reference E-Books or digital readings
        └── code/              <-- Scripts, notebooks, or project codebases
```

The `code/` subdirectory is optional and can be added using the `--code` flag.

### 02.engagement-projects/

Holds compiled output for non-course, structured work, like internships, committee roles, or group projects.

`new-project.sh`, `archive-project.sh`, `unarchive-project.sh`, and `remove-project.sh` can be used to manipulate files stored within this directory.

### 03.research-exploration/

Stores long-term, exploratory work, including original research codebases, data files, and manuscripts.

`new-exploration.sh` and `remove-exploration.sh` can be used to manipulate files stored within this directory.

### 04.vault/

The Obsidian Vault. This folder contains all your editable, plain-text Markdown files, serving as the single source of truth for your knowledge and data.

## Setup and Dependencies

### 1. Dependencies and Prerequisites

- Obsidian: Installed on your system.
- Pandoc: Installed on your system and added to your system PATH (required for `pandoc-compile.sh` and `crm-compile.sh` to convert Markdown/LaTeX to professional PDFs).
- Shell Environment: A Unix-like shell (Bash/Zsh on macOS/Linux, or WSL/Git Bash on Windows) to run the .sh scripts.

### 2. Obsidian Plugin Installation (Recommended)

Install these community plugins to maximize the functionality of your Vault:
- Dataview: Essential for querying the structured data (metadata/YAML) in your notes and transforming the raw CRM files into the unified CRM-DASHBOARD.md view.
- Metadata Menu: Highly recommended for enforcing data consistency and streamlining input when creating new contacts, organizations, and events.
- Latex Suite: Highly recommended if your academic work involves frequent mathematical or scientific notation, as it dramatically speeds up LaTeX typing.

### 3. Initial Setup

- Clone the Repository: Download the entire Smarty Vault structure onto your local system.
- Run Initialization: Open your system terminal (or the integrated Obsidian Terminal pane) and navigate to the repository's root directory (/).
- Execute the initial setup script: `./init.sh`.
- Create Your Vault: In Obsidian, open the `04.vault/` directory as a new vault.

### 4. Synchronization (Optional but Recommended)

If you need to access your vault across multiple computers, use a third-party synchronization tool:
- Rclone is an excellent choice for syncing the entire directory structure with services like Google Drive, Dropbox, or OneDrive while maintaining local control.
- Alternatively, you can use Obsidian Sync for the contents of the `04.vault/` folder, and a standard cloud service (like Google Drive) for the rest of the `template-root/` and compiled files.

