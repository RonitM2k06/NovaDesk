# Module Guide

This document outlines the core modules contained within `Sources/Modules` and their respective responsibilities.

## Dashboard
Provides a customizable widget layout grid. Aggregates native macOS system metrics (CPU, Memory, Disk) using Mach kernel APIs (`host_statistics64`).

## Project Manager
Asynchronously scans directories to detect software repositories. Heuristically identifies languages (Swift, Python, Java, etc.) based on manifest files and Git presence.

## Notes & Snippets
Both modules leverage SwiftData for persistence. 
- Notes features a hierarchical folder system and autosave.
- Snippets features multi-language tagging and AppKit clipboard (`NSPasteboard`) integration.

## Markdown Workspace
Implements an HTML bridging engine (`MarkdownEngine`) to bypass heavy native dependencies, utilizing a transparent `WKWebView` to render Github-flavored Markdown, Mermaid diagrams, and MathJax equations in real-time alongside a native SwiftUI `TextEditor`.

## Git Workspace
Wraps the system `/usr/bin/git` binary via Foundation `Process` for a secure, asynchronous Git client. Features staging, unstaging, branching, and commit history parsing.

## GitHub Integration
Provides a Codable REST API client. Uses native macOS `Security` framework to safely persist Personal Access Tokens.

## Global Search
Builds an inverted index of Projects, Notes, Snippets, and application Commands. Uses debounce logic to provide Spotlight-esque real-time filtering without lag.

## Terminal Workspace
Leverages `SwiftTerm` for native terminal emulation. Handles session tabs, pane splitting, and profile switching.

## AI Workspace
Provides an abstraction layer (`AIProviderProtocol`) that supports OpenAI streams (`AsyncThrowingStream`) and Ollama local models. Integrates with SwiftData to persist conversations.

## Workspace Automation
Manages Application State Restoration. Orchestrates `UserDefaults` payload serialization to resume user sessions dynamically upon app launch.
