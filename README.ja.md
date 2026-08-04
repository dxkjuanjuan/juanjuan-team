# 🌀 Juanjuan Team

**Claude Code初の対抗型コラボレーション・マルチエージェントSkill — 単一エージェントの認知的トンネリングを解決するために構築。**

> 単一のLLMに設計・構築・レビューを任せないでください。Juanjuan Teamは7人の専門エージェントを起動し、各成果物を独立して分析・議論・監査します — エラーがあなたに届く前に発見されます。

[![License: Personal Use](https://img.shields.io/badge/License-Personal%20Use-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-blueviolet)](https://claude.com/claude-code)
[![Status: v1.0](https://img.shields.io/badge/status-v1.0%20stable-brightgreen)](#)

🌐 **言語:** [中文](README.md) | [English](README.en.md) | **日本語** | [한국어](README.ko.md)

---

## 🎯 なぜ Juanjuan Team なのか？

シニアエンジニアなら、単一のLLMがスパイラルに陥るのを見たことがあるでしょう。欠陥のあるアーキテクチャを設計し、実装し、自分自身の作業を「レビュー」して同じ欠陥を承認します。バグは出荷されます。**Juanjuan Teamはこれを不可能にするために存在します。**

**対抗型コラボレーション**（adversarial collaboration）に基づいて構築 — 人間のコードレビューが機能するのと同じ原則 — 意味のある決定はすべて、3人以上のエージェントが独自に分析し、提出前に互いの意見を見ることはありません。

### ⚡ 30秒ピッチ

| 単一エージェント | Juanjuan Team |
|-------------|---------------|
| 設計・実装・レビューを単独で | 7エージェントが設計・実装・レビューに分割 |
| 自分の間違いを承認（認知的トンネリング） | レビューアーはコード/ドキュメント作成が構造的に禁止（自己推薦なし） |
| セッション間ですべて忘れる | Rufloメモリに自動保存 + 次回プロジェクトで自動呼び出し |
| プロジェクト分離なし | 日付付きプロジェクトディレクトリ + スマートバックアップを自動作成 |
| ワンショット決定 | 重み付け決定エンジン（技術30% + 価値25% + 保守性20% + セキュリティ15% + コスト10%） |

---

## 🆚 他のマルチエージェントフレームワークとの違い

| フレームワーク | アプローチ | 弱点 | Juanjuan Teamの回答 |
|-----------|---------|----------|------------------------|
| **CrewAI** | 役割ベースエージェント、順次タスク | 役割が互いの出力を読める → グループシンク | **独立レビュー強制**: レビューアーは提出前に他エージェントの意見を見られない |
| **LangGraph** | グラフベースワークフロー | フロー重視、対抗思考なし | **議論プロトコル内蔵**: Proposer → Critic → Optimizer → Judge |
| **AutoGen** | 会話型エージェント | 全エージェントが自由に話す → カオス | **単一ウィンドウポリシー**: Convenerのみがユーザーと話す、他6人は内部調整 |
| **OpenAI Swarm** | 軽量ハンドオフ | メモリなし、監査なし | **メモリ + 状態機械**: 全タスクにライフサイクル、全教訓を保存 |
| **Claude Subagents** | ワンショットタスク委譲 | チームの一貫性なし | **キャラクター付き7役チーム**: 各エージェントにアイデンティティ、禁止事項、エラー処理 |

### 🌟 Juanjuan Teamだけの5つの特徴

1. **構造的反自己推薦** — レビューアーは契約上コードまたはドキュメントの作成が禁止。「ちょっとした1行修正」も拒否。問題は指摘のみ、自己修正不可。

2. **対抗型議論プロトコル** — 重要な決定ごとに、4つの役割を既存エージェントが担当: **Proposer**（architect）→ **Critic**（reviewer）→ **Optimizer**（convener）→ **Judge**（leader）。新規エージェント不要。

3. **重み付け決定エンジン** — 3つの解決策が競合する時、投票しない。スコア付け: `技術的実現可能性 × 30% + ユーザー価値 × 25% + 保守性 × 20% + セキュリティ × 15% + コスト × 10%`。LEVEL A/B/C/Dでエスカレーション決定。

4. **シークレットブラックリスト付きスマートバックアップ** — `git diff > 200行` OR `ファイル変更 > 5`で自動バックアップ。20+のシークレットパターンを除外（`.env`、`id_rsa`、`.aws/credentials`、`*.keystore`、`*.kdbx`など）。ディスク浪費防止のため1日3回上限。

5. **Claude Code組み込みコマンドへの非依存** — Claude Codeが`/review`と`deep search`を無効化した後も動作。Reviewerサブエージェントが`/review`を代替、`memory_search` + `kimi-webbridge`が`deep search`を代替。

---

## 🏗️ アーキテクチャ

```
                    ユーザー (卷卷)
                       │
                  Convener (唯一の対話窓口)
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

### 11フェーズワークフロー

```
Phase 0  ブレインストーム      Phase 6  ドキュメントレビュー
Phase 1  モード選択            Phase 7  実装 (frontend + coder 並列)
Phase 2  プロジェクトディレクトリ Phase 8  コードレビュー (OWASP Top 10 + 80%カバレッジ)
Phase 3  A/B/C提案            Phase 9  スマートバックアップ (tar.gz + git bundle)
Phase 4  対抗型監査            Phase 10 メモリ保存
Phase 5  仕様書               Phase 11 報告
```

### 4つの実行モード

| モード | 振る舞い | 使用場面 |
|------|---------|----------|
| **Safe** | 全フェーズ監査 + ユーザーが各ステップ確認 | 本番、取り消し不能な変更 |
| **Normal** | チームはブレインストームのみ、ユーザーが全監査 | ユーザーが完全制御したい時 |
| **Auto** | チーム監査、困難な選択のみエスカレーション | 日常推奨 |
| **YOLO** | 完全自律、ハイブマインド投票 | 信頼チーム、高速出力 |

---

## 📦 インストール

### オプションA: gh CLIで1行

```bash
gh repo clone dxkjuanjuan/juanjuan-team ~/.claude/skills/juanjuan-team
```

### オプションB: 手動

```bash
git clone https://github.com/dxkjuanjuan/juanjuan-team.git ~/.claude/skills/juanjuan-team
chmod +x ~/.claude/skills/juanjuan-team/references/backup-script.sh
chmod +x ~/.claude/skills/juanjuan-team/scripts/*.sh
```

### 前提条件

- **Claude Code 2.0+**（skillシステム）
- **Ruflo MCPサーバー**設定済み（`mcp__claude-flow__*`ツール用）
  ```bash
  claude mcp add claude-flow -- npx -y ruflo@latest mcp start
  ```
- **Bash + git**（バックアップスクリプト用）

### インストール確認

Claude Codeを再起動後、任意の会話で:

```
用卷卷 skill
```

（または `juanjuan skill` / `用 juanjuan team`）

Convenerが自己紹介し、何に取り組みたいか聞いてきます。

---

## 🤖 対応エージェントプラットフォーム

Juanjuan Teamは主に**Claude Code**向けに設計されていますが、他のAIコーディングエージェントにも適応可能:

| エージェント | 使用方法 |
|-------|-----------|
| **Claude Code**（主要） | skillを`~/.claude/skills/juanjuan-team/`に配置。`juanjuan skill`等のキーワードで起動。 |
| **Codex CLI** | `references/role-*.md`をCodex設定のシステムプロンプトとして使用。7役プロンプトはモデル非依存。 |
| **Gemini CLI** | `role-*.md`を`.gemini/agent.json`のシステム指示として使用。`kimi-webbridge`をGeminiのブラウザツールに置き換え。 |
| **Cursor** | 役割プロンプトを`.cursorrules`またはCursorのエージェント設定に追加。 |
| **Cline** | 役割プロンプトを`.clinerules`として使用。 |
| **Continue.dev** | `config.json`に7役をカスタムエージェントとして設定。 |

---

## 🔬 実世界検証

このskillは自身の設計で戦闘テスト済み:

1. **3way LLMコラボレーションで設計**（ChatGPT=理論、Claude=実装、Gemini=メタプロンプト）
2. **3サブエージェントで自己監査**（leader/architect/reviewer役をプレイ）— CRITICAL 5件 + HIGH 8件を発見、すべて修正
3. **実バグ修正でAutoモード検証**（kaoyan-english-appの欠落ページ）:
   - 6ページを281行で作成（各65行以下）
   - Reviewerが3件のminor問題を指摘、critical 0件
   - OWASP Top 10すべてN/A（`dangerouslySetInnerHTML`を使わずXSS回避）
   - ビルド成功、バックアップ作成、メモリ保存

---

## 📜 ライセンス

[Personal Use Only](LICENSE) — 個人利用（学習、個人プロジェクト、学術研究、個人開発者のワークフロー）は無料。商用利用は許可なく禁止。詳細は [LICENSE](LICENSE) を参照。

## 🙏 謝辞

このプロジェクトは巨人の肩の上に立っています。Juanjuan Team の実現を可能にしたオープンソースプロジェクトに感謝します：

- **[SuperPower](https://github.com/obra/superpowers-marketplace)** — ブレインストーミング、TDD、systematic-debugging、writing-plans、verification-before-completion などのサブエージェント手法が役割割り当て (`references/skill-allocation.md`) に統合されています。`superpowers:brainstorming` が Phase 0 のメインエントリです。
- **[Ruflo / Claude Flow](https://github.com/ruvnet/ruflo)** — MCP ツール（`swarm_init`, `agent_spawn`, `memory_search`, `memory_store`, `hive-mind_consensus`）が 7 エージェントチームの実行エンジンです。ruvLLM 自己学習層は差別化優位として保持しています。
- **[ECC (Essential Claude Code) Rules](https://github.com/)** — `code-review`, `security-review`, `build-fix`, `kimi-webbridge` などのスキルが役割別に割り当てられています。`global-rules.md` の 10 の硬い制約は ECC のコーディングスタイル、テスト、パフォーマンス、セキュリティ基準に準拠しています。

これらのプロジェクトがなければ Juanjuan Team は存在しません。コミュニティのすべての貢献者に感謝します。

## 🌟 Starをお願いします

Juanjuan Teamが単一エージェントの災難から救ってくれたなら、⭐ starをお願いします — 他の人が見つけやすくなります。

---

**🌀 [dxkjuanjuan](https://github.com/dxkjuanjuan) により作成**
