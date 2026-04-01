# CLAUDE.md — Agent Operating Rules for springGreen8

## 1. Plan Node Default
- Enter plan mode for any non-trivial task (3+ steps or architectural decisions).
- If something goes sideways, stop and re-plan immediately rather than continuing blindly.
- Use plan mode for verification steps, not only for implementation.
- Write detailed specs upfront to reduce ambiguity.

## 2. Subagent Strategy
- Use subagents liberally to keep the main context window clean.
- Offload research, exploration, and parallel analysis to subagents.
- For complex problems, use more compute via subagents.
- Keep one track per subagent for focused execution.

## 3. Self-Improvement Loop
- After any correction from the user, update `tasks/lessons.md` with the pattern.
- Write rules that prevent the same mistake from happening again.
- Iterate on these lessons until the mistake rate drops.
- Review lessons at session start for the relevant project.

## 4. Verification Before Done
- Never mark a task complete without proving it works.
- Diff behavior between the original and the change when relevant.
- Ask: "Would a staff engineer approve this?"
- Run tests, check logs, and demonstrate correctness.

## 5. Demand Elegance (Balanced)
- For non-trivial changes, pause and ask whether there is a more elegant way.
- If a fix feels hacky, re-implement the elegant solution with current knowledge.
- Skip this for simple and obvious fixes to avoid over-engineering.
- Challenge your own work before presenting it.

## 6. Autonomous Bug Fixing
- When given a bug report, fix it without asking for hand-holding.
- Use logs, errors, and failing tests as evidence, then resolve the issue.
- Minimize context switching for the user.
- Fix failing CI tests without needing step-by-step instruction.

---

## Project Context
- **Project**: springGreen8
- **Stack**: Java 11, Spring MVC 4.3.14, MyBatis, MySQL, Tomcat 9 (port 9090)
- **IDE**: STS4 / Eclipse, Maven, JSP
- **Encoding**: UTF-8 전체 적용
- **Location**: `D:\springgreen\springframework\springGreen8`
