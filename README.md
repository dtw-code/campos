# CampusPilot AI 🚀

### Your Campus, Organized.

CampusPilot AI is an intelligent campus operating system designed to help students discover opportunities, manage tasks, track deadlines, and turn scattered campus announcements into structured, actionable information.

Built during a hackathon at **KIIT University**, CampusPilot AI aims to bring different parts of student life into one organized platform.

---

## 🎯 Problem

Campus information is often scattered across:

- WhatsApp groups
- College announcements
- Club messages
- Emails
- Posters
- Different student communities

Students can easily miss:

- Events
- Registration deadlines
- Hackathons
- Workshops
- Career opportunities
- Important tasks

CampusPilot AI solves this by creating a centralized campus workspace where students can discover opportunities and keep track of what they need to do.

---

## 💡 Our Solution

CampusPilot AI provides a single platform for managing campus life.

### Core Features

- 📊 **Dashboard**
  - View upcoming events
  - Track pending tasks
  - Monitor upcoming deadlines
  - See completed tasks

- 🔎 **Discover Events**
  - Find hackathons
  - Workshops
  - Career opportunities
  - Competitions
  - Student club events

- ✅ **Task Management**
  - Create tasks
  - Assign priorities
  - Set deadlines
  - Mark tasks as completed

- 📥 **AI Announcement Inbox**
  - Paste a campus announcement
  - Extract useful information
  - Identify event dates
  - Find registration deadlines
  - Extract venue and eligibility information
  - Convert announcements into actionable tasks

- 🤖 **Campus AI Search**
  - Ask questions about campus opportunities
  - Search events and deadlines
  - Find relevant information from campus knowledge

- 🗓️ **Calendar Integration**
  - Keep track of important dates
  - Connect events and tasks with the student's schedule

- 🔐 **Role-Based Experience**
  - Student view
  - Club Coordinator view

---

## 🏗️ Tech Stack

### Frontend

- Flutter
- Dart
- Material UI

### Backend

- Node.js
- Express.js
- REST APIs

### Database / Knowledge Management

- Notion API
- Notion databases

### AI

- LLM-powered announcement extraction
- AI-powered campus search

---

## 🧠 Architecture

```text
                    ┌─────────────────────┐
                    │      Student        │
                    │    Flutter App      │
                    └──────────┬──────────┘
                               │
                               │ REST API
                               ▼
                    ┌─────────────────────┐
                    │   Node.js / Express │
                    │       Backend       │
                    └──────────┬──────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
        ┌────────────┐  ┌────────────┐  ┌────────────┐
        │ Notion API │  │ AI / LLM   │  │   Events   │
        │            │  │   Layer    │  │   & Tasks  │
        └────────────┘  └────────────┘  └────────────┘
