# FamilyFlow

**English** · [中文](#中文)

FamilyFlow helps parents and teenagers see how each of them experiences the family's parenting style, and turns the difference into one small weekly challenge.

- **Two views, one chart.** A parent rates their own parenting. Each child (13+) rates each parent. Both land on the same Warmth × Demandingness chart.
- **Private by design.** Parents see a child's overall scores, never individual answers.
- **Real families.** Invite codes with parent approval, multiple parents and children per family, live sync across phones.
- **Act on it.** An advice library for every parenting style, plus weekly family challenges with daily check-ins and reminders.
- **Bilingual.** Simplified Chinese and English.

> Status: being rebuilt from a hackathon prototype into a launch-ready app. See the [roadmap](docs/ROADMAP.md).

_Screenshots: coming at M7._

### Tech
Flutter (Android + iOS) · Firebase Auth, Cloud Firestore, Crashlytics · go_router · provider (MVVM, official Flutter architecture) · fl_chart · Firestore security rules with emulator tests · GitHub Actions CI.

### Docs
| | |
|---|---|
| [Product requirements](docs/PRD.md) | users, features, non-goals |
| [Architecture](docs/ARCHITECTURE.md) | layers, folders, testing, CI |
| [Data model](docs/DATA_MODEL.md) | Firestore schema and rules |
| [Assessment](docs/ASSESSMENT.md) | scoring model and content guide |
| [Privacy](docs/PRIVACY.md) | data inventory, age gate, deletion |
| [Release](docs/RELEASE.md) | signing and distribution |
| [Decisions](docs/adr/) | architecture decision records |
| [Glossary](GLOSSARY.md) | domain terms (en ↔ zh) |

### Getting started
You will need the Flutter SDK (stable), Android Studio, Node 20+, and the Firebase CLI.

```bash
npm i -g firebase-tools
firebase emulators:start --only auth,firestore
flutter run --flavor dev --dart-define=ENV=dev
```

FamilyFlow is a self-reflection tool, not a psychological assessment.

---

## 中文

FamilyFlow 帮助父母和青少年子女看清彼此眼中的家庭教养方式，并把差距变成每周一个小小的亲子挑战。

- **两个视角，一张图**：家长自评，每个孩子（13 岁以上）分别评每位家长，结果落在同一张“温暖回应 × 规则要求”四象限图上。
- **隐私优先**：家长只能看到孩子的总体得分，看不到孩子每道题的答案。
- **真正的家庭**：邀请码 + 家长审批加入，支持多位家长和多个孩子，多台手机实时同步。
- **落到行动**：按四种教养方式分类的建议库，以及每周亲子挑战、每日打卡和提醒。
- **双语**：简体中文与英文。

> 状态：正在把黑客松原型重建为可上线的产品，进度见[路线图](docs/ROADMAP.md)。

技术栈：Flutter（Android + iOS）、Firebase Auth、Cloud Firestore、Crashlytics、go_router、provider（MVVM，Flutter 官方架构）、fl_chart、带模拟器测试的 Firestore 安全规则、GitHub Actions CI。

文档目前为英文，术语中英对照见 [GLOSSARY.md](GLOSSARY.md)。

本应用是帮助家庭自我反思的工具，不是心理诊断。
