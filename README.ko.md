# 🌀 Juanjuan Team

**Claude Code 최초의 적대적 협업 멀티 에이전트 Skill — 단일 에이전트 인지 터널링을 해결하기 위해 구축.**

> 하나의 LLM에게 설계, 빌드, 리뷰를 모두 맡기지 마세요. Juanjuan Team은 7명의 전문 에이전트를 실행하여 각 산출물을 독립적으로 분석, 토론, 감사합니다 — 에러가 사용자에게 도달하기 전에 잡아냅니다.

[![License: Personal Use](https://img.shields.io/badge/License-Personal%20Use-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet)](https://claude.com/claude-code)
[![Status: v1.0](https://img.shields.io/badge/status-v1.0%20stable-brightgreen)](#)

🌐 **언어:** [中文](README.md) | [English](README.en.md) | [日本語](README.ja.md) | **한국어**

---

## 🎯 왜 Juanjuan Team인가?

모든 시니어 엔지니어는 단일 LLM이 나선형에 빠지는 것을 본 적이 있을 것입니다: 결함이 있는 아키텍처를 설계하고, 구현한 다음, 자신의 작업을 "리뷰"하고 같은 결함을 승인합니다. 버그가 출하됩니다. **Juanjuan Team은 이것을 불가능하게 만들기 위해 존재합니다.**

**적대적 협업**(adversarial collaboration)에 기반하여 구축 — 인간 코드 리뷰가 작동하는 것과 같은 원리 — 모든 의미 있는 결정은 3개 이상의 에이전트가 독립적으로 분석하며, 제출 전에는 서로의 의견을 볼 수 없습니다.

### ⚡ 30초 피치

| 단일 에이전트 | Juanjuan Team |
|-------------|---------------|
| 설계 + 구현 + 리뷰를 혼자 | 7개 에이전트가 설계, 구현, 리뷰에 분산 |
| 자신의 실수 승인 (인지 터널링) | Reviewer는 코드/문서 작성이 구조적으로 금지 (자기 추천 없음) |
| 세션 간 모두 잊음 | Ruflo 메모리에 자동 저장 + 다음 프로젝트에서 자동 호출 |
| 프로젝트 분리 없음 | 날짜가 있는 프로젝트 디렉토리 + 스마트 백업 자동 생성 |
| 원샷 결정 | 가중 결정 엔진 (기술 30% + 가치 25% + 유지보수성 20% + 보안 15% + 비용 10%) |

---

## 🆚 다른 멀티 에이전트 프레임워크와의 차이

| 프레임워크 | 접근 | 약점 | Juanjuan Team의 답 |
|-----------|---------|----------|------------------------|
| **CrewAI** | 역할 기반 에이전트, 순차 작업 | 역할이 서로의 출력을 읽을 수 있음 → 그룹싱크 | **독립 리뷰 강제**: reviewer는 제출 전 다른 에이전트 의견을 볼 수 없음 |
| **LangGraph** | 그래프 기반 워크플로우 | 흐름에 집중, 적대적 사고 없음 | **토론 프로토콜 내장**: Proposer → Critic → Optimizer → Judge |
| **AutoGen** | 대화형 에이전트 | 모든 에이전트가 자유롭게 말함 → 혼돈 | **단일 창구 정책**: Convener만 사용자와 대화, 나머지 6개는 내부 조정 |
| **OpenAI Swarm** | 경량 핸드오프 | 메모리 없음, 감사 없음 | **메모리 + 상태 머신**: 모든 작업에 수명 주기, 모든 교훈 저장 |
| **Claude Subagents** | 원샷 작업 위임 | 팀 일관성 없음 | **캐릭터가 있는 7역할 팀**: 각 에이전트에 정체성, 금지사항, 에러 처리 |

### 🌟 Juanjuan Team만의 5가지 특징

1. **구조적 자기 추천 방지** — Reviewer는 계약상 코드 또는 문서 작성이 금지. "1줄 수정"도 거부. 문제는 지적만 가능, 자체 수정 불가.

2. **적대적 토론 프로토콜** — 중요한 결정마다 4개 역할을 기존 에이전트가 담당: **Proposer**(architect) → **Critic**(reviewer) → **Optimizer**(convener) → **Judge**(leader). 신규 에이전트 불필요.

3. **가중 결정 엔진** — 3개 해결책이 충돌할 때 투표하지 않음. 점수화: `기술적 실현가능성 × 30% + 사용자 가치 × 25% + 유지보수성 × 20% + 보안 × 15% + 비용 × 10%`. LEVEL A/B/C/D가 에스컬레이션 결정.

4. **시크릿 블랙리스트가 있는 스마트 백업** — `git diff > 200줄` OR `파일 변경 > 5`일 때 자동 백업. 20+ 시크릿 패턴 제외(`.env`, `id_rsa`, `.aws/credentials`, `*.keystore`, `*.kdbx` 등). 디스크 낭비 방지를 위한 일일 3회 상한.

5. **Claude Code 내장 명령어 비의존** — Claude Code가 `/review`와 `deep search`를 비활성화한 후에도 작동. Reviewer 서브에이전트가 `/review` 대체, `memory_search` + `kimi-webbridge`가 `deep search` 대체.

---

## 🏗️ 아키텍처

```
                    사용자 (卷卷)
                       │
                  Convener (유일 대화 창구)
                       │
                    Leader
                       │
        ┌──────────────┼──────────────┐
        │              │              │
   Architect       Reviewer    Docs-Researcher
   (Proposer)     (Critic)     (Memory)
                       │
              ┌────────┴────────┐
              │                 │
          Frontend            Coder
```

### 11단계 워크플로우

```
Phase 0  브레인스토밍      Phase 6  문서 리뷰
Phase 1  모드 선택          Phase 7  구현 (frontend + coder 병렬)
Phase 2  프로젝트 디렉토리  Phase 8  코드 리뷰 (OWASP Top 10 + 80% 커버리지)
Phase 3  A/B/C 제안         Phase 9  스마트 백업 (tar.gz + git bundle)
Phase 4  적대적 감사        Phase 10 메모리 저장
Phase 5  명세서             Phase 11 보고
```

### 4가지 실행 모드

| 모드 | 동작 | 사용 시기 |
|------|---------|----------|
| **Safe** | 모든 단계 감사 + 사용자가 각 단계 확인 | 프로덕션, 되돌릴 수 없는 변경 |
| **Normal** | 팀은 브레인스토밍만, 사용자가 모두 감사 | 사용자가 완전 제어 원할 때 |
| **Auto** | 팀 감사, 어려운 선택만 에스컬레이션 | 일일 추천 |
| **YOLO** | 완전 자율, 하이브마인드 투표 | 신뢰 팀, 빠른 출력 |

---

## 📦 설치

### 옵션 A: gh CLI로 1줄

```bash
gh repo clone dxkjuanjuan/juanjuan-team ~/.claude/skills/juanjuan-team
```

### 옵션 B: 수동

```bash
git clone https://github.com/dxkjuanjuan/juanjuan-team.git ~/.claude/skills/juanjuan-team
chmod +x ~/.claude/skills/juanjuan-team/references/backup-script.sh
chmod +x ~/.claude/skills/juanjuan-team/scripts/*.sh
```

### 전제조건

- **Claude Code 2.0+** (skill 시스템)
- **Ruflo MCP 서버** 설정 (`mcp__claude-flow__*` 도구용)
  ```bash
  claude mcp add claude-flow -- npx -y ruflo@latest mcp start
  ```
- **Bash + git** (백업 스크립트용)

### 설치 확인

Claude Code 재시작 후, 아무 대화에서:

```
用卷卷 skill
```

(또는 `juanjuan skill` / `用 juanjuan team`)

Convener가 자기소개하고 무엇에 작업하고 싶은지 물어봅니다.

---

## 🤖 지원 에이전트 플랫폼

Juanjuan Team은 주로 **Claude Code**용으로 설계되었지만, 다른 AI 코딩 에이전트에도 적응 가능:

| 에이전트 | 사용 방법 |
|-------|-----------|
| **Claude Code** (주) | skill을 `~/.claude/skills/juanjuan-team/`에 배치. `juanjuan skill` 키워드로 트리거. |
| **Codex CLI** | `references/role-*.md`를 Codex 설정의 시스템 프롬프트로 사용. 7역할 프롬프트는 모델 비의존적. |
| **Gemini CLI** | `role-*.md`를 `.gemini/agent.json`의 시스템 지시로 사용. `kimi-webbridge`를 Gemini의 브라우저 도구로 교체. |
| **Cursor** | 역할 프롬프트를 `.cursorrules` 또는 Cursor의 에이전트 설정에 추가. |
| **Cline** | 역할 프롬프트를 `.clinerules`로 사용. |
| **Continue.dev** | `config.json`에 7역할을 커스텀 에이전트로 설정. |

---

## 🔬 실제 검증

이 skill은 자체 설계로 전투 테스트됨:

1. **3-way LLM 협업으로 설계** (ChatGPT=이론, Claude=구현, Gemini=메타 프롬프팅)
2. **3개 서브에이전트로 자기 감사** (leader/architect/reviewer 역할 플레이) — CRITICAL 5건 + HIGH 8건 발견, 모두 수정
3. **실제 버그 수정으로 Auto 모드 검증** (kaoyan-english-app 누락 페이지):
   - 6페이지를 281줄로 작성 (각 65줄 이하)
   - Reviewer가 3건의 minor 문제 지적, critical 0건
   - OWASP Top 10 모두 N/A (`dangerouslySetInnerHTML` 미사용으로 XSS 회피)
   - 빌드 통과, 백업 생성, 메모리 저장

---

## 📜 라이선스

[Personal Use Only](LICENSE) — 개인 사용(학습, 개인 프로젝트, 학술 연구, 개인 개발자 워크플로)은 무료. 상업적 사용은 서면 허가 없이 금지. 자세한 내용은 [LICENSE](LICENSE) 참조.

## 🙏 감사의 말

이 프로젝트는 거인의 어깨 위에 서 있습니다. Juanjuan Team을 가능하게 한 오픈소스 프로젝트에 감사드립니다:

- **[SuperPower](https://github.com/obra/superpowers-marketplace)** — 브레인스토밍, TDD, systematic-debugging, writing-plans, verification-before-completion 등의 서브에이전트 방법론이 역할 할당(`references/skill-allocation.md`)에 통합되어 있습니다. `superpowers:brainstorming`이 Phase 0의 메인 진입점입니다.
- **[Ruflo / Claude Flow](https://github.com/ruvnet/ruflo)** — MCP 도구(`swarm_init`, `agent_spawn`, `memory_search`, `memory_store`, `hive-mind_consensus`)가 7 에이전트 팀의 실행 엔진입니다. ruvLLM 자가 학습 계층은 차별화 우위로 보존됩니다.
- **[ECC (Essential Claude Code) Rules](https://github.com/)** — `code-review`, `security-review`, `build-fix`, `kimi-webbridge` 등의 스킬이 역할별로 할당됩니다. `global-rules.md`의 10개 하드 제약은 ECC의 코딩 스타일, 테스트, 성능, 보안 표준에 정렬되어 있습니다.

이 프로젝트들이 없었다면 Juanjuan Team은 존재하지 않았을 것입니다. 이 커뮤니티의 모든 기여자에게 감사드립니다.

## 🌟 Star 부탁드립니다

Juanjuan Team이 단일 에이전트 재난에서 구해주었다면, ⭐ star를 부탁드립니다 — 다른 사람들이 찾기 쉬워집니다.

---

**🌀 [dxkjuanjuan](https://github.com/dxkjuanjuan) 제작**
